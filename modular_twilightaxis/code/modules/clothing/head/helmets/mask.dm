/obj/item/clothing/head/helmet/sallet/warden/wolf/wretch
	name = "accursed mask"
	desc = "Mask made from the skull of Volf, detailed with blood of animals and heretics, enchanted with their souls."
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "norswolf"
	item_state = "norswolf"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_HIP|ITEM_SLOT_MASK
	var/on = FALSE
	light_color = LIGHT_COLOR_ORANGE
	light_system = MOVABLE_LIGHT
	light_outer_range = 3
	light_power = 1
	toggle_icon_state = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/sallet/warden/wolf/wretch/Initialize(mapload)
	. = ..()
	set_light_on(FALSE)

/obj/item/clothing/head/helmet/sallet/warden/wolf/wretch/MiddleClick(mob/user, list/modifiers)
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	toggle_helmet_light(user)
	to_chat(user, span_info("I spark [src] [on ? "on" : "off"]."))

/obj/item/clothing/head/helmet/sallet/warden/wolf/wretch/proc/toggle_helmet_light(mob/living/user)
	on = !on
	set_light_on(on)
	if(on)
		playsound(loc, 'modular_azurepeak/sound/effects/hood_ignite.ogg', 100, TRUE)
		do_sparks(2, FALSE, user)
	else
		playsound(loc, 'modular_azurepeak/sound/misc/toggle_lamp.ogg', 100)
	update_appearance()

/obj/item/clothing/head/helmet/sallet/warden/wolf/wretch/update_icon_state()
	. = ..()
	var/state = on ? "norswolf_lit" : "norswolf"
	icon_state = state
	item_state = state
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()
		H.update_inv_wear_mask()

/obj/item/clothing/head/helmet/sallet/warden/wolf/wretch/ResetAdjust(mob/user)
	. = ..()
	if(on)
		set_light_on(FALSE)
	update_appearance()
