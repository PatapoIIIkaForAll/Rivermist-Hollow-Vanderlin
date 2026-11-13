// Succubus abilities. Pointed spells use /datum/action/cooldown/spell; self-cast ones use the
// /undirected subtype. Essence is charged by hand against the antag datum (base spell_cost is
// left 0), and every lewd-lane ability gates on can_target_lewd() before any effect.

/// The single "may I affect this person with lust magic" pref gate — every lewd ability
/// funnels through it so the check can't drift between abilities.
/datum/antagonist/succubus/proc/can_target_lewd(mob/living/target)
	if(!ishuman(target))
		return FALSE
	if(is_succubus_consecrated(target) || is_succubus_consecrated(owner?.current))
		return FALSE
	return target.has_erp_pref(/datum/erp_preference/boolean/lust_magic_targetable)

// --- Detect Desire: pointed, no cost, short cooldown --------------------------------------------

/datum/action/cooldown/spell/succubus_detect_desire
	name = "Detect Desire"
	desc = "Gaze into a soul to learn what desires and wards lie within."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	self_cast_possible = FALSE
	cast_range = 5
	charge_required = FALSE
	cooldown_time = 6 SECONDS

/datum/action/cooldown/spell/succubus_detect_desire/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

// Gate in before_cast, not cast(): a SPELL_CANCEL_CAST here skips spell_feedback() (casting
// sound/invocation), so a warded target gets no effect, message, or sound at all.
/datum/action/cooldown/spell/succubus_detect_desire/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/carbon/human/target = cast_on
	if(!istype(target))
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(succubus_antag && (is_succubus_consecrated(target) || is_succubus_consecrated(owner)))
		to_chat(owner, span_warning("Consecrated ground turns my gaze aside in a flare of white fire."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag && !succubus_antag.can_target_lewd(target))
		to_chat(owner, span_notice("I gaze into [target.real_name]... and meet a wall of white flame. This soul is warded against me."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/succubus_detect_desire/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on))
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return

	// can_target_lewd() already passed in before_cast
	var/list/lines = list()
	lines += "This soul lies open to my arts."
	lines += cast_on.has_erp_pref(/datum/erp_preference/boolean/enthrallable) ? "Their will could be bound to mine, in time." : "Their will is anchored; thralldom is beyond reach."
	lines += cast_on.has_erp_pref(/datum/erp_preference/boolean/fatal_drain_ok) ? "I could drink this one to the very dregs..." : "Something guards their lifespark; I may sip, never drain."
	if(cast_on.IsWedded())
		lines += "A mortal vow binds this soul. Corrupting it would be especially sweet."
	if(HAS_TRAIT(cast_on, TRAIT_VIRGIN))
		lines += "This soul is untouched. Its first surrender would be potent."
	to_chat(owner, span_love(lines.Join("<br>")))

// --- Lust: pointed, essence cost, hard pref gate -------------------------------------------------

/datum/action/cooldown/spell/succubus_lust
	name = "Lust"
	desc = "Kindle unbidden desire in a target's heart."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	self_cast_possible = FALSE
	cast_range = 5
	charge_required = FALSE
	cooldown_time = 4 SECONDS

/datum/action/cooldown/spell/succubus_lust/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

// Gated in before_cast like Detect Desire. Pref check before the essence check, so the caster
// always gets the warded-soul line regardless of essence.
/datum/action/cooldown/spell/succubus_lust/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/carbon/human/target = cast_on
	if(!istype(target))
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return . | SPELL_CANCEL_CAST
	if(is_succubus_consecrated(target) || is_succubus_consecrated(owner))
		to_chat(owner, span_warning("Consecrated ground scatters my magic before it can take hold."))
		return . | SPELL_CANCEL_CAST
	if(!succubus_antag.can_target_lewd(target))
		to_chat(owner, span_notice("I reach for [target.real_name]'s heart... and meet a wall of white flame. This soul is warded against me."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.essence < SUCCUBUS_COST_LUST)
		to_chat(owner, span_warning("I don't have the essence to kindle their desire."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/succubus_lust/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on))
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return

	// gates already passed in before_cast
	succubus_antag.adjust_essence(-SUCCUBUS_COST_LUST)
	// COMSIG_SEX_ADJUST_AROUSAL: the arousal component handles arousal_frozen internally
	SEND_SIGNAL(cast_on, COMSIG_SEX_ADJUST_AROUSAL, 15)
	to_chat(cast_on, span_love("A wave of unbidden heat rolls through me..."))
	to_chat(owner, span_love("Desire kindles within [cast_on.real_name]."))

// --- Allure: toggled aura, no cost, slow pulse ----------------------------------------------------
// cast() toggles a standing status effect; the effect's own tick_interval drives the pulse.

/datum/action/cooldown/spell/undirected/succubus_allure
	name = "Allure"
	desc = "Radiate a subtle, toggled aura of desire."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = 2 SECONDS
	var/aura_active = FALSE

/datum/action/cooldown/spell/undirected/succubus_allure/cast(mob/living/cast_on)
	. = ..()
	if(aura_active)
		deactivate_aura()
	else
		activate_aura()

/datum/action/cooldown/spell/undirected/succubus_allure/proc/activate_aura()
	aura_active = TRUE
	var/mob/living/current_owner = owner
	current_owner?.apply_status_effect(/datum/status_effect/succubus_allure_aura)
	to_chat(owner, span_love("I let my allure show..."))

/datum/action/cooldown/spell/undirected/succubus_allure/proc/deactivate_aura()
	aura_active = FALSE
	var/mob/living/current_owner = owner
	current_owner?.remove_status_effect(/datum/status_effect/succubus_allure_aura)
	to_chat(owner, span_notice("I rein my allure back in."))

/datum/action/cooldown/spell/undirected/succubus_allure/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return aura_active

/datum/action/cooldown/spell/undirected/succubus_allure/Remove(mob/living/remove_from)
	if(aura_active && remove_from)
		remove_from.remove_status_effect(/datum/status_effect/succubus_allure_aura)
	aura_active = FALSE
	return ..()

/datum/status_effect/succubus_allure_aura
	id = "succubus_allure_aura"
	duration = -1
	tick_interval = 4 SECONDS
	alert_type = null

/// Nearby humans who pass the pref gate get a small arousal tick; opted-out ones are skipped.
/datum/status_effect/succubus_allure_aura/tick()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return
	for(var/mob/living/carbon/human/target in range(SUCCUBUS_ALLURE_RANGE, owner))
		if(target == owner)
			continue
		if(!succubus_antag.can_target_lewd(target))
			continue
		SEND_SIGNAL(target, COMSIG_SEX_ADJUST_AROUSAL, 2)

// --- Aphrodisiac Kiss: self-buff, essence cost, delivered on the next kiss -----------------------
// Delivered via a COMSIG_SEX_RECEIVE_ACTION listener filtered to /datum/sex_action/kissing.

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss
	name = "Aphrodisiac Kiss"
	desc = "Lace your next kiss with a lingering aphrodisiac venom."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = 10 SECONDS
	/// Timer for the venom expiring unused
	var/venom_timer

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(venom_timer)
		to_chat(owner, span_warning("My lips are already laced with venom."))
		return . | SPELL_CANCEL_CAST
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || succubus_antag.essence < SUCCUBUS_COST_APHRODISIAC_KISS)
		to_chat(owner, span_warning("I don't have the essence to lace my lips with venom."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/cast(mob/living/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return

	succubus_antag.adjust_essence(-SUCCUBUS_COST_APHRODISIAC_KISS)
	RegisterSignal(owner, COMSIG_SEX_RECEIVE_ACTION, PROC_REF(on_kiss_received), override = TRUE)
	if(venom_timer)
		deltimer(venom_timer)
	venom_timer = addtimer(CALLBACK(src, PROC_REF(expire_venom)), 2 MINUTES, TIMER_STOPPABLE)
	to_chat(owner, span_love("My lips grow sweet with venom; the next I kiss will taste it."))

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/proc/on_kiss_received(datum/source, datum/sex_action/s_action, mob/living/action_receiver, mob/living/action_partner, arousal_amt, pain_amt, orgasm_prog_amt, giving, applied_force, applied_speed, applied_resist, mob/living/action_performer)
	SIGNAL_HANDLER
	if(!istype(s_action, /datum/sex_action/kissing))
		return
	consume_venom(action_partner)

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/proc/consume_venom(mob/living/partner)
	if(venom_timer)
		deltimer(venom_timer)
		venom_timer = null
	if(owner)
		UnregisterSignal(owner, COMSIG_SEX_RECEIVE_ACTION)

	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || !succubus_antag.can_target_lewd(partner))
		to_chat(owner, span_warning("Their ward sours my venom."))
		return

	var/mob/living/carbon/human/human_partner = partner
	human_partner.reagents?.add_reagent(/datum/reagent/consumable/aphrodisiac, 5)
	to_chat(owner, span_love("My kiss leaves [human_partner] sweetly poisoned."))

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/proc/expire_venom()
	venom_timer = null
	if(!owner)
		return
	UnregisterSignal(owner, COMSIG_SEX_RECEIVE_ACTION)
	to_chat(owner, span_notice("The venom on my lips fades, unused."))

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/Grant(mob/grant_to)
	. = ..()
	if(venom_timer && owner)
		RegisterSignal(owner, COMSIG_SEX_RECEIVE_ACTION, PROC_REF(on_kiss_received), override = TRUE)
	return .

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/Remove(mob/living/remove_from)
	if(remove_from)
		UnregisterSignal(remove_from, COMSIG_SEX_RECEIVE_ACTION)
	return ..()

/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss/Destroy()
	if(venom_timer)
		deltimer(venom_timer)
		venom_timer = null
	return ..()

// --- Whisper: telepathic flirtation at range -----------------------------------------------------

/datum/action/cooldown/spell/succubus_whisper
	name = "Whisper"
	desc = "Slip a few words directly into a target's mind, sweet and unbidden."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	self_cast_possible = FALSE
	cast_range = 7
	charge_required = FALSE
	cooldown_time = 6 SECONDS
	/// Text captured in before_cast so a cancelled prompt refunds the cooldown; consumed in cast().
	var/pending_whisper

/datum/action/cooldown/spell/succubus_whisper/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

/datum/action/cooldown/spell/succubus_whisper/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/carbon/human/target = cast_on
	if(!istype(target))
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return . | SPELL_CANCEL_CAST
	if(!succubus_antag.can_target_lewd(target))
		to_chat(owner, span_notice("Their mind is sealed against my voice."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.essence < SUCCUBUS_COST_WHISPER)
		to_chat(owner, span_warning("I lack the essence to reach their mind."))
		return . | SPELL_CANCEL_CAST
	// Prompt here, not in cast(): only a before_cast cancel refunds the cooldown. Essence is
	// still spent in cast(), on words actually sent.
	var/text = tgui_input_text(owner, "What shall I whisper into their mind?", "Whisper", max_length = 200)
	if(!text)
		return . | SPELL_CANCEL_CAST
	// Re-validate after the input gap
	if(QDELETED(target) || succubus_antag.essence < SUCCUBUS_COST_WHISPER)
		return . | SPELL_CANCEL_CAST
	pending_whisper = text

/datum/action/cooldown/spell/succubus_whisper/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/text = pending_whisper
	pending_whisper = null
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || !istype(cast_on) || !text)
		return
	if(succubus_antag.essence < SUCCUBUS_COST_WHISPER)
		return
	succubus_antag.adjust_essence(-SUCCUBUS_COST_WHISPER)
	to_chat(cast_on, span_love("A sultry voice caresses my mind: \"[text]\""))
	to_chat(owner, span_love("I pour the words into [cast_on.real_name]'s mind: \"[text]\""))
	log_game("SUCCUBUS WHISPER: [key_name(owner)] to [key_name(cast_on)]: [text]")

// --- Charm: a warm disposition nudge -------------------------------------------------------------

/datum/stress_event/succubus_charm
	stress_change = -6
	desc = span_green("A warm fondness settles over me like perfume...")
	timer = 10 MINUTES

/datum/stress_event/succubus_charm/on_remove(mob/living/user)
	. = ..()
	to_chat(user, span_notice("The glamour finally slips away. I remember how this made me feel, but no clear detail remains of what happened to me - or who did it."))

/datum/action/cooldown/spell/succubus_charm
	name = "Charm"
	desc = "Wrap a target's heart in warmth toward you. A nudge of disposition, nothing more - the rest is craft."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	self_cast_possible = FALSE
	cast_range = 3
	charge_required = FALSE
	cooldown_time = SUCCUBUS_CHARM_COOLDOWN

/datum/action/cooldown/spell/succubus_charm/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

/datum/action/cooldown/spell/succubus_charm/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/carbon/human/target = cast_on
	if(!istype(target))
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return . | SPELL_CANCEL_CAST
	if(!succubus_antag.can_target_lewd(target))
		to_chat(owner, span_notice("Their heart is barred against me."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.essence < SUCCUBUS_COST_CHARM)
		to_chat(owner, span_warning("I lack the essence to warm their heart."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/succubus_charm/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || !istype(cast_on))
		return
	succubus_antag.adjust_essence(-SUCCUBUS_COST_CHARM)
	cast_on.add_stress(/datum/stress_event/succubus_charm)
	var/mob/living/caster = owner
	to_chat(cast_on, span_love("A warm fondness for [caster.real_name] settles over me like perfume. My thoughts grow pleasantly hazy, and the details of this moment already feel difficult to hold."))
	to_chat(owner, span_love("[cast_on.real_name]'s heart softens toward me."))

// --- Beguiling Doubles: tier-2 visual misdirection ----------------------------------------------

/obj/effect/temp_visual/decoy/fading/succubus_double
	anchored = FALSE
	duration = SUCCUBUS_BEGUILING_DOUBLE_DURATION
	var/steps_remaining = SUCCUBUS_BEGUILING_DOUBLE_STEPS
	var/movement_timer

/obj/effect/temp_visual/decoy/fading/succubus_double/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	movement_timer = addtimer(CALLBACK(src, PROC_REF(take_step)), SUCCUBUS_BEGUILING_DOUBLE_STEP_DELAY, TIMER_LOOP | TIMER_STOPPABLE)

/obj/effect/temp_visual/decoy/fading/succubus_double/Destroy()
	if(movement_timer)
		deltimer(movement_timer)
		movement_timer = null
	return ..()

/obj/effect/temp_visual/decoy/fading/succubus_double/proc/take_step()
	steps_remaining--
	if(!step(src, dir))
		for(var/alternate_direction in shuffle(list(turn(dir, 90), turn(dir, -90))))
			if(step(src, alternate_direction))
				break

	if(steps_remaining <= 0)
		deltimer(movement_timer)
		movement_timer = null

/datum/action/cooldown/spell/undirected/succubus_beguiling_doubles
	name = "Beguiling Doubles"
	desc = "Fracture your current appearance into a handful of short-lived, fading doubles."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = SUCCUBUS_BEGUILING_DOUBLES_COOLDOWN

/datum/action/cooldown/spell/undirected/succubus_beguiling_doubles/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || succubus_antag.get_succubus_contract_tier() < SUCCUBUS_BEGUILING_DOUBLES_UNLOCK_TIER)
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.essence < SUCCUBUS_COST_BEGUILING_DOUBLES)
		to_chat(owner, span_warning("I lack the essence to split my image."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/undirected/succubus_beguiling_doubles/cast(mob/living/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || succubus_antag.get_succubus_contract_tier() < SUCCUBUS_BEGUILING_DOUBLES_UNLOCK_TIER)
		return
	if(succubus_antag.essence < SUCCUBUS_COST_BEGUILING_DOUBLES)
		return

	var/turf/origin = get_turf(cast_on)
	if(!origin)
		return

	succubus_antag.adjust_essence(-SUCCUBUS_COST_BEGUILING_DOUBLES)
	var/list/turf/decoy_turfs = list(origin)
	for(var/turf/adjacent_turf as anything in shuffle(get_adjacent_open_turfs(origin)))
		if(adjacent_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		decoy_turfs += adjacent_turf
		if(length(decoy_turfs) >= SUCCUBUS_BEGUILING_DOUBLE_COUNT)
			break

	for(var/turf/decoy_turf as anything in decoy_turfs)
		var/obj/effect/temp_visual/decoy/fading/succubus_double/double = new(decoy_turf, cast_on)
		var/outward_direction = get_dir(origin, decoy_turf)
		double.setDir(outward_direction || cast_on.dir)

	to_chat(owner, span_love("My image fractures into a beguiling host."))

/datum/antagonist/succubus/proc/grant_succubus_abilities()
	var/mob/living/current_mob = owner?.current
	if(!current_mob)
		return
	current_mob.add_spell(/datum/action/cooldown/spell/succubus_detect_desire, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/succubus_lust, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/undirected/succubus_allure, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/succubus_whisper, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/succubus_charm, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/succubus_enthrall, source = owner)
	current_mob.add_spell(/datum/action/cooldown/spell/hypnosis/succubus, source = owner)
	refresh_succubus_tier_abilities()

/datum/antagonist/succubus/proc/refresh_succubus_tier_abilities()
	var/mob/living/current_mob = owner?.current
	if(!current_mob)
		return
	var/current_tier = get_succubus_contract_tier()
	if(current_tier >= SUCCUBUS_BEGUILING_DOUBLES_UNLOCK_TIER)
		current_mob.add_spell(/datum/action/cooldown/spell/undirected/succubus_beguiling_doubles, source = owner)
	else
		current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_beguiling_doubles)
	if(current_tier >= SUCCUBUS_RETINUE_UNLOCK_TIER)
		current_mob.add_spell(/datum/action/cooldown/spell/undirected/succubus_summon_imp, source = owner)
		current_mob.add_spell(/datum/action/cooldown/spell/undirected/succubus_summon_lusthound, source = owner)
		current_mob.add_spell(/datum/action/cooldown/spell/succubus_infernal_snare, source = owner)
	else
		current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_summon_imp)
		current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_summon_lusthound)
		current_mob.remove_spell(/datum/action/cooldown/spell/succubus_infernal_snare)
	if(current_tier >= SUCCUBUS_FATAL_DRAIN_UNLOCK_TIER)
		current_mob.add_spell(/datum/action/cooldown/spell/succubus_fatal_drain, source = owner)
	else
		current_mob.remove_spell(/datum/action/cooldown/spell/succubus_fatal_drain)
	refresh_succubus_form_actions()

/datum/antagonist/succubus/proc/remove_succubus_abilities()
	var/mob/living/current_mob = owner?.current
	if(!current_mob)
		return
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_detect_desire)
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_lust)
	current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_allure)
	current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_aphrodisiac_kiss)
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_whisper)
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_charm)
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_enthrall)
	current_mob.remove_spell(/datum/action/cooldown/spell/hypnosis/succubus)
	current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_beguiling_doubles)
	current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_summon_imp)
	current_mob.remove_spell(/datum/action/cooldown/spell/undirected/succubus_summon_lusthound)
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_infernal_snare)
	current_mob.remove_spell(/datum/action/cooldown/spell/succubus_fatal_drain)
	remove_true_form_actions(current_mob)
	// Allure's aura is a separate datum that outlives the spell if stripped mid-pulse
	if(current_mob.has_status_effect(/datum/status_effect/succubus_allure_aura))
		current_mob.remove_status_effect(/datum/status_effect/succubus_allure_aura)
