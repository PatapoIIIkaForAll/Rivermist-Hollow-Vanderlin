/// Organ blood_req offsets the brain's oxygenation reading; a standard body must not read as blood-starved.
/datum/unit_test/blood_req_baseline
#ifdef FOCUS_BLOOD_REQ_TEST
	focus = TRUE
#endif

/datum/unit_test/blood_req_baseline/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.set_species(/datum/species/human/northern)
	TEST_ASSERT(abs(human.total_blood_req - DEFAULT_TOTAL_BLOOD_REQ) < 1, "Standard human total_blood_req is [human.total_blood_req], DEFAULT_TOTAL_BLOOD_REQ is [DEFAULT_TOTAL_BLOOD_REQ]")

	// Extra-organ sets drift from the baseline; keep that drift well inside the SAFE band.
	var/max_offset = BLOOD_VOLUME_NORMAL * 0.05
	for(var/species_type in list(/datum/species/lizardfolk, /datum/species/anthromorph, /datum/species/harpy))
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
		body.set_species(species_type)
		var/offset = body.total_blood_req - DEFAULT_TOTAL_BLOOD_REQ
		if(abs(offset) > max_offset)
			TEST_FAIL("[species_type] total_blood_req offset is [offset], limit is [max_offset]")

/// Species organ lists replace the base list, so ported species can silently drop core organs.
/// Blooded species need a spleen to regenerate blood; every species carries guts for mouth storage.
/datum/unit_test/species_have_spleen_and_guts
#ifdef FOCUS_BLOOD_REQ_TEST
	focus = TRUE
#endif

/datum/unit_test/species_have_spleen_and_guts/Run()
	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = new species_type
		var/bloodless = (NOBLOOD in species.species_traits) || (TRAIT_BLOODLOSS_IMMUNE in species.inherent_traits)
		var/has_spleen = !isnull(LAZYACCESS(species.organs, ORGAN_SLOT_SPLEEN))
		var/has_guts = !isnull(LAZYACCESS(species.organs, ORGAN_SLOT_GUTS))
		qdel(species)
		if(!bloodless && !has_spleen)
			TEST_FAIL("[species_type] has blood but no spleen in its organs list")
		if(!has_guts)
			TEST_FAIL("[species_type] has no guts in its organs list")
