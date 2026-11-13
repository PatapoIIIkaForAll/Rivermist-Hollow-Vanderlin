/obj/item/clothing/neck/gorget/ancient/vampire
	name = "ancient ceremonial gorget"
	desc = "A neckguard of enchanted gilbranze. Though a vampyre needn't air to lyve, they most certainly need a spine."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "vgorget"
	armor_type = /datum/armor/blackbag
	max_integrity = ARMOR_INT_SIDE_ANTAG
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/gorget/ancient/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.
