/obj/item/clothing/pants/skirt/baotha_ta
	name = "saccharine fauldcoat"
	desc = "A fauldcoat lacquered in sickly pink and steeped in a dreamlike perfume. To the faithful of Blissara, every heartbeat is merely a craving waiting to be answered."
	icon = 'modular_twilightaxis/icons/clothing/pants_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/pants_2.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "baothaskirt"
	armor_type = /datum/armor/maille
	resistance_flags = FIRE_PROOF
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	body_parts_covered = GROIN | LEGS
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/skirt/baotha_ta/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/pants/skirt/baotha_ta/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)
