#define MUSK_SCREEN_CATEGORY "musk_haze"
#define MUSK_SCREEN_FILTER "musk_sway"
#define MUSK_SCREEN_BASE_TIME (4 SECONDS)
#define MUSK_SCREEN_TIME_PER_LEVEL (1 SECONDS)
#define MUSK_SCREEN_FADE (2 SECONDS)
#define MUSK_SCREEN_ALPHA_BASE 30
#define MUSK_SCREEN_ALPHA_PER_LEVEL 15
#define MUSK_SCREEN_COLOR "#d9a05b"
#define MUSK_SCREEN_COLOR_PLEASANT "#e79ab0"
#define MUSK_SCREEN_COLOR_FOUL "#7d8a45"
#define MUSK_SWAY_SIZE_PER_LEVEL 0.25
#define MUSK_SWAY_PERIOD (6 SECONDS)
#define MUSK_DIZZY_TIME_PER_LEVEL (1 SECONDS)

/datum/status_effect/musk
	id = "musk"
	duration = -1
	tick_interval = MUSK_AURA_INTERVAL
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/buff/musk
	var/level = 1
	var/fade_at = 0
	var/hidden = FALSE

/datum/status_effect/musk/on_creation(mob/living/new_owner, new_level = 1)
	level = clamp(new_level, 1, MUSK_LEVEL_MAX)
	. = ..(new_owner)
	if(QDELETED(src))
		return
	update_hiding()
	update_alert()
	to_chat(owner, span_love(musk_level_text(owner, level)))

/datum/status_effect/musk/on_apply()
	. = ..()
	fade_at = world.time + MUSK_LEVEL_FADE_TIME
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/status_effect/musk/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	return ..()

/datum/status_effect/musk/tick()
	if(world.time >= fade_at && !weaken())
		return
	update_hiding()
	if(hidden)
		return
	spread_musk_scent(get_turf(owner), level, owner)
	reach_for_thralls()

/datum/status_effect/musk/get_examine_text(mob/user, list/P)
	if(hidden)
		return null
	switch(level)
		if(1)
			return span_notice("SUBJECTPRONOUN is glistening with fresh sweat.")
		if(2)
			return span_notice("SUBJECTPRONOUN is damp with sweat, a warm musk clinging to the skin.")
		if(3)
			return span_love("SUBJECTPRONOUN is drenched in sweat and wreathed in a heavy musk.")
	return span_love("SUBJECTPRONOUN is reeking of labour and heat, a heady musk rolling off the skin like smoke.")

/datum/status_effect/musk/proc/strengthen()
	fade_at = world.time + MUSK_LEVEL_FADE_TIME
	if(level >= MUSK_LEVEL_MAX)
		return FALSE
	level += 1
	update_alert()
	to_chat(owner, span_love(musk_level_text(owner, level)))
	return TRUE

/datum/status_effect/musk/proc/weaken()
	level -= 1
	if(level <= 0)
		to_chat(owner, span_notice(musk_faded_text(owner)))
		qdel(src)
		return FALSE
	fade_at = world.time + MUSK_LEVEL_FADE_TIME
	update_alert()
	to_chat(owner, span_notice(musk_weaker_text(owner)))
	return TRUE

/datum/status_effect/musk/proc/update_hiding()
	var/now_hidden = !!owner.get_musk()?.is_hidden()
	if(hidden == now_hidden)
		return
	hidden = now_hidden
	update_alert()

/datum/status_effect/musk/proc/reach_for_thralls()
	var/datum/component/musk/musk = owner.get_musk()
	for(var/datum/musk_bond/bond as anything in owner.mind?.scent_followers)
		bond.reach(musk)

/datum/status_effect/musk/proc/update_alert()
	if(!linked_alert)
		return
	var/static/list/numerals = list("I", "II", "III", "IV")
	linked_alert.name = musk_localized(owner, "Smelling [numerals[level]]", "Запах [numerals[level]]")
	linked_alert.desc = hidden ? "[musk_alert_text(owner, level)] [musk_hidden_alert_text(owner)]" : musk_alert_text(owner, level)

/datum/status_effect/musk/proc/on_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/debuff/musk_haze
	id = "musk_haze"
	duration = MUSK_HAZE_DURATION
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/debuff/musk_haze
	var/level = 1
	var/screen_timer

/datum/status_effect/debuff/musk_haze/on_creation(mob/living/new_owner, new_level = 1, silent = FALSE, mob/living/source)
	level = clamp(new_level, 1, MUSK_LEVEL_MAX)
	effectedstats = get_level_stats()
	. = ..(new_owner)
	if(QDELETED(src))
		return
	update_alert()
	strike(silent, source)

/datum/status_effect/debuff/musk_haze/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_SEX_GET_AROUSAL_FLOOR, PROC_REF(on_get_arousal_floor))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/status_effect/debuff/musk_haze/on_remove()
	UnregisterSignal(owner, list(COMSIG_SEX_GET_AROUSAL_FLOOR, COMSIG_LIVING_DEATH))
	deltimer(screen_timer)
	clear_haze_screen()
	return ..()

/datum/status_effect/debuff/musk_haze/proc/get_level_stats()
	var/static/list/penalties = MUSK_INTELLIGENCE_PENALTY_BY_LEVEL
	return list((STAT_INTELLIGENCE) = -penalties[level])

/datum/status_effect/debuff/musk_haze/proc/intensify(new_level, silent = FALSE, mob/living/source)
	if(new_level <= level)
		return FALSE
	level = min(new_level, MUSK_LEVEL_MAX)
	effectedstats = get_level_stats()
	owner.set_stat_modifier("[id]", effectedstats)
	duration = world.time + initial_duration
	update_alert()
	strike(silent, source)
	return TRUE

/datum/status_effect/debuff/musk_haze/proc/strike(silent, mob/living/source)
	var/mob/living/carbon/human/smeller = owner
	var/datum/component/musk/musk = source?.get_musk()
	var/quality = musk?.get_scent_for(smeller)
	cloud_head(quality)
	show_haze_screen(quality)
	if(silent)
		return
	var/list/lines = list(musk_haze_text(smeller, level))
	var/quality_text = musk_quality_text(smeller, musk)
	if(quality_text)
		lines += quality_text
	if(source && (source in view(smeller)))
		lines += musk_source_text(smeller, source)
	smeller.tell_once_per_contact(MUSK_LINE_HAZE, lines.Join(" "))

/datum/status_effect/debuff/musk_haze/proc/cloud_head(quality)
	var/dizzy_time = MUSK_DIZZY_TIME_PER_LEVEL * level
	switch(quality)
		if(MUSK_SCENT_PLEASANT)
			dizzy_time *= MUSK_PLEASANT_DIZZY_MULTIPLIER
		if(MUSK_SCENT_FOUL)
			dizzy_time *= MUSK_FOUL_DIZZY_MULTIPLIER
			owner.set_eye_blur_if_lower(MUSK_FOUL_BLUR_PER_LEVEL * level)
	owner.set_dizzy_if_lower(dizzy_time)

/datum/status_effect/debuff/musk_haze/proc/get_screen_color(quality)
	switch(quality)
		if(MUSK_SCENT_PLEASANT)
			return MUSK_SCREEN_COLOR_PLEASANT
		if(MUSK_SCENT_FOUL)
			return MUSK_SCREEN_COLOR_FOUL
	return MUSK_SCREEN_COLOR

/datum/status_effect/debuff/musk_haze/proc/show_haze_screen(quality)
	var/atom/movable/screen/fullscreen/haze_screen = owner.overlay_fullscreen(MUSK_SCREEN_CATEGORY, /atom/movable/screen/fullscreen/weedsm/musk)
	haze_screen.color = get_screen_color(quality)
	animate(haze_screen, alpha = MUSK_SCREEN_ALPHA_BASE + MUSK_SCREEN_ALPHA_PER_LEVEL * level, time = MUSK_SCREEN_FADE)
	var/atom/movable/plane_master_controller/game_planes = get_game_planes()
	if(game_planes)
		game_planes.add_filter(MUSK_SCREEN_FILTER, 1, list("type" = "wave", "size" = MUSK_SWAY_SIZE_PER_LEVEL * level, "x" = 32, "y" = 32))
		for(var/filter in game_planes.get_filters(MUSK_SCREEN_FILTER))
			animate(filter, offset = 32, time = MUSK_SWAY_PERIOD, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	screen_timer = addtimer(CALLBACK(src, PROC_REF(clear_haze_screen)), MUSK_SCREEN_BASE_TIME + MUSK_SCREEN_TIME_PER_LEVEL * level, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/datum/status_effect/debuff/musk_haze/proc/clear_haze_screen()
	screen_timer = null
	if(!owner)
		return
	owner.clear_fullscreen(MUSK_SCREEN_CATEGORY, MUSK_SCREEN_FADE)
	var/atom/movable/plane_master_controller/game_planes = get_game_planes()
	game_planes?.remove_filter(MUSK_SCREEN_FILTER)

/datum/status_effect/debuff/musk_haze/proc/get_game_planes()
	var/datum/hud/owner_hud = owner?.hud_used
	if(!owner_hud)
		return null
	return owner_hud.plane_master_controllers[PLANE_MASTERS_GAME]

/datum/status_effect/debuff/musk_haze/proc/update_alert()
	if(!linked_alert)
		return
	linked_alert.name = musk_localized(owner, "Musk Haze", "Мускусный дурман")
	linked_alert.desc = musk_localized(owner, "The smell is so strong it makes your head spin. Your thoughts wade through it like flies through honey.", "Запах настолько сильный, что у вас от него кружится голова. Мысли вязнут в нём, как мухи в мёду.")

/datum/status_effect/debuff/musk_haze/proc/on_get_arousal_floor(datum/source, list/floor_data)
	SIGNAL_HANDLER
	var/datum/component/arousal/arousal = owner.GetComponent(/datum/component/arousal)
	if(arousal?.last_ejaculation_time && world.time < arousal.last_ejaculation_time + MUSK_HAZE_CLIMAX_GRACE)
		return
	var/static/list/floors = MUSK_AROUSAL_FLOOR_BY_LEVEL
	floor_data["floor"] = max(floor_data["floor"], floors[level])

/datum/status_effect/debuff/musk_haze/proc/on_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/buff/musk
	name = "Smelling"
	desc = "Sweat beads at my temples and in the hollows of my arms. A faint musk follows me like a shadow."
	icon_state = "stinky"

/atom/movable/screen/alert/status_effect/debuff/musk_haze
	name = "Musk Haze"
	desc = "The smell is so strong it makes your head spin. Your thoughts wade through it like flies through honey."
	icon_state = "debuff"

/atom/movable/screen/fullscreen/weedsm/musk
	alpha = 0
	color = MUSK_SCREEN_COLOR

/datum/pollution
	var/datum/weakref/musk_source_ref

/proc/spread_musk_scent(turf/center, level, mob/living/carbon/human/source)
	if(!center)
		return
	var/static/list/scent_types = list(
		/datum/pollutant/musk_scent/level_1,
		/datum/pollutant/musk_scent/level_2,
		/datum/pollutant/musk_scent/level_3,
		/datum/pollutant/musk_scent/level_4,
	)
	var/scent_type = scent_types[clamp(level, 1, MUSK_LEVEL_MAX)]
	for(var/turf/open/scent_turf in RANGE_TURFS(MUSK_SCENT_RANGE, center))
		if(get_musk_amount(scent_turf) >= MUSK_SCENT_CAP)
			continue
		scent_turf.pollute_turf(scent_type, MUSK_SCENT_AMOUNT)
		scent_turf.pollution?.musk_source_ref = WEAKREF(source)

/proc/get_musk_amount(turf/open/scent_turf)
	. = 0
	var/datum/pollution/present = scent_turf.pollution
	if(QDELETED(present))
		return
	for(var/pollutant_type in present.pollutants)
		if(ispath(pollutant_type, /datum/pollutant/musk_scent))
			. += present.pollutants[pollutant_type]

/datum/pollutant/musk_scent
	pollutant_flags = POLLUTANT_SMELL | POLLUTANT_BREATHE_ACT | POLLUTION_DO_NOT_SPREAD
	descriptor = SCENT_DESC_ODOR
	color = MUSK_SCREEN_COLOR
	var/level = 1

/datum/pollutant/musk_scent/breathe_act(mob/living/carbon/victim, amount, total_amount)
	. = ..()
	if(amount <= 0 || !ishuman(victim))
		return
	var/mob/living/carbon/human/smeller = victim
	if(reaches(smeller))
		smeller.smell_musk(level, find_source(smeller))
	else if(smeller.has_quirk(/datum/quirk/neutral/scent_sensitivity))
		smeller.notice_sweat(level, find_source(smeller))

/datum/pollutant/musk_scent/can_be_smelled_by(mob/living/sniffer)
	if(!reaches(sniffer))
		return FALSE
	var/mob/living/carbon/human/smeller = sniffer
	if(!smeller.can_smell_musk())
		return FALSE
	var/datum/status_effect/musk_contact/contact = smeller.has_status_effect(/datum/status_effect/musk_contact)
	return !contact || contact.allows_line(MUSK_LINE_SMELL)

/datum/pollutant/musk_scent/on_smell(mob/living/carbon/victim, amount)
	. = ..()
	var/mob/living/carbon/human/smeller = victim
	smeller.get_musk_contact()?.claim_line(MUSK_LINE_SMELL)
	var/datum/component/musk/musk = find_source(smeller)?.get_musk()
	var/notes = musk_notes_text(smeller, musk?.scent_notes)
	if(notes)
		to_chat(smeller, span_love(notes))

/datum/pollutant/musk_scent/proc/reaches(mob/living/sniffer)
	if(!ishuman(sniffer))
		return FALSE
	var/mob/living/carbon/human/smeller = sniffer
	if(!smeller.is_musk_susceptible())
		return FALSE
	return !smeller.get_musk_sweat() || !!find_source(smeller)

/datum/pollutant/musk_scent/proc/find_source(mob/living/carbon/human/smeller)
	RETURN_TYPE(/mob/living/carbon/human)
	for(var/mob/living/carbon/human/candidate in range(MUSK_SCENT_RANGE, smeller))
		if(candidate == smeller)
			continue
		var/datum/status_effect/musk/musk = candidate.has_status_effect(/datum/status_effect/musk)
		if(musk?.level == level && !musk.hidden)
			return candidate
	return get_lingering_source(smeller)

/datum/pollutant/musk_scent/proc/get_lingering_source(mob/living/carbon/human/smeller)
	RETURN_TYPE(/mob/living/carbon/human)
	var/turf/open/scented_turf = get_turf(smeller)
	if(!isopenturf(scented_turf))
		return null
	var/mob/living/carbon/human/source = scented_turf.pollution?.musk_source_ref?.resolve()
	return source == smeller ? null : source

/datum/pollutant/musk_scent/level_1
	name = "Fresh Sweat"
	scent = "fresh sweat"
	smell_intensity = 0.75
	level = 1

/datum/pollutant/musk_scent/level_2
	name = "Warm Musk"
	scent = "warm sweat and musk"
	smell_intensity = 1
	level = 2

/datum/pollutant/musk_scent/level_3
	name = "Heavy Musk"
	scent = "heavy musk"
	smell_intensity = 1.5
	level = 3

/datum/pollutant/musk_scent/level_4
	name = "Heady Musk"
	scent = "rank, heady musk"
	smell_intensity = 2
	level = 4

#undef MUSK_SCREEN_CATEGORY
#undef MUSK_SCREEN_FILTER
#undef MUSK_SCREEN_BASE_TIME
#undef MUSK_SCREEN_TIME_PER_LEVEL
#undef MUSK_SCREEN_FADE
#undef MUSK_SCREEN_ALPHA_BASE
#undef MUSK_SCREEN_ALPHA_PER_LEVEL
#undef MUSK_SCREEN_COLOR
#undef MUSK_SCREEN_COLOR_PLEASANT
#undef MUSK_SCREEN_COLOR_FOUL
#undef MUSK_SWAY_SIZE_PER_LEVEL
#undef MUSK_SWAY_PERIOD
#undef MUSK_DIZZY_TIME_PER_LEVEL
