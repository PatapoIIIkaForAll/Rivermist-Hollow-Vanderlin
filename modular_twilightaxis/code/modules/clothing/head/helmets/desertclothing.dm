/obj/item/clothing/head/helmet/janissaryhelm
	name = "janissary helmet"
	desc = "A helmet with too much style."
	icon = 'modular_twilightaxis/icons/clothing/desert/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/head.dmi'
	sleeved = null
	icon_state = "mamhelm"
	max_integrity = 320
	body_parts_covered = HEAD|HAIR|EARS
	flags_inv = HIDEEARS|HIDEHAIR
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/cataphract
	name = "cataphracts helm"
	desc = "A helmet with a menacing visage."
	icon = 'modular_twilightaxis/icons/clothing/desert/head32x48.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/head32x48.dmi'
	sleeved = null
	icon_state = "cathelm"
	item_state = "cathelm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/cataphract/sultan
	name = "sultan helm"
	desc = "Impenetrable scales like an ancient black dragon!"
	icon = 'modular_twilightaxis/icons/clothing/desert/head32x48.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/head32x48.dmi'
	sleeved = null
	icon_state = "cathelm"
	item_state = "cathelm"
	color = "#5e5d5d"
	armor_type = /datum/armor/ported/plate_bsteel
	max_integrity = ARMOR_INT_CHEST_PLATE_BLACKSTEEL
	smeltresult = /obj/item/ingot/blacksteel
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
