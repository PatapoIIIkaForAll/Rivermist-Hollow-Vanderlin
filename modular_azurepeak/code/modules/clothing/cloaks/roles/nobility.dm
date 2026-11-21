/obj/item/clothing/cloak/donator_goldmaillekini
	name = "golden maillekini"
	desc = "A curious - and particularly revealing - variant of a common maille-aketon, fashioned from interlinked rings of pure gold. Unlike its iron- and steel-mailled cousins, this regal corset is far too fragile to double as armor; but that's not going to stop you, is it? </br> It feels light enough to be worn above-or-below most garments."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "chainking"
	item_state = "chainking"
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/donator_oathkeeper
	name = "oathkeeper's noble surcoat"
	desc = "An elegant surcoat, toned in cadence with the unofficial coat-of-arms that's used to represent Duskmar's many noble houses. One shoulder is decorated with a golden-laced sleeve, while the other supports a small ecranche. To wear such garments is to command respect from those that've come after you; hopefully, not undue."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "oa_fancy_short"
	color = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/surcoat/donator_oathkeeper
	name = "oathkeeper's noble jupon"
	desc = "An elegant jupon, toned in cadence with the unofficial coat-of-arms that's used to represent Duskmar's many noble houses. One shoulder is decorated with a golden-laced sleeve, while the other supports a small ecranche. To wear such garments is to command respect from those that've come after you; hopefully, not undue."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "oa_fancy_long"
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/bandolier
	name = "bandolier"
	desc = "A sash that's pelted with pouches, perfect for carrying plenty of pint-sized pieces. </br>'Hail to the King, baby.'"
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "bandolier"
	item_state = "bandolier"
	color = null
	resistance_flags = FIRE_PROOF
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	salvage_result = /obj/item/natural/hide/cured
	grid_width = 64
	grid_height = 96
	ported_clothing = TRUE

/obj/item/clothing/cloak/cotehardie
	name = "fitted coat"
	desc = "Also known as a cotehardie: a long-sleeved tunic worn by peasants and nobles alike. It's used by men and women, in both summer and winter. It won't drop any items inside when unequipped."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_cloaks.dmi'
	icon_state = "cotehardie"
	item_state = "cotehardie"
	color = "#586849"
	alternate_worn_layer = TABARD_LAYER
	body_parts_covered = CHEST|GROIN|ARMS
	boobed = TRUE
	slot_flags = ITEM_SLOT_CLOAK
	flags_inv = HIDECROTCH|HIDEBOOB
	detail_tag = "_detail"
	detail_color = "#36241f"
	sleevetype = "cotehardie"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/cloak/rosa
	name = "regal cloak"
	desc = "A finely crafted cloak of silk adorned with rosas."
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosacloak7"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	salvage_result = /obj/item/natural/silk
	ported_clothing = TRUE

/obj/item/clothing/cloak/stabard/guardhood
	name = "hood"
	desc = "A hood with the lord's heraldic colors."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	sleeved = null
	icon_state = "guard_hood"
	item_state = "guard_hood"
	color = CLOTHING_AZURE
	detail_tag = "_spl"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_NECK|ITEM_SLOT_MASK|ITEM_SLOT_CLOAK
	detail_color = CLOTHING_WHITE
	body_parts_covered = CHEST
	dyeable = TRUE
	uses_lord_coloring = LORD_SECONDARY|LORD_DETAIL_AND_COLOR
	ported_clothing = TRUE
	hint_pattern = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/custom_design = FALSE

/obj/item/clothing/cloak/stabard/guardhood/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(custom_design)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/the_time = world.time
	var/chosen = browser_input_list(user, "Select a design.","Tabard Design", list("Split"))
	if(!chosen)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(world.time > (the_time + 10 SECONDS))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!chosen)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	switch(chosen)
		if("Split")
			detail_tag = "_spl"
	update_appearance()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()
	if(alert(user, "Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
		detail_tag = initial(detail_tag)
		update_appearance()
		if(ismob(loc))
			var/mob/L = loc
			L.update_inv_cloak()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	custom_design = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
