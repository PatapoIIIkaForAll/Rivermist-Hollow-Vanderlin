/datum/inscription
	VAR_PRIVATE/text
	VAR_PRIVATE/datum/language/used_language

/datum/inscription/New(text, language)
	src.text = text
	src.used_language = language

/datum/inscription/proc/can_be_read(mob/reader)
	return reader.has_language(src.used_language)

/datum/inscription/proc/get_text()
	return src.text

/datum/inscription/proc/set_text(new_text)
	src.text = new_text

/datum/inscription/proc/get_unreadable_warning()
	PRIVATE_PROC(TRUE)
	return span_warning("You can’t understand what’s written here.")

/datum/inscription/proc/update(new_text, language)
	PRIVATE_PROC(TRUE)
	src.text = text
	src.used_language = language

/datum/inscription/proc/try_to_read(mob/reader)
	if(!src.can_be_read(reader))
		return src.get_unreadable_warning()
	return src.get_text()

/datum/inscription/proc/try_to_update(mob/reader, text, datum/language/language)
	if(!src.can_be_read(reader))
		return
	src.update()

// ---

/datum/component/inscription_holder
	VAR_PRIVATE/list/datum/inscriptions = list()

/datum/component/inscription_holder/Initialize(list/datum/initial_inscriptions = list())
	for(var/inscription in initial_inscriptions)
		src.add_inscription(inscription)

/datum/component/inscription_holder/proc/add_inscription(datum/inscription/inscription)
	src.inscriptions.Add(inscription)

/datum/component/inscription_holder/proc/get_examine_list(mob/reader)
	RETURN_TYPE(/list)
	var/list/list_to_return = list()
	for(var/datum/inscription/inscription_to_check in src.inscriptions)
		list_to_return.Add(span_info(inscription_to_check.try_to_read(reader)))
	return list_to_return

/datum/component/inscription_holder/proc/get_inscription(index)
	RETURN_TYPE(/datum/inscription)
	if(src.inscriptions.len < index)
		return
	return src.inscriptions[index]

/datum/component/inscription_holder/proc/remove_inscription(index)
	if(src.inscriptions.len < index)
		return
	del src.inscriptions[index]
