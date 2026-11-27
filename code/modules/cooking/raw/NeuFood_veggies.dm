/* * * * * * * * * * * **
 *						*
 *		 NeuFood		*
 *		(Veggies)		*
 *						*
 * * * * * * * * * * * **/

/obj/item/reagent_containers/food/snacks/veg
	dish_type = DISH_VEGETABLE
	faretype = FARE_POOR
	nutrition = VEGGIE_NUTRITION

/*	..................   Onion slice   ................... */
/obj/item/reagent_containers/food/snacks/veg/onion_sliced
	item_weight = 70 GRAMS
	name = "sliced onion"
	desc = "An onion cut into pieces, ready for the pot."
	icon_state = "onion_sliced"
	slices_num = 0
	slice_skill = /datum/attribute/skill/craft/cooking/preparation

/*	..................   Cabbage   ................... */
/obj/item/reagent_containers/food/snacks/veg/cabbage_sliced
	item_weight = 300 GRAMS
	name = "shredded cabbage"
	desc = "A head of cabbage shredded into thin ribbons."
	icon_state = "cabbage_sliced"
	slice_skill = /datum/attribute/skill/craft/cooking/preparation

/*	..................   Potato   ................... */
/obj/item/reagent_containers/food/snacks/veg/potato_sliced
	item_weight = 70 GRAMS
	name = "potato cuts"
	desc = "A potato cut into chunks, ready for the pot."
	icon_state = "potato_sliced"
	slice_skill = /datum/attribute/skill/craft/cooking/preparation

/*	..................   Turnip   ................... */
/obj/item/reagent_containers/food/snacks/veg/turnip_sliced
	item_weight = 70 GRAMS
	name = "cleaned turnip"
	desc = "A turnip scrubbed and cut into pieces, ready for the pot."
	icon_state = "turnip_sliced"
	slice_skill = /datum/attribute/skill/craft/cooking/preparation


/*	..................		Roasted seeds		................... */
/obj/item/reagent_containers/food/snacks/roastseeds
	dish_type = DISH_VEGETABLE
	item_weight = 5 GRAMS
	nutrition = BERRY_NUTRITION * COOK_MOD
	tastes = list("roasted seeds" = 1)
	name = "roasted seeds"
	desc = "Treats for both rats and humens."
	icon_state = "roastseeds"
	dropshrink = 0.8
	color = "#e5b175"
	foodtype = VEGETABLES
	rotprocess = null
	faretype = FARE_POOR

/*	..................		Salted seeds		................... */
/obj/item/reagent_containers/food/snacks/saltseeds
	dish_type = DISH_VEGETABLE
	item_weight = 5 GRAMS
	nutrition =  (BERRY_NUTRITION+1) * COOK_MOD
	tastes = list("salted roasted seeds" = 1)
	name = "salted roasted seeds"
	desc = "Too salty for rats, delectable for humens."
	icon_state = "roastseeds"
	dropshrink = 0.8
	color = "#e5b175"
	foodtype = VEGETABLES
	rotprocess = null
	eat_effect = /datum/status_effect/buff/foodbuff
	faretype = FARE_NEUTRAL
