/datum/buildmode_mode/varedit
	name = "Var Edit"
	key = "edit"
	var/varholder = null
	var/valueholder = null

/datum/buildmode_mode/varedit/Destroy()
	varholder = null
	valueholder = null
	return ..()

/datum/buildmode_mode/varedit/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Right Mouse Button on buildmode button = Select var(type) & value"))
	to_chat(c, span_notice("Left Mouse Button on turf/obj/mob      = Set var(type) & value"))
	to_chat(c, span_notice("Right Mouse Button on turf/obj/mob     = Reset var's value"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/varedit/change_settings(client/c)
	var/new_var = input(c, "Enter variable name:", "Name", "name") as null|text
	// Check before storing, or a refused name would still be applied on click.
	if(!new_var || !vv_varname_lockcheck(new_var))
		return
	var/temp_value = c.vv_get_value()
	if(isnull(temp_value["class"]) || QDELETED(src))
		to_chat(c, span_notice("Variable unset."))
		return
	varholder = new_var
	valueholder = temp_value["value"]

/datum/buildmode_mode/varedit/handle_click(client/c, list/modifiers, atom/object)
	if(isnull(varholder))
		to_chat(c, span_warning("Choose a variable to modify first."))
		return
	if(!object.vars.Find(varholder))
		to_chat(c, span_warning("[initial(object.name)] does not have a var called '[varholder]'"))
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(object.vv_edit_var(varholder, valueholder) == FALSE)
			to_chat(c, span_warning("My edit was rejected by the object."))
			return
		log_admin("Build Mode: [key_name(c)] modified [object.name]'s [varholder] to [valueholder]")
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/reset_value = initial(object.vars[varholder])
		if(object.vv_edit_var(varholder, reset_value) == FALSE)
			to_chat(c, span_warning("My edit was rejected by the object."))
			return
		log_admin("Build Mode: [key_name(c)] modified [object.name]'s [varholder] to [reset_value]")
