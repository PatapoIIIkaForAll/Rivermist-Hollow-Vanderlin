/obj/item/clothing/shoes/boots/tabi
	name = "tabis"
	desc = "A pair of unique leather boots, platformed in the back and hooved along the toes. One must wonder if there's any sense to wearing such footwear, beyond the battlefield of a banquet."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "river_tabi"
	item_state = "river_tabi"
	allowed_sex = list(MALE, FEMALE)
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/footwraps
	name = "cloth footwraps"
	desc = "Thickly-woven bandages that've been wrapped around the ankles to protect from any unwanted shattered teeth from sticking in your precious legs."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "footwraps"
	gender = PLURAL
	sewrepair = TRUE
	salvage_result = /obj/item/natural/cloth
	ported_clothing = TRUE

/obj/item/clothing/shoes/footwraps/apply_components()
	. = ..()
	AddComponent(/datum/component/storage/concrete/boots)

/obj/item/clothing/shoes/rosa
	name = "ivory shoes"
	desc = "Finely crafted shoes of silk and leather."
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes1"
	ported_clothing = TRUE

/obj/item/clothing/shoes/footwraps/hleather
	name = "hardened leather footwraps"
	desc = "A cut-down pair of boots that keeps most of the cover they'd normally offer, with added comfort for those with unusual anatomy - claws, talons and the like."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "footwraps_hleather"
	salvage_result = /obj/item/natural/hide/cured
	armor_type = /datum/armor/ported/leather
	max_integrity = ARMOR_INT_SIDE_HARDLEATHER

/obj/item/clothing/shoes/footwraps/padded
	name = "padded cloth footwraps"
	desc = "Thickly-woven padded bandages wrapped about one's ankles to maintain mobility for climbing and kicking."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "footwraps"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER

/obj/item/clothing/shoes/rosa/eight
	name = "courtly shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes8"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rosa/five
	name = "sable shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rosa/four
	name = "obsidian shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes4"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rosa/six
	name = "maroon shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes6"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rosa/ten
	name = "stately shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes10"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rosa/three
	name = "silvered shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes3"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rosa/two
	name = "scarlet shoes"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosashoes2"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/sandals/toga
	name = "classical sandals"
	desc = "A fancy pair of sandals delicately woven in a style that hark back to bygone yils of antiquity."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "togasandals"
	item_state = "togasandals"
	gender = PLURAL
	salvage_amount = 1
	salvage_result = /obj/item/natural/cloth
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/sandals/toga/apply_components()
	. = ..()
	AddComponent(/datum/component/storage/concrete/boots)
