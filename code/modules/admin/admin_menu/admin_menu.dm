#define PLAYER_LIST_CACHE_TIME (3 SECONDS)
#define PQ_CACHE_TIME (15 SECONDS)

/**
 * Admin Menu: one window for the admin commands that used to live on the extra stat panel tabs,
 * the player panel, and quick access to tools such as View Variables.
 *
 * Security model:
 * - The window only opens for, and only accepts input from, the client that owns the admin holder.
 *   A deadminned admin has no holder, so the window closes and every action is refused.
 * - Commands are not executed by this datum. It checks that the verb is admin-granted and is
 *   still on the client, then asks the client to run it, exactly like a click on the stat panel.
 *   BYOND itself refuses verbs the client does not have, and every verb keeps its own checks.
 * - Player actions are routed through /datum/admins/Topic(), so the rights checks, confirmations
 *   and logging of the classic player panel are reused instead of duplicated.
 * - The target of a player action always comes with the request and is verified again here.
 */

GLOBAL_DATUM_INIT(admin_menu_state, /datum/ui_state/admin_menu_state, new)

/datum/ui_state/admin_menu_state/can_use_topic(src_object, mob/user)
	var/datum/admin_menu/menu = src_object
	if(!istype(menu) || !menu.holder)
		return UI_CLOSE
	var/client/user_client = user?.client
	if(!user_client?.holder || user_client.holder != menu.holder || menu.holder.owner != user_client)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admins
	/// The Admin Menu window of this admin, created on first use.
	var/datum/admin_menu/admin_menu
	/// While above zero, Topic handlers called by the Admin Menu do not pop the classic player panel back up.
	var/admin_menu_pp_suppress = 0

/datum/admin_menu
	/// The admin datum this menu belongs to.
	var/datum/admins/holder
	/// Which page the window shows; decides which of the heavier data sets are sent.
	var/page = "commands"
	/// Bumped when the server opens a page (F6), so an already open window jumps to it.
	var/page_request = 0
	/// REF of the mob picked in the player list.
	var/selected_ref
	/// ckey the picked mob had when it was picked.
	var/selected_ckey
	/// Last feedback line shown in the window.
	var/notice
	/// "info", "good" or "bad".
	var/notice_type = "info"
	/// Bumped on every new notice so the window can tell two identical messages apart.
	var/notice_id = 0
	/// Most recently used commands, newest first, as verb path text.
	var/list/recent = list()
	/// Favourite commands as verb path text, in the order they were starred. Saved per admin.
	var/list/favorites
	/// Round Log page: categories shown (empty = all), player ckey filter, search text and page.
	var/list/log_categories = list()
	var/log_player
	var/log_search = ""
	var/log_page = 1
	/// Ids of matching entries, extended with new entries only (see round_log_page()).
	var/list/log_cache = list()
	/// Player Quality of the selected player: list("ckey", "num", "text", "time"). Read from disk at most every PQ_CACHE_TIME.
	var/list/pq_cache
	/// TRUE while a log page refresh is queued.
	var/log_refresh_queued = FALSE
	/// Timer of the slow refresh that replaces tgui's once-a-second autoupdate.
	var/pulse_timer
	/// Heavy lists last sent to the window: they are left out of updates while unchanged
	/// (tgui keeps the previous value of keys an update does not contain).
	var/list/sent_players
	var/sent_actor_count = -1
	/// TRUE while a verb list refresh is queued.
	var/verb_refresh_queued = FALSE

/datum/admin_menu/New(datum/admins/new_holder)
	. = ..()
	holder = new_holder

/datum/admin_menu/Destroy()
	SStgui.close_uis(src)
	if(holder?.admin_menu == src)
		holder.admin_menu = null
	holder = null
	return ..()

/client/proc/open_admin_menu()
	set name = "Admin Menu"
	set category = "Admin"
	set desc = "Open the Admin Menu: commands, players and tools in one window."

	if(!holder)
		to_chat(src, span_danger("You need to be an administrator to access this."))
		return
	if(!holder.admin_menu)
		holder.admin_menu = new(holder)
	holder.admin_menu.ui_interact(mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Menu")

/// Opens the Admin Menu straight on one page ("commands", "players" or "mc"), even if it is already open elsewhere.
/client/proc/open_admin_menu_page(page)
	if(!holder)
		return
	if(!holder.admin_menu)
		holder.admin_menu = new(holder)
	var/datum/admin_menu/menu = holder.admin_menu
	if(page in list("commands", "players", "mc"))
		menu.page = page
		menu.page_request++
	menu.ui_interact(mob)
	SStgui.update_uis(menu)

/datum/admin_menu/ui_state(mob/user)
	return GLOB.admin_menu_state

/datum/admin_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminMenu", "Admin Menu")
		// A new window has none of the heavy lists yet.
		sent_players = null
		sent_actor_count = -1
		ui.open()
	sync_autoupdate(ui)

/**
 * tgui would resend the whole page every second, URL-encoded (about three times its JSON size).
 * Instead the window is refreshed after every action and by a slow pulse whose pace depends on
 * the page: players and MC every 2 seconds, the command pages every 10, the Round Log only when
 * something is logged.
 */
/datum/admin_menu/proc/sync_autoupdate(datum/tgui/ui)
	ui?.set_autoupdate(FALSE)
	restart_pulse()

/datum/admin_menu/proc/pulse_interval()
	switch(page)
		if("players", "mc")
			return 2 SECONDS
		if("log")
			return 0
	return 10 SECONDS

/datum/admin_menu/proc/restart_pulse()
	if(pulse_timer)
		deltimer(pulse_timer)
		pulse_timer = null
	var/interval = pulse_interval()
	if(interval)
		pulse_timer = addtimer(CALLBACK(src, PROC_REF(pulse)), interval, TIMER_STOPPABLE)

/datum/admin_menu/proc/pulse()
	pulse_timer = null
	if(!LAZYLEN(open_uis))
		return // the window is closed: stop until it opens again
	SStgui.update_uis(src)
	restart_pulse()

/datum/admin_menu/ui_close(mob/user)
	. = ..()
	if(pulse_timer)
		deltimer(pulse_timer)
		pulse_timer = null

/// Called when a new admin log entry arrives: refreshes this window soon if it shows the log.
/datum/admin_menu/proc/queue_log_refresh()
	if(page != "log" || log_refresh_queued)
		return
	log_refresh_queued = TRUE
	addtimer(CALLBACK(src, PROC_REF(refresh_log)), 1 SECONDS)

/datum/admin_menu/proc/refresh_log()
	log_refresh_queued = FALSE
	if(page == "log")
		SStgui.update_uis(src)

/datum/admin_menu/proc/set_notice(text, type = "info")
	notice = text
	notice_type = type
	notice_id++

/// Refuses an action: tells the admin why in the window and in chat. Always returns TRUE so the window refreshes.
/datum/admin_menu/proc/fail(text)
	set_notice(text, "bad")
	if(usr)
		to_chat(usr, span_warning("Admin Menu: [text]"))
	return TRUE

/// Called by add_verb()/remove_verb() when the admin's verbs change (rights edit, hide verbs, debug verbs...).
/datum/admin_menu/proc/queue_verb_refresh()
	if(verb_refresh_queued)
		return
	verb_refresh_queued = TRUE
	addtimer(CALLBACK(src, PROC_REF(refresh_verbs)), 0.5 SECONDS)

/datum/admin_menu/proc/refresh_verbs()
	verb_refresh_queued = FALSE
	update_static_data_for_all_viewers()

/datum/admin_menu/ui_static_data(mob/user)
	var/list/data = list()
	var/client/admin = user.client
	var/list/verb_data = list()
	if(admin?.holder == holder)
		var/list/registry = get_admin_menu_verbs()
		var/list/seen = list()
		for(var/procpath/verb_path as anything in admin.verbs)
			if(!verb_path || seen[verb_path] || isnull(registry[verb_path]))
				continue
			if(GLOB.admin_menu_tab_verbs[verb_path])
				continue // lives on the Admin tab
			seen[verb_path] = TRUE
			var/rights = registry[verb_path]
			verb_data += list(list(
				"path" = "[verb_path]",
				"name" = verb_path.name,
				"desc" = verb_path.desc,
				"category" = istext(verb_path.category) ? verb_path.category : "",
				"hidden" = !!verb_path.hidden,
				"rights" = rights ? rights2text(rights, " ") : "",
			))
	data["verbs"] = verb_data
	data["quirk_options"] = admin_menu_quirk_options()
	data["mute_types"] = list(
		list("name" = "IC", "flag" = MUTE_IC),
		list("name" = "OOC", "flag" = MUTE_OOC),
		list("name" = "PRAY", "flag" = MUTE_PRAY),
		list("name" = "ADMINHELP", "flag" = MUTE_ADMINHELP),
		list("name" = "DEADCHAT", "flag" = MUTE_DEADCHAT),
		list("name" = "LOOC", "flag" = MUTE_LOOC),
		list("name" = "Meditate", "flag" = MUTE_MEDITATE),
	)
	return data

/datum/admin_menu/ui_data(mob/user)
	var/list/data = list()
	var/client/admin = user.client
	data["ckey"] = admin?.ckey
	data["rank"] = "[holder?.rank]"
	data["rights"] = holder ? rights2text(holder.rank.rights, " ") : ""
	data["can_varedit"] = check_rights_for(admin, R_VAREDIT)
	data["new_menu"] = admin ? admin.uses_admin_menu() : TRUE
	data["page"] = page
	data["page_request"] = page_request
	data["notice"] = notice
	data["notice_type"] = notice_type
	data["notice_id"] = notice_id
	data["recent"] = recent
	data["favorites"] = get_favorites(admin)
	data["active_tickets"] = length(GLOB.ahelp_tickets?.active_tickets)
	data["round_time"] = ROUND_TIME()
	data["player_count"] = length(GLOB.clients)

	var/datum/marked = holder?.marked_datum
	data["marked"] = QDELETED(marked) ? null : "[marked] ([marked.type])"

	if(page == "players")
		var/list/players = admin_menu_player_list()
		if(players != sent_players) // the shared list is rebuilt at most every 3 seconds
			sent_players = players
			data["players"] = players
		var/mob/selected = get_selected_mob()
		data["selected"] = selected ? player_detail_data(selected) : null
	if(page == "mc")
		data["mc"] = controller_data(admin)
	if(page == "log")
		var/list/feed = round_log_page(log_categories, log_player, log_search, log_page, log_cache)
		// Top level on purpose: tgui only keeps unchanged values for top-level keys.
		if(sent_actor_count != length(GLOB.round_log_actors))
			sent_actor_count = length(GLOB.round_log_actors)
			data["log_actors"] = round_log_actor_list()
		log_page = feed["page"]
		feed["selected_categories"] = log_categories
		feed["player"] = log_player
		feed["search"] = log_search
		data["log"] = feed
	return data

/datum/admin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	var/client/admin = user?.client
	// The ui state already refuses non-owners; this is the second, explicit check.
	if(!admin || !holder || admin.holder != holder || holder.owner != admin)
		return FALSE

	switch(action)
		if("set_page")
			var/new_page = params["page"]
			if(new_page in list("commands", "players", "mc", "log"))
				page = new_page
				sent_players = null // the new page sends its lists afresh
				sent_actor_count = -1
				sync_autoupdate(ui)
			return TRUE

		if("toggle_favorite")
			return toggle_favorite(admin, params["path"])

		if("log_filter")
			if(!isnull(params["player"]))
				var/new_player = params["player"]
				log_player = (istext(new_player) && length(new_player)) ? ckey(new_player) : null
			if(istext(params["search"]))
				log_search = copytext_char(params["search"], 1, 101)
			if(islist(params["categories"]))
				var/list/valid = round_log_categories()
				log_categories = list()
				for(var/category in params["categories"])
					if(valid[category])
						log_categories |= category
			log_page = 1
			return TRUE

		if("log_jump")
			var/turf/spot = locate(text2num("[params["x"]]"), text2num("[params["y"]]"), text2num("[params["z"]]"))
			if(!spot)
				return fail("That place is not on the map.")
			user.forceMove(spot)
			log_admin("[key_name(user)] jumped to [AREACOORD(spot)] from the Round Log.")
			return TRUE

		if("log_page")
			var/new_log_page = text2num("[params["page"]]")
			if(isnum(new_log_page))
				log_page = max(1, round(new_log_page))
			return TRUE

		if("run_verb")
			return run_verb(admin, params["path"])

		if("select_player")
			var/mob/picked = locate(params["ref"]) in GLOB.mob_list
			if(!picked)
				selected_ref = null
				selected_ckey = null
				return fail("That mob no longer exists.")
			selected_ref = REF(picked)
			selected_ckey = picked.ckey
			return TRUE

		if("clear_player")
			selected_ref = null
			selected_ckey = null
			return TRUE

		if("player_action")
			return player_action(admin, params["action"], params)

		if("global_action")
			return global_action(admin, params["action"], params)

		if("set_menu_mode")
			var/use_new_menu = !!params["new_menu"]
			if(admin.set_admin_menu_mode(use_new_menu))
				set_notice(use_new_menu ? "New-Adm. menu enabled: admin tabs are hidden from the right panel." : "Classic admin tabs are back on the right panel.", "good")
			return TRUE

		if("vv_marked")
			if(!check_rights(R_VAREDIT))
				return fail("You need +VAREDIT to open View Variables from here.")
			if(QDELETED(holder.marked_datum))
				return fail("You have no marked datum.")
			admin.debug_variables(holder.marked_datum)
			return TRUE

		if("vv_controller")
			if(!check_rights(R_VAREDIT))
				return fail("You need +VAREDIT to open View Variables from here.")
			var/datum/target = controller_by_ref(params["ref"])
			if(!target)
				return fail("That controller no longer exists.")
			admin.debug_variables(target)
			return TRUE

		if("sdql2_list")
			if(!check_rights(R_DEBUG))
				return TRUE
			admin.debug_variables(GLOB.sdql2_queries)
			return TRUE

		if("dismiss_notice")
			notice = null
			return TRUE

	return FALSE

/// Runs an admin-granted verb for its owner, the same way a click on the stat panel does.
/datum/admin_menu/proc/run_verb(client/admin, path_text)
	var/verb_path = istext(path_text) ? text2path(path_text) : null
	if(!verb_path || isnull(get_admin_menu_verbs()[verb_path]))
		return fail("Unknown command.")
	if(!(verb_path in admin.verbs))
		queue_verb_refresh()
		return fail("That command is not available to you anymore.")

	var/procpath/verb_ref = verb_path
	recent -= path_text
	recent.Insert(1, path_text)
	if(length(recent) > 8)
		recent.Cut(9)
	// Verbs that take a mob get it from the Players / Nearby / All picker.
	if(admin_mob_target_verbs()[verb_path])
		admin.run_admin_mob_verb(verb_path)
		return TRUE
	// The client runs the verb itself, so usr/src, argument prompts and the verb's own rights
	// checks, confirmations and logging behave exactly like a stat panel click.
	winset(admin, null, list2params(list("command" = replacetext(verb_ref.name, " ", "-"))))
	return TRUE

/// Resolves the player picked in the list. Follows the player when they moved to another mob.
/datum/admin_menu/proc/get_selected_mob()
	if(!selected_ref)
		return null
	var/mob/selected = locate(selected_ref) in GLOB.mob_list
	if(selected && (selected.ckey == selected_ckey || !selected_ckey))
		return selected
	// The mob is gone or the player left it: follow the player, like "Find Updated Panel" did.
	if(selected_ckey)
		var/mob/moved = get_mob_by_ckey(selected_ckey)
		if(moved)
			selected_ref = REF(moved)
			return moved
	if(selected)
		selected_ckey = selected.ckey
		return selected
	selected_ref = null
	selected_ckey = null
	return null

/datum/admin_menu/proc/job_text(mob/target)
	return admin_menu_job_text(target)

/proc/admin_menu_job_text(mob/target)
	if(isliving(target))
		if(iscarbon(target))
			if(ishuman(target))
				if(target.mind?.assigned_role?.parent_job)
					return target.mind.assigned_role.parent_job.title
				return target.job
			return "Carbon-based"
		if(isanimal(target))
			return "Animal"
		return "Living"
	if(isnewplayer(target))
		return "New player"
	if(isobserver(target))
		var/mob/dead/observer/ghost = target
		return ghost.started_as_observer ? "Observer" : "Ghost"
	return ""

/// Player list shared by every open Admin Menu, rebuilt at most every PLAYER_LIST_CACHE_TIME.
/// A rebuild that changed nothing keeps the old list, so open windows (which compare by identity) are not sent it again.
/proc/admin_menu_player_list()
	var/static/list/cached
	var/static/cached_json
	var/static/cached_at = -INFINITY
	if(cached && world.time < cached_at + PLAYER_LIST_CACHE_TIME)
		return cached
	cached_at = world.time
	// Only mobs with a key are listed: pick them first, then sort just those (not every mob in the world).
	var/list/keyed = list()
	for(var/mob/candidate as anything in GLOB.mob_list)
		if(candidate.ckey)
			keyed += candidate
	sortTim(keyed, GLOBAL_PROC_REF(cmp_admin_menu_players))
	var/list/players = list()
	for(var/mob/player as anything in keyed)
		var/kind = "other"
		if(isnewplayer(player))
			kind = "lobby"
		else if(isobserver(player))
			kind = "ghost"
		else if(isliving(player))
			kind = "living"
		var/previous_names = ""
		var/datum/player_details/details = GLOB.player_details[ckey(player.key)]
		if(details)
			previous_names = details.played_names.Join(", ")
		players += list(list(
			"ref" = REF(player),
			"ckey" = player.ckey,
			"key" = player.key,
			"name" = player.name,
			"real_name" = player.real_name,
			"job" = admin_menu_job_text(player),
			"kind" = kind,
			"antag" = !!is_special_character(player),
			"connected" = !!player.client,
			"admin" = !!player.client?.holder,
			"dead" = isliving(player) && player.stat == DEAD,
			"old_names" = previous_names,
		))
	var/players_json = json_encode(players)
	if(players_json != cached_json)
		cached_json = players_json
		cached = players
	return cached

/proc/cmp_admin_menu_players(mob/a, mob/b)
	return sorttext("[b.name]", "[a.name]") || sorttext("[b.ckey]", "[a.ckey]")

/// Quirk choices for the player panel. They never change during a round, so they are built once.
/proc/admin_menu_quirk_options()
	var/static/list/options
	if(options)
		return options
	options = list()
	for(var/category in list(QUIRK_POSITIVE, QUIRK_NEGATIVE, QUIRK_NEUTRAL))
		var/category_name = "Peculiarities"
		if(category == QUIRK_POSITIVE)
			category_name = "Boons"
		else if(category == QUIRK_NEGATIVE)
			category_name = "Vices"
		for(var/list/quirk_data as anything in GLOB.quirk_points_by_type[category])
			options += list(list(
				"type" = "[quirk_data["type"]]",
				"name" = "[quirk_data["name"]]",
				"points" = quirk_data["value"],
				"group" = category_name,
			))
	return options

/// Player Quality is read from a file per player: cache it instead of hitting the disk every second.
/datum/admin_menu/proc/cached_playerquality(ckey)
	if(!pq_cache || pq_cache["ckey"] != ckey || world.time > pq_cache["time"] + PQ_CACHE_TIME)
		pq_cache = list(
			"ckey" = ckey,
			"num" = get_playerquality(ckey, FALSE),
			"text" = "[get_playerquality(ckey, TRUE)]",
			"time" = world.time,
		)
	return pq_cache

/datum/admin_menu/proc/player_detail_data(mob/target)
	var/list/detail = list()
	var/client/target_client = target.client
	detail["ref"] = REF(target)
	detail["ckey"] = target.ckey
	detail["key"] = target.key
	detail["name"] = target.name
	detail["real_name"] = target.real_name
	detail["type"] = "[target.type]"
	detail["job"] = job_text(target)
	detail["connected"] = !!target_client
	detail["is_new_player"] = isnewplayer(target)
	detail["is_living"] = isliving(target)
	detail["is_human"] = ishuman(target)
	detail["has_mind"] = !!target.mind
	detail["antag"] = !!is_special_character(target)
	detail["ip"] = target_client ? target_client.address : target.lastKnownIP
	detail["log_src"] = target_client ? LOGSRC_CLIENT : LOGSRC_MOB
	detail["has_attributes"] = !!target.attributes

	var/turf/location = get_turf(target)
	detail["location"] = location ? "[get_area_name(location, TRUE)] ([location.x], [location.y], [location.z])" : "nullspace"

	if(isliving(target))
		var/mob/living/living_target = target
		detail["health"] = living_target.health
		detail["max_health"] = living_target.maxHealth
		detail["stat"] = living_target.stat == DEAD ? "Dead" : (living_target.stat == CONSCIOUS ? "Conscious" : "Unconscious")
		detail["godmode"] = !!(living_target.status_flags & GODMODE)
		detail["patron"] = living_target.patron ? "[initial(living_target.patron.name)]" : null
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		detail["curses"] = human_target.curses.Join(", ")
		detail["job_title"] = human_target.mind?.assigned_role?.title
		var/list/quirks = list()
		for(var/datum/quirk/quirk in human_target.quirks)
			quirks += list(list("type" = "[quirk.type]", "name" = "[initial(quirk.name)]", "points" = quirk.point_value))
		detail["quirks"] = quirks

	var/list/languages = list()
	for(var/datum/language/language as anything in GLOB.all_languages)
		languages += list(list(
			"type" = "[language]",
			"name" = "[initial(language.name)]",
			"known" = !!target.mind?.language_holder?.has_language(language),
		))
	detail["languages"] = languages

	if(target_client)
		detail["rank"] = target_client.holder ? "[target_client.holder.rank]" : "Player"
		detail["is_admin"] = !!(GLOB.admin_datums[target_client.ckey] || GLOB.deadmins[target_client.ckey])
		if(CONFIG_GET(flag/use_exp_tracking))
			detail["playtime"] = target_client.get_exp_living()
		detail["first_seen"] = target_client.player_join_date
		detail["account_date"] = target_client.account_join_date
		detail["byond_version"] = target_client.byond_version ? "[target_client.byond_version].[target_client.byond_build ? target_client.byond_build : "xxx"]" : "Unknown"
		var/list/pq = cached_playerquality(target.ckey)
		detail["pq"] = pq["text"]
		detail["pq_num"] = pq["num"]
		detail["muted"] = target_client.prefs?.muted
		detail["centcom"] = !!CONFIG_GET(string/centcom_ban_db)
	return detail

/datum/admin_menu/proc/controller_data(client/admin)
	var/list/out = list()
	// The stat panel only refreshes this while someone has its MC tab open, which the new menu hides:
	// refresh it here, at most once a second for every open Admin Menu together.
	var/static/mc_generated_at = -INFINITY
	if(!SSstatpanels.mc_data || world.time >= mc_generated_at + 1 SECONDS)
		mc_generated_at = world.time
		SSstatpanels.generate_mc_data()
	var/turf/eye_turf = admin ? get_turf(admin.eye) : null
	out += list(list("flag" = "", "name" = "Location:", "value" = eye_turf ? "[COORD(eye_turf)]" : "nullspace", "ref" = null))
	for(var/list/entry as anything in SSstatpanels.mc_data)
		out += list(list(
			"flag" = "[entry[1]]",
			"name" = "[entry[2]]",
			"value" = "[entry[3]]",
			"ref" = length(entry) >= 4 ? entry[4] : null,
		))
	return list("rows" = out, "sdql2" = length(GLOB.sdql2_queries))

/// Only the controllers the MC tab links to may be opened through the "vv_controller" action.
/datum/admin_menu/proc/controller_by_ref(ref)
	if(!istext(ref))
		return null
	for(var/datum/candidate as anything in list(GLOB, config, Master, Failsafe) + Master.subsystems)
		if(candidate && text_ref(candidate) == ref)
			return candidate
	return null

/// Calls the admin Topic handler on behalf of the Admin Menu. usr is still the admin who clicked.
/datum/admin_menu/proc/dispatch_topic(list/href_list, suppress_panel = TRUE)
	set waitfor = FALSE
	var/datum/admins/target_holder = holder
	if(!target_holder || usr?.client?.holder != target_holder)
		return
	href_list["admin_token"] = target_holder.href_token
	if(suppress_panel)
		target_holder.admin_menu_pp_suppress++
	try
		target_holder.Topic("admin_menu=1", href_list)
	catch(var/exception/error)
		if(suppress_panel)
			target_holder.admin_menu_pp_suppress = max(target_holder.admin_menu_pp_suppress - 1, 0)
		throw error
	if(suppress_panel)
		target_holder.admin_menu_pp_suppress = max(target_holder.admin_menu_pp_suppress - 1, 0)
	if(!QDELETED(src))
		SStgui.update_uis(src)

/datum/admin_menu/proc/global_action(client/admin, action, list/params)
	switch(action)
		if("check_antagonists")
			dispatch_topic(list("check_antagonist" = "1"))
		if("kick_lobby")
			dispatch_topic(list("kick_all_from_lobby" = "1", "afkonly" = params["afk"] ? "1" : "0"))
		if("tickets")
			dispatch_topic(list("ahelp_tickets" = "[AHELP_ACTIVE]"))
		else
			return fail("Unknown action.")
	return TRUE

/**
 * Runs one player panel action on the mob named in the request.
 *
 * The request carries the REF and the ckey the window was showing. If the mob is gone, or the
 * player is no longer in it, nothing is done: the admin is told and the selection is refreshed.
 */
/datum/admin_menu/proc/player_action(client/admin, action, list/params)
	if(!istext(action))
		return fail("Unknown action.")
	var/mob/target = locate(params["ref"]) in GLOB.mob_list
	if(QDELETED(target))
		return fail("That mob no longer exists. Nothing was done.")
	var/expected_ckey = params["ckey"]
	if(!istext(expected_ckey))
		expected_ckey = ""
	if((target.ckey || "") != expected_ckey)
		// Re-point the selection at the player and make the admin look again before acting.
		if(expected_ckey)
			selected_ckey = expected_ckey
			var/mob/moved = get_mob_by_ckey(expected_ckey)
			selected_ref = moved ? REF(moved) : REF(target)
		return fail("[expected_ckey ? expected_ckey : "The player"] is no longer controlling [target]. Nothing was done; the selection was refreshed.")

	var/ref = REF(target)
	var/client/target_client = target.client

	// Actions whose handlers read the target's client.
	var/static/list/needs_client = list("showpq", "showtriumphs", "roleban", "related_cid", "related_ip", "playtime", "rights", "lobby", "editpq")
	if((action in needs_client) && !target_client)
		return fail("[target.key ? target.key : target] is not connected.")

	// action -> Topic key, called as key=REF
	var/static/list/ref_actions = list(
		"traitor" = "traitor",
		"initmind" = "initmind",
		"subtle" = "subtlemessage",
		"follow" = "adminplayerobservefollow",
		"heal" = "revive",
		"kick" = "boot2",
		"lobby" = "sendbacktolobby",
		"cryo" = "cryomob",
		"jumpto" = "jumpto",
		"getmob" = "getmob",
		"sendmob" = "sendmob",
		"narrate" = "narrateto",
		"whitelist" = "open_whitelist_panel",
		"boost" = "open_boost_panel",
		"skills" = "attributes",
		"playtime" = "getplaytimewindow",
		"smite" = "adminsmite",
		"forcespeech" = "forcespeech",
		"moreinfo" = "adminmoreinfo",
		"makeanimal" = "makeanimal",
		"languagemenu" = "languagemenu",
	)
	// action -> Topic key, called as key=add;mob=REF
	var/static/list/mob_actions = list(
		"editpq" = "editpq",
		"showpq" = "showpq",
		"edittriumphs" = "edittriumphs",
		"showtriumphs" = "showtriumphs",
		"roleban" = "roleban",
		"patron" = "changepatron",
		"curses" = "modifycurses",
		"job" = "setjob",
	)

	if(ref_actions[action])
		dispatch_topic(list(ref_actions[action] = ref))
		return TRUE
	if(mob_actions[action])
		dispatch_topic(list(mob_actions[action] = "add", "mob" = ref))
		return TRUE

	switch(action)
		if("pp") // the classic per-player window, kept as a fallback for anything not shown here
			if(!check_rights())
				return TRUE
			holder.show_player_panel_next(target, null, TRUE)
		if("vv")
			if(!check_rights(R_VAREDIT))
				return fail("You need +VAREDIT to open View Variables from here.")
			admin.debug_variables(target)
		if("spells")
			if(!check_rights_for(admin, R_FUN))
				return fail("You need +FUN to open the Spell Library.")
			admin.open_spell_library(target)
		if("pm")
			if(!target.ckey)
				return fail("[target] has no key to message.")
			admin.cmd_admin_pm(target.ckey, null)
		if("notes")
			dispatch_topic(list("showmessageckey" = target.ckey))
		if("logs")
			dispatch_topic(list("individuallog" = ref, "log_src" = target_client ? LOGSRC_CLIENT : LOGSRC_MOB))
		if("ban")
			var/list/ban_href = list("newbankey" = target.key)
			if(target_client)
				ban_href["newbanip"] = target_client.address
				ban_href["newbancid"] = target_client.computer_id
			dispatch_topic(ban_href)
		if("mute")
			var/mute_type = params["mute_type"]
			if(mute_type == "all")
				mute_type = MUTE_ALL
			else if(!isnum(mute_type))
				mute_type = text2num("[mute_type]")
			var/static/list/mute_types = list(MUTE_IC, MUTE_OOC, MUTE_PRAY, MUTE_ADMINHELP, MUTE_DEADCHAT, MUTE_LOOC, MUTE_MEDITATE, MUTE_ALL)
			if(!(mute_type in mute_types))
				return fail("Unknown mute type.")
			dispatch_topic(list("mute" = target.ckey, "mute_type" = "[mute_type]"))
		if("rights")
			var/is_admin = GLOB.admin_datums[target_client.ckey] || GLOB.deadmins[target_client.ckey]
			dispatch_topic(list("editrights" = is_admin ? "rank" : "add", "key" = target.key))
		if("centcom")
			dispatch_topic(list("centcomlookup" = target.ckey))
		if("related_cid")
			dispatch_topic(list("showrelatedacc" = "cid", "client" = REF(target_client)))
		if("related_ip")
			dispatch_topic(list("showrelatedacc" = "ip", "client" = REF(target_client)))
		if("add_language", "remove_language")
			var/language_path = text2path("[params["language"]]")
			if(!ispath(language_path, /datum/language))
				return fail("Unknown language.")
			dispatch_topic(list("[action]" = ref, "language" = "[language_path]"))
		if("add_quirk", "remove_quirk")
			var/quirk_path = text2path("[params["quirk"]]")
			if(!ispath(quirk_path, /datum/quirk))
				return fail("Unknown quirk.")
			dispatch_topic(list("[action]" = ref, "quirk" = "[quirk_path]"))
		else
			return fail("Unknown action.")
	return TRUE

/// Favourites ---------------------------------------------------------------------------------

/datum/admin_menu/proc/favorites_path(client/admin)
	var/owner = admin?.ckey
	if(!owner)
		return null
	return "data/player_saves/[owner[1]]/[owner]/admin_menu.json"

/datum/admin_menu/proc/get_favorites(client/admin)
	if(islist(favorites))
		return favorites
	favorites = list()
	var/path = favorites_path(admin)
	if(path && fexists(path))
		var/list/saved = safe_json_decode(file2text(path))
		if(islist(saved) && islist(saved["favorites"]))
			// Verb paths are proc paths: ispath() is FALSE for them, so check them against the registry.
			var/list/registry = get_admin_menu_verbs()
			for(var/entry in saved["favorites"])
				if(istext(entry) && !isnull(registry[text2path(entry)]))
					favorites |= entry
	return favorites

/datum/admin_menu/proc/toggle_favorite(client/admin, path_text)
	var/verb_path = istext(path_text) ? text2path(path_text) : null
	if(!verb_path || isnull(get_admin_menu_verbs()[verb_path]))
		return FALSE
	var/list/current = get_favorites(admin)
	if(path_text in current)
		current -= path_text
	else if(length(current) >= 40)
		return fail("You already have 40 favourites.")
	else
		current += path_text
	var/path = favorites_path(admin)
	if(path)
		if(fexists(path))
			fdel(path)
		text2file(json_encode(list("favorites" = current)), path)
	return TRUE

#undef PLAYER_LIST_CACHE_TIME
#undef PQ_CACHE_TIME

/**
 * Slow refresh for admin windows whose data changes only now and then. tgui's autoupdate resends
 * everything every second (URL-encoded); call this once when the window opens, after turning
 * autoupdate off, and it refreshes every interval for as long as a window of source is open.
 */
/proc/admin_ui_slow_refresh(datum/source, interval)
	if(QDELETED(source) || !LAZYLEN(source.open_uis))
		return
	SStgui.update_uis(source)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(admin_ui_slow_refresh), source, interval), interval, TIMER_UNIQUE)
