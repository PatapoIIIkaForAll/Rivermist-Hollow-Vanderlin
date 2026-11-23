/// Stable identities are a projection of the existing THROAT decree list, not history.
/datum/rmh_law_documents
	var/list/decrees = list()
	var/next_decree_id = 0

/datum/rmh_law_documents/proc/sync_legacy_decrees()
	var/list/next = list()
	var/list/used = list()
	for(var/legacy in GLOB.lord_decrees)
		var/text = html_decode(legacy)
		var/list/entry
		for(var/list/candidate as anything in decrees)
			if(candidate["text"] == text && !(candidate["id"] in used))
				entry = candidate.Copy()
				break
		if(!entry)
			next_decree_id++
			entry = list("id" = "decree_[next_decree_id]", "text" = text, "text_en" = "", "revision" = 1)
		used += entry["id"]
		next += list(entry)
	if(json_encode(next) == json_encode(decrees))
		return FALSE
	decrees = next
	SEND_SIGNAL(src, COMSIG_RMH_DECREES_CHANGED)
	return TRUE

/datum/rmh_law_documents/proc/publish_decree_translation(id, expected_revision, text_en)
	if(!rmh_law_text(text_en, RMH_LAW_MAX_TEXT))
		return "The English translation exceeds the text limit."
	var/list/selected
	var/total = length_char(text_en)
	for(var/list/entry as anything in decrees)
		if(entry["id"] == id)
			selected = entry
		else
			total += length_char(entry["text_en"])
	if(!selected || !isnum(expected_revision) || selected["revision"] != expected_revision)
		return "The decree changed or was abolished. Reload its current translation."
	if(total > RMH_LAW_MAX_DOCUMENT)
		return "The round's decree translation size limit was reached."
	if(selected["text_en"] == text_en)
		return null
	selected["text_en"] = text_en
	selected["revision"]++
	SEND_SIGNAL(src, COMSIG_RMH_DECREES_CHANGED)
	return null

