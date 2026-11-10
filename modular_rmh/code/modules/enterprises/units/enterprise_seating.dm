/datum/enterprise_seating
	var/datum/enterprise_room/room
	var/list/datum/enterprise_fixture/tables = list()
	var/list/datum/enterprise_fixture/chairs = list()
	var/datum/weakref/patron

/datum/enterprise_seating/New(datum/enterprise_room/room)
	src.room = room

/datum/enterprise_seating/Destroy()
	room = null
	tables = null
	chairs = null
	patron = null
	return ..()

/datum/enterprise_seating/proc/get_level()
	return room ? room.level : ENTERPRISE_LEVEL_BARE

/datum/enterprise_seating/proc/has_chair(obj/structure/chair/seat)
	for(var/datum/enterprise_fixture/fixture as anything in chairs)
		if(fixture.get_thing() == seat)
			return TRUE
	return FALSE

/datum/enterprise_seating/proc/get_patron()
	var/mob/living/found = patron?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_seating/proc/is_free()
	return !get_patron()
