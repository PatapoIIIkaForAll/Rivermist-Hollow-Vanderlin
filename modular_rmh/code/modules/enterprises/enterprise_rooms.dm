#define ROOM_CELL_OPEN 1
#define ROOM_CELL_BARRIER 2

/datum/enterprise
	// Lock ids every member of staff carries; a door that only they can open is not a guest room.
	var/list/staff_lock_ids = list()
	// Guest rooms by the lock id of their doors.
	var/list/datum/enterprise_room/rooms = list()

/datum/enterprise/proc/get_room(atom/checked)
	var/turf/location = get_turf(checked)
	if(!location)
		return null
	var/datum/enterprise_floor/floor = get_floor(location.z)
	return floor ? floor.get_room(location) : null

/datum/enterprise/proc/get_rooms_data()
	var/list/rooms_data = list()
	for(var/lock_id in rooms)
		var/datum/enterprise_room/room = rooms[lock_id]
		rooms_data += list(list(
			"id" = room.lock_id,
			"name" = room.name,
			"z" = room.z,
			"tiles" = length(room.turfs),
			"beds" = room.beds,
		))
	return rooms_data

/datum/enterprise/proc/get_door_lock_ids(obj/structure/door/door)
	var/datum/lock/key/key_lock = door.lock
	if(!istype(key_lock))
		return null
	return key_lock.lockid_list

// A wall, a window, or a door with a lock on it bounds a room; a door without lock ids does not.
/datum/enterprise/proc/classify_room_turf(turf/checked)
	if(isclosedturf(checked))
		return ROOM_CELL_BARRIER
	for(var/obj/structure/thing in checked)
		if(istype(thing, /obj/structure/window))
			return ROOM_CELL_BARRIER
		if(istype(thing, /obj/structure/door) && length(get_door_lock_ids(thing)))
			return thing
	return ROOM_CELL_OPEN

/**
 * Finds the guest rooms on every floor. A room is a closed pocket of the premises whose every way in
 * is a door with the same lock id, and that id is not one of the staff's.
 */
/datum/enterprise/proc/scan_rooms()
	QDEL_LIST_ASSOC_VAL(rooms)
	var/list/obj/structure/door/locked_doors = list()
	var/list/obj/structure/door/housed_doors = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			scan_floor_rooms(floor, locked_doors, housed_doors)

	for(var/obj/structure/door/door as anything in locked_doors - housed_doors)
		var/list/room_ids = get_door_lock_ids(door) - staff_lock_ids
		if(length(room_ids))
			log_mapping("Map issue: [door] ([door.type]) at [AREACOORD(door)] carries the room lock \"[room_ids[1]]\" but closes no room: the walls have a gap, there is a way in without that lock, or the doors of the room differ in locks.")

/datum/enterprise/proc/scan_floor_rooms(datum/enterprise_floor/floor, list/obj/structure/door/locked_doors, list/obj/structure/door/housed_doors)
	var/cell_count = floor.width * floor.height
	var/list/cells = new /list(cell_count)
	for(var/turf/member as anything in floor.turfs)
		cells[floor.cell_index(member)] = classify_room_turf(member)
	floor.room_cells = new /list(cell_count)
	floor.rooms = list()

	var/list/seen = new /list(cell_count)
	for(var/turf/start as anything in floor.turfs)
		var/start_cell = floor.cell_index(start)
		if(cells[start_cell] != ROOM_CELL_OPEN || seen[start_cell])
			continue
		seen[start_cell] = TRUE
		var/list/turf/pocket = list(start)
		var/list/obj/structure/door/doors = list()
		var/enclosed = TRUE

		var/position = 1
		while(position <= length(pocket))
			var/turf/current = pocket[position]
			position++
			for(var/direction in GLOB.cardinals)
				var/turf/neighbour = get_step(current, direction)
				if(!neighbour)
					continue
				var/cell = 0
				var/kind
				if(floor.contains(neighbour))
					cell = floor.cell_index(neighbour)
					kind = cells[cell]
				else
					kind = classify_room_turf(neighbour)
					if(kind == ROOM_CELL_OPEN)
						enclosed = FALSE
						continue
				if(kind == ROOM_CELL_BARRIER)
					continue
				if(kind == ROOM_CELL_OPEN)
					if(!seen[cell])
						seen[cell] = TRUE
						pocket += neighbour
					continue
				doors |= kind

		locked_doors |= doors
		if(!enclosed || !length(doors))
			continue
		var/room_id = get_pocket_room_id(doors)
		if(!room_id)
			continue
		if(rooms[room_id])
			var/obj/structure/door/extra_door = doors[1]
			log_mapping("Map issue: the room lock \"[room_id]\" closes a second, separate room at [AREACOORD(extra_door)]. Give each room its own lock.")
			continue
		var/datum/enterprise_room/room = new(room_id, floor.z, pocket, doors)
		rooms[room_id] = room
		floor.rooms += room
		housed_doors |= doors
		for(var/turf/member as anything in pocket)
			floor.room_cells[floor.cell_index(member)] = room
	floor.update_labels()

// The lock id shared by every door of the pocket, or null when a door lacks it or opens for staff only.
/datum/enterprise/proc/get_pocket_room_id(list/obj/structure/door/doors)
	var/room_id
	for(var/obj/structure/door/door as anything in doors)
		var/list/room_ids = get_door_lock_ids(door) - staff_lock_ids
		if(!length(room_ids))
			return null
		if(!room_id)
			room_id = room_ids[1]
		else if(!(room_id in room_ids))
			return null
	return room_id

#undef ROOM_CELL_OPEN
#undef ROOM_CELL_BARRIER
