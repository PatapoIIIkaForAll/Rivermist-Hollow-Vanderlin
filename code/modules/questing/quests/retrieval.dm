/datum/quest/retrieval
	quest_type = QUEST_RETRIEVAL
	contract_group = QUEST_GROUP_ERRANDS
	minimum_tier = QUEST_TIER_ROUTINE
	maximum_tier = QUEST_TIER_DEADLY
	base_reward_value = QUEST_BASE_REWARD_RETRIEVAL
	var/list/fetch_items = list(
		/obj/item/weapon/knife/throwingknife/steel,
		/obj/item/weapon/knife,
		/obj/item/reagent_containers/glass/bottle/whitewine
	)

/datum/quest/retrieval/get_title()
	if(title)
		return title
	return "Retrieve [pick("an ancient", "a rare", "a stolen", "a magical")] [pick("artifact", "relic", "doohickey", "treasure")]"

/datum/quest/retrieval/get_objective_text()
	return "Retrieve [progress_required] [initial(target_item_type.name)]."

/datum/quest/retrieval/get_compass_signal_label(turf/reference_turf, using_live_target)
	if(has_tracked_item_in_inventory())
		return "Turn-in signal"
	return ..()

/datum/quest/retrieval/resolve_compass_focus_target(turf/reference_turf, atom/movable/preferred_atom = null)
	var/atom/movable/item_target = get_nearest_tracked_atom(reference_turf, FALSE, preferred_atom)
	if(item_target)
		return item_target
	return get_nearest_tracked_atom(reference_turf, TRUE, preferred_atom)


/// The rune would carry the goods home for free, so a rescue with them in hand voids the contract.
/datum/quest/retrieval/fails_on_rune_rescue(mob/living/carbon/rescued)
	return is_tracked_item_carried_by(rescued)

/datum/quest/retrieval/get_risk_score(turf/target_turf)
	return requested_tier + max(progress_required - 1, 0)

/datum/quest/retrieval/get_workload_reward(target_turf)
	var/turf/scroll_turf = get_turf(quest_scroll)
	var/distance = CLAMP(get_dist(scroll_turf, target_turf), 0, 200) // Avoid infinity rewards if it bugs out
	var/distance_reward = (distance / QUEST_DELIVERY_DISTANCE_DIVISOR) * QUEST_DELIVERY_DISTANCE_BONUS
	var/item_bonus = progress_required * QUEST_DELIVERY_PER_ITEM_BONUS

	return ROUND_UP(distance_reward + item_bonus)

/datum/quest/retrieval/calculate_reward(turf/target_turf)
	return calculate_errand_reward(target_turf)

/datum/quest/retrieval/can_generate_for_world()
	return has_supported_spawn_landmark()

/datum/quest/retrieval/generate(obj/effect/landmark/quest_spawner/landmark)
	..()
	if(!landmark)
		return FALSE
	if(!is_supported_map_turf(get_turf(landmark)))
		return FALSE

	// Select random item type from landmark's list
	target_item_type = pick(fetch_items)
	progress_required = rand(1, 3)
	target_spawn_area = get_area_name(get_turf(landmark))

	// Spawn items
	var/spawned_items = 0
	for(var/i in 1 to progress_required)
		var/turf/spawn_turf = landmark.get_safe_spawn_turf()
		if(!spawn_turf)
			continue

		var/obj/item/new_item = new target_item_type(spawn_turf)
		new_item.AddComponent(/datum/component/quest_object/retrieval, src)
		add_tracked_atom(new_item)
		spawned_items++

	if(!spawned_items)
		return FALSE

	progress_required = spawned_items
	return TRUE

/datum/quest/retrieval/get_target_location(turf/reference_turf, atom/movable/preferred_target = null)
	var/turf/item_turf = get_nearest_tracked_location(reference_turf, FALSE, preferred_target)
	if(item_turf)
		return get_anchor_safe_target_location(reference_turf, item_turf)

	if(has_tracked_item_in_inventory())
		return get_turn_in_target_turf(reference_turf)

	var/turf/live_target_turf = get_nearest_tracked_location(reference_turf, TRUE, preferred_target)
	return get_anchor_safe_target_location(reference_turf, live_target_turf)

/datum/quest/retrieval/get_target_map_anchor(turf/reference_turf)
	if(has_tracked_item_in_inventory())
		return get_turn_in_target_turf(reference_turf)

	return get_target_anchor_turf()
