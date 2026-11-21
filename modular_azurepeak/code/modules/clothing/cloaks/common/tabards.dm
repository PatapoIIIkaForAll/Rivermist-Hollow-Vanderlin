/obj/item/clothing/cloak/stabard/donator_shoulderguard
	name = "ecranche"
	desc = "An alloyed shoulderguard, strapped to the shoulder. While traditionally fielded in tournaments to serve as protective targets for jousts on saigaback, it isn't uncommon to see them fielded in battle as well - though the effectiveness is dubious, at best."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "shoulderguard"
	item_state = "shoulderguard"
	color = null
	body_parts_covered = CHEST
	slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_CLOAK
	grid_width = 32
	grid_height = 32
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/sash
	name = "sash"
	desc = "A large sash that can be draped across one's torso."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "sash"
	item_state = "sash"
	boobed = FALSE
	slot_flags = ITEM_SLOT_CLOAK|ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L|ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	ported_clothing = TRUE

/obj/item/clothing/cloak/sleevedtabard
	name = "sleeved tabard"
	desc = "A tabard with a light sleeve and pauldron sewn on, it lacks the explicit detailing of other tabards in exchange."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_cloaks.dmi'
	icon_state = "halfsurcoat"
	item_state = "halfsurcoat"
	color = null
	boobed = TRUE
	sleevetype = "shirt"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/surcoat
	name = "jupon"
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	icon_state = "surcoat"
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	ported_clothing = TRUE

/obj/item/clothing/cloak/stabard/surcoat/short
	name = "short jupon"
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	icon_state = "surcoat_short"
	body_parts_covered = CHEST
