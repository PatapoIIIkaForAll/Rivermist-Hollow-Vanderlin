/obj/item/clothing/wrists/bracers/ancient/chain_ap
	name = "ancient chain sleeves"
	desc = "Coverings of polished gilbranze-maille, fashioned from hundreds of interlinked rings. An aura of undying harlotry eminates from these sleeves. </br>I can adjust these sleeves to hang further down, rather than simply hugging my wrists."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "ancientchainsleevesalt"
	item_state = "ancientchainsleevesalt"
	blocksound = CHAINHIT
	armor_type = /datum/armor/maille
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	var/wrapped = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/chain_ap/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!wrapped)
		icon_state = "ancientchainsleeves"
		item_state = "ancientchainsleeves"
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = TRUE
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = FALSE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
