#define PREFERENCE_PREVIEW_RATE_LIMIT_WINDOW_DS 10
#define PREFERENCE_PREVIEW_RATE_LIMIT_MAX_REQUESTS 8
#define PREFERENCE_PREVIEW_RATE_LIMIT_MUTE_DS 50
#define PREFERENCE_PREVIEW_CACHE_LIMIT 8

/// Randomizes our character preferences according to enabled bitflags.
// Reflect changes in [mob/living/carbon/human/proc/randomize_human_appearance]
/datum/preferences/proc/randomise_appearance_prefs(randomise_flags = ALL)
	if(randomise_flags & RANDOMIZE_SPECIES)
		var/list/species_list = list()
		for(var/species_id in GLOB.roundstart_species)
			var/species_type = GLOB.species_list[species_id]

			var/datum/species/species = new species_type()
			if(!species.preference_accessible(src))
				continue

			species_list += species.type

		var/rando_race = pick(species_list)
		set_species_preference(rando_race)

	if(randomise_flags & RANDOMIZE_FEATURES)
		features = pref_species.get_random_features()
		sanitize_species_mutant_colors()
		try_update_mutant_colors()

	if(NOEYESPRITES in pref_species.species_traits)
		randomise_flags &= ~RANDOMIZE_EYE_COLOR

	if(randomise_flags & RANDOMIZE_GENDER)
		write_preference(/datum/preference/choiced/gender, pref_species.sexes ? pick(MALE, FEMALE) : PLURAL)

	// pronouns and voice should match gender, not randomized
	var/list/allowed_voices
	switch(read_preference(/datum/preference/choiced/gender))
		if(MALE)
			write_preference(/datum/preference/choiced/pronouns, HE_HIM)
			allowed_voices = pref_species.allowed_voicetypes_m
			write_preference(/datum/preference/choiced/voice_type, VOICE_TYPE_MASC)
		if(FEMALE)
			write_preference(/datum/preference/choiced/pronouns, SHE_HER)
			allowed_voices = pref_species.allowed_voicetypes_f
			write_preference(/datum/preference/choiced/voice_type, VOICE_TYPE_FEM)
		if(PLURAL)
			write_preference(/datum/preference/choiced/pronouns, THEY_THEM)
			allowed_voices = VOICE_TYPES_LIST
			write_preference(/datum/preference/choiced/voice_type, VOICE_TYPE_ANDRO)
		else
			write_preference(/datum/preference/choiced/pronouns, IT_ITS)
			allowed_voices = VOICE_TYPES_LIST
			write_preference(/datum/preference/choiced/voice_type, VOICE_TYPE_ANDRO)

	if(!allowed_voices || !length(allowed_voices))
		allowed_voices = VOICE_TYPE_ANDRO

	if(!(read_preference(/datum/preference/choiced/voice_type) in allowed_voices))
		write_preference(/datum/preference/choiced/voice_type, pick(allowed_voices))

	var/list/allowed_pronouns = pref_species.allowed_pronouns
	if(!allowed_pronouns || !length(allowed_pronouns))
		allowed_pronouns = PRONOUNS_LIST

	if (!(read_preference(/datum/preference/choiced/pronouns) in allowed_pronouns))
		write_preference(/datum/preference/choiced/pronouns, pick(allowed_pronouns))

	if(randomise_flags & RANDOMIZE_FEATURES)
		randomise_body_build()
	else
		sanitize_body_build()

	if(randomise_flags & RANDOMIZE_AGE)
		write_preference(/datum/preference/choiced/age, pick(pref_species.possible_ages))

	if(randomise_flags & RANDOMIZE_NAME)
		write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))

	//if(randomise_flags & RANDOMIZE_UNDERWEAR)
	//	underwear = pref_species.random_underwear(gender)

	if(randomise_flags & (RANDOMIZE_HAIRSTYLE | RANDOMIZE_HAIR_COLOR))
		var/datum/customizer_entry/hair/entry = get_customizer_entry_of_type(/datum/customizer_entry/hair/head)
		if(entry)
			var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
			var/color = (randomise_flags & RANDOMIZE_HAIR_COLOR)
			var/accessory = (randomise_flags & RANDOMIZE_HAIRSTYLE)
			customizer_choice.randomize_entry(entry, src, color, accessory)

	if(randomise_flags & (RANDOMIZE_FACIAL_HAIRSTYLE | RANDOMIZE_FACIAL_HAIR_COLOR))
		var/datum/customizer_entry/hair/entry = get_customizer_entry_of_type(/datum/customizer_entry/hair/facial)
		if(entry)
			var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
			var/color = (randomise_flags & RANDOMIZE_FACIAL_HAIR_COLOR)
			var/accessory = (randomise_flags & RANDOMIZE_FACIAL_HAIRSTYLE)
			customizer_choice.randomize_entry(entry, src, color, accessory)

	if(randomise_flags & RANDOMIZE_SKIN_TONE)
		var/list/skin_list = pref_species.get_skin_list()
		write_preference(/datum/preference/choiced/skin_tone, pick_assoc(skin_list))

	if(pref_species.forced_taur && pref_species.allowed_taur_types.len)
		write_preference(/datum/preference/choiced/taur_type, pick(pref_species.allowed_taur_types))
	else
		write_preference(/datum/preference/choiced/taur_type, null)

	validate_descriptors()

/// Randomizes our character preferences according to enabled randomise preferences.
/datum/preferences/proc/apply_character_randomization_prefs(antag_override = FALSE)
	if(!randomise[RANDOM_BODY] && !(antag_override && randomise[RANDOM_BODY_ANTAG]))
		return // Prefs say "no, thank you"
	if(randomise[RANDOM_SPECIES])
		random_species()
	if(randomise[RANDOM_GENDER] || antag_override && randomise[RANDOM_GENDER_ANTAG])
		write_preference(/datum/preference/choiced/gender, pref_species.sexes ? pick(MALE, FEMALE) : PLURAL)
	if(randomise[RANDOM_AGE] || randomise[RANDOM_AGE_ANTAG] && antag_override)
		write_preference(/datum/preference/choiced/age, pick(pref_species.possible_ages))
	if(randomise[RANDOM_VOICETYPE] || antag_override && randomise[RANDOM_VOICETYPE_ANTAG])
		write_preference(/datum/preference/choiced/voice_type, pick(VOICE_TYPES_LIST))
	if(randomise[RANDOM_PRONOUNS] || antag_override && randomise[RANDOM_PRONOUNS_ANTAG])
		var/list/allowed_pronouns = pref_species.allowed_pronouns
		if(!allowed_pronouns || !length(allowed_pronouns))
			allowed_pronouns = PRONOUNS_LIST
		if(length(allowed_pronouns) == 1)
			write_preference(/datum/preference/choiced/pronouns, allowed_pronouns[1])
		else
			write_preference(/datum/preference/choiced/pronouns, pick(allowed_pronouns))

	if(randomise[RANDOM_NAME] || antag_override && randomise[RANDOM_NAME_ANTAG])
		write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))

	//if(randomise[RANDOM_UNDERWEAR_COLOR])
	//	underwear_color = random_short_color()
	//if(randomise[RANDOM_UNDERSHIRT])
	//	undershirt = random_undershirt(gender)
	//if(randomise[RANDOM_UNDERWEAR])
	//	underwear = pref_species.random_underwear(gender)
	if(randomise[RANDOM_SKIN_TONE])
		var/list/skins = pref_species.get_skin_list()
		write_preference(/datum/preference/choiced/skin_tone, pick_assoc(skins))
	if(randomise[RANDOM_EYE_COLOR])
		var/datum/customizer_entry/organ/eyes/eye_entry = get_customizer_entry_of_type(/datum/customizer_entry/organ/eyes)
		if(eye_entry)
			var/randomized_eye_color = random_eye_color()
			eye_entry.right_eye_color = randomized_eye_color
			eye_entry.left_eye_color = randomized_eye_color
	features = pref_species.get_random_features()
	sanitize_species_mutant_colors()

	if(pref_species.default_features["ears"])
		features["ears"] = pref_species.default_features["ears"]
	write_preference(/datum/preference/choiced/accessory, "Nothing")
	body_markings = pref_species.get_random_body_markings(features)

/datum/preferences/proc/random_species()
	var/rando_race = GLOB.species_list[pick(GLOB.roundstart_species)]
	set_species_preference(rando_race)
	if(randomise[RANDOM_NAME])
		write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))
	if(pref_species.forced_taur && pref_species.allowed_taur_types.len)
		write_preference(/datum/preference/choiced/taur_type, pick(pref_species.allowed_taur_types))
	else
		write_preference(/datum/preference/choiced/taur_type, null)
	validate_descriptors()

/datum/preferences/proc/get_preview_job()
	var/datum/job/preview_job
	var/highest_pref = 0
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			preview_job = SSjob.GetJob(job)
			highest_pref = job_preferences[job]
	return preview_job

/datum/preferences/proc/get_preview_resource_token()
	if(!preview_resource_token)
		preview_resource_token = copytext(md5("[REF(src)]"), 1, 9)
	return preview_resource_token

/datum/preferences/proc/get_preview_dummy_key()
	return "[DUMMY_HUMAN_SLOT_PREFERENCES]_[get_preview_resource_token()]"

/datum/preferences/proc/mark_preview_appearance_dirty()
	preview_image_revision++
	preview_browser_fingerprint = null

/datum/preferences/proc/normalize_preview_fingerprint_value(value)
	if(isnull(value))
		return null
	if(islist(value))
		var/list/list_value = value
		var/list/normalized = list()
		for(var/index in 1 to length(list_value))
			var/element = list_value[index]
			// Associative entries store a non-null value under the element key. Plain/ordered
			// elements (including datums and objects) return null here, so normalize them directly
			// instead of dropping their contents - this is what carries eye colors etc. in customizer_entries.
			var/element_value = null
			if(!isnull(element) && !isnum(element))
				element_value = list_value[element]
			if(isnull(element_value))
				normalized += list(normalize_preview_fingerprint_value(element))
			else
				normalized["[normalize_preview_fingerprint_value(element)]"] = normalize_preview_fingerprint_value(element_value)
		return normalized
	if(ispath(value))
		return "[value]"
	if(isicon(value) || isfile(value))
		return "[value]"
	if(isdatum(value))
		var/datum/datum_value = value
		var/list/datum_vars = list("__type" = "[datum_value.type]")
		for(var/var_name in datum_value.vars)
			if(var_name in list("type", "parent_type", "vars", "tag"))
				continue
			datum_vars[var_name] = normalize_preview_fingerprint_value(datum_value.vars[var_name])
		return datum_vars
	return value

/datum/preferences/proc/get_character_preview_fingerprint()
	var/datum/job/preview_job = preview_subclass || get_preview_job()
	var/list/fingerprint_data = list(
		"preview_image_revision" = preview_image_revision,
		"species" = "[pref_species?.type]",
		"preview_job" = preview_job ? "[preview_job.type]" : null,
		"preview_subclass" = preview_subclass ? "[preview_subclass.type]" : null,
		"gender" = read_preference(/datum/preference/choiced/gender),
		"age" = read_preference(/datum/preference/choiced/age),
		"skin_tone" = read_preference(/datum/preference/choiced/skin_tone),
		"eye_color" = get_eye_color(RIGHT_SIDE),
		"eye_color_left" = get_eye_color(LEFT_SIDE),
		"detail" = read_preference(/datum/preference/choiced/detail),
		"detail_color" = read_preference(/datum/preference/color/detail_color),
		"taur_type" = read_preference(/datum/preference/choiced/taur_type),
		"taur_color" = read_preference(/datum/preference/color/taur_color),
		"taur_markings" = read_preference(/datum/preference/color/taur_markings),
		"taur_tertiary" = read_preference(/datum/preference/color/taur_tertiary),
		"features" = normalize_preview_fingerprint_value(features),
		"body_markings" = normalize_preview_fingerprint_value(body_markings),
		"customizer_entries" = normalize_preview_fingerprint_value(customizer_entries),
		"smallclothes_preferences" = normalize_preview_fingerprint_value(read_preference(/datum/preference/list_type/smallclothes_preferences)),
	)
	return md5(json_encode(fingerprint_data))

/datum/preferences/proc/touch_preview_sheet_cache(preview_fingerprint)
	preview_sheet_cache_order -= preview_fingerprint
	preview_sheet_cache_order += preview_fingerprint

/datum/preferences/proc/get_cached_preview_sheet_icon(preview_fingerprint)
	var/icon/cached_sheet = preview_sheet_cache[preview_fingerprint]
	if(cached_sheet)
		touch_preview_sheet_cache(preview_fingerprint)
	return cached_sheet

/datum/preferences/proc/cache_preview_sheet_icon(preview_fingerprint, icon/preview_sheet)
	preview_sheet_cache[preview_fingerprint] = preview_sheet
	touch_preview_sheet_cache(preview_fingerprint)
	if(length(preview_sheet_cache_order) <= PREFERENCE_PREVIEW_CACHE_LIMIT)
		return
	var/oldest_fingerprint = preview_sheet_cache_order[1]
	preview_sheet_cache_order.Cut(1, 2)
	preview_sheet_cache -= oldest_fingerprint

/datum/preferences/proc/build_preview_sheet_icon(icon/preview_icon)
	var/icon/preview_sheet = icon('icons/blanks/32x32.dmi', "nothing")
	preview_sheet.Scale(64, 64)
	preview_sheet.Blend(icon(preview_icon, "", NORTH, 1, 0), ICON_OVERLAY, 1, 33)
	preview_sheet.Blend(icon(preview_icon, "", SOUTH, 1, 0), ICON_OVERLAY, 33, 33)
	preview_sheet.Blend(icon(preview_icon, "", EAST, 1, 0), ICON_OVERLAY, 1, 1)
	preview_sheet.Blend(icon(preview_icon, "", WEST, 1, 0), ICON_OVERLAY, 33, 1)
	return preview_sheet

/datum/preferences/proc/get_preview_sheet_icon(preview_fingerprint)
	var/icon/cached_sheet = get_cached_preview_sheet_icon(preview_fingerprint)
	if(cached_sheet)
		return cached_sheet
	var/datum/job/preview_job = preview_subclass || get_preview_job()
	var/icon/preview_icon = get_flat_human_icon(
		null,
		preview_job,
		src,
		get_preview_dummy_key(),
		list(NORTH, SOUTH, EAST, WEST)
	)
	if(!preview_icon)
		preview_icon = icon('icons/blanks/32x32.dmi', "nothing")
	var/icon/preview_sheet = build_preview_sheet_icon(preview_icon)
	cache_preview_sheet_icon(preview_fingerprint, preview_sheet)
	return preview_sheet

/datum/preferences/proc/get_character_preview_data(mob/user, preview_fingerprint)
	var/list/preview_data = list()
	if(!user?.client)
		return preview_data

	var/resource_name = "preference_preview_[get_preview_resource_token()]_sheet_[preview_fingerprint].png"
	user << browse_rsc(get_preview_sheet_icon(preview_fingerprint), resource_name)
	preview_data["preview_sheet"] = resource_name
	return preview_data

/datum/preferences/proc/queue_preview_update(preview_fingerprint, force_push = FALSE)
	if(preview_render_in_progress && !force_push && preview_active_fingerprint == preview_fingerprint)
		return
	if(preview_render_pending && !force_push && preview_pending_fingerprint == preview_fingerprint)
		return
	preview_render_pending = TRUE
	preview_pending_fingerprint = preview_fingerprint
	preview_pending_force_push ||= force_push
	preview_update_generation++

/datum/preferences/proc/schedule_preview_rate_limit_release()
	if(preview_rate_limit_callback_pending)
		return
	preview_rate_limit_callback_pending = TRUE
	if(SStimer?.initialized)
		addtimer(CALLBACK(src, PROC_REF(on_preview_rate_limit_release)), PREFERENCE_PREVIEW_RATE_LIMIT_MUTE_DS)
	else
		spawn(PREFERENCE_PREVIEW_RATE_LIMIT_MUTE_DS)
			on_preview_rate_limit_release()

/datum/preferences/proc/enter_preview_rate_limit(mob/user)
	preview_rate_limit_release_time = world.time + PREFERENCE_PREVIEW_RATE_LIMIT_MUTE_DS
	preview_update_request_times = list()
	schedule_preview_rate_limit_release()
	if(user)
		to_chat(user, span_warning("Preview updates are paused briefly while your latest appearance changes settle."))

/datum/preferences/proc/register_preview_update_request(mob/user)
	if(preview_rate_limit_release_time > world.time)
		return
	var/cutoff = world.time - PREFERENCE_PREVIEW_RATE_LIMIT_WINDOW_DS
	while(length(preview_update_request_times) && preview_update_request_times[1] <= cutoff)
		preview_update_request_times.Cut(1, 2)
	preview_update_request_times += world.time
	if(length(preview_update_request_times) > PREFERENCE_PREVIEW_RATE_LIMIT_MAX_REQUESTS)
		enter_preview_rate_limit(user)

/datum/preferences/proc/request_preview_update(force_push = FALSE, ignore_rate_limit = FALSE)
	set waitfor = 0
	var/mob/user = parent?.mob
	if(!user || !winexists(user, "preferences_browser"))
		return

	var/preview_fingerprint = get_character_preview_fingerprint()
	if(!force_push)
		if(preview_browser_fingerprint == preview_fingerprint)
			return
		if(preview_render_in_progress && preview_active_fingerprint == preview_fingerprint)
			return
		if(preview_render_pending && preview_pending_fingerprint == preview_fingerprint)
			return

	if(preview_rate_limit_release_time > world.time)
		queue_preview_update(preview_fingerprint, TRUE)
		return

	if(!ignore_rate_limit)
		register_preview_update_request(user)
		if(preview_rate_limit_release_time > world.time)
			queue_preview_update(preview_fingerprint, TRUE)
			return

	if(preview_render_in_progress)
		queue_preview_update(preview_fingerprint, force_push)
		return

	preview_render_in_progress = TRUE
	preview_active_fingerprint = preview_fingerprint
	var/update_generation = ++preview_update_generation
	var/list/preview_data = get_character_preview_data(user, preview_fingerprint)
	if(length(preview_data))
		schedule_preview_icon_update(user, preview_data, update_generation, preview_fingerprint)
	else
		finish_preview_update()

/datum/preferences/proc/update_preview_icon()
	return request_preview_update()

/datum/preferences/proc/flush_queued_preview_update()
	if(!preview_render_pending)
		return
	if(preview_rate_limit_release_time > world.time || preview_render_in_progress)
		return
	var/force_push = preview_pending_force_push
	preview_render_pending = FALSE
	preview_pending_fingerprint = null
	preview_pending_force_push = FALSE
	request_preview_update(force_push, TRUE)

/datum/preferences/proc/on_preview_rate_limit_release()
	preview_rate_limit_callback_pending = FALSE
	if(preview_rate_limit_release_time > world.time)
		schedule_preview_rate_limit_release()
		return
	flush_queued_preview_update()

/datum/preferences/proc/finish_preview_update()
	preview_render_in_progress = FALSE
	preview_active_fingerprint = null
	flush_queued_preview_update()

/datum/preferences/proc/schedule_preview_icon_update(mob/user, list/preview_data, update_generation, preview_fingerprint)
	// Before subsystem init, addtimer() is not reliable for lobby preview refreshes.
	// Keep the one-tick delay that fixes live browser loading, but fall back to spawn.
	if(SStimer?.initialized)
		addtimer(CALLBACK(src, PROC_REF(push_preview_icon_update), user, preview_data, update_generation, preview_fingerprint), 1)
	else
		sleep(world.tick_lag)
		push_preview_icon_update(user, preview_data, update_generation, preview_fingerprint)

/datum/preferences/proc/push_preview_icon_update(mob/user, list/preview_data, update_generation, preview_fingerprint)
	if(update_generation != preview_update_generation)
		finish_preview_update()
		return
	if(!user || !winexists(user, "preferences_browser"))
		finish_preview_update()
		return
	user << output(list2params(preview_data), "preferences_browser:updateCharacterData")
	preview_browser_fingerprint = preview_fingerprint
	finish_preview_update()

#undef PREFERENCE_PREVIEW_RATE_LIMIT_WINDOW_DS
#undef PREFERENCE_PREVIEW_RATE_LIMIT_MAX_REQUESTS
#undef PREFERENCE_PREVIEW_RATE_LIMIT_MUTE_DS
#undef PREFERENCE_PREVIEW_CACHE_LIMIT
