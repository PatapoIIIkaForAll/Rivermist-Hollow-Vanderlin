/obj/item/clothing/pants/platelegs/blkknight/death
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "bklegs"
	item_state = "plate_legs"
	color = CLOTHING_BLACK
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/chainlegs/iron/hose/dyeable/necro
	name = "iron chain hosen with decrepit coverings"
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "iupchainhose"
	item_state = "iupchainhose"
	altdetail_color = CLOTHING_BLACK
	detail_color = CLOTHING_BLACK
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/platelegs/vampire
	name = "ancient ceremonial plate greaves"
	desc = "Enchanted gilbranze tassets, meticulously shingled over silk-lined chausses. Lathander tore open the dawn, and His light sundered all who had embraced your gift. They cried for your help - but you stood there, numb."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "vpants"
	item_state = "vpants"
	gender = PLURAL
	sewrepair = FALSE
	armor_type = /datum/armor/blackbag
	max_integrity = ARMOR_INT_LEG_ANTAG
	blocksound = PLATEHIT
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	resistance_flags = FIRE_PROOF | ACID_PROOF
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/platelegs/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.

/obj/item/clothing/pants/tights/puritan/vampire
	desc = "A pair of form-fitting tights, these ones have been enchanted with various magic wards to maintain their look while being protective."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "monkpants"
	item_state = "monkpants"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_LEG_LEATHER
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
