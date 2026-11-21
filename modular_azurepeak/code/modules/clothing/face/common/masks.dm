/obj/item/clothing/face/facemask/goldmask/triumph
	name = "ornate golden mask"
	desc = "An ornate mask of pure, glistening gold. If you have no face to call your own, then can you truly call yourself humen at all?"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "goldmask"
	sellprice = 77
	smeltresult = /obj/item/clothing/face/lordmask
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/goldmaskc/triumph
	name = "ornate golden mask"
	desc = "An ornate mask of pure, glistening gold. If you have no face to call your own, then can you truly call yourself humen at all?"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "goldmaskc"
	sellprice = 77
	smeltresult = /obj/item/clothing/face/lordmask
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/iamcrystalclear
	name = "porcelain mask"
	desc = "A porcelain mask with black eyes and no mouth."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "porc_mask"
	adjustable = CAN_CADJUST
	var/list/toggles = list( "porc_mask", "porc_mask_red", "porc_mask_blue" )
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/iamcrystalclear/AdjustClothes(mob/user)
	for(var/i in 1 to length(toggles))
		if(toggles[i] == icon_state)
			if(i == length(toggles))
				icon_state = toggles[1]
			else
				icon_state = toggles[i+1]
			break
	to_chat(user, span_info("My mask shifts its contours."))
	update_appearance()
	user.update_inv_head()
	user.update_inv_wear_mask()

/obj/item/clothing/face/facemask/donator
	name = "jade halfmask"
	desc = "An intimidating mandible, chiseled from jade and decorated with indeterminable alloys. It is smiling back at you with eternal malice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "elegantjademask"
	item_state = "elegantjademask"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/bronze/donator
	name = "jade halfmask"
	desc = "An intimidating mandible, chiseled from jade and decorated with indeterminable alloys. It is smiling back at you with eternal malice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "elegantjademask"
	item_state = "elegantjademask"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/donator
	name = "jade halfmask"
	desc = "An intimidating mandible, chiseled from jade and decorated with indeterminable alloys. It is smiling back at you with eternal malice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "elegantjademask"
	item_state = "elegantjademask"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/ancient/jademask/donator
	name = "jade halfmask"
	desc = "An intimidating mandible, chiseled from jade and decorated with indeterminable alloys. It is smiling back at you with eternal malice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "elegantjademask"
	item_state = "elegantjademask"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/duelmask
	name = "duelist's mask"
	desc = "A black cloth mask for those masked duelists, doesn't grant any protection, but covers your eyes, and your identity... somehow."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "duelmask"
	flags_inv = HIDEFACE
	body_parts_covered = EYES
	slot_flags = ITEM_SLOT_MASK
	color = COLOR_ALMOST_BLACK
	detail_tag = "_detail"
	detail_color = COLOR_SILVER
	sewrepair = TRUE
	grid_width = 32
	grid_height = 32
	ported_clothing = TRUE

/obj/item/clothing/face/ragmask
	name = "rag mask"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "ragmask"
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HIP
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	experimental_onhip = TRUE
	sewrepair = TRUE
	grid_width = 32
	grid_height = 32
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/bronze
	name = "bronze mask"
	desc = "Glimmering bronze, curved to veil its wearer's face from both judgement and harm."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "bronzemask"
	item_state = "bronzemask"
	armor_type = /datum/armor/ported/bronze
	armor_class = AC_LIGHT
	max_integrity = 150
	smeltresult = /obj/item/ingot/bronze
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/goldmaskc
	name = "gold mask"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "goldmaskc"
	max_integrity = 150
	smeltresult = /obj/item/ingot/gold
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/leather
	name = "padded leather mask"
	desc = "A padded leather mask with a visor, it will prevent bad smells and some damage."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "leathermask"
	blocksound = SOFTHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	max_integrity = 180
	armor_type = /datum/armor/ported/leather
	adjustable = CAN_CADJUST
	sewrepair = TRUE
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/maille
	name = "iron chainmaille mask"
	desc = "A padded chainmaille mask that will protect against some damage and can be rolled down to show your identity."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "imaillemask"
	blocksound = CHAINHIT
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	max_integrity = 150
	armor_type = /datum/armor/maille
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'modular_azurepeak/sound/foley/equip/chain_equip.ogg'
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/padded
	name = "padded mask"
	desc = "A padded cloth mask with a visor, it will prevent bad smells more than damage."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "gambesonmask"
	blocksound = SOFTHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	max_integrity = 150
	armor_type = /datum/armor/ported/padded
	adjustable = CAN_CADJUST
	sewrepair = TRUE
	salvage_result = /obj/item/natural/fibers
	salvage_amount = 1
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/foley/equip/rummaging-03.ogg'
	ported_clothing = TRUE

/obj/item/clothing/face/xylixmask/ceramic
	name = "ceramic mask"
	desc = "An ivory ceramic mask, plain and vacant. What is a joke with a smile missing? Ever so drought of what used to be painted with colors and joy."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "ceramicmask"
	item_state = "ceramicmask"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/bronze/anthro
	name = "bronze mask"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "bronzemask_snout"
	item_state = "bronzemask_snout"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/bronze/classic
	name = "bronze death mask"
	desc = "Glimmering bronze, meticuliusly shaped to mimic the guise of another. One of civilization's oldest superstitions is the belief that donning such masks would impart a sliver of the mimicked facebearer's power unto its wearer."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "bronzemask_legacy"
	item_state = "bronzemask_legacy"

/obj/item/clothing/face/facemask/steel/ancient/coralmask
	name = "heartstone mask"
	desc = "An heartstone mask that both conceals and protects the face. It mimics the guise of a laughing spirit."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_coral"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/steel/ancient/jademask
	name = "jade mask"
	desc = "A jade mask that both conceals and protects the face. It mimics the guise of a jubilant shaman."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_jade"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/steel/ancient/onyxamask
	name = "onyxa mask"
	desc = "An onyxa mask that both conceals and protects the face. It mimics the guise of a bulbous alchemist."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_onyxa"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/steel/ancient/opalmask
	name = "opal mask"
	desc = "An opal mask that both conceals and protects the face. It mimics the guise of a jubilant shaman."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_opal"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/steel/ancient/shellmask
	name = "shell mask"
	desc = "A shell mask that both conceals and protects the face. It mimics the guise of a stoic wanderer."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_shell"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/steel/ancient/turqmask
	name = "cerulite mask"
	desc = "A cerulite mask that both conceals and protects the face. It mimics the guise of a ferocious lion."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_turq"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/maille/fluted
	name = "iron fluted chainmaille mask"
	desc = "A padded chainmaille mask that will protect against some damage and can be rolled down to show your identity. The fluted design is meant to deflect blows and increase durability."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "iflutedmask"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'modular_azurepeak/sound/foley/equip/chain_equip.ogg'

/obj/item/clothing/face/facemask/steel/maille
	name = "steel chainmaille mask"
	desc = "A padded chainmaille mask that will protect against some damage and can be rolled down to show your identity."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "smaillemask"
	blocksound = CHAINHIT
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	max_integrity = 250
	armor_type = /datum/armor/maille
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'modular_azurepeak/sound/foley/equip/chain_equip.ogg'
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/bronze/classic/anthro
	name = "bronze death mask"
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "bronzemask_legacy_snout"
	item_state = "bronzemask_legacy_snout"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/maille/fluted
	name = "steel fluted chainmaille mask"
	desc = "A padded chainmaille mask that will protect against some damage and can be rolled down to show your identity. The fluted design is meant to deflect blows and increase durability."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "sflutedmask"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'modular_azurepeak/sound/foley/equip/chain_equip.ogg'
	misc_flags = CRAFTING_TEST_EXCLUDE
