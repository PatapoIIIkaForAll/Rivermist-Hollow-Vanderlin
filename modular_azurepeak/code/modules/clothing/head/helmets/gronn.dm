/obj/item/clothing/head/helmet/leather/shaman_hood
	name = "moose hood"
	desc = "A deceptively strong moosehide hood with a pair of large heavy antlers. It is the reward of the fourth trial of the The Uthgardt holds Shamans: To slay a Grinning Moose in the final hunt alone - and fashion a hood from its head."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/32x48/gronn.dmi'
	sleeved = null
	icon_state = "gronnfurhood"
	item_state = "gronnfurhood"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_HIP
	body_parts_covered = HEAD|HAIR|EARS|NOSE
	armor_type = /datum/armor/ported/leather
	flags_inv = HIDEEARS|HIDEFACE
	worn_x_dimension = 32
	worn_y_dimension = 48
	sellprice = 10
	anvilrepair = null
	smeltresult = null
	sewrepair = TRUE
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_HELMET_HARDLEATHER
	salvage_result = /obj/item/natural/hide/cured
	var/on = FALSE
	var/lux_consumed = FALSE
	var/lux_color = LIGHT_COLOR_CYAN
	adjustable = CAN_CADJUST
	light_color = LIGHT_COLOR_ORANGE
	light_system = MOVABLE_LIGHT
	light_outer_range = 3
	light_power = 1
	toggle_icon_state = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/leather/shaman_hood/Initialize(mapload)
	. = ..()
	set_light_on(FALSE)

/obj/item/clothing/head/helmet/leather/shaman_hood/MiddleClick(mob/user, list/modifiers)
	if(.)
		return
	if(adjustable == CADJUSTED)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	toggle_helmet_light(user)
	to_chat(user, span_info("I spark [src] [on ? "on" : "off"]."))

/obj/item/clothing/head/helmet/leather/shaman_hood/proc/toggle_helmet_light(mob/living/user)
	on = !on
	set_light_on(on)
	if(on)
		playsound(loc, 'modular_azurepeak/sound/effects/hood_ignite.ogg', 100, TRUE)
		do_sparks(2, FALSE, user)
	else
		playsound(loc, 'modular_azurepeak/sound/misc/toggle_lamp.ogg', 100)
	update_appearance()

/obj/item/clothing/head/helmet/leather/shaman_hood/update_icon_state()
	. = ..()
	if(adjustable == CADJUSTED)
		return
	var/state = on ? "gronnfurhood_lit[lux_consumed ? "3" : "2"]" : "gronnfurhood"
	icon_state = state
	item_state = state
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()

/obj/item/clothing/head/helmet/leather/shaman_hood/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/I = attacking_item
	if(istype(I, /obj/item/reagent_containers/lux))
		if(adjustable == CADJUSTED)
			to_chat(user, span_warning("The hood must be up for this to work!"))
			return
		if(lux_consumed)
			to_chat(user, span_warning("It has already been infused."))
			return
		to_chat(user, span_warning("I infuse the hood with the soul energies!"))
		lux_consumed = TRUE
		set_light_range_power_color(6, 2, lux_color) //The light is doubled
		if(!on)
			toggle_helmet_light(user)
		else
			update_appearance()
		qdel(I)
	. = ..()

/obj/item/clothing/head/helmet/leather/shaman_hood/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			playsound(src, 'sound/foley/equip/rummaging-03.ogg', 50, TRUE)
			if(on)
				toggle_helmet_light(user)
			if(toggle_icon_state)
				icon_state = "gronnfurhood_down"
				item_state = "gronnfurhood_down"
			adjustable = CADJUSTED
			flags_inv = null
			body_parts_covered = null
		else if(adjustable == CADJUSTED)
			playsound(src, 'modular_azurepeak/sound/foley/equip/cloak (3).ogg', 50, TRUE)
			ResetAdjust(user)
		if(ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_neck()
			H.update_inv_head()

/obj/item/clothing/head/helmet/leather/shaman_hood/ResetAdjust(mob/user)
	. = ..()
	if(on)
		set_light_on(FALSE)
	update_appearance()

/obj/item/clothing/head/helmet/bascinet/atgervi/gronn
	name = "Uthgardt ravager helm"
	desc = "A helmet of hardened leather fitted with a carved animal skull, a design of the Uthgardt tribes beyond the Spine of the World. It is said to frighten the spirits of the defeated, keeping them from haunting the warrior who slew them."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = null
	icon_state = "gronnleatherhelm"
	item_state = "gronnleatherhelm"
	block2add = null
	body_parts_covered = HEAD|HAIR|EARS|EYES|NOSE
	worn_x_dimension = 32
	worn_y_dimension = 32
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/bucket/gronn
	name = "Uthgardt norsii horned helmet"
	desc = "One of the Uthgardt's infamous horned helms of solid iron. Styled after the invaders of legend who came from beyond the Spine of the World, brutal and bare, it is a reminder of a time before there was snow."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/64x64/gronn.dmi'
	sleeved = null
	icon_state = "gronnplatehelm"
	item_state = "gronnplatehelm"
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/iron
	worn_x_dimension = 64
	worn_y_dimension = 64
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
