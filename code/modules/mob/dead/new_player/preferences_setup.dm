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
		pref_species = new rando_race()

	if(NOEYESPRITES in pref_species.species_traits)
		randomise_flags &= ~RANDOMIZE_EYE_COLOR

	if(randomise_flags & RANDOMIZE_GENDER)
		gender = pref_species.sexes ? pick(MALE, FEMALE) : PLURAL

	// pronouns and voice should match gender, not randomized
	var/list/allowed_voices
	switch(gender)
		if(MALE)
			pronouns = HE_HIM
			allowed_voices = pref_species.allowed_voicetypes_m
			voice_type = VOICE_TYPE_MASC
		if(FEMALE)
			pronouns = SHE_HER
			allowed_voices = pref_species.allowed_voicetypes_f
			voice_type = VOICE_TYPE_FEM
		if(PLURAL)
			pronouns = THEY_THEM
			allowed_voices = VOICE_TYPES_LIST
			voice_type = VOICE_TYPE_ANDRO
		else
			pronouns = IT_ITS
			allowed_voices = VOICE_TYPES_LIST
			voice_type = VOICE_TYPE_ANDRO

	if(!allowed_voices || !length(allowed_voices))
		allowed_voices = VOICE_TYPE_ANDRO

	if(!(voice_type in allowed_voices))
		voice_type = pick(allowed_voices)

	var/list/allowed_pronouns = pref_species.allowed_pronouns
	if(!allowed_pronouns || !length(allowed_pronouns))
		allowed_pronouns = PRONOUNS_LIST

	if (!(pronouns in allowed_pronouns))
		pronouns = pick(allowed_pronouns)

	if(randomise_flags & RANDOMIZE_AGE)
		age = pick(pref_species.possible_ages)

	if(randomise_flags & RANDOMIZE_NAME)
		real_name = pref_species.random_name(gender, TRUE)

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
		skin_tone = pick_assoc(skin_list)

	if(randomise_flags & RANDOMIZE_EYE_COLOR)
		eye_color = random_eye_color()

	if(pref_species.forced_taur && pref_species.allowed_taur_types.len)
		taur_type = pick(pref_species.allowed_taur_types)
	else
		taur_type = null

	//if(randomise_flags & RANDOMIZE_FEATURES)
		//features = random_features()

/// Randomizes our character preferences according to enabled randomise preferences.
/datum/preferences/proc/apply_character_randomization_prefs(antag_override = FALSE)
	if(!randomise[RANDOM_BODY] && !(antag_override && randomise[RANDOM_BODY_ANTAG]))
		return // Prefs say "no, thank you"
	if(randomise[RANDOM_SPECIES])
		random_species()
	if(randomise[RANDOM_GENDER] || antag_override && randomise[RANDOM_GENDER_ANTAG])
		gender = pref_species.sexes ? pick(MALE, FEMALE) : PLURAL
	if(randomise[RANDOM_AGE] || randomise[RANDOM_AGE_ANTAG] && antag_override)
		age = pick(pref_species.possible_ages)
	if(randomise[RANDOM_VOICETYPE] || antag_override && randomise[RANDOM_VOICETYPE_ANTAG])
		voice_type = pick(VOICE_TYPES_LIST)
	if(randomise[RANDOM_PRONOUNS] || antag_override && randomise[RANDOM_PRONOUNS_ANTAG])
		var/list/allowed_pronouns = pref_species.allowed_pronouns
		if(!allowed_pronouns || !length(allowed_pronouns))
			allowed_pronouns = PRONOUNS_LIST
		if(length(allowed_pronouns) == 1)
			pronouns = allowed_pronouns[1]
		else
			pronouns = pick(allowed_pronouns)

	if(randomise[RANDOM_NAME] || antag_override && randomise[RANDOM_NAME_ANTAG])
		real_name = pref_species.random_name(gender, TRUE)

	//if(randomise[RANDOM_UNDERWEAR_COLOR])
	//	underwear_color = random_short_color()
	//if(randomise[RANDOM_UNDERSHIRT])
	//	undershirt = random_undershirt(gender)
	//if(randomise[RANDOM_UNDERWEAR])
	//	underwear = pref_species.random_underwear(gender)
	if(randomise[RANDOM_SKIN_TONE])
		var/list/skins = pref_species.get_skin_list()
		skin_tone = pick_assoc(skins)
	if(randomise[RANDOM_EYE_COLOR])
		eye_color = random_eye_color()
	features = pref_species.get_random_features()
	sanitize_species_mutant_colors()

	if(pref_species.default_features["ears"])
		features["ears"] = pref_species.default_features["ears"]
	accessory = "Nothing"
	body_markings = pref_species.get_random_body_markings(features)

/datum/preferences/proc/random_species()
	var/rando_race = GLOB.species_list[pick(GLOB.roundstart_species)]
	pref_species = new rando_race()
	if(randomise[RANDOM_NAME])
		real_name = pref_species.random_name(gender, TRUE)
	if(pref_species.forced_taur && pref_species.allowed_taur_types.len)
		taur_type = pick(pref_species.allowed_taur_types)
	else
		taur_type = null

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

/datum/preferences/proc/get_character_preview_data(mob/user)
	var/list/preview_data = list()
	if(!user?.client)
		return preview_data

	var/datum/job/preview_job = preview_subclass || get_preview_job()
	var/resource_token = get_preview_resource_token()
	preview_image_revision++

	var/list/preview_dirs = list(
		"preview_north" = NORTH,
		"preview_south" = SOUTH,
		"preview_east" = EAST,
		"preview_west" = WEST,
	)
	var/icon/preview_icon = get_flat_human_icon(
		null,
		preview_job,
		src,
		get_preview_dummy_key(),
		list(NORTH, SOUTH, EAST, WEST)
	)
	if(!preview_icon)
		preview_icon = icon('icons/blanks/32x32.dmi', "nothing")

	for(var/preview_key in preview_dirs)
		var/icon/flat_icon = icon(preview_icon, "", preview_dirs[preview_key], 1, 0)
		var/resource_name = "preference_preview_[resource_token]_[preview_key]_[preview_image_revision].png"
		user << browse_rsc(flat_icon, resource_name)
		preview_data[preview_key] = resource_name

	return preview_data

/datum/preferences/proc/update_preview_icon()
	set waitfor = 0
	var/mob/user = parent?.mob
	if(!user || !winexists(user, "preferences_browser"))
		return

	var/update_generation = ++preview_update_generation
	var/list/preview_data = get_character_preview_data(user)
	if(length(preview_data))
		schedule_preview_icon_update(user, preview_data, update_generation)

/datum/preferences/proc/schedule_preview_icon_update(mob/user, list/preview_data, update_generation)
	// Before subsystem init, addtimer() is not reliable for lobby preview refreshes.
	// Keep the one-tick delay that fixes live browser loading, but fall back to spawn.
	if(SStimer?.initialized)
		addtimer(CALLBACK(src, PROC_REF(push_preview_icon_update), user, preview_data, update_generation), 1)
	else
		sleep(world.tick_lag)
		push_preview_icon_update(user, preview_data, update_generation)

/datum/preferences/proc/push_preview_icon_update(mob/user, list/preview_data, update_generation)
	if(update_generation != preview_update_generation)
		return
	if(!user || !winexists(user, "preferences_browser"))
		return
	user << output(list2params(preview_data), "preferences_browser:updateCharacterData")
