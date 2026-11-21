/datum/sex_action/masturbate/slap_breasts
	name = "Slap breasts"
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	do_time = 2.5 SECONDS
	stamina_cost = 0

/datum/sex_action/masturbate/slap_breasts/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/slap_breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/slap_breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] raises [user.p_their()] hand over [user.p_their()] breasts..."))

/datum/sex_action/masturbate/slap_breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/sound = get_slap_sound("clap")
	var/action_text = "slaps"
	var/arousal_amt = 0.8
	var/pain_amt = 1.0
	var/orgasm_amt = 0.2

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 1.2
			pain_amt = 1.8
			orgasm_amt = 0.4
		if(SEX_FORCE_HIGH)
			action_text = "roughly slaps"
			arousal_amt = 1.4
			pain_amt = 2.8
			orgasm_amt = 0.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "smacks"
			arousal_amt = 1.3
			pain_amt = 4.0
			orgasm_amt = 0.4

	playsound(user, sound, 45, TRUE, -2, ignore_walls = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [user.p_their()] breasts."))

	perform_sex_action(user, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/slap_breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] hand from [user.p_their()] chest."))

/datum/sex_action/masturbate/other/slap_breasts
	name = "Breast slapping"
	remote_phrase = "Slap their breasts"
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	do_time = 2.5 SECONDS
	stamina_cost = 0
	mage_hand_overlay_zone = MAGE_HAND_ZONE_CHEST

/datum/sex_action/masturbate/other/slap_breasts/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/slap_breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/slap_breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] raises [user.p_their()] hand over [target]'s breasts..."))

/datum/sex_action/masturbate/other/slap_breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/sound = get_slap_sound("clap")
	var/action_text = "slaps"
	var/arousal_amt = 0.8
	var/pain_amt = 1.0
	var/orgasm_amt = 0.2

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 1.2
			pain_amt = 1.8
			orgasm_amt = 0.4
		if(SEX_FORCE_HIGH)
			action_text = "roughly slaps"
			arousal_amt = 1.4
			pain_amt = 2.8
			orgasm_amt = 0.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "smacks"
			arousal_amt = 1.3
			pain_amt = 4.0
			orgasm_amt = 0.4

	playsound(target, sound, 45, TRUE, -2, ignore_walls = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [target]'s breasts."))

	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/slap_breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] hand from [target]'s chest."))
