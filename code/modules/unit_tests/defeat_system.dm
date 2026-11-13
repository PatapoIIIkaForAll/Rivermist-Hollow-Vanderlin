/proc/defeat_unit_place_adjacent(mob/living/first, mob/living/second, turf/base_turf)
	var/turf/first_turf = get_step(base_turf, EAST)
	var/turf/second_turf = get_step(first_turf, EAST)
	first.forceMove(first_turf)
	second.forceMove(second_turf)

/datum/defeat_recovery_profile/manual/unit_test_instant

/datum/defeat_recovery_profile/manual/unit_test_instant/recovery_time(datum/defeat_recovery_channel/channel)
	return 0

/datum/defeat_recovery_profile/campfire/unit_test_instant

/datum/defeat_recovery_profile/campfire/unit_test_instant/recovery_time(datum/defeat_recovery_channel/channel)
	return 0

/datum/defeat_recovery_profile/campfire/tended/unit_test_instant

/datum/defeat_recovery_profile/campfire/tended/unit_test_instant/recovery_time(datum/defeat_recovery_channel/channel)
	return 0

/datum/defeat_trauma_provider/medical/machine/unit_test_interrupted

/datum/defeat_trauma_provider/medical/machine/unit_test_interrupted/perform_treatment_delay(mob/living/patient, mob/living/helper, datum/status_effect/debuff/defeat/target)
	return FALSE

/datum/defeat_trauma_provider/medical/machine/unit_test_resource_deleted

/datum/defeat_trauma_provider/medical/machine/unit_test_resource_deleted/perform_treatment_delay(mob/living/patient, mob/living/helper, datum/status_effect/debuff/defeat/target)
	qdel(helper.get_active_held_item())
	return TRUE

/datum/defeat_recovery_resource_tracker
	var/reservations = 0
	var/consumptions = 0
	var/releases = 0

/datum/defeat_recovery_profile/unit_test_resources
	apply_snapshot_aftermath = FALSE

/datum/defeat_recovery_profile/unit_test_resources/reserve_resources(datum/defeat_recovery_channel/channel)
	var/datum/defeat_recovery_resource_tracker/tracker = channel.resolve_source()
	if(!tracker)
		return FALSE
	tracker.reservations++
	return TRUE

/datum/defeat_recovery_profile/unit_test_resources/consume_resources(datum/defeat_recovery_channel/channel)
	var/datum/defeat_recovery_resource_tracker/tracker = channel.resolve_source()
	if(!tracker)
		return FALSE
	tracker.consumptions++
	return TRUE

/datum/defeat_recovery_profile/unit_test_resources/release_resources(datum/defeat_recovery_channel/channel)
	var/datum/defeat_recovery_resource_tracker/tracker = channel.resolve_source()
	if(!tracker)
		return FALSE
	tracker.releases++
	return TRUE

/datum/unit_test/defeat_preferences_defaults_and_sanitize

/datum/unit_test/defeat_preferences_defaults_and_sanitize/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)

	TEST_ASSERT_EQUAL(prefs.get_defeat_mode(), DEFEAT_MODE_KO_RUNE, "Defeat mode should default to knockout plus rune.")
	TEST_ASSERT_EQUAL(prefs.get_defeat_damage_threshold(), DEFEAT_DAMAGE_THRESHOLD_DEFAULT, "Defeat damage threshold should default to the conservative baseline.")

	prefs.set_defeat_mode(DEFEAT_MODE_NO_RETURN)
	TEST_ASSERT_EQUAL(prefs.get_defeat_mode(), DEFEAT_MODE_NO_RETURN, "No Return must be a valid explicit opt-out.")

	prefs.set_defeat_mode("bad-mode")
	TEST_ASSERT_EQUAL(prefs.get_defeat_mode(), DEFEAT_MODE_KO_RUNE, "Invalid defeat modes should sanitize back to the default.")

	prefs.set_defeat_damage_threshold(250)
	TEST_ASSERT_EQUAL(prefs.get_defeat_damage_threshold(), 250, "Listed threshold choices should be accepted.")

	prefs.set_defeat_damage_threshold(999)
	TEST_ASSERT_EQUAL(prefs.get_defeat_damage_threshold(), DEFEAT_DAMAGE_THRESHOLD_DEFAULT, "Unlisted threshold choices should sanitize back to the default.")

/datum/unit_test/defeat_monitor_eligibility_respects_player_and_opt_in_ai

/datum/unit_test/defeat_monitor_eligibility_respects_player_and_opt_in_ai/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	TEST_ASSERT(!monitor.is_defeat_eligible(), "Clientless, mindless humans should not be defeat-monitored by default.")

	test_human.defeat_system_ai_opt_in = TRUE
	TEST_ASSERT(monitor.is_defeat_eligible(), "Explicit opt-in bodies should be eligible even without a player client.")

	test_human.defeat_system_ai_opt_in = FALSE
	test_human.mind = allocate(/datum/mind, "defeat-test-mind")
	test_human.mind.current = test_human
	TEST_ASSERT(monitor.is_defeat_eligible(), "Player minds should be eligible for defeat monitoring.")
	test_human.mind.current = null
	test_human.mind = null

/datum/unit_test/defeat_snapshot_records_damage_and_worst_injury

/datum/unit_test/defeat_snapshot_records_damage_and_worst_injury/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.setToxLoss(200, FALSE, TRUE)
	var/obj/item/bodypart/chest = test_human.get_bodypart(BODY_ZONE_CHEST)
	chest.create_injury(WOUND_SLASH, 15, TRUE)
	var/obj/item/bodypart/head = test_human.get_bodypart(BODY_ZONE_HEAD)
	head.create_injury(WOUND_BLUNT, 40, TRUE)

	var/datum/defeat_snapshot/snapshot = new
	snapshot.capture_from(test_human, DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT_EQUAL(snapshot.reason, DEFEAT_REASON_DAMAGE, "The snapshot should preserve the defeat reason.")
	TEST_ASSERT_EQUAL(snapshot.severity, DEFEAT_SEVERITY_NORMAL, "The snapshot should preserve the defeat severity.")
	TEST_ASSERT_EQUAL(snapshot.tox_loss, test_human.getToxLoss(), "The snapshot should preserve major damage totals before stabilization.")
	TEST_ASSERT_EQUAL(snapshot.worst_body_zone, BODY_ZONE_HEAD, "The snapshot should prefer the highest-damage injury bodypart.")
	TEST_ASSERT_EQUAL(snapshot.worst_injury_type, WOUND_BLUNT, "The snapshot should preserve the worst injury type for aftermath mapping.")

/datum/unit_test/defeat_stabilization_preserves_bounded_injuries_after_snapshot

/datum/unit_test/defeat_stabilization_preserves_bounded_injuries_after_snapshot/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	var/obj/item/bodypart/chest = test_human.get_bodypart(BODY_ZONE_CHEST)
	var/datum/injury/bleeding_cut = chest.create_injury(WOUND_SLASH, 5)
	bleeding_cut.bleed_timer = 30

	TEST_ASSERT(length(test_human.all_injuries), "The setup should create active injury data before defeat.")
	TEST_ASSERT(bleeding_cut.is_bleeding(), "The setup should make the preserved cut actively bleed.")
	TEST_ASSERT(test_human.defeat_stabilize_active_injuries(FALSE), "The dedicated defeat injury stabilizer should report that it suppressed active bleeding.")
	TEST_ASSERT(length(test_human.all_injuries), "Bounded stabilization should preserve ordinary injury datums for later treatment.")
	TEST_ASSERT_EQUAL(test_human.get_bleed_rate(), 0, "Bounded stabilization must stop active bleeding before recovery.")

	chest.create_injury(WOUND_PIERCE, 50, TRUE)
	test_human.setToxLoss(250, FALSE, TRUE)
	TEST_ASSERT(test_human.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL), "Eligible damage should enter defeat.")
	TEST_ASSERT_EQUAL(test_human.last_defeat_snapshot.worst_injury_type, WOUND_PIERCE, "Defeat should capture the worst injury before stabilizing it.")
	TEST_ASSERT(length(test_human.all_injuries), "Defeat stabilization should retain live injury datums after snapshot capture.")
	var/bounded_major_damage = test_human.getBruteLoss() + test_human.getFireLoss() + test_human.getToxLoss() + test_human.getCloneLoss()
	TEST_ASSERT(bounded_major_damage <= test_human.defeat_damage_safety_cap(), "Defeat stabilization should cap aggregate major damage below the immediate re-defeat boundary.")
	TEST_ASSERT_EQUAL(test_human.get_bleed_rate(), 0, "Defeat stabilization should keep preserved injuries from bleeding while the victim is down.")

/datum/unit_test/defeat_death_signal_is_conservative_fallback

/datum/unit_test/defeat_death_signal_is_conservative_fallback/Run()
	var/mob/living/carbon/human/normal_dead = allocate(/mob/living/carbon/human)
	normal_dead.defeat_system_ai_opt_in = TRUE
	normal_dead.stat = DEAD
	var/datum/component/defeat_monitor/normal_monitor = normal_dead.AddComponent(/datum/component/defeat_monitor)

	normal_monitor.on_death(normal_dead)
	TEST_ASSERT_NULL(normal_dead.has_status_effect(/datum/status_effect/defeat_knockout), "Ordinary completed death should not be converted into defeat KO by the death signal fallback.")
	TEST_ASSERT_NULL(normal_dead.last_defeat_snapshot, "Ordinary completed death should not capture a defeat snapshot in the death signal fallback.")

/datum/unit_test/defeat_health_signal_preempts_death_finalization

/datum/unit_test/defeat_health_signal_preempts_death_finalization/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.defeat_damage_threshold = 300
	victim.AddComponent(/datum/component/defeat_monitor)
	victim.setToxLoss(victim.maxHealth - HEALTH_THRESHOLD_DEAD, FALSE, TRUE)

	victim.updatehealth()
	TEST_ASSERT(victim.stat != DEAD, "The health signal must offer lethal damage to Defeat before update_stat() finalizes death.")
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "The lethal health update should enter Defeat on its authoritative signal path.")
	TEST_ASSERT_EQUAL(victim.last_defeat_snapshot.reason, DEFEAT_REASON_DEATH, "A lethal health update should preserve the death-class snapshot reason.")

/datum/unit_test/defeat_monitor_uses_only_health_signal_for_damage

/datum/unit_test/defeat_monitor_uses_only_health_signal_for_damage/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.defeat_damage_threshold = 100
	victim.AddComponent(/datum/component/defeat_monitor)
	victim.setToxLoss(100, FALSE, TRUE)

	SEND_SIGNAL(victim, COMSIG_LIVING_LIFE, SSMOBS_DT, 1)
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Life signals must not duplicate the authoritative damage-defeat check.")
	SEND_SIGNAL(victim, COMSIG_LIVING_HEALTH_UPDATE)
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "The health signal should be the single normal Defeat evaluation path.")

/datum/unit_test/defeat_damage_threshold_edges

/datum/unit_test/defeat_damage_threshold_edges/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_mode = DEFEAT_MODE_KO_RUNE
	test_human.defeat_damage_threshold = 200
	test_human.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	test_human.setToxLoss(199)
	monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Damage below the selected threshold should not trigger defeat.")

	test_human.setToxLoss(200)
	monitor.check_defeat_triggers()
	TEST_ASSERT_NOTNULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Damage at the selected threshold should trigger defeat.")
	TEST_ASSERT_NOTNULL(test_human.last_defeat_snapshot, "Damage defeat should capture a snapshot before stabilization.")
	TEST_ASSERT_EQUAL(test_human.last_defeat_snapshot.tox_loss, 200, "The snapshot should retain the threshold-crossing damage.")
	TEST_ASSERT(test_human.getToxLoss() < 200, "Live toxin damage should be bounded rather than fully erased after defeat.")
	TEST_ASSERT(test_human.getToxLoss() <= test_human.defeat_damage_safety_cap() * DEFEAT_DAMAGE_POOL_CAP_FRACTION, "Each scalar damage pool should remain below its configured safety cap.")

/datum/unit_test/defeat_damage_threshold_uses_total_damage

/datum/unit_test/defeat_damage_threshold_uses_total_damage/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	test_human.defeat_damage_threshold = 150
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	// Neither pool reaches 150 on its own (so the old max-pool rule would NOT fire), but together
	// they total 160 after DEFEAT_BURN_DAMAGE_WEIGHT - the threshold is total damage, so defeat triggers.
	test_human.setBruteLoss(100, FALSE, TRUE)
	test_human.setFireLoss(100, FALSE, TRUE)
	test_human.updatehealth()
	monitor.check_defeat_triggers()
	TEST_ASSERT_NOTNULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Combined damage across pools should trigger defeat even when no single pool hits the threshold.")
	TEST_ASSERT_EQUAL(test_human.last_defeat_snapshot.reason, DEFEAT_REASON_DAMAGE, "Total-damage defeat should be recorded as a damage defeat, not death.")

/datum/unit_test/defeat_oxygen_has_separate_threshold

/datum/unit_test/defeat_oxygen_has_separate_threshold/Run()
	// Oxygen is excluded from the pooled beatdown threshold: a fall's oxy spike alongside minor damage
	// must not tap you out. Brute 40 + oxy 90 would have summed to 130 >= 100 under the old pooled rule.
	var/mob/living/carbon/human/faller = allocate(/mob/living/carbon/human)
	faller.defeat_system_ai_opt_in = TRUE
	faller.defeat_damage_threshold = 100
	var/datum/component/defeat_monitor/faller_monitor = faller.AddComponent(/datum/component/defeat_monitor)
	faller.setBruteLoss(40, FALSE, TRUE)
	faller.setOxyLoss(90, FALSE, TRUE)
	faller.updatehealth()
	faller_monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(faller.has_status_effect(/datum/status_effect/defeat_knockout), "Oxygen below its own bar must not count toward the pooled threshold, so a survivable fall does not KO.")

	// At the near-lethal oxygen bar it downs you on its own, even though the pooled damage is nowhere near.
	var/mob/living/carbon/human/suffocator = allocate(/mob/living/carbon/human)
	suffocator.defeat_system_ai_opt_in = TRUE
	suffocator.defeat_damage_threshold = 200
	var/datum/component/defeat_monitor/suffocator_monitor = suffocator.AddComponent(/datum/component/defeat_monitor)
	suffocator.setOxyLoss(DEFEAT_OXY_THRESHOLD, FALSE, TRUE)
	suffocator.updatehealth()
	suffocator_monitor.check_defeat_triggers()
	TEST_ASSERT_NOTNULL(suffocator.has_status_effect(/datum/status_effect/defeat_knockout), "Oxygen at the kill-limit bar should trigger defeat on its own.")
	TEST_ASSERT_EQUAL(suffocator.last_defeat_snapshot.reason, DEFEAT_REASON_DEATH, "An oxygen defeat is recorded as a death-class defeat.")

/datum/unit_test/defeat_near_death_covers_blood_loss

/datum/unit_test/defeat_near_death_covers_blood_loss/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!test_human.defeat_is_near_death(), "A healthy mob should not read as near death.")
	test_human.blood_volume = BLOOD_VOLUME_SURVIVE
	TEST_ASSERT(test_human.defeat_is_near_death(), "Bleeding to the survive floor should read as near death (the real brute/burn death path).")
	test_human.blood_volume = BLOOD_VOLUME_NORMAL
	TEST_ASSERT(!test_human.defeat_is_near_death(), "Restored blood should clear the near-death state.")

/datum/unit_test/defeat_shock_does_not_trigger_knockout

/datum/unit_test/defeat_shock_does_not_trigger_knockout/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	test_human.setShockStage(SHOCK_STAGE_6, FALSE, TRUE)
	monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Stage 6 shock alone must not trigger Defeat.")

	monitor.shock_defeat_started_at = world.time - DEFEAT_SHOCK_SUSTAIN_DURATION
	monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Sustained shock must not trigger Defeat even with an elapsed shock window.")
	TEST_ASSERT_NULL(test_human.last_defeat_snapshot, "Shock alone must not capture a defeat snapshot.")
	TEST_ASSERT_EQUAL(monitor.shock_warning_last_at, 0, "Disabled shock defeat must not emit its warning.")

	var/mob/living/carbon/human/hard_shock_human = allocate(/mob/living/carbon/human)
	hard_shock_human.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/hard_monitor = hard_shock_human.AddComponent(/datum/component/defeat_monitor)
	hard_shock_human.setShockStage(SHOCK_STAGE_8, FALSE, TRUE)
	hard_monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(hard_shock_human.has_status_effect(/datum/status_effect/defeat_knockout), "Stage 8 shock alone must not trigger Defeat.")
	TEST_ASSERT_EQUAL(hard_monitor.shock_warning_last_at, 0, "Extreme shock must not emit a defeat warning.")
	hard_shock_human.setToxLoss(hard_shock_human.get_effective_defeat_threshold(), FALSE, TRUE)
	hard_shock_human.updatehealth()
	TEST_ASSERT_NOTNULL(hard_shock_human.has_status_effect(/datum/status_effect/defeat_knockout), "Disabling shock defeat must not disable injury defeat.")
	TEST_ASSERT_EQUAL(hard_shock_human.last_defeat_snapshot.reason, DEFEAT_REASON_DAMAGE, "Injury defeat must retain its damage reason even at extreme shock.")

/datum/unit_test/defeat_no_return_bypasses_new_routing

/datum/unit_test/defeat_no_return_bypasses_new_routing/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_mode = DEFEAT_MODE_NO_RETURN
	test_human.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	test_human.setBruteLoss(300, FALSE, TRUE)
	monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "No Return should bypass defeat KO routing even if a monitor is present.")
	TEST_ASSERT_NULL(test_human.last_defeat_snapshot, "No Return should not generate a defeat snapshot.")

/datum/unit_test/defeat_death_threshold_uses_death_reason

/datum/unit_test/defeat_death_threshold_uses_death_reason/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	test_human.defeat_damage_threshold = 300
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	test_human.set_health(HEALTH_THRESHOLD_DEAD)
	monitor.check_defeat_triggers()
	TEST_ASSERT_NOTNULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Lethal health should trigger defeat even when no single damage category reaches the selected threshold.")
	TEST_ASSERT_EQUAL(test_human.last_defeat_snapshot.reason, DEFEAT_REASON_DEATH, "Lethal health defeat should be captured as death defeat.")
	TEST_ASSERT_EQUAL(test_human.last_defeat_snapshot.severity, DEFEAT_SEVERITY_SEVERE, "Lethal health defeat should be severe.")

/datum/unit_test/defeat_ko_only_hazard_can_emergency_rune

/datum/unit_test/defeat_ko_only_hazard_can_emergency_rune/Run()
	var/turf/original_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/original_turf_type = original_turf.type
	var/list/original_baseturfs = original_turf.baseturfs
	var/turf/lava_turf = original_turf.ChangeTurf(/turf/open/lava)
	var/obj/structure/resurrection_rune/test_rune = allocate(/obj/structure/resurrection_rune, get_step(lava_turf, EAST))
	test_rune.rune_tag = "defeat_unit_hazard_[world.time]"
	var/datum/resurrection_rune_controller/controller = test_rune.resrunecontroler
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human, lava_turf)
	test_human.defeat_system_ai_opt_in = TRUE
	test_human.defeat_mode = DEFEAT_MODE_KO_ONLY
	test_human.mind = allocate(/datum/mind, "defeat-hazard-rune-user")
	test_human.mind.current = test_human
	controller.add_user(test_human)
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	monitor.check_defeat_triggers()
	controller.handle_linked_user_update(test_human)
	var/has_defeat_knockout = test_human.has_status_effect(/datum/status_effect/defeat_knockout)
	var/defeat_reason = test_human.last_defeat_snapshot?.reason
	var/queued_for_resurrection = (test_human in controller.resurrecting)

	test_human.mind.current = null
	test_human.mind = null
	lava_turf.ChangeTurf(original_turf_type, original_baseturfs)

	TEST_ASSERT_NOTNULL(has_defeat_knockout, "KO Only should still enter defeat before a live linked rune emergency hazard rescue.")
	TEST_ASSERT_EQUAL(defeat_reason, DEFEAT_REASON_HAZARD, "Immediate rune hazards should preserve the hazard defeat reason.")
	TEST_ASSERT(queued_for_resurrection, "Immediate hazards should queue emergency rune rescue even for KO Only users.")

/datum/unit_test/defeat_unlinked_ko_rune_gets_emergency_link

/datum/unit_test/defeat_unlinked_ko_rune_gets_emergency_link/Run()
	var/turf/rune_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/structure/resurrection_rune/city_rune = allocate(/obj/structure/resurrection_rune, rune_turf)
	city_rune.rune_tag = RUNE_LINK_CITY

	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_mode = DEFEAT_MODE_KO_RUNE
	test_human.rune_linked = RUNE_LINK_NONE
	test_human.mind = allocate(/datum/mind, "defeat-emergency-link-user")
	test_human.mind.current = test_human

	TEST_ASSERT_NULL(get_resurrection_rune_controller_for_user(test_human), "Setup: the user should start with no rune link.")
	TEST_ASSERT(test_human.defeat_ensure_emergency_rune_link(), "An unlinked KO+Rune user should receive an emergency link on defeat.")
	TEST_ASSERT_NOTNULL(get_resurrection_rune_controller_for_user(test_human), "After the emergency link the user should resolve to a live rune controller.")
	TEST_ASSERT_EQUAL(test_human.rune_linked, RUNE_LINK_CITY, "The emergency bond should link to the public city rune.")
	TEST_ASSERT(!test_human.defeat_ensure_emergency_rune_link(), "A user already tied to a rune should not be re-linked.")

	// KO Only users opted out of the rune entirely - they never get an emergency bond.
	var/mob/living/carbon/human/ko_only = allocate(/mob/living/carbon/human)
	ko_only.defeat_mode = DEFEAT_MODE_KO_ONLY
	ko_only.rune_linked = RUNE_LINK_NONE
	ko_only.mind = allocate(/datum/mind, "defeat-emergency-link-koonly")
	ko_only.mind.current = ko_only
	TEST_ASSERT(!ko_only.defeat_ensure_emergency_rune_link(), "A KO Only user should never receive an emergency rune bond.")

	test_human.mind.current = null
	test_human.mind = null
	ko_only.mind.current = null
	ko_only.mind = null

/datum/unit_test/defeat_ko_only_pref_severs_roundstart_rune_link

/datum/unit_test/defeat_ko_only_pref_severs_roundstart_rune_link/Run()
	var/turf/rune_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/structure/resurrection_rune/city_rune = allocate(/obj/structure/resurrection_rune, rune_turf)
	city_rune.rune_tag = RUNE_LINK_CITY

	// A KO Only character who got auto-linked anyway - the job link runs on its own path, so
	// pref/link ordering at roundstart is unreliable and the enforcement must clean up after it.
	var/mob/living/carbon/human/ko_only = allocate(/mob/living/carbon/human)
	ko_only.defeat_mode = DEFEAT_MODE_KO_ONLY
	ko_only.mind = allocate(/datum/mind, "defeat-ko-only-unlink")
	ko_only.mind.current = ko_only
	TEST_ASSERT(city_rune.resrunecontroler.add_user(ko_only), "Setup: the rune should accept the user like a roundstart auto-link would.")
	TEST_ASSERT_NOTNULL(get_resurrection_rune_controller_for_user(ko_only), "Setup: the user should resolve to the rune controller while linked.")

	TEST_ASSERT(ko_only.defeat_enforce_ko_only_rune_optout(), "KO Only enforcement should sever an existing rune link.")
	TEST_ASSERT_NULL(get_resurrection_rune_controller_for_user(ko_only), "After enforcement the user must not resolve to any rune controller.")
	TEST_ASSERT_EQUAL(ko_only.rune_linked, RUNE_LINK_NONE, "After enforcement the rune tag must be cleared.")
	TEST_ASSERT(!(ko_only.mind in city_rune.resrunecontroler.linked_users_minds), "After enforcement the mind must not remain in the controller's user list.")
	TEST_ASSERT(!ko_only.defeat_has_rune_safety_net(), "A severed KO Only user must not count as rune-protected.")

	// The job auto-link itself now refuses KO Only characters outright.
	var/datum/job/generic_job = allocate(/datum/job)
	TEST_ASSERT(!generic_job.try_auto_link_resurrection_rune(ko_only), "The job auto-link must skip KO Only characters.")
	TEST_ASSERT_NULL(get_resurrection_rune_controller_for_user(ko_only), "The refused auto-link must leave the user unlinked.")

	// Other modes pass through the enforcement untouched.
	var/mob/living/carbon/human/rune_user = allocate(/mob/living/carbon/human)
	rune_user.defeat_mode = DEFEAT_MODE_KO_RUNE
	rune_user.mind = allocate(/datum/mind, "defeat-ko-rune-keeps-link")
	rune_user.mind.current = rune_user
	TEST_ASSERT(city_rune.resrunecontroler.add_user(rune_user), "Setup: a KO+Rune user should link normally.")
	TEST_ASSERT(!rune_user.defeat_enforce_ko_only_rune_optout(), "Enforcement must be a no-op for KO+Rune users.")
	TEST_ASSERT_NOTNULL(get_resurrection_rune_controller_for_user(rune_user), "A KO+Rune user must keep their link.")

	ko_only.mind.current = null
	ko_only.mind = null
	rune_user.mind.current = null
	rune_user.mind = null

/datum/unit_test/defeat_knockout_traits_are_custom

/datum/unit_test/defeat_knockout_traits_are_custom/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	test_human.setBruteLoss(200, FALSE, TRUE)

	TEST_ASSERT(test_human.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL), "Eligible damage should enter defeat. eligible=[test_human.defeat_system_is_eligible()] stat=[test_human.stat] brute=[test_human.getBruteLoss()] health=[test_human.health]")
	TEST_ASSERT_NOTNULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Defeat should apply the custom KO status.")
	TEST_ASSERT(HAS_TRAIT(test_human, TRAIT_NODEATH), "Defeat KO should protect against normal death.")
	TEST_ASSERT(HAS_TRAIT(test_human, TRAIT_PACIFISM), "Defeat KO should pacify hostile actions.")
	TEST_ASSERT(HAS_TRAIT(test_human, TRAIT_IMMOBILIZED), "Defeat KO should block movement.")
	TEST_ASSERT(HAS_TRAIT(test_human, TRAIT_HANDS_BLOCKED), "Defeat KO should block normal item combat.")
	TEST_ASSERT(!HAS_TRAIT(test_human, TRAIT_KNOCKEDOUT), "Defeat KO must not use normal unconsciousness.")
	TEST_ASSERT(test_human.stat != DEAD, "Defeat KO should not make the mob dead.")

/datum/unit_test/defeat_knockout_has_alert_and_overlay_feedback

/datum/unit_test/defeat_knockout_has_alert_and_overlay_feedback/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE

	TEST_ASSERT(test_human.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL), "Eligible damage should enter defeat.")
	var/datum/status_effect/defeat_knockout/knockout = test_human.has_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NOTNULL(knockout, "Defeat should apply the custom KO status.")
	TEST_ASSERT_NOTNULL(knockout.alert_type, "Defeat KO should expose a status alert.")
	TEST_ASSERT_NOTNULL(test_human.screens["defeat"], "Defeat KO should apply a limited-vision fullscreen overlay.")

	test_human.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NULL(test_human.screens["defeat"], "Removing defeat KO should clear the fullscreen overlay.")

/datum/unit_test/defeat_collapse_texts_differ_per_track

/datum/unit_test/defeat_collapse_texts_differ_per_track/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	TEST_ASSERT(test_human.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL), "Eligible damage should enter defeat.")
	var/datum/status_effect/defeat_knockout/knockout = test_human.has_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NOTNULL(knockout, "Defeat should apply the custom KO status.")

	// Every track must produce a complete, unique moment-of-collapse message set.
	var/list/seen_self_texts = list()
	for(var/reason in list(DEFEAT_REASON_DAMAGE, DEFEAT_REASON_PAIN, DEFEAT_REASON_HAZARD, DEFEAT_REASON_DEATH, DEFEAT_REASON_HORNY))
		var/list/texts = knockout.defeat_collapse_texts(reason)
		TEST_ASSERT(length(texts["self"]) && length(texts["visible"]) && length(texts["balloon"]), "Track [reason] must fill self/visible/balloon collapse texts.")
		TEST_ASSERT(!(texts["self"] in seen_self_texts), "Track [reason] must not reuse another track's collapse text.")
		seen_self_texts += texts["self"]

	// The near-death track tells its sub-causes apart from the body's live state: bleeding out
	// (blood at the survival floor) must read differently from the plain health-floor collapse.
	var/fading_text = knockout.defeat_collapse_texts(DEFEAT_REASON_DEATH)["self"]
	test_human.blood_volume = BLOOD_VOLUME_SURVIVE
	var/bled_text = knockout.defeat_collapse_texts(DEFEAT_REASON_DEATH)["self"]
	TEST_ASSERT(bled_text != fading_text, "A bleed-out collapse must read differently from a plain near-death collapse.")

/datum/unit_test/defeat_shock_warning_feedback_is_throttled

/datum/unit_test/defeat_shock_warning_feedback_is_throttled/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/monitor = test_human.AddComponent(/datum/component/defeat_monitor)

	TEST_ASSERT(monitor.maybe_warn_shock_defeat(DEFEAT_SHOCK_WARNING_STAGE), "Shock warning stage should produce an initial warning.")
	TEST_ASSERT(!monitor.maybe_warn_shock_defeat(DEFEAT_SHOCK_WARNING_STAGE), "Shock warnings should be throttled during their cooldown.")
	monitor.shock_warning_last_at = world.time - DEFEAT_SHOCK_WARNING_COOLDOWN
	TEST_ASSERT(monitor.maybe_warn_shock_defeat(DEFEAT_SHOCK_WARNING_STAGE), "Shock warning should fire again after the cooldown.")

/datum/unit_test/defeat_rescue_applies_aftermath_debuff

/datum/unit_test/defeat_rescue_applies_aftermath_debuff/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, helper, run_loc_floor_bottom_left)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT(victim.begin_defeat_recovery(/datum/defeat_recovery_profile/manual/unit_test_instant, helper, "manual unit test"), "An eligible helper should complete the manual recovery channel.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Rescue should clear the defeat KO status.")
	TEST_ASSERT(victim.has_any_defeat_physical_trauma(), "Damage defeat should leave physical trauma after rescue.")

/datum/unit_test/defeat_rescue_allows_inactive_recent_attacker

/datum/unit_test/defeat_rescue_allows_inactive_recent_attacker/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, attacker, run_loc_floor_bottom_left)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL, attacker)
	victim.recent_damage_source_attacker_weakref = WEAKREF(attacker)
	victim.recent_damage_source_time = world.time - DEFEAT_ACTIVE_HARM_WINDOW - 1

	TEST_ASSERT(victim.defeat_can_be_rescued_by(attacker), "A recent attacker should become eligible to rescue once active harm has stopped.")
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Eligibility checks must not bypass the manual recovery channel.")

/datum/unit_test/defeat_rescue_blocks_active_harm

/datum/unit_test/defeat_rescue_blocks_active_harm/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, attacker, run_loc_floor_bottom_left)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL, attacker)
	victim.recent_damage_source_attacker_weakref = WEAKREF(attacker)
	victim.recent_damage_source_time = world.time

	TEST_ASSERT(!victim.defeat_rescue(attacker), "Very recent direct harm should block rescues.")
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Blocked rescues should leave defeat KO in place.")

	victim.recent_damage_source_time = world.time - DEFEAT_ACTIVE_HARM_WINDOW - 1
	attacker.pulling = victim
	attacker.grab_state = GRAB_AGGRESSIVE
	TEST_ASSERT(!victim.defeat_rescue(attacker), "Active aggressive grabs should block rescues.")

/datum/unit_test/defeat_healing_uses_explicit_recovery_profiles

/datum/unit_test/defeat_healing_uses_explicit_recovery_profiles/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, helper, run_loc_floor_bottom_left)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT(victim.defeat_stabilize_from_healing(helper, "bandage"), "A bandage should run the non-waking stabilization path.")
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Stabilization alone should leave KO in place.")
	TEST_ASSERT(victim.defeat_try_prepared_recovery(helper, "prepared medicine"), "A completed prepared treatment should use the prepared recovery profile.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Prepared recovery should clear Defeat KO through the finalizer.")

/datum/unit_test/defeat_treatment_clears_correct_trauma

/datum/unit_test/defeat_treatment_clears_correct_trauma/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/priest = allocate(/mob/living/carbon/human)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_NORMAL)

	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	TEST_ASSERT(patient.defeat_treat_trauma(doctor, DEFEAT_TREATMENT_MEDICAL), "A medically trained helper should clear one physical trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical), "Medical treatment should deterministically clear the first diagnosed physical trauma.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/pain), "One medical treatment must leave a second physical trauma in place.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/rune), "Medical treatment should not clear rune trauma.")
	TEST_ASSERT(patient.defeat_treat_trauma(doctor, DEFEAT_TREATMENT_MEDICAL), "A second medical treatment should clear the remaining physical trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/pain), "The second medical treatment should clear the remaining pain trauma.")

	ADD_TRAIT(priest, TRAIT_HOLY, TRAIT_GENERIC)
	TEST_ASSERT(patient.defeat_treat_trauma(priest, DEFEAT_TREATMENT_SPIRITUAL), "A priestly helper should clear rune trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/rune), "Spiritual treatment should clear rune trauma.")

/datum/unit_test/defeat_tool_treatment_clears_matching_trauma_only

/datum/unit_test/defeat_tool_treatment_clears_matching_trauma_only/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/burn, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain, null, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT(patient.defeat_treat_tool_physical_trauma(doctor, list(/datum/status_effect/debuff/defeat/physical/wound)), "Qualified wound care should clear wound trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/wound), "Wound care should remove wound trauma.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/burn), "Wound care should not remove burn trauma.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/pain), "Wound care should not remove pain trauma.")

/datum/unit_test/defeat_universal_treatment_and_priest_spell_surface

/datum/unit_test/defeat_universal_treatment_and_priest_spell_surface/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT(patient.defeat_treat_trauma(patient, DEFEAT_TREATMENT_UNIVERSAL), "Universal defeat treatment should clear one trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/pain), "Universal treatment should clear the highest-priority matching trauma.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/rune), "Universal treatment should clear only one trauma at a time.")

	var/datum/devotion/devotion = allocate(/datum/devotion)
	devotion.make_priest()
	TEST_ASSERT(!(/datum/action/cooldown/spell/defeat_absolution in devotion.miracles_extra), "The rare burden prayer must not be a default priest grant.")
	var/obj/item/book/granter/spell/magick/bear_burden/prayer = allocate(/obj/item/book/granter/spell/magick/bear_burden)
	TEST_ASSERT_EQUAL(prayer.spell, /datum/action/cooldown/spell/defeat_absolution, "The rare prayer must teach the field treatment spell.")

	var/datum/container_craft/cooking/herbal_tea/mercy_draught/recipe = allocate(/datum/container_craft/cooking/herbal_tea/mercy_draught)
	TEST_ASSERT_EQUAL(recipe.created_reagent, /datum/reagent/medicine/herbal/mercy_draught, "Mercy Draught recipe should create the universal trauma-clearing reagent.")

/datum/unit_test/defeat_trauma_provider_diagnosis_is_deterministic

/datum/unit_test/defeat_trauma_provider_diagnosis_is_deterministic/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/battered = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/status_effect/debuff/defeat/pain = patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/defeat_trauma_provider/medical/provider = allocate(/datum/defeat_trauma_provider/medical/compatibility)

	var/list/diagnosed = provider.diagnose(patient)
	TEST_ASSERT_EQUAL(length(diagnosed), 2, "Medical diagnosis should return only its two compatible physical traumas.")
	TEST_ASSERT(diagnosed[1] == battered, "Automatic diagnosis should sort exact trauma datums by their player-facing label.")
	TEST_ASSERT(provider.select_target(patient, doctor, null, FALSE) == battered, "Noninteractive treatment should deterministically select the first diagnosis.")
	TEST_ASSERT(provider.select_target(patient, doctor, pain, FALSE) == pain, "An explicitly selected compatible trauma datum should be preserved exactly.")

/datum/unit_test/defeat_trauma_provider_costs_only_on_success

/datum/unit_test/defeat_trauma_provider_costs_only_on_success/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(patient, doctor, run_loc_floor_bottom_left)
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	var/datum/status_effect/debuff/defeat/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_NORMAL)
	var/obj/item/natural/bundle/cloth/bandage/bandages = allocate(/obj/item/natural/bundle/cloth/bandage/full)
	doctor.put_in_active_hand(bandages)
	var/datum/defeat_trauma_provider/medical/machine/provider = allocate(/datum/defeat_trauma_provider/medical/machine)

	TEST_ASSERT_EQUAL(provider.resource_cost_for(trauma), 2, "Normal trauma should cost two treatment resources.")
	TEST_ASSERT(provider.treat(patient, doctor, trauma, FALSE, TRUE, bandages), "A valid reserved bandage roll should pay for a completed treatment.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/wound), "Successful resource-backed treatment should remove its exact trauma.")
	TEST_ASSERT_EQUAL(bandages.amount, 2, "A successful normal treatment should consume exactly two bandages from the held roll.")

/datum/unit_test/defeat_trauma_provider_interruption_has_no_cost

/datum/unit_test/defeat_trauma_provider_interruption_has_no_cost/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(patient, doctor, run_loc_floor_bottom_left)
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	var/datum/status_effect/debuff/defeat/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_SEVERE)
	var/obj/item/natural/bundle/cloth/bandage/bandages = allocate(/obj/item/natural/bundle/cloth/bandage/full)
	doctor.put_in_active_hand(bandages)
	var/datum/defeat_trauma_provider/medical/machine/unit_test_interrupted/provider = allocate(/datum/defeat_trauma_provider/medical/machine/unit_test_interrupted)

	TEST_ASSERT_EQUAL(provider.resource_cost_for(trauma), 3, "Severe trauma should cost three treatment resources.")
	TEST_ASSERT(!provider.treat(patient, doctor, trauma, FALSE, FALSE, bandages), "An interrupted treatment should fail before payment.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/wound), "Interrupted treatment must leave the selected trauma in place.")
	TEST_ASSERT_EQUAL(bandages.amount, 4, "Interrupted treatment must not consume any reserved bandages.")

/datum/unit_test/defeat_trauma_provider_discloses_full_treatment

/datum/unit_test/defeat_trauma_provider_discloses_full_treatment/Run()
	var/turf/provider_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/defeat_medical_machine/machine = allocate(/obj/machinery/defeat_medical_machine, provider_turf)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(provider_turf, EAST))
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human, get_step(provider_turf, NORTH))
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	var/datum/status_effect/debuff/defeat/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_NORMAL)
	var/summary = machine.treatment_provider.treatment_summary(doctor, trauma)

	TEST_ASSERT(findtext(summary, trauma.trauma_label), "Treatment disclosure should name the exact trauma.")
	TEST_ASSERT(findtext(summary, defeat_severity_label(trauma.severity)), "Treatment disclosure should show severity.")
	TEST_ASSERT(findtext(summary, trauma.treatment_description), "Treatment disclosure should include the trauma-specific description.")
	TEST_ASSERT(findtext(summary, DisplayTimeText(machine.treatment_provider.treatment_time(doctor, trauma))), "Treatment disclosure should show the exact provider-adjusted duration.")
	TEST_ASSERT(findtext(summary, "2 bandages"), "Treatment disclosure should show the severity-scaled resource cost.")
	TEST_ASSERT(findtext(summary, machine.name), "Treatment disclosure should identify the selected provider and its location.")

/datum/unit_test/defeat_trauma_provider_prefilters_unusable_candidates

/datum/unit_test/defeat_trauma_provider_prefilters_unusable_candidates/Run()
	var/turf/provider_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/defeat_medical_machine/machine = allocate(/obj/machinery/defeat_medical_machine, provider_turf)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(provider_turf, EAST))
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human, get_step(provider_turf, NORTH))
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_NORMAL)
	var/obj/item/natural/bundle/cloth/bandage/bandages = allocate(/obj/item/natural/bundle/cloth/bandage/full)
	doctor.put_in_active_hand(bandages)

	TEST_ASSERT_EQUAL(length(machine.treatment_provider.usable_diagnoses(patient, doctor, bandages)), 1, "Provider selection should allow untrained helpers when the other requirements are met.")
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	TEST_ASSERT_EQUAL(length(machine.treatment_provider.usable_diagnoses(patient, doctor, bandages)), 1, "Provider selection should retain candidates with valid skill, proximity, and held resources.")
	bandages.amount = 1
	bandages.update_bundle()
	TEST_ASSERT_EQUAL(length(machine.treatment_provider.usable_diagnoses(patient, doctor, bandages)), 0, "Provider selection should reject candidates whose held resource cannot pay the selected severity cost.")

/datum/unit_test/defeat_trauma_provider_rejects_deleted_resource_after_delay

/datum/unit_test/defeat_trauma_provider_rejects_deleted_resource_after_delay/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(patient, doctor, run_loc_floor_bottom_left)
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	var/datum/status_effect/debuff/defeat/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_LIGHT)
	var/obj/item/natural/cloth/bandage/bandage = allocate(/obj/item/natural/cloth/bandage)
	doctor.put_in_active_hand(bandage)
	var/datum/defeat_trauma_provider/medical/machine/unit_test_resource_deleted/provider = allocate(/datum/defeat_trauma_provider/medical/machine/unit_test_resource_deleted)

	TEST_ASSERT(!provider.treat(patient, doctor, trauma, FALSE, FALSE, bandage), "Treatment should reject a reserved resource deleted during the asynchronous gap.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/wound), "Deleting a reserved resource must leave the exact trauma untreated.")

/datum/unit_test/defeat_trauma_providers_have_blueprint_acquisition

/datum/unit_test/defeat_trauma_providers_have_blueprint_acquisition/Run()
	var/datum/blueprint_recipe/engineering/defeat_medical_machine/medical_recipe = allocate(/datum/blueprint_recipe/engineering/defeat_medical_machine)
	var/datum/blueprint_recipe/masonry/defeat_trauma_shrine/shrine_recipe = allocate(/datum/blueprint_recipe/masonry/defeat_trauma_shrine)

	TEST_ASSERT_EQUAL(medical_recipe.result_type, /obj/machinery/defeat_medical_machine, "The construction browser should expose a build path for the medical provider.")
	TEST_ASSERT_EQUAL(shrine_recipe.result_type, /obj/structure/defeat_trauma_shrine, "The construction browser should expose a build path for the shrine provider.")
	TEST_ASSERT(!medical_recipe.requires_learning && !shrine_recipe.requires_learning, "Both provider blueprints should be reachable without a special recipe grant.")

/datum/unit_test/defeat_universal_provider_removes_exactly_one_selected_trauma

/datum/unit_test/defeat_universal_provider_removes_exactly_one_selected_trauma/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/physical = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/status_effect/debuff/defeat/rune = patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/defeat_trauma_provider/universal/provider = allocate(/datum/defeat_trauma_provider/universal)

	TEST_ASSERT(provider.treat(patient, patient, rune, FALSE, TRUE), "Universal treatment should accept an exact compatible trauma datum.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/rune), "Universal treatment should remove the selected rune trauma.")
	TEST_ASSERT(physical in patient.status_effects, "Universal treatment must leave every non-selected trauma in place.")

/datum/unit_test/defeat_shrine_routes_horny_trauma

/datum/unit_test/defeat_shrine_routes_horny_trauma/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/priest = allocate(/mob/living/carbon/human)
	ADD_TRAIT(priest, TRAIT_HOLY, TRAIT_GENERIC)
	var/datum/status_effect/debuff/defeat/horny/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/horny/wobble, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/defeat_trauma_provider/medical/compatibility/medical = allocate(/datum/defeat_trauma_provider/medical/compatibility)
	var/datum/defeat_trauma_provider/shrine/compatibility/shrine = allocate(/datum/defeat_trauma_provider/shrine/compatibility)

	TEST_ASSERT_EQUAL(length(medical.diagnose(patient)), 0, "Medical providers must reject horny trauma.")
	TEST_ASSERT_EQUAL(length(shrine.diagnose(patient)), 1, "Shrines should diagnose horny trauma through spiritual routing.")
	TEST_ASSERT(shrine.treat(patient, priest, trauma, FALSE, TRUE), "A shrine provider should treat one exact horny trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/horny), "Shrine treatment should remove the chosen horny trauma.")

/datum/unit_test/defeat_debuff_fallback_duration_by_severity

/datum/unit_test/defeat_debuff_fallback_duration_by_severity/Run()
	var/mob/living/carbon/human/light_patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/severe_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/light_effect = light_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_LIGHT)
	var/datum/status_effect/debuff/defeat/severe_effect = severe_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_SEVERE)

	TEST_ASSERT_EQUAL(light_effect.initial_duration, 10 MINUTES, "Light defeat trauma should decay slowly but sooner than worse trauma.")
	TEST_ASSERT_EQUAL(severe_effect.initial_duration, 60 MINUTES, "Severe defeat trauma should have the longest fallback decay.")

/datum/unit_test/defeat_trauma_subtypes_have_distinct_stat_profiles

/datum/unit_test/defeat_trauma_subtypes_have_distinct_stat_profiles/Run()
	var/mob/living/carbon/human/wound_patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/burn_patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/concussion_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/wound_effect = wound_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/status_effect/debuff/defeat/burn_effect = burn_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/burn, null, DEFEAT_SEVERITY_NORMAL)
	var/datum/status_effect/debuff/defeat/concussion_effect = concussion_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/concussion, null, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT_NOTNULL(wound_effect.effectedstats[STAT_SPEED], "Wound trauma should pressure speed.")
	TEST_ASSERT_NOTNULL(burn_effect.effectedstats[STAT_CONSTITUTION], "Burn trauma should pressure constitution.")
	TEST_ASSERT_NOTNULL(concussion_effect.effectedstats[STAT_INTELLIGENCE], "Concussion trauma should pressure intelligence.")
	TEST_ASSERT_NULL(burn_effect.effectedstats[STAT_SPEED], "Burn trauma should not use the old generic speed profile.")

/datum/unit_test/defeat_rune_charge_first_free_spend_and_recharge

/datum/unit_test/defeat_rune_charge_first_free_spend_and_recharge/Run()
	var/datum/mind/test_mind = allocate(/datum/mind, "defeat-rune-charge-test")

	TEST_ASSERT_EQUAL(test_mind.get_defeat_rune_charges(), DEFEAT_RUNE_MAX_CHARGES, "Rune charges should start full for the round.")

	var/list/first_spend = test_mind.spend_defeat_rune_charge()
	TEST_ASSERT_EQUAL(first_spend[DEFEAT_RUNE_SPEND_KIND], DEFEAT_RUNE_SPEND_FIRST_FREE, "The first defeat rune return should be free.")
	TEST_ASSERT_EQUAL(test_mind.get_defeat_rune_charges(), DEFEAT_RUNE_MAX_CHARGES, "The first free return should not spend a stored charge.")

	var/list/charged_spend = test_mind.spend_defeat_rune_charge()
	TEST_ASSERT_EQUAL(charged_spend[DEFEAT_RUNE_SPEND_KIND], DEFEAT_RUNE_SPEND_CHARGED, "Later returns should spend stored charges.")
	TEST_ASSERT_EQUAL(charged_spend[DEFEAT_RUNE_CHARGES_REMAINING], DEFEAT_RUNE_MAX_CHARGES - 1, "Charged returns should report remaining charges.")

	test_mind.defeat_rune_charges = 0
	test_mind.defeat_rune_last_recharge_time = world.time - DEFEAT_RUNE_RECHARGE_TIME
	test_mind.recharge_defeat_rune_charges()
	TEST_ASSERT_EQUAL(test_mind.get_defeat_rune_charges(), 1, "One rune charge should recharge each recharge interval.")

/datum/unit_test/defeat_rune_depletion_and_emergency

/datum/unit_test/defeat_rune_depletion_and_emergency/Run()
	var/datum/mind/test_mind = allocate(/datum/mind, "defeat-rune-depletion-test")
	test_mind.defeat_rune_first_free_used = TRUE
	test_mind.defeat_rune_charges = 0

	TEST_ASSERT(!test_mind.can_spend_defeat_rune_charge(), "Depleted non-emergency rune returns should be blocked.")

	var/list/emergency_spend = test_mind.spend_defeat_rune_charge(TRUE)
	TEST_ASSERT_EQUAL(emergency_spend[DEFEAT_RUNE_SPEND_KIND], DEFEAT_RUNE_SPEND_EMERGENCY, "Emergency hazard returns should be allowed even at zero charges.")
	TEST_ASSERT_EQUAL(emergency_spend[DEFEAT_RUNE_CHARGES_REMAINING], 0, "Emergency hazard returns should not create negative charges.")

/datum/unit_test/defeat_rune_preference_routing

/datum/unit_test/defeat_rune_preference_routing/Run()
	var/obj/structure/resurrection_rune/test_rune = allocate(/obj/structure/resurrection_rune)
	var/datum/resurrection_rune_controller/controller = test_rune.resrunecontroler
	var/mob/living/carbon/human/ko_rune_user = allocate(/mob/living/carbon/human)
	ko_rune_user.defeat_system_ai_opt_in = TRUE
	ko_rune_user.defeat_mode = DEFEAT_MODE_KO_RUNE
	ko_rune_user.mind = allocate(/datum/mind, "defeat-ko-rune-user")
	ko_rune_user.mind.current = ko_rune_user
	controller.linked_users += ko_rune_user
	ko_rune_user.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT(controller.can_offer_defeat_rune_return(ko_rune_user), "KO + Rune defeated users should be offered voluntary rune return when charges are available.")

	var/mob/living/carbon/human/ko_only_user = allocate(/mob/living/carbon/human)
	ko_only_user.defeat_system_ai_opt_in = TRUE
	ko_only_user.defeat_mode = DEFEAT_MODE_KO_ONLY
	ko_only_user.mind = allocate(/datum/mind, "defeat-ko-only-user")
	ko_only_user.mind.current = ko_only_user
	controller.linked_users += ko_only_user
	ko_only_user.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT(!controller.can_offer_defeat_rune_return(ko_only_user), "KO Only defeated users should not receive voluntary rune return.")

	ko_rune_user.mind.defeat_rune_first_free_used = TRUE
	ko_rune_user.mind.defeat_rune_charges = 0
	TEST_ASSERT(!controller.can_offer_defeat_rune_return(ko_rune_user), "Depleted KO + Rune users should stay KO-only until charges recharge.")
	ko_rune_user.mind.current = null
	ko_rune_user.mind = null
	ko_only_user.mind.current = null
	ko_only_user.mind = null

/datum/unit_test/defeat_rune_fatigue_mapping

/datum/unit_test/defeat_rune_fatigue_mapping/Run()
	var/datum/resurrection_rune_controller/controller = allocate(/datum/resurrection_rune_controller)
	var/mob/living/carbon/human/first_free_user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/last_charge_user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/emergency_user = allocate(/mob/living/carbon/human)

	controller.apply_revival_debuffs(first_free_user, TRUE, list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_FIRST_FREE, DEFEAT_RUNE_CHARGES_REMAINING = DEFEAT_RUNE_MAX_CHARGES))
	TEST_ASSERT_NOTNULL(first_free_user.has_status_effect(/datum/status_effect/debuff/revived/rune/light), "First free rune return should apply light rune fatigue.")

	controller.apply_revival_debuffs(last_charge_user, TRUE, list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_CHARGED, DEFEAT_RUNE_CHARGES_REMAINING = 0))
	TEST_ASSERT_NOTNULL(last_charge_user.has_status_effect(/datum/status_effect/debuff/revived/rune/rough), "Spending the last charge should apply rough rune fatigue.")

	controller.apply_revival_debuffs(emergency_user, TRUE, list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_EMERGENCY, DEFEAT_RUNE_CHARGES_REMAINING = 0))
	TEST_ASSERT_NOTNULL(emergency_user.has_status_effect(/datum/status_effect/debuff/revived/rune/rough), "Emergency depleted rescues should apply rough rune fatigue.")

/datum/unit_test/defeat_snapshot_debuff_maps_worst_injury

/datum/unit_test/defeat_snapshot_debuff_maps_worst_injury/Run()
	var/mob/living/carbon/human/burn_patient = allocate(/mob/living/carbon/human)
	burn_patient.defeat_system_ai_opt_in = TRUE
	var/obj/item/bodypart/chest = burn_patient.get_bodypart(BODY_ZONE_CHEST)
	chest.create_injury(WOUND_BURN, 45, TRUE)
	burn_patient.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	burn_patient.apply_defeat_snapshot_debuffs()
	TEST_ASSERT_NOTNULL(burn_patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/burn), "Burn injuries should produce burn trauma.")

	var/mob/living/carbon/human/head_patient = allocate(/mob/living/carbon/human)
	head_patient.defeat_system_ai_opt_in = TRUE
	var/obj/item/bodypart/head = head_patient.get_bodypart(BODY_ZONE_HEAD)
	head.create_injury(WOUND_BLUNT, 45, TRUE)
	head_patient.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	head_patient.apply_defeat_snapshot_debuffs()
	TEST_ASSERT_NOTNULL(head_patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/concussion), "Head blunt injuries should produce concussion trauma.")

/datum/unit_test/defeat_trauma_refresh_keeps_highest_severity

/datum/unit_test/defeat_trauma_refresh_keeps_highest_severity/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_SEVERE)
	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_LIGHT)
	var/datum/status_effect/debuff/defeat/pain/pain_trauma = patient.has_status_effect(/datum/status_effect/debuff/defeat/pain)
	TEST_ASSERT_EQUAL(pain_trauma.severity, DEFEAT_SEVERITY_SEVERE, "Repeated lighter trauma should not downgrade an existing severe defeat trauma.")

/datum/unit_test/defeat_trauma_escalates_on_repeat_defeat

/datum/unit_test/defeat_trauma_escalates_on_repeat_defeat/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_LIGHT)
	var/datum/status_effect/debuff/defeat/first = patient.has_status_effect(/datum/status_effect/debuff/defeat/pain)
	TEST_ASSERT_EQUAL(first.severity, DEFEAT_SEVERITY_LIGHT, "A first defeat should apply at the rolled severity.")

	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_LIGHT)
	var/datum/status_effect/debuff/defeat/second = patient.has_status_effect(/datum/status_effect/debuff/defeat/pain)
	TEST_ASSERT_EQUAL(second.severity, DEFEAT_SEVERITY_NORMAL, "An untreated repeat defeat should escalate one stage (light -> moderate).")

	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_LIGHT)
	var/datum/status_effect/debuff/defeat/third = patient.has_status_effect(/datum/status_effect/debuff/defeat/pain)
	TEST_ASSERT_EQUAL(third.severity, DEFEAT_SEVERITY_SEVERE, "A third untreated defeat should escalate to severe.")

	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_LIGHT)
	var/datum/status_effect/debuff/defeat/fourth = patient.has_status_effect(/datum/status_effect/debuff/defeat/pain)
	TEST_ASSERT_EQUAL(fourth.severity, DEFEAT_SEVERITY_SEVERE, "Severe trauma should cap and not overflow on further defeats.")

/datum/unit_test/defeat_horny_requires_valid_hostile_source

/datum/unit_test/defeat_horny_requires_valid_hostile_source/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/grabber = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.pulledby = grabber
	grabber.pulling = victim
	grabber.grab_state = GRAB_AGGRESSIVE
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)
	monitor.horny_defeat_climax_threshold = 1

	monitor.on_climax(victim, null, victim, grabber, grabber)
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Hostile grab climax metadata should trigger horny defeat when the threshold is met. eligible=[victim.defeat_system_is_eligible()] horny_eligible=[victim.horny_defeat_is_eligible()] stat=[victim.stat] climaxes=[monitor.horny_defeat_climax_count] threshold=[monitor.horny_defeat_climax_threshold]")
	TEST_ASSERT_EQUAL(victim.last_defeat_snapshot.reason, DEFEAT_REASON_HORNY, "Horny defeat should preserve its reason in the snapshot.")

/datum/unit_test/defeat_horny_rejects_self_farming_and_unopted_ai

/datum/unit_test/defeat_horny_rejects_self_farming_and_unopted_ai/Run()
	var/mob/living/carbon/human/self_target = allocate(/mob/living/carbon/human)
	self_target.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/self_monitor = self_target.AddComponent(/datum/component/defeat_monitor)
	self_monitor.on_climax(self_target, null, self_target, self_target, self_target)
	TEST_ASSERT_NULL(self_target.has_status_effect(/datum/status_effect/defeat_knockout), "Self-generated climax metadata must not farm horny defeat.")

	var/mob/living/carbon/human/unopted_ai = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/grabber = allocate(/mob/living/carbon/human)
	unopted_ai.pulledby = grabber
	grabber.pulling = unopted_ai
	grabber.grab_state = GRAB_AGGRESSIVE
	var/datum/component/defeat_monitor/unopted_monitor = unopted_ai.AddComponent(/datum/component/defeat_monitor)
	unopted_monitor.on_climax(unopted_ai, null, unopted_ai, grabber, grabber)
	TEST_ASSERT_NULL(unopted_ai.has_status_effect(/datum/status_effect/defeat_knockout), "AI without explicit opt-in should not be defeated through horny defeat.")

/datum/unit_test/defeat_ai_opt_in_component_sets_monitor

/datum/unit_test/defeat_ai_opt_in_component_sets_monitor/Run()
	var/mob/living/carbon/human/ai_body = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!ai_body.defeat_system_is_eligible(), "Clientless, mindless AI bodies should not be eligible before explicit opt-in.")

	var/datum/component/defeat_ai_opt_in/opt_in = ai_body.AddComponent(/datum/component/defeat_ai_opt_in)
	TEST_ASSERT(ai_body.defeat_system_ai_opt_in, "The opt-in component should set the explicit AI defeat flag.")
	TEST_ASSERT_NOTNULL(ai_body.GetComponent(/datum/component/defeat_monitor), "The opt-in component should ensure the defeat monitor.")

	opt_in.UnregisterFromParent()
	TEST_ASSERT(!ai_body.defeat_system_ai_opt_in, "Removing the opt-in component should restore the previous opt-in flag.")

/datum/unit_test/defeat_threshold_quirk_modifier

/datum/unit_test/defeat_threshold_quirk_modifier/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.defeat_damage_threshold = 200
	TEST_ASSERT_EQUAL(test_human.get_effective_defeat_threshold(), 200, "With no fragility quirks the effective threshold should equal the base.")

	var/datum/quirk/negative/frail/frail_quirk = new()
	test_human.quirks += frail_quirk
	TEST_ASSERT_EQUAL(test_human.get_effective_defeat_threshold(), round(200 * 0.6), "A fragility quirk should lower the effective defeat threshold.")

	test_human.quirks -= frail_quirk
	qdel(frail_quirk)
	TEST_ASSERT_EQUAL(test_human.get_effective_defeat_threshold(), 200, "Removing the quirk should restore the base threshold.")

/datum/unit_test/defeat_rune_charge_cost_ladder

/datum/unit_test/defeat_rune_charge_cost_ladder/Run()
	var/list/full = defeat_rune_charge_cost(5)
	TEST_ASSERT_EQUAL(full["coin"], 1, "Spending from a full five charges should cost one coin.")
	TEST_ASSERT_EQUAL(full["blood"], 100, "Spending from a full five charges should cost 100 blood.")

	var/list/last = defeat_rune_charge_cost(1)
	TEST_ASSERT_EQUAL(last["coin"], 30, "Spending the final charge should cost thirty coin.")
	TEST_ASSERT_EQUAL(last["blood"], DEFEAT_RUNE_BLOOD_FRACTION_SENTINEL, "The final charge should bill a fraction of current blood, flagged by sentinel.")

	var/list/none = defeat_rune_charge_cost(0)
	TEST_ASSERT_EQUAL(none["coin"], 0, "With no charges available there is no charge cost.")

/datum/unit_test/defeat_collect_blood_tax_drains_blood

/datum/unit_test/defeat_collect_blood_tax_drains_blood/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.blood_volume = 500

	var/drawn = test_human.collect_blood_tax(120)
	TEST_ASSERT_EQUAL(drawn, 120, "Collecting a blood tax should report the blood drawn.")
	TEST_ASSERT_EQUAL(test_human.blood_volume, 380, "The blood tax should be removed from the mob's blood volume.")

	var/overdraw = test_human.collect_blood_tax(99999)
	TEST_ASSERT_EQUAL(overdraw, 380, "A blood tax larger than available blood should draw only what remains.")
	TEST_ASSERT_EQUAL(test_human.blood_volume, 0, "Over-drawing blood should leave the mob empty, not negative.")

/datum/unit_test/defeat_hazard_only_when_not_passing_over

/datum/unit_test/defeat_hazard_only_when_not_passing_over/Run()
	var/turf/original_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/original_turf_type = original_turf.type
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human, original_turf)

	TEST_ASSERT(!test_human.defeat_is_immediate_hazard(), "A normal floor should not count as an immediate defeat hazard.")

	var/turf/open/lava/lava = original_turf.ChangeTurf(/turf/open/lava)
	test_human.forceMove(lava)
	TEST_ASSERT(test_human.defeat_is_immediate_hazard(), "Standing in lava should count as an immediate defeat hazard.")

	// Flying over the lava is not a hazard - you are not actually in it.
	test_human.movement_type |= FLYING
	TEST_ASSERT(!test_human.defeat_is_immediate_hazard(), "Flying over lava should not count as a defeat hazard.")
	test_human.movement_type &= ~FLYING
	TEST_ASSERT(test_human.defeat_is_immediate_hazard(), "Landing back in the lava should count as a hazard again.")

	// Mid-jump (thrown) across the lava is likewise safe.
	test_human.throwing = TRUE
	TEST_ASSERT(!test_human.defeat_is_immediate_hazard(), "Jumping over lava should not count as a defeat hazard.")
	test_human.throwing = FALSE

	// Leave the test tile as we found it.
	lava.ChangeTurf(original_turf_type)

/datum/unit_test/defeat_injury_profiles_match_design

/datum/unit_test/defeat_injury_profiles_match_design/Run()
	var/mob/living/carbon/human/concussion_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/concussion_effect = concussion_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/concussion, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_EQUAL(concussion_effect.effectedstats[STAT_PERCEPTION], -3, "Concussion should drop perception by 3 at normal severity.")
	TEST_ASSERT_EQUAL(concussion_effect.effectedstats[STAT_INTELLIGENCE], -2, "Concussion should drop intelligence by 2 at normal severity.")
	TEST_ASSERT_EQUAL(concussion_effect.effectedstats[STAT_FORTUNE], -2, "Concussion should drop fortune by 2 at normal severity.")

	var/mob/living/carbon/human/body_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/body_effect = body_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/body, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_EQUAL(body_effect.effectedstats[STAT_CONSTITUTION], -3, "Internal bruising should drop constitution by 3 at normal severity.")
	TEST_ASSERT_EQUAL(body_effect.effectedstats[STAT_STRENGTH], -2, "Internal bruising should drop strength by 2 at normal severity.")

	var/mob/living/carbon/human/leg_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/leg_effect = leg_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/leg, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_EQUAL(leg_effect.effectedstats[STAT_SPEED], -4, "A leg injury should drop speed by 4 at normal severity.")

	var/mob/living/carbon/human/arm_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/arm_effect = arm_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/arm, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_EQUAL(arm_effect.effectedstats[STAT_STRENGTH], -4, "An arm injury should drop strength by 4 at normal severity.")

	var/mob/living/carbon/human/mana_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/mana_effect = mana_patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_EQUAL(mana_effect.effectedstats[STAT_INTELLIGENCE], -4, "Mana-backlash should drop intelligence by 4 at normal severity.")

	var/mob/living/carbon/human/severe_patient = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/severe_effect = severe_patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/concussion, null, DEFEAT_SEVERITY_SEVERE)
	TEST_ASSERT_EQUAL(severe_effect.effectedstats[STAT_PERCEPTION], -5, "Severe concussion should scale perception up to -5.")

/datum/unit_test/defeat_stacked_trauma_endurance_is_capped

/datum/unit_test/defeat_stacked_trauma_endurance_is_capped/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/base_endurance = GET_MOB_ATTRIBUTE_VALUE(patient, STAT_ENDURANCE)

	// Leg (-3) and body (-3) carry distinct ids, so they stack rather than fester into one another.
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/leg, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/body, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(patient, STAT_ENDURANCE), base_endurance - 6, "Two stacked traumas should take their full 6 Endurance, which is exactly the cap.")

	// A third and fourth push the raw total past -6, but the carried loss must stay pinned at the cap.
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/arm, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/burn, null, DEFEAT_SEVERITY_SEVERE)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(patient, STAT_ENDURANCE), base_endurance - DEFEAT_TRAUMA_ENDURANCE_PENALTY_CAP, "Stacked defeat traumas must never take more than the Endurance cap between them.")

	// Curing back down below the cap must give the compensating modifier back, not leave a windfall.
	patient.remove_status_effect(/datum/status_effect/debuff/defeat/physical/burn)
	patient.remove_status_effect(/datum/status_effect/debuff/defeat/physical/arm)
	patient.remove_status_effect(/datum/status_effect/debuff/defeat/physical/body)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(patient, STAT_ENDURANCE), base_endurance - 3, "Clearing traumas back under the cap should restore the remaining trauma's own penalty.")

	patient.remove_status_effect(/datum/status_effect/debuff/defeat/physical/leg)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(patient, STAT_ENDURANCE), base_endurance, "Clearing every trauma should leave no Endurance modifier behind.")

/datum/unit_test/defeat_leg_injury_blocks_jump

/datum/unit_test/defeat_leg_injury_blocks_jump/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/leg, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_DEFEAT_NO_JUMP), "A leg injury should block jumping while active.")
	patient.remove_status_effect(/datum/status_effect/debuff/defeat/physical/leg)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_DEFEAT_NO_JUMP), "Clearing the leg injury should restore jumping.")

/datum/unit_test/defeat_limb_zone_injuries_map_to_limb_trauma

/datum/unit_test/defeat_limb_zone_injuries_map_to_limb_trauma/Run()
	var/mob/living/carbon/human/arm_patient = allocate(/mob/living/carbon/human)
	arm_patient.defeat_system_ai_opt_in = TRUE
	var/obj/item/bodypart/arm = arm_patient.get_bodypart(BODY_ZONE_R_ARM)
	arm.create_injury(WOUND_BLUNT, 45, TRUE)
	arm_patient.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	arm_patient.apply_defeat_snapshot_debuffs()
	TEST_ASSERT_NOTNULL(arm_patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/arm), "Arm-zone injuries should produce arm trauma.")

	var/mob/living/carbon/human/leg_patient = allocate(/mob/living/carbon/human)
	leg_patient.defeat_system_ai_opt_in = TRUE
	var/obj/item/bodypart/leg = leg_patient.get_bodypart(BODY_ZONE_L_LEG)
	leg.create_injury(WOUND_BLUNT, 45, TRUE)
	leg_patient.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	leg_patient.apply_defeat_snapshot_debuffs()
	TEST_ASSERT_NOTNULL(leg_patient.has_status_effect(/datum/status_effect/debuff/defeat/physical/leg), "Leg-zone injuries should produce leg trauma.")

/datum/unit_test/defeat_knockout_applies_and_clears_cleanly

/datum/unit_test/defeat_knockout_applies_and_clears_cleanly/Run()
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	var/datum/status_effect/defeat_knockout/knockout = test_human.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NOTNULL(knockout, "Knockout should apply.")
	TEST_ASSERT(HAS_TRAIT(test_human, TRAIT_PACIFISM), "Knockout should pacify the victim.")
	test_human.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NULL(test_human.has_status_effect(/datum/status_effect/defeat_knockout), "Knockout should clear without runtime.")
	TEST_ASSERT(!HAS_TRAIT(test_human, TRAIT_PACIFISM), "Clearing knockout should drop its pacifism.")

/datum/unit_test/defeat_intimate_aftermath_is_consistent

/datum/unit_test/defeat_intimate_aftermath_is_consistent/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.defeat_system_ai_opt_in = TRUE
	patient.enter_defeat(DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_NORMAL)
	patient.apply_defeat_snapshot_debuffs()
	var/datum/status_effect/debuff/defeat/horny/trauma = patient.has_status_effect(/datum/status_effect/debuff/defeat/horny)
	TEST_ASSERT_NOTNULL(trauma, "Intimate defeat should produce Lewd Exhaustion.")
	TEST_ASSERT_EQUAL(trauma.type, /datum/status_effect/debuff/defeat/horny, "Intimate defeat must not roll unrelated movement, grip, or mana penalties.")
	TEST_ASSERT_EQUAL(patient.last_defeat_snapshot.defeat_debuff_type(), trauma.type, "The aftermath preview must match the applied trauma.")

/datum/unit_test/defeat_aftermath_prioritizes_cause/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	arm.create_injury(WOUND_BLUNT, 10, TRUE)
	patient.blood_volume = BLOOD_VOLUME_SURVIVE
	var/datum/defeat_snapshot/snapshot = allocate(/datum/defeat_snapshot)
	snapshot.capture_from(patient, DEFEAT_REASON_DEATH)
	TEST_ASSERT_EQUAL(snapshot.defeat_debuff_type(), /datum/status_effect/debuff/defeat/blood_loss, "Blood-loss defeat must not inherit an unrelated arm injury.")
	patient.blood_volume = BLOOD_VOLUME_NORMAL
	patient.setOxyLoss(DEFEAT_OXY_THRESHOLD, FALSE, TRUE)
	snapshot.capture_from(patient, DEFEAT_REASON_DEATH)
	TEST_ASSERT_EQUAL(snapshot.defeat_debuff_type(), /datum/status_effect/debuff/defeat/breathless, "Oxygen defeat must produce breathless exhaustion.")
	patient.setOxyLoss(0, FALSE, TRUE)
	patient.setToxLoss(100, FALSE, TRUE)
	snapshot.capture_from(patient, DEFEAT_REASON_DAMAGE)
	TEST_ASSERT_EQUAL(snapshot.defeat_debuff_type(), /datum/status_effect/debuff/defeat/poisoned, "Predominant toxin damage must produce poisoning aftereffects.")
	patient.setToxLoss(0, FALSE, TRUE)
	patient.setCloneLoss(100, FALSE, TRUE)
	snapshot.capture_from(patient, DEFEAT_REASON_DAMAGE)
	TEST_ASSERT_EQUAL(snapshot.defeat_debuff_type(), /datum/status_effect/debuff/defeat/body_strain, "Predominant clone damage must produce systemic strain.")
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	medic.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_EXPERT, TRUE)
	for(var/trauma_type in list(/datum/status_effect/debuff/defeat/blood_loss, /datum/status_effect/debuff/defeat/breathless, /datum/status_effect/debuff/defeat/poisoned, /datum/status_effect/debuff/defeat/body_strain))
		var/datum/status_effect/debuff/defeat/trauma = patient.apply_defeat_trauma_status(trauma_type)
		TEST_ASSERT(patient.defeat_treat_trauma(medic, DEFEAT_TREATMENT_MEDICAL, trauma), "Cause-specific physical aftermath must be medically treatable.")

/datum/unit_test/defeat_horny_threshold_uses_encounter_start_stats

/datum/unit_test/defeat_horny_threshold_uses_encounter_start_stats/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/grabber = allocate(/mob/living/carbon/human)
	victim.mind = allocate(/datum/mind, "legacy-deterministic-threshold-test")
	// /datum/mind/Destroy() detaches itself through current, so a mind attached without one leaves
	// the body holding a deleted mind and hard-deletes at the end of the run.
	victim.mind.current = victim
	victim.defeat_system_ai_opt_in = TRUE
	victim.attributes.raw_attribute_list[STAT_CONSTITUTION] = 14
	victim.attributes.raw_attribute_list[STAT_ENDURANCE] = 16
	victim.attributes.update_attributes()
	victim.pulledby = grabber
	grabber.pulling = victim
	grabber.grab_state = GRAB_AGGRESSIVE
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)

	monitor.on_climax(victim, null, victim, grabber, grabber)
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 7, "Horny defeat should cache the exact encounter-start stat formula.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "A single climax should not reach this deterministic horny knockout threshold.")

/datum/unit_test/defeat_horny_encounter_decays_and_recalculates

/datum/unit_test/defeat_horny_encounter_decays_and_recalculates/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/grabber = allocate(/mob/living/carbon/human)
	victim.mind = allocate(/datum/mind, "legacy-threshold-timeout-test")
	// /datum/mind/Destroy() detaches itself through current, so a mind attached without one leaves
	// the body holding a deleted mind and hard-deletes at the end of the run.
	victim.mind.current = victim
	victim.defeat_system_ai_opt_in = TRUE
	victim.attributes.raw_attribute_list[STAT_CONSTITUTION] = 14
	victim.attributes.raw_attribute_list[STAT_ENDURANCE] = 16
	victim.attributes.update_attributes()
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)

	// A stale encounter one climax from collapse, whose last counted climax was too long ago.
	monitor.horny_defeat_climax_count = 9
	monitor.horny_defeat_climax_threshold = 10
	monitor.horny_defeat_warned_stage = 3
	monitor.horny_defeat_last_climax_at = world.time - DEFEAT_HORNY_ENCOUNTER_TIMEOUT - 1 SECONDS

	// The next climax must open a FRESH encounter, not land as the stale 10th.
	monitor.on_climax(victim, null, victim, grabber, grabber)
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Climaxes from a long-expired encounter must not stack into a surprise horny defeat.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 1, "After the encounter lull, the climax count should restart at one.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 7, "The expired encounter's threshold should be recalculated from current player stats.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_warned_stage, 0, "Warning beats should reset with the expired encounter.")

	// Completed progress stays cached through the KO itself and clears only when recovery removes it.
	monitor.horny_defeat_climax_count = 0
	monitor.horny_defeat_climax_threshold = 1
	monitor.on_climax(victim, null, victim, grabber, grabber)
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Reaching the threshold should still trigger the horny defeat.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 1, "Horny defeat should retain completed progress while the victim remains down.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 1, "Horny defeat should retain its cached threshold while the victim remains down.")
	victim.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_count, 0, "Recovery should clear completed horny-defeat progress.")
	TEST_ASSERT_EQUAL(monitor.horny_defeat_climax_threshold, 0, "Recovery should clear the cached horny-defeat threshold.")

	// Entering a real defeat here detaches current, so the mind can no longer unhook itself in
	// Destroy() and the body would hold a deleted mind. Detach both ends by hand.
	victim.mind.current = null
	victim.mind = null

/datum/unit_test/defeat_knockout_clears_traits_without_physiology

/datum/unit_test/defeat_knockout_clears_traits_without_physiology/Run()
	// Regression: on_remove once early-returned before its trait cleanup when a human owner had no
	// physiology, leaving NODEATH/PACIFISM/IMMOBILIZED/FLOORED stuck forever. The traits do not touch
	// physiology, so their removal must not depend on it.
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	test_human.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(HAS_TRAIT(test_human, TRAIT_FLOORED), "Knockout should floor the victim.")
	QDEL_NULL(test_human.physiology)
	test_human.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(!HAS_TRAIT(test_human, TRAIT_FLOORED), "Clearing knockout must drop its traits even with no physiology.")
	TEST_ASSERT(!HAS_TRAIT(test_human, TRAIT_NODEATH), "Clearing knockout must drop NODEATH even with no physiology.")
	TEST_ASSERT(!HAS_TRAIT(test_human, TRAIT_PACIFISM), "Clearing knockout must drop pacifism even with no physiology.")

/datum/unit_test/defeat_trauma_treatment_classes_are_registered

/datum/unit_test/defeat_trauma_treatment_classes_are_registered/Run()
	// Every trauma self-registers its cure via treatment_class - a subtype outside the two skilled
	// classes would be curable only by the universal path, which is never intended silently.
	for(var/datum/status_effect/debuff/defeat/trauma_type as anything in typesof(/datum/status_effect/debuff/defeat))
		var/cure_class = initial(trauma_type.treatment_class)
		TEST_ASSERT(cure_class == DEFEAT_TREATMENT_MEDICAL || cure_class == DEFEAT_TREATMENT_SPIRITUAL, "[trauma_type] must register a medical or spiritual treatment_class.")

	// The class-driven cure sorts mixed traumas to the right healer with no hand-kept lists.
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/priest = allocate(/mob/living/carbon/human)
	doctor.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	ADD_TRAIT(priest, TRAIT_HOLY, TRAIT_GENERIC)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/grievous, null, DEFEAT_SEVERITY_SEVERE)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/horny/wobble, null, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT(patient.defeat_treat_trauma(doctor, DEFEAT_TREATMENT_MEDICAL), "Medical treatment should clear medical-class traumas.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "Grievous Wounds registers as medical and should be cleared by the clinic.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/horny), "Medical treatment must not clear spiritual-class horny trauma.")
	TEST_ASSERT(patient.defeat_treat_trauma(priest, DEFEAT_TREATMENT_SPIRITUAL), "Spiritual treatment should clear spiritual-class traumas.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/horny), "Horny trauma variants register as spiritual and should be cleared by the priest.")

/datum/unit_test/defeat_horny_instigator_combat_mode_gate

/datum/unit_test/defeat_horny_instigator_combat_mode_gate/Run()
	// NPC / AI instigators (not player-controlled) always count, combat mode or not.
	TEST_ASSERT(horny_defeat_instigator_counts(FALSE, FALSE), "A non-player instigator should count regardless of combat mode.")
	TEST_ASSERT(horny_defeat_instigator_counts(FALSE, TRUE), "A non-player instigator should count regardless of combat mode.")
	// A player instigator only counts while in combat mode.
	TEST_ASSERT(horny_defeat_instigator_counts(TRUE, TRUE), "A player instigator in combat mode should count.")
	TEST_ASSERT(!horny_defeat_instigator_counts(TRUE, FALSE), "A player instigator out of combat mode (consensual) should not count.")

/datum/unit_test/defeat_horny_warning_stage_escalates

/datum/unit_test/defeat_horny_warning_stage_escalates/Run()
	// No warning before the design's opening climax count.
	TEST_ASSERT_EQUAL(horny_defeat_warning_stage(1, 15), 0, "Warnings should not fire before the second climax.")
	// Warnings always open at DEFEAT_HORNY_WARNING_START, even for a low rolled threshold.
	TEST_ASSERT_EQUAL(horny_defeat_warning_stage(2, 15), 1, "The second climax should open the faint warning.")
	TEST_ASSERT_EQUAL(horny_defeat_warning_stage(2, 10), 1, "Even a low threshold opens at the second climax.")
	// Mid-encounter the warning builds (>= 60% of threshold).
	TEST_ASSERT_EQUAL(horny_defeat_warning_stage(9, 15), 2, "Past 60% of the threshold the warning should build.")
	// The climax right before collapse is the imminent warning.
	TEST_ASSERT_EQUAL(horny_defeat_warning_stage(14, 15), 3, "The climax before the threshold should warn of imminent collapse.")
	// A never-rolled threshold yields no warning.
	TEST_ASSERT_EQUAL(horny_defeat_warning_stage(5, 0), 0, "An unrolled threshold should produce no warning.")

/datum/unit_test/defeat_horny_self_recovery
	needs_pocket_space = TRUE

/datum/unit_test/defeat_horny_self_recovery/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.defeat_system_ai_opt_in = TRUE
	patient.enter_defeat(DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "Setup: the horny defeat should apply a knockout.")

	// Fire the self-recovery the timer would eventually call.
	TEST_ASSERT(patient.defeat_horny_self_recover(), "A horny knockout should self-recover on its own.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "Self-recovery should clear the knockout.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/horny), "Self-recovery should still leave the Lewd Exhaustion aftermath.")
	TEST_ASSERT(!patient.defeat_horny_self_recover(), "Self-recovery is a no-op once the knockout is gone.")

	// A kidnapped victim cannot self-recover - captivity governs their release instead.
	var/mob/living/carbon/human/captive = allocate(/mob/living/carbon/human)
	captive.defeat_system_ai_opt_in = TRUE
	captive.enter_defeat(DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_NORMAL)
	captive.AddComponent(/datum/component/kidnap_captivity, "unit_test_kidnap_lair")
	TEST_ASSERT(!captive.defeat_horny_self_recover(), "A kidnapped victim should not self-recover.")
	TEST_ASSERT_NOTNULL(captive.has_status_effect(/datum/status_effect/defeat_knockout), "A kidnapped victim should stay knocked out despite the self-recover window.")

/datum/unit_test/defeat_ko_only_struggle_up_grievous

/datum/unit_test/defeat_ko_only_struggle_up_grievous/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.defeat_system_ai_opt_in = TRUE
	patient.defeat_mode = DEFEAT_MODE_KO_ONLY
	patient.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "Setup: a KO Only damage defeat should knock the victim out.")

	// Fire the self-rescue the Struggle-Up action / auto safety-net would call.
	TEST_ASSERT(patient.defeat_ko_only_self_recover(), "A KO Only victim should be able to struggle up unaided.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "Struggling up should clear the knockout.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "Struggling up should inflict Grievous Wounds.")
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_PACIFISM), "Grievous Wounds should lock the victim out of fighting.")
	TEST_ASSERT(!patient.defeat_ko_only_self_recover(), "Self-rescue is a no-op once the knockout is gone.")

	// Town-clinic-only cure: a full field heal must NOT clear Grievous Wounds.
	patient.fully_heal(HEAL_ALL)
	var/datum/status_effect/debuff/defeat/grievous/wounds = patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous)
	TEST_ASSERT_NOTNULL(wounds, "A field full-heal must not cure Grievous Wounds - only town care does.")

	// The universal potion/spell path is field healing by another name and must not reach it either.
	TEST_ASSERT(!patient.defeat_treat_trauma(patient, DEFEAT_TREATMENT_UNIVERSAL, wounds), "The universal cure must not accept Grievous Wounds.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "A refused universal cure must leave Grievous Wounds in place.")

	// A skilled medic (the clinic cure path) clears it. The struggle also left the ordinary damage
	// trauma behind, and a provider treats one exact injury per attempt, so name the target.
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	medic.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_EXPERT, TRUE)
	TEST_ASSERT(patient.defeat_treat_trauma(medic, DEFEAT_TREATMENT_MEDICAL, wounds), "Medical care should treat Grievous Wounds.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "Medical care should clear Grievous Wounds.")

/datum/unit_test/defeat_depleted_rune_arms_struggle_up

/datum/unit_test/defeat_depleted_rune_arms_struggle_up/Run()
	// KO Only never has a rune to fall back on.
	var/mob/living/carbon/human/ko_only = allocate(/mob/living/carbon/human)
	ko_only.defeat_mode = DEFEAT_MODE_KO_ONLY
	TEST_ASSERT(!ko_only.defeat_has_rune_safety_net(), "KO Only should never report a rune safety net.")

	// A KO+Rune player whose rune cannot answer (unlinked / depleted) is treated the same.
	var/mob/living/carbon/human/rune_user = allocate(/mob/living/carbon/human)
	rune_user.defeat_mode = DEFEAT_MODE_KO_RUNE
	rune_user.rune_linked = RUNE_LINK_NONE
	TEST_ASSERT(!rune_user.defeat_has_rune_safety_net(), "A KO+Rune player with no callable rune should have no safety net.")

	// Entering defeat with no rune to answer arms the self-rescue for the KO+Rune player too.
	rune_user.defeat_system_ai_opt_in = TRUE
	rune_user.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	var/datum/status_effect/defeat_knockout/knockout = rune_user.has_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NOTNULL(knockout, "Setup: the depleted-rune user should be knocked out.")
	TEST_ASSERT_NOTNULL(knockout.struggle_offer_timer, "A depleted/uncallable-rune KO+Rune victim should have the struggle-up self-rescue armed.")

/datum/unit_test/defeat_potion_feed_rescues_downed_victim

/datum/unit_test/defeat_potion_feed_rescues_downed_victim/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/healer = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, healer, run_loc_floor_bottom_left)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)

	var/obj/item/reagent_containers/glass/bottle/vial/curative = allocate(/obj/item/reagent_containers/glass/bottle/vial, run_loc_floor_bottom_left)
	curative.reagents.add_reagent(/datum/reagent/medicine/herbal/symphitum_tea, 20)
	TEST_ASSERT(curative.transfer_feed_reagents(victim, healer), "Actually feeding a full medicinal gulp to a downed victim should rescue them.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Potion rescue should clear the knockout.")

	var/mob/living/carbon/human/loner = allocate(/mob/living/carbon/human)
	loner.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(!curative.transfer_feed_reagents(loner, loner), "A victim cannot revive themselves with their own drink.")
	TEST_ASSERT_NOTNULL(loner.has_status_effect(/datum/status_effect/defeat_knockout), "Self-administered drinks must leave the knockout in place.")

	var/mob/living/carbon/human/thirsty = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/water_bearer = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(thirsty, water_bearer, run_loc_floor_bottom_left)
	thirsty.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/obj/item/reagent_containers/glass/bottle/vial/plain = allocate(/obj/item/reagent_containers/glass/bottle/vial, run_loc_floor_bottom_left)
	plain.reagents.add_reagent(/datum/reagent/water, 20)
	TEST_ASSERT(!plain.transfer_feed_reagents(thirsty, water_bearer), "Plain water is not curative and should not rescue.")
	TEST_ASSERT_NOTNULL(thirsty.has_status_effect(/datum/status_effect/defeat_knockout), "A non-curative drink must leave the knockout in place.")

	var/mob/living/carbon/human/diluted_patient = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/glass/bottle/vial/diluted = allocate(/obj/item/reagent_containers/glass/bottle/vial, run_loc_floor_bottom_left)
	diluted_patient.apply_status_effect(/datum/status_effect/defeat_knockout)
	diluted.reagents.add_reagent(/datum/reagent/medicine/herbal/symphitum_tea, DEFEAT_PREPARED_MEDICINE_MINIMUM)
	diluted.reagents.add_reagent(/datum/reagent/water, 15)
	TEST_ASSERT(!diluted.transfer_feed_reagents(diluted_patient, healer), "Medicine left elsewhere in a diluted container must not count as medicine consumed in this gulp.")
	TEST_ASSERT_NOTNULL(diluted_patient.has_status_effect(/datum/status_effect/defeat_knockout), "A sub-threshold medicinal gulp must leave Defeat knockout in place.")

/datum/unit_test/defeat_treatment_requires_zone

/datum/unit_test/defeat_treatment_requires_zone/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!patient.defeat_treatment_zone_ok(DEFEAT_TREATMENT_MEDICAL), "Medical defeat cures should require a clinic zone (the test reservation is neither).")
	TEST_ASSERT(!patient.defeat_treatment_zone_ok(DEFEAT_TREATMENT_SPIRITUAL), "Spiritual defeat cures should require a church zone.")
	TEST_ASSERT(patient.defeat_treatment_zone_ok(DEFEAT_TREATMENT_UNIVERSAL), "The expensive universal cure should bypass the zone requirement.")

/obj/effect/landmark/kidnap/entrance/unit_test
	lair_tag = "unit_test_kidnap_lair"

/obj/effect/landmark/kidnap/escape/unit_test
	lair_tag = "unit_test_kidnap_lair"

/datum/unit_test/defeat_kidnap_to_lair_and_escape
	needs_pocket_space = TRUE

/datum/unit_test/defeat_kidnap_to_lair_and_escape/Run()
	var/turf/lair_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/escape_turf = get_step(lair_turf, EAST)
	allocate(/obj/effect/landmark/kidnap/entrance/unit_test, lair_turf)
	allocate(/obj/effect/landmark/kidnap/escape/unit_test, escape_turf)

	TEST_ASSERT(("unit_test_kidnap_lair" in GLOB.kidnap_entrance_markers), "Entrance markers should register under their lair tag.")

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)

	TEST_ASSERT(victim.kidnap_to_lair("unit_test_kidnap_lair"), "The compatibility lair tag should resolve to a shared pocket profile.")
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	TEST_ASSERT_NOTNULL(captivity, "Kidnap should attach the captivity component.")
	var/datum/pocket_dimension/defeat_captivity/instance = captivity.resolve_instance()
	TEST_ASSERT_NOTNULL(instance, "Kidnap should attach the captive to an active pocket instance.")
	TEST_ASSERT(instance.contains_turf(get_turf(victim)), "Kidnap should move the victim into the profile-owned pocket.")
	TEST_ASSERT_NOTEQUAL(get_turf(victim), lair_turf, "Legacy static entrance markers must no longer receive new captives.")

	captivity.release_from_knockout()
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Captivity release should clear the knockout state.")
	// Release now hands over agency (no pacifism) plus the Refuse Advances opt-out toggle.
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_PACIFISM), "A released captive should no longer be pacified - the path is a lighthearted one.")
	var/datum/action/innate/defeat_refuse_advances/refuse = locate(/datum/action/innate/defeat_refuse_advances) in victim.actions
	TEST_ASSERT_NOTNULL(refuse, "A released captive should be granted the Refuse Advances opt-out.")

	// Toggling it makes horny mobs ignore the captive.
	refuse.Activate()
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES), "Activating Refuse Advances should set the opt-out trait.")
	var/mob/living/carbon/human/would_be_suitor = allocate(/mob/living/carbon/human)
	var/datum/targetting_datum/basic/td = new()
	TEST_ASSERT(!td.can_horny(would_be_suitor, victim), "A refusing captive should not be a valid horny target.")

	TEST_ASSERT(instance.exit_mob(victim), "A released shared-lair captive should escape through the pocket exit contract.")
	TEST_ASSERT_NULL(victim.GetComponent(/datum/component/kidnap_captivity), "Using the pocket exit should end captivity.")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES), "Escaping should strip the opt-out trait.")
	TEST_ASSERT(!(locate(/datum/action/innate/defeat_refuse_advances) in victim.actions), "Escaping should remove the Refuse Advances action from the captive.")

/datum/unit_test/defeat_faction_mob_kidnaps_defeated_prey
	needs_pocket_space = TRUE

/datum/unit_test/defeat_faction_mob_kidnaps_defeated_prey/Run()
	var/turf/lair_turf = get_step(run_loc_floor_bottom_left, EAST)
	allocate(/obj/effect/landmark/kidnap/entrance/unit_test, lair_turf)

	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, captor, run_loc_floor_bottom_left)

	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.recent_damage_source_attacker_weakref = WEAKREF(captor)
	// Kidnapping only claims horny-defeated prey, so stamp the snapshot the gate checks.
	victim.last_defeat_snapshot = new /datum/defeat_snapshot
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY

	TEST_ASSERT(!captor.can_kidnap_defeated_prey(victim), "A mob with no lair tag cannot kidnap.")
	captor.kidnap_lair_tag = "unit_test_kidnap_lair"
	TEST_ASSERT(captor.can_kidnap_defeated_prey(victim), "A faction captor beside prey it just defeated should be able to kidnap.")

	TEST_ASSERT(captor.try_kidnap_defeated_prey(victim), "The kidnap attempt should succeed.")
	TEST_ASSERT_NOTNULL(victim.GetComponent(/datum/component/kidnap_captivity), "The kidnapped victim should be in captivity.")
	TEST_ASSERT(!captor.can_kidnap_defeated_prey(victim), "An already-captive victim cannot be kidnapped again.")

/datum/unit_test/defeat_kidnap_only_claims_horny_prey

/datum/unit_test/defeat_kidnap_only_claims_horny_prey/Run()
	var/turf/lair_turf = get_step(run_loc_floor_bottom_left, EAST)
	allocate(/obj/effect/landmark/kidnap/entrance/unit_test, lair_turf)

	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, captor, run_loc_floor_bottom_left)
	captor.kidnap_lair_tag = "unit_test_kidnap_lair"

	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.recent_damage_source_attacker_weakref = WEAKREF(captor)
	// A plain beatdown defeat - the lighthearted gate must refuse to drag them off.
	victim.last_defeat_snapshot = new /datum/defeat_snapshot
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_DAMAGE
	TEST_ASSERT(!captor.can_kidnap_defeated_prey(victim), "A regular (non-horny) defeat should never be kidnappable.")

	// Switch the same victim's defeat to a horny one and now they can be claimed.
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY
	TEST_ASSERT(captor.can_kidnap_defeated_prey(victim), "A horny defeat beside its captor should be kidnappable.")

/datum/unit_test/defeat_kidnap_candidate_ignores_distance

/datum/unit_test/defeat_kidnap_candidate_ignores_distance/Run()
	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	captor.kidnap_lair_tag = "unit_test_kidnap_lair"
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.recent_damage_source_attacker_weakref = WEAKREF(captor)
	victim.last_defeat_snapshot = new /datum/defeat_snapshot
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY

	// The AI candidate check holds without adjacency, so a captor can path toward distant prey...
	TEST_ASSERT(captor.is_kidnap_candidate(victim), "A horny-defeated victim should be a kidnap candidate regardless of distance.")
	// ...while a non-horny defeat is never a candidate, and a mob with no lair never kidnaps.
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_DAMAGE
	TEST_ASSERT(!captor.is_kidnap_candidate(victim), "A non-horny defeat is never a kidnap candidate.")
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY
	captor.kidnap_lair_tag = null
	TEST_ASSERT(!captor.is_kidnap_candidate(victim), "A mob with no lair tag is never a kidnap candidate.")

/datum/unit_test/defeat_kidnap_blocked_when_outnumbered

/datum/unit_test/defeat_kidnap_blocked_when_outnumbered/Run()
	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/rescuer_one = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/rescuer_two = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, captor, run_loc_floor_bottom_left)
	rescuer_one.forceMove(get_turf(captor))
	rescuer_two.forceMove(get_turf(captor))

	captor.set_faction(list("kidnap_unit_test_captor"))
	captor.kidnap_lair_tag = "unit_test_kidnap_lair"
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.recent_damage_source_attacker_weakref = WEAKREF(captor)
	// Kidnapping only claims horny-defeated prey, so stamp the snapshot the gate checks.
	victim.last_defeat_snapshot = new /datum/defeat_snapshot
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY

	TEST_ASSERT(captor.kidnap_is_outnumbered(victim), "Two nearby rescuers against a lone captor should count as outnumbered.")
	TEST_ASSERT(!captor.can_kidnap_defeated_prey(victim), "An outnumbered captor should not be able to drag prey off.")

/datum/unit_test/defeat_distress_npc_spawns_and_rewards

/datum/unit_test/defeat_distress_npc_spawns_and_rewards/Run()
	var/turf/spot = get_step(run_loc_floor_bottom_left, EAST)
	var/mob/living/carbon/human/npc_in_distress/captive = allocate(/mob/living/carbon/human/npc_in_distress, spot)
	var/datum/component/npc_in_distress/distress = captive.GetComponent(/datum/component/npc_in_distress)
	TEST_ASSERT_NOTNULL(distress, "An ambient distress NPC should carry the distress component.")

	var/mob/living/carbon/human/rescuer = allocate(/mob/living/carbon/human)
	distress.complete_rescue(rescuer)
	var/coins = 0
	for(var/obj/item/coin/silver/coin in spot)
		coins++
	TEST_ASSERT(coins >= NPC_DISTRESS_REWARD_MIN && coins <= NPC_DISTRESS_REWARD_MAX, "Rescue should drop the silver reward on the ground.")
	TEST_ASSERT(QDELETED(captive), "A rescued distress NPC should be removed (taken by the Rune).")
	for(var/obj/item/coin/silver/coin in spot)
		qdel(coin)

/datum/unit_test/defeat_distress_drop_carried_clears_hands

/datum/unit_test/defeat_distress_drop_carried_clears_hands/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/coin/silver/trinket = allocate(/obj/item/coin/silver, get_turf(victim))
	victim.put_in_hands(trinket)
	TEST_ASSERT((trinket in victim.held_items), "Setup: the trinket should start in hand.")
	victim.npc_in_distress_drop_carried()
	TEST_ASSERT(!(trinket in victim.held_items), "Surrender should drop carried items out of the hands.")

/datum/unit_test/defeat_kidnap_remembers_captor_faction
	needs_pocket_space = TRUE

/datum/unit_test/defeat_kidnap_remembers_captor_faction/Run()
	var/turf/lair_turf = get_step(run_loc_floor_bottom_left, EAST)
	allocate(/obj/effect/landmark/kidnap/entrance/unit_test, lair_turf)
	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, captor, run_loc_floor_bottom_left)
	captor.set_faction(list("greenskin_unit_test"))
	captor.kidnap_lair_tag = "unit_test_kidnap_lair"
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.recent_damage_source_attacker_weakref = WEAKREF(captor)
	// Kidnapping only claims horny-defeated prey, so stamp the snapshot the gate checks.
	victim.last_defeat_snapshot = new /datum/defeat_snapshot
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY

	TEST_ASSERT(captor.try_kidnap_defeated_prey(victim), "Kidnap should succeed.")
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	TEST_ASSERT_NOTNULL(captivity, "Captivity should be attached after a kidnap.")
	TEST_ASSERT(("greenskin_unit_test" in captivity.captor_faction), "Captivity should remember the captor's faction so a surrendered captive shares it.")

/datum/unit_test/defeat_kidnap_climaxes_offer_surrender
	needs_pocket_space = TRUE

/datum/unit_test/defeat_kidnap_climaxes_offer_surrender/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/datum/component/kidnap_captivity/captivity = victim.AddComponent(/datum/component/kidnap_captivity, "unit_test_kidnap_lair")
	TEST_ASSERT_NOTNULL(captivity, "Captivity component should attach.")
	TEST_ASSERT(!captivity.surrender_available, "Surrender should not be offered before enough climaxes.")

	for(var/i in 1 to KIDNAP_SURRENDER_CLIMAXES)
		captivity.on_captive_climax(victim, null, victim, null, null)
	TEST_ASSERT(captivity.surrender_available, "Enough climaxes endured in captivity should offer surrender early.")

/datum/unit_test/defeat_healing_spring_rescues

/datum/unit_test/defeat_healing_spring_rescues/Run()
	var/turf/spring_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/structure/well/fountain/healing/spring = allocate(/obj/structure/well/fountain/healing, spring_turf)
	var/turf/victim_turf = get_step(spring_turf, EAST)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, victim_turf)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)

	spring.process(1)
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "A healing spring should free a defeated mob lingering beside it.")

/datum/unit_test/defeat_holy_communion_rescues_downed

/datum/unit_test/defeat_holy_communion_rescues_downed/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/saint = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, saint, run_loc_floor_bottom_left)
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	ADD_TRAIT(saint, TRAIT_HOLY, TRAIT_GENERIC)

	monitor.on_climax(victim, null, victim, saint, saint)
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "A holy character's communion should free a downed victim.")

	var/mob/living/carbon/human/victim_two = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/layperson = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim_two, layperson, run_loc_floor_bottom_left)
	var/datum/component/defeat_monitor/monitor_two = victim_two.AddComponent(/datum/component/defeat_monitor)
	victim_two.apply_status_effect(/datum/status_effect/defeat_knockout)

	monitor_two.on_climax(victim_two, null, victim_two, layperson, layperson)
	TEST_ASSERT_NOTNULL(victim_two.has_status_effect(/datum/status_effect/defeat_knockout), "A non-holy partner's climax should not free the victim.")

/datum/unit_test/defeat_monitor_attaches_once_controlled

/datum/unit_test/defeat_monitor_attaches_once_controlled/Run()
	var/mob/living/carbon/human/player = allocate(/mob/living/carbon/human)
	player.defeat_mode = DEFEAT_MODE_KO_RUNE
	// Mirrors apply_prefs_to running before the client/mind is attached: not yet eligible -> no monitor.
	player.ensure_defeat_monitor()
	TEST_ASSERT_NULL(player.GetComponent(/datum/component/defeat_monitor), "Without a client or mind, the monitor must not attach (the spawn-time pref-cache case). mind=[player.mind || "null"] client=[player.client || "null"] ai_opt_in=[player.defeat_system_ai_opt_in] horny_enabled=[player.mob_horny_defeat_enabled] mode=[player.defeat_mode]")

	// Once the player actually controls the body (as at Login), it must attach.
	player.mind = allocate(/datum/mind, "defeat-monitor-attach-test")
	player.mind.current = player
	player.ensure_defeat_monitor()
	TEST_ASSERT_NOTNULL(player.GetComponent(/datum/component/defeat_monitor), "With a mind present, ensure_defeat_monitor must attach the defeat monitor.")

	player.mind.current = null
	player.mind = null

/datum/unit_test/defeat_pet_rescues_downed_ally

/datum/unit_test/defeat_pet_rescues_downed_ally/Run()
	var/mob/living/carbon/human/pet = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/fallen = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(fallen, pet, run_loc_floor_bottom_left)
	fallen.apply_status_effect(/datum/status_effect/defeat_knockout)

	TEST_ASSERT(fallen.defeat_can_be_rescued_by(pet), "A loyal companion beside a downed ally should qualify for the manual recovery channel.")
	TEST_ASSERT_NOTNULL(fallen.has_status_effect(/datum/status_effect/defeat_knockout), "Companion eligibility alone must not bypass the manual recovery channel.")

	var/mob/living/carbon/human/standing = allocate(/mob/living/carbon/human)
	standing.forceMove(get_turf(pet))
	TEST_ASSERT(!pet.try_rescue_downed_ally(standing), "A pet cannot 'rescue' someone who is not defeated.")

/datum/unit_test/defeat_revive_time_scales_with_medicine

/datum/unit_test/defeat_revive_time_scales_with_medicine/Run()
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)

	medic.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_NONE, TRUE)
	TEST_ASSERT_EQUAL(medic.defeat_revive_time(), DEFEAT_REVIVE_TIME_MAX, "No medical skill should take the longest to revive.")

	medic.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_LEGENDARY, TRUE)
	TEST_ASSERT_EQUAL(medic.defeat_revive_time(), DEFEAT_REVIVE_TIME_MIN, "Legendary medicine should revive fastest.")

	medic.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_JOURNEYMAN, TRUE)
	var/mid = medic.defeat_revive_time()
	TEST_ASSERT(mid > DEFEAT_REVIVE_TIME_MIN && mid < DEFEAT_REVIVE_TIME_MAX, "Middling medicine should land between the extremes.")

/datum/unit_test/defeat_recovery_profiles_are_explicit

/datum/unit_test/defeat_recovery_profiles_are_explicit/Run()
	var/datum/defeat_recovery_profile/manual/manual = allocate(/datum/defeat_recovery_profile/manual)
	var/datum/defeat_recovery_profile/prepared/prepared = allocate(/datum/defeat_recovery_profile/prepared)
	var/datum/defeat_recovery_profile/campfire/campfire = allocate(/datum/defeat_recovery_profile/campfire)
	var/datum/defeat_recovery_profile/self_recovery/self_recovery = allocate(/datum/defeat_recovery_profile/self_recovery)
	var/datum/defeat_recovery_profile/environmental/environmental = allocate(/datum/defeat_recovery_profile/environmental)
	var/datum/defeat_recovery_profile/rune/rune = allocate(/datum/defeat_recovery_profile/rune)

	TEST_ASSERT_EQUAL(manual.profile_id, DEFEAT_RECOVERY_MANUAL, "Empty-handed rescue should use the universal manual profile.")
	TEST_ASSERT(manual.requires_helper, "Manual rescue should require another living helper.")
	TEST_ASSERT(manual.helper_stamina_cost > 0, "Manual rescue should tax the helper's stamina on success.")
	TEST_ASSERT_EQUAL(manual.aftermath_severity, DEFEAT_SEVERITY_NORMAL, "Manual rescue should leave moderate aftermath.")
	TEST_ASSERT_EQUAL(prepared.aftermath_severity, DEFEAT_SEVERITY_LIGHT, "Prepared rescue should reward preparation with light aftermath.")
	TEST_ASSERT_EQUAL(prepared.profile_id, DEFEAT_RECOVERY_PREPARED, "Prepared care should have an explicit profile.")
	TEST_ASSERT(!prepared.requires_adjacent_helper, "Prepared care should allow range-capable completed treatments to recover a distant victim.")
	TEST_ASSERT_EQUAL(campfire.profile_id, DEFEAT_RECOVERY_CAMPFIRE, "Campfire recovery should have a reusable profile before its interaction is added.")
	TEST_ASSERT_EQUAL(self_recovery.profile_id, DEFEAT_RECOVERY_SELF, "Self recovery should have an explicit profile.")
	TEST_ASSERT_EQUAL(environmental.profile_id, DEFEAT_RECOVERY_ENVIRONMENTAL, "Environmental recovery should have an explicit profile.")
	TEST_ASSERT_EQUAL(rune.profile_id, DEFEAT_RECOVERY_RUNE, "Rune return should have an explicit profile.")

/datum/unit_test/defeat_prepared_recovery_allows_range

/datum/unit_test/defeat_prepared_recovery_allows_range/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	var/turf/victim_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/helper_turf = get_step(get_step(victim_turf, EAST), EAST)
	victim.forceMove(victim_turf)
	helper.forceMove(helper_turf)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)

	TEST_ASSERT(!victim.defeat_can_be_rescued_by(helper), "The ranged prepared-care test must keep its helper outside manual rescue range.")
	TEST_ASSERT(victim.begin_defeat_recovery(/datum/defeat_recovery_profile/prepared, helper, "ranged prepared unit test"), "A completed range-capable prepared treatment should recover a non-adjacent victim.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Ranged prepared care should clear Defeat knockout through the shared finalizer.")

/datum/unit_test/defeat_priority_recovery_replaces_active_channel

/datum/unit_test/defeat_priority_recovery_replaces_active_channel/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	var/datum/defeat_recovery_resource_tracker/tracker = allocate(/datum/defeat_recovery_resource_tracker)
	var/datum/defeat_recovery_profile/unit_test_resources/old_profile = new
	var/datum/defeat_recovery_channel/old_channel = new(old_profile, victim, null, "old channel", tracker)
	TEST_ASSERT(old_profile.reserve_resources(old_channel), "Setup: the replaced channel should reserve its resource.")
	old_channel.resources_reserved = TRUE
	old_channel.active = TRUE
	victim.defeat_recovery_channel = old_channel

	var/datum/defeat_recovery_profile/rune/rune_profile = new
	rune_profile.additional_aftermath_severity = DEFEAT_SEVERITY_LIGHT
	TEST_ASSERT(victim.perform_defeat_rescue(null, "priority rune unit test", rune_profile), "A one-shot rune recovery should replace an unfinished lower-priority channel.")
	TEST_ASSERT_EQUAL(tracker.releases, 1, "Replacing a channel must roll back its unconsumed reservation exactly once.")
	TEST_ASSERT_EQUAL(tracker.consumptions, 0, "A replaced channel must not consume its reservation.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Successful priority recovery must leave the victim awake.")
	var/datum/status_effect/debuff/defeat/rune/rune_aftermath = victim.has_status_effect(/datum/status_effect/debuff/defeat/rune)
	TEST_ASSERT_NOTNULL(rune_aftermath, "The rune profile should apply its declared Defeat aftermath.")
	TEST_ASSERT_EQUAL(rune_aftermath.severity, DEFEAT_SEVERITY_LIGHT, "Rune aftermath severity must come from profile data.")
	TEST_ASSERT(!victim.perform_defeat_rescue(null, "duplicate rune", /datum/defeat_recovery_profile/rune), "A one-shot recovery must report failure once the victim is already awake.")
	qdel(old_channel)

/datum/unit_test/defeat_manual_channel_interruption_tax_and_aftermath

/datum/unit_test/defeat_manual_channel_interruption_tax_and_aftermath/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, helper, run_loc_floor_bottom_left)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	var/stamina_before = helper.stamina
	TEST_ASSERT(victim.begin_defeat_recovery(/datum/defeat_recovery_profile/manual/unit_test_instant, helper, "manual success"), "The zero-time test subtype should exercise the manual channel finalizer without a slow test.")
	TEST_ASSERT(helper.stamina >= stamina_before + DEFEAT_MANUAL_HELPER_STAMINA_COST, "Successful manual recovery should tax the helper.")
	var/datum/status_effect/debuff/defeat/manual_aftermath
	for(var/datum/status_effect/debuff/defeat/trauma as anything in victim.status_effects)
		if(trauma.trauma_category != DEFEAT_TRAUMA_CATEGORY_PHYSICAL)
			continue
		manual_aftermath = trauma
		break
	TEST_ASSERT_NOTNULL(manual_aftermath, "Manual recovery should apply one physical Defeat aftermath selected from the snapshot.")
	TEST_ASSERT_EQUAL(manual_aftermath.severity, DEFEAT_SEVERITY_NORMAL, "Manual recovery should use the profile's moderate aftermath.")

	var/mob/living/carbon/human/interrupted_victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/interrupted_helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(interrupted_victim, interrupted_helper, run_loc_floor_bottom_left)
	interrupted_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/datum/defeat_recovery_profile/manual/unit_test_instant/interrupted_profile = new
	var/datum/defeat_recovery_channel/interrupted_channel = new(interrupted_profile, interrupted_victim, interrupted_helper, "interrupted manual")
	interrupted_channel.resources_reserved = TRUE
	interrupted_channel.active = TRUE
	interrupted_victim.defeat_recovery_channel = interrupted_channel
	interrupted_channel.register_interrupt_signals()
	var/interrupted_stamina_before = interrupted_helper.stamina
	var/obj/item/manual_attack_weapon = allocate(/obj/item)
	manual_attack_weapon.force = 10
	SEND_SIGNAL(interrupted_helper, COMSIG_ATOM_ATTACKBY, manual_attack_weapon, interrupted_victim, list())
	TEST_ASSERT(!interrupted_channel.active, "Damage to a recovery participant should cancel the manual channel.")
	TEST_ASSERT_NOTNULL(interrupted_victim.has_status_effect(/datum/status_effect/defeat_knockout), "An interrupted manual channel must leave the victim defeated.")
	TEST_ASSERT_EQUAL(interrupted_helper.stamina, interrupted_stamina_before, "An interrupted manual channel must not charge the success-only helper tax.")
	qdel(interrupted_channel)

/datum/unit_test/defeat_recovery_resource_consume_and_rollback

/datum/unit_test/defeat_recovery_resource_consume_and_rollback/Run()
	var/mob/living/carbon/human/completed_victim = allocate(/mob/living/carbon/human)
	completed_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/datum/defeat_recovery_resource_tracker/completed_tracker = allocate(/datum/defeat_recovery_resource_tracker)
	var/datum/defeat_recovery_profile/unit_test_resources/completed_profile = new
	TEST_ASSERT(completed_victim.perform_defeat_rescue(null, "resource completion", completed_profile, completed_tracker), "A valid resource-backed recovery should complete.")
	TEST_ASSERT_EQUAL(completed_tracker.reservations, 1, "Successful recovery should reserve its resource once.")
	TEST_ASSERT_EQUAL(completed_tracker.consumptions, 1, "Successful recovery should consume its resource once.")
	TEST_ASSERT_EQUAL(completed_tracker.releases, 0, "Consumed resources must not be rolled back during channel destruction.")

	var/mob/living/carbon/human/cancelled_victim = allocate(/mob/living/carbon/human)
	cancelled_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/datum/defeat_recovery_resource_tracker/cancelled_tracker = allocate(/datum/defeat_recovery_resource_tracker)
	var/datum/defeat_recovery_profile/unit_test_resources/cancelled_profile = new
	var/datum/defeat_recovery_channel/cancelled_channel = new(cancelled_profile, cancelled_victim, null, "resource cancellation", cancelled_tracker)
	TEST_ASSERT(cancelled_profile.reserve_resources(cancelled_channel), "Setup: the cancelled channel should reserve its resource.")
	cancelled_channel.resources_reserved = TRUE
	cancelled_channel.active = TRUE
	cancelled_victim.defeat_recovery_channel = cancelled_channel
	TEST_ASSERT(cancelled_channel.cancel(), "An active resource-backed recovery should be cancellable.")
	qdel(cancelled_channel)
	TEST_ASSERT_EQUAL(cancelled_tracker.reservations, 1, "Cancelled recovery should reserve only once.")
	TEST_ASSERT_EQUAL(cancelled_tracker.consumptions, 0, "Cancelled recovery must not consume its resource.")
	TEST_ASSERT_EQUAL(cancelled_tracker.releases, 1, "Cancelled recovery should roll back its reservation exactly once.")

/datum/unit_test/defeat_campfire_requires_crafted_lit_fueled_source

/datum/unit_test/defeat_campfire_requires_crafted_lit_fueled_source/Run()
	var/turf/fire_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/light/fueled/campfire/campfire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, get_step(fire_turf, NORTH))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(fire_turf, EAST))
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/datum/defeat_recovery_profile/campfire/profile = new
	var/datum/defeat_recovery_channel/channel = new(profile, victim, null, "campfire eligibility", campfire)

	TEST_ASSERT(!profile.can_recover(channel), "A mapped or otherwise non-crafted campfire must not recover defeated characters.")
	campfire.OnCrafted(null, builder)
	TEST_ASSERT(!campfire.player_built, "Construction without a player-controlled crafter must not qualify a campfire for recovery.")
	TEST_ASSERT(campfire.can_damage, "Campfire OnCrafted must preserve the fueled-light parent behavior.")
	TEST_ASSERT(!campfire.on, "Campfire OnCrafted must preserve the parent's initial burn-out behavior.")
	builder.mind = allocate(/datum/mind, "campfire-eligibility-builder")
	builder.mind.current = builder
	campfire.OnCrafted(null, builder)
	TEST_ASSERT(campfire.player_built, "OnCrafted should mark a campfire made by a player-controlled living crafter.")
	campfire.fire_act()
	TEST_ASSERT(profile.can_recover(channel), "A crafted, lit, fueled campfire should qualify while the victim rests beside it.")
	campfire.burn_out()
	TEST_ASSERT(!profile.can_recover(channel), "An extinguished campfire must not qualify for recovery.")
	qdel(channel)

/datum/unit_test/defeat_campfire_passive_completion_and_tending_speed

/datum/unit_test/defeat_campfire_passive_completion_and_tending_speed/Run()
	var/turf/fire_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/light/fueled/campfire/campfire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, get_step(fire_turf, NORTH))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(fire_turf, EAST))
	builder.mind = allocate(/datum/mind, "campfire-passive-builder")
	builder.mind.current = builder
	campfire.OnCrafted(null, builder)
	campfire.fire_act()
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)

	TEST_ASSERT(victim.begin_defeat_recovery(/datum/defeat_recovery_profile/campfire/unit_test_instant, null, "instant passive campfire test", campfire), "The zero-time test profile should complete passive campfire recovery through the shared finalizer.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Completed passive campfire recovery should wake the victim.")
	TEST_ASSERT_NULL(victim.defeat_recovery_channel, "Completed passive campfire recovery should clean the victim-owned channel.")
	TEST_ASSERT_NULL(campfire.defeat_recovery_channels, "Completed passive campfire recovery should clean the fire's weak registry.")

	var/mob/living/carbon/human/progress_victim = allocate(/mob/living/carbon/human, get_step(fire_turf, EAST))
	progress_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(campfire.begin_passive_defeat_recovery(progress_victim), "Passive campfire recovery should start without asking the incapacitated victim to perform a do_after.")
	TEST_ASSERT_NOTNULL(progress_victim.defeat_recovery_channel?.passive_completion_timer, "Passive progress should be owned by a stoppable recovery-channel timer.")
	TEST_ASSERT(progress_victim.defeat_recovery_channel.active, "A started passive timer should leave an active victim-owned recovery channel.")
	progress_victim.cancel_defeat_recovery()
	QDEL_NULL(progress_victim.defeat_recovery_channel)

	var/datum/defeat_recovery_profile/campfire/passive_profile = allocate(/datum/defeat_recovery_profile/campfire)
	var/datum/defeat_recovery_profile/campfire/tended/tended_profile = allocate(/datum/defeat_recovery_profile/campfire/tended)
	var/datum/defeat_recovery_channel/passive_channel = new(passive_profile, victim, null, "passive timing", campfire)
	var/datum/defeat_recovery_channel/tended_channel = new(tended_profile, victim, builder, "tended timing", campfire)
	TEST_ASSERT(passive_profile.uses_passive_timer, "Passive campfire recovery must use non-interaction timer semantics.")
	TEST_ASSERT(!tended_profile.uses_passive_timer, "Tended campfire recovery should use the helper-owned interruptible interaction.")
	TEST_ASSERT(passive_profile.recovery_time(passive_channel) > tended_profile.recovery_time(tended_channel), "Active ally tending should be substantially faster than passive campfire recovery.")
	qdel(passive_channel)
	qdel(tended_channel)

/datum/unit_test/defeat_campfire_channel_interruptions_and_duplicates

/datum/unit_test/defeat_campfire_channel_interruptions_and_duplicates/Run()
	var/turf/fire_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/light/fueled/campfire/campfire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, get_step(fire_turf, NORTH))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(fire_turf, EAST))
	helper.mind = allocate(/datum/mind, "campfire-interruption-builder")
	helper.mind.current = helper
	campfire.OnCrafted(null, helper)
	campfire.fire_act()
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)

	TEST_ASSERT(campfire.begin_passive_defeat_recovery(victim), "Setup: the victim should begin a real timer-backed passive recovery.")
	var/datum/defeat_recovery_channel/movement_channel = victim.defeat_recovery_channel
	var/original_passive_timer = movement_channel.passive_completion_timer
	TEST_ASSERT(!victim.begin_defeat_recovery(/datum/defeat_recovery_profile/campfire/unit_test_instant, null, "duplicate campfire", campfire), "A victim must not start a duplicate campfire recovery channel.")
	victim.recent_damage_source_attacker_weakref = WEAKREF(helper)
	victim.recent_damage_source_time = world.time
	TEST_ASSERT(!campfire.begin_tended_defeat_recovery(victim, helper), "A hostile or otherwise ineligible helper must not replace passive campfire recovery.")
	TEST_ASSERT(victim.defeat_recovery_channel == movement_channel, "Rejected tending must leave the original passive channel in place.")
	TEST_ASSERT_EQUAL(movement_channel.passive_completion_timer, original_passive_timer, "Rejected tending must not reset passive recovery progress.")
	TEST_ASSERT(movement_channel.active, "Rejected tending must leave passive recovery active.")
	victim.recent_damage_source_attacker_weakref = null
	victim.recent_damage_source_time = 0
	victim.forceMove(get_step(get_turf(victim), EAST))
	TEST_ASSERT_NULL(victim.defeat_recovery_channel, "Movement cancellation should clean the victim-owned channel.")

	victim.forceMove(get_step(fire_turf, EAST))
	var/datum/defeat_recovery_profile/campfire/tended/damage_profile = new
	var/datum/defeat_recovery_channel/damage_channel = new(damage_profile, victim, helper, "damage interruption", campfire)
	damage_channel.resources_reserved = TRUE
	damage_channel.active = TRUE
	damage_channel.channel_started = TRUE
	victim.defeat_recovery_channel = damage_channel
	damage_profile.on_channel_started(damage_channel)
	damage_channel.register_interrupt_signals()
	TEST_ASSERT(HAS_TRAIT(helper, TRAIT_RELAYING_ATTACKER), "An active recovery channel should attach the repository's attack relay to its helper.")
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, get_step(fire_turf, WEST))
	var/obj/item/test_weapon = allocate(/obj/item)
	test_weapon.force = 10
	SEND_SIGNAL(helper, COMSIG_ATOM_ATTACKBY, test_weapon, attacker, list())
	TEST_ASSERT(!damage_channel.active, "A real relayed hostile attack should interrupt tended campfire recovery.")
	qdel(damage_channel)
	TEST_ASSERT(!HAS_TRAIT(helper, TRAIT_RELAYING_ATTACKER), "Recovery cleanup should remove the attack relay it attached.")

	var/datum/defeat_recovery_profile/campfire/fire_profile = new
	var/datum/defeat_recovery_channel/fire_channel = new(fire_profile, victim, null, "fire interruption", campfire)
	fire_channel.resources_reserved = TRUE
	fire_channel.active = TRUE
	fire_channel.channel_started = TRUE
	victim.defeat_recovery_channel = fire_channel
	fire_profile.on_channel_started(fire_channel)
	campfire.burn_out()
	TEST_ASSERT_NULL(victim.defeat_recovery_channel, "Extinguishing or exhausting the fire should cancel and clean its registered recovery channel.")
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Interrupted campfire recovery must leave the victim defeated.")

/datum/unit_test/defeat_campfire_qdel_cleanup

/datum/unit_test/defeat_campfire_qdel_cleanup/Run()
	var/turf/fire_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/light/fueled/campfire/source_fire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, get_step(fire_turf, NORTH))
	var/mob/living/carbon/human/source_victim = allocate(/mob/living/carbon/human, get_step(fire_turf, EAST))
	builder.mind = allocate(/datum/mind, "campfire-qdel-builder")
	builder.mind.current = builder
	source_fire.OnCrafted(null, builder)
	source_fire.fire_act()
	source_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/datum/defeat_recovery_profile/campfire/source_profile = new
	var/datum/defeat_recovery_channel/source_channel = new(source_profile, source_victim, null, "source qdel", source_fire)
	source_channel.resources_reserved = TRUE
	source_channel.active = TRUE
	source_channel.channel_started = TRUE
	source_victim.defeat_recovery_channel = source_channel
	source_profile.on_channel_started(source_channel)
	qdel(source_fire)
	TEST_ASSERT_NULL(source_victim.defeat_recovery_channel, "Deleting a campfire should clean the victim-owned recovery channel.")

	var/obj/machinery/light/fueled/campfire/target_fire = allocate(/obj/machinery/light/fueled/campfire, fire_turf)
	var/mob/living/carbon/human/target_victim = allocate(/mob/living/carbon/human, get_step(fire_turf, EAST))
	target_fire.OnCrafted(null, builder)
	target_fire.fire_act()
	target_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	var/datum/defeat_recovery_profile/campfire/target_profile = new
	var/datum/defeat_recovery_channel/target_channel = new(target_profile, target_victim, null, "target qdel", target_fire)
	target_channel.resources_reserved = TRUE
	target_channel.active = TRUE
	target_channel.channel_started = TRUE
	target_victim.defeat_recovery_channel = target_channel
	target_profile.on_channel_started(target_channel)
	qdel(target_victim)
	TEST_ASSERT_NULL(target_fire.defeat_recovery_channels, "Deleting a resting victim should remove its weak channel from the campfire.")

/datum/unit_test/defeat_recovery_finalizer_emits_once
	var/rescue_signal_count = 0

/datum/unit_test/defeat_recovery_finalizer_emits_once/Destroy()
	rescue_signal_count = 0
	return ..()

/datum/unit_test/defeat_recovery_finalizer_emits_once/proc/on_recovered(datum/source, mob/living/helper, rescue_source)
	SIGNAL_HANDLER
	rescue_signal_count++

/datum/unit_test/defeat_recovery_finalizer_emits_once/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, helper, run_loc_floor_bottom_left)
	victim.defeat_system_ai_opt_in = TRUE
	victim.setBruteLoss(200, FALSE, TRUE)
	victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)
	RegisterSignal(victim, COMSIG_LIVING_DEFEAT_RESCUED, PROC_REF(on_recovered))

	TEST_ASSERT(victim.begin_defeat_recovery(/datum/defeat_recovery_profile/prepared, helper, "prepared unit test"), "Prepared care should complete through the recovery profile entrypoint.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "The shared finalizer should remove Defeat knockout.")
	TEST_ASSERT_NULL(victim.defeat_recovery_channel, "A completed recovery must release its active channel reference.")
	TEST_ASSERT_EQUAL(rescue_signal_count, 1, "One successful recovery should emit exactly one rescued signal.")
	TEST_ASSERT(!victim.begin_defeat_recovery(/datum/defeat_recovery_profile/prepared, helper, "duplicate unit test"), "An awake victim cannot complete the recovery finalizer twice.")
	TEST_ASSERT_EQUAL(rescue_signal_count, 1, "A rejected duplicate recovery must not emit another rescued signal.")
	UnregisterSignal(victim, COMSIG_LIVING_DEFEAT_RESCUED)

/datum/unit_test/defeat_bandage_stabilizes_without_waking

/datum/unit_test/defeat_bandage_stabilizes_without_waking/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(victim, helper, run_loc_floor_bottom_left)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.blood_volume = BLOOD_VOLUME_SURVIVE - 1
	victim.setOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH - 1)

	TEST_ASSERT(victim.defeat_stabilize_from_healing(helper, "bandage"), "Bandaging should perform the bounded recovery safety pass while the victim is defeated.")
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "A bandage must not independently wake a defeated victim.")
	TEST_ASSERT(victim.blood_volume >= DEFEAT_BLOOD_VOLUME_MINIMUM, "Bandage stabilization should restore the safe blood minimum.")
	TEST_ASSERT(victim.getOrganLoss(ORGAN_SLOT_BRAIN) <= DEFEAT_BRAIN_DAMAGE_MAX, "Bandage stabilization should clear immediate brain danger.")

/datum/unit_test/defeat_rescue_clears_lethal_conditions

/datum/unit_test/defeat_rescue_clears_lethal_conditions/Run()
	// Brain damage can attempt to kill synchronously from the organ setter, before updatehealth(). The
	// health-signal preflight must enter Defeat and establish every safety margin immediately.
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.AddComponent(/datum/component/defeat_monitor)
	victim.blood_volume = BLOOD_VOLUME_SURVIVE
	victim.setOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH)
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Brain-death organ damage should enter Defeat before owner.death() finalizes.")
	TEST_ASSERT(victim.stat != DEAD, "The synchronous brain-death path should leave the victim defeated, not dead.")
	TEST_ASSERT_EQUAL(victim.getOrganLoss(ORGAN_SLOT_BRAIN), DEFEAT_BRAIN_DAMAGE_MAX, "Defeat entry immediately clears brain damage to the configured safety margin.")
	TEST_ASSERT_EQUAL(victim.blood_volume, DEFEAT_BLOOD_VOLUME_MINIMUM, "Defeat entry immediately restores the configured safe minimum blood volume.")

	victim.perform_defeat_rescue(null, "unit-test")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "The rescue clears the knockout.")
	TEST_ASSERT_EQUAL(victim.getOrganLoss(ORGAN_SLOT_BRAIN), DEFEAT_BRAIN_DAMAGE_MAX, "Recovery idempotently preserves the entry brain-damage safety margin.")
	TEST_ASSERT_EQUAL(victim.blood_volume, DEFEAT_BLOOD_VOLUME_MINIMUM, "Recovery idempotently preserves the entry blood-volume safety margin.")
	TEST_ASSERT(!victim.defeat_is_near_death(), "A rescued victim is no longer near-death, so it will not instantly re-trigger defeat.")

	// A clean follow-up recomputation must be stable: no death and no immediate fresh Defeat.
	victim.updatehealth()
	TEST_ASSERT(victim.stat != DEAD, "One health/life recomputation after recovery must not kill the victim without new harm.")
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "One clean recomputation after recovery must not immediately re-enter Defeat.")

/datum/unit_test/defeat_followup_damage_reapplies_bounded_safety

/datum/unit_test/defeat_followup_damage_reapplies_bounded_safety/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.defeat_damage_threshold = 100
	victim.AddComponent(/datum/component/defeat_monitor)
	victim.setToxLoss(100)
	var/datum/defeat_snapshot/first_snapshot = victim.last_defeat_snapshot
	TEST_ASSERT_NOTNULL(first_snapshot, "Setup: threshold damage should enter Defeat.")

	victim.setToxLoss(200)
	TEST_ASSERT(victim.stat != DEAD, "Follow-up damage while defeated must be clamped before ordinary death finalization.")
	TEST_ASSERT_EQUAL(victim.last_defeat_snapshot, first_snapshot, "Follow-up damage must not create a second Defeat snapshot or revive loop.")
	TEST_ASSERT(victim.getToxLoss() <= victim.defeat_damage_safety_cap() * DEFEAT_DAMAGE_POOL_CAP_FRACTION, "Follow-up damage should reapply the bounded scalar-pool cap.")

/datum/unit_test/defeat_admin_heal_clears_ko_and_traumas

/datum/unit_test/defeat_admin_heal_clears_ko_and_traumas/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.apply_status_effect(/datum/status_effect/defeat_knockout)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/grievous, null, DEFEAT_SEVERITY_SEVERE)

	// A clinic/potion full-heal (HEAL_ALL excludes HEAL_ADMIN) must leave the defeat state intact -
	// traumas are meant to fester through ordinary healing.
	patient.fully_heal(HEAL_ALL)
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "A non-admin full heal keeps the knockout.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical), "A non-admin full heal keeps physical trauma.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "A non-admin full heal keeps grievous wounds.")

	// An admin full-heal is a clean reset: knockout and every trauma are wiped.
	patient.fully_heal(ADMIN_HEAL_ALL)
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "Admin heal removes the knockout.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical), "Admin heal removes physical trauma.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "Admin heal removes grievous wounds.")

/datum/unit_test/defeat_rune_heal_preserves_defeat_state

/datum/unit_test/defeat_rune_heal_preserves_defeat_state/Run()
	// The rune sets defeat_suppress_heal_cleanup around its own ADMIN_HEAL_ALL revive so it can run its
	// own teardown (manual KO removal + escalating aftermath trauma). While the flag is up, an admin-flag
	// heal must NOT auto-wipe the defeat state; with it down, it must.
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.apply_status_effect(/datum/status_effect/defeat_knockout)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_NORMAL)

	patient.defeat_suppress_heal_cleanup = TRUE
	patient.fully_heal(ADMIN_HEAL_ALL)
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "A suppressed admin heal (rune path) keeps the knockout for the rune's own teardown.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical), "A suppressed admin heal keeps the prior trauma so the rune's aftermath can escalate it.")

	patient.defeat_suppress_heal_cleanup = FALSE
	patient.fully_heal(ADMIN_HEAL_ALL)
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/defeat_knockout), "Once suppression is lifted, an admin heal resets the knockout.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/physical), "Once suppression is lifted, an admin heal resets traumas.")

// A requirement-free, spellblock-ignoring test spell, so the only thing that can block it in the test
// below is the defeat knockout itself. Nameless + INVOCATION_NONE, so it is skipped by the spell name
// and invocation validators.
/datum/action/cooldown/spell/defeat_ko_cast_test
	charge_required = FALSE
	spell_requirements = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK

/datum/unit_test/defeat_knockout_blocks_spellcasting

/datum/unit_test/defeat_knockout_blocks_spellcasting/Run()
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human)
	var/datum/action/cooldown/spell/defeat_ko_cast_test/spell = allocate(/datum/action/cooldown/spell/defeat_ko_cast_test)
	spell.Grant(caster)
	TEST_ASSERT(spell.can_cast_spell(FALSE), "Baseline: a requirement-free spell should be castable before defeat.")

	caster.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(!spell.can_cast_spell(FALSE), "A defeat knockout must block spellcasting, even for a spell that ignores spellblock.")

	caster.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(spell.can_cast_spell(FALSE), "Clearing the knockout should restore spellcasting.")

// --- Mob horny-defeat KO (clientless mobs) ---

/datum/unit_test/mob_horny_defeat_eligibility

/datum/unit_test/mob_horny_defeat_eligibility/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)

	TEST_ASSERT(!beast.horny_defeat_is_eligible(), "A clientless mob without the flag must not be horny-defeat eligible.")

	beast.mob_horny_defeat_enabled = TRUE
	TEST_ASSERT(beast.horny_defeat_is_eligible(), "A clientless mob with the flag must be horny-defeat eligible.")

	beast.ensure_defeat_monitor()
	TEST_ASSERT_NOTNULL(beast.GetComponent(/datum/component/defeat_monitor), "Enabling a clientless mob must let ensure_defeat_monitor attach the monitor.")

/datum/unit_test/mob_horny_ko_cleanup_deletes_when_alone

/datum/unit_test/mob_horny_ko_cleanup_deletes_when_alone/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)
	beast.mob_horny_defeat_enabled = TRUE

	var/datum/status_effect/mob_horny_knockout/ko = beast.apply_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT_NOTNULL(ko, "Applying the mob horny knockout must return the status effect instance.")
	TEST_ASSERT(HAS_TRAIT(beast, TRAIT_IMMOBILIZED), "The mob horny knockout must immobilize the mob.")

	// No client mobs exist in the unit-test world, so the mob is 'alone' and cleanup must delete it.
	ko.mob_horny_ko_cleanup_check()
	TEST_ASSERT(QDELETED(beast), "With no players nearby the KO cleanup must delete the downed mob.")

/datum/unit_test/enter_mob_horny_defeat_applies_ko

/datum/unit_test/enter_mob_horny_defeat_applies_ko/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)
	var/mob/living/carbon/human/aggressor = allocate(/mob/living/carbon/human)

	beast.mob_horny_defeat_enabled = TRUE

	TEST_ASSERT(beast.enter_mob_horny_defeat(aggressor), "A flagged clientless mob should enter the mob horny KO.")
	TEST_ASSERT_NOTNULL(beast.has_status_effect(/datum/status_effect/mob_horny_knockout), "Entering mob horny defeat should apply the mob knockout status.")

	TEST_ASSERT(!beast.enter_mob_horny_defeat(aggressor), "A mob already in horny KO should not re-enter it.")

/datum/unit_test/mob_horny_ko_pauses_ai_and_frees_hold

/datum/unit_test/mob_horny_ko_pauses_ai_and_frees_hold/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)
	var/mob/living/carbon/human/prey = allocate(/mob/living/carbon/human)
	beast.mob_horny_defeat_enabled = TRUE
	beast.start_handless_pull(prey, GRAB_PASSIVE, MOVE_FORCE_OVERPOWERING, suppress_message = TRUE)
	TEST_ASSERT_EQUAL(beast.pulling, prey, "Setup: the beast should be holding its prey.")

	beast.apply_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT(HAS_TRAIT(beast, TRAIT_AI_PAUSED), "The mob KO must pause the AI through the trait, not a bare status change.")
	TEST_ASSERT_NULL(beast.pulling, "A spent mob must let go of what it holds.")

	beast.remove_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT(!HAS_TRAIT(beast, TRAIT_AI_PAUSED), "Waking must lift the AI pause.")

/datum/unit_test/mob_horny_ko_help_up_and_carry

/datum/unit_test/mob_horny_ko_help_up_and_carry/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	beast.mob_horny_defeat_enabled = TRUE
	beast.living_flags &= ~CAN_BE_FIREMANNED

	TEST_ASSERT(!helper.can_be_firemanned(beast), "An awake creature without the carry flag must not be liftable.")
	TEST_ASSERT(!beast.try_mob_horny_ko_help_up(helper), "Help-up must not use the click on an awake mob.")

	beast.apply_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT(helper.can_be_firemanned(beast), "Any spent creature must be liftable.")
	TEST_ASSERT(beast.confirm_mob_horny_ko_lift(helper), "A clientless lifter gets no popup and may lift.")

	TEST_ASSERT(beast.try_mob_horny_ko_help_up(helper), "Help-up must use the click on a spent mob.")
	TEST_ASSERT_NULL(beast.has_status_effect(/datum/status_effect/mob_horny_knockout), "A finished help-up must end the mob KO.")

/datum/unit_test/mob_horny_ko_bonds_stay_docile

/datum/unit_test/mob_horny_ko_bonds_stay_docile/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/obj/item/rope/arm_rope = allocate(/obj/item/rope)
	var/obj/item/rope/leg_rope = allocate(/obj/item/rope)
	var/mob/living/carbon/human/carrier = allocate(/mob/living/carbon/human)
	goblin.mob_horny_defeat_enabled = TRUE

	goblin.apply_status_effect(/datum/status_effect/mob_horny_knockout)
	arm_rope.apply_cuffs(goblin, null)
	TEST_ASSERT_EQUAL(goblin.handcuffed, arm_rope, "Setup: the goblin should be tied while spent.")
	TEST_ASSERT(!goblin.roll_mob_horny_ko_lash_out(carrier), "A mob with tied arms must never lash out when lifted.")

	goblin.remove_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT(goblin.restraints_all_docile(), "Bonds put on while spent must be accepted on waking.")
	goblin.cuff_resist(arm_rope, instant = TRUE)
	TEST_ASSERT_EQUAL(goblin.handcuffed, arm_rope, "A docile mob must not break the bonds it woke up in.")

	leg_rope.apply_cuffs(goblin, null, leg = TRUE)
	TEST_ASSERT(!goblin.restraints_all_docile(), "Fresh bonds put on an awake mob are fought as usual.")

/datum/unit_test/defeat_keyless_npc_mind_not_eligible

/datum/unit_test/defeat_keyless_npc_mind_not_eligible/Run()
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human)
	npc.mind = allocate(/datum/mind)
	npc.mind.current = npc
	TEST_ASSERT(!npc.defeat_system_is_eligible(), "An NPC with a keyless mind must not get the regular defeat KO.")

	npc.mind.key = "defeat-keyless-npc-player"
	TEST_ASSERT(npc.defeat_system_is_eligible(), "A keyed mind is a player and keeps the regular defeat KO.")
	npc.mind.current = null
	npc.mind = null

/datum/unit_test/mob_horny_defeat_ko_after_threshold

/datum/unit_test/mob_horny_defeat_ko_after_threshold/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)
	var/mob/living/carbon/human/aggressor = allocate(/mob/living/carbon/human)

	beast.mob_horny_defeat_enabled = TRUE
	var/datum/component/defeat_monitor/monitor = beast.AddComponent(/datum/component/defeat_monitor)
	monitor.horny_defeat_climax_threshold = 2 // pin the roll so the test is deterministic

	// action_receiver = beast (the climaxing victim), action_partner/performer = the external aggressor.
	SEND_SIGNAL(beast, COMSIG_SEX_CLIMAX, null, beast, aggressor, aggressor)
	TEST_ASSERT_NULL(beast.has_status_effect(/datum/status_effect/mob_horny_knockout), "One climax below the threshold must not KO the mob.")

	SEND_SIGNAL(beast, COMSIG_SEX_CLIMAX, null, beast, aggressor, aggressor)
	TEST_ASSERT_NOTNULL(beast.has_status_effect(/datum/status_effect/mob_horny_knockout), "Reaching the threshold must horny-KO the mob.")

/datum/unit_test/mob_horny_defeat_ignores_self_and_missing_instigator

/datum/unit_test/mob_horny_defeat_ignores_self_and_missing_instigator/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)

	beast.mob_horny_defeat_enabled = TRUE
	var/datum/component/defeat_monitor/monitor = beast.AddComponent(/datum/component/defeat_monitor)
	monitor.horny_defeat_climax_threshold = 1

	SEND_SIGNAL(beast, COMSIG_SEX_CLIMAX, null, beast, null, null)
	TEST_ASSERT_NULL(beast.has_status_effect(/datum/status_effect/mob_horny_knockout), "A climax with no external instigator must not KO the mob.")

	SEND_SIGNAL(beast, COMSIG_SEX_CLIMAX, null, beast, beast, beast)
	TEST_ASSERT_NULL(beast.has_status_effect(/datum/status_effect/mob_horny_knockout), "A self-driven climax must not KO the mob.")

/datum/unit_test/arousal_enables_mob_horny_defeat_on_clientless

/datum/unit_test/arousal_enables_mob_horny_defeat_on_clientless/Run()
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile)

	beast.AddComponent(/datum/component/arousal)

	TEST_ASSERT(beast.mob_horny_defeat_enabled, "Adding arousal to a clientless mob must enable mob horny defeat.")
	TEST_ASSERT_NOTNULL(beast.GetComponent(/datum/component/defeat_monitor), "Adding arousal to a clientless mob must attach the defeat monitor.")

/datum/unit_test/arousal_enables_mob_horny_defeat_on_carbon_npc

/// Carbon NPCs are in the horny system too. They are told apart from a not-yet-logged-in player body
/// by their ai_controller, since neither has a client when arousal is attached in Initialize.
/datum/unit_test/arousal_enables_mob_horny_defeat_on_carbon_npc/Run()
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human/species/human/northern/bum)
	TEST_ASSERT_NOTNULL(npc.ai_controller, "Setup: the fixture must be an AI-driven carbon NPC.")

	TEST_ASSERT(npc.mob_horny_defeat_enabled, "A carbon NPC carrying arousal must stay horny-KO-able.")
	TEST_ASSERT_NOTNULL(npc.GetComponent(/datum/component/defeat_monitor), "A carbon NPC must still get the defeat monitor.")

	var/mob/living/carbon/human/player_body = allocate(/mob/living/carbon/human)
	TEST_ASSERT_NULL(player_body.ai_controller, "Setup: a plain human body must not be AI-driven.")
	TEST_ASSERT(!player_body.mob_horny_defeat_enabled, "A clientless player body must not be mistaken for an NPC before Login.")

/datum/unit_test/defeat_trauma_alert_names_are_per_trauma

/datum/unit_test/defeat_trauma_alert_names_are_per_trauma/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	var/datum/status_effect/debuff/defeat/physical/concussion/head = patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/concussion, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT_NOTNULL(head.linked_alert, "A defeat trauma should own a status alert.")
	TEST_ASSERT_NOTEQUAL(head.linked_alert.name, "Defeat Trauma", "A trauma alert must not keep the generic fallback name.")
	TEST_ASSERT_EQUAL(head.linked_alert.name, "Injury: Concussion (Moderate)", "A physical trauma alert should read as a categorized injury.")
	TEST_ASSERT(findtext(head.linked_alert.desc, head.trauma_desc), "A trauma alert should retain its own description.")
	TEST_ASSERT(findtext(head.linked_alert.desc, head.mechanics_description()), "A trauma alert should disclose effects and treatment.")

	var/datum/status_effect/debuff/defeat/horny/wobble/lewd = patient.apply_status_effect(/datum/status_effect/debuff/defeat/horny/wobble, null, DEFEAT_SEVERITY_SEVERE)
	TEST_ASSERT_EQUAL(lewd.linked_alert.name, "Lewd: Rubbery Legs (Severe)", "A horny trauma alert should be labelled distinctly from an ordinary injury.")
	TEST_ASSERT_NOTEQUAL(lewd.linked_alert.overlay_state, head.linked_alert.overlay_state, "Horny and physical trauma alerts should not share an icon.")

	var/datum/status_effect/debuff/defeat/grievous/grave = patient.apply_status_effect(/datum/status_effect/debuff/defeat/grievous, null, DEFEAT_SEVERITY_SEVERE)
	TEST_ASSERT_EQUAL(grave.linked_alert.name, "Recovery: Convalescence (Severe)", "A convalescence alert should be labelled distinctly.")
	TEST_ASSERT_NOTEQUAL(grave.linked_alert.overlay_state, head.linked_alert.overlay_state, "Convalescence and physical trauma alerts should not share an icon.")

// Focused isolation run for just the mob horny-defeat KO tests. Compile with FOCUS_MOB_HORNY_DEFEAT_TEST
// defined to run only these. Guarded so it is inert (and safe to leave in) on a normal build.
#ifdef FOCUS_MOB_HORNY_DEFEAT_TEST
/datum/unit_test/defeat_trauma_alert_names_are_per_trauma
	focus = TRUE
/datum/unit_test/mob_horny_defeat_eligibility
	focus = TRUE
/datum/unit_test/mob_horny_ko_cleanup_deletes_when_alone
	focus = TRUE
/datum/unit_test/enter_mob_horny_defeat_applies_ko
	focus = TRUE
/datum/unit_test/mob_horny_defeat_ko_after_threshold
	focus = TRUE
/datum/unit_test/mob_horny_defeat_ignores_self_and_missing_instigator
	focus = TRUE
/datum/unit_test/arousal_enables_mob_horny_defeat_on_clientless
	focus = TRUE
#endif

#ifdef FOCUS_BOUNDED_DEFEAT_TEST
/datum/unit_test/defeat_stabilization_preserves_bounded_injuries_after_snapshot
	focus = TRUE
/datum/unit_test/defeat_health_signal_preempts_death_finalization
	focus = TRUE
/datum/unit_test/defeat_monitor_uses_only_health_signal_for_damage
	focus = TRUE
/datum/unit_test/defeat_rescue_clears_lethal_conditions
	focus = TRUE
/datum/unit_test/defeat_followup_damage_reapplies_bounded_safety
	focus = TRUE
#endif

#ifdef FOCUS_DEFEAT_RECOVERY_TEST
/datum/unit_test/defeat_organ_lethality_modes
	focus = TRUE
/datum/unit_test/defeat_intimate_aftermath_is_consistent
	focus = TRUE
/datum/unit_test/defeat_aftermath_prioritizes_cause
	focus = TRUE
/datum/unit_test/defeat_snapshot_debuff_maps_worst_injury
	focus = TRUE
/datum/unit_test/defeat_shock_does_not_trigger_knockout
	focus = TRUE
/datum/unit_test/defeat_destructive_damage_preserves_body
	focus = TRUE
/datum/unit_test/defeat_explicit_death_and_no_return_stay_lethal
	focus = TRUE
/datum/unit_test/defeat_rune_loss_arms_fallback
	focus = TRUE
/datum/unit_test/defeat_hazard_extracts_without_rune
	focus = TRUE
/datum/unit_test/defeat_introduction_save_migration
	focus = TRUE
/datum/unit_test/defeat_trauma_alert_names_are_per_trauma
	focus = TRUE
/datum/unit_test/defeat_disconnected_mind_keeps_protection
	focus = TRUE
/datum/unit_test/defeat_recovery_resets_pain_and_preserves_prepared_trauma
	focus = TRUE
/datum/unit_test/defeat_grievous_convalescence_expires
	focus = TRUE
/datum/unit_test/defeat_healing_uses_explicit_recovery_profiles
	focus = TRUE
/datum/unit_test/defeat_recovery_profiles_are_explicit
	focus = TRUE
/datum/unit_test/defeat_prepared_recovery_allows_range
	focus = TRUE
/datum/unit_test/defeat_priority_recovery_replaces_active_channel
	focus = TRUE
/datum/unit_test/defeat_manual_channel_interruption_tax_and_aftermath
	focus = TRUE
/datum/unit_test/defeat_recovery_resource_consume_and_rollback
	focus = TRUE
/datum/unit_test/defeat_potion_feed_rescues_downed_victim
	focus = TRUE
/datum/unit_test/defeat_campfire_requires_crafted_lit_fueled_source
	focus = TRUE
/datum/unit_test/defeat_campfire_passive_completion_and_tending_speed
	focus = TRUE
/datum/unit_test/defeat_campfire_channel_interruptions_and_duplicates
	focus = TRUE
/datum/unit_test/defeat_campfire_qdel_cleanup
	focus = TRUE
/datum/unit_test/defeat_recovery_finalizer_emits_once
	focus = TRUE
/datum/unit_test/defeat_bandage_stabilizes_without_waking
	focus = TRUE
#endif

/datum/unit_test/defeat_disconnected_mind_keeps_protection/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.mind = allocate(/datum/mind, "defeat-offline-test")
	victim.mind.current = victim
	victim.ensure_defeat_monitor()
	victim.setToxLoss(victim.defeat_damage_threshold, FALSE, TRUE)
	victim.updatehealth()
	TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "A disconnected player's mind must retain damage defeat protection.")
	victim.mind.current = null
	victim.mind = null

/datum/unit_test/defeat_organ_lethality_modes/Run()
	for(var/mode in list(DEFEAT_MODE_KO_ONLY, DEFEAT_MODE_NO_RETURN, "npc"))
		for(var/injury in list("brain", "artery", "extraction", "head", "skeletonize"))
			var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
			victim.defeat_system_ai_opt_in = mode != "npc"
			victim.defeat_mode = mode == "npc" ? DEFEAT_MODE_DEFAULT : mode
			var/obj/item/organ/brain/brain = victim.getorganslot(ORGAN_SLOT_BRAIN)
			var/obj/item/bodypart/head/head = victim.get_bodypart(BODY_ZONE_HEAD)
			switch(injury)
				if("brain")
					victim.setOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH)
				if("artery")
					var/obj/item/organ/artery/neck/artery = locate(/obj/item/organ/artery/neck) in victim.internal_organs
					TEST_ASSERT_NOTNULL(artery, "The fixture needs a neck artery.")
					ADD_TRAIT(victim, TRAIT_CRITICAL_WEAKNESS, TRAIT_SOURCE_UNIT_TESTS)
					artery.dissect()
				if("extraction")
					brain.remove_and_drop(victim, get_turf(victim))
				if("head")
					head.drop_limb()
				if("skeletonize")
					head.skeletonize()
			if(mode == DEFEAT_MODE_KO_ONLY)
				TEST_ASSERT(victim.stat != DEAD, "Protected [injury] must leave the character alive.")
				TEST_ASSERT_NOTNULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Protected [injury] must enter Defeat.")
				TEST_ASSERT(!brain.brain_death, "Intercepted injury must not mark the brain permanently dead.")
			else
				TEST_ASSERT_EQUAL(victim.stat, DEAD, "[mode] must retain ordinary lethal behavior for [injury].")
				TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Unprotected [injury] must not add Defeat.")

/datum/unit_test/defeat_destructive_damage_preserves_body/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.defeat_mode = DEFEAT_MODE_KO_ONLY
	victim.death()
	TEST_ASSERT(victim.stat != DEAD, "Direct ordinary death must convert to defeat.")
	victim.gib()
	TEST_ASSERT(!QDELETED(victim), "Gibbing a protected victim must preserve the body.")
	victim.dust()
	TEST_ASSERT(!QDELETED(victim), "Dusting a protected victim must preserve the body.")
	var/obj/item/bodypart/head/head = victim.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(!head.drop_limb(), "A lethal head removal must be intercepted.")
	TEST_ASSERT_EQUAL(head.owner, victim, "An intercepted decapitation must retain the head.")
	var/obj/item/organ/brain/brain = victim.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(!brain.remove_and_drop(victim, get_turf(victim)), "Vital-organ extraction must not move the preserved organ.")
	TEST_ASSERT_EQUAL(brain.owner, victim, "An intercepted extraction must retain the brain.")
	TEST_ASSERT_NULL(brain.brainmob, "An intercepted extraction must not transfer identity into a brainmob.")
	head.skeletonize()
	TEST_ASSERT(!head.skeletonized, "Lethal skeletonization must be intercepted before stripping flesh.")
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/defeat_knockout), "Destructive attacks must leave a recoverable defeat.")
	var/mob/living/carbon/human/artery_patient = allocate(/mob/living/carbon/human)
	artery_patient.defeat_system_ai_opt_in = TRUE
	artery_patient.defeat_mode = DEFEAT_MODE_KO_ONLY
	var/obj/item/organ/artery/neck/neck_artery
	for(var/obj/item/organ/artery/artery as anything in artery_patient.internal_organs)
		if(istype(artery, /obj/item/organ/artery/neck))
			neck_artery = artery
			break
	ADD_TRAIT(artery_patient, TRAIT_CRITICAL_WEAKNESS, "defeat-unit-test")
	neck_artery.dissect()
	TEST_ASSERT(artery_patient.stat != DEAD, "Critical neck-artery dissection must enter Defeat instead of bypassing through a direct death call.")
	REMOVE_TRAIT(artery_patient, TRAIT_CRITICAL_WEAKNESS, "defeat-unit-test")
	var/mob/living/carbon/human/fresh = allocate(/mob/living/carbon/human)
	fresh.defeat_system_ai_opt_in = TRUE
	fresh.defeat_mode = DEFEAT_MODE_KO_ONLY
	fresh.gib()
	TEST_ASSERT(!QDELETED(fresh) && fresh.has_status_effect(/datum/status_effect/defeat_knockout), "A first-hit gib must enter defeat before any body destruction.")
	var/mob/living/carbon/human/fresh_dust = allocate(/mob/living/carbon/human)
	fresh_dust.defeat_system_ai_opt_in = TRUE
	fresh_dust.defeat_mode = DEFEAT_MODE_KO_ONLY
	fresh_dust.dust()
	TEST_ASSERT(!QDELETED(fresh_dust) && fresh_dust.has_status_effect(/datum/status_effect/defeat_knockout), "A first-hit dust must enter defeat before any body destruction.")

/datum/unit_test/defeat_explicit_death_and_no_return_stay_lethal/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.defeat_mode = DEFEAT_MODE_KO_ONLY
	victim.defeat_explicit_death()
	TEST_ASSERT_EQUAL(victim.stat, DEAD, "Explicit character-ending death must bypass defeat.")
	TEST_ASSERT(victim.defeat_final_death, "Explicit death must also block later automatic rune offers.")
	var/mob/living/carbon/human/lethal = allocate(/mob/living/carbon/human)
	lethal.defeat_system_ai_opt_in = TRUE
	lethal.defeat_mode = DEFEAT_MODE_NO_RETURN
	lethal.death()
	TEST_ASSERT_EQUAL(lethal.stat, DEAD, "No Return must keep ordinary death lethal.")
	lethal.gib()
	TEST_ASSERT(QDELETED(lethal), "No Return must keep destructive death effective.")

/datum/unit_test/defeat_rune_loss_arms_fallback/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.mind = allocate(/datum/mind, "defeat-rune-loss-test")
	victim.mind.current = victim
	var/obj/structure/resurrection_rune/rune = allocate(/obj/structure/resurrection_rune)
	rune.rune_tag = "defeat_rune_loss_test"
	rune.resrunecontroler.add_user(victim)
	victim.enter_defeat()
	var/datum/status_effect/defeat_knockout/knockout = victim.has_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NOTNULL(knockout, "A linked character should enter defeat.")
	TEST_ASSERT_NULL(knockout.struggle_offer_timer, "A working rune should initially provide the safety net.")
	rune.disabled_res = TRUE
	knockout.tick()
	TEST_ASSERT_NOTNULL(knockout.struggle_offer_timer, "Losing the rune after defeat must arm unaided recovery.")
	var/first_timer = knockout.struggle_offer_timer
	knockout.tick()
	TEST_ASSERT_EQUAL(knockout.struggle_offer_timer, first_timer, "Fallback checks must not restart the recovery countdown.")
	qdel(rune)
	knockout.tick()
	TEST_ASSERT_EQUAL(knockout.struggle_offer_timer, first_timer, "Rune deletion must retain the existing recovery countdown.")
	victim.mind.current = null
	victim.mind = null

/datum/unit_test/defeat_hazard_extracts_without_rune/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	victim.defeat_mode = DEFEAT_MODE_KO_ONLY
	var/turf/hazard = get_step(run_loc_floor_bottom_left, EAST)
	var/original_type = hazard.type
	var/list/original_baseturfs = hazard.baseturfs
	hazard = hazard.ChangeTurf(/turf/open/lava/acid)
	victim.forceMove(hazard)
	var/turf/open/lava/acid/acid = hazard
	acid.do_burn(victim)
	var/was_safe = defeat_safe_recovery_turf(get_turf(victim))
	var/was_defeated = victim.has_status_effect(/datum/status_effect/defeat_knockout)
	var/obj/item/bodypart/head/head = victim.get_bodypart(BODY_ZONE_HEAD)
	hazard.ChangeTurf(original_type, original_baseturfs)
	TEST_ASSERT(was_safe, "An unlinked protected victim must be extracted onto safe ground.")
	TEST_ASSERT(was_defeated && victim.stat != DEAD, "Hazard extraction must leave the victim alive and defeated.")
	TEST_ASSERT(!head.skeletonized, "Acid protection must run before skeletonization.")

/datum/unit_test/defeat_introduction_save_migration
	var/save_path

/datum/unit_test/defeat_introduction_save_migration/Destroy()
	if(save_path)
		fdel(save_path)
	return ..()

/datum/unit_test/defeat_introduction_save_migration/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	TEST_ASSERT(!prefs.defeat_introduction_complete, "New accounts must explicitly choose their defeat experience.")
	save_path = "[GLOB.log_directory]/defeat_introduction_test.sav"
	prefs.path = save_path
	TEST_ASSERT(prefs.save_preferences(), "The introduction state should save.")
	prefs.defeat_introduction_complete = TRUE
	TEST_ASSERT(prefs.load_preferences(), "Saved account preferences should load.")
	TEST_ASSERT(!prefs.defeat_introduction_complete, "An unfinished introduction must remain unfinished after reconnecting.")
	prefs.defeat_introduction_complete = TRUE
	prefs.save_preferences()
	prefs.defeat_introduction_complete = FALSE
	prefs.load_preferences()
	TEST_ASSERT(prefs.defeat_introduction_complete, "A confirmed introduction must survive reconnecting.")
	var/savefile/legacy_save = new(save_path)
	WRITE_FILE(legacy_save["defeat_introduction_complete"], null)
	prefs.defeat_introduction_complete = FALSE
	prefs.load_preferences()
	TEST_ASSERT(prefs.defeat_introduction_complete, "Existing accounts without an introduction flag should keep their settings without onboarding.")

/datum/unit_test/defeat_recovery_resets_pain_and_preserves_prepared_trauma/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	victim.defeat_system_ai_opt_in = TRUE
	var/datum/component/defeat_monitor/monitor = victim.AddComponent(/datum/component/defeat_monitor)
	var/datum/status_effect/debuff/defeat/pain/old_trauma = victim.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/pain, DEFEAT_SEVERITY_NORMAL)
	var/old_expiry = old_trauma.duration
	monitor.shock_defeat_started_at = world.time - DEFEAT_SHOCK_SUSTAIN_DURATION
	TEST_ASSERT(victim.enter_defeat(DEFEAT_REASON_PAIN), "The test victim should enter pain defeat.")
	TEST_ASSERT_EQUAL(monitor.shock_defeat_started_at, 0, "Defeat entry must clear the old sustained-pain window.")
	monitor.shock_defeat_started_at = world.time - DEFEAT_SHOCK_SUSTAIN_DURATION
	TEST_ASSERT(victim.defeat_try_prepared_recovery(helper, "test care"), "Prepared care should recover the victim.")
	TEST_ASSERT_EQUAL(monitor.shock_defeat_started_at, 0, "Recovery must clear the sustained-pain window.")
	TEST_ASSERT_EQUAL(victim.has_status_effect(/datum/status_effect/debuff/defeat/pain), old_trauma, "Prepared care must preserve existing trauma rather than escalate or replace it.")
	TEST_ASSERT_EQUAL(old_trauma.duration, old_expiry, "Prepared care must not restart existing trauma's recovery clock.")
	victim.setShockStage(DEFEAT_SHOCK_DEFEAT_STAGE, FALSE, TRUE)
	monitor.check_defeat_triggers()
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/defeat_knockout), "A new pain episode must earn its own sustain window.")

/datum/unit_test/defeat_grievous_convalescence_expires/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/datum/status_effect/debuff/defeat/grievous/trauma = victim.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/grievous, DEFEAT_SEVERITY_SEVERE)
	TEST_ASSERT_EQUAL(trauma.initial_duration, DEFEAT_GRIEVOUS_RECOVERY_TIME, "Unaided convalescence must have a finite duration.")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_PACIFISM), "Convalescence should prevent immediate return to combat.")
	trauma.duration = world.time - 1
	trauma.process()
	TEST_ASSERT_NULL(victim.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "Expired convalescence must be removed.")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_PACIFISM), "Natural recovery must restore the ability to fight.")

#ifdef FOCUS_DEFEAT_TRAUMA_TREATMENT_TEST
/datum/unit_test/defeat_universal_treatment_and_priest_spell_surface
	focus = TRUE
/datum/unit_test/defeat_station_cross_treatment
	focus = TRUE
/datum/unit_test/defeat_mercy_draught_swallowed_doses
	focus = TRUE
/datum/unit_test/defeat_mercy_draught_rejects_splash_and_short_dose
	focus = TRUE
/datum/unit_test/defeat_burden_costs_and_exclusions
	focus = TRUE
/datum/unit_test/defeat_healer_guarantees_draught
	focus = TRUE
/datum/unit_test/defeat_treatment_clears_correct_trauma
	focus = TRUE
/datum/unit_test/defeat_tool_treatment_clears_matching_trauma_only
	focus = TRUE
/datum/unit_test/defeat_trauma_provider_diagnosis_is_deterministic
	focus = TRUE
/datum/unit_test/defeat_trauma_provider_costs_only_on_success
	focus = TRUE
/datum/unit_test/defeat_trauma_provider_interruption_has_no_cost
	focus = TRUE
/datum/unit_test/defeat_trauma_provider_discloses_full_treatment
	focus = TRUE
/datum/unit_test/defeat_trauma_provider_prefilters_unusable_candidates
	focus = TRUE
/datum/unit_test/defeat_trauma_provider_rejects_deleted_resource_after_delay
	focus = TRUE
/datum/unit_test/defeat_trauma_providers_have_blueprint_acquisition
	focus = TRUE
/datum/unit_test/defeat_universal_provider_removes_exactly_one_selected_trauma
	focus = TRUE
/datum/unit_test/defeat_shrine_routes_horny_trauma
	focus = TRUE
#endif

/datum/unit_test/defeat_station_cross_treatment

/datum/unit_test/defeat_station_cross_treatment/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(patient, helper, run_loc_floor_bottom_left)
	var/datum/defeat_trauma_provider/medical/machine/medical = allocate(/datum/defeat_trauma_provider/medical/machine)
	var/datum/defeat_trauma_provider/shrine/structure/shrine = allocate(/datum/defeat_trauma_provider/shrine/structure)
	var/datum/status_effect/debuff/defeat/rune/rune = patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_SEVERE)
	var/obj/item/natural/bundle/cloth/bandage/bandages = allocate(/obj/item/natural/bundle/cloth/bandage/full)
	helper.put_in_active_hand(bandages)
	TEST_ASSERT(medical.validate(patient, helper, rune, bandages), "An untrained helper should be able to use the apparatus.")
	var/untrained_medical_time = medical.treatment_time(helper, rune)
	medical.untrained_time_multiplier = 1
	var/medical_time_without_penalty = medical.treatment_time(helper, rune)
	medical.untrained_time_multiplier = 2
	TEST_ASSERT_EQUAL(untrained_medical_time, medical_time_without_penalty * 2, "Missing Medicine training should double apparatus time after the specialty penalty.")
	TEST_ASSERT_EQUAL(length(medical.all_diagnoses(patient)), 1, "The untrained diagnosis must remain visible.")
	helper.set_skillrank(/datum/skill/misc/medicine, SKILL_RANK_APPRENTICE, TRUE)
	TEST_ASSERT_EQUAL(medical.resource_cost_for(rune), 4, "Even the worst spiritual trauma must fit within one full bandage roll.")
	TEST_ASSERT(medical.treat(patient, helper, rune, FALSE, TRUE, bandages), "Medicine training alone must suffice for spiritual treatment at the apparatus.")
	TEST_ASSERT(QDELETED(bandages), "The completed treatment should consume exactly one four-bandage roll.")
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/rune), "The selected spiritual trauma should be gone.")

	var/datum/status_effect/debuff/defeat/grievous/convalescence = patient.apply_status_effect(/datum/status_effect/debuff/defeat/grievous, null, DEFEAT_SEVERITY_SEVERE)
	var/obj/item/coin/silver/coins = allocate(/obj/item/coin/silver)
	coins.set_quantity(7)
	helper.put_in_active_hand(coins)
	TEST_ASSERT(shrine.validate(patient, helper, convalescence, coins), "An untrained helper should be able to use the shrine.")
	var/untrained_shrine_time = shrine.treatment_time(helper, convalescence)
	shrine.untrained_time_multiplier = 1
	var/shrine_time_without_penalty = shrine.treatment_time(helper, convalescence)
	shrine.untrained_time_multiplier = 2
	TEST_ASSERT_EQUAL(untrained_shrine_time, shrine_time_without_penalty * 2, "Missing holy training should double shrine time after the specialty penalty.")
	ADD_TRAIT(helper, TRAIT_HOLY, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(shrine.resource_cost_for(convalescence), 6, "The shrine should charge its physical specialty surcharge.")
	TEST_ASSERT(shrine.treat(patient, helper, convalescence, FALSE, TRUE, coins), "A holy helper must be able to treat Convalescence at a shrine.")
	TEST_ASSERT_EQUAL(coins.quantity, 1, "The shrine must consume exactly six silver coins.")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_PACIFISM), "Treating Convalescence must release its pacifism.")

/datum/unit_test/defeat_mercy_draught_swallowed_doses

/datum/unit_test/defeat_mercy_draught_swallowed_doses/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/glass/bottle/vial/mercydraught/vial = allocate(/obj/item/reagent_containers/glass/bottle/vial/mercydraught)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical, null, DEFEAT_SEVERITY_LIGHT)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/wound, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/physical/burn, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain, null, DEFEAT_SEVERITY_NORMAL)
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/rune, null, DEFEAT_SEVERITY_SEVERE)
	var/datum/defeat_trauma_provider/universal/provider = allocate(/datum/defeat_trauma_provider/universal)
	for(var/dose in 1 to 5)
		vial.reagents.trans_to(patient, DEFEAT_MERCY_DRAUGHT_DOSE, transfered_by = patient, method = INGEST)
		TEST_ASSERT_EQUAL(length(provider.diagnose(patient)), 5 - dose, "Every swallowed dose must cure exactly one ordinary trauma.")
		TEST_ASSERT_EQUAL(vial.reagents.total_volume, 25 - dose * DEFEAT_MERCY_DRAUGHT_DOSE, "A full vial must contain five real doses.")
		if(dose == 1)
			TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/rune), "Automatic dosing must prioritize severe trauma over alphabetic label order.")
	var/obj/item/organ/stomach/stomach = patient.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT_EQUAL(stomach.reagents.get_reagent_amount(/datum/reagent/medicine/herbal/mercy_draught), 0, "Spent doses must not remain in the stomach for another cure.")

/datum/unit_test/defeat_mercy_draught_rejects_splash_and_short_dose

/datum/unit_test/defeat_mercy_draught_rejects_splash_and_short_dose/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/glass/bottle/vial/mercydraught/vial = allocate(/obj/item/reagent_containers/glass/bottle/vial/mercydraught)
	var/datum/status_effect/debuff/defeat/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain)
	var/datum/reagent/medicine/herbal/mercy_draught/draught = locate(/datum/reagent/medicine/herbal/mercy_draught) in vial.reagents.reagent_list
	draught.reaction_mob(patient, TOUCH, 25)
	TEST_ASSERT(trauma in patient.status_effects, "A splash reaction must not give a free trauma cure.")
	vial.reagents.trans_to(patient, 4, transfered_by = patient, method = INGEST)
	TEST_ASSERT(trauma in patient.status_effects, "Four swallowed measures must not suffice.")
	vial.reagents.trans_to(patient, 1, transfered_by = patient, method = INGEST)
	TEST_ASSERT_NULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/pain), "Completing a real five-measure dose should cure the trauma.")
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/grievous)
	vial.transfer_feed_reagents(patient, patient)
	TEST_ASSERT_EQUAL(vial.reagents.total_volume, 20, "The labeled vial should refuse to waste a dose on Convalescence alone.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "A draught must not cure Convalescence.")

/datum/unit_test/defeat_burden_costs_and_exclusions

/datum/unit_test/defeat_burden_costs_and_exclusions/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human)
	defeat_unit_place_adjacent(patient, caster, run_loc_floor_bottom_left)
	var/datum/devotion/devotion = allocate(/datum/devotion)
	devotion.grant_to(caster)
	devotion.devotion = 300
	var/datum/action/cooldown/spell/defeat_absolution/spell = allocate(/datum/action/cooldown/spell/defeat_absolution)
	spell.Grant(caster)
	TEST_ASSERT(!spell.is_valid_target(caster), "The sacrifice cannot target its own caster.")
	patient.apply_status_effect(/datum/status_effect/debuff/defeat/grievous)
	TEST_ASSERT(!spell.is_valid_target(patient), "Convalescence alone is not a valid sacrifice target.")
	var/datum/status_effect/debuff/defeat/trauma = patient.apply_status_effect(/datum/status_effect/debuff/defeat/pain, null, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT(!spell.cast(patient), "A cast without a confirmed exact trauma must fail.")
	TEST_ASSERT_EQUAL(devotion.devotion, 300, "A failed cast must not spend devotion.")
	TEST_ASSERT_EQUAL(caster.getBruteLoss(), 0, "A failed cast must not harm the caster.")
	devotion.devotion = 0
	spell.selected_trauma_ref = WEAKREF(trauma)
	TEST_ASSERT(!spell.cast(patient), "This miracle must enforce devotion even though the shared miracle check is disabled.")
	TEST_ASSERT(trauma in patient.status_effects, "A caster without devotion must not clear trauma.")
	devotion.devotion = 300
	var/cost = spell.get_adjusted_cost()
	spell.selected_trauma_ref = WEAKREF(trauma)
	TEST_ASSERT(spell.cast(patient), "A confirmed affordable ordinary trauma should be cured.")
	TEST_ASSERT_EQUAL(devotion.devotion, 300 - cost, "A successful sacrifice must pay its devotion cost exactly once.")
	TEST_ASSERT_EQUAL(caster.getBruteLoss(), 20, "Normal trauma should cost the caster twenty bodily damage.")
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "The spell must leave Convalescence alone.")
	TEST_ASSERT_NOTNULL(caster.has_status_effect(/datum/status_effect/sacrificial_exhaustion), "Success should exhaust the caster.")
	caster.fully_heal(HEAL_ALL)
	TEST_ASSERT_NOTNULL(caster.has_status_effect(/datum/status_effect/sacrificial_exhaustion), "Ordinary full healing must not erase the sacrifice's exhaustion.")
	TEST_ASSERT(!spell.can_cast_spell(FALSE), "The caster cannot repeat the sacrifice while exhausted.")

/datum/unit_test/defeat_healer_guarantees_draught

/datum/unit_test/defeat_healer_guarantees_draught/Run()
	var/datum/world_faction/faction = allocate(/datum/world_faction)
	var/datum/trader_data/medicine_merchant/healer = allocate(/datum/trader_data/medicine_merchant)
	// Even a faction with no compatible random wares must supply the healer's fixed medicine.
	faction.customize_trader_inventory(healer)
	var/list/product = healer.initial_products[/obj/item/reagent_containers/glass/bottle/vial/mercydraught]
	TEST_ASSERT_EQUAL(product[1], 100, "The Healer's fixed medicine must use the lowered supply price.")
	TEST_ASSERT_EQUAL(product[2], 5, "Every generated Healer should carry five vials.")



/// Beating a prosthetic wears the device, not the wearer, so it never fills the defeat pool.
/datum/unit_test/defeat_pool_ignores_prosthetic_damage/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/old_arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	old_arm.drop_limb()
	qdel(old_arm)
	var/obj/item/bodypart/r_arm/prosthetic/wood/arm = new(null)
	arm.attach_limb(patient)
	TEST_ASSERT_EQUAL(patient.get_bodypart(BODY_ZONE_R_ARM), arm, "Test setup: the wooden arm should be attached")
	arm.bodypart_attacked_by(BCLASS_BLUNT, 40)
	arm.update_damages()
	TEST_ASSERT(arm.brute_dam > 0, "Test setup: the wooden arm should take damage")
	TEST_ASSERT_EQUAL(patient.get_defeat_damage_pool(), 0, "Prosthetic damage must not count toward defeat")

	var/obj/item/bodypart/left_arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	left_arm.create_injury(WOUND_BLUNT, 30)
	left_arm.update_damages()
	TEST_ASSERT(patient.get_defeat_damage_pool() > 0, "Damage to a flesh limb should still count toward defeat")

	var/mob/living/carbon/human/automaton = allocate(/mob/living/carbon/human)
	automaton.set_species(/datum/species/automaton)
	var/obj/item/bodypart/brass_arm = automaton.get_bodypart(BODY_ZONE_R_ARM)
	TEST_ASSERT(brass_arm.is_robotic_limb(), "Test setup: automaton limbs should be robotic")
	brass_arm.bodypart_attacked_by(BCLASS_BLUNT, 40)
	brass_arm.update_damages()
	TEST_ASSERT(automaton.get_defeat_damage_pool() > 0, "An automaton's own limbs are its body and must still count")
