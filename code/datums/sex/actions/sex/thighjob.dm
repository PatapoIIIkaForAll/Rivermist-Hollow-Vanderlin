/datum/sex_action/sex/thighjob
	name = "Fuck thighs"
	target_menu_zone_mask = SEX_UI_ZONE_LEGS
	requires_hole_storage = FALSE
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/sex/thighjob/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return
	return TRUE

/datum/sex_action/sex/thighjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/thighjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] grabs [target]'s thighs and shoves [user.p_their()] cock inbetween!"))

/datum/sex_action/sex/thighjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks [target]'s thighs."))
	play_rub_sound("skin", user, 20)
	do_thrust_animate(user, target)

	perform_sex_action(user, target, 2, 4, 2)
	handle_passive_ejaculation()

/datum/sex_action/sex/thighjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out from inbetween [target]'s thighs."))
