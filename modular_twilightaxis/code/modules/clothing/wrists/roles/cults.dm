/obj/item/clothing/wrists/bracers/leather/baotha_ta
	name = "saccharine cuffs"
	desc = "A betrayal without compare, and a sin without redemption; or so, She believed.."
	icon = 'modular_twilightaxis/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/wrists.dmi'
	icon_state = "baothabracers"
	armor_type = /datum/armor/maille
	resistance_flags = FIRE_PROOF
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/leather/baotha_ta/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/wrists/bracers/leather/baotha_ta/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)
