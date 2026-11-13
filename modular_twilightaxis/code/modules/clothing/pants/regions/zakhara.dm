/obj/item/clothing/pants/sirwal
	name = "sirwal"
	desc = "Long, baggy trousers from the Land of Fate, Zakhara."
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = null
	ported_clothing = TRUE

/obj/item/clothing/pants/sirwal/beige
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = "#edc6a5"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/black
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = CLOTHING_BLACK
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/brown
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = "#927351"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/fancy
	name = "fancy sirwal"
	desc = "Long, baggy trousers from Zakharan dyed in expensive, exotic colours."
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/plainrandom
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/plainrandom/Initialize()
	color = pick("#FFFFFF", "#edc6a5", "#927351", CLOTHING_BLACK)
	. = ..()

/obj/item/clothing/pants/sirwal/fancy/blue
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = CLOTHING_BLUE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/fancy/purple
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = CLOTHING_PURPLE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/fancy/random
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/fancy/random/Initialize()
	color = pick(CLOTHING_BLACK, CLOTHING_BLUE, CLOTHING_PURPLE, CLOTHING_RED, CLOTHING_YELLOW)
	. = ..()

/obj/item/clothing/pants/sirwal/fancy/red
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = CLOTHING_RED
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/sirwal/fancy/yellow
	icon = 'modular_twilightaxis/icons/clothing/desert/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"
	color = CLOTHING_YELLOW
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
