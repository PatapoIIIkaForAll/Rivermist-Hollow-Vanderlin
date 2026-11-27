/// Holds the gold-quality sparkle; its relay is hidden for players with the Quality glint toggle off.
/atom/movable/screen/plane_master/quality_glint
	name = "quality glint plane master"
	plane = QUALITY_GLINT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_plane = GAME_PLANE
	// Just under the field-of-view plane, like the sparkles drawn there before.
	render_relay_layer = MOB_LAYER - 0.01

/atom/movable/screen/plane_master/quality_glint/backdrop(mob/mymob)
	. = ..()
	clear_filters()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = FIELD_OF_VISION_MASK_RENDER_TARGET, flags = MASK_INVERSE))
	if(relay)
		relay.alpha = quality_glint_shown(mymob) ? 255 : 0

/// Whether this viewer wants the quality sparkle; no preferences means shown.
/proc/quality_glint_shown(mob/viewer)
	var/datum/preferences/prefs = viewer?.client?.prefs
	if(!prefs)
		return TRUE
	return !!prefs.read_preference(/datum/preference/toggle/quality_glint)

/// Shows or hides the quality sparkle on this viewer's screen.
/proc/update_quality_glint_plane(mob/viewer)
	var/atom/movable/screen/plane_master/glint_plane = viewer?.hud_used?.plane_masters["[QUALITY_GLINT_PLANE]"]
	glint_plane?.backdrop(viewer)
