/obj/item/clothing/pants/platelegs/aasimar
	name = "aasimari plated chausses"
	desc = "Plated chausses of polished gilbranze, unfettered by Aeon's grasp. It has been meticulously sculpted to only fit the physique of its wearer; one of Lathander's divine legionnaires."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "chiv_achaussus"
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/tights/dhoti
	name = "dhoti"
	desc = "A pair of baggy pants of Calishite origin, with a long banner-like cloth draped between the two pant legs."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "dhoti"
	item_state = "dhoti"
	detail_tag = "_detail"
	detail_color = CLOTHING_WHITE
	salvage_result = /obj/item/natural/cloth
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/pants/tights/shalwar
	name = "shalwar pants"
	desc = "A pair of cloth shalwar pants, with a baggy fit and a tapered ankle. Originating from Calishite, these pants are known for their comfort and ease of movement."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "shalwar"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_LEG_LEATHER
	blocksound = SOFTUNDERHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	body_parts_covered = GROIN|LEGS
	detail_tag = "_detail"
	detail_color = CLOTHING_WHITE
	ported_clothing = TRUE
