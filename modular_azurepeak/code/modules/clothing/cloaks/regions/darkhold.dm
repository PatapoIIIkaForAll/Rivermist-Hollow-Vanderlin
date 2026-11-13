/obj/item/clothing/cloak/donator_rhynn
	name = "ladylike longcloak"
	desc = "Ermine trimmed, dusted with fyritus. A siege mage's mantle is <i>traditionally</i> cermeonial, but that seldom keeps the more fashion-minded from flaunting their Darkholdian silks at any given opportunity."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "rhynncloak"
	item_state = "rhynncloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	boobed = FALSE
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	allowed_sex = list(FEMALE)
	color = CLOTHING_RED
	detail_tag = "_detail"
	detail_color = CLOTHING_WHITE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/surcoat/sofiavest
	name = "Darkholdian mages vest"
	desc = "A vest often worn by those of the Darkholdian mages college."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "sofiavest"
	item_state = "sofiavest"
	sleevetype = "sofiavest"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK|ITEM_SLOT_ARMOR
	flags_inv = HIDEBOOB
	color = null
	nodismemsleeves = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/grenzelhoft
	name = "Darkhold mercenary tabard"
	desc = "A tabard bearing the colors of the Darkhold emperiate mercenary guild."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	sleeved = null
	icon_state = "stabard"
	item_state = "tabard"
	color = CLOTHING_YELLOW
	detail_color = CLOTHING_RED
	detail_tag = "_box"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/grenzelmage
	name = "Darkholdian magos mantle"
	desc = "A fashionable mantle often worn by the magi of Darkhold's war-colleges."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	sleeved = null
	icon_state = "guard_hood"
	item_state = "guard_hood"
	color = CLOTHING_WHITE
	detail_color = CLOTHING_WHITE
	detail_tag = "_spl"
	body_parts_covered = CHEST
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
