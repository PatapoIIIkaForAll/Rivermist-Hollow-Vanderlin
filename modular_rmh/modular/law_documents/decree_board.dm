/// Event-driven, glazed public decree reader; no per-tick processing or local copies.
/obj/structure/rmh_decree_board
	name = "decree board"
	desc = "A glazed, enchanted board displaying the ruler's current decrees."
	icon = 'modular_rmh/icons/obj/structures/laws_objs.dmi'
	icon_state = "decree_board_1"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	integrity_failure = 0.5
	break_sound = "glassbreak"
	attacked_sound = 'sound/combat/hits/onglass/glasshit.ogg'
	SET_BASE_PIXEL(0, 32)
	var/tmp/datum/rmh_law_documents/documents
	var/tmp/announcement_timer

/obj/structure/rmh_decree_board/Initialize(mapload)
	. = ..()
	documents = rmh_get_law_documents()
	RegisterSignal(documents, COMSIG_RMH_DECREES_CHANGED, PROC_REF(on_decrees_changed))
	RegisterSignal(documents, COMSIG_PARENT_QDELETING, PROC_REF(on_documents_deleted))
	update_appearance()
	schedule_announcement()

/obj/structure/rmh_decree_board/Destroy()
	if(documents)
		UnregisterSignal(documents, list(COMSIG_RMH_DECREES_CHANGED, COMSIG_PARENT_QDELETING))
	documents = null
	if(announcement_timer)
		deltimer(announcement_timer)
		announcement_timer = null
	return ..()

/obj/structure/rmh_decree_board/proc/on_decrees_changed(datum/source)
	SIGNAL_HANDLER
	update_appearance()
	SStgui.update_uis(src)

/obj/structure/rmh_decree_board/proc/on_documents_deleted(datum/source)
	SIGNAL_HANDLER
	documents = null
	if(announcement_timer)
		deltimer(announcement_timer)
		announcement_timer = null
	update_appearance()
	SStgui.close_uis(src)

/obj/structure/rmh_decree_board/proc/schedule_announcement()
	if(documents && !announcement_timer)
		announcement_timer = addtimer(CALLBACK(src, PROC_REF(announce_count)), 10 MINUTES, TIMER_STOPPABLE)

/obj/structure/rmh_decree_board/proc/count_message()
	var/count = length(documents?.decrees)
	if(!count)
		return null
	var/message = "Active decrees: [count]. / Действующих указов: [count]."
	return obj_broken ? "A-active decrees / Д-действующих указов: [count]... кх-х..." : message

/obj/structure/rmh_decree_board/proc/announce_count()
	announcement_timer = null
	var/message = count_message()
	if(message)
		Shake(1, 1, 25)
		// Temporary cue: replace this stock sound when final audio is available.
		playsound(src, RMH_LAW_SOUND_BOARD, 60, FALSE)
		say(message, spans = list("info"))
	schedule_announcement()

/obj/structure/rmh_decree_board/update_icon_state()
	. = ..()
	icon_state = obj_broken ? "decree_board_3" : (length(documents?.decrees) ? "decree_board_2" : "decree_board_1")

/obj/structure/rmh_decree_board/atom_break(damage_flag, silent)
	. = ..()
	update_appearance()
	SStgui.close_uis(src)

/obj/structure/rmh_decree_board/atom_fix()
	. = ..()
	update_appearance()

/obj/structure/rmh_decree_board/proc/can_read_decrees(mob/user)
	return documents && !obj_broken && rmh_law_can_read(user, src)

/obj/structure/rmh_decree_board/attack_hand(mob/user)
	. = ..()
	if(. || !can_read_decrees(user))
		return
	ui_interact(user)

/obj/structure/rmh_decree_board/ui_status(mob/user, datum/ui_state/state)
	if(!can_read_decrees(user))
		return UI_CLOSE
	if(isobserver(user))
		return UI_UPDATE
	return ..()

/obj/structure/rmh_decree_board/ui_interact(mob/user, datum/tgui/ui)
	if(!can_read_decrees(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RmhDecree", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/rmh_decree_board/ui_data(mob/user)
	return list("language" = get_preferred_ui_language(user), "kind" = "board", "mode" = "read", "decrees" = can_read_decrees(user) ? documents.decrees : list())

/obj/structure/rmh_decree_board/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	..()
	// Reading/search/language are local; forged editing actions never reach THROAT.
	return FALSE

/// Shards inherit /glass, but are not repair panes.
/obj/structure/rmh_decree_board/proc/is_repair_glass(obj/item/material)
	if(!material || QDELETED(material))
		return FALSE
	if(material.type == /obj/item/natural/glass)
		return TRUE
	if(istype(material, /obj/item/natural/bundle/glass))
		var/obj/item/natural/bundle/glass/bundle = material
		return bundle.amount > 0
	return FALSE

/obj/structure/rmh_decree_board/proc/can_repair(mob/user, obj/item/material)
	return obj_broken && is_repair_glass(material) && user && user.is_holding(material) \
		&& in_range(user, src) && user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH)

/obj/structure/rmh_decree_board/attackby(obj/item/material, mob/user, list/modifiers)
	if(!can_repair(user, material))
		return ..()
	to_chat(user, span_notice(rmh_law_feedback(user, "I begin replacing the board's broken glass.")))
	if(!do_after(user, 5 SECONDS, src) || QDELETED(src) || QDELETED(user) || !can_repair(user, material))
		return TRUE
	// No sleep between final checks, consumption and repair: concurrent repairs cost once.
	if(istype(material, /obj/item/natural/bundle/glass))
		var/obj/item/natural/bundle/glass/bundle = material
		bundle.amount--
		if(!bundle.amount)
			qdel(bundle)
		else
			bundle.update_bundle()
	else
		if(!user.temporarilyRemoveItemFromInventory(material))
			return TRUE
		qdel(material)
	repair_damage(max_integrity)
	var/turf/debris_turf = get_turf(user)
	new /obj/item/natural/glass/shard(debris_turf)
	new /obj/effect/decal/cleanable/debris/glass(debris_turf)
	playsound(src, 'sound/misc/glassknock.ogg', 50, TRUE)
	return TRUE

/// PNG artwork shared by the decree board and physical-poster reader.
/datum/asset/simple/rmh_decree_backgrounds
	assets = list(
		"rmh-decree-board-main.png" = 'modular_rmh/modular/law_documents/assets/decree_board_main.png',
		"rmh-decree-board-button.png" = 'modular_rmh/modular/law_documents/assets/decree_board_button.png',
		"rmh-decree-poster-main.png" = 'modular_rmh/modular/law_documents/assets/decree_poster_main.png',
		"rmh-decree-poster-button.png" = 'modular_rmh/modular/law_documents/assets/decree_poster_button.png',
	)

/obj/structure/rmh_decree_board/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/rmh_decree_backgrounds)


/obj/structure/rmh_decree_board/attack_ghost(mob/dead/observer/user)
	ui_interact(user)
