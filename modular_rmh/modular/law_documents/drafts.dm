/datum/preferences
	var/tmp/rmh_law_next_draft_write = 0

/// Account savefiles isolate ckeys. Records further isolate mind-name and current office.
/datum/preference/list_type/rmh_law_drafts
	savefile_key = "rmh_law_drafts_v1"
	savefile_identifier = PREF_PLAYER
	should_apply = FALSE

/datum/preference/list_type/rmh_law_drafts/is_valid(value, datum/preferences/prefs)
	if(!islist(value) || length(value) > RMH_LAW_MAX_DRAFT_RECORDS)
		return FALSE
	var/list/identities = list()
	var/total_size = 0
	var/datum/rmh_law_document/code/code_validator = new
	var/datum/rmh_law_document/book/book_validator = new
	for(var/list/record as anything in value)
		if(!islist(record) || length(record) != 3)
			return FALSE
		if(!rmh_law_text(record["character"], RMH_LAW_MAX_TITLE, allow_empty = FALSE) || !(record["role"] in list("burgmeister", "councilor")))
			return FALSE
		var/identity = json_encode(list(record["character"], record["role"]))
		if(identity in identities)
			return FALSE
		identities += identity
		var/list/documents = record["documents"]
		if(!islist(documents) || length(documents) > 2)
			return FALSE
		for(var/document_id in documents)
			var/datum/rmh_law_document/validator
			switch(document_id)
				if(RMH_LAW_CODE)
					validator = code_validator
				if(RMH_LAW_BOOK)
					validator = book_validator
				else
					return FALSE
			var/list/saved = documents[document_id]
			if(!islist(saved) || length(saved) != 3 || !istext(saved["epoch"]) || length(saved["epoch"]) > RMH_LAW_MAX_TITLE)
				return FALSE
			var/version = saved["revision"]
			if(!isnum(version) || version < 1 || version != round(version))
				return FALSE
			if(!validator.normalize(saved["content"], check_ids = FALSE, for_draft = TRUE))
				return FALSE
			total_size += length(json_encode(saved["content"]))
			if(total_size > RMH_LAW_MAX_SAVED_TEXT)
				return FALSE
	return TRUE

/// Never use a starting-job flag: THROAT appointments and demotions change assigned_role.
/proc/rmh_law_editor_role(mob/user)
	var/datum/job/job = user?.mind?.assigned_role
	if(is_burgmeister_job(job))
		return "burgmeister"
	if(istype(job, /datum/job/councilor) || istype(job, /datum/job/advclass/councilor))
		return "councilor"
	return null

/proc/rmh_law_character(mob/user)
	// The mind's original character name survives ordinary in-round aliases.
	return user?.mind?.name

/proc/rmh_law_saved_record(mob/user, role)
	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs || !role)
		return null
	var/list/records = prefs.read_preference(/datum/preference/list_type/rmh_law_drafts)
	var/character = rmh_law_character(user)
	for(var/list/record as anything in records)
		if(record["character"] == character && record["role"] == role)
			return record
	return null

/proc/rmh_save_law_draft(mob/user, role, document_id, revision, list/content)
	var/datum/preferences/prefs = user?.client?.prefs
	var/character = rmh_law_character(user)
	if(!prefs || !rmh_law_text(character, RMH_LAW_MAX_TITLE, allow_empty = FALSE))
		return "This character has no usable account save."
	if(world.time < prefs.rmh_law_next_draft_write)
		return "Please wait a moment before writing drafts again."
	var/list/old_records = prefs.read_preference(/datum/preference/list_type/rmh_law_drafts)
	var/list/records = old_records.Copy()
	var/list/record = rmh_law_saved_record(user, role)
	if(record)
		var/index = records.Find(record)
		record = record.Copy()
		var/list/old_documents = record["documents"]
		record["documents"] = old_documents.Copy()
		records[index] = record
	else
		if(length(records) >= RMH_LAW_MAX_DRAFT_RECORDS)
			return "The account draft record limit was reached."
		record = list("character" = character, "role" = role, "documents" = list())
		records += list(record)
	var/datum/rmh_law_documents/store = rmh_get_law_documents()
	var/list/documents = record["documents"]
	documents[document_id] = list("epoch" = store.epoch, "revision" = revision, "content" = content)
	if(!rmh_law_storage_growth_allowed(old_records, records))
		return "New archive data exceeds 128 KiB. Existing saved text has been kept; shorten the edit."
	prefs.rmh_law_next_draft_write = world.time + 2 SECONDS
	if(!prefs.write_preference(/datum/preference/list_type/rmh_law_drafts, records))
		return "The account draft size limit was reached."
	if(!prefs.save_preferences())
		prefs.write_preference(/datum/preference/list_type/rmh_law_drafts, old_records)
		return "Could not write the account savefile."
	return null

/proc/rmh_delete_law_draft(mob/user, role, document_id)
	var/datum/preferences/prefs = user?.client?.prefs
	var/list/record = rmh_law_saved_record(user, role)
	if(!prefs || !record || world.time < prefs.rmh_law_next_draft_write)
		return FALSE
	var/list/old_records = prefs.read_preference(/datum/preference/list_type/rmh_law_drafts)
	var/list/records = old_records.Copy()
	var/index = records.Find(record)
	record = record.Copy()
	var/list/old_documents = record["documents"]
	var/list/documents = old_documents.Copy()
	documents -= document_id
	if(!length(documents))
		records.Cut(index, index + 1)
	else
		record["documents"] = documents
		records[index] = record
	prefs.rmh_law_next_draft_write = world.time + 2 SECONDS
	if(!prefs.write_preference(/datum/preference/list_type/rmh_law_drafts, records))
		return FALSE
	if(!prefs.save_preferences())
		prefs.write_preference(/datum/preference/list_type/rmh_law_drafts, old_records)
		return FALSE
	return TRUE

/// Private free-form records are independent of publishable code/book snapshots.
/datum/preference/list_type/rmh_law_notes
	savefile_key = "rmh_law_notes_v1"
	savefile_identifier = PREF_PLAYER
	should_apply = FALSE

/datum/preference/list_type/rmh_law_notes/is_valid(value, datum/preferences/prefs)
	if(!islist(value) || length(value) > RMH_LAW_MAX_DRAFT_RECORDS)
		return FALSE
	var/list/identities = list()
	var/total_size = 0
	for(var/list/record as anything in value)
		if(!islist(record) || length(record) != 6 || record["schema"] != 1)
			return FALSE
		if(!rmh_law_text(record["character"], RMH_LAW_MAX_TITLE, FALSE) || !(record["role"] in list("burgmeister", "councilor")))
			return FALSE
		var/identity = json_encode(list(record["character"], record["role"]))
		if(identity in identities)
			return FALSE
		identities += identity
		var/revision = record["revision"]
		var/next_id = record["next_id"]
		if(!isnum(revision) || revision < 1 || revision != round(revision) || !isnum(next_id) || next_id < 0 || next_id != round(next_id))
			return FALSE
		var/list/entries = rmh_normalize_law_notes(record["entries"])
		if(isnull(entries))
			return FALSE
		for(var/list/entry as anything in entries)
			var/id = entry["id"]
			var/number = text2num(copytext(id, 6))
			if(copytext(id, 1, 6) != "note_" || !number || number < 1 || number != round(number) || number > next_id || id != "note_[number]")
				return FALSE
		total_size += length(json_encode(entries))
		if(total_size > RMH_LAW_MAX_SAVED_TEXT)
			return FALSE
	return TRUE

/proc/rmh_normalize_law_notes(value, list/existing_ids, check_ids = FALSE)
	if(!islist(value) || length(value) > 32)
		return null
	var/list/seen = list()
	var/list/result = list()
	var/size = 0
	for(var/list/entry as anything in value)
		if(!islist(entry) || length(entry) != 3)
			return null
		var/id = entry["id"]
		if(!rmh_law_text(id, RMH_LAW_MAX_TITLE, FALSE) || (id in seen))
			return null
		if(check_ids && !(id in existing_ids) && copytext(id, 1, 7) != "draft_")
			return null
		if(!rmh_law_text(entry["title"], RMH_LAW_MAX_TITLE) || !rmh_law_text(entry["body"], RMH_LAW_MAX_BODY))
			return null
		seen += id
		size += length_char(entry["title"]) + length_char(entry["body"])
		if(size > RMH_LAW_MAX_DOCUMENT)
			return null
		result += list(list("id" = id, "title" = entry["title"], "body" = entry["body"]))
	return result

/proc/rmh_law_note_record(mob/user, role)
	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs || !role)
		return null
	var/list/records = prefs.read_preference(/datum/preference/list_type/rmh_law_notes)
	for(var/list/record as anything in records)
		if(record["character"] == rmh_law_character(user) && record["role"] == role)
			return record
	return null

/proc/rmh_save_law_notes(mob/user, role, expected_revision, list/payload)
	var/datum/preferences/prefs = user?.client?.prefs
	var/character = rmh_law_character(user)
	if(!prefs || !rmh_law_text(character, RMH_LAW_MAX_TITLE, FALSE))
		return "This character has no usable account save."
	if(world.time < prefs.rmh_law_next_draft_write)
		return "Please wait a moment before writing drafts again."
	var/list/record = rmh_law_note_record(user, role)
	var/revision = record ? record["revision"] : 1
	if(!isnum(expected_revision) || expected_revision != revision)
		return "The saved notes changed. Compare and reload them before saving."
	var/list/existing_ids = list()
	if(record)
		var/list/old_entries = record["entries"]
		for(var/list/entry as anything in old_entries)
			existing_ids += entry["id"]
	var/list/entries = rmh_normalize_law_notes(payload, existing_ids, TRUE)
	if(isnull(entries))
		return "Invalid notes: check identifiers and text limits."
	var/list/old_records = prefs.read_preference(/datum/preference/list_type/rmh_law_notes)
	var/list/records = old_records.Copy()
	var/index = record ? records.Find(record) : 0
	if(record)
		record = record.Copy()
	else
		if(length(records) >= RMH_LAW_MAX_DRAFT_RECORDS)
			return "The account note-record limit was reached."
		record = list("character" = character, "role" = role, "revision" = 1, "next_id" = 0, "entries" = list(), "schema" = 1)
	for(var/list/entry as anything in entries)
		if(copytext(entry["id"], 1, 7) == "draft_")
			record["next_id"]++
			entry["id"] = "note_[record["next_id"]]"
	record["revision"]++
	record["entries"] = entries
	if(index)
		records[index] = record
	else
		records += list(record)
	if(!rmh_law_storage_growth_allowed(old_records, records))
		return "New archive data exceeds 128 KiB. Existing saved text has been kept; shorten the edit."
	prefs.rmh_law_next_draft_write = world.time + 2 SECONDS
	if(!prefs.write_preference(/datum/preference/list_type/rmh_law_notes, records))
		return "The account note storage limit was reached."
	if(!prefs.save_preferences())
		prefs.write_preference(/datum/preference/list_type/rmh_law_notes, old_records)
		return "Could not write the account savefile."
	return null


/// Grandfather valid v1 archives. Over-limit archives may shrink, never grow.
/proc/rmh_law_storage_growth_allowed(list/old_records, list/records)
	var/next_size = length(json_encode(records))
	return next_size <= RMH_LAW_MAX_NEW_SAVED_TEXT || next_size <= length(json_encode(old_records))
