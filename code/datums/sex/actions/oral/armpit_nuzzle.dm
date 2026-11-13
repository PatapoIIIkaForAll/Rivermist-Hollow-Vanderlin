/datum/sex_action/armpit_nuzzle
	name = "Nuzzle armpit"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_ARMS

/datum/sex_action/armpit_nuzzle/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/armpit_nuzzle/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/armpit_nuzzle/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] moves [user.p_their()] head against [target]'s armpit..."))

/datum/sex_action/armpit_nuzzle/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] nuzzles [target]'s armpit..."))
	perform_sex_action(user, target, 0.6, 0, 0)

	perform_sex_action(target, user, 0.3, 0, 0)

/datum/sex_action/armpit_nuzzle/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops nuzzling [target]'s armpit..."))

/datum/sex_action/armpit_nuzzle/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
