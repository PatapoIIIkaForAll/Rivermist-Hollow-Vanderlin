// Pumpkin foods, spice, soups and ale. Twilight-Axis recipes, adapted to our cooking.

#define PUMPKIN_FOOD_ICON 'modular_rmh/modular/pumpkins/icons/pumpkin_food.dmi'
#define PUMPKINPIE_NUTRITION (CRUST_NUTRITION + VEGGIE_NUTRITION * 2 + EGG_NUTRITION + SUGAR_NUTRITION)
#define PUMPKINLOAF_NUTRITION (BUTTERDOUGH_NUTRITION + VEGGIE_NUTRITION)
#define PUMPKINBALL_NUTRITION (BUTTERDOUGHSLICE_NUTRITION + VEGGIE_NUTRITION)

/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced
	item_weight = 600 GRAMS
	name = "pumpkin slice"
	desc = "A thick wedge of pumpkin flesh. Better cooked than raw."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkin_sliced"
	tastes = list("raw pumpkin" = 1)
	filling_color = "#d9761c"
	foodtype = VEGETABLES
	rotprocess = SHELFLIFE_LONG
	slice_skill = /datum/attribute/skill/craft/cooking/preparation

/obj/item/reagent_containers/food/snacks/pumpkin_mash
	item_weight = 500 GRAMS
	name = "pumpkin mash"
	desc = "Once bland, now a surprisingly rich and fibrous mash."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkin_mash"
	nutrition = COOKED_VEGGIE_NUTRITION
	faretype = FARE_NEUTRAL
	foodtype = VEGETABLES
	tastes = list("sweet pumpkin mash" = 1)
	filling_color = "#e8a43a"
	bitesize = 3
	rotprocess = SHELFLIFE_LONG
	portable = FALSE

// Pie --------------------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/foodbase/pumpkinpie_raw
	item_weight = 400 GRAMS
	name = "uncooked pumpkin pie"
	desc = "An open pie of sweet pumpkin custard, waiting for the oven."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinpie_raw"
	w_class = WEIGHT_CLASS_NORMAL
	eat_effect = /datum/status_effect/debuff/uncookedfood
	nutrition = PUMPKINPIE_NUTRITION
	foodtype = GRAIN | VEGETABLES | SUGAR | RAW
	filling_color = "#df7a04"
	dropshrink = 0.9

/obj/item/reagent_containers/food/snacks/pie/cooked/pumpkin
	name = "pumpkin pie"
	desc = "An open pie of baked pumpkin custard, sweet and warmly spiced."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinpie"
	color = null
	filling_color = "#df7a04"
	slice_path = /obj/item/reagent_containers/food/snacks/pieslice/pumpkin
	nutrition = PUMPKINPIE_NUTRITION * COOK_MOD
	foodtype = GRAIN | VEGETABLES | SUGAR
	tastes = list("crispy butterdough" = 1, "sweet pumpkin" = 1)

// Full-colour sprite; the generic tinted filling overlay would cover it.
/obj/item/reagent_containers/food/snacks/pie/cooked/pumpkin/update_snack_overlays(obj/item/reagent_containers/food/snacks/S)
	return

/obj/item/reagent_containers/food/snacks/pie/cooked/pumpkin/good
	eat_effect = /datum/status_effect/buff/foodbuff
	slice_path = /obj/item/reagent_containers/food/snacks/pieslice/pumpkin/good
	tastes = list("crispy butterdough" = 1, "rich pumpkin custard" = 1)

/obj/item/reagent_containers/food/snacks/pie/cooked/pumpkin/good/Initialize(mapload)
	. = ..()
	good_quality_descriptors()

/obj/item/reagent_containers/food/snacks/pieslice/pumpkin
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, still holding its shape."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinpie_slice"
	color = null
	filling_color = "#df7a04"
	nutrition = PUMPKINPIE_NUTRITION * COOK_MOD * SLICED_MOD
	foodtype = GRAIN | VEGETABLES | SUGAR
	tastes = list("crispy butterdough" = 1, "sweet pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/pieslice/pumpkin/update_snack_overlays(obj/item/reagent_containers/food/snacks/S)
	return

/obj/item/reagent_containers/food/snacks/pieslice/pumpkin/good
	eat_effect = /datum/status_effect/buff/foodbuff

// Loaf -------------------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/foodbase/pumpkinloaf_raw
	item_weight = 500 GRAMS
	name = "raw pumpkin loaf"
	desc = "Butterdough kneaded with pumpkin. Into the oven you go!"
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinloaf_raw"
	w_class = WEIGHT_CLASS_NORMAL
	eat_effect = /datum/status_effect/debuff/uncookedfood
	nutrition = PUMPKINLOAF_NUTRITION
	faretype = FARE_IMPOVERISHED
	foodtype = GRAIN | DAIRY | VEGETABLES | RAW
	rotprocess = SHELFLIFE_DECENT
	tastes = list("dough" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/bread/pumpkin
	name = "pumpkin loaf"
	desc = "A loaf of sweetbread baked with pumpkin. A surprising dessert, easily shared."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinloaf"
	base_icon_state = "pumpkinloaf"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/pumpkin
	nutrition = PUMPKINLOAF_NUTRITION * COOK_MOD
	faretype = FARE_NEUTRAL
	foodtype = GRAIN | DAIRY | VEGETABLES
	tastes = list("sweetbread" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/breadslice/pumpkin
	name = "pumpkin loaf slice"
	desc = "Soft and chewy. It is surprisingly light for what went into it."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinloaf_slice"
	nutrition = PUMPKINLOAF_NUTRITION * COOK_MOD * SLICED_MOD
	faretype = FARE_NEUTRAL
	foodtype = GRAIN | DAIRY | VEGETABLES
	tastes = list("sweetbread" = 1, "pumpkin" = 1)

// Balls ------------------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/foodbase/pumpkinball_raw
	item_weight = 150 GRAMS
	name = "uncooked pumpkin balls"
	desc = "Little balls of dough mixed with pumpkin, yearning to be baked or fried."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinball_raw"
	gender = PLURAL
	eat_effect = /datum/status_effect/debuff/uncookedfood
	nutrition = PUMPKINBALL_NUTRITION
	faretype = FARE_IMPOVERISHED
	foodtype = GRAIN | DAIRY | VEGETABLES | RAW
	rotprocess = SHELFLIFE_DECENT
	tastes = list("dough" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/pumpkinball
	item_weight = 150 GRAMS
	name = "pumpkin balls"
	desc = "Crispy, soft balls of dough mixed with pumpkin. A surprisingly nice snack."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinball"
	base_icon_state = "pumpkinball"
	gender = PLURAL
	biting = TRUE
	bitesize = 3
	nutrition = PUMPKINBALL_NUTRITION * COOK_MOD
	faretype = FARE_NEUTRAL
	foodtype = GRAIN | DAIRY | VEGETABLES
	filling_color = "#d17624"
	rotprocess = SHELFLIFE_LONG
	tastes = list("crispy butterdough" = 1, "pumpkin" = 1)

// Seeds and spice --------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/roastseeds/pumpkin
	name = "roasted pumpkin seeds"
	desc = "Toasted pumpkin seeds. A millstone grinds them into pumpkin spice."
	color = "#c9a35e"
	tastes = list("toasted pumpkin seeds" = 1)
	mill_result = /obj/item/reagent_containers/food/snacks/pumpkin_spice

/obj/item/reagent_containers/food/snacks/pumpkin_spice
	item_weight = 30 GRAMS
	name = "pumpkin spice"
	desc = "Rich flavours from a humble origin. A pinch livens up tea and coffee."
	icon = PUMPKIN_FOOD_ICON
	icon_state = "pumpkinspice"
	gender = PLURAL
	w_class = WEIGHT_CLASS_TINY
	nutrition = SNACK_WORST
	foodtype = VEGETABLES
	tastes = list("warm spice" = 1)
	list_reagents = list(/datum/reagent/consumable/pumpkin_spice = 5)
	grind_results = list(/datum/reagent/consumable/pumpkin_spice = 10)
	rotprocess = null
	sellprice = 4

/datum/reagent/consumable/pumpkin_spice
	name = "pumpkin spice"
	description = "Spiced delight."
	color = "#b5652a"
	taste_description = "warm autumn spice"
	nutriment_factor = 0.5

// Soups and ale ----------------------------------------------------------------

/datum/reagent/consumable/soup/veggie/pumpkin
	name = "pumpkin soup"
	color = "#c98c42"
	taste_description = "autumn's loving embrace"

/datum/reagent/consumable/soup/veggie/pumpkin/roasted
	name = "roasted pumpkin soup"
	color = "#d3702e"
	taste_description = "a hearth kindled within your chest"
	nutriment_factor = 9

/datum/reagent/consumable/ethanol/pumpkin_ale
	name = "Pumpkin Ale"
	boozepwr = 25
	taste_description = "sweet spiced pumpkin"
	glass_name = "glass of pumpkin ale"
	color = "#c0702a"
	quality = DRINK_NICE

/datum/pollutant/food/pumpkin_pie
	name = "pumpkin pie"
	scent = "pumpkin pie"

/datum/pollutant/food/pumpkin_loaf
	name = "fresh baked pumpkin loaf"
	scent = "fresh baked pumpkin loaf"

/datum/pollutant/food/pumpkin_soup
	name = "pumpkin soup"
	scent = "pumpkin soup"

/datum/pollutant/food/roasted_pumpkin
	name = "roasted pumpkin"
	scent = "roasted pumpkin"

#undef PUMPKIN_FOOD_ICON
#undef PUMPKINPIE_NUTRITION
#undef PUMPKINLOAF_NUTRITION
#undef PUMPKINBALL_NUTRITION
