/obj/item/clothing/pants/chainlegs/iron/kilt
	name = "iron chain kilt"
	desc = "An ankle-length iron maille skirt, warding cuts against the thighs without slowing the feet."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "ichainkilt"
	item_state = "ichainkilt"
	sleevetype = "ichainkilt"
	alternate_worn_layer = (SHIRT_LAYER)
	ported_clothing = TRUE

/obj/item/clothing/pants/chainlegs/kilt/bronze
	name = "bronze chain kilt"
	desc = "An ankle-length bronze maille skirt, warding cuts against the thighs without slowing the feet."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "bchainkilt"
	item_state = "bchainkilt"
	sleevetype = "bchainkilt"
	alternate_worn_layer = (SHIRT_LAYER)
	smeltresult = /obj/item/ingot/bronze
	ported_clothing = TRUE

/obj/item/clothing/pants/heavy_leather_pants/bronzeskirt
	name = "bronze chain skirt"
	desc = "A knee-length maille skirt, made with hundreds of small bronze rings. It wards cuts against the thighs without slowing the feet."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "chain_skirt"
	item_state = "chain_skirt"
	color = "#f9d690"
	blocksound = CHAINHIT
	resistance_flags = FIRE_PROOF
	sewrepair = FALSE
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/bronze
	dyeable = TRUE

/obj/item/clothing/pants/skirt/gambeson
	name = "gambesoned kilt"
	desc = "Long, flowing, and modest; and more importantly, quilted for protection."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "patkilt"
	item_state = "patkilt"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_LEG_LEATHER
	blocksound = SOFTUNDERHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	body_parts_covered = GROIN | LEGS
	color = "#ad977d"
	ported_clothing = TRUE
	var/shifted = FALSE
	var/shiftable = TRUE

/obj/item/clothing/pants/skirt/gambeson/attack_hand_secondary(mob/user, list/modifiers)
	if(!shiftable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(shifted)
		if(alert(user, "Would you like to wear your gambesoned kilt normally? This restores the new greyscaled style.",, "Yes", "No") != "No")
			icon_state = "patkilt"
			color = "#976E6B"
			update_appearance()
			shifted = FALSE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_pants()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		if(alert(user, "Would you like to wear your gambesoned kilt traditionally? This restores the original coloration.",, "Yes", "No") != "No")
			icon_state = "patkiltold"
			color = null
			update_appearance()
			shifted = TRUE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_pants()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/pants/skirt/short
	name = "short skirt"
	desc = "short, flowing, and not very modest."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "surcoatshortskirt"
	item_state = "surcoatshortskirt"
	ported_clothing = TRUE

/obj/item/clothing/pants/skirt/gambeson/heavy
	name = "padded gambesoned kilt"
	desc = "Long, flowing, and modest; thickly padded, yet surprisingly unfettered in terms of agility."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "patkilt"
	item_state = "patkilt"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_LEG_HARDLEATHER
	color = "#976E6B"
	dyeable = TRUE

/obj/item/clothing/pants/skirt/gambeson/heavy/attack_hand_secondary(mob/user, list/modifiers)
	if(!shiftable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(shifted)
		if(alert(user, "Would you like to wear your padded gambesoned kilt normally? This restores the new greyscaled style.",, "Yes", "No") != "No")
			icon_state = "patkilt"
			color = "#976E6B"
			update_appearance()
			shifted = FALSE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_pants()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		if(alert(user, "Would you like to wear your padded gambesoned kilt traditionally? This restores the original coloration.",, "Yes", "No") != "No")
			icon_state = "patkiltold"
			color = null
			update_appearance()
			shifted = TRUE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_pants()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/pants/skirt/gambeson/light
	name = "light gambesoned kilt"
	desc = "Long, flowing, and modest; a light padding lines the undercarriage, providing milder protection and warmth."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "patkilt"
	item_state = "patkilt"
	armor_type = /datum/armor/robe/mage
	max_integrity = ARMOR_INT_LEG_LEATHER - 50
	shiftable = FALSE
	dyeable = TRUE
