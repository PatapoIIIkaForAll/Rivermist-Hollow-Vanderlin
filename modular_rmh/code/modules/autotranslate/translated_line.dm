GLOBAL_VAR_INIT(autotranslate_line_count, 0)
/// The chat panel keeps lines across server restarts, so ids need a part that differs for each boot.
GLOBAL_VAR_INIT(autotranslate_boot_token, copytext(md5("[world.realtime]-[world.timeofday]-[rand(1, 999999)]"), 1, 9))

/**
 * One chat line for one reader, while its translation is on its way or already known.
 * Marks the text in the chat panel, and replaces the Runechat bubble when the result arrives.
 */
/datum/translated_line
	/// Set when the chat wrapper is built. A line that only has a bubble needs no id.
	var/id
	/// A ckey, so a waiting line never keeps a logged-out client in memory.
	var/owner_ckey
	/// HTML-encoded source text with no tags.
	var/original
	/// HTML-encoded result.
	var/translated
	var/state = AUTOTRANSLATE_LINE_PENDING
	var/channel

	/// The bubble that shows the original text, and what is needed to make one with the translation.
	var/datum/weakref/bubble_ref
	var/datum/weakref/listener_ref
	var/datum/weakref/speaker_ref
	var/datum/language/bubble_language
	var/list/bubble_spans

/datum/translated_line/New(owner_ckey, original, channel)
	src.owner_ckey = owner_ckey
	src.original = original
	src.channel = channel

/// Chat markup for this line. inner_html is how the original text looks in the line.
/datum/translated_line/proc/wrap(inner_html)
	if(state == AUTOTRANSLATE_LINE_DONE)
		return "<span class='tsl tsl-done' title='[original]'>[translated]</span>"
	if(!id)
		GLOB.autotranslate_line_count++
		id = "tsl-[GLOB.autotranslate_boot_token]-[GLOB.autotranslate_line_count]"
	return "<span class='tsl tsl-pending' data-tsl-id='[id]'>[inner_html]</span>"

/datum/translated_line/proc/remember_bubble_request(mob/listener, atom/movable/speaker, datum/language/message_language, list/spans)
	listener_ref = WEAKREF(listener)
	speaker_ref = WEAKREF(speaker)
	bubble_language = message_language
	bubble_spans = spans?.Copy()

/datum/translated_line/proc/on_result(text, success)
	SSautotranslate.live_lines--
	if(success)
		state = AUTOTRANSLATE_LINE_DONE
		translated = text
		SSautotranslate.channel_counts[channel]++
	else
		state = AUTOTRANSLATE_LINE_FAILED
	push_chat_update()
	if(success)
		replace_bubble()

/**
 * Sends the result through SSchat, the same queue as the line itself.
 * That queue keeps order and resends lost payloads; a direct window message does neither.
 */
/datum/translated_line/proc/push_chat_update()
	if(!id)
		return
	var/client/owner = GLOB.directory[owner_ckey]
	if(!owner)
		return
	// The key is not "html" or "text": SSchat also prints those two to the legacy output.
	SSchat.queue(owner, list(
		"type" = AUTOTRANSLATE_PANEL_MESSAGE,
		"id" = id,
		"status" = state,
		"translated" = (state == AUTOTRANSLATE_LINE_DONE) ? html_decode(translated) : null,
	))

/// Shows the translation above the speaker, but only while the bubble with the original is still there.
/datum/translated_line/proc/replace_bubble()
	var/datum/chatmessage/bubble = bubble_ref?.resolve()
	if(QDELETED(bubble))
		return
	var/mob/listener = listener_ref?.resolve()
	var/atom/movable/speaker = speaker_ref?.resolve()
	if(!listener || !speaker)
		return
	// Deleted first: a bubble that still waits for its text measure would otherwise delete the new one.
	qdel(bubble)
	listener.create_chat_message(speaker, bubble_language, translated, bubble_spans)

/**
 * The line for one reader of one text, or null when the reader needs no translation of it.
 * A returned line is either done (cache hit) or has a request in flight.
 */
/proc/autotranslate_line(client/reader, text, channel)
	var/target_language = reader.autotranslate_target || reader.read_autotranslate_target()
	if(target_language == AUTOTRANSLATE_TARGET_NONE)
		return null
	var/cost_start = TICK_USAGE_REAL
	. = autotranslate_build_line(reader, text, channel, target_language)
	SSautotranslate.hook_cost_ms += TICK_USAGE_TO_MS(cost_start)

/proc/autotranslate_build_line(client/reader, text, channel, target_language)
	// Emote and admin text can carry markup. The translator and the hover attribute need plain text.
	if(findtext(text, "<"))
		text = GLOB.html_tags.Replace(text, "")
	text = replacetext(text, "'", "&#39;")
	var/source_language = autotranslate_detect_language(text)
	if(!source_language || source_language == target_language)
		return null
	var/datum/translated_line/line = new(reader.ckey, text, channel)
	var/cached = SSautotranslate.get_cached(text, source_language, target_language)
	if(cached)
		line.translated = cached
		line.state = AUTOTRANSLATE_LINE_DONE
		SSautotranslate.channel_counts[channel]++
		return line
	var/datum/callback/on_result = CALLBACK(line, TYPE_PROC_REF(/datum/translated_line, on_result))
	if(!SSautotranslate.request_translation(text, source_language, target_language, on_result, channel))
		return null
	SSautotranslate.live_lines++
	return line

/**
 * Text for a chat-only line (OOC, LOOC and similar) as one reader gets it.
 * shown_html is the text as the line shows it; source_text is the same text before markup.
 */
/proc/autotranslate_chat_text(client/reader, shown_html, source_text, client/author, channel)
	if(!SSautotranslate.running || !reader || reader == author)
		return shown_html
	var/datum/translated_line/line = autotranslate_line(reader, source_text, channel)
	if(!line)
		return shown_html
	return line.wrap(shown_html)

// Core files call these, because they are compiled before the channel defines exist.
/proc/autotranslate_ooc_text(client/reader, shown_html, source_text, client/author)
	return autotranslate_chat_text(reader, shown_html, source_text, author, AUTOTRANSLATE_CHANNEL_OOC)

/proc/autotranslate_looc_text(client/reader, shown_html, source_text, client/author)
	return autotranslate_chat_text(reader, shown_html, source_text, author, AUTOTRANSLATE_CHANNEL_LOOC)

/proc/autotranslate_admin_text(client/reader, shown_html, source_text, client/author)
	return autotranslate_chat_text(reader, shown_html, source_text, author, AUTOTRANSLATE_CHANNEL_ADMIN)
