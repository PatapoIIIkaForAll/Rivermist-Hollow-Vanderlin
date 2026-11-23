/datum/rmh_law_document
	var/revision = 1
	var/next_id = 0
	var/list/content = list()

/datum/rmh_law_document/Destroy()
	content = null
	return ..()

/datum/rmh_law_document/proc/allocate_id()
	next_id++
	return "entry_[next_id]"

/datum/rmh_law_document/proc/normalize(list/payload, check_ids = TRUE, for_draft = FALSE)
	return null

/datum/rmh_law_document/proc/assign_ids(list/payload)
	return

/// IDs are unique across a document; fresh client IDs are never official IDs.
/datum/rmh_law_document/proc/valid_id(id, list/seen, list/existing, check_ids)
	if(!istext(id) || !length(id) || length(id) > RMH_LAW_MAX_TITLE || (id in seen))
		return FALSE
	if(check_ids && !(id in existing) && copytext(id, 1, 7) != "draft_")
		return FALSE
	seen += id
	return TRUE

/proc/rmh_law_text(value, limit, allow_empty = TRUE)
	if(!istext(value) || length_char(value) > limit)
		return FALSE
	return allow_empty || length(trim(value))

/datum/rmh_law_document/code

/datum/rmh_law_document/code/normalize(list/payload, check_ids = TRUE, for_draft = FALSE)
	if(!islist(payload) || length(payload) > RMH_LAW_MAX_LAWS)
		return null
	var/list/existing = list()
	for(var/list/entry as anything in content)
		existing += entry["id"]
	var/list/seen = list()
	var/list/result = list()
	var/text_size = 0
	for(var/list/entry as anything in payload)
		if(!islist(entry) || (length(entry) != 2 && !(length(entry) == 3 && ("text_en" in entry))))
			return null
		if(!valid_id(entry["id"], seen, existing, check_ids) || !rmh_law_text(entry["text"], RMH_LAW_MAX_TEXT, allow_empty = for_draft))
			return null
		var/english = ("text_en" in entry) ? entry["text_en"] : ""
		if(!rmh_law_text(english, RMH_LAW_MAX_TEXT))
			return null
		text_size += length_char(entry["text"]) + length_char(english)
		if(text_size > RMH_LAW_MAX_DOCUMENT)
			return null
		result += list(list("id" = entry["id"], "text" = entry["text"], "text_en" = english))
	return result

/datum/rmh_law_document/code/assign_ids(list/payload)
	for(var/list/entry as anything in payload)
		if(copytext(entry["id"], 1, 7) == "draft_")
			entry["id"] = allocate_id()

/// Required legacy fields plus optional translations; unknown fields never survive.
/proc/rmh_law_fields(value, list/required, list/optional)
	if(!islist(value))
		return FALSE
	var/list/fields = value
	for(var/key in required)
		if(!(key in fields))
			return FALSE
	for(var/key in fields)
		if(!(key in required) && !(key in optional))
			return FALSE
	return TRUE

/datum/rmh_law_document/book
	content = list("title" = "Tome of Justice", "title_en" = "", "chapters" = list())

/// Read the SAME source as /obj/item/book/law; do not maintain a second legal text.
/datum/rmh_law_document/book/proc/seed_tome()
	var/list/pages = strings("books/law.json", "Contents")
	var/list/articles = list()
	for(var/page in pages)
		// Paragraph boundaries become ordered articles, retaining the original wording.
		var/list/paragraphs = splittext(replacetext(page, "<hr>", ""), "</p>")
		for(var/paragraph in paragraphs)
			var/body = trim(html_decode(GLOB.html_tags.Replace(paragraph, "")))
			if(!length(body))
				continue
			articles += list(list("id" = allocate_id(), "title" = "Article [length(articles) + 1]", "title_en" = "", "body" = body, "body_en" = ""))
	content = list(
		"title" = "Tome of Justice",
		"title_en" = "",
		"chapters" = list(list("id" = allocate_id(), "title" = "The New Law of the Town", "title_en" = "", "intro" = "", "intro_en" = "", "articles" = articles)),
	)

/datum/rmh_law_document/book/normalize(list/payload, check_ids = TRUE, for_draft = FALSE)
	if(!rmh_law_fields(payload, list("title", "chapters"), list("title_en")) || !rmh_law_text(payload["title"], RMH_LAW_MAX_TITLE, allow_empty = for_draft))
		return null
	var/title_en = ("title_en" in payload) ? payload["title_en"] : ""
	if(!rmh_law_text(title_en, RMH_LAW_MAX_TITLE))
		return null
	var/list/chapters = payload["chapters"]
	if(!islist(chapters) || length(chapters) > RMH_LAW_MAX_CHAPTERS)
		return null
	var/list/existing_chapters = list()
	var/list/existing_articles = list()
	var/list/current_chapters = content["chapters"]
	for(var/list/chapter as anything in current_chapters)
		existing_chapters += chapter["id"]
		var/list/current_articles = chapter["articles"]
		for(var/list/article as anything in current_articles)
			existing_articles += article["id"]
	var/list/seen = list()
	var/list/result_chapters = list()
	var/article_count = 0
	var/text_size = length_char(payload["title"]) + length_char(title_en)
	for(var/list/chapter as anything in chapters)
		if(!rmh_law_fields(chapter, list("id", "title", "intro", "articles"), list("title_en", "intro_en")))
			return null
		if(!valid_id(chapter["id"], seen, existing_chapters, check_ids))
			return null
		if(!rmh_law_text(chapter["title"], RMH_LAW_MAX_TITLE, allow_empty = for_draft) || !rmh_law_text(chapter["intro"], RMH_LAW_MAX_BODY))
			return null
		var/chapter_title_en = ("title_en" in chapter) ? chapter["title_en"] : ""
		var/intro_en = ("intro_en" in chapter) ? chapter["intro_en"] : ""
		if(!rmh_law_text(chapter_title_en, RMH_LAW_MAX_TITLE) || !rmh_law_text(intro_en, RMH_LAW_MAX_BODY))
			return null
		var/list/articles = chapter["articles"]
		if(!islist(articles))
			return null
		article_count += length(articles)
		if(article_count > RMH_LAW_MAX_ARTICLES)
			return null
		text_size += length_char(chapter["title"]) + length_char(chapter["intro"]) + length_char(chapter_title_en) + length_char(intro_en)
		var/list/result_articles = list()
		for(var/list/article as anything in articles)
			if(!rmh_law_fields(article, list("id", "title", "body"), list("title_en", "body_en")) || !valid_id(article["id"], seen, existing_articles, check_ids))
				return null
			if(!rmh_law_text(article["title"], RMH_LAW_MAX_TITLE, allow_empty = for_draft) || !rmh_law_text(article["body"], RMH_LAW_MAX_BODY, allow_empty = for_draft))
				return null
			var/article_title_en = ("title_en" in article) ? article["title_en"] : ""
			var/body_en = ("body_en" in article) ? article["body_en"] : ""
			if(!rmh_law_text(article_title_en, RMH_LAW_MAX_TITLE) || !rmh_law_text(body_en, RMH_LAW_MAX_BODY))
				return null
			text_size += length_char(article["title"]) + length_char(article["body"]) + length_char(article_title_en) + length_char(body_en)
			result_articles += list(list("id" = article["id"], "title" = article["title"], "title_en" = article_title_en, "body" = article["body"], "body_en" = body_en))
		if(text_size > RMH_LAW_MAX_DOCUMENT)
			return null
		result_chapters += list(list("id" = chapter["id"], "title" = chapter["title"], "title_en" = chapter_title_en, "intro" = chapter["intro"], "intro_en" = intro_en, "articles" = result_articles))
	return list("title" = payload["title"], "title_en" = title_en, "chapters" = result_chapters)

/datum/rmh_law_document/book/assign_ids(list/payload)
	var/list/chapters = payload["chapters"]
	for(var/list/chapter as anything in chapters)
		if(copytext(chapter["id"], 1, 7) == "draft_")
			chapter["id"] = allocate_id()
		var/list/articles = chapter["articles"]
		for(var/list/article as anything in articles)
			if(copytext(article["id"], 1, 7) == "draft_")
				article["id"] = allocate_id()

