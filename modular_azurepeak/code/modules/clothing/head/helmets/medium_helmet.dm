/obj/item/clothing/head/helmet/baotha
	name = "saccharine sallet"
	desc = "<font color='bf64d0'>...ah, but none of this really matters, anyway.</font>"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "baothahelm"
	item_state = "baothahelm"
	body_parts_covered = HEAD | HAIR | EARS | MOUTH | EYES
	flags_inv = HIDEFACE
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_HELMET_ANTAG - 300
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bronze
	name = "bronze illyriahelm"
	desc = "A helmet of bronze, older-in-design than you could possibly imagine. Mounted to its crest is a decorative sigil that has sparked scholarly debates for the better part of a millennium; is it a star, a vortex, or the Sun? </br>A notch behind the sigil allows for the joint mounting of a plume. Nock a feather into it to show off your alliegence's colors."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "bronzehelmet"
	item_state = "bronzehelmet"
	armor_type = /datum/armor/ported/bronze
	max_integrity = 450 - 25
	body_parts_covered = HEAD|HAIR|EARS
	worn_x_dimension = 64
	worn_y_dimension = 64
	smeltresult = /obj/item/ingot/bronze
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/bronze/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/bronzegladiator
	name = "bronze murmillo"
	desc = "A bronze helmet that veils the wearer's face behind a perforated visor; a distant ancestor to both the sallet and the savoyard, offering excellent coverage without suffocating its wearer. </br>Arena troupes across the Sword Coast still reenact the legendary duel between Tempus and Gruumsh in such helms - the war god's champion against the One-Eyed God's."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "bronzemurmillo"
	item_state = "bronzemurmillo"
	armor_type = /datum/armor/ported/bronze
	max_integrity = 450 - 100
	armor_class = AC_LIGHT
	body_parts_covered = FULL_HEAD
	smeltresult = /obj/item/ingot/bronze
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/bronzegladiator/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/elvenbarbute
	name = "elven barbute"
	desc = "It fits snugly on one's elven head, with special slots for their pointier ears."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "elven_barbute_full"
	item_state = "elven_barbute_full"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_HIP
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor_type = /datum/armor/plate
	clothing_flags = 0
	block2add = FOV_BEHIND
	detail_tag = "_detail"
	detail_color = "#FFFFFF"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/otavan
	name = "Amnian helmet"
	desc = "A helmet of Amnian make, similar in structure to an Aonic armet but fitted with an angular klappvisier."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "otavahelm"
	item_state = "otavahelm"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	detail_tag = "_detail"
	color = "#FFFFFF"
	detail_color = "#e08828"
	dyeable = TRUE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = HIDEEARS
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/otavan/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -5,"sy" = -3,"nx" = 0,"ny" = 0,"wx" = 0,"wy" = -3,"ex" = 2,"ey" = -3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 8)
			if("onbelt")
				return list("shrink" = 0.32,"sx" = -3,"sy" = -8,"nx" = 6,"ny" = -8,"wx" = -1,"wy" = -8,"ex" = 3,"ey" = -8,"nturn" = 180,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 1,"sflip" = 0,"wflip" = 0,"eflip" = 8,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/clothing/head/helmet/bascinet/antler
	name = "warden's helmet"
	desc = "A beastly snouted armet with the large horns of an elder saiga protruding from it. Residents of Rivermist Hollow know not to fear such a sight in the wilds, for they are exclusively associated with the Duskmarian wardens."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden64.dmi'
	sleeved = null
	icon_state = "wardenhelm"
	adjustable = CAN_CADJUST
	worn_x_dimension = 64
	worn_y_dimension = 64
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/aventail
	name = "bascinet with aventail"
	desc = "A steel bascinet helmet, further protected with a thick maille aventail. Burdensome on the shoulders of those not trained to carry maille, yet excellent in both coverage and durability."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "aventail"
	item_state = "aventail"
	body_parts_covered = HEAD|HAIR|EARS|MOUTH|NECK
	block2add = FOV_BEHIND
	armor_class = AC_MEDIUM
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/bascinet/etruscan
	name = "klappvisier bascinet"
	desc = "A steel bascinet helmet with a straight visor, or \\\"klappvisier\\\", which can greatly reduce visibility. Though it was first developed in Sembia, it is also widely used in Darkhold."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "klappvisier"
	item_state = "klappvisier"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/bascinet/etruscan/attackby(obj/item/attacking_item, mob/user, list/modifiers)
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

/obj/item/clothing/head/helmet/bascinet/iron
	name = "iron bascinet"
	desc = "An iron bascinet helmet, and the basis for many-a-visored greathelm. Though it lacks a visor, it still protects the head and ears."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ibascinet"
	item_state = "ibascinet"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/bascinet/pigface
	name = "pigface bascinet"
	desc = "A steel bascinet helmet with a pigface visor that protects the entire head and face. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "pigface"
	item_state = "pigface"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE

/obj/item/clothing/head/helmet/bascinet/pigface/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/cloth) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Orle", GLOB.ported_color_map)
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
	if(istype(W, /obj/item/natural/feather) && !altdetail_tag)
		var/choicealt = browser_input_list(user, "Choose a color.", "Plume", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/elvenbarbute/blackoak
	desc = "An elven barbute with a thin gold plating designed for Elven Woodland guardians."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "elven_barbute_full"
	item_state = "elven_barbute_full"
	detail_color = COLOR_ASSEMBLY_GOLD
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/elvenbarbute/winged
	name = "winged elven barbute"
	desc = "A winged version of the elven barbute. They have always been known for their vanity."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "elven_barbute_winged"
	item_state = "elven_barbute_winged"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/kettle/aalloy
	name = "decrepit kettle helmet"
	desc = "A rotted metal helmet which protects the top and sides of the head. Atop a resurrected levyman's scalp, it's a sign that forces-most-foul are soon to besiege; and atop a fleshless ballistaeman's skull, it's a sign that you should probably duck."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ancientkettle"
	body_parts_covered = HEAD|HAIR|EARS
	color = "#bb9696"
	anvilrepair = null
	max_integrity = ARMOR_INT_HELMET_HEAVY_DECREPIT
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/kettle/jingasa
	name = "jingasa"
	desc = "A steel-reinforced conical hat with a decorative rim of fabric. It protects the head and ears as much as it shields the eyes from the sun."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "kazengunmedhelm"
	item_state = "kazengunmedhelm"
	detail_tag = "_detail"
	detail_color = "#FFFFFF"
	flags_inv = HIDEEARS|HIDEHAIR
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/kettle/paalloy
	name = "ancient kettle helmet"
	desc = "A polished gilbranze helmet which protects the top and sides of the head. Shar's glare musn't be interceded, when matters of unholy war are at hand. Undead ballistaemen practice a curious method of tying dyed cloth around its rim; can they, too, think and associate?"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ancientkettle"
	body_parts_covered = HEAD|HAIR|EARS
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/kettle/wide
	name = "wide kettle helmet"
	desc = "A wider variant of the humble 'kettle helmet', for those who prefer to keep Lathander's glare from blighting their eyes."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "kettlewide"
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/nasal/iron
	name = "iron nasal helmet"
	desc = "An iron helmet that doesn't get any more simple in design."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "inasal"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/sallet/beastskull
	name = "beast skull"
	desc = "The skull of a horned beast, carved and fashioned into a helmet. An steel skull cap has been inserted on the inside."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "marauder_head"
	body_parts_covered = HEAD|EARS|HAIR
	max_integrity = ARMOR_INT_HELMET_STEEL + 50
	smeltresult = /obj/item/ingot/steel
	worn_x_dimension = 64
	worn_y_dimension = 64
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/visored
	name = "visored sallet"
	desc = "A steel 'sallet'-styled helmet with an adjustable visor. Away with you, vile beggar!"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "sallet_visor"
	adjustable = CAN_CADJUST
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES
	block2add = FOV_BEHIND
	armor_type = /datum/armor/plate
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = HIDEEARS|HIDEHAIR
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/sallet/warden
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "sallet"
	item_state = "that"
	flags_inv = HIDEFACE
	body_parts_covered = FULL_HEAD
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	block2add = FOV_BEHIND
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/skullcap/steel
	name = "skull cap"
	desc = "A steel helmet which covers the top of the head."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "skullcap"
	body_parts_covered = HEAD|HAIR
	max_integrity = ARMOR_INT_HELMET_STEEL
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/winged/iron
	name = "iron winged helmet"
	desc = "A helmet with two wings on its sides."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "iwingedcap"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/bascinet/etruscan/iron
	name = "iron klappvisier bascinet"
	desc = "An iron bascinet helmet with a straight visor, or \\\"klappvisier\\\", which can greatly reduce visibility. Though it was first developed in Sembia, it is also widely used in Darkhold."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iklappvisier"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON

/obj/item/clothing/head/helmet/bascinet/iron/aventail
	name = "iron bascinet with aventail"
	desc = "An iron bascinet helmet, further protected with a thick maille aventail. Burdensome on the shoulders of those not trained to carry maille, yet excellent in both coverage and durability."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "iaventail"
	item_state = "iaventail"
	body_parts_covered = HEAD|HAIR|EARS|MOUTH|NECK
	block2add = FOV_BEHIND
	armor_class = AC_MEDIUM

/obj/item/clothing/head/helmet/bascinet/pigface/hounskull
	name = "hounskull bascinet"
	desc = "A bascinet with a conical visor, favored by those with snouts and whiskers. Nestle a feather or length of cloth onto the rim to display your allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "hounskull"
	item_state = "hounskull"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/bascinet/pigface/iron
	name = "iron pigface bascinet"
	desc = "An iron bascinet helmet with a pigface visor that protects the entire head and face. Add a feather to show the colors of your family or allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ipigface"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON

/obj/item/clothing/head/helmet/bascinet/pigface/roundface
	name = "roundface bascinet"
	desc = "A bascinet with a conical visor, favored by those without snouts and whiskers. Nestle a feather or length of cloth onto the rim to display your allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "roundface"
	item_state = "roundface"
	worn_x_dimension = 64
	worn_y_dimension = 64
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/elvenbarbute/winged/blackoak
	desc = "A winged version of the elven barbute with a thin gold plating designed for Elven Woodland guardians."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "elven_barbute_winged"
	item_state = "elven_barbute_winged"
	detail_color = COLOR_ASSEMBLY_GOLD
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/iron/banded
	name = "banded iron helmet"
	desc = "A menacing horned half-face iron helmet worn primarily by mercenaries hailing from an unaligned conflict-ridden enclave within the Uthgardt-Mithral Hall border. A helmet of this kind was notoriously worn by an unknown person said to kill the last Great Drakyn inhabiting the mountains of Mithral Hall."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ibandedhelm"
	item_state = "ibandedhelm"
	max_integrity = ARMOR_INT_HELMET_HEAVY_IRON
	armor_class = AC_MEDIUM
	flags_inv = HIDEEARS|HIDEFACE
	flags_cover = HEADCOVERSEYES
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES
	block2add = FOV_BEHIND
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/visored/grinning
	name = "besilked sallet"
	desc = "The gilded steel of the helm cradles your face between two great drakkyn-jaws. Pass a coin through the slit and place it on your tongue, for the ferryman is never far away."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "mgrinningsallet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/visored/iron
	name = "iron visored sallet"
	desc = "An iron 'sallet'-styled helmet with an adjustable visor. Out for a stroll, now, are we?"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "isallet_visor"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON

/obj/item/clothing/head/helmet/sallet/visored/snouted
	name = "snouted visored sallet"
	desc = "A steel 'sallet'-styled helmet with an adjustable visor, its bevor drawn forward into a muzzle. Favored by those with snouts. Away with you, vile beggar!"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "sallet_visor_s"

/obj/item/clothing/head/helmet/sallet/warden/bear
	name = "warden's bearskull helm"
	desc = "The large, intimidating skull of a common direbear, plated with steel on its inner side and given padding - paired together with a steel maille mask and worn with a linen shroud. Such trophies are associated with life-long hunters and their descendants."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = null
	icon_state = "skullmet_bear"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/warden/goat
	name = "warden's ramskull helm"
	desc = "The large, intimidating horned skull of an elusive Duskmarian great ram, plated with steel on its inner side and given padding - paired together with a steel maille mask and worn with a linen shroud. Such trophies are associated with life-long foresters and their descendants."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = null
	icon_state = "skullmet_goat"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/warden/rat
	name = "warden's rouskull helm"
	desc = "The large, intimidating skull of the rare giant rous, plated with steel on its inner side and given padding - paired together with a steel maille mask and worn with a linen shroud. Such trophies are associated with life-long sewer dwellers and their descendants."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = null
	icon_state = "skullmet_rat"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/warden/wolf
	name = "warden's volfskull helm"
	desc = "The large, intimidating skull of an elusive white volf, plated with steel on its inner side and given padding - paired together with a steel maille mask and worn with a linen shroud. Such trophies are associated with life-long game wardens and their descendants."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = null
	icon_state = "skullmet_volf"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/pigface/hounskull/iron
	name = "iron hounskull bascinet"
	desc = "An iron bascinet with a conical visor, favored by those with snouts and whiskers. Nestle a feather or length of cloth onto the rim to display your allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ihounskull"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON

/obj/item/clothing/head/helmet/bascinet/pigface/roundface/iron
	name = "iron roundface bascinet"
	desc = "An iron bascinet with a conical visor, favored by those without snouts and whiskers. Nestle a feather or length of cloth onto the rim to display your allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "iroundface"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_HELMET_IRON

/obj/item/clothing/head/helmet/bascinet/pigface/roundface/snouted
	name = "snouted roundface bascinet"
	desc = "A bascinet with a conical visor, drawn forward into a muzzle for those with snouts. Nestle a feather or length of cloth onto the rim to display your allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "roundface_s"
	item_state = "roundface_s"

/obj/item/clothing/head/helmet/sallet/visored/iron/snouted
	name = "iron snouted visored sallet"
	desc = "An iron 'sallet'-styled helmet with an adjustable visor, its bevor drawn forward into a muzzle. Favored by those with snouts. Out for a stroll, now, are we?"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "isallet_visor_s"

/obj/item/clothing/head/helmet/bascinet/pigface/roundface/iron/snouted
	name = "iron snouted roundface bascinet"
	desc = "An iron bascinet with a conical visor, drawn forward into a muzzle for those with snouts. Nestle a feather or length of cloth onto the rim to display your allegiance."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "iroundface_s"
	item_state = "iroundface_s"
