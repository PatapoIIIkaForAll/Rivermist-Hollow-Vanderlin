/obj/item/clothing/head/helmet/baotha_ta
	name = "saccharine sallet"
	desc = "A sallet lacquered in sickly pink and cloying perfume. The cultists of Blissara wear such helms to remind the world that desire, not steel, is the truest conqueror."
	icon = 'modular_twilightaxis/icons/clothing/head_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head_2.dmi'
	sleeved = null
	icon_state = "baothahelm"
	item_state = "baothahelm"
	body_parts_covered = HEAD | HAIR | EARS | MOUTH | EYES
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_HELMET_ANTAG - 250
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/baotha_ta/Initialize()
	. = ..()
