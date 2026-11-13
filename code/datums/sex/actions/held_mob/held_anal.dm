/datum/sex_action/held_mob_fuck/anal
	name = "Held anal"
	hole_id = ORGAN_SLOT_ANUS

/datum/sex_action/held_mob_fuck/anal/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	// Still pressing at the opening: nothing went in yet, so no entry line or sound.
	if(orifice_pressing)
		return .
	user.visible_message(span_warning("[user] forces [target] down onto [user.p_their()] cock!"))
	playsound(user, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/held_mob_fuck/anal/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] pumps [target] along [user.p_their()] cock."))

	playsound(user, get_force_sound(), sex_volume, TRUE, -2, ignore_walls = FALSE)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	apply_held_mob_thrust(user, target)
	handle_passive_ejaculation(target)

/datum/sex_action/held_mob_fuck/anal/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		target.visible_message(span_love("[target] spills over [user]'s fingers!"))
		return ORGASM_LOCATION_ONTO
	user.visible_message(span_love("[user] empties themselves into [target]!"))
	user.lose_virginity()
	return ORGASM_LOCATION_INTO

/datum/sex_action/held_mob_fuck/anal/on_finish(mob/living/user, mob/living/target)
	// The parent clears the pressing state, so read it first.
	var/was_pressing = orifice_pressing
	. = ..()
	if(was_pressing)
		user.visible_message(span_warning("[user] gives up forcing [target] down onto [user.p_their()] cock."))
		return
	user.visible_message(span_warning("[user] pulls [target] free with a wet sound."))
