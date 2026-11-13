/mob/living/simple_animal/mothbug
	var/flying = FALSE
	/// Lets people below stab upward at a mothbug flying over open space.
	var/obj/effect/flyer_shadow/flight_shadow

/datum/action/cooldown/mothbug/take_wing
	name = "Take Wing"
	desc = "Take off or land. Flight is free, as fast as a running person, and rises into open sky above when there is room."
	button_icon_state = "flight"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/mothbug/take_wing/Grant(mob/grant_to)
	. = ..()
	// Living mobs already listen to their own immobilize trait, so the action listens instead.
	RegisterSignal(grant_to, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_owner_immobilized))

/datum/action/cooldown/mothbug/take_wing/Remove(mob/remove_from)
	UnregisterSignal(remove_from, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED))
	return ..()

/datum/action/cooldown/mothbug/take_wing/proc/on_owner_immobilized(mob/living/simple_animal/mothbug/source)
	SIGNAL_HANDLER
	if(istype(source) && source.flying)
		source.fall_mothbug()

/datum/action/cooldown/mothbug/take_wing/is_action_active(atom/movable/screen/movable/action_button/current_button)
	var/mob/living/simple_animal/mothbug/moth = owner
	return istype(moth) && moth.flying

/datum/action/cooldown/mothbug/take_wing/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	if(moth.flying)
		if(!do_after(moth, MOTHBUG_LAND_TIME, moth, IGNORE_USER_LOC_CHANGE))
			return FALSE
		if(moth.flying)
			moth.land_mothbug()
		StartCooldown()
		return TRUE
	if(!moth.can_take_wing(TRUE))
		return FALSE
	moth.visible_message(span_notice("[moth] flutters its wings faster and faster."), span_notice("I beat my wings to take off."), vision_distance = 4)
	if(!do_after(moth, MOTHBUG_TAKEOFF_TIME, moth, extra_checks = CALLBACK(moth, TYPE_PROC_REF(/mob/living/simple_animal/mothbug, can_take_wing))))
		return FALSE
	moth.start_mothbug_flight()
	StartCooldown()
	return TRUE

/mob/living/simple_animal/mothbug/proc/can_take_wing(feedback = FALSE)
	var/reason
	if(flying)
		reason = "already flying!"
	else if(!isturf(loc) || buckled)
		reason = "no room to fly!"
	else if(pulledby)
		reason = "someone is holding me!"
	else if(body_position != STANDING_UP || HAS_TRAIT(src, TRAIT_IMMOBILIZED) || stat != CONSCIOUS)
		reason = "can't spread my wings!"
	if(!reason)
		return TRUE
	if(feedback)
		balloon_alert(src, reason)
	return FALSE

/mob/living/simple_animal/mothbug/proc/start_mothbug_flight()
	set_mothbug_hidden(FALSE)
	stop_pulling()
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, MOTHBUG_FLIGHT_TRAIT)
	flying = TRUE
	icon_state = "[icon_living]_fly"
	add_movespeed_modifier(MOVESPEED_ID_MOTHBUG_FLIGHT, multiplicative_slowdown = MOTHBUG_FLIGHT_SPEED - speed)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_flight_moved))
	RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_flight_damaged))
	playsound(src, 'sound/mobs/wingflap.ogg', 50, FALSE)
	to_chat(src, span_notice("I take to the air."))
	update_take_wing_button()
	var/turf/here = get_turf(src)
	var/turf/above = GET_TURF_ABOVE(here)
	if(isopenspace(above) && can_z_move(UP, here, above, ZMOVE_FLIGHT_FLAGS))
		set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		zMove(UP, above, ZMOVE_FLIGHT_FLAGS)

/// Lands gently, dropping a level first when hovering over open space.
/mob/living/simple_animal/mothbug/proc/land_mothbug()
	var/turf/here = get_turf(src)
	if(isturf(loc) && isopenspace(here) && can_z_move(DOWN, here, null, ZMOVE_FLIGHT_FLAGS))
		zMove(DOWN, GET_TURF_BELOW(here), ZMOVE_FLIGHT_FLAGS)
	to_chat(src, span_notice("I settle back to the ground."))
	end_mothbug_flight()

/mob/living/simple_animal/mothbug/proc/fall_mothbug()
	if(!flying)
		return
	visible_message(span_warning("[src] tumbles out of the air!"), span_userdanger("I tumble out of the air!"))
	end_mothbug_flight()

/mob/living/simple_animal/mothbug/proc/end_mothbug_flight()
	if(!flying)
		return
	flying = FALSE
	REMOVE_TRAIT(src, TRAIT_MOVE_FLYING, MOTHBUG_FLIGHT_TRAIT)
	remove_movespeed_modifier(MOVESPEED_ID_MOTHBUG_FLIGHT)
	UnregisterSignal(src, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_APPLY_DAMAGE))
	QDEL_NULL(flight_shadow)
	icon_state = stat == DEAD ? icon_dead : icon_living
	update_take_wing_button()
	var/turf/here = get_turf(src)
	if(isturf(loc) && isopenspace(here))
		here.zFall(src)

/mob/living/simple_animal/mothbug/proc/update_take_wing_button()
	for(var/datum/action/cooldown/mothbug/take_wing/wing_action in innate_actions)
		wing_action.build_all_button_icons(UPDATE_BUTTON_BACKGROUND)

/mob/living/simple_animal/mothbug/proc/on_flight_moved(datum/source)
	SIGNAL_HANDLER
	if(!isturf(loc))
		end_mothbug_flight()
		return
	update_flight_shadow()

/mob/living/simple_animal/mothbug/proc/update_flight_shadow()
	var/turf/here = get_turf(src)
	var/turf/below = GET_TURF_BELOW(here)
	if(!below || !istransparentturf(here))
		QDEL_NULL(flight_shadow)
		return
	if(QDELETED(flight_shadow))
		flight_shadow = new(below, src)
	else
		flight_shadow.forceMove(below)

/mob/living/simple_animal/mothbug/proc/on_flight_damaged(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damagetype != BRUTE && damagetype != BURN)
		return
	if(prob(damage / 4))
		fall_mothbug()
		Knockdown(2 SECONDS)
