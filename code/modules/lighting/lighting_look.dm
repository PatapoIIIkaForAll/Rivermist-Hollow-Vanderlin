/// One shared lighting appearance on one z-level, shown by turfs through vis_contents.
/// Lives in nullspace; only SSlighting creates and deletes it.
/atom/movable/lighting_look
	name = ""
	anchored = TRUE
	icon = LIGHTING_ICON
	icon_state = null
	plane = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	luminosity = 1
	/// Number of turfs that show this look now.
	var/users = 0
	/// The cache key: z-level and the four corner ids. Used to drop the cache entry.
	var/look_z
	var/look_a
	var/look_b
	var/look_c
	var/look_d
	/// TRUE when a newer object took this one's place in the cache because it was full.
	var/retired = FALSE
	/// TRUE while this look is in SSlighting.idle_looks.
	var/idle = FALSE

/atom/movable/lighting_look/Destroy(force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	return ..()

// Variety of overrides so the looks don't get affected by weird things.

/atom/movable/lighting_look/ex_act(severity)
	return 0

/atom/movable/lighting_look/onTransitZ(turf/old_turf, turf/new_turf)
	return

/atom/movable/lighting_look/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	return FALSE
