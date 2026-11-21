/// Whether this character's voice pitch follows their strength.
/datum/preference/toggle/strength_voice_pitch
	savefile_key = "strength_voice_pitch"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/datum/preference/toggle/strength_voice_pitch/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.strength_voice_pitch = value

/mob/living/carbon/human
	/// Whether strength lowers or raises the emote pitch.
	var/strength_voice_pitch = TRUE
