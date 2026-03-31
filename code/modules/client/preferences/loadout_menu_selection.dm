/datum/loadout_menu
	var/current_slot

/datum/loadout_menu/Destroy()
	current_slot = null
	. = ..()

/datum/loadout_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutMenu", "Loadout Item Selection")
		ui.set_state(GLOB.always_state)
		ui.open()

/datum/loadout_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/loadout_items)
	)

/datum/loadout_menu/ui_data(mob/user)
	var/list/data = ..()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return data

	var/datum/loadout_item/current_item
	if(current_slot >= 1 && current_slot <= 10)
		current_item = prefs.vars["loadout[current_slot]"]

	data["current_slot"] = current_slot
	data["total_points"] = prefs.get_base_points()
	data["remaining_points"] = prefs.get_remaining_points()
	data["slot_budget"] = prefs.get_remaining_points() + (current_item?.point_cost || 0)
	data["current_item_type"] = current_item ? "[current_item.type]" : null

	var/list/selected_slots = list()
	for(var/slot = 1 to 10)
		var/datum/loadout_item/item = prefs.vars["loadout[slot]"]
		if(!item)
			continue

		UNTYPED_LIST_ADD(selected_slots, list(
			"slot" = slot,
			"name" = item.name,
			"typepath" = "[item.type]",
		))

	data["selected_slots"] = selected_slots
	return data

/datum/loadout_menu/ui_static_data(mob/user)
	var/list/data = ..()
	var/list/loadout_items = list()
	var/datum/asset/spritesheet/spritesheet = get_asset_datum(/datum/asset/spritesheet/loadout_items)

	for(var/datum/loadout_item/item as anything in GLOB.loadout_items)
		var/obj/item/item_type = item.item_path
		if(!item_type)
			continue

		UNTYPED_LIST_ADD(loadout_items, list(
			"name" = item.name,
			"desc" = initial(item_type.desc),
			"point_cost" = item.point_cost,
			"nobility_check" = item.nobility_check(user),
			"typepath" = "[item.type]",
			"ref" = REF(item),
			"icon" = spritesheet.icon_class_name(sanitize_css_class_name("loadout_item_[REF(item)]")),
		))

	data["loadout_items"] = loadout_items
	return data

/datum/loadout_menu/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(!current_slot || current_slot < 1 || current_slot > 10)
		ui.close()
		return

	var/mob/user = ui.user
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		ui.close()
		return

	switch(action)
		if("choose_item")
			var/datum/loadout_item/item_template = locate(params["ref"])
			if(!istype(item_template))
				ui.close()
				prefs.open_loadout_menu(user)
				return TRUE

			prefs.try_select_loadout_item(user, item_template.type, current_slot)
			ui.close()
			prefs.open_loadout_menu(user)
			return TRUE

/datum/preferences/proc/open_loadout_menu_selection(mob/user, slot)
	if(!user || !user.client)
		return

	var/target_slot = slot || current_loadout_slot || 1
	if(target_slot < 1 || target_slot > 10)
		target_slot = 1

	current_loadout_slot = target_slot

	if(!loadout_menu)
		loadout_menu = new()

	loadout_menu.current_slot = target_slot
	loadout_menu.ui_interact(user)

/datum/preferences/proc/try_select_loadout_item(mob/user, item_type, slot)
	if(!user || !user.client)
		return FALSE
	if(!slot || slot < 1 || slot > 10)
		return FALSE
	if(!ispath(item_type, /datum/loadout_item))
		return FALSE

	var/datum/loadout_item/item = new item_type
	if(!istype(item))
		return FALSE

	if(!item.nobility_check(user))
		temp_loadout_selection = null
		to_chat(user, span_warning("[item.name] is not available for your character."))
		qdel(item)
		return FALSE

	var/total_points = get_base_points()
	var/spent_points = 0
	for(var/current = 1 to 10)
		if(current == slot)
			continue

		var/datum/loadout_item/other_item = vars["loadout[current]"]
		if(!other_item)
			continue

		if(other_item.type == item.type)
			temp_loadout_selection = null
			to_chat(user, span_warning("[item.name] is already in slot [current]."))
			qdel(item)
			return FALSE

		spent_points += other_item.point_cost

	if(spent_points + item.point_cost > total_points)
		temp_loadout_selection = null
		to_chat(user, span_warning("Not enough points! Need [item.point_cost], but only have [total_points - spent_points] remaining."))
		qdel(item)
		return FALSE

	current_loadout_slot = slot
	temp_loadout_selection = null
	vars["loadout[slot]"] = item
	to_chat(user, span_notice("Selected [item.name] for slot [slot]."))
	return TRUE

/datum/preferences/proc/handle_loadout_topic(mob/user, href_list)
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		var/datum/browser/browser = locate(href_list["popup"])
		if(browser)
			browser.close()
		return

	switch(href_list["preference"])
		if("choose_item")
			var/item_type = text2path(href_list["loadout_type"])
			var/slot = text2num(href_list["slot"])
			prefs.try_select_loadout_item(user, item_type, slot)

			var/datum/browser/browser = locate(href_list["popup"])
			if(browser)
				browser.close()

			prefs.open_loadout_menu(user)
			return TRUE
