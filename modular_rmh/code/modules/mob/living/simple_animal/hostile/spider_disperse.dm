// Spiders leave an occupied cocoon alone: they walk off, or keep quiet where they cannot.

/// A spider keeps at least this many tiles from every occupied cocoon.
#define SPIDER_COCOON_SPACE 5
/// An idle spider this close to an occupied cocoon starts shunning it.
#define SPIDER_COCOON_NOTICE 2
#define SPIDER_SHUN_TIME (5 MINUTES)
/// The longest walk, in steps, searched for a spot away from the cocoons.
#define SPIDER_DISPERSE_REACH 8
/// Turfs the spot search may visit.
#define SPIDER_DISPERSE_BUDGET 300
/// A spider still too close after this long gives up and keeps quiet.
#define SPIDER_DISPERSE_WALK_LIMIT (20 SECONDS)

// ---- Cocoons, lairs and who the hunt spares ----

/// Occupied cocoons within [radius] tiles of [center], on its level.
/proc/spider_cocoons_near(atom/center, radius)
	. = list()
	var/turf/here = get_turf(center)
	if(!here)
		return
	for(var/obj/structure/spider/cocoon/cocoon as anything in GLOB.occupied_spider_cocoons)
		var/turf/cocoon_turf = get_turf(cocoon)
		if(!cocoon_turf || cocoon_turf.z != here.z || get_dist(here, cocoon_turf) > radius)
			continue
		if(QDELETED(cocoon) || !cocoon.get_wrapped_victim())
			continue
		. += cocoon

/// Spider caves: spiders there stay by their cocoons and only go quiet.
/proc/spider_in_lair(atom/movable/spider)
	var/static/list/lair_areas = typecacheof(list(/area/under/cave/spider, /area/under/spiderbase, /area/outdoors/spidercave, /area/under/rmh_bogforest_caves/spiders))
	var/area/spider_area = get_area(spider)
	return is_type_in_typecache(spider_area, lair_areas)

/// TRUE for someone the hunt leaves alone: wound in a cocoon, or newly out of one.
/proc/spider_hunt_spares(atom/target)
	if(!isliving(target))
		return FALSE
	var/mob/living/living_target = target
	return istype(living_target.loc, /obj/structure/spider/cocoon) || world.time < living_target.kidnap_protected_until

// ---- Shunning and keeping quiet ----

/// [controller]'s spider keeps away from [cocoon] for a while.
/proc/spider_shun_cocoon(datum/ai_controller/controller, obj/structure/spider/cocoon/cocoon)
	if(!controller || QDELETED(cocoon))
		return
	controller.set_blackboard_key(BB_SPIDER_SHUNNED_COCOON, cocoon)
	controller.set_blackboard_key(BB_SPIDER_SHUNNED_UNTIL, world.time + SPIDER_SHUN_TIME)
	controller.clear_blackboard_key(BB_SPIDER_HUSHED_UNTIL)
	controller.clear_blackboard_key(BB_SPIDER_DISPERSE_SINCE)

/proc/spider_stop_shunning(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_SPIDER_SHUNNED_COCOON)
	controller.clear_blackboard_key(BB_SPIDER_SHUNNED_UNTIL)
	controller.clear_blackboard_key(BB_SPIDER_HUSHED_UNTIL)
	controller.clear_blackboard_key(BB_SPIDER_DISPERSE_SINCE)

/// The cocoon still shunned; null once it is empty or gone, or the time ran out.
/proc/spider_current_shun(datum/ai_controller/controller)
	var/obj/structure/spider/cocoon/cocoon = controller.blackboard[BB_SPIDER_SHUNNED_COCOON]
	if(isnull(cocoon) && isnull(controller.blackboard[BB_SPIDER_SHUNNED_UNTIL]))
		return null
	if(QDELETED(cocoon) || !cocoon.get_wrapped_victim() || world.time >= controller.blackboard[BB_SPIDER_SHUNNED_UNTIL])
		spider_stop_shunning(controller)
		return null
	return cocoon

/// A spider that cannot leave keeps quiet until its shun ends.
/proc/spider_hush(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_SPIDER_HUSHED_UNTIL, controller.blackboard[BB_SPIDER_SHUNNED_UNTIL])

/// TRUE while [spider] keeps quiet beside a cocoon.
/proc/spider_is_hushed(mob/living/spider)
	var/datum/ai_controller/controller = spider?.ai_controller
	if(!controller)
		return FALSE
	return world.time < controller.blackboard[BB_SPIDER_HUSHED_UNTIL]

/// TRUE when [spider] swallows an automatic idle noise; each spider kind's emote() asks.
/proc/spider_mutes_emote(mob/living/spider, act, intentional)
	if(intentional || act != "idle")
		return FALSE
	return spider_is_hushed(spider)

/// TRUE while a fight, a hunt, a meal, a brood, a wrap, an order or a do_after has the spider.
/proc/spider_has_other_business(datum/ai_controller/controller)
	var/static/list/busy_keys = list(
		BB_BASIC_MOB_CURRENT_TARGET,
		BB_BASIC_MOB_CURRENT_HORNY_TARGET,
		BB_BASIC_MOB_FOOD_TARGET,
		BB_SPIDER_BROOD_COCOON,
		BB_BASIC_MOB_COCOON_TARGET,
		BB_ACTIVE_PET_COMMAND,
	)
	var/mob/living/pawn = controller.pawn
	if(pawn.doing())
		return TRUE
	for(var/key in busy_keys)
		if(!isnull(controller.blackboard[key]))
			return TRUE
	return FALSE

// ---- A spot away from the cocoons ----

/// The nearest reachable open turf SPIDER_COCOON_SPACE or more from all [cocoons], or null.
/proc/spider_find_disperse_turf(mob/living/spider, list/cocoons)
	var/turf/start = get_turf(spider)
	if(!start)
		return null
	var/list/steps_to = list()
	steps_to[start] = 0
	var/list/queue = list(start)
	var/index = 0
	while(index < length(queue) && index < SPIDER_DISPERSE_BUDGET)
		index++
		var/turf/current = queue[index]
		var/steps = steps_to[current]
		if(current != start && spider_disperse_spot_ok(current, cocoons, spider))
			return current
		if(steps >= SPIDER_DISPERSE_REACH)
			continue
		for(var/direction in GLOB.cardinals)
			var/turf/next_turf = get_step(current, direction)
			if(!next_turf || !isnull(steps_to[next_turf]) || !spider_can_step(current, next_turf, spider))
				continue
			steps_to[next_turf] = steps + 1
			queue += next_turf
	return null

/// Far enough from every cocoon, and no one else stands there.
/proc/spider_disperse_spot_ok(turf/spot, list/cocoons, mob/living/spider)
	for(var/obj/structure/spider/cocoon/cocoon as anything in cocoons)
		if(get_dist(spot, cocoon) < SPIDER_COCOON_SPACE)
			return FALSE
	for(var/mob/living/other in spot)
		if(other != spider)
			return FALSE
	return TRUE

/// One cardinal step a walking spider can take: no wall, hazard or blocking object.
/proc/spider_can_step(turf/from_turf, turf/next_turf, mob/living/spider)
	if(next_turf.density || ai_turf_is_hazardous(next_turf) || !next_turf.can_traverse_safely(spider))
		return FALSE
	var/direction = get_dir(from_turf, next_turf)
	var/reverse = REVERSE_DIR(direction)
	for(var/obj/thing in next_turf)
		if(!thing.CanAStarPass(null, reverse, spider))
			return FALSE
	for(var/obj/thing in from_turf)
		if(!thing.CanAStarPass(null, direction, spider))
			return FALSE
	return TRUE

// ---- Walking away ----

/// After a wrap, a seal, or idling by an occupied cocoon: walk off, or keep quiet without a way out.
/datum/ai_planning_subtree/spider_disperse

/datum/ai_planning_subtree/spider_disperse/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/mob/living/pawn = controller.pawn
	if(!isturf(pawn.loc) || pawn.buckled || pawn.pulledby || spider_has_other_business(controller))
		return
	var/list/too_close = spider_cocoons_near(pawn, SPIDER_COCOON_SPACE - 1)
	if(!spider_current_shun(controller))
		var/obj/structure/spider/cocoon/noticed = spider_cocoon_to_notice(pawn, too_close)
		if(!noticed)
			return
		spider_shun_cocoon(controller, noticed)
	if(!length(too_close))
		controller.clear_blackboard_key(BB_SPIDER_HUSHED_UNTIL)
		return
	if(spider_is_hushed(pawn))
		return
	controller.queue_behavior(/datum/ai_behavior/spider_disperse, BB_SPIDER_DISPERSE_TURF)
	return SUBTREE_RETURN_FINISH_PLANNING

/// The nearest of [cocoons] within SPIDER_COCOON_NOTICE of [pawn], or null.
/datum/ai_planning_subtree/spider_disperse/proc/spider_cocoon_to_notice(mob/living/pawn, list/cocoons)
	var/obj/structure/spider/cocoon/nearest
	for(var/obj/structure/spider/cocoon/cocoon as anything in cocoons)
		var/distance = get_dist(pawn, cocoon)
		if(distance > SPIDER_COCOON_NOTICE)
			continue
		if(!nearest || distance < get_dist(pawn, nearest))
			nearest = cocoon
	return nearest

/// Walks to a spot away from every occupied cocoon; with no spot, or in a lair, it keeps quiet.
/datum/ai_behavior/spider_disperse
	required_distance = 0
	action_cooldown = 1 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/spider_disperse/setup(datum/ai_controller/controller, turf_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/started = controller.blackboard[BB_SPIDER_DISPERSE_SINCE]
	if(isnull(started))
		started = world.time
		controller.set_blackboard_key(BB_SPIDER_DISPERSE_SINCE, started)
	var/turf/destination
	if(world.time <= started + SPIDER_DISPERSE_WALK_LIMIT && !spider_in_lair(pawn))
		destination = spider_find_disperse_turf(pawn, spider_cocoons_near(pawn, SPIDER_COCOON_SPACE + SPIDER_DISPERSE_REACH))
	if(!destination)
		spider_hush(controller)
		return FALSE
	controller.set_blackboard_key(turf_key, destination)
	set_movement_target(controller, destination)

/datum/ai_behavior/spider_disperse/perform(seconds_per_tick, datum/ai_controller/controller, turf_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	if(!length(spider_cocoons_near(pawn, SPIDER_COCOON_SPACE - 1)))
		finish_action(controller, TRUE, turf_key)
		return
	if(world.time > controller.blackboard[BB_SPIDER_DISPERSE_SINCE] + SPIDER_DISPERSE_WALK_LIMIT)
		spider_hush(controller)
		finish_action(controller, FALSE, turf_key)
		return
	// On the spot, yet a cocoon is still near: the next plan looks again.
	if(get_turf(pawn) == controller.blackboard[turf_key])
		finish_action(controller, FALSE, turf_key)

/datum/ai_behavior/spider_disperse/finish_action(datum/ai_controller/controller, succeeded, turf_key)
	. = ..()
	controller.clear_blackboard_key(turf_key)
	if(succeeded)
		controller.clear_blackboard_key(BB_SPIDER_DISPERSE_SINCE)

#undef SPIDER_COCOON_SPACE
#undef SPIDER_COCOON_NOTICE
#undef SPIDER_SHUN_TIME
#undef SPIDER_DISPERSE_REACH
#undef SPIDER_DISPERSE_BUDGET
#undef SPIDER_DISPERSE_WALK_LIMIT
