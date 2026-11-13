/// Every real vagina comes with exactly one hidden womb, on every spawn path, and never two.

/datum/unit_test/womb_pairs_with_vagina_on_every_species/Run()
	var/checked = 0
	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = new species_type
		var/has_vagina_customizer = FALSE
		for(var/customizer_type in species.customizers)
			if(ispath(customizer_type, /datum/customizer/organ/genitals/vagina))
				has_vagina_customizer = TRUE
				break
		qdel(species)
		if(!has_vagina_customizer)
			continue
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
		body.set_species(species_type)
		// Some species build genitals on gain; whatever arrived, wombs and vaginas must match one to one.
		TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_WOMB)), length(body.getorganslotlist(ORGAN_SLOT_VAGINA)), "[species_type]: a womb must exist exactly when a vagina does.")
		body.gender = FEMALE
		body.give_genitals()
		TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_VAGINA)), 1, "[species_type]: give_genitals should give one vagina.")
		TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_WOMB)), 1, "[species_type]: the vagina should bring exactly one womb.")
		var/obj/item/organ/genitals/filling_organ/womb/womb = body.get_womb()
		TEST_ASSERT(!womb.visible_organ && isnull(womb.get_render_key_state()), "[species_type]: the womb must stay hidden and out of the render key.")
		checked += 1
	TEST_ASSERT(checked >= 30, "Expected to check most species, checked only [checked].")

/datum/unit_test/womb_regenerates_from_dna/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.gender = FEMALE
	var/datum/organ_dna/vagina/vagina_dna = new
	vagina_dna.organ_type = /obj/item/organ/genitals/filling_organ/vagina
	body.dna.organ_dna[ORGAN_SLOT_VAGINA] = vagina_dna
	var/datum/organ_dna/womb/womb_dna = new
	womb_dna.organ_type = /obj/item/organ/genitals/filling_organ/womb
	womb_dna.fertility = FALSE
	body.dna.organ_dna[ORGAN_SLOT_WOMB] = womb_dna
	body.dna.species.regenerate_organs(body, null, TRUE, null, null)
	TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_VAGINA)), 1, "DNA should yield one vagina.")
	TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_WOMB)), 1, "DNA should yield one womb, with no extra from the pairing hook.")
	var/obj/item/organ/genitals/filling_organ/womb/womb = body.get_womb()
	TEST_ASSERT(!womb.fertility, "The womb should take fertility from its DNA.")
	TEST_ASSERT(!body.is_fertile(), "The body's fertility is read from the womb.")

	// A heal regenerates without prefs and must keep the womb it finds, contents and all.
	body.dna.species.regenerate_organs(body, null, TRUE, null, null)
	TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_WOMB)), 1, "A heal should leave exactly one womb.")
	TEST_ASSERT_EQUAL(body.get_womb(), womb, "A heal should keep the same womb.")
	TEST_ASSERT(!womb.fertility, "A kept womb keeps its fertility.")

/datum/unit_test/womb_survives_gender_potion_round_trip/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.gender = FEMALE
	body.give_genitals()
	var/obj/item/organ/genitals/filling_organ/womb/womb = body.get_womb()
	TEST_ASSERT_NOTNULL(womb, "A female NPC body should start with a womb.")

	body.gender = MALE
	TEST_ASSERT(body.apply_gender_potion_genital_change(FEMALE), "The potion should swap to the masculine set.")
	TEST_ASSERT_NULL(body.getorganslot(ORGAN_SLOT_VAGINA), "The masculine set should drop the vagina.")
	TEST_ASSERT_NULL(body.getorganslot(ORGAN_SLOT_WOMB), "The womb should leave with the vagina.")

	body.gender = FEMALE
	TEST_ASSERT(body.apply_gender_potion_genital_change(MALE), "The potion should restore the feminine set.")
	TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_VAGINA)), 1, "The restore should bring back one vagina.")
	TEST_ASSERT_EQUAL(length(body.getorganslotlist(ORGAN_SLOT_WOMB)), 1, "The restore should bring back exactly one womb.")
	TEST_ASSERT_EQUAL(body.get_womb(), womb, "The stored womb should come back, not a new one.")
