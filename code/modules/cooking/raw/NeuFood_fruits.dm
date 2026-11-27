/* * * * * * * * * * * **
 *						*
 *		 NeuFood		*
 *		(FRUITS)		*
 *						*
 * * * * * * * * * * * **/

/obj/item/reagent_containers/food/snacks/fruit
	dish_type = DISH_FRUIT
	faretype = FARE_NEUTRAL
	bitesize = 2
	nutrition = FRUIT_NUTRITION
	foodtype = FRUIT

/*	..................   mango   ................... */
/obj/item/reagent_containers/food/snacks/fruit/mango_half
	item_weight = 90 GRAMS
	name = "mangga"
	desc = "Half of a mangga, its stone removed, ready to eat."
	icon_state = "mango_half"
	dropshrink = 0.8
	nutrition = FRUIT_NUTRITION/2

/*	..................   mangosteen   ................... */
/obj/item/reagent_containers/food/snacks/fruit/mangosteen_opened
	item_weight = 75 GRAMS
	name = "mangosteen"
	desc = "A mangosteen cracked open, its pale flesh exposed."
	icon_state = "mangosteen_open"
	trash = /obj/item/trash/mangosteenshell
	bitesize = 5
	dropshrink = 0.8

/*	..................   avocado   ................... */
/obj/item/reagent_containers/food/snacks/fruit/avocado_half
	item_weight = 60 GRAMS
	name = "avocado"
	desc = "Half of an avocado, pit removed, its flesh soft and green."
	icon_state = "avocado_half"
	dropshrink = 0.9
	nutrition = FRUIT_NUTRITION/2

/*	..................   dragonfruit   ................... */
/obj/item/reagent_containers/food/snacks/fruit/dragonfruit_half
	item_weight = 175 GRAMS
	name = "piyata"
	desc = "Half of a piyata, its speckled white flesh exposed."
	icon_state = "dragonfruit_half"
	dropshrink = 0.7
	nutrition = FRUIT_NUTRITION/2

/*	..................   pineapple   ................... */
/obj/item/reagent_containers/food/snacks/fruit/pineapple_slice
	item_weight = 200 GRAMS
	name = "ananas slice"
	desc = "A ring cut from an ananas, sweet and fibrous."
	icon_state = "pineapple_slice"
	bitesize = 1
	dropshrink = 0.7
	nutrition = FRUIT_NUTRITION/2
	foodtype = FRUIT | PINEAPPLE
