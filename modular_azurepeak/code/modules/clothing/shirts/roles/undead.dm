/obj/item/clothing/shirt/toga/lich
	name = "decrepit toga"
	desc = "Roughspun fabrics from beyond your lyfetime, donned by those who fight a war without reason."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "toga"
	item_state = "toga"
	color = CLOTHING_BLACK
	detail_color = "#bb9696"
	var/open_wear = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/toga/lich/attack_hand_secondary(mob/user, list/modifiers)
	switch(open_wear)
		if(FALSE)
			name = "decrepit bared toga"
			desc = "Roughspun fabrics from beyond your lyfetime, donned by those who fight a war without reason, parted to reveal what remains beneath its cloth."
			body_parts_covered = GROIN
			icon_state = "togaalt"
			item_state = "togaalt"
			open_wear = TRUE
			flags_inv = HIDECROTCH // BARE YOUR CHEST, NOT YOUR WEEN! Not urm, you have one, you're a fucking skeleton sire.
			to_chat(usr, span_warning("You pull back the roughspun fabric, baring what remains to Faerun's eyes."))
		if(TRUE)
			name = "decrepit toga"
			desc = "Roughspun fabrics from beyond your lyfetime, donned by those who fight a war without reason.."
			body_parts_covered = CHEST|GROIN
			icon_state = "toga"
			item_state = "toga"
			flags_inv = HIDECROTCH|HIDEBOOB
			open_wear = FALSE
			to_chat(usr, span_warning("You cloak yourself in the roughspun fabric, veiling what remains from Faerun's eyes."))
	update_appearance()
	if(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			H.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/toga/lich/alt
	name = "decrepit bared toga"
	desc = "Roughspun fabrics from beyond your lyfetime, donned by those who fight a war without reason, parted to reveal what remains beneath its cloth."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "togaalt"
	item_state = "togaalt"
	body_parts_covered = GROIN
	flags_inv = HIDECROTCH
	open_wear = TRUE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/undershirt/priest/lich
	name = "decrepit unholy undervestaments"
	desc = "Roughspan fabrics, silks and burlap from beyond your lyfetyme, wrapped and coiled around the waist uncomfortably tight.</br>Its adorned with inverted holy symboles in the stitchwork, a sworn unbreakable promise against the orders that bind this world to stagnation.</br></br>\u200e<font color='FF0000'>..Just looking at the fabric makes you feel like you're being watched..</font>"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "monkvestments"
	item_state = "monkvestments"
	resistance_flags = FIRE_PROOF
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (CHEST|GROIN|ARMS|VITALS)
	adj_sound = 'sound/foley/cloth_wipe (1).ogg'
	armor_type = /datum/armor/padded/bad
