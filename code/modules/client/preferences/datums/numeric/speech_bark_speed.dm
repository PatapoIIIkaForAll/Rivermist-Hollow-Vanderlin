/// Letters of speech per bark; each bark sound narrows this further.
/datum/preference/numeric/speech_bark_speed
	savefile_key = "speech_bark_speed"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	should_update_preview = FALSE
	minimum = 2
	maximum = 16

/datum/preference/numeric/speech_bark_speed/create_default_value(datum/preferences/prefs)
	return 4

/datum/preference/numeric/speech_bark_speed/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.speech_bark_speed = value
