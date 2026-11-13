/datum/sex_action/masturbate/penis_over
	name = "Jerk over"
	check_same_tile = FALSE
	target_menu_zone_mask = SEX_UI_ZONE_MISC

/datum/sex_action/masturbate/penis_over/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/penis_over/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/penis_over/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts jerking over [target]..."))

/datum/sex_action/masturbate/penis_over/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/chosen_verb = pick(list("jerks [user.p_their()] cock", "strokes [user.p_their()] cock", "masturbates", "jerks off"))
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [chosen_verb] over [target]"))
	play_rub_sound("fap", user, 30)

	perform_sex_action(user, user, 2, 0, 2)

/datum/sex_action/masturbate/penis_over/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] cums over [target]'s body!"))
	return ORGASM_LOCATION_ONTO

/datum/sex_action/masturbate/penis_over/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops jerking off."))

/datum/sex_action/masturbate/penis_over/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(user, ORGAN_SLOT_PENIS, null, FALSE)
