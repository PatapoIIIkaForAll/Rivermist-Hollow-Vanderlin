/obj/item/clothing/head/decoration
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = null
	armor_type = /datum/armor/none
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/head/decoration

/obj/item/clothing/head/halo
	name = "halo"
	desc = "<font color='FFFF00'>'Don't forget, I'm with you in the dark.'</font>"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "chiv_halo"
	item_state = "chiv_halo"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	alternate_worn_layer = HALO_LAYER
	body_parts_covered = null
	resistance_flags = FIRE_PROOF | ACID_PROOF
	smeltresult = /obj/item/ingot/gold
	max_integrity = 777
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/decoration/gazelleskull
	name = "Gazelle Skull"
	desc = "A skull, carved from a gazelle that rests overhead. The tribal identity of the gazelle is seen as an omen of sorts. Known for being quick to act and fleetfooted, it symbolizes the need to be fast to react and the need to get out of danger. Sometimes, you will encounter an insurmountable threat, and in order to survive against such a threat, you must flee. That is a fact of life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "donor_skull"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	alternate_worn_layer = 8.9
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/shroudwhite/evil_ah_ah
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "whitehood"
	item_state = "whitehood"
	color = CLOTHING_SCARLET
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/cap/dwarf
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "armingcap"
	item_state = "armingcap"
	color = "#cb3434"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
