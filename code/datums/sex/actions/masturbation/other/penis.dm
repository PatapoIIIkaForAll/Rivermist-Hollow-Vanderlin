/datum/sex_action/masturbate/other/penis
	name = "Handjob"
	remote_phrase = "Jerk them off"
	check_same_tile = FALSE

/datum/sex_action/masturbate/other/penis/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/penis/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/penis/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts jerking [target]'s off..."))

/datum/sex_action/masturbate/other/penis/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] jerks [target]'s cock off..."))
	play_rub_sound("handjob", target, 30)

	perform_sex_action(target, user, 2, 0, 2)

	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/penis/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops jerking [target]'s off."))

/datum/sex_action/masturbate/other/penis/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(target, ORGAN_SLOT_PENIS, null, FALSE)
