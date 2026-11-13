/// TGUI character setup menu — state, logging, savefile persistence and small helpers.
/// Ported from neurolin's character_menu.dm and integrated natively (no wrapper prefs).
/datum/preferences/var/character_setup_preferences_initial_tab = "identity"
/datum/preferences/var/character_setup_preferences_open_sequence = 0
/datum/preferences/var/character_setup_preferences_fullscreen = FALSE
/datum/preferences/var/character_setup_preferences_scale = 1
/datum/preferences/var/character_setup_preferences_scale_version = 3
/datum/preferences/var/character_setup_preview_underwear = TRUE
/datum/preferences/var/character_setup_preview_clothes = TRUE
/datum/preferences/var/character_setup_preview_dir = SOUTH
/datum/preferences/var/character_setup_preview_background
/datum/preferences/var/character_setup_static_sig
/datum/preferences/var/atom/movable/screen/map_view/character_setup_view
/datum/preferences/var/atom/movable/screen/map_view/character_setup_view_front
/datum/preferences/var/atom/movable/screen/map_view/character_setup_view_side
/datum/preferences/var/atom/movable/screen/background/character_setup_bg
/datum/preferences/var/atom/movable/screen/background/character_setup_bg_front
/datum/preferences/var/atom/movable/screen/background/character_setup_bg_side
/datum/preferences/var/character_setup_view_extent_w = 1
/datum/preferences/var/character_setup_view_extent_h = 1
/datum/preferences/var/character_setup_view_bbox_w = 32
/datum/preferences/var/character_setup_view_bbox_h = 33
/datum/preferences/var/character_setup_view_zoom_w = 32
/datum/preferences/var/character_setup_view_zoom_h = 36
/datum/preferences/var/character_setup_view_off_x = 0
/datum/preferences/var/character_setup_view_off_y = 0
/datum/preferences/var/character_setup_view_bbox_sent = ""
/datum/preferences/var/character_setup_view_doll_x = 1
/datum/preferences/var/character_setup_view_doll_y = 1
/datum/preferences/var/character_setup_view_doll_px = 0
/datum/preferences/var/character_setup_view_doll_py = 0
/datum/preferences/var/character_setup_view_canvas_w = 20
/datum/preferences/var/character_setup_view_canvas_h = 15
/datum/preferences/var/character_setup_view_canvas_cx = 320
/datum/preferences/var/character_setup_view_canvas_cy = 240
/datum/preferences/var/character_setup_view_tile_top = 15
/datum/preferences/var/character_setup_view_tile_center = 8
/datum/preferences/var/character_setup_view_scale = 12
/datum/preferences/var/character_setup_view_feet_margin = 20
/datum/preferences/var/character_setup_view_last_flat = ""
/datum/preferences/var/character_setup_render_main_only = FALSE
/datum/preferences/var/mob/living/carbon/human/dummy/character_setup_body
/datum/preferences/var/character_setup_hover_acc
/datum/preferences/var/character_setup_hover_color
/datum/preferences/var/character_setup_hover_customizer
/datum/preferences/var/character_setup_view_busy = FALSE
/datum/preferences/var/character_setup_view_pending = FALSE
/// Render signature the preview dummy was last dressed from.
/datum/preferences/var/character_setup_rendered_sig
/datum/preferences/var/character_setup_render_forced = FALSE
/// Facing changed with nothing else; only re-measure and turn the main view.
/datum/preferences/var/character_setup_redraw_dir = FALSE
/// Hover the dummy currently shows, so a new hover can swap one accessory instead of rebuilding.
/datum/preferences/var/character_setup_rendered_hover_acc
/datum/preferences/var/character_setup_rendered_hover_color
/datum/preferences/var/character_setup_rendered_hover_customizer
/datum/preferences/var/character_setup_view_shown = FALSE
/datum/preferences/var/list/character_setup_ui_heavy_cache
/datum/preferences/var/character_setup_ui_heavy_sig
/// Counts ui_data builds, so a queued push can tell that a later build already went out.
/datum/preferences/var/character_setup_data_serial = 0
/// character_setup_data_serial when the pending push was queued.
/datum/preferences/var/character_setup_push_serial = 0
/datum/preferences/var/character_setup_render_cooldown = 0

GLOBAL_LIST_EMPTY(character_setup_chargen_ooc_messages)

GLOBAL_VAR_INIT(character_setup_debug, FALSE)

/proc/character_setup_glog(category, msg)
	if(!GLOB.character_setup_debug)
		return
	WRITE_LOG("[GLOB.log_directory]/character_setup.log", "[world.timeofday]ds render \[[category]\] [msg]")

/proc/character_setup_art_bounds(icon/scanned)
	if(!isicon(scanned))
		return null
	var/width = scanned.Width()
	var/height = scanned.Height()
	var/x1 = 0
	var/x2 = 0
	var/y1 = 0
	var/y2 = 0
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			if(!scanned.GetPixel(x, y))
				continue
			if(!x1 || x < x1)
				x1 = x
			if(x > x2)
				x2 = x
			if(!y1)
				y1 = y
			y2 = y
	if(!x1)
		return null
	return list(x1, y1, x2, y2)

/datum/preferences/var/list/character_setup_log_counts
/datum/preferences/var/character_setup_log_action_name = ""
/datum/preferences/var/character_setup_log_action_tod = 0

/datum/preferences/proc/character_setup_log(category, msg)
	if(!GLOB.character_setup_debug)
		return
	WRITE_LOG("[GLOB.log_directory]/character_setup.log", "[world.timeofday]ds [parent?.ckey || "?"] \[[category]\] [msg]")

/datum/preferences/proc/character_setup_log_action(action_name, extra)
	if(!GLOB.character_setup_debug)
		return
	character_setup_log_counts = list()
	character_setup_log_action_name = action_name
	character_setup_log_action_tod = world.timeofday
	character_setup_log("ACTION", ">>>>> [action_name][extra ? " ([extra])" : ""]")

/datum/preferences/proc/character_setup_log_op(op, start_tod, detail)
	if(!GLOB.character_setup_debug)
		return
	LAZYINITLIST(character_setup_log_counts)
	character_setup_log_counts[op] = (character_setup_log_counts[op] || 0) + 1
	var/cnt = character_setup_log_counts[op]
	var/delta = world.timeofday - start_tod
	character_setup_log("OP", "[op] x[cnt] took=[delta]ds[detail ? " {[detail]}" : ""][cnt > 1 ? "  *** MULTIPLICATIVE in [character_setup_log_action_name] ***" : ""]")

/proc/character_setup_chargen_record_ooc(sender, message, lobby_only = FALSE)
	if(!istext(sender) || !istext(message))
		return

	var/clean_message = trim(STRIP_HTML_FULL(message, MAX_MESSAGE_LEN))
	if(!length(clean_message))
		return

	GLOB.character_setup_chargen_ooc_messages += list(list(
		"sender" = sender,
		"message" = clean_message,
		"time" = time2text(world.timeofday, "hh:mm"),
		"lobby" = !!lobby_only,
	))
	if(length(GLOB.character_setup_chargen_ooc_messages) > 40)
		GLOB.character_setup_chargen_ooc_messages.Cut(1, length(GLOB.character_setup_chargen_ooc_messages) - 39)

/datum/preferences/proc/character_setup_sanitize_preferences_scale(value)
	if(!isnum(value))
		value = text2num("[value]")
	if(!isnum(value))
		return 0.85
	return clamp(round(value * 20) / 20, 0.8, 1.25)

/// Called from load_preferences() in preferences_savefile.dm with the already-open savefile.
/datum/preferences/proc/character_setup_load_menu_prefs(savefile/S)
	if(!S)
		return
	S.cd = "/"
	S["character_setup_preferences_fullscreen"] >> character_setup_preferences_fullscreen
	S["character_setup_preferences_scale"] >> character_setup_preferences_scale
	var/loaded_scale_version
	S["character_setup_preferences_scale_version"] >> loaded_scale_version

	character_setup_preferences_fullscreen = !!character_setup_preferences_fullscreen
	if(!isnum(loaded_scale_version) || loaded_scale_version < character_setup_preferences_scale_version)
		character_setup_preferences_scale = initial(character_setup_preferences_scale)
	character_setup_preferences_scale = character_setup_sanitize_preferences_scale(character_setup_preferences_scale)

/// Called from save_preferences() in preferences_savefile.dm with the already-open savefile.
/datum/preferences/proc/character_setup_save_menu_prefs(savefile/S)
	if(!S)
		return
	S.cd = "/"
	WRITE_FILE(S["character_setup_preferences_fullscreen"], character_setup_preferences_fullscreen)
	WRITE_FILE(S["character_setup_preferences_scale"], character_setup_preferences_scale)
	WRITE_FILE(S["character_setup_preferences_scale_version"], character_setup_preferences_scale_version)

/datum/preferences/proc/character_setup_background_options()
	return list(
		list("name" = "None", "value" = "none"),
		list("name" = "White", "value" = "white"),
		list("name" = "Dark", "value" = "dark"),
	)

/datum/preferences/proc/character_setup_chargen_clean_text(text, limit = 900)
	if(!text)
		return ""
	return trim(STRIP_HTML_FULL(replacetext("[text]", "\n", " "), limit))

// ---- TGUI plumbing ----

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

/datum/preferences/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/character_setup_chargen),
		get_asset_datum(/datum/asset/spritesheet/loadout_items),
		get_asset_datum(/datum/asset/spritesheet/preference_badges),
		get_asset_datum(/datum/asset/simple/character_creator),
	)

/datum/preferences/ui_static_data(mob/user)
	var/_t = world.timeofday
	. = list()
	.["background_options"] = character_setup_background_options()
	.["thumbs"] = character_setup_thumbnail_catalog()
	.["species_options"] = character_setup_species_options()
	.["smallclothes_catalog"] = character_setup_smallclothes_static()
	.["loadout_catalog"] = character_setup_loadout_static(user)
	.["job_categories"] = character_setup_job_categories(user)
	character_setup_log_op("ui_static_data", _t, "thumbs=[length(.["thumbs"])] species=[length(.["species_options"])]")

/datum/preferences/proc/character_setup_handle_color_task(mob/user, list/href_list)
	var/customizer_type = text2path(href_list["customizer"])
	if(!customizer_type)
		return FALSE
	var/datum/customizer_entry/hair/he = get_customizer_entry_for_customizer_type(customizer_type)
	if(!istype(he))
		return FALSE
	var/field
	switch(href_list["customizer_task"])
		if("hair_color")
			field = "hair_color"
		if("natural_gradient_color")
			field = "natural_color"
		if("dye_gradient_color")
			field = "dye_color"
		else
			return FALSE
	var/new_color = tgui_color_picker(user, "Choose color", "Color", sanitize_hexcolor(he.vars[field], 6, TRUE, "#ffffff"))
	if(new_color)
		he.vars[field] = sanitize_hexcolor(new_color)
	return TRUE

// ---- Species catalog ----

/datum/preferences/proc/character_setup_species_lock_reason(datum/species/species)
	if(!species)
		return "Unavailable"
	if(species.preference_accessible(src))
		return ""
	return "Unavailable"

/datum/preferences/proc/character_setup_stat_modifiers_for_sheet(sheet_type)
	. = list()
	if(!sheet_type)
		return

	var/datum/attribute_holder/sheet/sheet = GLOB.attribute_sheets[sheet_type]
	if(!sheet)
		sheet = GLOB.attribute_sheets[sheet_type] = new sheet_type()
	for(var/stat_type in MOBSTATS)
		var/value = sheet.raw_attribute_list[stat_type]
		if(!isnum(value) || !value)
			continue
		var/datum/attribute/stat/stat = GET_ATTRIBUTE_DATUM(stat_type)
		. += list(list(
			"name" = stat ? stat.name : "[stat_type]",
			"label" = stat ? stat.shorthand : "[stat_type]",
			"value" = value,
		))

/datum/preferences/proc/character_setup_species_stat_modifiers(datum/species/species)
	if(!species)
		return list()
	var/sheet_type = species.statsheet_male
	if(read_preference(/datum/preference/choiced/gender) == FEMALE && species.statsheet_female)
		sheet_type = species.statsheet_female
	return character_setup_stat_modifiers_for_sheet(sheet_type)

/datum/preferences/proc/character_setup_age_sheet_type(age_name)
	switch(age_name)
		if(AGE_MIDDLEAGED)
			return /datum/attribute_holder/sheet/age/middleaged
		if(AGE_OLD)
			return /datum/attribute_holder/sheet/age/old

/datum/preferences/proc/character_setup_stat_modifier_summary(list/modifiers)
	if(!length(modifiers))
		return "No stat modifiers."
	var/list/parts = list()
	for(var/list/modifier as anything in modifiers)
		var/value = modifier["value"]
		parts += "[modifier["label"]] [value > 0 ? "+" : ""][value]"
	return parts.Join(", ")

/datum/preferences/proc/character_setup_age_stat_tooltip(age_name)
	var/list/modifiers = character_setup_stat_modifiers_for_sheet(character_setup_age_sheet_type(age_name))
	if(!length(modifiers))
		return "[age_name]: No age stat modifiers."
	return "[age_name]: [character_setup_stat_modifier_summary(modifiers)]"

/datum/preferences/proc/character_setup_species_tags(datum/species/species, available)
	. = list()
	if(!species)
		return
	if(species.native_language)
		. += "[species.native_language]"
	if(species.skin_tone_wording && species.skin_tone_wording != "Ancestry")
		. += "[species.skin_tone_wording]"
	var/list/display_ages = character_setup_species_display_ages(species)
	if(length(display_ages) == 1)
		. += "[display_ages[1]]"
	if(!(species.id in RACES_PLAYER_NONDISCRIMINATED))
		. += "Discriminated"
	if(!(species.id in RACES_PLAYER_NONEXOTIC))
		. += "Exotic"
	if(species.forced_taur)
		. += "Taur"
	if(!available)
		. += "Locked"

/datum/preferences/proc/character_setup_species_tag_description(datum/species/species, tag, available)
	switch(tag)
		if("Discriminated")
			return "This species faces social discrimination; expect a more difficult roundstart experience."
		if("Exotic")
			return "This species is considered uncommon or exotic in most local cultures."
		if("Taur")
			return "Tauric body plan; some equipment and clothing may fit differently."
		if("Locked")
			return available ? "Available." : character_setup_species_lock_reason(species)

	if(species)
		if(species.native_language && tag == "[species.native_language]")
			return "Native language or culture group: [tag]."
		if(species.skin_tone_wording && tag == "[species.skin_tone_wording]")
			return "This species uses [tag] as its ancestry/color choice."
		if(tag in character_setup_species_display_ages(species))
			return "Available age category: [tag]."

	return "[tag] species tag."

/datum/preferences/proc/character_setup_species_tag_descriptions(datum/species/species, available)
	. = list()
	for(var/tag in character_setup_species_tags(species, available))
		.["[tag]"] = character_setup_species_tag_description(species, tag, available)

/datum/preferences/proc/character_setup_species_display_ages(datum/species/species)
	. = list()
	if(!species)
		return
	for(var/possible_age in species.possible_ages)
		if(!(possible_age in .))
			. += possible_age

/datum/preferences/proc/character_setup_species_options()
	. = list()
	for(var/species_id in GLOB.roundstart_species)
		var/species_type = GLOB.species_list[species_id]
		if(!species_type)
			continue
		var/datum/species/species = new species_type()
		var/lock_reason = character_setup_species_lock_reason(species)
		var/available = !lock_reason
		var/description = species.desc ? character_setup_chargen_clean_text(species.desc, 900) : "No description available."
		var/list/display_ages = character_setup_species_display_ages(species)
		. += list(list(
			"id" = species.id,
			"name" = species.name,
			"description" = trim(description),
			"available" = available,
			"lock_reason" = lock_reason,
			"language" = species.native_language || "Imperial",
			"ancestry_label" = species.skin_tone_wording || "Ancestry",
			"ages" = length(display_ages) ? display_ages.Join(", ") : "Any",
			"tags" = character_setup_species_tags(species, available),
			"tag_descriptions" = character_setup_species_tag_descriptions(species, available),
			"stats" = character_setup_species_stat_modifiers(species),
		))

/datum/preferences/proc/character_setup_apply_species(mob/user, species_id)
	if(!user || !species_id)
		return FALSE
	if(!(species_id in GLOB.roundstart_species))
		return FALSE

	var/species_type = GLOB.species_list[species_id]
	if(!species_type)
		return FALSE

	var/datum/species/new_species = new species_type()
	if(!new_species.preference_accessible(src))
		to_chat(user, span_warning("[new_species.name] is not available for this character."))
		return TRUE

	if(pref_species?.type == species_type)
		return TRUE

	var/saved_age = read_preference(/datum/preference/choiced/age)
	var/saved_name = read_preference(/datum/preference/text/real_name)
	var/had_mutant_colors = has_mutant_color_preferences()
	write_preference(/datum/preference/choiced/selected_accent, ACCENT_NONE)
	set_species_preference(new_species)

	to_chat(user, "<em>[pref_species.name]</em>")
	if(pref_species.desc)
		to_chat(user, "[pref_species.desc]")

	if(!length(pref_species.allowed_pronouns))
		to_chat(user, span_warning("This species does not have any allowed pronouns. Please contact a coder to add them."))
	else if(length(pref_species.allowed_pronouns) == 1)
		write_preference(/datum/preference/choiced/pronouns, pref_species.allowed_pronouns[1])
	else if(!(read_preference(/datum/preference/choiced/pronouns) in pref_species.allowed_pronouns))
		write_preference(/datum/preference/choiced/pronouns, pref_species.allowed_pronouns[1])

	reset_jobs(user)
	reset_patron(user)
	reset_culture(user)
	fit_appearance_to_species(had_mutant_colors)

	var/list/selectable_ages = character_setup_species_display_ages(pref_species)
	if(saved_age && (saved_age in selectable_ages))
		write_preference(/datum/preference/choiced/age, saved_age)
	else if(length(selectable_ages))
		write_preference(/datum/preference/choiced/age, selectable_ages[1])
	if(!saved_name)
		write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))

	update_menu_data(user)
	return TRUE

/datum/preferences/proc/character_setup_thumbnail_catalog()
	. = list()
	if(!pref_species)
		return
	for(var/customizer_type in pref_species.customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer)
			continue
		for(var/choice_type in customizer.customizer_choices)
			var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
			if(!choice || !LAZYLEN(choice.sprite_accessories))
				continue
			for(var/accessory_type in choice.sprite_accessories)
				var/key = "[accessory_type]"
				if(.[key])
					continue
				var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
				if(accessory)
					.[key] = sanitize_css_class_name("[accessory_type]")

// ---- Faith / patron / ancestry catalogs ----

/datum/preferences/proc/character_setup_patron_options_for_faith(faith_type)
	. = list()
	var/list/patrons = GLOB.patrons_by_faith[faith_type]
	if(!length(patrons))
		return
	var/datum/patron/selected_patron = read_preference(/datum/preference/choiced/patron)
	var/current_patron_type = selected_patron?.type
	// GLOB.patrons_by_faith is keyed by patron INSTANCES, not typepaths.
	for(var/datum/patron/patron as anything in patrons)
		if(!istype(patron))
			continue
		var/available = patron.preference_accessible(src)
		var/patron_name = patron.display_name ? patron.display_name : patron.name
		. += list(list(
			"id" = "[patron.type]",
			"name" = patron_name,
			"domain" = patron.domain || "",
			"description" = character_setup_chargen_clean_text(patron.desc, 700),
			"flaws" = patron.flaws || "",
			"worshippers" = patron.worshippers || "",
			"sins" = patron.sins || "",
			"boons" = patron.boons || "",
			"available" = available,
			"selected" = current_patron_type == patron.type,
		))

/datum/preferences/proc/character_setup_faith_options()
	. = list()
	var/datum/patron/selected_patron = read_preference(/datum/preference/choiced/patron)
	var/current_faith = selected_patron ? selected_patron.associated_faith : /datum/patron/divine/astrata::associated_faith
	for(var/faith_type in GLOB.faith_list)
		var/datum/faith/faith = GLOB.faith_list[faith_type]
		if(!faith)
			continue
		var/list/patrons = character_setup_patron_options_for_faith(faith_type)
		var/available = faith.preference_accessible(src)
		if(!available && !length(patrons))
			continue
		. += list(list(
			"id" = "[faith_type]",
			"name" = faith.name || "[faith_type]",
			"description" = character_setup_chargen_clean_text(faith.desc, 700),
			"available" = available,
			"selected" = faith_type == current_faith,
			"patrons" = patrons,
		))

/datum/preferences/proc/character_setup_current_ancestry_name()
	if(!pref_species)
		return "None"
	var/list/skins = pref_species.get_skin_list()
	for(var/skin_name in skins)
		if(skins[skin_name] == read_preference(/datum/preference/choiced/skin_tone))
			return "[skin_name]"
	return "None"

/datum/preferences/proc/character_setup_ancestry_options()
	. = list()
	if(!pref_species || has_mutant_color_preferences())
		return
	var/list/skins = pref_species.get_skin_list()
	for(var/skin_name in skins)
		var/skin_value = skins[skin_name]
		. += list(list(
			"name" = "[skin_name]",
			"value" = "[skin_name]",
			"color" = "[skin_value]",
			"selected" = skin_value == read_preference(/datum/preference/choiced/skin_tone),
		))

/datum/preferences/proc/character_setup_apply_patron(mob/user, patron_id)
	if(!user || !patron_id)
		return TRUE
	var/patron_type = text2path(patron_id)
	var/datum/patron/patron = GLOB.patron_list[patron_type]
	if(!patron)
		return TRUE
	if(!patron.preference_accessible(src))
		to_chat(user, span_warning("[patron.display_name || patron.name] is not available for this character."))
		return TRUE

	write_preference(/datum/preference/choiced/patron, patron_type)
	var/datum/patron/selected_patron = read_preference(/datum/preference/choiced/patron)
	to_chat(user, "<font color='purple'>Patron: [selected_patron.name]</font>")
	to_chat(user, "<font color='purple'>Domain: [selected_patron.domain]</font>")
	to_chat(user, "<font color='purple'>Background: [selected_patron.desc]</font>")
	to_chat(user, "<font color='purple'>Flawed aspects: [selected_patron.flaws]</font>")
	to_chat(user, "<font color='purple'>Likely Worshippers: [selected_patron.worshippers]</font>")
	to_chat(user, "<font color='red'>Considers these to be Sins: [selected_patron.sins]</font>")
	to_chat(user, "<font color='white'>Blessed with boon(s): [selected_patron.boons]</font>")
	save_character()
	update_menu_data(user)
	return TRUE

/datum/preferences/proc/character_setup_apply_faith(mob/user, faith_id)
	if(!user || !faith_id)
		return TRUE
	var/faith_type = text2path(faith_id)
	var/datum/faith/faith = GLOB.faith_list[faith_type]
	if(!faith)
		return TRUE
	if(!faith.preference_accessible(src))
		to_chat(user, span_warning("[faith.name] is not available for this character."))
		return TRUE

	var/patron_type = faith.godhead
	var/datum/patron/patron = patron_type ? GLOB.patron_list[patron_type] : null
	if(!patron || !patron.preference_accessible(src))
		patron_type = null
		// Keys of patrons_by_faith lists are patron instances.
		for(var/datum/patron/candidate as anything in GLOB.patrons_by_faith[faith_type])
			if(istype(candidate) && candidate.preference_accessible(src))
				patron_type = candidate.type
				break
	if(!patron_type)
		return TRUE

	write_preference(/datum/preference/choiced/patron, patron_type)
	to_chat(user, "<font color='purple'>Faith: [faith.name]</font>")
	to_chat(user, "<font color='purple'>Background: [faith.desc]</font>")
	save_character()
	update_menu_data(user)
	return TRUE

/datum/preferences/proc/character_setup_apply_ancestry(mob/user, ancestry_name)
	if(!user || !pref_species || !ancestry_name || has_mutant_color_preferences())
		return TRUE
	var/list/skins = pref_species.get_skin_list()
	if(!(ancestry_name in skins))
		return TRUE
	var/new_skin_tone = skins[ancestry_name]
	if(read_preference(/datum/preference/choiced/skin_tone) != new_skin_tone)
		write_preference(/datum/preference/choiced/skin_tone, new_skin_tone)
		save_character()
		update_menu_data(user)
	return TRUE

// ---- Lobby round flow ----

/mob/dead/new_player/proc/character_setup_chargen_set_ready(new_ready)
	if(new_ready == PLAYER_READY_TO_PLAY && !client?.prefs?.defeat_introduction_complete)
		client?.prefs?.show_choices(src)
		return FALSE
	ready = new_ready
	if(ready == PLAYER_READY_TO_PLAY)
		cache_multi_ready_characters()
	else
		multi_ready_characters = list()

	var/datum/hud/new_player/lobby_hud = hud_used
	if(istype(lobby_hud))
		for(var/atom/movable/screen/lobby/button/ready/ready_button in lobby_hud.static_inventory)
			ready_button.ready = (ready == PLAYER_READY_TO_PLAY)
			ready_button.base_icon_state = ready_button.ready ? "ready" : "not_ready"
			ready_button.update_appearance(UPDATE_ICON)
			break
		SEND_SIGNAL(lobby_hud, COMSIG_HUD_PLAYER_READY_TOGGLE)
	character_setup_push_lobby_menus()
	return TRUE

/// Open lobby menus show the ready count, so every ready toggle refreshes them.
/proc/character_setup_push_lobby_menus()
	for(var/mob/dead/new_player/lobby_player as anything in GLOB.new_player_list)
		lobby_player.client?.prefs?.character_setup_queue_push()

/mob/dead/new_player/proc/character_setup_chargen_join_round()
	if(!SSticker?.IsRoundInProgress())
		to_chat(src, span_boldwarning("The round is either not ready, or has already finished..."))
		return TRUE

	var/relevant_cap
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(hard_popcap && extreme_popcap)
		relevant_cap = min(hard_popcap, extreme_popcap)
	else
		relevant_cap = max(hard_popcap, extreme_popcap)

	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in GLOB.admin_datums)))
		to_chat(src, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))

		var/queue_position = SSticker.queued_players.Find(src)
		if(queue_position == 1)
			to_chat(src, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
		else if(queue_position)
			to_chat(src, span_notice("There are [queue_position-1] players in front of you in the queue to join the game."))
		else
			SSticker.queued_players += src
			to_chat(src, span_notice("You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len]."))
		return TRUE

	LateChoices()
	return TRUE

/datum/preferences/proc/character_setup_round_action(mob/user)
	var/mob/dead/new_player/new_player
	if(istype(user, /mob/dead/new_player))
		new_player = user
	if(!new_player?.client || !SSticker)
		return TRUE

	if(parent && new_player.client != parent)
		return TRUE

	if(is_active_migrant())
		to_chat(new_player, span_boldwarning("You are in the migrant queue."))
		return TRUE

	if(SSticker.IsRoundInProgress())
		return new_player.character_setup_chargen_join_round()

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		if(new_player.ready == PLAYER_READY_TO_PLAY)
			if(SSticker.job_change_locked)
				return TRUE
			return new_player.character_setup_chargen_set_ready(PLAYER_NOT_READY)
		return new_player.character_setup_chargen_set_ready(PLAYER_READY_TO_PLAY)

	to_chat(new_player, span_boldwarning("The game is starting. You cannot join yet."))
	return TRUE

// ---- ERP preferences (native Intimacy tab) ----

/datum/preferences/proc/character_setup_erp_data(mob/user)
	setup_default_erp_preferences()
	var/lock_reason = get_erp_preference_edit_lock_reason(user)

	var/list/category_map = list()
	for(var/datum/erp_preference/pref_type as anything in subtypesof(/datum/erp_preference))
		if(IS_ABSTRACT(pref_type))
			continue
		var/datum/erp_preference/pref = new pref_type()
		if(pref.abstract_type == pref_type)
			continue
		var/list/entry = list(
			"type" = "[pref_type]",
			"name" = pref.name,
			"description" = pref.description,
		)
		if(pref.locked_after_spawn && is_erp_spawn_locked(user))
			entry["lock_reason"] = pref.get_edit_lock_reason(user, src)
		if(istype(pref, /datum/erp_preference/bitflag))
			var/datum/erp_preference/bitflag/flag_pref = pref
			entry["kind"] = "flags"
			var/current_flags = flag_pref.get_value(src)
			var/list/flags_out = list()
			for(var/flag_name in flag_pref.flags)
				var/flag_bit = flag_pref.flags[flag_name]
				flags_out += list(list(
					"name" = flag_name,
					"bit" = flag_bit,
					"description" = flag_pref.flag_descriptions[flag_name] || "",
					"on" = !!(current_flags & flag_bit),
				))
			entry["flags"] = flags_out
		else if(istype(pref, /datum/erp_preference/numeric))
			var/datum/erp_preference/numeric/num_pref = pref
			entry["kind"] = "number"
			entry["value"] = num_pref.get_value(src)
			entry["min"] = num_pref.min_value
			entry["max"] = num_pref.max_value
		else if(istype(pref, /datum/erp_preference/list_choice))
			var/datum/erp_preference/list_choice/choice_pref = pref
			entry["kind"] = "choice"
			entry["value"] = "[choice_pref.get_value(src)]"
			var/list/choice_names = list()
			for(var/choice in choice_pref.choices)
				choice_names += "[choice]"
			entry["choices"] = choice_names
		else
			entry["kind"] = "bool"
			entry["value"] = !!pref.get_value(src)
		if(!category_map[pref.category])
			category_map[pref.category] = list()
		category_map[pref.category] += list(entry)
	var/list/categories = list()
	for(var/category_name in category_map)
		categories += list(list("name" = category_name, "prefs" = category_map[category_name]))

	var/list/kink_map = list()
	var/list/kink_prefs = ensure_kink_preferences()
	for(var/kink_name in GLOB.available_kinks)
		var/datum/kink/kink = GLOB.available_kinks[kink_name]
		if(!kink)
			continue
		var/list/kink_data = kink_prefs[kink.name]
		if(!islist(kink_data))
			kink_data = get_default_kink_preference_data()
			kink_prefs[kink.name] = kink_data
		if(!kink_map[kink.category])
			kink_map[kink.category] = list()
		kink_map[kink.category] += list(list(
			"name" = kink.name,
			"description" = kink.description,
			"enabled" = !!kink_data["enabled"],
			"intensity" = kink_data["intensity"] || 1,
			"notes" = kink_data["notes"] || "",
		))
	var/list/kink_categories = list()
	for(var/category_name in kink_map)
		kink_categories += list(list("name" = category_name, "kinks" = kink_map[category_name]))

	return list(
		"lock_reason" = lock_reason,
		"categories" = categories,
		"kink_categories" = kink_categories,
	)

// ---- Live data ----

/datum/preferences/ui_data(mob/user)
	character_setup_data_serial++
	var/list/data = list()
	var/real_name = read_preference(/datum/preference/text/real_name)
	var/gender = read_preference(/datum/preference/choiced/gender)
	var/age = read_preference(/datum/preference/choiced/age)
	var/pronouns = read_preference(/datum/preference/choiced/pronouns)
	var/domhand = read_preference(/datum/preference/choiced/domhand)
	var/skin_tone = read_preference(/datum/preference/choiced/skin_tone)
	var/culture = read_preference(/datum/preference/choiced/culture)
	var/datum/patron/selected_patron = read_preference(/datum/preference/choiced/patron)
	var/selected_title = read_preference(/datum/preference/text/selected_title)
	var/taur_type = read_preference(/datum/preference/choiced/taur_type)
	var/taur_color = read_preference(/datum/preference/color/taur_color)
	var/taur_markings = read_preference(/datum/preference/color/taur_markings)
	var/taur_tertiary = read_preference(/datum/preference/color/taur_tertiary)
	var/headshot_link = read_preference(/datum/preference/text/headshot_link)
	var/nsfw_headshot_link = read_preference(/datum/preference/text/nsfw_headshot_link)
	var/voice_type = read_preference(/datum/preference/choiced/voice_type)
	var/voice_color = read_preference(/datum/preference/color/voice_color)
	var/voice_pack = read_preference(/datum/preference/choiced/voice_pack)
	var/moan_selection = read_preference(/datum/preference/choiced/moan_selection)
	var/selected_accent = read_preference(/datum/preference/choiced/selected_accent)
	var/combat_music_type = read_preference(/datum/preference/choiced/combat_music)
	var/datum/combat_music/combat_music = GLOB.cmode_tracks_by_type[combat_music_type]
	var/song_link = read_preference(/datum/preference/text/song_link)
	var/song_title = read_preference(/datum/preference/text/song_title)
	var/song_artist = read_preference(/datum/preference/text/song_artist)
	var/toggles = read_preference(/datum/preference/bitwise/toggles)
	var/hotkeys = read_preference(/datum/preference/toggle/hotkeys)
	var/buttons_locked = read_preference(/datum/preference/toggle/buttons_locked)
	var/see_chat_non_mob = read_preference(/datum/preference/toggle/see_chat_non_mob)
	var/tgui_fancy = read_preference(/datum/preference/toggle/tgui_fancy)
	var/tgui_lock = read_preference(/datum/preference/toggle/tgui_lock)
	var/windowflashing = read_preference(/datum/preference/toggle/windowflashing)
	var/ambientocclusion = read_preference(/datum/preference/toggle/ambientocclusion)
	var/auto_fit_viewport = read_preference(/datum/preference/toggle/auto_fit_viewport)
	var/descriptor_color = read_preference(/datum/preference/toggle/descriptor_color)
	var/toggles_maptext = read_preference(/datum/preference/bitwise/toggles_maptext)
	var/pixel_size = read_preference(/datum/preference/numeric/pixel_size)
	var/scaling_method = read_preference(/datum/preference/choiced/scaling_method)

	var/datum/faith/selected_faith
	if(selected_patron)
		selected_faith = GLOB.faith_list[selected_patron.associated_faith]

	var/high_job = "None"
	for(var/job_type in job_preferences)
		if(job_preferences[job_type] != JP_HIGH)
			continue
		var/datum/job/high_job_datum = SSjob?.GetJob(job_type)
		high_job = high_job_datum ? get_selected_job_alt_value(high_job_datum, "title") : "[job_type]"
		break

	var/gender_name = "Other"
	var/gender_short = "X"
	switch(gender)
		if(MALE)
			gender_name = "Masculine"
			gender_short = "M"
		if(FEMALE)
			gender_name = "Feminine"
			gender_short = "F"
		if(PLURAL)
			gender_name = "Plural"
			gender_short = "P"

	var/patron_name = "None"
	if(selected_patron)
		patron_name = selected_patron.display_name ? selected_patron.display_name : selected_patron.name
	var/current_faith_type = selected_patron ? selected_patron.associated_faith : /datum/patron/divine/astrata::associated_faith

	var/heavy_sig = "[pref_species?.type]|[gender]|[selected_patron?.type]|[age]|[skin_tone]"
	if(!character_setup_ui_heavy_cache || character_setup_ui_heavy_sig != heavy_sig)
		var/list/heavy = list()

		var/list/selectable_ages = character_setup_selectable_ages()
		var/list/age_options = list()
		var/age_index = 1
		if(length(selectable_ages))
			var/current_index = 1
			for(var/possible_age in selectable_ages)
				age_options += "[possible_age]"
				if(possible_age == age)
					age_index = current_index
				current_index++
		else
			age_options += "[age || AGE_ADULT]"
		var/display_age = age
		if(length(selectable_ages) && !(display_age in selectable_ages))
			display_age = selectable_ages[1]
		var/list/age_tooltips = list()
		for(var/age_option in age_options)
			age_tooltips["[age_option]"] = character_setup_age_stat_tooltip(age_option)

		heavy["age_options"] = age_options
		heavy["age_index"] = age_index
		heavy["display_age"] = display_age
		heavy["age_tooltips"] = age_tooltips
		heavy["faith_options"] = character_setup_faith_options()
		heavy["ancestry_options"] = character_setup_ancestry_options()
		heavy["features"] = character_setup_build_features_data()
		character_setup_ui_heavy_cache = heavy
		character_setup_ui_heavy_sig = heavy_sig
	var/list/heavy_cache = character_setup_ui_heavy_cache
	var/list/age_options = heavy_cache["age_options"]
	var/age_index = heavy_cache["age_index"]
	var/display_age = heavy_cache["display_age"]
	var/list/age_tooltips = heavy_cache["age_tooltips"]

	data["real_name"] = real_name || "Unnamed"
	data["initial_tab"] = character_setup_preferences_initial_tab
	data["open_sequence"] = character_setup_preferences_open_sequence
	data["preferences_fullscreen"] = !!character_setup_preferences_fullscreen
	data["preferences_scale"] = character_setup_preferences_scale
	data["species_name"] = pref_species ? pref_species.name : "Human"
	data["species_id"] = pref_species ? pref_species.id : SPEC_ID_HUMEN
	data["is_taur"] = !!(pref_species?.forced_taur && LAZYLEN(pref_species.allowed_taur_types))
	var/obj/item/bodypart/taur/taur_body_type = taur_type
	data["taur_body"] = ispath(taur_body_type) ? taur_body_type::name : "None"
	data["taur_color"] = "#[taur_color]"
	data["taur_markings"] = "#[taur_markings]"
	data["taur_tertiary"] = "#[taur_tertiary]"
	var/list/mutant_colors = list()
	if(has_mutant_color_preferences())
		for(var/color_slot in 1 to 3)
			var/feature_key = get_mutant_color_feature_key(color_slot)
			if(!feature_key)
				continue
			mutant_colors += list(list(
				"slot" = color_slot,
				"color" = "#[pref_species.normalize_body_color(features[feature_key]) || "000000"]",
			))
	data["mutant_colors"] = mutant_colors
	data["use_skintones"] = !!pref_species?.use_skintones
	data["use_titles"] = !!pref_species?.use_titles
	data["race_title"] = selected_title || "None"
	data["gender"] = gender_name
	data["gender_short"] = gender_short
	var/body_build_id = get_body_build_id()
	var/datum/body_build/current_build = body_build_id ? GLOB.body_builds[body_build_id] : null
	data["body_build"] = body_build_id
	data["body_build_name"] = current_build?.name || "None"
	data["body_build_options"] = character_setup_body_build_options()
	data["default_slot"] = default_slot

	data["patron_name"] = patron_name
	data["faith_name"] = selected_faith ? selected_faith.name : "None"
	data["selected_patron_id"] = selected_patron ? "[selected_patron.type]" : ""
	data["selected_faith_id"] = current_faith_type ? "[current_faith_type]" : ""
	data["faith_options"] = heavy_cache["faith_options"]
	data["high_job"] = high_job
	data["age"] = display_age
	data["age_index"] = age_index
	data["age_min"] = 1
	data["age_max"] = max(1, length(age_options))
	data["age_options"] = age_options
	data["age_tooltips"] = age_tooltips
	data["pronouns"] = pronouns || "None"
	data["domhand"] = (domhand == 1) ? "Left" : "Right"
	data["ancestry_label"] = has_mutant_color_preferences() ? "Mutant Colors" : (pref_species?.skin_tone_wording || "Ancestry")
	data["ancestry_value"] = character_setup_current_ancestry_name()
	data["ancestry_options"] = heavy_cache["ancestry_options"]

	data["erp"] = character_setup_erp_data(user)
	data["preference_badges"] = preference_badges_ui_data()
	data["genital_set_label"] = get_current_genital_set_label()
	data["genital_extra_unlock"] = !!has_extra_genital_customizer_unlock()
	data["headshot"] = headshot_link || null
	data["nsfw_headshot"] = nsfw_headshot_link || null
	data["features"] = heavy_cache["features"]
	data["smallclothes"] = character_setup_smallclothes_data()
	data["preview_underwear"] = !!character_setup_preview_underwear
	data["preview_clothes"] = !!character_setup_preview_clothes
	data["preview_dir"] = character_setup_preview_dir
	data["background"] = character_setup_preview_background ? character_setup_preview_background : "none"
	data["preview_map"] = character_setup_view ? character_setup_view.assigned_map : null
	data["preview_map_front"] = character_setup_view_front ? character_setup_view_front.assigned_map : null
	data["preview_map_side"] = character_setup_view_side ? character_setup_view_side.assigned_map : null
	data["preview_bbox_w"] = character_setup_view_zoom_w
	data["preview_bbox_h"] = character_setup_view_zoom_h

	var/datum/culture/culture_datum = GLOB.culture_singletons[culture]
	data["culture_name"] = culture_datum?.name || "None"
	data["voice_type"] = voice_type || "Default"
	data["voice_color"] = voice_color ? "#[voice_color]" : "#a0a0a0"
	data["voice_pack"] = voice_pack || VOICE_PACK_DEFAULT
	data["speech_bark"] = read_preference(/datum/preference/choiced/speech_bark)
	data["speech_moans"] = !!read_preference(/datum/preference/toggle/speech_moans)
	data["moan_selection"] = moan_selection || MOANPACK_TYPE_DEF
	data["selected_accent"] = selected_accent || "None"

	data["loadout_slots"] = character_setup_loadout_slots_data()
	data["loadout_points"] = character_setup_loadout_points_data()
	data["loadout_presets"] = character_setup_loadout_presets_data()
	data["triumphs"] = user?.client ? user.get_triumphs() : 0

	var/combat_music_name = combat_music?.shortname ? combat_music.shortname : combat_music?.name
	data["combat_music"] = combat_music_name || "Default"
	data["defeat_mode"] = defeat_mode_display_name(get_defeat_mode())
	data["defeat_threshold"] = get_defeat_damage_threshold()
	data["song_set"] = !!song_link
	data["song_title"] = song_title || "No title set"
	data["song_artist"] = song_artist || "No artist set"

	var/mob/dead/new_player/new_player
	if(istype(user, /mob/dead/new_player))
		new_player = user
	if(new_player && SSticker && SSticker.current_state <= GAME_STATE_PREGAME)
		var/ready_count = 0
		for(var/mob/dead/new_player/lobby_player as anything in GLOB.new_player_list)
			if(lobby_player.ready == PLAYER_READY_TO_PLAY)
				ready_count++
		data["round_ready_players"] = ready_count
		data["round_total_players"] = length(GLOB.new_player_list)
	data["round_action_label"] = "Unavailable"
	data["round_action_icon"] = "ban"
	data["round_action_color"] = null
	data["round_action_disabled"] = TRUE
	data["round_action_tooltip"] = "This action is only available in the lobby."
	if(SSticker && new_player)
		if(SSticker.IsRoundInProgress())
			data["round_action_label"] = "Join Now"
			data["round_action_icon"] = "sign-in-alt"
			data["round_action_color"] = "green"
			data["round_action_disabled"] = FALSE
			data["round_action_tooltip"] = "Open late join choices."
		else if(SSticker.current_state <= GAME_STATE_PREGAME)
			if(new_player.ready == PLAYER_READY_TO_PLAY)
				data["round_action_label"] = "Cancel Ready"
				data["round_action_icon"] = "times"
				data["round_action_color"] = "bad"
				data["round_action_disabled"] = !!SSticker.job_change_locked
				data["round_action_tooltip"] = "Cancel roundstart readiness."
			else
				data["round_action_label"] = "Ready"
				data["round_action_icon"] = "user-check"
				data["round_action_color"] = "green"
				data["round_action_disabled"] = FALSE
				data["round_action_tooltip"] = "Ready this character for roundstart."
		else if(SSticker.current_state == GAME_STATE_SETTING_UP)
			data["round_action_label"] = "Setting Up"
			data["round_action_icon"] = "hourglass-half"
			data["round_action_tooltip"] = "The game is starting."
		else
			data["round_action_label"] = "Round Finished"
			data["round_action_icon"] = "flag-checkered"
			data["round_action_tooltip"] = "The round has already finished."

	data["game_prefs"] = list(
		"hotkeys" = !!hotkeys,
		"buttons_locked" = !!buttons_locked,
		"see_chat_non_mob" = !!see_chat_non_mob,
		"tgui_fancy" = !!tgui_fancy,
		"tgui_lock" = !!tgui_lock,
		"windowflashing" = !!windowflashing,
		"lobby_music" = !!(toggles & SOUND_LOBBY),
		"hear_midis" = !!(toggles & SOUND_MIDI),
		"hear_speech_barks" = !!read_preference(/datum/preference/toggle/hear_speech_barks),
		"ambientocclusion" = !!ambientocclusion,
		"auto_fit_viewport" = !!auto_fit_viewport,
		"descriptor_color" = !!descriptor_color,
		"allow_midround_antag" = !!(toggles & MIDROUND_ANTAG),
		"ambience" = !!(toggles & SOUND_AMBIENCE),
		"background_music" = !!(toggles & SOUND_SHIP_AMBIENCE),
		"be_voice" = !!(toggles & SCHIZO_VOICE),
		"balloon_alerts" = !(toggles_maptext & DISABLE_BALLOON_ALERTS),
		"runechat" = !(toggles_maptext & DISABLE_RUNECHAT),
		"pixel_size" = "[pixel_size]",
		"scaling_method" = "[scaling_method]",
	)
	var/list/job_data = character_setup_job_data(user)
	for(var/key in job_data)
		data[key] = job_data[key]

	return data

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	var/window_width = character_setup_preferences_fullscreen ? 7680 : 1360
	var/window_height = character_setup_preferences_fullscreen ? 4320 : 800
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterCreator", "Character Creator", window_width, window_height)
		ui.set_autoupdate(FALSE)
		ui.open()
	character_setup_ensure_view(user, ui)

/datum/preferences/ui_close(mob/user)
	. = ..()
	var/remaining = 0
	for(var/datum/tgui/open_ui in open_uis)
		if(open_ui.user == user)
			remaining++
	if(remaining > 1)
		character_setup_log("VIEW", "ui_close keep view, other windows remain=[remaining - 1]")
		return
	character_setup_teardown_view(user)

// ---- Actions ----

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui?.user || usr
	if(!user)
		return FALSE
	if(!character_setup_action_allowed(user, action, params))
		return FALSE

	switch(action)
		if("pref_badge")
			return handle_preference_badge_action(user, params)

		if("pref")
			if(!islist(params) || !params["preference"])
				return FALSE

			var/list/href_list = list()
			for(var/key in params)
				href_list[key] = params[key]

			if(href_list["preference"] == "tab")
				current_tab = text2num("[href_list["tab"]]")
				return TRUE

			var/handled = process_link(user, href_list)
			if(href_list["preference"] == "finished")
				ui?.close(FALSE)
			// Hovers and geometry reports only change the doll, whose new bounds queue their own push.
			if(href_list["preference"] == "character_setup_hover" || href_list["preference"] == "character_setup_report_geometry")
				return FALSE
			return handled || TRUE

		if("set_age")
			if(!islist(params))
				return FALSE

			var/new_age = params["value"]
			if(!isnum(new_age))
				new_age = text2num("[new_age]")
			if(!isnum(new_age))
				return FALSE

			var/list/selectable_ages = character_setup_selectable_ages()
			if(!length(selectable_ages))
				return FALSE

			var/age_index = clamp(round(new_age), 1, length(selectable_ages))
			var/selected_age = selectable_ages[age_index]
			if(read_preference(/datum/preference/choiced/age) != selected_age)
				write_preference(/datum/preference/choiced/age, selected_age)
				reset_jobs(user)
				update_menu_data(user)
			return TRUE

		if("job_set_pref_level")
			if(SSticker?.job_change_locked)
				return FALSE
			var/datum/job/level_job = SSjob?.GetJob(params["job"])
			if(!job_is_available(level_job, user))
				return FALSE
			var/new_level = params["level"]
			if(isnull(new_level))
				job_preferences -= level_job.title
			else
				if(!isnum(new_level))
					new_level = text2num("[new_level]")
				if(!(new_level in list(JP_LOW, JP_MEDIUM, JP_HIGH)))
					return FALSE
				set_job_preference_level(level_job, new_level)
			update_menu_data(user)
			return TRUE

		if("job_set_alt")
			if(SSticker?.job_change_locked)
				return FALSE
			var/datum/job/alt_job = SSjob?.GetJob(params["job"])
			if(!job_is_available(alt_job, user))
				return FALSE
			if(!set_job_alt_preference(alt_job, params["category"], params["value"]))
				return FALSE
			update_menu_data(user)
			return TRUE

		if("job_explain")
			var/datum/job/explain_job = SSjob?.GetJob(params["job"])
			if(!explain_job?.class_setup_examine)
				return FALSE
			explain_job.show_explain(user)
			return FALSE

		if("job_toggle_unavailable")
			if(SSticker?.job_change_locked)
				return FALSE
			switch(read_preference(/datum/preference/choiced/joblessrole))
				if(RETURNTOLOBBY)
					write_preference(/datum/preference/choiced/joblessrole, BERANDOMJOB)
				if(BERANDOMJOB)
					write_preference(/datum/preference/choiced/joblessrole, RETURNTOLOBBY)
			update_menu_data(user)
			return TRUE

		if("job_reset_priorities")
			if(SSticker?.job_change_locked)
				return FALSE
			reset_jobs(user, TRUE)
			update_menu_data(user)
			return TRUE

		if("job_play_last_class")
			if(SSticker?.job_change_locked)
				return FALSE
			reset_last_class(user)
			update_menu_data(user)
			return TRUE

	return FALSE

// ---- Hooks ----

/// Allows temporary Preferences subtypes to reject actions before the legacy
/// process_link() bridge sees them. Ordinary character setup remains open.
/datum/preferences/proc/character_setup_action_allowed(mob/user, action, list/params)
	return TRUE

/// Close the setup menu when the lobby mob turns into a real character.
/mob/dead/new_player/transfer_character()
	if(new_character && client?.prefs)
		SStgui.close_uis(client.prefs)
	return ..()
