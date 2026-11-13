/datum/sex_action/masturbate/vagina
	name = "Stroke clit"

/datum/sex_action/masturbate/vagina/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/vagina/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/vagina/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts stroking [user.p_their()] clit..."))

/datum/sex_action/masturbate/vagina/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] strokes [user.p_their()] clit..."))
	play_rub_sound("finger", user, 30, ORGAN_SLOT_VAGINA)

	perform_sex_action(user, user, 2, 0, 2)

	handle_passive_ejaculation()

/datum/sex_action/masturbate/vagina/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops stroking."))

/datum/sex_action/masturbate/vagina/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] creams themself!"))
	return ORGASM_LOCATION_SELF
