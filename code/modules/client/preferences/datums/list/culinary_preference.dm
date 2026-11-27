/datum/preference/list_type/culinary_preferences
	savefile_key = "culinary_preferences"
	savefile_identifier = PREF_CHARACTER

/datum/preference/list_type/culinary_preferences/create_default_value(datum/preferences/prefs)
	return list(
		CULINARY_RANDOM_PREFERENCES = FALSE,
		CULINARY_FAVOURITE_FOOD = NONE,
		CULINARY_FAVOURITE_DRINK = NONE,
		CULINARY_HATED_FOOD = NONE,
		CULINARY_HATED_DRINK = NONE,
	)

/datum/preference/list_type/culinary_preferences/apply_to_human(mob/living/carbon/human/H, list/value, datum/preferences/prefs)
	prefs.validate_culinary_preferences()
	value = prefs.read_preference(type)
	H.culinary_preferences = value.Copy()
	if(has_world_trait(/datum/world_trait/exotic_tastes))
		H.culinary_preferences[CULINARY_RANDOM_PREFERENCES] = TRUE
	if(H.culinary_preferences[CULINARY_RANDOM_PREFERENCES])
		var/list/rolled = roll_random_culinary_groups()
		for(var/key in rolled)
			H.culinary_preferences[key] = rolled[key]
