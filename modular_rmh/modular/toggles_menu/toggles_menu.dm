#define TOGGLES_MENU_CHARACTER "Current character"
#define TOGGLES_MENU_EYES_ID "character_eyes_glow"
#define GENITAL_SHOW_HIDDEN "Hidden"
#define GENITAL_SHOW_UNDER "Show Under clothes"
#define GENITAL_SHOW_ABOVE "Show Above clothes"

/// Section order of the Toggles window; preferences name their section in toggles_menu_category.
GLOBAL_LIST_INIT(toggles_menu_categories, list("Interface", "Display", "Audio", "Chat", "Gameplay", "Content", "Admin"))

/datum/preference
	/// Toggles window section this preference is listed in; null keeps it out of the window.
	var/toggles_menu_category
	/// Row label in the Toggles window.
	var/toggles_menu_name
	/// Row tooltip in the Toggles window.
	var/toggles_menu_desc

/// Writes a value from the Toggles window, applies it live and saves it.
/datum/preference/proc/toggles_menu_write(datum/preferences/prefs, value)
	if(!prefs.update_preference(src, value))
		return FALSE
	if(savefile_identifier == PREF_CHARACTER)
		prefs.save_character()
	else
		prefs.save_preferences()
	return TRUE

/// Flips this toggle from the Toggles window. Override to call the code that already applies it.
/datum/preference/toggle/proc/toggles_menu_toggle(datum/preferences/prefs)
	return toggles_menu_write(prefs, !prefs.read_preference(type))

/proc/cmp_toggles_menu_label(datum/preference/a, datum/preference/b)
	return sorttext(b.toggles_menu_name, a.toggles_menu_name)

/// Toggle and choiced preferences listed in the Toggles window: section name -> preferences sorted by label.
/proc/get_toggles_menu_prefs()
	var/static/list/by_category
	if(by_category)
		return by_category
	by_category = list()
	for(var/category in GLOB.toggles_menu_categories)
		var/list/listed = list()
		for(var/key in GLOB.preference_entries_by_key)
			var/datum/preference/pref = GLOB.preference_entries_by_key[key]
			if(pref.toggles_menu_category != category)
				continue
			if(!istype(pref, /datum/preference/toggle) && !istype(pref, /datum/preference/choiced))
				continue
			listed += pref
		by_category[category] = sortList(listed, GLOBAL_PROC_REF(cmp_toggles_menu_label))
	return by_category

/// One window with every listed on/off setting, plus rows for the character played now.
/datum/toggle_options_menu
	var/datum/preferences/prefs

/datum/toggle_options_menu/New(datum/preferences/prefs)
	. = ..()
	src.prefs = prefs

/datum/toggle_options_menu/Destroy(force)
	prefs = null
	return ..()

/datum/toggle_options_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ToggleOptionsMenu", "Toggles")
		ui.set_state(GLOB.always_state)
		ui.open()

/datum/toggle_options_menu/ui_data(mob/user)
	var/list/data = list()
	var/list/categories = list()
	if(prefs)
		var/list/character = character_category(user)
		if(character)
			categories += list(character)
		var/list/by_category = get_toggles_menu_prefs()
		for(var/category in by_category)
			var/list/entries = list()
			var/list/selects = list()
			for(var/datum/preference/pref as anything in by_category[category])
				if(!pref.is_accessible(prefs))
					continue
				if(istype(pref, /datum/preference/toggle))
					entries += list(list(
						"id" = pref.savefile_key,
						"label" = pref.toggles_menu_name,
						"enabled" = !!prefs.read_preference(pref.type),
						"desc" = pref.toggles_menu_desc,
					))
					continue
				var/datum/preference/choiced/choiced = pref
				var/list/options = list()
				for(var/choice in choiced.get_choices(prefs))
					options += list(list("label" = "[choice]", "value" = choiced.serialize(choice)))
				selects += list(list(
					"id" = pref.savefile_key,
					"label" = pref.toggles_menu_name,
					"value" = choiced.serialize(prefs.read_preference(pref.type)),
					"desc" = pref.toggles_menu_desc,
					"options" = options,
				))
			if(length(entries) || length(selects))
				categories += list(list("name" = category, "entries" = entries, "selects" = selects))
	data["categories"] = categories
	return data

/datum/toggle_options_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !prefs)
		return
	var/id = params["id"]
	if(!istext(id))
		return FALSE
	switch(action)
		if("toggle")
			if(id == TOGGLES_MENU_EYES_ID)
				return toggle_eyes_glow(ui?.user)
			var/datum/preference/toggle/pref = get_listed_pref(id)
			if(!istype(pref))
				return FALSE
			pref.toggles_menu_toggle(prefs)
			return TRUE
		if("select")
			var/value = params["value"]
			var/datum/preference/choiced/pref = get_listed_pref(id)
			if(!istype(pref))
				return set_genital_visibility(ui?.user, id, value)
			if(!(value in pref.get_choices_serialized()))
				return FALSE
			pref.toggles_menu_write(prefs, value)
			return TRUE
	return FALSE

/// The listed preference with this savefile key that the player may change, or null.
/datum/toggle_options_menu/proc/get_listed_pref(key)
	var/datum/preference/pref = GLOB.preference_entries_by_key[key]
	if(!pref?.toggles_menu_category || !(pref.toggles_menu_category in GLOB.toggles_menu_categories))
		return null
	if(!pref.is_accessible(prefs))
		return null
	return pref

/// The living carbon body the player has in the round, or null.
/datum/toggle_options_menu/proc/get_round_body(mob/user)
	if(!SSticker.HasRoundStarted() || !iscarbon(user) || user.stat == DEAD)
		return null
	return user

/datum/toggle_options_menu/proc/get_glowing_eyes(mob/living/carbon/body)
	for(var/obj/item/organ/eyes/eyes in body.internal_organs)
		if(eyes.glows)
			return eyes
	return null

/// Genitals of body that can be shown or hidden.
/datum/toggle_options_menu/proc/get_menu_genitals(mob/living/carbon/body)
	var/list/genitals = list()
	for(var/obj/item/organ/genitals/organ in body.get_exposable_genitals())
		genitals += organ
	return genitals

/// Section for the current character: only rows that apply to this body.
/datum/toggle_options_menu/proc/character_category(mob/user)
	var/mob/living/carbon/body = get_round_body(user)
	if(!body)
		return null
	var/list/entries = list()
	var/list/selects = list()
	var/obj/item/organ/eyes/eyes = get_glowing_eyes(body)
	if(eyes)
		entries += list(list(
			"id" = TOGGLES_MENU_EYES_ID,
			"label" = "Glowing eyes",
			"enabled" = !!eyes.user_glowing_pref,
			"desc" = "Make your eyes glow.",
		))
	for(var/obj/item/organ/genitals/organ as anything in get_menu_genitals(body))
		var/current = GENITAL_SHOW_HIDDEN
		if(organ.visible_through_clothes == DRAW_ABOVE)
			current = GENITAL_SHOW_ABOVE
		else if(organ.visible_through_clothes)
			current = GENITAL_SHOW_UNDER
		selects += list(list(
			"id" = REF(organ),
			"label" = capitalize(organ.name),
			"value" = current,
			"desc" = "Hide it, show it under your clothes, or show it above them.",
			"options" = list(
				list("label" = "Hidden", "value" = GENITAL_SHOW_HIDDEN),
				list("label" = "Under clothes", "value" = GENITAL_SHOW_UNDER),
				list("label" = "Above clothes", "value" = GENITAL_SHOW_ABOVE),
			),
		))
	if(!length(entries) && !length(selects))
		return null
	return list("name" = TOGGLES_MENU_CHARACTER, "entries" = entries, "selects" = selects)

/datum/toggle_options_menu/proc/toggle_eyes_glow(mob/user)
	var/mob/living/carbon/body = get_round_body(user)
	if(!body || !get_glowing_eyes(body))
		return FALSE
	body.set_eyes_glowing()
	return TRUE

/datum/toggle_options_menu/proc/set_genital_visibility(mob/user, id, value)
	var/mob/living/carbon/body = get_round_body(user)
	if(!body || !(value in list(GENITAL_SHOW_HIDDEN, GENITAL_SHOW_UNDER, GENITAL_SHOW_ABOVE)))
		return FALSE
	var/obj/item/organ/genitals/organ = locate(id)
	if(!organ || !(organ in get_menu_genitals(body)))
		return FALSE
	if(body.stat != CONSCIOUS)
		to_chat(body, span_warning("I can't change that right now."))
		return FALSE
	organ.toggle_visibility(value)
	return TRUE

/client
	/// Toggles window, made on first open.
	var/datum/toggle_options_menu/toggles_menu

/client/verb/toggles_menu_verb()
	set name = "Toggles"
	set category = "Preferences"
	set desc = "Open one window with your on/off settings."
	open_toggles_menu()

/// Opens the Toggles window for this player.
/client/proc/open_toggles_menu()
	if(!prefs || !mob)
		return
	if(!toggles_menu)
		toggles_menu = new(prefs)
	toggles_menu.ui_interact(mob)

#undef TOGGLES_MENU_CHARACTER
#undef TOGGLES_MENU_EYES_ID
#undef GENITAL_SHOW_HIDDEN
#undef GENITAL_SHOW_UNDER
#undef GENITAL_SHOW_ABOVE
