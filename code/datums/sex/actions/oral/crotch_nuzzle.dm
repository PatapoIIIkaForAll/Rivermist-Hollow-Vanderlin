/datum/sex_action/crotch_nuzzle
	name = "Nuzzle crotch"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/crotch_nuzzle/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/crotch_nuzzle/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/crotch_nuzzle/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] moves [user.p_their()] head against [target]'s crotch..."))

/datum/sex_action/crotch_nuzzle/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] nuzzles [target]'s crotch..."))

	perform_sex_action(target, user, 0.8, 0, 0.5)
	handle_passive_ejaculation(target)
	perform_sex_action(user, target, 0.4, 0, 0)

/datum/sex_action/crotch_nuzzle/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops nuzzling [target]'s crotch..."))

/datum/sex_action/crotch_nuzzle/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
