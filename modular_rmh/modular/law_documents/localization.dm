/proc/rmh_ui_text(mob/user, russian, english)
	return get_preferred_ui_language(user) == "ru" ? russian : english

/proc/rmh_law_revision_message(document_id, revision, language)
	if(language == "ru")
		return "Опубликована [revision]-я редакция [document_id == RMH_LAW_CODE ? "свода" : "книги законов"]."
	return "Published revision [revision] of [document_id == RMH_LAW_CODE ? "the law code" : "the lawbook"]."

/proc/rmh_law_feedback(mob/user, message)
	if(get_preferred_ui_language(user) != "ru")
		return message
	var/static/list/messages = list(
		"New archive data exceeds 128 KiB. Existing saved text has been kept; shorten the edit." = "Новые данные архива превышают 128 КиБ. Старый текст сохранён; сократите правку.",
		"Could not write the account savefile." = "Не удалось записать данные аккаунта.",
		"I begin replacing the board's broken glass." = "Я начинаю заменять разбитое стекло доски.",
		"Invalid document: check text limits and identifiers." = "Недопустимый документ: проверьте объём текста и идентификаторы.",
		"Invalid document: check text limits, identifiers and document structure." = "Недопустимый документ: проверьте объём текста, идентификаторы и структуру.",
		"Invalid notes: check identifiers and text limits." = "Недопустимые записи: проверьте идентификаторы и объём текста.",
		"Personal draft saved. The official document has not changed." = "Личный черновик сохранён. Опубликованный документ не изменился.",
		"Personal notes saved." = "Личные записи сохранены.",
		"Please wait a moment before writing drafts again." = "Подождите немного перед следующим сохранением.",
		"The English translation exceeds the text limit." = "Английский перевод превышает допустимый объём.",
		"The account draft record limit was reached." = "Достигнут предел разделов черновиков аккаунта.",
		"The account draft size limit was reached." = "Достигнут предел объёма черновиков аккаунта.",
		"The account note storage limit was reached." = "Достигнут предел объёма записей аккаунта.",
		"The account note-record limit was reached." = "Достигнут предел разделов личных записей.",
		"The decree changed or was abolished. Reload its current translation." = "Указ изменён или отменён. Загрузите его текущий перевод.",
		"The decree changed or was revoked. Choose from the current list." = "Указ изменён или отозван. Выберите его в актуальном перечне.",
		"The published revision changed. Compare with the current document before publishing." = "Опубликованная редакция изменилась. Сверьте документ перед публикацией.",
		"The round's decree translation size limit was reached." = "Достигнут предел объёма переводов указов в этом раунде.",
		"The saved notes changed. Compare and reload them before saving." = "Сохранённые записи изменились. Сверьте и загрузите их перед сохранением.",
		"There is already a poster on this face of the wall." = "На этой стороне стены уже висит постер.",
		"This character has no usable account save." = "Для этого персонажа недоступно сохранение аккаунта.",
		"This decree exceeds the poster's text limit." = "Указ превышает допустимый объём текста постера.",
	)
	return istext(messages[message]) ? messages[message] : message

/// Reading is separate from physical interaction and mutation permissions.
/proc/rmh_law_can_read(mob/user, atom/source, allow_remote = FALSE)
	if(!user || !source)
		return FALSE
	if(isobserver(user))
		return TRUE
	return (allow_remote || in_range(user, source)) && user.can_read(source, TRUE) \
		&& user.can_perform_action(source, NEED_LITERACY | (allow_remote ? NONE : FORBID_TELEKINESIS_REACH))
