//By Vide Noir https://github.com/EaglePhntm.

/obj/item/clothing/pants/trou/leather/skirt
	name = "leather skirt"
	icon = 'modular_rmh/icons/clothing/armor/pants.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/armor/onmob/pants.dmi'
	desc = "Short skirt made of fine leather."
	icon_state = "leatherskirt"
	genital_access = TRUE

/obj/item/clothing/pants/trou/leather/advanced/skirt
	name = "hardened leather skirt"
	icon = 'modular_rmh/icons/clothing/armor/pants.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/armor/onmob/pants.dmi'
	icon_state = "hlskirt"
	item_state = "hlskirt"
	genital_access = TRUE

/obj/item/clothing/pants/chainlegs/iron/studdedskirt
	name = "studded leather skirt"
	icon = 'modular_rmh/icons/armor/pants.dmi'
	mob_overlay_icon = 'modular_rmh/icons/armor/onmob/pants.dmi'
	armor = ARMOR_LEATHER_GOOD
	desc = "Short studded skirt made of fine leather and iron."
	icon_state = "studdedskirt"
	genital_access = TRUE

/obj/item/clothing/pants/chainlegs/iron/skirt
	name = "iron chain skirt"
	icon = 'modular_rmh/icons/clothing/armor/pants.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/armor/onmob/pants.dmi'
	icon_state = "chain_skirt"
	item_state = "chain_skirt"
	color = "#9EA48E"
	genital_access = TRUE

/obj/item/clothing/pants/chainlegs/skirt
	name = "chain skirt"
	icon = 'modular_rmh/icons/clothing/armor/pants.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/armor/onmob/pants.dmi'
	icon_state = "chain_skirt"
	item_state = "chain_skirt"
	genital_access = TRUE

/obj/item/clothing/pants/platelegs/skirt
	name = "plated skirt"
	icon = 'modular_rmh/icons/clothing/armor/pants.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/armor/onmob/pants.dmi'
	icon_state = "plate_skirt"
	item_state = "plate_skirt"
	genital_access = TRUE

///RECIPES

/datum/repeatable_crafting_recipe/sewing/leatherskirt
	name = "leather skirt"
	output = list(/obj/item/clothing/pants/trou/leather/skirt)
	requirements = list(/obj/item/natural/hide = 1,
	/obj/item/reagent_containers/food/snacks/tallow = 1,)
	sellprice = 10

/datum/repeatable_crafting_recipe/leather/standalone/hlskirt
	name = "hardened leather skirt"
	output = /obj/item/clothing/pants/trou/leather/advanced/skirt
	requirements = list(/obj/item/natural/hide/cured = 1,
				/obj/item/natural/fibers = 1,
				/obj/item/reagent_containers/food/snacks/tallow = 1,)
	craftdiff = 4

/datum/anvil_recipe/armor/studdedskirt
	name = "Studded Skirt (+1 Leather Skirt)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/clothing/pants/trou/leather/skirt)
	created_item = /obj/item/clothing/pants/chainlegs/iron/studdedskirt
	category = "Armor"

/datum/anvil_recipe/armor/chainskirt
	name = "Chain Skirt"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/pants/chainlegs/skirt
	craftdiff = 2
	category = "Armor"

/datum/anvil_recipe/armor/ichainskirt
	name = "Iron Chain Skirt"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/pants/chainlegs/iron/skirt
	craftdiff = 1
	category = "Armor"

/datum/anvil_recipe/armor/plateskirt
	name = "Plate Tassets (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/ingot/steel)
	created_item = /obj/item/clothing/pants/platelegs/skirt
	craftdiff = 4	//It's plate, no easy craft.
	category = "Armor"

///CONVERSIONS

/datum/repeatable_crafting_recipe/leatherskirtconv
	name = "leather pants to skirt"
	output = list(/obj/item/clothing/pants/trou/leather/skirt)
	requirements = list(/obj/item/clothing/pants/trou/leather = 1)

/datum/repeatable_crafting_recipe/leatherskirtconvtwo
	name = "hardened leather pants to skirt"
	output = list(/obj/item/clothing/pants/trou/leather/advanced/skirt)
	requirements = list(/obj/item/clothing/pants/trou/leather/advanced = 1)
