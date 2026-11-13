/datum/ai_planning_subtree/behemoth_special_abilities
	var/datum/ai_behavior/behemoth_quake/quake_behavior = /datum/ai_behavior/behemoth_quake
	/// Percent chance per plan to quake once the cooldown is over.
	var/quake_chance = 20
	/// Farthest target distance, in tiles, that can start a quake.
	var/quake_range = 3

/datum/ai_planning_subtree/behemoth_special_abilities/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	if(QDELETED(target))
		return

	if(world.time <= controller.blackboard[BB_QUAKE_COOLDOWN] || get_dist(controller.pawn, target) > quake_range || !prob(quake_chance))
		return
	controller.queue_behavior(quake_behavior, BB_BASIC_MOB_CURRENT_TARGET)
	controller.set_blackboard_key(BB_QUAKE_COOLDOWN, world.time + 20 SECONDS)
	// Keep planning: a melee left out of this plan is cancelled, and that clears the target.

/datum/ai_behavior/behemoth_quake
	action_cooldown = 3 SECONDS

/datum/ai_behavior/behemoth_quake/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

/datum/ai_behavior/behemoth_quake/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/simple_animal/behemoth_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/turf/focalpoint = get_turf(target)

	if(QDELETED(target) || !focalpoint || !istype(behemoth_pawn))
		finish_action(controller, FALSE)
		return

	for (var/turf/open/visual in view(1, focalpoint))
		new /obj/effect/temp_visual/marker(visual)
	// A timer, not sleep(): perform runs inside the AI subsystem.
	addtimer(CALLBACK(src, PROC_REF(rupture), focalpoint, behemoth_pawn), 1.5 SECONDS)

	finish_action(controller, TRUE)

/// Stuns every mob around the marked turf, except the caster and its allies.
/datum/ai_behavior/behemoth_quake/proc/rupture(turf/focalpoint, mob/living/caster)
	for (var/mob/living/shaken in view(1, focalpoint))
		if(shaken == caster || (!QDELETED(caster) && caster.faction_check_atom(shaken)))
			continue
		shake_camera(shaken, 5, 5)
		to_chat(shaken, span_danger("<B>The ground ruptures beneath your feet!</B>"))
		shaken.Paralyze(50)
		var/obj/structure/flora/rock/giant_rock = new(get_turf(shaken))
		QDEL_IN(giant_rock, 200)
