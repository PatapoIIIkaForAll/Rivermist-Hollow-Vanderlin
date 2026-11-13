// Pumpkin recipes on our pan, oven, pot, pie slapcraft, dough crafting and keg.

// Pan --------------------------------------------------------------------------

/datum/container_craft/pan/pumpkin_mash
	name = "Pumpkin Mash"
	requirements = list(/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced = 1)
	output = /obj/item/reagent_containers/food/snacks/pumpkin_mash
	cooked_smell = /datum/pollutant/food/roasted_pumpkin

/datum/container_craft/pan/roastseeds_pumpkin
	name = "Roasted Pumpkin Seeds"
	crafting_time = 15 SECONDS
	requirements = list(/obj/item/neuFarm/seed/pumpkin = 1)
	output = /obj/item/reagent_containers/food/snacks/roastseeds/pumpkin
	cooked_smell = /datum/pollutant/food/roasted_seeds

/datum/container_craft/pan/pumpkinball
	name = "Fried Pumpkin Balls"
	requirements = list(/obj/item/reagent_containers/food/snacks/foodbase/pumpkinball_raw = 1)
	output = /obj/item/reagent_containers/food/snacks/pumpkinball
	cooked_smell = /datum/pollutant/food/pastry

// Oven -------------------------------------------------------------------------

/datum/container_craft/oven/pie/pumpkin
	name = "Pumpkin Pie"
	requirements = list(/obj/item/reagent_containers/food/snacks/foodbase/pumpkinpie_raw = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/cooked/pumpkin
	good_path = /obj/item/reagent_containers/food/snacks/pie/cooked/pumpkin/good
	cooked_smell = /datum/pollutant/food/pumpkin_pie

/datum/container_craft/oven/pumpkin_loaf
	name = "Pumpkin Loaf"
	requirements = list(/obj/item/reagent_containers/food/snacks/foodbase/pumpkinloaf_raw = 1)
	output = /obj/item/reagent_containers/food/snacks/bread/pumpkin
	cooked_smell = /datum/pollutant/food/pumpkin_loaf

/datum/container_craft/oven/pumpkinball
	name = "Baked Pumpkin Balls"
	requirements = list(/obj/item/reagent_containers/food/snacks/foodbase/pumpkinball_raw = 1)
	output = /obj/item/reagent_containers/food/snacks/pumpkinball
	cooked_smell = /datum/pollutant/food/pastry

// Pot --------------------------------------------------------------------------

/datum/container_craft/cooking/pumpkin_soup
	name = "Pumpkin Soup"
	created_reagent = /datum/reagent/consumable/soup/veggie/pumpkin
	requirements = list(/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced = 1)
	max_optionals = 3
	optional_wildcard_requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/vegetable = 3
	)
	finished_smell = /datum/pollutant/food/pumpkin_soup
	crafting_time = 40 SECONDS

/datum/container_craft/cooking/pumpkin_soup/roasted
	name = "Roasted Pumpkin Soup"
	created_reagent = /datum/reagent/consumable/soup/veggie/pumpkin/roasted
	requirements = list(/obj/item/reagent_containers/food/snacks/pumpkin_mash = 1)

// Pie slapcraft ----------------------------------------------------------------

// Open pie: no dough lid, sugar finishes it.
/datum/orderless_slapcraft/food/pie/pumpkin
	name = "Unbaked Pumpkin Pie"
	requirements = list(
		list(
			/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced,
			/obj/item/reagent_containers/food/snacks/pumpkin_mash) = 2,
		/obj/item/reagent_containers/food/snacks/egg = 1,
	)
	finishing_item = /obj/item/reagent_containers/food/snacks/sugar
	overlay_state = "fill_pumpkin"
	output_item = /obj/item/reagent_containers/food/snacks/foodbase/pumpkinpie_raw

/datum/orderless_slapcraft/food/pie/pumpkin/step_process(mob/user, obj/item/attacking_item)
	hosted_source.name = "unfinished [name]"
	var/remaining = 0
	for(var/requirement in requirements)
		remaining += requirements[requirement]
	hosted_source.cut_overlays()
	hosted_source.add_overlay(mutable_appearance('modular_rmh/modular/pumpkins/icons/pumpkin_food.dmi', "[overlay_state][clamp(fill_states - remaining, 1, fill_states)]"))

// Dough ------------------------------------------------------------------------

/datum/repeatable_crafting_recipe/cooking/pumpkin_loaf
	name = "Raw Pumpkin Loaf"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/butterdough = 1,
		/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough
	starting_atom = /obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced
	output = /obj/item/reagent_containers/food/snacks/foodbase/pumpkinloaf_raw
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "knead pumpkin into the dough"
	extra_chance = 100
	skillcraft = /datum/attribute/skill/craft/cooking/baking

/datum/repeatable_crafting_recipe/cooking/pumpkin_loaf/mash
	name = "Raw Pumpkin Loaf (mash)"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/butterdough = 1,
		/obj/item/reagent_containers/food/snacks/pumpkin_mash = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/pumpkin_mash

/datum/repeatable_crafting_recipe/cooking/pumpkin_ball
	name = "Uncooked Pumpkin Balls"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
		/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced
	output = /obj/item/reagent_containers/food/snacks/foodbase/pumpkinball_raw
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "roll pumpkin into little balls of dough"
	extra_chance = 100
	skillcraft = /datum/attribute/skill/craft/cooking/baking

/datum/repeatable_crafting_recipe/cooking/pumpkin_ball/mash
	name = "Uncooked Pumpkin Balls (mash)"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
		/obj/item/reagent_containers/food/snacks/pumpkin_mash = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/pumpkin_mash

// Keg --------------------------------------------------------------------------

/datum/brewing_recipe/pumpkin_ale
	name = "Pumpkin Ale"
	reagent_to_brew = /datum/reagent/consumable/ethanol/pumpkin_ale
	needed_reagents = list(/datum/reagent/water = 100)
	needed_crops = list(/obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced = 4)
	needed_items = list(/obj/item/reagent_containers/food/snacks/pumpkin_spice = 1)
	brewed_amount = 3
	brew_time = 2.5 MINUTES
	sell_value = 35
	brewing_skill = /datum/attribute/skill/craft/cooking/brewing
