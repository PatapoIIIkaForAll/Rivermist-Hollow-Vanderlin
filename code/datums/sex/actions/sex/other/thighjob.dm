/datum/sex_action/sex/other/thighjob
	name = "Give thighjob"
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	requires_hole_storage = FALSE
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/sex/other/thighjob/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/other/thighjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/other/thighjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] moves [user.p_their()] thighs between [target]'s cock..."))

/datum/sex_action/sex/other/thighjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] jerks [target]'s cock with [user.p_their()] thighs..."))
	play_rub_sound("skin", target, 30)
	do_thrust_animate(target, user)

	perform_sex_action(target, user, 2, 4, 2)
	handle_passive_ejaculation(target)

/datum/sex_action/sex/other/thighjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops jerking [target] off with [user.p_their()] thighs..."))

