// Partner dancing, ported from Ochre Valley.
// Hold your partner's hand with a gentle grip, both of you relaxed, and right-click them with the grab:
// you twirl around each other and swap places. Leading with your right hand spins clockwise, with your left counterclockwise.

#define DANCE_DURATION (2 SECONDS)
#define DANCE_TRAIT "dance"
/// How many pixels the dancers step towards each other before the spin.
#define DANCE_CLOSE_IN 8

/obj/item/grabbing/pre_attack_secondary(atom/target, mob/living/user, list/modifiers)
	if(target == grabbed && user.try_dance(src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/// Returns TRUE if the click was taken as a dance attempt, even a refused one.
/mob/living/proc/try_dance(obj/item/grabbing/grab)
	var/mob/living/carbon/partner = grab.grabbed
	if(!istype(partner))
		return FALSE
	if(grab.sublimb_grabbed != BODY_ZONE_PRECISE_L_HAND && grab.sublimb_grabbed != BODY_ZONE_PRECISE_R_HAND)
		return FALSE
	// A tight grip or a fight means this is not a dance; leave the click to the grab.
	if(grab.grab_state != GRAB_PASSIVE || cmode || partner.cmode)
		return FALSE

	if(!(get_dir(src, partner) in GLOB.cardinals))
		to_chat(src, span_warning("I cannot dance at this strange angle, I should line up with [partner]."))
		return TRUE

	dance_with(partner, counterclockwise = (active_hand_index % 2) != 0)
	return TRUE

/mob/living/proc/dance_with(mob/living/carbon/partner, counterclockwise = FALSE)
	var/turf/start_turf = get_turf(src)
	var/turf/partner_start_turf = get_turf(partner)
	var/list/start_offset = list(pixel_x, pixel_y)
	var/list/partner_start_offset = list(partner.pixel_x, partner.pixel_y)
	// Snapshot both dancers before they are hidden, the stand-ins wear these.
	var/mutable_appearance/look = new(src)
	var/mutable_appearance/partner_look = new(partner)

	if(!swap_places_with(partner))
		to_chat(src, span_warning("I can't dance with [partner] here."))
		return FALSE

	var/dir_after = get_dir(src, partner)
	setDir(dir_after)
	partner.setDir(turn(dir_after, 180))

	var/list/passes = calculate_dance_passes(
		list(base_pixel_x, base_pixel_y), start_offset, list(pixel_x, pixel_y),
		list(partner.base_pixel_x, partner.base_pixel_y), partner_start_offset, list(partner.pixel_x, partner.pixel_y),
		counterclockwise, dir_after,
	)

	start_dance(start_turf, look, passes["lead"])
	partner.start_dance(partner_start_turf, partner_look, passes["partner"])
	return TRUE

/// Hides us, spins a stand-in wearing our old look from start_turf, holds the camera there, and restores everything after.
/mob/living/proc/start_dance(turf/start_turf, mutable_appearance/look, list/passes)
	// The real mob hides while the stand-in performs the spin. Invisibility hides us from others,
	// alpha hides us from ourselves too, since living mobs see themselves through any invisibility.
	invisibility = INVISIBILITY_ABSTRACT
	alpha = 0
	Immobilize(DANCE_DURATION)
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, DANCE_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(end_dance), look.invisibility, look.alpha), DANCE_DURATION)

	var/list/first = passes[1]
	look.dir = first["dir"]
	look.layer = first["layer"]
	look.pixel_x = first["x"]
	look.pixel_y = first["y"]
	var/obj/effect/temp_visual/dance_stand_in/stand_in = new(start_turf)
	stand_in.appearance = look

	if(client)
		// Moving reset our view to the new turf; keep it on the old one so it can glide along with the spin.
		client.perspective = EYE_PERSPECTIVE
		client.eye = start_turf
		hide_cone()

	var/step_time = DANCE_DURATION / (length(passes) - 1)
	for(var/i in 2 to length(passes))
		var/list/pass = passes[i]
		var/list/animate_args = list("dir" = pass["dir"], "pixel_x" = pass["x"], "pixel_y" = pass["y"])
		if(!isnull(pass["layer"]))
			animate_args["layer"] = pass["layer"]
		animate(stand_in, animate_args, time = step_time, flags = ANIMATION_CONTINUE)
		if(client)
			animate(client, pixel_x = pass["x"], pixel_y = pass["y"], time = step_time, flags = ANIMATION_CONTINUE)

/mob/living/proc/end_dance(original_invisibility, original_alpha)
	invisibility = original_invisibility
	alpha = original_alpha
	REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, DANCE_TRAIT)
	reset_perspective()
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0
	update_cone_show()

/// Swaps turfs with the partner without bumping anyone else. Mirrors the swap in MobBump.
/mob/living/proc/swap_places_with(mob/living/partner)
	var/turf/our_turf = loc
	var/turf/partner_turf = partner.loc
	var/our_passmob = pass_flags & PASSMOB
	var/partner_passmob = partner.pass_flags & PASSMOB
	var/our_animate_movement = animate_movement
	var/partner_animate_movement = partner.animate_movement
	pass_flags |= PASSMOB
	partner.pass_flags |= PASSMOB
	animate_movement = NO_STEPS
	partner.animate_movement = NO_STEPS

	var/swapped = partner.Move(our_turf) && Move(partner_turf)
	if(!swapped)
		forceMove(our_turf)
		partner.forceMove(partner_turf)

	if(!our_passmob)
		pass_flags &= ~PASSMOB
	if(!partner_passmob)
		partner.pass_flags &= ~PASSMOB
	animate_movement = our_animate_movement
	partner.animate_movement = partner_animate_movement

	if(swapped)
		set_pull_offsets(partner, GRAB_PASSIVE)
	return swapped

/**
 * Works out the four keyframes of the spin for both dancers: start, close in, half turn, finish.
 * Offsets are list(x, y). The stand-ins live on the old turfs, so the finish is a full tile away.
 * Returns list("lead" = passes, "partner" = passes); each pass is list("x", "y", "dir", "layer"), a null layer keeps the last one.
 */
/proc/calculate_dance_passes(list/lead_base, list/lead_start, list/lead_end, list/partner_base, list/partner_start, list/partner_end, counterclockwise, dir_after)
	var/dir_before = turn(dir_after, 180)
	var/vertical = dir_before & (NORTH|SOUTH)
	var/half_tile = world.icon_size / 2
	var/list/lead = list()
	var/list/partner = list()

	// Start: whoever is in front of the other draws on top.
	lead += list(list(
		"x" = lead_start[1], "y" = lead_start[2], "dir" = dir_before,
		"layer" = (dir_before & (NORTH | (counterclockwise ? EAST : WEST))) ? ABOVE_ALL_MOB_LAYER : MOB_LAYER,
	))
	partner += list(list(
		"x" = partner_start[1], "y" = partner_start[2], "dir" = dir_after,
		"layer" = (dir_before & (SOUTH | (counterclockwise ? WEST : EAST))) ? ABOVE_ALL_MOB_LAYER : MOB_LAYER,
	))

	// Close in: step towards each other.
	var/close_x = vertical ? 0 : ((dir_before & EAST) ? DANCE_CLOSE_IN : -DANCE_CLOSE_IN)
	var/close_y = vertical ? ((dir_before & NORTH) ? DANCE_CLOSE_IN : -DANCE_CLOSE_IN) : 0
	lead += list(list("x" = lead_base[1] + close_x, "y" = lead_base[2] + close_y, "dir" = dir_before, "layer" = null))
	partner += list(list("x" = partner_base[1] - close_x, "y" = partner_base[2] - close_y, "dir" = dir_after, "layer" = null))

	// Half turn: side by side, halfway between the two tiles.
	var/side = (half_tile - DANCE_CLOSE_IN) * (counterclockwise ? 1 : -1) * ((dir_before & (NORTH|WEST)) ? 1 : -1)
	var/forward = half_tile * ((dir_before & (NORTH|EAST)) ? 1 : -1)
	var/half_x = vertical ? side : forward
	var/half_y = vertical ? forward : side
	var/lead_half_layer = MOB_LAYER
	switch(dir_before)
		if(SOUTH)
			lead_half_layer = ABOVE_ALL_MOB_LAYER
		if(EAST)
			lead_half_layer = counterclockwise ? ABOVE_ALL_MOB_LAYER : MOB_LAYER
		if(WEST)
			lead_half_layer = counterclockwise ? MOB_LAYER : ABOVE_ALL_MOB_LAYER
	var/partner_half_layer = (lead_half_layer == MOB_LAYER) ? ABOVE_ALL_MOB_LAYER : MOB_LAYER
	lead += list(list(
		"x" = lead_base[1] + half_x, "y" = lead_base[2] + half_y,
		"dir" = turn(dir_before, counterclockwise ? 90 : -90), "layer" = lead_half_layer,
	))
	partner += list(list(
		"x" = partner_base[1] - half_x, "y" = partner_base[2] - half_y,
		"dir" = turn(dir_before, counterclockwise ? -90 : 90), "layer" = partner_half_layer,
	))

	// Finish: each stand-in ends on the other's old tile, facing back.
	var/end_x = vertical ? 0 : ((dir_before & EAST) ? world.icon_size : -world.icon_size)
	var/end_y = vertical ? ((dir_before & NORTH) ? world.icon_size : -world.icon_size) : 0
	lead += list(list("x" = lead_end[1] + end_x, "y" = lead_end[2] + end_y, "dir" = dir_after, "layer" = null))
	partner += list(list("x" = partner_end[1] - end_x, "y" = partner_end[2] - end_y, "dir" = dir_before, "layer" = null))

	return list("lead" = lead, "partner" = partner)

/obj/effect/temp_visual/dance_stand_in
	duration = DANCE_DURATION
	randomdir = FALSE

#undef DANCE_DURATION
#undef DANCE_TRAIT
#undef DANCE_CLOSE_IN
