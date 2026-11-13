// One-shot layout plan for the Sunken Warrens' 19x19 combat shell. The plan is
// built and checked before touching the loaded map; it owns no world objects.
/datum/dungeon_room_plan
	var/seed
	var/recipe
	var/rng_state
	var/list/cells
	var/list/guardian_slots
	var/list/decoration_slots
	var/list/light_slots
	var/list/glow_slots
	var/list/focal_slots
	var/list/moss_slots
	var/entry_index = 29 // (10, 2)
	var/back_gate_index = 48 // (10, 3)
	var/list/forward_gate_indices = list(309, 319) // (5, 17), (15, 17)

/datum/dungeon_room_plan/New(given_seed, given_recipe)
	. = ..()
	seed = clamp(round(abs(given_seed)), 1, 65535)
	recipe = given_recipe
	rng_state = seed

/datum/dungeon_room_plan/proc/next_random(upper_bound)
	// This 16-bit sequence stays within DM's exact integer range. World RNG
	// is never advanced by decisions about room shape or placement.
	rng_state = (rng_state * 109 + 1021) % 65536
	return 1 + (rng_state % upper_bound)

/datum/dungeon_room_plan/proc/grid_index(x, y)
	return (y - 1) * 19 + x

/datum/dungeon_room_plan/proc/is_walkable(index)
	if(!cells || index < 1 || index > 361)
		return FALSE
	return cells[index] == "floor" || cells[index] == "grass" || cells[index] == "cobble"

/datum/dungeon_room_plan/proc/get_turf_for_index(turf/southwest_origin, index)
	if(!southwest_origin || index < 1 || index > 361)
		return null
	var/x = ((index - 1) % 19) + 1
	var/y = round((index - 1) / 19) + 1
	return locate(southwest_origin.x + x - 1, southwest_origin.y + y - 1, southwest_origin.z)

/datum/dungeon_room_plan/proc/build()
	if(!(recipe in list("root_ring", "split_hall", "crossing")))
		return FALSE
	rng_state = seed
	cells = new /list(361)
	guardian_slots = list()
	decoration_slots = list()
	light_slots = list()
	glow_slots = list()
	focal_slots = list()
	moss_slots = list()
	for(var/y in 1 to 19)
		for(var/x in 1 to 19)
			cells[grid_index(x, y)] = (x == 1 || x == 19 || y == 1 || y == 19) ? "wall" : "floor"

	switch(recipe)
		if("root_ring")
			// An irregular pool occupies the center. Both shores remain open,
			// so the party can flank the defenders in either direction.
			var/half_width = 2 + next_random(2) - 1
			var/half_height = 2 + next_random(2) - 1
			var/shift_x = next_random(3) - 2
			var/shift_y = next_random(3) - 2
			for(var/y in (10 + shift_y - half_height) to (10 + shift_y + half_height))
				for(var/x in (10 + shift_x - half_width) to (10 + shift_x + half_width))
					if(abs(x - 10 - shift_x) + abs(y - 10 - shift_y) <= half_width + half_height - next_random(2) + 1)
						cells[grid_index(x, y)] = "water"
		if("split_hall")
			// A stone wall divides a long hall. Two offset breaches and the
			// open ends give several ways to switch sides during combat.
			var/divider_x = 9 + next_random(3) - 1
			var/lower_breach = 6 + next_random(2)
			var/upper_breach = 12 + next_random(2)
			for(var/y in 5 to 15)
				if(y == lower_breach || y == upper_breach)
					continue
				cells[grid_index(divider_x, y)] = "wall"
				if(y >= 8 && y <= 11)
					cells[grid_index(divider_x + 1, y)] = "wall"
			// Small side bogs make the approaches asymmetric without closing
			// either flank.
			for(var/y in 9 to 11)
				cells[grid_index(4, y)] = "water"
				cells[grid_index(16, y)] = "water"
		if("crossing")
			// Interlocking flooded bars make four fighting pockets. The
			// central gap and outer edge both reconnect them.
			var/bar_y = 9 + next_random(3) - 1
			var/bar_x = 9 + next_random(3) - 1
			for(var/x in 4 to 16)
				if(x >= bar_x - 1 && x <= bar_x + 1)
					continue
				cells[grid_index(x, bar_y)] = "water"
			for(var/y in 5 to 15)
				if(y >= bar_y - 1 && y <= bar_y + 1)
					continue
				cells[grid_index(bar_x, y)] = "wall"

	// The shell's straight border stays sealed; short irregular shoulders
	// inside it make the playable cave edge read as cut rock and muddy bays.
	for(var/y in 5 to 15)
		cells[grid_index(2, y)] = "wall"
		cells[grid_index(18, y)] = "wall"
		if(!is_walkable(grid_index(4, y)) || next_random(3) == 1)
			cells[grid_index(3, y)] = "wall"
		if(!is_walkable(grid_index(16, y)) || next_random(3) == 1)
			cells[grid_index(17, y)] = "wall"
	// Recess the passages into the rock, like the authored Swampgob rooms.
	// The arrival tile sits behind the back gate; the room opens north of it.
	for(var/x in 2 to 18)
		cells[grid_index(x, 2)] = "wall"
		cells[grid_index(x, 3)] = "wall"
		cells[grid_index(x, 17)] = "wall"
		cells[grid_index(x, 18)] = "wall"
	cells[entry_index] = "cobble"
	cells[back_gate_index] = "cobble"
	for(var/index in forward_gate_indices)
		cells[index] = "cobble"

	// Tall mushrooms grow on dry banks, never in the pools or in a doorway.
	focal_slots = list(grid_index(5, 12), grid_index(15, 8))
	// Broad patches make recognisable banks and overgrown corners rather than
	// isolated checkerboard grass tiles. Only dry ground gets repainted.
	var/list/patch_centers = focal_slots + list(grid_index(5, 6), grid_index(14, 14))
	for(var/center in patch_centers)
		var/center_x = ((center - 1) % 19) + 1
		var/center_y = round((center - 1) / 19) + 1
		var/radius = 2 + next_random(2)
		for(var/y in max(4, center_y - radius) to min(16, center_y + radius))
			for(var/x in max(3, center_x - radius) to min(17, center_x + radius))
				var/index = grid_index(x, y)
				var/distance = abs(x - center_x) + abs(y - center_y)
				if(is_walkable(index) && (distance < radius || (distance == radius && next_random(3) != 1)))
					cells[index] = "grass"

	// Worn stone thresholds lead into each passage, fading into dirt and moss.
	for(var/y in 4 to 6)
		for(var/x in 9 to 11)
			var/index = grid_index(x, y)
			if(is_walkable(index) && (y < 6 || x == 10))
				cells[index] = "cobble"
	for(var/gate_x in list(5, 15))
		for(var/y in 14 to 16)
			for(var/x in (gate_x - 1) to (gate_x + 1))
				var/index = grid_index(x, y)
				if(is_walkable(index) && (y > 14 || x == gate_x))
					cells[index] = "cobble"

	// Warm light marks both ends of the room. Cool fungal light fills the
	// side banks, so a central wall does not leave the far half unlit.
	light_slots = list(grid_index(7, 4), grid_index(13, 4), grid_index(7, 16), grid_index(13, 16))
	glow_slots = list(grid_index(4, 7), grid_index(16, 7), grid_index(4, 13), grid_index(16, 13))
	// Two more colonies follow the inner banks or partition breaches. These
	// fill the central shadow without adding a solid obstacle to a narrow lane.
	for(var/target_x in list(8, 12))
		var/nearest_slot
		var/nearest_distance = INFINITY
		for(var/y in 5 to 15)
			for(var/x in 3 to 17)
				var/index = grid_index(x, y)
				if(!is_walkable(index) || (index in focal_slots) || (index in glow_slots))
					continue
				var/distance = abs(x - target_x) + abs(y - 10)
				if(distance < nearest_distance)
					nearest_distance = distance
					nearest_slot = index
		if(nearest_slot)
			glow_slots += nearest_slot

	// Low plants collect in grass and along banks. Keep thresholds bare and
	// leave the dense trees and braziers their own space.
	for(var/y in 5 to 15)
		for(var/x in 3 to 17)
			var/index = grid_index(x, y)
			if(!is_walkable(index) || (index in focal_slots) || (index in glow_slots))
				continue
			var/near_feature = !is_walkable(grid_index(x - 1, y)) || !is_walkable(grid_index(x + 1, y)) || !is_walkable(grid_index(x, y - 1)) || !is_walkable(grid_index(x, y + 1))
			if(cells[index] == "cobble")
				if(next_random(3) == 1)
					moss_slots += index
				continue
			if(length(decoration_slots) < 36 && ((cells[index] == "grass" && next_random(3) == 1) || (near_feature && next_random(3) == 1)))
				decoration_slots += index
			else if(near_feature && length(moss_slots) < 16 && next_random(4) == 1)
				moss_slots += index

	// Every eligible tile is a candidate. The encounter director still
	// chooses the mob count and style; this list merely gives it safe sites.
	for(var/y in 5 to 15)
		for(var/x in 3 to 17)
			var/index = grid_index(x, y)
			if(!is_walkable(index) || (index in light_slots) || (index in focal_slots))
				continue
			if(abs(x - 10) + abs(y - 2) < 6 || abs(x - 10) + abs(y - 3) < 6)
				continue
			if(abs(x - 5) + abs(y - 17) < 6 || abs(x - 15) + abs(y - 17) < 6)
				continue
			guardian_slots += index
	return TRUE

/datum/dungeon_room_plan/proc/validate()
	if(!cells || length(cells) != 361 || length(guardian_slots) < 18 || length(decoration_slots) > 36 || length(light_slots) != 4 || length(glow_slots) != 6 || length(focal_slots) != 2 || length(moss_slots) > 24)
		return FALSE
	if(!is_walkable(entry_index) || !is_walkable(back_gate_index))
		return FALSE
	for(var/index in forward_gate_indices)
		if(!is_walkable(index))
			return FALSE
	// Each archway must sit between rock jambs, with a clear inward approach.
	for(var/index in forward_gate_indices + list(back_gate_index))
		if(cells[index - 1] != "wall" || cells[index + 1] != "wall")
			return FALSE
	for(var/index in guardian_slots)
		if(!is_walkable(index) || (index in light_slots) || (index in focal_slots))
			return FALSE
		var/x = ((index - 1) % 19) + 1
		var/y = round((index - 1) / 19) + 1
		if(abs(x - 10) + abs(y - 2) < 6 || abs(x - 10) + abs(y - 3) < 6 || abs(x - 5) + abs(y - 17) < 6 || abs(x - 15) + abs(y - 17) < 6)
			return FALSE
	for(var/index in decoration_slots)
		if(!is_walkable(index))
			return FALSE
	for(var/index in light_slots + glow_slots + moss_slots)
		if(!is_walkable(index))
			return FALSE
	for(var/index in focal_slots)
		if(cells[index] != "grass")
			return FALSE

	// Flood every usable tile, not just the gates: an unreachable alcove
	// could trap a spawned guardian or a player using another movement mode.
	var/list/visited = list()
	var/list/queue = list(entry_index)
	visited["[entry_index]"] = TRUE
	for(var/head = 1, head <= length(queue), head++)
		var/index = queue[head]
		var/x = ((index - 1) % 19) + 1
		var/y = round((index - 1) / 19) + 1
		for(var/neighbor in list(grid_index(x - 1, y), grid_index(x + 1, y), grid_index(x, y - 1), grid_index(x, y + 1)))
			if(!is_walkable(neighbor) || (neighbor in light_slots) || (neighbor in focal_slots) || visited["[neighbor]"])
				continue
			visited["[neighbor]"] = TRUE
			queue += neighbor
	for(var/index in 1 to 361)
		if(is_walkable(index) && !(index in light_slots) && !(index in focal_slots) && !visited["[index]"])
			return FALSE
	return TRUE

/datum/dungeon_room_plan/proc/materialize(turf/southwest_origin)
	if(!validate() || !southwest_origin)
		return FALSE
	var/origin_x = southwest_origin.x
	var/origin_y = southwest_origin.y
	var/origin_z = southwest_origin.z
	// Verify the whole footprint first, so a bad reservation cannot leave
	// a partly changed room.
	for(var/index in 1 to 361)
		var/x = ((index - 1) % 19) + origin_x
		var/y = round((index - 1) / 19) + origin_y
		if(!locate(x, y, origin_z))
			return FALSE
	for(var/index in 1 to 361)
		if(QDELETED(src))
			return FALSE
		var/x = ((index - 1) % 19) + origin_x
		var/y = round((index - 1) / 19) + origin_y
		var/turf/current = locate(x, y, origin_z)
		switch(cells[index])
			if("wall")
				if(!istype(current, /turf/closed/mineral))
					current.ChangeTurf(/turf/closed/mineral)
			if("water")
				current.ChangeTurf(/turf/open/water/swamp)
			if("grass")
				current.ChangeTurf(/turf/open/floor/grass)
			if("cobble")
				current.ChangeTurf(/turf/open/floor/cobblerock/alt)
		if(index % 64 == 0)
			CHECK_TICK
	for(var/index in decoration_slots)
		if(QDELETED(src))
			return FALSE
		var/x = ((index - 1) % 19) + origin_x
		var/y = round((index - 1) / 19) + origin_y
		switch(index % 3)
			if(0)
				new /obj/structure/flora/grass(locate(x, y, origin_z))
			if(1)
				new /obj/structure/flora/tinymushrooms(locate(x, y, origin_z))
			if(2)
				new /obj/structure/flora/new_shroom/red(locate(x, y, origin_z))
	for(var/index in moss_slots)
		if(QDELETED(src))
			return FALSE
		new /obj/effect/decal/cobble/mossy(get_turf_for_index(locate(origin_x, origin_y, origin_z), index))
	for(var/index in glow_slots)
		if(QDELETED(src))
			return FALSE
		var/turf/spot = get_turf_for_index(locate(origin_x, origin_y, origin_z), index)
		if((index - 1) % 19 < 9)
			new /obj/structure/flora/new_shroom/cyansmall(spot)
		else
			new /obj/structure/flora/new_shroom/purplef(spot)
	for(var/index in light_slots)
		if(QDELETED(src))
			return FALSE
		var/x = ((index - 1) % 19) + origin_x
		var/y = round((index - 1) / 19) + origin_y
		new /obj/machinery/light/fueled/firebowl/stump(locate(x, y, origin_z))
	for(var/index in focal_slots)
		if(QDELETED(src))
			return FALSE
		var/x = ((index - 1) % 19) + origin_x
		var/y = round((index - 1) / 19) + origin_y
		var/obj/structure/flora/shroom_tree/happy/mushroom2/focal = new(locate(x, y, origin_z))
		focal.pixel_x = 0
	return TRUE
