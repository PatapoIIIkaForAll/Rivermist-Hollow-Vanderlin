/datum/buildmode_mode/basic
	name = "Basic"
	key = "basic"
	uses_selection = TRUE
	pixel_placement = TRUE

/datum/buildmode_mode/basic/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Catalogue button (grid)          = Pick what to place, and pick a tool"))
	to_chat(c, span_notice("Left click                       = Use the tool picked in the catalogue (Place by default)"))
	to_chat(c, span_notice("Shift + left click               = Place at the exact pixel under the cursor"))
	to_chat(c, span_notice("Middle button drag               = Paint the rectangle with the selection"))
	to_chat(c, span_notice("Ctrl + middle button drag        = Erase objects in the rectangle"))
	to_chat(c, span_notice("                                   (also a left drag with Delete, or Ctrl + left drag with Paint area)"))
	to_chat(c, span_notice("Ctrl + left click on an object   = Copy it exactly, variables included"))
	to_chat(c, span_notice("Alt + left click                 = Pick the type of what you clicked"))
	to_chat(c, span_notice("Right click                      = Clear the selection; with nothing selected, delete"))
	to_chat(c, span_notice("                                   (the Tools panel can lock this; Ctrl + right click still deletes)"))
	to_chat(c, span_notice("Ctrl + right click               = Delete the object, or strip the top turf layer"))
	to_chat(c, span_notice("Alt + right click                = Rotate the build direction"))
	to_chat(c, span_notice("Right click on buildmode button  = Select by typepath"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/basic/change_settings(client/c)
	prompt_for_type(c)

/datum/buildmode_mode/basic/handle_click(client/c, list/modifiers, atom/object)
	BM.handle_tool_click(c, modifiers, object)
