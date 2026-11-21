/datum/sex_action/npc/npc_body_rub
	name = "Humping"
	var/selected_genital_slot

/datum/sex_action/npc/npc_body_rub/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_body_rub/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST))
		return FALSE

	selected_genital_slot = null
	for(var/genital_slot in list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA))
		if(user.getorganslot(genital_slot) && !check_sex_lock(user, genital_slot))
			selected_genital_slot = genital_slot
			break
	return !!selected_genital_slot

/datum/sex_action/npc/npc_body_rub/on_start(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/// The rubbing part: the hunter's cock word, or "pussy".
/datum/sex_action/npc/npc_body_rub/proc/get_rub_part(mob/living/user, list/words)
	var/slot = selected_genital_slot
	if(!slot)
		slot = user.getorganslot(ORGAN_SLOT_PENIS) ? ORGAN_SLOT_PENIS : ORGAN_SLOT_VAGINA
	return slot == ORGAN_SLOT_VAGINA ? "pussy" : get_act_part(user, words)

/datum/sex_action/npc/npc_body_rub/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/part = get_rub_part(user, words)
	var/their = words["their"]
	return act_lines(
		"[user] presses [their] [part] against [target]'s thigh.",
		"[user] presses [their] [part] against my thigh.",
		get_act_hear(words, "body_rub")
	)

/datum/sex_action/npc/npc_body_rub/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	do_thrust_animate(user, target)
	perform_sex_action(user, target, 1.8, 0, 1.5)
	perform_sex_action(target, user, 0.5, 0, 0.3)
	handle_passive_ejaculation()

/datum/sex_action/npc/npc_body_rub/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/part = get_rub_part(user, words)
	var/their = words["their"]
	var/body = words["body"]
	var/hear = get_act_hear(words, "body_rub")
	switch(stage)
		if("opening")
			return act_lines("[user] settles against [target]'s thigh and finds a rhythm.", "[user] settles against my thigh and finds a rhythm.", hear)
		if("late")
			return act_lines("[user] humps [target]'s thigh faster, [body] stuttering.", "[user] humps my thigh faster, [body] stuttering against me.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] humps [target]'s thigh.", "[user] humps my thigh, [their] [part] dragging along my skin.", hear)
		if(2)
			return act_lines("[user] [adverb] grinds [their] [part] along [target]'s hip.", "[user] grinds [their] [part] along my hip.", hear)
	return act_lines("[user] [adverb] rubs [their] [part] against [target]'s thigh.", "[user] rubs [their] [part] against my thigh in quick strokes.", hear)

/datum/sex_action/npc/npc_body_rub/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return null
	var/list/words = get_act_words(climaxer, partner)
	var/hear = get_act_hear(words, "body_rub")
	if(get_rub_part(climaxer, words) == "pussy")
		return act_lines("[climaxer] shudders and leaves [partner]'s thigh slick!", "[climaxer] shudders and leaves my thigh slick!", hear)
	return act_lines("[climaxer] stiffens and spills over [partner]'s thigh!", "[climaxer] stiffens and spills over my thigh!", hear)

/datum/sex_action/npc/npc_body_rub/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return null

/datum/sex_action/npc/npc_body_rub/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_body_rub/compose_finish_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/their = words["their"]
	return act_lines("[user] pulls [their] [words["body"]] back from [target].", "[user] pulls [their] [words["body"]] back from me.", get_act_hear(words, "body_rub"))

/datum/sex_action/npc/npc_body_rub/lock_sex_object(mob/living/user, mob/living/target)
	if(selected_genital_slot)
		add_sex_lock(user, selected_genital_slot)
