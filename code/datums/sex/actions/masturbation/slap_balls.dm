/datum/sex_action/masturbate/slap_balls
	name = "Slap balls"
	description = "Slap your balls, ranging from a teasing tap to a punishing smack."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	do_time = 2.5 SECONDS
	stamina_cost = 0

/datum/sex_action/masturbate/slap_balls/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && user.has_testicles()

/datum/sex_action/masturbate/slap_balls/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target || !user.has_testicles())
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_TESTICLES))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/slap_balls/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] cups one hand beneath [user.p_their()] balls and raises the other..."))

/datum/sex_action/masturbate/slap_balls/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "lightly taps"
	var/arousal_amt = 0.6
	var/pain_amt = 1.2
	var/orgasm_amt = 0.2

	switch(force)
		if(SEX_FORCE_MID)
			action_text = "slaps"
			arousal_amt = 1
			pain_amt = 2.5
			orgasm_amt = 0.4
		if(SEX_FORCE_HIGH)
			action_text = "roughly slaps"
			arousal_amt = 1.1
			pain_amt = 4.5
			orgasm_amt = 0.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "brutally smacks"
			arousal_amt = 0.8
			pain_amt = 7
			orgasm_amt = 0.3

	playsound(user, get_slap_sound("balls"), 45, TRUE, -2, ignore_walls = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [user.p_their()] balls."))
	perform_sex_action(user, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/slap_balls/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] hand from [user.p_their()] balls."))

/datum/sex_action/masturbate/slap_balls/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(user, ORGAN_SLOT_TESTICLES, null, FALSE)

/datum/sex_action/masturbate/other/slap_balls
	name = "Ball slapping"
	remote_phrase = "Slap their balls"
	description = "Slap their balls, ranging from a teasing tap to a punishing smack."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	do_time = 2.5 SECONDS
	stamina_cost = 0
	mage_hand_overlay_zone = MAGE_HAND_ZONE_GROIN

/datum/sex_action/masturbate/other/slap_balls/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && target.has_testicles()

/datum/sex_action/masturbate/other/slap_balls/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !target.has_testicles())
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_TESTICLES))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/slap_balls/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] raises [user.p_their()] hand beneath [target]'s balls..."))

/datum/sex_action/masturbate/other/slap_balls/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "lightly taps"
	var/arousal_amt = 0.6
	var/pain_amt = 1.2
	var/orgasm_amt = 0.2

	switch(force)
		if(SEX_FORCE_MID)
			action_text = "slaps"
			arousal_amt = 1
			pain_amt = 2.5
			orgasm_amt = 0.4
		if(SEX_FORCE_HIGH)
			action_text = "roughly slaps"
			arousal_amt = 1.1
			pain_amt = 4.5
			orgasm_amt = 0.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "brutally smacks"
			arousal_amt = 0.8
			pain_amt = 7
			orgasm_amt = 0.3

	playsound(target, get_slap_sound("balls"), 45, TRUE, -2, ignore_walls = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [target]'s balls."))
	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/slap_balls/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] hand from [target]'s balls."))

/datum/sex_action/masturbate/other/slap_balls/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(target, ORGAN_SLOT_TESTICLES, null, FALSE)
