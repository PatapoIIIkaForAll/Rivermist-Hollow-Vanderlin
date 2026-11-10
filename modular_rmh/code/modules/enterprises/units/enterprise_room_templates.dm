/datum/enterprise_room_template
	abstract_type = /datum/enterprise_room_template
	var/id
	var/name
	var/priority = 100

/datum/enterprise_room_template/proc/matches(datum/enterprise_room/room)
	return FALSE

/datum/enterprise_room_template/proc/get_effect(datum/enterprise_room/room, level, russian)
	return null

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
		return russian ? "Ночлег без удобств: бесплатно и без прибавок." : "A bare room: free, and no better than any bed."
	var/price = enterprise.get_level_value(enterprise.rest_prices, level)
	var/stats = enterprise.get_level_value(russian ? enterprise.rest_stats_ru : enterprise.rest_stats, level)
	return russian \
		? "[price] за ночь. Уставший гость, выспавшись, на 30 минут получает: [stats]." \
		: "[price] a night. A tired guest who sleeps here gets for 30 minutes: [stats]."

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

/datum/enterprise_room_template/drink_storage
	id = ENTERPRISE_PURPOSE_DRINK_STORAGE
	name = "Drinks storage"
	priority = 35
	var/kegs_needed = 2

/datum/enterprise_room_template/drink_storage/matches(datum/enterprise_room/room)
	return !room.beds && room.count_fixtures(/obj/structure/fermentation_keg) >= kegs_needed

/datum/enterprise_room_template/storage
	id = ENTERPRISE_PURPOSE_STORAGE
	name = "Storage"
	priority = 40
	var/list/stores = list(
		/obj/structure/rack,
		/obj/structure/closet,
	)
	var/stores_needed = 2

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
		? "Место закупки у двери хранит по [cap] каждого вида еды." \
		: "The buying post at the door holds [cap] of each kind of food."

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
