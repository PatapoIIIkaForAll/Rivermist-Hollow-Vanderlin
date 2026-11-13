/obj/item/clothing/cloak/bishop
	name = "bishop cape"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "bishop_cape"
	item_state = "bishop_cape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/storage = TRUE

/obj/item/clothing/cloak/etrcape
	name = "wanderer's cape"
	desc = "A stylish raincoat that protects you from the rain and makes you look great"
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	icon_state = "etrcape"
	item_state = "etrcape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = FALSE
	color = null
	allowed_race = SPECIES_BASE_BODY
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/twilight_scarf
	name = "scarf"
	desc = "A long piece of cloth, meant to be worn around one's neck, Keeps you warm even under colder winds."
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "scarf"
	item_state = "scarf"
	inhand_mod = TRUE
	var/elven_colors = list("blue", "black", "green", "beige", "brown", "white")
	var/picked = FALSE
	ported_clothing = TRUE
	hint_pattern = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/twilight_scarf/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Elven colors", elven_colors)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
		detail_tag = "_[choice]"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
