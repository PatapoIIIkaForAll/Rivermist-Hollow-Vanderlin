/**
 * One announcement per changed publication, never per book/board instance.
 * Pure summary helper also keeps batch additions distinct from amendments.
 */
/proc/rmh_law_publication_notice(document_id, list/before, list/after, language = "ru")
	if(json_encode(before) == json_encode(after))
		return null
	if(language == "en")
		return rmh_law_publication_notice_en(document_id, before, after)
	if(document_id == RMH_LAW_BOOK)
		return list("title" = "В КНИГУ ЗАКОНОВ ВНЕСЕНЫ ПОПРАВКИ", \
			"text" = "Опубликованы поправки к Книге законов. Ознакомьтесь с обновлённым изданием.", \
			"sound" = RMH_LAW_SOUND_BOOK)
	if(document_id != RMH_LAW_CODE)
		return null
	var/list/old_ids = list()
	for(var/list/entry as anything in before)
		old_ids += entry["id"]
	var/list/additions = list()
	for(var/list/entry as anything in after)
		if(!(entry["id"] in old_ids))
			additions += list(entry)
	if(length(additions) == 1)
		var/list/entry = additions[1]
		return list("title" = "ВВЕДЁН НОВЫЙ ЗАКОН ГРАДА", \
			"text" = "[after.Find(entry)]. [entry["text"]]", "sound" = RMH_LAW_SOUND_CODE)
	if(length(additions) > 1)
		return list("title" = "ВВЕДЕНЫ НОВЫЕ ЗАКОНЫ ГРАДА", \
			"text" = "Введено новых законов града: [length(additions)]. Ознакомьтесь с обновлённым сводом.", \
			"sound" = RMH_LAW_SOUND_CODE)
	return list("title" = "СВОД ЗАКОНОВ ГРАДА ОБНОВЛЁН", \
		"text" = "Опубликованы изменения свода законов града. Ознакомьтесь с действующей редакцией.", \
		"sound" = RMH_LAW_SOUND_CODE)

/proc/rmh_announce_law_publication(document_id, list/before, list/after)
	// One rare publication fan-out, preserving stock hearing and sound-preference checks.
	var/list/russian = list()
	var/list/english = list()
	for(var/mob/viewer as anything in GLOB.player_list)
		if(get_preferred_ui_language(viewer) == "ru")
			russian += viewer
		else
			english += viewer
	for(var/language in list("ru", "en"))
		var/list/players = language == "ru" ? russian : english
		if(!length(players))
			continue
		var/list/notice = rmh_law_publication_notice(document_id, before, after, language)
		if(notice)
			priority_announce(notice["text"], notice["title"], notice["sound"], "Captain", players = players)

/proc/rmh_law_publication_notice_en(document_id, list/before, list/after)
	if(document_id == RMH_LAW_BOOK)
		return list("title" = "LAWBOOK AMENDED", "text" = "Amendments to the lawbook have been published. Read the updated edition.", "sound" = RMH_LAW_SOUND_BOOK)
	if(document_id != RMH_LAW_CODE)
		return null
	var/list/old_ids = list()
	for(var/list/entry as anything in before)
		old_ids += entry["id"]
	var/list/additions = list()
	for(var/list/entry as anything in after)
		if(!(entry["id"] in old_ids))
			additions += list(entry)
	if(length(additions) == 1)
		var/list/entry = additions[1]
		var/english = entry["text_en"]
		var/text = istext(english) && length(trim(english)) ? english : entry["text"]
		return list("title" = "A LAW IS DECLARED", "text" = "[after.Find(entry)]. [text]", "sound" = RMH_LAW_SOUND_CODE)
	if(length(additions) > 1)
		return list("title" = "NEW TOWN LAWS", "text" = "New town laws enacted: [length(additions)]. Read the updated code.", "sound" = RMH_LAW_SOUND_CODE)
	return list("title" = "LAW CODE UPDATED", "text" = "Changes to the town law code have been published. Read the current edition.", "sound" = RMH_LAW_SOUND_CODE)

/proc/rmh_log_law_publication(mob/author, document_id, revision, list/before, list/after)
	var/event = json_encode(list("author" = key_name(author), "document" = document_id, "revision" = revision, "before" = before, "after" = after))
	var/size = length_char(event)
	for(var/offset = 1, offset <= size, offset += 2000)
		log_game("LAW_PUBLICATION [document_id] revision [revision] part [offset]: [html_encode(copytext_char(event, offset, offset + 2000))]")

/// Only read paths admit observers; physical editing retains its own capability checks.
