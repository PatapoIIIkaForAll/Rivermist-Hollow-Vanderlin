/datum/sex_action/sex/vaginal
	name = "Fuck pussy"
	hole_id = ORGAN_SLOT_VAGINA
	stamina_cost = 0.5

/datum/sex_action/sex/vaginal/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/sex/vaginal/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/vaginal/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	// Still pressing at the opening: nothing went in yet, so no entry line or sound.
	if(orifice_pressing)
		return .
	user.visible_message(span_warning("[user] slides [user.p_their()] cock into [target]'s pussy!"))

	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/sex/vaginal/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks [target]'s pussy."))

	playsound(target, get_force_sound(), sex_volume, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	perform_sex_action(user, target, 2, 0, 2)

	if(considered_limp(user))
		perform_sex_action(target, user, 1.2, 4, 1.2)
	else
		perform_sex_action(target, user, 2.4, 9, 2.4)
	handle_passive_ejaculation(target)

/datum/sex_action/sex/vaginal/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		user.visible_message(span_love("[user] creams themselves around [target]'s dick!"))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_ONTO
	else
		user.visible_message(span_love("[user] cums into [target]'s pussy!"))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_INTO


/datum/sex_action/sex/vaginal/on_finish(mob/living/user, mob/living/target)
	// The parent clears the pressing state, so read it first.
	var/was_pressing = orifice_pressing
	. = ..()
	if(was_pressing)
		user.visible_message(span_warning("[user] gives up pressing [user.p_their()] cock against [target]'s pussy."))
		return
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out of [target]'s pussy."))
