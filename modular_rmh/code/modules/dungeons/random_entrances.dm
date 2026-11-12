#define RMH_RANDOM_ENTRANCE_LIMIT 12
#define RMH_ENTRANCE_SPACING 32
#define RMH_ENTRANCE_ROAD_DISTANCE 3
#define RMH_ENTRANCE_TRAVEL_DISTANCE 5

/datum/controller/subsystem/treesetup
	var/random_dungeon_entrances_initialized = FALSE

/datum/controller/subsystem/treesetup/proc/InitializeRandomDungeonEntrances()
	if(random_dungeon_entrances_initialized || SSmapping.config?.map_name != "Rivermist Hollow" || SSmapping.config.map_path != "map_files/hsector")
		return
	random_dungeon_entrances_initialized = TRUE
	var/list/quotas = list(
		/area/outdoors/rmh_field/west = 2,
		/area/outdoors/rmh_field/north = 1,
		/area/outdoors/rmh_field/east = 1,
		/area/outdoors/rmh_darkforest = 3,
		/area/outdoors/rmh_bog/north = 2,
		/area/outdoors/rmh_bog/south = 1,
		/area/outdoors/mountains/rmh_mountains/frozen = 2,
	)
	var/list/pools = list()
	var/list/entrances = list()
	var/list/surface_files = list("hsector.dmm", "bogforest.dmm", "frozen_mountains.dmm")
	for(var/zone in quotas)
		pools[zone] = list()
	var/list/surface_levels = list()
	var/list/surface_counts = list()
	// Select each loaded map's principal surface by its exact approved outdoor area coverage.
	for(var/z in 1 to length(SSmapping.z_list))
		var/map_file = SSmapping.level_trait(z, ZTRAIT_MAP_FILE)
		if(!(map_file in surface_files))
			continue
		var/zone_tiles = 0
		for(var/turf/tile as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			CHECK_TICK
			if(tile.loc.type in quotas)
				zone_tiles++
		if(zone_tiles > surface_counts[map_file])
			surface_counts[map_file] = zone_tiles
			surface_levels[map_file] = z
	for(var/map_file in surface_files)
		var/surface_z = surface_levels[map_file]
		if(surface_z)
			CollectRandomDungeonCandidates(surface_z, pools, entrances)
		else
			log_world("Random dungeons: no approved surface found for [map_file].")
	var/placed = 0
	var/list/zone_counts = list()
	var/list/quota_zones = shuffle(quotas)
	for(var/zone in quotas)
		zone_counts[zone] = 0
		var/list/candidates = pools[zone]
		shuffle_inplace(candidates)
	while(length(quota_zones))
		for(var/zone in quota_zones.Copy())
			var/list/candidates = pools[zone]
			if(zone_counts[zone] >= quotas[zone] || !length(candidates))
				quota_zones -= zone
				continue
			while(length(candidates))
				CHECK_TICK
				if(PlaceRandomDungeonEntrance(candidates, zone, entrances))
					zone_counts[zone]++
					placed++
					break
	for(var/zone in quotas)
		if(zone_counts[zone] < quotas[zone])
			log_world("Random dungeons: [zone] supplied [zone_counts[zone]]/[quotas[zone]] entrances; redistributing shortage.")
	var/list/fallback_zones = shuffle(quotas)
	// Consumed candidates never return to a pool, including candidates rejected for spacing.
	while(placed < RMH_RANDOM_ENTRANCE_LIMIT && length(fallback_zones))
		CHECK_TICK
		for(var/zone in fallback_zones.Copy())
			var/list/candidates = pools[zone]
			if(!length(candidates))
				fallback_zones -= zone
				continue
			if(PlaceRandomDungeonEntrance(candidates, zone, entrances))
				placed++
			if(placed >= RMH_RANDOM_ENTRANCE_LIMIT)
				break
	log_world("Random dungeons: placed [placed]/[RMH_RANDOM_ENTRANCE_LIMIT] entrances without changing mapped entrances.")
	// All candidate, connectivity and entrance references are local to startup.

/datum/controller/subsystem/treesetup/proc/CollectRandomDungeonCandidates(z, list/pools, list/entrances)
	var/list/walkable = list()
	var/list/approaches = list()
	var/list/excluded = list()
	for(var/turf/tile as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
		CHECK_TICK
		var/is_road = rmh_dungeon_road(tile)
		var/is_travel = (locate(/obj/structure/stairs) in tile) || (locate(/obj/structure/ladder) in tile) || (locate(/obj/structure/fluff/traveltile) in tile)
		for(var/obj/structure/dungeon_entrance/entrance in tile)
			entrances += tile
		if(is_road || is_travel)
			var/radius = is_travel ? RMH_ENTRANCE_TRAVEL_DISTANCE - 1 : RMH_ENTRANCE_ROAD_DISTANCE - 1
			for(var/turf/nearby as anything in block(locate(max(1, tile.x - radius), max(1, tile.y - radius), z), locate(min(world.maxx, tile.x + radius), min(world.maxy, tile.y + radius), z)))
				excluded[nearby] = TRUE
			if(rmh_dungeon_walkable(tile) && istype(tile.loc, /area/outdoors))
				approaches[tile] = TRUE
		if(pools[tile.loc.type] && rmh_dungeon_walkable(tile) && !is_travel)
			walkable[tile] = TRUE
	var/list/reachable = list()
	var/list/queue = list()
	for(var/turf/approach as anything in approaches)
		CHECK_TICK
		if(walkable[approach] && !reachable[approach])
			reachable[approach] = TRUE
			queue += approach
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(approach, direction)
			if(walkable[neighbor] && !reachable[neighbor])
				reachable[neighbor] = TRUE
				queue += neighbor
	// Cardinal edges cannot cross blocked diagonal corners.
	for(var/index = 1, index <= length(queue), index++)
		CHECK_TICK
		var/turf/tile = queue[index]
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(tile, direction)
			if(walkable[neighbor] && !reachable[neighbor])
				reachable[neighbor] = TRUE
				queue += neighbor
	for(var/turf/tile as anything in reachable)
		CHECK_TICK
		if(excluded[tile] || rmh_dungeon_road(tile) || tile.x <= 1 || tile.y <= 1 || tile.x >= world.maxx || tile.y >= world.maxy)
			continue
		if(rmh_dungeon_clear_footprint(tile, tile.loc.type))
			var/list/candidates = pools[tile.loc.type]
			candidates += tile

/datum/controller/subsystem/treesetup/proc/PlaceRandomDungeonEntrance(list/candidates, zone, list/entrances)
	var/turf/tile = candidates[length(candidates)]
	candidates.len--
	// Tick-budget yields can change occupancy after candidate collection.
	if(!rmh_dungeon_clear_footprint(tile, zone))
		return FALSE
	for(var/turf/nearby as anything in block(locate(max(1, tile.x - RMH_ENTRANCE_TRAVEL_DISTANCE + 1), max(1, tile.y - RMH_ENTRANCE_TRAVEL_DISTANCE + 1), tile.z), locate(min(world.maxx, tile.x + RMH_ENTRANCE_TRAVEL_DISTANCE - 1), min(world.maxy, tile.y + RMH_ENTRANCE_TRAVEL_DISTANCE - 1), tile.z)))
		if(get_dist(tile, nearby) < RMH_ENTRANCE_ROAD_DISTANCE && rmh_dungeon_road(nearby))
			return FALSE
		if((locate(/obj/structure/stairs) in nearby) || (locate(/obj/structure/ladder) in nearby) || (locate(/obj/structure/fluff/traveltile) in nearby))
			return FALSE
	for(var/turf/other as anything in entrances)
		if(other.z == tile.z && get_dist(other, tile) < RMH_ENTRANCE_SPACING)
			return FALSE
	var/entrance_type
	switch(zone)
		if(/area/outdoors/rmh_field/west, /area/outdoors/rmh_field/north, /area/outdoors/rmh_field/east)
			entrance_type = pick(/obj/structure/dungeon_entrance/bandit_hideout, /obj/structure/dungeon_entrance/wolf_den)
		if(/area/outdoors/rmh_darkforest)
			entrance_type = pick(/obj/structure/dungeon_entrance/wolf_den, /obj/structure/dungeon_entrance/bear_den)
		if(/area/outdoors/rmh_bog/north, /area/outdoors/rmh_bog/south)
			entrance_type = /obj/structure/dungeon_entrance/ratfolk_camp
		if(/area/outdoors/mountains/rmh_mountains/frozen)
			entrance_type = pick(/obj/structure/dungeon_entrance/bear_den, /obj/structure/dungeon_entrance/wolf_den)
	if(!entrance_type)
		return FALSE
	new entrance_type(tile)
	entrances += tile
	return TRUE

/proc/rmh_dungeon_clear_footprint(turf/tile, zone)
	if(!tile || tile.x <= 1 || tile.y <= 1 || tile.x >= world.maxx || tile.y >= world.maxy)
		return FALSE
	for(var/turf/footprint as anything in block(locate(tile.x - 1, tile.y - 1, tile.z), locate(tile.x + 1, tile.y + 1, tile.z)))
		if(footprint.loc.type != zone || !rmh_dungeon_walkable(footprint) || rmh_dungeon_road(footprint))
			return FALSE
		for(var/atom/movable/obstacle in footprint)
			if(obstacle.density || istype(obstacle, /obj/structure) || istype(obstacle, /obj/item))
				return FALSE
	return TRUE

/proc/rmh_dungeon_road(turf/tile)
	return istype(tile, /turf/open/floor/dirt/road) || istype(tile, /turf/open/floor/snowpath) || istype(tile, /turf/open/floor/abyss_sand/path)

/proc/rmh_dungeon_walkable(turf/tile)
	if(!tile || tile.density || !(istype(tile, /turf/open/floor/dirt) || istype(tile, /turf/open/floor/grass) || istype(tile, /turf/open/floor/snow) || istype(tile, /turf/open/floor/naturalstone) || rmh_dungeon_road(tile)))
		return FALSE
	for(var/atom/movable/obstacle in tile)
		if(obstacle.density)
			return FALSE
	return TRUE

#undef RMH_RANDOM_ENTRANCE_LIMIT
#undef RMH_ENTRANCE_SPACING
#undef RMH_ENTRANCE_ROAD_DISTANCE
#undef RMH_ENTRANCE_TRAVEL_DISTANCE
