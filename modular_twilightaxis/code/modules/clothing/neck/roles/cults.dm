/obj/item/clothing/neck/psycross/inhumen
	mob_overlay_icon = null
	sleeved = null
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/neck/psycross/inhumen

/obj/item/clothing/neck/psycross/inhumen/matthios/moneta
	name = "pierced coin amulet"
	desc = "A simple luck charm - a zenny, pierced by a blade and hanging on a thin iron chain. A tiny inscription upon the amulet's edge reads: «All tyrants will die alone.»"
	icon = 'modular_twilightaxis/icons/clothing/neck.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "matthios"
	item_state = "matthios"
	wrist_mob_icon = 'modular_twilightaxis/icons/clothing/onmob/wrists.dmi'
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/psycross/inhumen/matthios/moneta/examine(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.patron, /datum/patron/faerun/evil_gods/Mask))
			desc = "A recognizible charm of Mask' own - a coin shattered, a symbol the pure rejection of wealth by those who would be oppressed with it. The amulet contains no power of its own, yet as you hold it in the palm of your hand, you can feel the promise of freedom empowering you. A tiny inscription upon the amulet's edge reads: «All tyrants will die alone.»"
		else
			desc = "A simple luck charm - a zenny, pierced by a blade and hanging on a thin iron chain. A tiny inscription upon the amulet's edge reads: «All tyrants will die alone.»"
	. = ..()
