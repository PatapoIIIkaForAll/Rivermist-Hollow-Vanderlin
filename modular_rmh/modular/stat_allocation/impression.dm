// Charisma sets the impression a character gives. Examine shows it, together with the rare looks traits.

/datum/stress_event/charming
	timer = 1 MINUTES
	stress_change = -1
	desc = span_green("Some people are a pleasure to be around.")

/datum/stress_event/offputting
	timer = 30 SECONDS
	stress_change = 1
	desc = span_red("What an unpleasant person.")

/// The impression this mob gives, from Charisma: one of the IMPRESSION_* values.
/mob/living/proc/get_impression()
	var/charisma = GET_MOB_ATTRIBUTE_VALUE(src, STAT_CHARISMA)
	if(!isnum(charisma))
		return IMPRESSION_ORDINARY
	if(charisma <= CHARISMA_POOR_MAX)
		return IMPRESSION_POOR
	if(charisma >= CHARISMA_STRONG_MIN)
		return IMPRESSION_STRONG
	return IMPRESSION_ORDINARY

/// The line the player wrote for this impression, or null to use the standard one.
/mob/living/proc/get_custom_impression_line(impression)
	return null

/mob/living/carbon/human/get_custom_impression_line(impression)
	switch(impression)
		if(IMPRESSION_STRONG)
			return impression_text_strong
		if(IMPRESSION_ORDINARY)
			return impression_text_ordinary
		if(IMPRESSION_POOR)
			return impression_text_poor
	return null

/**
 * The examine line for looks and impression together, or null when both are ordinary.
 *
 * Arguments:
 *   looks      - 1 beautiful, -1 ugly, 0 neither
 *   impression - an IMPRESSION_* value
 *   P          - the examine pronoun list
 */
/mob/living/carbon/proc/get_appeal_line(looks, impression, list/P)
	var/custom_line = get_custom_impression_line(impression)
	if(custom_line)
		custom_line = html_encode(custom_line)
		switch(impression)
			if(IMPRESSION_STRONG)
				return span_rose(custom_line)
			if(IMPRESSION_POOR)
				return span_necrosis(custom_line)
		return span_info(custom_line)

	var/beauty_desc = "gorgeous"
	if(pronouns == SHE_HER)
		beauty_desc = "beautiful"
	else if(pronouns == HE_HIM)
		beauty_desc = "handsome"

	if(looks > 0)
		switch(impression)
			if(IMPRESSION_STRONG)
				return span_rose("[P[THEYRE]] [beauty_desc], and [P[THEIR]] bearing only makes it harder to look away!")
			if(IMPRESSION_POOR)
				return span_rose("[P[THEYRE]] [beauty_desc], but [P[THEIR]] beauty is marred by an absolutely awful demeanor.")
		return span_rose("[P[THEYRE]] [beauty_desc]!")
	if(looks < 0)
		switch(impression)
			if(IMPRESSION_STRONG)
				return span_necrosis("[P[THEYRE]] hideous, yet [P[THEIR]] bearing makes it easy to forget.")
			if(IMPRESSION_POOR)
				return span_necrosis("[P[THEYRE]] hideous, and [P[THEIR]] foul demeanor only makes it worse!")
		return span_necrosis("[P[THEYRE]] hideous!")
	switch(impression)
		if(IMPRESSION_STRONG)
			return span_rose("[P[THEYVE]] a presence that fills the room.")
		if(IMPRESSION_POOR)
			return span_necrosis("[P[THEYVE]] a sour, graceless manner about [P[THEM]].")
	return null

/// The mood an examiner gets from looks and impression together. A strong impression cancels an ugly face and the reverse.
/mob/living/carbon/proc/get_appeal_stress_event(looks, impression, self_inspect)
	var/appeal = looks + impression
	if(appeal > 0)
		if(looks > 0)
			return self_inspect ? /datum/stress_event/beautiful_self : /datum/stress_event/beautiful
		return self_inspect ? null : /datum/stress_event/charming
	if(appeal < 0)
		if(looks < 0)
			return self_inspect ? /datum/stress_event/ugly_self : /datum/stress_event/ugly
		return self_inspect ? null : /datum/stress_event/offputting
	return null
