/obj/item/clothing/head/helmet/grandmaster_habit
	name = "\improper Knight-Abbot's habited burgonet"
	desc = "The Demon's Legion fell before them, like wheat before the swinging scythe. </br>However, the Demon's armies were numberless.</br> A sea of death, forever coming and marching in flame-borne fervour, crashed upon the Lord and his army in waves."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "dasfox_habitburgeonet"
	item_state = "dasfox_habitburgeonet"
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	detail_color = CLOTHING_WHITE
	altdetail_color = CLOTHING_WHITE
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	dyeable = TRUE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet_winged
	name = "\improper Knight-Apostle's winged sallet"
	desc = "O' Lord, hear of my call. Guide me through the blackest of nights. </b> Steel my heart against the temptations of the damned and wicked. </b> Make of me to rest, within the warmest of places."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "psyallet"
	item_state = "psyallet"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet_winged/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
	var/choice = browser_input_list(user, "Choose a color.", "Wings", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/shadowplate
	name = "scourge mantle"
	desc = "Gilded fangs, darkened iron; a warning of the venom not held by itself, but by the one who has taken up this mantle."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "chiv_drowhelm"
	item_state = "chiv_drowhelm"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES|MOUTH
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	block2add = FOV_BEHIND
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/shadowplate/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
	user.visible_message(span_warning("[user] adds [W] to [src]."))
	user.transferItemToLoc(W, src, FALSE, FALSE)
	detail_color = COLOR_WHITE
	detail_tag = "_detail"
	update_appearance()
	if(loc == user && ishuman(user))
		var/mob/living/carbon/H = user
		H.update_inv_head()

/obj/item/clothing/head/helmet/bascinet/apostle
	name = "\improper Knight-Apostle's heavy burgonet"
	desc = "O' Father, hear my cry! Seat me by Your side as my death comes! </br> Make of me one within Your glories as I fall! </br> Let the world, through my deeds, once more see Your favor!"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "apostleburgeonet"
	item_state = "apostleburgeonet"
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
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/apostle/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
	var/choice = browser_input_list(user, "Choose a color.", "Wings", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/bascinet/apostle_winged
	name = "\improper Knight-Apostle's winged burgonet"
	desc = "O' Ao, see of Your servant. For I walk only where You have bid of me to. </br> Stand only within the places that You have blessed of me to. </br> And sing only the hymn and word You have gifted me to."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "wingedburgeonet"
	item_state = "wingedburgeonet"
	adjustable = CANT_CADJUST
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
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/apostle_winged/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
	var/choice = browser_input_list(user, "Choose a color.", "Wings", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/grandmaster_habit/aventail
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "dasfox_habitburgeonet"
	item_state = "dasfox_habitburgeonet"
	adjustable = CAN_CADJUST
	emote_environment = 3
	body_parts_covered = FULL_HEAD|NECK
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_RIGHT|FOV_LEFT
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL + ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY
	smeltresult = /obj/item/ingot/steel
	armor_class = AC_HEAVY
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/burgeonet
	name = "gothic burgonet"
	desc = "A magnificent steel helmet, unburdening to one's guise. The intricate fluting serves as a clear sign of its Darkholdian heritage; ornate, but not obnoxiously so."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "burgeonet_t"
	item_state = "burgeonet_t"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/apostle/aventail
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "apostleburgeonet"
	item_state = "apostleburgeonet"
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
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/apostle/grandmaster
	name = "\improper Knight-Abbot's heavy burgonet"
	desc = "The Demon's Legion fell before them, like wheat before the swinging scythe. </br>However, the Demon's armies were numberless.</br> A sea of death, forever coming and marching in flame-borne fervour, crashed upon the Lord and his army in waves."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "dasfox_apostleburgeonet"
	item_state = "dasfox_apostleburgeonet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/pigface/burgeonet
	name = "gothic burgonet"
	desc = "A magnificent steel helmet, and the newest of the venerable armet's lineage. The intricate fluting serves as a clear sign of its Darkholdian heritage; ornate, but not obnoxiously so."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "burgeonet"
	item_state = "burgeonet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/pigface/donator_stalkerino
	name = "skikudic savoyard"
	desc = "A helmet forged in the great Underdark, no doubt a Duergar had a hand in making this. The material has started to lose its color under Lathander's gaze, yet one feature stands above all - a combination of a visor and gold that inspires happiness, or tries to. Lighten up, will you?"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "stalkerino_smilehelm"
	item_state = "stalkerino_smilehelm"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/pigface/spartanbobby
	name = "holy Lathanderite bascinet"
	desc = "A silver bascinet with an ornate, golden klappvisier moulded in HIS image.</br><font color='46bacf'>LATHANDER IMPRESSED.</font>"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "astrata_impressed"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/abyssorgreathelm/limetease
	name = "serpentine bascinet"
	desc = "A sturdy bascinet that seems to have been fitten with a long visor. Loosely resembles a drakynn or some sort of sea serpent."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes64.dmi'
	sleeved = null
	icon_state = "limehelm"
	worn_x_dimension = 64
	worn_y_dimension = 64
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/aventail/donator_lamprey
	name = "stechhelm"
	desc = "The froggemund's battle-ready brother from another mother, offering excellent protection at the cost of less-than-excellent visibility."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "lamprey_stechhelm"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/barbute/avantyne
	name = "avantyne-threaded barbute"
	desc = "A barbute that seems to be more avantyne than steel. Some might assume that the presence of yet-uncovered steel means this helmet can be saved, but rest assured.. </br> <font color='FF0000'>..that it has already been corrupted from the inside-out.</font>"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes64.dmi'
	sleeved = null
	icon_state = "dakken_zizhelm"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/gilded
	name = "gilded knight's helmet"
	desc = "A noble knight's helm made of steel and completed with a gilded trim."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "gildedknight"
	item_state = "gildedknight"
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/gilded/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
	user.visible_message(span_warning("[user] adds [W] to [src]."))
	user.transferItemToLoc(W, src, FALSE, FALSE)
	detail_tag = "_detail"
	update_appearance()
	if(loc == user && ishuman(user))
		var/mob/living/carbon/H = user
		H.update_inv_head()

/obj/item/clothing/head/helmet/heavy/knight/rockhill
	name = "knight-errant's armet"
	desc = "Originating in Waterdeep's armories, this particular helmet - truthfully closer to a burgonet than an armet - was borne to further plate its men-at-arms against rising perils. A wider visor offers better vision in a torch-snuffed street, and small studs along the neckguard allow for it to be scarfed with ducal colors."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "rockhillarmet"
	item_state = "rockhillarmet"
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/knight/rockhill/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/cloth) && !altdetail_tag)
		var/choicealt = browser_input_list(user, "Choose a color.", "Scarf", GLOB.ported_color_map)
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

/obj/item/clothing/head/helmet/heavy/psydonhelm/ryan
	name = "maimed Aonic helm"
	desc = "Disavowed lamb, suicidal hero, cursed idiot - the Overgod does not answer. Will you march on as a beacon of dwindling hope, or surrender to temptation?"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes64.dmi'
	sleeved = null
	icon_state = "ryan_maimedhelm"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/helmet/sallet/visored/aasimar
	name = "aasimari sayovard"
	desc = "Statuesque beauty, forever preserved in polished gilbranze."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "chiv_adeathmask"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR|NOSE|EYES)
	adj_open_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	adj_sound = 'sound/magic/bless.ogg'
	adj_open_fov = FOV_BEHIND
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/visored/aasimar/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-clicking can either reveal or hide the helmet's ornamental halo.")

/obj/item/clothing/head/helmet/sallet/visored/gilded
	name = "gilded visored sallet"
	desc = "A steel helmet with gilded trim which protects the ears, nose, and eyes."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "gildedsallet_visor"
	item_state = "gildedsallet_visor"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/visored/gothic
	name = "gothic sallet"
	desc = "An ornate steel sallet, and the most modern design of its kind. These helms are commonly worn by Darkhold's knights, and feature a much more aggressive shape and longer tail than sallets common of munition arms."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "gsallet"
	item_state = "gsallet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/visored/limetease
	name = "serpentine bascinet"
	desc = "A sturdy bascinet that seems to have been fitten with a long visor. Loosely resembles a drakynn or some sort of sea serpent."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes64.dmi'
	sleeved = null
	icon_state = "limehelm"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/apostle/aventail/grandmaster
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "dasfox_apostleburgeonet"
	item_state = "dasfox_apostleburgeonet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/pigface/hounskull/dakken
	name = "armoured avantyne barbute"
	desc = "A heavy-metal barbute that seems to be more avantyne than steel. It carries a tormented lustre about it, glinting under the sun as threads of the dark metal wind through its visor."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "dakken_zizbarb"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/bascinet/pigface/hounskull/spaz
	name = "hound-nosed bascinet"
	desc = "A sturdy bascinet that seems to have been fitten with a long visor."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "spaz_helm"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/astratahelm/cleric/koruu
	name = "Lux In Tenebris"
	desc = "Topped with a magnificent plume, this helmet turns the wearer into a walking beacon of Lathander's wrath. Designed to cut a striking silhouette, it strikes terror into the hearts of nonbelievers from afar."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "astrataclerichelm"
	item_state = "astrataclerichelm"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/aventail/iron/donator_lamprey
	name = "iron stechhelm"
	desc = "The froggemund's battle-ready brother from another mother, offering excellent protection at the cost of less-than-excellent visibility. This particular variant happens to be wrought from iron."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "lamprey_istechhelm"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/barbute/visor/dakken
	name = "armoured avantyne barbute"
	desc = "A heavy-metal barbute that seems to be more avantyne than steel. It carries a tormented lustre about it, glinting under the sun as threads of the dark metal wind through its visor."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes64.dmi'
	sleeved = null
	icon_state = "dakken_zizbarb"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/barbute/visor/spaz
	name = "hound-nosed bascinet"
	desc = "A sturdy bascinet that seems to have been fitten with a long visor."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes64.dmi'
	sleeved = null
	icon_state = "spaz_helm"
	worn_x_dimension = 64
	worn_y_dimension = 64
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/visored/royalknight/dakken
	name = "armoured avantyne barbute"
	desc = "A heavy-metal barbute that seems to be more avantyne than steel. It carries a tormented lustre about it, glinting under the sun as threads of the dark metal wind through its visor."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "dakken_zizbarb"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/visored/royalknight/dasfox
	name = "archaic ceremonial valkyrhelm"
	desc = "A winged and angular helm of archaic design, tracing its lineage back to the fall of Netheril. House Timbermere makes sole use of its design within Duskmar, claiming it as their heritage right. This one has been gilded in Lathander's own colours, with a hand-woven plume atop to bear heraldic colours."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "valkyrhelm"
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/visored/royalknight/dasfox/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(!(istype(W, /obj/item/natural/feather) && !detail_tag))
		return
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

/obj/item/clothing/head/helmet/visored/royalknight/spaz
	name = "hound-nosed bascinet"
	desc = "A sturdy bascinet that seems to have been fitten with a long visor."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "spaz_helm"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/head/helmet/heavy/knight/rockhill/iron
	name = "knight-errant's armet"
	desc = "Originating in Waterdeep's armories, this particular helmet - truthfully closer to a burgonet than an armet - was borne to further plate its men-at-arms against rising perils. A wider visor offers better vision in a torch-snuffed street, and small studs along the neckguard allow for it to be scarfed with ducal colors."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "irockhillarmet"
	item_state = "irockhillarmet"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/ravoxhelm_ap/cleric/koruu
	name = "Gebura"
	desc = "Adorned with powerful ox horns and a seamless blindfold, this helm embodies the steadfast resolve of Tempus. Blind, is our justice. Ever-defying, is our tenacity."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ravoxclerichelmet"
	item_state = "ravoxclerichelmet"
	misc_flags = CRAFTING_TEST_EXCLUDE
