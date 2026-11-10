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
	var/turf/origin = get_turf(anchor)
	if(!origin || !is_premises_turf(origin))
		log_mapping("Map issue: [anchor] ([anchor.type]) at [AREACOORD(anchor)] is outside the [name] premises. [premises_hint]")
		return FALSE
	if(contains(origin))
		return TRUE
	var/list/found_by_z = scan_premises(origin)
	for(var/z in 1 to length(found_by_z))
		var/list/turf/found = found_by_z[z]
		if(!found)
			continue
		if(length(floors) < z)
			floors.len = z
		var/datum/enterprise_floor/floor = floors[z]
		if(!floor)
			floor = new(z, src)
			floors[z] = floor
		floor.add_turfs(found)
		floor.basement = is_basement_floor(floor)
	scan_rooms()
	update_static_data_for_all_viewers()
	return TRUE

/datum/enterprise/proc/get_floors_data()
	var/list/floors_data = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			floors_data += list(list(
				"z" = floor.z,
				"basement" = floor.basement,
				"tiles" = length(floor.turfs),
				"map" = floor.map_key,
			))
	return floors_data

// Puts the live view of one floor on the viewer's screen and takes the other floors off it.
/datum/enterprise/proc/show_floor(mob/user, z)
	var/client/viewer = user?.client
	var/datum/enterprise_floor/floor = get_floor(z)
	if(!viewer || !floor || !is_owner(user))
		return FALSE
	if(viewed_z[REF(user)] == z)
		return FALSE
	hide_floors(user)
	floor.show_to(viewer)
	viewed_z[REF(user)] = z
	return TRUE

// Opens the lowest floor that is not a basement, or the lowest floor there is.
/datum/enterprise/proc/open_premises(mob/user)
	var/datum/enterprise_floor/chosen
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(!floor)
			continue
		if(!chosen)
			chosen = floor
		if(!floor.basement)
			chosen = floor
			break
	return chosen ? show_floor(user, chosen.z) : FALSE

// Moves the viewer one floor up or down, skipping the levels the enterprise does not reach.
/datum/enterprise/proc/step_floor(mob/user, direction)
	var/z = viewed_z[REF(user)]
	if(!z)
		return FALSE
	var/next_z = get_next_floor_z(z, direction)
	return next_z ? show_floor(user, next_z) : FALSE

/datum/enterprise/proc/get_next_floor_z(z, direction)
	z += direction
	while(z >= 1 && z <= length(floors))
		if(floors[z])
			return z
		z += direction
	return null

/datum/enterprise/proc/wheel_floor(mob/user, direction)
	if(step_floor(user, direction))
		SStgui.update_uis(src)

/datum/enterprise/proc/hide_floors(mob/user)
	viewed_z -= REF(user)
	var/client/viewer = user?.client
	if(!viewer)
		return
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			floor.hide_from(viewer)

/datum/enterprise/proc/is_basement_floor(datum/enterprise_floor/floor)
	for(var/turf/member as anything in floor.turfs)
		if(!istype(member.loc, /area/under))
			return FALSE
	return TRUE

// Walks every premises turf joined to the origin: the eight neighbours on its level, then the turf above and below.
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
