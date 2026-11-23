/datum/attribute_holder/sheet/job/stat_allocation_test
	raw_attribute_list = list(
		STAT_STRENGTH = 3,
		/datum/attribute/skill/combat/swords = 20,
	)

/// One point a step up to 13, two points each for 14 and 15, nothing back below the free value.
/datum/unit_test/stat_allocation_cost/Run()
	TEST_ASSERT_EQUAL(stat_alloc_cost(STAT_ALLOC_FLOOR), 0, "A stat under the free value gives no points back")
	TEST_ASSERT_EQUAL(stat_alloc_cost(STAT_ALLOC_FREE), 0, "The free value costs nothing")
	TEST_ASSERT_EQUAL(stat_alloc_cost(13), 5, "Steps up to 13 cost one point each")
	TEST_ASSERT_EQUAL(stat_alloc_cost(14), 7, "The step to 14 costs two points")
	TEST_ASSERT_EQUAL(stat_alloc_cost(15), 9, "The step to 15 costs two points")
	TEST_ASSERT_EQUAL(stat_alloc_cost(40), stat_alloc_cost(STAT_ALLOC_BUY_MAX), "Cost stops at the highest value points can buy")

/// Saved choices outside the rules come back inside them.
/datum/unit_test/stat_allocation_validate/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.stat_allocation = list(
		STATKEY_STR = 99,
		STATKEY_SPD = 15,
		STATKEY_CON = 15,
		STATKEY_INT = 15,
		STATKEY_PER = 15,
		STATKEY_CHA = -4,
		"bogus" = 12,
	)
	prefs.stat_bonus_major = STATKEY_STR
	prefs.stat_bonus_minor = STATKEY_STR
	prefs.impression_text_poor = "  two\nlines  "
	prefs.validate_stat_allocation()

	TEST_ASSERT_EQUAL(length(prefs.stat_allocation), length(GLOB.stat_alloc_keys), "Only the known stats stay, and every one of them is present")
	TEST_ASSERT(prefs.stat_alloc_spent() <= prefs.stat_alloc_budget(), "Points over the budget must be taken back")
	TEST_ASSERT_EQUAL(prefs.stat_allocation[STATKEY_CHA], STAT_ALLOC_FLOOR, "A value under the floor rises to the floor")
	TEST_ASSERT_EQUAL(prefs.stat_allocation[STATKEY_END], STAT_ALLOC_DEFAULT, "A missing stat takes the default value")
	TEST_ASSERT_EQUAL(prefs.stat_bonus_major, STATKEY_STR, "The larger bonus stays where it was")
	TEST_ASSERT_NULL(prefs.stat_bonus_minor, "Both bonuses cannot sit on one stat")
	TEST_ASSERT_EQUAL(prefs.impression_text_poor, "two lines", "A custom line is one trimmed line of text")

/// The editor refuses a step the budget cannot pay for, and the two bonuses trade places.
/datum/unit_test/stat_allocation_actions/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.reset_stat_allocation()
	TEST_ASSERT_EQUAL(prefs.stat_alloc_spent(), length(GLOB.stat_alloc_keys) * stat_alloc_cost(STAT_ALLOC_DEFAULT), "A fresh character has every stat at the default")

	var/refused = 0
	for(var/stat_key in GLOB.stat_alloc_keys)
		if(!prefs.character_creator_stat_act(null, "cc_stat_set", list("stat" = stat_key, "value" = STAT_ALLOC_BUY_MAX)))
			refused++
	TEST_ASSERT(refused > 0, "The budget cannot pay for every stat at the top value")
	TEST_ASSERT(prefs.stat_alloc_spent() <= prefs.stat_alloc_budget(), "A refused step must leave the spending inside the budget")
	TEST_ASSERT(!prefs.character_creator_stat_act(null, "cc_stat_set", list("stat" = "bogus", "value" = 12)), "An unknown stat is refused")

	prefs.character_creator_stat_act(null, "cc_stat_bonus", list("slot" = "major", "stat" = STATKEY_STR))
	prefs.character_creator_stat_act(null, "cc_stat_bonus", list("slot" = "minor", "stat" = STATKEY_CON))
	prefs.character_creator_stat_act(null, "cc_stat_bonus", list("slot" = "major", "stat" = STATKEY_CON))
	TEST_ASSERT_EQUAL(prefs.stat_bonus_major, STATKEY_CON, "The larger bonus moves to the chosen stat")
	TEST_ASSERT_EQUAL(prefs.stat_bonus_minor, STATKEY_STR, "The stat that gave up the larger bonus takes the smaller one")
	prefs.character_creator_stat_act(null, "cc_stat_bonus", list("slot" = "major", "stat" = STATKEY_CON))
	TEST_ASSERT_NULL(prefs.stat_bonus_major, "A second click takes the bonus off")

/// The choices survive the character export and import.
/datum/unit_test/stat_allocation_export_round_trip/Run()
	var/datum/preferences/source = allocate(/datum/preferences)
	source.reset_stat_allocation()
	source.character_creator_stat_act(null, "cc_stat_set", list("stat" = STATKEY_CHA, "value" = STAT_ALLOC_FLOOR))
	source.character_creator_stat_act(null, "cc_stat_set", list("stat" = STATKEY_STR, "value" = 14))
	source.stat_bonus_major = STATKEY_STR
	source.impression_text_strong = "Walks like the hall is theirs."

	var/list/payload = json_decode(json_encode(source.character_creator_export_payload()))
	var/datum/preferences/target = allocate(/datum/preferences)
	target.character_creator_apply_import(null, payload)

	TEST_ASSERT_EQUAL(target.stat_alloc_value(STATKEY_CHA), STAT_ALLOC_FLOOR, "A lowered stat should survive the round trip")
	TEST_ASSERT_EQUAL(target.stat_alloc_value(STATKEY_STR), 14, "A raised stat should survive the round trip")
	TEST_ASSERT_EQUAL(target.stat_bonus_major, STATKEY_STR, "The bonus should survive the round trip")
	TEST_ASSERT_EQUAL(target.impression_text_strong, "Walks like the hall is theirs.", "The custom line should survive the round trip")

/// The random spread spends what is left, keeps the player's own choices, and stays the same for the round.
/datum/unit_test/stat_allocation_random_spread/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.reset_stat_allocation()
	prefs.character_creator_stat_act(null, "cc_stat_set", list("stat" = STATKEY_CHA, "value" = STAT_ALLOC_FLOOR))
	prefs.character_creator_stat_act(null, "cc_stat_set", list("stat" = STATKEY_STR, "value" = 13))
	prefs.stat_bonus_major = STATKEY_STR
	var/list/saved = prefs.stat_allocation.Copy()

	var/list/spread = prefs.stat_alloc_random_spread()
	TEST_ASSERT_NOTNULL(spread, "Unspent points should give a spread")
	var/list/values = spread["values"]
	var/spent = 0
	var/cheapest_step = INFINITY
	for(var/stat_key in GLOB.stat_alloc_keys)
		TEST_ASSERT(values[stat_key] >= saved[stat_key], "[stat_key] must not go under the player's own value")
		TEST_ASSERT(values[stat_key] <= STAT_ALLOC_BUY_MAX, "[stat_key] must not pass the highest value points can buy")
		spent += stat_alloc_cost(values[stat_key])
		if(values[stat_key] >= STAT_ALLOC_FREE && values[stat_key] < STAT_ALLOC_BUY_MAX)
			cheapest_step = min(cheapest_step, stat_alloc_step_cost(values[stat_key]))
	TEST_ASSERT(spent <= prefs.stat_alloc_budget(), "The spread must stay inside the budget")
	TEST_ASSERT(prefs.stat_alloc_budget() - spent < cheapest_step, "The spread should spend every point that still buys a step")
	TEST_ASSERT_EQUAL(values[STATKEY_CHA], STAT_ALLOC_FLOOR, "A stat the player set under the free value is left alone")
	TEST_ASSERT_EQUAL(spread["major"], STATKEY_STR, "A bonus the player placed stays where it is")
	TEST_ASSERT(spread["minor"] && spread["minor"] != STATKEY_STR, "An unplaced bonus goes on another stat")
	TEST_ASSERT_EQUAL(prefs.stat_allocation[STATKEY_STR], 13, "The saved choices must stay as the player made them")
	TEST_ASSERT_NULL(prefs.stat_bonus_minor, "The saved bonus must stay unplaced")

	var/list/round_spread = prefs.stat_alloc_round_spread()
	TEST_ASSERT_EQUAL(prefs.stat_alloc_round_spread(), round_spread, "The spread of a round is made once")
	prefs.character_creator_stat_act(null, "cc_stat_set", list("stat" = STATKEY_STR, "value" = 12))
	TEST_ASSERT_NOTEQUAL(prefs.stat_alloc_round_spread(), round_spread, "A change of the saved choices gives a new spread")

/// A spawned body gets the random spread only while the option is on.
/datum/unit_test/stat_allocation_auto_toggle/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.reset_stat_allocation()
	TEST_ASSERT(prefs.stat_alloc_auto, "The random spread is on for a character that never set it")

	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	prefs.apply_stat_allocation_to_human(body)
	var/list/spread = prefs.stat_alloc_round_spread()
	var/expected = STAT_ALLOC_BONUS_MAJOR + STAT_ALLOC_BONUS_MINOR
	var/total = 0
	for(var/stat_key in GLOB.stat_alloc_keys)
		expected += spread["values"][stat_key]
		total += GET_MOB_ATTRIBUTE_VALUE_RAW(body, GLOB.stat_alloc_keys[stat_key])
	TEST_ASSERT_EQUAL(total, expected, "The body should carry the spread values and both bonuses")

	prefs.character_creator_stat_act(null, "cc_stat_auto", list())
	TEST_ASSERT(!prefs.stat_alloc_auto, "The action should turn the option off")
	prefs.apply_stat_allocation_to_human(body)
	for(var/stat_key in GLOB.stat_alloc_keys)
		TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, GLOB.stat_alloc_keys[stat_key]), STAT_ALLOC_DEFAULT, "With the option off, [stat_key] keeps the saved value")

	var/list/state = json_decode(json_encode(prefs.stat_alloc_state()))
	var/datum/preferences/other = allocate(/datum/preferences)
	other.stat_alloc_read(state)
	TEST_ASSERT(!other.stat_alloc_auto, "The option should survive a save")
	other.stat_alloc_read(list())
	TEST_ASSERT(other.stat_alloc_auto, "A save without the option turns it on")

/// Creator stats replace what the species gave, do not stack when applied twice, and keep job stats out.
/datum/unit_test/stat_allocation_apply/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.set_creator_stats(list(STAT_STRENGTH = 5, STAT_CHARISMA = -2))
	TEST_ASSERT(body.uses_creator_stats(), "The body should be marked as creator-made")
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, STAT_STRENGTH), ATTRIBUTE_DEFAULT + 5, "The chosen change should be on the raw stat")
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, STAT_CHARISMA), ATTRIBUTE_DEFAULT - 2, "A lowered stat should be on the raw stat")
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, STAT_SPEED), ATTRIBUTE_DEFAULT, "The species stat sheet should be gone")

	body.set_creator_stats(list(STAT_STRENGTH = 1))
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, STAT_STRENGTH), ATTRIBUTE_DEFAULT + 1, "A second application replaces the first")
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, STAT_CHARISMA), ATTRIBUTE_DEFAULT, "A second application undoes what the first set")

	var/swords_before = nulltozero(GET_MOB_ATTRIBUTE_VALUE_RAW(body, /datum/attribute/skill/combat/swords))
	body.attributes.add_sheet(/datum/attribute_holder/sheet/job/stat_allocation_test, body.uses_creator_stats())
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, STAT_STRENGTH), ATTRIBUTE_DEFAULT + 1, "A job sheet must not change a creator-made character's stats")
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE_RAW(body, /datum/attribute/skill/combat/swords), swords_before + 20, "A job sheet still gives its skills")

	body.set_stat_modifier(STATMOD_JOB, list(STAT_STRENGTH = 4))
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(body, STAT_STRENGTH), ATTRIBUTE_DEFAULT + 1, "A job stat modifier must not apply to a creator-made character")

/// Looks and impression are read together on examine.
/datum/unit_test/impression_appeal/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.set_creator_stats(list(STAT_CHARISMA = CHARISMA_POOR_MAX - ATTRIBUTE_DEFAULT))
	TEST_ASSERT_EQUAL(body.get_impression(), IMPRESSION_POOR, "Charisma at the poor limit gives a poor impression")
	body.set_creator_stats(list(STAT_CHARISMA = CHARISMA_STRONG_MIN - ATTRIBUTE_DEFAULT))
	TEST_ASSERT_EQUAL(body.get_impression(), IMPRESSION_STRONG, "Charisma at the strong limit gives a strong impression")

	TEST_ASSERT_NULL(body.get_appeal_stress_event(1, IMPRESSION_POOR, FALSE), "A poor impression cancels a beautiful face")
	TEST_ASSERT_NULL(body.get_appeal_stress_event(-1, IMPRESSION_STRONG, FALSE), "A strong impression cancels an ugly face")
	TEST_ASSERT_EQUAL(body.get_appeal_stress_event(1, IMPRESSION_ORDINARY, FALSE), /datum/stress_event/beautiful, "Beauty alone still lifts the mood")
	TEST_ASSERT_EQUAL(body.get_appeal_stress_event(0, IMPRESSION_STRONG, FALSE), /datum/stress_event/charming, "A strong impression alone lifts the mood")
	TEST_ASSERT_EQUAL(body.get_appeal_stress_event(0, IMPRESSION_POOR, FALSE), /datum/stress_event/offputting, "A poor impression alone sours the mood")
	TEST_ASSERT_NULL(body.get_appeal_stress_event(0, IMPRESSION_ORDINARY, FALSE), "Nothing notable gives no mood")

	var/list/pronouns = list(THEY = "They", THEM = "them", THEIR = "their", HAVE = "have", ARE = "are", THEYRE = "They are", THEYVE = "They have")
	TEST_ASSERT_NULL(body.get_appeal_line(0, IMPRESSION_ORDINARY, pronouns), "Nothing notable gives no line")
	TEST_ASSERT(findtext(body.get_appeal_line(1, IMPRESSION_POOR, pronouns), "marred"), "A poor impression should be named next to a beautiful face")
	body.impression_text_poor = "<b>Scowls</b> at everyone."
	var/custom_line = body.get_appeal_line(0, IMPRESSION_POOR, pronouns)
	TEST_ASSERT(findtext(custom_line, "&lt;b&gt;Scowls"), "A custom line is shown as plain text, never as markup")
	body.impression_text_ordinary = "A weathered face under a wide hat."
	TEST_ASSERT(findtext(body.get_appeal_line(0, IMPRESSION_ORDINARY, pronouns), "weathered face"), "The middle impression shows its custom line")

/// The two looks quirks stay in the game but players cannot take them.
/datum/unit_test/looks_quirks_admin_only/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	for(var/quirk_type in list(/datum/quirk/positive/beautiful, /datum/quirk/neutral/ugly))
		TEST_ASSERT(GLOB.quirk_singletons[quirk_type], "[quirk_type] should still exist for admins")
		TEST_ASSERT(!prefs.can_add_quirk(quirk_type), "[quirk_type] must not be open to players")
		prefs.quirks = list(quirk_type)
		prefs.validate_quirks()
		TEST_ASSERT(!(quirk_type in prefs.quirks), "[quirk_type] must leave a saved character")
