// Character creator stats: the saved choices, their rules, and the creator's data and actions.

/// Stats a player sets in the creator, in menu order: save key = stat typepath.
GLOBAL_LIST_INIT(stat_alloc_keys, list(
	STATKEY_STR = STAT_STRENGTH,
	STATKEY_SPD = STAT_SPEED,
	STATKEY_CON = STAT_CONSTITUTION,
	STATKEY_INT = STAT_INTELLIGENCE,
	STATKEY_PER = STAT_PERCEPTION,
	STATKEY_CHA = STAT_CHARISMA,
	STATKEY_END = STAT_ENDURANCE,
	STATKEY_LCK = STAT_FORTUNE,
))

/datum/preferences
	/// Stat values bought with points: save key = value before the bonuses.
	var/list/stat_allocation
	/// Save key of the stat that takes the larger bonus, or null.
	var/stat_bonus_major
	/// Save key of the stat that takes the smaller bonus, or null.
	var/stat_bonus_minor
	/// The player's own examine lines, one per impression: strong, ordinary and poor Charisma. Null uses the standard line.
	var/impression_text_strong
	var/impression_text_ordinary
	var/impression_text_poor
	/// TRUE: points and bonuses the player left unspent are spread at random when the character spawns.
	var/stat_alloc_auto = TRUE
	/// The random spread of this round and the saved choices it was made for. Never saved.
	var/list/stat_alloc_roll

/// Points it takes to raise one stat from the free value to this value.
/proc/stat_alloc_cost(value)
	value = min(value, STAT_ALLOC_BUY_MAX)
	if(value <= STAT_ALLOC_FREE)
		return 0
	return (value - STAT_ALLOC_FREE) + max(0, value - STAT_ALLOC_STEEP_ABOVE)

/// One line of plain text, cut to the length limit. Null when nothing is left.
/proc/impression_clean_text(text)
	if(!istext(text))
		return null
	text = trim(replacetext(text, "\n", " "))
	text = copytext_char(text, 1, IMPRESSION_TEXT_MAX + 1)
	return length(text) ? text : null

/datum/preferences/proc/stat_alloc_value(stat_key)
	var/value = LAZYACCESS(stat_allocation, stat_key)
	return isnum(value) ? value : STAT_ALLOC_DEFAULT

/datum/preferences/proc/stat_alloc_bonus(stat_key)
	if(stat_key == stat_bonus_major)
		return STAT_ALLOC_BONUS_MAJOR
	if(stat_key == stat_bonus_minor)
		return STAT_ALLOC_BONUS_MINOR
	return 0

/datum/preferences/proc/stat_alloc_budget()
	return STAT_ALLOC_BUDGET + (pref_species?.creator_stat_points || 0)

/datum/preferences/proc/stat_alloc_spent()
	. = 0
	for(var/stat_key in GLOB.stat_alloc_keys)
		. += stat_alloc_cost(stat_alloc_value(stat_key))

/// What the chosen origin adds to one stat.
/datum/preferences/proc/stat_alloc_origin_bonus(stat_type)
	var/datum/culture/origin = GLOB.culture_singletons[read_preference(/datum/preference/choiced/culture)]
	return LAZYACCESS(origin?.stat_bonuses, stat_type) || 0

/// Brings the saved choices inside the rules. Runs after a load, an import, a species change and before a spawn.
/datum/preferences/proc/validate_stat_allocation()
	var/list/clean = list()
	for(var/stat_key in GLOB.stat_alloc_keys)
		var/value = LAZYACCESS(stat_allocation, stat_key)
		clean[stat_key] = isnum(value) ? clamp(round(value), STAT_ALLOC_FLOOR, STAT_ALLOC_BUY_MAX) : STAT_ALLOC_DEFAULT
	stat_allocation = clean

	// A smaller budget, such as after a change of species, takes points back from the highest stat first.
	var/budget = stat_alloc_budget()
	while(stat_alloc_spent() > budget)
		var/highest_key
		for(var/stat_key in stat_allocation)
			if(!highest_key || stat_allocation[stat_key] > stat_allocation[highest_key])
				highest_key = stat_key
		stat_allocation[highest_key]--

	if(!(stat_bonus_major in GLOB.stat_alloc_keys))
		stat_bonus_major = null
	if(!(stat_bonus_minor in GLOB.stat_alloc_keys) || stat_bonus_minor == stat_bonus_major)
		stat_bonus_minor = null
	impression_text_strong = impression_clean_text(impression_text_strong)
	impression_text_ordinary = impression_clean_text(impression_text_ordinary)
	impression_text_poor = impression_clean_text(impression_text_poor)

/datum/preferences/proc/reset_stat_allocation()
	stat_allocation = null
	stat_bonus_major = null
	stat_bonus_minor = null
	validate_stat_allocation()

/*
 * SAVEFILE
 */

/datum/preferences/load_character(slot)
	. = ..()
	stat_allocation = null
	stat_bonus_major = null
	stat_bonus_minor = null
	impression_text_strong = null
	impression_text_ordinary = null
	impression_text_poor = null
	stat_alloc_auto = TRUE
	stat_alloc_roll = null
	if(. && path)
		var/savefile/S = new /savefile(path)
		S.cd = "/character[default_slot]"
		var/raw
		S["stat_allocation"] >> raw
		if(istext(raw))
			stat_alloc_read(safe_json_decode(raw))
	validate_stat_allocation()

/datum/preferences/save_character()
	. = ..()
	if(!. || !path)
		return
	var/savefile/S = new /savefile(path)
	S.cd = "/character[default_slot]"
	WRITE_FILE(S["stat_allocation"], json_encode(stat_alloc_state()))

/// The saved choices as one list, for the savefile and the character export.
/datum/preferences/proc/stat_alloc_state()
	return list(
		"values" = stat_allocation || list(),
		"major" = stat_bonus_major,
		"minor" = stat_bonus_minor,
		"text_strong" = impression_text_strong,
		"text_ordinary" = impression_text_ordinary,
		"text_poor" = impression_text_poor,
		"auto" = stat_alloc_auto,
	)

/// Takes the choices from a saved or imported list. The caller validates afterwards.
/datum/preferences/proc/stat_alloc_read(list/state)
	if(!islist(state))
		return
	var/list/values = state["values"]
	stat_allocation = islist(values) ? values.Copy() : null
	stat_bonus_major = istext(state["major"]) ? state["major"] : null
	stat_bonus_minor = istext(state["minor"]) ? state["minor"] : null
	impression_text_strong = state["text_strong"]
	impression_text_ordinary = state["text_ordinary"]
	impression_text_poor = state["text_poor"]
	// A save from before the option existed has no entry and gets the default, on.
	stat_alloc_auto = isnull(state["auto"]) ? TRUE : !!state["auto"]

/*
 * RANDOM SPREAD
 */

/// Points one step up from this value costs.
/proc/stat_alloc_step_cost(value)
	return stat_alloc_cost(value + 1) - stat_alloc_cost(value)

/// The name players see for a stat save key.
/proc/stat_alloc_name(stat_key)
	var/datum/attribute/stat/stat = GET_ATTRIBUTE_DATUM(GLOB.stat_alloc_keys[stat_key])
	return stat ? stat.name : stat_key

/**
 * Spends the unspent points one random step at a time and puts each bonus not yet placed on a random stat.
 * The saved choices stay as they are. A stat the player set under the free value is left alone.
 *
 * Returns list("values" = save key to value, "major", "minor", "gains" = save key to points added),
 * or null when there was nothing to spread.
 */
/datum/preferences/proc/stat_alloc_random_spread()
	validate_stat_allocation()
	var/list/values = stat_allocation.Copy()
	var/list/gains = list()
	var/left = stat_alloc_budget() - stat_alloc_spent()
	while(left > 0)
		var/list/raisable = list()
		for(var/stat_key in values)
			var/value = values[stat_key]
			if(value >= STAT_ALLOC_FREE && value < STAT_ALLOC_BUY_MAX && stat_alloc_step_cost(value) <= left)
				raisable += stat_key
		if(!length(raisable))
			break
		var/picked = pick(raisable)
		left -= stat_alloc_step_cost(values[picked])
		values[picked]++
		gains[picked]++

	var/major = stat_bonus_major
	var/minor = stat_bonus_minor
	if(!major)
		major = pick(GLOB.stat_alloc_keys - minor)
	if(!minor)
		minor = pick(GLOB.stat_alloc_keys - major)
	if(!length(gains) && major == stat_bonus_major && minor == stat_bonus_minor)
		return null
	return list("values" = values, "major" = major, "minor" = minor, "gains" = gains)

/// The random spread for this round: made once, then used again while the saved choices stay the same.
/datum/preferences/proc/stat_alloc_round_spread()
	validate_stat_allocation()
	var/signature = json_encode(list(default_slot, stat_alloc_budget(), stat_allocation, stat_bonus_major, stat_bonus_minor))
	if(stat_alloc_roll?["signature"] == signature)
		return stat_alloc_roll["spread"]
	var/list/spread = stat_alloc_random_spread()
	stat_alloc_roll = list("signature" = signature, "spread" = spread)
	return spread

/// What a random spread added, as one phrase with the stats' own names.
/datum/preferences/proc/stat_alloc_spread_text(list/spread)
	var/list/parts = list()
	var/list/gains = spread["gains"]
	for(var/stat_key in GLOB.stat_alloc_keys)
		if(gains[stat_key])
			parts += "[stat_alloc_name(stat_key)] +[gains[stat_key]]"
	if(spread["major"] != stat_bonus_major)
		parts += "the +[STAT_ALLOC_BONUS_MAJOR] bonus on [stat_alloc_name(spread["major"])]"
	if(spread["minor"] != stat_bonus_minor)
		parts += "the +[STAT_ALLOC_BONUS_MINOR] bonus on [stat_alloc_name(spread["minor"])]"
	return english_list(parts)

/*
 * CHARACTER CREATOR
 */

/// The rules of the stat editor, the same for every character.
/proc/character_creator_stat_rules()
	var/static/list/rules = list(
		"floor" = STAT_ALLOC_FLOOR,
		"free" = STAT_ALLOC_FREE,
		"max" = STAT_ALLOC_BUY_MAX,
		"steep" = STAT_ALLOC_STEEP_ABOVE,
		"bonus_major" = STAT_ALLOC_BONUS_MAJOR,
		"bonus_minor" = STAT_ALLOC_BONUS_MINOR,
		"poor_max" = CHARISMA_POOR_MAX,
		"strong_min" = CHARISMA_STRONG_MIN,
		"text_max" = IMPRESSION_TEXT_MAX,
	)
	return rules

/// One row per stat: the bought value, what is added to it, and the point costs.
/datum/preferences/proc/character_creator_stats()
	. = list()
	var/age_sheet_type = character_setup_age_sheet_type(read_preference(/datum/preference/choiced/age))
	var/datum/attribute_holder/sheet/age_sheet
	if(age_sheet_type)
		age_sheet = GLOB.attribute_sheets[age_sheet_type] || (GLOB.attribute_sheets[age_sheet_type] = new age_sheet_type())
	for(var/stat_key in GLOB.stat_alloc_keys)
		var/stat_type = GLOB.stat_alloc_keys[stat_key]
		var/datum/attribute/stat/stat = GET_ATTRIBUTE_DATUM(stat_type)
		var/value = stat_alloc_value(stat_key)
		var/bonus = stat_alloc_bonus(stat_key)
		var/origin_value = stat_alloc_origin_bonus(stat_type)
		var/age_value = age_sheet?.raw_attribute_list[stat_type] || 0
		. += list(list(
			"key" = stat_key,
			"name" = stat ? stat.name : stat_key,
			"desc" = stat ? character_setup_chargen_clean_text(stat.desc, 600) : "",
			"icon" = stat ? "[stat.icon]" : null,
			"icon_state" = stat?.icon_state,
			"label" = stat ? stat.shorthand : stat_key,
			"value" = value,
			"bonus" = bonus,
			"origin" = origin_value,
			"age" = age_value,
			"total" = value + bonus + origin_value + age_value,
			"cost" = stat_alloc_cost(value),
			// Points the next step up costs; null at the top.
			"raise_cost" = value < STAT_ALLOC_BUY_MAX ? stat_alloc_cost(value + 1) - stat_alloc_cost(value) : null,
		))

/datum/preferences/proc/character_creator_stat_points()
	var/budget = stat_alloc_budget()
	var/spent = stat_alloc_spent()
	return list(
		"budget" = budget,
		"spent" = spent,
		"left" = budget - spent,
		"species" = pref_species?.creator_stat_points || 0,
		"major" = stat_bonus_major,
		"minor" = stat_bonus_minor,
		"text_strong" = impression_text_strong || "",
		"text_ordinary" = impression_text_ordinary || "",
		"text_poor" = impression_text_poor || "",
		"auto" = stat_alloc_auto,
	)

/// Handles the stat editor's actions. TRUE when a saved choice changed.
/datum/preferences/proc/character_creator_stat_act(mob/user, action, list/params)
	validate_stat_allocation()
	switch(action)
		if("cc_stat_set")
			var/stat_key = params["stat"]
			var/value = text2num("[params["value"]]")
			if(!(stat_key in GLOB.stat_alloc_keys) || !isnum(value))
				return FALSE
			value = clamp(round(value), STAT_ALLOC_FLOOR, STAT_ALLOC_BUY_MAX)
			var/old_value = stat_allocation[stat_key]
			if(value == old_value)
				return FALSE
			stat_allocation[stat_key] = value
			if(stat_alloc_spent() > stat_alloc_budget())
				stat_allocation[stat_key] = old_value
				return FALSE
			return TRUE
		if("cc_stat_bonus")
			var/stat_key = params["stat"]
			if(!(stat_key in GLOB.stat_alloc_keys))
				return FALSE
			// A second click takes the bonus off; a stat that holds the other bonus trades places.
			if(params["slot"] == "major")
				if(stat_bonus_major == stat_key)
					stat_bonus_major = null
					return TRUE
				if(stat_bonus_minor == stat_key)
					stat_bonus_minor = stat_bonus_major
				stat_bonus_major = stat_key
				return TRUE
			if(params["slot"] == "minor")
				if(stat_bonus_minor == stat_key)
					stat_bonus_minor = null
					return TRUE
				if(stat_bonus_major == stat_key)
					stat_bonus_major = stat_bonus_minor
				stat_bonus_minor = stat_key
				return TRUE
			return FALSE
		if("cc_stat_reset")
			reset_stat_allocation()
			return TRUE
		if("cc_stat_auto")
			stat_alloc_auto = !stat_alloc_auto
			return TRUE
		if("cc_stat_text")
			var/new_text = impression_clean_text(params["value"])
			switch(params["band"])
				if("strong")
					if(impression_text_strong == new_text)
						return FALSE
					impression_text_strong = new_text
				if("ordinary")
					if(impression_text_ordinary == new_text)
						return FALSE
					impression_text_ordinary = new_text
				if("poor")
					if(impression_text_poor == new_text)
						return FALSE
					impression_text_poor = new_text
				else
					return FALSE
			log_game("[key_name(user)] has set their [params["band"]] impression examine line.")
			return TRUE
	return FALSE
