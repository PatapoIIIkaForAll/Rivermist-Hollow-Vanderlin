/datum/sex_action/sex/boobjob
	name = "Fuck tits"
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	hole_id = ORGAN_SLOT_BREASTS
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/sex/boobjob/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return
	return TRUE

/datum/sex_action/sex/boobjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/boobjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] grabs [target]'s tits and shoves [user.p_their()] cock inbetween!"))

/datum/sex_action/sex/boobjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks [target]'s tits."))
	play_rub_sound("boob", user, 20)

	perform_sex_action(user, target, 2 * get_breast_paizuri_multiplier(target), 4, 2)

/datum/sex_action/sex/boobjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out from inbetween [target]'s tits."))
