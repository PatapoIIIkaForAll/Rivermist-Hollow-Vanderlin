/obj/item/clothing/pants/heavy_leather_pants/grenzelpants
	name = "Darkholdian paumpers"
	desc = "Padded pants for extra comfort and protection, adorned in vibrant colors."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelpants"
	item_state = "grenzelpants"
	detail_tag = "_detail"
	var/picked = FALSE
	armor_class = AC_LIGHT
	color = "#262927"
	detail_color = "#FFFFFF"
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	dyeable = TRUE

/obj/item/clothing/pants/heavy_leather_pants/grenzelpants/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Darkhold colors", GLOB.ported_color_map)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		var/playerchoice = GLOB.ported_color_map[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_pants()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/pants/heavy_leather_pants/grenzelpants/loadout
	name = "aesthetic Darkholdian paumpers"
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelpants"
	item_state = "grenzelpants"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
