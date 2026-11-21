// Hypnosis: consent, helpers and the suggestion a trance leaves on a mind.

/datum/erp_preference/boolean/allow_hypnosis
	name = "Hypnosis"
	description = "If you can hypnotize others and be hypnotized, and if you see hypnosis examine text. Turning it off ends your current trance"
	default_value = FALSE
	category = "General"

/datum/erp_preference/boolean/allow_hypnosis/set_value(datum/preferences/prefs, value)
	. = ..()
	if(value)
		return
	var/mob/living/body = prefs?.parent?.mob
	if(!istype(body))
		return
	body.hypnosis_channel_cancelled = TRUE
	qdel(body.mind?.hypnotic_suggestion)

/// Both sides of every hypnosis check need this.
/mob/proc/allows_hypnosis()
	return has_erp_pref(/datum/erp_preference/boolean/allow_hypnosis)

/// Endurance, plus two for the Iron Will quirk.
/mob/living/proc/hypnosis_willpower()
	. = GET_MOB_ATTRIBUTE_VALUE(src, STAT_ENDURANCE)
	if(has_quirk(/datum/quirk/positive/iron_will))
		. += 2

/// Whether others can look this mob in the eyes.
/mob/living/proc/hypnosis_eyes_visible()
	return FALSE

/mob/living/carbon/hypnosis_eyes_visible()
	if(!getorganslot(ORGAN_SLOT_EYES) || is_eyes_covered())
		return FALSE
	for(var/obj/item/clothing/worn in list(head, wear_mask, mouth))
		if(worn.flags_inv & HIDEEYES)
			return FALSE
		if(istype(worn, /obj/item/clothing/face/blindfold))
			return FALSE
	return TRUE

/mob/living/proc/hypnosis_can_see()
	return stat == CONSCIOUS && !is_blind()

/proc/hypnosis_styles()
	return list("Hypnotic", "Violet", "Rose", "Velvet", "Gold", "Moss", "Crimson")

/proc/hypnosis_format(text, style = "Hypnotic")
	text = html_encode(text)
	switch(style)
		if("Violet")
			return "<span style='color:#b56cff'>[text]</span>"
		if("Rose")
			return "<span style='color:#ff8fca'>[text]</span>"
		if("Velvet")
			return "<span style='color:#c45b85'>[text]</span>"
		if("Gold")
			return "<span style='color:#e8c65a'>[text]</span>"
		if("Moss")
			return "<span style='color:#72c779'>[text]</span>"
		if("Crimson")
			return "<span style='color:#d0343f'>[text]</span>"
	return span_hypnophrase(text)

/// Strips markup from heard speech and caps its length.
/proc/hypnosis_plaintext(text, max_length = MAX_MESSAGE_LEN)
	if(!istext(text))
		return ""
	var/static/regex/markup = regex(@"<[^>]*>", "g")
	return trim(copytext_char(html_decode(markup.Replace(text, "")), 1, max_length + 1))

/datum/mind
	/// The suggestion this mind carries, if any.
	var/datum/hypnotic_suggestion/hypnotic_suggestion
	/// Weakrefs to minds this one gives in to without a prompt.
	var/list/hypnosis_trusted

/mob/living
	/// Set to stop a running hypnosis channel that involves this mob.
	var/hypnosis_channel_cancelled = FALSE
	/// TRUE while this mob is in a hypnosis channel.
	var/hypnosis_channeling = FALSE

/datum/mind/proc/trusts_hypnotist(datum/mind/caster_mind)
	for(var/datum/weakref/ref as anything in hypnosis_trusted)
		if(ref.resolve() == caster_mind)
			return TRUE
	return FALSE

/datum/mind/proc/trust_hypnotist(datum/mind/caster_mind)
	if(!trusts_hypnotist(caster_mind))
		LAZYADD(hypnosis_trusted, WEAKREF(caster_mind))

/// A trance and the words that fill it; owned by the target's mind so it follows body swaps.
/datum/hypnotic_suggestion
	var/datum/weakref/target_mind_ref
	var/datum/weakref/caster_mind_ref
	var/datum/weakref/body_ref
	var/caster_name
	var/mode = HYPNOSIS_MODE_SUGGESTION
	var/duration = 1 HOURS
	/// The suggestion, or the trigger phrase in trigger mode.
	var/phrase
	/// The latest command heard during a trigger daze.
	var/command
	var/pending_timer
	var/reminder_timer
	var/expiry_timer
	var/expires_at
	COOLDOWN_DECLARE(trigger_cooldown)

/datum/hypnotic_suggestion/New(datum/mind/target_mind, datum/mind/caster_mind, new_mode, new_duration)
	target_mind_ref = WEAKREF(target_mind)
	caster_mind_ref = WEAKREF(caster_mind)
	caster_name = caster_mind.current?.real_name || caster_mind.name
	mode = new_mode || HYPNOSIS_MODE_SUGGESTION
	duration = clamp(new_duration || 1 HOURS, 1 MINUTES, HYPNOSIS_MAX_DURATION)
	target_mind.hypnotic_suggestion = src
	RegisterSignal(target_mind, COMSIG_PARENT_QDELETING, PROC_REF(end_by_signal))
	RegisterSignal(target_mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transferred))
	RegisterSignal(SSdcs, COMSIG_GLOB_HUMAN_ENTER_CRYO, PROC_REF(on_cryo))
	bind_body(target_mind.current)
	pending_timer = addtimer(CALLBACK(src, PROC_REF(expire_pending)), HYPNOSIS_PENDING_TIME, TIMER_STOPPABLE)
	return ..()

/datum/hypnotic_suggestion/Destroy()
	deltimer(pending_timer)
	deltimer(reminder_timer)
	deltimer(expiry_timer)
	unbind_body()
	UnregisterSignal(SSdcs, COMSIG_GLOB_HUMAN_ENTER_CRYO)
	var/datum/mind/target_mind = target_mind_ref?.resolve()
	if(target_mind)
		UnregisterSignal(target_mind, list(COMSIG_PARENT_QDELETING, COMSIG_MIND_TRANSFERRED))
		if(target_mind.hypnotic_suggestion == src)
			target_mind.hypnotic_suggestion = null
	return ..()

/datum/hypnotic_suggestion/proc/get_target_body()
	return body_ref?.resolve()

/datum/hypnotic_suggestion/proc/get_caster_mind()
	return caster_mind_ref?.resolve()

/datum/hypnotic_suggestion/proc/bind_body(mob/living/body)
	unbind_body()
	if(!istype(body) || QDELETED(body))
		return
	body_ref = WEAKREF(body)
	RegisterSignal(body, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(on_body_deleted))
	body.apply_status_effect(/datum/status_effect/hypnotized, src)
	if(phrase)
		body.add_stress(/datum/stress_event/hypnotized)

/datum/hypnotic_suggestion/proc/unbind_body()
	var/mob/living/body = get_target_body()
	body_ref = null
	if(QDELETED(body))
		return
	UnregisterSignal(body, list(COMSIG_MOVABLE_HEAR, COMSIG_PARENT_QDELETING))
	var/datum/status_effect/hypnotized/effect = body.has_status_effect(/datum/status_effect/hypnotized)
	if(effect?.suggestion == src)
		effect.suggestion = null
		qdel(effect)
	body.remove_status_effect(/datum/status_effect/hypnosis_daze)
	body.remove_stress(/datum/stress_event/hypnotized)

/datum/hypnotic_suggestion/proc/on_mind_transferred(datum/mind/source, mob/previous_body)
	SIGNAL_HANDLER
	bind_body(source.current)

/datum/hypnotic_suggestion/proc/on_body_deleted(datum/source)
	SIGNAL_HANDLER
	unbind_body()

/datum/hypnotic_suggestion/proc/end_by_signal(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/hypnotic_suggestion/proc/on_cryo(datum/source, mob/departing)
	SIGNAL_HANDLER
	if(departing && departing == get_target_body())
		qdel(src)

/datum/hypnotic_suggestion/proc/tell_target(text)
	var/mob/living/body = get_target_body()
	if(body?.allows_hypnosis())
		to_chat(body, text)

/datum/hypnotic_suggestion/proc/tell_caster(text)
	var/datum/mind/caster_mind = get_caster_mind()
	var/mob/living/caster = caster_mind?.current
	if(caster?.allows_hypnosis())
		to_chat(caster, text)

/// Listens for the caster's words: the first sentence fills the trance, later ones may spring the trigger.
/datum/hypnotic_suggestion/proc/on_hear(mob/living/listener, list/hearing_args)
	SIGNAL_HANDLER
	var/mob/living/speaker = hearing_args[HEARING_SPEAKER]
	if(!isliving(speaker) || speaker == listener || !speaker.mind || speaker.mind != get_caster_mind())
		return
	if(hearing_args[HEARING_RADIO_FREQ] || !listener.can_hear() || listener.stat != CONSCIOUS)
		return
	var/datum/language/language = hearing_args[HEARING_LANGUAGE]
	if(language && !(listener.has_language(language) || listener.check_language_hear(language)))
		return
	var/list/message_mods = hearing_args[HEARING_MESSAGE_MODE]
	if(LAZYACCESS(message_mods, WHISPER_MODE) && get_dist(speaker, listener) > 1)
		return
	if(!listener.allows_hypnosis() || !speaker.allows_hypnosis())
		return
	var/text = hypnosis_plaintext(hearing_args[HEARING_RAW_MESSAGE])
	if(!length(text))
		return
	if(!phrase)
		capture_phrase(listener, speaker, text)
		return
	if(mode != HYPNOSIS_MODE_TRIGGER)
		return
	var/datum/status_effect/hypnosis_daze/daze = listener.has_status_effect(/datum/status_effect/hypnosis_daze)
	if(daze && !daze.command_heard)
		daze.command_heard = TRUE
		command = text
		update_status()
		addtimer(CALLBACK(src, PROC_REF(tell_target), span_hypnophrase("The command settles where the trigger opened you: [html_encode(command)]")), 1)
		log_game("HYPNOSIS: [key_name(speaker)] commanded [key_name(listener)] in a daze: '[command]'.")
		return
	if(!daze && COOLDOWN_FINISHED(src, trigger_cooldown) && findtext(text, phrase))
		COOLDOWN_START(src, trigger_cooldown, HYPNOSIS_TRIGGER_COOLDOWN)
		INVOKE_ASYNC(listener, TYPE_PROC_REF(/mob/living, apply_status_effect), /datum/status_effect/hypnosis_daze, src)

/datum/hypnotic_suggestion/proc/capture_phrase(mob/living/listener, mob/living/speaker, text)
	if(mode == HYPNOSIS_MODE_TRIGGER && length_char(text) > HYPNOSIS_TRIGGER_MAX_LENGTH)
		addtimer(CALLBACK(src, PROC_REF(tell_caster), span_warning("That is too long to take root as a trigger. I need a shorter phrase.")), 1)
		return
	phrase = text
	deltimer(pending_timer)
	pending_timer = null
	expires_at = world.time + duration
	expiry_timer = addtimer(CALLBACK(src, PROC_REF(expire)), duration, TIMER_STOPPABLE)
	reminder_timer = addtimer(CALLBACK(src, PROC_REF(remind)), HYPNOSIS_REMINDER_TIME, TIMER_STOPPABLE | TIMER_LOOP)
	listener.add_stress(/datum/stress_event/hypnotized)
	update_status()
	if(mode == HYPNOSIS_MODE_TRIGGER)
		addtimer(CALLBACK(src, PROC_REF(tell_target), span_hypnophrase("The words sink in and wait there. Whenever [caster_name] says \"[html_encode(phrase)]\", you will slip back under.")), 1)
		addtimer(CALLBACK(src, PROC_REF(tell_caster), span_hypnophrase("The trigger takes root. Saying \"[html_encode(phrase)]\" near them will pull them back under.")), 1)
	else
		addtimer(CALLBACK(src, PROC_REF(tell_target), span_hypnophrase("The words sink deep and settle: [html_encode(phrase)]")), 1)
		addtimer(CALLBACK(src, PROC_REF(tell_caster), span_hypnophrase("The suggestion takes hold of them.")), 1)
	log_game("HYPNOSIS: [key_name(speaker)] gave [key_name(listener)] a [mode] for [DisplayTimeText(duration)]: '[phrase]'.")

/datum/hypnotic_suggestion/proc/update_status()
	var/mob/living/body = get_target_body()
	var/datum/status_effect/hypnotized/effect = body?.has_status_effect(/datum/status_effect/hypnotized)
	effect?.update_alert()

/// What the alert and the reminders show the target.
/datum/hypnotic_suggestion/proc/describe()
	if(!phrase)
		return "My mind is open and waiting. The next words [caster_name] says to me will stay."
	if(mode == HYPNOSIS_MODE_TRIGGER)
		. = "When [caster_name] says \"[phrase]\", I slip back into trance."
		if(command)
			. += " Last command: [command]"
		return
	return "I feel compelled to follow: [phrase]"

/datum/hypnotic_suggestion/proc/time_left_text()
	if(!expires_at)
		return null
	return DisplayTimeText(max(expires_at - world.time, 0), 60)

/datum/hypnotic_suggestion/proc/remind()
	var/mob/living/body = get_target_body()
	if(!body || body.stat == DEAD)
		return
	if(body.client && !body.allows_hypnosis())
		qdel(src)
		return
	tell_target(span_hypnophrase("<i>...[html_encode(describe())]...</i>"))

/datum/hypnotic_suggestion/proc/expire_pending()
	pending_timer = null
	if(phrase)
		return
	tell_target(span_hypnophrase("The trance thins and fades. My thoughts are my own again."))
	qdel(src)

/datum/hypnotic_suggestion/proc/expire()
	expiry_timer = null
	tell_target(span_hypnophrase("The suggestion loosens and slips away. My thoughts are my own again."))
	tell_caster(span_notice("My hold on [get_target_body() || "their mind"] fades."))
	qdel(src)

/// Ends the trance from outside; [how] picks the message.
/datum/hypnotic_suggestion/proc/release(how = "released")
	var/mob/living/body = get_target_body()
	switch(how)
		if("released")
			tell_target(span_hypnophrase("My head clears. The words lose their hold on me."))
		if("self")
			tell_target(span_hypnophrase("I tear my thoughts free. The words are only words again."))
			tell_caster(span_warning("I feel my hold on [body || "their mind"] snap."))
		if("overwritten")
			tell_target(span_hypnophrase("The old words wash away under a stronger pull."))
	log_game("HYPNOSIS: [key_name(body)]'s [mode] from [caster_name] ended ([how]).")
	qdel(src)

/datum/stress_event/hypnotized
	desc = "<span class='nicegreen'>My thoughts are quiet and simple.</span>\n"
	stress_change = -1
	timer = 0
