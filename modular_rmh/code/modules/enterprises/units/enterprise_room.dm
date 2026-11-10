/datum/enterprise_room
	var/kind = ENTERPRISE_ROOM_COMMON
	// The lock id of a guest room's doors; null for the other kinds.
	var/lock_id
	var/name
	var/z
	var/beds = 0
	var/list/turf/turfs = list()
	var/list/datum/weakref/doors = list()
	// The structures and machinery standing in the room when it was last surveyed.
	var/list/datum/weakref/interior = list()

	// Only meaningful while the enterprise is surveying its rooms.
	var/enclosed = TRUE
	var/kept = FALSE
	var/name_weight = 0
	var/list/obj/structure/door/lock_doors = list()
	var/list/datum/enterprise_room/links = list()
	var/datum/enterprise_room/merged_into

/datum/enterprise_room/New(z)
	src.z = z

/datum/enterprise_room/Destroy()
	turfs = null
	doors = null
	interior = null
	lock_doors = null
	links = null
	merged_into = null
	return ..()

// The room this pocket ended up in, once pockets without doors have joined their neighbours.
/datum/enterprise_room/proc/resolve()
	var/datum/enterprise_room/current = src
	while(current.merged_into)
		current = current.merged_into
	return current

/datum/enterprise_room/proc/link_with(datum/enterprise_room/other)
	if(other == src)
		return
	links |= other
	other.links |= src

// Lists what stands in the room and drops what the survey no longer needs.
/datum/enterprise_room/proc/finish_survey()
	for(var/obj/structure/door/door as anything in lock_doors)
		doors += WEAKREF(door)
	for(var/turf/member as anything in turfs)
		for(var/obj/thing in member)
			if(thing.invisibility || (!istype(thing, /obj/structure) && !istype(thing, /obj/machinery)))
				continue
			interior += WEAKREF(thing)
			if(istype(thing, /obj/structure/bed))
				beds++
	lock_doors = null
	links = null

// The room's furnishings that still exist, all of them or only those of one type.
/datum/enterprise_room/proc/get_interior(atom_type)
	var/list/obj/found = list()
	for(var/datum/weakref/reference as anything in interior)
		var/obj/thing = reference.resolve()
		if(thing && (!atom_type || istype(thing, atom_type)))
			found += thing
	return found
