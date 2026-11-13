// Species defaults for penis length in centimetres.

/datum/species
	/// Length a new penis entry starts at for this species.
	var/default_penis_length = PENIS_LENGTH_DEFAULT

/datum/species/kobold
	default_penis_length = PENIS_LENGTH_SMALL_FRAME

/datum/species/goblin
	default_penis_length = PENIS_LENGTH_SMALL_FRAME

/datum/species/halfling
	default_penis_length = PENIS_LENGTH_SMALL_FRAME

/datum/species/gnome
	default_penis_length = PENIS_LENGTH_SMALL_FRAME

/datum/species/ogre
	default_penis_length = PENIS_LENGTH_LARGE_FRAME

/datum/species/taur_kin
	default_penis_length = PENIS_LENGTH_LARGE_FRAME

/// Default length for the selected species.
/datum/preferences/proc/get_default_penis_length()
	return pref_species ? pref_species.default_penis_length : PENIS_LENGTH_DEFAULT

/// Random length for a body without preferences: its set size range, else a band by body frame.
/mob/living/proc/get_random_penis_length()
	if(penis_min != MIN_PENIS_SIZE || penis_max != MAX_PENIS_SIZE)
		return rand(get_penis_length_for_size(penis_min), get_penis_length_for_size(penis_max))
	if(has_fluid_modifier(/datum/fluid_modifier/small_frame))
		return rand(8, 13)
	if(has_fluid_modifier(/datum/fluid_modifier/large_frame))
		return rand(17, 26)
	return rand(11, 19)
