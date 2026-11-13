GLOBAL_LIST_INIT(random_bookcase_lore_books, list(
	"Apocrypha & Grimoires" = list(
		/obj/item/book/magicaltheory,
		/obj/item/book/arcyne,
		/obj/item/book/godofdreamsandnightmares,
		/obj/item/book/vownecrapage,
		/obj/item/book/necra,
		/obj/item/book/noc,
		/obj/item/book/psybibleplayerbook,
		/obj/item/book/bookofpriests,
	),
	"Myths & Tales" = list(
		/obj/item/book/tales1,
		/obj/item/book/festus,
		/obj/item/book/tales3,
		/obj/item/book/beardling,
	),
	"Legends & Accounts" = list(
		/obj/item/book/tales3,
		/obj/item/book/blackmountain,
		/obj/item/book/abyssor,
		/obj/item/book/mysticalfog,
		/obj/item/book/magicaltheory,
		/obj/item/book/noc,
	),
	"Thesis" = list(
		/obj/item/book/knowledge1,
		/obj/item/book/arcyne,
		/obj/item/book/mysticalfog,
		/obj/item/book/fishing,
		/obj/item/book/sword,
		/obj/item/book/robber,
		/obj/item/book/cardgame,
		/obj/item/book/manners,
		/obj/item/book/advice_soup,
		/obj/item/book/advice_farming,
		/obj/item/book/advice_weaving,
		/obj/item/book/yeoldecookingmanual,
	),
))

/obj/structure/bookcase/proc/shelve_random_books(amount, category)
	if(!isnum(amount) || amount < 1)
		return
	var/list/categories = category ? list(category) : null
	if(category == "Erotica")
		categories += list("Romance & Scandal", "Eoratica")
	var/list/player_books = SSlibrarian.get_player_book_titles(categories)
	var/list/lore_books = list()
	for(var/lore_category in GLOB.random_bookcase_lore_books)
		if(!category || lore_category == category)
			lore_books |= GLOB.random_bookcase_lore_books[lore_category]
	for(var/i in 1 to amount)
		if(length(player_books))
			new /obj/item/book/playerbook(src, null, null, null, pick_n_take(player_books))
		else if(length(lore_books))
			var/book_type = pick_n_take(lore_books)
			new book_type(src)
		else
			return

/obj/structure/bookcase/random
	var/category = null
	var/book_count = 10
	anchored = TRUE
	state = 2
	based = "a"

/obj/structure/bookcase/random/Initialize(mapload)
	. = ..()
	based = pick("a","b","c","d","e","f","g","h")
	state = 2
	anchored = TRUE
	book_count = rand(5,10) // Set book_count between 5 and 10
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bookcase/random/LateInitialize()
	create_random_books(book_count)
	update_appearance(UPDATE_ICON_STATE)
	return ..()

/obj/structure/bookcase/random/proc/create_random_books(amount = 2)
	shelve_random_books(amount, category)

/obj/structure/bookcase/random/apocrypha
	name = "bookcase (Apocrypha & Grimoires)"
	category = "Apocrypha & Grimoires"

/obj/structure/bookcase/random/myths
	name = "bookcase (Myths & Tales)"
	category = "Myths & Tales"

/obj/structure/bookcase/random/legends
	name = "bookcase (Legends & Accounts)"
	category = "Legends & Accounts"

/obj/structure/bookcase/random/thesis
	name = "bookcase (Thesis)"
	category = "Thesis"

/obj/structure/bookcase/random/erotica
	name = "bookcase (Erotica)"
	category = "Erotica"

/obj/structure/bookcase/random/archive // Deprecated subtype, used in the old code. Swap these out for one of the types above whenever possible.
	name = "bookcase (Random)"
	category = "Erotica"
	desc = "This is an improper bookcase. Please exit the game and inform your local mapper where this is and to replace it."

/obj/structure/bookcase/fancy/random
	var/category = null
	var/book_count = 10
	anchored = TRUE
	state = 2
	based = "a"

/obj/structure/bookcase/fancy/random/Initialize(mapload)
	. = ..()
	based = pick("a","b","c","d","e","f","g","h")
	state = 2
	anchored = TRUE
	book_count = rand(5,10) // Set book_count between 5 and 10
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bookcase/fancy/random/LateInitialize()
	create_random_books(book_count)
	update_appearance(UPDATE_ICON_STATE)
	return ..()

/obj/structure/bookcase/fancy/random/proc/create_random_books(amount = 2)
	shelve_random_books(amount, category)

/obj/structure/bookcase/fancy/random/apocrypha
	name = "fancy bookcase (Apocrypha & Grimoires)"
	category = "Apocrypha & Grimoires"

/obj/structure/bookcase/fancy/random/myths
	name = "fancy bookcase (Myths & Tales)"
	category = "Myths & Tales"

/obj/structure/bookcase/fancy/random/legends
	name = "fancy bookcase (Legends & Accounts)"
	category = "Legends & Accounts"

/obj/structure/bookcase/fancy/random/thesis
	name = "fancy bookcase (Thesis)"
	category = "Thesis"

/obj/structure/bookcase/fancy/random/erotica
	name = "fancy bookcase (Erotica)"
	category = "Erotica"

/obj/structure/bookcase/fancy/random/archive // Deprecated subtype, used in the old code. Swap these out for one of the types above whenever possible.
	name = "fancy bookcase (Random)"
	category = "Erotica"
	desc = "This is an improper bookcase. Please exit the game and inform your local mapper where this is and to replace it."

/obj/item/book/random_book
	var/book_category = null
	random_cover = TRUE

/obj/item/book/random_book/Initialize()
	if(!..())
		return FALSE
	return INITIALIZE_HINT_LATELOAD // Indicate that LateInitialize() should be called

/obj/item/book/random_book/LateInitialize()
	src.get_random_book_from_database(book_category)
	return ..()

/obj/item/book/random_book/proc/get_random_book_from_database(book_category)
	var/datum/DBQuery/query_get_random_book = SSdbcore.NewQuery({"
		SELECT author, title, content, category, select_icon
		FROM library
		WHERE deleted <> 1 AND approved = 1 AND category = :category
		ORDER BY RAND() LIMIT 1
	"}, list("category" = book_category))

	if (query_get_random_book && query_get_random_book.Execute())
		if (query_get_random_book.NextRow())
			src.author = query_get_random_book.item[1]
			src.title = query_get_random_book.item[2]
			var/content = query_get_random_book.item[3]
			src.category = query_get_random_book.item[4]
			var/select_icon = query_get_random_book.item[5]

			src.pages = list("<b3><h3>Title: [src.title]<br>Author: [src.author]</b><h3>[content]")
			src.name = src.title
			if (select_icon)
				src.icon_state = "[select_icon]_0"
				src.base_icon_state = select_icon
			else
				src.icon_state = "book[rand(1,8)]"
		else
			// No books found; delete the book object
			qdel(src)
	else
		// Query failed; delete the book object
		qdel(src)

	if(query_get_random_book)
		qdel(query_get_random_book)

/obj/item/book/random_book/apocrypha
	book_category = "Apocrypha & Grimoires"
	name = "Book (Apocrypha & Grimoires)"

/obj/item/book/random_book/myths
	book_category = "Myths & Tales"
	name = "Book (Myths & Tales)"

/obj/item/book/random_book/legends
	book_category = "Legends & Accounts"
	name = "Book (Legends & Accounts)"

/obj/item/book/random_book/thesis
	book_category = "Thesis"
	name = "Book (Thesis)"

/obj/item/book/random_book/erotica
	book_category = "Erotica"
	name = "Book (Erotica)"

/obj/item/book/random // Deprecated subtype
	name = "Book (improper)"
	desc = "Inform your local coder/mapper to have this removed."
