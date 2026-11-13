// Horny NPCs can jerk off over someone, aiming at a spot so their spurts paint down the body.

/datum/sex_action/npc/npc_jerk_over
	name = "Jerking off"

/datum/sex_action/npc/npc_jerk_over/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_jerk_over/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS) || check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE)

/// The NPC strokes its own cock, so the aim on it steers the climax.
/datum/sex_action/npc/npc_jerk_over/get_grip_owner(mob/living/user, mob/living/target)
	return user

/datum/sex_action/npc/npc_jerk_over/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return
	aim_at_target(user, target)
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_jerk_over/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/part = get_act_part(user, words)
	var/their = words["their"]
	return act_lines(
		"[user] grips [their] [part] and aims it at [target].",
		"[user] grips [their] [part] and aims it at me.",
		get_act_hear(words, "jerk_over")
	)

/// Picks a spot on the target, mostly high on the body, so later spurts drift down it.
/datum/sex_action/npc/npc_jerk_over/proc/aim_at_target(mob/living/user, mob/living/target)
	var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return
	var/list/zone_weights = list(FLUID_COAT_FACE = 4, FLUID_COAT_CHEST = 3, FLUID_COAT_BELLY = 2)
	if(target.mouth_is_free(cloth_blocks = TRUE))
		zone_weights[PENIS_AIM_MOUTH] = 1
	penis.get_climax_aim().set_target(target, pickweight(zone_weights), user)

/datum/sex_action/npc/npc_jerk_over/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(user, user, 2, 0, 2)
	handle_passive_ejaculation()

/datum/sex_action/npc/npc_jerk_over/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
	if(penis?.climax_aim?.aimer == user)
		penis.climax_aim.clear()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_jerk_over/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/list/thrusts = words["thrusts"]
	var/part = get_act_part(user, words)
	var/their = words["their"]
	var/themself = "[words["them"]]self"
	var/hear = get_act_hear(words, "jerk_over")
	switch(stage)
		if("opening")
			return act_lines("[user] strokes [themself] slowly, eyes on [target].", "[user] strokes [themself] slowly, eyes on me.", hear)
		if("late")
			return act_lines("[user] jerks [themself] over [target], fast and ragged.", "[user] jerks [themself] over me, fast and ragged.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] strokes [themself] over [target].", "[user] strokes [themself] over me, eyes on my face.", hear)
		if(2)
			return act_lines("[user] [adverb] jerks off over [target], eyes on [target.p_them()].", "[user] jerks off over me and does not look away.", hear)
	return act_lines("[user] [adverb] [thrusts[1]] [their] [part] over [target].", "[user] [thrusts[1]] [their] [part] over me, the tip aimed at me.", hear)

/datum/sex_action/npc/npc_jerk_over/compose_finish_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/their = words["their"]
	var/part = get_act_part(user, words)
	return act_lines(
		"[user] lets go of [their] [part] and steps back.",
		"[user] lets go of [their] [part] and steps back from me.",
		get_act_hear(words, "jerk_over")
	)

/datum/sex_action/npc/npc_jerk_over/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] shudders through a climax under [partner]!",
			"I shudder through a climax under [partner]!",
			get_act_hear(get_act_words(partner, climaxer), "jerk_over")
		)
	return act_lines(
		"[climaxer] grunts and shoots over [partner]!",
		"[climaxer] grunts and shoots over me!",
		get_act_hear(get_act_words(climaxer, partner), "jerk_over")
	)

/datum/sex_action/npc/npc_jerk_over/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return ORGASM_LOCATION_ONTO

/datum/sex_action/npc/npc_jerk_over/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
