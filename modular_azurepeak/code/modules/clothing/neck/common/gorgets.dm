/obj/item/clothing/neck/bevor/aasimar
	name = "aasimari gorget"
	desc = "Chiseled lips of polished gilbranze, forever curled to mimic an expression you can't quite parse."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "chiv_abevor"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/neck/leather
	name = "hardened leather gorget"
	desc = "Sturdy. Durable. Will protect your neck from some good lumbering."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "lgorget"
	slot_flags = ITEM_SLOT_NECK
	blocksound = SOFTHIT
	body_parts_covered = NECK
	armor_type = /datum/armor/ported/leather
	sewrepair = TRUE
	max_integrity = ARMOR_INT_SIDE_HARDLEATHER + 50
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/neck/chaincoif/full
	name = "full chain coif"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "fchaincoif"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	resistance_flags = FIRE_PROOF
	body_parts_covered = NECK|MOUTH|NOSE|HAIR|EARS|HEAD
	adjustable = CAN_CADJUST
	ported_clothing = TRUE
	var/body_parts_covered_dynamic = 0

/obj/item/clothing/neck/chaincoif/full/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "chaincoif"
			flags_inv = HIDEEARS|HIDEHAIR
			body_parts_covered = NECK|HAIR|EARS|HEAD
			body_parts_covered_dynamic = body_parts_covered
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED)
			adjustable = 3
			if(toggle_icon_state)
				icon_state = "chaincoif_t"
			flags_inv = null
			body_parts_covered = NECK
			body_parts_covered_dynamic = body_parts_covered
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == 3)
			ResetAdjust(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_neck()
			H.update_inv_head()

/obj/item/clothing/neck/coif/heavypadding
	name = "heavy padded coif"
	desc = "A padded gambeson's coif, bearing the distinct dorpel-styled stitchwork of its larger cousin. When layered properly, it can last through even the busiest of daes."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "fullpadded"
	item_state = "fullpadded"
	color = "#976E6B"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HEAD
	blocksound = SOFTHIT
	body_parts_covered = NECK|MOUTH|NOSE|HAIR|EARS|HEAD
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	armor_type = /datum/armor/ported/padded
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	sewrepair = TRUE
	ported_clothing = TRUE
	var/body_parts_covered_dynamic = 0

/obj/item/clothing/neck/coif/heavypadding/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "fullpadded_down"
			flags_inv = HIDEEARS|HIDEHAIR
			body_parts_covered = NECK|HAIR|EARS|HEAD
			body_parts_covered_dynamic = body_parts_covered
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED)
			adjustable = 3
			if(toggle_icon_state)
				icon_state = "fullpadded_neck"
			flags_inv = null
			body_parts_covered = NECK
			body_parts_covered_dynamic = body_parts_covered
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == 3)
			ResetAdjust(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_neck()
			H.update_inv_head()

/obj/item/clothing/neck/coif/padded
	name = "padded coif"
	desc = "A gambeson's coif, hewn from cloth. It can either be worn beneath a helmet to cushion one's skull from punishment, or worn on its own to keep one's cheeks warm in more frigid climates."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "ccoif"
	item_state = "ccoif"
	color = "#ad977d"
	flags_inv = HIDEEARS|HIDEHAIR
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HEAD
	blocksound = SOFTHIT
	body_parts_covered = NECK|HAIR|EARS|HEAD
	armor_type = /datum/armor/ported/padded
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	sewrepair = TRUE
	ported_clothing = TRUE

/obj/item/clothing/neck/gorget/bronze
	name = "bronze neckguard"
	desc = "An interlinked veil of bronze plates, shielding the throat from terrible wounds since the dawn of tyme. Piercing blows may sunder the plate, but - as long as the alloy persists - so shall you."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "bronzegorget"
	armor_type = /datum/armor/ported/bronze
	smeltresult = /obj/item/ingot/bronze
	max_integrity = 250 + 50
	ported_clothing = TRUE

/obj/item/clothing/neck/gorget/steel
	name = "steel gorget"
	desc = "A series of steel plates designed to protect the neck, traditionally worn atop a jacket or cuirass. It bears a mammon-sized divet along its right flank; the certification of its 'proofedness' against a longbow's strike."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "sgorget"
	smeltresult = /obj/item/ingot/steel
	max_integrity = ARMOR_INT_SIDE_STEEL + 50
	ported_clothing = TRUE

/obj/item/clothing/neck/chaincoif/iron/full
	name = "full iron chain coif"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "ifullchaincoif"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	resistance_flags = FIRE_PROOF
	body_parts_covered = NECK|MOUTH|NOSE|HAIR|EARS|HEAD
	adjustable = CANT_CADJUST
	smeltresult = /obj/item/ingot/iron
	ported_clothing = TRUE
