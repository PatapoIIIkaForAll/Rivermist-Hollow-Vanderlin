/obj/item/clothing/shoes/simpleshoes/heels
	name = "high-heeled shoes"
	desc = "Elegant shoes that're lightly elevated in the rear, providing a distinctive 'click' with each step. Allegedly, it's quite the fashion statement in Baldur's Gate's noble galas - a sentiment yet to be fully appreciated by Duskmar's own."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "heels"
	item_state = "heels"
	detail_tag = "_detail"
	color = "#FFFFFF"
	detail_color = "#FFFFFF"
	var/picked = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	heeled = TRUE

/obj/item/clothing/shoes/simpleshoes/heels/attack_hand_secondary(mob/user, list/modifiers)
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

/obj/item/clothing/shoes/simpleshoes/heels/donator_gold
	name = "high-heeled golden shoes"
	desc = "Gold-laced shoes that're lightly elevated in the rear, providing a distinctive 'click' with each step. Allegedly, it's quite the fashion statement in Baldur's Gate's noble galas - a sentiment yet to be fully appreciated by Duskmar's own."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "goldheels"
	item_state = "goldheels"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/simpleshoes/heels/donator_silver
	name = "high-heeled silver shoes"
	desc = "Silver-laced shoes that're lightly elevated in the rear, providing a distinctive 'click' with each step. Allegedly, it's quite the fashion statement in Baldur's Gate's noble galas - a sentiment yet to be fully appreciated by Duskmar's own."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "silverheels"
	item_state = "silverheels"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
