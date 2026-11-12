/datum/ai_controller/enterprise_patron
	movement_delay = 0.5 SECONDS
	max_target_distance = 300
	can_idle = FALSE
	ai_movement = /datum/ai_movement/hybrid_pathing/enterprise_patron
	idle_behavior = /datum/idle_behavior/nothing
	planning_subtrees = list(
		/datum/ai_planning_subtree/enterprise_patron_speak,
		/datum/ai_planning_subtree/enterprise_patron/find_table/order,
		/datum/ai_planning_subtree/enterprise_patron/leave,
		/datum/ai_planning_subtree/enterprise_patron/find_bar,
		/datum/ai_planning_subtree/enterprise_patron/find_table,
		/datum/ai_planning_subtree/enterprise_patron/find_room,
	)

/datum/ai_controller/enterprise_patron/get_expected_ai_status()
	. = ..()
	if(. != AI_STATUS_OFF || !able_to_run || QDELETED(pawn))
		return
	var/mob/living/patron = pawn
	if(!patron.client && patron.stat < UNCONSCIOUS)
		return AI_STATUS_ON

/datum/ai_movement/hybrid_pathing/enterprise_patron
	max_path_distance = ENTERPRISE_PATRON_PATH_REACH
	max_pathing_attempts = 3
	always_advanced = TRUE

/datum/ai_movement/hybrid_pathing/enterprise_patron/process(delta_time)
	var/list/datum/ai_controller/ready = list()
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(COOLDOWN_FINISHED(controller, movement_cooldown))
			ready[controller] = get_turf(controller.pawn)
	. = ..()
	for(var/datum/ai_controller/controller as anything in ready)
		var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
		if(istype(patron) && (controller in moving_controllers) && get_turf(patron) == ready[controller] && controller.can_move())
			patron.step_through(controller)

/mob/living/simple_animal/enterprise_patron/proc/step_through(datum/ai_controller/controller)
	var/turf/here = loc
	var/list/turf/path = controller.movement_path
	var/turf/next_step = length(path) ? path[1] : null
	if(!isturf(here) || !next_step || next_step.z != here.z || get_dist(here, next_step) != 1)
		return FALSE
	var/minimum_distance = controller.max_target_distance
	for(var/datum/ai_behavior/behavior as anything in controller.current_behaviors)
		minimum_distance = min(minimum_distance, behavior.required_distance)
	if(get_dist(src, controller.current_movement_target) <= minimum_distance)
		return FALSE
	open_door(locate(/obj/structure/door) in next_step)
	if(!Move(next_step, get_dir(here, next_step)) || loc != next_step)
		return FALSE
	path.Cut(1, 2)
	return TRUE

/datum/ai_planning_subtree/enterprise_patron_speak/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
	if(!istype(patron) || !length(patron.remarks))
		return
	var/line = patron.remarks[1]
	patron.remarks.Cut(1, 2)
	controller.queue_behavior(/datum/ai_behavior/perform_speech, line)

/datum/ai_planning_subtree/enterprise_patron
	var/goal
	var/walk_type = /datum/ai_behavior/enterprise_patron_walk

/datum/ai_planning_subtree/enterprise_patron/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
	if(!istype(patron) || !patron.enterprise || patron.get_goal() != goal)
		return
	switch(patron.goal_stage)
		if(ENTERPRISE_PATRON_STAGE_STAY)
			if(world.time >= patron.stay_until)
				patron.next_goal()
			return SUBTREE_RETURN_FINISH_PLANNING
		if(ENTERPRISE_PATRON_STAGE_SEEK)
			var/turf/target = find_target(patron)
			if(!target)
				nothing_found(patron)
				return SUBTREE_RETURN_FINISH_PLANNING
			controller.set_blackboard_key(BB_ENTERPRISE_PATRON_TARGET, target)
			patron.goal_stage = ENTERPRISE_PATRON_STAGE_WALK
			if(!patron.walk_until)
				patron.walk_until = world.time + patron.walk_time
		if(ENTERPRISE_PATRON_STAGE_WALK)
			if(world.time >= patron.walk_until)
				patron.give_up()
				return SUBTREE_RETURN_FINISH_PLANNING
			if(patron.seat_lost())
				patron.goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
				patron.stop_walking()
				return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(walk_type, BB_ENTERPRISE_PATRON_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/enterprise_patron/proc/find_target(mob/living/simple_animal/enterprise_patron/patron)
	return null

/datum/ai_planning_subtree/enterprise_patron/proc/nothing_found(mob/living/simple_animal/enterprise_patron/patron)
	patron.next_goal()

/datum/ai_planning_subtree/enterprise_patron/leave
	goal = ENTERPRISE_PATRON_GOAL_LEAVE
	walk_type = /datum/ai_behavior/enterprise_patron_walk/out

/datum/ai_planning_subtree/enterprise_patron/leave/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
	if(!istype(patron) || !patron.enterprise)
		return
	if(!length(patron.goals))
		patron.depart()
	return ..()

/datum/ai_planning_subtree/enterprise_patron/leave/find_target(mob/living/simple_animal/enterprise_patron/patron)
	patron.claim_seat(null)
	return patron.enterprise.get_exit_turf(patron) || patron.origin

/datum/ai_planning_subtree/enterprise_patron/leave/nothing_found(mob/living/simple_animal/enterprise_patron/patron)
	patron.leave()

/datum/ai_planning_subtree/enterprise_patron/find_bar
	goal = ENTERPRISE_PATRON_GOAL_BAR

/datum/ai_planning_subtree/enterprise_patron/find_bar/find_target(mob/living/simple_animal/enterprise_patron/patron)
	var/list/claimed = patron.enterprise.get_claimed_seats(patron)
	var/datum/enterprise_seating/bar = patron.enterprise.find_seating(TRUE, claimed, patron)
	return patron.claim_seat(bar?.get_free_chair(claimed, patron))

/datum/ai_planning_subtree/enterprise_patron/find_bar/nothing_found(mob/living/simple_animal/enterprise_patron/patron)
	patron.complain(ENTERPRISE_PATRON_LINE_NO_BAR)
	if(!patron.leaving)
		patron.next_goal()

/datum/ai_planning_subtree/enterprise_patron/find_table
	goal = ENTERPRISE_PATRON_GOAL_TABLE

/datum/ai_planning_subtree/enterprise_patron/find_table/find_target(mob/living/simple_animal/enterprise_patron/patron)
	var/list/claimed = patron.enterprise.get_claimed_seats(patron)
	var/datum/enterprise_seating/free_set = patron.table_set || patron.enterprise.find_seating(FALSE, claimed, patron)
	if(!free_set || (free_set != patron.table_set && !patron.take_seat(free_set)))
		return null
	return patron.claim_seat(free_set.get_free_chair(claimed, patron))

/datum/ai_planning_subtree/enterprise_patron/find_table/nothing_found(mob/living/simple_animal/enterprise_patron/patron)
	patron.complain(ENTERPRISE_PATRON_LINE_NO_TABLE)
	if(!patron.leaving)
		patron.next_goal()

/datum/ai_planning_subtree/enterprise_patron/find_room
	goal = ENTERPRISE_PATRON_GOAL_ROOM

/datum/ai_planning_subtree/enterprise_patron/find_room/find_target(mob/living/simple_animal/enterprise_patron/patron)
	var/datum/enterprise_room/free_room = patron.lodging || patron.enterprise.find_free_room()
	if(!free_room || (free_room != patron.lodging && !patron.take_room(free_room)))
		return null
	var/list/claimed = patron.enterprise.get_claimed_seats(patron)
	for(var/obj/structure/bed/bed as anything in free_room.get_interior(/obj/structure/bed))
		if(!(bed in claimed) && !patron.seat_blocked(bed))
			return patron.claim_seat(bed)
	patron.claim_seat(null)
	for(var/turf/open/floor in free_room.turfs)
		if(!floor.is_blocked_turf(TRUE))
			return floor
	return null

/datum/ai_planning_subtree/enterprise_patron/find_room/nothing_found(mob/living/simple_animal/enterprise_patron/patron)
	patron.complain(ENTERPRISE_PATRON_LINE_NO_ROOM)
	if(!patron.leaving)
		patron.next_goal()

/datum/ai_behavior/enterprise_patron_walk
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/enterprise_patron_walk/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	controller.movement_path = null
	controller.clear_blackboard_key(BB_FUTURE_MOVEMENT_PATH)
	set_movement_target(controller, target)

/datum/ai_behavior/enterprise_patron_walk/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/enterprise_patron_walk/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(BB_ENTERPRISE_PATRON_TARGET)
	var/mob/living/simple_animal/enterprise_patron/patron = controller.pawn
	if(!istype(patron) || QDELETED(patron) || patron.goal_stage != ENTERPRISE_PATRON_STAGE_WALK)
		return
	if(succeeded)
		patron.arrive()
	else if(controller.ai_status == AI_STATUS_OFF)
		patron.goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
	else
		patron.give_up()

/datum/ai_behavior/enterprise_patron_walk/out
	required_distance = 1
