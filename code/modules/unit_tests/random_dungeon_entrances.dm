#define RANDOM_DUNGEON_MIN_PLACED 9
#define RANDOM_DUNGEON_MAX_PLACED 12
#define RANDOM_DUNGEON_SPACING 32
#define RANDOM_DUNGEON_ROAD_DISTANCE 3

/// TRUE when the loaded map is the one the random entrances are placed on.
/proc/random_dungeon_map_loaded()
	return SSmapping.config?.map_name == "Rivermist Hollow" && SSmapping.config.map_path == "map_files/hsector"

/// Footprint, spacing and zone type rules on scratch turfs.
/datum/unit_test/random_dungeon_entrance_rules

/datum/unit_test/random_dungeon_entrance_rules/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/turf/center = locate(corner.x + 2, corner.y + 2, corner.z)
	TEST_ASSERT_NOTNULL(center, "The test room should hold a 3x3 footprint.")
	var/zone = center.loc.type
	var/list/footprint = block(locate(center.x - 1, center.y - 1, center.z), locate(center.x + 1, center.y + 1, center.z))
	var/list/original_types = list()
	for(var/turf/tile as anything in footprint)
		original_types += tile.type
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "Built floor must not count as natural ground.")
	for(var/turf/tile as anything in footprint)
		tile.ChangeTurf(/turf/open/floor/dirt)
	TEST_ASSERT(rmh_dungeon_clear_footprint(center, zone), "An empty 3x3 of dirt in the zone should be clear.")
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, /area/outdoors/rmh_field/west), "A footprint outside the zone area must fail.")
	// block() runs row by row from the south-west corner: 1 SW, 2 S, 3 SE, 4 W, 5 centre, 6 E, 7 NW, 8 N, 9 NE.
	var/turf/edge = footprint[1]
	var/turf/south = footprint[2]
	var/turf/north = footprint[8]
	TEST_ASSERT_EQUAL(center, footprint[5], "The fifth footprint tile should be the centre.")
	var/obj/item/grown/log/tree/stick/stick = allocate(/obj/item/grown/log/tree/stick, north)
	TEST_ASSERT(rmh_dungeon_clear_footprint(center, zone), "A stick on a neighbour tile should not block the footprint.")
	stick.forceMove(center)
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "A stick on the centre tile must block it.")
	qdel(stick)
	var/obj/structure/flora/grass/grass = allocate(/obj/structure/flora/grass, edge)
	TEST_ASSERT(rmh_dungeon_clear_footprint(center, zone), "Grass on a south neighbour should not block the footprint.")
	grass.forceMove(north)
	TEST_ASSERT(rmh_dungeon_clear_footprint(center, zone), "Low grass north of the centre should be allowed.")
	TEST_ASSERT(rmh_dungeon_footprint_fault(center, zone, FALSE), "Grass north of the centre draws over the entrance, so it is not an uncovered spot.")
	grass.forceMove(edge)
	TEST_ASSERT(!rmh_dungeon_footprint_fault(center, zone, FALSE), "Grass on a south neighbour leaves the entrance uncovered.")
	grass.forceMove(center)
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "Grass on the centre tile must block it.")
	qdel(grass)
	var/obj/structure/flora/grass/bush/bush = allocate(/obj/structure/flora/grass/bush, south)
	TEST_ASSERT(!bush.density, "The test bush should not be dense.")
	TEST_ASSERT(rmh_dungeon_clear_footprint(center, zone), "A bush south of the centre should be allowed.")
	bush.forceMove(north)
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "A tall bush north of the centre would hide the entrance and must block it.")
	qdel(bush)
	var/obj/structure/flora/tree/tree = allocate(/obj/structure/flora/tree, south)
	TEST_ASSERT(tree.density, "The test tree should be dense.")
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "A dense tree on a neighbour tile must block it.")
	qdel(tree)
	var/obj/structure/chair/bench/ancientlog/bench = allocate(/obj/structure/chair/bench/ancientlog, south)
	TEST_ASSERT(!bench.density, "The test bench should not be dense.")
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "Furniture on a neighbour tile must block it even when it is not dense.")
	qdel(bench)
	var/obj/structure/flora/grass/herb/urtica/herb = allocate(/obj/structure/flora/grass/herb/urtica, south)
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "A harvestable herb, a grass subtype, must still block a neighbour tile.")
	qdel(herb)
	TEST_ASSERT(rmh_dungeon_clear_footprint(center, zone), "Removing the obstacles should clear the footprint again.")
	edge.ChangeTurf(/turf/open/floor/dirt/road)
	TEST_ASSERT(!rmh_dungeon_clear_footprint(center, zone), "A road tile in the footprint must block it.")
	for(var/index in 1 to length(footprint))
		var/turf/tile = footprint[index]
		tile.ChangeTurf(original_types[index])

	// The test room is small, so the spacing rule is checked at the corner-to-centre distance.
	var/gap = get_dist(corner, center)
	TEST_ASSERT(rmh_dungeon_spaced(center, list(corner), gap), "An entrance exactly at the spacing distance is allowed.")
	TEST_ASSERT(!rmh_dungeon_spaced(center, list(corner), gap + 1), "An entrance closer than the spacing distance is refused.")
	TEST_ASSERT(rmh_dungeon_spaced(center, list(), RANDOM_DUNGEON_SPACING), "No entrances means any spot is spaced.")

	var/list/expected = list(
		/area/outdoors/rmh_field/west = list(/obj/structure/dungeon_entrance/bandit_hideout, /obj/structure/dungeon_entrance/wolf_den),
		/area/outdoors/rmh_field/north = list(/obj/structure/dungeon_entrance/bandit_hideout, /obj/structure/dungeon_entrance/wolf_den),
		/area/outdoors/rmh_field/east = list(/obj/structure/dungeon_entrance/bandit_hideout, /obj/structure/dungeon_entrance/wolf_den),
		/area/outdoors/rmh_darkforest = list(/obj/structure/dungeon_entrance/wolf_den, /obj/structure/dungeon_entrance/bear_den),
		/area/outdoors/rmh_bog/north = list(/obj/structure/dungeon_entrance/ratfolk_camp),
		/area/outdoors/rmh_bog/south = list(/obj/structure/dungeon_entrance/ratfolk_camp),
		/area/outdoors/mountains/rmh_mountains/frozen = list(/obj/structure/dungeon_entrance/bear_den, /obj/structure/dungeon_entrance/wolf_den),
	)
	for(var/zone_type in expected)
		var/list/allowed = rmh_dungeon_zone_types(zone_type)
		var/list/wanted = expected[zone_type]
		TEST_ASSERT_EQUAL(length(allowed), length(wanted), "[zone_type] should allow [length(wanted)] entrance types.")
		for(var/entrance_type in wanted)
			TEST_ASSERT(entrance_type in allowed, "[zone_type] should allow [entrance_type].")
	TEST_ASSERT(!length(rmh_dungeon_zone_types(/area/outdoors/rmh_field)), "The parent field area is not an approved zone.")

/// The round's random entrances obey the placement rules and leave mapped ones alone.
/datum/unit_test/random_dungeon_entrance_placement

/datum/unit_test/random_dungeon_entrance_placement/Run()
	if(!random_dungeon_map_loaded())
		TEST_NOTICE(src, "Random dungeon entrances are placed only on Rivermist Hollow; nothing to check on [SSmapping.config?.map_name].")
		return
	TEST_ASSERT(SStreesetup.random_dungeon_entrances_initialized, "Random entrance placement should have run at startup.")
	var/list/records = SStreesetup.random_dungeon_entrance_records.Copy()
	TEST_ASSERT(length(records) >= RANDOM_DUNGEON_MIN_PLACED, "Expected at least [RANDOM_DUNGEON_MIN_PLACED] random entrances, got [length(records)]: [jointext(SStreesetup.random_dungeon_entrance_report, " / ")]")
	TEST_ASSERT(length(records) <= RANDOM_DUNGEON_MAX_PLACED, "Expected at most [RANDOM_DUNGEON_MAX_PLACED] random entrances, got [length(records)].")

	var/list/map_files = list("hsector.dmm" = 6, "frozen_mountains.dmm" = 6, "bogforest.dmm" = 10)
	var/list/all_entrances = list()
	for(var/obj/structure/dungeon_entrance/entrance in world)
		var/turf/entrance_turf = get_turf(entrance)
		if(entrance_turf && (SSmapping.level_trait(entrance_turf.z, ZTRAIT_MAP_FILE) in map_files))
			all_entrances += entrance

	var/list/random_entrances = list()
	var/list/zone_placed = list()
	for(var/record in records)
		var/list/fields = splittext(record, "|")
		TEST_ASSERT_EQUAL(length(fields), 5, "Record [record] should hold type, x, y, z and area.")
		var/entrance_type = text2path(fields[1])
		var/turf/tile = locate(text2num(fields[2]), text2num(fields[3]), text2num(fields[4]))
		TEST_ASSERT_NOTNULL(tile, "Record [record] should point at a turf.")
		var/obj/structure/dungeon_entrance/entrance = locate(entrance_type) in tile
		TEST_ASSERT_NOTNULL(entrance, "Record [record] should have its entrance on the turf.")
		random_entrances += entrance
		var/area/tile_area = tile.loc
		zone_placed[tile_area.type]++
		var/list/allowed = rmh_dungeon_zone_types(tile_area.type)
		TEST_ASSERT(length(allowed), "[record] stands in [tile_area.type], which is not an approved zone.")
		TEST_ASSERT(entrance.type in allowed, "[record] has a type not allowed in [tile_area.type].")
		TEST_ASSERT(rmh_dungeon_walkable(tile), "[record] should stand on walkable natural ground.")
		for(var/turf/nearby as anything in RANGE_TURFS(RANDOM_DUNGEON_ROAD_DISTANCE - 1, tile))
			TEST_ASSERT(!rmh_dungeon_road(nearby), "[record] is within [RANDOM_DUNGEON_ROAD_DISTANCE - 1] tiles of a road at [nearby.x],[nearby.y].")
		for(var/obj/structure/dungeon_entrance/other as anything in all_entrances)
			if(other == entrance || other.z != tile.z)
				continue
			TEST_ASSERT(get_dist(other, tile) >= RANDOM_DUNGEON_SPACING, "[record] is [get_dist(other, tile)] tiles from [other.type] at [other.x],[other.y].")

	// Water, roads and generated flora leave the bogs with few or no clear 3x3 spots, so a bog may get no camp.
	for(var/bog_zone in list(/area/outdoors/rmh_bog/north, /area/outdoors/rmh_bog/south))
		var/candidates = SStreesetup.random_dungeon_entrance_candidates[bog_zone]
		if(!zone_placed[bog_zone])
			TEST_NOTICE(src, "[bog_zone] got no random entrance ([candidates] candidates).")
	for(var/map_file in map_files)
		var/mapped = 0
		for(var/obj/structure/dungeon_entrance/entrance as anything in all_entrances)
			if(!(entrance in random_entrances) && SSmapping.level_trait(entrance.z, ZTRAIT_MAP_FILE) == map_file)
				mapped++
				var/turf/mapped_turf = get_turf(entrance)
				if(!rmh_dungeon_walkable(mapped_turf))
					TEST_NOTICE(src, "Mapped [entrance.type] at [mapped_turf.x],[mapped_turf.y],[mapped_turf.z] is not on open natural ground ([mapped_turf.type], [mapped_turf.loc.type]).")
		TEST_ASSERT_EQUAL(mapped, map_files[map_file], "[map_file] should keep all of its mapped entrances.")

	var/total_before = length(all_entrances)
	SStreesetup.InitializeRandomDungeonEntrances()
	TEST_ASSERT_EQUAL(length(SStreesetup.random_dungeon_entrance_records), length(records), "A second placement call must not add records.")
	var/total_after = 0
	for(var/obj/structure/dungeon_entrance/entrance in world)
		var/turf/entrance_turf = get_turf(entrance)
		if(entrance_turf && (SSmapping.level_trait(entrance_turf.z, ZTRAIT_MAP_FILE) in map_files))
			total_after++
	TEST_ASSERT_EQUAL(total_after, total_before, "A second placement call must not add entrances.")

/// A random entrance opens its themed dungeon and returns the delver to it.
/datum/unit_test/random_dungeon_entrance_opens
	needs_pocket_space = TRUE

/datum/unit_test/random_dungeon_entrance_opens/Run()
	if(!random_dungeon_map_loaded())
		TEST_NOTICE(src, "Random dungeon entrances are placed only on Rivermist Hollow; nothing to open on [SSmapping.config?.map_name].")
		return
	var/list/records = SStreesetup.random_dungeon_entrance_records
	TEST_ASSERT(length(records), "No random entrance was placed, so none can be opened.")
	var/list/fields = splittext(records[1], "|")
	TEST_ASSERT_EQUAL(length(fields), 5, "Record [records[1]] should hold type, x, y, z and area.")
	var/turf/origin = locate(text2num(fields[2]), text2num(fields[3]), text2num(fields[4]))
	TEST_ASSERT_NOTNULL(origin, "Record [records[1]] should point at a turf.")
	var/obj/structure/dungeon_entrance/entrance = locate(text2path(fields[1])) in origin
	TEST_ASSERT_NOTNULL(entrance, "Record [records[1]] should have its entrance on the turf.")
	TEST_ASSERT(entrance.icon_state in icon_states(entrance.icon), "A random entrance should have a drawable icon state.")
	TEST_ASSERT(entrance.invisibility <= SEE_INVISIBLE_LIVING, "A random entrance should be visible.")
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, origin)
	var/datum/pocket_dimension/dungeon/room = entrance.get_entry_room(delver)
	TEST_ASSERT_NOTNULL(room, "[entrance] at [origin.x],[origin.y],[origin.z] should open a dungeon.")
	TEST_ASSERT(entrance.try_enter(delver), "[entrance] should admit a delver.")
	TEST_ASSERT(room.contains_turf(get_turf(delver)), "[entrance] should deliver the delver into its room.")
	TEST_ASSERT(room.exit_mob(delver), "The room's return seam should work.")
	TEST_ASSERT_EQUAL(get_turf(delver), origin, "The return seam should lead back to the random entrance.")
	SSpocket_dimensions.delete_instance(entrance.get_instance_key())
	TEST_ASSERT(!QDELETED(entrance), "Closing the dungeon must keep the entrance.")

#undef RANDOM_DUNGEON_MIN_PLACED
#undef RANDOM_DUNGEON_MAX_PLACED
#undef RANDOM_DUNGEON_SPACING
#undef RANDOM_DUNGEON_ROAD_DISTANCE
