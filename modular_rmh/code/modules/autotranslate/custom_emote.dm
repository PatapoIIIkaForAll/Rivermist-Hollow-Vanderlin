/**
 * A custom emote ("me") while it is sent to its viewers. visible_message() shows every viewer the same
 * string, so each viewer's copy is swapped as show_message() gets it.
 */
/datum/autotranslate_emote
	/// The chat line every viewer gets: prefix, then the typed text.
	var/full_message
	/// The name part before the typed text.
	var/prefix
	/// What the player typed, HTML-encoded.
	var/typed_text
	var/author_ckey

/datum/autotranslate_emote/New(full_message, prefix, typed_text, author_ckey)
	src.full_message = full_message
	src.prefix = prefix
	src.typed_text = typed_text
	src.author_ckey = author_ckey

/// The chat line for one viewer. Also sets the line that the viewer's next bubble belongs to.
/datum/autotranslate_emote/proc/message_for(mob/viewer, message)
	SSautotranslate.current_line = null
	// Viewers who get another string (blind text, an obscured copy) are left alone.
	if(message != full_message || !viewer.client || viewer.ckey == author_ckey)
		return message
	var/datum/translated_line/line = autotranslate_line(viewer.client, typed_text, AUTOTRANSLATE_CHANNEL_EMOTE)
	if(!line)
		return message
	SSautotranslate.current_line = line
	return "[prefix][line.wrap(typed_text)]"

/mob/show_message(msg, type, alt_msg, alt_type)
	var/datum/autotranslate_emote/emote = SSautotranslate?.current_emote
	if(emote)
		msg = emote.message_for(src, msg)
	return ..()

/datum/emote/living/custom/send_visible_emote_message(mob/user, atom/message_source, message, runechat_message = null, intentional = FALSE, obfuscated_message = null, obfuscated_runechat_message = null)
	// run_emote() keeps the typed text in src.message for the length of the call.
	var/typed_text = src.message
	var/typed_start = length(message) - length(typed_text) + 1
	if(!SSautotranslate.running || !length(typed_text) || typed_start < 1 || copytext(message, typed_start) != typed_text)
		return ..()
	SSautotranslate.current_emote = new /datum/autotranslate_emote(message, copytext(message, 1, typed_start), typed_text, user.ckey)
	. = ..()
	SSautotranslate.current_emote = null
	SSautotranslate.current_line = null
