//RMH EDITED START - zone cave generation
/*
 * Presets. Paint one of these area types over the rock you want hollowed out.
 * Everything outside the painted area is left exactly as the mapper built it.
 */

/**
 * Everything in one zone: narrow winding passages, occasional large halls,
 * tunnels that widen and pinch along their length, and rich ore pockets buried
 * deep in the rock where no tunnel reaches them.
 *
 * Chamber radius is rolled per chamber, so hall_chance controls the ratio of
 * cramped junctions to open galleries rather than the size of everything.
 */
/datum/map_generator/caves/mixed
	name = "Mixed Cave Generator"
	chamber_spacing = 15
	chamber_min_radius = 2
	chamber_max_radius = 4
	hall_chance = 25
	hall_min_radius = 5
	hall_max_radius = 8
	chamber_edge_noise = 0.35
	tunnel_radius_min = 0
	tunnel_radius_max = 2
	tunnel_wander = 35
	// A high shift rate is what makes one corridor crawl-narrow in places and
	// open into a gallery in others instead of holding a constant width.
	tunnel_width_shift = 16
	extra_loop_ratio = 0.25
	smoothing_passes = 2
	// 6 rather than the default 5: the CA must not eat back the solid rock that
	// the deep ore pass needs, and halls already supply the open space.
	birth_limit = 6
	min_pocket_size = 10
	deep_vein_spacing = 24
	deep_vein_clearance = 4
	deep_spread_iterations = 2
	deep_max_veins = 3

/datum/map_generator/caves/mixed/New()
	. = ..()
	if(isnull(deep_ore_table))
		deep_ore_table = default_deep_ore_table()

/// Deep deposits are hidden, but valuable ores should stay rare.
/datum/map_generator/caves/mixed/proc/default_deep_ore_table()
	return list(
		/turf/closed/mineral/iron = list("weight" = 28, "spread_chance" = 55, "spread_range" = 1, "amount_min" = 4, "amount_max" = 7),
		/turf/closed/mineral/coal = list("weight" = 24, "spread_chance" = 55, "spread_range" = 1, "amount_min" = 4, "amount_max" = 8),
		/turf/closed/mineral/silver = list("weight" = 5, "spread_chance" = 50, "spread_range" = 1, "amount_min" = 3, "amount_max" = 6),
		/turf/closed/mineral/gold = list("weight" = 3, "spread_chance" = 50, "spread_range" = 1, "amount_min" = 3, "amount_max" = 6),
		/turf/closed/mineral/gemeralds = list("weight" = 2, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 2, "amount_max" = 4),
		/turf/closed/mineral/cinnabar = list("weight" = 2, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 2, "amount_max" = 4),
		/turf/closed/mineral/mana_crystal = list("weight" = 1, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 2, "amount_max" = 3),
	)

/// Long snaking corridors, small chambers. Feels like a worked-out mine.
/datum/map_generator/caves/warren
	name = "Warren Cave Generator"
	chamber_spacing = 17
	chamber_min_radius = 2
	chamber_max_radius = 4
	tunnel_radius_min = 0
	tunnel_radius_max = 1
	tunnel_wander = 42
	extra_loop_ratio = 0.15
	smoothing_passes = 1
	min_pocket_size = 8
	// Tight worked-out passages: more rubble underfoot, less growth.
	patch_threshold_a = 0.64
	patch_threshold_b = 0.62

/datum/map_generator/caves/warren/default_decor_spawns()
	var/list/table = ..()
	for(var/list/entry as anything in table)
		var/list/paths = entry["paths"]
		if(paths[/obj/item/natural/stone])
			entry["chance"] = 2.4
		else if(paths[/obj/item/natural/rock])
			entry["chance"] = 1.6
		else if(paths[/obj/structure/flora/new_shroom/cyansmall])
			entry["chance"] = 0.5
	return table

/// Big hollow caverns joined by short wide throats.
/datum/map_generator/caves/cavern
	name = "Cavern Generator"
	chamber_spacing = 11
	chamber_min_radius = 6
	chamber_max_radius = 11
	chamber_edge_noise = 0.4
	tunnel_radius_min = 1
	tunnel_radius_max = 2
	tunnel_wander = 22
	extra_loop_ratio = 0.35
	smoothing_passes = 3
	min_pocket_size = 16
	// Open halls read as empty faster than corridors do, so lean on the props a
	// little harder and let the floor break up more.
	patch_threshold_a = 0.56
	patch_threshold_b = 0.62

/datum/map_generator/caves/cavern/default_decor_spawns()
	var/list/table = ..()
	for(var/list/entry as anything in table)
		var/list/paths = entry["paths"]
		if(paths[/obj/structure/stalagmite])
			entry["chance"] = 3.2
		else if(paths[/obj/structure/flora/crystal])
			entry["chance"] = 0.45
			entry["cluster_max"] = 3
	return table

/// Deep caves: sparse small deposits with fewer valuable ores.
/datum/map_generator/caves/deep
	name = "Deep Vein Generator"
	chamber_spacing = 15
	ore_vein_spacing = 20
	ore_spread_iterations = 2
	ore_max_veins = 15

/datum/map_generator/caves/deep/default_ore_table()
	return list(
		/turf/closed/mineral/iron = list("weight" = 28, "spread_chance" = 65, "spread_range" = 1, "amount_min" = 3, "amount_max" = 6),
		/turf/closed/mineral/coal = list("weight" = 24, "spread_chance" = 65, "spread_range" = 1, "amount_min" = 3, "amount_max" = 7),
		/turf/closed/mineral/silver = list("weight" = 5, "spread_chance" = 50, "spread_range" = 1, "amount_min" = 2, "amount_max" = 4),
		/turf/closed/mineral/gold = list("weight" = 3, "spread_chance" = 50, "spread_range" = 1, "amount_min" = 2, "amount_max" = 4),
		/turf/closed/mineral/gemeralds = list("weight" = 2, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 1, "amount_max" = 3),
		/turf/closed/mineral/cinnabar = list("weight" = 2, "spread_chance" = 45, "spread_range" = 1, "amount_min" = 1, "amount_max" = 3),
		/turf/closed/mineral/mana_crystal = list("weight" = 1, "spread_chance" = 40, "spread_range" = 1, "amount_min" = 1, "amount_max" = 2),
	)

/*
 * Paintable areas.
 */

/area/under/cave/generated
	name = "cave"
	map_generator = /datum/map_generator/caves/mixed

/area/under/cave/generated/mixed
	map_generator = /datum/map_generator/caves/mixed

/area/under/cave/generated/warren
	map_generator = /datum/map_generator/caves/warren

/area/under/cave/generated/cavern
	map_generator = /datum/map_generator/caves/cavern

/area/under/cave/generated/deep
	map_generator = /datum/map_generator/caves/deep
//RMH EDITED END
