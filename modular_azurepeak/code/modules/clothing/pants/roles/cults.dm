/obj/item/clothing/pants/skirt/baotha
	name = "saccharine fauldcoat"
	desc = "A fauldcoat lacquered in sickly pink. The cultists of Blissara claim that their goddess was born from the first longing ever felt by a thinking mind - and that she will be the last thing any mind ever feels."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "baothaskirt"
	armor_type = /datum/armor/ported/padded
	resistance_flags = FIRE_PROOF
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	body_parts_covered = GROIN | LEGS
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/skirt/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/pants/skirt/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)
