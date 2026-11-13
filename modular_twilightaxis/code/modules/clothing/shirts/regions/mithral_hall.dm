/obj/item/clothing/shirt/twilight_hammerhold
	name = "Mithral Hall shirt"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_shirt_a"
	item_state = "white_shirt_a"
	allowed_race = SPECIES_BASE_BODY
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	var/hammerhold_colors = list("white", "black", "red")
	var/hammerhold_variants = list("a", "b", "c", "d")
	var/picked = FALSE
	var/hammerhold_final_icon = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/iconH = icon_state
		var/choiceC = browser_input_list(user, "Choose a color.", "Mithral Hall colors", hammerhold_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "white")
			iconH = "white_shirt"
			hammerhold_variants += list("e", "g")
		if(choiceC == "black")
			iconH = "black_shirt"
			hammerhold_variants += list("e", "g")
		if(choiceC == "red")
			iconH = "red_shirt"
		var/choiceV = browser_input_list(user, "Choose a variant.", "Mithral Hall variants", hammerhold_variants)
		if(!choiceV)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		iconH = iconH + "_[choiceV]"
		icon_state = iconH
		item_state = iconH
		base_icon_state = iconH
		hammerhold_final_icon = iconH
		update_appearance()
		if(alert("Are you pleased with your shirt?", "Shirt", "Yes", "No") != "Yes")
			icon_state = "white_shirt_a"
			item_state = "white_shirt_a"
			base_icon_state = "white_shirt_a"
			hammerhold_final_icon = "white_shirt_a"
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_hammerhold/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_appearance()

/obj/item/clothing/shirt/twilight_hammerhold/dropped(mob/user, silent = FALSE)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_appearance()

/obj/item/clothing/shirt/twilight_hammerhold/coat
	name = "boyar coat"
	desc = "A boyar coat inspired by elven fashion, worn by the nobility of Mithral Hall."
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "coat_a"
	item_state = "coat_a"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	hammerhold_colors = list("red", "beige")
	hammerhold_variants = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/coat/attack_hand_secondary(mob/user, list/modifiers)
	if(!picked)
		var/choiceC = browser_input_list(user, "Choose a color.", "Mithral Hall colors", hammerhold_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "beige")
			icon_state = "coat_a"
			item_state = "coat_a"
			hammerhold_final_icon = "coat_a"
		if(choiceC == "red")
			icon_state = "coat_b"
			item_state = "coat_b"
			hammerhold_final_icon = "coat_b"
		update_appearance()
		if(alert("Are you pleased with your coat?", "Coat", "Yes", "No") != "Yes")
			icon_state = "coat_a"
			item_state = "coat_a"
			hammerhold_final_icon = "coat_a"
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_inv_armor()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_hammerhold/dress
	name = "Mithral Hall dress"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_dress_a"
	item_state = "white_dress_a"
	allowed_race = SPECIES_BASE_BODY
	allowed_sex = list(FEMALE)
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|GROIN|VITALS
	hammerhold_colors = list("white", "black", "blue", "red")
	hammerhold_variants = list("a", "b")
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/dress/attack_hand_secondary(mob/user, list/modifiers)
	if(!picked)
		var/iconH = icon_state
		var/choiceC = browser_input_list(user, "Choose a color.", "Mithral Hall colors", hammerhold_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "white")
			iconH = "white_dress"
			hammerhold_variants += list("c")
		if(choiceC == "black")
			iconH = "black_dress"
			hammerhold_variants += list("c")
		if(choiceC == "blue")
			iconH = "blue_dress"
		if(choiceC == "red")
			iconH = "red_dress"
		var/choiceV = browser_input_list(user, "Choose a variant.", "Mithral Hall variants", hammerhold_variants)
		if(!choiceV)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		iconH = iconH + "_[choiceV]"
		icon_state = iconH
		item_state = iconH
		hammerhold_final_icon = iconH
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
		if(alert("Are you pleased with your dress?", "Dress", "Yes", "No") != "Yes")
			icon_state = "white_dress_a"
			item_state = "white_dress_a"
			hammerhold_final_icon = "white_dress_a"
			update_appearance()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_shirt()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_hammerhold/dress/furcoat
	name = "Mithral Hall mage coat"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_mage_coat"
	item_state = "white_mage_coat"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	hammerhold_colors = list("white", "blue")
	hammerhold_variants = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/dress/furcoat/attack_hand_secondary(mob/user, list/modifiers)
	if(!picked)
		var/choiceC = browser_input_list(user, "Choose a color.", "Mithral Hall colors", hammerhold_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "white")
			icon_state = "white_mage_coat"
			item_state = "white_mage_coat"
			hammerhold_final_icon = "white_mage_coat"
		if(choiceC == "blue")
			icon_state = "blue_mage_coat"
			item_state = "blue_mage_coat"
			hammerhold_final_icon = "blue_mage_coat"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
		if(alert("Are you pleased with your furcoat?", "Furcoat", "Yes", "No") != "Yes")
			icon_state = "white_mage_coat"
			item_state = "white_mage_coat"
			hammerhold_final_icon = "white_mage_coat"
			update_appearance()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_shirt()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_hammerhold/dress/robe
	name = "Mithral Hall robe"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_mage_robe"
	item_state = "white_mage_robe"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	hammerhold_colors = list("white", "blue")
	hammerhold_variants = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/dress/robe/attack_hand_secondary(mob/user, list/modifiers)
	if(!picked)
		var/choiceC = browser_input_list(user, "Choose a color.", "Mithral Hall colors", hammerhold_colors)
		if(!choiceC)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(choiceC == "white")
			icon_state = "white_mage_robe"
			item_state = "white_mage_robe"
			hammerhold_final_icon = "white_mage_robe"
		if(choiceC == "blue")
			icon_state = "blue_mage_robe"
			item_state = "blue_mage_robe"
			hammerhold_final_icon = "blue_mage_robe"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_inv_armor()
		if(alert("Are you pleased with your furcoat?", "Furcoat", "Yes", "No") != "Yes")
			icon_state = "white_mage_robe"
			item_state = "white_mage_robe"
			hammerhold_final_icon = "white_mage_robe"
			update_appearance()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_shirt()
				H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/shirt/twilight_hammerhold/dress/furcoat/heavy
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_mage_coat"
	item_state = "white_mage_coat"
	body_parts_covered = COVERAGE_ALL_BUT_ARMS
	armor_type = /datum/armor/ported/leather
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = TRUE
	sellprice = 25
	slot_flags = ITEM_SLOT_ARMOR
	salvage_result = /obj/item/natural/hide/cured
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/dress/robe/heavy
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_mage_robe"
	item_state = "white_mage_robe"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	armor_class = AC_LIGHT
	sellprice = 25
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/twilight_hammerhold/dress/robe/light
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "white_mage_robe"
	item_state = "white_mage_robe"
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	armor_type = /datum/armor/ported/padded
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
