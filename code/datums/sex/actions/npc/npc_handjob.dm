/datum/sex_action/npc/npc_handjob
	name = "Handjob"

/datum/sex_action/npc/npc_handjob/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_handjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS) || check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE

	selected_hand = find_available_hand(target)
	return !!selected_hand

/datum/sex_action/npc/npc_handjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_handjob/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/part = get_act_part(user, words)
	var/their = words["their"]
	return act_lines(
		"[user] takes [target]'s hand and wraps it around [their] [part].",
		"[user] takes my hand and wraps it around [their] [part].",
		get_act_hear(words, "handjob")
	)

/datum/sex_action/npc/npc_handjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	play_rub_sound("handjob", user, 30)
	perform_sex_action(user, target, 2, 0, 2)
	perform_sex_action(target, user, 0.4, 0, 0.2)
	handle_passive_ejaculation()

/datum/sex_action/npc/npc_handjob/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/list/thrusts = words["thrusts"]
	var/part = get_act_part(user, words)
	var/their = words["their"]
	var/themself = "[words["them"]]self"
	var/hear = get_act_hear(words, "handjob")
	switch(stage)
		if("opening")
			return act_lines("[user] guides [target]'s hand along [their] [part], finding a pace.", "[user] guides my hand along [their] [part], finding a pace.", hear)
		if("late")
			return act_lines("[user] jerks [themself] with [target]'s hand, fast and ragged.", "[user] jerks [themself] with my hand, fast and ragged.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] works [target]'s hand along [their] [part].", "[user] works my hand along [their] [part].", hear)
		if(2)
			return act_lines("[user] [adverb] [thrusts[3]] [target]'s fist.", "[user] [thrusts[3]] my fist, [their] grip tight on my wrist.", hear)
	return act_lines("[user] holds [target]'s wrist and [adverb] strokes [themself] with [target.p_their()] hand.", "[user] uses my hand like a toy.", hear)

/datum/sex_action/npc/npc_handjob/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return null
	return act_lines(
		"[climaxer] grunts and spills over [partner]'s hand!",
		"[climaxer] grunts and spills over my hand!",
		get_act_hear(get_act_words(climaxer, partner), "handjob")
	)

/datum/sex_action/npc/npc_handjob/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return null

/datum/sex_action/npc/npc_handjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_handjob/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines("[user] lets go of [target]'s hand.", "[user] lets go of my hand.", get_act_hear(get_act_words(user, target), "handjob"))

/datum/sex_action/npc/npc_handjob/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	if(selected_hand)
		add_sex_lock(target, selected_hand)
