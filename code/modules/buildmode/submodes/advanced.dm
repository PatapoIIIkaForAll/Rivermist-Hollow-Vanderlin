/datum/buildmode_mode/advanced
	name = "Advanced"
	key = "advanced"
	uses_selection = TRUE

/datum/buildmode_mode/advanced/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Right Mouse Button on buildmode button = Select by typepath"))
	to_chat(c, span_notice("Left Mouse Button + alt on turf/obj    = Copy object type"))
	to_chat(c, span_notice("Left Mouse Button on turf/obj          = Place objects"))
	to_chat(c, span_notice("Right Mouse Button                     = Delete objects"))
	to_chat(c, "")
	to_chat(c, span_notice("The item browser selection is shared with this mode."))
	to_chat(c, span_notice("Use the direction button to change the direction of built objects."))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/advanced/change_settings(client/c)
	prompt_for_type(c)

/datum/buildmode_mode/advanced/handle_click(client/c, list/modifiers, atom/object)
	if(LAZYACCESS(modifiers, LEFT_CLICK) && LAZYACCESS(modifiers, ALT_CLICKED))
		if(isturf(object) || isobj(object) || ismob(object))
			BM.select_item(object.type)
		else
			to_chat(c, span_notice("[object] is not a turf, object, or mob! Please select again."))
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(!BM.selected_item)
			to_chat(c, span_warning("Select object type first."))
			return
		BM.place_selected(get_turf(object), c.mob)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && isobj(object))
		log_admin("Build Mode: [key_name(c)] deleted [object] at [AREACOORD(object)]")
		qdel(object)
