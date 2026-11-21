/datum/erp_preference
	abstract_type = /datum/erp_preference
	/// User facing name of the preference
	var/name = "ERP Preference"
	/// Description shown to the user
	var/description = ""
	/// Whether this preference is enabled by default
	var/default_value = FALSE
	/// Category for organization in menus
	var/category = "General"
	/// Belongs to character creation; cannot change once the character has spawned.
	var/locked_after_spawn = FALSE

/datum/erp_preference/proc/get_value(datum/preferences/prefs)
	return get_value_from_list(prefs?.ensure_erp_preferences())

/datum/erp_preference/proc/get_value_from_list(list/stored_preferences)
	var/stored_value = stored_preferences?[type]
	if(isnull(stored_value))
		return get_default_value()
	return stored_value

/datum/erp_preference/proc/get_default_value()
	return default_value

/datum/erp_preference/proc/set_value(datum/preferences/prefs, value)
	if(!prefs)
		return
	var/list/stored_preferences = prefs.ensure_erp_preferences()
	stored_preferences[type] = value
	prefs.mark_erp_preferences_dirty()

/datum/erp_preference/proc/show_pref_ui(datum/preferences/prefs, lock_reason = null)
	return

/datum/erp_preference/proc/get_tooltip_attribute(tooltip_text)
	if(!tooltip_text)
		return ""
	return " title='[escape_html_attribute(tooltip_text)]'"

/datum/erp_preference/proc/wrap_with_tooltip(content, tooltip_text)
	var/tooltip_attr = get_tooltip_attribute(tooltip_text)
	if(!tooltip_attr)
		return content
	return "<span[tooltip_attr]>[content]</span>"

/// Why this preference cannot change right now, or null when it can.
/datum/erp_preference/proc/get_edit_lock_reason(mob/user, datum/preferences/prefs)
	if(locked_after_spawn && prefs?.is_erp_spawn_locked(user))
		return "[name] is set in character creation and cannot change after spawning."
	return prefs?.get_erp_preference_edit_lock_reason(user)

/datum/erp_preference/proc/ensure_editable(mob/user, datum/preferences/prefs)
	var/lock_reason = get_edit_lock_reason(user, prefs)
	if(!lock_reason)
		return TRUE
	if(user)
		to_chat(user, span_warning(lock_reason))
	return FALSE

/datum/erp_preference/proc/handle_topic(mob/user, list/href_list, datum/preferences/prefs)
	return

