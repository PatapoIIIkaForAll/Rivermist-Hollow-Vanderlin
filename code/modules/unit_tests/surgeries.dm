/datum/unit_test/amputation/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/weapon/surgery/saw/saw = allocate(/obj/item/weapon/surgery/saw)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 0, "Patient is somehow missing limbs before surgery")

	var/datum/surgery_operation/limb/amputate/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]

	UNLINT(surgery.success(patient.get_bodypart(BODY_ZONE_R_ARM), user, saw, list()))

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 1, "Patient did not lose any limbs")
	TEST_ASSERT_EQUAL(patient.get_missing_limbs()[1], BODY_ZONE_R_ARM, "Patient is missing a limb that isn't the one we operated on")

/datum/unit_test/head_transplant/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	var/mob/living/carbon/human/alice = allocate(/mob/living/carbon/human)
	alice.fully_replace_character_name(null, "Alice")

	var/mob/living/carbon/human/bob = allocate(/mob/living/carbon/human)
	bob.fully_replace_character_name(null, "Bob")

	var/obj/item/bodypart/head/alices_head = alice.get_bodypart(BODY_ZONE_HEAD)
	alices_head.drop_limb()

	var/obj/item/bodypart/head/bobs_head = bob.get_bodypart(BODY_ZONE_HEAD)
	bobs_head.drop_limb()

	TEST_ASSERT_EQUAL(alice.get_bodypart(BODY_ZONE_HEAD), null, "Alice still has a head after dismemberment")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Unknown", "Alice's head was dismembered, but they are not Unknown")

	TEST_ASSERT_EQUAL(bobs_head.real_name, "Bob", "Bob's head does not remember that it is from Bob")

	// Put Bob's head onto Alice's body
	var/datum/surgery_operation/limb_replacement/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	user.put_in_active_hand(bobs_head)
	UNLINT(surgery.success(alice, user, bobs_head, list()))

	TEST_ASSERT(!isnull(alice.get_bodypart(BODY_ZONE_HEAD)), "Alice has no head after prosthetic replacement")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Bob", "Bob's head was transplanted onto Alice's body, but their name is not Bob")

/datum/unit_test/proc/open_test_organ_storage(mob/living/carbon/human/patient)
	var/datum/component/storage/concrete/organ/organ_storage = patient.GetComponent(/datum/component/storage/concrete/organ)
	TEST_ASSERT_NOTNULL(organ_storage, "Patient has no organ storage component")

	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_NOTNULL(chest, "Patient has no chest to open for organ storage")

	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	organ_storage.assign_bodypart(chest)

	TEST_ASSERT(organ_storage.is_accessible(), "Organ storage was not accessible after opening the surgical site")
	return organ_storage

/datum/unit_test/genital_organs_cannot_be_inserted_through_surgery

/datum/unit_test/genital_organs_cannot_be_inserted_through_surgery/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	user.used_intent = user.a_intent

	var/datum/component/storage/concrete/organ/organ_storage = open_test_organ_storage(patient)
	var/obj/item/organ/genitals/penis/penis = allocate(/obj/item/organ/genitals/penis)

	TEST_ASSERT(!organ_storage.can_be_inserted(penis, TRUE, user), "Surgery storage accepted a genital organ for insertion")

/datum/unit_test/genital_organs_cannot_be_removed_through_surgery_storage

/datum/unit_test/genital_organs_cannot_be_removed_through_surgery_storage/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	var/datum/component/storage/concrete/organ/organ_storage = open_test_organ_storage(patient)
	var/obj/item/organ/genitals/penis/penis = allocate(/obj/item/organ/genitals/penis)
	penis.Insert(patient, TRUE, TRUE)
	penis.organ_flags |= ORGAN_CUT_AWAY

	TEST_ASSERT(penis in organ_storage.contents(), "Inserted genital organ was not visible in open organ storage")
	TEST_ASSERT(!organ_storage.remove_from_storage(penis, get_turf(patient)), "Surgery storage removed a genital organ")
	TEST_ASSERT_EQUAL(penis.owner, patient, "Blocked genital removal still detached the organ from its owner")

/datum/unit_test/suture_tool_only_tends_brute_wounds

/datum/unit_test/suture_tool_only_tends_brute_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/needle/needle = allocate(/obj/item/needle)
	patient.take_overall_damage(10, 10)

	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	var/list/options = surgery.get_radial_options(patient, needle, BODY_ZONE_CHEST)
	TEST_ASSERT(length(options), "Sutures did not offer brute wound tending")
	for(var/option in options)
		var/list/operation_args = options[option]
		TEST_ASSERT(operation_args[OPERATION_BRUTE_HEAL] > 0, "A suture option did not tend brute wounds")
		TEST_ASSERT(!operation_args[OPERATION_BURN_HEAL], "Sutures offered burn wound tending")

	patient.set_body_position(LYING_DOWN)
	var/obj/item/bodypart/chest/patient_chest = patient.get_bodypart(BODY_ZONE_CHEST)
	patient_chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/obj/item/weapon/surgery/hemostat/hemostat = allocate(/obj/item/weapon/surgery/hemostat)
	var/datum/surgery_operation/basic/tend_wounds/combo/combo_surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT(combo_surgery.check_availability(patient, patient, surgeon, hemostat, BODY_ZONE_CHEST), "Mixed wound tending test setup was not otherwise operable")
	TEST_ASSERT(!combo_surgery.check_availability(patient, patient, surgeon, needle, BODY_ZONE_CHEST), "Sutures were accepted for mixed burn/brute tending")

/datum/unit_test/surgery_success_curve_is_driven_by_medicine_skill

/datum/unit_test/surgery_success_curve_is_driven_by_medicine_skill/Run()
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]

	TEST_ASSERT_EQUAL(FLOOR(surgery.get_base_roll_requirement_for_skill(0), 1), 22, "No medicine skill should retain a desperate baseline chance")
	TEST_ASSERT_EQUAL(FLOOR(surgery.get_base_roll_requirement_for_skill(15), 1), 31, "Basic medicine should reach roughly even surgery odds")
	TEST_ASSERT_EQUAL(FLOOR(surgery.get_base_roll_requirement_for_skill(30), 1), 40, "Journeyman medicine should be strongly reliable")
	TEST_ASSERT_EQUAL(FLOOR(surgery.get_base_roll_requirement_for_skill(40), 1), 48, "Expert medicine should nearly always succeed")
	TEST_ASSERT_EQUAL(FLOOR(surgery.get_base_roll_requirement_for_skill(60), 1), 53, "Legendary medicine should be just short of guaranteed success")

/datum/unit_test/surgery_critical_failures_stop_at_basic_medicine

/datum/unit_test/surgery_critical_failures_stop_at_basic_medicine/Run()
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]

	TEST_ASSERT_EQUAL(surgery.get_critical_failure_roll_threshold(0), 45, "Unskilled surgery should retain meaningful critical-failure risk")
	TEST_ASSERT_EQUAL(surgery.get_critical_failure_roll_threshold(10), 50, "Novice surgery should retain a small critical-failure risk")
	TEST_ASSERT_EQUAL(surgery.get_critical_failure_roll_threshold(14), 55, "Critical-failure risk should nearly vanish below 15 medicine")
	TEST_ASSERT(surgery.get_critical_failure_roll_threshold(15) > surgery.dice_num * surgery.dice_sides, "Critical failures should stop at 15 medicine")

/datum/unit_test/surgery_tool_quality_modifiers_reward_better_tools

/datum/unit_test/surgery_tool_quality_modifiers_reward_better_tools/Run()
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]

	TEST_ASSERT_EQUAL(surgery.get_tool_quality_roll_modifier(0.5), 3, "Fast surgical tools should improve surgery odds")
	TEST_ASSERT_EQUAL(surgery.get_tool_quality_roll_modifier(1), 0, "Standard surgical tools should be neutral")
	TEST_ASSERT_EQUAL(surgery.get_tool_quality_roll_modifier(1.5), -3, "Slow surgical tools should make surgery harder")
	TEST_ASSERT_EQUAL(surgery.get_tool_quality_roll_modifier(2), -6, "Improvised surgical tools should be noticeably harder to use")

// Ensures that the tend wounds surgery can be started
/datum/unit_test/start_tend_wounds

/datum/unit_test/start_tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/weapon/surgery/hemostat/hemostat = allocate(/obj/item/weapon/surgery/hemostat)

	patient.set_body_position(LYING_DOWN)

	var/obj/item/bodypart/chest/patient_chest = patient.get_bodypart(BODY_ZONE_CHEST)

	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was available on an undamaged, unoperated patient")

	patient.take_overall_damage(10, 10)
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was available on a damaged but unoperated patient")

	patient_chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	TEST_ASSERT(surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was not available on a damaged, operated patient")

/datum/unit_test/tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.take_overall_damage(100, 100)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/weapon/surgery/hemostat/hemostat = allocate(/obj/item/weapon/surgery/hemostat)

	// Test that tending wounds actually lowers damage
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(surgery.success(patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))
	TEST_ASSERT(patient.getBruteLoss() < 100, "Tending brute wounds didn't lower brute damage ([patient.getBruteLoss()])")

/// Checks all operations have a name and description
/datum/unit_test/verify_surgery_setup

/datum/unit_test/verify_surgery_setup/Run()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(subtypesof(/datum/surgery_operation)))
		if (isnull(operation.name))
			TEST_FAIL("Surgery operation [operation.type] has no name set")
		if (isnull(operation.desc))
			TEST_FAIL("Surgery operation [operation.type] has no description set")

/// Tests that make incision shows up when expected
/datum/unit_test/incision_check

/datum/unit_test/incision_check/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)

	var/obj/item/weapon/surgery/scalpel/scalpel = allocate(/obj/item/weapon/surgery/scalpel)
	var/list/operations

	surgeon.put_in_active_hand(scalpel)
	operations = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(length(operations), 0, "Surgery operations were available on a standing patient")

	patient.set_body_position(LYING_DOWN)
	operations = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)
	if(length(operations) > 1)
		TEST_FAIL("More operations than expected were available on the patient")
		return

	if(length(operations) == 1)
		var/list/found_operation_data = operations[operations[1]]
		var/datum/surgery_operation/operation = found_operation_data[1]
		var/atom/movable/operating_on = found_operation_data[2]
		TEST_ASSERT_EQUAL(operation.type, /datum/surgery_operation/limb/incise_skin, "The available surgery operation was not \"make incision\"")
		TEST_ASSERT_EQUAL(operating_on, patient.get_bodypart(BODY_ZONE_CHEST), "The available surgery operation was not on the chest bodypart")
		return

	TEST_ASSERT_EQUAL(patient.body_position, LYING_DOWN, "Patient is not lying down as expected")

	var/datum/surgery_operation/incise_operation = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]
	var/atom/movable/operate_on = incise_operation.get_operation_target(patient, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(operate_on, patient.get_bodypart(BODY_ZONE_CHEST), "Incise skin operation did not return the chest bodypart as a valid operation target")

	if(incise_operation.check_availability(patient, operate_on, surgeon, scalpel, BODY_ZONE_CHEST))
		TEST_FAIL("Make incision operation was not found among available operations despite being available")
	else
		TEST_FAIL("Make incision operation was not available when it should have been")

/// Tests surgeries which just modify basic surgical states
/datum/unit_test/state_surgeries

/datum/unit_test/state_surgeries/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)

	var/obj/item/weapon/surgery/scalpel/scalpel = allocate(/obj/item/weapon/surgery/scalpel)
	var/obj/item/weapon/surgery/retractor/retractor = allocate(/obj/item/weapon/surgery/retractor)
	var/obj/item/weapon/surgery/saw/saw = allocate(/obj/item/weapon/surgery/saw)
	var/obj/item/weapon/surgery/hemostat/hemostat = allocate(/obj/item/weapon/surgery/hemostat)
	var/obj/item/weapon/surgery/cautery/cautery = allocate(/obj/item/weapon/surgery/cautery)
	var/obj/item/weapon/surgery/bonesetter/bonesetter = allocate(/obj/item/weapon/surgery/bonesetter)

	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)

	var/datum/surgery_operation/limb/incise_skin/isurgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(isurgery.success(chest, surgeon, scalpel, list()))

	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_CUT), "Making an incision did not apply the skin cut surgical state")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_VESSELS_UNCLAMPED), "Making an incision did not apply the vessels unclamped surgical state")

	var/datum/surgery_operation/limb/retract_skin/rsurgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(rsurgery.success(chest, surgeon, retractor, list()))

	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_CUT), "Retracting skin did not remove the skin cut surgical state")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_OPEN), "Retracting skin did not apply the skin open surgical state")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_VESSELS_UNCLAMPED), "Retracting skin removed the vessels unclamped surgical state unexpectedly")

	var/datum/surgery_operation/limb/clamp_bleeders/csurgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(csurgery.success(chest, surgeon, hemostat, list()))

	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_VESSELS_UNCLAMPED), "Clamping bleeders did not remove the vessels unclamped surgical state")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_VESSELS_CLAMPED), "Clamping bleeders did not apply the vessels clamped surgical state")

	var/datum/surgery_operation/limb/saw_bones/ssurgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(ssurgery.success(chest, surgeon, saw, list()))

	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_BONE_SAWED), "Sawing bones did not apply the bone sawed surgical state")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_VESSELS_CLAMPED), "Sawing bones removed the vessels clamped surgical state unexpectedly")
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_OPEN), "Sawing bones removed the skin open surgical state unexpectedly")

	var/datum/surgery_operation/limb/fix_bones/bsurgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(bsurgery.success(chest, surgeon, bonesetter, list()))

	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_BONE_SAWED), "Fixing bones did not remove the bone sawn surgery state")

	chest.remove_embedded_object(retractor)

	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_OPEN), "Removing retractor did not remove the open surgical state")

	chest.remove_embedded_object(hemostat)

	TEST_ASSERT(!LIMB_HAS_SURGERY_STATE(chest, SURGERY_VESSELS_CLAMPED), "Removing hemostat did not remove the clamped surgical state")

	var/datum/surgery_operation/limb/close_skin/msurgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(msurgery.success(chest, surgeon, cautery, list()))

	TEST_ASSERT(!LIMB_HAS_ANY_SURGERY_STATE(chest, ALL), "Closing surgery did not remove all surgical states applied during surgery")

/// Any surgeon may detach a prosthetic of any material; engineering only improves the odds.
/datum/unit_test/detach_prosthetic_needs_no_skill/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/obj/item/weapon/surgery/saw/saw = allocate(/obj/item/weapon/surgery/saw)
	var/obj/item/bodypart/old_arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	old_arm.drop_limb()
	qdel(old_arm)
	var/obj/item/bodypart/r_arm/prosthetic/iron/arm = new(null)
	arm.attach_limb(patient)
	patient.set_body_position(LYING_DOWN)
	surgeon.put_in_active_hand(saw)

	var/datum/surgery_operation/limb/amputate/pegleg/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT(surgery.check_availability(patient, arm, surgeon, saw, BODY_ZONE_R_ARM), "Detaching should be offered for an iron prosthetic")
	var/engineering = GET_MOB_SKILL_VALUE(surgeon, surgery.skill_used) || 0
	TEST_ASSERT(engineering >= surgery.skill_min, "A surgeon without engineering must not auto-fail for lack of skill")

	UNLINT(surgery.success(arm, surgeon, saw, list(), FALSE))
	TEST_ASSERT_NULL(patient.get_bodypart(BODY_ZONE_R_ARM), "The prosthetic should come off")
