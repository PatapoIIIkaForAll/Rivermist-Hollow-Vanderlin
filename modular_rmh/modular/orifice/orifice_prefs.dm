// Preferences for the stretching system: baselines, intensity toggles, potion consent and the Size Queen kink.

/datum/erp_preference/list_choice/vaginal_tightness
	name = "Vaginal tightness"
	description = "How tight your vagina rests when nothing has stretched it lately"
	category = "Body"
	choices = ORIFICE_TIGHTNESS_NAMES
	default_choice = "Average"
	locked_after_spawn = TRUE

/datum/erp_preference/list_choice/anal_tightness
	name = "Anal tightness"
	description = "How tight your anus rests when nothing has stretched it lately"
	category = "Body"
	choices = ORIFICE_TIGHTNESS_NAMES
	default_choice = "Average"
	locked_after_spawn = TRUE

/datum/erp_preference/boolean/rough_stretching
	name = "Rough stretching"
	description = "If things bigger than your holes can take may be forced in with enough force and lube. Heavy pain and a gape, never a wound"
	default_value = FALSE
	category = "Body"

/datum/erp_preference/boolean/lasting_stretch
	name = "Lasting stretch"
	description = "If heavy use slowly loosens your baseline for the rest of the round"
	default_value = FALSE
	category = "Body"

/datum/erp_preference/boolean/allow_tightness_potions
	name = "Tightness potions"
	description = "If others can dose you with draughts that loosen, tighten or gape your holes. Drinking one yourself always works"
	default_value = TRUE
	category = "Body"

/// Whether a tightness draught given by [giver] takes hold; drinking one yourself always does.
/mob/living/proc/accepts_tightness_potion_from(mob/living/giver)
	if(!giver || giver == src)
		return TRUE
	// A body nobody plays keeps no preferences to honour.
	if(!client && !mind?.key && !mind?.cached_erp_preferences && !cached_erp_preferences)
		return TRUE
	return has_erp_pref(/datum/erp_preference/boolean/allow_tightness_potions)

/datum/kink/size_queen
	name = KINK_SIZE_QUEEN
	description = "Being stretched wide is the point. Big things please more, gaping feels good, and the strain hurts less."
	intensity = 3
	category = "Fetish"
