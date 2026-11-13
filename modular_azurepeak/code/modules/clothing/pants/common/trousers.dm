/obj/item/clothing/pants/splintlegs
	name = "splinted leggings"
	desc = "A pair of leather pants backed with iron splints, offering superior protection while remaining lightweight."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "ironsplintlegs"
	item_state = "ironsplintlegs"
	max_integrity = ARMOR_INT_LEG_IRON_CHAIN
	armor_type = /datum/armor/brigandine
	blocksound = SOFTHIT
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/iron
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	armor_class = AC_LIGHT
	w_class = WEIGHT_CLASS_NORMAL
	sewrepair = FALSE
	ported_clothing = TRUE

/obj/item/clothing/pants/chainlegs/hose/dyeable
	name = "steel chain hosen with coverings"
	desc = "A set of maille-armored leggings, composed from interlinked steel rings and lightly padded for comfort. Worn in conjunction with one's shortclothes to cover the lower body, the maille socks pair nicely with custom-fitted sabatons. For a more personalized look, a second pair of cloth hosen has been secured to cover the maille."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "upchainhose"
	item_state = "upchainhose"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	color = null
	detail_color = CLOTHING_WHITE
	altdetail_color = CLOTHING_WHITE
	dyeable = TRUE

/obj/item/clothing/pants/chainlegs/iron/hose/dyeable
	name = "iron chain hosen with coverings"
	desc = "A set of maille-armored leggings, composed from interlinked iron rings and lightly padded for comfort. Worn in conjunction with one's shortclothes to cover the lower body, the maille socks pair nicely with lighter boots. For a more personalized look, a second pair of cloth hosen has been secured to cover the maille."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "iupchainhose"
	item_state = "iupchainhose"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	color = null
	detail_color = CLOTHING_WHITE
	altdetail_color = CLOTHING_WHITE
	dyeable = TRUE

/obj/item/clothing/pants/tights/explorerpants
	name = "explorer's pants"
	desc = "Practical and modest, you hope that it will survive the next cavedive."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "explorerpants"
	item_state = "explorerpants"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/tights/hose
	name = "cloth hosen"
	desc = "A pair of cloth leggings, traditionally worn in conjunction with one's shortclothes. These can be combined with maille hosen for the perfect blend of function-and-fashion; just pray no one has the mind to aim below the belt."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "hose"
	item_state = "hose"
	body_parts_covered = LEGS|FEET
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	flags_inv = null
	color = null
	detail_color = CLOTHING_WHITE
	altdetail_color = CLOTHING_WHITE
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/pants/tights/puritan
	name = "formal breeches"
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "monkpants"
	item_state = "monkpants"
	color = CLOTHING_BLACK
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/pants/heavy_leather_pants
	name = "hardened leather trousers"
	desc = "Thick hide cut and sewn into a pair of very protective trousers. The dense leather can turn away errant chops."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "roguepants"
	item_state = "roguepants"
	gender = PLURAL
	sewrepair = TRUE
	armor_type = /datum/armor/ported/leather
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_LEG_HARDLEATHER
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	resistance_flags = FIRE_PROOF
	armor_class = AC_LIGHT
	salvage_result = /obj/item/natural/hide/cured
	ported_clothing = TRUE

/obj/item/clothing/pants/heavy_leather_pants/shorts
	name = "hardened leather shorts"
	desc = "A thick hide pair of shorts, favored by some for their ease of motion in spite of being less protective than full trousers."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "rogueshorts"
	item_state = "rogueshorts"
	body_parts_covered = GROIN
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/trou/shadowpants/spymaster
	name = "hand's tights"
	desc = "Tailored from fine, unreflective silk that clings close to the form."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "handpants"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	allowed_race = SPECIES_BASE_BODY
