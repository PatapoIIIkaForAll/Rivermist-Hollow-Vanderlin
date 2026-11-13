/obj/item/clothing/armor/vampiric
	name = "vampiric armour"
	desc = "Abstract parent. Contact developer if you see this."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = null
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	resistance_flags = FIRE_PROOF
	body_parts_covered = COVERAGE_FULL
	flags_inv = null
	surgery_cover = FALSE
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor_class = AC_LIGHT
	blocksound = SOFTUNDERHIT
	armor_type = /datum/armor/ported/padded
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/armor/vampiric

/obj/item/clothing/armor/vampiric/gnoll
	name = "gnoll skin"
	desc = "an impenetrable hide of Gruumsh's fury"
	icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "berserker"
	body_parts_covered = FULL_BODY
	sewrepair = FALSE
	item_flags = DROPDEL
	armor_type = /datum/armor/ported/gnoll_standard
	max_integrity = 475
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/vampiric/gnoll/knight
	icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "knight"
	max_integrity = 800
	armor_type = /datum/armor/ported/gnoll_strong
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/vampiric/gnoll/shaman
	icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "shaman"
	max_integrity = 400
	armor_type = /datum/armor/ported/gnoll_weak
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/vampiric/gnoll/templar
	icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gnoll.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "templar"
	max_integrity = 600
	armor_type = /datum/armor/ported/gnoll_standard
	misc_flags = CRAFTING_TEST_EXCLUDE
