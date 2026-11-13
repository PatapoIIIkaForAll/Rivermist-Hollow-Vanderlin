/obj/item/clothing/pants/platelegs/blkknight
	name = "darkened plate chausses"
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "bklegs"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/tights/clothlegs
	name = "padded chausses"
	desc = "A pair of cloth-armored trousers, comprised of padded hoses worn atop thickly-quilted shortclothes. Originating as an answer to labors and pilgrimages through harsher terrain, it's also been mobilized as a cost-effective means of protecting militia-legs aplenty."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "paddedchausses"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_LEG_LEATHER
	blocksound = SOFTUNDERHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	body_parts_covered = GROIN|LEGS
	detail_color = CLOTHING_WHITE
	altdetail_color = CLOTHING_WHITE
	ported_clothing = TRUE
