#define MUSK_SCREEN_CATEGORY "musk_haze"
#define MUSK_SCREEN_FILTER "musk_sway"
#define MUSK_SCREEN_BASE_TIME (4 SECONDS)
#define MUSK_SCREEN_TIME_PER_LEVEL (1 SECONDS)
#define MUSK_SCREEN_FADE (2 SECONDS)
#define MUSK_SCREEN_ALPHA_BASE 30
#define MUSK_SCREEN_ALPHA_PER_LEVEL 15
#define MUSK_SCREEN_COLOR "#d9a05b"
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

/datum/status_effect/musk/on_creation(mob/living/new_owner, new_level = 1)
	level = clamp(new_level, 1, MUSK_LEVEL_MAX)
	. = ..(new_owner)
	if(QDELETED(src))
		return
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
	spread_scent()

/datum/status_effect/musk/get_examine_text(mob/user, list/P)
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

/datum/status_effect/musk/proc/spread_scent()
	var/turf/source_turf = get_turf(owner)
	if(!source_turf)
		return
	var/static/list/scent_ranges = MUSK_SCENT_RANGE_BY_LEVEL
	for(var/mob/living/carbon/human/smeller in hearers(scent_ranges[level], source_turf))
		if(smeller != owner)
			smeller.smell_musk(level, owner)

/datum/status_effect/musk/proc/update_alert()
	if(!linked_alert)
		return
	var/static/list/numerals = list("I", "II", "III", "IV")
	linked_alert.name = musk_localized(owner, "Smelling [numerals[level]]", "Запах [numerals[level]]")
	linked_alert.desc = musk_alert_text(owner, level)

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
	show_haze_screen()
	if(silent)
		return
	var/message = musk_haze_text(owner, level)
	if(source && (source in view(owner)))
		message += " [musk_source_text(owner, source)]"
	to_chat(owner, span_love(message))

/datum/status_effect/debuff/musk_haze/proc/show_haze_screen()
	owner.set_dizzy_if_lower(MUSK_DIZZY_TIME_PER_LEVEL * level)
	var/atom/movable/screen/fullscreen/haze_screen = owner.overlay_fullscreen(MUSK_SCREEN_CATEGORY, /atom/movable/screen/fullscreen/weedsm/musk)
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

#undef MUSK_SCREEN_CATEGORY
#undef MUSK_SCREEN_FILTER
#undef MUSK_SCREEN_BASE_TIME
#undef MUSK_SCREEN_TIME_PER_LEVEL
#undef MUSK_SCREEN_FADE
#undef MUSK_SCREEN_ALPHA_BASE
#undef MUSK_SCREEN_ALPHA_PER_LEVEL
#undef MUSK_SCREEN_COLOR
#undef MUSK_SWAY_SIZE_PER_LEVEL
#undef MUSK_SWAY_PERIOD
#undef MUSK_DIZZY_TIME_PER_LEVEL
