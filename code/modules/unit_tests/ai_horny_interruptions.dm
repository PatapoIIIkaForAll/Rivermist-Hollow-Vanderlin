/// Side events must not end a horny scene early: weapons, departed threats, partner grabs and hits, long chases.
/datum/unit_test/ai_horny_interruption
	abstract_type = /datum/unit_test/ai_horny_interruption
#ifdef FOCUS_AI_HORNY_INTERRUPTION_TEST
	focus = TRUE
#endif

/// Skeletons drop their weapon to grab a partner; their weapon field saw it land and cancelled everything.
/datum/unit_test/ai_horny_interruption/spotted_weapon_keeps_scene

/datum/unit_test/ai_horny_interruption/spotted_weapon_keeps_scene/Run()
	var/obj/item/weapon/sword/iron/sword = allocate(/obj/item/weapon/sword/iron)
	sword.moveToNullspace()
	var/mob/living/carbon/human/species/skeleton/npc/skeleton = allocate(/mob/living/carbon/human/species/skeleton/npc)
	var/datum/ai_controller/controller = skeleton.ai_controller
	var/datum/ai_behavior/scene = GET_AI_BEHAVIOR(/datum/ai_behavior/unit_test_busywork)

	controller.queue_behavior(/datum/ai_behavior/find_and_set/better_weapon, BB_MOB_EQUIP_TARGET, null, 9)
	ai_test_ticks(controller, 2)
	TEST_ASSERT(ai_test_has_field(controller, BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_and_set/better_weapon)), "Test setup: an unarmed skeleton should watch for weapons.")

	controller.queue_behavior(/datum/ai_behavior/unit_test_busywork)
	sword.forceMove(run_loc_floor_top_right)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, scene), "Spotting a weapon must not cancel what the skeleton is doing.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_MOB_EQUIP_TARGET], sword, "The weapon field should still note the dropped sword for later.")

/// SSaggro re-asserted the top threat every decay tick after it left, pulling horny NPCs off their partners.
/datum/unit_test/ai_horny_interruption/departed_threat_leaves_board

/datum/unit_test/ai_horny_interruption/departed_threat_leaves_board/Run()
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/species/skeleton/npc/skeleton = allocate(/mob/living/carbon/human/species/skeleton/npc)
	var/datum/ai_controller/controller = skeleton.ai_controller
	var/datum/component/ai_aggro_system/aggro = skeleton.GetComponent(/datum/component/ai_aggro_system)
	TEST_ASSERT_NOTNULL(aggro, "Skeleton NPCs should have an aggro board.")
	controller.set_blackboard_key(BB_AGGRO_MAINTAIN_RANGE, 2) // the test room is smaller than the real keep range
	aggro.add_threat_to_mob(bystander, 18)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HIGHEST_THREAT_MOB], bystander, "Test setup: a close threat should top the aggro board.")

	bystander.forceMove(run_loc_floor_top_right)
	TEST_ASSERT(get_dist(skeleton, bystander) > 2, "Test setup: the bystander should now stand past the keep range.")
	aggro.process()
	TEST_ASSERT_NULL(controller.blackboard[BB_HIGHEST_THREAT_MOB], "A threat that walked out of range should leave the aggro board.")
	var/datum/ai_planning_subtree/planner = GLOB.ai_subtrees[/datum/ai_planning_subtree/horny]
	TEST_ASSERT(!planner.horny_ai_should_yield_to_aggro(controller), "Horny planning must not yield to a threat that walked away.")
	var/datum/ai_behavior/horny/scene = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT(!scene.is_valid_aggro_interrupt_target(skeleton, controller.blackboard[BB_TARGETTING_DATUM], bystander), "A running scene must not stop for a threat that walked away.")

	// Someone shooting at the NPC still counts, however far away they stand.
	controller.set_blackboard_key(BB_LAST_RANGED_ATTACKER, bystander)
	controller.set_blackboard_key(BB_LAST_RANGED_HIT_TIME, world.time)
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, bystander)
	TEST_ASSERT(planner.horny_ai_should_yield_to_aggro(controller), "Horny planning should still yield to a fresh ranged attacker.")

/// A grab from a willing partner retargeted the NPC and cancelled the scene before it began.
/datum/unit_test/ai_horny_interruption/partner_grab_keeps_scene

/datum/unit_test/ai_horny_interruption/partner_grab_keeps_scene/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	var/datum/ai_controller/controller = goblin.ai_controller
	var/datum/targetting_datum/targeting = controller.blackboard[BB_TARGETTING_DATUM]
	TEST_ASSERT(targeting.is_selected_horny_target(goblin, partner), "Test setup: the partner should be a wanted horny target.")
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.queue_behavior(/datum/ai_behavior/unit_test_busywork)

	goblin.set_pulledby(partner)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/unit_test_busywork)), "A grab from a willing partner must not cancel what the NPC is doing.")
	TEST_ASSERT(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] != partner, "A willing partner who grabs should not become a combat target at once.")
	TEST_ASSERT(goblin.hostile_grab_horny_hostility_timer, "Holding on too long should still turn the NPC hostile.")

/// Chasing a moving partner rebuilds the path often; every rebuild counted toward giving up the chase.
/datum/unit_test/ai_horny_interruption/chase_survives_path_rebuilds

/datum/unit_test/ai_horny_interruption/chase_survives_path_rebuilds/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/mob/living/simple_animal/hostile/pawn = allocate(/mob/living/simple_animal/hostile)
	var/datum/ai_controller/controller = allocate(/datum/ai_controller/unit_test_one_finder, pawn)
	controller.change_ai_movement_type(/datum/ai_movement/hybrid_pathing/gnome) // always pathfinds, never steps blindly
	var/datum/ai_movement/hybrid_pathing/movement = controller.ai_movement
	var/datum/ai_behavior/chase = GET_AI_BEHAVIOR(/datum/ai_behavior/unit_test_busywork)
	controller.queue_behavior(/datum/ai_behavior/unit_test_busywork)
	controller.set_movement_target(type, runner)
	movement.start_moving_towards(controller, runner, 1)

	// A* sleeps once the tick is spent, which ends process() early; start the passes on a fresh tick.
	stoplag()
	// Each pass the runner has moved on, so the old path is dropped and a new one is built.
	for(var/i in 1 to movement.max_pathing_attempts + 3)
		controller.movement_path = null
		COOLDOWN_RESET(controller, movement_cooldown)
		COOLDOWN_RESET(controller, repath_cooldown)
		movement.process(0.1)
		TEST_ASSERT(LAZYACCESS(controller.current_behaviors, chase), "A chase must not give up while every path rebuild succeeds.")
		TEST_ASSERT(length(controller.movement_path), "Test setup: each rebuild should find a path to the runner.")
	movement.stop_moving_towards(controller)

/// The aggro board marked a partner hostile on the first hit, before the scene's own hit count could decide.
/datum/unit_test/ai_horny_interruption/partner_hits_counted_by_scene

/datum/unit_test/ai_horny_interruption/partner_hits_counted_by_scene/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	goblin.AddElement(/datum/element/ai_retaliate) // the other hit listener, so both are covered
	var/datum/ai_controller/controller = goblin.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.set_blackboard_key(BB_HORNY_TIME_START, world.time) // a scene is under way

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, 5)
	TEST_ASSERT_NULL(controller.blackboard[BB_HORNY_AGGRO_TARGET], "One hit from the partner mid-scene must not turn the NPC hostile.")

	controller.clear_blackboard_key(BB_HORNY_TIME_START)
	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, 5)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_AGGRO_TARGET], partner, "Outside a scene, a hit from a wanted partner should still turn the NPC hostile.")

/// Light blows from a partner never make the hunter lethal; a hurt hunter turns once the damage adds up.
/datum/unit_test/ai_horny_interruption/hurt_npc_tires_of_rough_partner

/datum/unit_test/ai_horny_interruption/hurt_npc_tires_of_rough_partner/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	var/datum/ai_controller/controller = goblin.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.set_blackboard_key(BB_HORNY_TIME_START, world.time)
	var/datum/ai_behavior/horny/scene = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	var/light_hit = goblin.maxHealth * HORNY_LETHAL_HURT_DAMAGE_SHARE * 0.5

	for(var/i in 1 to 2)
		scene.on_attacked(goblin, partner, light_hit)
	TEST_ASSERT_NULL(controller.blackboard[BB_HORNY_AGGRO_TARGET], "An unhurt NPC should shrug off light partner hits.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_TEMPER] > 0, "Partner hits should still raise the hunter's temper.")

	goblin.traumatic_shock = SHOCK_STAGE_4 // badly hurt: the lethal budget shrinks
	scene.on_attacked(goblin, partner, light_hit)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_AGGRO_TARGET], partner, "A hurt NPC should turn on a partner who keeps hurting it.")

/// Prep steps ran back to back once planning stopped stalling; each now waits a moment after the last.
/datum/unit_test/ai_horny_interruption/prep_steps_pause_between

/datum/unit_test/ai_horny_interruption/prep_steps_pause_between/Run()
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	partner.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_UNDEAD,
	))
	var/mob/living/carbon/human/species/skeleton/npc/warrior/skilled/skeleton = allocate(/mob/living/carbon/human/species/skeleton/npc/warrior/skilled)
	sleep(15) // the warrior dresses one second after spawning
	var/datum/ai_controller/controller = skeleton.ai_controller
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/basic/unit_test_allow_clientless_horny))
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
	var/datum/ai_behavior/horny/horny = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, horny), "Test setup: the horny behavior should start.")
	partner.SetKnockdown(10 SECONDS) // already down, so the first step strips the warrior's own armour
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "Test setup: the partner should be on the ground.")

	// The catch takes a few beats (grab, second grip, pin); the first prep step then strips the warrior's own armour.
	for(var/beat in 1 to 12)
		skeleton.next_move = 0
		horny.perform(0.1, controller, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
		if(!skeleton.wear_armor || !skeleton.wear_pants)
			break
	TEST_ASSERT(!skeleton.wear_armor || !skeleton.wear_pants, "Test setup: the first prep step should strip part of the warrior's armour.")
	TEST_ASSERT(controller.behavior_cooldowns[horny] - world.time >= 1 SECONDS, "The next prep step should wait at least a second after the last one ends.")
	// Teardown deletes the partner, and a floored, grabbed mob runtimes in its async get_up().
	skeleton.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)
