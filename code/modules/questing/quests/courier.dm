/datum/quest/courier
	quest_type = QUEST_COURIER
	contract_group = QUEST_GROUP_ERRANDS
	minimum_tier = QUEST_TIER_ROUTINE
	maximum_tier = QUEST_TIER_DEADLY
	base_reward_value = QUEST_BASE_REWARD_COURIER
	var/list/target_delivery_locations = list(
		/area/indoors/town/tavern,
		/area/indoors/town/church,
		/area/indoors/town/dwarfin,
		/area/indoors/town/shop,
		/area/indoors/town/noble_manor,
		/area/indoors/town/keep/magician,
	)

/datum/quest/courier/get_title()
	if(title)
		return title
	return "Deliver [pick("an important", "a sealed", "a confidential", "a valuable")] [pick("package", "parcel", "letter", "delivery")]"

/datum/quest/courier/get_objective_text()
	return "Deliver [initial(target_delivery_item.name)] to [initial(target_delivery_location.name)]."

/datum/quest/courier/get_location_text()
	var/text = ""
	if(target_spawn_area)
		text += "Pickup location: Reported sighting in [target_spawn_area] region.<br>"
	text += "Destination: [initial(target_delivery_location.name)]."
	return text

/datum/quest/courier/proc/get_available_delivery_locations()
	var/list/available_locations = list()
	for(var/area_type in target_delivery_locations)
		var/area/resolved_area = resolve_target_area(area_type)
		if(!resolved_area)
			continue
		if(!length(resolved_area.get_zlevel_turf_lists()))
			continue
		if(!is_supported_area_target(resolved_area))
			continue
		available_locations += area_type
	return available_locations

/datum/quest/courier/can_generate_for_world()
	return has_supported_spawn_landmark() && length(get_available_delivery_locations()) > 0

/datum/quest/courier/get_compass_signal_label(turf/reference_turf, using_live_target)
	if(has_tracked_item_in_inventory())
		return "Delivery signal"
	return ..()

/datum/quest/courier/resolve_compass_focus_target(turf/reference_turf, atom/movable/preferred_atom = null)
	var/atom/movable/item_target = get_nearest_tracked_atom(reference_turf, FALSE, preferred_atom)
	if(item_target)
		return item_target
	return get_nearest_tracked_atom(reference_turf, TRUE, preferred_atom)

/// The rune would carry the parcel to town for free, so a rescue with it in hand voids the contract.
/datum/quest/courier/fails_on_rune_rescue(mob/living/carbon/rescued)
	return is_tracked_item_carried_by(rescued)

/datum/quest/courier/get_risk_score(turf/target_turf)
	return requested_tier + 1

/datum/quest/courier/get_workload_reward(target_turf)
	var/turf/scroll_turf = get_turf(quest_scroll)
	var/pickup_distance = (scroll_turf && target_turf) ? CLAMP(get_dist(scroll_turf, target_turf), 0, 200) : 0
	var/turf/delivery_turf = get_area_target_turf(target_delivery_location, target_turf)
	var/delivery_distance = (target_turf && delivery_turf) ? CLAMP(get_dist(target_turf, delivery_turf), 0, 200) : 0
	var/distance_reward = ((pickup_distance + delivery_distance) / QUEST_DELIVERY_DISTANCE_DIVISOR) * QUEST_DELIVERY_DISTANCE_BONUS
	return ROUND_UP(distance_reward + QUEST_COURIER_BONUS_FLAT)

/datum/quest/courier/calculate_reward(turf/target_turf)
	return calculate_errand_reward(target_turf)

/datum/quest/courier/proc/spawn_courier_item(area/delivery_area, obj/effect/landmark/quest_spawner/landmark)
	if(!delivery_area)
		return null

	var/turf/spawn_turf = landmark.get_safe_spawn_turf()
	if(!spawn_turf)
		return

	var/obj/item/parcel/delivery_parcel = new(spawn_turf)
	var/static/list/area_delivery_items = list(
		/area/indoors/town/tavern = list(
			/obj/item/cooking/pan,
			/obj/item/reagent_containers/glass/bottle/beer/aurorian,
			/obj/item/reagent_containers/food/snacks/cheddar,
		),
		/area/indoors/town/bath = list(
			/obj/item/reagent_containers/glass/bottle/beer/aurorian,
			/obj/item/reagent_containers/food/snacks/pie/cooked/meat/fish,
			/obj/item/perfume/random,
		),
		/area/indoors/town/church = list(
			/obj/item/natural/cloth,
			/obj/item/reagent_containers/powder/ozium,
			/obj/item/reagent_containers/food/snacks/hardtack,
		),
		/area/indoors/town/dwarfin = list(
			/obj/item/ingot/iron,
			/obj/item/ingot/bronze,
			/obj/item/ore/coal,
		),
		/area/indoors/town/shop = list(
			/obj/item/coin/gold,
			/obj/item/clothing/ring/silver,
			/obj/item/scomstone/bad,
		),
		/area/indoors/town/noble_manor = list(
			/obj/item/clothing/cloak/raincloak/furcloak,
			/obj/item/reagent_containers/glass/bottle/whitewine,
			/obj/item/reagent_containers/food/snacks/cheddar/aged,
			/obj/item/perfume/random,
		),
		/area/indoors/town/keep/magician = list(
			/obj/item/book/granter/spellbook,
			/obj/item/gem/yellow,
			/obj/item/reagent_containers/glass/bottle/manapot,
		),
	)

	var/list/possible_items = area_delivery_items[delivery_area] || list(
		/obj/item/natural/cloth,
		/obj/item/ration,
		/obj/item/reagent_containers/food/snacks/hardtack,
	)

	var/contained_item_type = pick(possible_items)
	var/obj/item/contained_item = new contained_item_type(delivery_parcel)
	delivery_parcel.contained_item = contained_item
	delivery_parcel.delivery_area_type = delivery_area
	delivery_parcel.allowed_jobs = delivery_parcel.get_area_jobs(delivery_area)
	delivery_parcel.name = "Delivery for [initial(delivery_area.name)]"
	delivery_parcel.desc = "A securely wrapped parcel addressed to [initial(delivery_area.name)]. [pick("Handle with care.", "Do not bend.", "Confidential contents.", "Urgent delivery.")]"
	delivery_parcel.icon_state = contained_item.w_class >= WEIGHT_CLASS_NORMAL ? "ration_large" : "ration_small"
	delivery_parcel.dropshrink = 1
	delivery_parcel.update_icon()

	target_delivery_item = contained_item_type
	delivery_parcel.AddComponent(/datum/component/quest_object/courier, src)
	contained_item.AddComponent(/datum/component/quest_object/courier, src)
	add_tracked_atom(delivery_parcel)
	add_tracked_atom(contained_item)

	return delivery_parcel

/datum/quest/courier/get_target_location(turf/reference_turf, atom/movable/preferred_target = null)
	var/turf/item_turf = get_nearest_tracked_location(reference_turf, FALSE, preferred_target)
	if(item_turf)
		return get_anchor_safe_target_location(reference_turf, item_turf)

	if(has_tracked_item_in_inventory())
		return get_area_target_turf(target_delivery_location, reference_turf)

	var/turf/live_target_turf = get_nearest_tracked_location(reference_turf, TRUE, preferred_target)
	return get_anchor_safe_target_location(reference_turf, live_target_turf)

/datum/quest/courier/get_target_map_anchor(turf/reference_turf)
	if(has_tracked_item_in_inventory())
		return get_area_target_turf(target_delivery_location, reference_turf)

	return get_target_anchor_turf()

/datum/quest/courier/generate(obj/effect/landmark/quest_spawner/landmark)
	..()
	if(!landmark)
		return FALSE
	if(!is_supported_map_turf(get_turf(landmark)))
		return FALSE

	// Select delivery location
	var/list/available_delivery_locations = get_available_delivery_locations()
	if(!length(available_delivery_locations))
		return FALSE

	target_delivery_location = pick(available_delivery_locations)
	progress_required = 1
	target_spawn_area = get_area_name(get_turf(landmark))

	// Spawn parcel
	var/obj/item/parcel/delivery_parcel = spawn_courier_item(target_delivery_location, landmark)
	if(!delivery_parcel)
		return FALSE

	return TRUE
