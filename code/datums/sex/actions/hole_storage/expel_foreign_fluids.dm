#define FOREIGN_FLUID_EXPULSION_TIME (4 SECONDS)
#define FOREIGN_FLUID_STAMINA_COST 10
#define FOREIGN_FLUID_ENERGY_COST 10
#define FOREIGN_FLUID_MIN_TRANSFER 0.0001

/datum/sex_action/hole_storage/expel_foreign_fluids
	abstract_type = /datum/sex_action/hole_storage/expel_foreign_fluids
	name = "Expel foreign fluids"
	description = "Clear retained foreign liquids into a container, a bucket, or onto the floor."
	requires_free_hands = FALSE
	continous = FALSE
	do_time = FOREIGN_FLUID_EXPULSION_TIME
	stamina_cost = 0
	user_priority = 0
	target_priority = 0
	var/cavity_name = "cavity"

/datum/sex_action/hole_storage/expel_foreign_fluids/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/organ/genitals/filling_organ/filling_organ = get_action_organ(user, target)
	if(!filling_organ)
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	if(get_foreign_fluid_volume(filling_organ) <= FOREIGN_FLUID_MIN_TRANSFER)
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
	if(get_foreign_fluid_volume(filling_organ) <= FOREIGN_FLUID_MIN_TRANSFER)
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
	if(user == target)
		to_chat(user, span_notice("I brace myself and start expelling retained fluid from my [cavity_name]."))
		return
	user.visible_message(
		span_notice("[user] prepares to help [target] expel retained fluid."),
		span_notice("I start helping [target] expel retained fluid from their [cavity_name].")
	)

/datum/sex_action/hole_storage/expel_foreign_fluids/on_perform(mob/living/user, mob/living/target)
	var/obj/item/organ/genitals/filling_organ/filling_organ = get_action_organ(user, target)
	if(!filling_organ)
		to_chat(user, span_warning("There is nothing to clear right now."))
		return

	var/foreign_fluid_volume = get_foreign_fluid_volume(filling_organ)
	if(foreign_fluid_volume <= FOREIGN_FLUID_MIN_TRANSFER)
		to_chat(user, span_warning("There is no retained foreign fluid to clear."))
		return

	var/obj/item/reagent_containers/held_container = get_held_collection_container(user)
	var/obj/item/reagent_containers/glass/bucket/ground_bucket = get_bucket_beneath_target(target, held_container)
	var/container_collected = transfer_foreign_fluids_to_container(filling_organ, held_container, user)
	var/bucket_collected = transfer_foreign_fluids_to_container(filling_organ, ground_bucket, user)
	var/spilled_to_floor = spill_foreign_fluids_to_floor(filling_organ, get_turf(target))
	var/total_moved = container_collected + bucket_collected + spilled_to_floor

	if(total_moved <= FOREIGN_FLUID_MIN_TRANSFER)
		to_chat(user, span_warning("Nothing comes out."))
		return

	target.adjust_stamina(FOREIGN_FLUID_STAMINA_COST)
	target.adjust_energy(-FOREIGN_FLUID_ENERGY_COST)
	announce_expulsion_result(user, target, held_container, ground_bucket, container_collected, bucket_collected, spilled_to_floor)

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_action_organ(mob/living/user, mob/living/target)
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ)
	if(user == target)
		return user.getorganslot(hole_id)
	return target.getorganslot(hole_id)

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/get_foreign_fluid_volume(obj/item/organ/genitals/filling_organ/filling_organ)
	if(!filling_organ?.reagents)
		return 0

	var/native_fluid_volume = 0
	if(filling_organ.reagent_to_make)
		native_fluid_volume = filling_organ.reagents.get_reagent_amount(filling_organ.reagent_to_make)
	return max(0, filling_organ.reagents.total_volume - native_fluid_volume)

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

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/create_foreign_fluid_snapshot(obj/item/organ/genitals/filling_organ/filling_organ)
	RETURN_TYPE(/datum/reagents)
	var/foreign_fluid_volume = get_foreign_fluid_volume(filling_organ)
	if(foreign_fluid_volume <= FOREIGN_FLUID_MIN_TRANSFER)
		return null

	var/datum/reagents/fluid_snapshot = new /datum/reagents(foreign_fluid_volume)
	fluid_snapshot.my_atom = filling_organ

	for(var/datum/reagent/stored_reagent as anything in filling_organ.reagents.reagent_list)
		if(stored_reagent.type == filling_organ.reagent_to_make)
			continue
		fluid_snapshot.add_reagent(
			stored_reagent.type,
			stored_reagent.volume,
			filling_organ.reagents.copy_data(stored_reagent),
			filling_organ.reagents.chem_temp,
			no_react = TRUE
		)
	return fluid_snapshot

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/remove_snapshot_transfer_from_organ(obj/item/organ/genitals/filling_organ/filling_organ, list/starting_amounts, datum/reagents/fluid_snapshot)
	var/transferred_amount = 0
	for(var/reagent_type in starting_amounts)
		var/remaining_amount = fluid_snapshot.get_reagent_amount(reagent_type)
		var/reagent_transfer_amount = starting_amounts[reagent_type] - remaining_amount
		if(reagent_transfer_amount <= FOREIGN_FLUID_MIN_TRANSFER)
			continue
		filling_organ.reagents.remove_reagent(reagent_type, reagent_transfer_amount, TRUE)
		transferred_amount += reagent_transfer_amount
	return transferred_amount

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/transfer_foreign_fluids_to_container(obj/item/organ/genitals/filling_organ/filling_organ, obj/item/reagent_containers/collection_container, mob/living/user)
	if(!can_collect_into(collection_container))
		return 0

	var/datum/reagents/fluid_snapshot = create_foreign_fluid_snapshot(filling_organ)
	if(!fluid_snapshot)
		return 0

	var/list/starting_amounts = list()
	for(var/datum/reagent/stored_reagent as anything in fluid_snapshot.reagent_list)
		starting_amounts[stored_reagent.type] = stored_reagent.volume

	var/collection_space = collection_container.reagents.maximum_volume - collection_container.reagents.total_volume
	fluid_snapshot.trans_to(collection_container, collection_space, transfered_by = user)
	var/transferred_amount = remove_snapshot_transfer_from_organ(filling_organ, starting_amounts, fluid_snapshot)
	qdel(fluid_snapshot)
	return transferred_amount

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/spill_foreign_fluids_to_floor(obj/item/organ/genitals/filling_organ/filling_organ, turf/target_turf)
	if(!target_turf)
		return 0

	var/datum/reagents/fluid_snapshot = create_foreign_fluid_snapshot(filling_organ)
	if(!fluid_snapshot)
		return 0

	var/spill_amount = fluid_snapshot.total_volume
	target_turf.add_liquid_from_reagents(fluid_snapshot, amount = spill_amount)
	for(var/datum/reagent/stored_reagent as anything in fluid_snapshot.reagent_list)
		filling_organ.reagents.remove_reagent(stored_reagent.type, stored_reagent.volume, TRUE)
	qdel(fluid_snapshot)
	return spill_amount

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/build_expulsion_destination_text(obj/item/reagent_containers/held_container, obj/item/reagent_containers/glass/bucket/ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	var/list/destinations = list()
	if(container_collected > FOREIGN_FLUID_MIN_TRANSFER && held_container)
		destinations += "\the [held_container]"
	if(bucket_collected > FOREIGN_FLUID_MIN_TRANSFER && ground_bucket)
		destinations += "\the [ground_bucket]"
	if(spilled_to_floor > FOREIGN_FLUID_MIN_TRANSFER)
		destinations += "the floor"
	return english_list(destinations)

/datum/sex_action/hole_storage/expel_foreign_fluids/proc/announce_expulsion_result(mob/living/user, mob/living/target, obj/item/reagent_containers/held_container, obj/item/reagent_containers/glass/bucket/ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	var/destination_text = build_expulsion_destination_text(held_container, ground_bucket, container_collected, bucket_collected, spilled_to_floor)
	if(!length(destination_text))
		destination_text = "the floor"

	if(user == target)
		user.visible_message(
			span_notice("[user] strains and clears retained fluid into [destination_text]."),
			span_notice("I clear the retained fluid from my [cavity_name] into [destination_text].")
		)
		return

	user.visible_message(
		span_notice("[user] helps [target] clear retained fluid into [destination_text]."),
		span_notice("I help [target] clear the retained fluid from their [cavity_name] into [destination_text].")
	)
	to_chat(target, span_notice("[user] helps me clear retained fluid into [destination_text]."))

/datum/sex_action/hole_storage/expel_foreign_fluids/vaginal
	name = "Expel foreign fluids from pussy"
	hole_id = ORGAN_SLOT_VAGINA
	cavity_name = "vaginal cavity"

/datum/sex_action/hole_storage/expel_foreign_fluids/anal
	name = "Expel foreign fluids from anus"
	hole_id = ORGAN_SLOT_ANUS
	cavity_name = "anal cavity"

#undef FOREIGN_FLUID_EXPULSION_TIME
#undef FOREIGN_FLUID_STAMINA_COST
#undef FOREIGN_FLUID_ENERGY_COST
#undef FOREIGN_FLUID_MIN_TRANSFER
