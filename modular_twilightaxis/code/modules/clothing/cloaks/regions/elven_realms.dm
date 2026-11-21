/obj/item/clothing/cloak/twilight_elven
	name = "elven cloak"
	desc = "It is said that this design might predate the War in Heaven and the consequient fall of the ancient Elven Empire."
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "cape"
	item_state = "cape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = TRUE
	var/elven_colors = list("Blue Cloak", "Red Cloak", "Blue Furcloak", "Red Furcloak")
	var/picked = FALSE
	ported_clothing = TRUE
	hint_pattern = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/storage = TRUE

/obj/item/clothing/cloak/twilight_elven/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a style.", "Elven styles", elven_colors)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
		switch(choice)
			if("Blue Cloak")
				detail_tag = "_blue"
			if("Red Cloak")
				detail_tag = "_red"
			if("Blue Furcloak")
				detail_tag = "_blue_alt"
			if("Red Furcloak")
				detail_tag = "_red_alt"
			if("Blue Short Cloak")
				detail_tag = "_blue"
			if("Red Short Cloak")
				detail_tag = "_red"
			if("Blue Short Furcloak")
				detail_tag = "_blue_alt"
			if("Red Short Furcloak")
				detail_tag = "_red_alt"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/cloak/twilight_elven/short
	name = "elven shortcloak"
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "cape_short"
	item_state = "cape_short"
	elven_colors = list("Blue Short Cloak", "Red Short Cloak", "Blue Short Furcloak", "Red Short Furcloak")
	misc_flags = CRAFTING_TEST_EXCLUDE
