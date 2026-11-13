/datum/sex_action/rimming
	name = "Rimjob"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	gags_user = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_ANUS

/datum/sex_action/rimming/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target && !allows_self_use(user))
		return FALSE
	return TRUE

/datum/sex_action/rimming/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target && !allows_self_use(user))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_ANUS))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/rimming/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rimming [target]'s butt..."))

/datum/sex_action/rimming/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rims [target]'s butt..."))
	user.make_mouth_noise("lick")
	do_thrust_animate(user, target)

	perform_sex_action(target, user, 2, 0, 1.5)
	handle_passive_ejaculation(target)
	deposit_saliva_in_hole(user, target, ORGAN_SLOT_ANUS, 0.5, 4)

/datum/sex_action/rimming/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops rimming [target]'s butt ..."))

/datum/sex_action/rimming/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(target, ORGAN_SLOT_ANUS, null, FALSE)
