/obj/item/clothing/pants/brayette
	name = "brayette"
	desc = "Maille groin protection ideal for answering Silvanus's call without removing your plate armor."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "chain_bootyshorts"
	item_state = "chain_bootyshorts"
	gender = PLURAL
	sewrepair = FALSE
	armor_type = /datum/armor/maille
	body_parts_covered = GROIN
	blocksound = CHAINHIT
	max_integrity = ARMOR_INT_LEG_STEEL_CHAIN
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/steel
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	resistance_flags = FIRE_PROOF
	armor_class = AC_LIGHT
	ported_clothing = TRUE

/obj/item/clothing/pants/trou/leather/pontifex
	name = "pontifex's chaqchur"
	desc = "A handmade pair of baggy, thin leather pants. They end in a tight stocking around the calf, ballooning out around the thigh."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "monkpants"
	item_state = "monkpants"
	salvage_result = /obj/item/natural/hide/cured
	ported_clothing = TRUE

/obj/item/clothing/pants/trou/leather/pontifex/loadout
	name = "aesthetic pontifex's chaqchur"
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "monkpants"
	item_state = "monkpants"
	misc_flags = CRAFTING_TEST_EXCLUDE
