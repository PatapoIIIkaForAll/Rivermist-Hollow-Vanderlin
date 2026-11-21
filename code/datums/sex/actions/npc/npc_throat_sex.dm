/datum/sex_action/npc/npc_throat_sex
	name = "Throat"
	check_same_tile = FALSE
	hole_id = BODY_ZONE_PRECISE_MOUTH
	gags_target = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_RECEIVER
	scene_user_slot = ORGAN_SLOT_PENIS
	scene_target_role = SEX_SCENE_ROLE_GIVER
	scene_target_slot = BODY_ZONE_PRECISE_MOUTH

/datum/sex_action/npc/npc_throat_sex/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_throat_sex/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/npc/npc_throat_sex/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_throat_sex/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/part = get_act_part(user, words)
	var/article = words["article"]
	var/hear = get_act_hear(words, "throat")
	var/list/override = override_lines(words, "start_throat", "throat", hear)
	if(override)
		return override
	if(!hunter_has_hands(user))
		return act_lines("[user] [words["mount"]] [article] [part] down [target]'s throat!", "[user] [words["mount"]] [article] [part] down my throat!", hear)
	return act_lines(
		"[user] grabs [target]'s head and shoves [article] [part] down [target.p_their()] throat!",
		"[user] grabs my head and shoves [article] [part] down my throat!",
		hear
	)

/datum/sex_action/npc/npc_throat_sex/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	play_throat_thrust(target, 50)
	do_thrust_animate(user, target)

	perform_sex_action(user, target, 2, 0, 2)

	if(considered_limp(user))
		perform_sex_action(target, user, 0, 2, 2)
	else
		perform_sex_action(target, user, 0, 7, 2)
		if(force >= SEX_FORCE_HIGH)
			var/choker_snap_chance = 5
			if(force >= SEX_FORCE_EXTREME)
				choker_snap_chance = 15
			if(prob(choker_snap_chance))
				target.snap_worn_choker(user)
	handle_passive_ejaculation()

/datum/sex_action/npc/npc_throat_sex/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/list/thrusts = words["thrusts"]
	var/target_their = target.p_their()
	var/hear = get_act_hear(words, "throat")
	var/hands = hunter_has_hands(user)
	switch(stage)
		if("opening")
			if(!hands)
				return act_lines("[user] pins [target] in place and eases into a rhythm down [target_their] throat.", "[user] pins me in place and eases into a rhythm down my throat.", hear)
			return act_lines("[user] holds [target]'s head and eases into a rhythm down [target_their] throat.", "[user] holds my head and eases into a rhythm down my throat.", hear)
		if("late")
			return act_lines("[user] [thrusts[3]] [target]'s throat in short, hard jabs.", "[user] [thrusts[3]] my throat in short, hard jabs.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] [thrusts[3]] [target]'s throat.", "[user] [thrusts[3]] my throat and I can only gag around it.", hear)
		if(2)
			if(!hands)
				return act_lines("[user] pins [target] in place and [adverb] [thrusts[1]] down [target_their] throat.", "[user] pins me in place and [thrusts[1]] down my throat.", hear)
			return act_lines("[user] holds [target]'s head still and [adverb] [thrusts[1]] down [target_their] throat.", "[user] holds my head still and [thrusts[1]] down my throat.", hear)
	return act_lines("[user] [adverb] drives into [target]'s throat, [target_their] eyes watering.", "[user] drives into my throat, my eyes watering.", hear)

/datum/sex_action/npc/npc_throat_sex/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		var/list/hunter_words = get_act_words(partner, climaxer)
		var/part = get_act_part(partner, hunter_words)
		return act_lines(
			"[climaxer] shudders through a climax with [partner]'s [part] in [climaxer.p_their()] throat!",
			"I shudder through a climax with [partner]'s [part] in my throat!",
			get_act_hear(hunter_words, "throat")
		)
	var/list/words = get_act_words(climaxer, partner)
	if(!hunter_has_hands(climaxer))
		return act_lines(
			"[climaxer] [words["spill"]], [words["spill_room"]] down [partner]'s throat!",
			"[climaxer] [words["spill"]], and [words["spill_me"]] down my throat!",
			get_act_hear(words, "throat")
		)
	return act_lines(
		"[climaxer] holds [partner]'s head down and spills down [partner.p_their()] throat!",
		"[climaxer] holds my head down and spills down my throat!",
		get_act_hear(words, "throat")
	)

/datum/sex_action/npc/npc_throat_sex/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		return ORGASM_LOCATION_SELF
	else
		user.lose_virginity()
		return ORGASM_LOCATION_ORAL

/datum/sex_action/npc/npc_throat_sex/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_throat_sex/compose_finish_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	return act_lines(
		"[user] pulls [words["their"]] [get_act_part(user, words)] out of [target]'s throat, leaving [target.p_them()] gasping.",
		"[user] pulls out of my throat and leaves me gasping.",
		get_act_hear(words, "throat")
	)

/datum/sex_action/npc/npc_throat_sex/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH, null, FALSE)
