/mob
	/// Cosmetic angle in degrees, kept apart from posture and facing.
	var/pixel_rotation = 0

/client
	/// Shares one rotation step per tick between key presses and held keys.
	var/next_pixel_rotation = 0
	/// Cooldown for the lift and "too heavy to tip over" messages.
	var/next_pixel_lift_message = 0

/datum/keybinding/living/pixel_rotate_reset
	hotkey_keys = list()
	name = "pixel_rotate_reset"
	full_name = "Pixel Rotate: Reset"
	description = "Reset cosmetic rotation while keeping your pixel position."

/datum/keybinding/living/pixel_rotate_reset/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/pose_target = user.mob.get_pixel_shift_target()
	if(isliving(pose_target))
		pose_target.reset_pixel_rotation()
	return TRUE

/mob/proc/pixel_rotate(angle, mob/living/poser)
	return

/mob/living/carbon/pixel_rotate(angle, mob/living/poser)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM) || !isturf(loc))
		return
	// Mounts allow rotation; chairs, beds and other buckles do not.
	if(buckled && (!isliving(buckled) || !buckled.GetComponent(/datum/component/riding)))
		return
	if(body_position == STANDING_UP)
		angle = get_standing_rotation_step(angle, poser)
	if(!angle)
		return
	var/matrix/new_transform = matrix(transform)
	new_transform.Turn(angle)
	transform = new_transform
	pixel_rotation = ((pixel_rotation + angle) % 360 + 360) % 360
	// Moving off the pose clears the rotation through update_pixelshift().
	pixelshifted = TRUE

/// Returns the allowed part of a rotation step for a standing mob.
/mob/living/carbon/proc/get_standing_rotation_step(angle, mob/living/poser)
	// Stored angles wrap through 360; the lean is measured from upright.
	var/current_lean = pixel_rotation > 180 ? pixel_rotation - 360 : pixel_rotation
	var/new_lean = current_lean + angle
	if(abs(new_lean) <= PIXEL_ROTATION_STANDING_LIMIT || abs(new_lean) < abs(current_lean))
		return angle
	// Past the limit only a grabber who passes the lift check can tip us further.
	var/obj/item/grabbing/grab = poser?.get_inactive_held_item()
	if(poser && poser != src && istype(grab) && grab.grabbed == src)
		if(poser.can_pixel_lift(src))
			if(abs(current_lean) <= PIXEL_ROTATION_STANDING_LIMIT)
				start_pixel_lift(poser, grab)
			return angle
		poser.show_pixel_lift_failure(src)
	if(abs(current_lean) >= PIXEL_ROTATION_STANDING_LIMIT)
		return 0
	return clamp(new_lean, -PIXEL_ROTATION_STANDING_LIMIT, PIXEL_ROTATION_STANDING_LIMIT) - current_lean

/mob/living/carbon/proc/start_pixel_lift(mob/living/poser, obj/item/grabbing/grab)
	if(poser.client && world.time >= poser.client.next_pixel_lift_message)
		poser.client.next_pixel_lift_message = world.time + 5 SECONDS
		poser.visible_message(span_notice("[poser] lifts [src] off [p_their()] feet!"), span_notice("I lift [src] off [p_their()] feet."))
	RegisterSignal(grab, COMSIG_PARENT_QDELETING, PROC_REF(on_pixel_lift_grab_deleted), override = TRUE)

/// The grab that held us up is gone; a standing body falls back to the lean limit.
/mob/living/carbon/proc/on_pixel_lift_grab_deleted(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src) || body_position != STANDING_UP)
		return
	var/current_lean = pixel_rotation > 180 ? pixel_rotation - 360 : pixel_rotation
	if(abs(current_lean) <= PIXEL_ROTATION_STANDING_LIMIT)
		return
	var/settled_lean = current_lean > 0 ? PIXEL_ROTATION_STANDING_LIMIT : -PIXEL_ROTATION_STANDING_LIMIT
	var/matrix/new_transform = matrix(transform)
	new_transform.Turn(settled_lean - current_lean)
	transform = new_transform
	pixel_rotation = (settled_lean + 360) % 360

/// Lift power minus what tipping the target over takes; zero or more passes.
/mob/living/proc/get_pixel_lift_margin(mob/living/target, resisting)
	var/height_bonus = round((get_grind_body_height() - target.get_grind_body_height()) * PIXEL_LIFT_HEIGHT_POINTS)
	var/power = GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH) + height_bonus
	var/required = GET_MOB_ATTRIBUTE_VALUE(target, STAT_CONSTITUTION) + PIXEL_LIFT_STRENGTH_MARGIN
	// A target in combat mode fights back; a calm one is only dead weight.
	if(resisting)
		required += round(GET_MOB_ATTRIBUTE_VALUE(target, STAT_STRENGTH) / 2)
	return power - required

/mob/living/proc/can_pixel_lift(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_TINY))
		return TRUE
	return get_pixel_lift_margin(target, target.cmode) >= 0

/mob/living/proc/show_pixel_lift_failure(mob/living/target)
	if(!client || world.time < client.next_pixel_lift_message)
		return
	client.next_pixel_lift_message = world.time + 2 SECONDS
	if(target.cmode && get_pixel_lift_margin(target, FALSE) >= 0)
		to_chat(src, span_warning("[target] struggles too hard for me to tip [target.p_them()] over."))
	else
		to_chat(src, span_warning("[target] is too heavy for me to tip over."))

/mob/living/proc/reset_pixel_rotation()
	if(!pixel_rotation)
		return
	var/matrix/new_transform = matrix(transform)
	new_transform.Turn(-pixel_rotation)
	transform = new_transform
	pixel_rotation = 0

/// Returns the rotation step for a key. Q and E always rotate while posing.
/client/proc/pixel_rotation_key_angle(key)
	switch(key)
		if("Q")
			return -5
		if("E")
			return 5
	return 0

/// Repeats held rotation keys and returns the movement directions still held.
/client/proc/process_pixel_shift_input()
	var/angle = 0
	var/movement_dir = NONE
	for(var/key in keys_held)
		var/key_angle = pixel_rotation_key_angle(key)
		if(key_angle)
			angle += key_angle
		else
			movement_dir |= movement_keys[key]
	if(angle)
		step_pixel_rotation(clamp(angle, -5, 5))
	return movement_dir

/client/proc/step_pixel_rotation(angle)
	if(world.time < next_pixel_rotation)
		return
	next_pixel_rotation = world.time + world.tick_lag
	var/mob/target = mob.get_pixel_shift_target()
	target?.pixel_rotate(angle, mob)

/// Resolves the pose target on every input, so hand swaps and released grabs apply at once.
/mob/proc/get_pixel_shift_target()
	return src

/mob/living/carbon/get_pixel_shift_target()
	if(stat != CONSCIOUS || HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	if(get_active_held_item() || !has_active_hand())
		return src
	var/obj/item/grabbing/grab = get_inactive_held_item()
	if(!istype(grab))
		return src
	if(QDELETED(grab) || grab.grabbee != src || !isliving(grab.grabbed))
		return
	var/mob/living/target = grab.grabbed
	if(QDELETED(target) || !Adjacent(target) || HAS_TRAIT(target, TRAIT_NO_TRANSFORM) || target.buckled || !isturf(target.loc))
		return
	return target
