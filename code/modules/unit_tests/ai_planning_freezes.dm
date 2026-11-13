/// Planning must keep running while a search, a finder or a nest trip waits out its cooldown.
/datum/unit_test/ai_planning_freeze
	abstract_type = /datum/unit_test/ai_planning_freeze
#ifdef FOCUS_AI_PLANNING_FREEZE_TEST
	focus = TRUE
#endif

/// Runs the weapon search twice, leaving it on the long cooldown it gets while its field is up.
/datum/unit_test/ai_planning_freeze/proc/start_long_weapon_search(datum/ai_controller/controller)
	var/datum/ai_behavior/search = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/better_weapon)
	ai_test_plan(controller)
	ai_test_ticks(controller, 4)
	controller.modify_cooldown(search, world.time)
	ai_test_plan(controller)
	ai_test_ticks(controller, 4)
	return controller.behavior_cooldowns[search] > world.time + 30 SECONDS

/datum/unit_test/ai_planning_freeze/weapon_search_does_not_block_planning

/datum/unit_test/ai_planning_freeze/weapon_search_does_not_block_planning/Run()
	var/mob/living/carbon/human/species/skeleton/npc/skeleton = allocate(/mob/living/carbon/human/species/skeleton/npc)
	var/datum/ai_controller/controller = skeleton.ai_controller
	var/datum/ai_behavior/search = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/better_weapon)

	TEST_ASSERT(start_long_weapon_search(controller), "Test setup: the weapon search should be on its long cooldown.")
	for(var/i in 1 to 5)
		ai_test_plan(controller)
		ai_test_ticks(controller, 2)
		TEST_ASSERT(controller.able_to_plan(), "A weapon search waiting on its cooldown must not block planning.")
		TEST_ASSERT(!LAZYACCESS(controller.current_behaviors, search), "A weapon search whose field is watching should stay out of the queue.")

/datum/unit_test/ai_planning_freeze/searching_skeleton_fights_back

/datum/unit_test/ai_planning_freeze/searching_skeleton_fights_back/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	attacker.moveToNullspace()
	var/mob/living/carbon/human/species/skeleton/npc/skeleton = allocate(/mob/living/carbon/human/species/skeleton/npc)
	var/datum/ai_controller/controller = skeleton.ai_controller

	TEST_ASSERT(start_long_weapon_search(controller), "Test setup: the weapon search should be on its long cooldown.")
	ai_test_plan(controller)

	// A hit from beyond the detection fields, like an arrow from twelve tiles away.
	var/turf/skeleton_turf = get_turf(skeleton)
	attacker.forceMove(locate(min(world.maxx, skeleton_turf.x + 12), skeleton_turf.y, skeleton_turf.z))
	SEND_SIGNAL(skeleton, COMSIG_ATOM_WAS_ATTACKED, attacker, 10)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], attacker, "Test setup: the hit should make the attacker the skeleton's target.")

	ai_test_plan(controller)
	// Any attack style counts; this checks that the skeleton answers, not how.
	var/static/list/attack_behaviors = list(
		/datum/ai_behavior/basic_melee_attack/human_npc,
		/datum/ai_behavior/human_npc_gap_close,
		/datum/ai_behavior/human_npc_harass_dart_in,
		/datum/ai_behavior/human_npc_harass_strike,
	)
	var/answered = FALSE
	for(var/behavior_type in attack_behaviors)
		if(LAZYACCESS(controller.current_behaviors, GET_AI_BEHAVIOR(behavior_type)))
			answered = TRUE
	TEST_ASSERT(answered, "A skeleton should fight back even while its weapon search waits.")

/// Bodies appear by dying in place, which no field sees; the slow re-scan must still find them.
/datum/unit_test/ai_planning_freeze/body_search_still_rescans

/datum/unit_test/ai_planning_freeze/body_search_still_rescans/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = allocate(/mob/living/simple_animal/hostile/retaliate/spider)
	var/datum/ai_controller/controller = spider.ai_controller
	// No combat targets, so the fight subtree never ends planning before the body search.
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/unit_test_one_target))
	var/datum/component/generic_mob_hunger/hunger = spider.GetComponent(/datum/component/generic_mob_hunger)
	TEST_ASSERT_NOTNULL(hunger, "Beespiders should have a hunger component.")
	hunger.current_hunger = 0
	var/datum/ai_behavior/search = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/dead_bodies)

	var/field_key = BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_and_set/dead_bodies)
	// One behavior runs per tick, and the other finders are queued ahead of the body search.
	ai_test_plan(controller)
	for(var/i in 1 to 12)
		ai_test_ticks(controller, 1)
		if(ai_test_has_field(controller, field_key))
			break
	TEST_ASSERT(ai_test_has_field(controller, field_key), "Test setup: a hungry beespider should leave a body search field.")

	victim.death()
	controller.modify_cooldown(search, world.time)
	ai_test_plan(controller)
	for(var/i in 1 to 12)
		ai_test_ticks(controller, 1)
		if(controller.blackboard[BB_BASIC_MOB_FOOD_TARGET])
			break
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_FOOD_TARGET], victim, "The slow re-scan should still find a body that died where it stood.")

/datum/unit_test/ai_planning_freeze/waiting_finder_does_not_block_planning

/datum/unit_test/ai_planning_freeze/waiting_finder_does_not_block_planning/Run()
	var/mob/living/simple_animal/hostile/pawn = allocate(/mob/living/simple_animal/hostile)
	var/datum/ai_controller/controller = allocate(/datum/ai_controller/unit_test_two_finders, pawn)
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/unit_test_one_target))
	var/horny_key = BB_FIND_HORNY_TARGETS_FIELD(/datum/ai_behavior/find_potential_horny_targets)

	ai_test_plan(controller)
	ai_test_ticks(controller)
	// The field ends, so the finder is queued again and waits out its cooldown.
	qdel(controller.blackboard[horny_key])
	ai_test_plan(controller)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_horny_targets)), "Test setup: the horny finder should wait in the queue.")
	TEST_ASSERT(controller.able_to_plan(), "A finder waiting on its cooldown must not block planning.")

/// Places a beespider and gives it a nest, by default one tile east.
/datum/unit_test/ai_planning_freeze/proc/make_nested_spider(turf/nest_turf)
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = allocate(/mob/living/simple_animal/hostile/retaliate/spider)
	var/obj/structure/spider/nest/nest = allocate(/obj/structure/spider/nest, nest_turf || get_step(spider, EAST))
	spider.ai_controller.set_blackboard_key(BB_CURRENT_HOME, nest)
	return spider

/datum/unit_test/ai_planning_freeze/nest_trip_waits_without_blocking

/datum/unit_test/ai_planning_freeze/nest_trip_waits_without_blocking/Run()
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = make_nested_spider()
	var/datum/ai_controller/controller = spider.ai_controller
	var/datum/ai_behavior/trip = GET_AI_BEHAVIOR(/datum/ai_behavior/enter_exit_home)
	controller.modify_cooldown(trip, world.time + 1 MINUTES) // as if it just left the nest

	for(var/i in 1 to 100)
		ai_test_plan(controller)
		ai_test_ticks(controller, 1)
		TEST_ASSERT(!LAZYACCESS(controller.current_behaviors, trip), "A nest trip must not wait in the queue while the last trip's cooldown runs.")
		TEST_ASSERT(controller.able_to_plan(), "A spider must keep planning while it waits to use its nest.")

/datum/unit_test/ai_planning_freeze/nest_trip_never_interrupts_a_fight

/datum/unit_test/ai_planning_freeze/nest_trip_never_interrupts_a_fight/Run()
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = make_nested_spider()
	var/mob/living/carbon/human/foe = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/datum/ai_controller/controller = spider.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, foe)
	var/datum/ai_behavior/trip = GET_AI_BEHAVIOR(/datum/ai_behavior/enter_exit_home)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack/agile)
	var/datum/ai_behavior/finder = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets/spider)

	// The foe stays out of reach, so the fight never ends; resetting the finder stands in for passing time.
	for(var/i in 1 to 100)
		ai_test_plan(controller)
		TEST_ASSERT(!LAZYACCESS(controller.current_behaviors, trip), "The nest roll must never pre-empt a fight.")
		TEST_ASSERT(LAZYACCESS(controller.current_behaviors, melee), "The spider should keep its melee attack planned.")
		controller.modify_cooldown(finder, world.time)
		ai_test_ticks(controller, 1)

	var/nest_index = controller.get_subtree_index(/datum/ai_planning_subtree/enter_exit_home)
	TEST_ASSERT(nest_index > controller.get_subtree_index(/datum/ai_planning_subtree/basic_melee_attack_subtree/agile), "The nest roll must come after the spider's melee in planning.")
	TEST_ASSERT(nest_index > controller.get_subtree_index(/datum/ai_planning_subtree/horny), "The nest roll must come after the spider's horny handling in planning.")

/datum/unit_test/ai_planning_freeze/nest_trip_still_happens

/datum/unit_test/ai_planning_freeze/nest_trip_still_happens/Run()
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = make_nested_spider()
	var/datum/ai_controller/controller = spider.ai_controller
	controller.idle_behavior = null // a wander step would need real time to walk back

	var/obj/structure/spider/nest/nest = controller.blackboard[BB_CURRENT_HOME]
	for(var/i in 1 to 200)
		ai_test_plan(controller)
		ai_test_ticks(controller, 2)
		if(spider.loc == nest)
			break
	TEST_ASSERT_EQUAL(spider.loc, nest, "An idle spider next to its nest should still go inside.")

/datum/unit_test/ai_planning_freeze/nest_trip_needs_the_spider_at_its_nest

/datum/unit_test/ai_planning_freeze/nest_trip_needs_the_spider_at_its_nest/Run()
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = make_nested_spider(run_loc_floor_top_right)
	var/datum/ai_controller/controller = spider.ai_controller
	var/obj/structure/spider/nest/nest = controller.blackboard[BB_CURRENT_HOME]
	var/datum/ai_behavior/trip = GET_AI_BEHAVIOR(/datum/ai_behavior/enter_exit_home)

	// Another behavior moved the walk target, so the trip runs while the nest is still far away.
	trip.perform(0.1, controller, BB_CURRENT_HOME)
	TEST_ASSERT(spider.loc != nest, "A nest trip must not pull a distant spider into its nest.")
