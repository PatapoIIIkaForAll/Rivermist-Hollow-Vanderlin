/turf
	var/dynamic_lighting = TRUE
	luminosity           = 1

	var/tmp/lighting_corners_initialised = FALSE

	var/tmp/list/datum/light_source/affecting_lights       // List of light sources affecting this turf.
	var/tmp/atom/movable/lighting_look/lighting_look // The shared lighting look we show; null when we have no dynamic lighting.
	var/tmp/list/datum/lighting_corner/corners
	var/tmp/has_opaque_atom = FALSE // Not to be confused with opacity, this will be TRUE if there's any opaque atom on the tile.

// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	for (var/datum/light_source/L as anything in affecting_lights)
		L.vis_update()

/turf/proc/lighting_clear_overlay()
	if (lighting_look)
		set_lighting_look(null)

	var/datum/lighting_corner/C
	var/thing
	for (thing in corners)
		if(!thing)
			continue
		C = thing
		C.update_active()

// Gives us a lighting look, but only if our area is dynamic.
/turf/proc/lighting_build_overlay()
	var/area/A = loc
	if (!IS_DYNAMIC_LIGHTING(A) && !light_sources)
		if (lighting_look)
			lighting_clear_overlay()
		return

	if (!lighting_corners_initialised)
		generate_missing_corners()

	if (!lighting_look)
		set_lighting_look(SSlighting.get_look(z, 0, 0, 0, 0))

	for(var/datum/lighting_corner/C as anything in corners)
		if(!C)
			continue
		if(!C.active) // We would activate the corner, calculate the lighting for it.
			for(var/datum/light_source/S in C.affecting)
				S.recalc_corner(C)
			C.active = TRUE

	queue_lighting_update()

/// Queues this turf for SSlighting to pick its lighting look again.
/turf/proc/queue_lighting_update()
	if (lighting_look && !(turf_flags & TURF_LIGHTING_QUEUED))
		turf_flags |= TURF_LIGHTING_QUEUED
		SSlighting.turf_queue += src

/// Picks the lighting look that matches our four corners and shows it.
/turf/proc/update_lighting_look()
	turf_flags &= ~TURF_LIGHTING_QUEUED
	if (!lighting_look)
		return

	var/a = 0
	var/b = 0
	var/c = 0
	var/d = 0
	var/list/our_corners = corners
	if (our_corners)
		var/datum/lighting_corner/corner = our_corners[3]
		if (corner)
			a = corner.cache_id
		corner = our_corners[2]
		if (corner)
			b = corner.cache_id
		corner = our_corners[4]
		if (corner)
			c = corner.cache_id
		corner = our_corners[1]
		if (corner)
			d = corner.cache_id

	set_lighting_look(SSlighting.get_look(z, a, b, c, d))

/// Shows new_look on this turf in place of the current look and updates the use counts.
/// A null new_look turns lighting off here.
/turf/proc/set_lighting_look(atom/movable/lighting_look/new_look)
	var/atom/movable/lighting_look/old_look = lighting_look
	if (new_look == old_look)
		return
	if (old_look)
		vis_contents -= old_look
		SSlighting.release_look(old_look)
	if (new_look)
		vis_contents += new_look
		new_look.users++
	lighting_look = new_look
	refresh_luminosity()

/// Sets our luminosity: lit when we have no dynamic lighting, when our lighting look is lit, or when the sky lights us.
/turf/proc/refresh_luminosity()
	var/new_luminosity = (!lighting_look || lighting_look.luminosity || outdoor_look?.luminosity) ? 1 : 0
	if(luminosity != new_luminosity)
		luminosity = new_luminosity

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	if (!lighting_look)
		return 1

	var/totallums = 0
	var/thing
	var/datum/lighting_corner/L
	var/totalSunFalloff
	for (thing in corners)
		if(!thing)
			continue
		L = thing
		totallums += L.lum_r + L.lum_b + L.lum_g
		totalSunFalloff += L.sunFalloff

	if(outdoor_effect && outdoor_effect.state)
		totalSunFalloff = 4

	totallums += totalSunFalloff / 4

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums = (totallums - minlum) / (maxlum - minlum)
	totallums += dynamic_lumcount

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	if (!lighting_look)
		return FALSE

	return !lighting_look.luminosity

// Can't think of a good name, this proc will recalculate the has_opaque_atom variable.
/turf/proc/recalc_atom_opacity()
	has_opaque_atom = opacity
	if (!has_opaque_atom)
		for (var/atom/A in src.contents) // Loop through every movable atom on our tile PLUS ourselves (we matter too...)
			if (A.opacity)
				has_opaque_atom = TRUE
				break

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if (Obj && Obj.opacity)
		recalc_atom_opacity() // Make sure to do this before reconsider_lights(), incase we're on instant updates.
		reconsider_lights()

/turf/proc/change_area(area/old_area, area/new_area)
	GLOB.SUNLIGHT_QUEUE_WORK += src
	if(outdoor_effect)
		GLOB.SUNLIGHT_QUEUE_UPDATE += src
	if(SSlighting.initialized)
		if (new_area.dynamic_lighting != old_area.dynamic_lighting)
			if (new_area.dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

	//move the turf
	LISTASSERTLEN(old_area.turfs_to_uncontain_by_zlevel, z, list())
	LISTASSERTLEN(new_area.turfs_by_zlevel, z, list())
	old_area.turfs_to_uncontain_by_zlevel[z] += src
	new_area.turfs_by_zlevel[z] += src
	new_area.contents += src

/turf/proc/get_corners()
	if (!IS_DYNAMIC_LIGHTING(src) && !light_sources)
		return null
	if (!lighting_corners_initialised)
		generate_missing_corners()
	if (has_opaque_atom)
		return null // Since this proc gets used in a for loop, null won't be looped though.

	return corners

/turf/proc/generate_missing_corners()
	if (!IS_DYNAMIC_LIGHTING(src) && !light_sources)
		return
	lighting_corners_initialised = TRUE
	if (!corners)
		corners = list(null, null, null, null)

	for (var/i = 1 to 4)
		if (corners[i]) // Already have a corner on this direction.
			continue

		corners[i] = new/datum/lighting_corner(src, GLOB.LIGHTING_CORNER_DIAGONAL[i])

