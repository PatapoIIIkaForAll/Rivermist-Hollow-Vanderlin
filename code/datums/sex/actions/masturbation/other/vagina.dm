/datum/sex_action/masturbate/other/vagina
	name = "Pussy fingering"
	remote_phrase = "Finger their pussy"
	check_same_tile = FALSE

/datum/sex_action/masturbate/other/vagina/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/vagina/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/vagina/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts fingering [target]'s [pick("slit","cunt","pussy","snatch")]..."))

/datum/sex_action/masturbate/other/vagina/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fingers [target]'s [pick("slit","cunt","pussy","snatch")]..."))
	play_rub_sound("finger", target, 30, ORGAN_SLOT_VAGINA)

	perform_sex_action(target, user, 2, 0, 2)

	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/vagina/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops fingering [target]'s [pick("slit","cunt","pussy","snatch")]."))

/datum/sex_action/masturbate/other/vagina/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(target, ORGAN_SLOT_VAGINA, null, FALSE)
