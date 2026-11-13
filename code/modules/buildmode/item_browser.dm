/// Item picker popup; opened once, then updated in place through output() calls.
/datum/buildmode_item_browser
	var/datum/buildmode/parent
	var/datum/browser/popup
	var/is_open = FALSE
	var/category = BM_CATEGORY_TURF
	var/page = 1
	var/search = ""
	/// Newest request number from the page, echoed back so it can drop stale replies.
	var/last_seq = 0
	COOLDOWN_DECLARE(toggle_cooldown)

/datum/buildmode_item_browser/New(datum/buildmode/parent)
	src.parent = parent

/datum/buildmode_item_browser/Destroy()
	close()
	QDEL_NULL(popup)
	parent = null
	return ..()

/datum/buildmode_item_browser/proc/toggle()
	// Rapid open/close cycles recreate the WebView window, which can crash the client.
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		return
	if(is_open)
		close()
	else
		open()

/datum/buildmode_item_browser/proc/open()
	var/mob/user = parent?.holder?.mob
	if(!user)
		return
	COOLDOWN_START(src, toggle_cooldown, 0.5 SECONDS)
	if(popup?.user != user)
		QDEL_NULL(popup)
		popup = new(user, BM_BROWSER_WINDOW, "BuildMode Items", 600, 800, src)
		popup.add_stylesheet("buildmodestyle", 'html/browser/buildmode.css')
		popup.add_script("buildmode", 'html/browser/buildmode.js')
	popup.set_content(build_shell())
	popup.open()
	is_open = TRUE

/datum/buildmode_item_browser/proc/close()
	if(!is_open)
		return
	is_open = FALSE
	COOLDOWN_START(src, toggle_cooldown, 0.5 SECONDS)
	var/client/user_client = parent?.holder
	if(user_client)
		user_client << browse(null, "window=[BM_BROWSER_WINDOW]")

/datum/buildmode_item_browser/proc/build_shell()
	var/list/dat = list()
	dat += "<div class='buildmode-browser'>"
	dat += "<div class='tabs' id='bm-tabs'>"
	var/list/names = buildmode_category_names()
	for(var/category_id in names)
		dat += "<a class='tab' href='#' data-category='[category_id]'>[names[category_id]]</a>"
	dat += "</div>"
	dat += "<div class='search-container'>"
	dat += "<input type='text' class='search-bar' id='bm-search' maxlength='[BM_SEARCH_MAX_LENGTH]' placeholder='Search (name or type path)...'>"
	dat += "</div>"
	dat += "<div class='bm-selection'><span id='bm-selected'></span><a class='button' href='#' id='bm-clear'>Clear</a></div>"
	dat += "<div class='pagination' id='bm-pages-top'></div>"
	dat += "<div class='item-grid' id='bm-grid'></div>"
	dat += "<div class='pagination' id='bm-pages-bottom'></div>"
	dat += "<div class='bm-hint'>Hold Shift over the map in Basic mode to place at the exact pixel.</div>"
	dat += "</div>"
	var/initial_state = replacetext(json_encode(build_state()), "</", "<\\/")
	dat += "<script type='text/javascript'>buildmodeInit('[REF(src)]', [initial_state]);</script>"
	return dat.Join()

/datum/buildmode_item_browser/proc/build_state()
	var/list/matches = buildmode_search_catalog(category, search)
	var/total = length(matches)
	var/page_count = max(1, CEILING(total / BM_ITEMS_PER_PAGE, 1))
	page = clamp(page, 1, page_count)
	var/list/items = list()
	if(total)
		var/first = (page - 1) * BM_ITEMS_PER_PAGE + 1
		var/last = min(first + BM_ITEMS_PER_PAGE - 1, total)
		for(var/index in first to last)
			var/atom/item_type = matches[index]
			items += list(list("[item_type]", "[initial(item_type.name)]", "\ref[initial(item_type.icon)]", "[initial(item_type.icon_state)]", initial(item_type.dir)))
	return list(
		"seq" = last_seq,
		"category" = category,
		"search" = search,
		"page" = page,
		"pages" = page_count,
		"total" = total,
		"items" = items,
		"selected" = selection_data(),
	)

/datum/buildmode_item_browser/proc/selection_data()
	var/atom/selected = parent?.selected_item
	if(!selected)
		return null
	return list("path" = "[selected]", "name" = "[initial(selected.name)]")

/datum/buildmode_item_browser/proc/send_update()
	send_to_page("buildmodeUpdate", build_state())

/datum/buildmode_item_browser/proc/send_selection()
	send_to_page("buildmodeSelect", list("selected" = selection_data()))

/datum/buildmode_item_browser/proc/send_to_page(function_name, list/data)
	var/client/user_client = parent?.holder
	if(!is_open || !user_client)
		return
	user_client << output(url_encode(json_encode(data)), "[BM_BROWSER_WINDOW].browser:[function_name]")

/datum/buildmode_item_browser/Topic(href, list/href_list)
	if(!parent || usr?.client != parent.holder)
		return
	if(href_list["close"])
		is_open = FALSE
		return
	if(href_list["item"])
		parent.select_item(text2path(href_list["item"]))
		return
	if(href_list["clear"])
		parent.clear_selection()
		return

	var/new_seq = text2num(href_list["seq"])
	if(new_seq)
		last_seq = new_seq
	if(href_list["category"])
		var/new_category = text2num(href_list["category"])
		var/list/names = buildmode_category_names()
		if(new_category != category && names["[new_category]"])
			category = new_category
			page = 1
	if("search" in href_list)
		var/new_search = trim(copytext_char(href_list["search"], 1, BM_SEARCH_MAX_LENGTH + 1))
		if(new_search != search)
			search = new_search
			page = 1
	if(href_list["page"])
		page = text2num(href_list["page"]) || 1
	send_update()

/// Category ids (as text) to tab labels, in tab order.
/proc/buildmode_category_names()
	var/static/list/names
	names ||= list(
		"[BM_CATEGORY_TURF]" = "Turfs",
		"[BM_CATEGORY_OBJ]" = "Objects",
		"[BM_CATEGORY_MOB]" = "Mobs",
		"[BM_CATEGORY_ITEM]" = "Items",
		"[BM_CATEGORY_WEAPON]" = "Weapons",
		"[BM_CATEGORY_CLOTHING]" = "Clothing",
		"[BM_CATEGORY_FOOD]" = "Food",
		"[BM_CATEGORY_REAGENT_CONTAINERS]" = "Liquid Vessels",
	)
	return names

/// Sorted placeable types for a category; built on first use and shared by all admins.
/proc/buildmode_category_types(category)
	var/static/list/types_by_category
	types_by_category ||= list()
	var/key = "[category]"
	if(!types_by_category[key])
		types_by_category[key] = build_buildmode_category(category)
	return types_by_category[key]

/proc/build_buildmode_category(category)
	var/list/candidates
	var/list/excluded_roots = list()
	switch(category)
		if(BM_CATEGORY_TURF)
			candidates = subtypesof(/turf)
			excluded_roots = list(/turf/template_noop)
		if(BM_CATEGORY_OBJ)
			candidates = subtypesof(/obj)
			excluded_roots = list(/obj/item, /obj/effect, /obj/abstract)
		if(BM_CATEGORY_MOB)
			candidates = subtypesof(/mob)
			excluded_roots = list(/mob/dead, /mob/camera)
		if(BM_CATEGORY_ITEM)
			candidates = subtypesof(/obj/item)
			excluded_roots = list(/obj/item/clothing, /obj/item/weapon, /obj/item/reagent_containers)
		if(BM_CATEGORY_WEAPON)
			candidates = subtypesof(/obj/item/weapon)
		if(BM_CATEGORY_CLOTHING)
			candidates = subtypesof(/obj/item/clothing)
		if(BM_CATEGORY_FOOD)
			candidates = subtypesof(/obj/item/reagent_containers/food)
		if(BM_CATEGORY_REAGENT_CONTAINERS)
			candidates = subtypesof(/obj/item/reagent_containers)
			excluded_roots = list(/obj/item/reagent_containers/food)
		else
			return list()

	. = list()
	for(var/atom/candidate as anything in candidates)
		if(IS_ABSTRACT(candidate) || !initial(candidate.icon))
			continue
		var/excluded = FALSE
		for(var/root in excluded_roots)
			if(ispath(candidate, root))
				excluded = TRUE
				break
		if(!excluded)
			. += candidate
	sortTim(., GLOBAL_PROC_REF(cmp_typepaths_asc))

/// Lowercase "name path" text that searches match against.
/proc/buildmode_search_text(atom/item_type)
	var/static/list/text_by_type
	text_by_type ||= list()
	. = text_by_type[item_type]
	if(isnull(.))
		. = LOWER_TEXT("[initial(item_type.name)] [item_type]")
		text_by_type[item_type] = .

/// Types in a category whose name or path contains every space-separated search term.
/proc/buildmode_search_catalog(category, search)
	var/list/types = buildmode_category_types(category)
	var/list/terms = splittext(LOWER_TEXT(search), " ")
	terms -= ""
	if(!length(terms))
		return types
	. = list()
	for(var/item_type in types)
		var/text = buildmode_search_text(item_type)
		var/matched = TRUE
		for(var/term in terms)
			if(!findtextEx(text, term))
				matched = FALSE
				break
		if(matched)
			. += item_type
