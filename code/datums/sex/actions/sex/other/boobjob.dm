/datum/sex_action/sex/other/boobjob
	name = "Give boobjob"
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	hole_id = ORGAN_SLOT_BREASTS
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/sex/other/boobjob/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return
	return TRUE

/datum/sex_action/sex/other/boobjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(target, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_CHEST))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/other/boobjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning(get_start_message(user, target)))

/datum/sex_action/sex/other/boobjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks [target]'s cock with [user.p_their()] tits."))
	play_rub_sound("boob", target, 20)

	perform_sex_action(target, user, 2 * get_breast_paizuri_multiplier(user), 4, 2)

/datum/sex_action/sex/other/boobjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning(get_finish_message(user, target)))

/datum/sex_action/sex/other/boobjob/proc/get_start_message(mob/living/user, mob/living/target)
	return "[user] presses [target]'s cock between [user.p_their()] tits!"

/datum/sex_action/sex/other/boobjob/proc/get_finish_message(mob/living/user, mob/living/target)
	return "[user] pulls [target]'s cock out from between [user.p_their()] tits."
