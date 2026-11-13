/datum/sex_action/masturbate/slap_pussy
	name = "Slap pussy"
	do_time = 2.5 SECONDS
	stamina_cost = 0

/datum/sex_action/masturbate/slap_pussy/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/slap_pussy/can_perform(mob/living/user, mob/living/target)
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

/datum/sex_action/masturbate/slap_pussy/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] raises [user.p_their()] hand over [user.p_their()] [pick("slit", "cunt", "pussy", "snatch")]..."))

/datum/sex_action/masturbate/slap_pussy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/sound = get_slap_sound("clap")
	var/action_text = "slaps"
	var/arousal_amt = 1.0
	var/pain_amt = 1.4
	var/orgasm_amt = 0.4
	var/pussy_text = pick("slit", "cunt", "pussy", "snatch")

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 1.5
			pain_amt = 2.3
			orgasm_amt = 0.6
		if(SEX_FORCE_HIGH)
			action_text = "roughly slaps"
			arousal_amt = 1.7
			pain_amt = 3.4
			orgasm_amt = 0.7
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "smacks"
			arousal_amt = 1.5
			pain_amt = 4.8
			orgasm_amt = 0.5

	playsound(user, sound, 45, TRUE, -2, ignore_walls = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [user.p_their()] [pussy_text]."))

	perform_sex_action(user, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/slap_pussy/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] hand from [user.p_their()] groin."))

/datum/sex_action/masturbate/other/slap_pussy
	name = "Pussy slapping"
	remote_phrase = "Slap their pussy"
	check_same_tile = FALSE
	do_time = 2.5 SECONDS
	stamina_cost = 0

/datum/sex_action/masturbate/other/slap_pussy/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/slap_pussy/can_perform(mob/living/user, mob/living/target)
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

/datum/sex_action/masturbate/other/slap_pussy/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] raises [user.p_their()] hand over [target]'s [pick("slit", "cunt", "pussy", "snatch")]..."))

/datum/sex_action/masturbate/other/slap_pussy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/sound = get_slap_sound("clap")
	var/action_text = "slaps"
	var/arousal_amt = 1.0
	var/pain_amt = 1.4
	var/orgasm_amt = 0.4
	var/pussy_text = pick("slit", "cunt", "pussy", "snatch")

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 1.5
			pain_amt = 2.3
			orgasm_amt = 0.6
		if(SEX_FORCE_HIGH)
			action_text = "roughly slaps"
			arousal_amt = 1.7
			pain_amt = 3.4
			orgasm_amt = 0.7
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "smacks"
			arousal_amt = 1.5
			pain_amt = 4.8
			orgasm_amt = 0.5

	playsound(target, sound, 45, TRUE, -2, ignore_walls = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [target]'s [pussy_text]."))

	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/slap_pussy/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] hand from [target]'s groin."))
