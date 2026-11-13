/datum/sex_action/masturbate/anus
	name = "Finger butt"

/datum/sex_action/masturbate/anus/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate/anus/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_ANUS))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/anus/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts fingering [user.p_their()] butt..."))

/datum/sex_action/masturbate/anus/on_perform(mob/living/user, mob/living/target)
	. = ..()
	apply_finger_lube(user, user, ORGAN_SLOT_ANUS)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fingers [user.p_their()] butt..."))
	play_rub_sound("finger", user, 30, ORGAN_SLOT_ANUS)

	perform_sex_action(user, user, 2, 2, 2)
	handle_passive_ejaculation()
	stretch_with_fingers(user, ORGAN_SLOT_ANUS)

/datum/sex_action/masturbate/anus/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops fingering [user.p_their()] butt."))
