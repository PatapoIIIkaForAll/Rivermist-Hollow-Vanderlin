/datum/sex_action/npc/npc_facesitting
	name = "Facesitting"
	check_same_tile = FALSE
	hole_id = BODY_ZONE_PRECISE_MOUTH
	gags_target = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_RECEIVER
	scene_user_slot = ORGAN_SLOT_VAGINA
	scene_target_role = SEX_SCENE_ROLE_GIVER
	scene_target_slot = BODY_ZONE_PRECISE_MOUTH

/datum/sex_action/npc/npc_facesitting/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_facesitting/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/npc/npc_facesitting/on_start(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_facesitting/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/their = words["their"]
	return act_lines(
		"[user] plants [their] pussy over [target]'s mouth and sits!",
		"[user] plants [their] pussy over my mouth and sits!",
		get_act_hear(words, "facesitting")
	)

/datum/sex_action/npc/npc_facesitting/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	target.make_mouth_noise("lick")
	do_thrust_animate(user, target)

	perform_sex_action(user, target, 1, 3, 2)
	handle_passive_ejaculation()

	perform_sex_action(target, user, 0, 2, 0)

/datum/sex_action/npc/npc_facesitting/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/their = words["their"]
	var/hear = get_act_hear(words, "facesitting")
	switch(stage)
		if("opening")
			return act_lines("[user] settles [their] thighs around [target]'s head and finds a rhythm.", "[user] settles [their] thighs around my head and finds a rhythm.", hear)
		if("late")
			return act_lines("[user] grinds down on [target]'s face, thighs shaking.", "[user] grinds down on my face, thighs shaking around my head.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			return act_lines("[user] [adverb] grinds [their] pussy over [target]'s face.", "[user] grinds [their] pussy over my face and I can barely breathe.", hear)
		if(2)
			return act_lines("[user] rides [target]'s face, [adverb] rocking [their] hips.", "[user] rocks [their] hips over my mouth.", hear)
	return act_lines("[user] [adverb] smothers [target] under [their] pussy.", "[user] smothers me under [their] pussy.", hear)

/datum/sex_action/npc/npc_facesitting/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return null
	return act_lines(
		"[climaxer] shudders and soaks [partner]'s face!",
		"[climaxer] shudders and soaks my face!",
		get_act_hear(get_act_words(climaxer, partner), "facesitting")
	)

/datum/sex_action/npc/npc_facesitting/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return null

/datum/sex_action/npc/npc_facesitting/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_facesitting/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines("[user] gets off [target]'s face.", "[user] lifts off my face and I gulp air.", get_act_hear(get_act_words(user, target), "facesitting"))

/datum/sex_action/npc/npc_facesitting/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH, null, FALSE)
	add_sex_lock(user, ORGAN_SLOT_VAGINA, null, FALSE)
