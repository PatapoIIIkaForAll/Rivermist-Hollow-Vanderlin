/datum/enterprise_room
	var/lock_id
	var/name
	var/z
	var/beds = 0
	var/list/turf/turfs
	var/list/datum/weakref/doors = list()

/datum/enterprise_room/New(lock_id, z, list/turf/turfs, list/obj/structure/door/doors)
	src.lock_id = lock_id
	src.z = z
	src.turfs = turfs
	for(var/obj/structure/door/door as anything in doors)
		src.doors += WEAKREF(door)
		if(!name)
			name = door.name
	for(var/turf/member as anything in turfs)
		for(var/obj/structure/bed/bed in member)
			beds++

/datum/enterprise_room/Destroy()
	turfs = null
	doors = null
	return ..()
