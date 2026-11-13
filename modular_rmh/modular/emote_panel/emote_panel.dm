#define EMOTE_PANEL_MAX_FAVOURITES 200
#define EMOTE_PANEL_MAX_CUSTOM 30
#define EMOTE_PANEL_MAX_NAME 32
#define EMOTE_PANEL_MAX_TEXT 256
#define EMOTE_PANEL_SAVE_DELAY (3 SECONDS)
/// Minimum gap between two custom emotes that print player text.
#define EMOTE_PANEL_TEXT_COOLDOWN (1 SECONDS)

#define CUSTOM_EMOTE_KEY 1
#define CUSTOM_EMOTE_KEY_TEXT 2
#define CUSTOM_EMOTE_ME 3

/// Verb names the player starred in the Emotes tab of the stat panel.
/datum/preference/list_type/emote_favourites
	savefile_key = "emote_favourites"
	savefile_identifier = PREF_PLAYER

/datum/preference/list_type/emote_favourites/is_valid(value, datum/preferences/prefs)
	if(!islist(value) || length(value) > EMOTE_PANEL_MAX_FAVOURITES)
		return FALSE
	for(var/entry in value)
		if(!istext(entry) || !length(entry) || length(entry) > MAX_NAME_LEN)
			return FALSE
	return TRUE

/// Player-made emote macros: list(list("id", "name", "type", "key", "text"), ...)
/datum/preference/list_type/custom_emotes
	savefile_key = "custom_emotes"
	savefile_identifier = PREF_PLAYER

/datum/preference/list_type/custom_emotes/is_valid(value, datum/preferences/prefs)
	if(!islist(value) || length(value) > EMOTE_PANEL_MAX_CUSTOM)
		return FALSE
	for(var/entry in value)
		if(!is_valid_custom_emote(entry))
			return FALSE
	return TRUE

/datum/preference/list_type/custom_emotes/proc/is_valid_custom_emote(list/entry)
	if(!islist(entry))
		return FALSE
	var/id = entry["id"]
	var/name = entry["name"]
	var/kind = entry["type"]
	if(!istext(id) || !length(id) || length(id) > 16)
		return FALSE
	if(!istext(name) || !length(name) || length_char(name) > EMOTE_PANEL_MAX_NAME)
		return FALSE
	if(!(kind in list(CUSTOM_EMOTE_KEY, CUSTOM_EMOTE_KEY_TEXT, CUSTOM_EMOTE_ME)))
		return FALSE
	if(kind != CUSTOM_EMOTE_ME)
		var/key = entry["key"]
		if(!istext(key) || !length(key) || length(key) > MAX_NAME_LEN)
			return FALSE
	if(kind != CUSTOM_EMOTE_KEY)
		var/text = entry["text"]
		if(!istext(text) || !length(text) || length_char(text) > EMOTE_PANEL_MAX_TEXT)
			return FALSE
	return TRUE

/client/on_stat_panel_message(type, payload)
	. = ..()
	switch(type)
		// Sent by the panel on (re)load only, mob changes keep the JS state
		if("Update-Verbs")
			send_emote_panel_data()
		if("Emote-Favourite")
			toggle_favourite_emote(payload["name"])
		if("Emote-Custom-Add")
			INVOKE_ASYNC(src, PROC_REF(add_custom_emote))
		if("Emote-Custom-Edit")
			INVOKE_ASYNC(src, PROC_REF(edit_custom_emote), payload["id"])
		if("Emote-Custom-Run")
			run_custom_emote(payload["id"])

/client/proc/send_emote_panel_data()
	if(!prefs || !stat_panel)
		return
	var/list/customs = list()
	for(var/list/entry as anything in prefs.read_preference(/datum/preference/list_type/custom_emotes))
		customs += list(list("id" = entry["id"], "name" = entry["name"]))
	stat_panel.send_message("emote_panel_data", list(
		"favourites" = prefs.read_preference(/datum/preference/list_type/emote_favourites),
		"customs" = customs,
	))

/// Writes the value and batches savefile writes, star clicks can come in quick bursts.
/client/proc/write_emote_panel_pref(pref_type, list/value)
	if(!prefs.write_preference(GLOB.preference_entries[pref_type], value))
		return FALSE
	addtimer(CALLBACK(prefs, TYPE_PROC_REF(/datum/preferences, save_preferences)), EMOTE_PANEL_SAVE_DELAY, TIMER_UNIQUE)
	send_emote_panel_data()
	return TRUE

/client/proc/toggle_favourite_emote(name)
	if(!prefs || !istext(name) || !length(name) || length(name) > MAX_NAME_LEN)
		return
	var/list/favourites = prefs.read_preference(/datum/preference/list_type/emote_favourites)
	favourites = favourites.Copy()
	if(name in favourites)
		favourites -= name
	else
		if(length(favourites) >= EMOTE_PANEL_MAX_FAVOURITES)
			to_chat(src, span_warning("I can't keep more than [EMOTE_PANEL_MAX_FAVOURITES] favourite emotes."))
			send_emote_panel_data()
			return
		favourites += name
	write_emote_panel_pref(/datum/preference/list_type/emote_favourites, favourites)

/client/proc/get_custom_emote(id)
	if(!prefs || !istext(id))
		return null
	for(var/list/entry as anything in prefs.read_preference(/datum/preference/list_type/custom_emotes))
		if(entry["id"] == id)
			return entry
	return null

/// Emote keys this mob type is allowed to use, for the custom emote picker.
/client/proc/get_pickable_emote_keys()
	var/list/keys = list()
	for(var/key in GLOB.emote_list)
		if(!key)
			continue
		for(var/datum/emote/emote as anything in GLOB.emote_list[key])
			if(emote.key != key || key == "me" || emote.only_forced_audio)
				continue
			if(!is_type_in_typecache(mob, emote.mob_type_allowed_typecache))
				continue
			keys |= key
			break
	return sortList(keys)

/client/proc/prompt_custom_emote_text(default)
	var/text = tgui_input_text(mob, "What should the chat show after your name?", "Custom emote", default, EMOTE_PANEL_MAX_TEXT, encode = FALSE)
	text = trim(copytext_char(text, 1, EMOTE_PANEL_MAX_TEXT + 1))
	return length(text) ? text : null

/client/proc/prompt_custom_emote_name(default)
	var/name = tgui_input_text(mob, "Button name", "Custom emote", default, EMOTE_PANEL_MAX_NAME, encode = FALSE)
	name = trim(STRIP_HTML_SIMPLE(name, EMOTE_PANEL_MAX_NAME))
	return length(name) ? name : null

/client/proc/add_custom_emote()
	if(!prefs || !mob)
		return
	var/list/customs = prefs.read_preference(/datum/preference/list_type/custom_emotes)
	if(length(customs) >= EMOTE_PANEL_MAX_CUSTOM)
		to_chat(src, span_warning("I can't keep more than [EMOTE_PANEL_MAX_CUSTOM] custom emotes."))
		return

	var/static/list/kinds = list(
		"Emote" = CUSTOM_EMOTE_KEY,
		"Emote + own text" = CUSTOM_EMOTE_KEY_TEXT,
		"*me" = CUSTOM_EMOTE_ME,
	)
	var/kind = tgui_alert(mob, "Emote runs as is. Emote + own text keeps the emote's sound but prints your text. *me only prints your text.", "Custom emote", assoc_list_strip_value(kinds))
	if(!kind || !kinds[kind])
		return
	var/list/entry = list("type" = kinds[kind])

	if(entry["type"] != CUSTOM_EMOTE_ME)
		var/key = tgui_input_list(mob, "Pick an emote", "Custom emote", get_pickable_emote_keys())
		if(!key || !GLOB.emote_list[key])
			return
		entry["key"] = key

	if(entry["type"] != CUSTOM_EMOTE_KEY)
		var/text = prompt_custom_emote_text()
		if(!text)
			return
		entry["text"] = text

	var/name = prompt_custom_emote_name(entry["key"] || copytext_char(entry["text"], 1, EMOTE_PANEL_MAX_NAME + 1))
	if(!name)
		return
	entry["name"] = name

	// The prompts can take a while, re-read so we don't drop edits made meanwhile.
	customs = prefs.read_preference(/datum/preference/list_type/custom_emotes)
	customs = customs.Copy()
	if(length(customs) >= EMOTE_PANEL_MAX_CUSTOM)
		return
	var/id_number = 1
	for(var/list/existing as anything in customs)
		id_number = max(id_number, text2num(existing["id"]) + 1)
	entry["id"] = "[id_number]"
	customs += list(entry)
	if(!write_emote_panel_pref(/datum/preference/list_type/custom_emotes, customs))
		to_chat(src, span_warning("That custom emote could not be saved."))

/client/proc/edit_custom_emote(id)
	var/list/entry = get_custom_emote(id)
	if(!entry || !mob)
		return
	var/list/options = list("Rename")
	if(entry["type"] != CUSTOM_EMOTE_KEY)
		options += "Change text"
	options += "Delete"
	var/choice = tgui_alert(mob, "What to do with \"[entry["name"]]\"?", "Custom emote", options)
	if(!choice)
		return

	var/list/updated = entry.Copy()
	switch(choice)
		if("Rename")
			var/name = prompt_custom_emote_name(entry["name"])
			if(!name)
				return
			updated["name"] = name
		if("Change text")
			var/text = prompt_custom_emote_text(entry["text"])
			if(!text)
				return
			updated["text"] = text
		if("Delete")
			if(tgui_alert(mob, "Delete \"[entry["name"]]\"?", "Custom emote", list("Delete", "Cancel")) != "Delete")
				return
			updated = null

	var/list/customs = prefs.read_preference(/datum/preference/list_type/custom_emotes)
	var/list/result = list()
	for(var/list/existing as anything in customs)
		if(existing["id"] != id)
			result += list(existing)
		else if(updated)
			result += list(updated)
	write_emote_panel_pref(/datum/preference/list_type/custom_emotes, result)

/client/proc/run_custom_emote(id)
	var/list/entry = get_custom_emote(id)
	if(!entry || !isliving(mob))
		return
	var/mob/living/user = mob
	var/kind = entry["type"]
	if(kind == CUSTOM_EMOTE_KEY)
		user.emote(entry["key"], intentional = TRUE)
		return

	#ifdef USES_PQ
	if(get_playerquality(ckey) <= -20)
		to_chat(src, span_warning("I can't use custom emotes. (LOW PQ)"))
		return
	#endif
	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return
	if(prefs.muted & MUTE_IC)
		to_chat(src, span_boldwarning("I cannot send IC messages (muted)."))
		return
	if(world.time < user.next_me_emote)
		return

	var/datum/emote/sound_source
	if(kind == CUSTOM_EMOTE_KEY_TEXT)
		// The emote's own sound cooldown applies, same as running it normally
		if(world.time < user.next_emote)
			return
		for(var/datum/emote/emote as anything in GLOB.emote_list[entry["key"]])
			if(emote.key == entry["key"] && emote.can_run_emote(user, TRUE, TRUE))
				sound_source = emote
				break
		if(!sound_source)
			to_chat(src, span_warning("I can't do that right now."))
			return

	var/message = trim(copytext_char(sanitize(entry["text"]), 1, MAX_MESSAGE_LEN))
	message = parsemarkdown_basic(message, limited = TRUE, barebones = TRUE)
	user.emote("me", sound_source ? sound_source.emote_type : EMOTE_VISIBLE, message, TRUE, custom_me = TRUE)
	user.next_me_emote = max(user.next_me_emote, world.time + EMOTE_PANEL_TEXT_COOLDOWN)
	if(sound_source)
		user.next_emote = max(user.next_emote, world.time + sound_source.mute_time)
		play_custom_emote_sound(user, sound_source)

/client/proc/play_custom_emote_sound(mob/living/user, datum/emote/sound_source)
	var/sound_file = sound_source.get_sound(user)
	if(!sound_file)
		return
	var/sound/emote_sound = istype(sound_file, /sound) ? sound_file : sound(get_sfx(sound_file))
	emote_sound.frequency = user.get_emote_pitch()
	playsound(user, emote_sound, sound_source.snd_vol, FALSE, sound_source.snd_range, soundping = sound_source.soundping)

#undef EMOTE_PANEL_MAX_FAVOURITES
#undef EMOTE_PANEL_MAX_CUSTOM
#undef EMOTE_PANEL_MAX_NAME
#undef EMOTE_PANEL_MAX_TEXT
#undef EMOTE_PANEL_SAVE_DELAY
#undef EMOTE_PANEL_TEXT_COOLDOWN
#undef CUSTOM_EMOTE_KEY
#undef CUSTOM_EMOTE_KEY_TEXT
#undef CUSTOM_EMOTE_ME
