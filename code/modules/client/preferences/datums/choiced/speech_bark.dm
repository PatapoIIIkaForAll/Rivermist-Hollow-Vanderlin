/// The blip this character makes while speaking, or none.
/datum/preference/choiced/speech_bark
	savefile_key = "speech_bark"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/speech_bark/init_possible_values(datum/preferences/prefs)
	var/list/choices = list(SPEECH_BARK_NONE)
	for(var/bark_name in GLOB.speech_barks)
		choices += bark_name
	return choices

/datum/preference/choiced/speech_bark/create_default_value(datum/preferences/prefs)
	return SPEECH_BARK_NONE

/datum/preference/choiced/speech_bark/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.speech_bark = GLOB.speech_barks[value] ? value : null
