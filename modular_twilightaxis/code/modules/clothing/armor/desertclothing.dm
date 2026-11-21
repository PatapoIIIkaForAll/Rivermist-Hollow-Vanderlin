/obj/item/clothing/armor/brigandine/agha
	name = "agha scale"
	desc = "Fine armor made of treated animal scales, denoting an esteemd career in the dunes."
	icon = 'modular_twilightaxis/icons/clothing/armor_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor_2.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "huus"
	item_state = "huus"
	blocksound = SOFTHIT
	slot_flags = ITEM_SLOT_ARMOR
	blade_dulling = DULLING_BASHCHOP
	body_parts_covered = CHEST|GROIN|LEGS|VITALS|ARMS
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	armor_class = AC_MEDIUM
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/zyb
	name = "desert coat"
	desc = "A slim-fitting sherwani, a Zakharan-styled coat meant to endure in the desert's climate."
	icon = 'modular_twilightaxis/icons/clothing/armor_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor_2.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "sherwani"
	color = "#7c6d5c"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/cataphract
	name = "cataphract armor"
	desc = "Metal scales interwoven intricately to form flexible protection!"
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "cataphract"
	slot_flags = ITEM_SLOT_ARMOR
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS)) | NECK
	equip_delay_self = 12 SECONDS
	unequip_delay_self = 12 SECONDS
	equip_delay_other = 3 SECONDS
	strip_delay = 6 SECONDS
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	armor_class = AC_HEAVY
	armor_type = /datum/armor/plate
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/janissary
	name = "janissary chainmail"
	desc = "A longer steel maille that protects the legs."
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "mamaluke"
	item_state = "mamaluke"
	slot_flags = ITEM_SLOT_ARMOR
	max_integrity = 350
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open
	name = "open vest"
	desc = "A leather vest. Not very protective when worn like this."
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	body_parts_covered = CHEST|VITALS
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/cataphract/sultan
	name = "sultan scale"
	desc = "Impenetrable scales like an ancient black dragon!"
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "cataphract"
	item_state = "halfplate"
	color = "#5e5d5d"
	armor_type = /datum/armor/ported/plate_bsteel
	max_integrity = ARMOR_INT_CHEST_PLATE_BLACKSTEEL
	smeltresult = /obj/item/ingot/blacksteel
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/blue
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	color = "#2f51b8"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/brown
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	color = "#514339"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/green
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	color = CLOTHING_GREEN
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/orange
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	color = CLOTHING_ORANGE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/purple
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	color = CLOTHING_PURPLE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/random
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/vest/open/random/Initialize()
	color = pick("#2f51b8", CLOTHING_RED, CLOTHING_ORANGE, CLOTHING_GREEN, CLOTHING_PURPLE)
	. = ..()

/obj/item/clothing/armor/leather/vest/open/red
	icon = 'modular_twilightaxis/icons/clothing/desert/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openvest"
	item_state = "vest"
	color = CLOTHING_RED
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
