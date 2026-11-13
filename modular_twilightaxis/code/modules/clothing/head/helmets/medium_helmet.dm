/obj/item/clothing/head/helmet/raneshi_jarhelmet
	name = "Calishite jar helmet"
	desc = "A jar-shaped helmet worn by the light infantry of the Calishite pashas."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/helmets.dmi'
	sleeved = null
	icon_state = "jar_helmet"
	item_state = "jar_helmet"
	adjustable = CAN_CADJUST
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES
	block2add = FOV_BEHIND
	armor_type = /datum/armor/plate
	smeltresult = /obj/item/ingot/steel
	max_integrity = ARMOR_INT_HELMET_STEEL + 20
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/raneshi_jarhelmet/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/sallet/morion
	name = "Sembian morion"
	desc = "The famous Sembian morion, which can often be seen on sailors and ordinary infantry."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "morion"
	item_state = "morion"
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_STEEL + 15
	worn_y_dimension = 30
	dyeable = TRUE
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/morion/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
		if(!choice)
			return
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detailalt"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/zizo_ap/bascinet/bloodraider
	name = "raider's helmet"
	desc = "A darksteel helmet that doesn't obstruct the wearer's vision. Fitted with a sharp horn for the most desperate situations."
	icon = 'modular_twilightaxis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/bloodraider.dmi'
	sleeved = null
	icon_state = "bloodhelmet"
	item_state = "bloodhelmet"
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_HELMET_ANTAG - 300
	flags_inv = HIDEEARS|HIDEFACE|HIDEFACIALHAIR
	var/active_item = FALSE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/zizo_ap/bascinet/bloodraider/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_HEAD))
		active_item = TRUE
		ADD_TRAIT(user, TRAIT_BITERHELM, REF(src))
		to_chat(user, span_warning("Unholy strands of darksteel worm into your flesh as the visor chitters. Her symbiotic malice tightens your jaw with predatory intent.."))
	return

/obj/item/clothing/head/helmet/heavy/zizo_ap/bascinet/bloodraider/dropped(mob/user, silent = FALSE)
	..()
	if(!active_item)
		return
	active_item = FALSE
	REMOVE_TRAIT(user, TRAIT_BITERHELM, REF(src))
	to_chat(user, span_warning("..and like that, the darksteel strands recede back into the helmet. Her oppressive grip releases your jaw, leaving a cold, hollow ache."))
