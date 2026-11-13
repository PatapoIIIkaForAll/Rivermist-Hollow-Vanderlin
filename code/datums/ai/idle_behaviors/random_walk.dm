/datum/idle_behavior/idle_random_walk
	///Chance that the mob random walks per second
	var/walk_chance = 25
	var/cooldown = 2 SECONDS
	var/next_time = 0

/datum/idle_behavior/idle_random_walk/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	. = ..()
	if(next_time > world.time)
		return
	if(!controller.able_to_run)
		return
	if(controller.blackboard[BB_BASIC_MOB_FOOD_TARGET]) // this means we are likely eating a corpse
		return
	if(controller.blackboard[BB_RESISTING]) //we are trying to resist
		return

	var/mob/living/simple_animal/wanderer = controller.pawn
	if(istype(wanderer))
		if(wanderer.binded)
			return

	next_time = world.time + cooldown
	var/mob/living/living_pawn = controller.pawn
	if(controller.can_move() && prob(walk_chance) && !HAS_TRAIT(living_pawn, TRAIT_IMMOBILIZED) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = get_leash_step_dir(controller, living_pawn) || pick(GLOB.alldirs)
		var/turf/step_turf = get_step(living_pawn, move_dir)
		if(ai_turf_is_hazardous(step_turf))
			return
		living_pawn.Move(step_turf, move_dir)

	if(prob(8))
		living_pawn.emote("idle")

/// Direction home for a leashed walker that strayed too far, or null to wander freely.
/datum/idle_behavior/idle_random_walk/proc/get_leash_step_dir(datum/ai_controller/controller, mob/living/living_pawn)
	var/turf/leash_turf = controller.blackboard[BB_IDLE_LEASH_TURF]
	if(!leash_turf || leash_turf.z != living_pawn.z)
		return null
	if(get_dist(living_pawn, leash_turf) <= controller.blackboard[BB_IDLE_LEASH_RANGE])
		return null
	var/home_dir = get_dir(living_pawn, leash_turf)
	var/turf/home_step = get_step(living_pawn, home_dir)
	if(!home_step || home_step.is_blocked_turf(exclude_mobs = TRUE))
		return null
	return home_dir
