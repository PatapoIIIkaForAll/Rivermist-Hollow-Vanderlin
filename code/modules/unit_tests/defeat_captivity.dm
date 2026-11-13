/datum/map_template/pocket/defeat_captivity/unit_test
	name = "Defeat Captivity Test Chamber"
	id = "pocket_defeat_captivity_test"
	mappath = "_maps/templates/pockets/pocket_test_chamber.dmm"

/datum/defeat_captivity_profile/shared/unit_test
	stable_key = "unit_test_shared"
	template_type = /datum/map_template/pocket/defeat_captivity/unit_test
	var/turf/unit_test_wilds

/datum/defeat_captivity_profile/shared/unit_test/get_wilds_destination(datum/component/kidnap_captivity/captivity)
	return unit_test_wilds || ..()

/datum/defeat_captivity_profile/shared/unit_test/single
	stable_key = "unit_test_capacity"
	capacity = 1

/datum/defeat_captivity_profile/carrier/unit_test
	template_type = /datum/map_template/pocket/defeat_captivity/unit_test

/datum/defeat_captivity_profile/per_captive/unit_test
	template_type = /datum/map_template/pocket/defeat_captivity/unit_test
	var/turf/unit_test_wilds

/datum/defeat_captivity_profile/per_captive/unit_test/get_wilds_destination(datum/component/kidnap_captivity/captivity)
	return unit_test_wilds || ..()

/datum/unit_test/defeat_captivity_shared_reuse_and_exit
	needs_pocket_space = TRUE

/datum/unit_test/defeat_captivity_shared_reuse_and_exit/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/turf/first_origin = get_turf(first)
	var/turf/test_wilds = run_loc_floor_top_right
	first.apply_status_effect(/datum/status_effect/defeat_knockout)
	second.apply_status_effect(/datum/status_effect/defeat_knockout)

	TEST_ASSERT(first.kidnap_to_pocket(/datum/defeat_captivity_profile/shared/unit_test, null, null, "unit_test_shared"), "The first shared-lair captive should be admitted.")
	TEST_ASSERT(second.kidnap_to_pocket(/datum/defeat_captivity_profile/shared/unit_test, null, null, "unit_test_shared"), "The second shared-lair captive should reuse the active lair.")
	var/datum/component/kidnap_captivity/first_captivity = first.GetComponent(/datum/component/kidnap_captivity)
	var/datum/component/kidnap_captivity/second_captivity = second.GetComponent(/datum/component/kidnap_captivity)
	var/datum/defeat_captivity_profile/shared/unit_test/first_profile = first_captivity.profile
	first_profile.unit_test_wilds = test_wilds
	var/datum/defeat_captivity_profile/shared/unit_test/second_profile = second_captivity.profile
	second_profile.unit_test_wilds = test_wilds
	var/datum/pocket_dimension/defeat_captivity/shared_instance = first_captivity.resolve_instance()
	var/obj/item/weapon/knife/left_behind = allocate(/obj/item/weapon/knife, shared_instance.get_entry_turf())
	TEST_ASSERT_EQUAL(second_captivity.resolve_instance(), shared_instance, "Shared profiles should reuse one stable-key instance.")
	TEST_ASSERT(shared_instance.can_exit_mob(first, null, FALSE), "The shared-lair exit should not duplicate KO interaction blocking with component state.")
	first.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(first_captivity.released, "Removing KO outside the captivity timer should reconcile the component to released.")
	TEST_ASSERT(shared_instance.exit_mob(first), "The shared-lair exit should route through contextual release.")
	TEST_ASSERT_NULL(first.GetComponent(/datum/component/kidnap_captivity), "Contextual exit should remove captivity state.")
	TEST_ASSERT_NOTEQUAL(get_turf(first), first_origin, "A shared lair must not dump an escapee back on the capture turf, in the middle of their captors.")
	TEST_ASSERT_EQUAL(get_turf(first), test_wilds, "A shared lair without a configured exterior should prefer the wilds over the saved capture turf.")
	TEST_ASSERT(first.kidnap_protected_until > world.time, "Leaving captivity should grant a short recapture grace period.")
	second.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(shared_instance.exit_mob(second), "The final captive should be able to leave the shared lair normally.")
	TEST_ASSERT_EQUAL(SSpocket_dimensions.get_instance(shared_instance.instance_key), shared_instance, "An empty shared lair should remain loaded for later captives.")
	TEST_ASSERT(shared_instance.contains_turf(get_turf(left_behind)), "Loose foreign contents should remain inside a persistent shared lair during the round.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(shared_instance), "Explicit shared-lair teardown should still succeed.")
	TEST_ASSERT(QDELETED(left_behind), "Explicit teardown should delete loose foreign contents instead of dumping them into the world.")

/datum/unit_test/defeat_captivity_capacity
	needs_pocket_space = TRUE

/datum/unit_test/defeat_captivity_capacity/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	first.apply_status_effect(/datum/status_effect/defeat_knockout)
	second.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(first.kidnap_to_pocket(/datum/defeat_captivity_profile/shared/unit_test/single, null, null, "unit_test_capacity"), "The first captive should fill the one-person pocket.")
	TEST_ASSERT(!second.kidnap_to_pocket(/datum/defeat_captivity_profile/shared/unit_test/single, null, null, "unit_test_capacity"), "Admission should fail cleanly when profile capacity is full.")
	var/datum/component/kidnap_captivity/captivity = first.GetComponent(/datum/component/kidnap_captivity)
	qdel(second)
	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/retry_victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	captor.kidnap_lair_tag = "unit_test_capacity"
	captor.kidnap_captivity_profile = /datum/defeat_captivity_profile/shared/unit_test/single
	retry_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	retry_victim.last_defeat_snapshot = new /datum/defeat_snapshot
	retry_victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY
	retry_victim.recent_damage_source_attacker_weakref = WEAKREF(captor)
	TEST_ASSERT(!captor.try_kidnap_defeated_prey(retry_victim), "A full profile should reject the AI captor's admission attempt.")
	TEST_ASSERT(captor.kidnap_retry_after > world.time, "A failed admission should arm a bounded per-captor retry cooldown.")
	TEST_ASSERT(!captor.is_kidnap_candidate(retry_victim), "The cooldown should keep a full pocket from hot-looping the same candidate.")
	SSpocket_dimensions.delete_instance(captivity.resolve_instance())

/datum/unit_test/defeat_captivity_carrier_keys_and_owner_teardown
	needs_pocket_space = TRUE

/datum/unit_test/defeat_captivity_carrier_keys_and_owner_teardown/Run()
	var/turf/carrier_turf = run_loc_floor_bottom_left
	var/mob/living/carbon/human/first_carrier = allocate(/mob/living/carbon/human, carrier_turf)
	var/mob/living/carbon/human/second_carrier = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/mob/living/carbon/human/isolated = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	first.apply_status_effect(/datum/status_effect/defeat_knockout)
	second.apply_status_effect(/datum/status_effect/defeat_knockout)
	isolated.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(first.kidnap_to_pocket(/datum/defeat_captivity_profile/carrier/unit_test, first_carrier), "The carrier should create its first pocket.")
	TEST_ASSERT(second.kidnap_to_pocket(/datum/defeat_captivity_profile/carrier/unit_test, first_carrier), "The same carrier should reuse its active pocket.")
	TEST_ASSERT(isolated.kidnap_to_pocket(/datum/defeat_captivity_profile/carrier/unit_test, second_carrier), "A different carrier should create an isolated pocket.")
	var/datum/component/kidnap_captivity/first_captivity = first.GetComponent(/datum/component/kidnap_captivity)
	var/datum/component/kidnap_captivity/second_captivity = second.GetComponent(/datum/component/kidnap_captivity)
	var/datum/component/kidnap_captivity/isolated_captivity = isolated.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/carrier_instance = first_captivity.resolve_instance()
	TEST_ASSERT_EQUAL(first_captivity.resolve_instance(), second_captivity.resolve_instance(), "One carrier should own one reusable instance.")
	TEST_ASSERT_NOTEQUAL(first_captivity.resolve_instance(), isolated_captivity.resolve_instance(), "Different carriers should never share a carrier instance.")
	TEST_ASSERT(carrier_instance.can_exit_mob(first_carrier, null, FALSE), "A carrier-profile pocket should recognize its owning carrier through the profile access rule.")
	TEST_ASSERT(!carrier_instance.can_exit_mob(second_carrier, null, FALSE), "A carrier-profile pocket should deny unrelated non-captive occupants instead of falling through to permissive base access.")
	qdel(first_carrier)
	TEST_ASSERT_NULL(first.GetComponent(/datum/component/kidnap_captivity), "Carrier destruction should clear the first captive's state.")
	TEST_ASSERT_NULL(second.GetComponent(/datum/component/kidnap_captivity), "Carrier destruction should clear every member's state.")
	TEST_ASSERT_EQUAL(get_turf(first), carrier_turf, "Carrier teardown should eject captives at the carrier's destruction turf.")
	SSpocket_dimensions.delete_instance(isolated_captivity.resolve_instance())

/datum/unit_test/defeat_captivity_per_captive_and_delete_paths
	needs_pocket_space = TRUE

/datum/unit_test/defeat_captivity_per_captive_and_delete_paths/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	first.apply_status_effect(/datum/status_effect/defeat_knockout)
	second.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(first.kidnap_to_pocket(/datum/defeat_captivity_profile/per_captive/unit_test, null), "The first per-captive pocket should admit its owner.")
	TEST_ASSERT(second.kidnap_to_pocket(/datum/defeat_captivity_profile/per_captive/unit_test, null), "The second per-captive pocket should admit its owner.")
	var/datum/component/kidnap_captivity/first_captivity = first.GetComponent(/datum/component/kidnap_captivity)
	var/datum/component/kidnap_captivity/second_captivity = second.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/first_instance = first_captivity.resolve_instance()
	var/datum/pocket_dimension/defeat_captivity/second_instance = second_captivity.resolve_instance()
	var/turf/first_pocket_turf = get_turf(first)
	TEST_ASSERT_NOTEQUAL(first_instance, second_instance, "Per-captive profiles should isolate every victim.")
	first_captivity.released = TRUE
	TEST_ASSERT(!first_instance.can_exit_mob(first, null, FALSE), "A sealed per-captive profile should deny its captive even after waking.")
	TEST_ASSERT(!first_instance.can_exit_mob(second, null, FALSE), "A sealed per-captive profile should deny unrelated occupants too.")
	qdel(first_instance)
	TEST_ASSERT_NULL(first.GetComponent(/datum/component/kidnap_captivity), "Direct qdel should contextually eject and clear captivity.")
	TEST_ASSERT_NOTEQUAL(get_turf(first), first_pocket_turf, "Direct qdel must not leave the captive in deleted pocket turf.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(second_instance), "Subsystem deletion should tear down the second isolated pocket.")
	TEST_ASSERT_NULL(second.GetComponent(/datum/component/kidnap_captivity), "Subsystem deletion should clear captivity exactly like direct qdel.")

/datum/unit_test/defeat_captivity_wilds_first_and_forced_move_cleanup
	needs_pocket_space = TRUE

/datum/unit_test/defeat_captivity_wilds_first_and_forced_move_cleanup/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/test_wilds = run_loc_floor_top_right
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, origin)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(victim.kidnap_to_pocket(/datum/defeat_captivity_profile/per_captive/unit_test, null), "The isolated test pocket should admit its captive.")
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/isolated_instance = captivity.resolve_instance()
	var/obj/item/weapon/knife/left_behind = allocate(/obj/item/weapon/knife, isolated_instance.get_entry_turf())
	var/datum/defeat_captivity_profile/per_captive/unit_test/profile = captivity.profile
	profile.unit_test_wilds = test_wilds
	TEST_ASSERT(captivity.release_to_context(), "Contextual per-captive release should succeed.")
	TEST_ASSERT_EQUAL(get_turf(victim), test_wilds, "Per-captive release should prefer a valid wilds destination over the saved origin.")
	TEST_ASSERT_NULL(victim.GetComponent(/datum/component/kidnap_captivity), "Wilds release should clear captivity state.")
	TEST_ASSERT(QDELETED(left_behind), "An isolated lair should delete loose foreign contents when its final captive leaves.")

	var/mob/living/carbon/human/moved_victim = allocate(/mob/living/carbon/human, origin)
	moved_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(moved_victim.kidnap_to_pocket(/datum/defeat_captivity_profile/shared/unit_test, null, null, "unit_test_forced_move"), "The movement cleanup pocket should admit its captive.")
	var/datum/component/kidnap_captivity/moved_captivity = moved_victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/moved_instance = moved_captivity.resolve_instance()
	var/moved_instance_key = moved_instance.instance_key
	moved_victim.forceMove(origin)
	TEST_ASSERT_NULL(moved_victim.GetComponent(/datum/component/kidnap_captivity), "A forced move out of the pocket should remove stale captivity state.")
	TEST_ASSERT_EQUAL(SSpocket_dimensions.get_instance(moved_instance_key), moved_instance, "Forced movement cleanup should not destroy an emptied shared lair.")
	SSpocket_dimensions.delete_instance(moved_instance)

/datum/unit_test/defeat_captivity_rune_cleanup_and_rejection_aftermath
	needs_pocket_space = TRUE

/datum/unit_test/defeat_captivity_rune_cleanup_and_rejection_aftermath/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/rejecting_victim = allocate(/mob/living/carbon/human, origin)
	rejecting_victim.defeat_system_ai_opt_in = TRUE
	TEST_ASSERT(rejecting_victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL), "The rejection victim should enter Defeat with a snapshot.")
	TEST_ASSERT(rejecting_victim.kidnap_to_pocket(/datum/defeat_captivity_profile/per_captive/unit_test, null), "The rejection victim should enter an isolated pocket.")
	var/datum/component/kidnap_captivity/rejecting_captivity = rejecting_victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/rejecting_instance = rejecting_captivity.resolve_instance()
	var/turf/rejection_turf = get_turf(rejecting_victim)
	rejecting_captivity.released = TRUE
	TEST_ASSERT(rejecting_captivity.reject_rune_and_wake(), "Reject Rune and Wake should run bounded recovery in place.")
	TEST_ASSERT_EQUAL(rejecting_victim.GetComponent(/datum/component/kidnap_captivity), rejecting_captivity, "Rune rejection should keep the victim's captivity choices available.")
	TEST_ASSERT(!rejecting_victim.has_status_effect(/datum/status_effect/defeat_knockout), "Rune rejection should remove the Defeat knockout.")
	TEST_ASSERT(rejecting_victim.has_any_defeat_trauma(), "Rune rejection should retain ordinary Defeat trauma.")
	TEST_ASSERT_EQUAL(get_turf(rejecting_victim), rejection_turf, "Rune rejection should wake the victim on their current lair tile.")
	TEST_ASSERT(HAS_TRAIT(rejecting_victim, TRAIT_DEFEAT_REFUSE_ADVANCES), "Rune rejection should automatically refuse the lair's advances.")
	TEST_ASSERT(locate(/datum/action/innate/defeat_refuse_advances) in rejecting_victim.actions, "Rune rejection should let the victim relent through Refuse Advances.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(rejecting_instance), "The rejection test pocket should cleanly tear down afterward.")

	var/mob/living/carbon/human/calling_victim = allocate(/mob/living/carbon/human, origin)
	calling_victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(calling_victim.kidnap_to_pocket(/datum/defeat_captivity_profile/shared/unit_test, null, null, "unit_test_rune_prepare"), "The rune-return cleanup victim should enter a shared pocket.")
	var/datum/component/kidnap_captivity/calling_captivity = calling_victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/calling_instance = calling_captivity.resolve_instance()
	var/calling_instance_key = calling_instance.instance_key
	TEST_ASSERT_EQUAL(calling_captivity.prepare_rune_return(), origin, "Rune preparation should preserve the original capture turf for return guidance.")
	TEST_ASSERT_NULL(calling_victim.GetComponent(/datum/component/kidnap_captivity), "Call-rune preparation should clear captivity state before relocation.")
	TEST_ASSERT_EQUAL(SSpocket_dimensions.get_instance(calling_instance_key), calling_instance, "Rune preparation should leave the stable shared lair registered.")
	SSpocket_dimensions.delete_instance(calling_instance)

/datum/unit_test/defeat_kidnap_reservation_and_grace/Run()
	var/mob/living/carbon/human/first_captor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second_captor = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))

	TEST_ASSERT(victim.try_reserve_kidnap(first_captor), "The first captor should reserve an unclaimed victim.")
	TEST_ASSERT(!victim.try_reserve_kidnap(second_captor), "A second captor must not reserve a victim whose hauling attempt is pending.")
	TEST_ASSERT_EQUAL(victim.get_kidnap_reserver(), first_captor, "The reservation should retain only the first captor.")
	TEST_ASSERT(victim.clear_kidnap_reservation(first_captor), "The owning captor should be able to release its reservation.")
	TEST_ASSERT_NULL(victim.get_kidnap_reserver(), "Releasing a reservation should make the victim claimable again.")

	first_captor.kidnap_captivity_profile = /datum/defeat_captivity_profile/shared/unit_test
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	victim.last_defeat_snapshot = new /datum/defeat_snapshot
	victim.last_defeat_snapshot.reason = DEFEAT_REASON_HORNY
	victim.recent_damage_source_attacker_weakref = WEAKREF(first_captor)
	victim.grant_kidnap_release_grace()
	TEST_ASSERT(!first_captor.is_kidnap_candidate(victim), "Recapture grace should reject an otherwise valid kidnapping candidate.")
	victim.kidnap_protected_until = world.time
	TEST_ASSERT(first_captor.is_kidnap_candidate(victim), "The victim should become claimable again when recapture grace expires.")

/datum/unit_test/defeat_captivity_physical_anchor/Run()
	var/turf/nest_turf = run_loc_floor_bottom_left
	var/mob/living/carbon/human/captor = allocate(/mob/living/carbon/human, get_step(nest_turf, WEST))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, nest_turf)
	var/obj/structure/tentacle_growth/nest/nest = allocate(/obj/structure/tentacle_growth/nest, nest_turf)
	var/obj/item/rope/spider_silk/tentacle_resin/restraints = allocate(/obj/item/rope/spider_silk/tentacle_resin)
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)

	TEST_ASSERT(restraints.apply_cuffs(victim), "The guardian fixture should resin-bind its victim before nesting them.")
	TEST_ASSERT(nest.buckle_mob(victim, TRUE), "The physical nest should accept the defeated victim.")
	TEST_ASSERT(victim.kidnap_at_physical_anchor(/datum/defeat_captivity_profile/shared/unit_test, captor, null, "unit_test_physical", nest), "A buckled victim should enter physical-anchor captivity without a pocket.")
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	TEST_ASSERT_NOTNULL(captivity, "Physical capture should attach the ordinary captivity component.")
	TEST_ASSERT_NULL(captivity.resolve_instance(), "Physical capture must not create a pocket instance.")
	TEST_ASSERT(captivity.is_physical_anchor(nest), "The captivity component should retain its physical restraint as a weak anchor.")
	TEST_ASSERT_EQUAL(get_turf(victim), nest_turf, "Physical capture must not teleport its victim.")

	captivity.release_from_knockout()
	var/datum/action/innate/defeat_refuse_advances/refuse = locate(/datum/action/innate/defeat_refuse_advances) in victim.actions
	TEST_ASSERT_NOTNULL(refuse, "Waking in a physical nest should grant Refuse Advances.")
	refuse.Activate()
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES), "Refuse Advances should protect a physically restrained captive from horny targeting.")

	nest.unbuckle_mob(victim, force = TRUE)
	TEST_ASSERT_NULL(victim.GetComponent(/datum/component/kidnap_captivity), "Leaving the physical restraint should end captivity.")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES), "Leaving the physical restraint should clear the opt-out trait.")
	TEST_ASSERT(!(locate(/datum/action/innate/defeat_refuse_advances) in victim.actions), "Leaving the physical restraint should remove Refuse Advances.")
	TEST_ASSERT(victim.kidnap_protected_until > world.time, "Leaving the physical restraint should grant recapture grace.")

#ifdef FOCUS_DEFEAT_CAPTIVITY_TEST
TEST_FOCUS(/datum/unit_test/defeat_captivity_shared_reuse_and_exit)
TEST_FOCUS(/datum/unit_test/defeat_captivity_capacity)
TEST_FOCUS(/datum/unit_test/defeat_captivity_carrier_keys_and_owner_teardown)
TEST_FOCUS(/datum/unit_test/defeat_captivity_per_captive_and_delete_paths)
TEST_FOCUS(/datum/unit_test/defeat_captivity_wilds_first_and_forced_move_cleanup)
TEST_FOCUS(/datum/unit_test/defeat_captivity_rune_cleanup_and_rejection_aftermath)
TEST_FOCUS(/datum/unit_test/defeat_kidnap_reservation_and_grace)
TEST_FOCUS(/datum/unit_test/defeat_captivity_physical_anchor)
#endif
