#define ENTERPRISE_SURVEY_COOLDOWN (10 SECONDS)

/datum/enterprise
	var/list/turf/anchors = list()
	var/list/claimed_by_z = list()
	COOLDOWN_DECLARE(survey_cooldown)

/datum/enterprise/proc/is_premises_turf(turf/checked)
	return FALSE

/datum/enterprise/proc/get_floor(z)
	if(z < 1 || z > length(floors))
		return null
	return floors[z]

/datum/enterprise/proc/contains(atom/checked)
	var/turf/location = get_turf(checked)
	if(!location)
		return FALSE
	var/datum/enterprise_floor/floor = get_floor(location.z)
	return floor ? floor.contains(location) : FALSE

/datum/enterprise/proc/claim_premises(atom/anchor)
	if(loading_premises)
		return FALSE
	var/turf/origin = get_turf(anchor)
	if(!origin || !is_premises_turf(origin))
		log_mapping("Map issue: [anchor] ([anchor.type]) at [AREACOORD(anchor)] is outside the [name] premises. [premises_hint]")
		return FALSE
	anchors |= origin
	var/list/turf/fresh
	var/list/turf/claimed_level = origin.z <= length(claimed_by_z) ? claimed_by_z[origin.z] : null
	if(claimed_level && (origin in claimed_level))
		if(contains(origin))
			return TRUE
	else
		fresh = list()
		var/list/found_by_z = scan_premises(origin)
		if(length(claimed_by_z) < length(found_by_z))
			claimed_by_z.len = length(found_by_z)
		for(var/z in 1 to length(found_by_z))
			var/list/turf/found = found_by_z[z]
			if(!found)
				continue
			var/list/turf/claimed = claimed_by_z[z]
			fresh += claimed ? (found - claimed) : found
			claimed_by_z[z] = claimed ? (claimed | found) : found
	survey(fresh)
	return TRUE

/datum/enterprise/proc/survey(list/turf/fresh)
	if(length(floors) < length(claimed_by_z))
		floors.len = length(claimed_by_z)
	for(var/z in 1 to length(claimed_by_z))
		var/list/turf/claimed = claimed_by_z[z]
		if(!claimed)
			continue
		var/datum/enterprise_floor/floor = floors[z]
		if(!floor)
			floor = new(z, src)
			floors[z] = floor
		floor.set_turfs(claimed)
	scan_rooms()
	var/list/datum/enterprise_fixture/taken = length(fresh) ? take_fixtures(fresh) : null
	mark_start_stock(fresh)
	furnish_rooms()
	for(var/datum/enterprise_fixture/fixture as anything in taken)
		fixture.apply_level(max(fixture.room ? fixture.room.level : ENTERPRISE_LEVEL_BARE, ENTERPRISE_LEVEL_WOOD))
	for(var/datum/enterprise_room/room as anything in rooms)
		room.template?.on_survey(room)
	update_map_frame()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			floor.take_picture()
	reshow_floors()
	update_static_data_for_all_viewers()

/datum/enterprise/proc/survey_again(mob/user)
	if(!is_owner(user) || !COOLDOWN_FINISHED(src, survey_cooldown))
		return
	COOLDOWN_START(src, survey_cooldown, ENTERPRISE_SURVEY_COOLDOWN)
	survey()

/datum/enterprise/proc/get_floors_data()
	var/list/floors_data = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			floors_data += list(list(
				"z" = floor.z,
				"basement" = floor.basement,
				"tiles" = length(floor.turfs),
			))
	return floors_data

/datum/enterprise/proc/get_floor_number(z)
	var/number = 0
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor && !floor.basement && floor.z <= z)
			number++
	return number

/datum/enterprise/proc/is_basement_floor(datum/enterprise_floor/floor)
	for(var/turf/member as anything in floor.turfs)
		if(!istype(member.loc, /area/under))
			return FALSE
	return TRUE

/datum/enterprise/proc/scan_premises(turf/origin)
	var/row_length = world.maxx
	var/level_size = row_length * world.maxy
	var/list/seen_by_z = new /list(world.maxz)
	var/list/found_by_z = new /list(world.maxz)
	var/list/turf/queue = list(origin)
	var/list/origin_seen = new /list(level_size)
	origin_seen[(origin.y - 1) * row_length + origin.x] = TRUE
	seen_by_z[origin.z] = origin_seen

	var/position = 1
	while(position <= length(queue))
		var/turf/current = queue[position]
		position++
		var/list/turf/found = found_by_z[current.z]
		if(!found)
			found = list()
			found_by_z[current.z] = found
		found += current

		var/list/turf/neighbours = list(GET_TURF_ABOVE(current), GET_TURF_BELOW(current))
		for(var/direction in GLOB.alldirs)
			neighbours += get_step(current, direction)
		for(var/turf/neighbour as anything in neighbours)
			if(!neighbour)
				continue
			var/list/seen = seen_by_z[neighbour.z]
			if(!seen)
				seen = new /list(level_size)
				seen_by_z[neighbour.z] = seen
			var/cell = (neighbour.y - 1) * row_length + neighbour.x
			if(seen[cell])
				continue
			seen[cell] = TRUE
			if(is_premises_turf(neighbour))
				queue += neighbour
	return found_by_z

#undef ENTERPRISE_SURVEY_COOLDOWN

#define ROOM_CELL_OPEN 1
#define ROOM_CELL_BARRIER 2
#define ROOM_CELL_TABLE 3

/datum/enterprise
	var/list/staff_lock_ids = list()
	var/owner_keyring
	var/list/own_lock_ids
	var/list/datum/enterprise_room/rooms = list()
	var/list/datum/enterprise_room/guest_rooms = list()

/datum/enterprise/proc/get_room(atom/checked)
	var/turf/location = get_turf(checked)
	if(!location)
		return null
	var/datum/enterprise_floor/floor = get_floor(location.z)
	return floor ? floor.get_room(location) : null

/datum/enterprise/proc/get_interior(atom_type)
	var/list/obj/found = list()
	for(var/datum/enterprise_room/room as anything in rooms)
		found += room.get_interior(atom_type)
	return found

/datum/enterprise/proc/get_room_by_id(id)
	if(!isnum(id) || id != round(id) || id < 1 || id > length(rooms))
		return null
	return rooms[id]

/datum/enterprise/proc/get_rooms_data()
	var/list/rooms_data = list()
	var/id = 0
	for(var/datum/enterprise_room/room as anything in rooms)
		id++
		rooms_data += list(list(
			"id" = id,
			"name" = room.name,
			"kind" = room.kind,
			"z" = room.z,
			"tiles" = length(room.turfs),
			"purpose" = room.template?.id,
			"level" = room.level,
			"tenant" = room.get_occupant_name(),
			"beds" = room.beds,
			"items" = length(room.fixtures),
		))
	return rooms_data

/datum/enterprise/proc/get_own_lock_ids()
	if(own_lock_ids)
		return own_lock_ids
	own_lock_ids = staff_lock_ids.Copy()
	if(owner_keyring)
		var/obj/item/storage/keyring/ring = new owner_keyring(null)
		for(var/obj/item/key/key in ring)
			var/list/access = key.get_access()
			if(access)
				own_lock_ids |= access
		qdel(ring)
	return own_lock_ids

/datum/enterprise/proc/get_door_lock_ids(obj/structure/door/door)
	var/datum/lock/key/key_lock = door.lock
	if(!istype(key_lock))
		return null
	return key_lock.lockid_list

/datum/enterprise/proc/is_own_door(obj/structure/door/door)
	var/list/lock_ids = get_door_lock_ids(door)
	return lock_ids ? length(lock_ids & own_lock_ids) : FALSE

/datum/enterprise/proc/get_door_room_name(obj/structure/door/door)
	var/static/list/door_words = list(" backdoor", " back door", " door", " entrance", " exit", " gate")
	if(door.name == initial(door.name))
		return null
	var/lowered = LOWER_TEXT(door.name)
	for(var/word in door_words)
		if(length(lowered) > length(word) && findtext(lowered, word, -length(word)))
			return null
	return door.name

/datum/enterprise/proc/classify_room_turf(turf/checked)
	if(isclosedturf(checked))
		return ROOM_CELL_BARRIER
	var/has_table = FALSE
	for(var/obj/structure/thing in checked)
		if(istype(thing, /obj/structure/window))
			return ROOM_CELL_BARRIER
		if(istype(thing, /obj/structure/door))
			if(length(get_door_lock_ids(thing)))
				return thing
		else if(istype(thing, /obj/structure/table) || istype(thing, /obj/structure/curtain))
			has_table = TRUE
	return has_table ? ROOM_CELL_TABLE : ROOM_CELL_OPEN

/datum/enterprise/proc/scan_rooms()
	var/list/datum/enterprise_room/former = rooms
	rooms = list()
	guest_rooms.Cut()
	exit_doors = null
	get_own_lock_ids()

	var/list/datum/enterprise_room/pockets = list()
	var/list/door_sides = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			find_pockets(floor, pockets, door_sides)

	for(var/datum/enterprise_room/pocket as anything in pockets)
		if(length(pocket.lock_doors) || !length(pocket.links))
			continue
		var/datum/enterprise_room/target
		for(var/datum/enterprise_room/other as anything in pocket.links)
			other = other.resolve()
			if(other != pocket && (!target || length(other.turfs) > length(target.turfs)))
				target = other
		if(!target)
			continue
		pocket.merged_into = target
		target.turfs += pocket.turfs
		target.links |= pocket.links
		if(!pocket.enclosed)
			target.enclosed = FALSE

	for(var/obj/structure/door/door as anything in door_sides)
		if(!is_own_door(door))
			continue
		var/list/datum/enterprise_room/sides = door_sides[door]
		for(var/datum/enterprise_room/side as anything in sides)
			for(var/datum/enterprise_room/other_side as anything in sides)
				side.link_with(other_side)

	var/list/datum/enterprise_room/reached = list()
	for(var/datum/enterprise_room/pocket as anything in pockets)
		if(pocket.merged_into)
			continue
		for(var/turf/member as anything in pocket.turfs)
			var/turf/above = GET_TURF_ABOVE(member)
			if(!above || !isopenspace(above))
				continue
			var/datum/enterprise_room/upper = get_room(above)
			if(upper)
				pocket.link_with(upper.resolve())
		for(var/obj/structure/door/door as anything in pocket.lock_doors)
			if(is_own_door(door))
				reached |= pocket
				break
	var/list/datum/enterprise_room/ledger_pockets = list()
	for(var/turf/anchor as anything in anchors)
		var/datum/enterprise_room/pocket = get_room(anchor)
		if(pocket)
			ledger_pockets |= pocket.resolve()
	reached |= ledger_pockets

	var/position = 1
	while(position <= length(reached))
		var/datum/enterprise_room/pocket = reached[position]
		position++
		pocket.kept = TRUE
		for(var/datum/enterprise_room/linked as anything in pocket.links)
			reached |= linked.resolve()

	prune_floors()
	for(var/datum/enterprise_room/pocket as anything in pockets)
		if(pocket.kept && !pocket.merged_into)
			rooms += pocket
	name_rooms(door_sides)
	sort_rooms()
	for(var/datum/enterprise_room/old_room as anything in former)
		var/datum/enterprise_room/heir = length(old_room.turfs) ? get_room(old_room.turfs[1]) : null
		if(heir)
			heir.inherit(old_room)
	QDEL_LIST(former)
	for(var/datum/enterprise_room/pocket as anything in pockets)
		if(!(pocket in rooms))
			qdel(pocket)

/datum/enterprise/proc/find_pockets(datum/enterprise_floor/floor, list/datum/enterprise_room/pockets, list/door_sides)
	var/cell_count = floor.width * floor.height
	var/list/cells = new /list(cell_count)
	for(var/turf/member as anything in floor.turfs)
		cells[floor.cell_index(member)] = classify_room_turf(member)
	var/list/datum/enterprise_room/owners = new /list(cell_count)
	floor.room_cells = owners

	for(var/turf/start as anything in floor.turfs)
		var/start_cell = floor.cell_index(start)
		if(cells[start_cell] != ROOM_CELL_OPEN || owners[start_cell])
			continue
		var/datum/enterprise_room/pocket = new(floor.z, src)
		pockets += pocket
		owners[start_cell] = pocket
		pocket.turfs += start

		var/position = 1
		while(position <= length(pocket.turfs))
			var/turf/current = pocket.turfs[position]
			position++
			var/on_table = cells[floor.cell_index(current)] == ROOM_CELL_TABLE
			for(var/direction in GLOB.cardinals)
				var/turf/neighbour = get_step(current, direction)
				if(!neighbour)
					continue
				var/cell = 0
				var/kind
				var/datum/enterprise_room/other
				if(floor.contains(neighbour))
					cell = floor.cell_index(neighbour)
					kind = cells[cell]
					other = owners[cell]
				else if(on_table)
					continue
				else
					kind = classify_room_turf(neighbour)
					if(kind == ROOM_CELL_OPEN || kind == ROOM_CELL_TABLE)
						pocket.enclosed = FALSE
						continue
				if(kind == ROOM_CELL_BARRIER)
					continue
				if(kind == ROOM_CELL_OPEN || kind == ROOM_CELL_TABLE)
					if(other && other != pocket)
						if(on_table || kind == ROOM_CELL_TABLE)
							pocket.link_with(other)
					else if(!other && !on_table)
						owners[cell] = pocket
						pocket.turfs += neighbour
					continue
				if(on_table)
					continue
				pocket.lock_doors |= kind
				var/list/datum/enterprise_room/sides = door_sides[kind]
				if(!sides)
					sides = list()
					door_sides[kind] = sides
				sides |= pocket

/datum/enterprise/proc/prune_floors()
	for(var/z in 1 to length(floors))
		var/datum/enterprise_floor/floor = floors[z]
		if(!floor)
			continue
		var/list/turf/kept_turfs = list()
		for(var/turf/member as anything in floor.turfs)
			var/datum/enterprise_room/pocket = floor.room_cells[floor.cell_index(member)]
			if(pocket)
				pocket = pocket.resolve()
				if(pocket.kept)
					kept_turfs += member
				continue
			for(var/direction in GLOB.alldirs)
				var/turf/neighbour = get_step(member, direction)
				if(!neighbour || !floor.contains(neighbour))
					continue
				var/datum/enterprise_room/near = floor.room_cells[floor.cell_index(neighbour)]
				if(!near)
					continue
				near = near.resolve()
				if(near.kept)
					kept_turfs += member
					break
		if(!length(kept_turfs))
			floors[z] = null
			qdel(floor)
			continue
		floor.set_turfs(kept_turfs)
		floor.basement = is_basement_floor(floor)

/datum/enterprise/proc/name_rooms(list/door_sides)
	var/list/sides_by_name = list()
	for(var/obj/structure/door/door as anything in door_sides)
		if(!is_own_door(door))
			continue
		var/room_name = get_door_room_name(door)
		if(!room_name)
			continue
		var/list/datum/enterprise_room/sides = list()
		for(var/datum/enterprise_room/side as anything in door_sides[door])
			side = side.resolve()
			if(side.kept)
				sides |= side
		if(!length(sides))
			continue
		var/list/named_doors = sides_by_name[room_name]
		if(!named_doors)
			named_doors = list()
			sides_by_name[room_name] = named_doors
		named_doors += list(sides)

	for(var/room_name in sides_by_name)
		var/list/all_sides = sides_by_name[room_name]
		var/list/datum/enterprise_room/candidates = all_sides[1]
		candidates = candidates.Copy()
		for(var/index in 2 to length(all_sides))
			candidates &= all_sides[index]
		if(!length(candidates))
			var/list/doors_by_room = list()
			var/most_doors = 0
			for(var/list/datum/enterprise_room/door_rooms as anything in all_sides)
				for(var/datum/enterprise_room/side as anything in door_rooms)
					doors_by_room[side]++
					most_doors = max(most_doors, doors_by_room[side])
			for(var/datum/enterprise_room/side as anything in doors_by_room)
				if(doors_by_room[side] == most_doors)
					candidates += side
		var/datum/enterprise_room/chosen
		for(var/datum/enterprise_room/candidate as anything in candidates)
			if(!chosen || length(candidate.lock_doors) < length(chosen.lock_doors) \
				|| (length(candidate.lock_doors) == length(chosen.lock_doors) && length(candidate.turfs) < length(chosen.turfs)))
				chosen = candidate
		if(chosen && length(all_sides) > chosen.name_weight)
			chosen.name = room_name
			chosen.name_weight = length(all_sides)

	var/list/obj/structure/door/housed_doors = list()
	for(var/datum/enterprise_room/room as anything in rooms)
		var/list/shared_ids
		var/staff_only = length(room.lock_doors) > 0
		for(var/obj/structure/door/door as anything in room.lock_doors)
			var/list/lock_ids = get_door_lock_ids(door)
			shared_ids = shared_ids ? (shared_ids & lock_ids) : lock_ids.Copy()
			if(!length(lock_ids & staff_lock_ids))
				staff_only = FALSE
		var/list/guest_ids = shared_ids ? ((shared_ids & own_lock_ids) - staff_lock_ids) : null
		if(room.enclosed && length(guest_ids))
			var/guest_id = guest_ids[1]
			if(guest_rooms[guest_id])
				var/obj/structure/door/extra_door = room.lock_doors[1]
				log_mapping("Map issue: the room lock \"[guest_id]\" closes a second, separate room at [AREACOORD(extra_door)]. Give each room its own lock.")
			else
				room.kind = ENTERPRISE_ROOM_GUEST
				room.lock_id = guest_id
				guest_rooms[guest_id] = room
				housed_doors |= room.lock_doors
		else if(room.enclosed && staff_only)
			room.kind = ENTERPRISE_ROOM_SERVICE

	for(var/obj/structure/door/door as anything in door_sides)
		if(door in housed_doors)
			continue
		var/list/guest_ids = (get_door_lock_ids(door) & own_lock_ids) - staff_lock_ids
		if(length(guest_ids))
			log_mapping("Map issue: [door] ([door.type]) at [AREACOORD(door)] carries the room lock \"[guest_ids[1]]\" but closes no room: the walls have a gap, there is a way in without that lock, or the doors of the room differ in locks.")

/datum/enterprise/proc/sort_rooms()
	var/list/datum/enterprise_room/ordered = list()
	var/halls = 0
	var/cellars = 0
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(!floor)
			continue
		var/list/datum/enterprise_room/floor_rooms = list()
		for(var/datum/enterprise_room/room as anything in rooms)
			if(room.z != floor.z)
				continue
			floor_rooms += room
			if(!room.name)
				if(floor.basement)
					cellars++
					room.name = "Cellar - [cellars]"
				else
					halls++
					room.name = "Hall - [halls]"
			room.finish_survey()
		floor.set_rooms(floor_rooms)
		ordered += floor_rooms
	rooms = ordered

#undef ROOM_CELL_OPEN
#undef ROOM_CELL_BARRIER
#undef ROOM_CELL_TABLE
