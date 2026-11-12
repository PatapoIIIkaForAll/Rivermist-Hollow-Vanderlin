/// How far each bark's pitch may stray from the set pitch.
/datum/preference/numeric/speech_bark_variance
	savefile_key = "speech_bark_variance"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	should_update_preview = FALSE
	minimum = 0.1
	maximum = 0.4
	step = 0.01

/datum/preference/numeric/speech_bark_variance/create_default_value(datum/preferences/prefs)
	return 0.2

/datum/preference/numeric/speech_bark_variance/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.speech_bark_variance = value
