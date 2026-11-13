#define FLUID_EXPULSION_TIME (3 SECONDS)
#define FLUID_EXPULSION_STAMINA_COST 3
#define FLUID_EXPULSION_ENERGY_COST 3
#define FLUID_EXPULSION_MIN_TRANSFER 0.0001
/// Each push moves this share of what is held, but never less than the minimum.
#define FLUID_EXPULSION_PORTION_SHARE 0.4
#define FLUID_EXPULSION_MIN_PORTION 5

/datum/sex_action/hole_storage/expel_foreign_fluids
	abstract_type = /datum/sex_action/hole_storage/expel_foreign_fluids
	name = "Expel fluids"
	description = "Push every liquid held inside out a portion at a time, into a container, a bucket, or onto the floor."
	requires_free_hands = FALSE
	continous = TRUE
	do_time = FLUID_EXPULSION_TIME
	stamina_cost = 0
	var/cavity_name = "cavity"

/datum/sex_action/hole_storage/expel_foreign_fluids/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/organ/genitals/filling_organ/filling_organ = get_action_organ(user, target)
	if(!filling_organ)
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	if(get_held_fluid_volume(filling_organ) <= FLUID_EXPULSION_MIN_TRANSFER)
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/expel_foreign_fluids/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target && !user.has_free_sex_hands())
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE

	var/obj/item/organ/genitals/filling_organ/filling_organ = get_action_organ(user, target)
	if(!filling_organ)
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	if(get_held_fluid_volume(filling_organ) <= FLUID_EXPULSION_MIN_TRANSFER)
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/expel_foreign_fluids/lock_sex_object(mob/living/user, mob/living/target)
	var/obj/item/collection_container = get_held_collection_container(user)
	var/collection_hand = get_precise_hand_for_item(user, collection_container)
	if(collection_hand)
		add_sex_lock(user, collection_hand)
	if(collection_container)
		add_sex_lock(user, null, collection_container)
	if(hole_id)
		add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/hole_storage/expel_foreign_fluids/on_start(mob/living/user, mob/living/target)
	. = ..()
	target_organ = get_action_organ(user, target)
	// Pushing it out means letting go of the clench.
	if(target.is_holding_fluids_in())
		target.toggle_holding_fluids_in()
	if(user == target)
		to_chat(user, span_notice("I brace myself and start expelling retained fluid from my [cavity_name]."))
		return
	user.visible_message(
		span_notice("[user] prepares to help [target] expel retained fluid."),
		span_notice("I start helping [target] expel retained fluid from their [cavity_name].")
	)

/datum/sex_action/hole_storage/expel_foreign_fluids/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/organ/genitals/filling_organ/filling_organ = get_action_organ(user, target)
	if(!filling_organ)
		to_chat(user, span_warning("There is nothing to clear right now."))
		return

	if(get_held_fluid_volume(filling_organ) <= FLUID_EXPULSION_MIN_TRANSFER)
		to_chat(user, span_warning("There is no retained fluid to clear."))
		return

	var/portion = get_expulsion_portion(filling_organ)
	var/obj/item/reagent_containers/held_container = get_held_collection_container(user)
	var/obj/item/reagent_containers/glass/bucket/ground_bucket = get_bucket_beneath_target(target, held_container)
	var/container_collected = transfer_fluids_to_container(filling_organ, held_container, user, portion)
	var/bucket_collected = transfer_fluids_to_container(filling_organ, ground_bucket, user, portion - container_collected)
	var/spilled_to_floor = spill_fluids_to_floor(filling_organ, get_turf(target), portion - container_collected - bucket_collected, target)
	var/total_moved = container_collected + bucket_collected + spilled_to_floor

	if(total_moved <= FLUID_EXPULSION_MIN_TRANSFER)
		to_chat(user, span_warning("Nothing comes out."))
		return

	target.adjust_stamina(FLUID_EXPULSION_STAMINA_COST)
	target.adjust_energy(-FLUID_EXPULSION_ENERGY_COST)
	announce_expulsion_result(user, target, held_container, ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	if(get_held_fluid_volume(filling_organ) <= FLUID_EXPULSION_MIN_TRANSFER)
		to_chat(target, span_notice("That was the last of it."))

/// Done once nothing is left inside.
/datum/sex_action/hole_storage/expel_foreign_fluids/is_finished(mob/living/user, mob/living/target)
	if(..())
		return TRUE
	return get_held_fluid_volume(get_action_organ(user, target)) <= FLUID_EXPULSION_MIN_TRANSFER

/// Units one push moves: a share of what is held, at least the minimum, never more than is there.
/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_expulsion_portion(obj/item/organ/genitals/filling_organ/filling_organ)
	var/held = get_held_fluid_volume(filling_organ)
	return min(held, max(FLUID_EXPULSION_MIN_PORTION, held * FLUID_EXPULSION_PORTION_SHARE))

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_action_organ(mob/living/user, mob/living/target)
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ)
	if(user == target)
		return user.getorganslot(hole_id)
	return target.getorganslot(hole_id)

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_held_fluid_volume(obj/item/organ/genitals/filling_organ/filling_organ)
	return filling_organ?.reagents?.total_volume || 0

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_precise_hand_for_item(mob/living/user, obj/item/held_item)
	if(!user || !held_item)
		return null

	var/held_index = user.get_held_index_of_item(held_item)
	if(!held_index)
		return null
	if(held_index % 2)
		return BODY_ZONE_PRECISE_L_HAND
	return BODY_ZONE_PRECISE_R_HAND

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_held_collection_container(mob/living/user)
	RETURN_TYPE(/obj/item/reagent_containers)
	if(!user)
		return null

	var/obj/item/active_item = user.get_active_held_item()
	if(can_collect_into(active_item))
		return active_item

	for(var/obj/item/held_item as anything in user.held_items)
		if(held_item == active_item)
			continue
		if(can_collect_into(held_item))
			return held_item
	return null

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_bucket_beneath_target(mob/living/target, obj/item/reagent_containers/excluded_container)
	RETURN_TYPE(/obj/item/reagent_containers/glass/bucket)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return null

	for(var/obj/item/reagent_containers/glass/bucket/collection_bucket as anything in target_turf)
		if(collection_bucket == excluded_container)
			continue
		if(!can_collect_into(collection_bucket))
			continue
		return collection_bucket
	return null

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/can_collect_into(obj/item/candidate)
	if(!istype(candidate, /obj/item/reagent_containers))
		return FALSE
	if(!candidate.reagents)
		return FALSE
	if(!candidate.is_refillable())
		return FALSE
	return candidate.reagents.total_volume < candidate.reagents.maximum_volume

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/transfer_fluids_to_container(obj/item/organ/genitals/filling_organ/filling_organ, obj/item/reagent_containers/collection_container, mob/living/user, limit = INFINITY)
	if(limit <= 0 || !can_collect_into(collection_container) || !filling_organ.reagents?.total_volume)
		return 0
	var/collection_space = min(limit, collection_container.reagents.maximum_volume - collection_container.reagents.total_volume)
	return filling_organ.reagents.trans_to(collection_container, collection_space, transfered_by = user) || 0

/// Small pushes fall as drops, bigger ones pool; either way they leave a scent.
/datum/sex_action/hole_storage/expel_foreign_fluids/proc/spill_fluids_to_floor(obj/item/organ/genitals/filling_organ/filling_organ, turf/target_turf, limit = INFINITY, mob/living/source)
	var/spill_amount = min(limit, filling_organ.reagents?.total_volume)
	if(!target_turf || spill_amount <= 0)
		return 0
	leave_fluid_scent(target_turf, source, get_fluid_scent_kind(filling_organ.reagents.get_master_reagent()))
	spill_fluid_to_turf(target_turf, filling_organ.reagents, spill_amount, filling_organ.drips_as_drops)
	return spill_amount

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/build_expulsion_destination_text(obj/item/reagent_containers/held_container, obj/item/reagent_containers/glass/bucket/ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	var/list/destinations = list()
	if(container_collected > FLUID_EXPULSION_MIN_TRANSFER && held_container)
		destinations += "\the [held_container]"
	if(bucket_collected > FLUID_EXPULSION_MIN_TRANSFER && ground_bucket)
		destinations += "\the [ground_bucket]"
	if(spilled_to_floor > FLUID_EXPULSION_MIN_TRANSFER)
		destinations += "the floor"
	return english_list(destinations)

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/announce_expulsion_result(mob/living/user, mob/living/target, obj/item/reagent_containers/held_container, obj/item/reagent_containers/glass/bucket/ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	var/destination_text = build_expulsion_destination_text(held_container, ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	if(!length(destination_text))
		destination_text = "the floor"

	if(user == target)
		user.visible_message(
			span_notice("[user] strains and pushes out some fluid into [destination_text]."),
			span_notice("I push some fluid out of my [cavity_name] into [destination_text].")
		)
		return

	user.visible_message(
		span_notice("[user] helps [target] push out some fluid into [destination_text]."),
		span_notice("I help [target] push some fluid out of their [cavity_name] into [destination_text].")
	)
	to_chat(target, span_notice("[user] helps me push some fluid out into [destination_text]."))

/datum/sex_action/hole_storage/expel_foreign_fluids/vaginal
	name = "Drain pussy"
	hole_id = ORGAN_SLOT_VAGINA
	cavity_name = "vaginal cavity"

/datum/sex_action/hole_storage/expel_foreign_fluids/anal
	name = "Drain ass"
	hole_id = ORGAN_SLOT_ANUS
	cavity_name = "anal cavity"

#undef FLUID_EXPULSION_TIME
#undef FLUID_EXPULSION_STAMINA_COST
#undef FLUID_EXPULSION_ENERGY_COST
#undef FLUID_EXPULSION_MIN_TRANSFER
#undef FLUID_EXPULSION_PORTION_SHARE
#undef FLUID_EXPULSION_MIN_PORTION
