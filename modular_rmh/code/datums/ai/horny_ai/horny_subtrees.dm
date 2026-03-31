/datum/ai_planning_subtree/simple_find_horny

/datum/ai_planning_subtree/simple_find_horny/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN])
		return
	if(horny_ai_should_yield_to_aggro(controller))
		return
	var/mob/living/living_pawn = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]
	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]
	if(current_target && QDELETED(current_target))
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
		current_target = null
	if(current_target && targetting_datum?.can_horny(living_pawn, current_target))
		return
	if(current_target)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	controller.queue_behavior(/datum/ai_behavior/find_potential_horny_targets, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/datum/ai_planning_subtree/horny
	/// Blackboard key containing current target
	var/target_key = BB_BASIC_MOB_CURRENT_HORNY_TARGET


/datum/ai_planning_subtree/horny/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(target && QDELETED(target))
		controller.clear_blackboard_key(target_key)
		target = null
	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN])
		return
	if(horny_ai_should_yield_to_aggro(controller))
		return
	var/behavior_type = get_horny_behavior_type(controller)
	var/datum/ai_behavior/horny/horny_behavior = GET_AI_BEHAVIOR(behavior_type)
	controller.queue_behavior(behavior_type, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	if(target && LAZYACCESS(controller.planned_behaviors, horny_behavior))
		return SUBTREE_RETURN_FINISH_PLANNING // Once horny actually has the wheel, don't queue later combat finders behind it.

/datum/ai_planning_subtree/horny/proc/get_horny_behavior_type(datum/ai_controller/controller)
	if(ishuman(controller.pawn))
		return /datum/ai_behavior/horny/human

	return /datum/ai_behavior/horny/simple_mob

/datum/ai_planning_subtree/proc/horny_ai_should_yield_to_aggro(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]
	var/atom/current_horny_target = controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]
	if(!living_pawn || !targetting_datum)
		return FALSE

	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(current_target != current_horny_target && horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, current_target))
		return TRUE

	var/atom/highest_threat = controller.blackboard[BB_HIGHEST_THREAT_MOB]
	if(highest_threat != current_horny_target && horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, highest_threat))
		return TRUE

	var/list/retaliate_list = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if(length(retaliate_list))
		for(var/mob/living/retaliator as anything in retaliate_list)
			if(retaliator == current_horny_target)
				continue
			if(retaliate_list[retaliator] + 2 MINUTES < world.time)
				continue
			if(!can_see(living_pawn, retaliator, 8))
				continue
			if(horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, retaliator))
				return TRUE

	if(locate(/datum/ai_planning_subtree/aggro_find_target) in controller.planning_subtrees || locate(/datum/ai_planning_subtree/minotaur_targeting) in controller.planning_subtrees)
		var/search_range = controller.blackboard[BB_AGGRO_RANGE]
		if(isnull(search_range))
			search_range = 9
		for(var/mob/living/potential_target in hearers(search_range, living_pawn) - living_pawn)
			if(potential_target == current_horny_target)
				continue
			if(horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, potential_target))
				return TRUE

	return FALSE

/datum/ai_planning_subtree/proc/horny_ai_is_valid_aggro_target(mob/living/living_pawn, datum/targetting_datum/targetting_datum, atom/target)
	if(!target || target == living_pawn || QDELETED(target))
		return FALSE

	// Human NPCs can consider prone, armed victims "disarm targets"; keep that from
	// hijacking horny planning while this same mob is still a valid horny partner.
	if(targetting_datum.can_horny(living_pawn, target))
		return FALSE

	if(!targetting_datum.can_attack(living_pawn, target) && !targetting_datum.should_disarm(living_pawn, target))
		return FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return FALSE
		if(living_target.rogue_sneaking)
			var/extra_chance = (living_pawn.health <= living_pawn.maxHealth * 0.5) ? 30 : 0
			if(!living_pawn.npc_detect_sneak(living_target, extra_chance))
				return FALSE

	return TRUE
