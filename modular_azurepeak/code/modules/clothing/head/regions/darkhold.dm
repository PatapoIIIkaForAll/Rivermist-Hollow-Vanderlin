/obj/item/clothing/head/grenzelhofthat/triumph
	name = "Darkhold tellerbarret"
	desc = "The latest in sixteenth-century fashionwear, stitched by the finest tailors in Darkhold. </br>I can fit this onto a sallet, Sembian bascinet, or Blacksteel armet for added protection. Alternatively, I can nestle it onto my helmet's cosmetic inventory."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelhat"
	item_state = "grenzelhat"
	max_integrity = ARMOR_INT_HELMET_CLOTH
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	dynamic_hair_suffix = ""
	armor_type = /datum/armor/none
	resistance_flags = FLAMMABLE
	color = "#007fff"
	detail_color = "#FFFFFF"
	altdetail_color = "#007fff"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/grenzelhofthat/triumph/attack_hand_secondary(mob/user, list/modifiers)
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
			H.update_inv_head()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/grenzelhofthat
	name = "Darkhold plume hat"
	desc = "Whether it's monsters or fair maidens, a true Darkholdian slays both. This hat contains a hidden metallic cap underneath to protect the head from blows. </br>I can fit this onto a sallet, Sembian bascinet, or Blacksteel armet for added protection."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelhat"
	item_state = "grenzelhat"
	slot_flags = ITEM_SLOT_HEAD
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	dynamic_hair_suffix = ""
	max_integrity = ARMOR_INT_HELMET_LEATHER
	body_parts_covered = HEAD|HAIR|EARS
	armor_type = /datum/armor/ported/leather
	sewrepair = TRUE
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#262927"
	detail_color = "#FFFFFF"
	altdetail_color = "#9c2525"
	ported_clothing = TRUE

/obj/item/clothing/head/grenzelhofthat/attack_hand_secondary(mob/user, list/modifiers)
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
			H.update_inv_head()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/grenzelhofthat/loadout
	name = "aesthetic Darkhold plume hat"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelhat"
	item_state = "grenzelhat"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
