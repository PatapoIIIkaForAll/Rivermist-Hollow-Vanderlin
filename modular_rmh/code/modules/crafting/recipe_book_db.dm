/// Every distinct recipe book entry; books send zero-based ids into it, clients get it once as an asset.
GLOBAL_LIST_EMPTY(recipe_book_db)
/// text_ref(entry) -> zero-based id in recipe_book_db.
GLOBAL_LIST_EMPTY(recipe_book_db_ids)
/// "[book_type]" -> list("types", "recipes" = ids, "linked" = ids), ids in the order books used to send entries.
GLOBAL_LIST_EMPTY(recipe_book_index)

/// Builds every book's caches and the shared db once every gameplay subsystem has initialized.
SUBSYSTEM_DEF(recipe_books)
	name = "Recipe Books"
	init_order = INIT_ORDER_RECIPE_BOOKS
	flags = SS_NO_FIRE

/datum/controller/subsystem/recipe_books/Initialize()
	init_recipe_book_db()
	return ..()

/// Builds every book's caches and the shared db, then registers the asset. Needs SSfishing and friends up.
/proc/init_recipe_book_db()
	build_recipe_book_db(check_tick = TRUE)
	get_asset_datum(/datum/asset/json/recipe_book_db)

/proc/build_recipe_book_db(check_tick = FALSE)
	if(length(GLOB.recipe_book_index))
		return
	var/list/index = list()
	for(var/book_type in typesof(/obj/item/recipe_book))
		var/obj/item/recipe_book/book = new book_type()
		index["[book_type]"] = list(
			"types" = book.types.Copy(),
			"recipes" = recipe_book_db_refs(book.get_cached_book_recipes(book_type, FALSE), TRUE),
			"linked" = recipe_book_db_refs(book.get_cached_linked_recipes(book_type), TRUE),
		)
		qdel(book)
		if(check_tick)
			CHECK_TICK
	GLOB.recipe_book_index = index

/// Maps entries to db ids by reference; unknown entries join the db, or stay inline once the db is frozen.
/proc/recipe_book_db_refs(list/entries, add_missing = FALSE)
	var/list/refs = list()
	for(var/list/entry as anything in entries)
		var/key = text_ref(entry)
		if(isnull(GLOB.recipe_book_db_ids[key]))
			if(!add_missing)
				refs += list(entry)
				continue
			GLOB.recipe_book_db_ids[key] = length(GLOB.recipe_book_db)
			GLOB.recipe_book_db += list(entry)
		refs += GLOB.recipe_book_db_ids[key]
	return refs

/// Resolves ids back to entries, the way the RecipeBook UI does.
/proc/recipe_book_db_entries(list/refs)
	var/list/entries = list()
	for(var/ref in refs)
		entries += list(isnum(ref) ? GLOB.recipe_book_db[ref + 1] : ref)
	return entries

/proc/get_recipe_book_index(book_type)
	build_recipe_book_db()
	return GLOB.recipe_book_index["[book_type]"]

/// This book's ids; recipes the craft HUD book learns per reader are appended after the type's own.
/obj/item/recipe_book/proc/get_recipe_book_ids()
	var/list/index = get_recipe_book_index(type)
	if(!index)
		return list("recipes" = list(), "linked" = list())
	var/list/learned = types - index["types"]
	if(!length(learned))
		return index
	return list(
		"recipes" = index["recipes"] + recipe_book_db_refs(collect_recipe_entries(learned)),
		"linked" = index["linked"],
	)

/obj/item/recipe_book/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/json/recipe_book_db))

/datum/asset/json/recipe_book_db
	name = "recipe_book_db"
	var/registered = FALSE

// SSassets loads every asset long before SSrecipe_books, so stay unregistered until the db exists.
/datum/asset/json/recipe_book_db/register()
	if(!length(GLOB.recipe_book_index))
		return
	registered = TRUE
	return ..()

/datum/asset/json/recipe_book_db/ensure_ready()
	if(!registered)
		build_recipe_book_db()
		register()
	return src

/datum/asset/json/recipe_book_db/generate()
	return GLOB.recipe_book_db
