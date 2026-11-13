/// TGUI character setup menu — doll preview engine.
/// Three embedded map views (main/front/side) rendering a prefs-dressed dummy,
/// measured via flat icon art bounds so the frontend can zoom to fit.

/// A full render dresses the dummy again and builds two flat icons, so a player gets at most one per this period.
#define CHARACTER_SETUP_RENDER_COOLDOWN (0.4 SECONDS)

/datum/preferences/proc/character_setup_selectable_ages()
	. = list()
	if(!pref_species)
		return
	for(var/possible_age in pref_species.possible_ages)
		. += possible_age

/datum/preferences/proc/character_setup_validate_smallclothes()
	validate_customizer_entries()

/datum/preferences/proc/character_setup_preview_job()
	var/datum/job/result
	var/highest = 0
	for(var/job_type in job_preferences)
		if(job_preferences[job_type] > highest)
			highest = job_preferences[job_type]
			result = SSjob.GetJob(job_type)
	return result

/datum/preferences/proc/character_setup_ensure_view(mob/user, datum/tgui/ui)
	if(!ui || QDELETED(ui))
		return
	if(!character_setup_view)
		var/client/view_client = user?.client
		var/list/view_size = view_client?.view ? getviewsize(view_client.view) : null
		character_setup_view_tile_top = (islist(view_size) && length(view_size) >= 2) ? view_size[2] : 15
		character_setup_view_tile_center = max(1, round((character_setup_view_tile_top + 1) / 2))
		character_setup_view_scale = max(1, character_setup_view_tile_top - 2)
		character_setup_view = new
		character_setup_view.generate_view("character_setup_main_[REF(src)]_map")
		character_setup_view_front = new
		character_setup_view_front.generate_view("character_setup_front_[REF(src)]_map")
		character_setup_view_side = new
		character_setup_view_side.generate_view("character_setup_side_[REF(src)]_map")
		character_setup_bg = new
		character_setup_bg.assigned_map = character_setup_view.assigned_map
		character_setup_bg_front = new
		character_setup_bg_front.assigned_map = character_setup_view_front.assigned_map
		character_setup_bg_side = new
		character_setup_bg_side.assigned_map = character_setup_view_side.assigned_map
		if(!character_setup_body)
			character_setup_body = new
		character_setup_log("VIEW", "ensure_view created map=[character_setup_view.assigned_map] user=[user?.ckey] window=[ui?.window ? "yes" : "NO"] window_visible=[ui?.window?.visible] tile_top=[character_setup_view_tile_top]")
		// New views start empty, so draw even if the preferences match the last render.
		character_setup_render_forced = TRUE
		character_setup_update_view()
		// The opening payload was built before the views existed, so it carries no map ids.
		character_setup_queue_push()
	if(character_setup_view_shown)
		return
	var/client/target_client = user?.client
	if(!target_client || QDELETED(ui) || !ui.window)
		return
	if(!ui.window.visible)
		character_setup_log("VIEW", "await window visible, retry queued")
		addtimer(CALLBACK(src, PROC_REF(character_setup_ensure_view), user, ui), 5, TIMER_UNIQUE)
		return
	character_setup_view_shown = TRUE
	character_setup_view.display_to_client(target_client)
	character_setup_view_front.display_to_client(target_client)
	character_setup_view_side.display_to_client(target_client)
	target_client.register_map_obj(character_setup_bg)
	target_client.register_map_obj(character_setup_bg_front)
	target_client.register_map_obj(character_setup_bg_side)
	character_setup_log("VIEW", "displayed maps=[character_setup_view.assigned_map],[character_setup_view_front.assigned_map],[character_setup_view_side.assigned_map] window=[ui.window.id] tile_center=[character_setup_view_tile_center] scale=[character_setup_view_scale]")
	character_setup_diag_controls(user, "post_display")

/datum/preferences/proc/character_setup_diag_controls(mob/user, context)
	set waitfor = FALSE
	if(!GLOB.character_setup_debug || !user?.client)
		return
	sleep(1 SECONDS)
	if(!user?.client)
		return
	var/client/C = user.client
	var/window_id = character_setup_active_window_id(user)
	character_setup_log("CTRL", "[context] === geometry dump === window_id=[window_id] view=[C.view] tile_center=[character_setup_view_tile_center] feet_margin=[character_setup_view_feet_margin] last_flat=[character_setup_view_last_flat]")
	if(window_id)
		character_setup_log("CTRL", "[context] WINDOW [window_id] winget=[winget(user, window_id, "size;pos;is-visible;is-maximized;inner-size")]")
		character_setup_log("CTRL", "[context] WINDOW.map winget=[winget(user, "[window_id].map", "size;pos;is-visible")]")
	for(var/atom/movable/screen/map_view/view as anything in list(character_setup_view, character_setup_view_front, character_setup_view_side))
		if(!view)
			continue
		var/list/bound = C.screen_maps[view.assigned_map]
		var/in_screen = (view in C.screen) ? "yes" : "NO"
		var/ctrl = winget(user, view.assigned_map, "parent;type;pos;size;view-size;icon-size;zoom;letterbox;zoom-mode;is-visible")
		character_setup_log("CTRL", "[context] MAP id=[view.assigned_map] screen_loc=[view.screen_loc] transform_scale=[character_setup_current_view_scale()] registered=[length(bound)] in_screen=[in_screen] winget=[ctrl ? ctrl : "MISSING"]")

/datum/preferences/proc/character_setup_apply_map_background(mob/user)
	if(!user?.client)
		return
	var/bg_hex = "#0d0d0d"
	switch(character_setup_preview_background)
		if("white")
			bg_hex = "#d8d8d8"
		if("dark")
			bg_hex = "#0a0a0a"
	for(var/atom/movable/screen/map_view/view as anything in list(character_setup_view, character_setup_view_front, character_setup_view_side))
		if(view)
			winset(user, view.assigned_map, "background-color=[bg_hex]")

/datum/preferences/proc/character_setup_apply_reported_zoom(mob/user, zoom_main, zoom_mini)
	if(!user?.client)
		return
	if(zoom_main > 0 && character_setup_view)
		winset(user, character_setup_view.assigned_map, "zoom=[zoom_main]")
	if(zoom_mini > 0)
		if(character_setup_view_front)
			winset(user, character_setup_view_front.assigned_map, "zoom=[zoom_mini]")
		if(character_setup_view_side)
			winset(user, character_setup_view_side.assigned_map, "zoom=[zoom_mini]")
	character_setup_apply_map_background(user)
	if(GLOB.character_setup_debug)
		character_setup_log("ZOOM", "applied main=[zoom_main] mini=[zoom_mini]")

/datum/preferences/proc/character_setup_active_window_id(mob/user)
	for(var/datum/tgui/open_ui in open_uis)
		if(open_ui.user == user && open_ui.window)
			return open_ui.window.id
	return null

/datum/preferences/proc/character_setup_teardown_view(mob/user)
	character_setup_log("VIEW", "teardown map=[character_setup_view?.assigned_map] user=[user?.ckey]")
	character_setup_hover_acc = null
	character_setup_hover_color = null
	character_setup_hover_customizer = null
	character_setup_view_shown = FALSE
	character_setup_rendered_sig = null
	character_setup_note_rendered_hover()
	character_setup_view?.hide_from(user)
	character_setup_view_front?.hide_from(user)
	character_setup_view_side?.hide_from(user)
	QDEL_NULL(character_setup_body)
	QDEL_NULL(character_setup_view)
	QDEL_NULL(character_setup_view_front)
	QDEL_NULL(character_setup_view_side)
	QDEL_NULL(character_setup_bg)
	QDEL_NULL(character_setup_bg_front)
	QDEL_NULL(character_setup_bg_side)

/// base_changed FALSE means only hover or facing changed, which the loop tracks on its own.
/datum/preferences/proc/character_setup_update_view(base_changed = TRUE)
	set waitfor = FALSE
	if(!character_setup_view || !character_setup_body || !pref_species)
		character_setup_log("VIEW", "update_view SKIP view=[!!character_setup_view] body=[!!character_setup_body] species=[!!pref_species]")
		return
	if(character_setup_view_busy)
		// The yielded render may have read the old preferences, so the next pass must draw.
		if(base_changed)
			character_setup_render_forced = TRUE
		character_setup_view_pending = TRUE
		character_setup_log("VIEW", "update_view BUSY -> pending")
		return
	// Topics run after SendMaps at the end of the tick, where a render's first stage would overrun it;
	// the timer runs it inside the MC's budget. A burst of clicks collapses into one render, at most
	// one per cooldown.
	addtimer(CALLBACK(src, PROC_REF(character_setup_run_view_update)), max(1, COOLDOWN_TIMELEFT(src, character_setup_render_cooldown)), TIMER_UNIQUE)

/datum/preferences/proc/character_setup_run_view_update()
	set waitfor = FALSE
	if(!character_setup_view || !character_setup_body || !pref_species)
		return
	if(character_setup_view_busy)
		character_setup_view_pending = TRUE
		return
	var/wait = COOLDOWN_TIMELEFT(src, character_setup_render_cooldown)
	if(wait)
		addtimer(CALLBACK(src, PROC_REF(character_setup_run_view_update)), wait, TIMER_UNIQUE)
		return
	character_setup_view_busy = TRUE
	do
		character_setup_view_pending = FALSE
		var/_t = world.timeofday
		try
			var/needs_full_render = character_setup_render_forced || character_setup_render_signature() != character_setup_rendered_sig
			if(!needs_full_render && character_setup_hover_changed())
				needs_full_render = !character_setup_render_hover()
			if(needs_full_render)
				COOLDOWN_START(src, character_setup_render_cooldown, CHARACTER_SETUP_RENDER_COOLDOWN)
				character_setup_render_forced = FALSE
				character_setup_redraw_dir = FALSE
				// Noted before dressing: the render reads hover first, and a hover changed during its yield must still show.
				character_setup_note_rendered_hover()
				character_setup_render_body()
				// Taken after the render, so preference writes made while dressing the dummy count as drawn.
				character_setup_rendered_sig = character_setup_render_signature()
				character_setup_log_op("render_body", _t, "dir=[character_setup_preview_dir] hover=[character_setup_hover_acc || "none"] species=[pref_species?.id]")
			else
				character_setup_render_main_only = FALSE
				if(character_setup_redraw_dir)
					character_setup_redraw_dir = FALSE
					character_setup_turn_view()
		catch(var/exception/render_error)
			// Cleared before rethrowing, or one failed render freezes this preview for the round.
			character_setup_view_busy = FALSE
			if(character_setup_body)
				character_setup_body.defer_body_parts_update = FALSE
				character_setup_body.status_flags &= ~BUILDING_ORGANS
			throw render_error
	while(character_setup_view_pending && character_setup_view && character_setup_body && !COOLDOWN_TIMELEFT(src, character_setup_render_cooldown))
	character_setup_view_busy = FALSE
	// Changes made while a render yielded wait out the cooldown like any other burst.
	if(character_setup_view_pending && character_setup_view && character_setup_body)
		character_setup_view_pending = FALSE
		addtimer(CALLBACK(src, PROC_REF(character_setup_run_view_update)), max(1, COOLDOWN_TIMELEFT(src, character_setup_render_cooldown)), TIMER_UNIQUE)
	var/bbox_sig = "[character_setup_view_zoom_w]x[character_setup_view_zoom_h]"
	if(bbox_sig != character_setup_view_bbox_sent)
		character_setup_view_bbox_sent = bbox_sig
		character_setup_queue_push()

/// What the preview dummy is dressed from, minus facing and hover; an unchanged signature means a render would change nothing.
/datum/preferences/proc/character_setup_render_signature()
	return "[get_character_preview_fingerprint()]|[character_setup_preview_clothes]|[character_setup_preview_underwear]"

/datum/preferences/proc/character_setup_hover_changed()
	return character_setup_hover_acc != character_setup_rendered_hover_acc || character_setup_hover_color != character_setup_rendered_hover_color || character_setup_hover_customizer != character_setup_rendered_hover_customizer

/datum/preferences/proc/character_setup_note_rendered_hover()
	character_setup_rendered_hover_acc = character_setup_hover_acc
	character_setup_rendered_hover_color = character_setup_hover_color
	character_setup_rendered_hover_customizer = character_setup_hover_customizer

/// Swaps only the hovered accessory on the dressed dummy; FALSE when a full render is needed instead.
/datum/preferences/proc/character_setup_render_hover()
	var/mob/living/carbon/human/dummy/body = character_setup_body
	var/old_customizer = character_setup_rendered_hover_customizer
	var/new_customizer_path = character_setup_hover_customizer ? text2path(character_setup_hover_customizer) : null
	var/new_acc_path = character_setup_hover_acc ? text2path(character_setup_hover_acc) : null
	// Put the previously hovered customizer back to its saved choice first.
	if(old_customizer && old_customizer != character_setup_hover_customizer)
		var/old_customizer_path = text2path(old_customizer)
		if(old_customizer_path && !character_setup_redress_customizer(body, old_customizer_path))
			return FALSE
	if(new_acc_path && new_customizer_path && !character_setup_redress_customizer(body, new_customizer_path, new_acc_path, character_setup_hover_color))
		return FALSE
	character_setup_suppress_eye_glow(body)
	body.update_body_parts(TRUE)
	character_setup_note_rendered_hover()
	character_setup_render_main_only = FALSE
	character_setup_redraw_dir = FALSE
	character_setup_turn_view()
	return TRUE

/// Re-applies one customizer to the dummy, optionally with a hovered accessory; FALSE if this one needs a full render.
/datum/preferences/proc/character_setup_redress_customizer(mob/living/carbon/human/body, customizer_path, accessory_path, accessory_colors)
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_path)
	if(!entry)
		return FALSE
	var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
	if(!customizer?.is_allowed(src))
		return FALSE
	var/saved_accessory = entry.accessory_type
	var/saved_colors = entry.accessory_colors
	var/saved_disabled = entry.disabled
	if(accessory_path)
		entry.accessory_type = accessory_path
		if(accessory_colors)
			entry.accessory_colors = accessory_colors
		entry.disabled = FALSE
	try
		. = character_setup_redress_choice(body, CUSTOMIZER_CHOICE(entry.customizer_choice_type), entry)
	catch(var/exception/redress_error)
		// The entry is the saved character; never leave a hovered value in it.
		entry.accessory_type = saved_accessory
		entry.accessory_colors = saved_colors
		entry.disabled = saved_disabled
		throw redress_error
	entry.accessory_type = saved_accessory
	entry.accessory_colors = saved_colors
	entry.disabled = saved_disabled

/// Mirrors how a full render applies this customizer; organs that would have to be created return FALSE.
/datum/preferences/proc/character_setup_redress_choice(mob/living/carbon/human/body, datum/customizer_choice/choice, datum/customizer_entry/entry)
	if(istype(choice, /datum/customizer_choice/bodypart_feature))
		var/datum/customizer_choice/bodypart_feature/feature_choice = choice
		if(!entry.disabled)
			// Adding a feature replaces whatever sits in its slot.
			feature_choice.apply_customizer_to_character(body, src, entry)
			return TRUE
		var/datum/bodypart_feature/feature_type = feature_choice.feature_type
		var/datum/bodypart_feature/existing = body.get_bodypart_feature_of_slot(initial(feature_type.feature_slot))
		if(existing)
			var/obj/item/bodypart/part = body.get_bodypart(existing.body_zone)
			part?.remove_bodypart_feature(existing)
		return TRUE
	if(istype(choice, /datum/customizer_choice/organ))
		var/datum/customizer_choice/organ/organ_choice = choice
		var/list/organs = body.getorganslotlist(organ_choice.get_organ_slot())
		if(entry.disabled || !length(organs))
			return FALSE
		var/datum/organ_dna/organ_dna = organ_choice.create_organ_dna(entry, src)
		if(!organ_dna)
			return FALSE
		for(var/obj/item/organ/organ as anything in organs)
			organ_dna.imprint_organ(organ, species = body.dna.species)
			customize_organ(organ)
		return TRUE
	return FALSE

/// Emissive eye glow renders as a flat white blob in the lit portrait; returns TRUE if any glow was switched off.
/datum/preferences/proc/character_setup_suppress_eye_glow(mob/living/carbon/human/body)
	for(var/obj/item/organ/eyes/preview_eyes in body.internal_organs)
		if(preview_eyes.glows && preview_eyes.user_glowing_pref)
			preview_eyes.user_glowing_pref = FALSE
			. = TRUE

/// Re-measures and turns the main view without dressing the dummy again.
/datum/preferences/proc/character_setup_turn_view()
	var/mob/living/carbon/human/dummy/body = character_setup_body
	character_setup_measure_body(character_setup_preview_dir)
	// Measuring can yield; skip if the menu closed or reopened meanwhile.
	if(QDELETED(body) || body != character_setup_body)
		return
	character_setup_apply_to_view(character_setup_view, body, character_setup_preview_dir)

/// A full render takes about two ticks of work. Yielding between its stages lets each tick
/// finish on time, so a busy editor delays its own doll instead of dilating the server.
/// FALSE when the menu closed or reopened meanwhile; update_view redraws any change made during the wait.
/datum/preferences/proc/character_setup_render_yield(mob/living/carbon/human/dummy/body)
	CHECK_TICK
	return !QDELETED(body) && body == character_setup_body

/datum/preferences/proc/character_setup_render_body()
	var/mob/living/carbon/human/dummy/body = character_setup_body
	var/datum/job/preview_job = character_setup_preview_clothes ? character_setup_preview_job() : null
	var/datum/outfit/preview_outfit
	if(preview_job)
		preview_outfit = (read_preference(/datum/preference/choiced/gender) == FEMALE && preview_job.outfit_female) ? preview_job.outfit_female : preview_job.outfit
	character_setup_validate_smallclothes()
	var/datum/customizer_entry/hover_entry
	var/hover_old_acc
	var/hover_old_colors
	var/hover_old_disabled
	var/hover_acc_path = character_setup_hover_acc ? text2path(character_setup_hover_acc) : null
	var/hover_customizer_path = character_setup_hover_customizer ? text2path(character_setup_hover_customizer) : null
	if(hover_acc_path && hover_customizer_path)
		hover_entry = get_customizer_entry_for_customizer_type(hover_customizer_path)
		if(hover_entry)
			hover_old_acc = hover_entry.accessory_type
			hover_old_colors = hover_entry.accessory_colors
			hover_old_disabled = hover_entry.disabled
			hover_entry.accessory_type = hover_acc_path
			if(character_setup_hover_color)
				hover_entry.accessory_colors = character_setup_hover_color
			hover_entry.disabled = FALSE
	// Dressing puts on dozens of organs and features, and each would redraw the whole body;
	// both flags hold those redraws for one regenerate_icons() at the end.
	var/was_building_organs = body.status_flags & BUILDING_ORGANS
	body.status_flags |= BUILDING_ORGANS
	body.defer_body_parts_update = TRUE
	body.wipe_state()
	// character_setup = TRUE: culls stale taur bodies (ensure_not_taur) and skips
	// roundstart-only side effects (quirks, bans, kinks) on the preview dummy.
	apply_prefs_to(body, TRUE, TRUE)
	if(hover_entry)
		hover_entry.accessory_type = hover_old_acc
		hover_entry.accessory_colors = hover_old_colors
		hover_entry.disabled = hover_old_disabled
	// The RMH user_glowing_pref switch suppresses the emissive overlay at its source.
	character_setup_suppress_eye_glow(body)
	// Not before this point: a hovered value must never sit in the saved entry across a yield.
	if(!character_setup_render_yield(body))
		return
	if(!character_setup_preview_underwear)
		// Smallclothes are worn items living in inventory slots here, not strings.
		QDEL_NULL(body.underwear)
		QDEL_NULL(body.undershirt)
		QDEL_NULL(body.bra)
		QDEL_NULL(body.garter)
		QDEL_NULL(body.legwear_socks)
		QDEL_NULL(body.armsleeves)
	if(preview_job)
		body.dna.species.pre_equip_species_outfit(preview_job, body, TRUE)
	if(preview_outfit)
		body.equipOutfit(preview_outfit, TRUE)
	if(!character_setup_render_yield(body))
		return
	if(!was_building_organs)
		body.status_flags &= ~BUILDING_ORGANS
	body.defer_body_parts_update = FALSE
	body.update_limb_efficiencies()
	// wipe_state() cut every overlay, and this rebuilds limbs, body and worn items in one pass.
	body.regenerate_icons()
	// After regenerate_icons(), which would redraw these slots without the preview filters.
	body.update_inv_hands()
	body.update_inv_belt(hide_experimental = TRUE)
	body.update_inv_back(hide_experimental = TRUE)
	body.update_inv_head(hide_nonstandard = TRUE)
	if(!character_setup_render_yield(body))
		return
	var/main_only = character_setup_render_main_only
	character_setup_render_main_only = FALSE
	character_setup_measure_body(character_setup_preview_dir)
	if(!main_only)
		if(!character_setup_render_yield(body))
			return
		var/list/perp_art = character_setup_measure_art(turn(character_setup_preview_dir, 90))
		var/zoom_dim_w = max(character_setup_view_bbox_w, perp_art ? perp_art[1] : 0)
		var/zoom_dim_h = max(character_setup_view_bbox_h, perp_art ? perp_art[2] : 0)
		character_setup_view_zoom_w = CEILING(zoom_dim_w, 4)
		character_setup_view_zoom_h = CEILING(zoom_dim_h, 4)
	// Measuring can yield; skip if the menu closed or reopened meanwhile.
	if(QDELETED(body) || body != character_setup_body)
		return
	character_setup_apply_to_view(character_setup_view, body, character_setup_preview_dir)
	if(!main_only)
		character_setup_apply_to_view(character_setup_view_front, body, SOUTH)
		character_setup_apply_to_view(character_setup_view_side, body, EAST)
	character_setup_log("VIEW", "render done main_only=[main_only] dir=[character_setup_preview_dir] flat=[character_setup_view_last_flat] feet_margin=[character_setup_view_feet_margin] underwear=[body.underwear]")

/datum/preferences/proc/character_setup_measure_art(dir)
	var/mob/living/carbon/human/dummy/body = character_setup_body
	if(!body)
		return null
	// A frozen copy, so the measurement holds if the dummy changes while a new sprite is scanned.
	var/mutable_appearance/snapshot = new(body)
	// Copied appearances get FLOAT_PLANE in New(); overlays are filtered by plane.
	snapshot.plane = body.plane
	var/list/art
	if(snapshot.alpha > 0)
		art = character_setup_appearance_art_bounds(snapshot, dir, snapshot.icon, snapshot.icon_state, snapshot.blend_mode)
	if(!art)
		return list(32, 32, 0, 0)
	return list(art[3] - art[1] + 1, art[4] - art[2] + 1, art[1] - 1, art[2] - 1)

/datum/preferences/proc/character_setup_measure_body(dir)
	var/list/art = character_setup_measure_art(dir)
	if(!art)
		return
	character_setup_view_bbox_w = art[1]
	character_setup_view_bbox_h = art[2]
	character_setup_view_off_x = art[3]
	character_setup_view_off_y = art[4]
	character_setup_view_extent_w = max(1, CEILING(character_setup_view_bbox_w / 32, 1))
	character_setup_view_extent_h = max(1, CEILING(character_setup_view_bbox_h / 32, 1))
	character_setup_bg?.fill_rect(1, 1, character_setup_view_canvas_w, character_setup_view_canvas_h)
	character_setup_bg_front?.fill_rect(1, 1, character_setup_view_canvas_w, character_setup_view_canvas_h)
	character_setup_bg_side?.fill_rect(1, 1, character_setup_view_canvas_w, character_setup_view_canvas_h)
	if(GLOB.character_setup_debug)
		character_setup_log("VIEW", "measure dir=[dir] art=[character_setup_view_bbox_w]x[character_setup_view_bbox_h] origin=[character_setup_view_off_x],[character_setup_view_off_y] extent=[character_setup_view_extent_w]x[character_setup_view_extent_h] zoom_dims=[character_setup_view_zoom_w]x[character_setup_view_zoom_h] species=[pref_species?.id] taur=[pref_species?.forced_taur ? 1 : 0]")

/// Pixel bounds (x1, y1, x2, y2) of what this appearance draws, in its own icon's coordinates, or null.
/// Follows the layer rules a flat icon of it would, but unions cached per-sprite bounds instead of
/// blending a flat icon, which made every preview render cost tenths of a second.
/proc/character_setup_appearance_art_bounds(image/appearance, defdir, deficon, defstate, defblend)
	var/curicon = appearance.icon || deficon
	var/curstate = appearance.icon_state || defstate
	var/curdir = (!appearance.dir || appearance.dir == SOUTH) ? defdir : appearance.dir
	var/curblend = appearance.blend_mode || defblend
	// Cached and shared: unions below always build a new list.
	var/list/bounds = character_setup_sprite_art_bounds(curicon, curstate, curdir)
	for(var/list/layers as anything in list(appearance.underlays, appearance.overlays))
		for(var/image/current as anything in layers)
			if(!current || current.alpha == 0 || current.plane == EMISSIVE_PLANE)
				continue
			if(current.plane != FLOAT_PLANE && current.plane != appearance.plane)
				continue
			// A flat icon gives up on layers this low and draws nothing.
			if(current.layer <= -1000)
				return null
			// Multiplied and inset layers only recolour pixels that are already drawn.
			var/layer_blend = current.blend_mode || curblend
			if(layer_blend == BLEND_MULTIPLY || layer_blend == BLEND_INSET_OVERLAY)
				continue
			var/list/layer_bounds = character_setup_appearance_art_bounds(image(current), curdir, curicon, curstate, curblend)
			if(!layer_bounds)
				continue
			var/x1 = layer_bounds[1] + current.pixel_x
			var/y1 = layer_bounds[2] + current.pixel_y
			var/x2 = layer_bounds[3] + current.pixel_x
			var/y2 = layer_bounds[4] + current.pixel_y
			if(bounds)
				bounds = list(min(bounds[1], x1), min(bounds[2], y1), max(bounds[3], x2), max(bounds[4], y2))
			else
				bounds = list(x1, y1, x2, y2)
	return bounds

/// Art bounds of one sprite frame, drawn the way a flat icon draws it. Sprites never change,
/// so every result is kept for the round and shared by all players.
/proc/character_setup_sprite_art_bounds(sprite_icon, sprite_state, sprite_dir)
	if(!sprite_icon)
		return null
	var/static/list/bounds_by_icon = list()
	var/list/bounds_by_key = bounds_by_icon[sprite_icon]
	if(!bounds_by_key)
		bounds_by_key = list()
		bounds_by_icon[sprite_icon] = bounds_by_key
	var/key = "[sprite_state]|[sprite_dir]"
	var/cached = bounds_by_key[key]
	if(!isnull(cached))
		return cached || null
	// Only a sprite seen for the first time is scanned; callers measure a frozen appearance copy.
	CHECK_TICK
	var/list/bounds
	var/state = sprite_state
	if(!icon_exists(sprite_icon, state) && icon_exists(sprite_icon, ""))
		state = ""
	if(icon_exists(sprite_icon, state))
		var/draw_dir = sprite_dir || SOUTH
		if(draw_dir != SOUTH && !length(icon_states(icon(sprite_icon, state, NORTH))))
			draw_dir = SOUTH
		bounds = character_setup_art_bounds(icon(sprite_icon, state, draw_dir, 1))
	bounds_by_key[key] = bounds || FALSE
	return bounds

/datum/preferences/proc/character_setup_apply_to_view(atom/movable/screen/map_view/view, mob/living/carbon/human/dummy/body, view_dir)
	if(!view)
		return
	view.appearance = body.appearance
	view.setDir(view_dir)
	view.plane = GAME_PLANE
	view.layer = GAME_PLANE
	view.pixel_x = 0
	view.pixel_y = 0
	view.pixel_z = 0
	view.pixel_w = 0
	view.maptext = null
	view.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	view.transform = null
	var/anchor_px = round(character_setup_view_canvas_cx - character_setup_view_bbox_w / 2) - character_setup_view_off_x + character_setup_view_doll_px
	var/anchor_py = round(character_setup_view_canvas_cy - character_setup_view_bbox_h / 2) - character_setup_view_off_y + character_setup_view_doll_py
	view.set_position(character_setup_view_doll_x, character_setup_view_doll_y, anchor_px, anchor_py)
	if(GLOB.character_setup_debug)
		character_setup_log("VIEW", "apply map=[view.assigned_map] dir=[view_dir] bbox=[character_setup_view_bbox_w]x[character_setup_view_bbox_h] extent=[character_setup_view_extent_w]x[character_setup_view_extent_h] screen_loc=[view.screen_loc] base_icon=[body.icon] overlays=[length(view.overlays)] appearance_flags=[view.appearance_flags] view_dir=[view.dir]")
	character_setup_view_last_flat = "appearance dir=[view_dir] bbox=[character_setup_view_bbox_w]x[character_setup_view_bbox_h] extent=[character_setup_view_extent_w]x[character_setup_view_extent_h] overlays=[length(view.overlays)] view_dir=[view.dir]"

/datum/preferences/proc/character_setup_current_view_scale()
	if(pref_species?.forced_taur && LAZYLEN(pref_species.allowed_taur_types))
		return max(1, round(character_setup_view_scale * 0.55))
	return character_setup_view_scale

#undef CHARACTER_SETUP_RENDER_COOLDOWN
