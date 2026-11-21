/obj/item/clothing/head/helmet/heavy/astratan
	name = "Lathanderite helmet"
	desc = "Gilded gold and silvered metal, the bright, vibrant colors of an Lathanderite crusader radiate from this blessed helmet."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "astratanhelm"
	item_state = "astratahnelm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/astratan/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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
	if(istype(W, /obj/item/clothing/head/veiled) && !altdetail_tag)
		var/choicealt = browser_input_list(user, "Choose a color.", "Veil", GLOB.ported_color_map)
		if(!choicealt)
			return
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		altdetail_color = GLOB.ported_color_map[choicealt]
		altdetail_tag = "_detailalt"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/astratan/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Bucket helmets, Sugarloaf helmets, and their decorated variants can be uniquely decorated with a nurse's veil as well.")

/obj/item/clothing/head/helmet/heavy/eoran
	name = "Sunite helmet"
	desc = "A visage of beauty, this helm made in soft pink and beige reminds one of the grace of Sune."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "eorahelm"
	item_state = "eorahelm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/undivided
	name = "templar silver sallet"
	desc = "A silver-plated jousting helm, and symbol of hope worn by the Duskmarian Sect of The Undivided. Those who don it have sworn to lay down their lyves for the greater good, for no cost is too great to preserve Their will."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "silversallet"
	item_state = "silversallet"
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/undivided/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/heavy/undivided_alt
	name = "templar bucket helmet"
	desc = "A gold-plated bucket helm adorned with symbol of Lathander, beacon of hope worn during crusades. Sacrificial Hero, fear not your enemy; it is only the first tilt."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "crusader_bucket"
	worn_x_dimension = 64
	worn_y_dimension = 64
	smeltresult = null
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/bandana
	name = "bandana"
	desc = "A simple triangular length of fabric, typically worn tied around the head as decoration, or to constrict long hair during intensive work."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "bandana"
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD|HAIR|EARS|NOSE
	armor_type = /datum/armor/tree
	anvilrepair = null
	smeltresult = null
	sewrepair = TRUE
	blocksound = SOFTHIT
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/tricorn
	name = "tricorn"
	desc = "A triangular hat with its brim turned in on itself. Quite a new-fangled design, but one gaining popularity among sailors in particular."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "tricorn"
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD|HAIR|EARS|NOSE
	armor_type = /datum/armor/tree
	max_integrity = 100
	anvilrepair = null
	smeltresult = null
	sewrepair = TRUE
	blocksound = SOFTHIT
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/tricorn/lucky
	name = "lucky tricorn"
	desc = "A weathered tricorn that has seen many skirmishes. You'd feel lucky with this on your head."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "tricorn"
	item_state = "that"
	armor_type = /datum/armor/ported/leather
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/tricorn/skull
	desc = "It has a skull sewn onto it. A clear sign of piracy"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "tricorn_skull"
	misc_flags = CRAFTING_TEST_EXCLUDE
