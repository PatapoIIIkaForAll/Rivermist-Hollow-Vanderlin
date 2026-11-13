// Scent marks on people and things: grinding rubs a scent in, the mark intent does it on purpose, keen noses notice.

#define GRIND_SCENT_LIFETIME (10 MINUTES)

/// Rubs [marker]'s scent into [target]; returns the name of the scent it covered, if it was someone else's.
/proc/scent_mark(atom/target, mob/living/marker, deliberate = FALSE)
	if(!ismovable(target) || !isliving(marker) || target == marker)
		return null
	var/datum/component/grind_scent/scent = target.GetComponent(/datum/component/grind_scent)
	if(!scent)
		target.AddComponent(/datum/component/grind_scent, marker, deliberate)
		return null
	return scent.refresh(marker, deliberate)

/// Whose scent is rubbed into this, or null.
/atom/proc/get_scent_mark_name()
	var/datum/component/grind_scent/scent = GetComponent(/datum/component/grind_scent)
	return scent?.marker_name

/// TRUE for a mob that can sniff out scents.
/mob/proc/has_keen_nose()
	return !!(locate(/datum/action/cooldown/keen_nose) in actions)

/datum/component/grind_scent
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/weakref/marker_ref
	var/marker_name
	/// TRUE when rubbed in on purpose rather than left by grinding.
	var/deliberate = FALSE
	var/expire_timer

/datum/component/grind_scent/Initialize(mob/living/marker, new_deliberate = FALSE)
	if(!ismovable(parent) || !isliving(marker))
		return COMPONENT_INCOMPATIBLE
	refresh(marker, new_deliberate)

/datum/component/grind_scent/Destroy(force)
	if(expire_timer)
		deltimer(expire_timer)
	marker_ref = null
	return ..()

/datum/component/grind_scent/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/grind_scent/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_COMPONENT_CLEAN_ACT))

/// Takes on [marker]'s scent; a stray grind never covers a scent rubbed in on purpose by someone else.
/datum/component/grind_scent/proc/refresh(mob/living/marker, new_deliberate)
	var/old_name = marker_name
	var/same_marker = marker_ref?.resolve() == marker
	if(!same_marker && deliberate && !new_deliberate)
		return null
	marker_ref = WEAKREF(marker)
	marker_name = marker.name
	deliberate = new_deliberate || (same_marker && deliberate)
	expire_timer = addtimer(CALLBACK(src, PROC_REF(expire)), GRIND_SCENT_LIFETIME, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	return (!same_marker && old_name) ? old_name : null

/datum/component/grind_scent/proc/expire()
	expire_timer = null
	qdel(src)

/datum/component/grind_scent/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!user.has_keen_nose() || marker_ref?.resolve() == user)
		return
	var/atom/marked = parent
	var/line
	if(deliberate)
		line = span_notice("[marker_name]'s scent is rubbed into [marked.p_them()], plain as a claim.")
	else
		line = span_notice("[marked.p_they(TRUE)] smell[marked.p_s()] faintly of [marker_name].")
	// Carbons send examine sections keyed by EXAMINE_SECT_*; everything else sends a flat list.
	if(iscarbon(marked))
		LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_BODY, line)
	else
		examine_list += line

/datum/component/grind_scent/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	if(clean_types & CLEAN_TYPE_BLOOD)
		qdel(src)

#undef GRIND_SCENT_LIFETIME
