/datum/time_of_day
	var/name = ""
	var/color = ""
	var/start = 6 HOURS // 6:00 am

/datum/time_of_day/dawn
	name = "Dawn"
	color = list("#3b4c99", "#5d417e", "#50184b")
	start = 5.5 HOURS //5:30:00 AM

/datum/time_of_day/sunrise
	name = "Sunrise"
	color = list("#F598AB","#e26d6d", "#e96e4f")
	start = 7.5 HOURS  //7:30:00 AM

/datum/time_of_day/daytime
	name = "Daytime"
	color = list("#f7baba", "#f5eabe", "#fffacece", "#bfd7e0d8", "#d2c1ebde", "#e7bbd8ea")
	start = 8 HOURS //8:00:00 AM

/datum/time_of_day/sunset
	name = "Sunset"
	color = "#fc7c52"
	start = 18 HOURS //6:00:00 PM

/datum/time_of_day/dusk
	name = "Dusk"
	color = list("#df6e4c", "#df4974", "#cf472b")
	start = 18.5 HOURS //6:30:00 PM

/datum/time_of_day/midnight
	name = "Midnight"
	color = list("#29173f96", "#2f0f46a8", "#34013fab")
	start = 20 HOURS //8:00:00 PM

GLOBAL_LIST_EMPTY(SUNLIGHT_QUEUE_WORK)   /* turfs to be stateChecked */
GLOBAL_LIST_EMPTY(SUNLIGHT_QUEUE_UPDATE) /* turfs to have their colors updated via corners (filter out the unroofed dudes) */
GLOBAL_LIST_EMPTY(SUNLIGHT_QUEUE_CORNER) /* turfs to have their color/lights/etc updated */

SUBSYSTEM_DEF(outdoor_effects)
	name = "Outdoor Weather Calc"
	wait = LIGHTING_INTERVAL
	flags = SS_TICKER
	init_order = INIT_ORDER_OUTDOOR_EFFECTS
	var/list/atom/movable/screen/plane_master/weather_effect/weather_planes_need_vis = list()

	var/list/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/sunlighting_planes = list()
	var/datum/time_of_day/current_step_datum
	var/datum/time_of_day/next_step_datum
	var/list/mutable_appearance/sunlight_overlays

	var/last_color = null
	var/picked_color
	/// world.time when the sunlight screens started to change to picked_color.
	var/transition_started = 0
	/// How long that change takes, in deciseconds.
	var/transition_length = 0
	//Ensure midnight is the liast step
	var/list/datum/time_of_day/time_cycle_steps = list(
		new /datum/time_of_day/dawn(),
		new /datum/time_of_day/sunrise(),
		new /datum/time_of_day/daytime(),
		new /datum/time_of_day/sunset(),
		new /datum/time_of_day/dusk(),
		new /datum/time_of_day/midnight()
	)
	var/alist/turf_weather_affectable_z_levels = alist()
	var/next_day = FALSE // Resets when station_time is less than the next start time.

	var/static/mutable_appearance/global_weather_effect

	/// Shared sky states: outdoor_states[state + 1][weatherproof ? 1 : 2].
	var/list/outdoor_states = list(list(null, null), list(null, null), list(null, null))
	/// Shared outdoor looks: outdoor_looks[z][sunlight appearance][weatherproof ? 1 : 2].
	var/list/outdoor_looks = list()

/datum/controller/subsystem/outdoor_effects/Initialize(timeofday)
	#ifdef FORCE_RANDOM_WORLD_GEN
	return ..()
	#endif
	if(!initialized)
		setup_weather_effect()
		for(var/zlevel in SSmapping.levels_by_trait(ZTRAIT_WEATHER_STUFF))
			if(SSmapping.level_trait(zlevel, ZTRAIT_IGNORE_WEATHER_TRAIT))
				continue
			turf_weather_affectable_z_levels[zlevel] = TRUE
		get_time_of_day()
		InitializeTurfs()
		initialized = TRUE
	fire(FALSE, TRUE)
	..()

/datum/controller/subsystem/outdoor_effects/stat_entry(msg)
	msg = "W:[length(GLOB.SUNLIGHT_QUEUE_WORK)]|U:[length(GLOB.SUNLIGHT_QUEUE_UPDATE)]|C:[length(GLOB.SUNLIGHT_QUEUE_CORNER)]"
	return ..()

/datum/controller/subsystem/outdoor_effects/proc/InitializeTurfs(list/targets)
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		if(SSmapping.level_trait(z, ZTRAIT_IGNORE_WEATHER_TRAIT))
			continue
		GLOB.SUNLIGHT_QUEUE_WORK += Z_TURFS(z)
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		if(SSmapping.level_trait(z, ZTRAIT_IGNORE_WEATHER_TRAIT))
			continue
		GLOB.SUNLIGHT_QUEUE_WORK += Z_TURFS(z)

/datum/controller/subsystem/outdoor_effects/proc/check_cycle()
	if(!next_step_datum)
		get_time_of_day()
		return TRUE

	if(station_time() > next_step_datum.start)
		if(next_day)
			return FALSE
		get_time_of_day()
		return TRUE
	else if (next_day) // It is now the next morning, reset our next day
		next_day = FALSE

	return FALSE

/datum/controller/subsystem/outdoor_effects/proc/get_time_of_day()
	//Set our current color as last_color so newly initialized sunlight screens have a color
	if(current_step_datum)
		last_color = picked_color

	//Get the next time step (first time where NOW > START_TIME)
	//If we don't find one - grab the LAST time step (which should be midnight)
	var/time = station_time()
	var/datum/time_of_day/new_step = null

	for(var/i in 1 to length(time_cycle_steps))
		if(time >= time_cycle_steps[i].start)
			new_step = time_cycle_steps[i]
			next_step_datum = i == length(time_cycle_steps) ? time_cycle_steps[1] : time_cycle_steps[i + 1]

	//New time is the last time step in list (midnight) - next time will be the first step
	if(!new_step)
		new_step = time_cycle_steps[length(time_cycle_steps)]
		next_step_datum = time_cycle_steps[1]

	current_step_datum = new_step
	picked_color = pick(current_step_datum.color)

	// If the next start time is less than the current start time (i.e 10 PM vs 5 AM) then set our NextDay value
	if(next_step_datum.start <= current_step_datum.start)
		next_day = TRUE

	//If it is round-start, we wouldn't have had a current_step_datum, so set our last_color to the current one
	if(!last_color)
		last_color = picked_color

/* set sunlight color + add weather effect to clients */
/datum/controller/subsystem/outdoor_effects/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/i = 0

	//Add our weather particle obj to any new weather screens
	if(SSParticleWeather.initialized)
		for(i in 1 to length(weather_planes_need_vis))
			var/atom/movable/screen/plane_master/weather_effect/W = weather_planes_need_vis[i]
			if(W)
				W.vis_contents = list(SSParticleWeather.getweatherEffect())
			if(init_tick_checks)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
		if(i)
			weather_planes_need_vis.Cut(1, i+1)
			i = 0

	for(i in 1 to length(GLOB.SUNLIGHT_QUEUE_WORK))
		var/turf/T = GLOB.SUNLIGHT_QUEUE_WORK[i]
		if(T)
			T.update_sky_and_weather_states()
			if(T.outdoor_effect)
				// a turf may be queued more than once; updating it twice is harmless
				// if that becomes slow, use |= instead of +=, or add a turf flag to prevent duplicate queueing
				GLOB.SUNLIGHT_QUEUE_UPDATE += T

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(i)
		GLOB.SUNLIGHT_QUEUE_WORK.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to length(GLOB.SUNLIGHT_QUEUE_UPDATE))
		var/turf/U = GLOB.SUNLIGHT_QUEUE_UPDATE[i]
		if(U?.outdoor_effect)
			U.sunlight_process_state()
			update_outdoor_look(U)

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.SUNLIGHT_QUEUE_UPDATE.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	// this list can get REALLY LONG so we do this to avoid list copies
	for (i in 1 to length(GLOB.SUNLIGHT_QUEUE_CORNER))
		var/turf/T = GLOB.SUNLIGHT_QUEUE_CORNER[i]
		T.turf_flags &= ~TURF_SUNLIGHT_QUEUED

		/* if we haven't initialized but we are affected, create new and check state */
		if(!T.outdoor_effect)
			T.outdoor_effect = get_outdoor_state(SKY_BLOCKED, TRUE)
			T.update_sky_and_weather_states()

			/* in case we aren't indoor somehow, wack us into the proc queue, we will be skipped on next indoor check */
			if(T.outdoor_effect.state != SKY_BLOCKED)
				GLOB.SUNLIGHT_QUEUE_UPDATE += T

		if(T.outdoor_effect.state != SKY_BLOCKED)
			continue

		//This might need to be run more liberally
		update_outdoor_look(T)

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break

	if (i)
		GLOB.SUNLIGHT_QUEUE_CORNER.Cut(1, i+1)
		i = 0

	if(check_cycle())
		transition_started = world.time
		transition_length = get_transition_length()
		for (var/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/SP in sunlighting_planes)
			transition_sunlight_color(SP)

//Transition from our last color to our current color (i.e if it is going from daylight (white) to sunset (red), we transition to red in the first hour of sunset)
/datum/controller/subsystem/outdoor_effects/proc/transition_sunlight_color(atom/movable/screen/fullscreen/lighting_backdrop/sunlight/SP)
	animate(SP, color = picked_color, time = transition_length)

/// How long a change of the sky colour takes: an hour of game time, or the time to the next step if that is shorter.
/datum/controller/subsystem/outdoor_effects/proc/get_transition_length()
	if(!next_step_datum)
		get_time_of_day()
	return min((1 HOURS / SSticker.station_time_rate_multiplier), daytimeDiff(station_time(), next_step_datum.start))

/// Gives a new sunlight screen the colour that the other screens show at this moment.
/datum/controller/subsystem/outdoor_effects/proc/sync_sunlight_color(atom/movable/screen/fullscreen/lighting_backdrop/sunlight/SP)
	if(!next_step_datum)
		get_time_of_day()
	var/time_left = transition_started + transition_length - world.time
	if(time_left <= 0 || transition_length <= 0 || !last_color)
		SP.color = picked_color
		return
	SP.color = gradient(last_color, picked_color, 1 - time_left / transition_length)
	animate(SP, color = picked_color, time = time_left)

/// Returns the shared sky state for state and weatherproof, making it on first use.
/datum/controller/subsystem/outdoor_effects/proc/get_outdoor_state(state, weatherproof)
	var/list/states = outdoor_states[state + 1]
	var/index = weatherproof ? 1 : 2
	var/datum/outdoor_state/outdoor_state = states[index]
	if(!outdoor_state)
		outdoor_state = new
		outdoor_state.state = state
		outdoor_state.weatherproof = weatherproof ? TRUE : FALSE
		states[index] = outdoor_state
	return outdoor_state

/// Returns a shared look for z-level z, the sunlight appearance and weatherproof, making one if needed.
/// Does not change the look's user count.
/datum/controller/subsystem/outdoor_effects/proc/get_outdoor_look(z, mutable_appearance/sunlight, weatherproof)
	LISTASSERTLEN(outdoor_looks, z, null)
	var/list/level = outdoor_looks[z]
	if(!level)
		level = list()
		outdoor_looks[z] = level
	var/list/pair = level[sunlight]
	if(!pair)
		pair = list(null, null)
		level[sunlight] = pair

	var/index = weatherproof ? 1 : 2
	var/atom/movable/outdoor_look/look = pair[index]
	if(look)
		if(look.users < OUTDOOR_LOOK_MAX_USERS)
			return look
		look.retired = TRUE

	look = new /atom/movable/outdoor_look(null)
	look.look_z = z
	look.look_sunlight = sunlight
	look.look_weatherproof = weatherproof ? TRUE : FALSE
	look.layer = OUTDOOR_LOOK_LAYER(z)
	//Get weather overlay if not weatherproof
	look.overlays = weatherproof ? list(sunlight) : list(sunlight, global_weather_effect)
	look.luminosity = sunlight.luminosity
	pair[index] = look
	return look

/// Drops one user from look. An unused retired look is deleted; an unused cached one stays cached.
/datum/controller/subsystem/outdoor_effects/proc/release_outdoor_look(atom/movable/outdoor_look/look)
	look.users--
	if(look.users <= 0 && look.retired)
		qdel(look, TRUE)

/// Picks the sunlight picture for T from its sky state and corners, and shows the matching shared look.
/datum/controller/subsystem/outdoor_effects/proc/update_outdoor_look(turf/T)
	var/mutable_appearance/MA
	if ((T.outdoor_effect.state != SKY_BLOCKED) || istype(T, /turf/closed/sea_fog))
		MA = get_sunlight_overlay(1, 1, 1, 1) /* fully lit */
	else //Indoor - do proper corner checks
		/* check if we are globally affected or not */
		var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

		var/list/corners = T.corners
		if(!length(corners))
			T.generate_missing_corners()
			corners = T.corners
		var/datum/lighting_corner/cr = corners[3] || dummy_lighting_corner
		var/datum/lighting_corner/cg = corners[2] || dummy_lighting_corner
		var/datum/lighting_corner/cb = corners[4] || dummy_lighting_corner
		var/datum/lighting_corner/ca = corners[1] || dummy_lighting_corner

		var/fr = cr.sunFalloff
		var/fg = cg.sunFalloff
		var/fb = cb.sunFalloff
		var/fa = ca.sunFalloff

		MA = get_sunlight_overlay(fr, fg, fb, fa)

	T.set_outdoor_look(get_outdoor_look(T.z, MA, T.outdoor_effect.weatherproof))

//Retrieve an overlay from the list - create if necessary
/datum/controller/subsystem/outdoor_effects/proc/get_sunlight_overlay(fr = 0, fg = 0, fb = 0, fa = 0)
	var/index = jointext(args, "|") // using = 0 ensures that the index still works even if we don't pass all args
	if(!sunlight_overlays?[index])
		LAZYSET(sunlight_overlays, index, create_sunlight_overlay(fr, fg, fb, fa))
	return sunlight_overlays[index]

//get our weather overlay
/datum/controller/subsystem/outdoor_effects/proc/setup_weather_effect()
	var/mutable_appearance/MA = new /mutable_appearance()
	MA.icon = 'icons/effects/weather_overlay.dmi'
	MA.icon_state = "weather_overlay"
	MA.plane = WEATHER_OVERLAY_PLANE
	MA.blend_mode = BLEND_OVERLAY
	MA.invisibility = INVISIBILITY_LIGHTING
	global_weather_effect = MA

//Create an overlay appearance from corner values
/datum/controller/subsystem/outdoor_effects/proc/create_sunlight_overlay(fr, fg, fb, fa)
	var/mutable_appearance/MA = new /mutable_appearance()
	MA.icon = LIGHTING_ICON
	MA.icon_state = null
	MA.plane = SUNLIGHTING_PLANE /* we put this on a lower level than lighting so we dont multiply anything */
	MA.blend_mode = BLEND_OVERLAY
	MA.invisibility = INVISIBILITY_LIGHTING

	//MA gets applied as an overlay, but we pull luminosity out to set the outdoor look's lum
#if LIGHTING_SOFT_THRESHOLD != 0
	MA.luminosity = max(fr, fg, fb, fa) > LIGHTING_SOFT_THRESHOLD
#else
	MA.luminosity = max(fr, fg, fb, fa) > 1e-6
#endif

	if((fr & fg & fb & fa) && (fr + fg + fb + fa == 4)) /* this will likely never happen */
		MA.color = LIGHTING_BASE_MATRIX
	else if(!MA.luminosity)
		MA.color = SUNLIGHT_DARK_MATRIX
	else
		MA.color = list(
			fr, fr, fr, 00,
			fg, fg, fg, 00,
			fb, fb, fb, 00,
			fa, fa, fa, 00,
			00, 00, 00, 01
		)
	return MA
