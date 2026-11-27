#ifdef UNIT_TESTS

// Local asserts: _unit_tests.dm undefines the shared ones before this file.
#define QE_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason]", __FILE__, __LINE__) }
#define QE_ASSERT_NULL(a, reason) if(!isnull(a)) { return Fail("Expected null but received [a]: [reason]", __FILE__, __LINE__) }
#define QE_ASSERT_NOTNULL(a, reason) if(isnull(a)) { return Fail("Expected a value: [reason]", __FILE__, __LINE__) }
#define QE_ASSERT_EQUAL(a, b, message) if((a) != (b)) { return Fail("Expected [a] to be equal to [b]. [message]", __FILE__, __LINE__) }

/// Character creator: topic limiter exemptions, action cooldowns, full export round trip, name rules, free Play again.

/// Chat pings and chunks of an accepted payload skip the topic limiter; real actions still count.
/datum/unit_test/topic_limiter_skips_ping_and_chunks/Run()
	var/list/ping = list("tgui" = "1", "type" = "ping", "payload" = json_encode(list("index" = 1)), "window_id" = "browseroutput")
	QE_ASSERT_EQUAL(topic_limiter_cost(ping, null, TRUE), TOPIC_LIMIT_FREE_PING, "A chat ping should not count")
	QE_ASSERT_EQUAL(topic_limiter_cost(ping, null, FALSE), TOPIC_LIMIT_COUNTED, "A second ping inside the free interval should count")

	var/list/pending = list("12345" = list("type" = "act/cc_import"))
	var/list/chunk = list("tgui" = "1", "type" = "payloadChunk", "payload" = json_encode(list("id" = "12345", "chunk" = "abc")), "window_id" = "creator")
	QE_ASSERT_EQUAL(topic_limiter_cost(chunk, pending, TRUE), TOPIC_LIMIT_FREE, "A chunk of an accepted payload should not count")
	QE_ASSERT_EQUAL(topic_limiter_cost(chunk, null, TRUE), TOPIC_LIMIT_COUNTED, "A chunk with no pending payload should count")
	var/list/stray_chunk = list("tgui" = "1", "type" = "payloadChunk", "payload" = json_encode(list("id" = "999", "chunk" = "abc")), "window_id" = "creator")
	QE_ASSERT_EQUAL(topic_limiter_cost(stray_chunk, pending, TRUE), TOPIC_LIMIT_COUNTED, "A chunk for an unknown payload should count")
	var/list/number_chunk = list("tgui" = "1", "type" = "payloadChunk", "payload" = json_encode(list("id" = 1, "chunk" = "abc")), "window_id" = "creator")
	QE_ASSERT_EQUAL(topic_limiter_cost(number_chunk, pending, TRUE), TOPIC_LIMIT_COUNTED, "A chunk with a numeric id should count")

	var/list/act = list("tgui" = "1", "type" = "act/cc_set_lang", "payload" = json_encode(list("lang" = "en")), "window_id" = "creator")
	QE_ASSERT_EQUAL(topic_limiter_cost(act, pending, TRUE), TOPIC_LIMIT_COUNTED, "An act() message should count")
	var/list/request = list("tgui" = "1", "type" = "oversizedPayloadRequest", "payload" = json_encode(list("id" = "777", "chunkCount" = 3)), "window_id" = "creator")
	QE_ASSERT_EQUAL(topic_limiter_cost(request, pending, TRUE), TOPIC_LIMIT_COUNTED, "The request that opens a chunked payload should count")
	QE_ASSERT_EQUAL(topic_limiter_cost(list("src" = "abc", "action" = "x"), pending, TRUE), TOPIC_LIMIT_COUNTED, "A plain link should count")

/// A second save inside the cooldown is refused; other actions keep their own cooldowns.
/datum/unit_test/character_creator_save_cooldown/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	QE_ASSERT(prefs.character_creator_cooldown_ready(null, "save"), "The first save should run")
	QE_ASSERT(!prefs.character_creator_cooldown_ready(null, "save"), "A second save inside the cooldown should be refused")
	QE_ASSERT(prefs.character_creator_cooldown_ready(null, "ready"), "The ready toggle has its own cooldown")
	QE_ASSERT(prefs.character_creator_cooldown_ready(null, "export"), "Export has its own cooldown")
	QE_ASSERT(!prefs.character_creator_cooldown_ready(null, "export"), "A second export inside the cooldown should be refused")
	prefs.character_creator_save_cooldown = world.time - 1
	QE_ASSERT(prefs.character_creator_cooldown_ready(null, "save"), "A save after the cooldown should run")

/// Body build, backup names, ERP preferences and kinks, badges, food and smallclothes survive an export through JSON.
/datum/unit_test/character_creator_export_import_full/Run()
	var/datum/preferences/source = allocate(/datum/preferences)
	source.write_preference(/datum/preference/text/real_name, "Laniel Thornwood")
	source.validate_customizer_entries()

	// First selectable species and sex with two or more builds, not the random default.
	var/chosen_species
	var/chosen_gender
	for(var/species_id in GLOB.species_list)
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/candidate = new species_type
		if(candidate.preference_accessible(source))
			for(var/gender in list(MALE, FEMALE))
				if(length(candidate.get_body_build_options(gender)) >= 2)
					chosen_species = species_type
					chosen_gender = gender
					break
		qdel(candidate)
		if(chosen_species)
			break
	QE_ASSERT(chosen_species, "Some selectable species should offer two body builds")
	source.set_species_preference(chosen_species)
	source.write_preference(/datum/preference/choiced/gender, chosen_gender)

	var/list/build_options = source.pref_species.get_body_build_options(chosen_gender)
	var/default_build = source.pref_species.get_default_body_build(chosen_gender)
	var/chosen_build
	for(var/build_id in build_options)
		if(build_id != default_build)
			chosen_build = build_id
	source.features["body_build"] = chosen_build

	source.custom_names["human"] = "Bran Holloway"

	var/datum/erp_preference/boolean/allow_mob_breeding/breeding_pref = new
	breeding_pref.set_value(source, !breeding_pref.default_value)
	var/kink_name = GLOB.available_kinks[1]
	QE_ASSERT(source.set_kink_preference(kink_name, TRUE, 4, "slowly"), "The test kink should exist")

	var/datum/preference/list_type/preference_badges/badge_entry = GLOB.preference_entries[/datum/preference/list_type/preference_badges]
	var/list/badges = badge_entry.create_default_value(source)
	var/badge_category = GLOB.preference_badge_categories[1]
	badges[badge_category] = 1
	badges["overhead"] = badge_category
	source.write_preference(/datum/preference/list_type/preference_badges, badges)

	// Culinary picks are group flags; the hated group is any group other than the favourite.
	var/list/dish_options = culinary_favourite_dish_options()
	var/list/drink_options = culinary_favourite_drink_options()
	QE_ASSERT(length(dish_options) && length(drink_options), "There should be favourite food and drink groups")
	var/favourite_dish = dish_options[dish_options[1]]
	var/favourite_drink = drink_options[drink_options[1]]
	var/hated_dish = NONE
	for(var/label in GLOB.culinary_dish_groups)
		if(GLOB.culinary_dish_groups[label] != favourite_dish)
			hated_dish = GLOB.culinary_dish_groups[label]
			break
	var/list/culinary = list(
		CULINARY_RANDOM_PREFERENCES = FALSE,
		CULINARY_FAVOURITE_FOOD = favourite_dish,
		CULINARY_FAVOURITE_DRINK = favourite_drink,
		CULINARY_HATED_FOOD = hated_dish,
		CULINARY_HATED_DRINK = NONE,
	)
	source.write_preference(/datum/preference/list_type/culinary_preferences, culinary)
	source.validate_culinary_preferences()

	source.validate_smallclothes_preferences()
	var/list/smallclothes = source.read_preference(/datum/preference/list_type/smallclothes_preferences)
	var/chosen_undies
	for(var/undie_type in GLOB.selectable_undies)
		if(undie_type)
			chosen_undies = undie_type
			break
	smallclothes[SMALCLOTHES_RANDOM_PREFERENCES] = FALSE
	smallclothes[SMALCLOTHES_UNDIE_PREFERENCES] = chosen_undies
	smallclothes[SMALCLOTHES_UNDIE_COLOR_PREFERENCES] = "#a01010"
	source.write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes)

	var/list/payload = json_decode(json_encode(source.character_creator_export_payload()))
	var/datum/preferences/target = allocate(/datum/preferences)
	target.character_creator_apply_import(null, payload)

	QE_ASSERT_EQUAL(target.features["body_build"], chosen_build, "The body build should survive the round trip")
	QE_ASSERT_EQUAL(target.custom_names["human"], "Bran Holloway", "A backup name should survive the round trip")
	QE_ASSERT_EQUAL(breeding_pref.get_value(target), !breeding_pref.default_value, "An ERP preference should survive the round trip")
	var/list/target_erp = target.read_preference(/datum/preference/list_type/erp_preferences)
	var/list/kink_data = target_erp["kinks"][kink_name]
	QE_ASSERT(islist(kink_data), "The kink should come back")
	QE_ASSERT_EQUAL(kink_data["enabled"], TRUE, "The kink should stay enabled")
	QE_ASSERT_EQUAL(kink_data["intensity"], 4, "The kink intensity should survive the round trip")
	QE_ASSERT_EQUAL(kink_data["notes"], "slowly", "The kink notes should survive the round trip")
	var/list/target_badges = target.read_preference(/datum/preference/list_type/preference_badges)
	QE_ASSERT_EQUAL(target_badges[badge_category], 1, "A preference badge should survive the round trip")
	QE_ASSERT_EQUAL(target_badges["overhead"], badge_category, "The overhead badge should survive the round trip")
	var/list/target_culinary = target.read_preference(/datum/preference/list_type/culinary_preferences)
	QE_ASSERT_EQUAL(target_culinary[CULINARY_FAVOURITE_FOOD], favourite_dish, "The favourite food group should survive the round trip")
	QE_ASSERT_EQUAL(target_culinary[CULINARY_FAVOURITE_DRINK], favourite_drink, "The favourite drink group should survive the round trip")
	QE_ASSERT_EQUAL(target_culinary[CULINARY_HATED_FOOD], hated_dish, "The hated food group should survive the round trip")
	var/list/target_smallclothes = target.read_preference(/datum/preference/list_type/smallclothes_preferences)
	QE_ASSERT_EQUAL(target_smallclothes[SMALCLOTHES_UNDIE_PREFERENCES], chosen_undies, "The smallclothes should come back as the same typepath")
	QE_ASSERT_EQUAL(target_smallclothes[SMALCLOTHES_UNDIE_COLOR_PREFERENCES], "#a01010", "The smallclothes colour should survive the round trip")

	// Every character list preference must have an import rule.
	var/list/skip_keys = target.character_creator_import_skip_keys()
	for(var/datum/preference/list_type/entry in GLOB.preferences_in_priority_order)
		if(entry.savefile_identifier != PREF_CHARACTER || (entry.savefile_key in skip_keys))
			continue
		QE_ASSERT_NOTNULL(target.character_creator_clean_list_pref(entry, list()), "[entry.type] has no import rule")

/// Forged ERP values and unknown kinks are dropped on import.
/datum/unit_test/character_creator_import_erp_forged/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	var/datum/erp_preference/boolean/allow_mob_breeding/breeding_pref = new
	prefs.character_creator_import_erp(list(
		("[breeding_pref.type]") = "<script>",
		"/datum/erp_preference/not_real" = 1,
		"kinks" = list("Not A Kink" = list("enabled" = 1, "intensity" = 3, "notes" = "x")),
	))
	var/list/stored = prefs.read_preference(/datum/preference/list_type/erp_preferences)
	QE_ASSERT_EQUAL(stored[breeding_pref.type], breeding_pref.default_value, "A text value for a yes/no preference should fall back to the default")
	QE_ASSERT(!("Not A Kink" in stored["kinks"]), "An unknown kink must be dropped")
	for(var/key in stored)
		QE_ASSERT(key == "kinks" || ispath(key, /datum/erp_preference), "Only known ERP preferences may be stored, found [key]")

/// A name with ~ is refused; a saved name loses the ~ instead.
/datum/unit_test/reject_bad_name_refuses_tilde/Run()
	QE_ASSERT_NULL(reject_bad_name("Ana~Bel"), "A name with ~ should be refused")
	QE_ASSERT_NULL(reject_bad_name("Ana~Bel", TRUE), "A name with ~ should be refused even where symbols are allowed")
	QE_ASSERT_EQUAL(reject_bad_name("Ana Bel"), "Ana Bel", "A plain name should pass")
	var/datum/preferences/prefs = allocate(/datum/preferences)
	var/datum/preference/text/real_name/name_entry = GLOB.preference_entries[/datum/preference/text/real_name]
	QE_ASSERT_EQUAL(name_entry.deserialize("Ana~Bel", prefs), "AnaBel", "A saved name should lose the ~ on load")

/// Play again clears the last class and leaves triumphs alone.
/datum/unit_test/play_again_is_free/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	var/mob/living/carbon/human/tester = allocate(/mob/living/carbon/human)
	tester.ckey = "qeplayagaintest"
	SStriumphs.triumph_amount_cache[tester.ckey] = 5
	prefs.lastclass = "Soldier"

	prefs.reset_last_class(tester, skip_confirm = TRUE)

	QE_ASSERT_NULL(prefs.lastclass, "Play again should clear the last class")
	QE_ASSERT_EQUAL(tester.get_triumphs(), 5, "Play again should not cost triumphs")
	SStriumphs.triumph_amount_cache -= tester.ckey
	tester.ckey = null

#undef QE_ASSERT
#undef QE_ASSERT_NULL
#undef QE_ASSERT_NOTNULL
#undef QE_ASSERT_EQUAL

#endif
