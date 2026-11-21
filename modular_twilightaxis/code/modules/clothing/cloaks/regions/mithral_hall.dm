/obj/item/clothing/cloak/twilight_cape
	name = "Mithral Hall cape"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "white_mage_neckwear"
	item_state = "white_mage_neckwear"
	inhand_mod = TRUE
	var/hammerhold_colors = list("white", "blue")
	var/picked = FALSE
	var/hammerhold_final_icon = null
	ported_clothing = TRUE
	hint_pattern = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/twilight_cape/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choiceC = browser_input_list(user, "Choose a color.", "Mithral Hall colors", hammerhold_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "white")
			icon_state = "white_mage_neckwear"
			item_state = "white_mage_neckwear"
			hammerhold_final_icon = "white_mage_neckwear"
		if(choiceC == "blue")
			icon_state = "blue_mage_neckwear"
			item_state = "blue_mage_neckwear"
			hammerhold_final_icon = "blue_mage_neckwear"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
		if(alert("Are you pleased with your cape?", "Cape", "Yes", "No") != "Yes")
			icon_state = "white_mage_neckwear"
			item_state = "white_mage_neckwear"
			hammerhold_final_icon = "white_mage_neckwear"
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_cloak()
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/cloak/twilight_cape/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_appearance()

/obj/item/clothing/cloak/twilight_cape/dropped(mob/user, silent = FALSE)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_appearance()
