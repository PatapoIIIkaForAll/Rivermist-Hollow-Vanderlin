/obj/item/clothing/shoes/boots/leather/donator_thistle
	name = "underdwelling artificer's boots"
	desc = "Leather boots with thin skikuldic plates layered within the soles. Such makes it far easier to tread through mud, or - in more civilized locales - stand in place for three hours straight while whittling down brass-and-bronze."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "thistleboots"
	allowed_sex = list(FEMALE)
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/leather/reinforced
	name = "hardened leather boots"
	desc = "Sturdy boots stitched together from cured leather. Stylish, firm, and sport a satisfying 'squeek' with each step."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "alboots"
	item_state = "alboots"
	max_integrity = ARMOR_INT_SIDE_HARDLEATHER
	armor_type = /datum/armor/ported/leather
	color = null
	ported_clothing = TRUE

/obj/item/clothing/shoes/boots/maille/copper
	name = "copper lamellar boots"
	desc = "A pair of leather boots, reinforced with smaller copper plates along the feet and ankles. Rarely seen since the dawn of civilization, copper garbs like these were the undersung heroes of humenity's earliest daes; a story of vintage proportions, still fresh in the minds of only a few blessed Aasimarites."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "csoldierboots"
	item_state = "csoldierboots"
	max_integrity = ARMOR_INT_SIDE_LEATHER
	armor_type = /datum/armor/ported/leather
	smeltresult = /obj/item/ingot/copper

/obj/item/clothing/shoes/boots/leather/reinforced/short
	name = "dress boots"
	desc = "A pair of sturdy boots stitched together from cured leather. These are shorter than usual, made for casual wear and dueling."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "albootsb"
	item_state = "albootsb"
