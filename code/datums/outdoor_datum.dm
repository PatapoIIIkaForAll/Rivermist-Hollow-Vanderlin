//todo: handle moving sunlight turfs - see various uses of get_turf in lighting_object


/*

Sunlight System

	States + Details
		Outdoor states (this file)
			- A turf that takes part holds a shared /datum/outdoor_state and shows a shared /atom/movable/outdoor_look
			- The look is a grayscale version of the lighting look
			- Has 3 states
				- SKY_BLOCKED  (0)
					- Turfs that have an opaque turf above them. Has no light themselves but is affected by SKY_VISIBLE_BORDER
				- SKY_VISIBLE (1)
					- Turfs that with no opaque turfs above it (no roof, glass roof, etc), with no neighbouring SKY_BLOCKED tiles
					  Emits no light, but is fully white to display the overlay color
				- SKY_VISIBLE_BORDER  (2)
					- Turfs that with no opaque turfs above it (no roof, glass roof, etc), which neighbour at least one SKY_BLOCKED tile.
				     Emits light to SKY_BLOCKED tiles, and fully white to display the overlay color

*/

/obj/proc/weather_act_on(weather_trait, severity)
	return

/// The sky state of a turf. One shared instance for each state and shelter value; never changed after creation.
/datum/outdoor_state
	var/state = SKY_VISIBLE	// If we can see the see the sky, are blocked, or we have a blocked neighbour (SKY_BLOCKED/VISIBLE/VISIBLE_BORDER)
	var/weatherproof = FALSE // If we have a weather overlay

/// Stops this turf lighting the corners it reached, and queues their turfs and this one for a sunlight recount.
/turf/proc/sunlight_disable()
	for(var/datum/lighting_corner/C in sunlight_corners)
		LAZYREMOVE(C.sunlight_objects, src)
		C.get_sunlight_falloff()
		for(var/turf/master in C.masters)
			if(!(master.turf_flags & TURF_SUNLIGHT_QUEUED))
				master.turf_flags |= TURF_SUNLIGHT_QUEUED
				GLOB.SUNLIGHT_QUEUE_CORNER += master
	if(!(turf_flags & TURF_SUNLIGHT_QUEUED))
		turf_flags |= TURF_SUNLIGHT_QUEUED
		GLOB.SUNLIGHT_QUEUE_CORNER += src /* get our calculated indoor lighting */

	//Empty our sunlight_corners list
	sunlight_corners = null

/// Spreads sunlight from a border turf, or stops spreading it when the sky above is blocked.
/turf/proc/sunlight_process_state()
	switch(outdoor_effect.state)
		if(SKY_BLOCKED)
			sunlight_disable() /* Do our indoor processing */
		if(SKY_VISIBLE_BORDER)
			sunlight_spread()

/// Stops this turf taking part in sunlight and weather: frees its corners, drops its look and its state.
/turf/proc/clear_outdoor_effect()
	if(sunlight_corners)
		sunlight_disable()
	set_outdoor_look(null)
	outdoor_effect = null

#define GLOBAL_LIGHT_RANGE 3

#define HARD_SUN 0.5 /* our hyperboloidy modifyer funky times - I wrote this in like, 2020 and can't remember how it works - I think it makes a 3D cone shape with a flat top */
/* calculate the indoor corners we are affecting */
#define SUN_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 - HARD_SUN) / max(1, GLOBAL_LIGHT_RANGE)))

/// Lights the lighting corners in sight of this border turf, with a falloff by distance.
/turf/proc/sunlight_spread()
	var/list/turf/turfs = list()
	var/list/reached_corners = list() /* corners we are currently affecting */

	//Set lum so we can see things
	var/oldLum = luminosity
	luminosity = GLOBAL_LIGHT_RANGE

	for(var/turf/T in view(CEILING(GLOBAL_LIGHT_RANGE, 1), src))
		if(T.opacity) /* get_corners used to do opacity checks for arse */
			continue
		if(!T.lighting_corners_initialised)
			T.lighting_build_overlay()
		if(!length(T.corners))
			continue
		reached_corners |= T.corners
		turfs += T

	//restore lum; lighting_build_overlay() above may have given us a lighting look, so recount it
	luminosity = oldLum
	refresh_luminosity()

	/* fix up the lists */
	/* add ourselves and our distance to the corner */
	LAZYINITLIST(sunlight_corners)
	var/list/L = reached_corners - sunlight_corners
	sunlight_corners += L
	for(var/datum/lighting_corner/C as anything in L)
		LAZYSET(C.sunlight_objects, src, SUN_FALLOFF(C, src))
		if(C.sunlight_objects[src] > C.sunFalloff) /* if are closer than current dist, update the corner */
			C.sunFalloff = C.sunlight_objects[src]
			for(var/turf/master in C.masters)
				if(!(master.turf_flags & TURF_SUNLIGHT_QUEUED))
					master.turf_flags |= TURF_SUNLIGHT_QUEUED
					GLOB.SUNLIGHT_QUEUE_CORNER += master

	L = sunlight_corners - reached_corners // Now-gone corners, remove us from the affecting.
	sunlight_corners -= L
	for(var/datum/lighting_corner/C as anything in L)
		LAZYREMOVE(C.sunlight_objects, src)
		C.get_sunlight_falloff()
		for(var/turf/master in C.masters)
			if(!(master.turf_flags & TURF_SUNLIGHT_QUEUED))
				master.turf_flags |= TURF_SUNLIGHT_QUEUED
				GLOB.SUNLIGHT_QUEUE_CORNER += master

#undef GLOBAL_LIGHT_RANGE
#undef HARD_SUN
#undef SUN_FALLOFF

/* Related object changes */
/* I moved this here to consolidate sunlight changes as much as possible, so its easily disabled */

/* area fuckery */
/area/var/turf/pseudo_roof

/* turf fuckery */
/turf/var/tmp/datum/outdoor_state/outdoor_effect /* a turf's shared sky state; null when the turf takes no part */
/turf/var/tmp/list/datum/lighting_corner/sunlight_corners /* corners a border turf lights */
/turf/var/tmp/is_being_weathered = FALSE // if we're in the weathered_turfs list or not
/turf/var/turf/pseudo_roof /* our roof turf - may be a path for top z level, or a ref to the turf above*/

//non-weatherproof turfs
/turf/var/weatherproof = TRUE
/turf/open/openspace/weatherproof = FALSE

/datum/lighting_corner/var/list/sunlight_objects /* border turfs lighting this corner, each with its falloff */
/datum/lighting_corner/var/sunFalloff = 0 /* smallest distance to sunlight turf, for sunlight falloff */

/* loop through and find our strongest sunlight value */
/datum/lighting_corner/proc/get_sunlight_falloff()
	sunFalloff = 0

	for(var/turf/S as anything in sunlight_objects)
		sunFalloff = sunFalloff < sunlight_objects[S] ? sunlight_objects[S] : sunFalloff

/turf/proc/reassess_stack()
	if(!SSlighting.initialized && !SSoutdoor_effects.initialized)
		return

	/* remove roof refs (not path for psuedo roof) so we can recalculate it */
	if(pseudo_roof && !ispath(pseudo_roof))
		pseudo_roof = null

	var/list/SunlightUpdates = list()

	//Add ourselves (we might not have corners initialized, and this handles it)
	SunlightUpdates += src

	for(var/datum/lighting_corner/corner in corners)
		SunlightUpdates |= corner.masters

	GLOB.SUNLIGHT_QUEUE_WORK += SunlightUpdates

	var/turf/T = GET_TURF_BELOW(src)
	if(T)
		T.reassess_stack()

/* check ourselves and neighbours to see what outdoor effects we need */
/* turf takes no part if sky_blocked and weatherproof */
/turf/proc/update_sky_and_weather_states()
	var/TempState

	var/sky_visible = is_sky_visible()
	var/turf_weatherproof = is_weatherproof()
	if(!sky_visible)/* roofed, so turn off the lights */
		TempState = SKY_BLOCKED
	else
		TempState = SKY_VISIBLE
		for(var/turf/closed/closed_neighbor in orange(1, src)) // use byond's built-in type filtering for speed
			TempState = SKY_VISIBLE_BORDER
			break
		if(TempState != SKY_VISIBLE_BORDER)
			for(var/turf/open/open_neighbor in orange(1, src)) // once again, use orange instead of RANGE_TURFS for the built-in type filtering
				if(!open_neighbor.is_sky_visible()) /* if we have a single roofed/indoor neighbour, we are a border */
					TempState = SKY_VISIBLE_BORDER
					break

	/* if border or indoor, initialize. Set sunlight state if valid */
	if(outdoor_effect || TempState != SKY_BLOCKED || !turf_weatherproof)
		outdoor_effect = SSoutdoor_effects.get_outdoor_state(TempState, turf_weatherproof)
		if(turf_weatherproof) // we're weatherproof so make sure we're not being weathered
			if(turf_flags & TURF_BEING_WEATHERED) // only remove it from the list if we're sure it's already in it
				SSParticleWeather.weathered_turfs -= src
				turf_flags &= ~TURF_BEING_WEATHERED
		else if(SSoutdoor_effects.turf_weather_affectable_z_levels[z]) // not weatherproof, enable weathering if allowed
			turf_flags |= TURF_BEING_WEATHERED
			SSParticleWeather.weathered_turfs += src

/// Do this turf and all the turfs above it in the z-stack allow sunlight through?
/turf/proc/is_sky_visible()
	// rare for this to be true but it overrides everything else
	if (pseudo_roof)
		return FALSE
	var/turf/ceiling = _GET_TURF_ABOVE_UNSAFE(src)
	if(ceiling)
		return ceiling.is_sky_visible_through()
	else
		var/area/turf_area = loc
		if(!turf_area.outdoors)
			return FALSE
	return TRUE

/// Does this turf allow the turf below to see the sky?
/// Equivalent to is_sky_visible(recursionStarted = TRUE) in the old format.
/turf/proc/is_sky_visible_through()
	if(!istransparentturf(src))
		return FALSE
	for(var/obj/structure/thing in src)
		if(thing.weatherproof)
			return FALSE
	return is_sky_visible()

/// Does this turf, or ANY turf in the Z-stack above it, block weather effects?
/turf/proc/is_weatherproof()
	// rare for this to be true
	if (pseudo_roof)
		return TRUE
	var/turf/ceiling = _GET_TURF_ABOVE_UNSAFE(src)
	if(ceiling)
		return ceiling.is_weatherproof_ceiling()
	var/area/turf_area = loc
	return !turf_area.outdoors // if this runtimes because a turf isn't in an area i'll just die

/turf/closed/is_weatherproof() // skip checks for this. refactor if you ever allow closed turfs to let weather through ig
	return TRUE

/// Does this turf block the ones below it from receiving weather effects?
/// Equivalent to is_weatherproof(recursionStarted = TRUE) in the old format.
/turf/proc/is_weatherproof_ceiling()
	// due to the type overrides of this proc we can assume src is never a closed turf
	if(weatherproof) // turf weatherproof only applies for passing weather downwards
		return TRUE
	// not inherently weatherproof
	for(var/obj/structure/thing in src) // check for weather blockers (tent walls, etc)
		if(thing.weatherproof)
			return TRUE
	return is_weatherproof() // check our own roof

/turf/closed/is_weatherproof_ceiling() // ditto, skip checks for this.
	return TRUE

/// Whether weather falls on this turf. Uses the cached outdoor state, so it is cheap.
/turf/proc/is_weather_exposed()
	return outdoor_effect && !outdoor_effect.weatherproof

/// Whether rain is falling on this turf right now.
/turf/proc/is_rained_on()
	var/datum/particle_weather/weather = SSParticleWeather.runningWeather
	if(!weather?.running || weather.target_trait != PARTICLEWEATHER_RAIN)
		return FALSE
	return is_weather_exposed()
