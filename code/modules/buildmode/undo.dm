/**
 * Build mode undo: the last BM_UNDO_STEPS placements, paints, erases and deletions can be undone
 * (Ctrl + Z, or the Undo button in the catalogue).
 *
 * Placed objects are deleted on undo; changed turfs get their previous type back. Deleted objects
 * are not destroyed at once: they wait in nullspace while their step can still be undone, and are
 * destroyed for good when the step falls off the stack or the admin leaves build mode.
 * Mobs removed by an area erase cannot be brought back.
 *
 * Each action records into its own step, handed from begin_undo() to end_undo(), so an action that
 * sleeps (a constructor, a long paint spread over ticks) never mixes with the next one.
 *
 * Tracked objects are watched with COMSIG_PARENT_QDELETING. A plain reference would turn every
 * object deleted by something else while its step waits (food eaten, a torch burning out in
 * nullspace) into a hard delete, and a weakref mints a REF() text per object: a big paint mints
 * thousands of them in creation order, which makes BYOND stop and re-sort its whole string table.
 */

#define BM_UNDO_STEPS 20
/// Deleted objects one step keeps for undo. Past this they are destroyed at once: a huge erase
/// must not leave thousands of objects (some still processing) waiting in nullspace.
#define BM_UNDO_TRASH_LIMIT 300

/datum/buildmode_undo
	var/label
	/// What this step created and is still in the world.
	var/list/created = list()
	/// list(turf, previous turf type), oldest first.
	var/list/turf_changes = list()
	/// Objects this step removed: object -> turf it was on.
	var/list/trashed = list()
	/// TRUE when some deletions of this step could not be kept for undo.
	var/partial = FALSE

/datum/buildmode_undo/New(label)
	src.label = label

/datum/buildmode_undo/Destroy(force)
	// The parent unregisters every signal this step still listens to.
	created = null
	turf_changes = null
	trashed = null
	return ..()

/datum/buildmode_undo/proc/is_empty()
	return !length(created) && !length(turf_changes) && !length(trashed)

/datum/buildmode_undo/proc/note_created(atom/movable/thing)
	created += thing
	RegisterSignal(thing, COMSIG_PARENT_QDELETING, PROC_REF(on_tracked_deleted), override = TRUE)

/datum/buildmode_undo/proc/note_turf(turf/target)
	turf_changes += list(list(target, target.type))

/// Takes thing out of the world so this step can bring it back. FALSE when the step is full.
/datum/buildmode_undo/proc/trash(atom/movable/thing)
	if(length(trashed) >= BM_UNDO_TRASH_LIMIT)
		partial = TRUE
		return FALSE
	trashed[thing] = get_turf(thing)
	RegisterSignal(thing, COMSIG_PARENT_QDELETING, PROC_REF(on_tracked_deleted), override = TRUE)
	thing.moveToNullspace()
	return TRUE

/// Something else deleted a tracked object: there is nothing left to undo for it.
/datum/buildmode_undo/proc/on_tracked_deleted(atom/movable/source)
	SIGNAL_HANDLER
	created -= source
	trashed -= source

/// Destroys what this step kept aside, then the step itself: called when it can no longer be undone.
/datum/buildmode_undo/proc/expire()
	var/list/kept = trashed
	trashed = list()
	for(var/atom/movable/thing as anything in kept)
		UnregisterSignal(thing, COMSIG_PARENT_QDELETING) // or every qdel below rescans the list
		if(QDELETED(thing))
			continue
		// In nullspace a container would dump its contents into nullspace, where they would stay.
		for(var/atom/movable/content as anything in thing.contents)
			qdel(content)
		qdel(thing)
	qdel(src)

/// Reverts the step. Returns how many changes were reverted. The caller deletes the step.
/datum/buildmode_undo/proc/undo()
	var/restored = 0
	var/list/made = created
	created = list()
	for(var/atom/movable/thing as anything in made)
		UnregisterSignal(thing, COMSIG_PARENT_QDELETING)
		if(!QDELETED(thing))
			qdel(thing)
			restored++
	for(var/index in length(turf_changes) to 1 step -1)
		var/list/change = turf_changes[index]
		var/turf/target = change[1]
		if(target)
			target.ChangeTurf(change[2])
			restored++
	turf_changes.Cut()
	var/list/kept = trashed
	trashed = list()
	for(var/atom/movable/thing as anything in kept)
		UnregisterSignal(thing, COMSIG_PARENT_QDELETING)
		if(QDELETED(thing))
			continue
		var/turf/home = kept[thing]
		if(home)
			thing.forceMove(home)
			restored++
		else // nowhere to go back to: do not leave it, or its contents, in nullspace
			for(var/atom/movable/content as anything in thing.contents)
				qdel(content)
			qdel(thing)
	return restored

/datum/buildmode
	/// Undo steps, newest last.
	var/list/undo_stack = list()

/// Starts an undo step for one action. Record what the action does on the returned step, then pass it to end_undo().
/datum/buildmode/proc/begin_undo(label)
	return new /datum/buildmode_undo(label)

/// Files a finished step. Empty steps, and steps finished after the admin left build mode, are dropped.
/datum/buildmode/proc/end_undo(datum/buildmode_undo/step)
	if(!step)
		return
	if(QDELETED(src) || step.is_empty())
		step.expire()
		return
	undo_stack += step
	while(length(undo_stack) > BM_UNDO_STEPS)
		var/datum/buildmode_undo/oldest = undo_stack[1]
		undo_stack.Cut(1, 2)
		oldest.expire()
	item_browser?.send_selection()

/// Removes thing so that step can bring it back. Mobs, and objects past the step's limit, are deleted for good.
/// A container with a mob inside is deleted on its tile too, so it drops them there instead of taking them to nullspace.
/datum/buildmode/proc/undoable_delete(atom/movable/thing, datum/buildmode_undo/step)
	if(!step || ismob(thing) || (locate(/mob) in thing.get_all_contents()) || !step.trash(thing))
		qdel(thing)

/datum/buildmode/proc/undo_last()
	if(!length(undo_stack))
		item_browser?.set_status("Nothing to undo.")
		return FALSE
	var/datum/buildmode_undo/step = undo_stack[length(undo_stack)]
	undo_stack.len--
	var/restored = step.undo()
	log_admin("Build Mode: [key_name(holder)] undid \"[step.label]\" ([restored] changes).")
	item_browser?.set_status("Undone: [step.label].[step.partial ? " Only the first [BM_UNDO_TRASH_LIMIT] deleted objects could be restored." : ""]")
	qdel(step)
	return TRUE

/datum/buildmode/proc/undo_label()
	if(!length(undo_stack))
		return null
	var/datum/buildmode_undo/step = undo_stack[length(undo_stack)]
	return step.label

/datum/buildmode/proc/clear_undo()
	var/list/steps = undo_stack
	undo_stack = list()
	for(var/datum/buildmode_undo/step as anything in steps)
		step.expire()

#undef BM_UNDO_STEPS
#undef BM_UNDO_TRASH_LIMIT
