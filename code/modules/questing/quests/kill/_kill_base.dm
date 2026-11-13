// Base for kill quests
/datum/quest/kill
	var/list/mob_types_to_spawn = list()
	var/count_min = 1
	var/count_max = 3
	var/kill_component_type = /datum/component/quest_object/kill
	var/type_risk_bonus = 0
	var/target_risk_value = 0
	var/target_spawn_weight = 0
	var/target_group_min = 1
	var/target_group_max = 1

/mob/living/proc/setup_quest_spawn_lockdown()
	setup_equip_block()
	ADD_TRAIT(src, TRAIT_STUCKITEMS, QUEST_SPAWN_LOCK_TRAIT)
	ADD_TRAIT(src, TRAIT_NODISMEMBER, QUEST_SPAWN_LOCK_TRAIT)

	for(var/obj/item/locked_item in GetAllContents(/obj/item))
		ADD_TRAIT(locked_item, TRAIT_NODROP, QUEST_SPAWN_LOCK_TRAIT)
		// Locked gear can never come off, so it must not block ERP for the wearer or a partner.
		locked_item.allow_erp_equipped = TRUE
		var/datum/component/storage/storage = locked_item.GetComponent(/datum/component/storage)
		if(storage)
			storage.allow_look_inside = FALSE
			storage.locked = TRUE
			storage.close_all()

	if(istype(src, /mob/living/simple_animal))
		var/mob/living/simple_animal/quest_animal = src
		quest_animal.loot = list()
		quest_animal.butcher_results = null
		quest_animal.guaranteed_butcher_results = null
		quest_animal.botched_butcher_results = null
		quest_animal.perfect_butcher_results = null
		quest_animal.head_butcher = null

/datum/quest/kill/proc/get_mob_spawn_descriptor(mob_type)
	var/mob_descriptor = mob_types_to_spawn[mob_type]
	if(islist(mob_descriptor))
		return mob_descriptor
	if(isnum(mob_descriptor))
		return list(
			QUEST_MOB_SPAWN_WEIGHT = mob_descriptor,
			QUEST_MOB_RISK_VALUE = mob_descriptor,
			QUEST_MOB_GROUP_MIN = 1,
			QUEST_MOB_GROUP_MAX = 1,
		)
	return null

/datum/quest/kill/proc/get_mob_spawn_weight(mob_type)
	var/list/mob_descriptor = get_mob_spawn_descriptor(mob_type)
	if(!mob_descriptor)
		return 0
	return mob_descriptor[QUEST_MOB_SPAWN_WEIGHT] || 0

/datum/quest/kill/proc/get_mob_risk_value(mob_type)
	var/list/mob_descriptor = get_mob_spawn_descriptor(mob_type)
	if(!mob_descriptor)
		return 0
	return mob_descriptor[QUEST_MOB_RISK_VALUE] || 0

/datum/quest/kill/proc/get_mob_group_min(mob_type)
	var/list/mob_descriptor = get_mob_spawn_descriptor(mob_type)
	if(!mob_descriptor)
		return 1
	return max(1, mob_descriptor[QUEST_MOB_GROUP_MIN] || 1)

/datum/quest/kill/proc/get_mob_group_max(mob_type)
	var/list/mob_descriptor = get_mob_spawn_descriptor(mob_type)
	if(!mob_descriptor)
		return 1
	return max(get_mob_group_min(mob_type), mob_descriptor[QUEST_MOB_GROUP_MAX] || 1)

/datum/quest/kill/proc/get_target_rating_min_for_tier(tier)
	switch(tier)
		if(QUEST_TIER_ROUTINE)
			return 1
		if(QUEST_TIER_RISKY)
			return 3
		if(QUEST_TIER_DANGEROUS)
			return 4
		if(QUEST_TIER_DEADLY)
			return 6
		if(QUEST_TIER_LETHAL)
			return 8
		if(QUEST_TIER_MYTHIC)
			return 9
	return 1

/datum/quest/kill/proc/get_target_rating_max_for_tier(tier)
	switch(tier)
		if(QUEST_TIER_ROUTINE)
			return 3
		if(QUEST_TIER_RISKY)
			return 4
		if(QUEST_TIER_DANGEROUS)
			return 6
		if(QUEST_TIER_DEADLY)
			return 8
		if(QUEST_TIER_LETHAL)
			return 9
		if(QUEST_TIER_MYTHIC)
			return 20
	return 20

/datum/quest/kill/proc/get_mob_map_flags(mob_type)
	var/list/mob_descriptor = get_mob_spawn_descriptor(mob_type)
	if(!mob_descriptor)
		return QUEST_MAP_FLAG_ALL
	if(!(QUEST_MOB_MAP_FLAGS in mob_descriptor))
		return QUEST_MAP_FLAG_ALL
	return mob_descriptor[QUEST_MOB_MAP_FLAGS] || QUEST_MAP_FLAG_ALL

/datum/quest/kill/proc/get_candidate_target_pool(map_flag_filter)
	var/list/candidates = list()
	var/list/closest_candidates = list()
	var/best_gap = INFINITY
	var/min_rating = get_target_rating_min_for_tier(requested_tier)
	var/max_rating = get_target_rating_max_for_tier(requested_tier)

	for(var/mob_type in mob_types_to_spawn)
		var/rating = get_mob_risk_value(mob_type)
		var/spawn_weight = get_mob_spawn_weight(mob_type)
		if(rating <= 0 || spawn_weight <= 0)
			continue

		// Filter by map flags if a filter is provided
		if(map_flag_filter)
			var/mob_flags = get_mob_map_flags(mob_type)
			if(!(mob_flags & map_flag_filter))
				continue

		if(rating >= min_rating && rating <= max_rating)
			candidates[mob_type] = spawn_weight
			continue

		var/gap = rating < min_rating ? min_rating - rating : rating - max_rating
		if(gap < best_gap)
			best_gap = gap
			closest_candidates = list()
			closest_candidates[mob_type] = spawn_weight
		else if(gap == best_gap)
			closest_candidates[mob_type] = spawn_weight

	return length(candidates) ? candidates : closest_candidates

/datum/quest/kill/proc/cache_target_spawn_values()
	target_risk_value = get_mob_risk_value(target_mob_type)
	target_spawn_weight = get_mob_spawn_weight(target_mob_type)
	target_group_min = get_mob_group_min(target_mob_type)
	target_group_max = get_mob_group_max(target_mob_type)

/datum/quest/kill/proc/get_target_group_count()
	var/effective_min = max(count_min, target_group_min)
	var/effective_max = max(effective_min, min(count_max, target_group_max))
	return rand(effective_min, effective_max)

/datum/quest/kill/proc/spawn_kill_mobs(obj/effect/landmark/quest_spawner/landmark)
	var/map_flag = get_quest_map_flag_for_turf(get_turf(landmark))
	var/list/candidate_pool = get_candidate_target_pool(map_flag)
	if(!length(candidate_pool))
		return FALSE

	target_mob_type = pickweight(candidate_pool)
	cache_target_spawn_values()
	progress_required = get_target_group_count()
	target_spawn_area = get_area_name(get_turf(landmark))
	var/spawned_targets = 0

	// Spawn mobs
	for(var/i in 1 to progress_required)
		var/turf/spawn_turf = landmark.get_safe_spawn_turf()
		if(!spawn_turf)
			continue

		var/mob/living/new_mob = new target_mob_type(spawn_turf)
		new_mob.add_faction("quest")
		prepare_spawned_target(new_mob)
		new_mob.AddComponent(kill_component_type, src)
		new_mob.setup_quest_spawn_lockdown()
		ADD_TRAIT(new_mob, TRAIT_FRESHSPAWN, "[type]")
		addtimer(TRAIT_CALLBACK_REMOVE(new_mob, TRAIT_FRESHSPAWN, "[type]"), 60 SECONDS)
		addtimer(CALLBACK(new_mob, TYPE_PROC_REF(/mob/living, setup_quest_spawn_lockdown)), 3 SECONDS)
		if(istype(new_mob.ai_controller, /datum/ai_controller))
			new_mob.ai_controller.set_blackboard_key(BB_IDLE_LEASH_TURF, get_turf(landmark))
			new_mob.ai_controller.set_blackboard_key(BB_IDLE_LEASH_RANGE, QUEST_IDLE_LEASH_RANGE)
		add_tracked_atom(new_mob)
		if(quest_type != QUEST_BOSS)
			landmark.add_quest_faction_to_nearby_mobs(spawn_turf)
		spawned_targets++

	progress_required = spawned_targets
	return spawned_targets > 0

/// Subtype hook to adjust a freshly spawned target before its quest component and lockdown.
/datum/quest/kill/proc/prepare_spawned_target(mob/living/new_mob)
	return

/// A shared-board posting loses a target before anyone claims it, so the posting shrinks or lapses.
/datum/quest/kill/proc/on_posted_target_lost(mob/living/lost_target)
	remove_tracked_atom(lost_target)
	progress_required = max(progress_required - 1, 0)
	if(progress_required <= progress_current)
		expire_posting("its last target is gone")
		return
	reward_amount = calculate_reward(get_target_anchor_turf())
	deposit_amount = calculate_deposit(reward_amount)

/// A rune rescue would otherwise let the contractor retry the fight with a fresh body.
/datum/quest/kill/fails_on_rune_rescue(mob/living/carbon/rescued)
	return TRUE

/datum/quest/kill/get_risk_score(turf/target_turf)
	return target_risk_value + type_risk_bonus + round(max(progress_required - 1, 0) / 2)

/datum/quest/kill/proc/get_reward_multiplier()
	switch(quest_type)
		if(QUEST_RAID)
			return QUEST_RAID_REWARD_MULTIPLIER
		if(QUEST_CLEAR_OUT)
			return QUEST_CLEAR_OUT_REWARD_MULTIPLIER
	return QUEST_HUNT_REWARD_MULTIPLIER

/datum/quest/kill/calculate_reward(turf/target_turf)
	var/risk_score = max(1, ROUND_UP(get_risk_score(target_turf)))
	threat_tier = get_tier_from_risk_score(risk_score)

	var/total_target_risk = max(1, target_risk_value) * max(1, progress_required)
	var/base_total = total_target_risk * get_reward_multiplier()
	// Apply map reward modifier
	base_total *= map_reward_modifier
	// Apply distance bonus
	base_total *= (1 + distance_bonus_mult)
	return max(0, ROUND_UP(base_total))
