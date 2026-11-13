/obj/item/clothing/armor/longcoat
	name = "longcoat"
	desc = "A padded longcoat meant to keep you warm in the frigid winters."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "longcoat"
	color = CLOTHING_BLACK
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	allowed_sex = list(MALE, FEMALE)
	grid_width = 64
	grid_height = 64
	ported_clothing = TRUE

/obj/item/clothing/armor/workervest
	name = "striped tunic"
	desc = "This cheap tunic is often used by sturdy laborous men and women."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = null
	icon_state = "workervest"
	armor_type = /datum/armor/none
	blocksound = SOFTHIT
	body_parts_covered = COVERAGE_VEST
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	sleevetype = null
	nodismemsleeves = TRUE
	boobed = TRUE
	grid_height = 64
	grid_width = 64
	ported_clothing = TRUE

/obj/item/clothing/armor/workervest/Initialize(mapload)
	color = pick("#94b4b6", "#ba8f9e", "#bd978c", "#92bd8c", "#c7c981")
	. = ..()

/obj/item/clothing/armor/longcoat/brown
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "longcoat"
	color = "#997C4F"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
