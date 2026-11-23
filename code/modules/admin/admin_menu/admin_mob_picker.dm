/**
 * Mob picker for admins: one window with three tabs instead of one endless list.
 *
 * Players - mobs with a player key (connected or not), by name
 * Nearby  - every mob within BM_PICKER_NEAR tiles of where the admin is looking, nearest first
 * All     - every mob in the world
 *
 * Used by Jump to Mob, Get Mob, Send Mob and by Admin Menu commands that take a mob.
 * Like tgui_input_list() it waits for the answer and returns the mob, or null when cancelled.
 */

#define MOB_PICKER_NEAR 15

/proc/admin_pick_mob(mob/user, title = "Pick a mob", message = "", default_tab = "players")
	if(istype(user, /client))
		var/client/user_client = user
		user = user_client.mob
	if(!istype(user) || !user.client?.holder)
		return null
	var/datum/admin_mob_picker/picker = new(user, title, message, default_tab)
	picker.ui_interact(user)
	if(!LAZYLEN(picker.open_uis)) // no window opened, so ui_close() would never end the wait
		to_chat(user, span_warning("The mob picker could not open. Close some windows and try again."))
		qdel(picker)
		return null
	picker.wait()
	var/mob/choice = picker.choice?.resolve()
	qdel(picker)
	if(QDELETED(choice))
		return null
	return choice

/datum/admin_mob_picker
	var/title
	var/message
	var/default_tab
	/// Weakref to the picked mob.
	var/datum/weakref/choice
	var/closed = FALSE
	/// Turf the distances are measured from: where the admin was looking when the window opened.
	var/turf/origin

/datum/admin_mob_picker/New(mob/user, title, message, default_tab)
	src.title = title
	src.message = message
	src.default_tab = (default_tab in list("players", "nearby", "all")) ? default_tab : "players"
	origin = get_turf(user.client?.eye || user)

/datum/admin_mob_picker/Destroy(force)
	SStgui.close_uis(src)
	origin = null
	return ..()

/datum/admin_mob_picker/proc/wait()
	while(!choice && !closed)
		stoplag(1)

/datum/admin_mob_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_mob_picker/ui_status(mob/user, datum/ui_state/state)
	return user.client?.holder ? UI_INTERACTIVE : UI_CLOSE

/datum/admin_mob_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminMobPicker", title)
		ui.set_autoupdate(FALSE) // everything is static data
		ui.open()

/datum/admin_mob_picker/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/admin_mob_picker/ui_static_data(mob/user)
	var/list/entries = list()
	// Shuffled: the window sorts by itself, and a REF() per mob in creation order would mint thousands
	// of rising strings at once, which makes BYOND stop and re-sort its whole string table.
	for(var/mob/candidate as anything in shuffle(GLOB.mob_list))
		if(QDELETED(candidate) || isnewplayer(candidate))
			continue
		if(candidate.client?.holder?.fakekey) // stealthed admins stay hidden
			continue
		var/turf/where = get_turf(candidate)
		var/distance = -1
		if(where && origin && where.z == origin.z)
			distance = get_dist(origin, where)
		var/kind = "npc"
		if(isobserver(candidate))
			kind = "ghost"
		else if(candidate.stat == DEAD)
			kind = "dead"
		entries += list(list(
			"ref" = REF(candidate),
			"name" = "[candidate.name]",
			"real_name" = candidate.real_name != candidate.name ? "[candidate.real_name]" : null,
			"key" = candidate.key,
			"online" = !!candidate.client,
			"job" = "[candidate.job || ""]",
			"kind" = kind,
			"area" = where ? "[get_area_name(where, TRUE)]" : "nowhere",
			"distance" = distance,
		))
	return list(
		"title" = title,
		"message" = message,
		"default_tab" = default_tab,
		"near" = MOB_PICKER_NEAR,
		"mobs" = entries,
	)

/datum/admin_mob_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("pick")
			var/mob/picked = locate(params["ref"]) in GLOB.mob_list
			if(!picked)
				to_chat(usr, span_warning("That mob no longer exists."))
				return TRUE
			choice = WEAKREF(picked)
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

#undef MOB_PICKER_NEAR
