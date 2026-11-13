/datum/sex_action/kissing
	name = "Make out"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	check_same_tile = FALSE

/datum/sex_action/kissing/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/kissing/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/kissing/on_start(mob/living/user, mob/living/target)
	..()
	user.visible_message(span_warning("[user] starts making out with [target]..."))

/datum/sex_action/kissing/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] makes out with [target]..."))
	user.make_mouth_noise("kiss")

	// Kissing has no pain of its own; only the top force step bites hard enough to sting.
	var/pain_amt = (force >= SEX_FORCE_EXTREME) ? 2.5 : 0

	perform_sex_action(user, target, 1, pain_amt, 0)
	handle_passive_ejaculation(user)

	perform_sex_action(target, user, 1, pain_amt, 0)
	handle_passive_ejaculation(target)

/datum/sex_action/kissing/on_finish(mob/living/user, mob/living/target)
	..()
	user.visible_message(span_warning("[user] stops making out with [target] ..."))

/datum/sex_action/kissing/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH)
