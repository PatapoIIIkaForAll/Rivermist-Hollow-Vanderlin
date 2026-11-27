// Fatal Drain: a consent-gated Tier-3 finish for victims already made Hollowed.

/mob/living/carbon/human
	/// Prevents stacked Fatal Drain prompts and remains set through the chosen channel.
	var/tmp/succubus_fatal_drain_prompt_pending = FALSE

/datum/status_effect/succubus_fatal_drain_scar
	id = "succubus_fatal_drain_scar"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = -1
	alert_type = null

/datum/status_effect/succubus_fatal_drain_scar/get_examine_text(mob/user, list/pronouns)
	return span_danger("SUBJECTPRONOUN bears an unmistakable soul-scar: cold, withered flesh webbed by faint infernal veins.")

/// Central validator used before the prompt and after every asynchronous boundary.
/datum/antagonist/succubus/proc/can_fatal_drain(mob/living/carbon/human/target, require_client = TRUE, ignore_pending = FALSE, silent = TRUE)
	var/mob/living/carbon/human/caster = owner?.current
	if(!istype(caster) || caster.stat != CONSCIOUS || !isturf(caster.loc))
		return FALSE
	if(get_succubus_contract_tier() < SUCCUBUS_FATAL_DRAIN_UNLOCK_TIER)
		if(!silent)
			to_chat(caster, span_warning("Asmodeus has not yet entrusted me with a soul's final draught."))
		return FALSE
	if(!istype(target) || !target.mind || target == caster)
		if(!silent)
			to_chat(caster, span_warning("There is no mortal lifespark there for me to drain."))
		return FALSE
	if(target.stat != CONSCIOUS || !isturf(target.loc))
		if(!silent)
			to_chat(caster, span_warning("Their lifespark is too unsteady to seize this way."))
		return FALSE
	if(!caster.Adjacent(target))
		if(!silent)
			to_chat(caster, span_warning("I must be beside them to seize their lifespark."))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/defeat_knockout))
		if(!silent)
			to_chat(caster, span_warning("Their lifespark is already tangled in defeat."))
		return FALSE
	var/datum/status_effect/debuff/succubus_depletion/depletion = target.has_status_effect(/datum/status_effect/debuff/succubus_depletion)
	if(!depletion || depletion.stage < SUCCUBUS_DEPLETION_HOLLOWED)
		if(!silent)
			to_chat(caster, span_notice("They are not yet Hollowed enough to surrender their lifespark."))
		return FALSE
	if(!target.has_erp_pref(/datum/erp_preference/boolean/fatal_drain_ok))
		if(!silent)
			to_chat(caster, span_notice("Something inviolate guards their lifespark. I may sip, never drain."))
		return FALSE
	if(!ignore_pending && target.succubus_fatal_drain_prompt_pending)
		if(!silent)
			to_chat(caster, span_warning("Their lifespark is already being contested."))
		return FALSE
	if(require_client && !target.client)
		if(!silent)
			to_chat(caster, span_warning("Their mind is vacant; no choice answers my hunger."))
		return FALSE
	if(is_succubus_consecrated(caster) || is_succubus_consecrated(target))
		if(!silent)
			to_chat(caster, span_userdanger("The refuge's ward closes around their lifespark before I can touch it!"))
		return FALSE
	return TRUE

/datum/antagonist/succubus/proc/offer_fatal_drain(mob/living/carbon/human/target)
	if(!can_fatal_drain(target, silent = FALSE))
		return FALSE
	target.succubus_fatal_drain_prompt_pending = TRUE
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob/living/carbon/human, prompt_succubus_fatal_drain), WEAKREF(src))
	to_chat(owner.current, span_love("I close my hunger around [target.real_name]'s lifespark and await their answer..."))
	return TRUE

/mob/living/carbon/human/proc/prompt_succubus_fatal_drain(datum/weakref/succubus_ref)
	var/datum/antagonist/succubus/succubus_antag = succubus_ref?.resolve()
	var/demon_name = succubus_antag?.owner?.current?.real_name || "the demon"
	var/choice = tgui_alert(
		src,
		"[demon_name] has closed their hunger around my Hollowed soul. If the drain completes, I may yield my lifespark and die immediately, bypassing defeat and rune rescue, or fight for life through my normal defeat and rescue settings.",
		"Fatal Drain",
		list("Fight for Life", "Yield the Lifespark"),
		SUCCUBUS_FATAL_DRAIN_PROMPT_TIMEOUT,
	)

	if(QDELETED(src))
		return FALSE
	var/valid_choice = choice in list("Fight for Life", "Yield the Lifespark")
	if(QDELETED(succubus_antag) || !valid_choice)
		succubus_fatal_drain_prompt_pending = FALSE
		if(choice)
			to_chat(src, span_notice("The infernal pressure slips away before it can take hold."))
		return FALSE
	if(!succubus_antag.can_fatal_drain(src, require_client = FALSE, ignore_pending = TRUE, silent = FALSE))
		succubus_fatal_drain_prompt_pending = FALSE
		to_chat(src, span_notice("The moment passes, and the grasp upon my lifespark loosens."))
		return FALSE

	var/completed = succubus_antag.resolve_fatal_drain_choice(src, choice == "Yield the Lifespark")
	if(!QDELETED(src))
		succubus_fatal_drain_prompt_pending = FALSE
	return completed

/datum/antagonist/succubus/proc/resolve_fatal_drain_choice(mob/living/carbon/human/target, yield_lifespark)
	if(!can_fatal_drain(target, require_client = FALSE, ignore_pending = TRUE, silent = FALSE))
		return FALSE
	var/mob/living/carbon/human/caster = owner.current
	caster.visible_message(
		span_boldwarning("Crimson strands coil from [target] toward [caster] as an infernal hunger takes hold!"),
		span_userdanger("I seize [target]'s Hollowed lifespark. I must hold them until it tears free!"),
	)
	to_chat(target, span_userdanger("My soul strains toward [caster] as the fatal drain begins!"))
	if(!do_after(caster, SUCCUBUS_FATAL_DRAIN_CHANNEL, target = target))
		to_chat(caster, span_warning("The lifespark wrenches free of my grasp."))
		to_chat(target, span_notice("The infernal pull breaks before it can finish me."))
		return FALSE
	if(!can_fatal_drain(target, require_client = FALSE, ignore_pending = TRUE, silent = FALSE))
		to_chat(target, span_notice("The infernal pull falters at the final instant."))
		return FALSE
	return complete_fatal_drain(target, yield_lifespark)

/datum/antagonist/succubus/proc/complete_fatal_drain(mob/living/carbon/human/target, yield_lifespark)
	if(!can_fatal_drain(target, require_client = FALSE, ignore_pending = TRUE, silent = TRUE))
		return FALSE
	var/mob/living/carbon/human/caster = owner.current
	var/outcome_committed = FALSE
	if(yield_lifespark)
		target.defeat_explicit_death()
		outcome_committed = target.stat == DEAD
	else
		outcome_committed = target.enter_defeat(DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_SEVERE, caster)
		if(!outcome_committed && target.get_effective_defeat_mode() == DEFEAT_MODE_NO_RETURN)
			target.death()
			outcome_committed = target.stat == DEAD
	if(!outcome_committed)
		return FALSE

	revert_form(forced = TRUE)
	if(yield_lifespark || target.stat == DEAD)
		target.visible_message(
			span_boldwarning("A final ember tears from [target]'s chest and vanishes between [caster]'s lips. [target] falls utterly still!"),
			span_userdanger("My last spark tears free. Everything goes cold."),
		)
	else
		target.visible_message(
			span_boldwarning("[target] crumples as [caster] tears away a ragged measure of their lifespark!"),
			span_userdanger("I wrench my soul back from the brink, but the struggle leaves me defeated."),
		)

	var/datum/status_effect/succubus_brand/brand = target.has_status_effect(/datum/status_effect/succubus_brand)
	if(!brand)
		brand = target.apply_status_effect(/datum/status_effect/succubus_brand)
	brand?.record_stage(SUCCUBUS_DEPLETION_HOLLOWED)
	brand?.reveal()
	target.apply_status_effect(/datum/status_effect/succubus_fatal_drain_scar)
	target.remove_status_effect(/datum/status_effect/debuff/succubus_depletion)

	var/essence_before = essence
	adjust_essence(SUCCUBUS_FATAL_DRAIN_REWARD)
	var/essence_gained = essence - essence_before
	if(essence_gained > 0)
		record_contract_progress(/datum/contract_goal/succubus/infernal_tithe, essence_gained)
	to_chat(caster, span_love("Their broken lifespark floods me with power. (+[essence_gained] essence, [essence]/[essence_cap])"))
	log_combat(caster, target, yield_lifespark ? "fatally drained the lifespark from" : "drained to severe defeat")
	return TRUE

// --- Fatal Drain spell ---------------------------------------------------------------------------

/datum/action/cooldown/spell/succubus_fatal_drain
	name = "Fatal Drain"
	desc = "Contest the lifespark of an adjacent Hollowed victim. Their explicit fatal-drain preference and immediate choice remain authoritative."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	self_cast_possible = FALSE
	cast_range = 1
	charge_required = FALSE
	cooldown_time = SUCCUBUS_FATAL_DRAIN_COOLDOWN

/datum/action/cooldown/spell/succubus_fatal_drain/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

/datum/action/cooldown/spell/succubus_fatal_drain/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || !succubus_antag.can_fatal_drain(cast_on, silent = FALSE))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/succubus_fatal_drain/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || !istype(cast_on))
		return
	succubus_antag.offer_fatal_drain(cast_on)
