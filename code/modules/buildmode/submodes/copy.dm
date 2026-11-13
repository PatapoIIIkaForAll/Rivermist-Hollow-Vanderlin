/datum/buildmode_mode/copy
	name = "Copy"
	key = "copy"
	var/datum/weakref/stored_ref

/datum/buildmode_mode/copy/Destroy()
	stored_ref = null
	return ..()

/datum/buildmode_mode/copy/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button on obj/turf/mob   = Spawn a Copy of selected target"))
	to_chat(c, span_notice("Right Mouse Button on obj/mob = Select target to copy"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/copy/handle_click(client/c, list/modifiers, atom/object)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/atom/movable/stored = stored_ref?.resolve()
		if(!stored)
			to_chat(c, span_warning("Right click something to copy first."))
			return
		DuplicateObject(stored, perfectcopy = TRUE, sameloc = FALSE, newloc = get_turf(object))
		log_admin("Build Mode: [key_name(c)] copied [stored] to [AREACOORD(object)]")
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(ismovable(object)) // No copying turfs for now.
			to_chat(c, span_notice("[object] set as template."))
			stored_ref = WEAKREF(object)
