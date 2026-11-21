/obj/item/clothing/head/helmet/blacksteel_ap
	name = "blacksteel bucket helm"
	desc = "An antiquated greathelm of blacksteel, crested with a thick and luscious plume. How much will it take for your faith to sway - and how little will it be? Will you clasp to the atrocities of the past and believe yourself unredeemable, or will you mantle the burden of doing what is right? </br>‎ </br>It is never too late to change; for the better, and for the worse."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "bkhelm"
	item_state = "bkhelm"
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor_type = /datum/armor/ported/plate_bsteel
	block2add = FOV_BEHIND
	max_integrity = ARMOR_INT_HELMET_BLACKSTEEL
	smeltresult = /obj/item/ingot/blacksteel
	armor_class = AC_MEDIUM
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/blacksteel_ap/modern
	name = "blacksteel armet"
	desc = "A magnificent greathelm of blacksteel, bearing the handiwork of Faerun's finest blacksmiths. Beneath the visor most-assuredly lays a legendary guise; be it a commander's glare, a conquerer's sneer, or a champion's observance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "bplatehelm"
	item_state = "bplatehelm"
	adjustable = CAN_CADJUST
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/blacksteel_ap/modern/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
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
	if(istype(W, /obj/item/natural/cloth) && !altdetail_tag)
		var/choicealt = browser_input_list(user, "Choose a color.", "Orle", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/blacksteel_ap/psychains
	name = "length of Aonic chains"
	desc = "Chains fashioned from blacksteel, ritualistically worn atop helmets to testify one's unshatterable bond to Him."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "psychains"
	armor_type = /datum/armor/ported/plate_bsteel
	body_parts_covered = HAIR
	max_integrity = 50
	alternate_worn_layer = 8.9
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	armor_class = ARMOR_CLASS_NONE
	block2add = FOV_DEFAULT
	flags_cover = null
	flags_inv = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/bucket/crusader/blacksteel
	name = "blacksteel sugarloaf helmet"
	desc = "A greathelmet of blacksteel that offers excellent protection to the head, while also ensuring total coverage to its most vulnerable spots. It resembles a freshly baked loave when worn - ergo, 'sugarloaf helmet'. Blessed fool, your faith will be challenged at every crevice-and-turn; will you succumb to despair's allure, or will your virtue shine forth in Faerun's darkest hour?"
	icon = 'modular_azurepeak/icons/clothing/special/crusader.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/crusader.dmi'
	sleeved = null
	icon_state = "crusader_helmb3"
	smeltresult = /obj/item/ingot/blacksteel
	armor_type = /datum/armor/ported/plate_bsteel
	block2add = FOV_BEHIND
	max_integrity = ARMOR_INT_HELMET_BLACKSTEEL

/obj/item/clothing/head/helmet/heavy/bucket/crusader/blacksteel/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("If handed to a Tailor, this Blacksteel Sugarloaf Helmet can be used to stitch a uniquely matching surcoat.")
