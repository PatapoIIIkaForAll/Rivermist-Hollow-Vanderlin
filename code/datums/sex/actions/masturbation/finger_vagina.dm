/datum/sex_action/masturbate/vagina_finger
	name = "Finger pussy"

/datum/sex_action/masturbate/vagina_finger/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/vagina_finger/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/vagina_finger/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts fingering [user.p_their()] [pick("slit","cunt","pussy","snatch")]..."))

/datum/sex_action/masturbate/vagina_finger/on_perform(mob/living/user, mob/living/target)
	. = ..()
	apply_finger_lube(user, user, ORGAN_SLOT_VAGINA)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fingers [user.p_their()] [pick("slit","cunt","pussy","snatch")]..."))
	play_rub_sound("finger", user, 30, ORGAN_SLOT_VAGINA)

	perform_sex_action(user, user, 2, 1, 2)

	handle_passive_ejaculation()

/datum/sex_action/masturbate/vagina_finger/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops fingering."))

/datum/sex_action/masturbate/vagina_finger/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(user, ORGAN_SLOT_VAGINA, null, FALSE)
