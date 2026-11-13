/datum/unit_test/ai_hazard_avoidance_detects_object_hazards
#ifdef FOCUS_AI_IDLE_DETECTION_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_hazard_avoidance_detects_object_hazards/Run()
	var/turf/clear_turf = run_loc_floor_bottom_left
	TEST_ASSERT_NOTNULL(clear_turf, "Test setup needs a run turf.")
	TEST_ASSERT(!ai_turf_is_hazardous(clear_turf), "An empty floor turf should not read as hazardous.")

	// Bushes are objects sitting on a turf, so the old turf-type-only check never saw them and
	// wandering AI walked in and scratched itself to death.
	var/obj/structure/flora/grass/bush/bush = allocate(/obj/structure/flora/grass/bush, clear_turf)
	TEST_ASSERT_NOTNULL(bush, "Test setup needs a bush.")
	TEST_ASSERT(ai_turf_is_hazardous(clear_turf), "A turf holding a bush must read as hazardous to AI movement.")

/datum/unit_test/ai_hazard_avoidance_allows_destination_object_hazard
#ifdef FOCUS_AI_IDLE_DETECTION_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_hazard_avoidance_allows_destination_object_hazard/Run()
	var/turf/destination = run_loc_floor_bottom_left
	TEST_ASSERT_NOTNULL(destination, "Test setup needs a run turf.")

	var/obj/structure/flora/grass/bush/bush = allocate(/obj/structure/flora/grass/bush, destination)
	TEST_ASSERT_NOTNULL(bush, "Test setup needs a bush.")

	// Prey hides inside bushes, so a mob closing on a target standing there must still be allowed in.
	TEST_ASSERT(!ai_turf_is_hazardous(destination, destination), "An object hazard on the mob's actual destination must not block movement, or mobs can never reach prey hiding in bushes.")

/obj/effect/unit_test_fire_probe
	name = "fire probe"
	var/ignited = FALSE

/obj/effect/unit_test_fire_probe/fire_act(added, maxstacks)
	ignited = TRUE

/datum/unit_test/ai_hazard_avoidance_detects_lit_fires
#ifdef FOCUS_AI_IDLE_DETECTION_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_hazard_avoidance_detects_lit_fires/Run()
	var/turf/fire_turf = run_loc_floor_bottom_left
	var/turf/oven_turf = get_step(fire_turf, EAST)
	TEST_ASSERT_NOTNULL(oven_turf, "Test setup needs a second run turf.")

	var/obj/machinery/light/fueled/campfire/fire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	TEST_ASSERT(fire.burns_crossers(), "Test setup needs a lit campfire.")
	TEST_ASSERT(ai_turf_is_hazardous(fire_turf), "A lit campfire sets alight whoever steps in, so AI movement must read its turf as hazardous.")
	TEST_ASSERT(!ai_turf_is_hazardous(fire_turf, fire_turf), "A lit fire on the mob's actual destination must not block movement onto it.")

	fire.burn_out()
	TEST_ASSERT(!ai_turf_is_hazardous(fire_turf), "A burnt out campfire must not read as hazardous.")

	var/obj/machinery/light/fueled/oven/south/oven = allocate(/obj/machinery/light/fueled/oven/south, oven_turf)
	TEST_ASSERT(oven.on, "Test setup needs a lit oven.")
	TEST_ASSERT(!ai_turf_is_hazardous(oven_turf), "A lit oven must not read as hazardous, or AI stops walking through kitchens.")

/datum/unit_test/ai_hazard_avoidance_paths_around_lit_fires
#ifdef FOCUS_AI_IDLE_DETECTION_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_hazard_avoidance_paths_around_lit_fires/Run()
	var/turf/fire_turf = run_loc_floor_bottom_left
	var/turf/side_turf = get_step(fire_turf, EAST)
	TEST_ASSERT_NOTNULL(side_turf, "Test setup needs a second run turf.")

	var/obj/effect/unit_test_fire_probe/inside = allocate(/obj/effect/unit_test_fire_probe, fire_turf)
	var/obj/effect/unit_test_fire_probe/outside = allocate(/obj/effect/unit_test_fire_probe, side_turf)
	var/obj/machinery/light/fueled/campfire/fire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	TEST_ASSERT(fire.burns_crossers(), "Test setup needs a lit campfire.")

	TEST_ASSERT(!fire.CanAStarPass(null, WEST, outside), "A* must not route a path through a lit fire.")
	TEST_ASSERT(fire.CanAStarPass(null, EAST, inside), "Something already standing in a lit fire must still be able to path out of it.")

	fire.burn_out()
	TEST_ASSERT(fire.CanAStarPass(null, WEST, outside), "A burnt out campfire must not block A*.")

/datum/unit_test/ai_hazard_avoidance_fire_spares_things_thrown_over
#ifdef FOCUS_AI_IDLE_DETECTION_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_hazard_avoidance_fire_spares_things_thrown_over/Run()
	var/turf/fire_turf = run_loc_floor_bottom_left
	var/turf/landing_turf = get_step(fire_turf, EAST)
	TEST_ASSERT_NOTNULL(landing_turf, "Test setup needs a second run turf.")

	var/obj/machinery/light/fueled/campfire/fire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	TEST_ASSERT(fire.burns_crossers(), "Test setup needs a lit campfire.")
	var/obj/effect/unit_test_fire_probe/probe = allocate(/obj/effect/unit_test_fire_probe, landing_turf)
	var/datum/thrownthing/flight = allocate(/datum/thrownthing, probe, landing_turf, EAST, 2, 1)
	probe.throwing = flight

	fire.Crossed(probe)
	TEST_ASSERT(!probe.ignited, "Something thrown over a lit fire must not catch from it.")

	flight.target_turf = fire_turf
	fire.Crossed(probe)
	TEST_ASSERT(probe.ignited, "Something thrown into a lit fire must still catch from it.")

	probe.throwing = null
