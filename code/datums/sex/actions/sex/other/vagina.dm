/datum/sex_action/sex/other/vagina
	name = "Ride them"
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	hole_id = ORGAN_SLOT_VAGINA
	stamina_cost = 0.5
	aggro_grab_instead_same_tile = FALSE

/datum/sex_action/sex/other/vagina/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/other/vagina/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/other/vagina/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	// Still pressing at the opening: nothing went in yet, so no entry line or sound.
	if(orifice_pressing)
		return .
	user.visible_message(span_warning("[user] gets on top of [target] and begins riding [target.p_them()] with [user.p_their()] cunt!"))
	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/sex/other/vagina/on_perform(mob/living/user, mob/living/target)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rides [target]."))
	var/used_sex_volume = sex_volume
	playsound(target, get_force_sound(), used_sex_volume, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	// The rider's hole takes the strain; the cock under them feels no pain, as in "Fuck pussy".
	if(considered_limp(target))
		perform_sex_action(user, target, 1.2, 3, 3)
	else
		perform_sex_action(user, target, 2.4, 7, 2)
	handle_passive_ejaculation(target)

	perform_sex_action(target, user, 2, 0, 3)

/datum/sex_action/sex/other/vagina/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		user.visible_message(span_love("[user] cums into [target]'s pussy!"))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_INTO
	else
		user.visible_message(span_love("[user] creams themselves around [target]'s dick!"))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_ONTO

/datum/sex_action/sex/other/vagina/on_finish(mob/living/user, mob/living/target)
	// The parent clears the pressing state, so read it first.
	var/was_pressing = orifice_pressing
	. = ..()
	if(was_pressing)
		user.visible_message(span_warning("[user] gives up trying to sink onto [target]'s cock."))
		return
	user.visible_message(span_warning("[user] gets off [target]."))
