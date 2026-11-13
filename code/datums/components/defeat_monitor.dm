/datum/component/defeat_monitor
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	/// First tick at or above the sustained pain defeat stage.
	var/shock_defeat_started_at = 0
	/// Last warning tick while pain shock is approaching defeat.
	var/shock_warning_last_at = 0
	/// Last warning tick while damage/blood loss is approaching defeat.
	var/damage_warning_last_at = 0
	/// Pooled damage seen at the last near-defeat check; only fresh harm repeats the warning.
	var/damage_warning_seen_total = 0
	/// Valid hostile climax events accumulated toward horny defeat.
	var/horny_defeat_climax_count = 0
	/// Climaxes needed for horny defeat this encounter. Resolved and cached on the first valid climax.
	var/horny_defeat_climax_threshold = 0
	/// Player-facing explanation of the cached threshold's source.
	var/horny_defeat_climax_threshold_source
	/// Highest gradual-warning stage already shown this encounter, so each beat fires only once.
	var/horny_defeat_warned_stage = 0
	/// world.time of the last climax that counted toward horny defeat
	var/horny_defeat_last_climax_at = 0

/datum/component/defeat_monitor/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/defeat_monitor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))
	RegisterSignal(parent, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))
	RegisterSignal(parent, COMSIG_LIVING_DEFEAT_RESCUED, PROC_REF(on_defeat_rescued))
	RegisterSignal(parent, COMSIG_LIVING_DEFEATED, PROC_REF(on_defeated))

/datum/component/defeat_monitor/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_HEALTH_UPDATE, COMSIG_SEX_CLIMAX, COMSIG_LIVING_DEFEAT_RESCUED, COMSIG_LIVING_DEFEATED))

/datum/component/defeat_monitor/proc/is_defeat_eligible()
	var/mob/living/living_parent = parent
	return living_parent?.defeat_system_is_eligible()

/datum/component/defeat_monitor/proc/check_defeat_triggers()
	var/mob/living/carbon/carbon_parent = parent
	if(!istype(carbon_parent))
		return FALSE
	if(!is_defeat_eligible())
		reset_shock_defeat_window()
		return FALSE
	if(carbon_parent.has_status_effect(/datum/status_effect/defeat_knockout))
		carbon_parent.defeat_stabilize_live_damage(FALSE)
		if(carbon_parent.defeat_is_immediate_hazard())
			carbon_parent.defeat_rescue_from_hazard()
		return FALSE

	if(carbon_parent.defeat_is_immediate_rune_hazard())
		return carbon_parent.enter_defeat(DEFEAT_REASON_HAZARD, DEFEAT_SEVERITY_SEVERE)
	// Lethal health, blood, and brain states take precedence over an overlapping ordinary damage
	// threshold so the snapshot and collapse feedback preserve why this update would have killed them.
	if(carbon_parent.defeat_is_near_death())
		return carbon_parent.enter_defeat(DEFEAT_REASON_DEATH, DEFEAT_SEVERITY_SEVERE)

	var/selected_threshold = carbon_parent.get_effective_defeat_threshold()
	// Total damage across the beatdown pools (not the single biggest) - predictable: you fall at roughly
	// maxHealth - threshold, regardless of how the damage is split across brute/burn/tox/clone. Oxygen is
	// deliberately excluded - a fall from a higher z-level spikes oxy hard and would otherwise KO you
	// almost instantly. It gets its own near-lethal bar below instead.
	// Burn is weighted down: it lands in bigger single lumps than brute, so raw parity fell far too fast.
	var/total_damage = carbon_parent.get_defeat_damage_pool()
	maybe_warn_damage_defeat(carbon_parent, total_damage, selected_threshold)
	if(total_damage >= selected_threshold)
		return carbon_parent.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL)

	// Oxygen on its own only downs you at the kill limit, so a survivable fall no longer taps you out.
	if(carbon_parent.getOxyLoss() >= DEFEAT_OXY_THRESHOLD)
		return carbon_parent.enter_defeat(DEFEAT_REASON_DEATH, DEFEAT_SEVERITY_SEVERE)

	// Shock-driven Defeat is disabled; ordinary pain effects remain active.
	/*
	var/current_shock_stage = carbon_parent.getShockStage()
	maybe_warn_shock_defeat(current_shock_stage)
	if(current_shock_stage >= DEFEAT_SHOCK_HARD_STAGE)
		return carbon_parent.enter_defeat(DEFEAT_REASON_PAIN, DEFEAT_SEVERITY_SEVERE)

	if(current_shock_stage < DEFEAT_SHOCK_DEFEAT_STAGE)
		reset_shock_defeat_window()
		return FALSE

	if(!shock_defeat_started_at)
		shock_defeat_started_at = world.time
		return FALSE

	if(world.time - shock_defeat_started_at >= DEFEAT_SHOCK_SUSTAIN_DURATION)
		return carbon_parent.enter_defeat(DEFEAT_REASON_PAIN, DEFEAT_SEVERITY_NORMAL)
	*/

	return FALSE

/datum/component/defeat_monitor/proc/reset_shock_defeat_window()
	shock_defeat_started_at = 0

/datum/component/defeat_monitor/proc/maybe_warn_shock_defeat(current_shock_stage)
	var/mob/living/carbon/carbon_parent = parent
	if(!istype(carbon_parent))
		return FALSE
	if(current_shock_stage < DEFEAT_SHOCK_WARNING_STAGE)
		shock_warning_last_at = 0
		return FALSE
	if(shock_warning_last_at && world.time - shock_warning_last_at < DEFEAT_SHOCK_WARNING_COOLDOWN)
		return FALSE
	shock_warning_last_at = world.time
	to_chat(carbon_parent, span_warning("Pain is pulling you toward defeat. You need help soon."))
	carbon_parent.flash_fullscreen("redflash1")
	return TRUE

/// Warn the player as their wounds (or blood loss) approach the point of defeat, throttled.
/datum/component/defeat_monitor/proc/maybe_warn_damage_defeat(mob/living/carbon/carbon_parent, total_damage, threshold)
	var/nearly_beaten = (threshold > 0 && total_damage >= threshold * DEFEAT_DAMAGE_WARNING_FRACTION && total_damage < threshold)
	var/bleeding_out = (carbon_parent.blood_volume <= BLOOD_VOLUME_BAD && carbon_parent.blood_volume > BLOOD_VOLUME_SURVIVE && !HAS_TRAIT(carbon_parent, TRAIT_BLOODLOSS_IMMUNE) && !carbon_parent.is_bloodless())
	if(!nearly_beaten && !bleeding_out)
		damage_warning_last_at = 0
		damage_warning_seen_total = 0
		return FALSE
	// Unchanged damage does not repeat the warning, so bodies that cannot heal are not nagged forever.
	var/fresh_harm = total_damage > damage_warning_seen_total
	damage_warning_seen_total = total_damage
	if(!bleeding_out && !fresh_harm)
		return FALSE
	if(damage_warning_last_at && world.time - damage_warning_last_at < DEFEAT_SHOCK_WARNING_COOLDOWN)
		return FALSE
	damage_warning_last_at = world.time
	// Kept out of the span macro: span_warning() expands to string concatenation, and DM's `+` binds
	// tighter than `?:`, so an inline ternary becomes ("<span...>" + condition) - a runtime when it's 0.
	var/warning_text = bleeding_out ? "You're bleeding badly - stay on your feet or you'll fall." : "You're battered to the brink - one more blow and you'll go down."
	to_chat(carbon_parent, span_warning(warning_text))
	carbon_parent.flash_fullscreen("redflash1")
	return TRUE

/datum/component/defeat_monitor/proc/on_health_update(datum/source, ...)
	SIGNAL_HANDLER
	return check_defeat_triggers()

// Kept as a direct-call compatibility shim for the narrow rune-hazard regression test. It is not
// registered as a normal death signal: health recomputation is the authoritative defeat path.
/datum/component/defeat_monitor/proc/on_death(datum/source, ...)
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_parent = parent
	if(!istype(carbon_parent))
		return FALSE
	if(!is_defeat_eligible())
		return FALSE
	if(carbon_parent.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(!carbon_parent.defeat_is_immediate_rune_hazard())
		return FALSE
	return carbon_parent.enter_defeat(DEFEAT_REASON_HAZARD, DEFEAT_SEVERITY_SEVERE)

/datum/component/defeat_monitor/proc/on_climax(datum/source, datum/sex_action/action, mob/living/action_receiver, mob/living/action_partner, mob/living/action_performer)
	SIGNAL_HANDLER
	if(try_holy_communion_rescue(action_receiver, action_partner, action_performer))
		return
	return check_horny_defeat_climax(source, action_receiver, action_partner, action_performer)

/datum/component/defeat_monitor/proc/on_defeat_rescued(datum/source, ...)
	SIGNAL_HANDLER
	reset_shock_defeat_window()
	shock_warning_last_at = 0
	damage_warning_last_at = 0
	damage_warning_seen_total = 0
	reset_horny_defeat_encounter()

/datum/component/defeat_monitor/proc/on_defeated(datum/source, ...)
	SIGNAL_HANDLER
	reset_shock_defeat_window()

/// A holy character (TRAIT_HOLY) bringing a downed victim to climax frees them - the design's
/// "ERP with the saints" rescue (section 3.1). A holy one who is actively harming the victim
/// (aggressive grab / recent attacker) is blocked by defeat_can_be_rescued_by, so only a tender act frees.
/datum/component/defeat_monitor/proc/try_holy_communion_rescue(mob/living/action_receiver, mob/living/action_partner, mob/living/action_performer)
	var/mob/living/carbon/victim = parent
	if(!istype(victim))
		return FALSE
	if(action_receiver != victim)
		return FALSE
	if(!victim.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	// action_performer can be a structure or item on the generic path, so only a mob qualifies here.
	var/mob/living/holy_one = isliving(action_performer) ? action_performer : action_partner
	if(!isliving(holy_one) || holy_one == victim)
		return FALSE
	if(!HAS_TRAIT(holy_one, TRAIT_HOLY))
		return FALSE
	return victim.defeat_try_prepared_recovery(holy_one, "holy communion")

/datum/component/defeat_monitor/proc/check_horny_defeat_climax(datum/source, mob/living/action_receiver, mob/living/action_partner, mob/living/action_performer)
	var/mob/living/living_parent = parent
	if(!istype(living_parent))
		return FALSE
	if(!living_parent.horny_defeat_is_eligible())
		return FALSE
	// A lull long enough means the encounter is over: stale climaxes from earlier dalliances
	// must never stack with a fresh encounter hours later.
	if(horny_defeat_last_climax_at && world.time - horny_defeat_last_climax_at > DEFEAT_HORNY_ENCOUNTER_TIMEOUT)
		reset_horny_defeat_encounter()
	if(living_parent.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(living_parent.has_status_effect(/datum/status_effect/mob_horny_knockout))
		return FALSE
	if(source != living_parent)
		return FALSE
	if(action_receiver != living_parent)
		return FALSE
	// Another mob has to be the one driving the climax - that is the whole anti-self-farm / anti-magic
	// guard (a solo or self-cast climax has no external instigator). We deliberately do NOT require a
	// maintained aggressive grab/pull anymore: horny mobs rarely hold their prey the whole encounter,
	// and a second attacker performing while the first one pulls broke the old `pulledby` check outright.
	// action_performer can be a structure or item on the generic path; defeat needs a living instigator.
	var/mob/living/instigator = isliving(action_performer) ? action_performer : action_partner
	if(!isliving(instigator) || instigator == living_parent)
		return FALSE
	// A player instigator only forces a horny defeat while in combat mode - a consensual encounter
	// (cmode off) never pushes the loss. NPC / AI mobs have no such switch, so they always count.
	if(!horny_defeat_instigator_counts(!!instigator.client, instigator.cmode))
		return FALSE

	// Player-owned bodies retain the player formula and full defeat path while temporarily disconnected.
	// Routed on what the mob path will actually accept, not on who owns the body: enter_mob_horny_defeat
	// refuses anything that is not an enabled clientless mob, so picking it for an AI-opted-in carbon
	// left that victim with no knockout from either path.
	var/mob_ko_path = living_parent.mob_horny_defeat_enabled && !living_parent.client
	if(horny_defeat_climax_threshold <= 0)
		var/list/resolved_threshold = living_parent.resolve_horny_defeat_threshold()
		horny_defeat_climax_threshold = resolved_threshold[DEFEAT_HORNY_THRESHOLD_VALUE]
		horny_defeat_climax_threshold_source = resolved_threshold[DEFEAT_HORNY_THRESHOLD_SOURCE]
		// Lust-fed beings (succubi) are nearly bottomless: heroic to tire out, not immune.
		if(HAS_TRAIT(living_parent, TRAIT_LUSTFUL_STAMINA))
			horny_defeat_climax_threshold *= SUCCUBUS_HORNY_KO_MULT
			horny_defeat_climax_threshold_source += " Lust-fed stamina multiplies this threshold by [SUCCUBUS_HORNY_KO_MULT]."
	else if(!horny_defeat_climax_threshold_source)
		horny_defeat_climax_threshold_source = "Threshold source: explicitly cached for this encounter."
	horny_defeat_climax_count = min(horny_defeat_climax_count + 1, horny_defeat_climax_threshold)
	horny_defeat_last_climax_at = world.time
	show_horny_defeat_progress(living_parent)
	if(horny_defeat_climax_count < horny_defeat_climax_threshold)
		maybe_warn_horny_defeat(living_parent)
		return FALSE

	if(mob_ko_path)
		return living_parent.enter_mob_horny_defeat(instigator)
	return living_parent.enter_defeat(DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_NORMAL, instigator)

/// Ends the current horny-defeat encounter. Recovery, timeout, and explicit callers own this reset.
/datum/component/defeat_monitor/proc/reset_horny_defeat_encounter()
	horny_defeat_climax_count = 0
	horny_defeat_climax_threshold = 0
	horny_defeat_climax_threshold_source = null
	horny_defeat_warned_stage = 0
	horny_defeat_last_climax_at = 0

/// Gives the victim exact private progress without leaking it to observers.
/datum/component/defeat_monitor/proc/show_horny_defeat_progress(mob/living/victim)
	to_chat(victim, span_notice(horny_defeat_progress_text(horny_defeat_climax_count, horny_defeat_climax_threshold, horny_defeat_climax_threshold_source)))

/// Emits the gradual "you are nearing a horny defeat" warning, but only the first time each escalating
/// stage is reached this encounter (climaxes are discrete, so this yields three rising beats, not spam).
/datum/component/defeat_monitor/proc/maybe_warn_horny_defeat(mob/living/victim)
	var/stage = horny_defeat_warning_stage(horny_defeat_climax_count, horny_defeat_climax_threshold)
	if(stage <= horny_defeat_warned_stage)
		return
	horny_defeat_warned_stage = stage
	switch(stage)
		if(1)
			to_chat(victim, span_warning("A pleasant heat clouds your thoughts - harder to shake off each time."))
		if(2)
			to_chat(victim, span_warning("A pleasured weakness spreads through your limbs - you can feel yourself starting to slip."))
			victim.flash_fullscreen("redflash1")
		if(3)
			to_chat(victim, span_userdanger("Your body is at its limit - one more peak and you'll give out completely!"))
			victim.flash_fullscreen("redflash2")

/// Whether a horny-climax instigator pushes the victim toward defeat. Player-controlled instigators
/// only count while in combat mode (consensual play, cmode off, never forces a loss); NPC / AI mobs
/// always count. Pure so the cmode/player matrix is unit-testable without a live client.
/proc/horny_defeat_instigator_counts(player_controlled, combat_mode)
	return !player_controlled || combat_mode

/// Pure mapping of climax-count vs the threshold to a warning stage (0 = none .. 3 = imminent).
/// Kept threshold-relative so the warning intensifies as collapse nears, but always opens at the
/// DEFEAT_HORNY_WARNING_START-th climax even for a low threshold.
/proc/horny_defeat_warning_stage(count, threshold)
	if(threshold <= 0 || count < DEFEAT_HORNY_WARNING_START)
		return 0
	if(count >= threshold - 1)
		return 3
	if(count >= threshold * DEFEAT_HORNY_WARNING_BUILD_FRACTION)
		return 2
	return 1

/// Pure threshold formula shared by production and focused tests. Explicit creature profiles win.
/proc/horny_defeat_threshold_for_stats(explicit_override, player_owned, constitution, endurance)
	if(explicit_override > 0)
		return clamp(round(explicit_override), DEFEAT_HORNY_MOB_THRESHOLD_MIN, DEFEAT_HORNY_MOB_THRESHOLD_MAX)
	if(player_owned)
		return clamp(round((constitution + endurance) / DEFEAT_HORNY_PLAYER_STAT_DIVISOR), DEFEAT_HORNY_PLAYER_THRESHOLD_MIN, DEFEAT_HORNY_PLAYER_THRESHOLD_MAX)
	return clamp(round((constitution + endurance) / 10), DEFEAT_HORNY_MOB_THRESHOLD_MIN, DEFEAT_HORNY_MOB_THRESHOLD_MAX)

/// Player-owned includes disconnected bodies whose mind is still attached.
/mob/living/proc/horny_defeat_uses_player_stats()
	return !!(client || mind)

/// Resolves the first valid climax's threshold and a stable explanation for exact personal progress.
/mob/living/proc/resolve_horny_defeat_threshold()
	if(horny_defeat_threshold_override > 0)
		var/override_value = horny_defeat_threshold_for_stats(horny_defeat_threshold_override, FALSE, 0, 0)
		return list(
			DEFEAT_HORNY_THRESHOLD_VALUE = override_value,
			DEFEAT_HORNY_THRESHOLD_SOURCE = "Threshold source: explicit creature profile ([override_value]).",
		)
	if(horny_defeat_uses_player_stats())
		var/player_constitution = GET_MOB_ATTRIBUTE_VALUE(src, STAT_CONSTITUTION)
		var/player_endurance = GET_MOB_ATTRIBUTE_VALUE(src, STAT_ENDURANCE)
		return list(
			DEFEAT_HORNY_THRESHOLD_VALUE = horny_defeat_threshold_for_stats(0, TRUE, player_constitution, player_endurance),
			DEFEAT_HORNY_THRESHOLD_SOURCE = "Threshold source: encounter-start stats (CON [player_constitution], END [player_endurance]).",
		)
	var/starting_constitution = initial(base_constitution)
	var/starting_endurance = initial(base_endurance)
	return list(
		DEFEAT_HORNY_THRESHOLD_VALUE = horny_defeat_threshold_for_stats(0, FALSE, starting_constitution, starting_endurance),
		DEFEAT_HORNY_THRESHOLD_SOURCE = "Threshold source: creature base stats (CON [starting_constitution], END [starting_endurance]).",
	)

/// Exact private progress text. Kept pure so the displayed values are regression-testable.
/proc/horny_defeat_progress_text(count, threshold, threshold_source)
	var/remaining = max(threshold - count, 0)
	var/climax_word = remaining == 1 ? "climax" : "climaxes"
	return "Horny defeat progress: [count]/[threshold]. [remaining] [climax_word] remaining. [threshold_source]"

/// Shared explicit/recovery cleanup entry point for both full defeat and the lighter mob KO.
/mob/living/proc/reset_horny_defeat_progress()
	var/datum/component/defeat_monitor/monitor = GetComponent(/datum/component/defeat_monitor)
	monitor?.reset_horny_defeat_encounter()

/datum/component/defeat_ai_opt_in
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/previous_opt_in = FALSE

/datum/component/defeat_ai_opt_in/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/defeat_ai_opt_in/RegisterWithParent()
	var/mob/living/living_parent = parent
	previous_opt_in = living_parent.defeat_system_ai_opt_in
	living_parent.defeat_system_ai_opt_in = TRUE
	living_parent.ensure_defeat_monitor()

/datum/component/defeat_ai_opt_in/UnregisterFromParent()
	var/mob/living/living_parent = parent
	if(!istype(living_parent))
		return
	living_parent.defeat_system_ai_opt_in = previous_opt_in
	if(!living_parent.defeat_system_is_eligible())
		var/datum/component/defeat_monitor/monitor = living_parent.GetComponent(/datum/component/defeat_monitor)
		qdel(monitor)
