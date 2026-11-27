//RMH EDITED START - zone cave generation
/**
 * Hybrid cave generator.
 *
 * Pure cellular automata produces blobs, not tunnels.
 * This one builds the skeleton explicitly and only uses CA to roughen it up:
 *
 *   1. split the painted area into contiguous regions (one painted blob = one cave system)
 *   2. erode a solid rim so the zone border never opens into neighbouring rooms
 *   3. Poisson-disk seed chamber centres, carve noise-warped blobs around them
 *   4. connect the chambers with a minimum spanning tree, each edge walked by a
 *      goal-biased drunkard walk with a variable brush -> winding tunnels
 *   5. a couple of CA passes to make the walls organic (tunnel spines are protected)
 *   6. drop disconnected pockets left over by the CA
 *   7. paint turfs, then seed ore veins into rock that actually touches a cave
 */
/datum/map_generator/caves
	name = "Zone Cave Generator"

	// --- turfs ---
	/// Turf used for carved cave floor.
	var/turf/open_turf = /turf/open/floor/naturalstone
	/// Turf used for solid rock.
	var/turf/wall_turf = /turf/closed/mineral
	/// Optional baseturf override for floors. Null inherits whatever was painted.
	var/list/open_baseturfs = null
	/// Optional baseturf override for rock. Null inherits whatever was painted.
	var/list/wall_baseturfs = null

	// --- zone shaping ---
	/// Tiles of guaranteed solid rock kept along the painted border.
	var/border_padding = 2
	/// Painted blobs smaller than this are skipped entirely.
	var/min_region_size = 60

	// --- chambers ---
	/// Poisson-disk radius between chamber centres.
	var/chamber_spacing = 13
	var/chamber_min_radius = 3
	var/chamber_max_radius = 7
	/// Percent of chambers promoted to a large hall. 0 keeps every chamber the same scale.
	var/hall_chance = 0
	var/hall_min_radius = 6
	var/hall_max_radius = 10
	/// How hard the noise warps the chamber outline. 0 = perfect circles.
	var/chamber_edge_noise = 0.3
	var/chamber_noise_frequency = 0.22

	// --- tunnels ---
	/// Brush radius. 0 is a single tile wide corridor, 1 is a three-wide cross.
	var/tunnel_radius_min = 0
	var/tunnel_radius_max = 1
	/// Percent chance per step to wander instead of stepping toward the target.
	var/tunnel_wander = 32
	/// Percent chance per step to re-roll the brush radius.
	var/tunnel_width_shift = 8
	/// Extra non-MST edges as a fraction of chamber count. Creates loops instead of a pure tree.
	var/extra_loop_ratio = 0.25

	// --- cellular smoothing ---
	var/smoothing_passes = 2
	/// Floor tile survives with at least this many floor neighbours.
	var/survive_limit = 2
	/// Rock tile turns to floor with at least this many floor neighbours.
	var/birth_limit = 5

	// --- cleanup ---
	/// Floor clusters smaller than this get filled back in.
	var/min_pocket_size = 10

	// --- ore ---
	/// Assoc: ore turf typepath -> list("weight", "spread_chance", "spread_range", "amount_min", "amount_max")
	var/list/ore_table
	/// Poisson-disk radius between vein seed points.
	var/ore_vein_spacing = 20
	/// BFS growth rounds per vein.
	var/ore_spread_iterations = 2
	var/ore_max_veins = 15
	/// A vein may only start this far from open cave.
	var/ore_near_cave_range = 3
	/// A vein may only grow into rock this far from open cave.
	var/ore_cluster_range = 4

	// --- deep ore pockets ---
	/*
	 * A second ore pass that does the opposite of the one above: it seeds only in
	 * rock that is FAR from any tunnel, so these pockets are invisible from the
	 * cave and have to be dug out on a hunch. Set deep_ore_table to null to
	 * disable the pass entirely.
	 */
	var/list/deep_ore_table
	/// Poisson-disk radius between deep pocket seeds.
	var/deep_vein_spacing = 24
	/// A pocket may only seed where no open floor exists within this radius.
	var/deep_vein_clearance = 5
	/// Pocket tiles must keep at least this much rock between them and open floor.
	var/deep_cluster_clearance = 2
	var/deep_spread_iterations = 2
	var/deep_max_veins = 3

	// --- floor patches ---
	/*
	 * Two independent low-frequency noise fields laid over the cave floor. Each
	 * paints its turf wherever it crosses its threshold, so the result reads as
	 * irregular blotches of dirt and cobble over the base naturalstone instead of
	 * a checkerboard of random tiles. Patch A wins where the two overlap.
	 */
	var/turf/patch_turf_a = /turf/open/floor/dirt
	/// 0..1. Higher means rarer. ~0.60 covers roughly a fifth of the floor.
	var/patch_threshold_a = 0.60
	var/turf/patch_turf_b = /turf/open/floor/cobblerock
	var/patch_threshold_b = 0.66
	/// Lower frequency means bigger, smoother patches.
	var/patch_frequency = 0.11

	// --- decoration ---
	/*
	 * Entries are rolled per eligible open tile in table order; a tile that wins
	 * one entry is not offered to the rest. Fields:
	 *
	 *   paths          weighted list of typepaths
	 *   chance         percent chance per eligible tile to seed here
	 *   spacing        minimum tiles between two seeds of THIS entry
	 *   near_wall      require at least one adjacent rock tile
	 *   open_min       require at least N open neighbours (keeps props out of choke points)
	 *   cluster_min    members per seed
	 *   cluster_max
	 *   cluster_radius members scatter within this radius of the seed
	 *
	 * Put rare clustered entries first: they get first refusal on tiles.
	 */
	var/list/decor_spawns

	var/seed = 0
	var/datum/noise_generator/shape_noise
	var/datum/noise_generator/patch_noise_a
	var/datum/noise_generator/patch_noise_b

/datum/map_generator/caves/New()
	. = ..()
	seed = rand(1, 999999)
	shape_noise = new /datum/noise_generator(seed)
	shape_noise.octaves = 2
	shape_noise.gain = 0.5
	shape_noise.lacunarity = 2
	shape_noise.frequency = chamber_noise_frequency

	patch_noise_a = new /datum/noise_generator(seed + 21001)
	patch_noise_a.octaves = 2
	patch_noise_a.gain = 0.5
	patch_noise_a.lacunarity = 2
	patch_noise_a.frequency = patch_frequency

	patch_noise_b = new /datum/noise_generator(seed + 47303)
	patch_noise_b.octaves = 2
	patch_noise_b.gain = 0.5
	patch_noise_b.lacunarity = 2
	patch_noise_b.frequency = patch_frequency

	if(isnull(ore_table))
		ore_table = default_ore_table()
	if(isnull(decor_spawns))
		decor_spawns = default_decor_spawns()

/datum/map_generator/caves/Destroy()
	QDEL_NULL(shape_noise)
	QDEL_NULL(patch_noise_a)
	QDEL_NULL(patch_noise_b)
	return ..()

/datum/map_generator/caves/proc/default_ore_table()
	return list(
		/turf/closed/mineral/iron = list("weight" = 22, "spread_chance" = 60, "spread_range" = 1, "amount_min" = 2, "amount_max" = 5),
		/turf/closed/mineral/copper = list("weight" = 20, "spread_chance" = 60, "spread_range" = 1, "amount_min" = 2, "amount_max" = 5),
		/turf/closed/mineral/tin = list("weight" = 16, "spread_chance" = 60, "spread_range" = 1, "amount_min" = 2, "amount_max" = 5),
		/turf/closed/mineral/coal = list("weight" = 16, "spread_chance" = 65, "spread_range" = 1, "amount_min" = 2, "amount_max" = 6),
		/turf/closed/mineral/salt = list("weight" = 12, "spread_chance" = 65, "spread_range" = 1, "amount_min" = 2, "amount_max" = 5),
		/turf/closed/mineral/silver = list("weight" = 6, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 1, "amount_max" = 3),
		/turf/closed/mineral/gold = list("weight" = 4, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 1, "amount_max" = 3),
		/turf/closed/mineral/gemeralds = list("weight" = 2, "spread_chance" = 40, "spread_range" = 1, "amount_min" = 1, "amount_max" = 2),
	)

/datum/map_generator/caves/proc/default_decor_spawns()
	return list(
		// One spider nest per cave system if you are unlucky. Tight cluster, far from anything else of its kind.
		list(
			"paths" = list(/obj/structure/spider/stickyweb/solo = 1),
			"chance" = 0.25,
			"spacing" = 14,
			"near_wall" = TRUE,
			"open_min" = 3,
			"cluster_min" = 3,
			"cluster_max" = 6,
			"cluster_radius" = 2,
		),
		// Light crystals: rare, they carry a 3.5-range light each, so a handful lights a whole chamber.
		list(
			"paths" = list(/obj/structure/flora/crystal = 1),
			"chance" = 0.3,
			"spacing" = 10,
			"near_wall" = TRUE,
			"open_min" = 2,
			"cluster_min" = 1,
			"cluster_max" = 2,
			"cluster_radius" = 1,
		),
		// Mushroom gardens against the rock face.
		list(
			"paths" = list(
				/obj/structure/flora/new_shroom/cyansmall = 3,
				/obj/structure/flora/new_shroom/cyanf = 2,
				/obj/structure/flora/new_shroom/purplesmall = 3,
				/obj/structure/flora/new_shroom/purplef = 2,
			),
			"chance" = 0.7,
			"spacing" = 6,
			"near_wall" = TRUE,
			"open_min" = 2,
			"cluster_min" = 2,
			"cluster_max" = 4,
			"cluster_radius" = 2,
		),
		// Stalagmites: the main filler. 64x64 sprite drawn above mobs, so keep them spaced.
		list(
			"paths" = list(/obj/structure/stalagmite = 1),
			"chance" = 2.2,
			"spacing" = 3,
			"near_wall" = FALSE,
			"open_min" = 3,
			"cluster_min" = 1,
			"cluster_max" = 1,
			"cluster_radius" = 0,
		),
		// Loose rubble.
		list(
			"paths" = list(/obj/item/natural/stone = 1),
			"chance" = 1.8,
			"spacing" = 0,
			"near_wall" = FALSE,
			"open_min" = 0,
			"cluster_min" = 1,
			"cluster_max" = 2,
			"cluster_radius" = 1,
		),
		list(
			"paths" = list(/obj/item/natural/rock = 1),
			"chance" = 1.1,
			"spacing" = 2,
			"near_wall" = FALSE,
			"open_min" = 0,
			"cluster_min" = 1,
			"cluster_max" = 1,
			"cluster_radius" = 0,
		),
	)

/datum/map_generator/caves/generate_terrain(list/turfs, area/target_area)
	if(!length(turfs))
		return FALSE

	var/list/mask = list()
	var/counted = 0
	for(var/turf/candidate as anything in turfs)
		if(!candidate)
			continue
		mask["[candidate.x],[candidate.y]"] = candidate
		counted++
		if(!(counted % 400))
			CHECK_TICK

	var/generated = FALSE
	// Share occupied ore across regions and both ore passes.
	var/list/placed_ore = list()
	for(var/list/region as anything in split_regions(mask))
		if(length(region) < min_region_size)
			continue
		if(generate_region(region, placed_ore))
			generated = TRUE
		CHECK_TICK

	return generated

/**
 * Splits the painted mask into contiguous blobs so a mapper can paint the same
 * area type in several unconnected places without them being treated as one
 * giant bounding box.
 */
/datum/map_generator/caves/proc/split_regions(list/mask)
	var/static/list/cardinal_offsets = list(list(1, 0), list(-1, 0), list(0, 1), list(0, -1))
	var/list/regions = list()
	var/list/visited = list()

	for(var/key in mask)
		if(visited[key])
			continue

		var/list/region = list()
		var/list/queue = list(key)
		visited[key] = TRUE
		var/index = 1

		while(index <= length(queue))
			var/current = queue[index]
			index++
			region[current] = mask[current]

			var/list/parts = splittext(current, ",")
			var/current_x = text2num(parts[1])
			var/current_y = text2num(parts[2])

			for(var/list/offset as anything in cardinal_offsets)
				var/neighbor = "[current_x + offset[1]],[current_y + offset[2]]"
				if(mask[neighbor] && !visited[neighbor])
					visited[neighbor] = TRUE
					queue += neighbor

			if(!(index % 250))
				CHECK_TICK

		regions += list(region)

	return regions

/datum/map_generator/caves/proc/generate_region(list/region, list/placed_ore)
	var/min_x = INFINITY
	var/max_x = -INFINITY
	var/min_y = INFINITY
	var/max_y = -INFINITY

	for(var/key in region)
		var/turf/target = region[key]
		min_x = min(min_x, target.x)
		max_x = max(max_x, target.x)
		min_y = min(min_y, target.y)
		max_y = max(max_y, target.y)
	CHECK_TICK

	var/list/carveable = build_carveable(region)
	if(length(carveable) < min_region_size)
		return FALSE

	var/list/floor_map = list()
	var/list/protected = list()

	var/list/centers = place_chambers(carveable, floor_map, min_x, max_x, min_y, max_y)
	if(!length(centers))
		return FALSE

	carve_tunnel_network(centers, carveable, floor_map, protected, min_x, max_x, min_y, max_y)
	smooth_region(carveable, floor_map, protected)
	prune_pockets(floor_map)
	apply_turfs(region, floor_map)
	place_ore_veins(region, floor_map, min_x, max_x, min_y, max_y, placed_ore)
	place_deep_ore_pockets(region, floor_map, min_x, max_x, min_y, max_y, placed_ore)
	populate(region, floor_map)
	return TRUE

/// Every mask tile whose full `border_padding` neighbourhood is still inside the mask.
/datum/map_generator/caves/proc/build_carveable(list/region)
	var/list/carveable = list()

	if(border_padding <= 0)
		for(var/key in region)
			carveable[key] = TRUE
		return carveable

	var/checked = 0
	for(var/key in region)
		var/turf/target = region[key]
		var/valid = TRUE

		for(var/offset_x = -border_padding to border_padding)
			for(var/offset_y = -border_padding to border_padding)
				if(!region["[target.x + offset_x],[target.y + offset_y]"])
					valid = FALSE
					break
			if(!valid)
				break

		if(valid)
			carveable[key] = TRUE

		checked++
		if(!(checked % 300))
			CHECK_TICK

	return carveable

/datum/map_generator/caves/proc/place_chambers(list/carveable, list/floor_map, min_x, max_x, min_y, max_y)
	var/list/centers = list()
	var/span = min(max_x - min_x, max_y - min_y)
	var/spacing = max(3, min(chamber_spacing, round(span / 3)))
	var/list/samples = shape_noise.poisson_disk_sampling(min_x, max_x + 1, min_y, max_y + 1, spacing)

	for(var/list/sample as anything in samples)
		var/center_x = round(sample[1])
		var/center_y = round(sample[2])
		if(!carveable["[center_x],[center_y]"])
			continue
		centers += list(list(center_x, center_y))
		carve_chamber(carveable, floor_map, center_x, center_y)
		CHECK_TICK

	// Tiny regions can miss every Poisson sample. Anchor at least one chamber.
	if(!length(centers))
		for(var/key in carveable)
			var/list/parts = splittext(key, ",")
			var/center_x = text2num(parts[1])
			var/center_y = text2num(parts[2])
			centers += list(list(center_x, center_y))
			carve_chamber(carveable, floor_map, center_x, center_y)
			break

	return centers

/datum/map_generator/caves/proc/carve_chamber(list/carveable, list/floor_map, center_x, center_y)
	// Rolling the scale per chamber, rather than per generator, is what lets one
	// zone hold both cramped junctions and open halls.
	var/radius = prob(hall_chance) ? rand(hall_min_radius, hall_max_radius) : rand(chamber_min_radius, chamber_max_radius)
	var/limit = round(radius * (1 + chamber_edge_noise * 1.5)) + 1

	for(var/offset_x = -limit to limit)
		for(var/offset_y = -limit to limit)
			var/distance = sqrt(offset_x * offset_x + offset_y * offset_y)
			if(distance > limit)
				continue
			var/wobble = shape_noise.fbm2(center_x + offset_x, center_y + offset_y)
			if(distance > radius * (1 + chamber_edge_noise * wobble))
				continue
			var/key = "[center_x + offset_x],[center_y + offset_y]"
			if(carveable[key])
				floor_map[key] = TRUE

/// Prim's MST over the chamber centres, plus a few extra edges so the layout loops.
/datum/map_generator/caves/proc/carve_tunnel_network(list/centers, list/carveable, list/floor_map, list/protected, min_x, max_x, min_y, max_y)
	var/count = length(centers)
	if(count < 2)
		return

	var/list/connected = list(1)
	var/list/remaining = list()
	for(var/index = 2 to count)
		remaining += index

	while(length(remaining))
		var/best_from = 0
		var/best_to = 0
		var/best_distance = INFINITY

		for(var/source_index in connected)
			var/list/start = centers[source_index]
			for(var/target_index in remaining)
				var/list/goal = centers[target_index]
				var/distance = ((start[1] - goal[1]) ** 2) + ((start[2] - goal[2]) ** 2)
				if(distance < best_distance)
					best_distance = distance
					best_from = source_index
					best_to = target_index

		if(!best_to)
			break

		var/list/start = centers[best_from]
		var/list/goal = centers[best_to]
		carve_tunnel(carveable, floor_map, protected, start[1], start[2], goal[1], goal[2], min_x, max_x, min_y, max_y)

		connected += best_to
		remaining -= best_to
		CHECK_TICK

	var/extra_edges = round(count * extra_loop_ratio)
	for(var/index = 1 to extra_edges)
		var/source_index = rand(1, count)
		var/target_index = rand(1, count)
		if(source_index == target_index)
			continue
		var/list/start = centers[source_index]
		var/list/goal = centers[target_index]
		carve_tunnel(carveable, floor_map, protected, start[1], start[2], goal[1], goal[2], min_x, max_x, min_y, max_y)
		CHECK_TICK

/// Goal-biased drunkard walk. The wander chance is what makes the corridor snake.
/datum/map_generator/caves/proc/carve_tunnel(list/carveable, list/floor_map, list/protected, start_x, start_y, goal_x, goal_y, min_x, max_x, min_y, max_y)
	var/current_x = start_x
	var/current_y = start_y
	var/radius = rand(tunnel_radius_min, tunnel_radius_max)
	var/steps = 0
	var/max_steps = (abs(goal_x - start_x) + abs(goal_y - start_y)) * 4 + 60

	while(steps < max_steps)
		steps++
		carve_brush(carveable, floor_map, protected, current_x, current_y, radius)

		if(current_x == goal_x && current_y == goal_y)
			break

		if(prob(tunnel_width_shift))
			radius = rand(tunnel_radius_min, tunnel_radius_max)

		if(prob(tunnel_wander))
			if(prob(50))
				current_x += pick(-1, 1)
			else
				current_y += pick(-1, 1)
		else if(current_x != goal_x && (current_y == goal_y || prob(50)))
			current_x += (goal_x > current_x) ? 1 : -1
		else if(current_y != goal_y)
			current_y += (goal_y > current_y) ? 1 : -1

		current_x = clamp(current_x, min_x, max_x)
		current_y = clamp(current_y, min_y, max_y)

	carve_brush(carveable, floor_map, protected, goal_x, goal_y, radius)

/datum/map_generator/caves/proc/carve_brush(list/carveable, list/floor_map, list/protected, center_x, center_y, radius)
	if(radius <= 0)
		var/key = "[center_x],[center_y]"
		if(carveable[key])
			floor_map[key] = TRUE
			protected[key] = TRUE
		return

	for(var/offset_x = -radius to radius)
		for(var/offset_y = -radius to radius)
			if((offset_x * offset_x + offset_y * offset_y) > (radius * radius) + 0.5)
				continue
			var/key = "[center_x + offset_x],[center_y + offset_y]"
			if(!carveable[key])
				continue
			floor_map[key] = TRUE
			protected[key] = TRUE

/// Cellular automata pass. Anything outside the mask counts as rock, so the rim holds.
/datum/map_generator/caves/proc/smooth_region(list/carveable, list/floor_map, list/protected)
	for(var/pass = 1 to smoothing_passes)
		var/list/next_map = list()
		var/processed = 0

		for(var/key in carveable)
			var/list/parts = splittext(key, ",")
			var/current_x = text2num(parts[1])
			var/current_y = text2num(parts[2])
			var/neighbors = 0

			for(var/offset_x = -1 to 1)
				for(var/offset_y = -1 to 1)
					if(!offset_x && !offset_y)
						continue
					if(floor_map["[current_x + offset_x],[current_y + offset_y]"])
						neighbors++

			if(protected[key])
				next_map[key] = TRUE
			else if(floor_map[key] ? (neighbors >= survive_limit) : (neighbors >= birth_limit))
				next_map[key] = TRUE

			processed++
			if(!(processed % 250))
				CHECK_TICK

		floor_map.Cut()
		for(var/key in next_map)
			floor_map[key] = TRUE
		CHECK_TICK

/// Fills in floor clusters too small to be worth walking into.
/datum/map_generator/caves/proc/prune_pockets(list/floor_map)
	if(min_pocket_size <= 1)
		return

	var/list/visited = list()
	var/list/doomed = list()

	for(var/key in floor_map)
		if(visited[key])
			continue

		var/list/queue = list(key)
		visited[key] = TRUE
		var/index = 1

		while(index <= length(queue))
			var/current = queue[index]
			index++

			var/list/parts = splittext(current, ",")
			var/current_x = text2num(parts[1])
			var/current_y = text2num(parts[2])

			for(var/offset_x = -1 to 1)
				for(var/offset_y = -1 to 1)
					if(!offset_x && !offset_y)
						continue
					var/neighbor = "[current_x + offset_x],[current_y + offset_y]"
					if(floor_map[neighbor] && !visited[neighbor])
						visited[neighbor] = TRUE
						queue += neighbor

			if(!(index % 250))
				CHECK_TICK

		if(length(queue) < min_pocket_size)
			doomed += queue

	for(var/key in doomed)
		floor_map -= key

/datum/map_generator/caves/proc/apply_turfs(list/region, list/floor_map)
	var/processed = 0

	for(var/key in region)
		var/turf/target = region[key]
		if(!target)
			continue

		if(floor_map[key])
			var/turf/chosen = select_floor_turf(target.x, target.y)
			if(target.type != chosen)
				target.ChangeTurf(chosen, open_baseturfs)
		else if(target.type != wall_turf)
			target.ChangeTurf(wall_turf, wall_baseturfs)

		processed++
		if(!(processed % 150))
			CHECK_TICK

/// Picks the floor variant for one tile from the two patch noise fields.
/datum/map_generator/caves/proc/select_floor_turf(tile_x, tile_y)
	if(patch_turf_a)
		if(((patch_noise_a.fbm2(tile_x, tile_y) + 1) / 2) > patch_threshold_a)
			return patch_turf_a
	if(patch_turf_b)
		if(((patch_noise_b.fbm2(tile_x, tile_y) + 1) / 2) > patch_threshold_b)
			return patch_turf_b
	return open_turf

/// 70% isolated tiles, 20% small groups, 10% groups of at most five.
/datum/map_generator/caves/proc/roll_ore_cluster_size()
	var/roll = rand(1, 100)
	if(roll <= 70)
		return 1
	if(roll <= 90)
		return rand(2, 3)
	return rand(4, 5)

/// Check the tile and all eight neighbours to keep deposits apart.
/datum/map_generator/caves/proc/ore_touches_existing(tile_x, tile_y, list/placed_ore)
	for(var/offset_x = -1 to 1)
		for(var/offset_y = -1 to 1)
			if(placed_ore["[tile_x + offset_x],[tile_y + offset_y]"])
				return TRUE
	return FALSE

/// Poisson-seeded veins that grow by BFS with distance decay, only into rock that borders a cave.
/datum/map_generator/caves/proc/place_ore_veins(list/region, list/floor_map, min_x, max_x, min_y, max_y, list/placed_ore)
	if(!length(ore_table))
		return

	var/list/wall_keys = list()
	for(var/key in region)
		if(!floor_map[key] && !placed_ore[key])
			wall_keys[key] = TRUE
	if(!length(wall_keys))
		return

	var/list/weights = list()
	for(var/ore_path in ore_table)
		var/list/ore_config = ore_table[ore_path]
		weights[ore_path] = ore_config["weight"]

	var/span = min(max_x - min_x, max_y - min_y)
	var/spacing = max(3, min(ore_vein_spacing, round(span / 3)))
	var/list/samples = shape_noise.poisson_disk_sampling(min_x, max_x + 1, min_y, max_y + 1, spacing)
	var/veins_placed = 0

	for(var/list/sample as anything in samples)
		if(veins_placed >= ore_max_veins)
			break

		var/seed_x = round(sample[1])
		var/seed_y = round(sample[2])
		if(!wall_keys["[seed_x],[seed_y]"])
			continue
		if(ore_touches_existing(seed_x, seed_y, placed_ore))
			continue
		if(!is_near_floor(seed_x, seed_y, floor_map, ore_near_cave_range))
			continue

		var/ore_path = pickweight(weights)
		var/list/ore_config = ore_table[ore_path]
		var/list/cluster = grow_ore_cluster(seed_x, seed_y, wall_keys, floor_map, ore_config["spread_chance"], ore_config["spread_range"], placed_ore, roll_ore_cluster_size())

		var/seed_key = "[seed_x],[seed_y]"
		for(var/cluster_key in cluster)
			var/turf/target = region[cluster_key]
			if(!target)
				continue
			// Neighboring walls may contain different ores, weighted by rarity.
			var/tile_ore_path = (cluster_key == seed_key) ? ore_path : pickweight(weights)
			var/list/tile_ore_config = ore_table[tile_ore_path]
			var/turf/closed/mineral/vein = target.ChangeTurf(tile_ore_path, wall_baseturfs)
			if(!ismineralturf(vein))
				continue
			vein.mineralAmt = rand(tile_ore_config["amount_min"], tile_ore_config["amount_max"])
			placed_ore[cluster_key] = TRUE
			wall_keys -= cluster_key

		veins_placed++
		CHECK_TICK

/datum/map_generator/caves/proc/grow_ore_cluster(seed_x, seed_y, list/wall_keys, list/floor_map, spread_chance, spread_range, list/placed_ore, max_tiles)
	var/list/cluster = list("[seed_x],[seed_y]" = TRUE)
	var/list/active = list("[seed_x],[seed_y]")
	if(max_tiles <= 1 || spread_range < 1)
		return cluster

	for(var/iteration = 1 to ore_spread_iterations)
		var/list/next_active = list()

		for(var/key in active)
			var/list/parts = splittext(key, ",")
			var/current_x = text2num(parts[1])
			var/current_y = text2num(parts[2])

			// Only adjacent walls can grow; every deposit has a hard size cap.
			for(var/offset_x = -1 to 1)
				for(var/offset_y = -1 to 1)
					if(length(cluster) >= max_tiles)
						return cluster
					if(abs(offset_x) + abs(offset_y) != 1)
						continue
					if(!prob(spread_chance * (1 - (1 / (spread_range + 1)))))
						continue

					var/neighbor = "[current_x + offset_x],[current_y + offset_y]"
					if(cluster[neighbor] || !wall_keys[neighbor])
						continue
					if(ore_touches_existing(current_x + offset_x, current_y + offset_y, placed_ore))
						continue
					if(!is_near_floor(current_x + offset_x, current_y + offset_y, floor_map, ore_cluster_range))
						continue

					cluster[neighbor] = TRUE
					next_active += neighbor

		active = next_active
		if(!length(active))
			break
		CHECK_TICK

	return cluster

/datum/map_generator/caves/proc/is_near_floor(check_x, check_y, list/floor_map, check_range)
	for(var/offset_x = -check_range to check_range)
		for(var/offset_y = -check_range to check_range)
			if(floor_map["[check_x + offset_x],[check_y + offset_y]"])
				return TRUE
	return FALSE

/**
 * Deep pockets: the inverse of place_ore_veins.
 *
 * Seeds only in rock with no open floor anywhere inside deep_vein_clearance, and
 * keeps every pocket tile at least deep_cluster_clearance away from the cave, so
 * a pocket never shows itself on a tunnel wall. Players find these by digging on
 * a guess, not by walking past them.
 */
/datum/map_generator/caves/proc/place_deep_ore_pockets(list/region, list/floor_map, min_x, max_x, min_y, max_y, list/placed_ore)
	if(!length(deep_ore_table))
		return

	var/list/wall_keys = list()
	for(var/key in region)
		if(!floor_map[key] && !placed_ore[key])
			wall_keys[key] = TRUE
	if(!length(wall_keys))
		return

	var/list/weights = list()
	for(var/ore_path in deep_ore_table)
		var/list/ore_config = deep_ore_table[ore_path]
		weights[ore_path] = ore_config["weight"]

	var/span = min(max_x - min_x, max_y - min_y)
	var/spacing = max(3, min(deep_vein_spacing, round(span / 3)))
	var/list/samples = shape_noise.poisson_disk_sampling(min_x, max_x + 1, min_y, max_y + 1, spacing)
	var/pockets_placed = 0

	for(var/list/sample as anything in samples)
		if(pockets_placed >= deep_max_veins)
			break

		var/seed_x = round(sample[1])
		var/seed_y = round(sample[2])
		if(!wall_keys["[seed_x],[seed_y]"])
			continue
		if(ore_touches_existing(seed_x, seed_y, placed_ore))
			continue
		// The whole point: reject anything a player could stumble onto.
		if(is_near_floor(seed_x, seed_y, floor_map, deep_vein_clearance))
			continue

		var/ore_path = pickweight(weights)
		var/list/ore_config = deep_ore_table[ore_path]
		var/list/pocket = grow_deep_pocket(seed_x, seed_y, wall_keys, floor_map, ore_config["spread_chance"], ore_config["spread_range"], placed_ore, roll_ore_cluster_size())

		var/seed_key = "[seed_x],[seed_y]"
		for(var/pocket_key in pocket)
			var/turf/target = region[pocket_key]
			if(!target)
				continue
			var/tile_ore_path = (pocket_key == seed_key) ? ore_path : pickweight(weights)
			var/list/tile_ore_config = deep_ore_table[tile_ore_path]
			var/turf/closed/mineral/vein = target.ChangeTurf(tile_ore_path, wall_baseturfs)
			if(!ismineralturf(vein))
				continue
			vein.mineralAmt = rand(tile_ore_config["amount_min"], tile_ore_config["amount_max"])
			placed_ore[pocket_key] = TRUE
			wall_keys -= pocket_key

		pockets_placed++
		CHECK_TICK

/datum/map_generator/caves/proc/grow_deep_pocket(seed_x, seed_y, list/wall_keys, list/floor_map, spread_chance, spread_range, list/placed_ore, max_tiles)
	var/list/pocket = list("[seed_x],[seed_y]" = TRUE)
	var/list/active = list("[seed_x],[seed_y]")
	if(max_tiles <= 1 || spread_range < 1)
		return pocket

	for(var/iteration = 1 to deep_spread_iterations)
		var/list/next_active = list()

		for(var/key in active)
			var/list/parts = splittext(key, ",")
			var/current_x = text2num(parts[1])
			var/current_y = text2num(parts[2])

			// Only adjacent walls can grow; every deposit has a hard size cap.
			for(var/offset_x = -1 to 1)
				for(var/offset_y = -1 to 1)
					if(length(pocket) >= max_tiles)
						return pocket
					if(abs(offset_x) + abs(offset_y) != 1)
						continue
					if(!prob(spread_chance * (1 - (1 / (spread_range + 1)))))
						continue

					var/next_x = current_x + offset_x
					var/next_y = current_y + offset_y
					var/neighbor = "[next_x],[next_y]"
					if(pocket[neighbor] || !wall_keys[neighbor])
						continue
					if(ore_touches_existing(next_x, next_y, placed_ore))
						continue
					// Stop the pocket before it breaks the surface of a tunnel wall.
					if(is_near_floor(next_x, next_y, floor_map, deep_cluster_clearance))
						continue

					pocket[neighbor] = TRUE
					next_active += neighbor

		active = next_active
		if(!length(active))
			break
		CHECK_TICK

	return pocket

/**
 * Scatters decoration over the finished cave floor.
 *
 * Tiles are shuffled first, otherwise the assoc-list iteration order biases every
 * spawn toward whichever corner of the zone was carved first.
 */
/datum/map_generator/caves/proc/populate(list/region, list/floor_map)
	if(!length(decor_spawns))
		return

	// A flat key list, not shuffle(floor_map): list.Swap() on an associative list
	// reorders the keys without carrying their values along.
	var/list/open_keys = list()
	for(var/key in floor_map)
		open_keys += key
	open_keys = shuffle(open_keys)
	/// Tiles already holding something we placed, so entries never stack.
	var/list/occupied = list()
	/// Per-entry seed positions, for the spacing check.
	var/list/seeds_by_entry = list()
	var/processed = 0

	for(var/key in open_keys)
		var/turf/target = region[key]
		if(!isopenturf(target) || length(target.contents))
			continue
		if(occupied[key])
			continue

		processed++
		if(!(processed % 150))
			CHECK_TICK

		var/list/parts = splittext(key, ",")
		var/tile_x = text2num(parts[1])
		var/tile_y = text2num(parts[2])
		var/open_neighbors = count_open_neighbors(tile_x, tile_y, floor_map)

		for(var/entry_index = 1 to length(decor_spawns))
			var/list/entry = decor_spawns[entry_index]

			if(!prob(entry["chance"]))
				continue
			if(entry["open_min"] && open_neighbors < entry["open_min"])
				continue
			if(entry["near_wall"] && open_neighbors >= 8)
				continue

			LISTASSERTLEN(seeds_by_entry, entry_index, list())
			var/list/entry_seeds = seeds_by_entry[entry_index]
			if(entry["spacing"] && is_taken_near(tile_x, tile_y, entry_seeds, entry["spacing"]))
				continue

			spawn_decor_cluster(entry, region, floor_map, occupied, tile_x, tile_y)
			entry_seeds[key] = TRUE
			break

/datum/map_generator/caves/proc/spawn_decor_cluster(list/entry, list/region, list/floor_map, list/occupied, tile_x, tile_y)
	var/list/paths = entry["paths"]
	if(!length(paths))
		return

	var/amount = rand(entry["cluster_min"], entry["cluster_max"])
	var/cluster_radius = entry["cluster_radius"]
	var/placed = 0
	var/attempts = 0
	var/max_attempts = amount * 8

	while(placed < amount && attempts < max_attempts)
		attempts++

		var/spot_x = tile_x
		var/spot_y = tile_y
		if(cluster_radius > 0 && placed > 0)
			spot_x += rand(-cluster_radius, cluster_radius)
			spot_y += rand(-cluster_radius, cluster_radius)

		var/spot_key = "[spot_x],[spot_y]"
		if(!floor_map[spot_key] || occupied[spot_key])
			continue

		var/turf/spot = region[spot_key]
		if(!isopenturf(spot) || length(spot.contents))
			continue

		var/atom/decor_path = pickweight(paths)
		new decor_path(spot)
		occupied[spot_key] = TRUE
		placed++

/// Open neighbours in the 8-cell ring. 8 means the tile is fully surrounded by floor.
/datum/map_generator/caves/proc/count_open_neighbors(tile_x, tile_y, list/floor_map)
	var/found = 0
	for(var/offset_x = -1 to 1)
		for(var/offset_y = -1 to 1)
			if(!offset_x && !offset_y)
				continue
			if(floor_map["[tile_x + offset_x],[tile_y + offset_y]"])
				found++
	return found

/datum/map_generator/caves/proc/is_taken_near(tile_x, tile_y, list/taken, distance)
	if(!length(taken))
		return FALSE
	for(var/offset_x = -distance to distance)
		for(var/offset_y = -distance to distance)
			if(taken["[tile_x + offset_x],[tile_y + offset_y]"])
				return TRUE
	return FALSE
//RMH EDITED END
