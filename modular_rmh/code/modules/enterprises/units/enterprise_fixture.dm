/datum/enterprise_fixture
	var/fixture_type
	var/name
	var/turf/home
	var/dir
	var/pixel_x
	var/pixel_y
	var/value
	var/datum/weakref/thing
	var/datum/enterprise_room/room

/datum/enterprise_fixture/New(obj/source)
	fixture_type = source.type
	name = source.name
	home = get_turf(source)
	dir = source.dir
	pixel_x = source.pixel_x
	pixel_y = source.pixel_y
	value = max(source.sellprice, ENTERPRISE_FIXTURE_MIN_VALUE)
	thing = WEAKREF(source)

/datum/enterprise_fixture/Destroy()
	home = null
	thing = null
	room = null
	return ..()

/datum/enterprise_fixture/proc/get_thing()
	var/obj/found = thing?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_fixture/proc/is_present()
	var/obj/found = get_thing()
	return found && room && room.enterprise.get_room(found) == room

/datum/enterprise_fixture/proc/is_missing()
	var/obj/found = get_thing()
	if(!found || !room)
		return TRUE
	return !room.enterprise.contains(found)

/datum/enterprise_fixture/proc/restore()
	var/obj/replacement = new fixture_type(home)
	replacement.dir = dir
	replacement.pixel_x = pixel_x
	replacement.pixel_y = pixel_y
	thing = WEAKREF(replacement)
	return replacement
