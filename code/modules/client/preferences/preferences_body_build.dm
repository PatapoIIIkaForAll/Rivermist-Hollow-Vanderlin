/// The saved build id, or the species default when the saved one is missing or invalid.
/datum/preferences/proc/get_body_build_id()
	if(!length(pref_species?.allowed_body_builds))
		return null
	var/gender = read_preference(/datum/preference/choiced/gender)
	var/build_id = features["body_build"]
	if(pref_species.is_body_build_valid(build_id, gender))
		return build_id
	return pref_species.get_default_body_build(gender)

/// Keeps the saved build valid for the current species and sex.
/datum/preferences/proc/sanitize_body_build()
	features["body_build"] = get_body_build_id()

/datum/preferences/proc/randomise_body_build()
	if(!pref_species)
		return
	var/list/options = pref_species.get_body_build_options(read_preference(/datum/preference/choiced/gender))
	features["body_build"] = length(options) ? pick(options) : null

/// Build choices for character setup as id/name pairs.
/datum/preferences/proc/character_setup_body_build_options()
	. = list()
	if(!pref_species)
		return
	for(var/build_id in pref_species.get_body_build_options(read_preference(/datum/preference/choiced/gender)))
		var/datum/body_build/build = GLOB.body_builds[build_id]
		. += list(list("id" = build_id, "name" = build.name))

/// Sets the build; nothing else about the character changes.
/datum/preferences/proc/character_setup_apply_body_build(mob/user, build_id)
	if(!pref_species?.is_body_build_valid(build_id, read_preference(/datum/preference/choiced/gender)))
		return TRUE
	if(features["body_build"] == build_id)
		return TRUE
	features["body_build"] = build_id
	mark_preview_appearance_dirty()
	update_menu_data(user)
	return TRUE

/// Clears only the job choices the given sex may not take.
/datum/preferences/proc/drop_jobs_closed_to_sex(mob/user, new_gender)
	var/list/dropped = list()
	for(var/job_title in job_preferences)
		var/datum/job/job = SSjob.GetJob(job_title)
		if(job && !(new_gender in job.allowed_sexes))
			dropped += job_title
	if(!length(dropped))
		return
	job_preferences -= dropped
	to_chat(user, span_warning("Classes closed to this body were cleared: [english_list(dropped)]."))

/// Keeps the voice type if this species allows it for the current sex.
/datum/preferences/proc/sanitize_voice_type_for_sex()
	var/list/allowed_voices
	switch(read_preference(/datum/preference/choiced/gender))
		if(MALE)
			allowed_voices = pref_species.allowed_voicetypes_m
		if(FEMALE)
			allowed_voices = pref_species.allowed_voicetypes_f
	if(!length(allowed_voices))
		allowed_voices = VOICE_TYPES_LIST
	if(!(read_preference(/datum/preference/choiced/voice_type) in allowed_voices))
		write_preference(/datum/preference/choiced/voice_type, allowed_voices[1])

/// Fits appearance to a newly picked species, keeping every choice it still allows.
/datum/preferences/proc/fit_appearance_to_species(had_mutant_colors = FALSE)
	if(!pref_species.sexes)
		write_preference(/datum/preference/choiced/gender, PLURAL)
	else if(!(read_preference(/datum/preference/choiced/gender) in list(MALE, FEMALE)))
		write_preference(/datum/preference/choiced/gender, pick(MALE, FEMALE))
	sanitize_voice_type_for_sex()

	var/list/skins = pref_species.get_skin_list()
	if(length(skins))
		var/skin_tone = read_preference(/datum/preference/choiced/skin_tone)
		var/skin_valid = FALSE
		for(var/skin_name in skins)
			if(skins[skin_name] == skin_tone)
				skin_valid = TRUE
				break
		if(!skin_valid)
			write_preference(/datum/preference/choiced/skin_tone, pick_assoc(skins))

	// A species gaining mutant colours rolls fresh ones instead of inheriting plain defaults.
	if(has_mutant_color_preferences() && !had_mutant_colors)
		var/list/rolled = pref_species.get_random_features()
		for(var/color_key in list("mcolor", "mcolor2", "mcolor3"))
			features[color_key] = rolled[color_key]
	sanitize_species_mutant_colors()
	sanitize_body_build()

	var/list/kept_entries = customizer_entries.Copy()
	validate_customizer_entries()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(entry in kept_entries)
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		choice.reset_accessory_colors(src, entry)
		choice.randomize_entry(entry, src)

	if(pref_species.forced_taur && length(pref_species.allowed_taur_types))
		write_preference(/datum/preference/choiced/taur_type, pick(pref_species.allowed_taur_types))
	else if(!(read_preference(/datum/preference/choiced/taur_type) in pref_species.allowed_taur_types))
		write_preference(/datum/preference/choiced/taur_type, null)
	validate_body_markings()
	validate_descriptors()
