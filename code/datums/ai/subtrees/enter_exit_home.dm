/datum/ai_planning_subtree/enter_exit_home
	///chance we go back home
	var/enter_change = 15
	///chance we exit the home
	var/exit_chance = 35

/datum/ai_planning_subtree/enter_exit_home/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	var/obj/structure/current_home = controller.blackboard[BB_CURRENT_HOME]

	if(QDELETED(current_home))
		return

	var/datum/ai_behavior/trip = GET_AI_BEHAVIOR(/datum/ai_behavior/enter_exit_home)
	// A trip under way keeps going; a new one is only rolled once the last trip's cooldown ends.
	if(!LAZYACCESS(controller.current_behaviors, trip))
		if(controller.behavior_cooldowns[trip] > world.time)
			return
		var/mob/living/pawn = controller.pawn
		var/action_prob =  (pawn in current_home.contents) ? exit_chance : enter_change
		if(!SPT_PROB(action_prob, seconds_per_tick))
			return

	controller.queue_behavior(/datum/ai_behavior/enter_exit_home, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING
