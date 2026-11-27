/// Structure that counts actions which pass the parent's interaction check.
/obj/structure/ui_act_probe
	var/actions_run = 0

/obj/structure/ui_act_probe/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	actions_run++

/// A structure's ui_act stops when the window is not interactive and runs when it is.
/datum/unit_test/structure_ui_act

/datum/unit_test/structure_ui_act/Run()
	var/obj/structure/ui_act_probe/probe = allocate(/obj/structure/ui_act_probe, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/tgui/window = allocate(/datum/tgui, user, probe, "Probe")
	TEST_ASSERT_NOTNULL(window.state, "The window should take the structure's ui_state.")
	usr = user

	window.status = UI_UPDATE
	TEST_ASSERT(probe.ui_act("poke", list(), window, window.state), "A view-only window should report the action as refused.")
	TEST_ASSERT_EQUAL(probe.actions_run, 0, "A view-only window must not run the action.")
	TEST_ASSERT(probe.ui_act("poke", list()), "A call without a window should be refused.")
	TEST_ASSERT_EQUAL(probe.actions_run, 0, "A call without a window must not run the action.")

	window.status = UI_INTERACTIVE
	TEST_ASSERT(!probe.ui_act("poke", list(), window, window.state), "An interactive window should pass the action on.")
	TEST_ASSERT_EQUAL(probe.actions_run, 1, "An interactive window should run the action.")

	// Status from the real checks: test mobs have no client, so keep their windows open.
	ADD_TRAIT(user, TRAIT_PRESERVE_UI_WITHOUT_CLIENT, TRAIT_SOURCE_UNIT_TESTS)
	window.process_status()
	TEST_ASSERT_EQUAL(window.status, UI_INTERACTIVE, "An adjacent, able user should get an interactive window.")
	probe.ui_act("poke", list(), window, window.state)
	TEST_ASSERT_EQUAL(probe.actions_run, 2, "An adjacent, able user should run the action.")

	user.forceMove(get_ranged_target_turf(run_loc_floor_bottom_left, EAST, 4))
	window.process_status()
	TEST_ASSERT(window.status != UI_INTERACTIVE, "A user three tiles away should not get an interactive window.")
	probe.ui_act("poke", list(), window, window.state)
	TEST_ASSERT_EQUAL(probe.actions_run, 2, "A user three tiles away must not run the action.")
	usr = null
