/datum/preference/choiced/gender
	savefile_key = "gender"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	priority = PREF_PRIORITY_GENDER

/datum/preference/choiced/gender/init_possible_values(datum/preferences/prefs)
	return list(MALE, FEMALE, PLURAL)

/datum/preference/choiced/gender/create_default_value(datum/preferences/prefs)
	return MALE

/datum/preference/choiced/gender/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	var/old_gender = H.gender
	H.gender = value
	H.dna?.species?.on_gender_update(H, old_gender)

/datum/preference/choiced/gender/handle_link(datum/preferences/prefs, mob/user)
	var/pickedGender = MALE
	if(prefs.read_preference(/datum/preference/choiced/gender) == MALE)
		pickedGender = FEMALE
	if(pickedGender && pickedGender != prefs.read_preference(/datum/preference/choiced/gender))
		// Name, hair, pronouns and customizers stay; only choices the new body cannot use change.
		var/old_gender = prefs.read_preference(/datum/preference/choiced/gender)
		var/on_default_build = prefs.get_body_build_id() == prefs.pref_species?.get_default_body_build(old_gender)
		prefs.write_preference(/datum/preference/choiced/gender, pickedGender)
		if(on_default_build)
			prefs.features["body_build"] = null
		prefs.sanitize_body_build()
		prefs.drop_jobs_closed_to_sex(user, pickedGender)
		prefs.sanitize_voice_type_for_sex()
