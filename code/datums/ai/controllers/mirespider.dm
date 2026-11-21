/// Mire crawlers: the shared habits, then trailing a lurker.
/datum/ai_controller/mirespider
	parent_type = /datum/ai_controller/spider_base
	tail_subtrees = list(
		/datum/ai_planning_subtree/being_a_minion/mirespider,
	)

/// Mire lurkers: the shared habits plus web globs before the melee.
/datum/ai_controller/mirespider_lurker
	parent_type = /datum/ai_controller/spider_base
	attack_subtrees = list(
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/mirespider_lurker,
	)

/// Aragns: the shared habits and nothing else; the venom lives on the mob.
/datum/ai_controller/mirespider_paralytic
	parent_type = /datum/ai_controller/spider_base

/datum/ai_planning_subtree/being_a_minion/mirespider
	/// Blackboard key where we travel a place
	location_key = BB_TRAVEL_DESTINATION
	/// Who we're following
	follow_target = BB_FOLLOW_TARGET
	/// What do we do in order to travel
	travel_behavior = /datum/ai_behavior/travel_towards/stop_on_arrival

/datum/ai_planning_subtree/being_a_minion/mirespider/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/turf/travel = controller.blackboard[BB_TRAVEL_DESTINATION]
	var/mob/living/simple_animal/hostile/mirespider_lurker/following = controller.blackboard[BB_FOLLOW_TARGET]
	var/mob/living/pawn = controller.pawn

	if (travel)  // Check if travel is defined
		controller.queue_behavior(travel_behavior, BB_TRAVEL_DESTINATION)
		return SUBTREE_RETURN_FINISH_PLANNING  // end here

	else if (following)  // If we're following someone
		var/mob/target = following.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
		following.add_follower(pawn)

		// If the follow target has a target, stop following
		if (target)
			controller.clear_blackboard_key(BB_FOLLOW_TARGET)

		// If too far from the following target, stop following
		else if (get_dist(pawn, following) > 12)
			controller.clear_blackboard_key(BB_FOLLOW_TARGET)

		// Otherwise, continue following
		else
			controller.queue_behavior(/datum/ai_behavior/follow_friend/mirespider, BB_FOLLOW_TARGET)

		return SUBTREE_RETURN_FINISH_PLANNING  // end here
	return  // No travel target and no one to follow, being a minion in other ways

/datum/ai_behavior/follow_friend/mirespider
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/follow_friend/mirespider/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/simple_animal/hostile/mirespider_lurker/target = controller.blackboard[target_key]
	var/mob/living/simple_animal/hostile/mirespider_lurker/target_target = target.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	if (target_target)
		return FALSE

	if (QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/follow_friend/mirespider/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/simple_animal/hostile/mirespider_lurker/target = controller.blackboard[target_key]
	var/mob/living/simple_animal/hostile/mirespider_lurker/target_target = target.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	if (target_target)
		return  // Stop following if the target has a target

	if (QDELETED(target))
		return

	return

/datum/ai_planning_subtree/basic_ranged_attack_subtree/mirespider_lurker
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack

/datum/ai_planning_subtree/basic_ranged_attack_subtree/mirespider_lurker/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return

	// A downed target is wrapped, not shot.
	if(isliving(target) && spider_can_wrap(controller.pawn, target))
		controller.set_blackboard_key(BB_BASIC_MOB_COCOON_TARGET, target)
		controller.queue_behavior(/datum/ai_behavior/cocoon_target, BB_BASIC_MOB_COCOON_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/mob/living/simple_animal/hostile/mirespider_lurker/lurker = controller.pawn
	if (istype(lurker))
		lurker.clear_followers_if_any()

	controller.queue_behavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING

/atom/movable/screen/alert/status_effect/buff/healing/spider_cocoon
	name = "Spider loogies"
	desc = "Arachnid weave is stitching some of my wounds up slowly. While I am inside a cocoon, click here to struggle out."
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/buff/healing/spider_cocoon/Click(location, control, params)
	if(LAZYACCESS(params2list(params), SHIFT_CLICKED))
		return ..()
	if(usr != mob_viewer || !isliving(mob_viewer))
		return
	var/obj/structure/spider/cocoon/cocoon = mob_viewer.loc
	if(istype(cocoon))
		cocoon.start_escape(mob_viewer)

#define COCOON_FILTER "cocoon_glow"

/datum/status_effect/buff/healing/spider_cocoon
	id = "healing_spider"
	alert_type = /atom/movable/screen/alert/status_effect/buff/healing/spider_cocoon
	duration = 1800 SECONDS
	examine_text = "SUBJECTPRONOUN is covered in spider silk... eww!"
	healing_on_tick = 1
	outline_colour = "#4e4c4c00"
	var/blood_healing_on_tick = 20
	/// Heal per tick asked for; the parent's slot for it doubles as the duration.
	var/silk_heal_per_tick = 1

/// Keeps the 30 minutes: a bare number in the parent's slot would become the duration.
/datum/status_effect/buff/healing/spider_cocoon/on_creation(mob/living/new_owner, new_healing_on_tick)
	if(isnum(new_healing_on_tick))
		silk_heal_per_tick = new_healing_on_tick
	return ..(new_owner, null)

/datum/status_effect/buff/healing/spider_cocoon/on_apply()
	healing_on_tick = silk_heal_per_tick
	. = ..()
	//The hardier you are, the more likely you are to recover from grievous wounds.
	var/stat_bonus = 0
	stat_bonus += ((GET_MOB_ATTRIBUTE_VALUE(owner, STAT_CONSTITUTION) - 10 ) * 0.05)
	stat_bonus += ((GET_MOB_ATTRIBUTE_VALUE(owner, STAT_STRENGTH) - 10 ) * 0.05)
	stat_bonus += ((GET_MOB_ATTRIBUTE_VALUE(owner, STAT_ENDURANCE) - 10 ) * 0.05)
	if(stat_bonus > 0)
		healing_on_tick += stat_bonus
		blood_healing_on_tick += (stat_bonus * 10)
	var/filter = owner.get_filter(COCOON_FILTER)
	if (!filter)
		owner.add_filter(COCOON_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 60, "size" = 1))
	return TRUE

/datum/status_effect/buff/healing/spider_cocoon/tick()
	var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal_rogue(get_turf(owner))
	H.color = "#4e4c4c00"
	var/list/wCount = owner.get_wounds()
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		//Keeps the user alive
		owner.blood_volume = min(owner.blood_volume+blood_healing_on_tick, BLOOD_VOLUME_NORMAL)
	if(wCount.len > 0)
		owner.heal_wounds(healing_on_tick)
		owner.update_damage_overlays()
	owner.adjustBruteLoss(-healing_on_tick, 0)
	owner.adjustFireLoss(-healing_on_tick, 0)
	owner.adjustOxyLoss(-healing_on_tick * 5, 0)
	owner.adjustToxLoss(-healing_on_tick, 0)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -healing_on_tick)
	owner.adjustCloneLoss(-healing_on_tick, 0)

#undef COCOON_FILTER
