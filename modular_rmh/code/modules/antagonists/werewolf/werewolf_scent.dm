// Scent of the Pack: the mark a beast leaves on a partner it climaxed inside.

/// Every live scent mark, so a wolf can sniff out its own.
GLOBAL_LIST_EMPTY(werewolf_scent_marks)

/datum/status_effect/werewolf_scent_mark
	id = "werewolf_scent_mark"
	duration = WW_SCENT_MARK_DURATION
	tick_interval = WW_SCENT_TICK_INTERVAL
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// Mind of the werewolf that left the mark.
	var/datum/weakref/marker_ref
	/// Times the current marker has bred this mob while marked.
	var/breed_count = 0
	/// Kin mind refs mapped to the time they may draw rage from this mark again.
	var/list/kin_rage_cooldowns
	/// Mark ticks in a row spent in the rain.
	var/rain_ticks = 0

/datum/status_effect/werewolf_scent_mark/on_creation(mob/living/new_owner, duration_override, datum/mind/marker)
	set_marker(marker)
	return ..()

/datum/status_effect/werewolf_scent_mark/refresh(mob/living/new_owner, duration_override, datum/mind/marker)
	. = ..()
	if(marker && marker_ref?.resolve() == marker)
		breed_count++
	else
		set_marker(marker)

/datum/status_effect/werewolf_scent_mark/on_apply()
	. = ..()
	GLOB.werewolf_scent_marks += src
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_wash))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMERSED), PROC_REF(on_immersed))

/datum/status_effect/werewolf_scent_mark/on_remove()
	GLOB.werewolf_scent_marks -= src
	UnregisterSignal(owner, list(COMSIG_COMPONENT_CLEAN_ACT, SIGNAL_ADDTRAIT(TRAIT_IMMERSED)))
	marker_ref = null
	kin_rage_cooldowns = null
	return ..()

/datum/status_effect/werewolf_scent_mark/tick()
	if(check_rain_rinse())
		return
	stir_nearby_kin()

/datum/status_effect/werewolf_scent_mark/proc/set_marker(datum/mind/marker)
	marker_ref = marker ? WEAKREF(marker) : null
	breed_count = 1
	kin_rage_cooldowns = null

/datum/status_effect/werewolf_scent_mark/proc/get_marker()
	RETURN_TYPE(/datum/mind)
	return marker_ref?.resolve()

/// Conversion chance multiplier for a breeding by source: higher when the marking wolf breeds its mark again.
/datum/status_effect/werewolf_scent_mark/proc/get_werewolf_conversion_multiplier(mob/living/source)
	if(!source?.mind || source.mind != get_marker())
		return 1
	return breed_count >= 2 ? WW_SCENT_REBREED_CONVERSION_MULT : 1

/// Werewolves and Rakshari pick the pack scent out.
/datum/status_effect/werewolf_scent_mark/proc/is_smelled_by(mob/living/sniffer)
	if(IS_WEREWOLF(sniffer))
		return TRUE
	var/mob/living/carbon/human/human_sniffer = sniffer
	return istype(human_sniffer) && istype(human_sniffer.dna?.species, /datum/species/rakshari)

/datum/status_effect/werewolf_scent_mark/proc/rinse_off(message)
	if(owner && message)
		to_chat(owner, span_notice(message))
	qdel(src)

/datum/status_effect/werewolf_scent_mark/proc/on_wash(datum/source, clean_types)
	SIGNAL_HANDLER
	if(clean_types & (CLEAN_WASH | CLEAN_SCRUB | CLEAN_ALL))
		rinse_off("The wash scrubs a heavy, wild musk off me.")

/datum/status_effect/werewolf_scent_mark/proc/on_immersed(datum/source)
	SIGNAL_HANDLER
	rinse_off("The water rinses a heavy, wild musk off me.")

/// A spell of rain under open sky washes the mark off; returns TRUE when it did.
/datum/status_effect/werewolf_scent_mark/proc/check_rain_rinse()
	var/datum/particle_weather/rain/rain = SSParticleWeather.runningWeather
	if(!istype(rain) || !rain.can_weather(owner) || !rain.can_weather_effect(owner))
		rain_ticks = 0
		return FALSE
	rain_ticks++
	if(rain_ticks < WW_SCENT_RAIN_RINSE_TICKS)
		return FALSE
	rinse_off("The rain rinses a heavy, wild musk off me.")
	return TRUE

/// Other werewolves standing by the marked mob catch the pack scent and gain rage, once a minute each.
/datum/status_effect/werewolf_scent_mark/proc/stir_nearby_kin()
	var/datum/mind/marker = get_marker()
	for(var/mob/living/carbon/human/kin in range(WW_SCENT_KIN_RANGE, owner))
		if(kin == owner || kin.stat == DEAD || !kin.rage_datum || !kin.mind || kin.mind == marker)
			continue
		if(!IS_WEREWOLF(kin))
			continue
		var/kin_key = REF(kin.mind)
		if(world.time < LAZYACCESS(kin_rage_cooldowns, kin_key))
			continue
		LAZYSET(kin_rage_cooldowns, kin_key, world.time + WW_SCENT_KIN_RAGE_COOLDOWN)
		kin.rage_datum.update_rage(WW_SCENT_KIN_RAGE)
		to_chat(kin, span_warning("The pack's scent on [owner] sets my blood racing."))

/// Lets the marking werewolf follow its scent to the nearest marked mate.
/datum/action/innate/werewolf_sniff_mark
	name = "Sniff Mark"
	desc = "Taste the wind for the scent you left on a mate you bred."
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_PHASED
	button_icon_state = "dream_track"

/datum/action/innate/werewolf_sniff_mark/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	return !!IS_WEREWOLF(owner)

/datum/action/innate/werewolf_sniff_mark/Activate()
	. = ..()
	var/datum/mind/marker_mind = target
	if(istype(marker_mind) && owner)
		sniff_werewolf_marks(owner, marker_mind)

/// The nearest mob the given mind marked on the sniffer's map, or null.
/proc/find_nearest_werewolf_mark(mob/living/sniffer, datum/mind/marker_mind)
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(sniffer)
	var/turf/sniffer_turf = get_turf(sniffer)
	if(!wolf || !sniffer_turf)
		return null
	var/sniffer_map = wolf.get_werewolf_lair_map_file(sniffer_turf)
	var/mob/living/closest
	var/closest_distance = INFINITY
	for(var/datum/status_effect/werewolf_scent_mark/mark as anything in GLOB.werewolf_scent_marks)
		if(QDELETED(mark.owner) || mark.get_marker() != marker_mind)
			continue
		var/turf/mark_turf = get_turf(mark.owner)
		if(!mark_turf)
			continue
		// A map without a map file only counts its own z-level.
		var/mark_map = wolf.get_werewolf_lair_map_file(mark_turf)
		if((sniffer_map || mark_map) ? (sniffer_map != mark_map) : (mark_turf.z != sniffer_turf.z))
			continue
		var/distance = get_dist(sniffer_turf, mark_turf)
		if(distance < closest_distance)
			closest_distance = distance
			closest = mark.owner
	return closest

/// Tells the sniffer which way and how far the nearest mob they marked is.
/proc/sniff_werewolf_marks(mob/living/sniffer, datum/mind/marker_mind)
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(sniffer)
	var/turf/sniffer_turf = get_turf(sniffer)
	if(!wolf || !sniffer_turf)
		return FALSE
	playsound(sniffer, 'sound/items/sniff.ogg', 70, TRUE)
	var/mob/living/closest = find_nearest_werewolf_mark(sniffer, marker_mind)
	if(!closest)
		to_chat(sniffer, span_notice("No mate of mine carries my scent on this land."))
		return FALSE
	var/turf/mark_turf = get_turf(closest)
	var/distance_text = wolf.get_werewolf_lair_distance_text(sniffer_turf, mark_turf)
	var/direction_text = get_precise_direction_between(sniffer_turf, mark_turf) || dir2text(get_dir(sniffer_turf, mark_turf))
	var/level_text = (mark_turf.z != sniffer_turf.z) ? ", on another level" : ""
	if(direction_text)
		to_chat(sniffer, span_notice("My scent on [closest] is [distance_text] to the [direction_text][level_text]."))
	else
		to_chat(sniffer, span_notice("My scent on [closest] is [distance_text][level_text]."))
	return TRUE
