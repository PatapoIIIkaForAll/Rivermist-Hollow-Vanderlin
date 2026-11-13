/// Static typecache list of things we are interested in
/// Consider this a union of the for loop and the hearers call from below
/// Must be kept up to date with the contents of hostile_machines
/datum/ai_behavior/find_potential_horny_targets
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How far can we see stuff?
	var/vision_range = 9

/datum/ai_behavior/find_potential_horny_targets/get_cooldown(datum/ai_controller/cooldown_for)
	if(cooldown_for.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)])
		return 60 SECONDS
	return ..()

/datum/ai_behavior/find_potential_horny_targets/has_live_detection_field(datum/ai_controller/controller)
	var/datum/field = controller.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)]
	return !QDELETED(field)

/datum/ai_behavior/find_potential_horny_targets/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
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

	controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
	if(failed_to_find_anyone(controller, target_key, targetting_datum_key, hiding_location_key))
		return
	finish_action(controller, succeeded = FALSE)

/datum/ai_behavior/find_potential_horny_targets/proc/failed_to_find_anyone(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/aggro_range = vision_range
	// takes the larger between our range() input and our implicit hearers() input (world.view)
	aggro_range = max(aggro_range, ROUND_UP(max(getviewsize(world.view)) / 2))
	var/datum/proximity_monitor/advanced/ai_target_tracking/horny/horny_detection_field = new(
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
	horny_detection_field.prime_existing_candidates()
	return QDELETED(horny_detection_field)

/datum/ai_behavior/find_potential_horny_targets/proc/new_turf_found(turf/found, datum/ai_controller/controller, datum/targetting_datum/strategy)
	var/valid_found = FALSE
	var/mob/pawn = controller.pawn
	for(var/maybe_target in found)
		if(!resolve_horny_candidate_target(pawn, strategy, maybe_target))
			continue
		valid_found = TRUE
		break
	if(!valid_found)
		return
	var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_HORNY_TARGETS_FIELD(type)]
	qdel(field)
	controller.modify_cooldown(src, world.time)

/datum/ai_behavior/find_potential_horny_targets/proc/atom_allowed(atom/movable/checking, datum/targetting_datum/strategy, mob/pawn)
	if(resolve_horny_candidate_target(pawn, strategy, checking))
		return TRUE
	if(!ismob(checking) && !is_type_in_typecache(checking, GLOB.target_interested_atoms))
		return FALSE
	return FALSE

/datum/ai_behavior/find_potential_horny_targets/proc/new_atoms_found(list/atom/movable/found, datum/ai_controller/controller, target_key, datum/targetting_datum/strategy, hiding_location_key)
	var/mob/pawn = controller.pawn
	var/list/portal_targets = list()
	var/list/accepted_targets = collect_potential_horny_targets(pawn, strategy, found, portal_targets)

	if(!LAZYLEN(accepted_targets))
		controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
		finish_action(controller, succeeded = FALSE)
		return

	var/atom/target = pick_final_target(controller, accepted_targets, portal_targets)
	controller.set_blackboard_key(target_key, target)
	if(portal_targets[target])
		controller.set_blackboard_key(BB_HORNY_PORTAL_LIGHT, portal_targets[target])
	else
		controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)

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
/datum/ai_behavior/find_potential_horny_targets/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets, list/portal_targets)
	var/mob/living/living_mob = controller.pawn
	var/list/weighted_targets = build_pattern_weighted_targets(living_mob, filtered_targets, portal_targets)
	return pick(weighted_targets)

/datum/ai_behavior/find_potential_horny_targets/proc/build_pattern_weighted_targets(mob/living/living_mob, list/filtered_targets, list/portal_targets)
	var/list/weighted_targets = filtered_targets.Copy()
	for(var/mob/living/target_living as anything in filtered_targets)
		var/obj/item/portallight/portal_light = portal_targets ? portal_targets[target_living] : null
		var/pattern_desirability = get_target_pattern_desirability(living_mob, target_living, portal_light)
		if(pattern_desirability > 0)
			add_weighted_horny_ai_choice(weighted_targets, target_living, pattern_desirability)
	return weighted_targets

/datum/ai_behavior/find_potential_horny_targets/proc/get_target_pattern_desirability(mob/living/living_mob, mob/living/target_living, obj/item/portallight/portal_light)
	var/datum/sex_scene/target_scene = target_living?.sex_scene
	if(!target_scene || QDELETED(target_scene))
		return 0

	var/list/weighted_actions = list()
	if(portal_light)
		add_portal_horny_ai_actions(weighted_actions, living_mob, target_living)
	else
		add_local_horny_ai_actions(weighted_actions, living_mob, target_living)

	var/best_desirability = 0
	var/list/scored_action_types = list()
	for(var/action_type in weighted_actions)
		if(action_type in scored_action_types)
			continue
		scored_action_types += action_type
		var/datum/sex_action/action = SEX_ACTION(action_type)
		var/pattern_desirability = target_scene.get_action_pattern_desirability(
			action,
			living_mob,
			target_living,
			allow_new_participant = TRUE,
		)
		best_desirability = max(best_desirability, pattern_desirability)
	return best_desirability

/datum/ai_behavior/find_potential_horny_targets/proc/get_portal_horny_target(mob/living/living_mob, datum/targetting_datum/strategy, atom/maybe_portal)
	if(!istype(maybe_portal, /obj/item/portallight))
		return null

	var/obj/item/portallight/portal_light = maybe_portal
	if(QDELETED(portal_light) || portal_light.anchored)
		return null
	if(portal_light.loc != living_mob && !isturf(portal_light.loc))
		return null

	var/mob/living/carbon/human/portal_target = portal_light.get_wearer()
	if(!portal_target)
		return null
	if(!strategy.can_horny(living_mob, portal_target))
		return null

	return portal_target

/datum/ai_behavior/find_potential_horny_targets/proc/resolve_horny_candidate_target(mob/living/living_mob, datum/targetting_datum/strategy, atom/potential_target)
	if(potential_target == living_mob)
		return null
	if(ishuman(potential_target) && strategy.can_horny(living_mob, potential_target))
		return potential_target
	return get_portal_horny_target(living_mob, strategy, potential_target)

/datum/ai_behavior/find_potential_horny_targets/proc/collect_potential_horny_targets(mob/living/living_mob, datum/targetting_datum/strategy, list/potential_targets, list/portal_targets)
	var/list/filtered_targets = list()
	var/list/direct_targets = list()

	for(var/atom/potential_target as anything in potential_targets)
		var/mob/living/carbon/human/resolved_target = resolve_horny_candidate_target(living_mob, strategy, potential_target)
		if(!resolved_target)
			continue

		if(resolved_target == potential_target)
			filtered_targets += resolved_target
			direct_targets |= resolved_target
			if(!isnull(portal_targets[resolved_target]))
				portal_targets -= resolved_target
			continue

		if(resolved_target in direct_targets)
			continue
		if(!(resolved_target in filtered_targets))
			filtered_targets += resolved_target
		if(isnull(portal_targets[resolved_target]))
			portal_targets[resolved_target] = potential_target

	return filtered_targets
