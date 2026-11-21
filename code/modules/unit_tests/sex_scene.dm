/// Tests the shared scene graph used by actor-owned scene controllers.
/datum/sex_scene_climax_probe
	var/received_live_action = FALSE

/datum/sex_scene_climax_probe/proc/on_climax(datum/source, datum/sex_action/action)
	SIGNAL_HANDLER
	received_live_action = action && !QDELETED(action)

/datum/targetting_datum/basic/sex_scene_unit_test_allow_clientless_horny/can_use_horny_ai_target(mob/living/living_mob, mob/living/carbon/human/human_target)
	return TRUE

/datum/unit_test/sex_scene_binds_connected_sessions/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)

	var/datum/sex_scene_controller/first_session = first.open_sex_scene(second, show_ui = FALSE)
	var/datum/sex_scene_controller/second_session = third.open_sex_scene(second, show_ui = FALSE)

	TEST_ASSERT_NOTNULL(first_session, "the first pair session should start")
	TEST_ASSERT_NOTNULL(second_session, "the connected pair session should start")
	TEST_ASSERT_NOTNULL(first.sex_scene, "a session should bind its user to a scene")
	TEST_ASSERT_EQUAL(first.sex_scene, second.sex_scene, "pair participants should share a scene")
	TEST_ASSERT_EQUAL(first.sex_scene, third.sex_scene, "connected pair sessions should share a scene")
	TEST_ASSERT_EQUAL(first_session.scene, second_session.scene, "connected sessions should share a scene")
	TEST_ASSERT_EQUAL(length(first.sex_scene.participants), 3, "the scene should contain all connected participants")
	TEST_ASSERT_EQUAL(length(first.sex_scene.controllers), 2, "the scene should contain one controller for each initiating actor")
	TEST_ASSERT_EQUAL(first.sex_scene.get_controller(first), first_session, "controller lookup should resolve through the bound scene")
	TEST_ASSERT_EQUAL(third.sex_scene.get_controller(third), second_session, "controller lookup should preserve actor ownership")

	qdel(first_session)
	qdel(second_session)

/datum/unit_test/sex_scene_merges_existing_scenes/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/fourth = allocate(/mob/living/carbon/human)

	var/datum/sex_scene_controller/first_session = first.open_sex_scene(second, show_ui = FALSE)
	var/datum/sex_scene_controller/second_session = third.open_sex_scene(fourth, show_ui = FALSE)
	var/datum/sex_scene/first_scene = first.sex_scene
	var/datum/sex_scene/second_scene = third.sex_scene
	var/datum/sex_action/second_scene_action = second_session.instantiate_action(/datum/sex_action/masturbate/penis)

	TEST_ASSERT(first_scene != second_scene, "disconnected pairs should begin in separate scenes")
	TEST_ASSERT_NOTNULL(second_scene_action, "a runtime action should instantiate for the second scene")
	TEST_ASSERT(second_scene_action.bind_runtime(second_session), "the second scene should accept a runtime action")

	var/datum/sex_scene_controller/linking_session = first.open_sex_scene(third, show_ui = FALSE)

	TEST_ASSERT_NOTNULL(linking_session, "a linking pair session should start")
	TEST_ASSERT_EQUAL(linking_session, first_session, "an actor should reuse one controller when selecting another participant")
	TEST_ASSERT_EQUAL(first.sex_scene, second.sex_scene, "the first pair should remain together")
	TEST_ASSERT_EQUAL(first.sex_scene, third.sex_scene, "the linking session should merge both scenes")
	TEST_ASSERT_EQUAL(first.sex_scene, fourth.sex_scene, "the second pair should move to the merged scene")
	TEST_ASSERT_EQUAL(length(first.sex_scene.participants), 4, "the merged scene should contain all participants")
	TEST_ASSERT_EQUAL(length(first.sex_scene.controllers), 2, "the merged scene should retain one controller per initiating actor")
	TEST_ASSERT_EQUAL(second_scene_action.scene, first.sex_scene, "scene merging should transfer runtime action ownership")
	TEST_ASSERT(second_scene_action in first.sex_scene.active_actions, "the merged scene should index transferred actions")

	second_scene_action.unbind_runtime()
	qdel(second_scene_action)
	qdel(first_session)
	qdel(second_session)

/datum/unit_test/sex_scene_splits_disconnected_groups/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/fourth = allocate(/mob/living/carbon/human)

	var/datum/sex_scene_controller/first_session = first.open_sex_scene(second, show_ui = FALSE)
	var/datum/sex_scene_controller/second_session = third.open_sex_scene(fourth, show_ui = FALSE)
	var/datum/sex_scene_controller/bridge_session = first.open_sex_scene(third, show_ui = FALSE)
	TEST_ASSERT_EQUAL(first.sex_scene, fourth.sex_scene, "the bridge should merge both connected groups")

	TEST_ASSERT_EQUAL(bridge_session, first_session, "the bridge should be another link on the first actor's controller")
	first_session.unlink_participant(third)
	TEST_ASSERT_EQUAL(first.sex_scene, second.sex_scene, "the first connected pair should remain together")
	TEST_ASSERT_EQUAL(third.sex_scene, fourth.sex_scene, "the second connected pair should remain together")
	TEST_ASSERT(first.sex_scene != third.sex_scene, "removing the only bridge should split disconnected groups")
	TEST_ASSERT_EQUAL(length(first.sex_scene.participants), 2, "the original scene should retain only its connected participants")
	TEST_ASSERT_EQUAL(length(third.sex_scene.participants), 2, "the split scene should contain the other connected participants")

	qdel(first_session)
	qdel(second_session)

/datum/unit_test/sex_scene_participant_removal_preserves_survivors/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/departing = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/first_controller = first.open_sex_scene(departing, show_ui = FALSE)
	var/datum/sex_scene_controller/third_controller = third.open_sex_scene(departing, show_ui = FALSE)
	var/datum/sex_scene/shared_scene = departing.sex_scene

	TEST_ASSERT(shared_scene.remove_participant(departing), "the scene should remove a departing participant")
	TEST_ASSERT_NULL(departing.sex_scene, "the departing participant should lose its scene binding")
	TEST_ASSERT(!QDELETED(first_controller), "another actor's controller should survive participant removal")
	TEST_ASSERT(!QDELETED(third_controller), "all unaffected actor controllers should survive participant removal")
	TEST_ASSERT_EQUAL(first_controller.target, first, "a controller should fall back to its own actor when its target leaves")
	TEST_ASSERT_EQUAL(third_controller.target, third, "each surviving controller should choose a valid fallback")
	TEST_ASSERT(first.sex_scene != third.sex_scene, "disconnected survivors should split into independent scenes")

	qdel(first_controller)
	qdel(third_controller)

/datum/unit_test/sex_scene_enforces_group_size
#ifdef FOCUS_SEX_SCENE_PERMISSIVE_ENTRY_TEST
	focus = TRUE
#endif

/datum/unit_test/sex_scene_enforces_group_size/Run()
	var/mob/living/carbon/human/focus = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)

	var/list/group_sessions = list()
	// Counts from 2, because the focus is participant 1 and is never a joiner.
	for(var/participant_number in 2 to SEX_SCENE_MAX_PARTICIPANTS)
		var/mob/living/carbon/human/joiner
		switch(participant_number)
			if(2)
				joiner = partner
			if(3)
				joiner = third
			else
				joiner = allocate(/mob/living/carbon/human)
		var/datum/sex_scene_controller/group_session = joiner.open_sex_scene(focus, show_ui = FALSE)
		TEST_ASSERT_NOTNULL(group_session, "participant [participant_number] should be admitted up to the configured scene cap")
		group_sessions += group_session
	TEST_ASSERT_EQUAL(length(focus.sex_scene.participants), SEX_SCENE_MAX_PARTICIPANTS, "the scene should reach its configured participant cap")
	var/mob/living/carbon/human/overflow_joiner = allocate(/mob/living/carbon/human)
	TEST_ASSERT_NULL(overflow_joiner.open_sex_scene(focus, show_ui = FALSE), "a participant beyond the configured cap should be rejected")
	TEST_ASSERT_NULL(overflow_joiner.sex_scene, "a size-rejected participant must remain outside the scene")
	var/refusal = overflow_joiner.get_sex_scene_refusal(focus)
	TEST_ASSERT(findtext(refusal, "more than [SEX_SCENE_MAX_PARTICIPANTS] people"), "a size-rejected participant should be told the scene is full, got: [refusal]")

	for(var/datum/sex_scene_controller/group_session as anything in group_sessions)
		qdel(group_session)

/datum/unit_test/sex_scene_clears_participant_bindings/Run()
	var/mob/living/carbon/human/participant = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/session = participant.open_sex_scene(participant, show_ui = FALSE)
	var/datum/sex_scene/scene = participant.sex_scene

	TEST_ASSERT_NOTNULL(scene, "a self-controller should create a scene")
	qdel(session)
	TEST_ASSERT_NULL(participant.sex_scene, "destroying the final controller should clear participant bindings")

/datum/unit_test/sex_scene_runtime_action_outlives_controller/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/controller = user.open_sex_scene(target, show_ui = FALSE)
	var/datum/sex_action/action = controller.instantiate_action(/datum/sex_action/rub_body)
	TEST_ASSERT(action.bind_runtime(controller), "the runtime action should bind before controller cleanup")
	var/datum/sex_scene/scene = user.sex_scene

	qdel(controller)
	TEST_ASSERT(!QDELETED(scene), "an active action should keep its scene alive after the UI controller closes")
	TEST_ASSERT(action.is_runtime_active(), "runtime ownership should not depend on the deleted controller")
	TEST_ASSERT_EQUAL(length(scene.controllers), 0, "controller cleanup should leave no compatibility registry entry")

	scene.stop_action(action)
	TEST_ASSERT(QDELETED(action), "scene-owned stopping should delete the runtime action")
	TEST_ASSERT(QDELETED(scene), "the scene should delete itself after its final controller and action are gone")
	TEST_ASSERT_NULL(user.sex_scene, "final scene cleanup should clear the actor binding")
	TEST_ASSERT_NULL(target.sex_scene, "final scene cleanup should clear the target binding")

/datum/unit_test/sex_scene_climax_origin_survives_signal_dispatch/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/controller = user.open_sex_scene(target, show_ui = FALSE)
	var/datum/sex_action/action = controller.instantiate_action(/datum/sex_action/rub_body)
	var/datum/sex_scene_climax_probe/probe = allocate(/datum/sex_scene_climax_probe)
	TEST_ASSERT(action.bind_runtime(controller), "the runtime action should bind before climax routing")
	probe.RegisterSignal(user, COMSIG_SEX_CLIMAX, TYPE_PROC_REF(/datum/sex_scene_climax_probe, on_climax))

	SEND_SIGNAL(user, COMSIG_SEX_CLIMAX, action, user, target, user)
	TEST_ASSERT(probe.received_live_action, "later climax consumers should receive a live originating action")
	TEST_ASSERT(!QDELETED(action), "the action must not delete itself during signal dispatch")
	TEST_ASSERT(action.stop_requested, "the originating action should request loop shutdown after climax")

	probe.UnregisterSignal(user, COMSIG_SEX_CLIMAX)
	action.unbind_runtime()
	qdel(action)
	qdel(controller)

/datum/unit_test/sex_scene_indexes_runtime_actions/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/session = user.open_sex_scene(user, show_ui = FALSE)
	var/datum/sex_action/action = session.instantiate_action(/datum/sex_action/masturbate/penis)

	TEST_ASSERT_NOTNULL(action, "a runtime action should instantiate from its menu type")
	session.set_current_speed(SEX_SPEED_HIGH)
	session.set_current_force(SEX_FORCE_LOW)
	TEST_ASSERT(action.bind_runtime(session), "a runtime action should bind to its pair session")

	TEST_ASSERT_EQUAL(action.scene, session.scene, "the action should bind to the shared scene")
	TEST_ASSERT_EQUAL(action.action_user, session.user, "the action should retain its performing participant")
	TEST_ASSERT_EQUAL(action.action_target, session.target, "the action should retain its target participant")
	TEST_ASSERT(action in session.get_active_actions(), "the pair adapter should derive its active actions from the scene")
	TEST_ASSERT(action in session.scene.active_actions, "the scene should index its runtime action")
	TEST_ASSERT(action in session.scene.get_actions_involving(user), "participant queries should return their runtime actions")
	TEST_ASSERT_EQUAL(action.speed, SEX_SPEED_HIGH, "the action should copy the selected speed")
	TEST_ASSERT_EQUAL(action.force, SEX_FORCE_LOW, "the action should copy the selected force")

	session.set_current_speed(SEX_SPEED_EXTREME)
	session.set_current_force(SEX_FORCE_HIGH)
	TEST_ASSERT_EQUAL(action.speed, SEX_SPEED_EXTREME, "speed changes should update active actions")
	TEST_ASSERT_EQUAL(action.force, SEX_FORCE_HIGH, "force changes should update active actions")
	TEST_ASSERT_EQUAL(action.spanify_force("test"), "<span class='love_high'>test</span>", "presentation helpers should use action-owned force")
	TEST_ASSERT(action.perform_sex_action(user, user, 0, 0, 0), "stimulation should use the bound action context")
	action.add_sex_lock(user, ORGAN_SLOT_PENIS)
	TEST_ASSERT_EQUAL(length(session.scene.resource_claims), 1, "runtime resource claims should be indexed by the scene")
	var/datum/sex_action_proposal/conflicting_proposal = session.create_action_proposal(/datum/sex_action/masturbate/penis_over, "unit_test")
	var/datum/sex_action/other_action = conflicting_proposal.action
	TEST_ASSERT(other_action.check_sex_lock(user, ORGAN_SLOT_PENIS), "another action should see a conflicting scene-local resource claim")
	TEST_ASSERT(!action.check_sex_lock(user, ORGAN_SLOT_PENIS), "an action should not conflict with its own resource claim")
	qdel(conflicting_proposal)

	action.unbind_runtime()
	TEST_ASSERT_EQUAL(length(session.scene.resource_claims), 1, "unbinding alone should retain claims until action cleanup")
	TEST_ASSERT(!(action in session.get_active_actions()), "unbinding should remove the action from pair queries")
	TEST_ASSERT(!(action in session.scene.active_actions), "unbinding should remove the scene index")
	TEST_ASSERT_NULL(action.scene, "unbinding should clear the scene back-reference")
	TEST_ASSERT(!action.perform_sex_action(user, user, 0, 0, 0), "an unbound action should not apply stimulation")

	qdel(action)
	TEST_ASSERT_EQUAL(length(session.scene.resource_claims), 0, "destroying the action should release its scene-local claims")
	qdel(session)

/datum/unit_test/sex_scene_prepares_contextual_action_proposals/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/session = user.open_sex_scene(target, show_ui = FALSE)
	session.set_current_speed(SEX_SPEED_EXTREME)
	session.set_current_force(SEX_FORCE_HIGH)
	var/datum/sex_remote_context/mage_hand/context = new(user, target)
	session.set_remote_context(context)

	var/datum/sex_action_proposal/proposal = session.create_action_proposal(/datum/sex_action/rub_body, "unit_test")
	var/datum/sex_action/action = proposal.action
	TEST_ASSERT_NOTNULL(action, "a proposal should instantiate a dedicated action")
	TEST_ASSERT_EQUAL(action.proposal_controller, session, "the proposal should bind its actor controller before validation")
	TEST_ASSERT_EQUAL(action.action_user, user, "the proposal should carry its actor directly")
	TEST_ASSERT_EQUAL(action.action_target, target, "the proposal should carry its target directly")
	TEST_ASSERT_EQUAL(action.speed, SEX_SPEED_EXTREME, "the proposal should snapshot the selected speed")
	TEST_ASSERT_EQUAL(action.force, SEX_FORCE_HIGH, "the proposal should snapshot the selected force")
	TEST_ASSERT_EQUAL(action.remote_context, context, "the proposal should carry a valid remote context directly")
	TEST_ASSERT(action.can_mage_hand_reach(user, target), "proposal validation should use the carried remote context")

	qdel(proposal)
	TEST_ASSERT(QDELETED(action), "rejecting or discarding a proposal should delete its unaccepted action")
	qdel(session)

/datum/unit_test/sex_scene_releases_remote_context_index/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/controller = user.open_sex_scene(target, show_ui = FALSE)
	var/datum/sex_remote_context/mage_hand/context = new(user, target)

	TEST_ASSERT(controller.set_remote_context(context), "the scene should accept a remote context for its participants")
	TEST_ASSERT(context in controller.scene.remote_contexts, "the scene should index the live remote context")
	qdel(context)
	TEST_ASSERT(!(context in controller.scene.remote_contexts), "direct context deletion should remove its scene index entry")
	TEST_ASSERT_NULL(context.scene, "direct context deletion should clear its scene back-reference")

	qdel(controller)

/// A merge moves a running action while its loop sleeps; the loop must follow it, not strand it.
/datum/unit_test/sex_scene_merge_keeps_action_loop/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/fourth = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/first_controller = first.open_sex_scene(second, show_ui = FALSE)
	TEST_ASSERT_NOTNULL(first_controller, "the first pair should open a scene")
	TEST_ASSERT_NOTNULL(third.open_sex_scene(fourth, show_ui = FALSE), "the second pair should open a scene")
	first_controller.set_current_speed(SEX_SPEED_EXTREME)
	var/datum/sex_action/action = first_controller.try_start_action(/datum/sex_action/rub_body, "unit_test")
	TEST_ASSERT_NOTNULL(action, "the first pair's action should start")
	var/interaction_key = "sex_action_[REF(action)]"
	TEST_ASSERT(DOING_INTERACTION(first, interaction_key), "the action loop should be running before the merge")

	TEST_ASSERT_NOTNULL(third.open_sex_scene(first, show_ui = FALSE), "the second scene should absorb the first")
	TEST_ASSERT_EQUAL(action.scene, third.sex_scene, "the merge should move the running action")
	sleep(2 SECONDS)
	TEST_ASSERT(DOING_INTERACTION(first, interaction_key), "the action loop should survive the merge")

	action.stop_runtime()
	TEST_ASSERT(QDELETED(action), "the moved action should still stop cleanly")

/// A split moves a running action into a new scene; the loop must follow it, not strand it.
/datum/unit_test/sex_scene_split_keeps_action_loop/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/third = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/fourth = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/first_controller = first.open_sex_scene(second, show_ui = FALSE)
	var/datum/sex_scene_controller/third_controller = third.open_sex_scene(fourth, show_ui = FALSE)
	TEST_ASSERT_NOTNULL(first_controller, "the first pair should open a scene")
	TEST_ASSERT_NOTNULL(third_controller, "the second pair should open a scene")
	TEST_ASSERT_NOTNULL(first.open_sex_scene(third, show_ui = FALSE), "a bridge should join both pairs")
	third_controller.set_current_speed(SEX_SPEED_EXTREME)
	var/datum/sex_action/action = third_controller.try_start_action(/datum/sex_action/rub_body, "unit_test")
	TEST_ASSERT_NOTNULL(action, "the second pair's action should start")
	var/interaction_key = "sex_action_[REF(action)]"

	first_controller.unlink_participant(third)
	TEST_ASSERT(first.sex_scene != third.sex_scene, "removing the bridge should split the scene")
	TEST_ASSERT_EQUAL(action.scene, third.sex_scene, "the split should move the running action")
	sleep(2 SECONDS)
	TEST_ASSERT(DOING_INTERACTION(third, interaction_key), "the action loop should survive the split")

	action.stop_runtime()
	TEST_ASSERT(QDELETED(action), "the moved action should still stop cleanly")

/// Mage Hand pulls a busy target's scene into the caster's; the target's own action must keep running.
/datum/unit_test/mage_hand_keeps_target_action_loop/Run()
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/caster_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target_partner = allocate(/mob/living/carbon/human)
	TEST_ASSERT_NOTNULL(caster.open_sex_scene(caster_partner, show_ui = FALSE), "the caster's pair should open a scene")
	var/datum/sex_scene_controller/target_controller = target.open_sex_scene(target_partner, show_ui = FALSE)
	TEST_ASSERT_NOTNULL(target_controller, "the target's pair should open a scene")
	target_controller.set_current_speed(SEX_SPEED_EXTREME)
	var/datum/sex_action/action = target_controller.try_start_action(/datum/sex_action/rub_body, "unit_test")
	TEST_ASSERT_NOTNULL(action, "the target's action should start")
	var/interaction_key = "sex_action_[REF(action)]"

	TEST_ASSERT(start_mage_hand_tether(caster, target, 2 MINUTES, 7, TRUE, TRUE, FALSE), "the tether should start")
	TEST_ASSERT_EQUAL(action.scene, caster.sex_scene, "the tether should merge the target's scene into the caster's")
	sleep(2 SECONDS)
	TEST_ASSERT(DOING_INTERACTION(target, interaction_key), "the target's action loop should survive the tether")

	action.stop_runtime()
	TEST_ASSERT(QDELETED(action), "the moved action should still stop cleanly")

/datum/unit_test/sex_scene_recognizes_spitroast_pattern/Run()
	var/mob/living/carbon/human/focus = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/oral_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/penetrating_partner = allocate(/mob/living/carbon/human)

	var/datum/sex_scene_controller/oral_session = focus.open_sex_scene(oral_partner, show_ui = FALSE)
	var/datum/sex_scene_controller/penetration_session = penetrating_partner.open_sex_scene(focus, show_ui = FALSE)
	var/datum/sex_action/oral_action = oral_session.instantiate_action(/datum/sex_action/blowjob)
	var/datum/sex_action/penetration_action = penetration_session.instantiate_action(/datum/sex_action/sex/vaginal)

	TEST_ASSERT(oral_action.bind_runtime(oral_session), "the oral action should bind to the shared scene")
	var/list/oral_roles = focus.sex_scene.get_roles_for(focus, SEX_SCENE_INTERACTION_ORAL, SEX_SCENE_ROLE_GIVER)
	TEST_ASSERT_EQUAL(length(oral_roles), 1, "the focus should expose one oral-giver role")
	var/datum/sex_scene_role/oral_role = oral_roles[1]
	TEST_ASSERT_EQUAL(oral_role.body_slot, BODY_ZONE_PRECISE_MOUTH, "the oral role should occupy the focus's mouth")
	TEST_ASSERT(!focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_SPITROAST), "one action should not form a multi-action pattern")

	var/datum/sex_action/compatible_ai_action = SEX_ACTION(/datum/sex_action/npc/npc_vaginal_sex)
	var/datum/sex_action/incompatible_ai_action = SEX_ACTION(/datum/sex_action/npc/npc_throat_sex)
	var/compatible_partner_desirability = focus.sex_scene.get_action_pattern_desirability(compatible_ai_action, penetrating_partner, focus)
	var/same_partner_desirability = focus.sex_scene.get_action_pattern_desirability(compatible_ai_action, oral_partner, focus)
	var/incompatible_action_desirability = focus.sex_scene.get_action_pattern_desirability(incompatible_ai_action, penetrating_partner, focus)
	TEST_ASSERT_EQUAL(compatible_partner_desirability, 4, "a distinct partner penetrating the focus should receive the pattern's AI desirability score")
	TEST_ASSERT_EQUAL(same_partner_desirability, 0, "the oral partner should not satisfy the pattern's distinct-partner requirement")
	TEST_ASSERT_EQUAL(incompatible_action_desirability, 0, "an action which does not fill the missing penetration role should not receive a pattern bonus")

	TEST_ASSERT(penetration_action.bind_runtime(penetration_session), "the penetration action should bind to the shared scene")
	var/list/pattern_matches = focus.get_active_sex_scene_patterns(SEX_SCENE_PATTERN_SPITROAST)
	TEST_ASSERT_EQUAL(length(pattern_matches), 1, "oral giving plus vaginal penetration should form one spit-roast pattern")
	var/datum/sex_scene_pattern_match/pattern_match = pattern_matches[1]
	TEST_ASSERT_EQUAL(pattern_match.focus, focus, "the pattern should identify the participant occupying both required roles")
	TEST_ASSERT_EQUAL(length(pattern_match.actions), 2, "the pattern should retain both contributing actions")
	TEST_ASSERT_EQUAL(length(pattern_match.participants), 3, "the pattern should require two distinct partners")
	TEST_ASSERT_EQUAL(length(pattern_match.counterparts), 2, "the pattern should preserve requirement-ordered partners for presentation")
	TEST_ASSERT(oral_partner.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_SPITROAST), "partners should be able to query patterns involving them")
	TEST_ASSERT(penetrating_partner.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_SPITROAST), "all involved mobs should share the recognized pattern")
	TEST_ASSERT(findtext(pattern_match.pattern.get_start_message(pattern_match), "[focus]"), "the pattern should provide a combined start message")
	TEST_ASSERT(findtext(pattern_match.pattern.get_end_message(pattern_match), "[focus]"), "the pattern should provide a combined end message")
	TEST_ASSERT(findtext(pattern_match.pattern.get_climax_message(pattern_match, focus), "[focus]"), "the pattern should provide focus-aware climax presentation")

	var/list/pattern_ui_data = oral_session.get_scene_patterns_ui_data()
	TEST_ASSERT_EQUAL(length(pattern_ui_data), 1, "an involved session should expose the active pattern to its UI")
	var/list/pattern_ui_entry = pattern_ui_data[1]
	TEST_ASSERT_EQUAL(pattern_ui_entry["name"], "Spit-roasting", "the UI should receive the pattern-owned display label")
	TEST_ASSERT(pattern_ui_entry["is_focus"], "the focus's session should mark the pattern as centered on its user")

	var/list/partner_pattern_ui_data = penetration_session.get_scene_patterns_ui_data()
	TEST_ASSERT_EQUAL(length(partner_pattern_ui_data), 1, "an involved partner's session should expose the active pattern")
	var/list/partner_pattern_ui_entry = partner_pattern_ui_data[1]
	TEST_ASSERT(!partner_pattern_ui_entry["is_focus"], "a partner's session should not mark the pattern as centered on its user")
	TEST_ASSERT_EQUAL(partner_pattern_ui_entry["focus_name"], focus.name, "a partner's session should identify the pattern's focus")

	var/datum/sex_action_effect_context/focus_effect = new(focus, oral_partner, oral_action, focus, oral_partner, TRUE)
	focus_effect.arousal_amt = 10
	focus_effect.orgasm_prog_amt = 10
	focus.sex_scene.modify_action_effect(focus_effect)
	TEST_ASSERT_EQUAL(focus_effect.arousal_amt, 11.5, "the focus should receive the pattern's pleasure multiplier")
	TEST_ASSERT_EQUAL(focus_effect.orgasm_prog_amt, 11.5, "the focus should receive the pattern's orgasm-progress multiplier")
	qdel(focus_effect)

	var/datum/sex_action_effect_context/partner_effect = new(oral_partner, focus, oral_action, focus, oral_partner, FALSE)
	partner_effect.arousal_amt = 10
	partner_effect.orgasm_prog_amt = 10
	focus.sex_scene.modify_action_effect(partner_effect)
	TEST_ASSERT_EQUAL(partner_effect.arousal_amt, 10.5, "other involved participants should receive their pattern pleasure multiplier")
	TEST_ASSERT_EQUAL(partner_effect.orgasm_prog_amt, 10.5, "other involved participants should receive their pattern orgasm-progress multiplier")
	qdel(partner_effect)

	var/focus_climax_stress = pattern_match.pattern.get_climax_stress_event(pattern_match, focus)
	var/partner_climax_stress = pattern_match.pattern.get_climax_stress_event(pattern_match, oral_partner)
	TEST_ASSERT_EQUAL(focus_climax_stress, /datum/stress_event/sex_scene_spitroast/focus, "the pattern should provide its focus climax stress event")
	TEST_ASSERT_EQUAL(partner_climax_stress, /datum/stress_event/sex_scene_spitroast/participant, "the pattern should provide its partner climax stress event")
	TEST_ASSERT(focus.sex_scene.handle_pattern_climax(focus, oral_action), "the scene should dispatch a climax through its active pattern")
	TEST_ASSERT(focus.has_stress_type(/datum/stress_event/sex_scene_spitroast/focus), "pattern climax handling should apply the focus stress event")
	focus.remove_stress(/datum/stress_event/sex_scene_spitroast/focus)
	var/active_pattern_desirability = focus.sex_scene.get_action_pattern_desirability(compatible_ai_action, penetrating_partner, focus)
	TEST_ASSERT_EQUAL(active_pattern_desirability, 0, "an already-active pattern should not keep attracting redundant AI actions")

	penetration_action.unbind_runtime()
	TEST_ASSERT(!focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_SPITROAST), "removing a required action should end the pattern immediately")

	oral_action.unbind_runtime()
	qdel(oral_action)
	qdel(penetration_action)
	qdel(oral_session)
	qdel(penetration_session)

/datum/unit_test/sex_scene_recognizes_and_supersedes_larger_patterns
#ifdef FOCUS_SEX_SCENE_PERMISSIVE_ENTRY_TEST
	focus = TRUE
#endif

/datum/unit_test/sex_scene_recognizes_and_supersedes_larger_patterns/Run()
	var/mob/living/carbon/human/focus = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/oral_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/vaginal_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/anal_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/late_partner = allocate(/mob/living/carbon/human)
	late_partner.gender = MALE
	late_partner.give_genitals()

	var/datum/sex_scene_controller/oral_session = focus.open_sex_scene(oral_partner, show_ui = FALSE)
	var/datum/sex_scene_controller/vaginal_session = vaginal_partner.open_sex_scene(focus, show_ui = FALSE)
	var/datum/sex_scene_controller/anal_session = anal_partner.open_sex_scene(focus, show_ui = FALSE)
	var/datum/sex_scene_controller/late_session
	var/datum/sex_action/oral_action = oral_session.instantiate_action(/datum/sex_action/blowjob)
	var/datum/sex_action/vaginal_action = vaginal_session.instantiate_action(/datum/sex_action/sex/vaginal)
	var/datum/sex_action/anal_action = anal_session.instantiate_action(/datum/sex_action/sex/anal)

	TEST_ASSERT(oral_action.bind_runtime(oral_session), "the oral action should bind")
	TEST_ASSERT(vaginal_action.bind_runtime(vaginal_session), "the vaginal action should bind")
	TEST_ASSERT(focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_SPITROAST), "oral plus one penetration should begin as a spit-roast")

	TEST_ASSERT(anal_action.bind_runtime(anal_session), "the anal action should bind")
	TEST_ASSERT(focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_AIRTIGHT), "oral, vaginal, and anal roles with distinct partners should form an airtight pattern")
	TEST_ASSERT(!focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_SPITROAST), "the complete airtight pattern should suppress its smaller spit-roast subsets")
	TEST_ASSERT(!focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_DOUBLE_PENETRATION), "the complete airtight pattern should suppress its double-penetration subset")
	var/list/airtight_matches = focus.get_active_sex_scene_patterns(SEX_SCENE_PATTERN_AIRTIGHT)
	TEST_ASSERT_EQUAL(length(airtight_matches), 1, "the four-participant arrangement should expose one maximal pattern")
	var/datum/sex_scene_pattern_match/airtight_match = airtight_matches[1]
	TEST_ASSERT_EQUAL(length(airtight_match.actions), 3, "the airtight match should retain all three actions")
	TEST_ASSERT_EQUAL(length(airtight_match.participants), 4, "the airtight match should retain all four participants")

	late_session = late_partner.open_sex_scene(focus, show_ui = FALSE)
	var/datum/sex_action/late_action = late_session.instantiate_action(/datum/sex_action/npc/npc_vaginal_sex)
	TEST_ASSERT(late_action.bind_runtime(late_session), "a late participant should be able to share an occupied hole")
	airtight_matches = focus.get_active_sex_scene_patterns(SEX_SCENE_PATTERN_AIRTIGHT)
	TEST_ASSERT_EQUAL(length(airtight_matches), 1, "an extra compatible action should not duplicate an established pattern")
	TEST_ASSERT_EQUAL(airtight_matches[1], airtight_match, "a late participant should not replace the established pattern actors")

	var/datum/sex_action_effect_context/focus_effect = new(focus, vaginal_partner, vaginal_action, vaginal_partner, focus, FALSE)
	focus_effect.arousal_amt = 10
	focus_effect.orgasm_prog_amt = 10
	focus.sex_scene.modify_action_effect(focus_effect)
	// Taken from the pattern rather than written out, so retuning the multiplier can't silently
	// turn this into a test of one specific number instead of "exactly one modifier applied".
	var/expected_focus_amt = 10 * airtight_match.pattern.focus_pleasure_multiplier
	TEST_ASSERT_EQUAL(focus_effect.arousal_amt, expected_focus_amt, "only the maximal airtight modifier should apply to its focus")
	TEST_ASSERT_EQUAL(focus_effect.orgasm_prog_amt, expected_focus_amt, "overlapping subset patterns must not stack their mechanics")
	qdel(focus_effect)

	oral_action.unbind_runtime()
	TEST_ASSERT(!focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_AIRTIGHT), "removing oral should end the airtight pattern")
	TEST_ASSERT(focus.has_active_sex_scene_pattern(SEX_SCENE_PATTERN_DOUBLE_PENETRATION), "the remaining vaginal and anal actions should fall back to double penetration")

	vaginal_action.unbind_runtime()
	anal_action.unbind_runtime()
	late_action.unbind_runtime()
	qdel(oral_action)
	qdel(vaginal_action)
	qdel(anal_action)
	qdel(late_action)
	qdel(oral_session)
	qdel(vaginal_session)
	qdel(anal_session)
	qdel(late_session)

/datum/unit_test/sex_scene_horny_ai_has_low_priority_fallbacks
#ifdef FOCUS_SEX_SCENE_PERMISSIVE_ENTRY_TEST
	focus = TRUE
#endif

/datum/unit_test/sex_scene_horny_ai_has_low_priority_fallbacks/Run()
	var/mob/living/carbon/human/horny_npc = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	horny_npc.gender = MALE
	horny_npc.give_genitals()
	target.gender = FEMALE
	target.give_genitals()

	var/list/weighted_actions = list()
	add_local_horny_ai_actions(weighted_actions, horny_npc, target)
	var/body_rub_entries = 0
	var/handjob_entries = 0
	var/vaginal_entries = 0
	for(var/action_type in weighted_actions)
		if(action_type == /datum/sex_action/npc/npc_body_rub)
			body_rub_entries += 1
		else if(action_type == /datum/sex_action/npc/npc_handjob)
			handjob_entries += 1
		else if(action_type == /datum/sex_action/npc/npc_vaginal_sex)
			vaginal_entries += 1
	TEST_ASSERT_EQUAL(body_rub_entries, 1, "body rubbing should be available as a low-weight fallback")
	TEST_ASSERT_EQUAL(handjob_entries, 1, "using the target's hand should be available as a low-weight fallback")
	TEST_ASSERT_EQUAL(vaginal_entries, 3, "preferred penetrative actions should retain a higher selection weight")

	var/datum/sex_scene_controller/controller = horny_npc.open_sex_scene(target, show_ui = FALSE)
	var/datum/sex_action_proposal/body_rub_proposal = controller.create_action_proposal(/datum/sex_action/npc/npc_body_rub, "unit_test")
	var/datum/sex_action_proposal/handjob_proposal = controller.create_action_proposal(/datum/sex_action/npc/npc_handjob, "unit_test")
	TEST_ASSERT(body_rub_proposal.can_start(), "the body-rubbing fallback should produce a valid action proposal")
	TEST_ASSERT(handjob_proposal.can_start(), "the target-hand fallback should produce a valid action proposal")
	qdel(body_rub_proposal)
	qdel(handjob_proposal)
	qdel(controller)

/datum/unit_test/sex_scene_ai_acquisition_prefers_pattern_opportunities/Run()
	var/mob/living/carbon/human/focus = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/oral_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/prospective_partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/unrelated_target = allocate(/mob/living/carbon/human)
	prospective_partner.gender = MALE
	prospective_partner.give_genitals()

	var/datum/sex_scene_controller/oral_session = focus.open_sex_scene(oral_partner, show_ui = FALSE)
	var/datum/sex_action/oral_action = oral_session.instantiate_action(/datum/sex_action/blowjob)
	TEST_ASSERT(oral_action.bind_runtime(oral_session), "the oral action should create an incomplete pattern opportunity")
	TEST_ASSERT(!(prospective_partner in focus.sex_scene.participants), "acquisition scoring should evaluate a mob before it joins the scene")

	var/datum/sex_action/compatible_action = SEX_ACTION(/datum/sex_action/npc/npc_anal_sex)
	var/ordinary_desirability = focus.sex_scene.get_action_pattern_desirability(compatible_action, prospective_partner, focus)
	var/acquisition_desirability = focus.sex_scene.get_action_pattern_desirability(compatible_action, prospective_partner, focus, allow_new_participant = TRUE)
	TEST_ASSERT_EQUAL(ordinary_desirability, 0, "ordinary action scoring should reject participants outside the scene")
	TEST_ASSERT_EQUAL(acquisition_desirability, 4, "acquisition scoring should recognize a prospective partner who can complete the pattern")

	var/datum/ai_behavior/find_potential_horny_targets/acquisition_behavior = new
	var/list/weighted_targets = acquisition_behavior.build_pattern_weighted_targets(
		prospective_partner,
		list(focus, unrelated_target),
		list(),
	)
	var/focus_entries = 0
	var/unrelated_entries = 0
	for(var/mob/living/weighted_target as anything in weighted_targets)
		if(weighted_target == focus)
			focus_entries += 1
		else if(weighted_target == unrelated_target)
			unrelated_entries += 1
	TEST_ASSERT_EQUAL(focus_entries, 5, "the compatible target should receive its base entry plus the pattern desirability weight")
	TEST_ASSERT_EQUAL(unrelated_entries, 1, "an unrelated target should retain its ordinary acquisition weight")

	qdel(acquisition_behavior)
	oral_action.unbind_runtime()
	qdel(oral_action)
	qdel(oral_session)

/datum/unit_test/sex_scene_horny_ai_starts_runtime_action
#ifdef FOCUS_SEX_SCENE_HORNY_AI_TEST
	focus = TRUE
#endif

/datum/unit_test/sex_scene_horny_ai_starts_runtime_action/Run()
	var/mob/living/carbon/human/species/goblin/npc/horny_npc = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	horny_npc.gender = MALE
	horny_npc.give_genitals()
	target.gender = FEMALE
	target.give_genitals()
	target.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_HUMANOIDS,
	))

	var/datum/ai_controller/controller = horny_npc.ai_controller
	if(!controller)
		controller = allocate(/datum/ai_controller, horny_npc)
	var/datum/targetting_datum/basic/targetting_datum = allocate(/datum/targetting_datum/basic/sex_scene_unit_test_allow_clientless_horny)
	controller.set_blackboard_key(BB_TARGETTING_DATUM, targetting_datum)
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, target)
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
	target.forceMove(get_turf(horny_npc))
	target.set_body_position(LYING_DOWN)

	var/datum/ai_behavior/horny/horny_behavior = new
	TEST_ASSERT(horny_behavior.setup(controller, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM) != FALSE, "the horny behavior should acquire its opted-in target")
	TEST_ASSERT_NULL(horny_npc.sex_scene, "the chase should not bind a sex scene before the NPC reaches its target")
	// The phased hunt seizes, holds and preps over several beats before the act starts.
	var/datum/sex_scene_controller/scene_controller
	for(var/beat in 1 to 12)
		horny_npc.next_move = 0
		horny_behavior.perform(1, controller, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
		scene_controller = horny_npc.sex_scene?.get_controller(horny_npc)
		if(length(scene_controller?.get_active_actions()))
			break
	TEST_ASSERT_NOTNULL(scene_controller, "the horny NPC should bind an actor-owned scene controller after reaching its target (phase [controller.blackboard[BB_HORNY_PHASE]])")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], target, "scene acquisition should not cancel the horny behavior")
	var/list/active_actions = scene_controller.get_active_actions()
	TEST_ASSERT_EQUAL(length(active_actions), 1, "the horny NPC should start one runtime action after reaching its target")
	var/datum/sex_action/action = active_actions[1]
	TEST_ASSERT(action in horny_npc.sex_scene.active_actions, "the shared scene should own the horny NPC's runtime action")

	horny_behavior.finish_action(controller, FALSE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT(QDELETED(scene_controller), "finishing the horny behavior should release its actor-owned scene controller")
	TEST_ASSERT_NULL(horny_npc.sex_scene, "finishing the horny behavior should not leave a stale scene bound to the NPC")

	var/mob/living/carbon/human/replacement_target = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/replacement_controller = horny_npc.open_sex_scene(replacement_target, FALSE)
	TEST_ASSERT_NOTNULL(replacement_controller, "a failed horny encounter should not prevent the NPC from acquiring a different target")
	qdel(replacement_controller)
	qdel(horny_behavior)

/// Records every mob that receives sex stimulation.
/datum/sex_scene_receive_probe
	var/list/receivers = list()

/datum/sex_scene_receive_probe/proc/on_receive(mob/living/source)
	SIGNAL_HANDLER
	receivers += source

/// Putting an item into a partner's body stimulates the partner, not the one who inserts it.
/datum/unit_test/hole_storage_insert_stimulates_receiver/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	target.gender = FEMALE
	target.give_genitals()
	TEST_ASSERT_NOTNULL(target.getorganslot(ORGAN_SLOT_BREASTS), "Test setup: the target needs breasts")
	var/obj/item/stored = allocate(/obj/item)
	stored.w_class = WEIGHT_CLASS_TINY
	user.put_in_active_hand(stored)

	var/datum/sex_scene_controller/session = user.open_sex_scene(target, show_ui = FALSE)
	var/datum/sex_action/hole_storage/boobs_store/action = session.instantiate_action(/datum/sex_action/hole_storage/boobs_store)
	TEST_ASSERT(action.bind_runtime(session), "Test setup: the action should bind to the session")
	var/datum/sex_scene_receive_probe/probe = allocate(/datum/sex_scene_receive_probe)
	probe.RegisterSignal(user, COMSIG_SEX_RECEIVE_ACTION, TYPE_PROC_REF(/datum/sex_scene_receive_probe, on_receive))
	probe.RegisterSignal(target, COMSIG_SEX_RECEIVE_ACTION, TYPE_PROC_REF(/datum/sex_scene_receive_probe, on_receive))

	action.on_perform(user, target)

	TEST_ASSERT(stored.loc != user, "Test setup: the item should leave the inserter's hand")
	TEST_ASSERT(target in probe.receivers, "The partner receiving the item should feel it")
	TEST_ASSERT(!(user in probe.receivers), "The inserter must not feel the partner's insertion")

	qdel(action)
	qdel(session)
