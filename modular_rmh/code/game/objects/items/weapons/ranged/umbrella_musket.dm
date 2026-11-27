/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella
	name = "umbrella musket"
	desc = "An inconspicuous high-class umbrella at the first sight, it's unusual handle betrays it's true nature as an actual combat musket. It's quite unwieldy due to it's shape and general form."
	icon = 'modular_rmh/icons/obj/items/weapons/ranged/musket.dmi'
	icon_state = "umbrella_icon_closed"
	item_state = "umbrella_closed"
	lefthand_file = 'modular_rmh/icons/obj/items/weapons/ranged/musket_lefthand.dmi'
	righthand_file = 'modular_rmh/icons/obj/items/weapons/ranged/musket_righthand.dmi'
	bigboy = FALSE
	experimental_inhand = FALSE
	experimental_onhip = TRUE
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_HIP
	var/umbrella_state = FALSE
	alternate_worn_layer = BODY_FRONT_LAYER
	possible_item_intents = list(/datum/intent/dagger/thrust/stiletto, INTENT_GENERIC)
	force = DAMAGE_DAGGER
	wdefense = AVERAGE_PARRY
	wbalance = HARD_TO_DODGE
	max_blade_int = 400

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/attack_self(mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	toggle_state(user)
	return TRUE

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/proc/toggle_state(mob/user)
	umbrella_state = !umbrella_state
	if(user)
		to_chat(user, span_info("I [umbrella_state ? "open" : "close"] \the [src]."))
	update_held_appearance()

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(!umbrella_state || !(slot & (ITEM_SLOT_BACK | ITEM_SLOT_HIP)))
		return
	umbrella_state = FALSE
	update_appearance(UPDATE_ICON_STATE)
	if(slot & ITEM_SLOT_BACK)
		user.update_inv_back()
	else
		user.update_inv_belt()

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/attackby(obj/item/I, mob/user, list/modifiers)
	if(istype(I, /obj/item/weapon/knife/dagger/bayonet))
		to_chat(user, span_warning("There is nowhere to fix a bayonet on \the [src]."))
		return
	return ..()

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/update_icon_state()
	. = ..()
	if(umbrella_state)
		icon_state = "umbrella_icon_open"
		item_state = "umbrella_open"
	else
		icon_state = "umbrella_icon_closed"
		item_state = "umbrella_closed"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/getonmobprop(tag)
	switch(tag)
		if("onback")
			return list("shrink" = 1,"sx" = 0,"sy" = -1,"nx" = 0,"ny" = -1,"wx" = 3,"wy" = -1,"ex" = -2,"ey" = -1,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
		if("onbelt")
			return list("shrink" = 0.5,"sx" = -5,"sy" = -4,"nx" = 5,"ny" = -4,"wx" = 0,"wy" = -4,"ex" = 1,"ey" = -4,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
	return ..()

/// Worn overlays come out on a 64 px canvas, but the 32 px inhands stop the mob code from centering it.
/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/umbrella/generateonmob(tag, prop, behind, mirrored)
	. = ..()
	if(!. || (tag != "onback" && tag != "onbelt"))
		return
	var/icon/centered = icon('icons/roguetown/helpers/inhand_64.dmi', "blank")
	centered.Blend(., ICON_OVERLAY, -15, -15)
	return centered
