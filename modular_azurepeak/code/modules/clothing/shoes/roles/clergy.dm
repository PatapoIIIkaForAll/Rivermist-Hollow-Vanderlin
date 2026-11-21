/obj/item/clothing/shoes/boots/tabi/otavan
	name = "Aonic tabis"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "river_otavatabi"
	item_state = "river_otavatabi"
	color = null
	sewrepair = TRUE
	armor_type = /datum/armor/ported/leather
	max_integrity = ARMOR_INT_SIDE_HARDLEATHER
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/maille
	name = "maille boots"
	desc = "A pair of leather boots, reinforced with smaller steel plates along the feet and ankles. Woven into the top of each boot's cuff is a thick layer of chainmail, which further protects the wearer's lower legs from harm. A favorite amongst men-at-arms and clerics, alongside the occassional plucky squire that's a few sizes too short to properly wade in them."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "shalfplateboots"
	item_state = "shalfplateboots"
	body_parts_covered = FEET
	color = null
	max_integrity = ARMOR_INT_SIDE_STEEL
	armor_type = /datum/armor/maille
	resistance_flags = FIRE_PROOF
	blocksound = CHAINHIT
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	sewrepair = FALSE
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
