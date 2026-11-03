/datum/preference/choiced/ui_language
	savefile_key = "ui_language"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/ui_language/init_possible_values(datum/preferences/prefs)
	return list("en", "ru")

/datum/preference/choiced/ui_language/create_default_value(datum/preferences/prefs)
	return "en"

/datum/preference/choiced/ui_language/apply_to_client(client/C, value)
	C?.tgui_panel?.localization_send_config()

/datum/preferences/preference_load_from_savefile(savefile/S, identifier)
	if(identifier == PREF_PLAYER && S)
		var/stored
		S["ui_language"] >> stored
		if(isnull(stored))
			var/old_client_language
			var/old_creator_language
			S["preferred_ui_language"] >> old_client_language
			S["character_creator_lang"] >> old_creator_language
			if(old_client_language == "ru" || old_creator_language == "ru")
				WRITE_FILE(S["ui_language"], "ru")
	return ..()

/datum/preferences/proc/set_ui_language(language)
	if(!update_preference(GLOB.preference_entries[/datum/preference/choiced/ui_language], sanitize_preferred_ui_language(language)))
		return FALSE
	save_preferences()
	if(parent?.mob)
		SStgui.update_user_uis(parent.mob)
	return TRUE

/proc/sanitize_preferred_ui_language(language)
	var/selected_language = LOWER_TEXT("[language || "en"]")
	if(!(selected_language in list("en", "ru")))
		return "en"
	return selected_language

/proc/get_client_ui_language(client/target)
	if(!target?.prefs)
		return "en"
	return sanitize_preferred_ui_language(target.prefs.read_preference(/datum/preference/choiced/ui_language))

/proc/get_preferred_ui_language(mob/user)
	return get_client_ui_language(user?.client)

/client/verb/change_prefered_language()
	set name = "Change Preferred Language"
	set category = "OOC"
	set desc = "Язык интерфейса, чата и осмотра (RU/EN) / Interface, chat and examine language (RU/EN)."

	if(!prefs)
		return
	var/list/language_choices = list(
		"English" = "en",
		"Русский" = "ru",
	)
	var/current_language = get_client_ui_language(src)
	var/selection = input(src, "Язык интерфейса / Interface language", "Language", current_language == "ru" ? "Русский" : "English") as null|anything in language_choices
	if(!selection || !prefs)
		return
	prefs.set_ui_language(language_choices[selection])
	if(language_choices[selection] == "ru")
		to_chat(src, span_notice("Язык: русский. Окна, открытые на другом языке, переключатся, когда вы откроете их снова."))
	else
		to_chat(src, span_notice("Language: English. Windows open in another language switch when you reopen them."))

#include "..\..\..\modular\localization\code\localization.dm"
