/datum/sex_action/masturbate/penis
	name = "Jerk off"

/datum/sex_action/masturbate/penis/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/penis/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/penis/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts jerking off..."))

/datum/sex_action/masturbate/penis/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/chosen_verb = pick(list("jerks [user.p_their()] cock", "strokes [user.p_their()] cock", "masturbates", "jerks off"))
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [chosen_verb]..."))
	play_rub_sound("fap", user, 30)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	perform_sex_action(user, user, 2, 0, 2)

	handle_passive_ejaculation()

/datum/sex_action/masturbate/penis/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops jerking off."))

/datum/sex_action/masturbate/penis/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] blows their load!"))
	return ORGASM_LOCATION_SELF

/datum/sex_action/masturbate/penis/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	add_sex_lock(user, ORGAN_SLOT_PENIS, null, FALSE)
