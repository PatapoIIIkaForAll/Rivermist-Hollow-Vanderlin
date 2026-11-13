/datum/sex_action/frotting
	name = "Frot them"
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/frotting/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return
	return TRUE

/datum/sex_action/frotting/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/frotting/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] shoves [user.p_their()] cock against [target]'s own!"))

/datum/sex_action/frotting/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] frots cocks together with [target]."))
	play_rub_sound("grind", user, 20)

	perform_sex_action(user, target, 1, 4, 1)
	handle_passive_ejaculation()

	perform_sex_action(target, user, 1, 4, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/frotting/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of both their cocks."))

/datum/sex_action/frotting/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	add_sex_lock(target, ORGAN_SLOT_PENIS)
