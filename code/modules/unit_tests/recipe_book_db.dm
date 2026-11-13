// Ids must resolve to the exact entries, in the exact order, each book used to send inline.
/datum/unit_test/recipe_book_ids_match_book_caches/Run()
	var/mob/living/carbon/human/reader = allocate(/mob/living/carbon/human)
	TEST_ASSERT(length(GLOB.recipe_book_db), "SSrecipe_books init should build the recipe book db.")
	for(var/book_type in typesof(/obj/item/recipe_book))
		var/obj/item/recipe_book/book = allocate(book_type)
		var/list/data = book.ui_static_data(reader)
		TEST_ASSERT_NOTNULL(data["recipe_ids"], "[book_type] should send recipe ids.")
		TEST_ASSERT_NOTNULL(data["linked_ids"], "[book_type] should send linked ids.")
		for(var/id in data["recipe_ids"] + data["linked_ids"])
			TEST_ASSERT(isnum(id) && id >= 0 && id < length(GLOB.recipe_book_db), "[book_type] sent [id] instead of a db id.")
		var/list/own = recipe_book_db_entries(data["recipe_ids"])
		var/list/own_expected = book.get_cached_book_recipes(book_type, FALSE)
		TEST_ASSERT_EQUAL(length(own), length(own_expected), "[book_type] should send every own recipe.")
		for(var/i in 1 to length(own))
			TEST_ASSERT(own[i] == own_expected[i], "[book_type] own recipe [i] should be the cached entry.")
		var/list/linked = recipe_book_db_entries(data["linked_ids"])
		var/list/linked_expected = book.get_cached_linked_recipes(book_type)
		TEST_ASSERT_EQUAL(length(linked), length(linked_expected), "[book_type] should send every linked recipe.")
		for(var/i in 1 to length(linked))
			TEST_ASSERT(linked[i] == linked_expected[i], "[book_type] linked recipe [i] should be the cached entry.")
		var/payload = length(json_encode(data))
		TEST_ASSERT(payload < 64 * 1024, "[book_type] static data is [payload] bytes; recipe entries belong in the db asset.")

// Fish pages read SSfishing, which inits after SSatoms; a db built too early has no bait or lure data.
/datum/unit_test/recipe_book_db_built_after_subsystems/Run()
	TEST_ASSERT(SSrecipe_books.initialized, "SSrecipe_books should have initialized before tests run.")
	var/fish_pages = 0
	var/fish_with_lures = 0
	for(var/list/entry as anything in GLOB.recipe_book_db)
		if(entry["type"] != "fish")
			continue
		fish_pages++
		if(!isnull(entry["lures"]))
			fish_with_lures++
	TEST_ASSERT(fish_pages, "The recipe book db should hold fish pages.")
	TEST_ASSERT(fish_with_lures, "No fish page has lure data; the db was built before SSfishing initialized.")

// Source pages were rebuilt for every book; uncached, the db would carry one copy per book.
/datum/unit_test/recipe_book_db_shares_source_pages/Run()
	var/list/seen = list()
	var/list/duplicates = list()
	var/pages = 0
	for(var/list/entry as anything in GLOB.recipe_book_db)
		if(entry["type"] != "source_page" && entry["type"] != "obtained_from")
			continue
		pages++
		var/encoded = json_encode(entry)
		if(seen[encoded])
			duplicates |= "[entry["type"]] [entry["name"]]"
		seen[encoded] = TRUE
	TEST_ASSERT(pages, "The recipe book db should hold source pages.")
	TEST_ASSERT(!length(duplicates), "The recipe book db repeats source pages: [jointext(duplicates, ", ")]")
	var/datum/asset/json/recipe_book_db/asset = get_asset_datum(/datum/asset/json/recipe_book_db)
	TEST_ASSERT(asset.registered, "The recipe book db asset should register once the db exists.")
	TEST_ASSERT_NOTNULL(SSassets.cache["data/recipe_book_db.json"], "The recipe book db should be in the asset cache.")

// The craft HUD book adds learned recipes to its own types; only that reader should see them.
/datum/unit_test/recipe_book_sends_learned_recipes/Run()
	var/mob/living/carbon/human/reader = allocate(/mob/living/carbon/human)
	var/obj/item/recipe_book/always_known/book = allocate(/obj/item/recipe_book/always_known)
	var/list/base_data = book.ui_static_data(reader)
	var/list/base_ids = base_data["recipe_ids"]
	TEST_ASSERT(length(base_ids), "The craft HUD book should list its survival recipes.")

	book.types |= list(/datum/blueprint_recipe/carpentry/easel, /datum/blueprint_recipe/zizo/shrine)
	var/list/data = book.ui_static_data(reader)
	var/list/ids = data["recipe_ids"]
	TEST_ASSERT_EQUAL(length(ids), length(base_ids) + 2, "Both learned recipes should be appended.")
	TEST_ASSERT(isnum(ids[length(ids) - 1]), "A learned recipe another book lists should be sent as a db id.")
	var/list/shrine = ids[length(ids)]
	TEST_ASSERT(islist(shrine), "A learned recipe in no book should be sent inline.")
	TEST_ASSERT_EQUAL(shrine["name"], "Profane Shrine", "The inline entry should be the shrine blueprint.")
	var/list/easel = recipe_book_db_entries(list(ids[length(ids) - 1]))
	TEST_ASSERT_EQUAL(easel[1], book.get_cached_recipe_data(/datum/blueprint_recipe/carpentry/easel), "The id should resolve to the cached easel entry.")

	var/obj/item/recipe_book/always_known/other = allocate(/obj/item/recipe_book/always_known)
	var/list/other_data = other.ui_static_data(reader)
	var/list/other_ids = other_data["recipe_ids"]
	TEST_ASSERT_EQUAL(length(other_ids), length(base_ids), "Another reader's HUD book should not show these learned recipes.")
