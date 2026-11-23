/datum/buildmode
	/// Client using this buildmode; BYOND nulls it when the client disconnects.
	var/client/holder
	/// Kept so the login callback can still be removed after holder is gone.
	var/datum/player_details/holder_details
	var/datum/callback/login_callback
	/// Mob whose hover signals move the preview.
	var/mob/registered_mob

	var/datum/buildmode_mode/mode
	var/build_dir = SOUTH

	/// HUD panel currently shown, a BM_SWITCHSTATE_* value.
	var/switch_state = BM_SWITCHSTATE_NONE
	var/switch_width = 5
	var/list/buttons = list()
	var/atom/movable/screen/buildmode/mode/modebutton
	var/atom/movable/screen/buildmode/bdir/dirbutton
	var/list/modeswitch_buttons = list()
	var/list/dirswitch_buttons = list()

	var/datum/buildmode_item_browser/item_browser

	/// Atom type that placement modes build.
	var/selected_item
	/// Translucent copy of selected_item that follows the cursor.
	var/image/preview_image
	/// Screen-wide catcher that tracks the cursor pixel while Shift is held.
	var/atom/movable/screen/buildmode/pixel_catcher/pixel_catcher

	/// How many copies one placement creates. Turfs always place one.
	var/spawn_amount = 1
	/// Manual pixel offset applied to placed movables, set in the catalogue.
	var/spawn_pixel_x = 0
	var/spawn_pixel_y = 0

/datum/buildmode/New(client/user_client)
	holder = user_client
	holder_details = holder.player_details
	mode = new /datum/buildmode_mode/basic(src)
	create_buttons()
	holder.screen += buttons
	holder.click_intercept = src
	login_callback = CALLBACK(src, PROC_REF(post_login))
	holder_details.post_login_callbacks += login_callback
	register_mob(holder.mob)
	setup_tools()
	item_browser = new(src)
	mode.enter_mode(src)
	item_browser.open()

/datum/buildmode/Destroy()
	close_switchstates()
	clear_pixel_catcher()
	clear_preview()
	cleanup_tools()
	mode?.exit_mode(src)
	QDEL_NULL(mode)
	QDEL_NULL(item_browser)
	if(holder)
		holder.screen -= buttons
		if(holder.click_intercept == src)
			holder.click_intercept = null
	holder_details?.post_login_callbacks -= login_callback
	holder_details = null
	login_callback = null
	register_mob(null)
	QDEL_LIST(modeswitch_buttons)
	QDEL_LIST(dirswitch_buttons)
	QDEL_LIST(buttons)
	modebutton = null
	dirbutton = null
	holder = null
	return ..()

/datum/buildmode/proc/quit()
	qdel(src)

/// Re-adds the HUD after the client takes a new mob; quits if the client reconnected.
/datum/buildmode/proc/post_login()
	if(!holder)
		// Deferred: this runs inside the loop over post_login_callbacks.
		QDEL_IN(src, 0)
		return
	clear_pixel_catcher()
	holder.screen += buttons
	switch(switch_state)
		if(BM_SWITCHSTATE_MODE)
			holder.screen += modeswitch_buttons
		if(BM_SWITCHSTATE_DIR)
			holder.screen += dirswitch_buttons
	register_mob(holder.mob)

/datum/buildmode/proc/register_mob(mob/new_mob)
	if(registered_mob == new_mob)
		return
	if(registered_mob)
		UnregisterSignal(registered_mob, list(COMSIG_USER_MOUSE_ENTERED, COMSIG_PARENT_QDELETING, COMSIG_MOB_LOGOUT))
	registered_mob = new_mob
	if(registered_mob)
		RegisterSignal(registered_mob, COMSIG_USER_MOUSE_ENTERED, PROC_REF(on_mouse_entered))
		RegisterSignal(registered_mob, COMSIG_PARENT_QDELETING, PROC_REF(on_mob_deleted))
		RegisterSignal(registered_mob, COMSIG_MOB_LOGOUT, PROC_REF(on_mob_logout))

/datum/buildmode/proc/on_mob_deleted(datum/source)
	SIGNAL_HANDLER
	register_mob(null)

/datum/buildmode/proc/on_mob_logout(datum/source)
	SIGNAL_HANDLER
	// A disconnect or only a change of mob: tell them apart once the logout is over.
	addtimer(CALLBACK(src, PROC_REF(quit_if_disconnected)), 10 SECONDS, TIMER_UNIQUE)

/// A build mode without its client is never used again (a reconnect quits it), so free its undo trash now.
/datum/buildmode/proc/quit_if_disconnected()
	if(!holder)
		quit()

/datum/buildmode/proc/create_buttons()
	modebutton = new(null, null, src)
	buttons += modebutton
	buttons += new /atom/movable/screen/buildmode/help(null, null, src)
	dirbutton = new(null, null, src)
	buttons += dirbutton
	buttons += new /atom/movable/screen/buildmode/quit(null, null, src)
	buttons += new /atom/movable/screen/buildmode/items(null, null, src)
	modebutton.update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	dirbutton.update_appearance(UPDATE_ICON_STATE)

	build_options_grid(subtypesof(/datum/buildmode_mode), modeswitch_buttons, /atom/movable/screen/buildmode/modeswitch)
	build_options_grid(list(SOUTH, EAST, WEST, NORTH, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST), dirswitch_buttons, /atom/movable/screen/buildmode/dirswitch)

/datum/buildmode/proc/build_options_grid(list/elements, list/buttonslist, buttontype)
	var/pos_idx = 0
	for(var/thing in elements)
		var/x = pos_idx % switch_width
		var/y = FLOOR(pos_idx / switch_width, 1)
		var/atom/movable/screen/buildmode/button = new buttontype(null, null, src, thing)
		// Extra .5 for a nice offset look
		button.screen_loc = "NORTH-[(1 + 0.5 + y * 1.5)],WEST+[0.5 + x * 1.5]"
		buttonslist += button
		pos_idx++

/datum/buildmode/proc/close_switchstates()
	switch(switch_state)
		if(BM_SWITCHSTATE_MODE)
			close_modeswitch()
		if(BM_SWITCHSTATE_DIR)
			close_dirswitch()

/datum/buildmode/proc/toggle_modeswitch()
	if(switch_state == BM_SWITCHSTATE_MODE)
		close_modeswitch()
		return
	close_switchstates()
	switch_state = BM_SWITCHSTATE_MODE
	holder?.screen += modeswitch_buttons

/datum/buildmode/proc/close_modeswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder?.screen -= modeswitch_buttons

/datum/buildmode/proc/toggle_dirswitch()
	if(switch_state == BM_SWITCHSTATE_DIR)
		close_dirswitch()
		return
	close_switchstates()
	switch_state = BM_SWITCHSTATE_DIR
	holder?.screen += dirswitch_buttons

/datum/buildmode/proc/close_dirswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder?.screen -= dirswitch_buttons

/datum/buildmode/proc/change_mode(newmode)
	close_switchstates()
	if(mode?.type == newmode)
		return
	clear_pixel_catcher()
	mode.exit_mode(src)
	QDEL_NULL(mode)
	mode = new newmode(src)
	mode.enter_mode(src)
	update_preview()
	modebutton.update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	to_chat(holder, span_notice("Build mode: [mode.name]. Use the ? button for controls."))
	item_browser?.send_selection()

/datum/buildmode/proc/change_dir(newdir)
	build_dir = newdir
	close_dirswitch()
	dirbutton.update_appearance(UPDATE_ICON_STATE)
	if(preview_image)
		preview_image.dir = build_dir
	item_browser?.send_selection()

/datum/buildmode/proc/InterceptClickOn(mob/user, list/modifiers, atom/object)
	// HUD elements keep working; everything on the map belongs to the current mode.
	if(istype(object, /atom/movable/screen))
		return FALSE
	// Rights can be taken away while build mode is open.
	if(!check_rights_for(holder, R_BUILD))
		quit()
		return TRUE
	mode.handle_click(user.client, modifiers, object)
	return TRUE

/datum/buildmode/proc/select_item(item_path)
	if(!ispath(item_path, /atom) || ispath(item_path, /area))
		return FALSE
	selected_item = item_path
	copy_ref = null
	update_preview()
	item_browser?.remember(item_path)
	item_browser?.send_selection()
	var/atom/item_atom = item_path
	to_chat(holder, span_notice("Selected [initial(item_atom.name)] ([item_path])."))
	return TRUE

/datum/buildmode/proc/clear_selection()
	if(!selected_item)
		return
	selected_item = null
	copy_ref = null
	clear_preview()
	clear_pixel_catcher()
	item_browser?.send_selection()
	to_chat(holder, span_notice("Selection cleared."))

/**
 * Builds the selected type on target and returns the last atom built.
 *
 * Movables are built spawn_amount times. Explicit offsets (Shift pixel placement) win over the
 * manual offset set in the catalogue. With in_hands, items go to the user's hands when they fit.
 */
/datum/buildmode/proc/place_selected(turf/target, mob/user, offset_x, offset_y, in_hands = FALSE)
	if(!selected_item || !target)
		return null
	if(ispath(selected_item, /turf))
		var/turf/turf_type = selected_item
		var/datum/buildmode_undo/turf_step = begin_undo("place [initial(turf_type.name)]")
		turf_step.note_turf(target)
		var/turf/replacement = target.ChangeTurf(selected_item)
		end_undo(turf_step)
		if(replacement)
			replacement.flags_1 |= ADMIN_SPAWNED_1
			item_browser?.set_status("Placed [replacement.name].")
		log_admin("Build Mode: [key_name(user)] changed [AREACOORD(target)] to [selected_item].")
		return replacement
	if(isnull(offset_x))
		offset_x = spawn_pixel_x
	if(isnull(offset_y))
		offset_y = spawn_pixel_y
	var/atom/movable/placing_type = selected_item
	var/atom/movable/template = copy_template()
	var/amount = clamp(round(spawn_amount), 1, ADMIN_SPAWN_CAP)
	var/created = 0
	var/held = 0
	var/atom/movable/placed
	var/datum/buildmode_undo/step = begin_undo("place [amount] x [initial(placing_type.name)]")
	for(var/i in 1 to amount)
		// A constructor may sleep: stop if the admin left build mode or the turf is gone.
		if(QDELETED(src) || QDELETED(target))
			break
		var/atom/movable/built = spawn_one(target, template, placing_type)
		if(!built)
			continue
		placed = built
		created++
		step.note_created(built)
		if(offset_x || offset_y)
			built.pixel_x = built.base_pixel_x + offset_x
			built.pixel_y = built.base_pixel_y + offset_y
		if(in_hands && isitem(built) && !QDELETED(user) && user.put_in_hands(built, merge_stacks = FALSE))
			held++
	end_undo(step) // drops the step when the admin left build mode meanwhile
	log_admin("Build Mode: [key_name(user)] placed [created] of [placing_type][template ? " (copy of [REF(template)])" : ""] at [AREACOORD(target)][in_hands ? ", [held] in hands" : ""].")
	if(!QDELETED(src))
		if(in_hands)
			item_browser?.set_status("Created [created] x [initial(placing_type.name)]: [held] in hands, [created - held] on the ground.")
		else
			item_browser?.set_status("Created [created] x [initial(placing_type.name)].")
	return placed

/// Deletes an object, or scrapes away the top layer of a turf. Mobs are never deleted this way.
/datum/buildmode/proc/delete_object(mob/user, atom/object)
	if(QDELETED(object) || istype(object, /atom/movable/screen))
		return FALSE
	if(!isturf(object) && (!isobj(object) || !isturf(object.loc)))
		return FALSE
	log_admin("Build Mode: [key_name(user)] deleted [object] ([object.type]) at [AREACOORD(object)].")
	item_browser?.set_status("Deleted [object.name].")
	var/datum/buildmode_undo/step = begin_undo("delete [object.name]")
	if(isturf(object))
		var/turf/target = object
		step.note_turf(target)
		target.ScrapeAway()
	else
		undoable_delete(object, step)
	end_undo(step)
	return TRUE

/// Sets the copy count or the manual pixel offset used by placement.
/datum/buildmode/proc/set_placement_option(option, value)
	switch(option)
		if("amount")
			spawn_amount = clamp(round(value), 1, ADMIN_SPAWN_CAP)
		if("pixel_x")
			spawn_pixel_x = clamp(round(value), -BM_MAX_OFFSET, BM_MAX_OFFSET)
		if("pixel_y")
			spawn_pixel_y = clamp(round(value), -BM_MAX_OFFSET, BM_MAX_OFFSET)
		else
			return
	apply_preview_offset()

/// Shows the manual offset on the preview. Turfs ignore it.
/datum/buildmode/proc/apply_preview_offset()
	if(!preview_image)
		return
	var/is_turf = ispath(selected_item, /turf)
	preview_image.pixel_x = is_turf ? 0 : spawn_pixel_x
	preview_image.pixel_y = is_turf ? 0 : spawn_pixel_y

/// Returns list(turf, pixel_x, pixel_y) under the cursor from click or mouse params.
/datum/buildmode/proc/resolve_cursor(list/modifiers)
	if(!holder || !LAZYACCESS(modifiers, SCREEN_LOC))
		return null
	var/turf/origin = get_turf(holder.eye)
	if(!origin)
		return null
	var/list/scratch = modifiers.Copy()
	var/turf/cursor_turf = parse_caught_click_modifiers(scratch, origin, holder)
	if(!cursor_turf)
		return null
	var/offset_x = clamp(text2num(scratch[ICON_X]) - 16, -16, 16)
	var/offset_y = clamp(text2num(scratch[ICON_Y]) - 16, -16, 16)
	return list(cursor_turf, offset_x, offset_y)

/datum/buildmode/proc/update_preview()
	var/turf/last_turf = preview_image?.loc
	clear_preview()
	if(!selected_item || !holder || !mode?.uses_selection)
		return
	var/atom/item_atom = selected_item
	preview_image = image(initial(item_atom.icon), last_turf, initial(item_atom.icon_state), dir = build_dir)
	preview_image.plane = ABOVE_LIGHTING_PLANE
	preview_image.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	preview_image.color = LIGHT_COLOR_LIGHT_CYAN
	preview_image.alpha = 150
	preview_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	apply_preview_offset()
	holder.images += preview_image

/datum/buildmode/proc/clear_preview()
	if(!preview_image)
		return
	if(holder)
		holder.images -= preview_image
	preview_image.loc = null
	preview_image = null

/datum/buildmode/proc/on_mouse_entered(datum/source, atom/hovered)
	SIGNAL_HANDLER
	// The catcher drives the preview while Shift is held.
	if(!preview_image || pixel_catcher)
		return
	var/turf/hovered_turf = get_turf(hovered)
	if(hovered_turf)
		preview_image.loc = hovered_turf

/// Called from the Shift key hooks; shows the pixel catcher while Shift is held.
/datum/buildmode/proc/set_pixel_positioning(enabled)
	if(!enabled)
		clear_pixel_catcher()
		return
	if(pixel_catcher || !holder || !preview_image || !mode?.pixel_placement)
		return
	pixel_catcher = new(null, null, src)
	holder.screen += pixel_catcher

/datum/buildmode/proc/clear_pixel_catcher()
	if(!pixel_catcher)
		return
	if(holder)
		holder.screen -= pixel_catcher
	QDEL_NULL(pixel_catcher)
	apply_preview_offset()

/datum/buildmode/proc/track_cursor(list/modifiers)
	if(!preview_image)
		return
	var/list/cursor = resolve_cursor(modifiers)
	if(!cursor)
		return
	preview_image.loc = cursor[1]
	preview_image.pixel_x = cursor[2]
	preview_image.pixel_y = cursor[3]

/datum/buildmode/proc/catcher_click(list/modifiers)
	// No Shift on the click means the key release was missed, so drop the catcher.
	if(!LAZYACCESS(modifiers, SHIFT_CLICKED))
		clear_pixel_catcher()
	var/list/cursor = resolve_cursor(modifiers)
	if(cursor)
		mode.handle_click(holder, modifiers, cursor[1])

/proc/togglebuildmode(mob/M as mob in GLOB.player_list)
	set name = "Toggle Build Mode"
	set category = "Event"

	if(M.client)
		if(istype(M.client.click_intercept, /datum/buildmode))
			var/datum/buildmode/B = M.client.click_intercept
			B.quit()
			log_admin("[key_name(usr)] has left build mode.")
		else
			// Building the catalogue in one go would freeze the server: wait for the background build.
			if(!buildmode_catalog_ready())
				to_chat(M, span_notice("Build mode: the spawn catalogue is still loading. Build mode opens when it is ready."))
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(enter_buildmode_when_ready), M.client)
				return
			new /datum/buildmode(M.client)
			log_admin("[key_name(usr)] has entered build mode.")

/// Opens build mode for user once the background catalogue build is done (or after a minute, if it failed).
/proc/enter_buildmode_when_ready(client/user)
	var/give_up_at = world.time + 1 MINUTES
	UNTIL(!user || buildmode_catalog_ready() || world.time > give_up_at)
	if(!user || istype(user.click_intercept, /datum/buildmode))
		return
	new /datum/buildmode(user)
	log_admin("[key_name(user)] has entered build mode.")

/// Used by the blueprint system to read pixel offsets from mouse params.
/proc/get_pixel_offsets_from_screenloc(params)
	var/list/modifiers = params2list(params)
	var/screen_loc = LAZYACCESS(modifiers, SCREEN_LOC)

	if(!screen_loc || !istext(screen_loc))
		return null

	var/list/coords = splittext(screen_loc, ",")
	if(length(coords) != 2)
		return null

	var/list/x_parts = splittext(coords[1], ":") // screen-loc is y,x order!
	var/list/y_parts = splittext(coords[2], ":")

	if(length(x_parts) != 2 || length(y_parts) != 2)
		return null

	var/x_offset = text2num(x_parts[2]) - 16
	var/y_offset = text2num(y_parts[2]) - 16

	return list("x" = x_offset, "y" = y_offset)
