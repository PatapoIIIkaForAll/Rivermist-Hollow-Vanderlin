/**
 * Basic mode tools: place, exact pixel, paint area, erase area, copy, pick type, delete.
 *
 * The tool picked in the catalogue decides what a plain left click does. The modifier hotkeys
 * always work, whatever tool is picked, so experienced builders never need the buttons:
 * the catalogue shows each tool's hotkey next to its button.
 *
 * Area tools follow the mouse: the middle button (or the left button with an area tool picked)
 * is held down on the first corner and released on the opposite one. Erasing also works as a
 * left drag with the Delete tool, and as Ctrl + left drag with Paint area; a press that does not
 * leave its tile stays an ordinary click (delete one object, copy).
 *
 * Every map position is the tile under the cursor (cursor_turf()), not the turf of the clicked
 * object: big sprites hang over their neighbours, and in darkness or outside the field of view
 * the click catcher gets the mouse instead of the map.
 */

/datum/buildmode
	/// What a plain left click does in Basic mode, a BM_TOOL_* value.
	var/active_tool = BM_TOOL_PLACE
	/// Whether a plain right click with nothing selected deletes. Ctrl + right click always does.
	var/rmb_delete = TRUE
	/// Exact object copied with Ctrl + left click. Placement duplicates it, variables included.
	var/datum/weakref/copy_ref
	/// Area drag in progress: first and current corner.
	var/turf/area_start
	var/turf/area_end
	/// Mouse button that drives the drag in progress (LEFT_CLICK or MIDDLE_CLICK).
	var/area_button
	/// Whether the drag in progress erases instead of painting.
	var/area_erase = FALSE
	/// The press is also an ordinary click: it only becomes a rectangle once it leaves its tile.
	var/area_needs_move = FALSE
	/// Outline of the dragged rectangle, shown only to the builder.
	var/list/area_images

/proc/buildmode_tool_ids()
	var/static/list/tools = list(BM_TOOL_PLACE, BM_TOOL_PIXEL, BM_TOOL_AREA, BM_TOOL_ERASE, BM_TOOL_COPY, BM_TOOL_PICK, BM_TOOL_DELETE)
	return tools

/datum/buildmode/proc/setup_tools()
	RegisterSignal(holder, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_client_mousedown))
	RegisterSignal(holder, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(on_client_mousedrag))
	RegisterSignal(holder, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_client_mouseup))

/datum/buildmode/proc/cleanup_tools()
	if(holder)
		UnregisterSignal(holder, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEDRAG, COMSIG_CLIENT_MOUSEUP))
	clear_area()
	copy_ref = null
	clear_undo()

/// Picks the tool a plain left click uses. Tools belong to Basic mode, so this switches to it.
/datum/buildmode/proc/set_tool(tool)
	if(!(tool in buildmode_tool_ids()))
		return FALSE
	active_tool = tool
	clear_area()
	if(!istype(mode, /datum/buildmode_mode/basic))
		change_mode(/datum/buildmode_mode/basic)
	item_browser?.send_selection()
	return TRUE

/// Locks or unlocks deleting with a plain right click. Ctrl + right click always deletes.
/datum/buildmode/proc/set_rmb_delete(enabled)
	rmb_delete = !!enabled
	item_browser?.set_status(rmb_delete ? "Right click deletes again (after clearing the selection)." : "Right-click deleting is locked. Ctrl + right click still deletes.")
	item_browser?.write_preferences()
	return TRUE

/// The object being copied, if it still exists and still matches the selection.
/datum/buildmode/proc/copy_template()
	var/atom/movable/template = copy_ref?.resolve()
	if(QDELETED(template) || template.type != selected_item)
		copy_ref = null
		return null
	return template

/// Builds one copy of the selection on target: an exact duplicate when copying, a fresh instance otherwise.
/// built_type pins the type for actions that sleep, so a new pick meanwhile does not change what they build.
/datum/buildmode/proc/spawn_one(turf/target, atom/movable/template, built_type = selected_item)
	var/atom/movable/built
	if(template && !QDELETED(template))
		built = buildmode_duplicate(template, target)
	else
		if(!built_type)
			return null
		built = new built_type(target)
	if(QDELETED(built))
		return null
	built.flags_1 |= ADMIN_SPAWNED_1
	built.setDir(build_dir)
	return built

/// Makes an exact copy of object the selection. Turfs are copied by type.
/datum/buildmode/proc/copy_object(atom/object)
	if(QDELETED(object) || istype(object, /atom/movable/screen))
		return FALSE
	if(ismob(object))
		var/mob/target_mob = object
		if(target_mob.ckey)
			item_browser?.set_status("Players cannot be copied.")
			return FALSE
	if(isturf(object))
		return select_item(object.type)
	if(!ismovable(object))
		return FALSE
	if(!select_item(object.type))
		return FALSE
	copy_ref = WEAKREF(object)
	change_dir(object.dir)
	item_browser?.set_status("Copying [object.name] exactly, variables included. Left click to place copies.")
	return TRUE

/datum/buildmode/proc/rotate_build_dir()
	change_dir(turn(build_dir, -90))
	item_browser?.set_status("Build direction: [dir2text(build_dir)].")

/// Basic mode click handling: hotkeys first, then the picked tool.
/datum/buildmode/proc/handle_tool_click(client/c, list/modifiers, atom/object)
	// Middle button work is done by the drag handlers, including a click without movement.
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return
	var/ctrl = LAZYACCESS(modifiers, CTRL_CLICKED)
	var/alt = LAZYACCESS(modifiers, ALT_CLICKED)
	var/shift = LAZYACCESS(modifiers, SHIFT_CLICKED)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(ctrl)
			delete_object(c.mob, object)
		else if(alt)
			rotate_build_dir()
		else if(selected_item)
			// The first right click only drops the selection, so a stray click never deletes.
			clear_selection()
		else if(rmb_delete)
			delete_object(c.mob, object)
		else
			item_browser?.set_status("Right-click deleting is locked. Use Ctrl + right click, or unlock it in Tools.")
		return
	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		return

	if(alt)
		use_tool(BM_TOOL_PICK, c, modifiers, object)
	else if(ctrl)
		use_tool(BM_TOOL_COPY, c, modifiers, object)
	else if(shift)
		use_tool(BM_TOOL_PIXEL, c, modifiers, object)
	else
		use_tool(active_tool, c, modifiers, object)

/datum/buildmode/proc/use_tool(tool, client/c, list/modifiers, atom/object)
	switch(tool)
		if(BM_TOOL_PLACE)
			if(!selected_item)
				to_chat(c, span_warning("Pick something in the catalogue first."))
				return
			place_selected(cursor_turf(object, modifiers), c.mob)
		if(BM_TOOL_PIXEL)
			if(!selected_item)
				to_chat(c, span_warning("Pick something in the catalogue first."))
				return
			var/list/cursor = resolve_cursor(modifiers)
			if(cursor)
				place_selected(cursor[1], c.mob, cursor[2], cursor[3])
			else
				place_selected(cursor_turf(object, modifiers), c.mob)
		if(BM_TOOL_COPY)
			// After taking a copy, the next left click places it instead of copying again.
			if(copy_object(object))
				active_tool = BM_TOOL_PLACE
				item_browser?.send_selection()
		if(BM_TOOL_PICK)
			if(isturf(object) || isobj(object) || ismob(object))
				select_item(object.type)
		if(BM_TOOL_DELETE)
			delete_object(c.mob, object)
		// BM_TOOL_AREA and BM_TOOL_ERASE work through the drag handlers.

/// Which area drag a button press starts: "paint", "erase" or null.
/datum/buildmode/proc/area_drag_kind(list/modifiers)
	if(!istype(mode, /datum/buildmode_mode/basic))
		return null
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return LAZYACCESS(modifiers, CTRL_CLICKED) ? "erase" : "paint"
	if(!LAZYACCESS(modifiers, LEFT_CLICK) || LAZYACCESS(modifiers, ALT_CLICKED) || LAZYACCESS(modifiers, SHIFT_CLICKED))
		return null
	var/ctrl = LAZYACCESS(modifiers, CTRL_CLICKED)
	switch(active_tool)
		if(BM_TOOL_AREA)
			return ctrl ? "erase" : "paint" // Ctrl: the same as Ctrl + middle drag
		if(BM_TOOL_ERASE, BM_TOOL_DELETE)
			return ctrl ? null : "erase"
	return null

/// Whether a press that starts an area drag is also an ordinary click (Ctrl + left copies, left with
/// Delete deletes one object). Such a press only becomes a rectangle once it reaches another tile.
/datum/buildmode/proc/area_drag_needs_move(list/modifiers)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return FALSE
	return LAZYACCESS(modifiers, CTRL_CLICKED) || active_tool == BM_TOOL_DELETE

/**
 * The tile under the mouse pointer for a click or mouse event on object, or null (HUD, off the map).
 *
 * A sprite bigger than a tile (trees, large furniture, an item shifted by its pixel offset) hangs
 * over its neighbours. The clicked pixel (icon-x / icon-y) decides the tile, not the turf the object
 * stands on: otherwise a copy placed beside a large original lands on the original's own tile.
 * In darkness and outside the field of view the click catcher, a screen object, gets the mouse;
 * its screen position is mapped to the turf, as the catcher itself does for ordinary clicks.
 */
/datum/buildmode/proc/cursor_turf(atom/object, list/modifiers)
	if(!isatom(object))
		return null
	if(istype(object, /atom/movable/screen))
		if(!holder || !istype(object, /atom/movable/screen/click_catcher))
			return null
		var/screen_loc = LAZYACCESS(modifiers, SCREEN_LOC)
		return screen_loc ? params2turf(screen_loc, get_turf(holder.eye), holder) : null
	var/turf/base = get_turf(object)
	if(!base || isturf(object) || object.loc != base)
		return base
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(!isnum(icon_x) || !isnum(icon_y))
		return base
	var/atom/movable/thing = object
	var/tiles_x = FLOOR((icon_x - 1 + thing.pixel_x + thing.pixel_w) / world.icon_size, 1)
	var/tiles_y = FLOOR((icon_y - 1 + thing.pixel_y + thing.pixel_z) / world.icon_size, 1)
	if(!tiles_x && !tiles_y)
		return base
	return locate(base.x + tiles_x, base.y + tiles_y, base.z) || base

/datum/buildmode/proc/on_client_mousedown(client/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	var/kind = area_drag_kind(modifiers)
	if(!kind)
		return
	var/turf/start = cursor_turf(object, modifiers)
	if(!start)
		return
	clear_area()
	area_start = start
	area_end = start
	area_erase = (kind == "erase")
	area_button = LAZYACCESS(modifiers, MIDDLE_CLICK) ? MIDDLE_CLICK : LEFT_CLICK
	area_needs_move = area_drag_needs_move(modifiers)
	if(!area_needs_move) // a click that may stay a click shows no rectangle until it moves
		draw_area()

/datum/buildmode/proc/on_client_mousedrag(client/source, src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!area_start)
		return
	var/turf/over = cursor_turf(over_object, params2list(params))
	if(!over || over == area_end || over.z != area_start.z)
		return
	area_end = over
	draw_area()

/datum/buildmode/proc/on_client_mouseup(client/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	if(!area_start)
		return
	var/list/modifiers = params2list(params)
	// Only the button that started the drag ends it. A release that names no button still counts.
	var/released_button = LAZYACCESS(modifiers, LEFT_CLICK) ? LEFT_CLICK : (LAZYACCESS(modifiers, MIDDLE_CLICK) ? MIDDLE_CLICK : (LAZYACCESS(modifiers, RIGHT_CLICK) ? RIGHT_CLICK : null))
	if(released_button && released_button != area_button)
		return
	// The drag already tracked the far corner; the release position only matters when no drag
	// event arrived (a press and release on two tiles faster than the mouse reports moves).
	if(area_end == area_start)
		var/turf/released = cursor_turf(object, modifiers)
		if(released && released.z == area_start.z)
			area_end = released
	var/turf/corner_a = area_start
	var/turf/corner_b = area_end
	var/erase = area_erase
	var/needs_move = area_needs_move
	clear_area()
	if(needs_move && corner_a == corner_b)
		return // it stayed on one tile: the ordinary click (copy, delete one object) handles it
	INVOKE_ASYNC(src, PROC_REF(apply_area), corner_a, corner_b, erase)

/// Outlines the dragged rectangle. Called on every tile the mouse crosses, so it walks only the
/// border and moves the images it already has instead of making and removing them each time.
/datum/buildmode/proc/draw_area()
	if(!holder || !area_start || !area_end)
		return
	var/min_x = min(area_start.x, area_end.x)
	var/max_x = max(area_start.x, area_end.x)
	var/min_y = min(area_start.y, area_end.y)
	var/max_y = max(area_start.y, area_end.y)
	var/z_level = area_start.z
	var/list/border = list()
	for(var/x in min_x to max_x)
		border += locate(x, min_y, z_level)
		if(max_y != min_y)
			border += locate(x, max_y, z_level)
	for(var/y in (min_y + 1) to (max_y - 1))
		border += locate(min_x, y, z_level)
		if(max_x != min_x)
			border += locate(max_x, y, z_level)
	if(!area_images)
		area_images = list()
	var/needed = length(border)
	var/had = length(area_images)
	if(had > needed)
		var/list/extra = area_images.Copy(needed + 1)
		area_images.Cut(needed + 1)
		holder.images -= extra
	var/overlay_state = area_erase ? "redOverlay" : "greenOverlay"
	for(var/index in 1 to needed)
		var/image/outline
		if(index <= had)
			outline = area_images[index]
			outline.loc = border[index]
			outline.icon_state = overlay_state
			continue
		outline = image('icons/turf/overlays.dmi', border[index], overlay_state)
		outline.plane = ABOVE_LIGHTING_PLANE
		outline.alpha = 170
		area_images += outline
		holder.images += outline
	var/width = max_x - min_x + 1
	var/height = max_y - min_y + 1
	// Called on every tile the mouse crosses: the catalogue window is refreshed a few times a second, not each time.
	item_browser?.set_status_soon("[area_erase ? "Erase" : "Paint"] area: [width] x [height] ([width * height] tiles). Release to apply.")

/datum/buildmode/proc/clear_area()
	if(holder && length(area_images))
		holder.images -= area_images
	area_images = null
	area_start = null
	area_end = null
	area_button = null
	area_needs_move = FALSE

/// Paints the rectangle with the selection, or erases the objects in it. Turfs are never erased.
/datum/buildmode/proc/apply_area(turf/corner_a, turf/corner_b, erase)
	if(QDELETED(src) || !holder || !check_rights_for(holder, R_BUILD) || !corner_a || !corner_b)
		return
	if(!erase && !selected_item)
		item_browser?.set_status("Pick something in the catalogue before painting an area.")
		return
	var/list/region = block(corner_a, corner_b)
	var/tiles = length(region)
	if(tiles > BM_AREA_MAX_TILES)
		item_browser?.set_status("That area has [tiles] tiles; the limit is [BM_AREA_MAX_TILES]. Use a smaller rectangle.")
		return
	if(tiles > BM_AREA_CONFIRM_TILES)
		var/answer = tgui_alert(holder.mob, "[erase ? "Erase objects on" : "Paint"] [tiles] tiles?", "Build Mode", list("Yes", "No"))
		if(answer != "Yes" || QDELETED(src) || !holder)
			return
	var/user_key = key_name(holder)
	// Up to BM_AREA_MAX_TILES tiles of constructors or ChangeTurf(): spread over ticks (CHECK_TICK)
	// instead of freezing the server for everyone. This proc runs async, so it may sleep.
	if(erase)
		var/removed = 0
		var/datum/buildmode_undo/erase_step = begin_undo("erase [tiles] tiles")
		for(var/turf/target as anything in region)
			for(var/atom/movable/thing as anything in target)
				if(!buildmode_can_erase(thing))
					continue
				undoable_delete(thing, erase_step)
				removed++
			CHECK_TICK
		end_undo(erase_step)
		log_admin("Build Mode: [user_key] erased [removed] objects from [AREACOORD(corner_a)] through [AREACOORD(corner_b)].")
		if(!QDELETED(src))
			item_browser?.set_status("Erased [removed] objects on [tiles] tiles.")
		return
	var/painting = selected_item
	var/atom/movable/template = copy_template()
	var/created = 0
	var/datum/buildmode_undo/paint_step = begin_undo("paint [tiles] tiles")
	for(var/turf/target as anything in region)
		if(QDELETED(src))
			break
		if(ispath(painting, /turf))
			paint_step.note_turf(target)
			var/turf/replacement = target.ChangeTurf(painting)
			if(replacement)
				replacement.flags_1 |= ADMIN_SPAWNED_1
				created++
		else
			var/atom/movable/built = spawn_one(target, template, painting)
			if(built)
				paint_step.note_created(built)
				created++
		CHECK_TICK
	end_undo(paint_step) // drops the step when the admin left build mode meanwhile
	log_admin("Build Mode: [user_key] painted [created] of [painting][template ? " (copy)" : ""] from [AREACOORD(corner_a)] through [AREACOORD(corner_b)].")
	if(!QDELETED(src))
		item_browser?.set_status("Painted [created] tiles.")

/// What an area erase may delete: objects and mindless mobs, never players or map machinery.
/proc/buildmode_can_erase(atom/movable/thing)
	if(QDELETED(thing) || thing.invisibility >= INVISIBILITY_ABSTRACT)
		return FALSE
	if(ismob(thing))
		var/mob/target_mob = thing
		return !target_mob.ckey && !target_mob.client
	if(!isobj(thing))
		return FALSE
	if(istype(thing, /obj/effect/landmark) || istype(thing, /obj/effect/mapping_helpers))
		return FALSE
	return TRUE

/**
 * Exact copy of original on newloc, for the Copy tool.
 *
 * Unlike DuplicateObject() this never copies internal bookkeeping (signals, components, timers,
 * traits, references to other datums) and never stops on a read-only variable: a failed
 * assignment is skipped, so a copy always gets placed.
 */
/proc/buildmode_duplicate(atom/movable/original, turf/newloc)
	var/atom/movable/copy = new original.type(newloc)
	if(QDELETED(copy))
		return null
	// var name -> TRUE: a keyed lookup per var instead of a scan of this list (an area paint copies thousands of times).
	var/static/list/skipped
	if(!skipped)
		skipped = list()
		for(var/skipped_name in list(
			"type", "parent_type", "vars", "verbs", "tag", "loc", "locs", "x", "y", "z", "contents",
			"vis_locs", "vis_contents", "overlays", "underlays", "appearance", "managed_overlays",
			"managed_vis_overlays", "area", "ckey", "key", "client", "mind", "reagents",
			"datum_flags", "gc_destroyed", "weak_reference", "cooldowns", "active_timers",
			"important_recursive_contents", "pulledby", "pulling", "buckled_mobs", "orbiters",
			"light", "light_sources", "stat", "screen_loc", "plane", "flags_1", "atom_storage",
			"spatial_grid_key", "group", "power_supply", "atmos_adjacent_turfs", "comp_lookup",
			// Datum bookkeeping this codebase names without the "_" prefix.
			"signal_procs", "signal_enabled", "status_traits", "open_uis",
		))
			skipped[skipped_name] = TRUE
	for(var/var_name in original.vars)
		if(skipped[var_name])
			continue
		if(copytext(var_name, 1, 2) == "_") // internal lists: signals, components, traits...
			continue
		var/value = original.vars[var_name]
		if(isdatum(value))
			continue // the copy would share, then break, the original's datum
		if(islist(value))
			// A shared list of objects lets the copy's Destroy delete the original's limbs, organs or actions.
			if(!buildmode_list_is_plain(value))
				continue
			value = deepCopyList(value)
		try
			copy.vars[var_name] = value
		catch
			continue
	// Whatever the copied variables did, the copy stands where it was placed, never on the original.
	if(!QDELETED(copy) && copy.loc != newloc)
		copy.forceMove(newloc)
	copy.update_appearance()
	return copy

/// TRUE when a list holds only text, numbers, paths, files and such lists, so its copy owns nothing of the original.
/proc/buildmode_list_is_plain(list/checked, depth = 0)
	if(depth > 3)
		return FALSE
	for(var/key in checked)
		if(!buildmode_value_is_plain(key, depth))
			return FALSE
		if(!isnum(key) && !buildmode_value_is_plain(checked[key], depth))
			return FALSE
	return TRUE

/proc/buildmode_value_is_plain(value, depth)
	if(isnull(value) || istext(value) || isnum(value) || ispath(value) || isfile(value))
		return TRUE
	if(islist(value))
		return buildmode_list_is_plain(value, depth + 1)
	return FALSE
