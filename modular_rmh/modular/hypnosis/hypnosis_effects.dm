// Hypnosis status effects: the lasting trance marker and the short daze a trigger causes.

/datum/status_effect/hypnotized
	id = "hypnotized"
	duration = -1
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/hypnotized
	var/datum/hypnotic_suggestion/suggestion

/datum/status_effect/hypnotized/on_creation(mob/living/new_owner, datum/hypnotic_suggestion/new_suggestion)
	suggestion = new_suggestion
	. = ..(new_owner)
	if(.)
		update_alert()

/datum/status_effect/hypnotized/on_remove()
	// Removed by anything but the suggestion itself, the trance ends too.
	var/datum/hypnotic_suggestion/old = suggestion
	suggestion = null
	if(old && !QDELETED(old))
		qdel(old)
	return ..()

/datum/status_effect/hypnotized/proc/update_alert()
	if(!linked_alert || !suggestion)
		return
	var/text = hypnosis_format(suggestion.describe())
	var/time_left = suggestion.time_left_text()
	if(time_left)
		text += "<br>It will fade in about [time_left]."
	if(owner.hypnosis_willpower() >= HYPNOSIS_WILL_SELF_RELEASE)
		text += "<br>My will is strong enough to fight it. Click to try."
	linked_alert.desc = text

/datum/status_effect/hypnotized/get_examine_text(mob/user, list/P)
	if(!suggestion || user == owner || !isliving(user) || !user.allows_hypnosis())
		return null
	var/mob/living/viewer = user
	if(!viewer.hypnosis_can_see() || !owner.hypnosis_eyes_visible())
		return null
	if(viewer.mind && viewer.mind == suggestion.get_caster_mind())
		return span_hypnophrase("[owner.p_their(TRUE)] mind still answers to mine.")
	return span_warning("[owner.p_their(TRUE)] eyes look distant and glassy.")

/// Fights the suggestion off alone; strong-willed minds only.
/datum/status_effect/hypnotized/proc/try_self_release()
	if(!suggestion || !owner)
		return
	if(owner.hypnosis_willpower() < HYPNOSIS_WILL_SELF_RELEASE)
		to_chat(owner, span_warning("The words hold me too firmly. My will is not strong enough to break them."))
		return
	if(browser_alert(owner, "Fight the suggestion off? It takes a while, and I must stay still.", "Hypnosis", DEFAULT_INPUT_CHOICES) != CHOICE_YES)
		return
	if(QDELETED(src) || !suggestion)
		return
	to_chat(owner, span_hypnophrase("I close my eyes and push against the words..."))
	if(!do_after(owner, HYPNOSIS_SELF_RELEASE_TIME, owner, IGNORE_HELD_ITEM | IGNORE_USER_DIR_CHANGE, display_over_user = TRUE))
		if(!QDELETED(src))
			to_chat(owner, span_warning("I lose my focus, and the words settle back in."))
		return
	if(QDELETED(src) || !suggestion)
		return
	suggestion.release("self")

/atom/movable/screen/alert/status_effect/hypnotized
	name = "Hypnotized"
	desc = "My mind is open and waiting."
	icon_state = "debuff"
	overlay_icon = 'modular_rmh/icons/hud/hypnosis.dmi'
	overlay_state = "hypnosis"

/atom/movable/screen/alert/status_effect/hypnotized/examine_ui(mob/user)
	var/datum/status_effect/hypnotized/effect = attached_effect
	if(istype(effect))
		effect.update_alert()
	return ..()

/atom/movable/screen/alert/status_effect/hypnotized/Click(location, control, params)
	if(usr != mob_viewer)
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICKED))
		examine_ui(usr)
		return
	var/datum/status_effect/hypnotized/effect = attached_effect
	if(!istype(effect) || !effect.suggestion)
		return
	to_chat(usr, hypnosis_format(effect.suggestion.describe()))
	if(effect.owner.hypnosis_willpower() >= HYPNOSIS_WILL_SELF_RELEASE)
		INVOKE_ASYNC(effect, TYPE_PROC_REF(/datum/status_effect/hypnotized, try_self_release))

/datum/status_effect/hypnosis_daze
	id = "hypnosis_daze"
	duration = HYPNOSIS_DAZE_DURATION
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/hypnosis_daze
	var/datum/weakref/suggestion_ref
	/// The first sentence from the hypnotist during the daze becomes a command.
	var/command_heard = FALSE

/datum/status_effect/hypnosis_daze/on_creation(mob/living/new_owner, datum/hypnotic_suggestion/suggestion)
	suggestion_ref = WEAKREF(suggestion)
	return ..(new_owner)

/datum/status_effect/hypnosis_daze/on_apply()
	. = ..()
	owner.add_client_colour(/datum/client_colour/monochrome/trance)
	owner.add_movespeed_modifier(MOVESPEED_ID_STATUS_EFFECT(id), multiplicative_slowdown = 1.5)
	var/datum/hypnotic_suggestion/suggestion = suggestion_ref?.resolve()
	to_chat(owner, span_hypnophrase("The trigger hits, and my thoughts drop away into the old trance. Whatever [suggestion?.caster_name || "they"] says next will settle in deep."))
	suggestion?.tell_caster(span_hypnophrase("[owner]'s eyes go glassy. The trigger has them; my next words will land as a command."))

/datum/status_effect/hypnosis_daze/on_remove()
	owner.remove_client_colour(/datum/client_colour/monochrome/trance)
	owner.remove_movespeed_modifier(MOVESPEED_ID_STATUS_EFFECT(id))
	if(!QDELETED(owner))
		to_chat(owner, span_hypnophrase("The daze lifts, and the world comes back into focus."))
	return ..()

/atom/movable/screen/alert/status_effect/hypnosis_daze
	name = "Dazed"
	desc = "A trigger has pulled me back under. My thoughts are slow and soft."
	icon_state = "debuff"
	overlay_icon = 'modular_rmh/icons/hud/hypnosis.dmi'
	overlay_state = "hypnosis"
