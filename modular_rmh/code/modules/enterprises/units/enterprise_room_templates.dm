/datum/enterprise_room_template
	abstract_type = /datum/enterprise_room_template
	var/id
	var/name
	var/priority = 100
	var/list/effects = list()
	var/list/effects_ru = list()
	var/list/upgrades = list()

/datum/enterprise_room_template/proc/matches(datum/enterprise_room/room)
	return FALSE

/datum/enterprise_room_template/proc/get_max_level()
	return max(length(effects), 1)

/datum/enterprise_room_template/proc/get_effect(level, russian)
	var/list/lines = russian ? effects_ru : effects
	if(level < 1 || level > length(lines))
		return null
	return lines[level]

/datum/enterprise_room_template/guest_room
	id = "guest_room"
	name = "Guest room"
	priority = 10
	effects = list(
		"A plain room: a guest pays the base rent.",
		"A comfortable room: a guest pays more a day and stays longer.",
		"A fine room: wealthy guests ask for it.",
	)
	effects_ru = list(
		"Простая комната: постоялец платит базовую плату.",
		"Уютная комната: постоялец платит больше в сутки и живёт дольше.",
		"Богатая комната: её спрашивают состоятельные гости.",
	)
	upgrades = list(
		/obj/structure/bed/inn = /obj/structure/bed/wool,
		/obj/structure/bed/inn/double = /obj/structure/bed/wool/double,
		/obj/structure/mirror = /obj/structure/mirror/fancy,
		/obj/structure/chair/wood/alt = /obj/structure/chair/wood/alt/fancy,
	)

/datum/enterprise_room_template/guest_room/matches(datum/enterprise_room/room)
	return room.kind == ENTERPRISE_ROOM_GUEST

/datum/enterprise_room_template/kitchen
	id = "kitchen"
	name = "Kitchen"
	priority = 20
	effects = list(
		"Dishes are cooked at the usual pace.",
		"Dishes are cooked faster.",
		"The finest dishes of the menu can be cooked.",
	)
	effects_ru = list(
		"Блюда готовятся с обычной скоростью.",
		"Блюда готовятся быстрее.",
		"Можно готовить лучшие блюда меню.",
	)
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
	id = "staff_quarters"
	name = "Staff quarters"
	priority = 30
	effects = list(
		"The staff have somewhere to sleep.",
		"Rested staff tire more slowly on a shift.",
		"Hired workers ask for lower wages.",
	)
	effects_ru = list(
		"Персоналу есть где спать.",
		"Отдохнувший персонал медленнее устаёт за смену.",
		"Наёмные работники просят меньшее жалованье.",
	)
	upgrades = list(
		/obj/structure/bed/shit = /obj/structure/bed/hay,
		/obj/structure/bed/hay = /obj/structure/bed/inn,
		/obj/structure/bed/inn = /obj/structure/bed/wool,
	)

/datum/enterprise_room_template/staff_quarters/matches(datum/enterprise_room/room)
	return room.kind == ENTERPRISE_ROOM_SERVICE && room.beds > 0

/datum/enterprise_room_template/storage
	id = "storage"
	name = "Storage"
	priority = 40
	effects = list(
		"Holds the stock of the enterprise.",
		"Holds more stock.",
		"Food kept here spoils more slowly.",
	)
	effects_ru = list(
		"Хранит запасы предприятия.",
		"Вмещает больше запасов.",
		"Еда здесь портится медленнее.",
	)
	var/list/stores = list(
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/structure/fermentation_keg,
	)
	var/stores_needed = 2

/datum/enterprise_room_template/storage/matches(datum/enterprise_room/room)
	if(room.count_fixtures(/obj/structure/chair))
		return FALSE
	var/stores_found = 0
	for(var/store in stores)
		stores_found += room.count_fixtures(store)
	return stores_found >= stores_needed

/datum/enterprise_room_template/service_hall
	id = "service_hall"
	name = "Service hall"
	priority = 100
	effects = list(
		"Guests are served here.",
		"Patrons are in a better mood and tip more.",
		"Patrons of higher standing come in.",
	)
	effects_ru = list(
		"Здесь обслуживают гостей.",
		"Посетители в лучшем настроении и щедрее на чаевые.",
		"Заходят посетители более высокого положения.",
	)
	upgrades = list(
		/obj/structure/chair/stool = /obj/structure/chair/wood/alt,
		/obj/structure/chair/wood/alt = /obj/structure/chair/wood/alt/fancy,
	)

/datum/enterprise_room_template/service_hall/matches(datum/enterprise_room/room)
	return TRUE
