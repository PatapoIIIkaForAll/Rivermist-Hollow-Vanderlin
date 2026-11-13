/// Native Loadout tab for the TGUI character creation menu.
/// Data procs here; action dispatch lives in character_setup_handle_loadout_link (same file).

/datum/preferences/proc/get_base_points()
	return 10

/datum/preferences/proc/get_loadout_points_spent()
	var/spent = 0
	for(var/i = 1 to 10)
		var/datum/loadout_item/L = vars["loadout[i]"]
		if(L && L.point_cost)
			spent += L.point_cost
	return spent

/datum/preferences/proc/get_remaining_points()
	var/base = get_base_points()
	var/spent = get_loadout_points_spent() // Languages no longer count toward this
	return base - spent

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
			to_chat(user, span_warning("[item.name] is already in slot [current]."))
			qdel(item)
			return FALSE

		spent_points += other_item.point_cost

	if(spent_points + item.point_cost > total_points)
		to_chat(user, span_warning("Not enough points! Need [item.point_cost], but only have [total_points - spent_points] remaining."))
		qdel(item)
		return FALSE

	vars["loadout[slot]"] = item
	to_chat(user, span_notice("Selected [item.name] for slot [slot]."))
	return TRUE

/datum/preferences/proc/save_preset(preset_slot)
	if(preset_slot < 1 || preset_slot > 3)
		return FALSE

	var/list/preset = list(
		"loadout1" = loadout1?.type,
		"loadout2" = loadout2?.type,
		"loadout3" = loadout3?.type,
		"loadout4" = loadout4?.type,
		"loadout5" = loadout5?.type,
		"loadout6" = loadout6?.type,
		"loadout7" = loadout7?.type,
		"loadout8" = loadout8?.type,
		"loadout9" = loadout9?.type,
		"loadout10" = loadout10?.type,
		"loadout_1_name" = loadout_1_name,
		"loadout_2_name" = loadout_2_name,
		"loadout_3_name" = loadout_3_name,
		"loadout_4_name" = loadout_4_name,
		"loadout_5_name" = loadout_5_name,
		"loadout_6_name" = loadout_6_name,
		"loadout_7_name" = loadout_7_name,
		"loadout_8_name" = loadout_8_name,
		"loadout_9_name" = loadout_9_name,
		"loadout_10_name" = loadout_10_name,
		"loadout_1_desc" = loadout_1_desc,
		"loadout_2_desc" = loadout_2_desc,
		"loadout_3_desc" = loadout_3_desc,
		"loadout_4_desc" = loadout_4_desc,
		"loadout_5_desc" = loadout_5_desc,
		"loadout_6_desc" = loadout_6_desc,
		"loadout_7_desc" = loadout_7_desc,
		"loadout_8_desc" = loadout_8_desc,
		"loadout_9_desc" = loadout_9_desc,
		"loadout_10_desc" = loadout_10_desc,
		"loadout_1_hex" = loadout_1_hex,
		"loadout_2_hex" = loadout_2_hex,
		"loadout_3_hex" = loadout_3_hex,
		"loadout_4_hex" = loadout_4_hex,
		"loadout_5_hex" = loadout_5_hex,
		"loadout_6_hex" = loadout_6_hex,
		"loadout_7_hex" = loadout_7_hex,
		"loadout_8_hex" = loadout_8_hex,
		"loadout_9_hex" = loadout_9_hex,
		"loadout_10_hex" = loadout_10_hex,
	)

	vars["loadout_preset_[preset_slot]"] = preset
	return TRUE

/datum/preferences/proc/load_preset(preset_slot)
	if(preset_slot < 1 || preset_slot > 3)
		return FALSE

	var/list/preset = vars["loadout_preset_[preset_slot]"]
	if(!preset || !istype(preset, /list) || !preset.len)
		return FALSE

	// Restore all values from preset with validation
	// Use string_to_typepath() to handle both type paths and JSON-decoded strings

	// Load loadout types and instantiate them if valid
	var/loadout_type = string_to_typepath(preset["loadout1"])
	if(loadout_type && ispath(loadout_type, /datum/loadout_item))
		loadout1 = new loadout_type()
	else
		loadout1 = null

	var/loadout_type2 = string_to_typepath(preset["loadout2"])
	if(loadout_type2 && ispath(loadout_type2, /datum/loadout_item))
		loadout2 = new loadout_type2()
	else
		loadout2 = null

	var/loadout_type3 = string_to_typepath(preset["loadout3"])
	if(loadout_type3 && ispath(loadout_type3, /datum/loadout_item))
		loadout3 = new loadout_type3()
	else
		loadout3 = null

	var/loadout_type4 = string_to_typepath(preset["loadout4"])
	if(loadout_type4 && ispath(loadout_type4, /datum/loadout_item))
		loadout4 = new loadout_type4()
	else
		loadout4 = null

	var/loadout_type5 = string_to_typepath(preset["loadout5"])
	if(loadout_type5 && ispath(loadout_type5, /datum/loadout_item))
		loadout5 = new loadout_type5()
	else
		loadout5 = null

	var/loadout_type6 = string_to_typepath(preset["loadout6"])
	if(loadout_type6 && ispath(loadout_type6, /datum/loadout_item))
		loadout6 = new loadout_type6()
	else
		loadout6 = null

	var/loadout_type7 = string_to_typepath(preset["loadout7"])
	if(loadout_type7 && ispath(loadout_type7, /datum/loadout_item))
		loadout7 = new loadout_type7()
	else
		loadout7 = null

	var/loadout_type8 = string_to_typepath(preset["loadout8"])
	if(loadout_type8 && ispath(loadout_type8, /datum/loadout_item))
		loadout8 = new loadout_type8()
	else
		loadout8 = null

	var/loadout_type9 = string_to_typepath(preset["loadout9"])
	if(loadout_type9 && ispath(loadout_type9, /datum/loadout_item))
		loadout9 = new loadout_type9()
	else
		loadout9 = null

	var/loadout_type10 = string_to_typepath(preset["loadout10"])
	if(loadout_type10 && ispath(loadout_type10, /datum/loadout_item))
		loadout10 = new loadout_type10()
	else
		loadout10 = null

	// Always restore all string values from preset (including null/empty values)
	loadout_1_name = preset["loadout_1_name"]
	loadout_2_name = preset["loadout_2_name"]
	loadout_3_name = preset["loadout_3_name"]
	loadout_4_name = preset["loadout_4_name"]
	loadout_5_name = preset["loadout_5_name"]
	loadout_6_name = preset["loadout_6_name"]
	loadout_7_name = preset["loadout_7_name"]
	loadout_8_name = preset["loadout_8_name"]
	loadout_9_name = preset["loadout_9_name"]
	loadout_10_name = preset["loadout_10_name"]

	loadout_1_desc = preset["loadout_1_desc"]
	loadout_2_desc = preset["loadout_2_desc"]
	loadout_3_desc = preset["loadout_3_desc"]
	loadout_4_desc = preset["loadout_4_desc"]
	loadout_5_desc = preset["loadout_5_desc"]
	loadout_6_desc = preset["loadout_6_desc"]
	loadout_7_desc = preset["loadout_7_desc"]
	loadout_8_desc = preset["loadout_8_desc"]
	loadout_9_desc = preset["loadout_9_desc"]
	loadout_10_desc = preset["loadout_10_desc"]

	loadout_1_hex = preset["loadout_1_hex"]
	loadout_2_hex = preset["loadout_2_hex"]
	loadout_3_hex = preset["loadout_3_hex"]
	loadout_4_hex = preset["loadout_4_hex"]
	loadout_5_hex = preset["loadout_5_hex"]
	loadout_6_hex = preset["loadout_6_hex"]
	loadout_7_hex = preset["loadout_7_hex"]
	loadout_8_hex = preset["loadout_8_hex"]
	loadout_9_hex = preset["loadout_9_hex"]
	loadout_10_hex = preset["loadout_10_hex"]

	return TRUE

/datum/preferences/proc/clear_preset(preset_slot)
	if(preset_slot < 1 || preset_slot > 3)
		return FALSE

	vars["loadout_preset_[preset_slot]"] = null
	return TRUE

/datum/preferences/proc/get_preset_summary(preset_slot)
	if(preset_slot < 1 || preset_slot > 3)
		return "Invalid Slot"

	var/list/preset = vars["loadout_preset_[preset_slot]"]
	if(!preset || !preset.len)
		return "Empty"

	// Build summary string
	var/summary = ""

	// Count loadout items
	var/loadout_count = 0
	for(var/i = 1 to 10)
		var/loadout_var = "loadout[i]"
		var/loadout_path = string_to_typepath(preset[loadout_var])
		if(ispath(loadout_path, /datum/loadout_item))
			loadout_count++
	if(loadout_count > 0)
		summary += " | [loadout_count] item[loadout_count > 1 ? "s" : ""]"

	return summary

/// Catalog fields that stay fixed for the round, keyed by loadout item; empty until the spritesheet is ready.
GLOBAL_LIST_EMPTY(loadout_catalog_fields)

/proc/get_loadout_catalog_fields()
	if(length(GLOB.loadout_catalog_fields))
		return GLOB.loadout_catalog_fields
	var/datum/asset/spritesheet/spritesheet = get_asset_datum(/datum/asset/spritesheet/loadout_items)
	var/list/fields_by_item = list()
	for(var/datum/loadout_item/item as anything in GLOB.loadout_items)
		var/obj/item/item_type = item.item_path
		if(!item_type)
			continue
		fields_by_item[item] = list(
			"name" = item.name,
			"desc" = initial(item_type.desc) || item.description,
			"point_cost" = item.point_cost,
			"typepath" = "[item.type]",
			"icon" = spritesheet.icon_class_name(sanitize_css_class_name("loadout_item_[REF(item)]")),
		)
	// A spritesheet still loading has no class names yet, so build again next time.
	if(spritesheet.fully_generated)
		GLOB.loadout_catalog_fields = fields_by_item
	return fields_by_item

/datum/preferences/proc/character_setup_loadout_static(mob/user)
	var/list/catalog = list()
	var/list/fields_by_item = get_loadout_catalog_fields()
	for(var/datum/loadout_item/item as anything in fields_by_item)
		var/list/fields = fields_by_item[item]
		var/list/entry = fields.Copy()
		entry["nobility_locked"] = !item.nobility_check(user)
		UNTYPED_LIST_ADD(catalog, entry)
	return catalog

/datum/preferences/proc/character_setup_loadout_slots_data()
	var/list/slots = list()
	for(var/slot_number in 1 to 10)
		var/datum/loadout_item/item = vars["loadout[slot_number]"]
		UNTYPED_LIST_ADD(slots, list(
			"slot" = slot_number,
			"item_name" = item ? item.name : null,
			"typepath" = item ? "[item.type]" : null,
			"point_cost" = item ? item.point_cost : 0,
			"custom_name" = vars["loadout_[slot_number]_name"],
			"custom_desc" = vars["loadout_[slot_number]_desc"],
			"custom_hex" = vars["loadout_[slot_number]_hex"],
		))
	return slots

/datum/preferences/proc/character_setup_loadout_points_data()
	var/total = get_base_points()
	var/spent = get_loadout_points_spent()
	return list("total" = total, "spent" = spent, "remaining" = total - spent)

/datum/preferences/proc/character_setup_loadout_presets_data()
	var/list/presets = list()
	for(var/preset_slot in 1 to 3)
		UNTYPED_LIST_ADD(presets, list(
			"slot" = preset_slot,
			"summary" = get_preset_summary(preset_slot),
		))
	return presets

/// Stores the hex for a named dye choice ("None" clears). Returns TRUE on success.
/// The "Custom" list entry carries the CUSTOM_RGB sentinel, not a hex — callers
/// must route that through the interactive color picker instead.
/datum/preferences/proc/character_setup_apply_loadout_color(slot, choice)
	if(!isnum(slot) || slot < 1 || slot > 10)
		return FALSE
	if(choice == "None")
		vars["loadout_[slot]_hex"] = null
		return TRUE
	var/hex = GLOB.colorlist[choice]
	if(!hex || hex == "CUSTOM_RGB")
		return FALSE
	vars["loadout_[slot]_hex"] = hex
	return TRUE

/// Dispatch for the Loadout tab (href preference "character_setup_loadout").
/// Tasks: select/clear/rename/describe/color (slot 1-10),
///        preset_save/preset_load/preset_clear (slot 1-3).
/datum/preferences/proc/character_setup_handle_loadout_link(mob/user, list/href_list)
	var/task = href_list["task"]

	if(task == "preset_save" || task == "preset_load" || task == "preset_clear")
		// tgui params arrive as JSON numbers; stringify before text2num (same as the "tab" handler)
		var/preset_slot = text2num("[href_list["slot"]]")
		if(!preset_slot || preset_slot < 1 || preset_slot > 3)
			return TRUE
		switch(task)
			if("preset_save")
				if(save_preset(preset_slot))
					save_character()
					to_chat(user, span_notice("Saved current setup to Preset [preset_slot]!"))
			if("preset_load")
				if(load_preset(preset_slot))
					save_character()
					to_chat(user, span_notice("Loaded Preset [preset_slot]!"))
				else
					to_chat(user, span_warning("Preset [preset_slot] is empty or invalid."))
			if("preset_clear")
				if(clear_preset(preset_slot))
					save_character()
					to_chat(user, span_notice("Cleared Preset [preset_slot]."))
		update_menu_data(user)
		return TRUE

	var/slot = text2num("[href_list["slot"]]")
	if(!slot || slot < 1 || slot > 10)
		return TRUE

	switch(task)
		if("select")
			var/item_type = text2path(href_list["typepath"])
			if(!ispath(item_type, /datum/loadout_item))
				return TRUE
			try_select_loadout_item(user, item_type, slot)
		if("clear")
			vars["loadout[slot]"] = null
			vars["loadout_[slot]_name"] = null
			vars["loadout_[slot]_desc"] = null
			vars["loadout_[slot]_hex"] = null
		if("rename")
			if(!vars["loadout[slot]"])
				return TRUE
			var/new_name = browser_input_text(user, "Enter a custom name for this item (leave blank to use default):", "Rename Item", vars["loadout_[slot]_name"], MAX_NAME_LEN, multiline = TRUE)
			if(!isnull(new_name))
				vars["loadout_[slot]_name"] = new_name
		if("describe")
			if(!vars["loadout[slot]"])
				return TRUE
			var/new_desc = browser_input_text(user, "Enter a custom description for this item (leave blank to use default):", "Describe Item", vars["loadout_[slot]_desc"], max_length = 500, multiline = TRUE)
			if(!isnull(new_desc))
				vars["loadout_[slot]_desc"] = new_desc
		if("color")
			if(!vars["loadout[slot]"])
				return TRUE
			var/list/color_choices = list("None")
			for(var/color_name in GLOB.colorlist)
				color_choices += color_name
			var/new_color = browser_input_list(user, "Choose a color for this item:", "Item Color", color_choices, vars["loadout_[slot]_hex"])
			if(!new_color)
				return TRUE
			if(GLOB.colorlist[new_color] == "CUSTOM_RGB")
				var/current_color = vars["loadout_[slot]_hex"] || "#FFFFFF"
				var/newer_color = tgui_color_picker(user, "Select color:", "Custom Color", sanitize_hexcolor(current_color, 6, TRUE, "#ffffff"))
				if(newer_color)
					vars["loadout_[slot]_hex"] = sanitize_hexcolor(newer_color, include_crunch = 1)
			else
				character_setup_apply_loadout_color(slot, new_color)

	update_menu_data(user)
	return TRUE
