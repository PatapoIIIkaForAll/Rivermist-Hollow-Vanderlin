// Handless hunters catch with their bodies: bear down, coil and squeeze, hoist and slam.

/// The body roll that puts a standing target on the ground: the tackle's own strength roll, plus what the family brings and what the struggle has cost so far.
/proc/horny_bear_down_chance(mob/living/hunter, mob/living/target, bonus = 0, pressure = 0)
	var/strength = hunter.get_stat_level(STATKEY_STR) || 10
	var/constitution = target.get_stat_level(STATKEY_CON) || 10
	var/chance = (4 + (strength - (constitution + 2)) / 2) * 10
	chance *= hunter.get_positioning_modifier(target)
	chance += target.cmode ? -10 : 10
	// A winded target goes down easier, and every failed takedown wears them further.
	chance += 30 * (target.stamina / max(target.maximum_stamina, 1))
	chance += bonus + pressure * HORNY_PRESSURE_PER_MISS
	return clamp(chance, 5, 95)

/proc/horny_get_pressure(datum/ai_controller/controller)
	return controller?.blackboard[BB_HORNY_WRESTLE_PRESSURE] || 0

/// A failed takedown: the target tires, and the next roll gets easier.
/proc/horny_add_pressure(datum/ai_controller/controller, mob/living/target)
	target?.adjust_stamina(HORNY_BEAR_DOWN_FATIGUE)
	controller?.set_blackboard_key(BB_HORNY_WRESTLE_PRESSURE, horny_get_pressure(controller) + 1)

/proc/horny_reset_pressure(datum/ai_controller/controller)
	controller?.clear_blackboard_key(BB_HORNY_WRESTLE_PRESSURE)

/// The lunge every body move shows: the attack bounce, no hit effect.
/proc/horny_jolt(mob/living/hunter, atom/target)
	hunter.do_attack_animation(target, no_effect = TRUE, atom_bounce = TRUE)

/// One body roll puts a standing target down; a handless hunter's hold lands in the same beat. TRUE when it lands.
/proc/horny_bear_down(mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, datum/ai_controller/controller)
	var/chance = horny_bear_down_chance(hunter, target, profile.bear_down_bonus, horny_get_pressure(controller))
	hunter.changeNext_move(CLICK_CD_GRABBING)
	hunter.face_atom(target)
	horny_jolt(hunter, target)
	// A target still tangled in fresh web is already down for the taking: no roll.
	if(!horny_target_presented(controller) && !prob(chance + rand(-5, 5)))
		horny_add_pressure(controller, target)
		hunter.visible_message(span_danger(profile.get_bear_down_miss_message(hunter, target)), null, span_hear("I hear a scuffle."))
		return FALSE
	horny_reset_pressure(controller)
	target.Knockdown(HORNY_BEAR_DOWN_KNOCKDOWN)
	if(profile.seize_move == HORNY_MOVE_HOIST)
		target.Immobilize(HORNY_HOIST_IMMOBILIZE)
	target.felt_visible_message(span_danger(profile.get_bear_down_message(hunter, target)), null, span_hear("I hear a body hit the ground."))
	// The weight follows the fall at once, before the target can scramble up.
	if(!iscarbon(hunter))
		horny_handless_hold(hunter, target, profile)
	return TRUE

/// Handless mobs keep victims in place through the generic pull state, not grab items.
/proc/horny_promote_handless_hold(mob/living/hunter, mob/living/target)
	hunter.setGrabState(GRAB_AGGRESSIVE)
	hunter.update_pull_movespeed()
	hunter.set_pull_offsets(target, hunter.grab_state)

/// A handless hold: a pull promoted to an aggressive hold that pins the target in place. TRUE when newly set.
/proc/horny_handless_hold(mob/living/hunter, mob/living/target, datum/horny_family_profile/profile)
	if(!hunter.Adjacent(target))
		return FALSE
	if(hunter.pulling && hunter.pulling != target)
		hunter.stop_pulling()

	if(target.pulledby == hunter)
		if(hunter.grab_state >= GRAB_AGGRESSIVE)
			return FALSE
		horny_promote_handless_hold(hunter, target)
		target.felt_visible_message(span_danger(profile.get_hold_message(hunter, target)), null, span_hear("I hear a violent struggle."))
		return TRUE

	// An aggressive hold, a packmate's or a fellow hunter's is never pulled loose.
	if(horny_hold_is_spoken_for(hunter, target))
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(target, "broke_free"))
		return FALSE
	if(!hunter.start_handless_pull(target, GRAB_PASSIVE, suppress_message = TRUE))
		return FALSE
	horny_promote_handless_hold(hunter, target)
	horny_jolt(hunter, target)
	target.felt_visible_message(span_danger(profile.get_hold_message(hunter, target)), null, span_hear("I hear a violent struggle."))
	return TRUE

/// Coils squeeze every beat they hold on; the breath goes before the body does. TRUE when it squeezed.
/proc/horny_squeeze(mob/living/hunter, mob/living/target, datum/horny_family_profile/profile)
	if(profile.seize_move != HORNY_MOVE_COIL || !profile.squeeze_fatigue)
		return FALSE
	if(target.pulledby != hunter || hunter.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	target.adjust_stamina(profile.squeeze_fatigue)
	if(prob(25))
		target.felt_visible_message(span_danger(profile.get_squeeze_message(hunter, target)), span_userdanger(profile.get_squeeze_message(hunter, target, TRUE)))
	return TRUE

/// One beat of the handless catch. Same results as the handed ladder.
/proc/horny_handless_seize_step(mob/living/hunter, mob/living/carbon/human/target, datum/ai_controller/controller, datum/horny_family_profile/profile)
	if(!hunter || !target || !hunter.Adjacent(target))
		return HORNY_SEIZE_FAILED
	if(hunter.body_position == LYING_DOWN)
		return HORNY_SEIZE_WAIT
	if(hunter.next_move > world.time)
		return HORNY_SEIZE_WAIT

	var/held = target.pulledby == hunter && hunter.grab_state >= GRAB_AGGRESSIVE

	// A yielding target is eased down and held, never wrestled.
	if(target.surrendering)
		if(target.body_position != LYING_DOWN)
			target.Knockdown(50)
			target.felt_visible_message(span_danger("[hunter] eases the yielding [target] down."))
			hunter.changeNext_move(CLICK_CD_GRABBING)
			return HORNY_SEIZE_ACTED
		if(held || (target.pulledby && target.pulledby != hunter))
			return HORNY_SEIZE_DONE
		return horny_handless_hold(hunter, target, profile) ? HORNY_SEIZE_ACTED : HORNY_SEIZE_WAIT

	// A weapon comes loose first.
	if(mob_has_ai_disarmable_held_item(target) && horny_disarm_target(hunter, target))
		hunter.changeNext_move(CLICK_CD_MELEE)
		return HORNY_SEIZE_ACTED

	// Strapped into something, the structure holds them; a hold of our own would only fail.
	if(target.buckled)
		return HORNY_SEIZE_DONE

	// A target who just broke free slips any new hold for a moment.
	if(!held && TIMER_COOLDOWN_RUNNING(target, "broke_free"))
		controller?.horny_react(HORNY_REACT_GRAB_BROKEN, target)
		return HORNY_SEIZE_WAIT

	if(target.body_position != LYING_DOWN)
		if(horny_target_is_subdued(hunter, target))
			if(held)
				return HORNY_SEIZE_DONE
			return horny_handless_hold(hunter, target, profile) ? HORNY_SEIZE_DONE : HORNY_SEIZE_WAIT
		// Coils wrap first and squeeze; everyone else knocks the target down, then holds.
		if(profile.seize_move == HORNY_MOVE_COIL)
			if(held)
				horny_squeeze(hunter, target, profile)
			else if(horny_handless_hold(hunter, target, profile))
				return HORNY_SEIZE_ACTED
			else if(!target.pulledby || target.pulledby == hunter)
				return HORNY_SEIZE_WAIT
			// In someone else's hold there is nothing to wrap, so the weight does the work.
		horny_bear_down(hunter, target, profile, controller)
		return HORNY_SEIZE_ACTED

	// Down: the hold pins them. A target someone else already pins is caught as well.
	if(held)
		return HORNY_SEIZE_DONE
	if(target.pulledby && target.pulledby != hunter)
		return HORNY_SEIZE_DONE
	return horny_handless_hold(hunter, target, profile) ? HORNY_SEIZE_ACTED : HORNY_SEIZE_WAIT
