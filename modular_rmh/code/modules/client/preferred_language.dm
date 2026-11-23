/client
	var/preferred_ui_language = "en"

/proc/sanitize_preferred_ui_language(language)
	var/selected_language = LOWER_TEXT("[language || "en"]")
	if(!(selected_language in list("en", "ru")))
		return "en"
	return selected_language

/proc/get_preferred_ui_language(mob/user)
	var/client/user_client = user?.client
	return sanitize_preferred_ui_language(user_client?.preferred_ui_language)

/client/verb/change_prefered_language()
	set name = "Change Preferred Language"
	set category = "OOC"
	set desc = "Change your preferred UI language for multilingual interfaces."

	var/list/language_choices = list(
		"English" = "en",
		"Russian" = "ru",
	)
	var/current_language = preferred_ui_language
	if(!(current_language in list("en", "ru")))
		current_language = "en"

	var/selection = input(src, "Choose your preferred UI language.", "Preferred Language", current_language == "ru" ? "Russian" : "English") as null|anything in language_choices
	if(!selection)
		return

	set_preferred_ui_language(language_choices[selection])
	prefs?.save_preferences()
	to_chat(src, span_notice("Preferred UI language set to [selection]. Reopen interfaces to apply it."))

/// Game UI language is independent of Character Creator; refresh active readers.
/client/proc/set_preferred_ui_language(language, refresh = TRUE)
	preferred_ui_language = sanitize_preferred_ui_language(language)
	if(refresh)
		SStgui.update_user_uis(mob)
		rmh_scom_reader?.send_publication()
	if(preferred_ui_language == "ru")
		to_chat(src, span_notice("Команда Chat Translation во вкладке OOC включает машинный перевод сообщений с других языков."))
	else
		to_chat(src, span_notice("The Chat Translation verb in the OOC tab machine-translates chat written in other languages."))
