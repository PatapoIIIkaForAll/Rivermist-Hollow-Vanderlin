#define BB_UNIT_TEST_GATE_CLOSED "unit_test_gate_closed"

/// Accepts exactly one chosen atom as a target.
/datum/targetting_datum/unit_test_one_target
	var/atom/allowed_target

/datum/targetting_datum/unit_test_one_target/can_attack(mob/living/living_mob, atom/target)
	return !isnull(target) && target == allowed_target

/// Stays in current_behaviors, so the controller is never empty between plans.
/datum/ai_behavior/unit_test_busywork
	action_cooldown = 1 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_planning_subtree/unit_test_busywork/SelectBehaviors(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/unit_test_busywork)

/// Ends planning early while the gate flag is set, like a higher-priority subtree taking over.
/datum/ai_planning_subtree/unit_test_gate/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_UNIT_TEST_GATE_CLOSED])
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_controller/unit_test_one_finder
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/unit_test_gate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/unit_test_busywork,
	)

/datum/ai_controller/unit_test_two_finders
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/simple_find_target,
	)

// Test-zone controllers stay OFF, so these helpers drive them at the real cadence.
/// One planning pass, as SSai_controllers runs it.
/datum/unit_test/proc/ai_test_plan(datum/ai_controller/controller)
	if(controller.able_to_plan())
		controller.SelectBehaviors(0.5)

/// Execution steps, as SSai_behaviors runs them.
/datum/unit_test/proc/ai_test_ticks(datum/ai_controller/controller, count = 3)
	for(var/i in 1 to count)
		controller.process(0.1)

/datum/unit_test/proc/ai_test_has_field(datum/ai_controller/controller, key)
	var/datum/field = controller.blackboard[key]
	return !QDELETED(field)

/datum/unit_test/ai_detection_field
	abstract_type = /datum/unit_test/ai_detection_field
#ifdef FOCUS_AI_DETECTION_FIELD_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_detection_field/survives_busy_plans

/datum/unit_test/ai_detection_field/survives_busy_plans/Run()
	var/mob/living/simple_animal/hostile/pawn = allocate(/mob/living/simple_animal/hostile)
	var/mob/living/carbon/human/prey = allocate(/mob/living/carbon/human)
	prey.moveToNullspace()
	var/datum/ai_controller/controller = allocate(/datum/ai_controller/unit_test_one_finder, pawn)
	var/datum/targetting_datum/unit_test_one_target/targeting = allocate(/datum/targetting_datum/unit_test_one_target)
	targeting.allowed_target = prey
	controller.set_blackboard_key(BB_TARGETTING_DATUM, targeting)
	var/field_key = BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_potential_targets)

	ai_test_plan(controller)
	ai_test_ticks(controller)
	TEST_ASSERT(ai_test_has_field(controller, field_key), "A finder that sees nobody should leave a detection field.")

	// Busywork keeps current_behaviors filled; this used to delete the field on the next tick.
	for(var/i in 1 to 3)
		ai_test_plan(controller)
		ai_test_ticks(controller)
	TEST_ASSERT(ai_test_has_field(controller, field_key), "A detection field must survive plans that still include its finder.")

	prey.forceMove(run_loc_floor_top_right)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], prey, "A live detection field should acquire a target as soon as it steps into range.")

/datum/unit_test/ai_detection_field/losing_one_field_keeps_the_other

/datum/unit_test/ai_detection_field/losing_one_field_keeps_the_other/Run()
	var/mob/living/simple_animal/hostile/pawn = allocate(/mob/living/simple_animal/hostile)
	var/datum/ai_controller/controller = allocate(/datum/ai_controller/unit_test_two_finders, pawn)
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/unit_test_one_target))
	var/horny_key = BB_FIND_HORNY_TARGETS_FIELD(/datum/ai_behavior/find_potential_horny_targets)
	var/combat_key = BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_potential_targets)

	ai_test_plan(controller)
	ai_test_ticks(controller)
	TEST_ASSERT(ai_test_has_field(controller, horny_key), "The horny finder should leave a detection field.")
	TEST_ASSERT(ai_test_has_field(controller, combat_key), "The combat finder should leave a detection field.")

	// The horny field ends, so its finder is queued again and waits out its cooldown in current_behaviors.
	qdel(controller.blackboard[horny_key])
	ai_test_plan(controller)
	ai_test_ticks(controller)
	TEST_ASSERT(ai_test_has_field(controller, combat_key), "Restarting one finder must not delete the other finder's detection field.")

/datum/unit_test/ai_detection_field/forgotten_finder_drops_field

/datum/unit_test/ai_detection_field/forgotten_finder_drops_field/Run()
	var/mob/living/simple_animal/hostile/pawn = allocate(/mob/living/simple_animal/hostile)
	var/datum/ai_controller/controller = allocate(/datum/ai_controller/unit_test_one_finder, pawn)
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/unit_test_one_target))
	var/field_key = BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_potential_targets)

	ai_test_plan(controller)
	ai_test_ticks(controller)
	TEST_ASSERT(ai_test_has_field(controller, field_key), "Test setup: the finder should leave a detection field.")

	controller.set_blackboard_key(BB_UNIT_TEST_GATE_CLOSED, TRUE)
	ai_test_plan(controller)
	TEST_ASSERT(!ai_test_has_field(controller, field_key), "A plan that never reaches the finder should delete its detection field.")

/// Unarmed skeletons search for a weapon every plan; that search used to cost them both fields.
/datum/unit_test/ai_detection_field/skeleton_sees_walker_while_searching

/datum/unit_test/ai_detection_field/skeleton_sees_walker_while_searching/Run()
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human)
	walker.moveToNullspace()
	var/mob/living/carbon/human/species/skeleton/npc/skeleton = allocate(/mob/living/carbon/human/species/skeleton/npc)
	var/datum/ai_controller/controller = skeleton.ai_controller
	TEST_ASSERT_NOTNULL(controller, "Skeleton NPCs should have an AI controller.")

	for(var/i in 1 to 4)
		ai_test_plan(controller)
		ai_test_ticks(controller, 4)
	TEST_ASSERT(ai_test_has_field(controller, BB_FIND_HORNY_TARGETS_FIELD(/datum/ai_behavior/find_potential_horny_targets)), "An idle skeleton should keep its horny detection field.")
	TEST_ASSERT(ai_test_has_field(controller, BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_aggro_targets)), "An idle skeleton should keep its aggro detection field while it searches for a weapon.")

	walker.forceMove(run_loc_floor_top_right)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], walker, "The skeleton should target a walker who steps into its field.")

/// Beespiders without a nest search for one every plan; that search used to cost them both fields.
/datum/unit_test/ai_detection_field/beespider_sees_walker_while_homeless

/datum/unit_test/ai_detection_field/beespider_sees_walker_while_homeless/Run()
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human)
	walker.moveToNullspace()
	var/mob/living/simple_animal/hostile/retaliate/spider/spider = allocate(/mob/living/simple_animal/hostile/retaliate/spider)
	var/datum/ai_controller/controller = spider.ai_controller
	TEST_ASSERT_NOTNULL(controller, "Beespiders should have an AI controller.")

	for(var/i in 1 to 4)
		ai_test_plan(controller)
		ai_test_ticks(controller, 4)
	TEST_ASSERT(ai_test_has_field(controller, BB_FIND_HORNY_TARGETS_FIELD(/datum/ai_behavior/find_potential_horny_targets)), "An idle beespider should keep its horny detection field.")
	TEST_ASSERT(ai_test_has_field(controller, BB_FIND_TARGETS_FIELD(/datum/ai_behavior/find_potential_targets/spider)), "An idle beespider should keep its combat detection field while it searches for a nest.")

	walker.forceMove(run_loc_floor_top_right)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], walker, "The beespider should target a walker who steps into its field.")

#undef BB_UNIT_TEST_GATE_CLOSED
