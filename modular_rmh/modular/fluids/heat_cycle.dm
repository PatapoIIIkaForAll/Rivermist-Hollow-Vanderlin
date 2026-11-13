// Heat and rut: a timed cycle from the quirk or species, or nightfall for werewolves.

/// Time from gaining the cycle to the first heat, picked at random between these.
#define HEAT_FIRST_DELAY_MIN (40 MINUTES)
#define HEAT_FIRST_DELAY_MAX (80 MINUTES)
/// Time from one heat starting to the next one, picked at random between these.
#define HEAT_INTERVAL_MIN (120 MINUTES)
#define HEAT_INTERVAL_MAX (180 MINUTES)
/// How long one heat lasts.
#define HEAT_DURATION (30 MINUTES)
/// A climax stops the heat pulling arousal up for this long.
#define HEAT_SATED_DURATION (10 MINUTES)
/// How often heat leaves a musk mark that a keen nose can follow.
#define HEAT_MUSK_INTERVAL (1 MINUTES)
/// Time between heat reminders, picked at random between these.
#define HEAT_MESSAGE_MIN (3 MINUTES)
#define HEAT_MESSAGE_MAX (5 MINUTES)
/// Pheromones reach this far from the owner, and this far from a tile on their recent trail.
#define PHEROMONE_RANGE 3
#define PHEROMONE_TRAIL_RANGE 1
/// A tile the owner stood on keeps their scent this long; the trail keeps this many tiles.
#define PHEROMONE_LINGER (3 MINUTES)
#define PHEROMONE_TRAIL_CAP 18
/// One whiff keeps its effect this long.
#define PHEROMONE_HAZE_DURATION (1 MINUTES)
/// The same person notices a scent again only after this long.
#define PHEROMONE_MESSAGE_COOLDOWN (5 MINUTES)

/// Gives heat cycles from one source; the cycle runs while any source remains.
/mob/living/proc/grant_heat_cycle(source)
	ADD_TRAIT(src, TRAIT_HEAT_CYCLE, source)
	var/datum/component/heat_cycle/cycle = LoadComponent(/datum/component/heat_cycle)
	cycle.update_schedule()

/mob/living/proc/revoke_heat_cycle(source)
	REMOVE_TRAIT(src, TRAIT_HEAT_CYCLE, source)
	var/datum/component/heat_cycle/cycle = GetComponent(/datum/component/heat_cycle)
	if(!cycle)
		return
	if(!HAS_TRAIT(src, TRAIT_HEAT_CYCLE))
		qdel(cycle)
		return
	cycle.update_schedule()

/// Raises arousal by one small step toward a floor, never past it.
/proc/pull_arousal_toward(mob/living/target, floor)
	var/list/arousal_data = list()
	SEND_SIGNAL(target, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal = arousal_data["arousal"]
	if(isnull(arousal) || arousal >= floor)
		return
	SEND_SIGNAL(target, COMSIG_SEX_ADJUST_AROUSAL, min(HEAT_AROUSAL_STEP, floor - arousal))

/// Starts heat on a timer, or at nightfall for werewolves; losing the last source ends any heat.
/datum/component/heat_cycle
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Timer that starts the next timed heat.
	var/next_heat_timer

/datum/component/heat_cycle/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/heat_cycle/RegisterWithParent()
	RegisterSignal(SSdcs, COMSIG_GLOB_TIME_OF_DAY_CHANGED, PROC_REF(on_time_of_day_changed))

/datum/component/heat_cycle/UnregisterFromParent()
	UnregisterSignal(SSdcs, COMSIG_GLOB_TIME_OF_DAY_CHANGED)

/datum/component/heat_cycle/Destroy(force)
	deltimer(next_heat_timer)
	next_heat_timer = null
	var/mob/living/living_parent = parent
	living_parent?.remove_status_effect(/datum/status_effect/in_heat)
	return ..()

/// Every source but the werewolf curse runs on the timer.
/datum/component/heat_cycle/proc/is_timed()
	return HAS_TRAIT_NOT_FROM(parent, TRAIT_HEAT_CYCLE, HEAT_SOURCE_WEREWOLF)

/datum/component/heat_cycle/proc/update_schedule()
	if(!is_timed())
		deltimer(next_heat_timer)
		next_heat_timer = null
		return
	if(!next_heat_timer)
		schedule_heat(rand(HEAT_FIRST_DELAY_MIN, HEAT_FIRST_DELAY_MAX))

/datum/component/heat_cycle/proc/schedule_heat(delay)
	deltimer(next_heat_timer)
	next_heat_timer = addtimer(CALLBACK(src, PROC_REF(on_heat_timer)), delay, TIMER_STOPPABLE)

/datum/component/heat_cycle/proc/on_heat_timer()
	next_heat_timer = null
	schedule_heat(rand(HEAT_INTERVAL_MIN, HEAT_INTERVAL_MAX))
	start_heat()

/datum/component/heat_cycle/proc/on_time_of_day_changed(datum/source, new_tod, old_tod)
	SIGNAL_HANDLER
	if(new_tod == "night" && HAS_TRAIT_FROM(parent, TRAIT_HEAT_CYCLE, HEAT_SOURCE_WEREWOLF))
		start_heat()

/// Starts a heat unless one runs already or the preferences refuse it; returns TRUE if it started.
/datum/component/heat_cycle/proc/start_heat()
	var/mob/living/living_parent = parent
	if(living_parent.stat == DEAD || living_parent.has_status_effect(/datum/status_effect/in_heat))
		return FALSE
	if(!allows_heat())
		return FALSE
	return !!living_parent.apply_status_effect(/datum/status_effect/in_heat)

/// The quirk is the player's own choice; species and curse heat need the ERP preference.
/datum/component/heat_cycle/proc/allows_heat()
	if(HAS_TRAIT_FROM(parent, TRAIT_HEAT_CYCLE, HEAT_SOURCE_QUIRK))
		return TRUE
	var/mob/living/living_parent = parent
	return living_parent.get_erp_pref(/datum/erp_preference/boolean/allow_heat_cycles)

/// More fluid, rising arousal, pheromones and reminders; a climax sates it for a while.
/datum/status_effect/in_heat
	id = "in_heat"
	duration = HEAT_DURATION
	tick_interval = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/in_heat
	examine_text = span_love("SUBJECTPRONOUN is flushed and restless.")
	/// TRUE when the mob has a real penis and no real vagina, so this is a rut.
	var/is_rut = FALSE
	/// Tiles the owner left pheromones on, mapped to when; oldest first.
	var/list/scent_trail
	COOLDOWN_DECLARE(next_musk)
	COOLDOWN_DECLARE(next_message)

/datum/status_effect/in_heat/on_creation(mob/living/new_owner, duration_override, ...)
	. = ..()
	if(linked_alert && is_rut)
		linked_alert.name = "In Rut"
		linked_alert.desc = "My body is in rut. I make more seed, and I keep getting aroused."

/datum/status_effect/in_heat/on_apply()
	. = ..()
	is_rut = get_real_organ(owner, ORGAN_SLOT_PENIS) && !get_real_organ(owner, ORGAN_SLOT_VAGINA)
	owner.add_fluid_modifier(/datum/fluid_modifier/in_heat, id)
	RegisterSignal(owner, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))
	RegisterSignal(owner, COMSIG_SEX_GET_AROUSAL_FLOOR, PROC_REF(on_get_arousal_floor))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	COOLDOWN_START(src, next_message, rand(HEAT_MESSAGE_MIN, HEAT_MESSAGE_MAX))
	if(is_rut)
		to_chat(owner, span_love("A hungry, restless rut takes hold of me. I crave a mate."))
	else
		to_chat(owner, span_love("A slow, restless heat builds deep inside me. My body craves a mate."))

/datum/status_effect/in_heat/on_remove()
	owner.remove_fluid_modifier(/datum/fluid_modifier/in_heat, id)
	UnregisterSignal(owner, list(COMSIG_SEX_CLIMAX, COMSIG_SEX_GET_AROUSAL_FLOOR, COMSIG_LIVING_DEATH))
	owner.remove_status_effect(/datum/status_effect/heat_sated)
	scent_trail = null
	if(owner.stat != DEAD)
		to_chat(owner, span_notice("The [is_rut ? "rut" : "heat"] fades, and my head clears."))
	return ..()

/datum/status_effect/in_heat/tick()
	if(owner.stat == DEAD)
		return
	emit_pheromones()
	if(COOLDOWN_FINISHED(src, next_musk))
		COOLDOWN_START(src, next_musk, HEAT_MUSK_INTERVAL)
		leave_fluid_scent(get_turf(owner), owner, "musk")
	if(owner.has_status_effect(/datum/status_effect/heat_sated))
		return
	pull_arousal_toward(owner, HEAT_AROUSAL_FLOOR)
	if(COOLDOWN_FINISHED(src, next_message))
		COOLDOWN_START(src, next_message, rand(HEAT_MESSAGE_MIN, HEAT_MESSAGE_MAX))
		to_chat(owner, span_love(pick(
			"My skin feels hot and too tight. I need a mate.",
			"A needy ache pulses low in my belly.",
			"Every scent around me makes my mind wander.",
			"I can't sit still. The [is_rut ? "rut" : "heat"] won't let me.",
		)))

/datum/status_effect/in_heat/proc/on_climax(datum/source)
	SIGNAL_HANDLER
	owner.apply_status_effect(/datum/status_effect/heat_sated)

/// Holds arousal at the heat floor until a climax sates it.
/datum/status_effect/in_heat/proc/on_get_arousal_floor(datum/source, list/floor_data)
	SIGNAL_HANDLER
	if(!owner.has_status_effect(/datum/status_effect/heat_sated))
		floor_data["floor"] = max(floor_data["floor"], HEAT_AROUSAL_FLOOR)

/datum/status_effect/in_heat/proc/on_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/in_heat/proc/get_scent_flag()
	return is_rut ? PHEROMONE_SCENT_RUT : PHEROMONE_SCENT_HEAT

/datum/status_effect/in_heat/proc/get_scent_name()
	return is_rut ? "a sharp, heavy musk" : "a sweet, heady musk"

/// The owner's scent reaches people nearby and people standing on the trail they left.
/datum/status_effect/in_heat/proc/emit_pheromones()
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf)
		return
	// Re-adding moves the tile to the end, so the oldest tile always comes first.
	LAZYREMOVE(scent_trail, owner_turf)
	LAZYSET(scent_trail, owner_turf, world.time)
	if(length(scent_trail) > PHEROMONE_TRAIL_CAP)
		scent_trail.Cut(1, 2)
	var/list/smellers = list()
	for(var/mob/living/carbon/human/smeller in hearers(PHEROMONE_RANGE, owner_turf))
		smellers[smeller] = TRUE
	for(var/turf/trail_turf as anything in scent_trail.Copy())
		if(world.time - scent_trail[trail_turf] > PHEROMONE_LINGER)
			scent_trail -= trail_turf
			continue
		if(trail_turf == owner_turf)
			continue
		for(var/mob/living/carbon/human/smeller in range(PHEROMONE_TRAIL_RANGE, trail_turf))
			smellers[smeller] = TRUE
	smellers -= owner
	for(var/mob/living/carbon/human/smeller as anything in smellers)
		smell_pheromones(smeller)

/datum/status_effect/in_heat/proc/smell_pheromones(mob/living/carbon/human/smeller)
	smell_pheromones_of(owner, smeller, get_scent_flag(), get_scent_name())

/// One whiff: it arouses only if the smeller's preference takes this scent; anyone else just smells it.
/proc/smell_pheromones_of(mob/living/source, mob/living/carbon/human/smeller, scent_flag, scent_name)
	if(smeller.stat != CONSCIOUS || !smeller.can_smell() || HAS_TRAIT(smeller, TRAIT_NOBREATH) || HAS_TRAIT(smeller, TRAIT_DEADNOSE))
		return
	var/aroused = smeller.get_erp_pref(/datum/erp_preference/bitflag/pheromones) & scent_flag
	if(aroused)
		smeller.apply_status_effect(/datum/status_effect/pheromone_haze)
	var/last_smelled = smeller.mob_timers["pheromone_smell"]
	if(last_smelled && world.time < last_smelled + PHEROMONE_MESSAGE_COOLDOWN)
		return
	smeller.mob_timers["pheromone_smell"] = world.time
	var/source_text = (source in view(smeller)) ? " from [source]" : ""
	if(aroused)
		to_chat(smeller, span_love("I catch [scent_name][source_text]. It makes my thoughts wander."))
	else
		to_chat(smeller, span_notice("I catch [scent_name][source_text]."))

/// One pheromone pulse reaching people near the source, without the lingering trail a heat leaves.
/proc/pulse_pheromones(mob/living/source, scent_flag, scent_name)
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/mob/living/carbon/human/smeller in hearers(PHEROMONE_RANGE, source_turf))
		if(smeller != source)
			smell_pheromones_of(source, smeller, scent_flag, scent_name)

/// Pauses the heat's arousal pull and reminders after a climax.
/datum/status_effect/heat_sated
	id = "heat_sated"
	duration = HEAT_SATED_DURATION
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/heat_sated/on_apply()
	to_chat(owner, span_love("For now, the need inside me is sated."))
	return ..()

/// Someone else's heat or rut scent: arousal climbs to a low floor and stays there while the scent lasts.
/datum/status_effect/pheromone_haze
	id = "pheromone_haze"
	duration = PHEROMONE_HAZE_DURATION
	tick_interval = 10 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/pheromone_haze/on_apply()
	RegisterSignal(owner, COMSIG_SEX_GET_AROUSAL_FLOOR, PROC_REF(on_get_arousal_floor))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	return ..()

/datum/status_effect/pheromone_haze/on_remove()
	UnregisterSignal(owner, list(COMSIG_SEX_GET_AROUSAL_FLOOR, COMSIG_LIVING_DEATH))
	return ..()

/datum/status_effect/pheromone_haze/tick()
	pull_arousal_toward(owner, PHEROMONE_AROUSAL_FLOOR)

/datum/status_effect/pheromone_haze/proc/on_get_arousal_floor(datum/source, list/floor_data)
	SIGNAL_HANDLER
	floor_data["floor"] = max(floor_data["floor"], PHEROMONE_AROUSAL_FLOOR)

/datum/status_effect/pheromone_haze/proc/on_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/buff/in_heat
	name = "In Heat"
	desc = "My body is in heat. I make more fluids, and I keep getting aroused."

/datum/erp_preference/bitflag/pheromones
	name = "Pheromones"
	description = "Which scents of someone in heat or rut slowly arouse you when you smell them."
	category = "General"
	default_value = NONE
	flags = list(
		"Heat scent" = PHEROMONE_SCENT_HEAT,
		"Rut scent" = PHEROMONE_SCENT_RUT,
	)
	flag_descriptions = list(
		"Heat scent" = "The scent of a body in heat. It comes from anyone with a vagina.",
		"Rut scent" = "The scent of a body in rut. It comes from anyone with a penis and no vagina.",
	)

/datum/quirk/neutral/heat_cycles
	name = "Heat Cycles"
	desc = "Every few hours my body goes into heat, or rut, and craves a mate."
	desc_hint = "Every 2-3 hours you go into heat for 30 minutes: more fluids, rising arousal and a musky smell. A climax gives some relief."

/datum/quirk/neutral/heat_cycles/on_spawn()
	. = ..()
	owner?.grant_heat_cycle(HEAT_SOURCE_QUIRK)

/datum/quirk/neutral/heat_cycles/on_remove()
	if(!QDELETED(owner))
		owner.revoke_heat_cycle(HEAT_SOURCE_QUIRK)
	return ..()

// The werewolf curse brings heat at nightfall; the body transfer hooks move it with the mind.

/datum/antagonist/werewolf/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/body = mob_override || owner.current
	if(istype(body))
		body.grant_heat_cycle(HEAT_SOURCE_WEREWOLF)

/datum/antagonist/werewolf/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/body = mob_override || owner.current
	if(istype(body))
		body.revoke_heat_cycle(HEAT_SOURCE_WEREWOLF)

#undef HEAT_FIRST_DELAY_MIN
#undef HEAT_FIRST_DELAY_MAX
#undef HEAT_INTERVAL_MIN
#undef HEAT_INTERVAL_MAX
#undef HEAT_DURATION
#undef HEAT_SATED_DURATION
#undef HEAT_MUSK_INTERVAL
#undef HEAT_MESSAGE_MIN
#undef HEAT_MESSAGE_MAX
#undef PHEROMONE_RANGE
#undef PHEROMONE_TRAIL_RANGE
#undef PHEROMONE_LINGER
#undef PHEROMONE_TRAIL_CAP
#undef PHEROMONE_HAZE_DURATION
#undef PHEROMONE_MESSAGE_COOLDOWN
