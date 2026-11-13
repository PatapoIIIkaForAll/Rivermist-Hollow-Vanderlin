/obj/item/clothing/cloak/apron/blacksmith/donator_thistle
	name = "underdwelling artificer's apron"
	desc = "A thick smock, impregnated with incendiary-snuffing powder and studded with skikuldic buckles. The only reason that the Town's blacksmiths haven't killed for this apron is because they're all far too large to actually wear it."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "thistleapron"
	allowed_sex = list(FEMALE)
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/apron/blacksmith
	name = "leather apron"
	desc = "A leather apron used by those who temper metals and work forges."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "leather_apron"
	item_state = "leather_apron"
	color = null
	body_parts_covered = CHEST|GROIN
	armor_type = /datum/armor/tree
	boobed = TRUE
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	ported_clothing = TRUE
