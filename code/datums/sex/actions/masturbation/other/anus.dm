/datum/sex_action/masturbate/other/anus
	name = "Butt fingering"
	remote_phrase = "Finger their butt"
	check_same_tile = FALSE
	mage_hand_overlay_zone = MAGE_HAND_ZONE_BUTT

/datum/sex_action/masturbate/other/anus/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/anus/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_ANUS))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/anus/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts fingering [target]'s butt..."))

/datum/sex_action/masturbate/other/anus/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fingers [target]'s butt..."))
	play_rub_sound("finger", target, 30, ORGAN_SLOT_ANUS)

	perform_sex_action(target, user, 2, 2, 2)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/anus/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops fingering [target]'s butt."))
