/// Whether this player hears other characters' speech barks.
/datum/preference/toggle/hear_speech_barks
	savefile_key = "hear_speech_barks"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Audio"
	toggles_menu_name = "Hear Speech Barks"
	toggles_menu_desc = "Hear the short blips other characters make while they speak, in place of their usual speech sounds."
	category = "audio"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE
