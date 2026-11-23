// Bubbles are made deep inside Hear() and visible_message(), so they find their line through SSautotranslate.current_line.
// These procs can run before the subsystems exist, so the subsystem is read with ?.

/mob/create_chat_message(atom/movable/speaker, datum/language/message_language, raw_message, list/spans)
	var/datum/translated_line/line = SSautotranslate?.current_line
	if(line && line.owner_ckey == ckey)
		if(line.state == AUTOTRANSLATE_LINE_DONE)
			raw_message = line.translated
		else
			line.remember_bubble_request(src, speaker, message_language, spans)
	return ..()

/datum/chatmessage/New(text, atom/target, mob/owner, datum/language/language, list/extra_classes = list(), lifespan = CHAT_MESSAGE_LIFESPAN)
	. = ..()
	var/datum/translated_line/line = SSautotranslate?.current_line
	if(line?.state == AUTOTRANSLATE_LINE_PENDING && line.owner_ckey == owner?.ckey)
		line.bubble_ref = WEAKREF(src)
