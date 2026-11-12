/datum/sex_action/sex/anal
	name = "Fuck ass"
	hole_id = ORGAN_SLOT_ANUS
	stamina_cost = 0.5

/datum/sex_action/sex/anal/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/anal/can_perform(mob/living/user, mob/living/target)
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
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/anal/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	// Still pressing at the opening: nothing went in yet, so no entry line or sound.
	if(orifice_pressing)
		return .
	user.visible_message(span_warning("[user] slides [user.p_their()] cock into [target]'s butt!"))
	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/sex/anal/on_perform(mob/living/user, mob/living/target)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks [target]'s ass."))
	var/used_sex_volume = sex_volume
	playsound(target, get_force_sound(), used_sex_volume, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	perform_sex_action(user, target, 2, 0, 2)

	if(considered_limp(user))
		perform_sex_action(target, user, 1.2, 4, 1.2)
	else
		perform_sex_action(target, user, 2.4, 9, 2.4)
	handle_passive_ejaculation(target)

/datum/sex_action/sex/anal/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		user.visible_message(span_love("[user] cums with their butt from [target]'s cock!"))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_SELF
	else
		user.visible_message(span_love("[user] cums into [target]'s butt!"))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_INTO


/datum/sex_action/sex/anal/on_finish(mob/living/user, mob/living/target)
	// The parent clears the pressing state, so read it first.
	var/was_pressing = orifice_pressing
	. = ..()
	if(was_pressing)
		user.visible_message(span_warning("[user] gives up pressing [user.p_their()] cock against [target]'s butt."))
		return
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out of [target]'s butt."))
