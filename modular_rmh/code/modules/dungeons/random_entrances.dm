#define RMH_RANDOM_ENTRANCE_LIMIT 12
#define RMH_ENTRANCE_SPACING 32
#define RMH_ENTRANCE_ROAD_DISTANCE 3
#define RMH_ENTRANCE_TRAVEL_DISTANCE 5

// Stage counter slots, one list per zone.
#define RMH_STAT_TILES 1
#define RMH_STAT_WALKABLE 2
#define RMH_STAT_REACHABLE 3
#define RMH_STAT_OPEN 4
#define RMH_STAT_CANDIDATES 5
#define RMH_STAT_FAULT_AREA 6
#define RMH_STAT_FAULT_GROUND 7
#define RMH_STAT_FAULT_DENSE 8
#define RMH_STAT_FAULT_STRUCTURE 9
#define RMH_STAT_FAULT_ITEM 10
#define RMH_STAT_CONSUMED 11
#define RMH_STAT_REJECT_FOOTPRINT 12
#define RMH_STAT_REJECT_ROAD 13
#define RMH_STAT_REJECT_SPACING 14
#define RMH_STAT_PLACED 15
#define RMH_STAT_COVERED 16
#define RMH_STAT_COUNT 16

// Footprint faults returned by rmh_dungeon_footprint_fault().
#define RMH_FOOTPRINT_CLEAR 0
#define RMH_FOOTPRINT_AREA 1
#define RMH_FOOTPRINT_GROUND 2
#define RMH_FOOTPRINT_DENSE 3
#define RMH_FOOTPRINT_STRUCTURE 4
#define RMH_FOOTPRINT_ITEM 5

// Natural clutter kinds returned by rmh_dungeon_clutter_kind().
#define RMH_CLUTTER_NONE 0
#define RMH_CLUTTER_SMALL 1
#define RMH_CLUTTER_LOW 2
#define RMH_CLUTTER_TALL 3

/datum/controller/subsystem/treesetup
	var/random_dungeon_entrances_initialized = FALSE
	/// Text records "type|x|y|z|area" of entrances placed this round.
	var/list/random_dungeon_entrance_records = list()
	/// Diagnostic lines written at placement, kept for admins and tests.
	var/list/random_dungeon_entrance_report = list()
	/// Candidate tile count per zone type at placement, kept for admins and tests.
	var/list/random_dungeon_entrance_candidates = list()
	/// Real seconds the placement took.
	var/random_dungeon_entrance_seconds = 0

/datum/controller/subsystem/treesetup/proc/InitializeRandomDungeonEntrances()
	if(random_dungeon_entrances_initialized || SSmapping.config?.map_name != "Rivermist Hollow" || SSmapping.config.map_path != "map_files/hsector")
		return
	random_dungeon_entrances_initialized = TRUE
	var/start_time = REALTIMEOFDAY
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
	var/list/covered_pools = list()
	var/list/stats = list()
	var/list/entrances = list()
	var/list/surface_files = list("hsector.dmm", "bogforest.dmm", "frozen_mountains.dmm")
	for(var/zone in quotas)
		pools[zone] = list()
		covered_pools[zone] = list()
		var/list/zone_stats = new /list(RMH_STAT_COUNT)
		for(var/index in 1 to RMH_STAT_COUNT)
			zone_stats[index] = 0
		stats[zone] = zone_stats
	var/list/surface_levels = list()
	var/list/surface_counts = list()
	// Select each loaded map's principal surface by its exact approved outdoor area coverage.
	for(var/z in 1 to length(SSmapping.z_list))
		var/map_file = SSmapping.level_trait(z, ZTRAIT_MAP_FILE)
		if(!(map_file in surface_files))
			continue
		var/zone_tiles = 0
		for(var/zone in quotas)
			var/area/zone_area = GLOB.areas_by_type[zone]
			if(zone_area)
				zone_tiles += length(zone_area.get_turfs_by_zlevel(z))
		if(zone_tiles > surface_counts[map_file])
			surface_counts[map_file] = zone_tiles
			surface_levels[map_file] = z
	for(var/map_file in surface_files)
		var/surface_z = surface_levels[map_file]
		if(surface_z)
			var/approach_count = CollectRandomDungeonCandidates(surface_z, pools, covered_pools, entrances, stats)
			random_dungeon_log("[map_file] z[surface_z]: [surface_counts[map_file]] zone tiles, [approach_count] approach tiles, [length(entrances)] entrances known.")
		else
			random_dungeon_log("no approved surface found for [map_file].")
	var/placed = 0
	var/list/zone_counts = list()
	var/list/quota_zones = shuffle(quotas)
	for(var/zone in quotas)
		zone_counts[zone] = 0
		// Candidates are drawn from the end, so tiles whose grass overlaps the sprite go first in the list.
		pools[zone] = shuffle(covered_pools[zone]) + shuffle(pools[zone])
	while(length(quota_zones))
		for(var/zone in quota_zones.Copy())
			var/list/candidates = pools[zone]
			if(zone_counts[zone] >= quotas[zone] || !length(candidates))
				quota_zones -= zone
				continue
			while(length(candidates))
				CHECK_TICK
				if(PlaceRandomDungeonEntrance(candidates, zone, entrances, stats[zone]))
					zone_counts[zone]++
					placed++
					break
	var/list/fallback_zones = shuffle(quotas)
	// Consumed candidates never return to a pool, including candidates rejected for spacing.
	while(placed < RMH_RANDOM_ENTRANCE_LIMIT && length(fallback_zones))
		CHECK_TICK
		for(var/zone in fallback_zones.Copy())
			var/list/candidates = pools[zone]
			if(!length(candidates))
				fallback_zones -= zone
				continue
			if(PlaceRandomDungeonEntrance(candidates, zone, entrances, stats[zone]))
				placed++
			if(placed >= RMH_RANDOM_ENTRANCE_LIMIT)
				break
	for(var/zone in quotas)
		var/list/zone_stats = stats[zone]
		random_dungeon_entrance_candidates[zone] = zone_stats[RMH_STAT_CANDIDATES]
		random_dungeon_log("[zone] quota [quotas[zone]]: tiles [zone_stats[RMH_STAT_TILES]], walkable [zone_stats[RMH_STAT_WALKABLE]], reachable [zone_stats[RMH_STAT_REACHABLE]], open [zone_stats[RMH_STAT_OPEN]], candidates [zone_stats[RMH_STAT_CANDIDATES]] (grass over the sprite on [zone_stats[RMH_STAT_COVERED]]); footprint faults area [zone_stats[RMH_STAT_FAULT_AREA]], ground [zone_stats[RMH_STAT_FAULT_GROUND]], dense [zone_stats[RMH_STAT_FAULT_DENSE]], structure [zone_stats[RMH_STAT_FAULT_STRUCTURE]], item [zone_stats[RMH_STAT_FAULT_ITEM]]; consumed [zone_stats[RMH_STAT_CONSUMED]], rejected footprint [zone_stats[RMH_STAT_REJECT_FOOTPRINT]], road or travel [zone_stats[RMH_STAT_REJECT_ROAD]], spacing [zone_stats[RMH_STAT_REJECT_SPACING]]; placed [zone_stats[RMH_STAT_PLACED]].")
	random_dungeon_entrance_seconds = (REALTIMEOFDAY - start_time) / 10
	random_dungeon_log("placed [placed]/[RMH_RANDOM_ENTRANCE_LIMIT] entrances in [random_dungeon_entrance_seconds] s without changing mapped entrances.")
	for(var/record in random_dungeon_entrance_records)
		random_dungeon_log("entrance [record]")
	// All candidate, connectivity and entrance references are local to startup.

/datum/controller/subsystem/treesetup/stat_entry(msg)
	msg = "Random dungeons: [length(random_dungeon_entrance_records)]"
	return ..()

/datum/controller/subsystem/treesetup/proc/random_dungeon_log(text)
	random_dungeon_entrance_report += text
	log_world("Random dungeons: [text]")

/// Fills zone pools with reachable clear tiles on one level; returns the approach tile count.
/datum/controller/subsystem/treesetup/proc/CollectRandomDungeonCandidates(z, list/pools, list/covered_pools, list/entrances, list/stats)
	var/alist/walkable = alist()
	var/alist/approaches = alist()
	var/alist/excluded = alist()
	for(var/turf/tile as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
		CHECK_TICK
		var/is_road = rmh_dungeon_road(tile)
		var/is_travel = FALSE
		var/blocked = FALSE
		// One pass over the contents finds blockers, entrances and travel objects.
		for(var/atom/movable/thing as anything in tile)
			if(thing.density)
				blocked = TRUE
			if(istype(thing, /obj/structure/dungeon_entrance))
				entrances += tile
			else if(istype(thing, /obj/structure/stairs) || istype(thing, /obj/structure/ladder) || istype(thing, /obj/structure/fluff/traveltile))
				is_travel = TRUE
		var/is_walkable = !blocked && rmh_dungeon_natural_ground(tile)
		if(is_road || is_travel)
			var/radius = is_travel ? RMH_ENTRANCE_TRAVEL_DISTANCE - 1 : RMH_ENTRANCE_ROAD_DISTANCE - 1
			for(var/turf/nearby as anything in block(locate(max(1, tile.x - radius), max(1, tile.y - radius), z), locate(min(world.maxx, tile.x + radius), min(world.maxy, tile.y + radius), z)))
				excluded[nearby] = TRUE
			if(is_walkable && istype(tile.loc, /area/outdoors))
				approaches[tile] = TRUE
		var/list/zone_stats = stats[tile.loc.type]
		if(!zone_stats)
			continue
		zone_stats[RMH_STAT_TILES]++
		if(is_walkable && !is_travel)
			walkable[tile] = TRUE
			zone_stats[RMH_STAT_WALKABLE]++
	var/alist/reachable = alist()
	var/list/queue = list()
	for(var/turf/approach as anything in approaches)
		CHECK_TICK
		if(walkable[approach] && !reachable[approach])
			reachable[approach] = TRUE
			queue += approach
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(approach, direction)
			if(neighbor && walkable[neighbor] && !reachable[neighbor])
				reachable[neighbor] = TRUE
				queue += neighbor
	// Cardinal edges cannot cross blocked diagonal corners.
	for(var/index = 1, index <= length(queue), index++)
		CHECK_TICK
		var/turf/tile = queue[index]
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(tile, direction)
			if(neighbor && walkable[neighbor] && !reachable[neighbor])
				reachable[neighbor] = TRUE
				queue += neighbor
	for(var/turf/tile as anything in reachable)
		CHECK_TICK
		var/list/zone_stats = stats[tile.loc.type]
		zone_stats[RMH_STAT_REACHABLE]++
		if(excluded[tile] || rmh_dungeon_road(tile) || tile.x <= 1 || tile.y <= 1 || tile.x >= world.maxx || tile.y >= world.maxy)
			continue
		zone_stats[RMH_STAT_OPEN]++
		var/fault = rmh_dungeon_footprint_fault(tile, tile.loc.type)
		if(fault)
			zone_stats[RMH_STAT_FAULT_AREA + fault - RMH_FOOTPRINT_AREA]++
			continue
		zone_stats[RMH_STAT_CANDIDATES]++
		var/list/candidates = pools[tile.loc.type]
		if(rmh_dungeon_footprint_fault(tile, tile.loc.type, FALSE))
			zone_stats[RMH_STAT_COVERED]++
			candidates = covered_pools[tile.loc.type]
		candidates += tile
	return length(approaches)

/datum/controller/subsystem/treesetup/proc/PlaceRandomDungeonEntrance(list/candidates, zone, list/entrances, list/zone_stats)
	var/turf/tile = candidates[length(candidates)]
	candidates.len--
	zone_stats[RMH_STAT_CONSUMED]++
	// Tick-budget yields can change occupancy after candidate collection.
	if(rmh_dungeon_footprint_fault(tile, zone))
		zone_stats[RMH_STAT_REJECT_FOOTPRINT]++
		return FALSE
	for(var/turf/nearby as anything in block(locate(max(1, tile.x - RMH_ENTRANCE_TRAVEL_DISTANCE + 1), max(1, tile.y - RMH_ENTRANCE_TRAVEL_DISTANCE + 1), tile.z), locate(min(world.maxx, tile.x + RMH_ENTRANCE_TRAVEL_DISTANCE - 1), min(world.maxy, tile.y + RMH_ENTRANCE_TRAVEL_DISTANCE - 1), tile.z)))
		if((get_dist(tile, nearby) < RMH_ENTRANCE_ROAD_DISTANCE && rmh_dungeon_road(nearby)) || rmh_dungeon_travel(nearby))
			zone_stats[RMH_STAT_REJECT_ROAD]++
			return FALSE
	if(!rmh_dungeon_spaced(tile, entrances, RMH_ENTRANCE_SPACING))
		zone_stats[RMH_STAT_REJECT_SPACING]++
		return FALSE
	var/entrance_type = pick(rmh_dungeon_zone_types(zone))
	if(!entrance_type)
		return FALSE
	new entrance_type(tile)
	entrances += tile
	zone_stats[RMH_STAT_PLACED]++
	var/area/zone_area = tile.loc
	random_dungeon_entrance_records += "[entrance_type]|[tile.x]|[tile.y]|[tile.z]|[zone_area.name]"
	return TRUE

/// Entrance types allowed in an approved zone; an empty list for any other area type.
/proc/rmh_dungeon_zone_types(zone)
	switch(zone)
		if(/area/outdoors/rmh_field/west, /area/outdoors/rmh_field/north, /area/outdoors/rmh_field/east)
			return list(/obj/structure/dungeon_entrance/bandit_hideout, /obj/structure/dungeon_entrance/wolf_den)
		if(/area/outdoors/rmh_darkforest)
			return list(/obj/structure/dungeon_entrance/wolf_den, /obj/structure/dungeon_entrance/bear_den)
		if(/area/outdoors/rmh_bog/north, /area/outdoors/rmh_bog/south)
			return list(/obj/structure/dungeon_entrance/ratfolk_camp)
		if(/area/outdoors/mountains/rmh_mountains/frozen)
			return list(/obj/structure/dungeon_entrance/bear_den, /obj/structure/dungeon_entrance/wolf_den)
	return list()

/// TRUE when no listed entrance turf on the same level lies closer than spacing tiles.
/proc/rmh_dungeon_spaced(turf/tile, list/entrances, spacing)
	for(var/turf/other as anything in entrances)
		if(other.z == tile.z && get_dist(other, tile) < spacing)
			return FALSE
	return TRUE

/proc/rmh_dungeon_clear_footprint(turf/tile, zone)
	return !rmh_dungeon_footprint_fault(tile, zone)

/// First fault that blocks a 3x3 footprint centred on tile, or RMH_FOOTPRINT_CLEAR; allow_cover lets low grass overlap the sprite.
/proc/rmh_dungeon_footprint_fault(turf/tile, zone, allow_cover = TRUE)
	if(!tile || tile.x <= 1 || tile.y <= 1 || tile.x >= world.maxx || tile.y >= world.maxy)
		return RMH_FOOTPRINT_AREA
	for(var/turf/footprint as anything in block(locate(tile.x - 1, tile.y - 1, tile.z), locate(tile.x + 1, tile.y + 1, tile.z)))
		if(footprint.loc.type != zone)
			return RMH_FOOTPRINT_AREA
		if(!rmh_dungeon_natural_ground(footprint) || rmh_dungeon_road(footprint))
			return RMH_FOOTPRINT_GROUND
		// The 64x64 entrance sprite overlaps the west, east and north tiles; the south row stays uncovered.
		var/south_row = footprint.y < tile.y
		for(var/atom/movable/obstacle in footprint)
			if(obstacle.density)
				return RMH_FOOTPRINT_DENSE
			if(!isstructure(obstacle) && !isitem(obstacle))
				continue
			var/clutter = footprint == tile ? RMH_CLUTTER_NONE : rmh_dungeon_clutter_kind(obstacle)
			if(clutter == RMH_CLUTTER_SMALL || (clutter != RMH_CLUTTER_NONE && south_row) || (clutter == RMH_CLUTTER_LOW && allow_cover))
				continue
			return isstructure(obstacle) ? RMH_FOOTPRINT_STRUCTURE : RMH_FOOTPRINT_ITEM
	return RMH_FOOTPRINT_CLEAR

/// Natural ground clutter allowed beside an entrance, by exact type; anything made or functional is RMH_CLUTTER_NONE.
/proc/rmh_dungeon_clutter_kind(atom/movable/thing)
	switch(thing.type)
		// Sticks and stones cover only a few pixels of the entrance.
		if(/obj/item/grown/log/tree/stick, /obj/item/natural/stone)
			return RMH_CLUTTER_SMALL
		// Grass tufts and creeping vines lie low but fill their tile.
		if(/obj/structure/flora/grass, /obj/structure/flora/grass/fullgrass_autumn, /obj/structure/flora/grass/sparegrass, /obj/structure/flora/grass/swampweed, /obj/structure/flora/grass/water)
			return RMH_CLUTTER_LOW
		if(/obj/structure/flora/grass/tundra, /obj/structure/flora/grass/green, /obj/structure/flora/grass/brown, /obj/structure/flora/grass/both, /obj/structure/vine)
			return RMH_CLUTTER_LOW
		// Bushes draw above mobs and big rocks are bulky; both may stand only south of the entrance.
		if(/obj/structure/flora/grass/bush, /obj/structure/flora/grass/bush/tundra, /obj/structure/flora/grass/bush_meagre, /obj/structure/flora/grass/bush_meagre/tundra, /obj/structure/flora/grass/bush_meagre/yellow)
			return RMH_CLUTTER_TALL
		if(/obj/item/natural/rock)
			return RMH_CLUTTER_TALL
	return RMH_CLUTTER_NONE

/proc/rmh_dungeon_road(turf/tile)
	return istype(tile, /turf/open/floor/dirt/road) || istype(tile, /turf/open/floor/snowpath) || istype(tile, /turf/open/floor/abyss_sand/path)

/proc/rmh_dungeon_travel(turf/tile)
	return (locate(/obj/structure/stairs) in tile) || (locate(/obj/structure/ladder) in tile) || (locate(/obj/structure/fluff/traveltile) in tile)

/proc/rmh_dungeon_natural_ground(turf/tile)
	return !tile.density && (istype(tile, /turf/open/floor/dirt) || istype(tile, /turf/open/floor/grass) || istype(tile, /turf/open/floor/snow) || istype(tile, /turf/open/floor/naturalstone) || rmh_dungeon_road(tile))

/proc/rmh_dungeon_walkable(turf/tile)
	if(!tile || !rmh_dungeon_natural_ground(tile))
		return FALSE
	for(var/atom/movable/obstacle in tile)
		if(obstacle.density)
			return FALSE
	return TRUE

#undef RMH_RANDOM_ENTRANCE_LIMIT
#undef RMH_ENTRANCE_SPACING
#undef RMH_ENTRANCE_ROAD_DISTANCE
#undef RMH_ENTRANCE_TRAVEL_DISTANCE
#undef RMH_STAT_TILES
#undef RMH_STAT_WALKABLE
#undef RMH_STAT_REACHABLE
#undef RMH_STAT_OPEN
#undef RMH_STAT_CANDIDATES
#undef RMH_STAT_FAULT_AREA
#undef RMH_STAT_FAULT_GROUND
#undef RMH_STAT_FAULT_DENSE
#undef RMH_STAT_FAULT_STRUCTURE
#undef RMH_STAT_FAULT_ITEM
#undef RMH_STAT_CONSUMED
#undef RMH_STAT_REJECT_FOOTPRINT
#undef RMH_STAT_REJECT_ROAD
#undef RMH_STAT_REJECT_SPACING
#undef RMH_STAT_PLACED
#undef RMH_STAT_COVERED
#undef RMH_STAT_COUNT
#undef RMH_FOOTPRINT_CLEAR
#undef RMH_FOOTPRINT_AREA
#undef RMH_FOOTPRINT_GROUND
#undef RMH_FOOTPRINT_DENSE
#undef RMH_FOOTPRINT_STRUCTURE
#undef RMH_FOOTPRINT_ITEM
#undef RMH_CLUTTER_NONE
#undef RMH_CLUTTER_SMALL
#undef RMH_CLUTTER_LOW
#undef RMH_CLUTTER_TALL
