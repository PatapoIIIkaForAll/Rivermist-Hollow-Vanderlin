/obj/item/clothing/shoes/boots/leather/reinforced/kazengun
	name = "armored sandals"
	desc = "Leather sandals, with steel ankle-protectors and socks of sturdy cloth."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "kazengunboots"
	item_state = "kazengunboots"
	detail_tag = "_detail"
	color = "#FFFFFF"
	detail_color = "#FFFFFF"
	var/picked = FALSE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/leather/reinforced/kazengun/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Uniform colors", GLOB.ported_color_map)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		var/playerchoice = GLOB.ported_color_map[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_armor()
			H.update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
