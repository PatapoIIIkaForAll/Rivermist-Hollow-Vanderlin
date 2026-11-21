/obj/item/clothing/head/roguehood/shadedhat
	name = "shaded hat"
	desc = "A friend to travelers across antique and distant lands; the sort where Lathander's light is bright enough to blind the unprepared, specifically."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "shadedhat"
	item_state = "shadedhat"
	color = null
	body_parts_covered = HEAD|HAIR
	block2add = null
	flags_inv = HIDEHAIR
	ported_clothing = TRUE
	hint_decorate = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/shadedhat/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/W = attacking_item
	..()
	if(istype(W, /obj/item/natural/fur) && !detail_tag)
		var/choice = browser_input_list(user, "Choose a color.", "Fur", GLOB.ported_color_map)
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
		var/choice = browser_input_list(user, "Choose a color.", "Cloth", GLOB.ported_color_map)
		if(!choice)
			return
		detail_color = GLOB.ported_color_map[choice]
		detail_tag = "_detailalt"
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/padded/pestra/keeper
	name = "keeper's stone mask"
	desc = "A hooded stone mask worn by Ilmatari keepers. Their faces, oft marred by disease, hold no value to them; it is the easing of others' suffering that is their true cause."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "keeperhelm"
	item_state = "keeperhelm"
	armor_type = /datum/armor/plate
	armor_class = AC_LIGHT
	smeltresult = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/abyssor
	name = "depths hood"
	desc = "A hood worn by the followers of Umberlee, with a unique, coral-shaped mask. How do they even see out of this?"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "abyssorhood"
	item_state = "abyssorhood"
	color = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/head/roguehood/eorahood
	name = "opera hood"
	desc = "An opera mask worn by the faithful of Sune, usually during their rituals. Comes with a hood that can be pulled up for warmth."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "eorahood"
	color = null
	bloody_icon_state = "helmetblood"
	worn_x_dimension = 64
	worn_y_dimension = 64
	resistance_flags = FIRE_PROOF
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/head/roguehood/hierophant
	name = "hierophant's pashmina"
	desc = "A thick hood that covers one's entire head, should they desire, or merely acts as a scarf otherwise. Made with spell-laced fabric to provide some protection against daemons and mortals alike."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "hijab"
	item_state = "hijab"
	max_integrity = ARMOR_INT_HELMET_LEATHER
	armor_type = /datum/armor/ported/leather
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/pontifex
	name = "pontifex's pashmina"
	desc = "A slim hood with thin, yet dense fabric. Stretchy and malleable, allowing for full flexibility and mobility. Made with spell-laced fabric to provide some protection against daemons and mortals alike."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "monkhood"
	item_state = "monkhood"
	max_integrity = ARMOR_INT_HELMET_LEATHER
	armor_type = /datum/armor/ported/leather
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/roguehood/psydon_ap
	name = "Aonic hood"
	desc = "A hood worn by the adherents of the Holy Aonic Inquisition, oft-donned in conjunction with its matching tabard. Made with spell-laced fabric to provide some protection."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "psydonhood"
	item_state = "psydonhood"
	color = null
	blocksound = SOFTHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	body_parts_covered = NECK | HEAD | HAIR
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	armor_type = /datum/armor/ported/leather
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = ARMOR_INT_HELMET_LEATHER
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/head/roguehood/psydon_ap

/obj/item/clothing/head/roguehood/ravox
	name = "Tempuran hood"
	desc = "A hood worn by those devoted to the will of Tempus. Battle may be blind, but His servants are not."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ravoxhood"
	item_state = "ravoxhood"
	color = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	block2add = null
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	ported_clothing = TRUE

/obj/item/clothing/head/roguehood/ravoxgorget
	name = "Tempuran tabard gorget"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "ravoxgorget"
	item_state = "ravoxgorget"
	color = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDENECK
	dynamic_hair_suffix = ""
	sewrepair = TRUE
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	block2add = null
	ported_clothing = TRUE
	adjustable = CANT_CADJUST

/obj/item/clothing/head/roguehood/undividedcleric
	name = "undivided clerical hood"
	desc = "A hood worn by those who guide the faithful of the whole pantheon across Faerun."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "monkhood"
	item_state = "monkhood"
	color = "#999999"
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	block2add = null
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/head/roguehood/psydon_ap/black
	name = "blessed hood"
	desc = "A hood worn by the worshippers of Ao, oft-donned in conjunction with its matching tabard. Mourn, but do not despair; for even the smallest spark of faith might yet reignite the hearth of this dying world."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "blackpsydonhood"
	item_state = "blackpsydonhood"

/obj/item/clothing/head/leather/inqhat/gravehat
	name = "gravetender's hat"
	desc = "A fine leather slouch fitted with a hidden steel skull cap. It serves as a reminder that Jergal's grasp is never too far."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "gravehat"
	item_state = "gravehat"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/priesthat/bishop
	name = "bishop's hat"
	desc = "Thine authority, divine; thine faith, unfettered."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "bishop"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/eoramask
	name = "Sunite mask"
	desc = "A silver mask in the likeness of a rabbit. Usually worn by the faithful of Sune during their rituals, but it's not like anyone's going to stop you. Right?"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/head.dmi'
	sleeved = null
	icon_state = "eoramask"
	item_state = "eoramask"
	color = null
	worn_x_dimension = 64
	worn_y_dimension = 64
	flags_inv = HIDEFACE
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	dynamic_hair_suffix = ""
	resistance_flags = FIRE_PROOF
	salvage_result = /obj/item/natural/silk
	salvage_amount = 2
	ported_clothing = TRUE

/obj/item/clothing/head/eoramask/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_HEAD) || (slot & ITEM_SLOT_MASK))
		ADD_TRAIT(user, TRAIT_PACIFISM, "eoramask_[REF(src)]")

/obj/item/clothing/head/eoramask/dropped(mob/user, silent = FALSE)
	..()
	REMOVE_TRAIT(user, TRAIT_PACIFISM, "eoramask_[REF(src)]")

/obj/item/clothing/head/eoramask/MouseDrop(atom/over_object)
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(src == C.head || src == C.wear_mask)
			return
	return ..()

/obj/item/clothing/head/eoramask/attack_hand(mob/user, list/modifiers)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head || src == C.wear_mask)
			to_chat(user, "<span class='warning'>I need some time to remove the mask peacefully.</span>")
			if(do_after(user, 50))
				return ..()
			return
	return ..()

/obj/item/clothing/head/necramask
	name = "death mask"
	desc = "A hood with a decorated jaw bone at the chin, normally worn by some followers of Jergal as a form of devotion."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "deathface"
	item_state = "deathface"
	color = null
	body_parts_covered = NECK|MOUTH
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	dynamic_hair_suffix = ""
	sewrepair = TRUE
	ported_clothing = TRUE

/obj/item/clothing/head/roguehood/abyssor_painter
	name = "quicksilver hood"
	desc = "A hood worn by the followers of Umberlee, with a unique spiral wrapping. How do they even see out of this? It's said out of the many pigments of the dream, the most potent resembles quicksilver. Hoods like these are designed to capture the fumes that are given off by the silvery paint... after completing certain rites."
	icon = 'modular_azurepeak/icons/clothing/special/abyssor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/abyssor.dmi'
	sleeved = null
	icon_state = "silverhood"
	item_state = "silverhood"
	color = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
