/datum/ai_planning_subtree/collossus_special_abilities
	var/datum/ai_behavior/collossus_quake/quake_behavior = /datum/ai_behavior/collossus_quake
	/// Percent chance per plan to stomp once the cooldown is over.
	var/quake_chance = 20

/datum/ai_planning_subtree/collossus_special_abilities/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	if(QDELETED(target))
		return

	// The stomp only reaches adjacent mobs.
	if(world.time <= controller.blackboard[BB_EARTHQUAKE_COOLDOWN] || get_dist(controller.pawn, target) > 1 || !prob(quake_chance))
		return
	controller.queue_behavior(quake_behavior)
	controller.set_blackboard_key(BB_EARTHQUAKE_COOLDOWN, world.time + 25 SECONDS)
	// Keep planning: an attack left out of this plan is cancelled, and that clears the target.

/datum/ai_behavior/collossus_quake
	action_cooldown = 3 SECONDS

/datum/ai_behavior/collossus_quake/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/collossus_pawn = controller.pawn

	if(!istype(collossus_pawn))
		finish_action(controller, FALSE)
		return

	for (var/mob/living/stomped in view(1, collossus_pawn))
		// view() includes the colossus itself; its allies, such as its own crawlers, are spared too.
		if(stomped == collossus_pawn || collossus_pawn.faction_check_atom(stomped))
			continue
		new	/obj/effect/temp_visual/stomp(stomped)
		var/atom/throw_target = get_edge_target_turf(collossus_pawn, get_dir(collossus_pawn, stomped))
		stomped.throw_at(throw_target, 7, 4)
		stomped.adjustBruteLoss(20, damage_type = BCLASS_BLUNT)

	finish_action(controller, TRUE)
