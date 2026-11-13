/obj/item/clothing/cloak/donator_greatcoat
	name = "greatcoat"
	desc = "A product of fashionable apparel originating from the Island Nation of Sembia's Tailor Society. Popularized by renowned duelists, privateers, and the likes of Sembia all over. It now has been seen in the hands of many others across Faerun."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "greatcoat"
	item_state = "greatcoat"
	color = null
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = FALSE
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK|ITEM_SLOT_BACK_R
	flags_inv = HIDEBOOB
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	var/flipped = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/donator_greatcoat/attack_hand_secondary(mob/user, list/modifiers)
	if(!flipped)
		icon_state += "alt"
		flipped = TRUE
		flags_inv = null
	else
		icon_state = initial(icon_state)
		flipped = FALSE
	user.regenerate_icons()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/cloak/poncho/dittocloak
	name = "Sembian design cloak"
	desc = "A overly fancy and nicely designed Cloak with what appears to be Sembian silks. Looks expensive."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "dittocloak"
	item_state = "dittocloak"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	adjustable = CANT_CADJUST
	alternate_worn_layer = 9.9
	color = CLOTHING_WHITE
	detail_color = CLOTHING_WHITE
	altdetail_color = CLOTHING_WHITE
	sleevetype = "dittocloak"
	nodismemsleeves = TRUE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
