/// Test mobs have no client and so count as resting; this one never rests, so its bladder fills.
/mob/living/carbon/human/bladder_probe/is_bladder_at_rest()
	return FALSE

/// What is drunk reaches the bladder at the configured rate, a unit at a time, and only for hydration really gained.
/datum/unit_test/watersports_bladder_fills_slowly

/datum/unit_test/watersports_bladder_fills_slowly/Run()
	var/old_rate = CONFIG_GET(number/bladder_fill_rate)
	CONFIG_SET(number/bladder_fill_rate, 0.03)
	var/mob/living/carbon/human/bladder_probe/drinker = allocate(/mob/living/carbon/human/bladder_probe)
	var/datum/component/bladder/bladder = drinker.AddComponent(/datum/component/bladder)

	drinker.set_hydration(HYDRATION_LEVEL_THIRSTY)
	drinker.adjust_hydration(300)
	TEST_ASSERT_EQUAL(bladder.get_volume(), 0, "Drinking filled the bladder at once")
	TEST_ASSERT_EQUAL(round(bladder.pending, 0.01), 9, "300 hydration at a rate of 0.03 should wait as 9 units")
	TEST_ASSERT_NOTNULL(bladder.flow_timer, "Nothing is moving the drink into the bladder")

	deltimer(bladder.flow_timer)
	bladder.flow()
	TEST_ASSERT_EQUAL(bladder.get_volume(), 1, "One flow step should move one unit")
	TEST_ASSERT_EQUAL(round(bladder.pending, 0.01), 8, "One flow step should leave 8 units waiting")

	deltimer(bladder.flow_timer)
	bladder.flow_timer = null
	bladder.pending = 0
	drinker.set_hydration(HYDRATION_LEVEL_FULL - 100)
	drinker.adjust_hydration(1000)
	TEST_ASSERT_EQUAL(round(bladder.pending, 0.01), 3, "Hydration past full should not fill the bladder")

	CONFIG_SET(number/bladder_fill_rate, old_rate)

/// With WATERSPORTS_ENABLED off, the quirk, the preference and every action are gone.
/datum/unit_test/watersports_server_switch

/datum/unit_test/watersports_server_switch/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	var/datum/quirk/bladder_quirk = GLOB.quirk_singletons[/datum/quirk/neutral/bladder]
	var/datum/erp_preference/boolean/watersports/watersports = new
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)

	TEST_ASSERT(bladder_quirk.is_available(prefs), "The Bladder quirk is not available by default")
	TEST_ASSERT(watersports.is_listed(prefs), "The Watersports preference is not listed by default")
	watersports.set_value(prefs, TRUE)
	body.cache_erp_preferences_from_prefs(prefs)
	TEST_ASSERT(body.watersports_allowed(), "Watersports is not allowed with the preference on")

	var/was_enabled = CONFIG_GET(flag/watersports_enabled)
	CONFIG_SET(flag/watersports_enabled, FALSE)
	TEST_ASSERT(!bladder_quirk.is_available(prefs), "The Bladder quirk is available with watersports off on the server")
	TEST_ASSERT(!bladder_quirk.is_listed(prefs), "The Bladder quirk is listed with watersports off on the server")
	TEST_ASSERT(!watersports.is_listed(prefs), "The Watersports preference is listed with watersports off on the server")
	TEST_ASSERT(!body.watersports_allowed(), "Watersports is allowed with watersports off on the server")
	TEST_ASSERT(is_fluid_hidden_from(/datum/reagent/consumable/urine, body), "Urine is named with watersports off on the server")
	CONFIG_SET(flag/watersports_enabled, was_enabled)

/// A player who turns off Watersports content cannot take the quirk or the preference, and urine goes unnamed for them.
/datum/unit_test/watersports_player_toggle

/datum/unit_test/watersports_player_toggle/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	var/datum/quirk/bladder_quirk = GLOB.quirk_singletons[/datum/quirk/neutral/bladder]
	var/datum/erp_preference/boolean/watersports/watersports = new
	TEST_ASSERT(prefs.shows_watersports(), "Watersports content is hidden by default")

	prefs.update_preference(/datum/preference/toggle/watersports_content, FALSE)
	TEST_ASSERT(!prefs.shows_watersports(), "Turning off Watersports content did not hide it")
	TEST_ASSERT(!bladder_quirk.is_listed(prefs), "The Bladder quirk is listed for a player who hides watersports")
	TEST_ASSERT(findtext(prefs.quirk_refusal_reason(/datum/quirk/neutral/bladder), "Toggles"), "The Bladder quirk refusal does not point to the Toggles window")
	TEST_ASSERT(!watersports.is_listed(prefs), "The Watersports preference is listed for a player who hides watersports")
	TEST_ASSERT_NOTNULL(watersports.get_edit_lock_reason(null, prefs), "The Watersports preference can be edited while hidden")
	watersports.set_value(prefs, TRUE)
	TEST_ASSERT(!watersports.get_value(prefs), "The Watersports preference turned on while hidden")

	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	viewer.key = "watersports_probe"
	GLOB.preferences_datums[viewer.ckey] = prefs
	TEST_ASSERT(!viewer.sees_watersports(), "A disconnected player who hides watersports still sees it")
	TEST_ASSERT(is_fluid_hidden_from(/datum/reagent/consumable/urine, viewer), "Urine is named to a player who hides watersports")
	TEST_ASSERT(!is_fluid_hidden_from(/datum/reagent/consumable/cum, viewer), "Fluids other than urine are hidden")
	GLOB.preferences_datums -= viewer.ckey
	viewer.key = null
