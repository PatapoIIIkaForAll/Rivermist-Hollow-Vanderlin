/obj/item/clothing/face/facemask/steel/kazengun
	name = "soldier's half-mask"
	desc = "\"The first lesson of war is that it would be better to live in peace.\""
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "kazengunmouthguard"
	item_state = "kazengunmouthguard"
	block2add = null
	armor_type = /datum/armor/plate
	max_integrity = 100
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/visor
	name = "helmetless visor"
	desc = "Fashion eschewing any practicality, or a knight's belonging so downtrodden the rest of their helmet was lost. Only seems to cover the eyes and nose, if barely."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "helmetless_visor"
	armor_type = /datum/armor/plate
	flags_inv = HIDEFACE
	body_parts_covered = EYES | NOSE
	block2add = FOV_DEFAULT
	max_integrity = 200
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HIP|ITEM_SLOT_HEAD
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
