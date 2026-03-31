/// Static typecache list of things we are interested in
/// Consider this a union of the for loop and the hearers call from below
/// Must be kept up to date with the contents of hostile_machines
/datum/ai_behavior/find_potential_horny_targets
	action_cooldown = 5 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9

/datum/ai_behavior/find_potential_horny_targets/get_cooldown(datum/ai_controller/cooldown_for)
	if(cooldown_for.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)])
		return 60 SECONDS
	return ..()

/datum/ai_behavior/find_potential_horny_targets/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	if(controller.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)])
		return FALSE
	var/mob/living/basic_mob = controller.pawn
	if(!basic_mob)
		return FALSE

	if(!basic_mob.GetComponent(/datum/component/arousal))
		basic_mob.AddComponent(/datum/component/arousal)


/datum/ai_behavior/find_potential_horny_targets/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/living_mob = controller.pawn

	if(living_mob.pet_passive)
		finish_action(controller, succeeded = FALSE)
		return
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	if(targetting_datum.can_horny(living_mob, current_target))
		finish_action(controller, succeeded = FALSE)
		return

	controller.clear_blackboard_key(target_key)
	// A passive field is already watching for horny targets, so don't sit in current_behaviors blocking planning.
	if(controller.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)])
		finish_action(controller, succeeded = FALSE)
		return

	var/list/potential_targets = hearers(vision_range, controller.pawn) - living_mob //Remove self, so we don't suicide

	if(!potential_targets.len)
		failed_to_find_anyone(controller, target_key, targetting_datum_key, hiding_location_key)
		finish_action(controller, succeeded = FALSE)
		return

	var/list/filtered_targets = list()

	for(var/atom/pot_target in potential_targets)
		if(targetting_datum.can_horny(living_mob, pot_target))//Can we horny it?
			filtered_targets += pot_target
			continue

	for(var/mob/living/living_target in filtered_targets)
		if(living_target.stat == DEAD)
			filtered_targets -= living_target
			continue
		if(!living_target.rogue_sneaking)
			continue

	if(!filtered_targets.len)
		failed_to_find_anyone(controller, target_key, targetting_datum_key, hiding_location_key)
		finish_action(controller, succeeded = FALSE)
		return

	var/atom/target = pick_final_target(controller, filtered_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targetting_datum.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/find_potential_horny_targets/proc/failed_to_find_anyone(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/aggro_range = vision_range
	// takes the larger between our range() input and our implicit hearers() input (world.view)
	aggro_range = max(aggro_range, ROUND_UP(max(getviewsize(world.view)) / 2))
	var/datum/proximity_monitor/advanced/ai_target_tracking/horny_detection_field = new(
		controller.pawn,
		aggro_range,
		TRUE,
		src,
		controller,
		target_key,
		targeting_strategy_key,
		hiding_location_key,
		BB_FIND_HORNY_TARGETS_FIELD(type),
	)
	controller.set_blackboard_key(BB_FIND_HORNY_TARGETS_FIELD(type), horny_detection_field)

/datum/ai_behavior/find_potential_horny_targets/proc/new_turf_found(turf/found, datum/ai_controller/controller, datum/targetting_datum/strategy)
	var/valid_found = FALSE
	var/mob/pawn = controller.pawn
	for(var/maybe_target as anything in found)
		if(maybe_target == pawn)
			continue
		if(!is_type_in_typecache(maybe_target, GLOB.target_interested_atoms))
			continue
		if(!strategy.can_horny(pawn, maybe_target))
			continue
		valid_found = TRUE
		break
	if(!valid_found)
		return
	var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)]
	qdel(field)
	controller.modify_cooldown(src, world.time)

/datum/ai_behavior/find_potential_horny_targets/proc/atom_allowed(atom/movable/checking, datum/targetting_datum/strategy, mob/pawn)
	if(checking == pawn)
		return FALSE
	if(!ismob(checking) && !is_type_in_typecache(checking, GLOB.target_interested_atoms))
		return FALSE
	if(!strategy.can_horny(pawn, checking))
		return FALSE
	return TRUE

/datum/ai_behavior/find_potential_horny_targets/proc/new_atoms_found(list/atom/movable/found, datum/ai_controller/controller, target_key, datum/targetting_datum/strategy, hiding_location_key)
	var/mob/pawn = controller.pawn
	var/list/accepted_targets = list()
	for(var/maybe_target as anything in found)
		if(maybe_target == pawn)
			continue
		// Need to better handle viewers here
		if(!ismob(maybe_target) && !is_type_in_typecache(maybe_target, GLOB.target_interested_atoms))
			continue
		if(!strategy.can_horny(pawn, maybe_target))
			continue
		accepted_targets += maybe_target

	if(!LAZYLEN(accepted_targets))
		finish_action(controller, succeeded = FALSE)
		return

	var/atom/target = pick_final_target(controller, accepted_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = strategy.find_hidden_mobs(pawn, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/find_potential_horny_targets/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if (succeeded)
		var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)]
		qdel(field)
		controller.CancelActions() // On retarget cancel any further queued actions so that they will setup again with new target
		controller.modify_cooldown(src, world.time + get_cooldown(controller))

/// Returns the desired final target from the filtered list of targets
/datum/ai_behavior/find_potential_horny_targets/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)
