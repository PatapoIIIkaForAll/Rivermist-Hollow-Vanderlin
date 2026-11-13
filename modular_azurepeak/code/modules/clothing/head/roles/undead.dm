/obj/item/clothing/head/roguehood/lich_sectarian
	name = "decrepit unholy hood"
	desc = "A padded and reinforced hood of roughspun fabrics, silks and worn leather from beyond your lyfetime, splinted into a cocoon that shrouds the face. It bears an inverted holy symbol upon its crest in defiance of the world.</br></br><font color='FF0000'>..Should you stare too long into it, you could almost glimpse something staring back with eternal malice..</font>"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "monkhood"
	item_state = "monkhood"
	color = CLOTHING_BLACK
	max_integrity = ARMOR_INT_HELMET_HARDLEATHER
	armor_type = /datum/armor/ported/leather
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 2
	resistance_flags = FIRE_PROOF
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/duelhat/vamp
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "duelhat"
	item_state = "that"
	color = CLOTHING_WHITE
	detail_color = CLOTHING_RED
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/witchhat/vamp
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "witch"
	item_state = "witch"
	color = CLOTHING_WHITE
	detail_color = CLOTHING_RED
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/studded/vamp
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "studhood"
	item_state = "studhood"
	color = CLOTHING_RED
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
