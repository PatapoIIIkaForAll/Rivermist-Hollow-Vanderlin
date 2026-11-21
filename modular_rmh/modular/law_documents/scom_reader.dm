#define COMSIG_RMH_SCOM_MODE_CHANGED "rmh_scom_mode_changed"

/datum/asset/simple/namespaced/rmh_scom
	assets = list(
		"scom-frame.png" = 'modular_rmh/modular/law_documents/assets/scom-frame.png',
		"scom-frame-active.png" = 'modular_rmh/modular/law_documents/assets/scom-frame-active.png',
	)

/client
	/// Owned, at most one independent public-document reader per connected client.
	var/tmp/datum/browser/rmh_scom/rmh_scom_reader

/datum/browser/rmh_scom
	var/tmp/client/viewer
	var/tmp/datum/rmh_law_documents/documents
	var/tmp/datum/weakref/scom_ref
	var/mode = "normal"

/datum/browser/rmh_scom/New(mob/reader, obj/structure/fake_machine/scomm/source)
	// The reader owns its close Topic; it is not owned by a distant SCOM.
	. = ..(reader, "rmh_scom_laws", "", 448, 672, src)
	set_window_options(can_close = TRUE, can_minimize = TRUE, can_maximize = FALSE, can_resize = FALSE, titlebar = FALSE)
	viewer = reader.client
	documents = rmh_get_law_documents()
	if(source)
		scom_ref = WEAKREF(source)
		mode = source.rmh_reader_mode()
		RegisterSignal(source, COMSIG_RMH_SCOM_MODE_CHANGED, PROC_REF(on_scom_mode_changed))
		RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(on_scom_deleted))
	RegisterSignal(viewer, COMSIG_PARENT_QDELETING, PROC_REF(on_viewer_deleted))
	RegisterSignal(documents, COMSIG_RMH_LAW_PUBLISHED, PROC_REF(on_publication))
	RegisterSignal(documents, COMSIG_PARENT_QDELETING, PROC_REF(on_documents_deleted))

/datum/browser/rmh_scom/Destroy()
	var/obj/structure/fake_machine/scomm/source = scom_ref?.resolve()
	if(source)
		UnregisterSignal(source, list(COMSIG_RMH_SCOM_MODE_CHANGED, COMSIG_PARENT_QDELETING))
	scom_ref = null
	if(viewer)
		if(viewer.rmh_scom_reader == src)
			viewer.rmh_scom_reader = null
		UnregisterSignal(viewer, COMSIG_PARENT_QDELETING)
	if(documents)
		UnregisterSignal(documents, list(COMSIG_RMH_LAW_PUBLISHED, COMSIG_PARENT_QDELETING))
	viewer = null
	documents = null
	return ..()

/datum/browser/rmh_scom/proc/on_viewer_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/browser/rmh_scom/user_deleted(datum/source)
	. = ..()
	close()
	qdel(src)

/datum/browser/rmh_scom/proc/on_documents_deleted(datum/source)
	SIGNAL_HANDLER
	documents = null
	close()
	qdel(src)

/datum/browser/rmh_scom/proc/on_publication(datum/source, document_id)
	SIGNAL_HANDLER
	if(document_id == RMH_LAW_CODE)
		send_publication()

/datum/browser/rmh_scom/proc/publication_data()
	return list(
		"laws" = documents.law_code.content,
		"mode" = mode,
		"language" = get_preferred_ui_language(user),
	)

/datum/browser/rmh_scom/build_page()
	var/datum/asset/simple/namespaced/rmh_scom/assets = get_asset_datum(/datum/asset/simple/namespaced/rmh_scom)
	var/list/urls = assets.get_url_mappings()
	var/page = file2text('modular_rmh/modular/law_documents/assets/scom-reader.html')
	// JSON strings are quoted CSS URLs; mappings work with browse_rsc and CDN transports.
	page = replacetext(page, "@FRAME@", json_encode(urls["scom-frame.png"]))
	page = replacetext(page, "@ACTIVE@", json_encode(urls["scom-frame-active.png"]))
	page = replacetext(page, "@REF@", REF(src))
	// Encoded JSON cannot break out of its script string, even with hostile legal text.
	return replacetext(page, "@DATA@", url_encode(json_encode(publication_data())))

/datum/browser/rmh_scom/open(use_onclose = TRUE)
	if(!viewer || viewer.mob != user || !documents)
		return
	var/datum/asset/simple/namespaced/rmh_scom/assets = get_asset_datum(/datum/asset/simple/namespaced/rmh_scom)
	assets.send(user)
	return ..()

/datum/browser/rmh_scom/proc/send_publication()
	if(!viewer || viewer.mob != user || (!isobserver(user) && !user.is_literate()) || !documents)
		close()
		qdel(src)
		return
	viewer << output(url_encode(json_encode(publication_data())), "rmh_scom_laws.browser:rmhScomUpdate")

/datum/browser/rmh_scom/Topic(href, list/href_list)
	. = ..()
	if(!usr || usr != user || usr.client != viewer)
		return
	if(href_list["close"])
		close()
		qdel(src)
	else if(href_list["ready"])
		send_publication()
	// No legal mutations or remote SCOM controls exist on this Topic.

/obj/structure/fake_machine/scomm/proc/rmh_open_laws(mob/user, allow_remote = FALSE)
	if(obj_broken || !user?.client || !rmh_law_can_read(user, src, allow_remote))
		return FALSE
	if(!isobserver(user) && !allow_remote && !in_range(user, src))
		return FALSE
	var/action_flags = NEED_LITERACY
	if(!allow_remote)
		action_flags |= FORBID_TELEKINESIS_REACH
	if(!isobserver(user) && !user.can_perform_action(src, action_flags))
		return FALSE
	var/client/player = user.client
	if(player.rmh_scom_reader)
		player.rmh_scom_reader.close()
		QDEL_NULL(player.rmh_scom_reader)
	player.rmh_scom_reader = new(user, src)
	player.rmh_scom_reader.open()
	return TRUE



/obj/structure/fake_machine/scomm/Topic(href, list/href_list)
	. = ..()
	if(href_list["rmh_laws"])
		// Existing chat links may reopen the public laws after walking away.
		rmh_open_laws(usr, allow_remote = TRUE)







/datum/browser/rmh_scom/proc/on_scom_mode_changed(obj/structure/fake_machine/scomm/source)
	SIGNAL_HANDLER
	var/next_mode = source.rmh_reader_mode()
	if(mode == next_mode)
		return
	mode = next_mode
	if(viewer)
		viewer << output(mode, "rmh_scom_laws.browser:rmhScomMode")

/datum/browser/rmh_scom/proc/on_scom_deleted(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_RMH_SCOM_MODE_CHANGED, COMSIG_PARENT_QDELETING))
	// Retain the last colour; the laws window remains independent of the device.
	scom_ref = null

/obj/structure/fake_machine/scomm/proc/rmh_reader_mode()
	if(obj_broken || !speaking || !listening)
		return "muted"
	return garrisonline ? "garrison" : "normal"

/obj/structure/fake_machine/scomm/update_icon_state()
	. = ..()
	SEND_SIGNAL(src, COMSIG_RMH_SCOM_MODE_CHANGED)

/obj/structure/fake_machine/scomm/atom_break(damage_flag)
	. = ..()
	SEND_SIGNAL(src, COMSIG_RMH_SCOM_MODE_CHANGED)

/obj/structure/fake_machine/scomm/atom_fix()
	. = ..()
	SEND_SIGNAL(src, COMSIG_RMH_SCOM_MODE_CHANGED)

#undef COMSIG_RMH_SCOM_MODE_CHANGED

/obj/structure/fake_machine/scomm/attack_ghost(mob/dead/observer/user)
	return rmh_open_laws(user, allow_remote = TRUE)
