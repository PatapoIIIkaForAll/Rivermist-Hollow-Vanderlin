/datum/container_craft/cooking/tea
	category = "Teas"
	abstract_type = /datum/container_craft/cooking/tea
	pollute_amount = 100
	finished_smell = /datum/pollutant/food/teas
	max_optionals = 3
	optional_reagent_requirements = list(/datum/reagent/consumable/milk = 5)
	optional_requirements = list(
		/obj/item/reagent_containers/food/snacks/sugar = 1,
		/obj/item/reagent_containers/food/snacks/pumpkin_spice = 1,
	)
	used_skill = /datum/attribute/skill/craft/cooking/fine_cuisine
	requires_fire = FALSE


/datum/container_craft/cooking/tea/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents, list/removing_items)
	var/datum/reagent/found_product = crafter.reagents.get_reagent(created_reagent)
	if(!found_product)
		return

	var/list/extras = list()
	for(var/obj/item/extra as anything in found_optional_requirements)
		extras += initial(extra.name)
	for(var/datum/reagent/extra as anything in found_optional_reagents)
		extras += LOWER_TEXT(initial(extra.name))

	if(length(extras))
		found_product.name += " with [english_list(extras)]"


/datum/container_craft/cooking/tea/taraxamint
	name = "Taraxacum-Mentha tea"
	crafting_time = 50 SECONDS
	created_reagent = /datum/reagent/consumable/tea/taraxamint
	requirements = list(
		/obj/item/alch/herb/taraxacum = 1,
		/obj/item/alch/herb/mentha = 1
	)

/datum/container_craft/cooking/tea/utricasalvia
	name = "Urtica-Salvia tea"
	crafting_time = 50 SECONDS
	created_reagent = /datum/reagent/consumable/tea/utricasalvia
	requirements = list(/obj/item/alch/herb/urtica = 1, /obj/item/alch/herb/salvia = 1)

/datum/container_craft/cooking/tea/badidea
	name = "Westleach Tar Tea"
	crafting_time = 30 SECONDS
	created_reagent = /datum/reagent/consumable/tea/badidea
	requirements = list(/obj/item/reagent_containers/food/snacks/produce/dry_westleach = 3)
	finished_smell = /datum/pollutant/food/fried_rat

/datum/container_craft/cooking/tea/fourtwenty
	name = "Swampweed Brew"
	crafting_time = 30 SECONDS
	created_reagent = /datum/reagent/consumable/tea/fourtwenty
	requirements = list(/obj/item/reagent_containers/food/snacks/produce/swampweed_dried = 2)
	finished_smell = /datum/pollutant/food/druqks

/datum/container_craft/cooking/tea/manabloom
	name = "Manabloom tea"
	crafting_time = 30 SECONDS
	created_reagent = /datum/reagent/consumable/tea/manabloom
	requirements = list(/obj/item/reagent_containers/food/snacks/produce/manabloom = 2)
	finished_smell = /datum/pollutant/food/druqks

/datum/container_craft/cooking/tea/compot
	name = "Compot"
	crafting_time = 60 SECONDS
	created_reagent = /datum/reagent/consumable/tea/compot
	requirements = list(/obj/item/reagent_containers/food/snacks/raisins = 2)
	finished_smell = /datum/pollutant/food/druqks

/datum/container_craft/cooking/tea/tiefbloodtea
	name = "Tiefing Blood Tea"
	crafting_time = 80 SECONDS
	created_reagent = /datum/reagent/consumable/tea/tiefbloodtea
	requirements = list(/obj/item/reagent_containers/food/snacks/tiefsugar = 1)
	finished_smell = /datum/pollutant/food/sugar

/datum/container_craft/cooking/tea/exotic
	name = "Exotic Tea"
	crafting_time = 30 SECONDS
	created_reagent = /datum/reagent/consumable/caffeine/tea
	requirements = list(/obj/item/reagent_containers/food/snacks/produce/tealeaves_ground = 2)
	finished_smell = /datum/pollutant/food/teas

/datum/container_craft/cooking/tea/coffee
	name = "Coffee"
	crafting_time = 30 SECONDS
	created_reagent = /datum/reagent/consumable/caffeine/coffee
	requirements = list(/obj/item/reagent_containers/food/snacks/produce/coffeebeansroasted = 2)
	finished_smell = /datum/pollutant/food/coffee

/datum/container_craft/cooking/tea/waddle
	name = "Waddle tea"
	crafting_time = 30 SECONDS
	created_reagent = /datum/reagent/consumable/tea/waddle
	requirements = list(/obj/item/reagent_containers/food/snacks/waddle_dried = 2)
	finished_smell = /datum/pollutant/food/waddle
