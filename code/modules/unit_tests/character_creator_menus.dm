#ifdef UNIT_TESTS

// Local asserts: the shared ones are undefined before files included after _unit_tests.dm.
#define QF_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason]", __FILE__, __LINE__) }
#define QF_ASSERT_EQUAL(a, b, message) if((a) != (b)) { return Fail("Expected [a] to be equal to [b]. [message]", __FILE__, __LINE__) }

/// Food preferences: group picks, None, favourite quality gate, hated at any quality, old saves.

/datum/unit_test/culinary_group_picks/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.validate_culinary_preferences()
	var/list/culinary = prefs.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], NONE, "A new character starts with no favourite food")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_DRINK], NONE, "A new character starts with no hated drink")

	QF_ASSERT(prefs.set_culinary_group(CULINARY_FAVOURITE_FOOD, DISH_MEAT), "Meat should be a valid favourite")
	QF_ASSERT(prefs.set_culinary_group(CULINARY_FAVOURITE_DRINK, "[DRINKTYPE_WINE]"), "A group sent as text should be accepted")
	culinary = prefs.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], DISH_MEAT, "The favourite food group should be stored")
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_DRINK], DRINKTYPE_WINE, "The favourite drink type should be stored")

	QF_ASSERT(prefs.set_culinary_group(CULINARY_HATED_FOOD, DISH_MEAT), "Meat should be a valid hated group")
	culinary = prefs.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], NONE, "Hating the favourite group clears the favourite")

	QF_ASSERT(!prefs.set_culinary_group(CULINARY_FAVOURITE_FOOD, DISH_MEAT | DISH_FRUIT), "Two groups at once must be refused")
	QF_ASSERT(prefs.set_culinary_group(CULINARY_FAVOURITE_DRINK, DRINKTYPE_MILK), "Milk can be a favourite")
	QF_ASSERT(prefs.set_culinary_group(CULINARY_HATED_DRINK, DRINKTYPE_MILK), "Milk can still be hated")
	QF_ASSERT(prefs.set_culinary_group(CULINARY_FAVOURITE_DRINK, NONE), "None should be accepted")
	QF_ASSERT(!prefs.set_culinary_group("Lunch", DISH_MEAT), "An unknown key must be refused")
	culinary = prefs.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_DRINK], NONE, "The favourite drink should now be None")

	var/list/rolled = roll_random_culinary_groups()
	QF_ASSERT(rolled[CULINARY_FAVOURITE_FOOD] in GLOB.selectable_foods, "A random favourite food must be a favourite group")
	QF_ASSERT(rolled[CULINARY_HATED_FOOD] != rolled[CULINARY_FAVOURITE_FOOD], "Random hated food must differ from the favourite")

/datum/unit_test/culinary_old_save_conversion/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.write_preference(/datum/preference/list_type/culinary_preferences, list(
		CULINARY_RANDOM_PREFERENCES = FALSE,
		CULINARY_FAVOURITE_FOOD = /obj/item/reagent_containers/food/snacks/cooked/roastchicken,
		CULINARY_HATED_FOOD = "/obj/item/reagent_containers/food/snacks/pie/cooked/meat",
		CULINARY_FAVOURITE_DRINK = /datum/reagent/consumable/ethanol/redwine,
		CULINARY_HATED_DRINK = /datum/reagent/consumable/nutriment,
	))
	prefs.validate_culinary_preferences()
	var/list/culinary = prefs.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], DISH_POULTRY, "A roast bird maps to Poultry")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_FOOD], DISH_PIE, "A meat pie maps to its dish form, Pies")
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_DRINK], DRINKTYPE_WINE, "Red wine maps to Wine")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_DRINK], NONE, "An untagged reagent becomes None")

	prefs.write_preference(/datum/preference/list_type/culinary_preferences, list(
		CULINARY_FAVOURITE_FOOD = /obj/item/reagent_containers/food/snacks/badrecipe,
		CULINARY_HATED_FOOD = "not a path",
		CULINARY_FAVOURITE_DRINK = 999,
	))
	prefs.validate_culinary_preferences()
	culinary = prefs.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], NONE, "An untagged dish becomes None")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_FOOD], NONE, "Garbage becomes None")
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_DRINK], NONE, "An unknown group number becomes None")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_DRINK], NONE, "A missing entry becomes None")

/datum/unit_test/culinary_quality_gate/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human)
	eater.culinary_preferences = list(
		CULINARY_RANDOM_PREFERENCES = FALSE,
		CULINARY_FAVOURITE_FOOD = DISH_MEAT,
		CULINARY_HATED_FOOD = DISH_DAIRY,
		CULINARY_FAVOURITE_DRINK = DRINKTYPE_WINE,
		CULINARY_HATED_DRINK = DRINKTYPE_ALE,
	)
	eater.culinary_react_to_food(DISH_MEAT, FARE_POOR)
	QF_ASSERT(!eater.has_stress_type(/datum/stress_event/favourite_food), "Poor fare of the favourite group must not count")

	var/obj/item/reagent_containers/food/snacks/cooked/frysteak/steak = allocate(/obj/item/reagent_containers/food/snacks/cooked/frysteak)
	QF_ASSERT_EQUAL(steak.faretype, FARE_NEUTRAL, "The test steak is normal fare")
	eater.culinary_react_to_food(steak.dish_type, steak.faretype)
	var/datum/stress_event/favourite = eater.has_stress_type(/datum/stress_event/favourite_food)
	QF_ASSERT(favourite, "Normal fare of the favourite group should count")
	QF_ASSERT_EQUAL(favourite.timer, world.time + 5 MINUTES * FARE_NEUTRAL, "The favourite lasts five minutes per fare step, as before")

	var/obj/item/reagent_containers/food/snacks/cheese/fresh_cheese = allocate(/obj/item/reagent_containers/food/snacks/cheese)
	eater.culinary_react_to_food(fresh_cheese.dish_type, fresh_cheese.faretype)
	QF_ASSERT(eater.has_stress_type(/datum/stress_event/hated_food), "Hated food counts at poor fare")

	eater.culinary_react_to_drink(/datum/reagent/consumable/ethanol/wine::drink_type, /datum/reagent/consumable/ethanol/wine::quality)
	QF_ASSERT(eater.has_stress_type(/datum/stress_event/favourite_drink), "Plain wine counts as a favourite")
	eater.culinary_react_to_drink(/datum/reagent/consumable/ethanol/beer::drink_type, /datum/reagent/consumable/ethanol/beer::quality)
	QF_ASSERT(eater.has_stress_type(/datum/stress_event/hated_drink), "A hated drink counts at any quality")

	var/mob/living/carbon/human/soup_lover = allocate(/mob/living/carbon/human)
	soup_lover.culinary_preferences = list(CULINARY_FAVOURITE_FOOD = DISH_SOUP)
	soup_lover.culinary_react_to_food(/datum/reagent/consumable/soup/stew/gross::dish_type, /datum/reagent/consumable/soup/stew/gross::dish_fare)
	QF_ASSERT(!soup_lover.has_stress_type(/datum/stress_event/favourite_food), "Beggars stew must not count as a favourite")
	soup_lover.culinary_react_to_food(/datum/reagent/consumable/soup/stew/meat::dish_type, /datum/reagent/consumable/soup/stew/meat::dish_fare)
	QF_ASSERT(soup_lover.has_stress_type(/datum/stress_event/favourite_food), "Meat stew counts for a soup lover")

	var/mob/living/carbon/human/milk_lover = allocate(/mob/living/carbon/human)
	milk_lover.culinary_preferences = list(CULINARY_FAVOURITE_DRINK = DRINKTYPE_MILK)
	milk_lover.culinary_react_to_drink(/datum/reagent/consumable/milk::drink_type, /datum/reagent/consumable/milk::quality)
	QF_ASSERT(milk_lover.has_stress_type(/datum/stress_event/favourite_drink), "Plain milk counts as a favourite at any quality")

	// None everywhere, and old null entries, must stay quiet.
	var/mob/living/carbon/human/picky = allocate(/mob/living/carbon/human)
	picky.culinary_preferences = list(CULINARY_FAVOURITE_FOOD = null, CULINARY_HATED_FOOD = NONE)
	picky.culinary_react_to_food(steak.dish_type, FARE_LAVISH)
	picky.culinary_react_to_drink(DRINKTYPE_WINE, DRINK_FANTASTIC)
	QF_ASSERT(!length(picky.get_positive_stressors()) && !length(picky.get_negative_stressors()), "None must not add any food stress")
	QF_ASSERT_EQUAL(culinary_group_name(GLOB.culinary_dish_groups, null), "None", "A missing group reads as None")

/// A sample of food and drink carries the expected group tags.
/datum/unit_test/culinary_tags_sample/Run()
	var/list/food_tags = list(
		/obj/item/reagent_containers/food/snacks/cooked/ham = DISH_MEAT,
		/obj/item/reagent_containers/food/snacks/cooked/roastchicken = DISH_POULTRY,
		/obj/item/reagent_containers/food/snacks/fryfish/carp = DISH_SEAFOOD,
		/obj/item/reagent_containers/food/snacks/cooked/valorian_omlette = DISH_EGG,
		/obj/item/reagent_containers/food/snacks/cheddar/aged = DISH_DAIRY,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/cabbage = DISH_VEGETABLE,
		/obj/item/reagent_containers/food/snacks/produce/mushroom/borowiki = DISH_VEGETABLE,
		/obj/item/reagent_containers/food/snacks/produce/fruit/apple = DISH_FRUIT,
		/obj/item/reagent_containers/food/snacks/bread/bookbread/plum = DISH_BREAD,
		/obj/item/reagent_containers/food/snacks/scone = DISH_PASTRY,
		/obj/item/reagent_containers/food/snacks/pieslice/good/berry = DISH_PIE | DISH_FRUIT,
		/obj/item/reagent_containers/food/snacks/pie/cooked/meat/fish = DISH_PIE | DISH_SEAFOOD,
		/obj/item/reagent_containers/food/snacks/strawbycake_slice = DISH_SWEET,
		/obj/item/reagent_containers/food/snacks/dough = NONE,
		/obj/item/reagent_containers/food/snacks/rotten/meat = NONE,
	)
	for(var/obj/item/reagent_containers/food/snacks/food_type as anything in food_tags)
		QF_ASSERT_EQUAL(initial(food_type.dish_type), food_tags[food_type], "[food_type] has the wrong dish groups")
	var/list/drink_tags = list(
		/datum/reagent/consumable/ethanol/redwine = DRINKTYPE_WINE,
		/datum/reagent/consumable/ethanol/blackberry/aged = DRINKTYPE_WINE,
		/datum/reagent/consumable/ethanol/beer = DRINKTYPE_ALE,
		/datum/reagent/consumable/ethanol/brandy/pear = DRINKTYPE_SPIRIT,
		/datum/reagent/consumable/ethanol/mead = DRINKTYPE_MEAD,
		/datum/reagent/consumable/ethanol/cider/pear = DRINKTYPE_CIDER,
		/datum/reagent/consumable/caffeine/coffee = DRINKTYPE_TEA,
		/datum/reagent/consumable/tea/compot = DRINKTYPE_TEA,
		/datum/reagent/consumable/milk/gote = DRINKTYPE_MILK,
		/datum/reagent/consumable/soup/stew = NONE,
	)
	for(var/datum/reagent/consumable/drink as anything in drink_tags)
		QF_ASSERT_EQUAL(initial(drink.drink_type), drink_tags[drink], "[drink] has the wrong drink type")
	var/list/soup_tags = list(
		/datum/reagent/consumable/soup/oatmeal = DISH_SOUP,
		/datum/reagent/consumable/soup/veggie/cabbage = DISH_SOUP | DISH_VEGETABLE,
		/datum/reagent/consumable/soup/stew/fish = DISH_SOUP | DISH_SEAFOOD,
		/datum/reagent/consumable/soup/stew/meat = DISH_SOUP | DISH_MEAT,
		/datum/reagent/consumable/ethanol/beer = NONE,
	)
	for(var/datum/reagent/consumable/dish as anything in soup_tags)
		QF_ASSERT_EQUAL(initial(dish.dish_type), soup_tags[dish], "[dish] has the wrong dish groups")
	QF_ASSERT_EQUAL(/datum/reagent/consumable/soup/stew/gross::dish_fare, FARE_POOR, "Beggars stew is poor fare")
	// Every dish group has a picture and enough normal food to be a favourite.
	var/list/favourite_dishes = culinary_favourite_dish_options()
	for(var/label in GLOB.culinary_dish_groups)
		QF_ASSERT(ispath(GLOB.culinary_dish_icons["[GLOB.culinary_dish_groups[label]]"], /obj/item), "[label] has no picture")
		QF_ASSERT(label in favourite_dishes, "[label] has no normal food")

/// Poor Vision: each choice gives that eyewear, None gives nothing, loadout eyewear skips the swap.
/datum/unit_test/poor_vision_eyewear/Run()
	var/datum/quirk/negative/bad_sight/singleton = GLOB.quirk_singletons[/datum/quirk/negative/bad_sight]
	for(var/choice in singleton.customization_options)
		var/mob/living/carbon/human/reader = allocate(/mob/living/carbon/human)
		reader.add_quirk(/datum/quirk/negative/bad_sight, choice)
		if(choice == QUIRK_EYEWEAR_OWN)
			QF_ASSERT(!reader.wear_mask, "Bringing your own eyewear must not give any")
		else
			QF_ASSERT_EQUAL(reader.wear_mask?.type, choice, "The chosen eyewear should be worn")
		QF_ASSERT(reader.is_nearsighted_currently() == (choice == QUIRK_EYEWEAR_OWN), "Only the eyewear should correct the sight")
		qdel(reader.wear_mask)

	var/mob/living/carbon/human/masked = allocate(/mob/living/carbon/human)
	masked.equip_to_slot_or_del(new /obj/item/clothing/face/shepherd/rag(masked), ITEM_SLOT_MASK)
	masked.add_quirk(/datum/quirk/negative/bad_sight, /obj/item/clothing/face/spectacles/monocle)
	QF_ASSERT(istype(masked.wear_mask, /obj/item/clothing/face/spectacles/monocle), "The monocle replaces the worn mask")
	QF_ASSERT(locate(/obj/item/clothing/face/shepherd/rag) in masked.held_items, "The old mask goes to the hands")

	var/datum/preferences/prefs = allocate(/datum/preferences)
	QF_ASSERT_EQUAL(singleton.resolve_customization(prefs, /obj/item/clothing/face/spectacles/golden), /obj/item/clothing/face/spectacles/golden, "Without loadout eyewear the choice stays")
	prefs.loadout1 = new /datum/loadout_item/ragmask
	QF_ASSERT_EQUAL(singleton.resolve_customization(prefs, /obj/item/clothing/face/spectacles/golden), /obj/item/clothing/face/spectacles/golden, "A loadout mask is not eyewear")
	prefs.loadout2 = new /datum/loadout_item/fancy_spectacles
	QF_ASSERT_EQUAL(singleton.resolve_customization(prefs, /obj/item/clothing/face/spectacles/golden), QUIRK_EYEWEAR_OWN, "Loadout spectacles replace the quirk's eyewear")
	prefs.quirks = list(/datum/quirk/negative/bad_sight)
	prefs.quirk_customizations = list(/datum/quirk/negative/bad_sight = /obj/item/clothing/face/spectacles/golden)
	var/mob/living/carbon/human/loadout_reader = allocate(/mob/living/carbon/human)
	prefs.apply_quirks_to_character(loadout_reader)
	QF_ASSERT(loadout_reader.has_quirk(/datum/quirk/negative/bad_sight), "The quirk should still apply")
	QF_ASSERT(!loadout_reader.wear_mask, "No eyewear is handed out when the loadout brings some")

/// Traumatized takes three fears, each extra fear gives a point, and all of them scare.
/datum/unit_test/traumatized_three_fears/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.quirks = list()
	prefs.quirk_customizations = list()
	var/base_balance = prefs.calculate_quirk_balance()
	QF_ASSERT(prefs.add_quirk(/datum/quirk/negative/traumatized, /datum/species/goblin), "Traumatized should be addable")
	QF_ASSERT_EQUAL(prefs.calculate_quirk_balance(), base_balance + 3, "One fear gives the base points")
	QF_ASSERT(prefs.add_quirk_pick(/datum/quirk/negative/traumatized), "A second fear should be addable")
	QF_ASSERT(prefs.add_quirk_pick(/datum/quirk/negative/traumatized), "A third fear should be addable")
	QF_ASSERT(!prefs.add_quirk_pick(/datum/quirk/negative/traumatized), "A fourth fear must be refused")
	QF_ASSERT_EQUAL(prefs.calculate_quirk_balance(), base_balance + 3 + 2 * QUIRK_EXTRA_PICK_POINTS, "Each extra fear gives one more point")
	QF_ASSERT(prefs.set_quirk_customization(/datum/quirk/negative/traumatized, /datum/species/elf, 2), "A pick should be changeable")
	QF_ASSERT(!prefs.set_quirk_customization(/datum/quirk/negative/traumatized, /datum/species/goblin, 3), "A fear may only be picked once")
	QF_ASSERT(prefs.set_quirk_customization(/datum/quirk/negative/traumatized, "Nobles", 3), "Nobles should be pickable")
	var/list/picks = prefs.quirk_customizations[/datum/quirk/negative/traumatized]
	QF_ASSERT(islist(picks) && length(picks) == 3, "Three fears should be stored as a list")

	// Save and load keep all three; an old single value loads as one pick.
	var/savefile/save = new
	prefs.save_quirks(save)
	var/datum/preferences/loaded = allocate(/datum/preferences)
	loaded.load_quirks(save)
	var/list/loaded_picks = loaded.quirk_customizations[/datum/quirk/negative/traumatized]
	QF_ASSERT(islist(loaded_picks) && length(loaded_picks) == 3, "Three fears should survive a save")
	QF_ASSERT(loaded_picks[1] == /datum/species/goblin && loaded_picks[2] == /datum/species/elf && loaded_picks[3] == "Nobles", "The fears should load in order")
	var/savefile/old_save = new
	WRITE_FILE(old_save["quirks"], list(list("type" = /datum/quirk/negative/traumatized, "value" = /datum/species/dwarf)))
	var/datum/preferences/old_prefs = allocate(/datum/preferences)
	old_prefs.load_quirks(old_save)
	var/list/old_picks = old_prefs.quirk_customizations[/datum/quirk/negative/traumatized]
	QF_ASSERT(islist(old_picks) && length(old_picks) == 1 && old_picks[1] == /datum/species/dwarf, "An old single fear loads as one pick")

	QF_ASSERT(prefs.remove_quirk_pick(/datum/quirk/negative/traumatized, 3), "An extra fear should be removable")
	QF_ASSERT(!prefs.remove_quirk_pick(/datum/quirk/negative/traumatized, 1), "The first fear must stay")
	QF_ASSERT_EQUAL(prefs.calculate_quirk_balance(), base_balance + 3 + QUIRK_EXTRA_PICK_POINTS, "Removing a fear takes its point back")

	var/mob/living/carbon/human/veteran = allocate(/mob/living/carbon/human)
	veteran.add_quirk(/datum/quirk/negative/traumatized, list(/datum/species/goblin, /datum/species/elf, "Nobles"))
	var/datum/quirk/negative/traumatized/trauma = locate() in veteran.quirks
	QF_ASSERT(trauma, "The quirk should be on the mob")
	QF_ASSERT_EQUAL(length(trauma.fear_types), 3, "All three fears should be active")
	var/mob/living/carbon/human/elf = allocate(/mob/living/carbon/human)
	elf.set_species(/datum/species/elf)
	QF_ASSERT(trauma.is_feared(elf), "The second fear should scare")
	var/mob/living/carbon/human/goblin = allocate(/mob/living/carbon/human)
	goblin.set_species(/datum/species/goblin)
	QF_ASSERT(trauma.is_feared(goblin), "The first fear should scare")
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	QF_ASSERT(!trauma.is_feared(stranger), "Someone matching no fear should not scare")

/// Export and import keep the new food groups and the multi-pick quirk; older files still load.
/datum/unit_test/character_creator_menus_round_trip/Run()
	var/datum/preferences/source = allocate(/datum/preferences)
	source.write_preference(/datum/preference/text/real_name, "Laniel Thornwood")
	source.validate_customizer_entries()
	source.set_culinary_group(CULINARY_FAVOURITE_FOOD, DISH_PIE)
	source.set_culinary_group(CULINARY_FAVOURITE_DRINK, DRINKTYPE_WINE)
	source.set_culinary_group(CULINARY_HATED_FOOD, DISH_DAIRY)
	source.set_culinary_group(CULINARY_HATED_DRINK, DRINKTYPE_MILK)
	source.quirks = list()
	source.quirk_customizations = list()
	QF_ASSERT(source.add_quirk(/datum/quirk/negative/traumatized, /datum/species/goblin), "Traumatized should be addable")
	source.set_quirk_customization(/datum/quirk/negative/traumatized, /datum/species/goblin, 1)
	source.add_quirk_pick(/datum/quirk/negative/traumatized)
	source.set_quirk_customization(/datum/quirk/negative/traumatized, "Nobles", 2)
	QF_ASSERT(source.add_quirk(/datum/quirk/negative/bad_sight, /obj/item/clothing/face/spectacles/monocle), "Poor Vision should be addable")

	var/list/payload = json_decode(json_encode(source.character_creator_export_payload()))
	var/datum/preferences/target = allocate(/datum/preferences)
	target.character_creator_apply_import(null, payload)
	var/list/culinary = target.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], DISH_PIE, "The favourite food group survives")
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_DRINK], DRINKTYPE_WINE, "The favourite drink type survives")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_FOOD], DISH_DAIRY, "The hated food group survives")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_DRINK], DRINKTYPE_MILK, "The hated drink type survives")
	var/list/fears = target.quirk_customizations[/datum/quirk/negative/traumatized]
	QF_ASSERT(islist(fears) && length(fears) == 2 && fears[1] == /datum/species/goblin && fears[2] == "Nobles", "Both fears survive")
	QF_ASSERT_EQUAL(target.quirk_customizations[/datum/quirk/negative/bad_sight], /obj/item/clothing/face/spectacles/monocle, "The eyewear choice survives")

	// A version 2 file: single dish and drink typepaths, one fear as plain text.
	payload["version"] = 2
	payload["prefs"]["culinary_preferences"] = list(
		CULINARY_RANDOM_PREFERENCES = 0,
		CULINARY_FAVOURITE_FOOD = "/obj/item/reagent_containers/food/snacks/cooked/ham",
		CULINARY_FAVOURITE_DRINK = "/datum/reagent/consumable/ethanol/mead",
		CULINARY_HATED_FOOD = "/obj/item/reagent_containers/food/snacks/rotten/meat",
		CULINARY_HATED_DRINK = "/datum/reagent/consumable/tea/compot",
	)
	for(var/list/quirk_entry in payload["quirks"])
		if(quirk_entry["type"] == "[/datum/quirk/negative/traumatized]")
			quirk_entry["value"] = "/datum/species/orc"
	var/datum/preferences/old_target = allocate(/datum/preferences)
	old_target.character_creator_apply_import(null, payload)
	culinary = old_target.read_preference(/datum/preference/list_type/culinary_preferences)
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_FOOD], DISH_MEAT, "An old favourite dish maps to its group")
	QF_ASSERT_EQUAL(culinary[CULINARY_FAVOURITE_DRINK], DRINKTYPE_MEAD, "An old favourite drink maps to its type")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_FOOD], NONE, "An untagged old dish becomes None")
	QF_ASSERT_EQUAL(culinary[CULINARY_HATED_DRINK], DRINKTYPE_TEA, "An old hated drink maps to its type")
	fears = old_target.quirk_customizations[/datum/quirk/negative/traumatized]
	QF_ASSERT(islist(fears) && length(fears) == 1 && fears[1] == /datum/species/orc, "An old single fear imports as one pick")

#undef QF_ASSERT
#undef QF_ASSERT_EQUAL

#endif
