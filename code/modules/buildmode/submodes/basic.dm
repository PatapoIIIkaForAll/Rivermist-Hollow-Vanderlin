/datum/buildmode_mode/basic
	name = "Basic"
	key = "basic"
	uses_selection = TRUE
	pixel_placement = TRUE

/datum/buildmode_mode/basic/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Item Browser button (grid)             = Pick what to place"))
	to_chat(c, span_notice("Left Mouse Button                      = Place the selection"))
	to_chat(c, span_notice("Hold Shift + Left Mouse Button         = Place at the exact pixel under the cursor"))
	to_chat(c, span_notice("Right Mouse Button                     = Clear the selection"))
	to_chat(c, span_notice("Right Mouse Button on buildmode button = Select by typepath"))
	to_chat(c, "")
	to_chat(c, span_notice("Use the direction button to change the direction of built objects."))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/basic/change_settings(client/c)
	prompt_for_type(c)

/datum/buildmode_mode/basic/handle_click(client/c, list/modifiers, atom/object)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		BM.clear_selection()
		return
	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		return
	if(!BM.selected_item)
		to_chat(c, span_warning("Pick something in the item browser first."))
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICKED))
		var/list/cursor = BM.resolve_cursor(modifiers)
		if(cursor)
			BM.place_selected(cursor[1], c.mob, cursor[2], cursor[3])
			return
	BM.place_selected(get_turf(object), c.mob)
