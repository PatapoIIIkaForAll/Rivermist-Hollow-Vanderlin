/datum/sex_action/foot_lick
	name = "Lick feet"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_LEGS
	check_same_tile = FALSE

/datum/sex_action/foot_lick/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/foot_lick/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_R_FOOT))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_L_FOOT))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)) //don't make me regret not locking your feet out while they are getting licked
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/foot_lick/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts licking [target]'s feet..."))

/datum/sex_action/foot_lick/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] licks [target]'s feet..."))
	user.make_mouth_noise("lick")
	perform_sex_action(user, target, 0.5, 0, 0)

	perform_sex_action(target, user, 0.25, 0, 0)

/datum/sex_action/foot_lick/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops licking [target]'s feet ..."))

/datum/sex_action/foot_lick/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
