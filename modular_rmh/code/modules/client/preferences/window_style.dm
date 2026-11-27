#define WINDOW_STYLE_VANDERLIN "Vanderlin"
#define WINDOW_STYLE_VANDERLIN_CLASSIC "Vanderlin classic"

/// Look of tgui windows that use the house theme or no theme of their own.
/datum/preference/choiced/window_style
	savefile_key = "window_style"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	toggles_menu_category = "Interface"
	toggles_menu_name = "Window style"
	toggles_menu_desc = "Vanderlin: warm gradients and soft glows. Vanderlin classic: the old flat panels. Windows with their own look keep it."

/datum/preference/choiced/window_style/init_possible_values(datum/preferences/prefs)
	return list(WINDOW_STYLE_VANDERLIN, WINDOW_STYLE_VANDERLIN_CLASSIC)

/datum/preference/choiced/window_style/create_default_value(datum/preferences/prefs)
	return WINDOW_STYLE_VANDERLIN

/datum/preference/choiced/window_style/apply_to_client_updated(client/C, value)
	. = ..()
	// Open windows take the new style on this push; new ones read it from their config.
	if(C?.mob)
		INVOKE_ASYNC(SStgui, TYPE_PROC_REF(/datum/controller/subsystem/tgui, update_user_uis), C.mob)

/// tgui theme for windows that ask for the house theme or none; sent in every window config.
/proc/get_tgui_window_theme(datum/preferences/prefs)
	if(prefs?.read_preference(/datum/preference/choiced/window_style) == WINDOW_STYLE_VANDERLIN_CLASSIC)
		return "vanderlin-classic"
	return "vanderlin"

#undef WINDOW_STYLE_VANDERLIN
#undef WINDOW_STYLE_VANDERLIN_CLASSIC
