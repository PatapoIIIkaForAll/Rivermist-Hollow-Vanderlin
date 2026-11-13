/datum/unit_test/library_shelves_no_blank_books

/datum/unit_test/library_shelves_no_blank_books/Run()
	var/obj/structure/bookcase/random/myths/shelf = allocate(/obj/structure/bookcase/random/myths)
	var/list/myth_lore = GLOB.random_bookcase_lore_books["Myths & Tales"]
	TEST_ASSERT(length(shelf.contents), "A random bookcase must shelve something, from the archive or from lore.")
	for(var/obj/item/book/book in shelf.contents)
		if(istype(book, /obj/item/book/playerbook))
			var/obj/item/book/playerbook/player_book = book
			TEST_ASSERT(player_book.player_book_title != initial(player_book.player_book_title), "Random bookcases must not shelve blank, untitled player books.")
			continue
		TEST_ASSERT(book.type in myth_lore, "A myths bookcase shelved [book.type], which is not one of its lore books.")
