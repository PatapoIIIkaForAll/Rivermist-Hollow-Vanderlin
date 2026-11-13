/datum/sex_action/masturbate/breasts
	name = "Rub breasts"
	target_menu_zone_mask = SEX_UI_ZONE_BODY

/datum/sex_action/masturbate/breasts/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rubbing [user.p_their()] breasts..."))

/datum/sex_action/masturbate/breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fondles [user.p_their()] breasts..."))

	perform_sex_action(user, user, 1 * get_breast_touch_multiplier(user), 0, 0.1)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops fondling [user.p_their()] breasts."))
