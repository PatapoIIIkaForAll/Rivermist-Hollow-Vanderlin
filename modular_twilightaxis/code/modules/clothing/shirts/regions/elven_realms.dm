/obj/item/clothing/shirt/twilight_elven
	name = "elven suit"
	desc = "A common garnament for Sembian countryside, each of these suits is woven in adherence to tradition."
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "suit"
	item_state = "suit"
	allowed_race = SPECIES_BASE_BODY
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|VITALS
	var/elven_colors = list("blue", "red", "beige", "black", "green")
	var/picked = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_elven/attack_hand_secondary(mob/user, list/modifiers)
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
			H.update_inv_shirt()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_elven/coat
	name = "elven coat"
	desc = "A common garnament for Sembian countryside, each of these durable coats is woven in adherence to tradition."
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "coat"
	item_state = "coat"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	flags_inv = HIDEBOOB|HIDECROTCH
	body_parts_covered = CHEST|GROIN|ARMS|VITALS
	elven_colors = list("blue", "red", "beige", "white", "green", "gray")
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_elven/coat/attack_hand_secondary(mob/user, list/modifiers)
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
			H.update_inv_shirt()
			H.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_elven/coat/alt
	name = "elven furcoat"
	desc = "A common garnament for Sembian countryside, each of these durable coats is woven in adherence to tradition. Luxurious leovarg fur makes it fit for colder regions as well as self-entitled nobility."
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "coat_alt"
	item_state = "coat_alt"
	elven_colors = list("blue", "red", "beige", "white")
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_elven/coat/alt/attack_hand_secondary(mob/user, list/modifiers)
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
			H.update_inv_shirt()
			H.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
