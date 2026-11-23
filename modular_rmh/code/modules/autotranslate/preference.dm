/// Opt-in: each reader with this on adds backend work for every line in the other language.
/datum/preference/choiced/autotranslate_target
	savefile_key = "autotranslate_target"
	savefile_identifier = PREF_PLAYER
	category = "chat"
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/autotranslate_target/init_possible_values(datum/preferences/prefs)
	return list(AUTOTRANSLATE_PREF_OFF, AUTOTRANSLATE_PREF_ENGLISH, AUTOTRANSLATE_PREF_RUSSIAN)

/datum/preference/choiced/autotranslate_target/create_default_value(datum/preferences/prefs)
	return AUTOTRANSLATE_PREF_OFF

/datum/preference/choiced/autotranslate_target/apply_to_client(client/player, value)
	player?.autotranslate_target = autotranslate_pref_to_target(value)

/proc/autotranslate_pref_to_target(value)
	switch(value)
		if(AUTOTRANSLATE_PREF_ENGLISH)
			return AUTOTRANSLATE_LANG_EN
		if(AUTOTRANSLATE_PREF_RUSSIAN)
			return AUTOTRANSLATE_LANG_RU
	return AUTOTRANSLATE_TARGET_NONE

/client
	/// "en", "ru" or AUTOTRANSLATE_TARGET_NONE. Null until the preference is first read.
	var/autotranslate_target

/client/proc/read_autotranslate_target()
	if(!prefs)
		return AUTOTRANSLATE_TARGET_NONE
	autotranslate_target = autotranslate_pref_to_target(prefs.read_preference(/datum/preference/choiced/autotranslate_target))
	return autotranslate_target

// The dialog shows both languages, because a reader who needs it may not read English.
/client/verb/change_chat_translation()
	set name = "Chat Translation"
	set category = "OOC"
	set desc = "Machine translation of chat written in another language."

	if(!prefs)
		return
	var/list/choices = list(
		"Off / Выключено" = AUTOTRANSLATE_PREF_OFF,
		"Translate to English / Переводить на английский" = AUTOTRANSLATE_PREF_ENGLISH,
		"Translate to Russian / Переводить на русский" = AUTOTRANSLATE_PREF_RUSSIAN,
	)
	var/current_value = prefs.read_preference(/datum/preference/choiced/autotranslate_target)
	var/current_label
	for(var/label in choices)
		if(choices[label] == current_value)
			current_label = label
			break
	var/prompt = "Machine translation of chat that other players write in another language. Hover a translated line to read the original."
	prompt += "\n\nМашинный перевод сообщений, которые другие игроки пишут на другом языке. Наведите курсор на переведённую строку, чтобы прочитать оригинал."
	var/selection = input(src, prompt, "Chat Translation / Перевод чата", current_label) as null|anything in choices
	if(!selection || !prefs)
		return

	var/new_value = choices[selection]
	prefs.update_preference(/datum/preference/choiced/autotranslate_target, new_value)
	prefs.save_preferences()
	switch(new_value)
		if(AUTOTRANSLATE_PREF_ENGLISH)
			to_chat(src, span_notice("Chat in other languages is now machine-translated to English. Machine translation can change the meaning. Hover a line to read the original."))
		if(AUTOTRANSLATE_PREF_RUSSIAN)
			to_chat(src, span_notice("Сообщения на других языках теперь переводятся на русский. Машинный перевод может исказить смысл. Наведите курсор на строку, чтобы прочитать оригинал."))
		else
			to_chat(src, span_notice("Chat translation is off. / Перевод чата выключен."))
			return
	if(!SSautotranslate.running || SSautotranslate.provider?.state != AUTOTRANSLATE_BACKEND_OK)
		to_chat(src, span_warning("The translation service is not available now, so lines stay in their original language. / Сервис перевода сейчас недоступен, поэтому сообщения остаются на языке оригинала."))
