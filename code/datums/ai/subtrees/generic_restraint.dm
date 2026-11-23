/datum/ai_planning_subtree/generic_break_restraints/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/carbon/living_pawn = controller.pawn
	if(!iscarbon(living_pawn))
		return

	if(!living_pawn.handcuffed && !living_pawn.legcuffed)
		return
	if(living_pawn.restraints_all_docile())
		return

	if(SPT_PROB(50, seconds_per_tick))
		controller.queue_behavior(/datum/ai_behavior/break_restraints)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/break_restraints
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 45 SECONDS

/datum/ai_behavior/break_restraints/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/carbon/living_pawn = controller.pawn
	var/obj/item/restraint = living_pawn.handcuffed || living_pawn.legcuffed
	if(!restraint)
		finish_action(controller, FALSE)
		return

	// Timed like a player's struggle, so moving the mob breaks it. The struggle sleeps; perform must not.
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob/living/carbon, cuff_resist), restraint)
	finish_action(controller, TRUE)
