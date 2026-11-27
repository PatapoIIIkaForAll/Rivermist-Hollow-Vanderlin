#ifdef UNIT_TESTS

/// Local assert: the shared TEST_ASSERT macros are undefined after _unit_tests.dm.
#define BT_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason]", __FILE__, __LINE__) }

/// Human whose behaviour toggles come from test vars instead of a player's preferences.
/mob/living/carbon/human/behaviour_toggle_test
	/// TRUE on, FALSE off, null for a mob without a player.
	var/test_auto_stand = null
	var/test_auto_climb = FALSE
	var/test_held_dir = NONE

/mob/living/carbon/human/behaviour_toggle_test/auto_stand_retries()
	return test_auto_stand == TRUE

/mob/living/carbon/human/behaviour_toggle_test/auto_stand_declined()
	return !isnull(test_auto_stand) && !test_auto_stand

/mob/living/carbon/human/behaviour_toggle_test/auto_climb_pref()
	return test_auto_climb

/mob/living/carbon/human/behaviour_toggle_test/auto_climb_held_dir()
	return test_held_dir

/// Walking into a climbable wall climbs; running, combat mode, the toggle off or a push do not.
/datum/unit_test/auto_climb_decision

/datum/unit_test/auto_climb_decision/Run()
	var/mob/living/carbon/human/behaviour_toggle_test/climber = allocate(/mob/living/carbon/human/behaviour_toggle_test)
	climber.setDir(NORTH)
	climber.m_intent = MOVE_INTENT_WALK
	climber.cmode = FALSE

	BT_ASSERT(auto_climb_allowed(climber, NORTH, TRUE, NORTH), "Walking into the wall with the toggle on should climb")
	climber.m_intent = MOVE_INTENT_SNEAK
	BT_ASSERT(auto_climb_allowed(climber, NORTH, TRUE, NORTH), "Sneaking into the wall with the toggle on should climb")
	BT_ASSERT(!auto_climb_allowed(climber, NORTH, FALSE, NORTH), "The toggle off should not climb")
	BT_ASSERT(!auto_climb_allowed(climber, NORTH, TRUE, EAST), "A push while holding another key should not climb")
	BT_ASSERT(!auto_climb_allowed(climber, EAST, TRUE, EAST), "Facing away from the wall should not climb")

	climber.m_intent = MOVE_INTENT_RUN
	BT_ASSERT(!auto_climb_allowed(climber, NORTH, TRUE, NORTH), "Running into the wall should crash, not climb")
	climber.m_intent = MOVE_INTENT_WALK

	climber.cmode = TRUE
	BT_ASSERT(!auto_climb_allowed(climber, NORTH, TRUE, NORTH), "Combat mode should not climb")
	climber.cmode = FALSE

	var/obj/item/held = allocate(/obj/item/kitchen/fork)
	climber.put_in_active_hand(held)
	BT_ASSERT(climber.get_active_held_item() == held, "The climber should hold the fork")
	BT_ASSERT(!auto_climb_allowed(climber, NORTH, TRUE, NORTH), "Anything in the active hand should stop the climb")
	climber.dropItemToGround(held)
	BT_ASSERT(auto_climb_allowed(climber, NORTH, TRUE, NORTH), "An empty hand again should climb")

	climber.test_auto_climb = TRUE
	climber.test_held_dir = NORTH
	BT_ASSERT(climber.should_auto_climb(NORTH), "should_auto_climb should read the toggle and the held keys")
	climber.test_auto_climb = FALSE
	BT_ASSERT(!climber.should_auto_climb(NORTH), "should_auto_climb should stop with the toggle off")

	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human)
	npc.setDir(NORTH)
	BT_ASSERT(!npc.should_auto_climb(NORTH), "A mob without a player should never auto-climb")

/// A failed stand-up schedules one retry with auto-stand on; off rests when the knockdown ends.
/datum/unit_test/auto_stand_retry

/datum/unit_test/auto_stand_retry/Run()
	var/mob/living/carbon/human/behaviour_toggle_test/faller = allocate(/mob/living/carbon/human/behaviour_toggle_test)
	faller.test_auto_stand = TRUE
	faller.set_body_position(LYING_DOWN)
	faller.stand_up_failed()
	BT_ASSERT(faller.auto_stand_timer, "Auto-stand on should schedule a retry")
	BT_ASSERT(!faller.resting, "Auto-stand on should not set resting after a failed stand-up")
	var/first_timer = faller.auto_stand_timer
	faller.stand_up_failed()
	BT_ASSERT(faller.auto_stand_timer == first_timer, "A second failure should keep the one pending retry")

	var/mob/living/carbon/human/behaviour_toggle_test/lier = allocate(/mob/living/carbon/human/behaviour_toggle_test)
	lier.test_auto_stand = FALSE
	lier.set_body_position(LYING_DOWN)
	lier.on_floored_end()
	BT_ASSERT(lier.resting, "Auto-stand off should leave the player resting when the knockdown ends")

	var/mob/living/carbon/human/behaviour_toggle_test/npc = allocate(/mob/living/carbon/human/behaviour_toggle_test)
	npc.set_body_position(LYING_DOWN)
	npc.stand_up_failed()
	BT_ASSERT(npc.resting, "A mob without a player should rest after a failed stand-up as before")
	BT_ASSERT(!npc.auto_stand_timer, "A mob without a player should not retry")

/// The quality sparkle spawns on its own plane; a polish sparkle stays on the shared plane.
/datum/unit_test/quality_glint_plane

/datum/unit_test/quality_glint_plane/Run()
	var/obj/item/quality_item = allocate(/obj/item/kitchen/fork)
	quality_item.set_quality(4)
	var/datum/component/particle_spewer/sparkle/glint = quality_item.GetComponent(/datum/component/particle_spewer/sparkle)
	BT_ASSERT(glint, "Gold quality should add a sparkle")
	BT_ASSERT(glint.particle_plane == QUALITY_GLINT_PLANE, "The quality sparkle should use the quality glint plane")
	glint.spawn_particles()
	BT_ASSERT(length(glint.living_particles), "The quality sparkle should spawn particles")
	for(var/obj/effect/abstract/particle/spark as anything in glint.living_particles)
		BT_ASSERT(spark.plane == QUALITY_GLINT_PLANE, "Quality sparkle particle is on plane [spark.plane]")

	var/obj/item/polished_item = allocate(/obj/item/kitchen/fork)
	var/datum/component/particle_spewer/sparkle/polish = polished_item.AddComponent(/datum/component/particle_spewer/sparkle)
	BT_ASSERT(isnull(polish.particle_plane), "A polish sparkle should not use the quality glint plane")
	polish.spawn_particles()
	for(var/obj/effect/abstract/particle/spark as anything in polish.living_particles)
		BT_ASSERT(spark.plane == GAME_PLANE_FOV_HIDDEN, "Polish sparkle particle is on plane [spark.plane]")

	var/atom/movable/screen/plane_master/quality_glint/glint_master = new
	BT_ASSERT(glint_master.plane == QUALITY_GLINT_PLANE, "The quality glint plane master should own the plane")
	qdel(glint_master)

/// Non-stop eating and drinking stops when sated, when the source is empty, and with the toggle off.
/datum/unit_test/auto_consume_stop_rules

/datum/unit_test/auto_consume_stop_rules/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human)

	eater.hydration = HYDRATION_LEVEL_THIRSTY
	BT_ASSERT(auto_consume_should_continue(eater, TRUE, TRUE, FALSE, TRUE), "A thirsty drinker should keep drinking")
	BT_ASSERT(!auto_consume_should_continue(eater, TRUE, TRUE, FALSE, FALSE), "An empty source should stop drinking")
	BT_ASSERT(!auto_consume_should_continue(eater, FALSE, TRUE, FALSE, TRUE), "The toggle off should drink one gulp")
	BT_ASSERT(!eater.auto_consume_continues(TRUE, FALSE, TRUE), "A mob without a player should drink one gulp")
	eater.hydration = HYDRATION_LEVEL_SMALLTHIRST
	BT_ASSERT(!auto_consume_should_continue(eater, TRUE, TRUE, FALSE, TRUE), "A drinker past thirst should stop")

	eater.nutrition = NUTRITION_LEVEL_HUNGRY
	BT_ASSERT(auto_consume_should_continue(eater, TRUE, FALSE, TRUE, TRUE), "A hungry eater should keep eating")
	BT_ASSERT(!auto_consume_should_continue(eater, TRUE, TRUE, FALSE, TRUE), "Drink does not count for hunger")
	eater.nutrition = NUTRITION_LEVEL_FED
	BT_ASSERT(!auto_consume_should_continue(eater, TRUE, FALSE, TRUE, TRUE), "An eater past hunger should stop")

	eater.hydration = HYDRATION_LEVEL_THIRSTY
	eater.nutrition = NUTRITION_LEVEL_FED
	BT_ASSERT(auto_consume_should_continue(eater, TRUE, TRUE, TRUE, TRUE), "Soup should continue while still thirsty")

	var/obj/structure/well/fountain/water_fountain = /obj/structure/well/fountain
	var/obj/structure/well/fountain/mana/mana_fountain = /obj/structure/well/fountain/mana
	BT_ASSERT(initial(water_fountain.auto_drink), "A water fountain should loop")
	BT_ASSERT(!initial(mana_fountain.auto_drink), "The mana fountain should stay one gulp")

#undef BT_ASSERT

#endif
