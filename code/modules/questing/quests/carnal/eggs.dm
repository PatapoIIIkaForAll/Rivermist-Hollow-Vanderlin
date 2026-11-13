/// Bring unhatched eggs of an egg-laying creature back to the ledger.
/datum/quest/kill/carnal/eggs
	quest_type = QUEST_EGG_HARVEST
	mob_types_to_spawn = QUEST_CARNAL_EGG_LIST
	count_min = 2
	count_max = 3
	minimum_tier = QUEST_TIER_ROUTINE
	maximum_tier = QUEST_TIER_DEADLY
	/// OVI_EGG_* type the ledger accepts.
	var/required_egg_type
	var/eggs_required = 0

/datum/quest/kill/carnal/eggs/build_title()
	if(!required_egg_type)
		return "Recover a creature clutch"
	return "Recover a clutch of [LOWER_TEXT(get_oviposition_egg_type_option_name(required_egg_type))] eggs"

/datum/quest/kill/carnal/eggs/get_objective_text()
	var/egg_name = required_egg_type ? LOWER_TEXT(get_oviposition_egg_type_option_name(required_egg_type)) : "creature"
	return "Bring [eggs_required] [egg_name] eggs to the contract ledger, carried or on the marked area beside it, then turn the contract in. A [initial(target_mob_type.name)] that climaxes outside a body drops its eggs. Eggs laid in you count if removed before they ripen; ripe eggs hatch."

/datum/quest/kill/carnal/eggs/on_targets_spawned()
	required_egg_type = null
	for(var/datum/weakref/target_ref as anything in tracked_atoms)
		var/mob/living/target = target_ref.resolve()
		var/obj/item/organ/genitals/penis/ovipositor/ovipositor = target?.getorganslot(ORGAN_SLOT_PENIS)
		if(istype(ovipositor))
			required_egg_type = ovipositor.ovi_egg_type
			break
	if(!required_egg_type)
		return FALSE
	eggs_required = get_eggs_for_tier(requested_tier)
	progress_required = 1
	return TRUE

/// Each layer starts with one egg and grows more over a few minutes.
/datum/quest/kill/carnal/eggs/proc/get_eggs_for_tier(tier)
	switch(tier)
		if(QUEST_TIER_ROUTINE, QUEST_TIER_RISKY)
			return 2
		if(QUEST_TIER_DANGEROUS)
			return 3
	return 4

/datum/quest/kill/carnal/eggs/get_reward_multiplier()
	return QUEST_EGG_REWARD_MULTIPLIER

/datum/quest/kill/carnal/eggs/get_task_reward_bonus()
	return eggs_required * QUEST_EGG_REWARD_PER_EGG

/datum/quest/kill/carnal/eggs/proc/get_turn_in_eggs(turf/input_point, mob/user)
	. = list()
	if(!required_egg_type)
		return
	for(var/obj/item/oviposition_egg/egg as anything in find_turn_in_goods(input_point, user, /obj/item/oviposition_egg))
		if(egg.egg_type == required_egg_type)
			. += egg

/datum/quest/kill/carnal/eggs/uses_turn_in_goods()
	return TRUE

/datum/quest/kill/carnal/eggs/has_turn_in_goods(turf/input_point, mob/user)
	return length(get_turn_in_eggs(input_point, user)) >= eggs_required

/datum/quest/kill/carnal/eggs/get_turn_in_goods_report(turf/input_point, mob/user)
	var/egg_name = required_egg_type ? LOWER_TEXT(get_oviposition_egg_type_option_name(required_egg_type)) : "creature"
	return "The ledger counts [length(get_turn_in_eggs(input_point, user))] of [eggs_required] [egg_name] eggs on its marked area and on you. Eggs still inside a body do not count."

/datum/quest/kill/carnal/eggs/try_collect_turn_in_goods(turf/input_point, mob/user)
	var/list/eggs = get_turn_in_eggs(input_point, user)
	if(length(eggs) < eggs_required)
		return FALSE
	for(var/index in 1 to eggs_required)
		qdel(eggs[index])
	progress_current = progress_required
	mark_complete()
	return TRUE
