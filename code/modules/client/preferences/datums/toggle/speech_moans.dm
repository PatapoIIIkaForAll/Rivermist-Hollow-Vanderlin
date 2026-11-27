/// Whether high arousal turns this character's speech sounds into moans.
/datum/preference/toggle/speech_moans
	savefile_key = "speech_moans"
	savefile_identifier = PREF_CHARACTER
	toggles_menu_category = "Content"
	toggles_menu_name = "Moan while speaking"
	toggles_menu_desc = "At high arousal your character moans instead of making speech sounds. Saved to the current character."
	category = "character"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/datum/preference/toggle/speech_moans/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.speech_moans = value
