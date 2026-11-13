/obj/item/clothing/head/hooded/rainhood/feather_hood
	name = "feather hood"
	desc = "This one will shelter me from the weather and my identity too."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "feather_hood"
	item_state = "feather_hood"
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = ""
	edelay_type = 1
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDETAIL
	block2add = FOV_BEHIND
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/hooded/rainhood/tyesca
	name = "\improper Szöréndnížine banner-hood"
	desc = "Coming from the depths of a repurposed banner for use as a cloak, this hood will serve well in its heavy canvas to keep the wind and light rain from the wearer's head and face. At least, for the most part."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "fencerhood"
	item_state = "fencerhood"
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = ""
	edelay_type = 1
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDETAIL
	block2add = FOV_BEHIND
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/hooded/rainhood/wyrd_hood
	name = "Hood of the Wyrd"
	desc = "Heavy is the head that hides beneath this shadowy hood, for what knowledge lays inside ought to never come into the light..."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "wyrd_hood"
	item_state = "wyrd_hood"
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = ""
	edelay_type = 1
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDETAIL
	block2add = FOV_BEHIND
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/studded
	name = "studded hood"
	desc = "A padded hood splinted across creating a cocooon for whoever wears it - won't protect your face however."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "studhood"
	item_state = "studhood"
	body_parts_covered = NECK | HEAD | HAIR
	slot_flags = ITEM_SLOT_HEAD
	flags_inv = HIDEEARS|HIDEHAIR
	blocksound = SOFTHIT
	armor_type = /datum/armor/ported/leather
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	block2add = null
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	color = CLOTHING_BROWN
	dyeable = TRUE
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'modular_azurepeak/sound/foley/equip/cloak (3).ogg'
	ported_clothing = TRUE

/obj/item/clothing/head/roguehood/undivided
	name = "undivided hood"
	desc = "A hood of those devoted to upholding the deca-divinity in their dae to dae duties."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "undividedhood"
	item_state = "undividedhood"
	color = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	block2add = null
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/head/necromhood
	name = "necromancers hood"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "necromhood"
	item_state = "necromhood"
	color = null
	body_parts_covered = NECK
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	dynamic_hair_suffix = ""
	sewrepair = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
