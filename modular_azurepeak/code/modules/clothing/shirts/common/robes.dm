/obj/item/clothing/shirt/robe/limetease
	name = "noviciate robe"
	desc = "Used by more risque followers of the arcayne"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "limedress"
	item_state = "limedress"
	body_parts_covered = null
	flags_inv = null
	sleevetype = "limedress"
	color = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/boobed_detail = TRUE

/obj/item/clothing/shirt/robe/limetease/color
	name = "noviciate robe"
	desc = "Used by more risque followers of the arcayne, this one seem to dye easily"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "limedress_color"
	item_state = "limedress_color"
	detail_tag = "_detail"
	detail_color = "#FFFFFF"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/toga/alt
	name = "bared toga"
	desc = "The ancestral predecessor to Faerun's many tabards, worn by the townsfolk, heroes, and villains of antiquity, bared open to reveal what's beneath."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "togaalt"
	item_state = "togaalt"
	flags_inv = HIDECROTCH
	body_parts_covered = GROIN
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/toga/dress
	name = "toga"
	desc = "The ancestral predecessor to Faerun's many tabards, worn by the townsfolk, heroes, and villains of antiquity."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "togadress"
	item_state = "togadress"
	boobed = TRUE
	var/open_wear = FALSE
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/toga/dress/attack_hand_secondary(mob/user, list/modifiers)
	switch(open_wear)
		if(FALSE)
			name = "bared toga"
			desc = "The ancestral predecessor to Faerun's many tabards, worn by the townsfolk, heroes, and villains of antiquity, bared open to reveal what's beneath."
			body_parts_covered = GROIN
			icon_state = "togadressalt"
			item_state = "togadressalt"
			open_wear = TRUE
			flags_inv = HIDECROTCH
			to_chat(usr, span_warning("You pull back a strap, baring what lies beneath to Faerun's eyes."))
		if(TRUE)
			name = "toga"
			desc = "The ancestral predecessor to Faerun's many tabards, worn by the townsfolk, heroes, and villains of antiquity."
			body_parts_covered = CHEST|GROIN
			icon_state = "togadress"
			item_state = "togadress"
			flags_inv = HIDECROTCH|HIDEBOOB
			open_wear = FALSE
			to_chat(usr, span_warning("You pull up your strap, veiling what lies beneath from Faerun's eyes."))
	update_appearance()
	if(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			H.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/toga/dress/alt
	name = "bared toga"
	desc = "The ancestral predecessor to Faerun's many tabards, worn by the townsfolk, heroes, and villains of antiquity, bared open to reveal what's beneath."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "togadressalt"
	item_state = "togadressalt"
	flags_inv = HIDECROTCH
	body_parts_covered = GROIN
	open_wear = TRUE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/bared
	name = "bared robe"
	desc = "A robe of basic cloth, it's chest bared open to expose what lay underneath."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "openrobe"
	item_state = "openrobe"
	color = CLOTHING_WHITE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/leopard
	name = "leopard robe"
	desc = "An exquisite silky robe with a leopard pattern."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "lpbathrobe"
	item_state = "lpbathrobe"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	var/open_wear = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/shirt/robe/leopard

/obj/item/clothing/shirt/robe/leopard/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-clicking this robe allows for it to be dynamically worn as a traditional robe, or as an open robe that partially exposes the chest.")

/obj/item/clothing/shirt/robe/leopard/MiddleClick(mob/user, list/modifiers)
	..()
	user.update_inv_shirt()

/obj/item/clothing/shirt/robe/leopard/attack_hand_secondary(mob/user, list/modifiers)
	switch(open_wear)
		if(FALSE)
			name = "bared leopard robe"
			desc = "An exquisite silky robe with a leopard pattern, untied to reveal what's beneath."
			body_parts_covered = GROIN
			icon_state = "lpbathrobe_open"
			item_state = "lpbathrobe_open"
			open_wear = TRUE
			flags_inv = HIDECROTCH
			to_chat(usr, span_warning("You pull back the threaded cloth, baring your heart to Faerun's eyes."))
		if(TRUE)
			name = "leopard robe"
			desc = "An exquisite silky robe with a leopard pattern."
			body_parts_covered = CHEST|GROIN
			icon_state = "lpbathrobe"
			item_state = "lpbathrobe"
			flags_inv = HIDECROTCH|HIDEBOOB
			open_wear = FALSE
			to_chat(usr, span_warning("You cloak yourself in the threaded cloth, veiling your heart from Faerun's eyes."))
	update_appearance()
	if(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			H.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/robe/tabardwhite
	name = "robed tabard"
	desc = "Sleeveless robes, billowing in the breeze."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "whiterobe"
	item_state = "whiterobe"
	color = null
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/leopard/alt
	name = "open leopard robe"
	desc = "An exquisite silky robe with a leopard pattern, untied to reveal what's beneath."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "lpbathrobe_open"
	item_state = "lpbathrobe_open"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	open_wear = TRUE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/magus/enchanted
	name = "ominously enchanted robes"
	desc = "An otherworldly veil, amythortz-woven and crackling with the constant ponderance of a runic enigma. Her hand guides your grandest missive; to bring forth progress, no matter the cost."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ewarlock"
	item_state = "ewarlock"
	armor_type = /datum/armor/ported/leather
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
