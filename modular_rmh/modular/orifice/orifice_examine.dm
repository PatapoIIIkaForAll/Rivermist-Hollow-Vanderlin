// Words for the state of an opening: panel lines, menu hints and examine adjectives.

/// Short id for how open the hole is right now; the holes window translates it.
/datum/orifice/proc/get_stretch_id()
	if(gaped)
		return "gaping"
	var/ratio = get_stretch_ratio()
	if(ratio >= 1.3)
		return "wide"
	if(ratio >= 1.1)
		return "loosened"
	var/rest = get_rest_girth()
	var/list/steps = rest_steps
	if(rest <= steps[2])
		return "tight"
	if(rest >= steps[5])
		return "loose"
	return "snug"

/// Short adjective for how open the hole is right now.
/datum/orifice/proc/get_stretch_adjective()
	switch(get_stretch_id())
		if("gaping")
			return "gaping open"
		if("wide")
			return "stretched wide"
		if("loosened")
			return "loosened"
		if("tight")
			return "tight"
		if("loose")
			return "loose"
	return "snug"

/// Short id for how slick the hole is; the word doubles as the adjective.
/datum/orifice/proc/get_lube_id()
	var/lube = get_lube_level()
	if(lube >= LUBE_SLICK_LEVEL)
		return "slick"
	if(lube >= LUBE_DRY_LEVEL)
		return "damp"
	return "dry"

/datum/orifice/proc/get_lube_adjective()
	return get_lube_id()

/// Short id for soreness, or null while the hole is fine.
/datum/orifice/proc/get_soreness_id()
	switch(get_soreness_state())
		if(ORIFICE_STATE_SORE)
			return "sore"
		if(ORIFICE_STATE_RAW)
			return "raw"
		if(ORIFICE_STATE_OVERUSED)
			return "overused"
	return null

/datum/orifice/proc/get_soreness_adjective()
	switch(get_soreness_id())
		if("sore")
			return "sore"
		if("raw")
			return "chafed raw"
		if("overused")
			return "used past bearing"
	return null

/// First-person line for the scene panel.
/datum/orifice/proc/get_status_line()
	var/line = "My [opening_name] feels [get_stretch_adjective()] and [get_lube_adjective()]"
	var/sore = get_soreness_adjective()
	if(sore)
		line += ", and [sore]"
	return line + "."

/// Third-person adjectives for examine; empty when nothing stands out.
/datum/orifice/proc/get_examine_adjectives()
	. = list()
	if(gaped)
		. += "gaping open"
	else if(get_stretch_ratio() >= 1.1)
		. += "stretched loose"
	if(get_lube_level() >= LUBE_SLICK_LEVEL)
		. += "glistening slick"
	var/sore = get_soreness_adjective()
	if(sore)
		. += "red and [sore]"

/// Menu hint for pushing [girth] in right now.
/datum/orifice/proc/get_fit_hint(girth)
	if(get_soreness_state() >= ORIFICE_STATE_OVERUSED)
		return "too sore"
	if(girth > get_max_girth())
		return "won't fit"
	var/hint
	if(gaped)
		hint = "gaping"
	else
		var/fit = get_fit(girth)
		if(girth > get_comfort_girth())
			hint = (get_lube_level() >= LUBE_FORCE_SUBSTITUTE_LEVEL || get_current_girth() >= girth * ORIFICE_OPEN_ENOUGH_RATIO) ? "tight, will stretch" : "needs lube or force"
		else if(fit < 0.6)
			hint = "loose"
		else
			hint = "snug"
	if(get_dryness_multiplier() >= ORIFICE_DRY_WARNING_MULT)
		hint += ", dry"
	if(!gaped && get_gape_strain() >= ORIFICE_GAPE_WARN_STRAIN)
		hint += ", gaping soon"
	return hint

/// Panel lines for every opening that has been used this round.
/mob/living/carbon/human/proc/get_orifice_status_lines()
	. = list()
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		var/obj/item/organ/genitals/filling_organ/hole = getorganslot(slot)
		if(!istype(hole) || !hole.orifice)
			continue
		. += get_character_information_line(hole.orifice.get_status_line())
