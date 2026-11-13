/datum/sex_action/masturbate/other/breasts
	name = "Breast rubbing"
	remote_phrase = "Rub their breasts"
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	mage_hand_overlay_zone = MAGE_HAND_ZONE_CHEST

/datum/sex_action/masturbate/other/breasts/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rubbing [target]'s breasts..."))

/datum/sex_action/masturbate/other/breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fondles [target]'s breasts..."))

	perform_sex_action(target, user, 1 * get_breast_touch_multiplier(target), 0, 0.1)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops fondling [target]'s breasts."))
