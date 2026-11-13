/obj/item/clothing/head/duelhat/donator_brimmedhat
	name = "brimmed hat"
	desc = "A well-made hat, trimmed with gold and silver, plumed with a rare feather. Rumored to be copied across the world by a merchant selling its likeness and using the wearer's name. Much to the original wearer's chagrin."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "rezahat"
	color = CLOTHING_BLACK
	detail_tag = "_detail"
	detail_color = COLOR_SILVER
	altdetail_tag = "_detailalt"
	altdetail_color = CLOTHING_PURPLE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/studded/retinue
	name = "guard studded hood"
	desc = "A padded hood splinted across creating a cocooon for whoever wears it - won't protect your face however. This one bears the heraldry of the local lord."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "studhood"
	item_state = "studhood"
	detail_tag = "_detail"
	color = CLOTHING_AZURE
	detail_color = CLOTHING_WHITE
	dyeable = TRUE
	uses_lord_coloring = LORD_SECONDARY|LORD_DETAIL_AND_COLOR
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/chaperon/noble/bailiff
	name = "Marshal's chaperon"
	desc = "A noble's chaperon made for the local Marshal. \"How terribly unfortunate you are!\""
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "noblechaperon"
	item_state = "noblechaperon"
	color = "#641E16"
	detail_color = "#b68e37ff"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/leather/inqhat/lamplighter/warden
	name = "lampwarden's hat"
	desc = "A seared and stained widebrim hat."
	icon = 'modular_azurepeak/icons/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/lamplighter.dmi'
	sleeved = null
	icon_state = "lamphat2"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/warden
	name = "warden's hood"
	desc = "A hunter's leather hood with two linen layers, sewn larger than usual to accommodate a helmet - or an animal's skull."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = null
	icon_state = "wardenhood"
	item_state = "wardenhood"
	color = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 200
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/warden/antler
	name = "warden's antlered hood"
	desc = "A hunter's leather hood with two linen layers, sewn larger than usual tooo accommodate a helmet, and fitted with the large horns of an elder saiga."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden64.dmi'
	sleeved = null
	icon_state = "wardenhoodalt"
	item_state = "wardenhoodalt"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/warden/munitioneer
	name = "forgehound's hood"
	desc = "<i><font color='ff9933'>'Beneath his gleaming mask, the fyrmanne smiles. He is a salamander upon the worlde, belching flame, cleaning away history, and leaving a new land for the lyving.'</font></i></br>A thick hood of masterwork quality, it is expertly fitted with thick-leather within the fabric to cushion the skull from blows."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = null
	icon_state = "wardenhood"
	item_state = "wardenhood"
	max_integrity = ARMOR_INT_HELMET_LEATHER
	armor_type = /datum/armor/ported/leather
	misc_flags = CRAFTING_TEST_EXCLUDE
