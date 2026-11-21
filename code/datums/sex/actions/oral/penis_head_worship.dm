/datum/sex_action/penis_head_worship
	name = "Worship tip"
	description = "Focus kisses and tongue-work on the head of their penis."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	check_same_tile = FALSE
	gags_user = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_PENIS

/datum/sex_action/penis_head_worship/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && target.has_penis()

/datum/sex_action/penis_head_worship/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !target.has_penis())
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/penis_head_worship/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] brings [user.p_their()] lips reverently to the head of [target]'s cock..."))

/datum/sex_action/penis_head_worship/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "plants slow kisses across"
	var/target_arousal = 1.1
	var/target_pain = 0
	var/target_orgasm = 0.8

	switch(force)
		if(SEX_FORCE_MID)
			action_text = "circles [user.p_their()] tongue around"
			target_arousal = 1.5
			target_orgasm = 1.2
		if(SEX_FORCE_HIGH)
			action_text = "firmly laps and presses [user.p_their()] tongue against"
			target_arousal = 1.8
			target_pain = 0.4
			target_orgasm = 1.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "roughly sucks and grinds [user.p_their()] tongue over"
			target_arousal = 2
			target_pain = 1.5
			target_orgasm = 1.4

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] the sensitive head of [target]'s cock."))
	if(force >= SEX_FORCE_HIGH)
		user.make_sucking_noise()
	perform_sex_action(target, user, target_arousal, target_pain, target_orgasm)
	handle_passive_ejaculation(target)
	perform_sex_action(user, target, 0.4, 0, 0.1)

/datum/sex_action/penis_head_worship/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] draws [user.p_their()] lips away from the head of [target]'s cock."))

/datum/sex_action/penis_head_worship/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(target, ORGAN_SLOT_PENIS, null, FALSE)

/datum/sex_action/penis_head_worship/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		target.visible_message(span_love("[target] spills over [user]'s worshipping tongue!"))
		return ORGASM_LOCATION_ORAL
	user.visible_message(span_love("[user] climaxes from worshipping [target]'s cock!"))
	return ORGASM_LOCATION_SELF
