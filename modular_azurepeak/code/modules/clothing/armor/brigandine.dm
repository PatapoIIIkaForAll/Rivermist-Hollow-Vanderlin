/obj/item/clothing/armor/brigandine/haraate
	name = "hansimhae cuirass"
	desc = "A more common form of Kozakuran armor, consisting of several interlocking plates of blacksteel-coated steel. Much cheaper than a full set of armor, these are commonly seen on militia forces and standing armies alike."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "kazengunmedium"
	item_state = "kazengunmedium"
	boobed = FALSE
	detail_tag = "_detail"
	color = "#FFFFFF"
	detail_color = "#FFFFFF"
	var/picked = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/haraate/attack_hand_secondary(mob/user, list/modifiers)
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

/obj/item/clothing/armor/brigandine/heavy
	name = "coat of plates"
	desc = "A heavyweight coat-of-plates, adorned with a pair of steel vambraces and faulds."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "coat_of_plates"
	blocksound = PLATEHIT
	armor_class = AC_HEAVY
	max_integrity = ARMOR_INT_CHEST_PLATE_BRIGANDINE + 100
	ported_clothing = TRUE

/obj/item/clothing/armor/brigandine/pyro
	name = "darksooted brigandine coat"
	desc = "A coat-of-plates, concealed underneath layers of soot-anointed leather. It seems to be insulated against flames and acid, due to the supernatural quality of the infernal ashes."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "pyrocoat"
	item_state = "pyrocoat"
	armor_type = /datum/armor/ported/insulated_brigandine
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/heavy/iron
	name = "iron coat of plates"
	desc = "A heavyweight coat-of-plates, adorned with a pair of iron vambraces and faulds."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "icoat_of_plates"
	blocksound = PLATEHIT
	armor_class = AC_HEAVY
	max_integrity = ARMOR_INT_CHEST_PLATE_BRIGANDINE
	smeltresult = /obj/item/ingot/iron
