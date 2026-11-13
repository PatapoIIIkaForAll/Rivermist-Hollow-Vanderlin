/// Bark pitch multiplier; each bark sound narrows the range further.
/datum/preference/numeric/speech_bark_pitch
	savefile_key = "speech_bark_pitch"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	should_update_preview = FALSE
	minimum = 0.6
	maximum = 1.6
	step = 0.01

/datum/preference/numeric/speech_bark_pitch/create_default_value(datum/preferences/prefs)
	return 1

/datum/preference/numeric/speech_bark_pitch/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.speech_bark_pitch = value
