/mob/living/carbon/human/defeat_horny_threshold_test_player
	defeat_system_ai_opt_in = TRUE

/mob/living/carbon/human/defeat_horny_threshold_test_player/horny_defeat_uses_player_stats()
	return TRUE

/mob/living/carbon/human/defeat_horny_threshold_test_player/instant
	horny_defeat_threshold_override = 1

/datum/unit_test/horny_defeat_threshold_formula

/datum/unit_test/horny_defeat_threshold_formula/Run()
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, TRUE, 14, 16), 7, "Player thresholds should be a quarter of Constitution plus Endurance.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, TRUE, 20, 20), 10, "An average body should land on the upper bound.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, TRUE, 1, 1), 5, "Player thresholds should clamp to the lower design bound.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, TRUE, 30, 30), 10, "Player thresholds should clamp to the upper design bound.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, FALSE, 10, 10), 2, "Mob thresholds should derive from one tenth of combined base stats.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, FALSE, 1, 1), 1, "Mob thresholds should clamp to at least one climax.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(0, FALSE, 30, 30), 3, "Mob thresholds should clamp to at most three climaxes.")
	TEST_ASSERT_EQUAL(horny_defeat_threshold_for_stats(2, FALSE, 1, 1), 2, "An explicit creature profile should override the stat fallback.")

/datum/unit_test/horny_defeat_mob_profiles_are_deterministic

/datum/unit_test/horny_defeat_mob_profiles_are_deterministic/Run()
	var/mob/living/carbon/human/aggressor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	goblin.mob_horny_defeat_enabled = TRUE
	var/datum/component/defeat_monitor/goblin_monitor = goblin.AddComponent(/datum/component/defeat_monitor)
	goblin_monitor.on_climax(goblin, null, goblin, aggressor, aggressor)
	TEST_ASSERT_EQUAL(goblin_monitor.horny_defeat_climax_threshold, 1, "A goblin's explicit profile should require one climax.")
	TEST_ASSERT(findtext(goblin_monitor.horny_defeat_climax_threshold_source, "explicit creature profile"), "Goblin progress should explain that its explicit profile won.")

	var/mob/living/simple_animal/hostile/retaliate/minotaur/minotaur = allocate(/mob/living/simple_animal/hostile/retaliate/minotaur)
	minotaur.mob_horny_defeat_enabled = TRUE
	var/datum/component/defeat_monitor/minotaur_monitor = minotaur.AddComponent(/datum/component/defeat_monitor)
	minotaur_monitor.on_climax(minotaur, null, minotaur, aggressor, aggressor)
	TEST_ASSERT_EQUAL(minotaur_monitor.horny_defeat_climax_threshold, 2, "A minotaur's immutable base Constitution and Endurance should require multiple climaxes.")
	TEST_ASSERT(findtext(minotaur_monitor.horny_defeat_climax_threshold_source, "CON 19, END 10"), "Mob progress should report the immutable base stats used by the fallback.")

/datum/unit_test/horny_defeat_player_threshold_caches_until_timeout

/datum/unit_test/horny_defeat_player_threshold_caches_until_timeout/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.mind = allocate(/datum/mind, "horny-threshold-disconnected-player")
	// /datum/mind/Destroy() detaches itself through current, so a mind attached without one leaves
	// the body holding a deleted mind and hard-deletes at the end of the run.
	victim.mind.current = victim
	var/mob/living/carbon/human/aggressor = allocate(/mob/living/carbon/human)
	victim.attributes.raw_attribute_list[STAT_CONSTITUTION] = 14
	victim.attributes.raw_attribute_list[STAT_ENDURANCE] = 16
	victim.attributes.update_attributes()
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)

	monitor.on_climax(victim, null, victim, aggressor, aggressor)
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 7, "The first valid climax should cache the current player-stat threshold.")
	TEST_ASSERT(!victim.has_status_effect(/datum/status_effect/mob_horny_knockout), "A disconnected body with a mind must stay on the player path.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 1, "The first valid climax should record exact progress.")
	TEST_ASSERT(findtext(monitor.horny_defeat_climax_threshold_source, "CON 14, END 16"), "Player progress should explain the encounter-start stats used.")

	victim.attributes.raw_attribute_list[STAT_CONSTITUTION] = 20
	victim.attributes.raw_attribute_list[STAT_ENDURANCE] = 20
	victim.attributes.update_attributes()
	monitor.on_climax(victim, null, victim, aggressor, aggressor)
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 7, "Mid-encounter stat changes must not move the cached threshold.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 2, "A second valid climax should advance the same encounter.")

	monitor.horny_defeat_last_climax_at = world.time - DEFEAT_HORNY_ENCOUNTER_TIMEOUT - 1 SECONDS
	monitor.on_climax(victim, null, victim, aggressor, aggressor)
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 10, "A timeout should start a new encounter from the now-current player stats.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 1, "A timeout should restart exact progress at one.")

/datum/unit_test/horny_defeat_progress_text_is_exact

/datum/unit_test/horny_defeat_progress_text_is_exact/Run()
	var/source_text = "Threshold source: encounter-start stats (CON 14, END 16)."
	TEST_ASSERT_EQUAL( horny_defeat_progress_text(2, 15, source_text), "Horny defeat progress: 2/15. 13 climaxes remaining. [source_text]", "Private progress should expose the exact count, threshold, remaining climaxes, and cached source.")
	TEST_ASSERT_EQUAL(horny_defeat_progress_text(14, 15, source_text), "Horny defeat progress: 14/15. 1 climax remaining. [source_text]", "Singular remaining progress should read naturally.")

/datum/unit_test/horny_defeat_progress_resets_on_both_recovery_paths

/datum/unit_test/horny_defeat_progress_resets_on_both_recovery_paths/Run()
	var/mob/living/carbon/human/aggressor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/defeat_horny_threshold_test_player/instant/player_victim = allocate(/mob/living/carbon/human/defeat_horny_threshold_test_player/instant)
	var/datum/component/defeat_monitor/player_monitor = player_victim.AddComponent(/datum/component/defeat_monitor)
	player_monitor.on_climax(player_victim, null, player_victim, aggressor, aggressor)
	TEST_ASSERT_NOTNULL(player_victim.has_status_effect(/datum/status_effect/defeat_knockout), "A threshold-one player body should enter full horny defeat.")
	TEST_ASSERT_EQUAL(player_monitor.horny_defeat_climax_count, 1, "Full defeat should retain completed progress until recovery.")
	player_victim.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_EQUAL(player_monitor.horny_defeat_climax_count, 0, "Full-defeat recovery should clear completed progress.")
	TEST_ASSERT_EQUAL(player_monitor.horny_defeat_climax_threshold, 0, "Full-defeat recovery should clear the cached threshold.")

	var/mob/living/carbon/human/species/goblin/npc/mob_victim = allocate(/mob/living/carbon/human/species/goblin/npc)
	mob_victim.mob_horny_defeat_enabled = TRUE
	var/datum/component/defeat_monitor/mob_monitor = mob_victim.AddComponent(/datum/component/defeat_monitor)
	mob_monitor.on_climax(mob_victim, null, mob_victim, aggressor, aggressor)
	TEST_ASSERT_NOTNULL(mob_victim.has_status_effect(/datum/status_effect/mob_horny_knockout), "A goblin should enter the lighter mob horny KO.")
	TEST_ASSERT_EQUAL(mob_monitor.horny_defeat_climax_count, 1, "Mob KO should retain completed progress until recovery.")
	mob_victim.remove_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT_EQUAL(mob_monitor.horny_defeat_climax_count, 0, "Mob-KO recovery should clear completed progress.")
	TEST_ASSERT_EQUAL(mob_monitor.horny_defeat_climax_threshold, 0, "Mob-KO recovery should clear the cached threshold.")

/datum/unit_test/horny_defeat_hostility_gate_remains_strict

/datum/unit_test/horny_defeat_hostility_gate_remains_strict/Run()
	TEST_ASSERT(horny_defeat_instigator_counts(FALSE, FALSE), "NPC instigators should still count without combat mode.")
	TEST_ASSERT(!horny_defeat_instigator_counts(TRUE, FALSE), "Consensual player encounters should still be excluded.")
	TEST_ASSERT(horny_defeat_instigator_counts(TRUE, TRUE), "Hostile player encounters should still count.")

	var/mob/living/carbon/human/defeat_horny_threshold_test_player/victim = allocate(/mob/living/carbon/human/defeat_horny_threshold_test_player)
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)
	monitor.on_climax(victim, null, victim, null, null)
	monitor.on_climax(victim, null, victim, victim, victim)
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 0, "Missing and self-generated instigators must not advance progress.")

#ifdef FOCUS_DEFEAT_HORNY_THRESHOLD_TEST
/datum/unit_test/horny_defeat_threshold_formula
	focus = TRUE
/datum/unit_test/horny_defeat_mob_profiles_are_deterministic
	focus = TRUE
/datum/unit_test/horny_defeat_player_threshold_caches_until_timeout
	focus = TRUE
/datum/unit_test/horny_defeat_progress_text_is_exact
	focus = TRUE
/datum/unit_test/horny_defeat_progress_resets_on_both_recovery_paths
	focus = TRUE
/datum/unit_test/horny_defeat_hostility_gate_remains_strict
	focus = TRUE
#endif
