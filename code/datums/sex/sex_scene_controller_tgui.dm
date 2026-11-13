/// Scene-facing TGUI data and actions for one actor's controller.

/datum/sex_scene_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SexScene", "Sate Desire", 760, 520)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/sex_scene_controller/ui_state(mob/user)
	// Runtime actions do their own distance/consciousness checks;
	// the window must stay usable while lying down or grabbed.
	return GLOB.always_state

/datum/sex_scene_controller/ui_data(mob/viewer)
	var/list/data = list()
	sync_ui_selected_participant()
	data["target_name"] = target?.name
	data["is_self"] = (user == target)
	data["scene_name"] = scene?.display_name
	data["scene_participants"] = get_scene_participants_ui_data()
	data["scene_connections"] = get_scene_connections_ui_data()
	data["scene_claims"] = get_scene_claims_ui_data()

	var/list/status_lines = list()
	for(var/line in user.return_character_information(status_follows_examine()))
		if(line)
			status_lines += line
	data["status_lines"] = status_lines

	data["arousal"] = get_arousal_ui_data()
	data["controls"] = list(
		"speed" = speed,
		"force" = force,
		"resist" = resistance_to_pleasure,
		"manual_arousal" = manual_arousal,
		"has_penis" = !!user.getorganslot(ORGAN_SLOT_PENIS),
		"do_until_finished" = do_until_finished,
		"edging_other" = edging_other,
		"finish_outside" = finish_outside,
		"can_leg_lock" = user.body_position == LYING_DOWN && length(user.get_hole_penetrators()) > 0,
		"leg_lock" = leg_lock,
		"lying_direction" = user.get_lying_direction_name(),
		"cmode" = !!user.cmode,
		"auto_clench" = !!user.wants_auto_clench(),
		"can_hold_it_in" = user.can_hold_fluids_in(),
		"hold_it_in" = user.is_holding_fluids_in(),
		"reach_under_armor" = user.get_cached_erp_pref(/datum/erp_preference/boolean/allow_reach_under_armor) == TRUE,
		"status_follows_examine" = status_follows_examine(),
	)
	data["zone_options"] = get_zone_options_ui_data()
	data["actions"] = get_actions_ui_data()
	data["scene_patterns"] = get_scene_patterns_ui_data()
	data["bellyriding"] = get_bellyriding_ui_data()
	data["custom"] = get_custom_actions_ui_data()
	data["intimacy"] = get_intimacy_ui_data()
	data["notes"] = get_notes_ui_data()
	return data

/datum/sex_scene_controller/proc/sync_ui_selected_participant()
	if(!scene || QDELETED(scene))
		return FALSE
	if(!ui_selected_participant || QDELETED(ui_selected_participant) || !(ui_selected_participant in scene.participants))
		ui_selected_participant = target
	if(ui_selected_participant != target)
		return set_target(ui_selected_participant)
	return TRUE

/datum/sex_scene_controller/proc/select_ui_participant(participant_ref)
	if(!scene || QDELETED(scene))
		return FALSE
	var/mob/living/selected_participant
	for(var/mob/living/participant as anything in scene.participants)
		if(REF(participant) == participant_ref)
			selected_participant = participant
			break
	if(!selected_participant)
		return FALSE

	if(!set_target(selected_participant))
		return FALSE
	SStgui.update_uis(src)
	return TRUE

/datum/sex_scene_controller/proc/get_scene_participants_ui_data()
	var/list/participants_out = list()
	var/examine_rule = status_follows_examine()
	for(var/mob/living/participant as anything in scene?.participants)
		if(!participant || QDELETED(participant))
			continue
		var/list/status_lines = list()
		for(var/line in participant.return_character_information(examine_rule))
			if(line)
				status_lines += line
		participants_out += list(list(
			"ref" = REF(participant),
			"name" = participant.name,
			"is_self" = (participant == user),
			"selected" = (participant == ui_selected_participant),
			"action_count" = length(scene.get_actions_involving(participant)),
			"status_lines" = status_lines,
		))
	return participants_out

/datum/sex_scene_controller/proc/get_scene_connections_ui_data()
	var/list/connections_out = list()
	for(var/datum/sex_action/action as anything in scene?.active_actions)
		if(!action || QDELETED(action))
			continue
		connections_out += list(list(
			"ref" = REF(action),
			"name" = action.name,
			"actor_name" = action.action_user?.name,
			"target_name" = action.action_target?.name,
			"speed" = action.speed,
			"force" = action.force,
			"can_stop" = (action.action_user == user),
		))
	return connections_out

/datum/sex_scene_controller/proc/get_scene_claims_ui_data()
	var/list/claims_out = list()
	for(var/datum/sex_scene_resource_claim/claim as anything in scene?.resource_claims)
		if(!claim || QDELETED(claim))
			continue
		var/resource_name = claim.locked_item?.name || claim.locked_organ_slot || "resource"
		claims_out += list(list(
			"action_name" = claim.owner?.name,
			"host_name" = claim.locked_host?.name,
			"resource_name" = resource_name,
			"hard" = claim.hard_lock,
		))
	return claims_out

/datum/sex_scene_controller/proc/get_arousal_ui_data()
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/current_arousal = arousal_data["arousal"] || 0
	var/orgasm_progress = arousal_data["orgasm_progress"] || 0
	return list(
		"arousal_pct" = min(100, (current_arousal / MAX_AROUSAL) * 100),
		"orgasm_pct" = min(100, (orgasm_progress / PASSIVE_EJAC_THRESHOLD) * 100),
		"pain_pct" = 0,
	)

/datum/sex_scene_controller/proc/get_zone_options_ui_data()
	var/list/options = list()
	for(var/filter_label in action_zone_filter_options)
		options += list(list(
			"name" = filter_label,
			"value" = action_zone_filter_options[filter_label],
		))
	return options

/datum/sex_scene_controller/proc/get_actions_ui_data()
	var/list/actions_out = list()
	for(var/datum/sex_action/action as anything in get_active_actions())
		actions_out += list(list(
			"key" = action.get_menu_action_key(),
			"name" = action.name,
			"active" = TRUE,
			"can_perform" = TRUE,
			"user_zones" = action.user_menu_zone_mask,
			"target_zones" = action.target_menu_zone_mask,
			"fit_hint" = target ? action.get_orifice_fit_hint(user, target) : null,
			"category" = action.menu_category,
			"tip" = action.menu_tip,
		))
	for(var/datum/sex_action/action_template as anything in get_all_menu_actions())
		if(is_action_active(action_template))
			continue
		var/datum/sex_action_proposal/proposal = create_action_proposal(action_template, "player")
		var/datum/sex_action/action = proposal?.action
		if(!action || !action.shows_on_menu(user, target))
			qdel(proposal)
			continue
		var/can_start = proposal?.can_start()
		actions_out += list(list(
			"key" = action.get_menu_action_key(),
			"name" = action.name,
			"active" = FALSE,
			"can_perform" = can_start,
			"refusal" = can_start ? null : action.armor_refusal,
			"user_zones" = action.user_menu_zone_mask,
			"target_zones" = action.target_menu_zone_mask,
			"fit_hint" = target ? action.get_orifice_fit_hint(user, target) : null,
			"category" = action.menu_category,
			"tip" = action.menu_tip,
		))
		qdel(proposal)
	return actions_out

/datum/sex_scene_controller/proc/get_scene_patterns_ui_data()
	var/list/patterns_out = list()
	for(var/datum/sex_scene_pattern_match/pattern_match as anything in scene?.get_pattern_matches(null, user))
		patterns_out += list(list(
			"key" = pattern_match.match_key,
			"id" = pattern_match.pattern_id,
			"name" = pattern_match.display_name,
			"focus_name" = pattern_match.focus?.name,
			"is_focus" = (pattern_match.focus == user),
		))
	return patterns_out

/datum/sex_scene_controller/proc/get_bellyriding_ui_data()
	var/datum/component/bellyriding/belly_comp = get_bellyriding_component()
	if(!belly_comp)
		return null
	var/static/list/bellyriding_action_types = list(
		/datum/sex_action/bellyriding/groin_rub,
		/datum/sex_action/bellyriding/frot,
		/datum/sex_action/bellyriding/vaginal,
		/datum/sex_action/bellyriding/anal,
	)
	var/list/actions_out = list()
	for(var/action_type in bellyriding_action_types)
		var/datum/sex_action/action = SEX_ACTION(action_type)
		if(!action)
			continue
		var/datum/sex_action_proposal/proposal = create_action_proposal(action, "player")
		var/can_start = proposal?.can_start()
		qdel(proposal)
		actions_out += list(list(
			"key" = "[action_type]",
			"name" = action.name,
			"selected" = (belly_comp.selected_action_type == action_type),
			"can_perform" = can_start,
		))
	return list(
		"enabled" = belly_comp.enable_interactions,
		"actions" = actions_out,
	)

/datum/sex_scene_controller/proc/get_intimacy_ui_data()
	var/list/out = list(
		"lock_reason" = null,
		"yours" = list(),
		"theirs" = list(),
		"their_kinks" = list(),
	)
	var/list/your_erp_data
	var/datum/preferences/your_prefs = user?.client?.prefs
	if(your_prefs)
		your_erp_data = your_prefs.character_setup_erp_data(user)
		out["yours"] = your_erp_data["categories"]
		out["lock_reason"] = your_erp_data["lock_reason"]
		out["your_kinks"] = your_erp_data["kink_categories"]

	var/list/their_erp_data = your_erp_data
	if(target != user)
		their_erp_data = null
		var/datum/preferences/their_prefs = target?.client?.prefs
		if(their_prefs)
			their_erp_data = their_prefs.character_setup_erp_data(target)
			out["theirs"] = their_erp_data["categories"]

	if(their_erp_data)
		var/list/categories_out = list()
		for(var/list/category in their_erp_data["kink_categories"])
			var/list/kinks_out = list()
			for(var/list/kink in category["kinks"])
				if(!kink["enabled"])
					continue
				kinks_out += list(kink)
			if(length(kinks_out))
				categories_out += list(list("name" = category["name"], "kinks" = kinks_out))
		out["their_kinks"] = categories_out
	return out

/// Flips the user's armor reach consent and writes it to the character.
/datum/sex_scene_controller/proc/toggle_reach_under_armor()
	var/allowed = flip_panel_pref(/datum/erp_preference/boolean/allow_reach_under_armor)
	if(isnull(allowed))
		return FALSE
	var/message = allowed ? "Players may now reach under my armor." : "My armor keeps everyone out again."
	to_chat(user, span_notice(message))
	return TRUE

/// Flips a boolean ERP pref of the user and writes it to the character; the new value, or null without prefs.
/datum/sex_scene_controller/proc/flip_panel_pref(pref_type)
	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs)
		return null
	var/datum/erp_preference/pref = new pref_type()
	var/value = !pref.get_value(prefs)
	pref.set_value(prefs, value)
	prefs.save_erp_preferences()
	return value

/// TRUE unless the viewing user switched the status lines to the older coverage rule.
/datum/sex_scene_controller/proc/status_follows_examine()
	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs)
		return TRUE
	var/datum/erp_preference/pref = new /datum/erp_preference/boolean/panel_status_follows_examine()
	return pref.get_value(prefs) != FALSE

/// Applies the Kinks tab draft to the user's prefs, writes the slot's ERP block and refreshes the cache.
/datum/sex_scene_controller/proc/save_own_kinks(list/changes)
	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs || !islist(changes) || length(changes) > length(GLOB.available_kinks))
		return FALSE
	var/lock_reason = prefs.get_erp_preference_edit_lock_reason(user)
	if(lock_reason)
		to_chat(user, span_warning(lock_reason))
		return TRUE
	var/changed = FALSE
	for(var/list/change in changes)
		if(prefs.set_kink_preference(change["name"], change["enabled"], change["intensity"], change["notes"]))
			changed = TRUE
	if(!changed)
		return TRUE
	prefs.mark_erp_preferences_dirty()
	if(prefs.save_erp_preferences())
		to_chat(user, span_notice("My kinks are saved."))
	else
		to_chat(user, span_warning("My kinks changed, but could not be saved to the character."))
	return TRUE

/datum/sex_scene_controller/proc/get_notes_ui_data()
	var/list/yours_out = list()
	var/list/theirs_out = list()
	if(user?.ckey && target?.ckey)
		var/list/partner_notes = get_player_notes_about(user.ckey, target.ckey, get_character_slot(user))
		for(var/note_title in partner_notes)
			yours_out += list(build_note_ui_entry(note_title, partner_notes[note_title]))
	if(target != user && target?.ckey)
		var/list/target_self_notes = get_player_notes_about(target.ckey, target.ckey, get_character_slot(target))
		for(var/note_title in target_self_notes)
			theirs_out += list(build_note_ui_entry(note_title, target_self_notes[note_title]))
	return list("yours" = yours_out, "theirs" = theirs_out)

/datum/sex_scene_controller/proc/build_note_ui_entry(note_title, list/note_data)
	var/created_time = note_data["created"]
	var/modified_time = note_data["last_modified"]
	var/meta = "Created: [time2text(created_time, "MM/DD/YY hh:mm")]"
	if(modified_time != created_time)
		meta += " | Modified: [time2text(modified_time, "MM/DD/YY hh:mm")]"
	return list(
		"title" = note_title,
		"content" = note_data["content"],
		"meta" = meta,
	)

/datum/sex_scene_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(ui.user != user)
		return FALSE

	if(action == "select_participant")
		return select_ui_participant("[params["ref"]]")

	if(action == "view_holes")
		var/mob/living/carbon/human/human_user = user
		if(istype(human_user))
			human_user.view_holes()
		return TRUE

	if(!sync_ui_selected_participant())
		return FALSE

	switch(action)
		if("action")
			if(!get_action_template(params["key"]))
				return FALSE
			try_start_action(params["key"])
			return TRUE
		if("stop")
			try_stop_action(params["key"])
			return TRUE
		if("stop_scene_action")
			for(var/datum/sex_action/scene_action as anything in scene?.active_actions)
				if(REF(scene_action) != "[params["ref"]]" || scene_action.action_user != user)
					continue
				scene?.stop_action(scene_action)
				return TRUE
			return FALSE
		if("set_speed")
			var/value = text2num("[params["value"]]")
			if(isnull(value) || value < SEX_SPEED_MIN || value > SEX_SPEED_MAX)
				return FALSE
			set_current_speed(value)
			return TRUE
		if("set_force")
			var/value = text2num("[params["value"]]")
			if(isnull(value) || value < SEX_FORCE_MIN || value > SEX_FORCE_MAX)
				return FALSE
			set_current_force(value)
			return TRUE
		if("set_resist")
			var/value = text2num("[params["value"]]")
			if(isnull(value) || value < RESIST_NONE || value > RESIST_HIGH)
				return FALSE
			set_current_resist(value)
			return TRUE
		if("set_manual_arousal")
			var/value = text2num("[params["value"]]")
			if(isnull(value) || value < SEX_MANUAL_AROUSAL_MIN || value > SEX_MANUAL_AROUSAL_MAX)
				return FALSE
			manual_arousal = value
			SEND_SIGNAL(user, COMSIG_SET_ERECT_STATE, manual_arousal > 2)
			return TRUE
		if("toggle_finished")
			set_stop_on_climax(!do_until_finished)
			return TRUE
		if("toggle_edging")
			edging_other = !edging_other
			return TRUE
		if("toggle_finish_outside")
			finish_outside = !finish_outside
			return TRUE
		if("toggle_leg_lock")
			toggle_leg_lock()
			return TRUE
		if("toggle_auto_clench")
			user.auto_clench_override = !user.wants_auto_clench()
			return TRUE
		if("toggle_hold_it_in")
			user.toggle_holding_fluids_in()
			return TRUE
		if("toggle_reach_under_armor")
			return toggle_reach_under_armor()
		if("toggle_status_follows_examine")
			return !isnull(flip_panel_pref(/datum/erp_preference/boolean/panel_status_follows_examine))
		if("swap_side")
			user.swap_lying_direction()
			return TRUE
		if("bellyriding_toggle")
			var/datum/component/bellyriding/belly_comp = get_bellyriding_component()
			if(!belly_comp)
				return FALSE
			belly_comp.enable_interactions = !belly_comp.enable_interactions
			return TRUE
		if("bellyriding_release")
			var/datum/component/bellyriding/belly_comp = get_bellyriding_component()
			if(!belly_comp)
				return FALSE
			belly_comp.unbuckle_victim()
			return TRUE
		if("bellyriding_action")
			var/datum/component/bellyriding/belly_comp = get_bellyriding_component()
			var/datum/sex_action/belly_action = get_action_template(params["key"])
			if(!belly_comp || !belly_action || !ispath(belly_action.type, /datum/sex_action/bellyriding))
				return FALSE
			belly_comp.set_selected_action(belly_action.type, user)
			INVOKE_ASYNC(belly_comp, TYPE_PROC_REF(/datum/component/bellyriding, maybe_do_interaction))
			return TRUE
		if("bellyriding_clear")
			var/datum/component/bellyriding/belly_comp = get_bellyriding_component()
			if(!belly_comp)
				return FALSE
			belly_comp.set_selected_action(null, user)
			return TRUE
		if("erp_pref")
			var/datum/preferences/prefs = user.client?.prefs
			if(!prefs)
				return FALSE
			// handle_erp_pref_topic reads href-style text values; tgui sends
			// JSON numbers, so stringify every param (text2num(number) runtimes).
			var/list/href_list = list()
			for(var/key in params)
				href_list[key] = "[params[key]]"
			var/revision = prefs.erp_preferences_revision
			prefs.handle_erp_pref_topic(user, href_list)
			// An accepted edit bumps the revision; write it to the character, as the Kinks tab's Save does.
			if(prefs.erp_preferences_revision != revision)
				prefs.save_erp_preferences()
			return TRUE
		if("save_kinks")
			return save_own_kinks(params["changes"])
		if("note_add")
			var/note_title = trim("[params["title"]]")
			var/note_content = trim("[params["content"]]")
			if(!length(note_title) || !length(note_content))
				to_chat(user, span_warning("Both title and content are required."))
				return TRUE
			note_title = copytext(note_title, 1, 129)
			var/character_slot = get_character_slot(user)
			if(!target?.ckey)
				return FALSE
			var/list/existing_notes = get_player_notes_about(user.ckey, target.ckey, character_slot)
			if(existing_notes[note_title])
				to_chat(user, span_warning("A note with that title already exists. Please choose a different title."))
				return TRUE
			if(set_player_note_about(user.ckey, target.ckey, note_title, note_content, character_slot))
				to_chat(user, span_notice("Note '[note_title]' saved."))
			else
				to_chat(user, span_warning("Failed to save note."))
			return TRUE
		if("note_edit")
			var/note_title = "[params["title"]]"
			var/note_content = trim("[params["content"]]")
			if(!length(note_title) || !length(note_content))
				return FALSE
			var/character_slot = get_character_slot(user)
			if(!target?.ckey)
				return FALSE
			var/list/notes = get_player_notes_about(user.ckey, target.ckey, character_slot)
			if(!notes[note_title])
				to_chat(user, span_warning("Note not found."))
				return TRUE
			set_player_note_about(user.ckey, target.ckey, note_title, note_content, character_slot)
			return TRUE
		if("note_remove")
			var/note_title = "[params["title"]]"
			if(!length(note_title))
				return FALSE
			var/character_slot = get_character_slot(user)
			var/datum/save_manager/note_save_manager = get_save_manager(user.ckey)
			if(!note_save_manager)
				return FALSE
			var/save_name = "character_[character_slot]_notes"
			var/list/all_notes = note_save_manager.get_data(save_name, "partner_notes", list())
			if(!target?.ckey)
				return FALSE
			var/list/own_notes = all_notes[ckey(target.ckey)]
			if(!islist(own_notes) || !own_notes[note_title])
				to_chat(user, span_warning("Note not found."))
				return TRUE
			own_notes -= note_title
			note_save_manager.set_data(save_name, "partner_notes", all_notes)
			return TRUE
		if("custom_select_template")
			return load_custom_action_draft_from_template("[params["id"]]")
		if("custom_select_saved")
			return load_custom_action_draft_from_saved("[params["id"]]")
		if("custom_field")
			return set_custom_action_field("[params["field"]]", params["value"])
		if("custom_save")
			if(!save_custom_action_draft())
				to_chat(user, span_warning("Failed to save the custom action."))
			return TRUE
		if("custom_reset")
			return reset_custom_action_draft()
		if("custom_delete")
			// Deletion is confirmed client-side via Button.Confirm.
			if(!delete_custom_action("[params["id"]]"))
				to_chat(user, span_warning("Failed to find that custom action."))
			return TRUE

	return FALSE
