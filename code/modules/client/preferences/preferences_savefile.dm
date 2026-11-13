//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 18

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX 40

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	S["version"] >> savefile_version

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2

	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version

	return -1

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

// Safely extract a type path from datums or type values; returns null if unset/invalid.
/proc/preferences_typepath_or_null(value)
	if(isnull(value))
		return null
	if(ispath(value))
		return value
	if(istype(value, /datum))
		var/datum/D = value
		return D.type
	return null

// Convert a string path to an actual type path, returns null if invalid
// This is needed for JSON-decoded presets where type paths become strings
/proc/string_to_typepath(value)
	if(isnull(value))
		return null
	if(ispath(value))
		return value
	if(istext(value))
		// Try to convert string to type path
		var/path = text2path(value)
		if(ispath(path))
			return path
	return null

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	if(current_version < 29)
		key_bindings = (read_preference(/datum/preference/toggle/hotkeys)) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
		parent.update_movement_keys()
		to_chat(parent, "<span class='danger'>Empty keybindings, setting default to [read_preference(/datum/preference/toggle/hotkeys) ? "Hotkey" : "Classic"] mode</span>")

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 22)
		job_preferences = list()
		for(var/datum/job/J as anything in subtypesof(/datum/job))
			var/new_value
			if(new_value)
				job_preferences[initial(J.title)] = new_value
	//if(current_version < 24)
	//	if (!(underwear in GLOB.underwear_list))
	//		underwear = "Nude"
	if(current_version < 25)
		randomise = list(RANDOM_UNDERWEAR = TRUE, RANDOM_UNDERWEAR_COLOR = TRUE, RANDOM_UNDERSHIRT = TRUE, RANDOM_SKIN_TONE = TRUE, RANDOM_EYE_COLOR = TRUE)
		if(S["name_is_always_random"] == 1)
			randomise[RANDOM_NAME] = TRUE
		if(S["body_is_always_random"] == 1)
			randomise[RANDOM_BODY] = TRUE
		if(S["species_is_always_random"] == 1)
			randomise[RANDOM_SPECIES] = TRUE

	if(current_version < 30)
		var/raw_voice_color
		S["voice_color"] >> raw_voice_color
		write_preference(GLOB.preference_entries[/datum/preference/color/voice_color], raw_voice_color)

	if(current_version < 31)
		write_preference(GLOB.preference_entries[/datum/preference/choiced/culture], /datum/culture/universal/ambiguous)
		var/list/assoc_skins = pref_species.get_skin_list()
		var/list/skins = list()
		for(var/skin in assoc_skins)
			skins += assoc_skins[skin]
		if(!(read_preference(/datum/preference/choiced/skin_tone) in skins))
			write_preference(GLOB.preference_entries[/datum/preference/choiced/skin_tone], pick_assoc(assoc_skins))

	if(current_version < 32)
		var/species_name = S["species"]
		for(var/species_id in GLOB.species_list)
			var/datum/species/species_type = GLOB.species_list[species_id]
			if(species_type::name == species_name)
				write_preference(GLOB.preference_entries[/datum/preference/choiced/species], species_type)
				break

	if(current_version < 33)
		var/voice_type = read_preference(/datum/preference/choiced/voice_type)
		switch(voice_type)
			if("Masculine")
				write_preference(/datum/preference/choiced/voice_type, VOICE_TYPE_MASC)
			if("Feminine")
				write_preference(/datum/preference/choiced/voice_type, VOICE_TYPE_FEM)

	if(current_version < 34)
		var/list/flat_preferences = list()
		for(var/savefile_key in list(
			"real_name", "gender", "pronouns", "voice_type", "voice_pack", "moan_selection", "age", "domhand", "selected_accent",
			"family", "setspouse", "gender_choice", "species", "selected_patron", "culture", "skin_tone", "voice_color", "detail_color",
			"accessory", "detail", "flavortext", "flavortext_display", "ooc_notes", "ooc_notes_display", "ooc_extra", "ooc_extra_link",
			"headshot_link", "nsfw_headshot_link", "nsfwflavortext", "erpprefs_flavor", "song_link", "song_artist", "song_title",
			"img_gallery", "nsfw_img_gallery", "joblessrole", "defeat_mode", "defeat_damage_threshold",
			"combat_music", "taur_type", "taur_color", "taur_markings", "taur_tertiary", "selected_title", "erp_preferences",
			"smallclothes_preferences", "culinary_preferences"
		))
			S[savefile_key] >> flat_preferences[savefile_key]
		migrate_character_flat_to_preference(flat_preferences)

	if(current_version < 36)
		var/old_family_mode
		S["family"] >> old_family_mode
		if(old_family_mode in list(FAMILY_NONE, FAMILY_PARTIAL, FAMILY_NEWLYWED, FAMILY_FULL))
			write_preference(/datum/preference/choiced/family_mode, old_family_mode)

		var/old_rumor
		S["rumour"] >> old_rumor
		if(istext(old_rumor) && length(trim(old_rumor)))
			write_preference(/datum/preference/list_type/rumors, list(copytext(trim(old_rumor), 1, MAX_GOSSIP_LENGTH + 1)))

		var/old_noble_gossip
		S["noble_gossip"] >> old_noble_gossip
		if(istext(old_noble_gossip) && length(trim(old_noble_gossip)))
			write_preference(/datum/preference/list_type/noble_gossip, list(copytext(trim(old_noble_gossip), 1, MAX_GOSSIP_LENGTH + 1)))

	if(current_version < 37)
		// Accents are opt-in now, so clear whatever the old default left on the slot.
		write_preference(/datum/preference/choiced/selected_accent, ACCENT_NONE)

	if(current_version < 38)
		// Unknown type paths load as null, so the old quirk paths are rewritten as text first.
		var/quirk_text = S.ExportText("quirks")
		if(quirk_text)
			S.ImportText("quirks", migrate_legacy_quirk_text(quirk_text))

	if(current_version < 39)
		// RMH EDIT - the Branded quirk became a creator brand. Its dead path reads back as the base quirk type.
		var/quirk_text = S.ExportText("quirks")
		if(quirk_text && findtext(quirk_text, "/datum/quirk/negative/branded"))
			var/static/regex/branded_path = regex(@"/datum/quirk/negative/branded\b", "g")
			S.ImportText("quirks", branded_path.Replace(quirk_text, "/datum/quirk"))
			var/list/quirk_data
			S["quirks"] >> quirk_data
			if(islist(quirk_data))
				for(var/list/entry in quirk_data.Copy())
					if(!islist(entry) || entry["type"] != /datum/quirk)
						continue
					quirk_data -= list(entry)
					migrate_branded_quirk_save(S, entry["value"], entry["extra"])
				WRITE_FILE(S["quirks"], quirk_data)

	if(current_version < 40)
		// RMH EDIT - prosthetic, Missing Arm/Leg and Cyclops quirks became Prosthetics window choices.
		migrate_prosthetic_quirk_save(S)

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)
		return FALSE

	// Non-preference fields
	var/stored_defeat_introduction_complete
	S["defeat_introduction_complete"] >> stored_defeat_introduction_complete
	// Existing accounts keep their character choices without a new onboarding prompt.
	defeat_introduction_complete = isnull(stored_defeat_introduction_complete) ? TRUE : !!stored_defeat_introduction_complete
	S["admin_ghost_icon"]	>> admin_ghost_icon
	S["lastchangelog"]		>> lastchangelog
	S["be_special"] 		>> be_special
	S["triumphs"]			>> triumphs
	S["lastclass"]			>> lastclass
	var/stored_preferred_ui_language
	S["preferred_ui_language"] >> stored_preferred_ui_language
	if(parent)
		parent.preferred_ui_language = sanitize_preferred_ui_language(stored_preferred_ui_language)


	S["default_slot"]		>> default_slot
	S["ignoring"]			>> ignoring
	S["menuoptions"]		>> menuoptions
	S["multi_ready_slots"] >> multi_ready_slots
	if(!islist(multi_ready_slots))
		multi_ready_slots = list()
	S["key_bindings"]		>> key_bindings

	// Player preferences are loaded through their native preference datums.
	preference_load_from_savefile(S, PREF_PLAYER)
	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)

	// Sanitize non-preference fields.
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	default_slot = sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	menuoptions	= SANITIZE_LIST(menuoptions)
	be_special = SANITIZE_LIST(be_special)
	key_bindings = sanitize_islist(key_bindings, list())

	check_new_keybindings()

	character_setup_load_menu_prefs(S)

	return TRUE

/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	WRITE_FILE(S["version"], SAVEFILE_VERSION_MAX)

	// Non-preference fields
	WRITE_FILE(S["defeat_introduction_complete"], defeat_introduction_complete)
	WRITE_FILE(S["triumphs"], triumphs)
	WRITE_FILE(S["admin_ghost_icon"], admin_ghost_icon)
	WRITE_FILE(S["lastclass"], lastclass)
	WRITE_FILE(S["preferred_ui_language"], parent ? sanitize_preferred_ui_language(parent.preferred_ui_language) : "en")
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["be_special"], be_special)
	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["ignoring"], ignoring)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["key_bindings"], key_bindings)
	WRITE_FILE(S["multi_ready_slots"], multi_ready_slots)

	preference_save_to_savefile(S, PREF_PLAYER)
	character_setup_save_menu_prefs(S)
	return TRUE


/datum/preferences/proc/_load_species(S)
	var/species_id = S["species"] == "slime" ? SPEC_ID_OOZE : S["species"]
	var/species_type = GLOB.species_list[species_id]
	if(!species_type)
		species_type = /datum/species/human/northern
	set_species_preference(species_type)

/datum/preferences/proc/_load_loadout1(S)
	var/loadout_type
	S["loadout1"] >> loadout_type
	loadout1 = (loadout_type && ispath(loadout_type)) ? new loadout_type() : null

/datum/preferences/proc/_load_loadout2(S)
	var/loadout_type2
	S["loadout2"] >> loadout_type2
	loadout2 = (loadout_type2 && ispath(loadout_type2)) ? new loadout_type2() : null

/datum/preferences/proc/_load_loadout3(S)
	var/loadout_type3
	S["loadout3"] >> loadout_type3
	loadout3 = (loadout_type3 && ispath(loadout_type3)) ? new loadout_type3() : null

/datum/preferences/proc/_load_loadout4(S)
	var/loadout_type4
	S["loadout4"] >> loadout_type4
	loadout4 = (loadout_type4 && ispath(loadout_type4)) ? new loadout_type4() : null

/datum/preferences/proc/_load_loadout5(S)
	var/loadout_type5
	S["loadout5"] >> loadout_type5
	loadout5 = (loadout_type5 && ispath(loadout_type5)) ? new loadout_type5() : null

/datum/preferences/proc/_load_loadout6(S)
	var/loadout_type6
	S["loadout6"] >> loadout_type6
	loadout6 = (loadout_type6 && ispath(loadout_type6)) ? new loadout_type6() : null

/datum/preferences/proc/_load_loadout7(S)
	var/loadout_type7
	S["loadout7"] >> loadout_type7
	loadout7 = (loadout_type7 && ispath(loadout_type7)) ? new loadout_type7() : null

/datum/preferences/proc/_load_loadout8(S)
	var/loadout_type8
	S["loadout8"] >> loadout_type8
	loadout8 = (loadout_type8 && ispath(loadout_type8)) ? new loadout_type8() : null

/datum/preferences/proc/_load_loadout9(S)
	var/loadout_type9
	S["loadout9"] >> loadout_type9
	loadout9 = (loadout_type9 && ispath(loadout_type9)) ? new loadout_type9() : null

/datum/preferences/proc/_load_loadout10(S)
	var/loadout_type10
	S["loadout10"] >> loadout_type10
	loadout10 = (loadout_type10 && ispath(loadout_type10)) ? new loadout_type10() : null

/datum/preferences/proc/_load_loadout_presets(S)
	var/preset1_json
	var/preset2_json
	var/preset3_json
	S["loadout_preset_1"] >> preset1_json
	S["loadout_preset_2"] >> preset2_json
	S["loadout_preset_3"] >> preset3_json

	// Load and validate preset 1
	if(preset1_json)
		var/decoded = json_decode(preset1_json)
		if(decoded && istype(decoded, /list))
			loadout_preset_1 = decoded
		else
			loadout_preset_1 = null
	else
		loadout_preset_1 = null

	// Load and validate preset 2
	if(preset2_json)
		var/decoded = json_decode(preset2_json)
		if(decoded && istype(decoded, /list))
			loadout_preset_2 = decoded
		else
			loadout_preset_2 = null
	else
		loadout_preset_2 = null

	// Load and validate preset 3
	if(preset3_json)
		var/decoded = json_decode(preset3_json)
		if(decoded && istype(decoded, /list))
			loadout_preset_3 = decoded
		else
			loadout_preset_3 = null
	else
		loadout_preset_3 = null

/datum/preferences/proc/_save_loadout_presets(S)
	// Save loadout presets as JSON
	if(loadout_preset_1)
		WRITE_FILE(S["loadout_preset_1"], json_encode(loadout_preset_1))
	else
		WRITE_FILE(S["loadout_preset_1"], null)

	if(loadout_preset_2)
		WRITE_FILE(S["loadout_preset_2"], json_encode(loadout_preset_2))
	else
		WRITE_FILE(S["loadout_preset_2"], null)

	if(loadout_preset_3)
		WRITE_FILE(S["loadout_preset_3"], json_encode(loadout_preset_3))
	else
		WRITE_FILE(S["loadout_preset_3"], null)


/datum/preferences/proc/_load_loadout_colours(S)
	S["loadout_1_hex"] >> loadout_1_hex
	S["loadout_2_hex"] >> loadout_2_hex
	S["loadout_3_hex"] >> loadout_3_hex
	S["loadout_4_hex"] >> loadout_4_hex
	S["loadout_5_hex"] >> loadout_5_hex
	S["loadout_6_hex"] >> loadout_6_hex
	S["loadout_7_hex"] >> loadout_7_hex
	S["loadout_8_hex"] >> loadout_8_hex
	S["loadout_9_hex"] >> loadout_9_hex
	S["loadout_10_hex"] >> loadout_10_hex
	// Load custom names
	S["loadout_1_name"] >> loadout_1_name
	S["loadout_2_name"] >> loadout_2_name
	S["loadout_3_name"] >> loadout_3_name
	S["loadout_4_name"] >> loadout_4_name
	S["loadout_5_name"] >> loadout_5_name
	S["loadout_6_name"] >> loadout_6_name
	S["loadout_7_name"] >> loadout_7_name
	S["loadout_8_name"] >> loadout_8_name
	S["loadout_9_name"] >> loadout_9_name
	S["loadout_10_name"] >> loadout_10_name
	// Load custom descriptions
	S["loadout_1_desc"] >> loadout_1_desc
	S["loadout_2_desc"] >> loadout_2_desc
	S["loadout_3_desc"] >> loadout_3_desc
	S["loadout_4_desc"] >> loadout_4_desc
	S["loadout_5_desc"] >> loadout_5_desc
	S["loadout_6_desc"] >> loadout_6_desc
	S["loadout_7_desc"] >> loadout_7_desc
	S["loadout_8_desc"] >> loadout_8_desc
	S["loadout_9_desc"] >> loadout_9_desc
	S["loadout_10_desc"] >> loadout_10_desc

/datum/preferences/proc/_load_appearence(S)
	S["randomise"] >> randomise
	S["feature_mcolor"]		>> features["mcolor"]
	S["feature_mcolor2"]	>> features["mcolor2"]
	S["feature_mcolor3"]	>> features["mcolor3"]
	S["feature_body_build"]	>> features["body_build"]
	if(!islist(randomise))
		randomise = list()

	// We load our list, but override everything to FALSE to stop a "tainted" save from making it random again.
	randomise[RANDOM_BODY] = FALSE
	randomise[RANDOM_BODY_ANTAG] = FALSE
	//randomise[RANDOM_UNDERWEAR] = FALSE
	randomise[RANDOM_SKIN_TONE] = FALSE
	randomise[RANDOM_EYE_COLOR] = FALSE


/datum/preferences/proc/load_character(slot)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"], slot)

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)
		return FALSE

	// Systems with their own load logic
	_load_species(S)

	//Loadout
	_load_loadout1(S)
	_load_loadout2(S)
	_load_loadout3(S)
	_load_loadout4(S)
	_load_loadout5(S)
	_load_loadout6(S)
	_load_loadout7(S)
	_load_loadout8(S)
	_load_loadout9(S)
	_load_loadout10(S)
	_load_loadout_colours(S)
	_load_loadout_presets(S)

	//Character
	_load_appearence(S)

	// preference character fields
	preference_load_from_savefile(S, PREF_CHARACTER)
	var/species_type = read_preference(/datum/preference/choiced/species)
	if(pref_species.type != species_type)
		set_species_preference(species_type)
	validate_culinary_preferences()
	validate_smallclothes_preferences()
	ensure_erp_preferences()

	// Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name"
		S[savefile_slot_name] >> custom_names[custom_name_id]

	// Non-preference jobs/loadout
	S["job_preferences"] >> job_preferences
	S["alt_job_selections"] >> alt_job_selections

	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if(!features["mcolor2"] || features["mcolor2"] == "#000")
		features["mcolor2"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if(!features["mcolor3"] || features["mcolor3"] == "#000")
		features["mcolor3"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S)
		var/migrated_species_type = read_preference(/datum/preference/choiced/species)
		if(pref_species.type != migrated_species_type)
			set_species_preference(migrated_species_type)
		validate_culinary_preferences()
		validate_smallclothes_preferences()
		ensure_erp_preferences()

	// Sanitize non-preference fields
	var/gender = read_preference(/datum/preference/choiced/gender)
	var/cached_name = read_preference(/datum/preference/text/real_name)
	cached_name = reject_bad_name(cached_name)
	if(!cached_name)
		cached_name = random_unique_name(gender)
		write_preference(GLOB.preference_entries[/datum/preference/text/real_name], cached_name)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id], namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	randomise = SANITIZE_LIST(randomise)

	S["emissive_markings"] >> emissive_markings 			// RMH edit
	emissive_markings = SANITIZE_LIST(emissive_markings) 	// RMH edit
	S["body_markings"] >> body_markings
	body_markings = SANITIZE_LIST(body_markings)
	sanitize_species_mutant_colors()
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 6, 0)
	features["mcolor2"]	= sanitize_hexcolor(features["mcolor2"], 6, 0)
	features["mcolor3"]	= sanitize_hexcolor(features["mcolor3"], 6, 0)
	sanitize_body_build()

	validate_body_markings()

	// RMH EDITED START - custom self-written tattoos, separate from GLOB.body_markings
	S["tattoos"] >> tattoos
	tattoos = SANITIZE_LIST(tattoos)
	validate_tattoos()
	S["prosthetics"] >> prosthetics
	prosthetics = SANITIZE_LIST(prosthetics)
	S["implants"] >> implants
	implants = SANITIZE_LIST(implants)
	validate_prosthetics()
	// RMH EDITED END

	S["descriptor_entries"] >> descriptor_entries
	descriptor_entries = SANITIZE_LIST(descriptor_entries)
	S["custom_descriptors"] >> custom_descriptors
	custom_descriptors = SANITIZE_LIST(custom_descriptors)
	current_slot = slot

	validate_descriptors()

	//Validate job prefs
	if(!job_preferences)
		job_preferences = list()
	else
		for(var/j in job_preferences)
			if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
				job_preferences -= j
	sanitize_alt_job_selections()

	load_customizer_and_quirk_data(S)

	return TRUE

/// Quirk availability is judged against the customizer entries, and the genital set rules are
/// judged against the quirks, so the entries are sanitized first, the quirks are validated second, and
/// load_quirks() runs the enforcing validation pass once both halves are present. Enforcing before
/// the quirks are read strips the mixed genital set that Extra Genitals exists to allow.
/datum/preferences/proc/load_customizer_and_quirk_data(savefile/S)
	S["customizer_entries"] >> customizer_entries
	// Body size caps read quirks, so the saved list must replace the previous slot's list first.
	read_saved_quirks(S)
	validate_customizer_entries(enforce_genital_rules = FALSE)
	load_quirks(S)

/datum/preferences/proc/save_character()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/character[default_slot]"

	WRITE_FILE(S["version"], SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

	// Native character preference datums.
	preference_save_to_savefile(S, PREF_CHARACTER)

	// Non-preference character data.
	WRITE_FILE(S["randomise"]		, randomise)
	// Loadout
	WRITE_FILE(S["loadout1"] , preferences_typepath_or_null(loadout1))
	WRITE_FILE(S["loadout2"] , preferences_typepath_or_null(loadout2))
	WRITE_FILE(S["loadout3"] , preferences_typepath_or_null(loadout3))
	WRITE_FILE(S["loadout4"] , preferences_typepath_or_null(loadout4))
	WRITE_FILE(S["loadout5"] , preferences_typepath_or_null(loadout5))
	WRITE_FILE(S["loadout6"] , preferences_typepath_or_null(loadout6))
	WRITE_FILE(S["loadout7"] , preferences_typepath_or_null(loadout7))
	WRITE_FILE(S["loadout8"] , preferences_typepath_or_null(loadout8))
	WRITE_FILE(S["loadout9"] , preferences_typepath_or_null(loadout9))
	WRITE_FILE(S["loadout10"] , preferences_typepath_or_null(loadout10))

	_save_loadout_presets(S)

	WRITE_FILE(S["loadout_1_hex"], loadout_1_hex)
	WRITE_FILE(S["loadout_2_hex"], loadout_2_hex)
	WRITE_FILE(S["loadout_3_hex"], loadout_3_hex)
	WRITE_FILE(S["loadout_4_hex"], loadout_4_hex)
	WRITE_FILE(S["loadout_5_hex"], loadout_5_hex)
	WRITE_FILE(S["loadout_6_hex"], loadout_6_hex)
	WRITE_FILE(S["loadout_7_hex"], loadout_7_hex)
	WRITE_FILE(S["loadout_8_hex"], loadout_8_hex)
	WRITE_FILE(S["loadout_9_hex"], loadout_9_hex)
	WRITE_FILE(S["loadout_10_hex"], loadout_10_hex)
	// Save custom names
	WRITE_FILE(S["loadout_1_name"], loadout_1_name)
	WRITE_FILE(S["loadout_2_name"], loadout_2_name)
	WRITE_FILE(S["loadout_3_name"], loadout_3_name)
	WRITE_FILE(S["loadout_4_name"], loadout_4_name)
	WRITE_FILE(S["loadout_5_name"], loadout_5_name)
	WRITE_FILE(S["loadout_6_name"], loadout_6_name)
	WRITE_FILE(S["loadout_7_name"], loadout_7_name)
	WRITE_FILE(S["loadout_8_name"], loadout_8_name)
	WRITE_FILE(S["loadout_9_name"], loadout_9_name)
	WRITE_FILE(S["loadout_10_name"], loadout_10_name)
	// Save custom descriptions
	WRITE_FILE(S["loadout_1_desc"], loadout_1_desc)
	WRITE_FILE(S["loadout_2_desc"], loadout_2_desc)
	WRITE_FILE(S["loadout_3_desc"], loadout_3_desc)
	WRITE_FILE(S["loadout_4_desc"], loadout_4_desc)
	WRITE_FILE(S["loadout_5_desc"], loadout_5_desc)
	WRITE_FILE(S["loadout_6_desc"], loadout_6_desc)
	WRITE_FILE(S["loadout_7_desc"], loadout_7_desc)
	WRITE_FILE(S["loadout_8_desc"], loadout_8_desc)
	WRITE_FILE(S["loadout_9_desc"], loadout_9_desc)
	WRITE_FILE(S["loadout_10_desc"], loadout_10_desc)

	WRITE_FILE(S["feature_mcolor"]		, features["mcolor"])
	WRITE_FILE(S["feature_mcolor2"]		, features["mcolor2"])
	WRITE_FILE(S["feature_mcolor3"]		, features["mcolor3"])
	WRITE_FILE(S["feature_body_build"]	, features["body_build"])

	// Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name"
		WRITE_FILE(S[savefile_slot_name], custom_names[custom_name_id])

	// Organs
	WRITE_FILE(S["customizer_entries"], customizer_entries)
	WRITE_FILE(S["body_markings"], body_markings)
	// Emissive body markings 								// RMH edit
	WRITE_FILE(S["emissive_markings"], emissive_markings) 	// RMH edit
	// RMH EDITED START - custom self-written tattoos, separate from GLOB.body_markings
	WRITE_FILE(S["tattoos"], tattoos)
	WRITE_FILE(S["prosthetics"], prosthetics)
	WRITE_FILE(S["implants"], implants)
	// RMH EDITED END
	// Descriptor entries
	WRITE_FILE(S["descriptor_entries"], descriptor_entries)
	WRITE_FILE(S["custom_descriptors"], custom_descriptors)
	WRITE_FILE(S["job_preferences"], job_preferences)
	WRITE_FILE(S["alt_job_selections"], alt_job_selections)

	save_quirks(S)

	return TRUE

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN

#ifdef TESTING
//DEBUG
//Some crude tools for testing savefiles
//path is the savefile path
/client/verb/savefile_export(path as text)
	set hidden = TRUE
	var/savefile/S = new /savefile(path)
	S.ExportText("/",file("[path].txt"))

//path is the savefile path
/client/verb/savefile_import(path as text)
	set hidden = TRUE
	var/savefile/S = new /savefile(path)
	S.ImportText("/",file("[path].txt"))

#endif

/datum/preferences/proc/check_new_keybindings()
	var/list/keybind_names = list()
	var/list/used_keys = list()
	for(var/key in key_bindings)
		keybind_names |= key_bindings[key]
		used_keys |= key

	if(!length(GLOB.hotkey_keybinding_list_by_key))
		init_keybindings()
	for(var/key in GLOB.hotkey_keybinding_list_by_key)
		var/list/key_name = GLOB.hotkey_keybinding_list_by_key[key]
		if(!length(key_name))
			continue
		if(!(key_name[1] in keybind_names))
			if(key in used_keys)
				preference_message_list |= span_bold("[key_name[1]] is unbound and the default key is in use, please set the keybind yourself!")
				continue
			key_bindings |= key
			key_bindings[key] = GLOB.hotkey_keybinding_list_by_key[key]

/datum/preferences/proc/preference_load_from_savefile(savefile/S, identifier)
	for (var/datum/preference/entry as anything in GLOB.preferences_in_priority_order)
		if (entry.savefile_identifier != identifier)
			continue
		var/raw
		S[entry.savefile_key] >> raw
		var/value
		if (!isnull(raw))
			value = entry.deserialize(raw, src)
		if (isnull(value) || !entry.is_valid(value, src))
			value = entry.create_informed_default_value(src)
			// Write the default back so stale/absent keys are healed immediately.
			WRITE_FILE(S[entry.savefile_key], entry.serialize(value))
		preference_cache[entry.type] = value

/datum/preferences/proc/preference_save_to_savefile(savefile/S, identifier)
	for (var/T in GLOB.preference_entries)
		var/datum/preference/entry = GLOB.preference_entries[T]
		if (entry.savefile_identifier != identifier)
			continue
		if (!(T in preference_cache))
			continue
		WRITE_FILE(S[entry.savefile_key], entry.serialize(preference_cache[T]))
