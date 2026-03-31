#define STONE_TRANSFORMATION_MANA_COST 100

/datum/mind
	var/list/known_waystones


/obj/structure/rmh_waystone
	name = "Waystone"
	desc = "A large piece of stone with magical runes. It is mainly used with a pair of small guide stones."

	icon = 'modular_rmh/icons/obj/waystone.dmi'
	icon_state = "waystone"
	base_icon_state = "waystone"

// Lightning
	light_power = 2
	light_inner_range = 1
	light_outer_range = 2
	light_color = LIGHT_COLOR_PINK
	light_system = MOVABLE_LIGHT

	density = TRUE
	anchored = TRUE

	/// dirs where waystone will try to teleport (in case of dir specific waystone)
	var/tp_dir = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	/// sound when someone start teleporting on waystone
	var/tp_sound_start = null
	/// sound when someone ends teleporting on waystone
	var/tp_sound_end = 'sound/magic/swap.ogg'

	/// tp_time = waystone tp_time + waystone chunk tp_time (min 1 second)
	var/tp_time = 5 SECONDS
	var/memorise_time = 5 SECONDS

	/// counter, used for pair_update_visual flick animation
	var/current_tp_num = 0

/obj/structure/rmh_waystone/attack_hand(mob/user, list/modifiers)
	if(!user || !user.mind)
		return
	if(user.mind.known_waystones && (src in user.mind.known_waystones))
		user.show_message("<span class='warning'>You already know the runes of this waystone.</span>")
		return

	user.visible_message(span_info("[user] begins to study the runes on [src]."), span_info("You begins to study the runes on [src]."))
	if(do_after(user, memorise_time, src))
		user.show_message("<span class='notice'>You memorise patterns of the runes and now can teleport via waystone chunks.</span>")
		LAZYADD(user.mind.known_waystones, src)

/obj/structure/rmh_waystone/attackby(obj/item/attacking_item, mob/user, list/modifiers)

/obj/structure/rmh_waystone/update_icon()
	. = ..()
	if(current_tp_num)
		icon_state = "[base_icon_state]-active"
	else
		icon_state = "[base_icon_state]"

/obj/item/rmh_waystone_chunk
	name = "Waystone chunk"
	desc = "A small piece of stone with magical runes. It is mainly used with a waystones."

	icon = 'modular_rmh/icons/obj/waystone.dmi'
	icon_state = "waystone-chunk"
	base_icon_state = "waystone-chunk"

	light_color = LIGHT_COLOR_PINK
	light_on = FALSE
	light_system = MOVABLE_LIGHT

	slot_flags = ITEM_SLOT_MOUTH
	w_class = WEIGHT_CLASS_SMALL
	grid_height = 32
	grid_width = 32

	var/max_charges = 10
	var/charges = 10

	/// tp_time = waystone tp_time + waystone chunk tp_time (min 1 second)
	var/tp_time = 5 SECONDS
	var/tp_sound_start = 'sound/magic/teleport_diss.ogg'

	/// the amount of mana required to restore 1 charge
	var/mana_per_charge = 25
	var/recharge_time = 5 SECONDS
	var/recharging_sound = 'sound/magic/fleshtostone.ogg'

	var/in_teleporting = FALSE

/obj/item/rmh_waystone_chunk/empty
	charges = 0
	icon_state = "waystone-chunk-empty"

/obj/item/rmh_waystone_chunk/update_icon()
	. = ..()
	if(in_teleporting)
		icon_state = "[base_icon_state]-active"
	else if(charges <= 0)
		icon_state = "[base_icon_state]-empty"
	else
		icon_state = "[base_icon_state]"

/obj/item/rmh_waystone_chunk/proc/pair_update_visual(obj/structure/rmh_waystone/waystone, activate = FALSE)
	in_teleporting = activate
	set_light_on(activate)
	if(activate)
		flick("[base_icon_state]-activate", src)
		if(waystone.current_tp_num)
			flick("[waystone.base_icon_state]-pulse", waystone)
		else
			flick("[waystone.base_icon_state]-activate", waystone)
		waystone.current_tp_num++
	else
		waystone.current_tp_num = max(0, waystone.current_tp_num - 1)

	update_icon()
	waystone.update_icon()

/obj/item/rmh_waystone_chunk/examine(mob/user)
	. = ..()
	if(user.mana_pool.amount >= mana_per_charge)
		. += span_notice("RMB in hand to recharge [src] power.")

/obj/item/rmh_waystone_chunk/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if(!user || !user.mind)
		return
	if(user.mana_pool.amount < mana_per_charge)
		user.show_message("<span class='warning'>[src] needs more mana to recharge.</span>")
		return
	if(charges >= max_charges)
		user.show_message("<span class='notice'>[src] does not need to be recharged.</span>")
		return

	user.show_message("<span class='notice'>You squeeze [src] in your hand and concentrate your mana on it.</span>")
	while(charges < max_charges)
		user.mana_pool.adjust_mana(-mana_per_charge)
		playsound(src, recharging_sound, 20)
		if(!do_after(user, recharge_time, src))
			break
		charges++
		update_icon()
		if(user.mana_pool.amount < mana_per_charge)
			user.show_message("<span class='notice'>[src] is recharged, but not completely</span>")
			return
	if(charges == max_charges)
		user.show_message("<span class='notice'>[src] is completely charged.</span>")

/obj/item/rmh_waystone_chunk/attack_self(mob/user, list/modifiers)
	. = ..()
	if(!user || !user.mind)
		return
	if(charges <= 0)
		user.show_message("<span class='warning'>[src] needs to be recharged before it can be used again.</span>")
		return
	if(!user.mind.known_waystones)
		user.show_message("<span class='warning'>You don't know any waystone to teleport on them.</span>")
		return
	if(listclearnulls(user.mind.known_waystones))
		user.show_message("<span class='warning'>You feel that your thoughts about some waystones are confused and lost.</span>")

	var/obj/structure/rmh_waystone/choosed_waystone = tgui_input_list(user, "Select a waystone:", "Waystone teleport", user.mind.known_waystones)
	if(!choosed_waystone)
		return

	pair_update_visual(choosed_waystone, activate = TRUE)
	user.visible_message(span_info("[user] is clutching [src]."), span_info("You clutching [src] and start thinking about [choosed_waystone]."))
	var/teleport_time = max(1 SECONDS, tp_time + choosed_waystone.tp_time)
	if(choosed_waystone.tp_sound_start)
		playsound(choosed_waystone, tp_sound_start, 20)

	if(tp_sound_start)
		playsound(src, tp_sound_start, 50)
	if(!use_tool(user, user, teleport_time, volume = 50))
		pair_update_visual(choosed_waystone, activate = FALSE)
		return

	if(!choosed_waystone)
		user.show_message("<span class='warning'>You feel that your thoughts about some waystones are confused and lost.</span>")
		return

	var/list/valid_tp_points = list()
	for(var/dir_check in choosed_waystone.tp_dir)
		var/turf/neighbor_turf = get_step(choosed_waystone, dir_check)
		if(!neighbor_turf || neighbor_turf.density)
			continue
		valid_tp_points += neighbor_turf

	if(!valid_tp_points)
		user.show_message("<span class='warning'>You feel like something blocking your path to waystone and prefer don't risk.</span>")
	else
		var/turf/teleport_loc = pick(valid_tp_points)
		user.forceMove(teleport_loc)
		if(choosed_waystone.tp_sound_end)
			playsound(choosed_waystone, choosed_waystone.tp_sound_end, 20, TRUE)
		charges--
		if(charges <= 0)
			user.show_message("<span class='warning'>[src] runes darken and weaken.</span>")

	pair_update_visual(choosed_waystone, activate = FALSE)


/obj/item/natural/stone/examine(mob/user)
	. = ..()
	if(user.mana_pool.amount >= STONE_TRANSFORMATION_MANA_COST)
		. += span_notice("RMB in hand to tranform [src] into the waystone chunk.")

/obj/item/natural/stone/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if(user.mana_pool.amount <= STONE_TRANSFORMATION_MANA_COST)
		return

	user.show_message("<span class='notice'>You squeeze [src] in your hand and concentrate your mana on it.</span>")
	playsound(src, 'sound/magic/diagnose.ogg', 10)

	if(!do_after(user, 20 SECONDS, src))
		return

	user.mana_pool.adjust_mana(-STONE_TRANSFORMATION_MANA_COST)
	playsound(src, 'sound/magic/antimagic.ogg', 30)
	user.dropItemToGround(src, TRUE, TRUE)
	var/obj/item/rmh_waystone_chunk/empty/waystone_chunk = new(get_turf(src))
	user.put_in_active_hand(waystone_chunk, TRUE, TRUE)
	user.show_message("<span class='warning'>When you relax your hand, you see [waystone_chunk] in it.</span>")
	qdel(src)

#undef STONE_TRANSFORMATION_MANA_COST
