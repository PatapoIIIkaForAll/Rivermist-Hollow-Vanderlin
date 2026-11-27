// Toggles whose live effect sits in a verb or in the character setup handler run that code from the Toggles window.

/datum/preference/toggle/crt/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent)
		return ..()
	prefs.parent.crtmode()
	return TRUE

/datum/preference/toggle/anonymize/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent)
		return ..()
	prefs.parent.anonymize()
	return TRUE

/datum/preference/toggle/breast_animation/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent)
		return ..()
	prefs.parent.toggle_breast_animation()
	return TRUE

/datum/preference/toggle/speech_moans/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent)
		return ..()
	prefs.parent.toggle_speech_moans()
	return TRUE

/datum/preference/toggle/role_calls/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent?.mob)
		return ..()
	prefs.toggle_role_calls(prefs.parent.mob)
	return TRUE

/datum/preference/toggle/admin_new_menu/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent)
		return ..()
	prefs.parent.toggle_admin_menu_mode()
	return TRUE

/datum/preference/toggle/admin_classic_context_menu/toggles_menu_toggle(datum/preferences/prefs)
	if(!prefs.parent)
		return ..()
	prefs.parent.toggle_admin_context_menu_mode()
	return TRUE

/// Runs the character setup Settings handler for this row, which toggles, saves and applies it.
/datum/preference/toggle/proc/toggles_menu_setup_link(datum/preferences/prefs, action)
	if(!prefs.parent?.mob)
		return toggles_menu_write(prefs, !prefs.read_preference(type))
	prefs.process_native_preference_link(prefs.parent.mob, list("preference" = action))
	return TRUE

/datum/preference/toggle/hotkeys/toggles_menu_toggle(datum/preferences/prefs)
	return toggles_menu_setup_link(prefs, "hotkeys")

/datum/preference/toggle/ambientocclusion/toggles_menu_toggle(datum/preferences/prefs)
	return toggles_menu_setup_link(prefs, "ambientocclusion")

/datum/preference/toggle/auto_fit_viewport/toggles_menu_toggle(datum/preferences/prefs)
	return toggles_menu_setup_link(prefs, "auto_fit_viewport")
