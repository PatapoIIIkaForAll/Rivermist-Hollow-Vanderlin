/mob/living/Moved()
	. = ..()
	stop_looking()
	update_turf_movespeed(loc)

	if(m_intent == MOVE_INTENT_RUN)
		consider_ambush()

/mob/living/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return (!density || body_position == LYING_DOWN || (mover.throwing.get_thrower() == src && !ismob(mover)))
	if(buckled == mover)
		return TRUE
	if(ismob(mover))
		if(mover in buckled_mobs)
			return TRUE
		if(isliving(mover))
			var/mob/living/M = mover
			if(M.wallpressed)
				return !wallpressed
			if(pixelshift_lets_pass(M))
				return TRUE
			// check src density instead of mover to prevent prone people from crawling under others
			return (!density || wallpressed || body_position == LYING_DOWN)
	return !mover.density || wallpressed || body_position == LYING_DOWN

/// Pixels past the tile centre a pixel-shifted mob must sit before others can slip past it.
#define PIXEL_SHIFT_PASS_OFFSET 8

/// TRUE if [mover] enters our tile beside us: we are shifted to an edge and it comes in along the other axis.
/mob/living/proc/pixelshift_lets_pass(mob/living/mover)
	if(!pixelshifted)
		return FALSE
	var/entry_dir = get_dir(get_turf(src), get_turf(mover))
	if(!entry_dir)
		return FALSE
	var/open_dirs = NONE
	if(abs(pixelshift_y) > PIXEL_SHIFT_PASS_OFFSET)
		open_dirs |= EAST|WEST
	if(abs(pixelshift_x) > PIXEL_SHIFT_PASS_OFFSET)
		open_dirs |= NORTH|SOUTH
	// A diagonal entry must be open on both of its axes.
	return open_dirs && (entry_dir & open_dirs) == entry_dir

#undef PIXEL_SHIFT_PASS_OFFSET

/mob/living/toggle_move_intent()
	. = ..()
	update_move_intent_slowdown()

/mob/living/toggle_rogmove_intent()
	. = ..()
	update_move_intent_slowdown()

// /mob/living/update_sneak_invis()
// if(m_intent == MOVE_INTENT_SNEAK)
//       return // Placeholder until further implementation
		// Implementation of invisibility or other effects.
		// For illustration:
		// src.set_invisibility(INVISIBILITY_LEVEL_MINIMAL)

/mob/living/def_intent_change()
	. = ..()
	update_move_intent_slowdown()

/mob/living/update_config_movespeed()
	update_move_intent_slowdown()
	return ..()

/mob/living/equip_to_slot_if_possible(obj/item/W, slot, qdel_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, bypass_equip_delay_self = FALSE, initial)
	. = ..()
	update_config_movespeed()

/mob/living/proc/update_move_intent_slowdown()
	var/mod = 0
	switch(m_intent)
		if(MOVE_INTENT_WALK)
			mod = CONFIG_GET(number/movedelay/walk_delay)
		if(MOVE_INTENT_RUN)
			mod = CONFIG_GET(number/movedelay/run_delay)
		if(MOVE_INTENT_SNEAK)
			var/skill = GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking)
			var/sneak_delay = 6 - (skill * 0.25)
			if(HAS_TRAIT(src, TRAIT_LIGHT_STEP))
				sneak_delay -= 0.2
			mod = max(CONFIG_GET(number/movedelay/walk_delay) + 1.5, sneak_delay)
	var/spdchange = (10-GET_MOB_ATTRIBUTE_VALUE(src, STAT_SPEED))*0.1
	spdchange = clamp(spdchange, -0.5, 1)  //if this is not clamped, it can make you go faster than you should be able to.
	mod = mod+spdchange
	//maximum speed is achieved at 15 speed.
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = mod)

/mob/living/proc/update_turf_movespeed(turf/open/T)
	if(isopenturf(T))
		var/usedslow = T.get_slowdown(src)
		if(HAS_TRAIT(src, TRAIT_LONGSTRIDER))
			usedslow = max(0, usedslow - 2)
		if(HAS_TRAIT(src, TRAIT_TRAM_MOVER))
			usedslow = 0
		if(usedslow != 0)
			add_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD, update=TRUE, priority=100, multiplicative_slowdown=usedslow, movetypes=GROUND)
		else
			remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)
	else
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)

/turf/open
	var/mob_overlay

/turf/open/proc/get_mob_overlay()
	return mob_overlay

/mob/living/proc/update_charging_movespeed(datum/intent/I)
	if(I)
		add_movespeed_modifier(MOVESPEED_ID_CHARGING, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=I.charging_slowdown, movetypes=GROUND)
	else
		remove_movespeed_modifier(MOVESPEED_ID_CHARGING)

/mob/living/proc/update_pull_movespeed()
	if(pulling)
		if(pulling != src)
			if(isliving(pulling))
				var/mob/living/L = pulling
				if(!slowed_by_drag || L.body_position == STANDING_UP || L.buckled || grab_state >= GRAB_AGGRESSIVE)
					remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)
					return
				add_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING, multiplicative_slowdown = PULL_PRONE_SLOWDOWN)
				return
			if(isobj(pulling))
				var/obj/structure/S = pulling
				if(!slowed_by_drag || !S.drag_slowdown || HAS_TRAIT(src, TRAIT_CRATEMOVER))
					remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)
					return
				add_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING, multiplicative_slowdown = S.drag_slowdown)
				return

	remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)

/mob/living/can_zFall(turf/T, levels)
	// Carried by something airborne: we go where it goes instead of dropping out of its arms.
	if(buckled?.movement_type & FLYING)
		return FALSE
	return ..()

/mob/living/up()
	if(stat >= UNCONSCIOUS || HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return
	return ..()

/mob/living/down()
	if(stat >= UNCONSCIOUS || HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return
	return ..()

/// Relay z-movement to whatever we are riding, or dismount when the movement does not support buckled mobs.
/mob/living/zMove(direction, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(buckled)
		if(buckled.currently_z_moving)
			return FALSE
		if(!(z_move_flags & ZMOVE_ALLOW_BUCKLED))
			buckled.unbuckle_mob(src, force = TRUE)
		else
			if(!target)
				target = can_z_move(direction, get_turf(src), z_move_flags = z_move_flags, rider = src)
				if(!target)
					return FALSE
			return buckled.zMove(direction, target, z_move_flags)
	return ..()

/// Apply living-specific posture and buckle policy before the generic z-movement checks.
/mob/living/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if((z_move_flags & ZMOVE_LYING_CHECKS) && body_position != STANDING_UP)
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(src, span_warning("I need to stand to do this!"))
		return FALSE
	if((z_move_flags & ZMOVE_INCAPACITATED_CHECKS) && incapacitated())
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, span_warning("[rider ? src : "I"] can't do that right now!"))
		return FALSE
	if(!buckled || !(z_move_flags & ZMOVE_ALLOW_BUCKLED))
		if(!(z_move_flags & ZMOVE_FALL_CHECKS) && incorporeal_move && (!rider || rider.incorporeal_move))
			z_move_flags |= ZMOVE_IGNORE_OBSTACLES
		return ..()
	switch(SEND_SIGNAL(buckled, COMSIG_BUCKLED_CAN_Z_MOVE, direction, start, destination, z_move_flags, src))
		if(COMPONENT_RIDDEN_ALLOW_Z_MOVE)
			return buckled.can_z_move(direction, start, destination, z_move_flags, src)
		if(COMPONENT_RIDDEN_STOP_Z_MOVE)
			return FALSE
		else
			if(!(z_move_flags & ZMOVE_CAN_FLY_CHECKS) && !buckled.anchored)
				return buckled.can_z_move(direction, start, destination, z_move_flags, src)
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(src, span_warning("Unbuckle from [buckled] first."))
			return FALSE

/mob/set_currently_z_moving(new_z_moving_value, forced = FALSE)
	if(buckled && !forced)
		return buckled.set_currently_z_moving(new_z_moving_value, forced)
	return ..()

/mob/living/can_safely_descend(turf/target)
	target = GET_TURF_BELOW(target)
	var/flags = NONE
	for(var/atom/thing as anything in target)
		flags |= thing.intercept_zImpact(src, 1)
		if(flags & FALL_STOP_INTERCEPTING)
			break
	for(var/obj/structure/stairs/S in target)
		return TRUE
	if(flags & FALL_INTERCEPTED)
		return TRUE
	return FALSE

//* Updates a mob's sneaking status, rendering them invisible or visible in accordance to their status. TODO:Fix people bypassing the sneak fade by turning, and add a proc var to have a timer after resetting visibility.
/mob/living/update_sneak_invis(reset = FALSE)
	if(!reset && HAS_TRAIT(src, TRAIT_IMPERCEPTIBLE)) // Check if the mob is affected by the invisibility spell
		rogue_sneaking = TRUE
		return

	if (stat == DEAD) // we're dead, so be visible if sneaking, and end it there. needed because DeadLife calls this constantly on every dead mob that exists
		if (rogue_sneaking)
			animate(src, alpha = initial(alpha), time = 25)
			spawn(25) regenerate_icons()
			rogue_sneaking = FALSE
		return

	var/turf/T = get_turf(src)
	if(!T) //if the turf they're headed to is invalid
		return

	var/light_amount = 0 // populated when needed below
	var/used_time = DEFAULT_MOB_SNEAK_TIME
	var/sneak_skill_level = GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking)
	var/light_threshold = rogue_sneaking_light_threshold
	if(mind)
		used_time = max(used_time - (sneak_skill_level * 8), 0)
		light_threshold += (sneak_skill_level / 100)

	if(!reset && m_intent != MOVE_INTENT_SNEAK && alpha != initial(alpha)) // prevents funny bugs with getting stuck transparent
		if(!wallpressed)
			animate(src, alpha = initial(alpha), time = 10)
			spawn(10) regenerate_icons()
		else
			animate(src, alpha = 255, time = 10)

		rogue_sneaking = FALSE
		return

	if(rogue_sneaking || reset) //If sneaking, check if they should be revealed
		var/should_reveal = FALSE
		// are we crit, sleeping, been recently discovered, have no turf, force-revealed or not in sneak intent? then we should be revealed, end of.
		if((stat > SOFT_CRIT) || IsSleeping() || has_status_effect(/datum/status_effect/debuff/stealthcd) || !T || reset || (m_intent != MOVE_INTENT_SNEAK))
			should_reveal = TRUE

		// are we in a area of light that should reveal us?
		if (!should_reveal)
			light_amount = T.get_lumcount() // this is moderately expensive, so only check it if we really need to
			if (light_amount >= light_threshold)
				should_reveal = TRUE

		if (should_reveal)
			used_time = round(clamp((50 - (used_time*1.75)), 5, 50),1)
			if(!wallpressed) // so we can stay partially invisible if wallpressed
				animate(src, alpha = initial(alpha), time =	used_time) //sneak skill makes you reveal slower but not as drastic as disappearing speed
				spawn(used_time) regenerate_icons()
			else
				if(src.alpha != 255)
					animate(src, alpha = 255, time = used_time)
			rogue_sneaking = FALSE
			SEND_SIGNAL(src, COMSIG_MOB_BREAK_SNEAK)
			return

	else //not currently sneaking, check if we can sneak
		if (m_intent == MOVE_INTENT_SNEAK) // we were not sneaking and are now trying to.
			if(wallpressed)
				update_wallpress_slowdown()
			var/target_alpha = 255
			if(resting)
				target_alpha = get_lying_alpha()
			if(target_alpha != alpha)
				if(!wallpressed)
					animate(src, alpha = target_alpha, time = used_time)
					spawn(used_time + 5) regenerate_icons()
			if(has_status_effect(/datum/status_effect/debuff/stealthcd)) // recently discovered or broke stealth, can't re-sneak yet
				return
			light_amount = T.get_lumcount()  // as above, this is moderately expensive, so only check it if we need to.
			if(light_amount < light_threshold)
				animate(src, alpha = 0, time = used_time)
				spawn(used_time + 5) regenerate_icons()
				rogue_sneaking = TRUE
	return

/mob/living/proc/get_lying_alpha()
	var/skill_level = GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking)

	switch(skill_level)
		if(1) return 178 //30%
		if(2) return 140 //45%
		if(3) return 128 //50%
		if(4) return 102 //60%
		if(5) return 77 //70%
		if(6) return 51 //80%

	return 255

/mob/living/proc/get_wallpress_alpha()
	var/skill_level = GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking)

	switch(skill_level)
		if(1) return 128 //50%
		if(2) return 115 //55%
		if(3) return 102 //60%
		if(4) return 90  //65%
		if(5) return 77  //70%
		if(6) return 64  //75%

	return 255
