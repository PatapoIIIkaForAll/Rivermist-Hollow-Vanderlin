#define RMH_POSTER_FORGE_DELAY (0.5 SECONDS)
#define RMH_POSTER_REMOVE_DELAY (5 SECONDS)

/// Private physical snapshot: no publication subscriptions or round registry.
/obj/item/rmh_decree_poster
	name = "blank decree poster"
	desc = "A sheet of prepared parchment."
	icon = 'modular_rmh/icons/obj/structures/laws_objs.dmi'
	icon_state = "decree_poster_3"
	w_class = WEIGHT_CLASS_TINY
	max_integrity = 30
	resistance_flags = FLAMMABLE
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 0
	var/list/snapshot
	var/damaged = FALSE
	var/torn_title
	var/torn_title_en
	var/content_revision = 0
	var/tmp/prompt_mode = "read"
	var/tmp/prompt_token = 0
	var/tmp/forging = FALSE
	var/tmp/datum/weakref/editor_ref
	var/tmp/datum/weakref/source_ref
	var/tmp/datum/weakref/tool_ref

/obj/item/rmh_decree_poster/update_icon_state()
	. = ..()
	icon_state = damaged ? "decree_poster_2" : (snapshot ? "decree_poster_1" : "decree_poster_3")

/obj/item/rmh_decree_poster/Destroy()
	snapshot = null
	torn_title = null
	torn_title_en = null
	editor_ref = null
	source_ref = null
	tool_ref = null
	return ..()

/obj/item/rmh_decree_poster/examine(mob/user)
	. = ..()
	if(damaged)
		. += span_notice(rmh_ui_text(user, "Надпись порвана и не поддаётся прочтению.", "The torn writing is illegible."))


/obj/item/rmh_decree_poster/proc/tear_edges()
	if(damaged)
		return FALSE
	torn_title = rmh_decree_title(snapshot?["text"])
	torn_title_en = rmh_decree_title(snapshot?["text_en"])
	damaged = TRUE
	// Keep only the title: no stale UI, forgery or later pickup can recover the body.
	snapshot = null
	content_revision++
	SStgui.close_uis(src)
	reset_prompt()
	refresh_title()
	atom_integrity = min(atom_integrity, max_integrity / 2)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/item/rmh_decree_poster/proc/copy_decree(list/entry)
	if(damaged || snapshot || !islist(entry) || !rmh_law_text(entry["text"], RMH_LAW_MAX_TEXT, FALSE))
		return FALSE
	var/english = isnull(entry["text_en"]) ? "" : entry["text_en"]
	if(!rmh_law_text(english, RMH_LAW_MAX_TEXT))
		return FALSE
	content_revision++
	snapshot = list("id" = "poster", "text" = entry["text"], "text_en" = english, "revision" = content_revision)
	refresh_title()
	desc = "A parchment bearing a copy of a decree."
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/// Only explicit physical forgery may replace a filled snapshot.
/obj/item/rmh_decree_poster/proc/replace_forgery(text, english, rank, expected_revision)
	if(!snapshot || expected_revision != content_revision || !rmh_law_text(text, RMH_LAW_MAX_TEXT, FALSE) || !rmh_law_text(english, RMH_LAW_MAX_TEXT) \
		|| length_char(text) + length_char(english) > RMH_POSTER_MAX_FORGERY)
		return FALSE
	content_revision++
	snapshot = list("id" = "poster", "text" = text, "text_en" = english, "revision" = content_revision, \
		"marks" = rmh_poster_marks(text, rank), "marks_en" = rmh_poster_marks(english, rank))
	refresh_title()
	return TRUE

/// Legacy get_skill_level returns ranks (0..6), not the attribute's 0..60 scale.
/proc/rmh_poster_marks(text, rank)
	var/chance = clamp((SKILL_RANK_EXPERT - rank) * 10, 0, 40)
	var/list/marks = list()
	var/count = length_char(text)
	marks.len = count
	if(!count)
		return marks
	for(var/index in 1 to count)
		var/letter = copytext_char(text, index, index + 1)
		marks[index] = uppertext(letter) != LOWER_TEXT(letter) && prob(chance) ? pick(1, 2) : 0
	return marks

/obj/item/rmh_decree_poster/proc/can_handle(mob/user)
	if(!isliving(user))
		return FALSE
	var/atom/movable/host = ui_host(user)
	if(host != src)
		var/obj/structure/rmh_decree_poster/mount = host
		if(!istype(mount) || mount.poster != src || !isturf(mount.loc))
			return FALSE
	else if(!user.is_holding(src) && !isturf(loc))
		return FALSE
	// Adjacent does not recurse from an item through a structure container.
	return host.Adjacent(user) && user.can_perform_action(host, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH)

/obj/item/rmh_decree_poster/proc/can_read_poster(mob/user)
	return !damaged && ((isobserver(user) && snapshot) || (can_handle(user) && user.can_read(ui_host(user), TRUE)))

/obj/item/rmh_decree_poster/proc/copy_source()
	var/obj/structure/source = source_ref?.resolve()
	if(!istype(source) || source.obj_broken)
		return null
	if(istype(source, /obj/structure/rmh_scribe_stand))
		var/obj/structure/rmh_scribe_stand/stand = source
		return stand.documents
	if(istype(source, /obj/structure/rmh_decree_board))
		var/obj/structure/rmh_decree_board/board = source
		return board.documents
	return null

/obj/item/rmh_decree_poster/proc/can_copy(mob/user)
	var/obj/structure/source = source_ref?.resolve()
	return !snapshot && user?.is_holding(src) && can_read_poster(user) && source \
		&& source.Adjacent(user) && user.can_read(source, TRUE) && copy_source()

/obj/item/rmh_decree_poster/proc/can_forge(mob/user)
	var/obj/item/tattoo_machine/tool = tool_ref?.resolve()
	return snapshot && can_read_poster(user) && istype(tool) && user.is_holding(tool)

/obj/item/rmh_decree_poster/proc/reset_prompt()
	prompt_mode = "read"
	prompt_token++
	editor_ref = null
	source_ref = null
	tool_ref = null
	forging = FALSE

/obj/item/rmh_decree_poster/pre_attack(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(istype(target, /obj/structure/rmh_scribe_stand) || istype(target, /obj/structure/rmh_decree_board))
		if(snapshot || !user.is_holding(src) || !can_read_poster(user) || !target.Adjacent(user))
			return TRUE
		SStgui.close_uis(src)
		source_ref = WEAKREF(target)
		if(!can_copy(user))
			reset_prompt()
			return TRUE
		editor_ref = WEAKREF(user)
		prompt_mode = "copy"
		ui_interact(user)
		return TRUE
	if(iswallturf(target))
		mount_on_wall(user, target)
		return TRUE

/obj/item/rmh_decree_poster/attackby(obj/item/tool, mob/user, list/modifiers)
	if(istype(tool, /obj/item/tattoo_machine))
		begin_forgery(user, tool)
		return TRUE
	return ..()

/obj/item/rmh_decree_poster/proc/begin_forgery(mob/user, obj/item/tattoo_machine/tool)
	if(!snapshot || forging || !can_read_poster(user) || !user.is_holding(tool))
		return FALSE
	SStgui.close_uis(src)
	editor_ref = WEAKREF(user)
	tool_ref = WEAKREF(tool)
	prompt_mode = "forge"
	ui_interact(user)
	return TRUE

/obj/item/rmh_decree_poster/attack_self(mob/user, list/modifiers)
	. = ..()
	if(!. && snapshot)
		ui_interact(user)

/obj/item/rmh_decree_poster/ui_host(mob/user)
	if(istype(loc, /obj/structure/rmh_decree_poster))
		return loc
	return ..()

/obj/item/rmh_decree_poster/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return snapshot && !damaged ? UI_UPDATE : UI_CLOSE
	if(!can_read_poster(user))
		return UI_CLOSE
	if(editor_ref?.resolve() == user)
		if(prompt_mode == "copy" && !can_copy(user))
			return UI_CLOSE
		if(prompt_mode == "forge" && !can_forge(user))
			return UI_CLOSE
	if(istype(loc, /obj/structure/rmh_decree_poster))
		// The visible mount supplies the normal distance/status checks.
		return loc.ui_status(user, state)
	return ..()

/obj/item/rmh_decree_poster/ui_interact(mob/user, datum/tgui/ui)
	if(!can_read_poster(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RmhDecree", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/rmh_decree_poster/ui_close(mob/user)
	. = ..()
	if(editor_ref?.resolve() == user)
		reset_prompt()

/obj/item/rmh_decree_poster/ui_data(mob/user)
	if(!can_read_poster(user))
		return list("language" = get_preferred_ui_language(user), "kind" = "poster", "mode" = "read", "decrees" = list())
	var/mode = editor_ref?.resolve() == user ? prompt_mode : "read"
	var/datum/rmh_law_documents/store = mode == "copy" ? copy_source() : null
	return list("language" = get_preferred_ui_language(user), "kind" = "poster", "mode" = mode, "token" = prompt_token, "revision" = content_revision, \
		"epoch" = store?.epoch, "busy" = forging, "forge_max_characters" = RMH_POSTER_MAX_FORGERY, \
		"decrees" = store ? store.decrees : (snapshot ? list(snapshot) : list()))

/obj/item/rmh_decree_poster/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui?.user
	if(!user || usr != user || state.can_use_topic(ui_host(user), user) != UI_INTERACTIVE \
		|| editor_ref?.resolve() != user || params["token"] != prompt_token || params["revision"] != content_revision || forging)
		return FALSE
	if(action == "copy" && prompt_mode == "copy" && can_copy(user))
		var/datum/rmh_law_documents/store = copy_source()
		if(params["epoch"] != store.epoch)
			return FALSE
		var/list/chosen
		for(var/list/entry as anything in store.decrees)
			if(entry["id"] == params["id"] && entry["revision"] == params["decree_revision"])
				chosen = entry
				break
		if(!chosen)
			to_chat(user, span_warning(rmh_law_feedback(user, "The decree changed or was revoked. Choose from the current list.")))
			SStgui.update_uis(src)
			return FALSE
		if(!copy_decree(chosen))
			to_chat(user, span_warning(rmh_law_feedback(user, "This decree exceeds the poster's text limit.")))
			return FALSE
		SStgui.close_uis(src)
		log_game("[key_name(user)] copied a decree onto [src] at [AREACOORD(src)].")
		ui_interact(user)
		return FALSE
	if(action == "forge" && prompt_mode == "forge" && can_forge(user))
		var/text = params["text"]
		var/english = params["text_en"]
		if(!rmh_law_text(text, RMH_LAW_MAX_TEXT, FALSE) || !rmh_law_text(english, RMH_LAW_MAX_TEXT))
			return FALSE
		if(length_char(text) + length_char(english) > RMH_POSTER_MAX_FORGERY)
			to_chat(user, span_warning(rmh_ui_text(user, "Подделка ограничена 360 символами суммарно в RU+EN (180 секунд). Сократите текст.", "Forgery is limited to 360 characters across RU+EN (180 seconds). Shorten the text.")))
			return FALSE
		forging = TRUE
		SStgui.update_uis(src)
		INVOKE_ASYNC(src, PROC_REF(complete_forgery), user, text, english, prompt_token, content_revision, loc)
	return FALSE

/obj/item/rmh_decree_poster/proc/forgery_active(mob/user, token, revision, atom/original_location)
	return forging && token == prompt_token && revision == content_revision && original_location == loc && !QDELETED(user) && can_forge(user)

/obj/item/rmh_decree_poster/proc/complete_forgery(mob/user, text, english, token, revision, atom/original_location)
	var/completed = do_after(user, (length_char(text) + length_char(english)) * RMH_POSTER_FORGE_DELAY, ui_host(user), extra_checks = CALLBACK(src, PROC_REF(forgery_active), user, token, revision, original_location))
	if(QDELETED(src) || token != prompt_token)
		return
	var/valid = completed && forgery_active(user, token, revision, original_location)
	forging = FALSE
	if(!valid)
		SStgui.update_uis(src)
		return
	if(!replace_forgery(text, english, user.get_skill_level(/datum/attribute/skill/misc/reading), revision))
		return
	log_game("[key_name(user)] forged [src] at [AREACOORD(src)].")
	SStgui.close_uis(src)
	ui_interact(user)

/obj/item/rmh_decree_poster/proc/mount_on_wall(mob/user, turf/closed/wall/wall)
	if(!snapshot || forging || !user?.is_holding(src) || !can_handle(user) || !iswallturf(wall))
		return FALSE
	var/turf/floor = get_turf(user)
	if(user.loc != floor || !isopenturf(floor) || get_dist(floor, wall) != 1 || !(get_dir(floor, wall) in GLOB.cardinals))
		return FALSE
	for(var/obj/structure/rmh_decree_poster/other in floor)
		if(other.attached_wall == wall)
			to_chat(user, span_warning(rmh_law_feedback(user, "There is already a poster on this face of the wall.")))
			return FALSE
	SStgui.close_uis(src)
	var/obj/structure/rmh_decree_poster/mount = new(floor)
	if(!user.transferItemToLoc(src, mount))
		qdel(mount)
		return FALSE
	if(!mount.attach_poster(src, wall))
		forceMove(floor)
		user.put_in_hands(src)
		qdel(mount)
		return FALSE
	return TRUE

/// The mount owns the one sheet; removing it transfers that same sheet back.
/obj/structure/rmh_decree_poster
	name = "decree poster"
	desc = "A decree posted on the wall."
	icon = 'modular_rmh/icons/obj/structures/laws_objs.dmi'
	icon_state = "decree_poster_1"
	anchored = TRUE
	density = FALSE
	interaction_flags_atom = NONE
	resistance_flags = FLAMMABLE
	max_integrity = 30
	var/tmp/obj/item/rmh_decree_poster/poster
	var/tmp/removing = FALSE
	var/tmp/turf/closed/wall/attached_wall


/obj/structure/rmh_decree_poster/update_icon_state()
	. = ..()
	icon_state = poster?.damaged ? "decree_poster_2" : "decree_poster_1"

/obj/structure/rmh_decree_poster/Initialize(mapload)
	. = ..()
	// Core steal_action only handles mobs. Intercept STEAL locally before that route.
	RegisterSignal(src, COMSIG_ATOM_CLICKEDON, PROC_REF(on_poster_click))

/obj/structure/rmh_decree_poster/proc/on_poster_click(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(user) || !LAZYACCESS(modifiers, MIDDLE_CLICK) || !istype(user.mmb_intent, INTENT_STEAL))
		return NONE
	if(user.next_move <= world.time)
		INVOKE_ASYNC(src, PROC_REF(try_steal), user)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/structure/rmh_decree_poster/proc/can_remove(mob/living/user, tear)
	if(!poster || poster.damaged || poster.forging || !isliving(user) || !user.Adjacent(src) || !user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return FALSE
	if(tear)
		return istype(user.rmb_intent, /datum/rmb_intent/strong)
	return istype(user.rmb_intent, /datum/rmb_intent/weak) && user.get_skill_level(/datum/attribute/skill/misc/reading) >= SKILL_RANK_EXPERT

/obj/structure/rmh_decree_poster/proc/try_steal(mob/living/user)
	var/tear = istype(user?.rmb_intent, /datum/rmb_intent/strong)
	if(removing || !can_remove(user, tear))
		return FALSE
	var/obj/item/rmh_decree_poster/sheet = poster
	var/turf/closed/wall/wall = attached_wall
	removing = TRUE
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(tear)
		playsound(src, 'sound/foley/cloth_rip.ogg', 60, FALSE)
	var/completed = do_after(user, RMH_POSTER_REMOVE_DELAY, src)
	if(QDELETED(src))
		return FALSE
	removing = FALSE
	if(!completed || QDELETED(user) || QDELETED(sheet) || poster != sheet || attached_wall != wall || !can_remove(user, tear))
		return FALSE
	if(tear)
		sheet.tear_edges()
		update_appearance(UPDATE_ICON_STATE)
		playsound(src, 'sound/foley/cloth_rip.ogg', 60, FALSE)
	else
		detach_poster(user)
	return TRUE

/obj/structure/rmh_decree_poster/proc/attach_poster(obj/item/rmh_decree_poster/sheet, turf/closed/wall/wall)
	if(poster || !sheet?.snapshot || sheet.loc != src || !iswallturf(wall))
		return FALSE
	var/direction = get_dir(src, wall)
	if(get_dist(src, wall) != 1 || !(direction in GLOB.cardinals))
		return FALSE
	poster = sheet
	name = sheet.name
	attached_wall = wall
	dir = direction
	base_pixel_x = (direction == EAST ? 32 : (direction == WEST ? -32 : 0))
	base_pixel_y = (direction == NORTH ? 32 : (direction == SOUTH ? -32 : 0))
	pixel_x = base_pixel_x
	pixel_y = base_pixel_y
	RegisterSignal(sheet, COMSIG_PARENT_QDELETING, PROC_REF(on_sheet_deleted))
	RegisterSignal(sheet, COMSIG_MOVABLE_MOVED, PROC_REF(on_sheet_moved))
	RegisterSignal(wall, list(COMSIG_TURF_CHANGE, COMSIG_PARENT_QDELETING), PROC_REF(on_wall_changed))
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/structure/rmh_decree_poster/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_CLICKEDON)
	if(attached_wall)
		UnregisterSignal(attached_wall, list(COMSIG_TURF_CHANGE, COMSIG_PARENT_QDELETING))
	attached_wall = null
	if(poster)
		UnregisterSignal(poster, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
		SStgui.close_uis(poster)
		QDEL_NULL(poster)
	return ..()

/obj/structure/rmh_decree_poster/proc/on_sheet_deleted(datum/source)
	SIGNAL_HANDLER
	poster = null
	qdel(src)

/obj/structure/rmh_decree_poster/proc/on_sheet_moved(datum/source)
	SIGNAL_HANDLER
	if(poster?.loc != src)
		if(poster)
			UnregisterSignal(poster, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
		poster = null
		qdel(src)

/obj/structure/rmh_decree_poster/proc/on_wall_changed(datum/source)
	SIGNAL_HANDLER
	detach_poster()

/obj/structure/rmh_decree_poster/proc/detach_poster(mob/user)
	if(!poster)
		return null
	if(poster.damaged)
		qdel(src)
		return null
	var/obj/item/rmh_decree_poster/sheet = poster
	poster = null
	UnregisterSignal(sheet, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
	SStgui.close_uis(sheet)
	sheet.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(sheet)
	qdel(src)
	return sheet

/obj/structure/rmh_decree_poster/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !poster || !isliving(user) || !user.Adjacent(src) || !user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return
	if(istype(user.used_intent, INTENT_STEAL))
		try_steal(user)
		return TRUE
	if(!poster.damaged)
		poster.ui_interact(user)
	return TRUE

/obj/structure/rmh_decree_poster/attackby(obj/item/tool, mob/user, list/modifiers)
	if(poster?.damaged)
		if(tool && user?.is_holding(tool) && user.Adjacent(src) && user.used_intent?.blade_class == BCLASS_CUT && user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
			add_fingerprint(user)
			qdel(src)
		return TRUE
	if(istype(tool, /obj/item/tattoo_machine) && poster)
		poster.begin_forgery(user, tool)
		return TRUE
	return ..()

/obj/structure/rmh_decree_poster/examine(mob/user)
	. = ..()
	if(poster?.damaged)
		. += span_notice(rmh_ui_text(user, "Края порваны.", "Its edges are torn."))

/datum/repeatable_crafting_recipe/reading/rmh_decree_poster
	name = "blank decree poster"
	output = /obj/item/rmh_decree_poster
	craft_time = 2 SECONDS
	subtypes_allowed = FALSE

/obj/item/rmh_decree_poster/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/rmh_decree_backgrounds)

#undef RMH_POSTER_FORGE_DELAY
#undef RMH_POSTER_REMOVE_DELAY


/proc/rmh_decree_title(text)
	if(!istext(text) || !length(text))
		return ""
	return copytext_char(trim(splittext(text, "\n")[1]), 1, RMH_LAW_MAX_TITLE + 1)

/obj/item/rmh_decree_poster/proc/refresh_title()
	var/title = rmh_decree_title(snapshot ? snapshot["text"] : "")
	name = damaged ? "torn decree poster" : (length(title) ? "Decree [html_encode(title)]" : "decree poster")
	if(istype(loc, /obj/structure/rmh_decree_poster))
		var/obj/structure/rmh_decree_poster/mount = loc
		if(mount.poster == src)
			mount.name = name

/obj/item/rmh_decree_poster/get_examine_name(mob/user, use_article = TRUE)
	if(damaged)
		var/title = get_preferred_ui_language(user) == "en" && length(torn_title_en) ? torn_title_en : torn_title
		if(user && user.get_skill_level(/datum/attribute/skill/misc/reading) >= SKILL_RANK_EXPERT && length(title))
			return "<b>[rmh_ui_text(user, "Порванный указ", "Torn decree")]: [html_encode(title)]</b>"
		return "<b>[rmh_ui_text(user, "Порванный указ", "Torn decree")]</b>"
	if(!snapshot)
		return "<b>[rmh_ui_text(user, "Пустой постер для указа", "Blank decree poster")]</b>"
	var/text = get_preferred_ui_language(user) == "en" && length(trim(snapshot["text_en"])) ? snapshot["text_en"] : snapshot["text"]
	return "<b>[rmh_ui_text(user, "Указ", "Decree")] [html_encode(rmh_decree_title(text))]</b>"

/obj/structure/rmh_decree_poster/get_examine_name(mob/user, use_article = TRUE)
	return poster ? poster.get_examine_name(user, use_article) : ..()

/obj/item/rmh_decree_poster/get_mechanics_examine(mob/user)
	. = ..()
	if(damaged)
		. += rmh_ui_text(user, "CUT любым предметом: убрать порванный указ.", "CUT with any held item to clear the torn decree.")
		return
	if(!snapshot)
		. += rmh_ui_text(user, "Примените пустой лист к стенду писаря или исправной доске и выберите указ.", "Apply the blank sheet to a scribe's stand or intact decree board and choose a decree.")
		return
	. += rmh_poster_mechanics(user)

/obj/structure/rmh_decree_poster/get_mechanics_examine(mob/user)
	return poster ? poster.get_mechanics_examine(user) : ..()

/proc/rmh_poster_mechanics(mob/user)
	return list(
		rmh_ui_text(user, "STEAL + WEAK: снять целым за 5 секунд; требуется Reading 4+.", "STEAL + WEAK: remove intact in 5 seconds; requires Reading 4+."),
		rmh_ui_text(user, "STEAL + STRONG: порвать за 5 секунд. Остатки снимаются предметом с интентом CUT.", "STEAL + STRONG: tear in 5 seconds. Clear the remains with an item using CUT."),
		rmh_ui_text(user, "С помощью тату-машинки можно менять законы на постере.", "A tattoo machine can change the laws on the poster."),
	)

/obj/item/rmh_decree_poster/get_examine_desc(mob/user)
	if(damaged)
		return rmh_ui_text(user, "Текст порван и не поддаётся прочтению.", "The torn text is illegible.")
	return snapshot ? rmh_ui_text(user, "Пергамент с копией указа.", "A parchment bearing a copy of a decree.") : rmh_ui_text(user, "Подготовленный лист пергамента.", "A sheet of prepared parchment.")

/obj/structure/rmh_decree_poster/get_examine_desc(mob/user)
	return poster?.damaged ? poster.get_examine_desc(user) : ..()

/obj/item/rmh_decree_poster/attack_ghost(mob/dead/observer/user)
	ui_interact(user)

/obj/structure/rmh_decree_poster/attack_ghost(mob/dead/observer/user)
	poster?.ui_interact(user)
