/**
 * Admin hotkeys that act on whatever is under the mouse cursor.
 *
 * Alt + B : View Variables of the hovered atom (the top object under the cursor, or the turf).
 */

/client
	/// What this admin's cursor last hovered on the map. Only tracked for admins.
	var/datum/weakref/admin_hovered_ref

/// Called from /atom/proc/on_mouse_enter() for admins.
/client/proc/track_admin_hover(atom/hovered)
	if(istype(hovered, /atom/movable/screen))
		return
	admin_hovered_ref = WEAKREF(hovered)

/datum/keybinding/admin/view_variables_hovered
	hotkey_keys = list("AltB")
	classic_keys = list("AltB")
	name = "view_variables_hovered"
	full_name = "View Variables of hovered object"
	description = "Opens View Variables on whatever the mouse cursor is over."

/datum/keybinding/admin/view_variables_hovered/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/atom/hovered = user.admin_hovered_ref?.resolve()
	if(QDELETED(hovered))
		hovered = target
	hovered = admin_vv_pick(hovered)
	if(!hovered)
		to_chat(user, span_warning("Point the cursor at something on the map first."))
		return TRUE
	user.debug_variables(hovered)
	return TRUE

/// What Alt + B opens: the hovered mob or object, never an effect or helper drawn on top of it.
/// If an effect was hovered, the first mob, then object, then the turf on its tile is used instead.
/proc/admin_vv_pick(atom/hovered)
	if(QDELETED(hovered))
		return null
	if(ismob(hovered) || (isobj(hovered) && !istype(hovered, /obj/effect)) || isturf(hovered))
		return hovered
	var/turf/spot = get_turf(hovered)
	if(!spot)
		return hovered
	for(var/mob/living/creature in spot)
		return creature
	for(var/obj/thing in spot)
		if(!istype(thing, /obj/effect) && thing.invisibility < INVISIBILITY_ABSTRACT)
			return thing
	return spot
