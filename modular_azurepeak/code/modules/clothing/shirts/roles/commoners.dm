/obj/item/clothing/shirt/freifechter/shepherd
	name = "shepherd's shirt"
	desc = "A strong loosely worn quilted shirt that places little weight on the arms."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "fencingshirt"
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER - 30
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/undivided
	name = "undivided robe"
	desc = "Undivided, we stand - a Pantheon of Many, shepherding Faerun's flock towards providence."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = null
	icon_state = "undividedrobe"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|GROIN|LEGS|VITALS
	boobed = TRUE
	color = null
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	ported_clothing = TRUE

/obj/item/clothing/shirt/dress/tavern
	name = "tavern dress"
	desc = "A simple green dress with a corset, its skirt has slits for easy movement."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = null
	icon_state = "taverndress"
	item_state = "taverndress"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	sleevetype = null
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	boobed = TRUE
	detail_tag = "_detail"
	color = "#BEF686"
	detail_color = "#996633"
	dyeable = TRUE
	ported_clothing = TRUE
