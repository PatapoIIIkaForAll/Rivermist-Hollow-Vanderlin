/datum/sex_action/npc/npc_vaginal_ride_sex
	name = "Riding"
	check_same_tile = FALSE
	hole_id = ORGAN_SLOT_VAGINA
	scene_interaction = SEX_SCENE_INTERACTION_PENETRATION
	scene_user_role = SEX_SCENE_ROLE_RECEIVER
	scene_user_slot = ORGAN_SLOT_VAGINA
	scene_target_role = SEX_SCENE_ROLE_GIVER
	scene_target_slot = ORGAN_SLOT_PENIS
	warms_up_orifice = TRUE
	// Only knotted organs tie; plain ones ignore these flags.
	knot_on_finish = TRUE
	can_knot = TRUE

/datum/sex_action/npc/npc_vaginal_ride_sex/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_vaginal_ride_sex/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/npc/npc_vaginal_ride_sex/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(needs_orifice_warmup(user, target))
		start_orifice_warmup(user, target)
		return .
	show_penetration_start(user, target)

/datum/sex_action/npc/npc_vaginal_ride_sex/show_penetration_start(mob/living/user, mob/living/target)
	show_act_lines(get_start_lines(user, target), user, target, "warning")
	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/npc/npc_vaginal_ride_sex/compose_start_lines(mob/living/user, mob/living/target)
	var/cock = get_penis_word(target)
	return act_lines(
		"[user] straddles [target] and sinks down onto [target.p_their()] [cock]!",
		"[user] straddles me and sinks down onto my [cock]!",
		get_act_hear(get_act_words(user, target), "ride")
	)

/datum/sex_action/npc/npc_vaginal_ride_sex/on_perform(mob/living/user, mob/living/target)
	if(run_orifice_warmup_cycle(user, target))
		return
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	var/used_sex_volume = sex_volume
	playsound(target, get_force_sound(), used_sex_volume, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	// The rider's hole takes the strain; the cock under them feels no pain.
	if(considered_limp(target))
		perform_sex_action(user, target, 1.2, 3, 1.2)
	else
		perform_sex_action(user, target, 2.4, 7, 2.4)
	handle_passive_ejaculation(target)

	perform_sex_action(target, user, 2, 0, 3)

/datum/sex_action/npc/npc_vaginal_ride_sex/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/cock = get_penis_word(target)
	var/list/words = get_act_words(user, target)
	var/their = words["their"]
	var/target_them = target.p_them()
	var/hear = get_act_hear(words, "ride")
	switch(stage)
		if("tied")
			return tied_ride_lines(user, target, hear)
		if("opening")
			return act_lines("[user] settles [their] weight on [target]'s hips and finds a rhythm.", "[user] settles [their] weight on my hips and finds a rhythm.", hear)
		if("late")
			return act_lines("[user] rides [target] hard and fast, head thrown back.", "[user] rides me hard and fast, head thrown back.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] rides [target]'s [cock].", "[user] rides my [cock], pinning me by the shoulders.", hear)
		if(2)
			return act_lines("[user] [adverb] bounces on [target]'s [cock], pinning [target_them] by the shoulders.", "[user] bounces on my [cock] and my hips buck under [words["them"]].", hear)
	return act_lines("[user] grinds down on [target] and [adverb] rides [target_them].", "[user] grinds down on me, wet heat gripping my [cock].", hear)

/datum/sex_action/npc/npc_vaginal_ride_sex/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] bucks and spills up into [partner]!",
			"I buck and spill up into [partner]!",
			get_act_hear(get_act_words(partner, climaxer), "ride")
		)
	var/cock = get_penis_word(partner)
	return act_lines(
		"[climaxer] grinds down hard and shudders around [partner]'s [cock]!",
		"[climaxer] grinds down hard and shudders around my [cock]!",
		get_act_hear(get_act_words(climaxer, partner), "ride")
	)

/datum/sex_action/npc/npc_vaginal_ride_sex/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_INTO
	else
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_ONTO

/datum/sex_action/npc/npc_vaginal_ride_sex/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_vaginal_ride_sex/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines("[user] climbs off [target].", "[user] climbs off me.", get_act_hear(get_act_words(user, target), "ride"))
