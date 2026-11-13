/datum/ai_behavior/enter_exit_home
	action_cooldown = 60 SECONDS

	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/enter_exit_home/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/enter_exit_home/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/structure/current_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn
	// Another behavior can move the walk target; never enter or leave a home we are not standing at.
	if(QDELETED(current_home) || get_dist(get_turf(bee_pawn), get_turf(current_home)) > 1)
		finish_action(controller, FALSE)
		return

	var/datum/callback/callback = CALLBACK(bee_pawn, TYPE_PROC_REF(/mob/living/simple_animal, handle_habitation), current_home)
	callback.Invoke()
	finish_action(controller, TRUE)

/datum/ai_behavior/enter_exit_home/no_cooldown
	action_cooldown = 0
