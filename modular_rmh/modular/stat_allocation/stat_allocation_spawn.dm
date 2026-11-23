// Character creator stats: putting the saved choices and the origin's bonuses on a spawned character.

/mob/living/carbon/human
	/// TRUE once creator stats were applied. Species sheets, job stats and the spawn roll then leave the stats alone.
	var/creator_stats = FALSE
	/// What the creator added to each raw stat: stat typepath = amount. A second application undoes it first.
	var/list/creator_stat_deltas
	/// Skill levels the origin added: skill typepath = amount. A second application undoes them first.
	var/list/origin_skill_deltas
	/// The player's own examine lines, one per impression: strong, ordinary and poor Charisma.
	var/impression_text_strong
	var/impression_text_ordinary
	var/impression_text_poor

/mob/living/carbon/human/uses_creator_stats()
	return creator_stats

/// Runs in apply_prefs_to() for real bodies. The sandbox editors and preview dolls have no stats to set.
/datum/preferences/proc/apply_stat_allocation_to_human(mob/living/carbon/human/character)
	if(!ishuman(character) || istype(character, /mob/living/carbon/human/dummy) || !character_creator_active())
		return
	validate_stat_allocation()
	var/datum/culture/origin = character.culture
	if(ispath(origin))
		origin = GLOB.culture_singletons[origin]

	// With the option on, what the player left unspent is spread at random, the same way for the whole round.
	var/list/old_roll = stat_alloc_roll
	var/list/spread = stat_alloc_auto ? stat_alloc_round_spread() : null
	var/list/values = spread ? spread["values"] : stat_allocation
	var/major = spread ? spread["major"] : stat_bonus_major
	var/minor = spread ? spread["minor"] : stat_bonus_minor

	var/list/deltas = list()
	for(var/stat_key in GLOB.stat_alloc_keys)
		var/stat_type = GLOB.stat_alloc_keys[stat_key]
		var/bonus = (stat_key == major) ? STAT_ALLOC_BONUS_MAJOR : ((stat_key == minor) ? STAT_ALLOC_BONUS_MINOR : 0)
		// Origin stats go into the raw value: a modifier would count as a debuff against governed skills.
		deltas[stat_type] = values[stat_key] + bonus + (LAZYACCESS(origin?.stat_bonuses, stat_type) || 0) - ATTRIBUTE_DEFAULT
	character.set_creator_stats(deltas)
	character.set_origin_bonuses(origin)
	character.impression_text_strong = impression_text_strong
	character.impression_text_ordinary = impression_text_ordinary
	character.impression_text_poor = impression_text_poor

	if(!parent)
		return
	if(spread)
		// Said once a round: a later body of the same character gets the same spread without the notice.
		if(stat_alloc_roll != old_roll)
			to_chat(parent, span_boldnotice("I left some of my stats to chance, and this round fate gave me [stat_alloc_spread_text(spread)]."))
			to_chat(parent, span_notice("I choose my stats, or turn the random spread off, in the Ability window of the character creator."))
		return
	var/unspent = stat_alloc_budget() - stat_alloc_spent()
	if(unspent > 0)
		to_chat(parent, span_warning("I have [unspent] unspent stat point\s. They are spent in the Ability window of the character creator."))

/// Replaces the stats the creator gave this body. deltas is stat typepath = change from the default.
/mob/living/carbon/human/proc/set_creator_stats(list/deltas)
	if(!attributes)
		return
	if(!creator_stats)
		// The species added its sheets when the body was made. Forms a character changes into keep theirs.
		if(dna?.species && !dna.species.forced_attribute_sheets)
			dna.species.remove_attribute_sheets(src)
		creator_stats = TRUE
	var/list/raw_stats = attributes.raw_attribute_list
	for(var/stat_type in creator_stat_deltas)
		raw_stats[stat_type] -= creator_stat_deltas[stat_type]
	for(var/stat_type in deltas)
		raw_stats[stat_type] += deltas[stat_type]
	creator_stat_deltas = deltas
	attributes.update_attributes()

/// Replaces the skills and traits the origin gave this body. Origin stats are part of set_creator_stats().
/mob/living/carbon/human/proc/set_origin_bonuses(datum/culture/origin)
	for(var/skill_type in origin_skill_deltas)
		adjust_skill_level(skill_type, -origin_skill_deltas[skill_type], null, TRUE)
	origin_skill_deltas = null
	REMOVE_TRAITS_IN(src, ORIGIN_TRAIT)
	if(!istype(origin))
		return
	for(var/skill_type in origin.skill_bonuses)
		adjust_skill_level(skill_type, origin.skill_bonuses[skill_type], null, TRUE)
	origin_skill_deltas = LAZYCOPY(origin.skill_bonuses)
	for(var/trait in origin.granted_traits)
		ADD_TRAIT(src, trait, ORIGIN_TRAIT)
