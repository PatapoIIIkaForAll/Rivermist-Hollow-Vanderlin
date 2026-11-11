/datum/enterprise_room_template
	abstract_type = /datum/enterprise_room_template
	var/id
	var/name
	var/priority = 100

/datum/enterprise_room_template/proc/matches(datum/enterprise_room/room)
	return FALSE

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
	priority = 10

/datum/enterprise_room_template/guest_room/matches(datum/enterprise_room/room)
	return room.kind == ENTERPRISE_ROOM_GUEST

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
	var/price = enterprise.get_rest_price(room)
	if(!enterprise.take_from_account(sleeper, price))
		to_chat(sleeper, span_warning(russian ? "На счёте нет [price] за ночлег: отдых будет обычным." : "My account cannot cover the [price] for the night: this will be an ordinary rest."))
		return FALSE
	enterprise.earn(price)
	if(room.damaged)
		to_chat(sleeper, span_warning(russian ? "За ночлег со счёта списано [price], но в комнате чего-то нет на месте или что-то сломано: отдых обычный." : "The night has cost me [price] from my account, but something in the room is gone or broken: this was an ordinary rest."))
		return TRUE
	enterprise.give_rest_buff(sleeper, room.level)
	to_chat(sleeper, span_notice(russian ? "За ночлег со счёта списано [price]." : "The night has cost me [price] from my account."))
	return TRUE

/datum/enterprise_room_template/kitchen
	id = ENTERPRISE_PURPOSE_KITCHEN
	name = "Kitchen"
	priority = 20
	var/list/appliances = list(
		/obj/machinery/light/fueled/oven,
		/obj/machinery/light/fueled/hearth,
	)

/datum/enterprise_room_template/kitchen/matches(datum/enterprise_room/room)
	for(var/appliance in appliances)
		if(room.count_fixtures(appliance))
			return TRUE
	return FALSE

/datum/enterprise_room_template/staff_quarters
	id = ENTERPRISE_PURPOSE_STAFF_QUARTERS
	name = "Staff quarters"
	priority = 30

/datum/enterprise_room_template/staff_quarters/matches(datum/enterprise_room/room)
	return room.kind == ENTERPRISE_ROOM_SERVICE && room.beds > 0

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
	if(!room.damaged)
		enterprise.give_rest_buff(sleeper, room.level)
	var/bonus = enterprise.get_staff_bonus()
	if(SStreasury.give_money_account(bonus, sleeper, "[enterprise.name] wages"))
		var/russian = get_preferred_ui_language(sleeper) == "ru"
		to_chat(sleeper, span_notice(russian ? "За день работы на счёт пришло [bonus]." : "The day's work has brought [bonus] to my account."))
	return TRUE

/datum/enterprise_room_template/storage
	id = ENTERPRISE_PURPOSE_STORAGE
	name = "Storage"
	priority = 40
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
	var/post_name = "food buying post"
	var/post_desc = "Food is bought here. What is taken is paid for on the spot."

/datum/enterprise_room_template/storage/matches(datum/enterprise_room/room)
	if(room.count_fixtures(/obj/structure/chair))
		return FALSE
	var/stores_found = 0
	for(var/store in stores)
		stores_found += room.count_fixtures(store)
	return stores_found >= stores_needed

/datum/enterprise_room_template/storage/get_effect(datum/enterprise_room/room, level, russian)
	var/datum/enterprise/enterprise = room.enterprise
	if(level > ENTERPRISE_MAX_LEVEL)
		return null
	var/cap = enterprise.get_level_value(enterprise.stock_caps, max(level, ENTERPRISE_LEVEL_WOOD))
	return russian \
		? "Место закупки у двери хранит по [cap] каждого вида товара." \
		: "The buying post at the door holds [cap] of each kind of goods."

/datum/enterprise_room_template/storage/on_survey(datum/enterprise_room/room)
	if(room.stock)
		return
	var/turf/outside = room.get_door_step()
	if(!outside)
		return
	var/datum/enterprise_stock/stock = new(room.enterprise, room, goods)
	var/obj/structure/fake_machine/enterprise_stock/post = new(outside)
	post.name = post_name
	post.desc = post_desc
	post.stock = stock
	stock.post = post
	room.stock = stock
	for(var/direction in GLOB.cardinals)
		if(!isclosedturf(get_step(outside, direction)))
			continue
		if(direction & (NORTH | SOUTH))
			post.pixel_y = direction == NORTH ? ICON_SIZE_Y : -ICON_SIZE_Y
		else
			post.pixel_x = direction == EAST ? ICON_SIZE_X : -ICON_SIZE_X
		break

/datum/enterprise_room_template/storage/drinks
	id = ENTERPRISE_PURPOSE_DRINK_STORAGE
	name = "Drinks storage"
	priority = 35
	stores = list(
		/obj/structure/fermentation_keg,
	)
	goods = list(
		/obj/item/reagent_containers/glass/bottle,
	)
	post_name = "drinks buying post"
	post_desc = "Bottled drink is bought here. What is taken is paid for on the spot."

/datum/enterprise_room_template/storage/drinks/matches(datum/enterprise_room/room)
	return !room.beds && ..()

/datum/enterprise_room_template/service_hall
	id = ENTERPRISE_PURPOSE_SERVICE_HALL
	name = "Service hall"
	priority = 100

/datum/enterprise_room_template/service_hall/matches(datum/enterprise_room/room)
	return TRUE

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
	if(!mood_type || room.damaged)
		return FALSE
	eater.add_stress(mood_type)
	return TRUE

/datum/enterprise
	var/list/rested_today = list()
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
	check_rooms(list(room))
	if(!room.template.on_rest(room, sleeper))
		return FALSE
	rested_today[who] = TRUE
	return TRUE

/datum/enterprise/proc/handle_night(mob/living/carbon/human/sleeper)
	var/datum/enterprise_room/room = get_room(sleeper)
	if(room)
		room.note_visit(sleeper)

/datum/enterprise/proc/handle_meal(mob/living/eater)
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
	check_rooms(list(room))
	return room.template.on_meal(room, eater, seating)
