/obj/item/clothing/head/helmet/heavy/citywatch
	name = "watchman's helmet"
	desc = "A heavy helmet, remarkably resistant to every kind of harm. Worn by the city Watch of Waterdeep."
	icon = 'modular_twilightaxis/icons/clothing/special/citywatch_armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/special/onmob/citywatch_armor.dmi'
	sleeved = null
	icon_state = "citywatch_helmet"
	item_state = "citywatch_helmet"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/twilight_drow
	name = "scourge barbute"
	desc = "This helmet is a reluctant concession to the reality of modern warfare. No self-respecting Dark Elf would ever wear this into battle unless absolutely necessary. Naturally, it is usually donned by Drow males."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "shadowbarbute"
	item_state = "shadowbarbute"
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/astratan/oldrw
	name = "plumed Lathander helmet"
	desc = "A helmet with a great, black plume. Order shall guide your hand. Strike sure. Strike true. For none may question your intent."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "astratahelm_plume"
	item_state = "astratahelm_plume"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/barbute/legion
	name = "Shoonite coolus"
	desc = "A time-tested helmet beloved by legionaries and praetorians for its practical protection: it covers the vulnerable places without blocking much of the view."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "legionhelmet"
	item_state = "legionhelmet"
	worn_x_dimension = 32
	worn_y_dimension = 32
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/citywatch/sheriff
	name = "sheriff's helmet"
	desc = "A heavy helmet, remarkably resistant to every kind of harm. Painted a different colour from the rest of the Watch's helmets, so the sheriff stands out."
	icon = 'modular_twilightaxis/icons/clothing/special/citywatch_armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/special/onmob/citywatch_armor.dmi'
	sleeved = null
	icon_state = "sheriff_helm"
	item_state = "sheriff_helm"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/eoran/resprite
	name = "Sunite helmet"
	desc = "A visage of beauty, this helm made in soft pink and beige reminds one of the grace of Sune."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "helmet_eora"
	item_state = "helmet_eora"
	adjustable = CANT_CADJUST
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/raneshi_hmamluk
	name = "masked mamluk helmet"
	desc = "Helmet of a heavy rider from Empire with a face-shaped visor."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/helmets.dmi'
	sleeved = null
	icon_state = "face_helmet"
	item_state = "face_helmet"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY + 20
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/knight/raneshi_hmamluk/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/cloth) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Orle", GLOB.ported_color_map)
		if(!choice)
			return
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/necrahelm/oldrw
	name = "hooded Jergal helmet"
	desc = "Grim as the faces who wear it. For their duty is sacred, as they know the one truth of this lyfe. They're to perish, just as you are."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "necrahelm_hooded"
	item_state = "necrahelm_hooded"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/ravoxhelm_ap/oldrw
	name = "plumed Tempus helmet"
	desc = "A helmet with a great, red plume. They will know, in time, that you are the true justiciar of the Vale."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ravoxhelm"
	item_state = "ravoxhelm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/twilight_drow/volf
	name = "razormaw helm"
	desc = "As if facing a Dark Elf raider was not intimidating enough by itself, this helmet, designed to resemble the head of a giant lizard hailing from the Underdark, is meant to invoke primal terror in men and creechers alike."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "shadowvolf"
	item_state = "shadowvolf"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/visored/royalknight/grenzelhoft
	name = "armet w/plume hat"
	desc = "A Darkholdian plume hat placed atop a steel armet, staying fashionable while protecting the wearer's head to a better degree. Will you endure alongside Him, as a knight of humenity, or crumble before temptation?"
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "grenzelarmet"
	item_state = "grenzelarmet"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	detail_color = "#262927"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY + 10
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/heavy/knight/raneshi_hmamluk/raneshi_vmamluk
	name = "hound masked mamluk helmet"
	desc = "Helmet of a heavy rider from Empire with a face-shaped visor."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/helmets.dmi'
	sleeved = null
	icon_state = "hound_helmet"
	item_state = "hound_helmet"

/obj/item/clothing/head/helmet/heavy/knight/skettle/grenzelhoft
	name = "slitted kettle helm w/plume hat"
	desc = "A Darkholdian plume hat placed atop a reinforced Eisenhut extended downwards to cover the face, staying fashionable while fully protecting the wearer at the cost of his field of view. Pairs well with a bevor."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "grenzelskettle"
	item_state = "grenzelskettle"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	detail_color = "#262927"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL + 10
	dyeable = TRUE
