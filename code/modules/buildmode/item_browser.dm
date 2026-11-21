/**
 * Spawn catalogue: the item picker of build mode, as a tgui window (port of Ratwood 2.0 PR 123).
 *
 * The buildmode datum owns the selection, the preview and the placement itself. This datum owns
 * what the window shows: navigation, search results, favourites and recently picked types.
 * Navigation, favourites and recents are saved per admin between rounds.
 */

GLOBAL_DATUM_INIT(buildmode_catalog_state, /datum/ui_state/buildmode_catalog, new)

/datum/ui_state/buildmode_catalog/can_use_topic(src_object, mob/user)
	var/datum/buildmode_item_browser/browser = src_object
	if(!istype(browser) || !browser.can_use(user?.client))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/buildmode_item_browser
	var/datum/buildmode/parent
	var/category = "all"
	var/subcategory = "all"
	var/armor_class = "all"
	var/coverage = "all"
	var/search = ""
	var/page = 1
	/// Cached search results for the current navigation; null when stale.
	var/list/results
	/// Favourite typepaths as text, oldest first.
	var/list/favorites = list()
	/// Recently picked typepaths as text, newest first.
	var/list/recent = list()
	/// JSON of what was last written to disk, to skip writes that change nothing.
	var/saved_snapshot
	/// Feedback line shown in the window footer.
	var/status
	/// Whether the Tools panel is unfolded. Saved with the other catalogue settings.
	var/tools_open = TRUE
	COOLDOWN_DECLARE(spawn_cooldown)

/datum/buildmode_item_browser/New(datum/buildmode/parent)
	src.parent = parent
	read_preferences()

/datum/buildmode_item_browser/Destroy()
	write_preferences()
	SStgui.close_uis(src)
	parent = null
	return ..()

/// Only the client that owns the build mode, while it still holds +BUILD.
/datum/buildmode_item_browser/proc/can_use(client/user_client)
	return user_client && parent && user_client == parent.holder && check_rights_for(user_client, R_BUILD)

/datum/buildmode_item_browser/proc/open()
	var/mob/user = parent?.holder?.mob
	if(user)
		ui_interact(user)

/datum/buildmode_item_browser/proc/close()
	SStgui.close_uis(src)

/datum/buildmode_item_browser/proc/toggle()
	var/mob/user = parent?.holder?.mob
	if(!user)
		return
	if(SStgui.get_open_ui(user, src))
		close()
	else
		open()

/// Called by the buildmode datum whenever something the window shows has changed.
/datum/buildmode_item_browser/proc/send_selection()
	SStgui.update_uis(src)

/datum/buildmode_item_browser/proc/set_status(text)
	status = text
	SStgui.update_uis(src)

/// set_status() for text that changes many times a second (an area drag): every update resends
/// the catalogue page, so the window is refreshed at most every quarter second, with the latest text.
/datum/buildmode_item_browser/proc/set_status_soon(text)
	status = text
	addtimer(CALLBACK(src, PROC_REF(send_selection)), 0.25 SECONDS, TIMER_UNIQUE)

/datum/buildmode_item_browser/ui_state(mob/user)
	return GLOB.buildmode_catalog_state

/datum/buildmode_item_browser/ui_interact(mob/user, datum/tgui/ui)
	if(!can_use(user?.client))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BuildMode", "Build Mode: Spawn Catalogue")
		// One window slot per admin, so its size and position survive re-entering build mode.
		ui.window_key = "buildmode-catalog-[user.ckey]"
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/buildmode_item_browser/ui_close(mob/user)
	. = ..()
	write_preferences()

/datum/buildmode_item_browser/ui_static_data(mob/user)
	return list(
		"categories" = buildmode_catalog_options(buildmode_catalog_categories()),
		"counts" = buildmode_catalog_index()["counts"],
		"total" = length(buildmode_catalog_entries()),
		"armor_classes" = buildmode_catalog_options(buildmode_catalog_armor_classes()),
		"coverage_zones" = buildmode_catalog_coverage_options(),
		"max_amount" = ADMIN_SPAWN_CAP,
		"max_favorites" = BM_MAX_FAVORITES,
		"max_search_length" = BM_SEARCH_MAX_LENGTH,
		"max_offset" = BM_MAX_OFFSET,
	)

/// Card data of one type for this admin, or null when the type is not listed.
/datum/buildmode_item_browser/proc/card(target_type, detailed = FALSE)
	var/list/entry = buildmode_catalog_entries()[target_type]
	if(!entry)
		return null
	var/list/data = list(
		"path" = entry["path"],
		"name" = entry["name"],
		"icon" = entry["icon"],
		"icon_state" = entry["icon_state"],
		"favorite" = (entry["path"] in favorites),
	)
	if(detailed)
		var/atom/atom_type = target_type
		data["desc"] = "[initial(atom_type.desc)]"
		data["is_item"] = ispath(target_type, /obj/item)
		data["is_turf"] = ispath(target_type, /turf)
	return data

/datum/buildmode_item_browser/ui_data(mob/user)
	var/list/found = filtered()
	var/pages = page_count()
	page = clamp(page, 1, pages)
	var/list/cards = list()
	var/first = (page - 1) * BM_ITEMS_PER_PAGE + 1
	for(var/index in first to min(first + BM_ITEMS_PER_PAGE - 1, length(found)))
		cards += list(card(found[index]))

	var/selected_type = parent.selected_item
	var/list/selected = selected_type ? card(selected_type, TRUE) : null
	if(selected_type && !selected) // picked by typepath or from the map, but not a listed type
		var/atom/atom_type = selected_type
		selected = list(
			"path" = "[selected_type]",
			"name" = "[initial(atom_type.name)]",
			"icon" = "[initial(atom_type.icon)]",
			"icon_state" = "[initial(atom_type.icon_state)]",
			"desc" = "[initial(atom_type.desc)]",
			"favorite" = FALSE,
			"unlisted" = TRUE,
			"is_item" = ispath(selected_type, /obj/item),
			"is_turf" = ispath(selected_type, /turf),
		)
	return list(
		"items" = cards,
		"matches" = length(found),
		"page" = page,
		"pages" = pages,
		"category" = category,
		"subcategory" = subcategory,
		"subcategories" = buildmode_catalog_subcategory_options(category),
		"armor_class" = armor_class,
		"coverage" = coverage,
		"search" = search,
		"favorites_count" = length(favorites),
		"recent_count" = length(recent),
		"selected" = selected,
		"amount" = parent.spawn_amount,
		"direction" = parent.build_dir,
		"pixel_x" = parent.spawn_pixel_x,
		"pixel_y" = parent.spawn_pixel_y,
		"mode" = parent.mode?.name,
		"tool" = parent.active_tool,
		"undo_count" = length(parent.undo_stack),
		"undo_label" = parent.undo_label(),
		"tools_open" = tools_open,
		"rmb_delete" = parent.rmb_delete,
		"copying" = !!parent.copy_template(),
		"placing" = !!(selected_type && parent.mode?.uses_selection),
		"can_hands" = isliving(user) && ispath(selected_type, /obj/item),
		"status" = status,
	)

/datum/buildmode_item_browser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/client/user_client = usr?.client
	if(!can_use(user_client))
		return FALSE
	status = null
	switch(action)
		if("search", "category", "subcategory", "armor_class", "coverage", "page")
			return set_navigation(action, params["value"])
		if("select")
			var/target_type = istext(params["path"]) ? text2path(params["path"]) : null
			if(!target_type || !buildmode_catalog_entries()[target_type])
				return FALSE
			if(parent.selected_item == target_type)
				parent.clear_selection()
			else
				parent.select_item(target_type)
			return TRUE
		if("favorite")
			return toggle_favorite(params["path"])
		if("amount", "pixel_x", "pixel_y")
			var/value = text2num("[params["value"]]")
			if(!isnum(value))
				return FALSE
			parent.set_placement_option(action, value)
			return TRUE
		if("direction")
			var/new_dir = text2num("[params["value"]]")
			if(!(new_dir in GLOB.alldirs))
				return FALSE
			parent.change_dir(new_dir)
			return TRUE
		if("reset")
			parent.set_placement_option("amount", 1)
			parent.set_placement_option("pixel_x", 0)
			parent.set_placement_option("pixel_y", 0)
			parent.change_dir(SOUTH)
			return TRUE
		if("cancel")
			parent.clear_selection()
			return TRUE
		if("basic_mode")
			parent.change_mode(/datum/buildmode_mode/basic)
			return TRUE
		if("tool")
			return parent.set_tool(params["value"])
		if("rmb_delete")
			return parent.set_rmb_delete(params["value"])
		if("toggle_tools")
			tools_open = !tools_open
			write_preferences()
			return TRUE
		if("rotate")
			parent.rotate_build_dir()
			return TRUE
		if("undo")
			parent.undo_last()
			return TRUE
		if("spawn_here", "spawn_hands")
			if(!COOLDOWN_FINISHED(src, spawn_cooldown))
				return FALSE
			COOLDOWN_START(src, spawn_cooldown, 0.2 SECONDS)
			var/mob/user = user_client.mob
			var/in_hands = (action == "spawn_hands")
			if(in_hands && (!isliving(user) || !ispath(parent.selected_item, /obj/item)))
				return FALSE
			parent.place_selected(get_turf(user), user, null, null, in_hands)
			return TRUE
		if("quit")
			parent.quit()
			return TRUE
	return FALSE

/// The types to search in, before text and armor filters. Never mutate the shared lists.
/datum/buildmode_item_browser/proc/candidates()
	var/list/entries = buildmode_catalog_entries()
	if(category == "all")
		return entries
	if(category == "favorites" || category == "recent")
		var/list/saved_types = list()
		for(var/path in (category == "favorites" ? favorites : recent))
			var/target_type = text2path(path)
			if(target_type && entries[target_type])
				saved_types += target_type
		return saved_types
	var/list/index = buildmode_catalog_index()
	if(subcategory != "all")
		var/list/groups = index["subcategories"][category]
		return groups?[subcategory] || list()
	return index["categories"][category] || list()

/// Types matching the current navigation, in catalogue order.
/datum/buildmode_item_browser/proc/filtered()
	if(!isnull(results))
		return results
	results = list()
	var/list/entries = buildmode_catalog_entries()
	var/list/search_text = buildmode_catalog_index()["search_text"]
	var/list/terms = splittext(LOWER_TEXT(search), " ")
	terms -= ""
	var/filter_armor = (category == "clothing") && (armor_class != "all" || coverage != "all")
	for(var/path in candidates())
		if(filter_armor)
			var/list/entry = entries[path]
			if(armor_class != "all" && entry["armor_class"] != armor_class)
				continue
			if(coverage != "all" && !(coverage in entry["coverage"]))
				continue
		var/matched = TRUE
		for(var/term in terms)
			if(!findtextEx(search_text[path], term))
				matched = FALSE
				break
		if(matched)
			results += path
	return results

/datum/buildmode_item_browser/proc/invalidate_results(reset_page = FALSE)
	results = null
	if(reset_page)
		page = 1

/datum/buildmode_item_browser/proc/page_count()
	return max(1, CEILING(length(filtered()) / BM_ITEMS_PER_PAGE, 1))

/// All navigation actions share validation, result invalidation and persistence.
/datum/buildmode_item_browser/proc/set_navigation(action, value)
	switch(action)
		if("search")
			if(!istext(value))
				return FALSE
			search = trim(copytext_char(value, 1, BM_SEARCH_MAX_LENGTH + 1))
		if("category")
			if(!(value in buildmode_catalog_categories()))
				return FALSE
			category = value
			subcategory = "all"
			armor_class = "all"
			coverage = "all"
		if("subcategory")
			if(!buildmode_catalog_valid_subcategory(category, value))
				return FALSE
			subcategory = value
		if("armor_class")
			if(category != "clothing" || !(value in buildmode_catalog_armor_classes()))
				return FALSE
			armor_class = value
		if("coverage")
			if(category != "clothing" || !buildmode_catalog_valid_coverage(value))
				return FALSE
			coverage = value
		if("page")
			var/new_page = text2num("[value]")
			if(!isnum(new_page))
				return FALSE
			page = clamp(round(new_page), 1, page_count())
			return TRUE
		else
			return FALSE
	invalidate_results(reset_page = TRUE)
	return TRUE

/datum/buildmode_item_browser/proc/toggle_favorite(path)
	if(!istext(path))
		return FALSE
	var/target_type = text2path(path)
	if(!target_type || !buildmode_catalog_entries()[target_type])
		return FALSE
	path = "[target_type]"
	if(path in favorites)
		favorites -= path
	else if(length(favorites) < BM_MAX_FAVORITES)
		favorites += path
	else
		status = "You already have [BM_MAX_FAVORITES] favourites. Remove some first."
		return TRUE
	if(category == "favorites")
		invalidate_results()
	write_preferences()
	return TRUE

/// Puts a picked type on top of the recent list.
/datum/buildmode_item_browser/proc/remember(target_type)
	if(!buildmode_catalog_entries()[target_type])
		return
	var/path = "[target_type]"
	if(length(recent) && recent[1] == path)
		return
	recent -= path
	recent.Insert(1, path)
	if(length(recent) > BM_MAX_RECENT)
		recent.Cut(BM_MAX_RECENT + 1)
	if(category == "recent")
		invalidate_results()

/datum/buildmode_item_browser/proc/preferences_path()
	var/owner = parent?.holder?.ckey
	if(!owner)
		return null
	return "data/player_saves/[owner[1]]/[owner]/buildmode_catalog.json"

/datum/buildmode_item_browser/proc/navigation_data()
	return list(
		"category" = category,
		"subcategory" = subcategory,
		"armor_class" = armor_class,
		"coverage" = coverage,
		"search" = search,
		"page" = page,
	)

/datum/buildmode_item_browser/proc/read_preferences()
	var/path = preferences_path()
	if(!path || !fexists(path))
		return
	var/list/saved = safe_json_decode(file2text(path))
	if(!islist(saved))
		return
	favorites = buildmode_sanitize_paths(saved["favorites"], BM_MAX_FAVORITES)
	recent = buildmode_sanitize_paths(saved["recent"], BM_MAX_RECENT)
	if(!isnull(saved["tools_open"]))
		tools_open = !!saved["tools_open"]
	if(!isnull(saved["rmb_delete"]))
		parent.rmb_delete = !!saved["rmb_delete"]
	var/list/navigation = saved["navigation"]
	if(islist(navigation) && (navigation["category"] in buildmode_catalog_categories()))
		category = navigation["category"]
		if(buildmode_catalog_valid_subcategory(category, navigation["subcategory"]))
			subcategory = navigation["subcategory"]
		if(category == "clothing")
			if(navigation["armor_class"] in buildmode_catalog_armor_classes())
				armor_class = navigation["armor_class"]
			if(buildmode_catalog_valid_coverage(navigation["coverage"]))
				coverage = navigation["coverage"]
		if(istext(navigation["search"]))
			search = trim(copytext_char(navigation["search"], 1, BM_SEARCH_MAX_LENGTH + 1))
		invalidate_results()
		if(isnum(navigation["page"]))
			page = clamp(round(navigation["page"]), 1, page_count())
	saved_snapshot = json_encode(list("favorites" = favorites, "recent" = recent, "navigation" = navigation_data(), "tools_open" = tools_open, "rmb_delete" = parent.rmb_delete))

/datum/buildmode_item_browser/proc/write_preferences()
	var/path = preferences_path()
	if(!path)
		return FALSE
	var/snapshot = json_encode(list("favorites" = favorites, "recent" = recent, "navigation" = navigation_data(), "tools_open" = tools_open, "rmb_delete" = parent.rmb_delete))
	if(snapshot == saved_snapshot)
		return FALSE
	if(fexists(path))
		fdel(path)
	text2file(snapshot, path)
	saved_snapshot = snapshot
	return TRUE
