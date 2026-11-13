/datum/buildmode_mode/throwing
	name = "Throw"
	key = "throw"
	var/datum/weakref/throw_ref

/datum/buildmode_mode/throwing/Destroy()
	throw_ref = null
	return ..()

/datum/buildmode_mode/throwing/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button on turf/obj/mob      = Select"))
	to_chat(c, span_notice("Right Mouse Button on turf/obj/mob     = Throw"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/throwing/handle_click(client/c, list/modifiers, atom/object)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(!ismovable(object))
			return
		throw_ref = WEAKREF(object)
		to_chat(c, span_notice("Selected object '[object]'"))
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/atom/movable/throw_atom = throw_ref?.resolve()
		if(!throw_atom)
			return
		throw_atom.throw_at(object, 10, 1, c.mob)
		log_admin("Build Mode: [key_name(c)] threw [throw_atom] at [object] ([AREACOORD(object)])")
