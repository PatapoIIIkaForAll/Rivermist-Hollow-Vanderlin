/obj/item/clothing/shirt/dress/gen/strapless
	name = "strapless dress"
	desc = "It barely covers anything at all!"
	icon = 'modular_azurepeak/icons/clothing/dress.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/dress.dmi'
	sleeved = null
	icon_state = "strapless"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEBOOB|HIDECROTCH
	sleevetype = null
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/dress/gen/strapless/alt
	name = "strapless dress"
	desc = "It barely covers anything at all!"
	icon = 'modular_azurepeak/icons/clothing/dress.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/dress.dmi'
	sleeved = null
	icon_state = "strapless2"
	flags_inv = HIDEBOOB|HIDECROTCH
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	dyeable = TRUE

/obj/item/clothing/shirt/dress/emerald
	name = "emerald dress"
	desc = "A silky smooth emerald-green dress, only for the finest of ladies."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "laciedress"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	sleevetype = "laciedress"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/dress/funkydress
	name = "padded dress"
	desc = "A trimmed down version of a would be protective dress."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "funkydress"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	sleevetype = "funkydress"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/dress/silkdress/donator_mortosasye_deepcutdress
	name = "deep cut dress"
	desc = "A daring dress with a deep V-cut neckline, secured at the sides by sleek, fitted fabric straps. It is tailored to its owner specific measurements. It seems to have a light coat of frost."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "mortosasye_deepcutdress"
	item_state = "mortosasye_deepcutdress"
	color = null
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/dress/silkdress/donator_mortosasye_sunrisegown
	name = "sunrise gown"
	desc = "A beautiful gown that seems to shimmer with the light of a rising sun, almost abnormally radiant."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "mortosasye_sunrisegown"
	item_state = "mortosasye_sunrisegown"
	color = null
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/dress/blue
	name = "light blue dress"
	desc = "A simple light blue dress, tailored to flatter the figure."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = null
	icon_state = "bluedress"
	item_state = "bluedress"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	sleevetype = null
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	boobed = TRUE
	detail_tag = "_detail"
	color = "#ADD8E6"
	detail_color = "#996633"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/dress/green
	name = "light green dress"
	desc = "A simple light green dress, tailored to flatter the figure."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = null
	icon_state = "greendress"
	item_state = "greendress"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	sleevetype = null
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	boobed = TRUE
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	color = "#BEF686"
	detail_color = CLOTHING_WHITE
	altdetail_color = "#996633"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/dress/slit
	name = "slitted dress"
	desc = "A finely sewn dress with a slit to expose the thigh, how scandalous!"
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "slitdress"
	item_state = "slitdress"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	color = CLOTHING_BLACK
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/dress/velvetdress
	name = "velvet dress"
	desc = "A garment made with embroidered velvet, both elegant and warm. Poetry made manifest in swaying fabric."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "velvetdress"
	item_state = "velvetdress"
	ported_clothing = TRUE

/obj/item/clothing/shirt/tunic/rosa/five
	name = "sable dress"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosadress5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/tunic/rosa/four
	name = "obsidian dress"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosadress4"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/tunic/rosa/six
	name = "maroon dress"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosadress6"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/tunic/rosa/three
	name = "velvet dress"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosadress3"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/tunic/rosa/two
	name = "scarlet dress"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosadress2"
	misc_flags = CRAFTING_TEST_EXCLUDE
