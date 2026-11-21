/// Character Creator: export/import validation, job priorities and the preferred subclass order.

/// A crafted export must not turn a quirk option into an arbitrary path: the pet quirk spawns it.
/datum/unit_test/character_creator_import_quirk_value/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	var/datum/quirk/pet = GLOB.quirk_singletons[/datum/quirk/positive/pet]
	TEST_ASSERT_NOTNULL(pet, "The pet quirk singleton should exist")
	TEST_ASSERT(length(pet.customization_options), "The pet quirk should offer at least one pet")
	var/offered = pet.customization_options[1]

	TEST_ASSERT_EQUAL(prefs.character_creator_quirk_value(/datum/quirk/positive/pet, "[offered]"), offered, "An offered pet should be kept")
	TEST_ASSERT_NULL(prefs.character_creator_quirk_value(/datum/quirk/positive/pet, "/mob/living/simple_animal/hostile"), "A mob type the quirk does not offer must be dropped")
	TEST_ASSERT_NULL(prefs.character_creator_quirk_value(/datum/quirk/positive/pet, "/obj/item"), "A non-mob path must be dropped")
	TEST_ASSERT_NULL(prefs.character_creator_quirk_value(/datum/quirk/positive/pet, 5), "A number must be dropped for a select quirk")

	prefs.character_creator_import_quirks(list(list("type" = "[/datum/quirk/positive/pet]", "value" = "/mob/living/simple_animal/hostile")))
	TEST_ASSERT(prefs.quirk_customizations[/datum/quirk/positive/pet] != /mob/living/simple_animal/hostile, "The importer must never store an unoffered pet path")

/// The customizer importer may only write the fields the editor itself changes.
/datum/unit_test/character_creator_import_customizer_fields/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.validate_customizer_entries()
	TEST_ASSERT(length(prefs.customizer_entries), "A fresh character should have customizer entries")
	var/datum/customizer_entry/source = prefs.customizer_entries[1]

	var/list/fields = character_creator_customizer_fields(source)
	for(var/forbidden in list("type", "parent_type", "vars", "tag", "gc_destroyed", "datum_flags", "customizer_type", "customizer_choice_type"))
		TEST_ASSERT(!(forbidden in fields), "[forbidden] must not be importable")
	TEST_ASSERT("accessory_type" in fields, "accessory_type should be importable")
	TEST_ASSERT_NULL(character_creator_customizer_value(source, "accessory_type", "/mob/living"), "An accessory must be a sprite accessory type")
	TEST_ASSERT_NULL(character_creator_customizer_value(source, "disabled", "yes"), "disabled only takes a number")

	var/list/forged = list(
		"customizer_type" = "[source.customizer_type]",
		"customizer_choice_type" = "[source.customizer_choice_type]",
		"tag" = "cc_unit_test_tag",
		"type" = "/datum",
		"gc_destroyed" = 1,
		"datum_flags" = 255,
		"disabled" = "not a number",
	)
	prefs.character_creator_import_customizers(list(forged))
	TEST_ASSERT_NULL(locate("cc_unit_test_tag"), "A forged tag must not be written")
	for(var/datum/customizer_entry/entry as anything in prefs.customizer_entries)
		TEST_ASSERT(!QDELETED(entry), "Imported entries must not be marked as deleted")
		TEST_ASSERT(isnum(entry.disabled), "disabled must stay a number")

/// The role menu allows one High job; an import keeps the same rule and skips unknown jobs.
/datum/unit_test/character_creator_import_single_high_job/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	var/list/imported = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		imported[job.title] = JP_HIGH
		if(length(imported) >= 3)
			break
	TEST_ASSERT(length(imported) >= 2, "The test needs at least two joinable jobs")
	imported["Character Creator Test Job"] = JP_HIGH

	prefs.character_creator_import_jobs(null, imported)

	var/high_count = 0
	for(var/job_title in prefs.job_preferences)
		if(prefs.job_preferences[job_title] == JP_HIGH)
			high_count++
	TEST_ASSERT_EQUAL(high_count, 1, "Exactly one imported job may stay at High")
	TEST_ASSERT(!("Character Creator Test Job" in prefs.job_preferences), "Unknown jobs must be skipped")

/// Job priorities must survive a save and reload, or old saves keep their stale job list.
/datum/unit_test/character_creator_job_priorities_save
	var/save_path

/datum/unit_test/character_creator_job_priorities_save/Destroy()
	if(save_path)
		fdel(save_path)
	return ..()

/datum/unit_test/character_creator_job_priorities_save/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	save_path = "[GLOB.log_directory]/character_creator_jobs_test.sav"
	fdel(save_path)
	prefs.path = save_path
	prefs.job_preferences = list("Saved Old Job" = JP_HIGH)
	TEST_ASSERT(prefs.save_character(), "The first save should succeed")

	prefs.job_preferences = list("Saved High Job" = JP_HIGH, "Saved Medium Job" = JP_MEDIUM, "Saved Low Job" = JP_LOW)
	TEST_ASSERT(prefs.save_character(), "The second save should succeed")
	prefs.job_preferences = list()
	TEST_ASSERT(prefs.load_character(prefs.default_slot), "The saved character should load")

	TEST_ASSERT_EQUAL(length(prefs.job_preferences), 3, "Every saved job priority should load back")
	TEST_ASSERT_EQUAL(prefs.job_preferences["Saved High Job"], JP_HIGH, "The High job should load back")
	TEST_ASSERT_EQUAL(prefs.job_preferences["Saved Medium Job"], JP_MEDIUM, "The Medium job should load back")
	TEST_ASSERT(!("Saved Old Job" in prefs.job_preferences), "A later save must replace the earlier job list")

/// The preferred subclass only moves an already rolled class to the front.
/datum/unit_test/character_creator_preferred_class_order/Run()
	var/list/rolled = list("first" = 1, "second" = 2, "third" = 3)

	var/list/ordered = character_creator_order_classes(rolled, "third")
	TEST_ASSERT_EQUAL(ordered[1], "third", "The preferred class should come first")
	TEST_ASSERT_EQUAL(length(ordered), 3, "Reordering must keep every rolled class")
	TEST_ASSERT_EQUAL(ordered["first"], 1, "Reordering must keep the rolled amounts")

	var/list/unchanged = character_creator_order_classes(rolled, "not rolled")
	TEST_ASSERT_EQUAL(length(unchanged), 3, "A class the roll did not offer must not be added")
	TEST_ASSERT(!("not rolled" in unchanged), "A class the roll did not offer must not be added")
	TEST_ASSERT_EQUAL(unchanged[1], "first", "The order stays as rolled when the preferred class is missing")

/// An exported character comes back the same through JSON, with display text rebuilt.
/datum/unit_test/character_creator_export_import_round_trip/Run()
	var/datum/preferences/source = allocate(/datum/preferences)
	source.write_preference(/datum/preference/text/real_name, "Laniel Thornwood")
	source.write_preference(/datum/preference/text/flavortext, "A tall *woman*.")
	source.validate_customizer_entries()

	var/list/payload = json_decode(json_encode(source.character_creator_export_payload()))
	TEST_ASSERT_EQUAL(payload["format"], "rmh_character", "The export should be marked as a character export")

	var/datum/preferences/target = allocate(/datum/preferences)
	target.character_creator_apply_import(null, payload)

	TEST_ASSERT_EQUAL(target.read_preference(/datum/preference/text/real_name), "Laniel Thornwood", "The name should survive the round trip")
	TEST_ASSERT_EQUAL(target.pref_species?.type, source.pref_species?.type, "The species should survive the round trip")
	TEST_ASSERT_EQUAL(length(target.customizer_entries), length(source.customizer_entries), "Every customizer entry should come back")
	var/display = target.read_preference(/datum/preference/text/flavortext_display)
	TEST_ASSERT(findtext(display, "<i>woman</i>"), "Display text should be rebuilt from the plain flavour text")
