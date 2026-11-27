/datum/unit_test/silk_weaving_grant/Run()
	var/mob/living/carbon/human/weaver = allocate(/mob/living/carbon/human)
	weaver.set_species(/datum/species/elf/dark/drider)
	TEST_ASSERT(HAS_TRAIT(weaver, TRAIT_SILK_WEAVER), "Driders must be silk weavers.")
	TEST_ASSERT(HAS_TRAIT(weaver, TRAIT_WEBWALK), "Silk weavers must walk through webs.")
	var/list/granted = list()
	for(var/datum/action/cooldown/silk_weaving/weaving_action in weaver.actions)
		granted += weaving_action.type
		TEST_ASSERT(icon_exists(weaving_action.button_icon, weaving_action.button_icon_state), "[weaving_action.type] has no button art.")
	TEST_ASSERT_EQUAL(length(granted), length(SILK_WEAVING_ACTIONS), "Each weaving action must be granted exactly once.")
	for(var/action_type in SILK_WEAVING_ACTIONS)
		TEST_ASSERT(action_type in granted, "[action_type] was not granted.")

	weaver.add_quirk(/datum/quirk/positive/silk_weaver)
	TEST_ASSERT_EQUAL(length(granted), count_weaving_actions(weaver), "A second source must not duplicate the actions.")
	weaver.remove_quirk(/datum/quirk/positive/silk_weaver)
	TEST_ASSERT_EQUAL(count_weaving_actions(weaver), length(granted), "Removing the quirk must keep the drider's actions.")

	weaver.set_species(/datum/species/taur_kin)
	TEST_ASSERT(!HAS_TRAIT(weaver, TRAIT_SILK_WEAVER), "Leaving the drider species must remove weaving.")
	TEST_ASSERT_EQUAL(count_weaving_actions(weaver), 0, "Leaving the drider species must remove the actions.")
	weaver.add_quirk(/datum/quirk/positive/silk_weaver)
	TEST_ASSERT_EQUAL(count_weaving_actions(weaver), length(granted), "The quirk must grant the actions.")
	weaver.remove_quirk(/datum/quirk/positive/silk_weaver)
	TEST_ASSERT_EQUAL(count_weaving_actions(weaver), 0, "Removing the quirk must remove the actions.")
	TEST_ASSERT(!HAS_TRAIT(weaver, TRAIT_WEBWALK), "Removing the quirk must remove web walking.")

/datum/unit_test/silk_weaving_grant/proc/count_weaving_actions(mob/living/weaver)
	. = 0
	for(var/datum/action/cooldown/silk_weaving/weaving_action in weaver.actions)
		.++

/datum/unit_test/silk_weaving_web/Run()
	var/turf/center = get_step(get_step(run_loc_floor_bottom_left, NORTH), EAST)
	var/mob/living/carbon/human/weaver = allocate(/mob/living/carbon/human, center)
	weaver.set_species(/datum/species/elf/dark/drider)
	ADD_TRAIT(weaver, TRAIT_NOSTAMINA, TRAIT_SOURCE_UNIT_TESTS)
	var/datum/action/cooldown/silk_weaving/web/web_action = locate() in weaver.actions
	web_action.spin_time = 1
	TEST_ASSERT(web_action.Activate(center), "An uninterrupted weave must succeed.")
	var/obj/structure/spider/stickyweb/web = locate() in center
	TEST_ASSERT(web && !istype(web, /obj/structure/spider/stickyweb/thin), "Two passes must leave a dense web.")
	allocated += web
	TEST_ASSERT(!web_action.can_place(center), "A dense web must refuse more weaving.")
	qdel(web)
	var/obj/structure/spider/stickyweb/thin/thin = allocate(/obj/structure/spider/stickyweb/thin, center)
	TEST_ASSERT(web_action.can_place(center), "A thin web must accept reinforcement.")
	web_action.next_use_time = 0
	TEST_ASSERT(web_action.Activate(center), "Reinforcing a thin web must succeed.")
	TEST_ASSERT(QDELETED(thin), "Reinforcement must replace the thin web.")
	web = locate() in center
	TEST_ASSERT(web && !istype(web, /obj/structure/spider/stickyweb/thin), "Reinforcement must leave a dense web.")
	allocated += web

/datum/unit_test/silk_bed/Run()
	var/turf/center = get_step(get_step(run_loc_floor_bottom_left, NORTH), EAST)
	var/obj/structure/bed/silk/bed = allocate(/obj/structure/bed/silk, center)
	TEST_ASSERT_EQUAL(bed.sleepy, 0.75, "The first weave must offer bedroll comfort.")
	TEST_ASSERT_NULL(bed.veil, "The first weave must only cover the floor.")
	TEST_ASSERT(icon_exists(bed.icon, "basic") && icon_exists(bed.icon, "complete") && icon_exists(bed.icon, "complete_front"), "Silk bed art is missing.")
	var/datum/action/cooldown/silk_weaving/bed/bed_action = allocate(/datum/action/cooldown/silk_weaving/bed)
	TEST_ASSERT(bed_action.can_place(center), "Unfinished bedding must accept a second weave.")
	var/mob/living/carbon/human/sleeper = allocate(/mob/living/carbon/human, center)
	TEST_ASSERT(bed.buckle_mob(sleeper, force = TRUE), "Silk bedding must accept a sleeper.")
	TEST_ASSERT(bed.upgrade(), "The second weave must upgrade the bed.")
	TEST_ASSERT_EQUAL(bed.sleepy, 2, "The veiled bed must offer proper-bed comfort.")
	TEST_ASSERT_EQUAL(sleeper.buckled, bed, "Upgrading must keep the sleeper in bed.")
	TEST_ASSERT_EQUAL(bed.veil.plane, GAME_PLANE_UPPER, "The veil must draw above its sleeper.")
	TEST_ASSERT(!bed.upgrade(), "A veiled bed must refuse further upgrades.")
	TEST_ASSERT(!bed_action.can_place(center), "A veiled bed must refuse another weave.")
	qdel(bed)
	TEST_ASSERT_NULL(sleeper.buckled, "Deleting the bed must release its sleeper.")

/datum/unit_test/silk_cocoon_containment/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, center)
	var/obj/structure/spider/rescue_cocoon/cocoon = allocate(/obj/structure/spider/rescue_cocoon, center)
	patient.blood_volume = 600
	TEST_ASSERT(cocoon.enclose(patient), "An intact cocoon must accept a living patient.")
	TEST_ASSERT_EQUAL(patient.loc, cocoon, "The patient must be inside the cocoon.")
	TEST_ASSERT(!cocoon.Exit(patient, center), "Walking must not bypass the escape action.")
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_SILK_COMPRESSION), "The cocoon must apply compression.")
	patient.bleed(10)
	TEST_ASSERT_EQUAL(patient.blood_volume, 600, "Compression must stop blood loss.")
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, center)
	TEST_ASSERT(!cocoon.enclose(second), "An occupied cocoon must refuse a second patient.")
	patient.forceMove(get_step(center, EAST))
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_SILK_COMPRESSION), "Leaving by force must remove compression.")
	TEST_ASSERT_NULL(cocoon.occupant, "Leaving by force must clear the occupant.")
	TEST_ASSERT(cocoon.opened, "A vacated cocoon must become a spent shell.")
	patient.bleed(10)
	TEST_ASSERT(patient.blood_volume < 600, "Bleeding must resume after release.")
	TEST_ASSERT(!cocoon.enclose(patient), "A spent shell must not be reused.")

/datum/unit_test/silk_cocoon_treatment/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, center)
	patient.adjustBruteLoss(20)
	patient.adjustFireLoss(20)
	patient.adjustOxyLoss(20)
	patient.blood_volume = 600
	var/obj/structure/spider/rescue_cocoon/cocoon = allocate(/obj/structure/spider/rescue_cocoon, center)
	TEST_ASSERT(cocoon.enclose(patient), "A wounded patient must be enclosed.")
	STOP_PROCESSING(SSobj, cocoon)
	var/brute = patient.getBruteLoss()
	var/burn = patient.getFireLoss()
	var/oxygen = patient.getOxyLoss()
	cocoon.next_treatment = world.time
	cocoon.process()
	TEST_ASSERT(patient.getBruteLoss() < brute && patient.getFireLoss() < burn, "Treatment must slowly heal brute and burns.")
	TEST_ASSERT(patient.getOxyLoss() < oxygen, "Treatment must ease oxygen loss.")
	TEST_ASSERT_EQUAL(patient.blood_volume, 600 + cocoon.blood_recovery, "Treatment must restore blood at the slow rate.")
	patient.death()
	TEST_ASSERT_EQUAL(patient.loc, cocoon, "A corpse must stay inside.")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_SILK_COMPRESSION), "Death must end compression.")
	var/blood = patient.blood_volume
	cocoon.next_treatment = world.time
	cocoon.process()
	TEST_ASSERT_EQUAL(patient.blood_volume, blood, "A corpse must not be treated.")
	cocoon.open_cocoon("snipped")
	TEST_ASSERT_EQUAL(patient.loc, center, "Opening must release a corpse.")

/datum/unit_test/silk_cocoon_opening/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, center)
	var/obj/structure/spider/rescue_cocoon/cocoon = allocate(/obj/structure/spider/rescue_cocoon, center)
	cocoon.enclose(patient)
	cocoon.take_damage(1000, BRUTE, "blunt", FALSE)
	TEST_ASSERT(!QDELETED(cocoon), "Breaking an intact cocoon must leave a shell.")
	TEST_ASSERT_EQUAL(cocoon.icon_state, "smashed", "Breaking must use the smashed art.")
	TEST_ASSERT_EQUAL(patient.loc, center, "Breaking must release the patient.")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_SILK_COMPRESSION), "Breaking must end compression.")
	cocoon.take_damage(1000, BRUTE, "blunt", FALSE)
	TEST_ASSERT(QDELETED(cocoon), "Breaking a spent shell must destroy it.")
	for(var/obj/item/natural/silk/silk in center)
		allocated += silk

	var/obj/structure/spider/rescue_cocoon/self_wrap = allocate(/obj/structure/spider/rescue_cocoon, center)
	patient.set_species(/datum/species/elf/dark/drider)
	self_wrap.enclose(patient)
	self_wrap.container_resist(patient)
	TEST_ASSERT_EQUAL(patient.loc, center, "A silk weaver must slip out at once.")
	TEST_ASSERT_EQUAL(self_wrap.icon_state, "snipped", "Slipping out must leave a parted shell.")

	var/obj/structure/spider/rescue_cocoon/deleted = allocate(/obj/structure/spider/rescue_cocoon, center)
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human, center)
	deleted.enclose(other)
	qdel(deleted)
	TEST_ASSERT_EQUAL(other.loc, center, "Deleting a cocoon must release its occupant.")
	TEST_ASSERT(!HAS_TRAIT(other, TRAIT_SILK_COMPRESSION), "Deleting a cocoon must end compression.")

/datum/unit_test/silk_cocoon_cast/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/weaver = allocate(/mob/living/carbon/human, center)
	weaver.set_species(/datum/species/elf/dark/drider)
	var/datum/action/cooldown/silk_weaving/cocoon/cocoon_action = locate() in weaver.actions
	TEST_ASSERT_EQUAL(cocoon_action.charges, cocoon_action.max_charges, "The action must start with full charges.")
	cocoon_action.weave_time = 1
	cocoon_action.charge_delay = 1
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(center, EAST))
	TEST_ASSERT(cocoon_action.Activate(patient), "An adjacent patient must be cocooned.")
	var/obj/structure/spider/rescue_cocoon/cocoon = patient.loc
	TEST_ASSERT(istype(cocoon), "A finished weave must enclose the patient.")
	allocated += cocoon
	TEST_ASSERT_EQUAL(cocoon_action.charges, cocoon_action.max_charges - 1, "A finished weave must spend one charge.")
	TEST_ASSERT(cocoon_action.Activate(weaver), "Self-wrapping must work.")
	var/obj/structure/spider/rescue_cocoon/self_wrap = weaver.loc
	TEST_ASSERT(istype(self_wrap), "Self-wrapping must enclose the weaver.")
	allocated += self_wrap
	self_wrap.container_resist(weaver)
	TEST_ASSERT_EQUAL(weaver.loc, center, "A weaver must slip out of their own cocoon.")
	sleep(1 SECONDS)
	TEST_ASSERT_EQUAL(cocoon_action.charges, cocoon_action.max_charges, "Spent charges must return after their delay.")
