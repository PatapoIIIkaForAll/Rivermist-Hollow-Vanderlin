/*
 * MOB LIVING - STAT SYSTEM (attribute_holder migration)
 *
 * WHAT CHANGED:
 *   Old                          New
 *   ──────────────────────────   ──────────────────────────────────────────
 *   base_strength (var)          raw_attribute_list[STAT_STRENGTH]
 *   modified_strength (var)      handled by attribute_modifier datums
 *   STASTR (final cached var)    attribute_list[STAT_STRENGTH]
 *   UPDATE_STRENGTH() macro      update_attributes() on attribute_holder
 *   stat_modifiers lazy list     attribute_modification lazy list
 *
 *   set_stat_modifier()    ->    applies a named attribute_modifier
 *   adjust_stat_modifier() ->    adjusts an existing named attribute_modifier
 *   remove_stat_modifier() ->    removes a named attribute_modifier
 *
 * READING A STAT:
 *   Final (with modifiers):   GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH)
 *   Base (raw, no modifiers): GET_MOB_ATTRIBUTE_VALUE_RAW(src, STAT_STRENGTH)
 *
 * NOTE: stat_modifiers, base_*, modified_*, and STA* vars are all gone.
 *       Do not reference them. Use the macros above everywhere.
 */

// Variable modifier subtype used for all runtime stat modifiers (species, age, roll, etc.)
// Must be variable = TRUE so it is never cached - each instance is unique per mob.
/datum/attribute_modifier/variable
	variable = TRUE

/mob/living
	var/datum/patron/patron = null
	var/final/STASTR = 10
	var/final/STAPER = 10
	var/final/STAEND = 10
	var/final/STACON = 10
	var/final/STAINT = 10
	var/final/STASPD = 10
	var/final/STALUC = 10
	var/has_rolled_for_stats = FALSE

/mob/living/proc/init_faith()
	patron = GLOB.patron_list[/datum/patron/godless/godless]

/mob/living/proc/set_patron(datum/patron/new_patron, check_antag = FALSE)
	if(!new_patron)
		return FALSE
	if(check_antag && mind?.special_role)
		return FALSE
	if(ispath(new_patron))
		new_patron = GLOB.patron_list[new_patron]
	if(!istype(new_patron))
		return FALSE
	if(patron && !ispath(patron))
		patron.on_remove(src)
		mana_pool?.remove_attunements(patron)
	patron = new_patron
	patron.on_gain(src)
	mana_pool?.set_attunements(patron)
	return TRUE

/mob/living/proc/sync_legacy_stat_cache()
	STASTR = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH))
	STAPER = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_PERCEPTION))
	STAEND = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_ENDURANCE))
	STACON = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_CONSTITUTION))
	STAINT = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_INTELLIGENCE))
	STASPD = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_SPEED))
	STALUC = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_FORTUNE))

/**
 * Rolls random stats (base 10, +-1) for SPECIAL, applies species and age modifiers.
 * Stats are written directly into raw_attribute_list via attributes.
 * Modifiers (species, age, traits) go through set_stat_modifier() as named sources.
 */

/datum/attribute_holder/sheet/age
	attribute_default = 0
	skill_default = null

/datum/attribute_holder/sheet/age/old
	raw_attribute_list = list(
		STAT_STRENGTH     = -2,
		STAT_PERCEPTION   = 2,
		STAT_ENDURANCE    = -1,
		STAT_CONSTITUTION = -1,
		STAT_INTELLIGENCE = 2,
		STAT_SPEED        = -1,
		STAT_FORTUNE      = 1,
	)

/datum/attribute_holder/sheet/age/middleaged
	raw_attribute_list = list(
		STAT_ENDURANCE = 1,
		STAT_SPEED     = -1,
	)

/datum/attribute_holder/sheet/job/random_stats
	attribute_variance = list(
		STAT_STRENGTH = list(-1, 1),
		STAT_PERCEPTION = list(-1, 1),
		STAT_ENDURANCE = list(-1, 1),
		STAT_CONSTITUTION = list(-1, 1),
		STAT_INTELLIGENCE = list(-1, 1),
		STAT_SPEED = list(-1, 1),
		STAT_FORTUNE = list(-1, 1),
		STAT_CHARISMA = list(-1, 1),
	)

/// TRUE for characters whose stats come from the character creator: jobs and the spawn roll leave them alone.
/mob/living/proc/uses_creator_stats()
	return FALSE

/mob/living/proc/roll_mob_stats()
	if(has_rolled_for_stats)
		return FALSE

	if(!uses_creator_stats())
		attributes?.add_sheet(/datum/attribute_holder/sheet/job/random_stats)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		switch(H.age)
			if(AGE_MIDDLEAGED)
				set_stat_modifier(STATMOD_AGE, STATKEY_END, 1)
				set_stat_modifier(STATMOD_AGE, STATKEY_SPD, -1)
			if(AGE_OLD)
				set_stat_modifier(STATMOD_AGE, STATKEY_STR, -2)
				set_stat_modifier(STATMOD_AGE, STATKEY_PER, 2)
				set_stat_modifier(STATMOD_AGE, STATKEY_END, -1)
				set_stat_modifier(STATMOD_AGE, STATKEY_CON, -1)
				set_stat_modifier(STATMOD_AGE, STATKEY_INT, 2)
				set_stat_modifier(STATMOD_AGE, STATKEY_SPD, -1)
				set_stat_modifier(STATMOD_AGE, STATKEY_LCK, 1)

		if(HAS_TRAIT(src, TRAIT_PUNISHMENT_CURSE))
			set_stat_modifier(STATMOD_CURSE, list(
				STAT_STRENGTH     = -3,
				STAT_SPEED        = -3,
				STAT_ENDURANCE    = -3,
				STAT_CONSTITUTION = -3,
				STAT_INTELLIGENCE = -3,
				STAT_FORTUNE      = -3,
			))
			H.voice_color = "c71d76"
			H.set_eye_color("#c71d76", updates_dna = TRUE) //majenta

	has_rolled_for_stats = TRUE
	return TRUE

/mob/living/carbon/human/proc/update_age_stats(old_age, only_remove = FALSE)
	if(has_rolled_for_stats && old_age)
		switch(old_age)
			if(AGE_MIDDLEAGED)
				attributes?.subtract_sheet(/datum/attribute_holder/sheet/age/middleaged)
			if(AGE_OLD)
				attributes?.subtract_sheet(/datum/attribute_holder/sheet/age/old)
	if(only_remove)
		return
	switch(age)
		if(AGE_MIDDLEAGED)
			attributes?.add_sheet(/datum/attribute_holder/sheet/age/middleaged)
		if(AGE_OLD)
			attributes?.add_sheet(/datum/attribute_holder/sheet/age/old)


/**
 * Applies or replaces a named stat modifier block.
 * Equivalent to the old set_stat_modifier() but takes stat typepaths
 * instead of STATKEY_* strings, matching attribute_holder's language.
 *
 * Arguments:
 *   source     - string key identifying the source (e.g. STATMOD_AGE)
 *   stat_list  - associative list of STAT_* typepath = integer amount
 *                pass null or empty list to remove the source entirely
 */
/mob/living/proc/set_stat_modifier(source, stat_or_list, amount = null)
	if(!source || !attributes)
		return
	if(source == STATMOD_JOB && uses_creator_stats())
		return

	var/list/stat_list
	if(islist(stat_or_list))
		stat_list = normalize_attribute_stat_list(stat_or_list)
	else
		var/stat_path = legacy_attribute_stat_path(stat_or_list)
		if(!stat_path || !isnum(amount))
			return
		stat_list = list((stat_path) = amount)

	// Remove the old modifier for this source if it exists (keyed by source string as ID)
	attributes.remove_attribute_modifier(source)
	if(!LAZYLEN(stat_list))
		return
	// Build a variable modifier so it won't be cached - stat modifiers are always per-instance
	var/datum/attribute_modifier/variable/mod = new()
	mod.id = source
	for(var/stat_type in stat_list)
		if(!ispath(stat_type, STAT))
			continue
		var/amt = stat_list[stat_type]
		if(!amt)
			continue
		LAZYSET(mod.attribute_list, stat_type, amt)
	attributes.add_attribute_modifier(mod)

/mob/living/proc/set_stat_modifier_list(source, stat_keys_values)
	set_stat_modifier(source, stat_keys_values)

/**
 * Adjusts an existing named stat modifier, adding delta values on top.
 * If no modifier for this source exists yet, creates one.
 *
 * Arguments:
 *   source    - string ID of the modifier to adjust
 *   stat_list - associative list of STAT_* typepath = integer delta
 */
/mob/living/proc/adjust_stat_modifier(source, stat_or_list, amount = null)
	if(!source || !attributes)
		return
	if(source == STATMOD_JOB && uses_creator_stats())
		return

	var/list/stat_list
	if(islist(stat_or_list))
		stat_list = normalize_attribute_stat_list(stat_or_list)
	else
		var/stat_path = legacy_attribute_stat_path(stat_or_list)
		if(!stat_path || !isnum(amount))
			return
		stat_list = list((stat_path) = amount)

	if(!LAZYLEN(stat_list))
		return
	var/datum/attribute_modifier/existing = LAZYACCESS(attributes.attribute_modification, source)
	if(!existing)
		set_stat_modifier(source, stat_list)
		return
	for(var/stat_type in stat_list)
		if(!ispath(stat_type, STAT))
			continue
		var/amt = stat_list[stat_type]
		if(!amt)
			continue
		LAZYADDASSOC(existing.attribute_list, stat_type, amt)
	attributes.update_attributes()

/mob/living/proc/adjust_stat_modifier_list(source, stat_keys_values)
	adjust_stat_modifier(source, stat_keys_values)

/**
 * Removes all stat modifiers from a named source.
 *
 * Arguments:
 *   source - string ID to remove (e.g. STATMOD_AGE)
 */
/mob/living/proc/remove_stat_modifier(source)
	if(!source || !attributes)
		return
	attributes.remove_attribute_modifier(source)

/**
 * Sets a stat to a specific total value by back-calculating the modifier needed.
 * Equivalent to the old modifier_set_stat_to().
 *
 * Arguments:
 *   source - string ID for the modifier source
 *   stat   - STAT_* typepath
 *   value  - desired final value (clamped to ATTRIBUTE_MIN/MAX)
 */
/mob/living/proc/modifier_set_stat_to(source, stat, value)
	if(!source || !stat || isnull(value))
		return
	var/stat_path = legacy_attribute_stat_path(stat)
	if(!stat_path)
		return
	var/current_base = nulltozero(GET_MOB_ATTRIBUTE_VALUE_RAW(src, stat_path))
	var/needed = clamp(value, ATTRIBUTE_MIN, ATTRIBUTE_MAX) - current_base
	set_stat_modifier(source, stat_path, needed)

/**
 * Returns all current stat values as an associative list keyed by STAT_* typepath.
 * Uses the final (modifier-inclusive) attribute_list values.
 */
/mob/living/proc/get_all_stats()
	RETURN_TYPE(/list)
	return list(
		STAT_STRENGTH     = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH)),
		STAT_PERCEPTION   = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_PERCEPTION)),
		STAT_ENDURANCE    = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_ENDURANCE)),
		STAT_CONSTITUTION = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_CONSTITUTION)),
		STAT_INTELLIGENCE = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_INTELLIGENCE)),
		STAT_SPEED        = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_SPEED)),
		STAT_FORTUNE      = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_FORTUNE)),
		STAT_CHARISMA     = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_CHARISMA)),
	)

/**
 * Returns a single stat's final value by STAT_* typepath.
 */
/mob/living/proc/get_stat(stat)
	if(!stat)
		return
	var/stat_path = legacy_attribute_stat_path(stat)
	if(!stat_path)
		return
	return nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, stat_path))

/**
 * Returns the difference between our stat and an opponent's stat.
 * Both sides use the same stat key.
 * e.g. our endurance - their endurance.
 */
/mob/living/proc/stat_difference_to(mob/living/opponent, stat)
	if(!opponent || !stat)
		return
	var/stat_path = legacy_attribute_stat_path(stat)
	if(!stat_path)
		return
	return nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, stat_path)) - nulltozero(GET_MOB_ATTRIBUTE_VALUE(opponent, stat_path))

/**
 * Returns the difference between our stat and an opponent's (possibly different) stat.
 * e.g. our STR vs their CON.
 */
/mob/living/proc/stat_compare(mob/living/opponent, our_stat, opp_stat)
	if(!opponent || !our_stat || !opp_stat)
		return
	var/our_stat_path = legacy_attribute_stat_path(our_stat)
	var/opp_stat_path = legacy_attribute_stat_path(opp_stat)
	if(!our_stat_path || !opp_stat_path)
		return
	return nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, our_stat_path)) - nulltozero(GET_MOB_ATTRIBUTE_VALUE(opponent, opp_stat_path))

/**
 * Probability roll weighted by a stat value.
 * chance_per_point: % chance added per point of stat (default 5, so 10 stat = 50% base)
 * dee_cee: difficulty modifier applied before the roll
 * invert_dc: if TRUE, uses (dc - stat) instead of (stat - dc)
 */
/mob/living/proc/stat_roll(stat, chance_per_point = 5, dee_cee = null, invert_dc = FALSE)
	if(!stat)
		return FALSE
	var/stat_path = legacy_attribute_stat_path(stat)
	if(!stat_path)
		return FALSE
	var/tocheck = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, stat_path))
	if(invert_dc)
		return isnull(dee_cee) ? prob(tocheck * chance_per_point) : prob(clamp((dee_cee - tocheck) * chance_per_point, 0, 100))
	return isnull(dee_cee) ? prob(tocheck * chance_per_point) : prob(clamp((tocheck - dee_cee) * chance_per_point, 0, 100))

/**
 * Returns the final value of a stat by STAT_* typepath.
 * Identical to get_stat() - kept for call-site compatibility.
 */
/mob/living/proc/get_stat_level(stat)
	return get_stat(stat)

/**
 * Returns TRUE (probabilistically) if the mob is unlucky.
 * Chance scales with how far fortune is below 10.
 */
/mob/living/proc/badluck(multi = 3)
	var/fortune = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_FORTUNE))
	if(fortune < 10)
		return prob((10 - fortune) * multi)

/**
 * Returns TRUE (probabilistically) if the mob is lucky.
 * Chance scales with how far fortune is above 10.
 */
/mob/living/proc/goodluck(multi = 3)
	var/fortune = nulltozero(GET_MOB_ATTRIBUTE_VALUE(src, STAT_FORTUNE))
	if(fortune > 10)
		return prob((fortune - 10) * multi)

/**
 * DEPRECATED: Legacy wrapper. Use adjust_stat_modifier() directly.
 * Kept so existing call sites don't crash before they're updated.
 */
/mob/living/proc/change_stat(stat, adjust_amount)
	if(!stat || !adjust_amount)
		return
	adjust_stat_modifier("legacy_change_stat", list((stat) = adjust_amount))

/**
 * Recomputes all final stat values from raw_attribute_list + attribute_modification.
 * Equivalent to the old recalculate_stats(). Thin wrapper around update_attributes().
 */
/mob/living/proc/recalculate_stats()
	attributes?.update_attributes()

/**
 * Resets all stats to default (10), clears all modifiers, then re-rolls.
 */
/mob/living/proc/reset_and_reroll_stats()
	if(!attributes)
		return
	// Raw stat values are always 10 - variance, species, age etc. are all modifiers.
	// Snapshot the keys first - remove_attribute_modifier modifies the list in place
	// so iterating it directly while removing would skip entries.
	var/list/to_remove = LAZYCOPY(attributes.attribute_modification)
	for(var/mod_id in to_remove)
		attributes.remove_attribute_modifier(mod_id, FALSE)
	attributes.update_attributes()
	// Re-roll
	has_rolled_for_stats = FALSE
	roll_mob_stats()
