/**
 * Language of a chat line by letter count: "ru", "en", or null when neither script has a clear majority.
 * The last answer is kept, because one line reaches every listener as the same string.
 */
/proc/autotranslate_detect_language(text)
	var/static/last_text
	var/static/last_language
	if(text == last_text)
		return last_language
	last_text = text
	last_language = autotranslate_count_scripts(text)
	return last_language

/proc/autotranslate_count_scripts(text)
	var/cyrillic = 0
	var/latin = 0
	var/byte_length = length(text)
	var/position = 1
	while(position <= byte_length)
		var/code = text2ascii(text, position)
		if(code < 128)
			position++
			if(code == 38) // "&": skip the entity so "&quot;" adds no Latin letters
				var/entity_end = findtext(text, ";", position, min(position + 9, byte_length + 1))
				if(entity_end)
					position = entity_end + 1
			else if((code >= 97 && code <= 122) || (code >= 65 && code <= 90))
				latin++
			continue
		if(code >= 0x400 && code <= 0x4FF)
			cyrillic++
		// text2ascii() reads a whole character at a byte position, so step by its UTF-8 width.
		position += (code < 0x800) ? 2 : ((code < 0x10000) ? 3 : 4)

	var/letters = cyrillic + latin
	if(letters < 2)
		return null
	if(cyrillic >= letters * AUTOTRANSLATE_SCRIPT_MAJORITY)
		return AUTOTRANSLATE_LANG_RU
	if(latin >= letters * AUTOTRANSLATE_SCRIPT_MAJORITY)
		return AUTOTRANSLATE_LANG_EN
	return null
