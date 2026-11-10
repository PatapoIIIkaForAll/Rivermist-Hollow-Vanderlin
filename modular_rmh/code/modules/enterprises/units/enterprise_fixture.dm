/datum/enterprise_fixture
	var/fixture_type
	var/name
	var/turf/home
	var/dir
	var/pixel_x
	var/pixel_y
	var/value
	var/list/lock_ids
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
	var/datum/lock/key/key_lock = source.lock
	if(istype(key_lock) && length(key_lock.lockid_list))
		lock_ids = key_lock.lockid_list.Copy()
	thing = WEAKREF(source)

/datum/enterprise_fixture/Destroy()
	home = null
	thing = null
	room = null
	lock_ids = null
	return ..()

/datum/enterprise_fixture/proc/get_thing()
	var/obj/found = thing?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_fixture/proc/is_present()
	var/obj/found = get_thing()
	if(!found || !room)
		return FALSE
	return room.enterprise.get_room(found) == room || get_turf(found) == home

/datum/enterprise_fixture/proc/is_missing()
	var/obj/found = get_thing()
	if(!found || !room)
		return TRUE
	return !room.enterprise.contains(found)

/datum/enterprise_fixture/proc/is_broken()
	var/obj/found = get_thing()
	return found ? found.obj_broken : FALSE

/datum/enterprise_fixture/proc/needs_repair()
	return is_missing() || is_broken()

/datum/enterprise_fixture/proc/restore()
	var/obj/found = get_thing()
	if(found && !is_missing())
		if(found.uses_integrity)
			found.repair_damage(found.max_integrity)
		return found
	var/obj/replacement = new fixture_type(home)
	replacement.name = name
	replacement.dir = dir
	replacement.pixel_x = pixel_x
	replacement.pixel_y = pixel_y
	var/datum/lock/key/key_lock = replacement.lock
	if(lock_ids && istype(key_lock))
		key_lock.lockid_list = lock_ids.Copy()
	thing = WEAKREF(replacement)
	return replacement
