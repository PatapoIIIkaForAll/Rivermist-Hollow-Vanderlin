/// Arousal as a percent of the display scale, capped at 100.
/proc/arousal_display_percent(arousal)
	return clamp(arousal / AROUSAL_DISPLAY_MAX * 100, 0, 100)

/// Filled steps of the interact heart, 0 to AROUSAL_HEART_STEPS.
/proc/arousal_heart_step(arousal)
	return clamp(FLOOR(arousal / AROUSAL_DISPLAY_MAX * AROUSAL_HEART_STEPS, 1), 0, AROUSAL_HEART_STEPS)

/// Arousal above the full display scale.
/proc/is_highly_aroused(arousal)
	return arousal > AROUSAL_DISPLAY_MAX

/// Near-climax edge strength from 0 to 1; zero below the start, full at the climax threshold.
/proc/near_climax_edge_strength(orgasm_progress)
	var/start = PASSIVE_EJAC_THRESHOLD * NEAR_CLIMAX_EDGE_START
	if(orgasm_progress < start)
		return 0
	if(orgasm_progress >= PASSIVE_EJAC_THRESHOLD)
		return 1
	var/progress = (orgasm_progress - start) / (PASSIVE_EJAC_THRESHOLD - start)
	return NEAR_CLIMAX_EDGE_START_STRENGTH + (1 - NEAR_CLIMAX_EDGE_START_STRENGTH) * progress

/// Shows the arousal edges and hazes on screen; off clears them.
/datum/preference/toggle/lewd_screen_effects
	savefile_key = "lewd_screen_effects"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE
	toggles_menu_category = "Content"
	toggles_menu_name = "Lewd screen effects"
	toggles_menu_desc = "Show the pink edge near climax and the hazes from cum-brain and aphrodisiac overdose."

/datum/preference/toggle/lewd_screen_effects/apply_to_client_updated(client/player, value)
	. = ..()
	var/mob/living/viewer = player?.mob
	if(!istype(viewer))
		return
	if(!value)
		viewer.clear_lewd_screens()
		return
	var/datum/component/arousal/arousal = viewer.GetComponent(/datum/component/arousal)
	arousal?.update_near_climax_edge(TRUE)

/// Whether these preferences allow lewd edges and hazes; no preferences means no screen to draw on.
/proc/lewd_screen_effects_enabled(datum/preferences/prefs)
	if(!prefs)
		return FALSE
	return !!prefs.read_preference(/datum/preference/toggle/lewd_screen_effects)

/atom/movable/screen/fullscreen/lewd
	icon = 'modular_rmh/icons/hud/arousal_edges.dmi'
	icon_state = "climax_edge"
	layer = 20.509
	alpha = 0

/atom/movable/screen/fullscreen/lewd/climax_edge

/atom/movable/screen/fullscreen/lewd/haze_cream
	icon_state = "haze_cream"
	layer = 20.508

/atom/movable/screen/fullscreen/lewd/haze_violet
	icon_state = "haze_violet"
	layer = 20.508

/// Fades a lewd edge to strength (0 to 1) over change_time; zero fades it out and removes it.
/mob/living/proc/set_lewd_edge(category, edge_type, strength, change_time = NEAR_CLIMAX_EDGE_STEP_TIME)
	if(strength <= 0)
		clear_fullscreen(category, change_time)
		return
	if(!lewd_screen_effects_enabled(client?.prefs))
		clear_fullscreen(category, FALSE)
		return
	var/atom/movable/screen/fullscreen/screen = overlay_fullscreen(category, edge_type)
	animate(screen, alpha = round(255 * strength, 1), time = change_time)

/// Fades a lewd haze in or out; repeat calls while it is shown do nothing.
/mob/living/proc/set_lewd_haze(category, haze_type, active)
	if(!active)
		clear_fullscreen(category, LEWD_HAZE_FADE_TIME)
		return
	if(!lewd_screen_effects_enabled(client?.prefs))
		clear_fullscreen(category, FALSE)
		return
	if(screens[category])
		return
	var/atom/movable/screen/fullscreen/screen = overlay_fullscreen(category, haze_type)
	animate(screen, alpha = 255, time = LEWD_HAZE_FADE_TIME)

/// Removes every lewd edge and haze at once.
/mob/living/proc/clear_lewd_screens()
	clear_fullscreen(FULLSCREEN_NEAR_CLIMAX, FALSE)
	clear_fullscreen(FULLSCREEN_HAZE_CUMBRAINED, FALSE)
	clear_fullscreen(FULLSCREEN_HAZE_APHRODISIAC, FALSE)
	clear_fullscreen(FULLSCREEN_DEFEAT_HORNY, FALSE)
