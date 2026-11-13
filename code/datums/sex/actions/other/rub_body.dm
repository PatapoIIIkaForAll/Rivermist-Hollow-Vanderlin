/datum/sex_action/rub_body
	name = "Rub body"
	remote_phrase = "Rub their body"
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	check_same_tile = FALSE
	requires_free_hands = TRUE
	mage_hand_allowed = TRUE
	mage_hand_overlay_zone = MAGE_HAND_ZONE_BODY

/datum/sex_action/rub_body/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/rub_body/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!find_available_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/rub_body/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] places [user.p_their()] hands onto [target]..."))

/datum/sex_action/rub_body/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rubs [target]'s body..."))
	play_rub_sound("skin", target, 25)

	perform_sex_action(target, user, 0.5, 0, 0)
	handle_passive_ejaculation(target)

/datum/sex_action/rub_body/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops rubbing [target]'s body ..."))

/datum/sex_action/rub_body/lock_sex_object(mob/living/user, mob/living/target)
	var/locked = get_hand_lock_slot(user)
	if(locked)
		add_sex_lock(user, locked)
