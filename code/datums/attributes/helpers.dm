// This is stupid and inefficient and should be defines, but i don't want to type every argument out, every time
/proc/canonical_skill_type(skill_type)
	if(isnull(skill_type))
		return null

	var/text_path = "[skill_type]"
	if(findtext(text_path, "/datum/skill/"))
		switch(skill_type)
			if(/datum/skill/combat/axes, /datum/skill/combat/maces)
				return /datum/attribute/skill/combat/axesmaces

		var/translated_path = text2path(replacetext(text_path, "/datum/skill/", "/datum/attribute/skill/"))
		if(ispath(translated_path, SKILL))
			return translated_path
		return null

	if(ispath(skill_type, SKILL))
		return skill_type
	return null

/proc/canonical_attribute_type(attribute_type)
	var/canonical_skill = canonical_skill_type(attribute_type)
	if(canonical_skill)
		return canonical_skill

	var/canonical_stat = legacy_attribute_stat_path(attribute_type)
	if(canonical_stat)
		return canonical_stat

	return attribute_type

/proc/legacy_attribute_stat_path(stat_key)
	switch(stat_key)
		if(STATKEY_STR)
			return STAT_STRENGTH
		if(STATKEY_PER)
			return STAT_PERCEPTION
		if(STATKEY_INT)
			return STAT_INTELLIGENCE
		if(STATKEY_CON)
			return STAT_CONSTITUTION
		if(STATKEY_END)
			return STAT_ENDURANCE
		if(STATKEY_SPD)
			return STAT_SPEED
		if(STATKEY_LCK)
			return STAT_FORTUNE
		if(STATKEY_CHA)
			return STAT_CHARISMA
	if(ispath(stat_key, STAT))
		return stat_key
	return null

/proc/normalize_attribute_stat_list(list/stat_list)
	if(!LAZYLEN(stat_list))
		return null

	var/list/normalized = list()
	for(var/stat_key in stat_list)
		var/stat_path = legacy_attribute_stat_path(stat_key)
		if(!stat_path)
			continue

		var/amount = stat_list[stat_key]
		if(!isnum(amount))
			continue

		normalized[stat_path] = amount
	return normalized

/mob/proc/diceroll(requirement = 0, crit = 10, dice_num = 3, dice_sides = 6, count_modifiers = TRUE, context = DICE_CONTEXT_DEFAULT, return_flags = RETURN_DICE_SUCCESS)
	return attributes ? attributes.diceroll(requirement, crit, dice_num, dice_sides, count_modifiers, context, return_flags) : DICE_FAILURE

/mob/proc/attribute_probability(modifier = ATTRIBUTE_MIDDLING, base_prob = 50, delta_value = ATTRIBUTE_MIDDLING, increment = 5)
	return attributes ? attributes.attribute_probability(modifier, base_prob, delta_value, increment) : base_prob

/**
 *
 * Example (unchanged call site):
 *   blade.clamped_adjust_skill_level(/datum/attribute/skill/combat/swords, 20, 40)
 *   -> raises skill by up to 20, capped at level 40 (expert)
 */
/mob/proc/clamped_adjust_skill_level(skill_type, amt, max, silent = FALSE)
	attributes?.adjust_skill_level(skill_type, amt, max, silent)

/mob/proc/get_skill_exp_multiplier(skill_type)
	return attributes?.get_skill_xp_multiplier(skill_type)

/mob/proc/set_skill_exp_multiplier(skill_type, multiplier)
	attributes?.set_skill_xp_multiplier(skill_type, multiplier)

/mob/proc/adjust_skill_exp_multiplier(skill_type, amount)
	attributes?.adjust_skill_xp_multiplier(skill_type, amount)

/mob/proc/remove_skill_exp_multiplier(skill_type)
	attributes?.remove_skill_xp_multiplier(skill_type)

/**
 * Returns the raw XP accumulated toward a skill (useful for UI/debug).
 */
/mob/proc/get_skill_xp(skill_type)
	return attributes?.get_skill_xp(skill_type)

/**
 * Returns the learning boon multiplier for a skill (age/trait modifier).
 * Multiply your XP grant by this if you want age to affect training speed.
 */
/mob/proc/get_learning_boon(skill_type)
	return attributes?.get_learning_boon(skill_type)

/**
 * Prints all current skill levels to the mob's chat.
 */
/mob/proc/print_skill_levels()
	attributes?.print_skills(src)

/**
 * Awards XP toward a skill, converting it into level gains automatically.
 * This is the standard call site for in-game skill training.
 *
 * Arguments:
 *   skill_type       - typepath of the /datum/attribute/skill
 *   amount           - XP to award
 *   silent           - suppress level-up messages
 *   check_apprentice - share XP with nearby apprentices
 */
/mob/proc/adjust_experience(skill_type, amount, silent = FALSE, check_apprentice = TRUE, daily_xp = TRUE)
	if(HAS_TRAIT(src, TRAIT_NO_EXPERIENCE))
		return FALSE
	return attributes?.adjust_experience(skill_type, amount, silent, check_apprentice, daily_xp = daily_xp)

/**
 * Adjusts a skill by a delta in the new 0-60 range, with an optional cap.
 *
 * Arguments:
 *   skill_type - typepath of the skill
 *   delta      - levels to add or remove (e.g. +5, -10)
 *   max_level  - optional ceiling in 0-60 range; null = no cap
 *   silent     - suppress messages
 */
/mob/proc/adjust_skill_level(skill_type, delta, max_level = null, silent = FALSE)
	attributes?.adjust_skill_level(skill_type, delta, max_level, silent)

/**
 * Wipes all skill levels and XP back to zero.
 */
/mob/proc/purge_all_skills(silent = TRUE)
	attributes?.purge_all_skills(silent)
