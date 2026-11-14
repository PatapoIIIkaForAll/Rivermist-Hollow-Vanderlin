/datum/enterprise_room_template
	abstract_type = /datum/enterprise_room_template
	var/id
	var/name
	var/name_ru
	var/priority = 100
	var/grouped = FALSE
	var/claims_kind
	var/lodges_patrons = FALSE
	var/grant_group
	var/grant_rank = 1
	var/grant_shuffled = FALSE
	var/seats_patrons = FALSE

/datum/enterprise_room_template/proc/matches(datum/enterprise_room/room)
	return FALSE

/datum/enterprise_room_template/proc/report_unmatched(datum/enterprise_room/room)
	return

/datum/enterprise_room_template/proc/joins_premises(list/turf/inside)
	return FALSE

/datum/enterprise_room_template/proc/claim_outside(datum/enterprise/enterprise, list/found_by_z, alist/seen)
	return list()

/datum/enterprise_room_template/proc/get_store_count(datum/enterprise_room/room)
	return null

/datum/enterprise_room_template/proc/get_effect(datum/enterprise_room/room, level, russian)
	return null

/datum/enterprise_room_template/proc/on_survey(datum/enterprise_room/room)
	return

/datum/enterprise_room_template/proc/on_rest(datum/enterprise_room/room, mob/living/carbon/human/sleeper)
	return FALSE

/datum/enterprise_room_template/proc/on_meal(datum/enterprise_room/room, mob/living/eater, datum/enterprise_seating/seating)
	return FALSE

/datum/enterprise_room_template/guest_room
	id = ENTERPRISE_PURPOSE_GUEST_ROOM
	name = "Guest room"
	name_ru = "Жилая комната"
	priority = 10
	claims_kind = ENTERPRISE_ROOM_GUEST
	lodges_patrons = TRUE
	grant_group = ENTERPRISE_GRANT_LIVING
	grant_rank = 2
	grant_shuffled = TRUE
	var/list/needs = list(
		/obj/structure/bed,
		/obj/structure/closet,
	)

/datum/enterprise_room_template/guest_room/matches(datum/enterprise_room/room)
	if(room.kind != ENTERPRISE_ROOM_GUEST)
		return FALSE
	for(var/need in needs)
		if(!room.count_listed(need))
			return FALSE
	return TRUE

/datum/enterprise_room_template/guest_room/report_unmatched(datum/enterprise_room/room)
	var/turf/first = room.turfs[1]
	log_mapping("Map issue: [room.name] at [AREACOORD(first)] has the lock of a guest room but lacks a bed or a wardrobe, so it is not let as one.")

/datum/enterprise_room_template/guest_room/get_effect(datum/enterprise_room/room, level, russian)
	var/datum/enterprise/enterprise = room.enterprise
	if(level > ENTERPRISE_MAX_LEVEL)
		return null
	if(level < ENTERPRISE_LEVEL_WOOD)
		return russian ? "Ночлег без удобств: [ENTERPRISE_BARE_REST_PRICE] за ночь и без прибавок." : "A bare room: [ENTERPRISE_BARE_REST_PRICE] a night, and no better than any bed."
	var/price = enterprise.get_level_value(enterprise.rest_prices, level)
	var/stats = enterprise.get_level_value(russian ? enterprise.rest_stats_ru : enterprise.rest_stats, level)
	return russian \
		? "[price] за ночь. Уставший гость, выспавшись, на 30 минут получает: [stats]." \
		: "[price] a night. A tired guest who sleeps here gets for 30 minutes: [stats]."

/datum/enterprise_room_template/guest_room/on_rest(datum/enterprise_room/room, mob/living/carbon/human/sleeper)
	var/datum/enterprise/enterprise = room.enterprise
	var/russian = get_preferred_ui_language(sleeper) == "ru"
	var/datum/weakref/who = WEAKREF(sleeper)
	var/paid = enterprise.night_fees[who] || 0
	var/due = max(enterprise.get_rest_price(room) - paid, 0)
	if(!enterprise.take_from_account(sleeper, due))
		to_chat(sleeper, span_warning(russian ? "На счёте нет [due] за ночлег: отдых будет обычным." : "My account cannot cover the [due] for the night: this will be an ordinary rest."))
		return FALSE
	if(due)
		enterprise.earn(due)
		enterprise.night_fees[who] = paid + due
		to_chat(sleeper, span_notice(russian ? "За ночлег со счёта списано [due]." : "The night has cost me [due] from my account."))
	if(!room.is_in_order())
		to_chat(sleeper, span_warning(russian ? "В комнате чего-то нет на месте или что-то сломано: отдых обычный. За эту ночь уже заплачено." : "Something in the room is gone or broken: this was an ordinary rest. The night is already paid for."))
		return FALSE
	return enterprise.give_rest_buff(sleeper, room.level)

/datum/enterprise_room_template/horny_room
	id = ENTERPRISE_PURPOSE_HORNY_ROOM
	name = "Horny Room"
	name_ru = "Horny Room"
	priority = 15
	var/list/signs = list(
		/obj/structure/bondage,
		/obj/structure/stripper_pole,
	)

/datum/enterprise_room_template/horny_room/matches(datum/enterprise_room/room)
	for(var/sign in signs)
		if(room.count_listed(sign))
			return TRUE
	return FALSE

/datum/enterprise_room_template/horny_room/joins_premises(list/turf/inside)
	for(var/turf/member as anything in inside)
		for(var/obj/thing in member)
			if(is_type_in_list(thing, signs))
				return TRUE
	return FALSE

/datum/enterprise_room_template/horny_room/get_effect(datum/enterprise_room/room, level, russian)
	if(level > ENTERPRISE_MAX_LEVEL)
		return null
	return russian ? "Особых эффектов пока нет." : "No special effects yet."

/datum/enterprise_room_template/staff_quarters
	id = ENTERPRISE_PURPOSE_STAFF_QUARTERS
	name = "Staff quarters"
	name_ru = "Комната персонала"
	priority = 20
	grouped = TRUE
	grant_group = ENTERPRISE_GRANT_LIVING

/datum/enterprise_room_template/staff_quarters/matches(datum/enterprise_room/room)
	return room.kind == ENTERPRISE_ROOM_SERVICE && room.count_listed(/obj/structure/bed)

/datum/enterprise_room_template/staff_quarters/get_effect(datum/enterprise_room/room, level, russian)
	var/datum/enterprise/enterprise = room.enterprise
	if(level > ENTERPRISE_MAX_LEVEL)
		return null
	if(level < ENTERPRISE_LEVEL_WOOD)
		return russian ? "Персоналу есть где спать, но без прибавок." : "The staff have somewhere to sleep, and nothing more."
	var/stats = enterprise.get_level_value(russian ? enterprise.rest_stats_ru : enterprise.rest_stats, level)
	return russian \
		? "Персонал спит бесплатно, на 30 минут получает: [stats], и долю дневной выручки на счёт." \
		: "The staff sleep for free, get for 30 minutes: [stats], and a share of the day's takings to their account."

/datum/enterprise_room_template/staff_quarters/on_rest(datum/enterprise_room/room, mob/living/carbon/human/sleeper)
	var/datum/enterprise/enterprise = room.enterprise
	if(!enterprise.is_staff(sleeper) || room.level < ENTERPRISE_LEVEL_WOOD)
		return FALSE
	var/russian = get_preferred_ui_language(sleeper) == "ru"
	enterprise.pay_staff_share(sleeper, russian)
	if(!room.is_in_order())
		to_chat(sleeper, span_warning(russian ? "В комнате чего-то нет на месте или что-то сломано: отдых обычный, без прибавок." : "Something in the room is gone or broken: this was an ordinary rest, with nothing more."))
		return FALSE
	return enterprise.give_rest_buff(sleeper, room.level)

/datum/enterprise_room_template/kitchen
	id = ENTERPRISE_PURPOSE_KITCHEN
	name = "Kitchen"
	name_ru = "Кухня"
	priority = 30
	grouped = TRUE
	var/list/appliances = list(
		/obj/machinery/light/fueled/oven,
		/obj/machinery/light/fueled/hearth,
	)
	var/list/tools = list(
		/obj/item/weapon/knife,
	)

/datum/enterprise_room_template/kitchen/matches(datum/enterprise_room/room)
	var/cooks = FALSE
	for(var/appliance in appliances)
		if(room.count_listed(appliance))
			cooks = TRUE
			break
	if(!cooks)
		return FALSE
	for(var/tool in tools)
		if(room.count_listed(tool))
			return TRUE
	return FALSE

/datum/enterprise_room_template/storage
	id = ENTERPRISE_PURPOSE_STORAGE
	name = "Storage"
	name_ru = "Склад"
	priority = 45
	grouped = TRUE
	grant_group = ENTERPRISE_GRANT_STORES
	var/list/stores = list(
		/obj/structure/rack,
		/obj/structure/closet,
	)
	var/stores_needed = 2
	var/list/goods = list(
		/obj/item/reagent_containers/food,
		/obj/item/reagent_containers/powder/salt,
		/obj/item/reagent_containers/powder/flour,
	)
	var/list/door_words = list("storage", "warehouse", "shed", "pantry", "склад", "кладов", "сарай")
	var/post_name = "food buying post"
	var/post_desc = "Food is bought here. What is taken is paid for on the spot."
	var/keeps_kegs = FALSE

/datum/enterprise_room_template/storage/matches(datum/enterprise_room/room)
	if(room.count_listed(/obj/structure/chair) || room.count_listed(/obj/structure/bed))
		return FALSE
	var/stores_found = 0
	for(var/store in stores)
		stores_found += room.count_listed(store)
	if(stores_found >= stores_needed)
		return TRUE
	return stores_found && (room.holds_any(goods) || is_named_for(room.name))

/datum/enterprise_room_template/storage/get_store_count(datum/enterprise_room/room)
	var/found = 0
	for(var/store in stores)
		found += room.count_listed(store)
	return found

/datum/enterprise_room_template/storage/proc/is_named_for(room_name)
	if(!room_name)
		return FALSE
	var/lowered = LOWER_TEXT(room_name)
	for(var/word in door_words)
		if(findtext(lowered, word))
			return TRUE
	return FALSE

/datum/enterprise_room_template/storage/get_effect(datum/enterprise_room/room, level, russian)
	var/datum/enterprise/enterprise = room.enterprise
	if(level > ENTERPRISE_MAX_LEVEL)
		return null
	var/cap = enterprise.get_level_value(enterprise.stock_caps, max(level, ENTERPRISE_LEVEL_WOOD))
	var/effect = russian \
		? "Место закупки у двери хранит по [cap] каждого вида товара." \
		: "The buying post at the door holds [cap] of each kind of goods."
	return keeps_kegs ? enterprise.describe_keg_store(level, russian) : effect

/datum/enterprise_room_template/storage/on_survey(datum/enterprise_room/room)
	if(room.stock?.post || room.leader)
		return
	var/datum/enterprise/enterprise = room.enterprise
	var/list/spot = enterprise.find_post_spot(room)
	if(!spot)
		return
	var/datum/enterprise_stock/stock = room.stock || new(enterprise, room, goods)
	var/obj/structure/fake_machine/enterprise_stock/post = new(spot[1])
	post.name = post_name
	post.desc = post_desc
	post.pixel_x = spot[2]
	post.pixel_y = spot[3]
	log_game("[enterprise.name]: the [post_name] stands at [AREACOORD(post)].")
	post.stock = stock
	stock.post = post
	room.stock = stock
	if(keeps_kegs && !stock.kegs)
		stock.kegs = new /datum/enterprise_keg_store(stock)

/datum/enterprise_room_template/storage/drinks
	id = ENTERPRISE_PURPOSE_DRINK_STORAGE
	name = "Drinks storage"
	name_ru = "Склад напитков"
	priority = 40
	stores = list(
		/obj/structure/fermentation_keg,
	)
	goods = list(
		/obj/item/reagent_containers/glass/bottle,
	)
	door_words = list("drink", "alcohol", "cellar", "wine", "brew", "напит", "алкогол", "погреб", "вин")
	post_name = "drinks buying post"
	post_desc = "Drink poured in here is paid for by the town. Kegs are handed in and drink is drawn here."
	keeps_kegs = TRUE

/datum/enterprise_room_template/service_hall
	id = ENTERPRISE_PURPOSE_SERVICE_HALL
	name = "Hall"
	name_ru = "Зал"
	priority = 100
	grouped = TRUE
	seats_patrons = TRUE

/datum/enterprise_room_template/service_hall/matches(datum/enterprise_room/room)
	return room.kind == ENTERPRISE_ROOM_COMMON

/datum/enterprise_room_template/service_hall/get_effect(datum/enterprise_room/room, level, russian)
	var/datum/enterprise/enterprise = room.enterprise
	if(level > ENTERPRISE_MAX_LEVEL)
		return null
	var/datum/stress_event/mood = enterprise.get_level_value(enterprise.meal_moods, level)
	if(!mood)
		return russian ? "Столы и стулья без отделки: еда за ними настроения не прибавляет." : "Bare tables and chairs: a meal at them does not lift the mood."
	var/minutes = round(initial(mood.timer) / (1 MINUTES))
	return russian \
		? "Еда за столом, сидя на стуле, поднимает настроение на [minutes] минут." \
		: "A meal eaten seated at a table lifts the mood for [minutes] minutes."

/datum/enterprise_room_template/service_hall/on_meal(datum/enterprise_room/room, mob/living/eater, datum/enterprise_seating/seating)
	var/datum/enterprise/enterprise = room.enterprise
	var/mood_type = enterprise.get_level_value(enterprise.meal_moods, seating.get_level())
	if(!mood_type)
		return FALSE
	enterprise.check_rooms(room.get_members())
	if(!room.is_in_order())
		return FALSE
	eater.add_stress(mood_type)
	return TRUE

/datum/enterprise
	var/alist/terrace_turfs = alist()

/datum/enterprise_room_template/service_hall/terrace
	id = ENTERPRISE_PURPOSE_TERRACE
	name = "Terrace"
	name_ru = "Терраса"
	priority = 5

/datum/enterprise_room_template/service_hall/terrace/matches(datum/enterprise_room/room)
	return room.terrace

/datum/enterprise_room_template/service_hall/terrace/claim_outside(datum/enterprise/enterprise, list/found_by_z, alist/seen)
	var/list/turf/claimed = list()
	var/alist/judged = alist()
	for(var/list/turf/found as anything in found_by_z)
		if(!found)
			continue
		for(var/turf/open/start in found)
			if(locate(/obj/structure/window) in start)
				continue
			for(var/direction in GLOB.cardinals)
				var/turf/open/ahead = get_step(start, direction)
				if(!istype(ahead) || judged[ahead] || seen[ahead] == ENTERPRISE_PREMISES_TAKEN)
					continue
				if(blocks_terrace(start, ahead, direction) || !holds_terrace(ahead))
					continue
				claimed += fill_terrace(ahead, seen, judged)
	for(var/turf/member as anything in claimed)
		enterprise.terrace_turfs[member] = TRUE
	return claimed

/datum/enterprise_room_template/service_hall/terrace/proc/fill_terrace(turf/open/first, alist/seen, alist/judged)
	var/area/place = first.loc
	var/list/turf/open/region = list(first)
	if(!place?.outdoors)
		return refuse_terrace(region, judged)
	judged[first] = region
	var/fenced = FALSE
	var/position = 1
	while(position <= length(region))
		var/turf/open/current = region[position]
		position++
		for(var/direction in GLOB.cardinals)
			var/turf/ahead = get_step(current, direction)
			if(!ahead)
				return refuse_terrace(region, judged)
			var/list/met = judged[ahead]
			if(met)
				if(met != region)
					return refuse_terrace(region, judged)
				continue
			if(seen[ahead] == ENTERPRISE_PREMISES_TAKEN)
				continue
			if(blocks_terrace(current, ahead, direction) || (locate(/obj/structure/stairs) in ahead))
				fenced = TRUE
				continue
			if(!istype(ahead, /turf/open) || ahead.loc != place || !holds_terrace(ahead))
				continue
			judged[ahead] = region
			region += ahead
			if(length(region) > ENTERPRISE_TERRACE_MAX)
				return refuse_terrace(region, judged)
	return fenced ? region : refuse_terrace(region, judged)

/datum/enterprise_room_template/service_hall/terrace/proc/refuse_terrace(list/turf/region, alist/judged)
	var/static/list/refused = list()
	for(var/turf/member as anything in region)
		judged[member] = refused
	return list()

/datum/enterprise_room_template/service_hall/terrace/proc/holds_terrace(turf/open/place)
	if(isopenspace(place))
		return FALSE
	for(var/obj/structure/thing in place)
		if(istype(thing, /obj/structure/stairs) || istype(thing, /obj/structure/window) || istype(thing, /obj/structure/door))
			return FALSE
	return TRUE

/datum/enterprise_room_template/service_hall/terrace/proc/blocks_terrace(turf/origin, turf/target, direction)
	for(var/obj/structure/fluff/railing/railing in origin)
		if(railing.dir & direction)
			return TRUE
	var/backwards = REVERSE_DIR(direction)
	for(var/obj/structure/fluff/railing/railing in target)
		if(railing.dir & backwards)
			return TRUE
	return FALSE

/datum/enterprise
	var/list/rested_today = list()
	var/list/night_fees = list()
	var/list/staff_shares = list()
	var/list/rest_stats = list(
		"Endurance +1, Constitution +1",
		"Strength +1, Endurance +1",
		"Strength, Constitution, Endurance, Speed and Intelligence +1",
		"Strength +1, Constitution +2, Endurance +2, Speed +1, Intelligence +2",
	)
	var/list/rest_stats_ru = list(
		"Воля +1, Стойкость +1",
		"Сила +1, Воля +1",
		"Сила, Стойкость, Воля, Скорость и Интеллект +1",
		"Сила +1, Стойкость +2, Воля +2, Скорость +1, Интеллект +2",
	)

/datum/status_effect/buff/enterprise_rest
	tick_interval = STATUS_EFFECT_NO_TICK
	id = "enterprise_rest"
	alert_type = /atom/movable/screen/alert/status_effect/buff/enterprise_rest
	effectedstats = list(STAT_ENDURANCE = 1, STAT_CONSTITUTION = 1)
	duration = ENTERPRISE_REST_BUFF_TIME

/datum/status_effect/buff/enterprise_rest/iron
	effectedstats = list(STAT_STRENGTH = 1, STAT_ENDURANCE = 1)

/datum/status_effect/buff/enterprise_rest/silver
	effectedstats = list(STAT_STRENGTH = 1, STAT_CONSTITUTION = 1, STAT_ENDURANCE = 1, STAT_SPEED = 1, STAT_INTELLIGENCE = 1)

/datum/status_effect/buff/enterprise_rest/gold
	effectedstats = list(STAT_STRENGTH = 1, STAT_CONSTITUTION = 2, STAT_ENDURANCE = 2, STAT_SPEED = 1, STAT_INTELLIGENCE = 2)

/atom/movable/screen/alert/status_effect/buff/enterprise_rest
	name = "Well Rested"
	desc = span_nicegreen("A night in a proper room has done me good.")
	icon_state = "foodbuff"

/datum/stress_event/enterprise_meal
	timer = 30 MINUTES
	stress_change = -1
	desc = span_green("I ate at a decent table.")

/datum/stress_event/enterprise_meal/iron
	timer = 45 MINUTES
	stress_change = -2
	desc = span_green("I ate at a good table.")

/datum/stress_event/enterprise_meal/silver
	timer = 60 MINUTES
	stress_change = -3
	desc = span_green("I dined at a fine table.")

/datum/stress_event/enterprise_meal/gold
	timer = 90 MINUTES
	stress_change = -4
	desc = span_green("I dined like a lord.")

/datum/enterprise/proc/give_rest_buff(mob/living/sleeper, level)
	var/buff_type = get_level_value(rest_buffs, level)
	if(!buff_type)
		return FALSE
	sleeper.apply_status_effect(buff_type)
	return TRUE

/datum/enterprise/proc/get_staff_bonus()
	return clamp(round(earned_today * ENTERPRISE_STAFF_BONUS_SHARE), ENTERPRISE_STAFF_BONUS_MIN, ENTERPRISE_STAFF_BONUS_MAX)

/datum/enterprise/proc/pay_staff_share(mob/living/carbon/human/sleeper, russian)
	var/datum/weakref/who = WEAKREF(sleeper)
	if(staff_shares[who])
		return FALSE
	var/bonus = get_staff_bonus()
	if(!SStreasury.give_money_account(bonus, sleeper, "[name] wages"))
		return FALSE
	staff_shares[who] = TRUE
	to_chat(sleeper, span_notice(russian ? "За день работы на счёт пришло [bonus]." : "The day's work has brought [bonus] to my account."))
	return TRUE

/datum/enterprise/proc/handle_rest(mob/living/carbon/human/sleeper)
	var/datum/enterprise_room/room = get_room(sleeper)
	if(!room)
		return FALSE
	room.note_visit(sleeper)
	if(get_time_away(sleeper) || !room.template)
		return FALSE
	var/datum/weakref/who = WEAKREF(sleeper)
	if(rested_today[who])
		return FALSE
	check_rooms(room.get_members())
	if(!room.template.on_rest(room, sleeper))
		return FALSE
	rested_today[who] = TRUE
	return TRUE

/datum/enterprise/proc/handle_night(mob/living/carbon/human/sleeper)
	var/datum/enterprise_room/room = get_room(sleeper)
	if(room)
		room.note_visit(sleeper)

/datum/enterprise/proc/handle_meal(mob/living/eater, first_bite = TRUE)
	var/obj/structure/chair/seat = eater.buckled
	if(!istype(seat))
		return FALSE
	var/datum/enterprise_room/room = get_room(eater)
	var/datum/enterprise_seating/seating = room?.get_seating(seat)
	if(!seating || !room.template)
		return FALSE
	var/mob/living/simple_animal/enterprise_patron/patron = seating.get_patron()
	if(patron && patron != eater)
		patron.take_offence(eater)
		return FALSE
	if(!first_bite)
		return FALSE
	return room.template.on_meal(room, eater, seating)
