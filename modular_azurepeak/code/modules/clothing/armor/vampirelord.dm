/obj/item/clothing/armor/chainmail/iron/vampire
	name = "regal maille"
	desc = "An ornate aketon, woven from crimson silk and worn beneath a layer of enchanted gilbranze maille. Orcus and Shar had both failed in their pursuits - yet, the ancient truths they left behind were more valuable than lyfe itself. It's time to show them all how a Lord truly gets it done."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "vunder"
	item_state = "vunder"
	body_parts_covered = COVERAGE_TORSO
	armor_class = AC_HEAVY
	armor_type = /datum/armor/blackbag
	max_integrity = ARMOR_INT_CHEST_PLATE_ANTAG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/iron/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.

/obj/item/clothing/armor/chainmail/hauberk/ancient/vampire
	name = "ancient ceremonial vestments"
	desc = "An ornate aketon, woven from crimson silk and worn beneath a layer of enchanted gilbranze maille. Orcus, and Shar had both failed in their pursuits - yet, the ancient truths they left behind were more valuable than lyfe itself. It's time to show them all how a Lord truly gets it done."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "vhauberk"
	item_state = "vhauberk"
	armor_class = AC_HEAVY
	armor_type = /datum/armor/blackbag
	max_integrity = ARMOR_INT_CHEST_PLATE_ANTAG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/ancient/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.
