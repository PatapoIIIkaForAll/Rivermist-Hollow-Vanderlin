/datum/unit_test/preferences_preview_taur_cleanup/Run()
	var/dummy_key = "unit_test_preview_taur_cleanup"
	var/datum/preferences/prefs = allocate(/datum/preferences)

	prefs.gender = FEMALE
	prefs.age = AGE_ADULT
	prefs.selected_patron = GLOB.patron_list[prefs.default_patron]

	prefs.pref_species = new /datum/species/yuanti
	prefs.features = prefs.pref_species.get_random_features()
	prefs.body_markings = prefs.pref_species.get_random_body_markings(prefs.features)
	prefs.real_name = prefs.pref_species.random_name(prefs.gender, TRUE)
	prefs.taur_type = /obj/item/bodypart/taur/lamia

	get_flat_human_icon(null, null, prefs, dummy_key, list(SOUTH))

	var/mob/living/carbon/human/dummy/body = GLOB.human_dummy_list[dummy_key]
	TEST_ASSERT_NOTNULL(body, "Expected the preview helper to reuse a pooled human dummy.")

	var/has_taur_body = FALSE
	for(var/obj/item/bodypart/bodypart as anything in body.bodyparts)
		if(bodypart.body_zone == BODY_ZONE_TAUR)
			has_taur_body = TRUE
			break
	TEST_ASSERT(has_taur_body, "Expected the first preview render to leave the pooled dummy taurized.")

	prefs.pref_species = new /datum/species/human/northern
	prefs.features = prefs.pref_species.get_random_features()
	prefs.body_markings = prefs.pref_species.get_random_body_markings(prefs.features)
	prefs.real_name = prefs.pref_species.random_name(prefs.gender, TRUE)
	prefs.taur_type = null

	get_flat_human_icon(null, null, prefs, dummy_key, list(SOUTH))

	has_taur_body = FALSE
	for(var/obj/item/bodypart/bodypart as anything in body.bodyparts)
		if(bodypart.body_zone == BODY_ZONE_TAUR)
			has_taur_body = TRUE
			break
	TEST_ASSERT(!has_taur_body, "Expected a non-taur preview render to clear any taur bodyparts left on the pooled dummy.")

	delete_human_dummy(dummy_key)
