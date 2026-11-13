/datum/unit_test/erp_preferences_recover_from_missing_storage
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_recover_from_missing_storage/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.preference_cache[/datum/preference/list_type/erp_preferences] = null

	var/datum/erp_preference/boolean/allow_mob_breeding/boolean_pref = new
	TEST_ASSERT_EQUAL(boolean_pref.get_value(prefs), boolean_pref.default_value, "Boolean ERP preferences should use defaults when storage is missing.")

	var/datum/erp_preference/bitflag/horny_mob_types/bitflag_pref = new
	TEST_ASSERT_EQUAL(bitflag_pref.get_value(prefs), bitflag_pref.default_value, "Bitflag ERP preferences should use defaults when storage is missing.")

	var/datum/kink/bondage/kink = new
	var/kink_ui = prefs.show_kink_ui(kink)
	TEST_ASSERT_NOTNULL(kink_ui, "Kink preference UI should render when ERP storage is missing.")
	var/list/erp_preferences = prefs.read_preference(/datum/preference/list_type/erp_preferences)
	TEST_ASSERT(islist(erp_preferences), "Rendering kink preferences should initialize ERP storage.")
	TEST_ASSERT(islist(erp_preferences["kinks"]), "Rendering kink preferences should initialize kink storage.")
	TEST_ASSERT_EQUAL(erp_preferences["kinks"][kink.name]["enabled"], FALSE, "Missing kink data should use the configured default enabled state.")
	TEST_ASSERT_EQUAL(erp_preferences["kinks"][kink.name]["intensity"], 1, "Missing kink data should use the configured default intensity.")

/datum/unit_test/erp_preferences_setup_defaults
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_setup_defaults/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.preference_cache[/datum/preference/list_type/erp_preferences] = null

	prefs.setup_default_erp_preferences()

	var/list/erp_preferences = prefs.read_preference(/datum/preference/list_type/erp_preferences)
	TEST_ASSERT(islist(erp_preferences), "Default setup should initialize ERP storage.")
	TEST_ASSERT((/datum/erp_preference/boolean/allow_mob_breeding in erp_preferences), "Default setup should populate concrete ERP preferences.")
	var/datum/erp_preference/bitflag/horny_mob_types/bitflag_pref = new
	TEST_ASSERT_EQUAL(erp_preferences[bitflag_pref.type], bitflag_pref.default_value, "Default setup should populate concrete bitflag ERP preferences.")
	TEST_ASSERT(!(/datum/erp_preference/bitflag in erp_preferences), "Default setup should not populate abstract ERP preferences.")

/datum/unit_test/erp_preferences_nonmatching_horny_mobs_are_nonlethal_by_default
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_nonmatching_horny_mobs_are_nonlethal_by_default/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.preference_cache[/datum/preference/list_type/erp_preferences] = null

	prefs.setup_default_erp_preferences()

	var/datum/erp_preference/boolean/nonmatching_horny_mobs_are_nonlethal/nonlethal_pref = new
	var/list/erp_preferences = prefs.read_preference(/datum/preference/list_type/erp_preferences)
	TEST_ASSERT((nonlethal_pref.type in erp_preferences), "Default setup should populate the nonmatching horny mob handling preference.")
	TEST_ASSERT_EQUAL(nonlethal_pref.get_value(prefs), TRUE, "Nonmatching horny mobs should use nonlethal handling by default.")

	nonlethal_pref.set_value(prefs, FALSE)
	TEST_ASSERT_EQUAL(nonlethal_pref.get_value(prefs), FALSE, "Nonmatching horny mob handling should be player-configurable.")

/datum/unit_test/erp_preferences_clientless_targets_require_cached_consent
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_clientless_targets_require_cached_consent/Run()
	var/mob/living/simple_animal/actor = allocate(/mob/living/simple_animal)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/mind/target_mind = allocate(/datum/mind, "erp-pref-test")
	target_mind.current = target
	target.mind = target_mind

	TEST_ASSERT_EQUAL(target_allows_mob_erp_action(actor, target, /datum/erp_preference/boolean/allow_mob_breeding), FALSE, "Clientless ERP targets should deny intrusive mob actions unless a cached preference allows them.")
	target.mind = null
	target_mind.current = null

/datum/unit_test/erp_preferences_clientless_targets_use_cached_consent
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_clientless_targets_use_cached_consent/Run()
	var/mob/living/simple_animal/actor = allocate(/mob/living/simple_animal)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/mind/target_mind = allocate(/datum/mind, "erp-pref-cache-test")
	target_mind.current = target
	target.mind = target_mind

	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	var/datum/erp_preference/boolean/allow_mob_breeding/breeding_pref = new

	breeding_pref.set_value(prefs, FALSE)
	target.cache_erp_preferences_from_prefs(prefs)
	TEST_ASSERT_EQUAL(target_allows_mob_erp_action(actor, target, breeding_pref.type), FALSE, "Clientless targets should keep denying intrusive mob actions when their cached preference is disabled.")

	breeding_pref.set_value(prefs, TRUE)
	target.cache_erp_preferences_from_prefs(prefs)
	TEST_ASSERT_EQUAL(target_allows_mob_erp_action(actor, target, breeding_pref.type), TRUE, "Clientless targets should allow intrusive mob actions when their cached preference explicitly allows them.")
	target.mind = null
	target_mind.current = null

/datum/unit_test/erp_preferences_clientless_targets_are_not_horny_ai_targets
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_clientless_targets_are_not_horny_ai_targets/Run()
	var/turf/test_turf = get_turf(run_loc_floor_bottom_left)
	var/mob/living/carbon/human/species/goblin/npc/actor = allocate(/mob/living/carbon/human/species/goblin/npc, test_turf)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, test_turf)
	actor.gender = MALE
	target.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_HUMANOIDS,
		/datum/erp_preference/boolean/nonmatching_horny_mobs_are_nonlethal = TRUE,
	))

	var/datum/targetting_datum/basic/targetting_datum = actor.ai_controller.blackboard[BB_TARGETTING_DATUM]
	var/datum/targetting_datum/basic/not_friends/pet_targetting_datum = actor.ai_controller.blackboard[BB_PET_TARGETING_DATUM]
	actor.ai_controller.set_blackboard_key(BB_FRIENDS_LIST, list())

	TEST_ASSERT_NULL(target.client, "Unit test target should be clientless.")
	TEST_ASSERT(!targetting_datum.is_selected_horny_target(actor, target), "Clientless human targets should not be selected as horny AI targets even when cached prefs match.")
	TEST_ASSERT(!targetting_datum.can_horny(actor, target), "Clientless human targets should not be valid horny AI targets.")
	TEST_ASSERT(!targetting_datum.should_use_nonlethal_mob_erp_handling(actor, target), "Clientless human targets should not fall through into nonlethal mob ERP handling.")
	TEST_ASSERT(pet_targetting_datum.can_attack(actor, target), "Clientless human targets should still be attackable through the normal pet attack targeting datum.")

/datum/unit_test/erp_preferences_mind_transfer_preserves_cached_consent
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_mind_transfer_preserves_cached_consent/Run()
	var/mob/living/carbon/human/old_body = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/new_body = allocate(/mob/living/carbon/human)
	var/datum/mind/target_mind = allocate(/datum/mind, "erp-pref-transfer-test")
	target_mind.current = old_body
	old_body.mind = target_mind

	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	var/datum/erp_preference/boolean/allow_mob_breeding/breeding_pref = new
	breeding_pref.set_value(prefs, TRUE)
	old_body.cache_erp_preferences_from_prefs(prefs)

	target_mind.transfer_to(new_body)

	TEST_ASSERT_EQUAL(new_body.get_cached_erp_pref(breeding_pref.type), TRUE, "Mind transfers should mirror cached ERP consent onto the new body.")
	old_body.mind = null
	old_body.last_mind = null
	new_body.mind = null
	new_body.last_mind = null
	target_mind.current = null

/datum/sex_action/unit_test_disconnected_erp
	name = "Disconnect test"
	check_distance = FALSE
	stamina_cost = 0

/datum/unit_test/erp_preferences_disconnected_players_deny_sex_scene_controllers_by_default
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_disconnected_players_deny_sex_scene_controllers_by_default/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/mind/target_mind = allocate(/datum/mind, "erp-pref-disconnected-default-test")
	target_mind.current = target
	target.mind = target_mind

	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	target.cache_erp_preferences_from_prefs(prefs)

	var/datum/sex_scene_controller/session = user.open_sex_scene(target, FALSE)
	if(session)
		qdel(session)
	target.mind = null
	target.last_mind = null
	target_mind.current = null

	TEST_ASSERT_NULL(session, "Disconnected player bodies should not accept player ERP sessions by default.")

/datum/unit_test/erp_preferences_disconnected_players_allow_sex_scene_controllers_when_enabled
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_disconnected_players_allow_sex_scene_controllers_when_enabled/Run()
	var/disconnected_pref_type = text2path("/datum/erp_preference/boolean/allow_player_erp_when_disconnected")
	TEST_ASSERT_NOTNULL(disconnected_pref_type, "The disconnected-player ERP preference should exist.")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/mind/target_mind = allocate(/datum/mind, "erp-pref-disconnected-enabled-test")
	target_mind.current = target
	target.mind = target_mind

	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	var/datum/erp_preference/boolean/disconnected_pref = new disconnected_pref_type
	disconnected_pref.set_value(prefs, TRUE)
	target.cache_erp_preferences_from_prefs(prefs)

	var/datum/sex_scene_controller/session = user.open_sex_scene(target, FALSE)
	var/session_created = !isnull(session)
	if(session)
		qdel(session)
	target.mind = null
	target.last_mind = null
	target_mind.current = null

	TEST_ASSERT(session_created, "Disconnected player bodies should accept player ERP sessions when their cached preference allows it.")

/datum/unit_test/erp_preferences_disconnected_players_block_existing_sex_actions
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_disconnected_players_block_existing_sex_actions/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/mind/target_mind = allocate(/datum/mind, "erp-pref-disconnected-action-test")
	target_mind.current = target
	target.mind = target_mind

	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	target.cache_erp_preferences_from_prefs(prefs)

	var/datum/sex_scene_controller/session = allocate(/datum/sex_scene_controller, user, target)
	var/datum/sex_action_proposal/proposal = session.create_action_proposal(/datum/sex_action/unit_test_disconnected_erp, "unit_test")
	var/can_perform = proposal.can_start()
	qdel(proposal)
	target.mind = null
	target.last_mind = null
	target_mind.current = null

	TEST_ASSERT_EQUAL(can_perform, FALSE, "Existing sex sessions should not perform actions with disconnected player bodies that have not opted in.")

/datum/unit_test/erp_preferences_dead_mobs_do_not_open_sex_scenes
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_dead_mobs_do_not_open_sex_scenes/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)

	user.death()
	var/datum/sex_scene_controller/dead_user_session = user.open_sex_scene(target, FALSE)
	if(dead_user_session)
		qdel(dead_user_session)

	var/mob/living/carbon/human/second_user = allocate(/mob/living/carbon/human)
	target.death()
	var/datum/sex_scene_controller/dead_target_controller = second_user.open_sex_scene(target, FALSE)
	if(dead_target_controller)
		qdel(dead_target_controller)

	TEST_ASSERT_NULL(dead_user_session, "Dead users should not start sex sessions.")
	TEST_ASSERT_NULL(dead_target_controller, "Dead targets should not accept sex scene controllers.")

/datum/unit_test/erp_preferences_death_removes_participant_from_existing_sex_scene
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_death_removes_participant_from_existing_sex_scene/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/datum/sex_scene_controller/controller = user.open_sex_scene(target, FALSE)
	TEST_ASSERT_NOTNULL(controller, "Living participants should be able to open a sex scene before the death check.")

	target.death()

	TEST_ASSERT(!QDELETED(controller), "Another participant's controller should survive when its target dies.")
	TEST_ASSERT_NULL(target.sex_scene, "A dead participant should be removed from the sex scene.")
	TEST_ASSERT_EQUAL(controller.target, user, "The surviving controller should fall back to its own user.")
	qdel(controller)

/datum/unit_test/erp_preferences_dead_targets_block_existing_sex_actions
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_dead_targets_block_existing_sex_actions/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	target.death()

	var/datum/sex_scene_controller/session = allocate(/datum/sex_scene_controller, user, target)
	var/datum/sex_action_proposal/proposal = session.create_action_proposal(/datum/sex_action/unit_test_disconnected_erp, "unit_test")
	var/can_perform = proposal.can_start()
	qdel(proposal)

	TEST_ASSERT_EQUAL(can_perform, FALSE, "Existing sex sessions should not perform actions with dead targets.")

/// Going back to the lobby means a new character, so the spawn lock must not follow the player there.
/datum/unit_test/erp_preferences_lobby_lifts_spawn_lock/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.has_spawned = TRUE
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	var/mob/dead/observer/ghost = allocate(/mob/dead/observer)
	var/datum/erp_preference/list_choice/vaginal_tightness/creation_pref = new

	TEST_ASSERT_NULL(prefs.get_erp_preference_edit_lock_reason(lobby), "A player back in the lobby should edit ERP preferences again")
	TEST_ASSERT_NULL(creation_pref.get_edit_lock_reason(lobby, prefs), "Creation-only preferences should be editable again in the lobby")
	TEST_ASSERT_NOTNULL(prefs.get_erp_preference_edit_lock_reason(ghost), "A ghost whose character is still in the round stays locked")
	TEST_ASSERT_NOTNULL(creation_pref.get_edit_lock_reason(ghost, prefs), "A ghost keeps creation-only preferences locked")
	TEST_ASSERT(prefs.has_spawned, "The lobby must not clear has_spawned, which respawn bans read")
