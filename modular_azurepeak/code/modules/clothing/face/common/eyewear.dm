/obj/item/clothing/face/blindfold_ap
	name = "blindfold"
	desc = "A strip of cloth tied around the eyes to block vision."
	icon = 'modular_azurepeak/icons/clothing/glasses.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/eyes.dmi'
	sleeved = null
	icon_state = "blindfold"
	item_state = "blindfold"
	body_parts_covered = EYES
	sewrepair = TRUE
	tint = 3
	grid_width = 32
	grid_height = 32
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/face/blindfold_ap

/obj/item/clothing/face/spectacles/bronze
	name = "bronze spectacles"
	desc = "Bronze frames holding thick glass lenses. Favored by those who would rather trust tempered metal than delicate craft."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "bgoggles"
	max_integrity = 30
	armor_type = /datum/armor/ported/spectacles
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	ported_clothing = TRUE
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'

/obj/item/clothing/face/spectacles/duelist
	name = "iron duelist goggles"
	desc = "A rigid pair of protective goggles made for fencing bouts, shielding the eyes without concealing the face."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "iduelist"
	break_sound = "garrote_snap"
	blocksound = PLATEHIT
	max_integrity = 125
	armor_type = /datum/armor/ported/spectacles
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'
	ported_clothing = TRUE

/obj/item/clothing/face/spectacles/iron
	name = "iron spectacles"
	desc = "Iron-framed spectacles built to weather rough treatment. They sit firm upon the face, no matter how heated the exchange."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "igoggles"
	max_integrity = 30
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	ported_clothing = TRUE
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'

/obj/item/clothing/face/spectacles/steel
	name = "steel spectacles"
	desc = "Steel spectacles wrought with a artificier's pragmatism. Clear sight is worth little if the frame shatters at the first strike."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "sgoggles"
	max_integrity = 40
	armor_type = /datum/armor/ported/spectacles
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	ported_clothing = TRUE
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'

/obj/item/clothing/face/spectacles/thin
	name = "thin-lensed spectacles"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "glassesa"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/spectacles/duelist/bronze
	name = "bronze duelist goggles"
	desc = "Bronze duelist goggles offering modest protection without obscuring one's features. Every victory deserves a witness."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "bduelist"
	max_integrity = 125

/obj/item/clothing/face/spectacles/duelist/steel
	name = "steel duelist goggles"
	desc = "Steel duelist goggles forged for the most punishing exchanges. They guard the eyes while leaving pride and identity uncovered."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "sduelist"
	max_integrity = 150

/obj/item/clothing/face/spectacles/fancy/dark
	name = "fancy tinted spectacles"
	desc = "Delicate, thin-lensed spectacles of foreign make, their craft finer than most local wares. This variant has a darker tint to its lenses."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "glassesb_dark"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
