/datum/lock/key/rmh_scribe
	lockid_list = list(ACCESS_HAND)
	locked = TRUE
	difficulty = 1

/datum/lock/key/rmh_scribe/lock(user, obj/item, silent = FALSE)
	. = ..()
	holder?.update_appearance()
	SStgui.update_uis(holder)

/datum/lock/key/rmh_scribe/unlock(user, obj/item, silent = FALSE)
	. = ..()
	holder?.update_appearance()
	SStgui.update_uis(holder)

/obj/structure/rmh_scribe_stand
	name = "scribe's stand"
	desc = "A locked writing stand for the official laws. The master and councilor hold its keys."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "book_binder"
	density = TRUE
	anchored = TRUE
	lock = /datum/lock/key/rmh_scribe
	var/tmp/datum/rmh_law_documents/documents

/obj/structure/rmh_scribe_stand/Initialize(mapload)
	. = ..()
	documents = rmh_get_law_documents()
	RegisterSignal(documents, list(COMSIG_RMH_LAW_PUBLISHED, COMSIG_RMH_DECREES_CHANGED), PROC_REF(on_publication))
	RegisterSignal(documents, COMSIG_PARENT_QDELETING, PROC_REF(on_documents_deleted))
	update_appearance()

/obj/structure/rmh_scribe_stand/Destroy()
	if(documents)
		UnregisterSignal(documents, list(COMSIG_RMH_LAW_PUBLISHED, COMSIG_RMH_DECREES_CHANGED, COMSIG_PARENT_QDELETING))
	documents = null
	return ..()

/obj/structure/rmh_scribe_stand/update_overlays()
	. = ..()
	// Reuse the existing binder and the Tome's two cover states, without binary edits.
	var/book_state = locked() ? "lawtome_0" : "lawtome_1"
	var/mutable_appearance/book = mutable_appearance('icons/roguetown/items/books.dmi', book_state)
	book.pixel_y = 8
	. += book

/obj/structure/rmh_scribe_stand/proc/on_publication(datum/source, document_id)
	SIGNAL_HANDLER
	SStgui.update_uis(src)

/obj/structure/rmh_scribe_stand/proc/on_documents_deleted(datum/source)
	SIGNAL_HANDLER
	documents = null
	SStgui.close_uis(src)

/obj/structure/rmh_scribe_stand/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.can_read(src, TRUE))
		ui_interact(user)

/obj/structure/rmh_scribe_stand/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return documents ? UI_UPDATE : UI_CLOSE
	return ..()

/obj/structure/rmh_scribe_stand/ui_interact(mob/user, datum/tgui/ui)
	if(!documents)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RmhScribeStand", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/rmh_scribe_stand/proc/can_edit(mob/user)
	return documents && ishuman(user) && !obj_broken && !locked() && Adjacent(user) \
		&& rmh_law_editor_role(user) && user.can_read(src, TRUE) \
		&& user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH)

/obj/structure/rmh_scribe_stand/ui_data(mob/user)
	if(!documents || !user)
		return list()
	var/role = rmh_law_editor_role(user)
	var/list/saved = can_edit(user) ? rmh_law_saved_record(user, role) : null
	var/list/notes = can_edit(user) ? rmh_law_note_record(user, role) : null
	var/can_read = rmh_law_can_read(user, src)
	var/list/decrees = list()
	if(can_read)
		decrees = documents.decrees
	return list(
		"language" = get_preferred_ui_language(user),
		"max_action_chunks" = CONFIG_GET(number/tgui_max_chunk_count),
		"epoch" = documents.epoch,
		"decrees" = decrees,
		"role" = role,
		"character" = rmh_law_character(user),
		"editor_key" = json_encode(list(user.ckey, rmh_law_character(user), role)),
		"can_edit" = can_edit(user),
		"locked" = locked(),
		"code_revision" = documents.law_code.revision,
		"book_revision" = documents.lawbook.revision,
		"law_code" = can_read ? documents.law_code.content : list(),
		"lawbook" = can_read ? documents.lawbook.content : list("title" = "", "chapters" = list()),
		"saved" = saved ? saved["documents"] : null,
		"notes" = can_edit(user) ? list("revision" = notes ? notes["revision"] : 1, "entries" = notes ? notes["entries"] : list()) : null,
	)

/obj/structure/rmh_scribe_stand/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui?.user
	// /obj/structure/ui_act does not propagate the base rejection; check explicitly.
	if(!user || usr != user || !documents || state.can_use_topic(src, user) != UI_INTERACTIVE)
		return FALSE
	if(action == "refresh")
		return Adjacent(user) && user.can_read(src, TRUE)
	if(!can_edit(user))
		return FALSE
	if(params["editor_key"] != json_encode(list(user.ckey, rmh_law_character(user), rmh_law_editor_role(user))))
		return FALSE
	if(action == "save_notes")
		if(params["epoch"] != documents.epoch || !istext(params["content"]) || length(params["content"]) > RMH_LAW_MAX_PAYLOAD)
			return FALSE
		var/list/notes_payload
		try
			notes_payload = json_decode(params["content"])
		catch
			return FALSE
		var/error = rmh_save_law_notes(user, rmh_law_editor_role(user), params["revision"], notes_payload)
		if(error)
			to_chat(user, span_warning(rmh_law_feedback(user, error)))
		else
			to_chat(user, span_notice(rmh_law_feedback(user, "Personal notes saved.")))
		return TRUE
	if(action == "publish_decree_translation")
		if(params["epoch"] != documents.epoch)
			return FALSE
		var/translation_error = documents.publish_decree_translation(params["id"], params["revision"], params["text_en"])
		if(translation_error)
			to_chat(user, span_warning(rmh_law_feedback(user, translation_error)))
		else
			log_game("[key_name(user)] published an English translation of [params["id"]] at [AREACOORD(src)].")
		// The publication signal already updates the stand and remote readers.
		return FALSE
	if(!(action in list("publish", "save_draft", "delete_draft")))
		return FALSE
	var/datum/rmh_law_document/doc = documents.document(params["document"])
	if(!doc || params["epoch"] != documents.epoch)
		return FALSE
	if(action == "delete_draft")
		return rmh_delete_law_draft(user, rmh_law_editor_role(user), params["document"])
	var/revision = params["revision"]
	if(!isnum(revision) || revision < 1 || revision != round(revision) || revision > doc.revision)
		return FALSE
	if(action == "publish" && revision != doc.revision)
		to_chat(user, span_warning(rmh_law_feedback(user, "The published revision changed. Compare with the current document before publishing.")))
		return TRUE
	var/raw = params["content"]
	if(!istext(raw) || length(raw) > RMH_LAW_MAX_PAYLOAD)
		to_chat(user, span_warning(rmh_ui_text(user, "Запрос слишком велик или повреждён. Рабочий текст не опубликован.", "The request is oversized or malformed. Your working text was not published.")))
		return FALSE
	var/list/payload
	try
		payload = json_decode(raw)
	catch
		to_chat(user, span_warning(rmh_ui_text(user, "Повреждённый запрос. Рабочий текст не опубликован.", "Malformed request. Your working text was not published.")))
		return FALSE
	var/list/normalized = doc.normalize(payload, check_ids = action == "publish", for_draft = action == "save_draft")
	if(!normalized)
		to_chat(user, span_warning(rmh_law_feedback(user, "Invalid document: check text limits and identifiers.")))
		return FALSE
	var/error
	if(action == "publish")
		error = documents.publish(params["document"], revision, normalized, user, params["announce"] == TRUE)
		if(!error)
			to_chat(user, span_notice(rmh_law_revision_message(params["document"], doc.revision, get_preferred_ui_language(user))))
			if(!documents.last_announcement_sent)
				to_chat(user, span_notice(rmh_ui_text(user, "Документ сохранён без глобального оглашения (не запрошено либо действует перезарядка).", "Published without a global announcement (not requested or on cooldown).")))
			// The publication signal already pushes all stands once.
			return FALSE
	else
		error = rmh_save_law_draft(user, rmh_law_editor_role(user), params["document"], revision, normalized)
	if(error)
		to_chat(user, span_warning(rmh_law_feedback(user, error)))
	else
		to_chat(user, span_notice(rmh_law_feedback(user, "Personal draft saved. The official document has not changed.")))
	return TRUE


/obj/structure/rmh_scribe_stand/attack_ghost(mob/dead/observer/user)
	ui_interact(user)


/obj/structure/rmh_scribe_stand/picked(mob/living/user, obj/tool, skill_level, difficulty)
	. = ..()
	update_appearance()
	SStgui.update_uis(src)
