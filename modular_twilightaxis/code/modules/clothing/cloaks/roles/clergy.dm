/obj/item/clothing/cloak/templar/eoran/alt
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "tabard_blue"
	item_state = "tabard_blue"
	var/eora_colors = list("Blue Tabard", "Pink Tabard")
	var/picked = FALSE
	var/eora_final_icon = null
	ported_clothing = TRUE
	layer_toggle = FALSE
	hint_pattern = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/templar/eoran/alt/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choiceC = browser_input_list(user, "Choose a color.", "Sune colors", eora_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "Blue Tabard")
			icon_state = "tabard_blue"
			item_state = "tabard_blue"
			eora_final_icon = "tabard_blue"
		if(choiceC == "Pink Tabard")
			icon_state = "tabard_pink"
			item_state = "tabard_pink"
			eora_final_icon = "tabard_pink"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
		if(alert("Are you pleased with your tabard?", "Tabard", "Yes", "No") != "Yes")
			icon_state = "tabard_blue"
			item_state = "tabard_blue"
			eora_final_icon = "tabard_blue"
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_cloak()
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/cloak/templar/eoran/alt/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(eora_final_icon)
		icon_state = eora_final_icon
		item_state = eora_final_icon
		update_appearance()

/obj/item/clothing/cloak/templar/eoran/alt/dropped(mob/user, silent = FALSE)
	. = ..()
	if(eora_final_icon)
		icon_state = eora_final_icon
		item_state = eora_final_icon
		update_appearance()
