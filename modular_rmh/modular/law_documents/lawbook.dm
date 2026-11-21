/// Existing mapped/vended Tomes become views of the one published lawbook.
/obj/item/book/law
	desc = "A lawbook inlaid with resonant minerals. Its pages follow the official publication and tremble when amended."
	resistance_flags = FIRE_PROOF
	firefuel = 0
	override_find_book = TRUE
	var/tmp/datum/rmh_law_documents/documents

/obj/item/book/law/Initialize(mapload)
	. = ..()
	documents = rmh_get_law_documents()
	RegisterSignal(documents, COMSIG_RMH_LAW_PUBLISHED, PROC_REF(on_lawbook_publication))
	RegisterSignal(documents, COMSIG_PARENT_QDELETING, PROC_REF(on_lawbook_documents_deleted))

/obj/item/book/law/Destroy()
	if(documents)
		UnregisterSignal(documents, list(COMSIG_RMH_LAW_PUBLISHED, COMSIG_PARENT_QDELETING))
	documents = null
	return ..()

/obj/item/book/law/proc/on_lawbook_publication(datum/source, document_id)
	SIGNAL_HANDLER
	if(document_id != RMH_LAW_BOOK)
		return
	SStgui.update_uis(src)
	// Native animation only on exposed copies; books in shelves/bags do no visual work.
	// The global amendment announcement already supplies the temporary sound cue.
	if(isturf(loc) || ismob(loc))
		rmh_resonate()

/obj/item/book/law/proc/on_lawbook_documents_deleted(datum/source)
	SIGNAL_HANDLER
	documents = null
	SStgui.close_uis(src)

/obj/item/book/law/attack_self(mob/user, list/modifiers)
	// Replace only this subtype's legacy HUD/browser reader.
	return read(user)

/obj/item/book/law/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!open)
		SStgui.close_uis(src)

/obj/item/book/law/read(mob/user)
	if(isobserver(user))
		ui_interact(user)
		return TRUE
	if(!user || !in_range(user, src) || !user.can_read(src))
		return FALSE
	if(!user.can_perform_action(src, NEED_LITERACY|FORBID_TELEKINESIS_REACH))
		return FALSE
	if(!open)
		attack_hand_secondary(user)
	if(!rmh_can_read(user) || ui_status(user, GLOB.default_state) < UI_UPDATE)
		return FALSE
	ui_interact(user)
	SEND_SIGNAL(user, COMSIG_BOOK_READ)
	return TRUE

/obj/item/book/law/proc/rmh_can_read(mob/user)
	return documents && (open || isobserver(user)) && rmh_law_can_read(user, src)

/obj/item/book/law/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user) && documents)
		return UI_UPDATE
	if(!rmh_can_read(user))
		return UI_CLOSE
	return ..()

/obj/item/book/law/ui_interact(mob/user, datum/tgui/ui)
	if(!rmh_can_read(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RmhLawbook", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/book/law/ui_data(mob/user)
	if(!rmh_can_read(user))
		return list("language" = get_preferred_ui_language(user), "revision" = 0, "lawbook" = list("title" = "", "chapters" = list()))
	return list("language" = get_preferred_ui_language(user), "revision" = documents.lawbook.revision, "lawbook" = documents.lawbook.content)

/obj/item/book/law/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	..()
	// Intentionally no domain actions, including forged editor/draft requests.
	// Contents navigation and search are entirely local to the reader.
	return FALSE

/// Add one Tome alongside the existing recipe selection; do not replace recipes.
/obj/structure/bookcase/random_recipes/Initialize(mapload)
	. = ..()
	if(!(locate(/obj/item/book/law) in src))
		new /obj/item/book/law(src)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/bookcase/fancy/random_recipes/Initialize(mapload)
	. = ..()
	if(!(locate(/obj/item/book/law) in src))
		new /obj/item/book/law(src)
	update_appearance(UPDATE_ICON_STATE)


/obj/item/book/law/proc/rmh_resonate()
	var/rest_x = pixel_x
	var/rest_y = pixel_y
	animate(src, pixel_x = rest_x + 3, pixel_y = rest_y + 1, time = 1, loop = 4)
	animate(pixel_x = rest_x - 3, pixel_y = rest_y - 1, time = 1)
	animate(pixel_x = rest_x, pixel_y = rest_y, time = 1)

/obj/item/book/law/attack_ghost(mob/dead/observer/user)
	return read(user)

