GLOBAL_DATUM(rmh_law_documents, /datum/rmh_law_documents)

/// Lazy: GLOB initialization order must not select the starter lawset twice.
/proc/rmh_get_law_documents()
	RETURN_TYPE(/datum/rmh_law_documents)
	if(!GLOB.rmh_law_documents)
		GLOB.rmh_law_documents = new
	return GLOB.rmh_law_documents

/// Two independent round-local publications. Saved drafts never initialize these.
/datum/rmh_law_documents
	var/datum/rmh_law_document/code/law_code
	var/datum/rmh_law_document/book/lawbook
	var/epoch
	var/has_publication = FALSE
	var/role_seeded = FALSE
	var/last_announcement_sent = FALSE

/datum/rmh_law_documents/New()
	. = ..()
	epoch = "[world.realtime]-[world.timeofday]"
	law_code = new
	lawbook = new
	sync_legacy_code()
	lawbook.seed_tome()
	sync_legacy_decrees()

/datum/rmh_law_documents/Destroy()
	if(GLOB.rmh_law_documents == src)
		GLOB.rmh_law_documents = null
	decrees = null
	QDEL_NULL(law_code)
	QDEL_NULL(lawbook)
	return ..()

/datum/rmh_law_documents/proc/document(document_id)
	RETURN_TYPE(/datum/rmh_law_document)
	switch(document_id)
		if(RMH_LAW_CODE)
			return law_code
		if(RMH_LAW_BOOK)
			return lawbook

/// Import starter laws and character preferences; THROAT cannot edit these.
/datum/rmh_law_documents/proc/sync_legacy_code()
	var/list/old = law_code.content
	var/list/next = list()
	var/list/used_ids = list()
	for(var/legacy_text in GLOB.laws_of_the_land)
		var/text = html_decode(legacy_text)
		var/list/entry
		for(var/list/candidate as anything in old)
			if(candidate["text"] == text && !(candidate["id"] in used_ids))
				entry = candidate.Copy()
				break
		if(!entry)
			entry = list("id" = law_code.allocate_id(), "text" = text, "text_en" = "")
		used_ids += entry["id"]
		next += list(entry)
	if(json_encode(old) == json_encode(next))
		return FALSE
	law_code.content = next
	law_code.revision++
	SEND_SIGNAL(src, COMSIG_RMH_LAW_PUBLISHED, RMH_LAW_CODE)
	return TRUE

/// No sleeps between version comparison and replacing the published snapshot.
/datum/rmh_law_documents/proc/publish(document_id, expected_revision, list/payload, mob/publisher, announce = FALSE)
	last_announcement_sent = FALSE
	var/datum/rmh_law_document/doc = document(document_id)
	if(!doc || expected_revision != doc.revision)
		return "The published revision changed. Compare with the current document before publishing."
	var/list/normalized = doc.normalize(payload, check_ids = TRUE)
	if(!normalized)
		return "Invalid document: check text limits, identifiers and document structure."
	var/list/before = doc.content
	// Identical publications neither invalidate editors nor trigger resonance.
	if(json_encode(normalized) == json_encode(doc.normalize(before, check_ids = FALSE)))
		return null
	doc.assign_ids(normalized)
	doc.content = normalized
	doc.revision++
	has_publication = TRUE
	if(document_id == RMH_LAW_CODE)
		var/list/projection = list()
		for(var/list/entry as anything in normalized)
			// Legacy consumers use browser HTML; official TGUI content stays plain text.
			projection += html_encode(entry["text"])
		GLOB.laws_of_the_land = projection
	SEND_SIGNAL(src, COMSIG_RMH_LAW_PUBLISHED, document_id)
	if(publisher)
		rmh_log_law_publication(publisher, document_id, doc.revision, before, normalized)
		record_round_statistic(STATS_LAWS_AND_DECREES_MADE)
		if(announce && SScommunications.can_announce(publisher))
			SScommunications.nonsilicon_message_cooldown = world.time + 30 SECONDS
			rmh_announce_law_publication(document_id, before, normalized)
			last_announcement_sent = TRUE
	return null

/datum/rmh_law_documents/proc/seed_role_preferences(mob/living/spawned, datum/preferences/prefs)
	if(!prefs || !spawned || spawned.islatejoin || spawned.mind?.late_joiner || role_seeded || has_publication || length(GLOB.lord_decrees))
		return FALSE
	role_seeded = TRUE
	var/list/laws = prefs.read_preference(/datum/preference/list_type/role_setting/monarch_law)
	var/list/initial_decrees = prefs.read_preference(/datum/preference/list_type/role_setting/monarch_decree)
	if(length(laws))
		GLOB.laws_of_the_land = list()
		for(var/law in laws)
			GLOB.laws_of_the_land += trim(law)
	if(length(initial_decrees))
		GLOB.lord_decrees = list()
		for(var/decree in initial_decrees)
			GLOB.lord_decrees += trim(decree)
	sync_legacy_code()
	sync_legacy_decrees()
	return TRUE

/datum/job/burgmeister/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	rmh_get_law_documents().seed_role_preferences(spawned, player_client?.prefs)
