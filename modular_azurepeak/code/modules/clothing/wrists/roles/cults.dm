/obj/item/clothing/wrists/bracers/graggar
	name = "vicious bracers"
	desc = "Oh, to plunge hands into cold water; to play a melody upon an ivory-keyed piano; to watch steam rise from boiling, twisting entrails.."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "graggarbracers"
	item_state = "graggarbracers"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/matthios
	name = "gilded bracers"
	desc = "Away with you, vile beggar!"
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "matthiosbracers"
	item_state = "matthiosbracers"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/graggar/heavy
	name = "vicious wristguards"
	desc = "Swaying chains, padded with a mixture of twine, leather and entrails. Steel and bone on the outside. It won't survive the onslaught - but it's not meant to. </br>Gruumsh lost his eye to Corellon's blade at the dawn of the world, and every orc who has worn such wristguards since has sworn to repay that wound a thousandfold."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "graggarplatebracer_heavy"
	max_integrity = ARMOR_INT_SIDE_ANTAG
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/graggar/heavy/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/wrists/bracers/graggar/heavy/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/wrists/bracers/leather/baotha
	name = "saccharine cuffs"
	desc = "Leather cuffs lacquered in sickly pink. Blissara's priests say that every chain can be made sweet, if only the captive learns to want it."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "baothabracers"
	armor_type = /datum/armor/ported/padded
	resistance_flags = FIRE_PROOF
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/leather/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/wrists/bracers/leather/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)
