/obj/item/clothing/armor/rare/elfplate/welfplate/light
	name = "woad elven maille"
	desc = "An assembly of woven trunk, bound together by ancient song and tool of the oldest elven druids. It still creaks and weeps with forlorn reminiscence of a bygone era. It looks like only Elves can fit in it."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "welfchestalt"
	item_state = "welfchestalt"
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	body_parts_covered = CHEST | VITALS | LEGS
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/dwarven
	name = "grudgebearer dwarven plate"
	desc = "A sturdy set of dwarven plate armor, forged in the old ways. It cannot be worked on without intrinsic dwarven knowledge."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "dwarfchest"
	item_state = "dwarfchest"
	allowed_race = list(SPEC_ID_DWARF)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/dwarven/smith
	name = "grudgebearer splint apron"
	desc = "A mixture of plate and maille, worn by dwarven smiths. It cannot be worked on without intrinsic dwarven knowledge."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "dsmithchest"
	item_state = "dsmithchest"
	armor_class = AC_MEDIUM
	body_parts_covered = CHEST|GROIN|VITALS|LEGS
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	misc_flags = CRAFTING_TEST_EXCLUDE
