/datum/sex_action/suck_balls
	name = "Suck balls"
	description = "Tease their balls with your tongue, shifting from licking to sucking as force increases."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	gags_user = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_TESTICLES

/datum/sex_action/suck_balls/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_TESTICLES))
		return FALSE
	return TRUE

/datum/sex_action/suck_balls/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_TESTICLES))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_TESTICLES))
		return FALSE
	return TRUE

/datum/sex_action/suck_balls/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] mouth to [target]'s balls..."))

/datum/sex_action/suck_balls/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "slowly licks over"
	var/arousal_amt = 0.8
	var/pain_amt = 0
	var/orgasm_amt = 0.4

	switch(force)
		if(SEX_FORCE_MID)
			action_text = "suckles"
			arousal_amt = 1.2
			pain_amt = 0.5
			orgasm_amt = 0.8
		if(SEX_FORCE_HIGH)
			action_text = "firmly sucks and rolls [user.p_their()] tongue over"
			arousal_amt = 1.5
			pain_amt = 1.8
			orgasm_amt = 1
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "roughly sucks and tugs at"
			arousal_amt = 1.3
			pain_amt = 3.8
			orgasm_amt = 0.8

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [target]'s balls..."))
	if(force >= SEX_FORCE_MID)
		user.make_sucking_noise()

	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/suck_balls/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lifts [user.p_their()] mouth away from [target]'s balls."))

/datum/sex_action/suck_balls/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(target, ORGAN_SLOT_TESTICLES, null, FALSE)
