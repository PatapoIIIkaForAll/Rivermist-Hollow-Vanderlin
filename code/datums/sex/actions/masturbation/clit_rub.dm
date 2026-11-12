/datum/sex_action/masturbate/clit_rub
	name = "Rub clit"

/datum/sex_action/masturbate/clit_rub/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/clit_rub/can_perform(mob/living/user, mob/living/target)
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

/datum/sex_action/masturbate/clit_rub/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rubbing [user.p_their()] clit..."))

/datum/sex_action/masturbate/clit_rub/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "rubs"
	var/arousal_amt = 2.2
	var/pain_amt = 0
	var/orgasm_amt = 2.1

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 2.8
			pain_amt = 0.4
			orgasm_amt = 2.7
		if(SEX_FORCE_HIGH)
			action_text = "pinches"
			arousal_amt = 2.5
			pain_amt = 1.5
			orgasm_amt = 2.1
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "roughly pinches"
			arousal_amt = 2.1
			pain_amt = 2.6
			orgasm_amt = 1.6

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [user.p_their()] clit..."))
	play_rub_sound("finger", user, 30, ORGAN_SLOT_VAGINA)

	perform_sex_action(user, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/clit_rub/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops rubbing [user.p_their()] clit."))

/datum/sex_action/masturbate/clit_rub/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] creams themself!"))
	return ORGASM_LOCATION_SELF

/datum/sex_action/masturbate/other/clit_rub
	name = "Clit rubbing"
	remote_phrase = "Rub their clit"
	check_same_tile = FALSE

/datum/sex_action/masturbate/other/clit_rub/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/clit_rub/can_perform(mob/living/user, mob/living/target)
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

/datum/sex_action/masturbate/other/clit_rub/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rubbing [target]'s clit..."))

/datum/sex_action/masturbate/other/clit_rub/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "rubs"
	var/arousal_amt = 2.2
	var/pain_amt = 0
	var/orgasm_amt = 2.1

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 2.8
			pain_amt = 0.4
			orgasm_amt = 2.7
		if(SEX_FORCE_HIGH)
			action_text = "pinches"
			arousal_amt = 2.5
			pain_amt = 1.5
			orgasm_amt = 2.1
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "roughly pinches"
			arousal_amt = 2.1
			pain_amt = 2.6
			orgasm_amt = 1.6

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [target]'s clit..."))
	play_rub_sound("finger", target, 30, ORGAN_SLOT_VAGINA)

	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/clit_rub/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops rubbing [target]'s clit."))
