/**
 * Speech translation hooks into Hear() through one value: SSautotranslate.current_line, the line of the
 * listener being served. Hear() sets it, and the bubble and chat-line code below read it.
 */

/// The line for this listener's copy of a spoken message, or null when it stays as it is.
/mob/proc/autotranslate_heard_line(atom/movable/speaker, datum/language/message_language, raw_message, list/message_mods)
	var/client/listener = client
	var/target_language = listener.autotranslate_target || listener.read_autotranslate_target()
	if(target_language == AUTOTRANSLATE_TARGET_NONE)
		return null
	// Radio speech arrives through a stand-in speaker.
	var/atom/movable/source = speaker.GetSource() || speaker
	if(source == src || !ismob(source))
		return null
	var/mob/speaking_mob = source
	if(!speaking_mob.client)
		return null
	// A listener who gets scrambled or missing text must not get the real words through a translation.
	if(!can_hear() || !(has_language(message_language) || check_language_hear(message_language)))
		return null
	// stars() hides letters of an overheard whisper behind "*". A copy with no "*" is the full text.
	if(message_mods?[WHISPER_MODE] && findtext(raw_message, "*"))
		return null
	return autotranslate_line(listener, raw_message, AUTOTRANSLATE_CHANNEL_SAY)

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), original_message)
	if(!SSautotranslate?.running || !client)
		return ..()
	var/datum/translated_line/outer_line = SSautotranslate.current_line
	// An unconscious or partly deaf listener gets altered text.
	if(stat < UNCONSCIOUS && !HAS_TRAIT(src, TRAIT_PARTIAL_DEAF))
		SSautotranslate.current_line = autotranslate_heard_line(speaker, message_language, raw_message, message_mods)
	else
		SSautotranslate.current_line = null
	. = ..()
	SSautotranslate.current_line = outer_line

/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), original_message)
	if(!SSautotranslate?.running || !client)
		return ..()
	var/datum/translated_line/outer_line = SSautotranslate.current_line
	SSautotranslate.current_line = autotranslate_heard_line(speaker, message_language, raw_message, message_mods)
	. = ..()
	SSautotranslate.current_line = outer_line

/// Marks the spoken words inside `verb, "words"`, and keeps the span that styles them around the mark.
/atom/movable/say_quote(input, list/spans = list(speech_span), list/message_mods = list())
	. = ..()
	var/datum/translated_line/line = SSautotranslate?.current_line
	if(line?.channel != AUTOTRANSLATE_CHANNEL_SAY)
		return
	// The player's own quote marks are HTML entities, so the first and last raw ones frame the words.
	var/open_quote = findtext(., "\"")
	var/close_quote = findlasttext(., "\"")
	if(!open_quote || close_quote <= open_quote)
		return
	var/words = copytext(., open_quote + 1, close_quote)
	var/span_open = ""
	var/span_close = ""
	var/static/span_end = "</span>"
	var/open_tag_end = findtext(words, ">")
	if(findtext(words, "<span", 1, 6) && open_tag_end && findtext(words, span_end, -length(span_end)))
		span_open = copytext(words, 1, open_tag_end + 1)
		span_close = span_end
		words = copytext(words, open_tag_end + 1, length(words) - length(span_end) + 1)
	return "[copytext(., 1, open_quote + 1)][span_open][line.wrap(words)][span_close][copytext(., close_quote)]"
