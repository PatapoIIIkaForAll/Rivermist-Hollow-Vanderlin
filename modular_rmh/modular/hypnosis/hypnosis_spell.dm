// Hypnosis spells: a still, two-tile channel that opens a trance, or releases one.

/datum/action/cooldown/spell/hypnosis
	name = "Hypnotic Gaze"
	desc = "Hold someone's gaze for ten seconds. The next words they hear from you stay with them as a suggestion or a trigger. Use it on someone already entranced to release them."
	button_icon = 'modular_rmh/icons/hud/hypnosis.dmi'
	button_icon_state = "hypnosis"
	sound = null
	spell_type = NONE
	spell_requirements = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	antimagic_flags = NONE
	charge_required = FALSE
	cooldown_time = 5 SECONDS
	cast_range = HYPNOSIS_RANGE
	self_cast_possible = FALSE
	has_visual_effects = FALSE
	experience_modifier = 0
	/// How long both sides must hold still.
	var/channel_time = 10 SECONDS
	var/needs_caster_eyes = TRUE
	var/needs_target_eyes = TRUE
	/// May replace a trance someone else left.
	var/can_overwrite = FALSE
	var/last_choice
	/// TRUE from the first prompt to the end of the channel.
	var/busy = FALSE
	var/channel_caster_text = "I fix my eyes on %TARGET% and reach for the quiet behind theirs."
	var/channel_target_text = "%CASTER%'s eyes catch mine, and looking away suddenly feels like far too much effort."
	var/trance_caster_text = "Their mind lies open. The next words they hear from me will stay."
	var/trance_target_text = "My thoughts go soft and slow. Whatever %CASTER% says to me next will stay with me."

/datum/action/cooldown/spell/hypnosis/presence
	name = "Hypnotic Presence"
	desc = "Focus your whole attention on someone for ten seconds; no eye contact needed. The next words they hear from you stay with them as a suggestion or a trigger. Use it on someone already entranced to release them."
	needs_caster_eyes = FALSE
	needs_target_eyes = FALSE
	channel_caster_text = "I turn the full weight of my attention onto %TARGET% and press gently against their thoughts."
	channel_target_text = "Something about %CASTER% draws my attention in and will not let it go."

/datum/action/cooldown/spell/hypnosis/pendulum
	name = "Swing the Pendulum"
	desc = "Swing the pendulum before someone's eyes for fifteen seconds. The next words they hear from you stay with them as a suggestion or a trigger. Use it on someone already entranced to release them."
	needs_caster_eyes = FALSE
	channel_time = 15 SECONDS
	channel_caster_text = "I set the pendulum swinging before %TARGET%'s eyes, slow and steady."
	channel_target_text = "%CASTER% sets a little pendulum swinging. My eyes follow it back and forth, back and forth..."

/datum/action/cooldown/spell/hypnosis/succubus
	name = "Infernal Allure"
	desc = "Let your demonic nature wash over someone for eight seconds; no eye contact needed. The next words they hear from you stay with them. You can overwrite a trance someone else left."
	needs_caster_eyes = FALSE
	needs_target_eyes = FALSE
	can_overwrite = TRUE
	channel_time = 8 SECONDS
	channel_caster_text = "I let my nature seep out toward %TARGET%, sweet and heavy."
	channel_target_text = "A warm, heavy sweetness rolls off %CASTER%, and my thoughts begin to drift toward it."

/datum/action/cooldown/spell/hypnosis/vampire
	name = "Mesmerize"
	desc = "Bend your Presence onto someone for eight seconds; no eye contact needed. The next words they hear from you stay with them. You can overwrite a trance someone else left."
	needs_caster_eyes = FALSE
	needs_target_eyes = FALSE
	can_overwrite = TRUE
	channel_time = 8 SECONDS
	channel_caster_text = "I let my Presence settle over %TARGET% like a cold, still weight."
	channel_target_text = "%CASTER% seems to fill the whole world, and my thoughts go very still."

/datum/action/cooldown/spell/hypnosis/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

/datum/action/cooldown/spell/hypnosis/cast(mob/living/carbon/human/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(begin_hypnosis), owner, cast_on)

/datum/action/cooldown/spell/hypnosis/proc/fill_text(text, mob/living/caster, mob/living/target)
	text = replacetext(text, "%CASTER%", "[caster]")
	return replacetext(text, "%TARGET%", "[target]")

/// Why the channel cannot start or go on, or null when it can.
/datum/action/cooldown/spell/hypnosis/proc/get_block_reason(mob/living/carbon/human/caster, mob/living/carbon/human/target)
	if(QDELETED(caster) || QDELETED(target) || caster == target)
		return "The connection is lost."
	if(!caster.allows_hypnosis())
		return "I do not have Hypnosis enabled in my ERP preferences."
	if(!target.client || !target.mind)
		return "There is no mind there for me to reach."
	if(!target.allows_hypnosis())
		return "They have not consented to hypnosis."
	if(caster.stat != CONSCIOUS || target.stat != CONSCIOUS)
		return "We both need to be awake for this."
	var/turf/caster_turf = get_turf(caster)
	var/turf/target_turf = get_turf(target)
	if(!caster_turf || !target_turf || caster_turf.z != target_turf.z || get_dist(caster_turf, target_turf) > cast_range)
		return "They are too far away."
	if(!(target in view(cast_range, caster_turf)))
		return "I cannot reach them through that."
	if(needs_caster_eyes)
		if(!caster.hypnosis_eyes_visible())
			return "My eyes are covered."
		if(!caster.hypnosis_can_see())
			return "I cannot see them."
	if(needs_target_eyes)
		if(!target.hypnosis_eyes_visible())
			return "Their eyes are covered."
		if(!target.hypnosis_can_see())
			return "They cannot see me."
	return null

/datum/action/cooldown/spell/hypnosis/proc/report_block(mob/living/caster, mob/living/target)
	var/reason = get_block_reason(caster, target)
	if(reason)
		to_chat(caster, span_warning(reason))
	return reason

/datum/action/cooldown/spell/hypnosis/proc/get_trance_options()
	return list(
		"Suggestion for half an hour" = list(HYPNOSIS_MODE_SUGGESTION, 30 MINUTES),
		"Suggestion for an hour" = list(HYPNOSIS_MODE_SUGGESTION, 1 HOURS),
		"Suggestion for an hour and a half" = list(HYPNOSIS_MODE_SUGGESTION, HYPNOSIS_MAX_DURATION),
		"Trigger phrase for half an hour" = list(HYPNOSIS_MODE_TRIGGER, 30 MINUTES),
		"Trigger phrase for an hour" = list(HYPNOSIS_MODE_TRIGGER, 1 HOURS),
		"Trigger phrase for an hour and a half" = list(HYPNOSIS_MODE_TRIGGER, HYPNOSIS_MAX_DURATION),
	)

/datum/action/cooldown/spell/hypnosis/proc/begin_hypnosis(mob/living/carbon/human/caster, mob/living/carbon/human/target)
	if(busy)
		to_chat(caster, span_warning("I am already focused on someone."))
		return
	busy = TRUE
	try
		try_hypnosis(caster, target)
	catch(var/exception/error)
		stack_trace("[name] failed: [error]")
	busy = FALSE

/datum/action/cooldown/spell/hypnosis/proc/try_hypnosis(mob/living/carbon/human/caster, mob/living/carbon/human/target)
	if(caster.hypnosis_channeling || target.hypnosis_channeling)
		to_chat(caster, span_warning("One of us is already caught in a trance."))
		return
	if(report_block(caster, target))
		return
	var/datum/hypnotic_suggestion/existing = target.mind.hypnotic_suggestion
	var/releasing = !!existing
	if(existing && can_overwrite && existing.get_caster_mind() != caster.mind)
		var/answer = browser_input_list(caster, "Someone else's words already hold them. What do I do?", "Hypnosis", list("Release them", "Overwrite the trance"))
		if(!answer || QDELETED(src))
			return
		releasing = (answer == "Release them")
	var/list/trance_choice
	if(!releasing)
		var/list/options = get_trance_options()
		var/answer = browser_input_list(caster, "What should the trance leave behind? A suggestion is their next words from you. A trigger phrase pulls them back under whenever you say it.", "Hypnosis", options, last_choice)
		if(!answer || QDELETED(src))
			return
		last_choice = answer
		trance_choice = options[answer]
		if(report_block(caster, target))
			return
		if(!ask_target_consent(caster, target))
			return
	if(QDELETED(src) || report_block(caster, target))
		return
	if(!run_channel(caster, target))
		if(!QDELETED(caster))
			to_chat(caster, span_hypnophrase("My focus breaks, and their thoughts slip out of reach."))
		if(!QDELETED(target) && target.allows_hypnosis())
			to_chat(target, span_hypnophrase("The pull fades before it can settle into my thoughts."))
		return
	if(target.mind.hypnotic_suggestion != existing)
		return
	if(existing)
		if(releasing)
			existing.release("released")
			to_chat(caster, span_hypnophrase("I let go of their mind, and the old words lose their hold."))
			return
		existing.release("overwritten")
	new /datum/hypnotic_suggestion(target.mind, caster.mind, trance_choice[1], trance_choice[2])
	to_chat(caster, span_hypnophrase(fill_text(trance_caster_text, caster, target)))
	to_chat(target, span_hypnophrase(fill_text(trance_target_text, caster, target)))
	log_game("HYPNOSIS: [key_name(caster)] entranced [key_name(target)] with [name].")

/// Strong-willed targets may refuse; returns TRUE when the trance may go ahead.
/datum/action/cooldown/spell/hypnosis/proc/ask_target_consent(mob/living/carbon/human/caster, mob/living/carbon/human/target)
	if(target.hypnosis_willpower() < HYPNOSIS_WILL_PROMPT || target.mind.trusts_hypnotist(caster.mind))
		return TRUE
	to_chat(caster, span_hypnophrase("I reach for their thoughts... and feel them weigh the pull."))
	var/answer = browser_alert(target, "[caster] is trying to draw you into a trance. Your will is strong enough to refuse it.", "Hypnosis", list("Give in", "Resist", "Always give in to them"), HYPNOSIS_PROMPT_TIMEOUT)
	if(QDELETED(src) || QDELETED(caster) || QDELETED(target) || !target.mind)
		return FALSE
	if(answer != "Give in" && answer != "Always give in to them")
		to_chat(caster, span_warning("Their mind pushes back. They will not go under."))
		to_chat(target, span_hypnophrase("I hold on to my own thoughts, and the pull slides off me."))
		return FALSE
	if(answer == "Always give in to them" && caster.mind)
		target.mind.trust_hypnotist(caster.mind)
	return TRUE

/// Both sides hold still for [channel_time]; returns TRUE when it completes.
/datum/action/cooldown/spell/hypnosis/proc/run_channel(mob/living/carbon/human/caster, mob/living/carbon/human/target)
	caster.hypnosis_channeling = TRUE
	target.hypnosis_channeling = TRUE
	caster.hypnosis_channel_cancelled = FALSE
	target.hypnosis_channel_cancelled = FALSE
	to_chat(caster, span_hypnophrase(fill_text(channel_caster_text, caster, target)))
	to_chat(target, span_hypnophrase(fill_text(channel_target_text, caster, target)))
	var/datum/progressbar/caster_bar = new(caster, channel_time, target)
	var/datum/progressbar/target_bar = new(target, channel_time, caster)
	var/atom/caster_loc = caster.loc
	var/atom/target_loc = target.loc
	var/start = world.time
	. = TRUE
	while(world.time < start + channel_time)
		stoplag(1)
		if(QDELETED(src) || QDELETED(caster) || QDELETED(target) || caster.hypnosis_channel_cancelled || target.hypnosis_channel_cancelled)
			. = FALSE
			break
		if(caster.loc != caster_loc || target.loc != target_loc || get_block_reason(caster, target))
			. = FALSE
			break
		caster_bar.update(world.time - start)
		target_bar.update(world.time - start)
	caster_bar.end_progress()
	target_bar.end_progress()
	if(!QDELETED(caster))
		caster.hypnosis_channeling = FALSE
	if(!QDELETED(target))
		target.hypnosis_channeling = FALSE
