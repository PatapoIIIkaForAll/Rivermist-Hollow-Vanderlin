/obj/item/clothing/shirt/robe/nunTA
	name = "nun dress"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "nun_dress"
	item_state = "nun_dress"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	allowed_race = SPECIES_BASE_BODY
	allowed_sex = list(FEMALE)
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/eora/resprite
	name = "Sunite robe"
	desc = "Holy robes, intended for use by followers of Sune"
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "robe_blue"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/fanatic_wear = FALSE

/obj/item/clothing/shirt/robe/eora/resprite/attack_hand_secondary(mob/user, list/modifiers)
	switch(fanatic_wear)
		if(FALSE)
			name = "open Sunite robe"
			desc = "Used by more radical followers of the Sunite Church"
			body_parts_covered = null
			icon_state = "straps_blue"
			fanatic_wear = TRUE
			flags_inv = HIDEBOOB
			to_chat(usr, span_warning("Now wearing radically!"))
		if(TRUE)
			name = "Sunite robe"
			desc = "Holy robes, intended for use by followers of Sune"
			body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
			icon_state = "robe_blue"
			fanatic_wear = FALSE
			flags_inv = HIDEBOOB|HIDECROTCH
			to_chat(usr, span_warning("Now wearing normally!"))
	update_appearance()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/robe/eora/resprite/pink
	name = "Sunite robe"
	desc = "Holy robes, intended for use by followers of Sune"
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "robe_pink"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/eora/resprite/pink/attack_hand_secondary(mob/user, list/modifiers)
	switch(fanatic_wear)
		if(FALSE)
			name = "open Sunite robe"
			desc = "Used by more radical followers of the Sunite Church"
			body_parts_covered = null
			icon_state = "straps_pink"
			fanatic_wear = TRUE
			flags_inv = HIDEBOOB
			to_chat(usr, span_warning("Now wearing radically!"))
		if(TRUE)
			name = "Sunite robe"
			desc = "Holy robes, intended for use by followers of Sune"
			body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
			icon_state = "robe_pink"
			fanatic_wear = FALSE
			flags_inv = HIDEBOOB|HIDECROTCH
			to_chat(usr, span_warning("Now wearing normally!"))
	update_appearance()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
