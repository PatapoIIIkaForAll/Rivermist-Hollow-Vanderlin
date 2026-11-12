/obj/item/paper/enterprise_order
	name = "order note"
	desc = "A note a guest has left for the house: what to bring to their table."
	var/text_en
	var/text_ru

/obj/item/paper/enterprise_order/show_paper_hud(mob/user)
	if(info == text_en || info == text_ru)
		info = get_preferred_ui_language(user) == "ru" ? text_ru : text_en
		updateinfolinks()
	return ..()

/obj/effect/enterprise_meal_bar
	icon = 'icons/effects/progressbar.dmi'
	icon_state = "prog_bar_0"
	plane = ABOVE_HUD_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 32

/datum/enterprise_order
	var/mob/living/simple_animal/enterprise_patron/patron
	var/datum/enterprise/enterprise
	var/state = ENTERPRISE_ORDER_STATE_NOTE
	var/morning = FALSE
	var/obj/item/reagent_containers/food/snacks/dish_type
	var/dish_name
	var/dish_price = 0
	var/datum/reagent/consumable/drink_type
	var/drink_name
	var/list/drink_types
	var/wish = FALSE
	var/drunk = FALSE
	var/turf/note_table
	var/turf/note_spot
	var/datum/weakref/note
	var/deadline = 0
	var/meal_until = 0
	var/bill = 0
	var/list/turf/watched = list()
	var/list/obj/item/plate/plates = list()
	var/obj/effect/enterprise_meal_bar/bar

/datum/enterprise_order/New(mob/living/simple_animal/enterprise_patron/patron, datum/enterprise/enterprise)
	src.patron = patron
	src.enterprise = enterprise
	RegisterSignal(patron, COMSIG_PARENT_QDELETING, PROC_REF(on_patron_gone))
	RegisterSignal(patron, COMSIG_LIVING_DEATH, PROC_REF(on_patron_gone))

/datum/enterprise_order/Destroy()
	unwatch()
	hide_bar()
	drop_note()
	if(patron)
		UnregisterSignal(patron, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
		if(patron.meal_order == src)
			patron.meal_order = null
	patron = null
	enterprise = null
	return ..()

/datum/enterprise_order/proc/on_patron_gone(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/enterprise_order/proc/get_note_text(russian)
	var/minutes = round(enterprise.get_order_wait() / (1 MINUTES))
	var/where = patron.table_set?.room?.get_title(russian)
	if(russian)
		return "<b>Заказ</b><br>[capitalize(patron.name)][where ? ", стол в комнате «[where]»" : ""].<br>Блюдо: [dish_name].<br>Напиток: [drink_name], не меньше [ENTERPRISE_ORDER_DRINK_PORTION] ед.[wish ? " По желанию, если найдётся." : ""]<br>Принесите на мой стол. Жду [minutes] мин."
	return "<b>An order</b><br>[capitalize(patron.name)][where ? ", at a table in [where]" : ""].<br>Dish: [dish_name].<br>Drink: [drink_name], at least [ENTERPRISE_ORDER_DRINK_PORTION] units.[wish ? " Only if the house has any." : ""]<br>Bring them to my table. I shall wait [minutes] minutes."

/datum/enterprise_order/proc/post_note()
	state = ENTERPRISE_ORDER_STATE_WAIT
	var/obj/item/paper/enterprise_order/paper = new(note_table)
	paper.text_en = get_note_text(FALSE)
	paper.text_ru = get_note_text(TRUE)
	paper.info = paper.text_en
	paper.updateinfolinks()
	paper.update_appearance(UPDATE_ICON_STATE)
	note = WEAKREF(paper)
	patron.remark_order(ENTERPRISE_PATRON_LINE_ORDER_NOTE)
	log_game("[enterprise.name]: [patron.name] left an order for [dish_name] and [drink_name][wish ? ", the drink if there is any" : ""].")
	enterprise.guests_changed()

/datum/enterprise_order/proc/drop_note()
	var/obj/item/paper/enterprise_order/paper = note?.resolve()
	note = null
	if(!QDELETED(paper))
		qdel(paper)

/datum/enterprise_order/proc/start_waiting()
	deadline = world.time + enterprise.get_order_wait()
	watch()
	enterprise.guests_changed()
	check_served()

/datum/enterprise_order/proc/watch()
	var/datum/enterprise_seating/seating = patron.table_set
	if(!seating)
		return
	for(var/datum/enterprise_fixture/fixture as anything in seating.tables)
		var/obj/structure/table/table = fixture.get_present(seating.room)
		var/turf/spot = table ? get_turf(table) : fixture.home
		if(!spot || (spot in watched))
			continue
		watched += spot
		RegisterSignal(spot, COMSIG_ATOM_ENTERED, PROC_REF(on_table_entered))
		for(var/obj/item/plate/plate in spot)
			watch_plate(plate)

/datum/enterprise_order/proc/unwatch()
	for(var/turf/spot as anything in watched)
		UnregisterSignal(spot, COMSIG_ATOM_ENTERED)
	watched.Cut()
	for(var/obj/item/plate/plate as anything in plates)
		UnregisterSignal(plate, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_QDELETING))
	plates.Cut()

/datum/enterprise_order/proc/watch_plate(obj/item/plate/plate)
	if(plate in plates)
		return
	plates += plate
	RegisterSignal(plate, COMSIG_ATOM_ENTERED, PROC_REF(on_plate_entered))
	RegisterSignal(plate, COMSIG_PARENT_QDELETING, PROC_REF(on_plate_gone))

/datum/enterprise_order/proc/on_table_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(istype(arrived, /obj/item/plate))
		watch_plate(arrived)
	queue_check()

/datum/enterprise_order/proc/on_plate_entered(obj/item/plate/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(get_turf(source) in watched)
		queue_check()

/datum/enterprise_order/proc/on_plate_gone(obj/item/plate/source)
	SIGNAL_HANDLER
	plates -= source
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_QDELETING))

/datum/enterprise_order/proc/queue_check()
	addtimer(CALLBACK(src, PROC_REF(check_served)), 1, TIMER_UNIQUE)

/datum/enterprise_order/proc/is_dish(obj/item/thing)
	return istype(thing, /obj/item/reagent_containers/food/snacks) && initial(thing.name) == dish_name

/datum/enterprise_order/proc/holds_drink(obj/item/thing)
	if(!istype(thing, /obj/item/reagent_containers) || istype(thing, /obj/item/reagent_containers/food) || !thing.reagents)
		return FALSE
	var/amount = 0
	for(var/drink in drink_types)
		amount += thing.reagents.get_reagent_amount(drink)
	return amount >= ENTERPRISE_ORDER_DRINK_PORTION

/datum/enterprise_order/proc/find_served(drink)
	for(var/turf/spot as anything in watched)
		for(var/obj/item/thing in spot)
			if(drink ? holds_drink(thing) : is_dish(thing))
				return thing
			if(!istype(thing, /obj/item/plate))
				continue
			for(var/obj/item/held in thing)
				if(drink ? holds_drink(held) : is_dish(held))
					return held
	return null

/datum/enterprise_order/proc/check_served()
	if(QDELETED(src) || QDELETED(patron) || patron.get_goal() != ENTERPRISE_PATRON_GOAL_ORDER || patron.goal_stage != ENTERPRISE_PATRON_STAGE_STAY)
		return FALSE
	if(state == ENTERPRISE_ORDER_STATE_MEAL)
		if(!wish || drunk)
			return FALSE
		var/obj/item/reagent_containers/late_drink = find_served(TRUE)
		if(!late_drink)
			return FALSE
		drink_from(late_drink)
		unwatch()
		return TRUE
	if(state != ENTERPRISE_ORDER_STATE_WAIT)
		return FALSE
	var/obj/item/reagent_containers/food/snacks/dish = find_served(FALSE)
	if(!dish)
		return FALSE
	var/obj/item/reagent_containers/cup = find_served(TRUE)
	if(!cup && !wish)
		return FALSE
	start_meal(dish, cup)
	return TRUE

/datum/enterprise_order/proc/drink_from(obj/item/reagent_containers/cup)
	var/left = ENTERPRISE_ORDER_DRINK_PORTION
	for(var/drink in drink_types)
		var/amount = min(left, cup.reagents.get_reagent_amount(drink))
		if(amount <= 0)
			continue
		cup.reagents.remove_reagent(drink, amount)
		bill += amount * enterprise.get_order_drink_price(drink)
		left -= amount
		if(left <= 0)
			break
	drunk = TRUE

/datum/enterprise_order/proc/start_meal(obj/item/reagent_containers/food/snacks/dish, obj/item/reagent_containers/cup)
	state = ENTERPRISE_ORDER_STATE_MEAL
	meal_until = world.time + ENTERPRISE_ORDER_MEAL_TIME
	bill += dish_price
	qdel(dish)
	if(cup)
		drink_from(cup)
	if(!wish || drunk)
		unwatch()
	drop_note()
	show_bar()
	patron.manual_emote("eats.")
	playsound(patron, 'sound/misc/eat.ogg', 50, TRUE)
	enterprise.guests_changed()

/datum/enterprise_order/proc/show_bar()
	if(bar)
		return
	bar = new
	patron.vis_contents += bar

/datum/enterprise_order/proc/update_bar()
	if(!bar)
		return
	var/done = 100 - (meal_until - world.time) * 100 / ENTERPRISE_ORDER_MEAL_TIME
	var/wanted = "prog_bar_[clamp(round(done, 5), 0, 100)]"
	if(bar.icon_state != wanted)
		bar.icon_state = wanted

/datum/enterprise_order/proc/hide_bar()
	if(!bar)
		return
	patron?.vis_contents -= bar
	QDEL_NULL(bar)

/datum/enterprise_order/proc/finish()
	var/mob/living/simple_animal/enterprise_patron/eater = patron
	var/datum/enterprise/house = enterprise
	var/paid = round(bill * ENTERPRISE_ORDER_PRICE_MULTIPLIER)
	log_game("[house.name]: [eater.name] ate [dish_name][drunk ? " with [drink_name]" : ""] and paid [paid].")
	house.log_order(src, TRUE, paid)
	eater.remark_order(ENTERPRISE_PATRON_LINE_ORDER_THANKS)
	eater.end_order()
	house.earn(paid)
	eater.next_goal()

/datum/enterprise_order/proc/get_stay_chance()
	return morning ? 100 - enterprise.get_order_leave_chance() : ENTERPRISE_ORDER_STAY_CHANCE

/datum/enterprise_order/proc/fail()
	var/mob/living/simple_animal/enterprise_patron/waiter = patron
	var/datum/enterprise/house = enterprise
	var/stays = prob(get_stay_chance())
	log_game("[house.name]: [waiter.name] waited in vain for [dish_name] and [stays ? "stayed on" : "left"].")
	house.log_order(src, FALSE, 0)
	waiter.remark_order(ENTERPRISE_PATRON_LINE_ORDER_LATE)
	waiter.end_order()
	if(stays)
		waiter.next_goal()
	else
		waiter.start_leaving()

/mob/living/simple_animal/enterprise_patron
	var/datum/enterprise_order/meal_order
	var/order_tried = FALSE
	var/morning_order = FALSE
	var/static/list/order_lines = list(
		ENTERPRISE_PATRON_LINE_ORDER_NOTE = list(
			"I have left my order on the counter, by the ledger.",
			"My order is on the counter. I shall be at my table.",
		),
		ENTERPRISE_PATRON_LINE_ORDER_THANKS = list(
			"Now that was a meal. My thanks, keeper.",
			"Well served! Here is my coin.",
		),
		ENTERPRISE_PATRON_LINE_ORDER_LATE = list(
			"I have waited long enough. Nobody brought my order.",
			"Still nothing on my table? I am done waiting.",
		),
	)

/mob/living/simple_animal/enterprise_patron/proc/remark_order(kind)
	var/list/choices = order_lines[kind]
	if(length(choices))
		remarks += pick(choices)

/mob/living/simple_animal/enterprise_patron/proc/plan_order()
	if(meal_order || order_tried || !enterprise)
		return meal_order
	order_tried = TRUE
	meal_order = enterprise.make_order(src, morning_order)
	return meal_order

/mob/living/simple_animal/enterprise_patron/proc/end_order()
	order_tried = FALSE
	morning_order = FALSE
	free_table()
	QDEL_NULL(meal_order)

/mob/living/simple_animal/enterprise_patron/proc/tend_order()
	var/datum/enterprise_order/order = meal_order
	if(!order || order.state == ENTERPRISE_ORDER_STATE_NOTE)
		if(!stay_until)
			stay_until = world.time + table_time
		else if(world.time >= stay_until)
			next_goal()
		return
	switch(order.state)
		if(ENTERPRISE_ORDER_STATE_WAIT)
			if(!order.deadline)
				order.start_waiting()
			else if(world.time >= order.deadline)
				order.fail()
		if(ENTERPRISE_ORDER_STATE_MEAL)
			if(world.time >= order.meal_until)
				order.finish()
			else
				order.update_bar()

/mob/living/simple_animal/enterprise_patron/proc/come_out_to_order()
	end_order()
	morning_order = TRUE
	goals.Insert(1, ENTERPRISE_PATRON_GOAL_ORDER)
	goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
	stay_until = 0
	walk_until = 0
	stop_walking()
	leave_seat()

/mob/living/simple_animal/enterprise_patron/proc/get_order_data()
	if(!meal_order || get_goal() != ENTERPRISE_PATRON_GOAL_ORDER)
		return null
	return list(
		"state" = meal_order.state,
		"time_left" = meal_order.deadline ? max(meal_order.deadline - world.time, 0) : null,
		"morning" = meal_order.morning,
	)

/datum/ai_planning_subtree/enterprise_patron/find_table/order
	goal = ENTERPRISE_PATRON_GOAL_ORDER
	walk_type = /datum/ai_behavior/enterprise_patron_walk/order

/datum/ai_planning_subtree/enterprise_patron/find_table/order/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
	if(!istype(patron))
		return
	if(patron.get_goal() != goal)
		if(patron.meal_order || patron.order_tried)
			patron.end_order()
		return
	if(!patron.enterprise)
		return
	if(patron.goal_stage == ENTERPRISE_PATRON_STAGE_STAY)
		patron.tend_order()
		return SUBTREE_RETURN_FINISH_PLANNING
	var/datum/enterprise_order/order = patron.meal_order
	if(patron.goal_stage == ENTERPRISE_PATRON_STAGE_WALK && order?.state == ENTERPRISE_ORDER_STATE_NOTE && patron.z == order.note_table?.z && get_dist(patron, order.note_table) <= 1)
		patron.goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
		patron.walk_until = 0
		patron.stop_walking()
		order.post_note()
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/ai_planning_subtree/enterprise_patron/find_table/order/find_target(mob/living/simple_animal/enterprise_patron/patron)
	. = ..()
	if(!.)
		return
	var/datum/enterprise_order/order = patron.plan_order()
	if(order?.state != ENTERPRISE_ORDER_STATE_NOTE)
		return
	patron.claim_seat(null)
	return order.note_spot

/datum/ai_planning_subtree/enterprise_patron/find_table/order/nothing_found(mob/living/simple_animal/enterprise_patron/patron)
	if(!patron.morning_order)
		return ..()
	patron.remark(ENTERPRISE_PATRON_LINE_NO_TABLE)
	patron.next_goal()

/datum/ai_behavior/enterprise_patron_walk/order/finish_action(datum/ai_controller/controller, succeeded, target_key)
	var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
	if(succeeded && istype(patron) && !QDELETED(patron) && patron.goal_stage == ENTERPRISE_PATRON_STAGE_WALK && patron.meal_order?.state == ENTERPRISE_ORDER_STATE_NOTE)
		patron.goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
		patron.walk_until = 0
		patron.meal_order.post_note()
	return ..()

/datum/enterprise
	var/list/order_dishes
	var/list/order_drinks
	var/list/order_drink_families

/datum/enterprise/proc/get_order_max_tier()
	return clamp(owner_level, 1, ENTERPRISE_ORDER_TOP_TIER)

/datum/enterprise/proc/get_order_wait()
	return max(owner_level, 1) * ENTERPRISE_ORDER_WAIT_PER_LEVEL

/datum/enterprise/proc/get_order_leave_chance()
	return clamp(ENTERPRISE_ORDER_MORNING_LEAVE_BASE - ENTERPRISE_ORDER_MORNING_LEAVE_STEP * owner_level, 0, 100)

/datum/enterprise/proc/has_patron_room_left()
	var/total = 0
	var/taken = 0
	for(var/lock_id in guest_rooms)
		var/datum/enterprise_room/room = guest_rooms[lock_id]
		if(!room.template?.lodges_patrons)
			continue
		total++
		if(room.get_patron())
			taken++
	return (taken + 1) * 2 <= total

/datum/enterprise/proc/is_order_dish(obj/item/reagent_containers/food/snacks/dish)
	if(ispath(dish, /obj/item/reagent_containers/food/snacks/badrecipe) || (initial(dish.foodtype) & RAW))
		return FALSE
	return !ispath(initial(dish.eat_effect), /datum/status_effect/debuff/uncookedfood)

/datum/enterprise/proc/get_order_dish_price(dish_type)
	return round(SSmerchant.get_item_base_value(dish_type))

/datum/enterprise/proc/get_order_dishes()
	if(order_dishes)
		return order_dishes
	order_dishes = list()
	if(!length(GLOB.selectable_foods))
		GLOB.selectable_foods = get_global_selectable_foods()
	for(var/obj/item/reagent_containers/food/snacks/dish as anything in GLOB.selectable_foods)
		if(!is_order_dish(dish) || get_order_dish_price(dish) <= 0)
			continue
		var/tier = "[clamp(initial(dish.faretype) - 1, 0, ENTERPRISE_ORDER_TOP_TIER)]"
		if(!order_dishes[tier])
			order_dishes[tier] = list()
		order_dishes[tier] += dish
	return order_dishes

/datum/enterprise/proc/get_order_drink_tier(datum/reagent/consumable/drink_type)
	return clamp(initial(drink_type.quality), 0, ENTERPRISE_ORDER_TOP_TIER)

/datum/enterprise/proc/note_order_drink(datum/reagent/consumable/drink_type, list/family)
	if(!ispath(drink_type, /datum/reagent/consumable/ethanol) || drink_type == /datum/reagent/consumable/ethanol)
		return
	var/list/known = order_drink_families[drink_type]
	if(known)
		order_drink_families[drink_type] = known | family
		return
	order_drink_families[drink_type] = family.Copy()
	var/tier = "[get_order_drink_tier(drink_type)]"
	if(!order_drinks[tier])
		order_drinks[tier] = list()
	order_drinks[tier] += drink_type

/datum/enterprise/proc/get_order_drinks()
	if(order_drinks)
		return order_drinks
	order_drinks = list()
	order_drink_families = list()
	for(var/list/entry as anything in enterprise_drink_entries())
		note_order_drink(entry[1], entry[3])
	return order_drinks

/datum/enterprise/proc/get_order_drink_price(drink_type)
	return enterprise_drink_unit_price(drink_type)

/datum/enterprise/proc/pick_by_tier(list/pool, tier)
	for(var/lower = tier, lower >= 0, lower--)
		var/list/found = pool["[lower]"]
		if(length(found))
			return pick(found)
	return null

/datum/enterprise/proc/get_table_group(turf/start)
	var/list/turf/group = list(start)
	var/position = 1
	while(position <= length(group))
		var/turf/current = group[position]
		position++
		for(var/direction in GLOB.cardinals)
			var/turf/next = get_step(current, direction)
			if(next && !(next in group) && (locate(/obj/structure/table) in next) && contains(next))
				group += next
	return group

/datum/enterprise/proc/find_note_table()
	var/turf/best
	var/best_distance = INFINITY
	for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in ledgers)
		var/turf/origin = get_turf(ledger)
		if(!origin)
			continue
		var/list/turf/checked = list()
		for(var/obj/structure/table/table in range(ENTERPRISE_ORDER_NOTE_REACH, origin))
			var/turf/spot = get_turf(table)
			if(!spot || spot.z != origin.z || (spot in checked) || !contains(spot))
				continue
			var/list/turf/group = get_table_group(spot)
			checked += group
			if(length(group) < ENTERPRISE_ORDER_NOTE_TABLE_MIN)
				continue
			for(var/turf/piece as anything in group)
				var/distance = get_dist(origin, piece)
				if(distance < best_distance)
					best = piece
					best_distance = distance
	return best

/datum/enterprise/proc/get_note_stand(turf/table_turf, atom/near)
	var/list/turf/spots = list()
	for(var/direction in GLOB.cardinals)
		var/turf/spot = get_step(table_turf, direction)
		if(!spot || isclosedturf(spot) || !contains(spot) || spot.is_blocked_turf(FALSE) || (locate(/obj/structure/table) in spot))
			continue
		spots[spot] = get_dist(spot, near) + ((locate(/obj/structure/chair) in spot) ? ENTERPRISE_ORDER_CHAIR_PENALTY : 0)
	var/mob/living/simple_animal/enterprise_patron/walker = near
	while(length(spots))
		var/turf/best
		for(var/turf/spot as anything in spots)
			if(!best || spots[spot] < spots[best])
				best = spot
		if(!istype(walker) || walker.can_walk_to(best))
			return best
		spots -= best
	return null

/mob/living/simple_animal/enterprise_patron/proc/can_walk_to(atom/target)
	var/turf/start = get_turf(src)
	var/turf/end = get_turf(target)
	if(!start || !end)
		return FALSE
	if(start == end)
		return TRUE
	return length(AStar(src, end, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), ENTERPRISE_PATRON_PATH_REACH, ENTERPRISE_PATRON_PATH_REACH, 0)) > 0

/datum/enterprise/proc/make_order(mob/living/simple_animal/enterprise_patron/patron, morning)
	var/turf/table_turf = find_note_table()
	var/turf/stand = table_turf ? get_note_stand(table_turf, patron) : null
	if(!stand)
		return null
	var/max_tier = get_order_max_tier()
	var/obj/item/reagent_containers/food/snacks/dish = pick_by_tier(get_order_dishes(), rand(0, max_tier))
	var/datum/reagent/consumable/drink = pick_by_tier(get_order_drinks(), rand(0, max_tier))
	if(!dish || !drink)
		return null
	var/datum/enterprise_order/order = new(patron, src)
	order.morning = morning
	order.note_table = table_turf
	order.note_spot = stand
	order.dish_type = dish
	order.dish_name = initial(dish.name)
	order.dish_price = get_order_dish_price(dish)
	order.drink_type = drink
	order.drink_name = initial(drink.name)
	order.drink_types = order_drink_families[drink] || list(drink)
	order.wish = get_order_drink_tier(drink) >= ENTERPRISE_ORDER_WISH_TIER
	return order

/datum/enterprise/proc/send_lodgers_to_order()
	return call_lodgers_to_order(owner_level * ENTERPRISE_ORDER_MORNING_CHANCE)

/datum/enterprise/proc/call_lodgers_to_order(chance)
	if(chance <= 0)
		return 0
	var/count = 0
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		if(patron.leaving || !patron.lodging || patron.get_goal() != ENTERPRISE_PATRON_GOAL_ROOM || patron.goal_stage != ENTERPRISE_PATRON_STAGE_STAY || !prob(chance))
			continue
		patron.come_out_to_order()
		count++
	if(count)
		log_game("[name]: [count] of the lodgers came out to order.")
		guests_changed()
	return count
