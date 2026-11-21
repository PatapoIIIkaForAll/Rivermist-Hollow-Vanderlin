/obj/item/clothing/wrists/bracers/cloth/lich
	name = "decrepit padded wrappings"
	desc = "Roughspan fabrics and burlap from beyond your lyfetyme, wrapped and coiled around the wrists by those who have embraced what they've truly become."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "nocwrappings"
	item_state = "nocwrappings"
	color = "#5c5a55"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/vampire
	name = "ancient ceremonial bracers"
	desc = "Enchanted gilbranze cuffings, clasped around the wrists. They call it a 'curse', but what would they know? What would they have in five hundred years? Would the oh-so-valiant heroes truly accept death, or would they see the pointlessness in besmirching eternal lyfe?"
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "vbracers"
	armor_type = /datum/armor/blackbag
	max_integrity = ARMOR_INT_SIDE_ANTAG
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.
