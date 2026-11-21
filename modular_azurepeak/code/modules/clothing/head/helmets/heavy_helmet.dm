/obj/item/clothing/head/helmet/heavy/aventail
	name = "hounskull with aventail"
	desc = "A steel hounskull bascinet with a thick maille aventail secured to the inside. Just as a froggemund befits a knight in the tournaments, an aventailed bascinet befits a knight on the battlefield; unmatched in coverage, durability, and weight."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "visaventail"
	item_state = "visaventail"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = FULL_HEAD|NECK
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_RIGHT|FOV_LEFT
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL + ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	smeltresult = /obj/item/ingot/steel
	armor_class = AC_HEAVY
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR|MOUTH|NECK)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/aventail/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
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

/obj/item/clothing/head/helmet/heavy/barbute
	name = "barbute"
	desc = "A steel helmet that provides excellent coverage, while uniquely keeping its wearer's field-of-view almost entirely unrestricted. The cruciformic visor is an inherited design, borne from the earliest daes of Faerun. Mounted on the back is a unique couplet, fit for adopting feathered greatplumes."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "barbute"
	item_state = "barbute"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL
	block2add = null
	worn_x_dimension = 64
	worn_y_dimension = 64
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/barbute/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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
	if(istype(W, /obj/item/natural/feather) && !altdetail_tag)
		var/choicealt = browser_input_list(user, "Choose a color.", "Greatplume", GLOB.ported_color_map)
		if(!choicealt)
			return
		altdetail_color = GLOB.ported_color_map[choicealt]
		altdetail_tag = "_detailalt"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/beakhelm
	name = "beak helmet"
	desc = "An odd spherical helmet with a beaklike visor."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "beakhelmet"
	item_state = "beakhelmet"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/bronze
	name = "bronze barbute"
	desc = "A greathelm of bronze, who's nasalguard and mandibles leave the wearer's face cloaked in darkness. The heroes of yore have long since passed, yet their blood still courses through the veins of Faerun's children; you are no different. Quiff a feather to its skullcap to bear your allegience with pride."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "bronzebarbute"
	item_state = "bronzebarbute"
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor_type = /datum/armor/ported/bronze
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/bronze
	max_integrity = 450
	armor_class = AC_MEDIUM
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/bronze/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/burgonet
	name = "snouted burgonet"
	desc = "A burgonet, though this one's not in blacksteel - the visor far more suited for snouts."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "burgonet_s"
	item_state = "burgonet_s"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/dwarven
	name = "grudgebearer dwarven helm"
	desc = "A hardy dwarven helmet. It lets one's dwarvenly beard to poke out."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = null
	icon_state = "dwarfhead"
	body_parts_covered = HEAD|MOUTH|NOSE|EYES|EARS|NECK
	armor_type = /datum/armor/plate
	allowed_race = list(SPEC_ID_DWARF)
	smeltresult = /obj/item/ingot/steel
	experimental_inhand = FALSE
	experimental_onhip = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	item_state = null

/obj/item/clothing/head/helmet/heavy/frogmouth
	name = "froggemund helmet"
	desc = "A tall and imposing frogmouth-style helm popular in the highest tourneys of the Sword Mountains. It covers not only the entire head and face, but the neck as well. Add some cloth to show the colours of your family or allegiance, or a nurse's veil to ward off the chill of a winterborn tournament."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "frogmouth"
	item_state = "frogmouth"
	emote_environment = 3
	body_parts_covered = FULL_HEAD|NECK
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_RIGHT|FOV_LEFT
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL + ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/frogmouth/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/heavy/guard
	name = "steel savoyard"
	desc = "A helmet with a menacing visage."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "steelsavoyard"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/holyseebarbute
	name = "holy see barbute"
	desc = "A polished plate of sheer silver curtains the barbute's front, its mirror-like sheen reflecting all that the gods have made of Creation. \n\n'Look upon their works, ye mighty, and despair.'"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "seebascinet"
	item_state = "seebascinet"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/kabuto
	name = "kabuto"
	desc = "A Kozakuran helmet of steel plates, gilded in blacksteel and gold trim alike to evoke feelings of nobility and strength. Commonly worn with a mask or mouthguard."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "kazengunheavyhelm"
	flags_inv = HIDEEARS|HIDEHAIR
	flags_cover = null
	block2add = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight
	name = "knight's armet"
	desc = "A noble knight's greathelm, and the reigning symbol of sixteenth-century nobility. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "knight"
	item_state = "knight"
	adjustable = CAN_CADJUST
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	smeltresult = /obj/item/ingot/steel
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/ravoxhelm_ap
	name = "Tempuran eagle"
	desc = "Forged in reverence to Tempus, this helm bears the stylized visage of an eagle, symbol of the Foehammer's vigilance. Its hollow eyes see not just foes, but the worth of every warrior who faces them."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ravoxhelmet"
	item_state = "ravoxhelmet"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	hint_decorate = TRUE
	abstract_type = /obj/item/clothing/head/helmet/heavy/ravoxhelm_ap

/obj/item/clothing/head/helmet/heavy/ravoxhelm_ap/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/sheriff
	name = "barred helmet"
	desc = "A helmet which offers good protection to the face at the expense of vision."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "gatehelm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/zizo_ap
	name = "avantyne barbute"
	desc = "Crystallized inzanity, brought to a lower plane of existence and flared into an ethereal greathelm. It has been called forth from the edge of reality, in Her name."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "zizobarbute"
	adjustable = CAN_CADJUST
	max_integrity = ARMOR_INT_HELMET_ANTAG
	toggle_icon_state = TRUE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/astratahelm/cleric
	name = "Lathander plumed helmet"
	desc = "Topped with a magnificent plume, this helmet turns the wearer into a walking beacon of Lathander's wrath. Designed to cut a striking silhouette, it strikes terror into the hearts of nonbelievers from afar."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "astrataclerichelm"
	item_state = "astrataclerichelm"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/aventail/iron
	name = "iron hounskull with aventail"
	desc = "An iron hounskull bascinet with a thick maille aventail secured to the inside. Just as a froggemund befits a knight in the tournaments, an aventailed bascinet befits a knight on the battlefield; unmatched in coverage, durability, and weight."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iavenheavy"
	item_state = "iavenheavy"
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON + ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/head/helmet/visored/captain/bascinet
	name = "banneret's snouted bascinet"
	desc = "An elegant bascinet, fitted with the gold trim and polished metal of nobility. Its visor tapers into a muzzle."
	icon = 'modular_azurepeak/icons/clothing/special/captain.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/captain.dmi'
	sleeved = null
	icon_state = "capbascinet_s"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/visored/captain/sallet
	name = "banneret's snouted sallet"
	desc = "An elegant sallet, fitted with the gold trim and polished metal of nobility. Its bevor is drawn forward into a muzzle."
	icon = 'modular_azurepeak/icons/clothing/special/captain.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/captain.dmi'
	sleeved = null
	icon_state = "capsallet_s"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/heavy/barbute/great
	name = "great barbute"
	desc = "A steel greathelm of inordinate thickness, whose design seems to've been inspired by both a tournament's froggemund and a kingdom's sugarloaf. It is far from elegant, but it will thwart killing blows again-and-again without compromise. Never forget that a champion of Faerun needn't nobility nor wealth to become eternal; they need only the courage to be free. </br>'In their legends, there were no gods - only heroes.'"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "barbutedunk"
	item_state = "barbutedunk"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND

/obj/item/clothing/head/helmet/heavy/barbute/iron
	name = "iron barbute"
	desc = "An iron helmet that provides excellent coverage, while uniquely keeping its wearer's field-of-view almost entirely unrestricted. The cruciformic visor is an inherited design, borne from the earliest daes of Faerun. Mounted on the back is a unique couplet, fit for adopting feathered greatplumes."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "ibarbute"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY

/obj/item/clothing/head/helmet/heavy/barbute/visor
	name = "visored barbute"
	desc = "A steel greathelm that provides excellent coverage, and whose cruciformic guise is further reinforced by a heavy visor. Valiant paladin, wretched bulwark, thoughtless worm; it won't be long until they're almost here. Will you cry all your tears, or will you face your fears? </br>Mounted on the back is a unique couplet, fit for adopting feathered greatplumes."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "barbute_visor"
	item_state = "barbute_visor"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	adjustable = CAN_CADJUST
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/heavy/beakhelm/iron
	name = "beaked iron helmet"
	desc = "No sacrifice is too great, when one is locked into the pursuit of dreams-most-divine."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ibeakhelmet"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/bucket/crusader
	name = "sugarloaf helmet"
	desc = "A greathelmet that offers excellent protection to the head, while also ensuring total coverage to its most vulnerable spots. It resembles a freshly baked loave when worn - ergo, 'sugarloaf helmet'. Popularly seen amongst crusaders of the faith-militances, its curved top helps to disperse the crushing force of blows from above."
	icon = 'modular_azurepeak/icons/clothing/special/crusader.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/crusader.dmi'
	sleeved = null
	icon_state = "crusader_helmt2"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/bucket/iron
	name = "iron bucket helm"
	desc = "A helmet that covers your entire head, offering good protection while making breathing a difficult ordeal."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ironplate"
	item_state = "ironplate"
	emote_environment = 3
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/iron
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/dwarven/smith
	name = "grudgebearer smith helm"
	desc = "A hardy dwarven helmet. It lets one's dwarvenly beard to poke out. This one is intended for the smiths of the clan. No less protective. All the more stylish."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = null
	icon_state = "dsmithhead"
	misc_flags = CRAFTING_TEST_EXCLUDE
	item_state = null

/obj/item/clothing/head/helmet/heavy/frogmouth/greatplume
	name = "froggemund helmet with greatplume"
	desc = "A tall and imposing frogmouth-style helm popular in the highest tourneys of the Sword Mountains. It covers not only the entire head and face, but the neck as well. Mounted on the back is a larger couplet, capable of holding a feathered greatplume; a blessing for the flamboyant-hearted."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "frogmouthgreatplume"
	item_state = "frogmouthgreatplume"
	worn_x_dimension = 64
	worn_y_dimension = 64
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/frogmouth/greatplume/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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
	if(istype(W, /obj/item/natural/feather) && !altdetail_tag)
		var/choicealt = browser_input_list(user, "Choose a color.", "Greatplume", GLOB.ported_color_map)
		if(!choicealt)
			return
		altdetail_color = GLOB.ported_color_map[choicealt]
		altdetail_tag = "_detailalt"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/graggar/skull
	name = "vicious skullhelm"
	desc = "Nigh lyke a crushed skull worn with pride; as sturdy as one that has seen fractures.. and survived them, too. Godliness was never meant to be tainted with minds so fragile and passionate."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "graggarplatehelm_heavy"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/guard/iron
	name = "savoyard"
	desc = "An iron helmet with a menacing visage."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "isavoyard"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/knight/aalloy
	name = "decrepit bascinet"
	desc = "A chipped greathelm of rotted metal. The fittings squeal with nauseous annoyance, whenever you move to lift its half-rusted visor up and down. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "ancientknight"
	item_state = "ancientknight"
	max_integrity = ARMOR_INT_HELMET_HEAVY_DECREPIT
	color = "#bb9696"
	anvilrepair = null
	worn_x_dimension = 64
	worn_y_dimension = 64
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/black
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "knight"
	item_state = "knight"
	color = CLOTHING_BLACK
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/fluted
	name = "fluted armet"
	desc = "An ornate steel greathelm with a visor, which protects the entire head. While bulky, the fluted design excels at prolonging chivalrous bouts with fellow knights. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "knight"
	item_state = "knight"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/gold
	name = "golden knight's armet"
	desc = "A resplendant armet, masterfully forged from pure gold. Hexagrammic etchings of a holy sigil line its visor, and its interior is fitted with a besilked arming cap. Even in absolute darkness, the polished surface sparkles with imbued sunlight."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "goldknight"
	armor_type = /datum/armor/blackbag
	max_integrity = 5
	armor_class = AC_HEAVY
	anvilrepair = null
	smeltresult = /obj/item/ingot/gold
	grid_height = 96
	grid_width = 96
	worn_x_dimension = 64
	worn_y_dimension = 64
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/knight/gold/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Greatplume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/knight/greatplume
	name = "greatplumed armet"
	desc = "A noble steel greathelm with a visor, which protects the entire head. When one must outpeacock all the other knightly contestants at a tournament, accept no substitute. The wider couplet atop its neckguard's rear can accept a uniquely large greatplume."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "knight"
	item_state = "knight"
	worn_x_dimension = 64
	worn_y_dimension = 64
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/knight/greatplume/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Greatplume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/knight/iron
	name = "iron knight's armet"
	desc = "A noble knight's greathelm made of iron; a popular choice in the preceding centuries, before many knew the answer to the riddle of steel. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iknight"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/knight/old
	name = "knight's helmet"
	desc = "A knight's greathelm, forged from steel in the antiquated 'Waterdhavian' style. Add a feather to show the colors of your family or allegiance. </br>\u200e </br>'She waited in the dragon's keep, in the highest room of the tallest tower, for her true love, and true love's first kiss..'"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "knightclassic"

/obj/item/clothing/head/helmet/heavy/knight/paalloy
	name = "ancient bascinet"
	desc = "An ancient greathelm of polished gilbranze. There is no sight more haunting than that of a noble knight, long-succumbed to the undying forces of evylle. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "ancientknight"
	item_state = "ancientknight"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/psy
	name = "Aonic armet"
	desc = "An ornate helmet whose visor has been bound shut with blacksteel chains. Knights of the Order of the Rose often decorate these armets with flowers - a lucky charm gifted by fair maidens and family, and a vibrant reminder that 'happiness has to be fought for.'"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "psyknight"
	item_state = "psyknight"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/skettle
	name = "slitted kettle helm"
	desc = "A reinforced Eisenhut that's been extended downwards to cover the face, fully protecting the wearer but limiting his field of view. Pairs well with a bevor."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "skettle"
	item_state = "skettle"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL
	adjustable = CANT_CADJUST
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/knight/skettle/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/heavy/nochelm/snouted
	name = "Mystra burgonet"
	desc = "Headwear commonly worn by Templars in service to Mystra, an open face to settle snouts. Without the night there can be no day; without Mystra there can be no light in the dark hours."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "nochelm_s"
	item_state = "nochelm_s"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/ravoxhelm_ap/cleric
	name = "Tempus helmet"
	desc = "Adorned with powerful ox horns and a seamless blindfold, this helm embodies the steadfast resolve of Tempus. It shuts out the physical world so that judgment may be delivered without bias or hesitation."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ravoxclerichelmet"
	item_state = "ravoxclerichelmet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/sheriff/gold
	name = "golden helmet"
	desc = "A resplendant barbute, masterfully forged from pure gold. Its nasalguard is marked by a holy sigil, and its interior is fitted with a besilked arming cap. Even in absolute darkness, the polished surface sparkles with imbued sunlight."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "goldbarbute"
	armor_type = /datum/armor/blackbag
	max_integrity = 5
	armor_class = AC_HEAVY
	anvilrepair = null
	smeltresult = /obj/item/ingot/gold
	grid_height = 96
	grid_width = 96

/obj/item/clothing/head/helmet/heavy/sheriff/iron
	name = "barred iron helmet"
	desc = "A helmet which offers good protection to the face at the expense of vision."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "igatehelm"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/volfplate/berserker
	name = "stripped volfskulle bascinet"
	desc = "A steel bascinet helmet with a snarling visor that protects the entire head and face. Just like the nitebeasts it mimics, so too does the helmet's teeth glisten with flesh-sundering sharpness."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "volfplate"
	item_state = "volfplate"
	armor_class = AC_LIGHT
	var/active_item = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/helmet/heavy/volfplate/berserker/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_HEAD))
		active_item = TRUE
		ADD_TRAIT(user, TRAIT_BITERHELM, REF(src))
		to_chat(user, span_warning("The bascinet's visor chitters, and your jaw tightens with symbiotic intent.."))
	return

/obj/item/clothing/head/helmet/heavy/volfplate/berserker/dropped(mob/user, silent = FALSE)
	..()
	if(!active_item)
		return
	active_item = FALSE
	REMOVE_TRAIT(user, TRAIT_BITERHELM, REF(src))
	to_chat(user, span_warning("..and like that, the bascinet's visor goes dormant once more - a strange pressure, relieved from your jaw."))

/obj/item/clothing/head/helmet/heavy/volfplate/iron
	name = "iron volfskulle bascinet"
	desc = "An iron bascinet helmet with a snarling visor that protects the entire head and face. It mimics the guise of a terrible nitebeast; intimidating to the levyman, inspiring to the hunter."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ivolfplate"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/helmet/heavy/volfplate/light
	name = "volfskulle bascinet"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "volfplate"
	item_state = "volfplate"
	armor_class = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/helmet/heavy/volfplate/psydonic
	name = "Aonic volfskulle bascinet"
	desc = "An Amnian re-creation of the generic volfskulle bascinet. Far more protective than a muzzle, that's for certain."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/32x40/head.dmi'
	sleeved = null
	icon_state = "psyhelm_s"
	item_state = "psyhelm_s"
	worn_x_dimension = 32
	worn_y_dimension = 40
	adjustable = CANT_CADJUST
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL
	smeltresult = /obj/item/ingot/silver
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/heavy/zizo_ap/bascinet
	name = "avantyne bascinet"
	desc = "A darksteeled bascinet, perpetually backlit with an eerie crimson haze. Glimpse into the abyss for too long..</br>‎<font color='FF0000'>..and something will look back.</font>"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "zizobascinet"
	item_state = "zizobascinet"
	flags_inv = HIDEFACE|HIDEEARS|HIDEHAIR
	adjustable = CANT_CADJUST
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/zizo_ap/frogge
	name = "avantyne froggemund"
	desc = "A monolithic, suffocating cage of darksteel that narrows one's perspective to a single, hateful point. It grants the wearer the clarity of a predator, blinding them to everything but the object of their malice."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "zizofrogmouth"
	flags_inv = HIDEFACE|HIDEEARS|HIDEHAIR
	adjustable = CANT_CADJUST
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/zizo_ap/volfhelm
	name = "avantyne volf-face bascinet"
	desc = "A terminal prognosis, a lethal parasite; unholy strands of avantyne, worming their way through the steel to make something greater. Progress is an agonising process, both unto flesh and metal."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "volfplate_avantyne"
	item_state = "volfplate_avantyne"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/barbute/visor/iron
	name = "visored iron barbute"
	desc = "A steel greathelm that provides excellent coverage, and whose cruciformic guise is further reinforced by a heavy visor. Valiant paladin, wretched bulwark, thoughtless worm; it won't be long until they're almost here. Will you cry all your tears, or will you face your fears? </br>Mounted on the back is a unique couplet, fit for adopting feathered greatplumes."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "ibarbute_visor"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY

/obj/item/clothing/head/helmet/heavy/bucket/crusader/gold
	name = "decorated sugarloaf helmet"
	desc = "A greathelmet that offers excellent protection to the head, while also ensuring total coverage to its most vulnerable spots. It resembles a freshly baked loave when worn - ergo, 'sugarloaf helmet'. Popularly seen amongst crusaders of the faith-militances, its curved top helps to disperse the crushing force of blows from above. This particular variant is decorated with golden iconography of Pantheonistic design. </br>'Ad maiorem dei gloriam.'"
	icon = 'modular_azurepeak/icons/clothing/special/crusader.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/crusader.dmi'
	sleeved = null
	icon_state = "crusader_helm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/gold

/obj/item/clothing/head/helmet/heavy/bucket/gold/cleric
	name = "decorated bucket helmet"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "topfhelm_gold"
	item_state = "topfhelm_gold"
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/bucket/iron/classic
	name = "iron bucket helmet"
	desc = "An iron greathelmet that offers excellent protection to the head, while also ensuring total coverage to its most vulnerable spots. It resembles an overturned bucket when worn - ergo, 'bucket helmet'. Owing to its simple-yet-robust design, the bucket helmet's venerability can still be observed todae, atop the shoulders of hedge-knights and paladins alike."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "itopfhelm"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/guard/bogman/iron
	name = "bogman's helmet"
	desc = "An iron helmet featuring the face of a snarling goblin. Once worn by the Bogmen, now a relic of old Duskmar."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iguardhelm"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/visored/royalknight/iron
	name = "iron armet"
	desc = "Holy lamb, sacrificial hero, blessed idiot - Ao endures. Will you endure alongside Him, as a knight of humenity, or crumble before temptation?"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iarmet"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	ported_clothing = TRUE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/visored/royalknight/owl
	name = "strigidae armet"
	desc = "An armet of distinct bird like design with a pronounced beak. Close to the teachings of the moon himself, it shields the curious gaze of the one wearing it. This one used to be in the hands of a pale elf and may be fitted with a great plume atop, to bear heraldic colors."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "armetowl"
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/visored/royalknight/owl/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
	var/choice = browser_input_list(user, "Choose a color.", "Greatplume", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/visored/royalknight/snouted
	name = "snouted armet"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "armet_s"
	ported_clothing = TRUE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/heavy/knight/gold/king
	name = "royal golden armet"
	desc = "A resplendant armet, masterfully forged from pure gold. Hexagrammic etchings of a holy sigil line its visor, and its interior is fitted with a besilked arming cap. The dorpeled crown atop its brow invokes authority, be it misbegotten or endowed."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "goldknight_crown"
	max_integrity = 10

/obj/item/clothing/head/helmet/heavy/knight/greatplume/fluted
	name = "fluted armet with greatplume"
	desc = "An ornate steel greathelm with a visor, which protects the entire head. While bulky, the fluted design excels at prolonging chivalrous bouts with fellow knights. The wider couplet atop its neckguard's rear can accept a uniquely large greatplume."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "knight"
	item_state = "knight"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/iron/greatplume
	name = "iron greatplumed armet"
	desc = "A venerable iron greathelm with a visor, which protects the entire head. It is not the alloy that truly matters, but the champion who has chosen to don such alloys in the face of peril and adversity. The wider couplet atop its neckguard's rear can accept a uniquely large greatplume."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "iknight"
	item_state = "knight"
	worn_x_dimension = 64
	worn_y_dimension = 64
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/heavy/knight/iron/greatplume/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Greatplume", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detail"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/knight/old/iron
	name = "iron knight's helmet"
	desc = "A knight's greathelm, forged from iron in the antiquated 'Waterdhavian' style. Add a feather to show the colors of your family or allegiance. </br>\u200e </br>'Despite everything, it's still you.'"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iknightclassic"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/knight/psy/greatplume
	name = "Aonic armet with greatplume"
	desc = "An ornate helmet whose visor has been bound shut with blacksteel chains. Knights of the Order of the Rose often decorate these armets with flowers - a lucky charm gifted by fair maidens and family, and a vibrant reminder that 'happiness has to be fought for.' This particular armet has a wider couplet, for accepting greatplumes."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "psyknight"
	item_state = "psyknight"
	worn_x_dimension = 64
	worn_y_dimension = 64
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	adjustable = CAN_CADJUST
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	smeltresult = /obj/item/ingot/silver

/obj/item/clothing/head/helmet/heavy/knight/skettle/iron
	name = "slitted iron kettle helm"
	desc = "A reinforced iron Eisenhut that's been extended downwards to cover the face, fully protecting the wearer but limiting his field of view. Pairs well with a bevor."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iskettle"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON

/obj/item/clothing/head/helmet/heavy/sheriff/gold/king
	name = "royal golden helmet"
	desc = "A resplendant barbute, masterfully forged from pure gold. Its nasalguard is marked by a holy sigil, and its interior is fitted with a besilked arming cap. The dorpeled crown atop its brow invokes authority, be it misbegotten or endowed."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "goldbarbute_crown"
	max_integrity = 10

/obj/item/clothing/head/helmet/heavy/bucket/crusader/gold/cleric
	name = "decorated sugarloaf helmet"
	icon = 'modular_azurepeak/icons/clothing/special/crusader.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/crusader.dmi'
	sleeved = null
	icon_state = "crusader_helm"
	item_state = "topfhelm"
	smeltresult = /obj/item/ingot/steel
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/visored/royalknight/iron/snouted
	name = "iron snouted armet"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iarmet_s"
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
