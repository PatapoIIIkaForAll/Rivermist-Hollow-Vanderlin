/// Gruumsh amulets, kept with the other inhumen symbols.
/obj/item/clothing/neck/psycross/inhumen/graggar
	resistance_flags = FIRE_PROOF
	abstract_type = /obj/item/clothing/neck/psycross/inhumen/graggar

/obj/item/clothing/neck/psycross/inhumen/graggar/g/triumph
	name = "ornate amulet of Gruumsh"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "graggar_g"
	sellprice = 77
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/coif/baotha
	name = "saccharine veil"
	desc = "A gauzy veil worn over a padded coif. Sune promises love and warmth; Blissara promises that you will never have to feel anything else again."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "baothacoif"
	item_state = "baothacoif"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	flags_inv = HIDEFACE
	body_parts_covered = NECK | HAIR | EARS | HEAD | NOSE
	armor_class = AC_LIGHT
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	resistance_flags = FIRE_PROOF
	blocksound = SOFTHIT
	color = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/coif/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/neck/coif/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/neck/chaincoif/chainmantle/matthios
	name = "gilded chain mantle"
	desc = "The world is yours, as they say - yet, why doth the Gods still led us astray?"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "matthioschainmantle"
	item_state = "matthioschainmantle"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/gorget/steel/graggar
	name = "vicious gorget"
	desc = "Curled plate, cradling the neck. Once, they were chains - now, they've allowed you to break free."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "graggargorget"
	item_state = "graggargorget"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/psycross/inhumen/aalloy
	name = "decrepit zcross"
	desc = "A symbol of progress from an era that had reason to believe in it."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "zcross_a"
	color = "#bb9696"
	resistance_flags = FIRE_PROOF
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/psycross/inhumen/baotha
	name = "amulet of Blissara"
	desc = "A hollow promise rendered in gold. It weighs heavy with the memory of sweet wine turned to poison, and the comfort of a sorrow that refuses to fade."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "baotha"
	resistance_flags = FIRE_PROOF
	smeltresult = null

/obj/item/clothing/neck/psycross/inhumen/matthios
	name = "amulet of Mask"
	desc = "He was but one flame in the dark. Together, His flock shall outblaze the Tyrant-Sun."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "matthios"
	resistance_flags = FIRE_PROOF
	smeltresult = null

/obj/item/clothing/neck/psycross/inhumen/paalloy
	name = "ancient zcross"
	desc = "'Progress. Ascension. Destiny. A mandate, commanded by God, to be fufilled by Man. She called us forth from the edge of reality - and with Her dying breath, rasped out the final truth; the fire is gone, and the world will soon follow.'"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "zcross_a"
	resistance_flags = FIRE_PROOF
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/psycross/inhumen/baotha/g
	name = "golden amulet of Blissara"
	desc = "A hollow promise, rendered in gold and glistening with value. It weighs heavy with the memory of sweet wine turned to poison, and the comfort of a sorrow that refuses to fade."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "baotha"

/obj/item/clothing/neck/psycross/inhumen/baotha/wood
	name = "wooden amulet of Blissara"
	desc = "Drown in the past, live in the present, and forget the future."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "baotha_w"
	item_state = "baotha_w"
	sellprice = 0
	salvage_result = /obj/item/grown/log/tree/stick
	salvage_amount = 1
	wrist_mob_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'

/obj/item/clothing/neck/psycross/inhumen/graggar/bronze
	name = "bronze amulet of Gruumsh"
	desc = "'EVERYTHING - AND EVERYONE YOU LOVE - WILL BE GONE! WHAT WILL YOU HAVE, AFTER THE LAST FIRE'S BEEN SMOTHERED OUT?!' </br>‎ </br>'..You. I'd still have you.'"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "graggar_b"
	item_state = "graggar_b"
	ported_clothing = TRUE
	wrist_mob_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'

/obj/item/clothing/neck/psycross/inhumen/graggar/g
	name = "golden amulet of Gruumsh"
	desc = "Might makes right."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "graggar_g"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/psycross/inhumen/graggar/wood
	name = "wooden amulet of Gruumsh"
	desc = "When all you have is a hammer, every problem tends to look like a nail."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "graggar_w"
	item_state = "graggar_w"
	sellprice = 0
	salvage_result = /obj/item/grown/log/tree/stick
	salvage_amount = 1
	ported_clothing = TRUE
	wrist_mob_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'

/obj/item/clothing/neck/psycross/inhumen/matthios/g
	name = "golden amulet of Mask"
	desc = "He was but one flame in the dark. Together, His flock shall outblaze the Tyrant-Sun, and shall live deliciously atop the highest throne."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "matthios"

/obj/item/clothing/neck/psycross/inhumen/matthios/wood
	name = "wooden amulet of Mask"
	desc = "Is a man not entitled to the sweat of their brow?"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "matthios_w"
	item_state = "matthios_w"
	sellprice = 0
	salvage_result = /obj/item/grown/log/tree/stick
	salvage_amount = 1
	wrist_mob_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'

/obj/item/clothing/neck/psycross/inhumen/matthios/gilded
	name = "ornate amulet of Mask"
	desc = "He was ever the one to make you ask questions: Why are we still here? Just to suffer? Nae. We are here to make a change. And a change we shall make, together."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "matthios"
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK | ITEM_SLOT_RING
	var/stolen_fyre = FALSE
	var/grant_chant = FALSE
	var/active_item = FALSE
	var/swap_type = /obj/item/clothing/neck/psycross/inhumen/matthios/gilded/astrata
	var/swap_message = "The gilded amulet transmutates to a different form. You feel a smile, as you profane Her fyre the same way as He did."
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/psycross/inhumen/matthios/gilded/proc/swap_form(mob/living/carbon/human/user)
	var/obj/item/clothing/neck/psycross/inhumen/matthios/gilded/new_amulet = new swap_type(user.loc)
	if(user.is_holding(src))
		user.temporarilyRemoveItemFromInventory(src)
		user.put_in_hands(new_amulet)
	else
		new_amulet.forceMove(get_turf(user))
	qdel(src)

/obj/item/clothing/neck/psycross/inhumen/matthios/gilded/attack_self(mob/user, list/modifiers)
	if(!do_after(user, 1 SECONDS))
		return
	playsound(user.loc, 'sound/magic/swap.ogg', 25, TRUE, -2)
	if(findtext(LOWER_TEXT(name), "ruined"))
		to_chat(user, span_warning("[src] crumbles into ash in your hands."))
		qdel(src)
		return
	to_chat(user, span_warning(swap_message))
	swap_form(user)

/obj/item/clothing/neck/psycross/inhumen/matthios/gilded/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(obj_broken || active_item || !istype(user))
		return
	if(!(slot & (ITEM_SLOT_NECK|ITEM_SLOT_RING)) || !istype(user.patron, /datum/patron/faerun/evil_gods))
		return
	active_item = TRUE
	if(!stolen_fyre && istype(user.patron, /datum/patron/faerun/evil_gods/Mask))
		user.set_stat_modifier("matthios_boldness_[REF(src)]", list((STATKEY_LCK) = 1))
	if(user.has_language(/datum/language/thievescant))
		to_chat(user, span_info("I already know Thieves' Cant, but praise be Mask anyway!"))
		return
	to_chat(user, span_info("I gain insight on Thieves' Cant. Blend the gestures into normal speech to hide them."))
	user.grant_language(/datum/language/thievescant)
	grant_chant = TRUE

/obj/item/clothing/neck/psycross/inhumen/matthios/gilded/dropped(mob/user, silent = FALSE)
	. = ..()
	if(!active_item)
		return
	active_item = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.remove_stat_modifier("matthios_boldness_[REF(src)]")
	if(grant_chant)
		to_chat(user, span_info("The knowledge fades from my mind."))
		user.remove_language(/datum/language/thievescant)
		grant_chant = FALSE
