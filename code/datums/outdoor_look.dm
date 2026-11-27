/// One shared sunlight and weather picture on one z-level, shown by turfs through vis_contents.
/// Lives in nullspace; only SSoutdoor_effects creates and deletes it.
/atom/movable/outdoor_look
	name = ""
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	plane = WEATHER_EFFECT_PLANE
	/// Number of turfs that show this look now.
	var/users = 0
	/// The cache key, used to drop the cache entry.
	var/look_z
	var/mutable_appearance/look_sunlight
	var/look_weatherproof
	/// TRUE when a newer object took this one's place in the cache because it was full.
	var/retired = FALSE

/atom/movable/outdoor_look/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

// Variety of overrides so the looks don't get affected by weird things.

/atom/movable/outdoor_look/ex_act(severity)
	return 0

/atom/movable/outdoor_look/onTransitZ(turf/old_turf, turf/new_turf)
	return

/atom/movable/outdoor_look/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	return FALSE

/turf/var/tmp/atom/movable/outdoor_look/outdoor_look /* the shared outdoor look we show; null when we have no sky state */

/// Shows new_look on this turf in place of the current outdoor look and updates the use counts.
/// A null new_look removes the picture.
/turf/proc/set_outdoor_look(atom/movable/outdoor_look/new_look)
	var/atom/movable/outdoor_look/old_look = outdoor_look
	if(new_look == old_look)
		return
	if(old_look)
		vis_contents -= old_look
		SSoutdoor_effects.release_outdoor_look(old_look)
	if(new_look)
		vis_contents += new_look
		new_look.users++
	outdoor_look = new_look
	refresh_luminosity()
