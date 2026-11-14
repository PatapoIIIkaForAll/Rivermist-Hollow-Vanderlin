#define ENTERPRISE_SURVEY_COOLDOWN (10 SECONDS)

/datum/enterprise
	var/list/turf/anchors = list()
	var/list/claimed_by_z = list()
	var/room_uid_seq = 0
	COOLDOWN_DECLARE(survey_cooldown)

/datum/enterprise/proc/is_premises_turf(turf/checked)
	return is_premises_area(checked.loc)

/datum/enterprise/proc/is_premises_area(area/place)
	return FALSE

/datum/enterprise/proc/get_floor(z)
	RETURN_TYPE(/datum/enterprise_floor)
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
	anchors |= origin
	var/list/turf/fresh
	var/list/turf/claimed_level = origin.z <= length(claimed_by_z) ? claimed_by_z[origin.z] : null
	if(claimed_level && (origin in claimed_level))
		if(length(rooms) && contains(origin))
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

/datum/enterprise/proc/build_floors()
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

/datum/enterprise/proc/survey(list/turf/fresh)
	build_floors()
	scan_rooms()
	var/list/datum/enterprise_fixture/taken = length(fresh) ? take_fixtures(fresh) : null
	if(!SSticker.HasRoundStarted())
		mark_start_stock(fresh)
	furnish_rooms()
	if(length(taken))
		for(var/datum/enterprise_room/room as anything in rooms)
			room.apply_inventory_level(max(room.level, ENTERPRISE_LEVEL_WOOD))
	for(var/datum/enterprise_room/room as anything in rooms)
		room.template?.on_survey(room)
	refresh_decor()
	update_map_frame()
	for(var/datum/enterprise_floor/floor as anything in floors)
		floor?.mark_stale(TRUE)
	refresh_viewers()
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
	var/list/found_by_z = new /list(world.maxz)
	var/alist/seen = alist()
	var/alist/judged = alist()
	var/list/area/joined = list()
	seen[origin] = ENTERPRISE_PREMISES_TAKEN
	var/list/turf/queue = list(origin)
	var/position = 1
	var/looked = 0
	while(position <= length(queue))
		var/turf/current = queue[position]
		position++
		var/list/turf/found = found_by_z[current.z]
		if(!found)
			found = list()
			found_by_z[current.z] = found
		found += current
		scan_neighbour(GET_TURF_ABOVE(current), seen, queue, joined)
		scan_neighbour(GET_TURF_BELOW(current), seen, queue, joined)
		for(var/direction in GLOB.alldirs)
			scan_neighbour(get_step(current, direction), seen, queue, joined)
		if(position > length(queue))
			var/from = looked + 1
			looked = length(queue)
			for(var/index in from to looked)
				look_out_from(queue[index], seen, queue, joined, judged)
	for(var/datum/enterprise_room_template/template as anything in get_room_templates())
		for(var/turf/extra as anything in template.claim_outside(src, found_by_z, seen))
			seen[extra] = ENTERPRISE_PREMISES_TAKEN
			var/list/turf/found = found_by_z[extra.z]
			if(found)
				found += extra
			else
				found_by_z[extra.z] = list(extra)
	return found_by_z

/datum/enterprise/proc/scan_neighbour(turf/neighbour, alist/seen, list/turf/queue, list/area/joined)
	if(!neighbour)
		return
	var/mark = seen[neighbour]
	if(mark == ENTERPRISE_PREMISES_TAKEN || (mark == ENTERPRISE_PREMISES_REFUSED && !(neighbour.loc in joined)))
		return
	if(is_premises_turf(neighbour) || (neighbour.loc in joined))
		seen[neighbour] = ENTERPRISE_PREMISES_TAKEN
		queue += neighbour
	else
		seen[neighbour] = ENTERPRISE_PREMISES_REFUSED

/datum/enterprise/proc/look_out_from(turf/start, alist/seen, list/turf/queue, list/area/joined, alist/judged)
	for(var/direction in GLOB.cardinals)
		var/turf/ahead = start
		for(var/step in 1 to ENTERPRISE_ZONE_REACH)
			ahead = get_step(ahead, direction)
			if(!ahead)
				break
			if(seen[ahead] == ENTERPRISE_PREMISES_TAKEN)
				continue
			var/area/place = ahead.loc
			if(!is_premises_turf(ahead) && !(place in joined))
				if(isnull(judged[place]))
					judged[place] = joins_premises(place, ahead.z)
					if(judged[place])
						joined += place
				if(!judged[place])
					continue
			seen[ahead] = ENTERPRISE_PREMISES_TAKEN
			queue += ahead

/datum/enterprise/proc/joins_premises(area/place, z)
	var/list/turf/inside = place.get_turfs_by_zlevel(z)
	if(!length(inside) || length(inside) > ENTERPRISE_JOINED_AREA_MAX)
		return FALSE
	for(var/datum/enterprise_room_template/template as anything in get_room_templates())
		if(template.joins_premises(inside))
			return TRUE
	return FALSE

#undef ENTERPRISE_SURVEY_COOLDOWN
