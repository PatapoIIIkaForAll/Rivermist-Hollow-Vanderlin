/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */

/*
 * Bookcase
 */

/obj/structure/bookcase/fancy
	name = "fancy bookcase"
	icon = 'icons/roguetown/misc/fancybookshelf.dmi'
	icon_state = "fancybookcase"
	desc = ""
	anchored = FALSE
	density = TRUE
	opacity = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 200

/obj/structure/bookcase/fancy/examine(mob/user)
	. = ..()
//	if(!anchored)
//		. += "<span class='notice'>The <i>bolts</i> on the bottom are unsecured.</span>"
//	else
//		. += "<span class='notice'>It's secured in place with <b>bolts</b>.</span>"
//	switch(state)
///		if(0)
//	//		. += "<span class='notice'>There's a <b>small crack</b> visible on the back panel.</span>"
//	//	if(1)
//	//		. += "<span class='notice'>There's space inside for a <i>wooden</i> shelf.</span>"
//	//	if(2)
//	//		. += "<span class='notice'>There's a <b>small crack</b> visible on the shelf.</span>"

/obj/structure/bookcase/fancy/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	based = pick("a","b","c","d","e","f","g","h")
	state = 2
	anchored = TRUE
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/book))
			I.forceMove(src)
		if(istype(I, /obj/item/recipe_book))
			I.forceMove(src)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/bookcase/fancy/random_recipes
	var/random_books = 4

/obj/structure/bookcase/fancy/random_recipes/Initialize(mapload)
	. = ..()
	var/list/books = subtypesof(/obj/item/recipe_book)
	for(var/obj/item/recipe_book/listed_book as anything in books)
		if(initial(listed_book.can_spawn))
			continue
		books -= listed_book

	for(var/i = 1 to random_books)
		var/obj/item/recipe_book/book = pick_n_take(books)
		new book(src)
	update_appearance(UPDATE_ICON_STATE)
