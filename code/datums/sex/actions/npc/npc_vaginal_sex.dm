/datum/sex_action/npc/npc_vaginal_sex
	name = "Vaginal"
	check_same_tile = FALSE
	hole_id = ORGAN_SLOT_VAGINA
	scene_interaction = SEX_SCENE_INTERACTION_PENETRATION
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = ORGAN_SLOT_PENIS
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_VAGINA
	warms_up_orifice = TRUE
	// Only knotted organs tie; plain ones ignore these flags.
	knot_on_finish = TRUE
	can_knot = TRUE

/datum/sex_action/npc/npc_vaginal_sex/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_vaginal_sex/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/npc/npc_vaginal_sex/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(needs_orifice_warmup(user, target))
		start_orifice_warmup(user, target)
		return .
	show_penetration_start(user, target)

/datum/sex_action/npc/npc_vaginal_sex/show_penetration_start(mob/living/user, mob/living/target)
	show_act_lines(get_start_lines(user, target), user, target, "warning")
	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/npc/npc_vaginal_sex/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/hole = get_act_hole(user, target)
	var/hear = get_act_hear(words, "vaginal")
	var/list/override = override_lines(words, "start_vaginal", hole, hear)
	if(override)
		return override
	return act_lines(
		"[user] [words["mount"]] [words["article"]] [get_act_part(user, words)] into [target]'s [hole]!",
		"[user] [words["mount"]] into my [hole] in one hard push!",
		hear
	)

/datum/sex_action/npc/npc_vaginal_sex/on_perform(mob/living/user, mob/living/target)
	if(run_orifice_warmup_cycle(user, target))
		return
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	var/used_sex_volume = sex_volume
	playsound(target, get_force_sound(), used_sex_volume, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	//if(user.has_kink(KINK_ONOMATOPOEIA))
	//	do_onomatopoeia(user)

	perform_sex_action(user, target, 2, 0, 2)

	if(considered_limp(user))
		perform_sex_action(target, user, 1.2, 4, 1.2)
	else
		perform_sex_action(target, user, 2.4, 9, 2.4)
		handle_passive_ejaculation(target)

/datum/sex_action/npc/npc_vaginal_sex/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/list/thrusts = words["thrusts"]
	var/hole = get_act_hole(user, target)
	var/their = words["their"]
	var/body = words["body"]
	var/hear = get_act_hear(words, "vaginal")
	switch(stage)
		if("tied")
			return tied_penetration_lines(user, target, words, hole, hear)
		if("opening")
			return act_lines("[user] settles [their] weight on [target] and finds a rhythm in [target.p_their()] [hole].", "[user] settles [their] weight on me and finds a rhythm in my [hole].", hear)
		if("late")
			return act_lines("[user] [thrusts[3]] [target]'s [hole] faster, [body] stuttering.", "[user] [thrusts[3]] my [hole] faster, [body] stuttering against me.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] [thrusts[1]] into [target]'s [hole].", "[user] [thrusts[1]] into my [hole], dragging my hips back to meet every thrust.", hear)
		if(2)
			return act_lines("[user] [adverb] [thrusts[2]] into [target]'s [hole], [body] slapping.", "[user] [thrusts[2]] into my [hole], wet slaps filling my ears.", hear)
	return act_lines("[user] [words["hold"]] and [adverb] [thrusts[3]] [target.p_their()] [hole].", "[user]'s weight pins me and each thrust into my [hole] knocks the breath out of me.", hear)

/datum/sex_action/npc/npc_vaginal_sex/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		var/list/hunter_words = get_act_words(partner, climaxer)
		var/part = get_act_part(partner, hunter_words)
		var/victim_hole = get_act_hole(partner, climaxer)
		return act_lines("[climaxer]'s [victim_hole] clamps down around [partner]'s [part]!", "I shake as my [victim_hole] clamps down around [partner]'s [part]!", get_act_hear(hunter_words, "vaginal"))
	var/list/words = get_act_words(climaxer, partner)
	var/hole = get_act_hole(climaxer, partner)
	return act_lines(
		"[climaxer] [words["spill"]], [words["spill_room"]] into [partner]'s [hole]!",
		"[climaxer] [words["spill"]], and [words["spill_me"]] into my [hole]!",
		get_act_hear(words, "vaginal")
	)

/datum/sex_action/npc/npc_vaginal_sex/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_ONTO
	else
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_INTO

/datum/sex_action/npc/npc_vaginal_sex/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_vaginal_sex/compose_finish_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/hole = get_act_hole(user, target)
	return act_lines(
		"[user] pulls [words["their"]] [get_act_part(user, words)] out of [target]'s [hole].",
		"[user] pulls out of my [hole].",
		get_act_hear(words, "vaginal")
	)

/datum/sex_action/npc/npc_vaginal_sex/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	add_sex_lock(target, ORGAN_SLOT_VAGINA, null, FALSE)
