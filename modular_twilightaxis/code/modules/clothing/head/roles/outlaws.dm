/obj/item/clothing/head/hscarf
	name = "head scarf"
	desc = "A silk headscarf, most often seen on the head of a sailor - or a pirate!"
	icon = 'modular_twilightaxis/icons/clothing/kazengun_n_burger.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/kazengun_n_burger.dmi'
	sleeved = null
	icon_state = "headscarf"
	item_state = "headscarf"
	salvage_result = /obj/item/natural/silk
	ported_clothing = TRUE

/obj/item/clothing/head/duelhat/pretzel/skelet
	name = "old rebel's hat"
	desc = "An old felt hat chewed up by time. It suits some rebel against this society perfectly - one who has left nothing behind but a heap of bones."
	icon = 'modular_twilightaxis/icons/clothing/donor_clothes_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/donor_clothes_2.dmi'
	sleeved = null
	icon_state = "pretzel_stolenhat"
	item_state = "pretzel_stolenhat"
	max_integrity = 100
	armor_type = /datum/armor/ported/leather
	body_parts_covered = HEAD|HAIR|EARS
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
