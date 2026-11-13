// Created-disguise wardrobe and its isolated, non-saving Preferences sandbox.

/datum/antagonist/succubus
	/// Fixed numbered slots. Higher-tier entries remain stored when favor falls.
	var/list/created_forms = list(
		null,
		null,
		null,
		null,
	)
	/// The sole live draft editor. The editor only keeps a weak link back.
	var/datum/preferences/succubus_disguise/active_disguise_editor

/datum/antagonist/succubus/proc/get_created_disguise_slot_cap()
	return min(get_succubus_contract_tier(), SUCCUBUS_CREATED_DISGUISE_MAX_SLOTS)

/datum/antagonist/succubus/proc/get_created_disguise_form_key(slot)
	if(slot < 1 || slot > SUCCUBUS_CREATED_DISGUISE_MAX_SLOTS)
		return null
	return "[SUCCUBUS_FORM_KEY_CREATED_PREFIX][slot]"

/// Resolves an opaque wardrobe key. Locked created slots are inaccessible unless
/// a lifecycle caller explicitly asks to inspect their retained snapshots.
/datum/antagonist/succubus/proc/get_disguise_snapshot(form_key, include_locked = FALSE)
	if(form_key == SUCCUBUS_FORM_KEY_STARTING)
		return starting_form
	if(istype(form_key, /datum/mind))
		return stolen_forms[form_key]

	var/created_slot_cap = include_locked ? SUCCUBUS_CREATED_DISGUISE_MAX_SLOTS : get_created_disguise_slot_cap()
	for(var/slot in 1 to created_slot_cap)
		if(form_key == get_created_disguise_form_key(slot))
			return created_forms[slot]
	return null

/// Builds unique player-facing labels backed by opaque keys. Display names are
/// never used to resolve the selected identity.
/datum/antagonist/succubus/proc/get_wearable_disguise_choices()
	var/list/disguise_choices = list()
	if(starting_form)
		disguise_choices["\[Starting\] [starting_form.real_name || "Unknown"]"] = SUCCUBUS_FORM_KEY_STARTING

	for(var/slot in 1 to get_created_disguise_slot_cap())
		var/datum/identity_snapshot/created_form = created_forms[slot]
		if(created_form)
			disguise_choices["\[Created [slot]\] [created_form.real_name || "Unknown"]"] = get_created_disguise_form_key(slot)

	for(var/datum/mind/stored_mind as anything in stolen_forms)
		var/datum/identity_snapshot/harvested_form = stolen_forms[stored_mind]
		var/base_label = "\[Harvested\] [harvested_form?.real_name || "Unknown"]"
		var/display_label = base_label
		var/suffix = 2
		while(display_label in disguise_choices)
			display_label = "[base_label] ([suffix])"
			suffix++
		disguise_choices[display_label] = stored_mind
	return disguise_choices

/// Creates a disposable editing baseline without ever replacing client.prefs.
/datum/antagonist/succubus/proc/create_disguise_editor(client/editor_client, slot)
	if(!editor_client || slot < 1 || slot > get_created_disguise_slot_cap())
		return null
	QDEL_NULL(active_disguise_editor)
	active_disguise_editor = new(editor_client, owner, slot)
	return active_disguise_editor

/datum/antagonist/succubus/proc/open_disguise_editor(mob/living/carbon/human/user)
	if(!istype(user) || user != owner?.current || user.stat != CONSCIOUS || !user.client)
		return FALSE
	if(active_disguise_editor?.get_editor_body(user))
		active_disguise_editor.ui_interact(user)
		return TRUE

	var/initial_slot = 1
	for(var/slot in 1 to get_created_disguise_slot_cap())
		if(!created_forms[slot])
			initial_slot = slot
			break
	var/datum/preferences/succubus_disguise/editor = create_disguise_editor(user.client, initial_slot)
	if(!editor)
		return FALSE
	editor.ui_interact(user)
	return TRUE

/// Final authoritative wardrobe swap. Failures leave both the offered snapshot
/// and the antagonist's essence/old slot untouched.
/datum/antagonist/succubus/proc/commit_created_disguise(slot, datum/identity_snapshot/new_form, creation_cost)
	if(!new_form?.dna || slot < 1 || slot > get_created_disguise_slot_cap())
		return FALSE
	if(current_form_key == get_created_disguise_form_key(slot))
		return FALSE
	if(creation_cost < 0 || essence < creation_cost)
		return FALSE

	var/datum/identity_snapshot/old_form = created_forms[slot]
	adjust_essence(-creation_cost)
	created_forms[slot] = new_form
	if(old_form)
		qdel(old_form)
	return TRUE

/datum/action/cooldown/spell/undirected/succubus_create_disguise
	name = "Create Disguise"
	desc = "Shape and bind a new mortal identity into my wardrobe."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = 0

/datum/action/cooldown/spell/undirected/succubus_create_disguise/cast(mob/living/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	var/mob/living/carbon/human/human_user = cast_on
	if(!succubus_antag || !istype(human_user))
		return
	if(!succubus_antag.open_disguise_editor(human_user))
		to_chat(owner, span_warning("I cannot hold the looking glass steady right now."))

/// Temporary character Preferences used only to render and edit a disguise.
/datum/preferences/succubus_disguise
	var/datum/weakref/owner_mind_ref
	var/selected_slot = 1

/datum/preferences/succubus_disguise/New(client/editor_client, datum/mind/succubus_mind, slot)
	. = ..(editor_client)
	if(succubus_mind)
		owner_mind_ref = WEAKREF(succubus_mind)
	selected_slot = clamp(round(slot || 1), 1, SUCCUBUS_CREATED_DISGUISE_MAX_SLOTS)
	character_setup_preferences_initial_tab = "identity"
	character_setup_preview_underwear = FALSE
	character_setup_preview_clothes = FALSE
	character_setup_preview_background = null

/datum/preferences/succubus_disguise/Destroy()
	var/datum/mind/succubus_mind = owner_mind_ref?.resolve()
	var/datum/antagonist/succubus/succubus_antag = succubus_mind?.has_antag_datum(/datum/antagonist/succubus)
	if(succubus_antag?.active_disguise_editor == src)
		succubus_antag.active_disguise_editor = null
	owner_mind_ref = null
	return ..()

/// The constructor and inherited appearance handlers may call either save
/// proc. Both deliberately stop here rather than touching the player's file.
/datum/preferences/succubus_disguise/save_preferences()
	return FALSE

/datum/preferences/succubus_disguise/save_character()
	return FALSE

/datum/preferences/succubus_disguise/proc/get_succubus_antag()
	var/datum/mind/succubus_mind = owner_mind_ref?.resolve()
	if(!succubus_mind)
		return null
	var/datum/antagonist/succubus/succubus_antag = succubus_mind.has_antag_datum(/datum/antagonist/succubus)
	if(succubus_antag?.active_disguise_editor != src)
		return null
	return succubus_antag

/datum/preferences/succubus_disguise/proc/get_editor_body(mob/user)
	var/datum/antagonist/succubus/succubus_antag = get_succubus_antag()
	var/mob/living/carbon/human/body = succubus_antag?.owner?.current
	if(!istype(body) || body.stat != CONSCIOUS || !body.client)
		return null
	if(user && user != body)
		return null
	if(parent != body.client)
		return null
	return body

/datum/preferences/succubus_disguise/proc/is_allowed_species(species_id)
	if(!species_id || !(species_id in GLOB.roundstart_species))
		return FALSE
	var/species_type = GLOB.species_list[species_id]
	if(!species_type || ispath(species_type, /datum/species/demon))
		return FALSE
	var/datum/species/candidate = new species_type()
	var/allowed = candidate.preference_accessible(src)
	qdel(candidate)
	return allowed

/datum/preferences/succubus_disguise/proc/is_allowed_customizer_action(list/params)
	var/customizer_type = text2path(params["customizer"])
	if(!pref_species || !customizer_type || !(customizer_type in pref_species.customizers))
		return FALSE
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry?.customizer_choice_type)
	if(!customizer || !entry || !choice)
		return FALSE

	var/customizer_task = params["customizer_task"]
	switch(customizer_task)
		if("toggle_missing")
			return customizer.allows_disabling
		if("select_acc")
			var/accessory_type = text2path(params["acc_type"])
			return accessory_type in choice.character_setup_accessory_types(src)
		if("acc_color")
			var/color_index = text2num("[params["color_index"]]")
			var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
			return accessory && choice.allows_accessory_color_customization && color_index >= 1 && color_index <= accessory.color_keys
		if("reset_colors")
			return choice.allows_accessory_color_customization

	for(var/list/extra as anything in choice.character_setup_tgui_extras(src, entry))
		if(extra["task"] == customizer_task)
			return TRUE
	return FALSE

/datum/preferences/succubus_disguise/proc/is_allowed_choice_action(list/params)
	var/customizer_type = text2path(params["key"])
	var/choice_type = text2path(params["choice_type"])
	if(!pref_species || !customizer_type || !choice_type || !(customizer_type in pref_species.customizers))
		return FALSE
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	if(!customizer)
		return FALSE
	return choice_type in customizer.customizer_choices

/datum/preferences/succubus_disguise/proc/is_allowed_hover_action(list/params)
	if(!params["acc"] && !params["customizer"])
		return TRUE
	var/customizer_type = text2path(params["customizer"])
	var/accessory_type = text2path(params["acc"])
	if(!pref_species || !customizer_type || !accessory_type || !(customizer_type in pref_species.customizers))
		return FALSE
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry?.customizer_choice_type)
	if(!choice)
		return FALSE
	return accessory_type in choice.character_setup_accessory_types(src)

/datum/preferences/succubus_disguise/proc/is_allowed_marking_action(list/params)
	var/marking_action = params["marking_action"]
	if(!(marking_action in list(
		"use_preset",
		"reset_all_colors",
		"reset_color",
		"change_color",
		"move_up",
		"move_down",
		"add",
		"remove",
		"replace",
	)))
		return FALSE
	if(marking_action == "use_preset" || marking_action == "reset_all_colors")
		return TRUE
	var/zone = params["zone"]
	if(!(zone in GLOB.marking_zones))
		return FALSE
	if(marking_action == "add")
		return TRUE
	var/marking_name = params["name"]
	var/list/zone_markings = body_markings[zone]
	return marking_name && zone_markings && zone_markings[marking_name]

/// This is intentionally a strict allowlist. The frontend may hide other
/// controls, but forged actions still stop here before process_link().
/datum/preferences/succubus_disguise/proc/is_allowed_disguise_action(action, list/params)
	if(!islist(params))
		return FALSE
	if(action == "disguise_cancel" || action == "disguise_commit")
		return TRUE
	if(action == "disguise_select_slot")
		if(!isnum(params["slot"]))
			return FALSE
		var/datum/antagonist/succubus/succubus_antag = get_succubus_antag()
		if(!succubus_antag)
			return FALSE
		return params["slot"] >= 1 && params["slot"] <= succubus_antag.get_created_disguise_slot_cap()
	if(action == "set_age")
		return isnum(params["value"])
	if(action != "pref")
		return FALSE

	var/preference = params["preference"]
	switch(preference)
		if("name", "pronouns", "voicetype", "voice")
			return params["task"] == "input"
		if("gender", "randomiseappearanceprefs", "character_setup_toggle_genital_set", "character_setup_taur_body")
			return !params["task"]
		if("character_setup_select_species")
			return !params["task"] && is_allowed_species(params["species_id"])
		if("character_setup_select_ancestry")
			if(!pref_species)
				return FALSE
			return !params["task"] && (params["ancestry"] in pref_species.get_skin_list())
		if("character_setup_select_body_build")
			return !params["task"] && pref_species?.is_body_build_valid(params["body_build"], read_preference(/datum/preference/choiced/gender))
		if("character_setup_customizer")
			return !params["task"] && is_allowed_customizer_action(params)
		if("character_setup_set_choice")
			return !params["task"] && is_allowed_choice_action(params)
		if("character_setup_mutant_color")
			if(!isnum(params["slot"]))
				return FALSE
			var/mutant_slot = params["slot"]
			return !params["task"] && mutant_slot >= 1 && mutant_slot <= 3 && get_mutant_color_feature_key(mutant_slot)
		if("character_setup_taur_color")
			return !params["task"] && (params["which"] in list("base", "markings", "tertiary"))
		if("character_setup_hover")
			return !params["task"] && is_allowed_hover_action(params)
		if("character_setup_preview_rotate")
			return !params["task"] && (params["rotate"] in list("left", "right"))
		if("character_setup_report_geometry")
			return !params["task"] && isnum(params["zoom_main"]) && isnum(params["zoom_mini"])
		if("character_setup_body_marking")
			return !params["task"] && is_allowed_marking_action(params)
	return FALSE

/datum/preferences/succubus_disguise/character_setup_action_allowed(mob/user, action, list/params)
	return !!get_editor_body(user) && is_allowed_disguise_action(action, params)

/datum/preferences/succubus_disguise/process_link(mob/user, list/href_list)
	switch(href_list["preference"])
		if("name")
			var/new_name = tgui_input_text(user, "Choose this disguise's name", "Create Disguise", read_preference(/datum/preference/text/real_name), MAX_NAME_LEN, encode = FALSE)
			if(!get_editor_body(user) || isnull(new_name))
				return FALSE
			new_name = reject_bad_name(new_name)
			if(!new_name)
				to_chat(user, span_warning("That name is not valid."))
				return FALSE
			write_preference(/datum/preference/text/real_name, new_name)
			update_menu_data(user)
			return TRUE
		if("character_setup_body_marking")
			var/list/marking_link = href_list.Copy()
			switch(href_list["marking_action"])
				if("use_preset")
					marking_link["preference"] = "use_preset"
				if("reset_all_colors")
					marking_link["preference"] = "reset_all_colors"
				if("reset_color")
					marking_link["preference"] = "reset_color"
				if("change_color")
					marking_link["preference"] = "change_color"
				if("move_up")
					marking_link["preference"] = "marking_move_up"
				if("move_down")
					marking_link["preference"] = "marking_move_down"
				if("add")
					marking_link["preference"] = "add_marking"
				if("remove")
					marking_link["preference"] = "remove_marking"
				if("replace")
					marking_link["preference"] = "change_marking"
			marking_link["key"] = href_list["zone"]
			marking_link["task"] = "change_marking"
			handle_body_markings_topic(user, marking_link)
			if(!get_editor_body(user))
				return FALSE
			update_menu_data(user)
			return TRUE
	return ..()

/datum/preferences/succubus_disguise/proc/get_creation_cost(mob/living/carbon/human/body)
	return istype(get_area(body), /area/indoors/succubus_lair) ? 0 : SUCCUBUS_COST_CREATE_DISGUISE

/datum/preferences/succubus_disguise/proc/get_commit_block_reason(mob/user)
	var/datum/antagonist/succubus/succubus_antag = get_succubus_antag()
	var/mob/living/carbon/human/body = get_editor_body(user)
	if(!body || !succubus_antag)
		return "The infernal bond no longer answers this draft."
	if(selected_slot < 1 || selected_slot > succubus_antag.get_created_disguise_slot_cap())
		return "That created-disguise slot is locked at my current tier."
	if(succubus_antag.current_form_key == succubus_antag.get_created_disguise_form_key(selected_slot))
		return "I cannot replace the identity I am currently wearing."
	if(!is_allowed_species(pref_species?.id))
		return "This form is not an ordinary mortal species."
	var/creation_cost = get_creation_cost(body)
	if(succubus_antag.essence < creation_cost)
		return "I need [creation_cost] essence to bind this identity here."
	return null

/datum/preferences/succubus_disguise/proc/build_disguise_snapshot()
	if(!is_allowed_species(pref_species?.id))
		return null
	var/mob/living/carbon/human/temporary_body = new(null)
	apply_prefs_to(temporary_body, TRUE, TRUE)
	// apply_prefs_to() deliberately omits this profile field in character-setup
	// mode, but identity snapshots retain it as part of a disguise's voice.
	temporary_body.voice_color = read_preference(/datum/preference/color/voice_color)
	var/datum/identity_snapshot/new_form = new
	if(!new_form.capture(temporary_body))
		qdel(new_form)
		new_form = null
	qdel(temporary_body)
	return new_form

/datum/preferences/succubus_disguise/proc/commit_disguise(mob/user)
	var/blocked_reason = get_commit_block_reason(user)
	if(blocked_reason)
		to_chat(user, span_warning(blocked_reason))
		return FALSE

	var/datum/antagonist/succubus/succubus_antag = get_succubus_antag()
	var/mob/living/carbon/human/body = get_editor_body(user)
	var/creation_cost = get_creation_cost(body)
	var/datum/identity_snapshot/new_form = build_disguise_snapshot()
	if(!new_form)
		to_chat(user, span_warning("The drafted identity refuses to take shape."))
		return FALSE

	// Re-resolve everything after constructing the temporary body. No essence or
	// old snapshot has changed yet, so a stale editor remains a free failure.
	blocked_reason = get_commit_block_reason(user)
	if(blocked_reason || succubus_antag != get_succubus_antag() || creation_cost != get_creation_cost(get_editor_body(user)))
		qdel(new_form)
		if(blocked_reason)
			to_chat(user, span_warning(blocked_reason))
		return FALSE
	if(!succubus_antag.commit_created_disguise(selected_slot, new_form, creation_cost))
		qdel(new_form)
		to_chat(user, span_warning("The identity slips free before I can bind it."))
		return FALSE

	to_chat(body, span_love("I bind [new_form.real_name] into created disguise slot [selected_slot].[creation_cost ? " (-[creation_cost] essence)" : ""]"))
	qdel(src)
	return TRUE

/datum/preferences/succubus_disguise/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui?.user || usr
	if(!get_editor_body(user) || !is_allowed_disguise_action(action, params))
		return FALSE
	switch(action)
		if("disguise_cancel")
			qdel(src)
			return TRUE
		if("disguise_select_slot")
			selected_slot = params["slot"]
			update_menu_data(user)
			return TRUE
		if("disguise_commit")
			return commit_disguise(user)
	return FALSE

/datum/preferences/succubus_disguise/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/character_setup_chargen))

/datum/preferences/succubus_disguise/ui_static_data(mob/user)
	return list(
		"disguise_mode" = TRUE,
		"thumbs" = character_setup_thumbnail_catalog(),
		"species_options" = character_setup_species_options(),
	)

/datum/preferences/succubus_disguise/proc/body_marking_data()
	var/list/zones = list()
	for(var/zone in GLOB.marking_zones)
		var/list/entries = list()
		for(var/marking_name in body_markings[zone])
			entries += list(list(
				"name" = marking_name,
				"color" = "#[body_markings[zone][marking_name]]",
			))
		var/list/available = marking_list_of_zone_for_species(zone, pref_species)
		for(var/used_name in body_markings[zone])
			available -= used_name
		zones += list(list(
			"id" = zone,
			"name" = capitalize(replacetext("[zone]", "_", " ")),
			"entries" = entries,
			"available" = available,
			"can_add" = !!(length(entries) < MAXIMUM_MARKINGS_PER_LIMB && length(available)),
		))
	return zones

/datum/preferences/succubus_disguise/ui_data(mob/user)
	var/list/full_data = ..()
	var/list/data = list("disguise_mode" = TRUE)
	var/static/list/allowed_fields = list(
		"real_name",
		"species_name",
		"species_id",
		"is_taur",
		"taur_body",
		"taur_color",
		"taur_markings",
		"taur_tertiary",
		"mutant_colors",
		"use_skintones",
		"gender",
		"gender_short",
		"body_build",
		"body_build_name",
		"body_build_options",
		"age",
		"age_index",
		"age_min",
		"age_max",
		"age_options",
		"age_tooltips",
		"pronouns",
		"ancestry_label",
		"ancestry_value",
		"ancestry_options",
		"genital_set_label",
		"genital_extra_unlock",
		"features",
		"preview_dir",
		"preview_map",
		"preview_map_front",
		"preview_map_side",
		"preview_bbox_w",
		"preview_bbox_h",
		"voice_type",
		"voice_color",
	)
	for(var/field in allowed_fields)
		data[field] = full_data[field]

	var/datum/antagonist/succubus/succubus_antag = get_succubus_antag()
	var/mob/living/carbon/human/body = get_editor_body(user)
	var/slot_cap = succubus_antag?.get_created_disguise_slot_cap() || 0
	var/creation_cost = get_creation_cost(body)
	var/list/slots = list()
	for(var/slot in 1 to SUCCUBUS_CREATED_DISGUISE_MAX_SLOTS)
		var/datum/identity_snapshot/stored_form
		if(succubus_antag)
			stored_form = succubus_antag.created_forms[slot]
		var/form_key = succubus_antag?.get_created_disguise_form_key(slot)
		slots += list(list(
			"slot" = slot,
			"unlocked" = slot <= slot_cap,
			"occupied" = !!stored_form,
			"name" = stored_form?.real_name || "Empty",
			"active" = succubus_antag?.current_form_key == form_key,
		))
	data["selected_slot"] = selected_slot
	data["slot_cap"] = slot_cap
	data["contract_tier"] = succubus_antag?.get_succubus_contract_tier() || 0
	data["creation_cost"] = creation_cost
	data["essence"] = succubus_antag?.essence || 0
	data["slots"] = slots
	data["body_markings"] = body_marking_data()
	var/commit_reason = get_commit_block_reason(user)
	data["commit_available"] = !commit_reason
	data["commit_reason"] = commit_reason || "Ready to bind this identity."
	return data

/datum/preferences/succubus_disguise/ui_interact(mob/user, datum/tgui/ui)
	if(!get_editor_body(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterCreator", "Create Disguise", 1180, 800)
		ui.set_autoupdate(FALSE)
		ui.open()
	character_setup_ensure_view(user, ui)

/datum/preferences/succubus_disguise/ui_close(mob/user)
	. = ..()
	if(!QDELETED(src) && !istype(src, /datum/preferences/ooze_body))
		qdel(src)
