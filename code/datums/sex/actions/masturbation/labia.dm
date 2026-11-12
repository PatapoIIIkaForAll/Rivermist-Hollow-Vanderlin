/datum/sex_action/masturbate/labia
	name = "Play with labia"

/datum/sex_action/masturbate/labia/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/labia/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/labia/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts playing with [user.p_their()] labia..."))

/datum/sex_action/masturbate/labia/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "tugs at"
	var/arousal_amt = 1.2
	var/pain_amt = 0.3
	var/orgasm_amt = 0.6

	switch(force)
		if(SEX_FORCE_MID)
			action_text = "pulls at"
			arousal_amt = 1.6
			pain_amt = 0.8
			orgasm_amt = 0.9
		if(SEX_FORCE_HIGH)
			action_text = "pinches"
			arousal_amt = 1.4
			pain_amt = 1.8
			orgasm_amt = 0.7
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "harshly pinches"
			arousal_amt = 1.1
			pain_amt = 2.8
			orgasm_amt = 0.4

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [user.p_their()] labia..."))
	play_rub_sound("finger", user, 25, ORGAN_SLOT_VAGINA)

	perform_sex_action(user, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/labia/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops teasing [user.p_their()] labia."))

/datum/sex_action/masturbate/other/labia
	name = "Play with labia"
	remote_phrase = "Play with their labia"
	check_same_tile = FALSE

/datum/sex_action/masturbate/other/labia/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/labia/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/labia/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts playing with [target]'s labia..."))

/datum/sex_action/masturbate/other/labia/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "tugs at"
	var/arousal_amt = 1.2
	var/pain_amt = 0.3
	var/orgasm_amt = 0.6

	switch(force)
		if(SEX_FORCE_MID)
			action_text = "pulls at"
			arousal_amt = 1.6
			pain_amt = 0.8
			orgasm_amt = 0.9
		if(SEX_FORCE_HIGH)
			action_text = "pinches"
			arousal_amt = 1.4
			pain_amt = 1.8
			orgasm_amt = 0.7
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "harshly pinches"
			arousal_amt = 1.1
			pain_amt = 2.8
			orgasm_amt = 0.4

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [target]'s labia..."))
	play_rub_sound("finger", target, 25, ORGAN_SLOT_VAGINA)

	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/labia/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops teasing [target]'s labia."))
