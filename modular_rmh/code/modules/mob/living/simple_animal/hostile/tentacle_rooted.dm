// Rooted burrow tentacles: the strike from the hole and the colony hand-off.

// Shared with tentacle_spawn.dm, which loads after this file and undefines them.
#define BB_TENTACLE_AMBUSH_HOME "BB_tentacle_ambush_home"
#define BB_TENTACLE_AMBUSH_LEASH "BB_tentacle_ambush_leash"
#define BB_TENTACLE_COLONY_KIDNAP_TARGET "BB_tentacle_colony_kidnap_target"

#define TENTACLE_ROOTED_TRAIT "tentacle_rooted"
/// Time between two tiles of the hand-off.
#define TENTACLE_HANDOFF_STEP (1 SECONDS)
/// A hand-off that has not reached the nest by then lets go.
#define TENTACLE_HANDOFF_TIMEOUT (45 SECONDS)
/// Trait on prey that a hand-off is passing along; the source is the hand-off.
#define TRAIT_TENTACLE_PASSED_ALONG "tentacle_passed_along"
/// Longest a colony plays with downed prey, or waits for a scene that never comes, before passing it on.
#define TENTACLE_PLAY_CAP (75 SECONDS)
/// How long prey counts as played.
#define TENTACLE_PLAYED_TIME (3 MINUTES)

/// Fixes the tentacle in its hole: no AI steps, no pulls, pushes or throws. The bounded component catches the rest.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/root_in_place()
	anchored = TRUE
	move_resist = INFINITY
	ADD_TRAIT(src, TRAIT_AI_MOVEMENT_HALTED, TENTACLE_ROOTED_TRAIT)

/// TRUE when the target is on this z-level and inside the strike range, or the leash of a mobile tentacle.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/is_in_ambush_reach(atom/target)
	var/turf/our_turf = get_turf(src)
	var/turf/their_turf = get_turf(target)
	if(!our_turf || !their_turf || our_turf.z != their_turf.z)
		return FALSE
	return get_dist(our_turf, their_turf) <= (rooted ? strike_range : leash_distance)

// --- Strike from the hole ------------------------------------------------------------------------

/// Hits an adjacent target and lashes one two tiles out. It never moves the tentacle.
/datum/ai_behavior/basic_melee_attack/tentacle_rooted
	action_cooldown = 0.2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/tentacle_rooted/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	if(!controller.blackboard_key_exists(targetting_datum_key))
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")
	if(!controller.blackboard_key_exists(target_key))
		return FALSE
	SEND_SIGNAL(controller.pawn, COMSIG_COMBAT_TARGET_SET, TRUE)
	return TRUE

/datum/ai_behavior/basic_melee_attack/tentacle_rooted/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	// The targeting datum drops a target that left the strike range.
	if(!istype(tentacle) || QDELETED(target) || !targetting_datum.can_attack(tentacle, target))
		finish_action(controller, FALSE, target_key)
		return
	tentacle.emerge_from_ground()
	if(tentacle.CanReach(target))
		return ..()
	if(isliving(target) && get_dist(tentacle, target) == HORNY_LASH_RANGE)
		tentacle.face_atom(target)
		horny_lash(tentacle, target, controller, tentacle.get_horny_family_profile())

/// One lash at prey two tiles out, so it lands next to the hole.
/datum/ai_behavior/tentacle_rooted_lash
	action_cooldown = 0.5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/tentacle_rooted_lash/setup(datum/ai_controller/controller, target_key)
	. = ..()
	return isliving(controller.blackboard[target_key])

/datum/ai_behavior/tentacle_rooted_lash/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(istype(tentacle) && isliving(target) && get_dist(tentacle, target) == HORNY_LASH_RANGE && !tentacle_prey_is_claimed(tentacle, target))
		tentacle.emerge_from_ground()
		horny_lash(tentacle, target, controller, tentacle.get_horny_family_profile())
	finish_action(controller, TRUE)

// --- Downed prey without a colony ----------------------------------------------------------------

/// Rooted tentacles take only adjacent prey and lash prey at two tiles nearer first.
/datum/ai_planning_subtree/kidnap_defeated_prey/tentacle_rooted

/datum/ai_planning_subtree/kidnap_defeated_prey/tentacle_rooted/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	if(!istype(tentacle) || !tentacle.rooted)
		return ..()
	if(!tentacle.kidnap_lair_tag && !tentacle.kidnap_captivity_profile)
		return
	var/mob/living/target = controller.blackboard[BB_KIDNAP_TARGET]
	if(target && (QDELETED(target) || !tentacle.is_in_ambush_reach(target) || !tentacle.is_kidnap_candidate(target)))
		controller.clear_blackboard_key(BB_KIDNAP_TARGET)
		target = null
	if(!target)
		for(var/mob/living/candidate in view(tentacle.strike_range, tentacle))
			if(!tentacle.is_in_ambush_reach(candidate) || !tentacle.is_kidnap_candidate(candidate))
				continue
			target = candidate
			controller.set_blackboard_key(BB_KIDNAP_TARGET, candidate)
			break
	if(!target)
		return
	// The haul needs adjacency; queued for prey further out it would wait forever and freeze planning.
	if(tentacle.Adjacent(target))
		// Prey in another's hold, scene or knot waits for the release.
		if((target.pulledby && target.pulledby != tentacle) || tentacle_prey_in_scene_or_tie(target))
			return
		controller.queue_behavior(/datum/ai_behavior/kidnap_defeated_prey/tentacle_rooted, BB_KIDNAP_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/tentacle_rooted_lash, BB_KIDNAP_TARGET)

/// The ordinary haul without movement; it gives up at once when the prey is no longer adjacent.
/datum/ai_behavior/kidnap_defeated_prey/tentacle_rooted
	behavior_flags = NONE

/datum/ai_behavior/kidnap_defeated_prey/tentacle_rooted/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/pawn = controller.pawn
	var/mob/living/victim = controller.blackboard[target_key]
	if(!istype(pawn) || QDELETED(victim) || !pawn.Adjacent(victim))
		finish_action(controller, FALSE, target_key)
		return
	pawn.emerge_from_ground()
	return ..()

// --- Colony defenders ----------------------------------------------------------------------------

/// Defenders bind adjacent prey and hand it to the small tentacles; prey two tiles out is lashed in first.
/datum/ai_planning_subtree/tentacle_colony_kidnap

/datum/ai_planning_subtree/tentacle_colony_kidnap/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender = controller.pawn
	if(!istype(defender) || !defender.get_colony_core())
		return

	var/mob/living/target = controller.blackboard[BB_TENTACLE_COLONY_KIDNAP_TARGET]
	if(target && (QDELETED(target) || !defender.is_in_ambush_reach(target) || !defender.is_colony_kidnap_candidate(target)))
		controller.clear_blackboard_key(BB_TENTACLE_COLONY_KIDNAP_TARGET)
		target = null
	if(!target)
		for(var/mob/living/candidate in view(defender.rooted ? defender.strike_range : KIDNAP_GUARD_VIEW, defender))
			if(!defender.is_in_ambush_reach(candidate) || !defender.is_colony_kidnap_candidate(candidate))
				continue
			target = candidate
			controller.set_blackboard_key(BB_TENTACLE_COLONY_KIDNAP_TARGET, candidate)
			break
	if(!target)
		return

	if(defender.Adjacent(target))
		// While play is pending the horny subtrees get their turn.
		if(!defender.colony_play_allows_handoff(target))
			return
		controller.queue_behavior(/datum/ai_behavior/tentacle_colony_kidnap, BB_TENTACLE_COLONY_KIDNAP_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/tentacle_rooted_lash, BB_TENTACLE_COLONY_KIDNAP_TARGET)

/// Binds adjacent prey and starts its hand-off in one beat; the hand-off then runs on its own timers.
/datum/ai_behavior/tentacle_colony_kidnap
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/tentacle_colony_kidnap/setup(datum/ai_controller/controller, target_key)
	. = ..()
	return isliving(controller.blackboard[target_key])

/datum/ai_behavior/tentacle_colony_kidnap/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender = controller.pawn
	var/mob/living/victim = controller.blackboard[target_key]
	if(!istype(defender) || QDELETED(victim) || !defender.Adjacent(victim))
		finish_action(controller, FALSE, target_key)
		return
	finish_action(controller, !!defender.begin_colony_kidnap(victim), target_key)

/datum/ai_behavior/tentacle_colony_kidnap/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

// --- The hand-off --------------------------------------------------------------------------------

/// Small tentacles pass bound prey one tile per beat to a colony nest. Holds only weak references.
/datum/tentacle_handoff
	/// The prey being passed along.
	var/datum/weakref/victim_ref
	/// The defender that bound the prey; it holds the reservation and is the captor.
	var/datum/weakref/defender_ref
	/// The colony core whose nest the prey goes to.
	var/datum/weakref/core_ref
	/// The nest turf the prey is passed toward.
	var/turf/nest_turf
	/// Where the prey must lie at the next beat; anywhere else means someone moved it.
	var/turf/expected_turf
	/// Remaining turfs to the nest, nearest first.
	var/list/path
	/// world.time when the hand-off began.
	var/started_at
	/// Tiles passed so far.
	var/tiles_passed = 0
	/// Timer of the next beat.
	var/timer_id

/datum/tentacle_handoff/New(mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender, mob/living/victim, obj/structure/tentacle_growth/colony_core/core)
	. = ..()
	victim_ref = WEAKREF(victim)
	defender_ref = WEAKREF(defender)
	core_ref = WEAKREF(core)
	started_at = world.time
	expected_turf = get_turf(victim)
	nest_turf = core.get_available_nest_turf()
	ADD_TRAIT(victim, TRAIT_TENTACLE_PASSED_ALONG, REF(src))
	new /obj/effect/temp_visual/tentacle_handoff(expected_turf)
	timer_id = addtimer(CALLBACK(src, PROC_REF(advance)), TENTACLE_HANDOFF_STEP, TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/tentacle_handoff/Destroy()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	var/mob/living/victim = victim_ref?.resolve()
	if(victim)
		REMOVE_TRAIT(victim, TRAIT_TENTACLE_PASSED_ALONG, REF(src))
	victim_ref = null
	defender_ref = null
	core_ref = null
	nest_turf = null
	expected_turf = null
	path = null
	return ..()

/// One beat: checks that the hand-off may go on, then passes the prey one tile.
/datum/tentacle_handoff/proc/advance()
	timer_id = null
	var/mob/living/victim = victim_ref?.resolve()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender = defender_ref?.resolve()
	var/obj/structure/tentacle_growth/colony_core/core = core_ref?.resolve()
	if(!can_continue(victim, defender, core) || !update_nest_turf(victim, core))
		stop(victim, defender)
		return
	if(get_turf(victim) != nest_turf)
		if(!pass_one_tile(victim))
			stop(victim, defender)
			return
		tiles_passed++
		new /obj/effect/temp_visual/tentacle_handoff(expected_turf)
		if(get_turf(victim) != nest_turf)
			if(!(tiles_passed % 3))
				victim.visible_message(span_danger("Tentacles pass [victim] from grip to grip."))
			timer_id = addtimer(CALLBACK(src, PROC_REF(advance)), TENTACLE_HANDOFF_STEP, TIMER_STOPPABLE | TIMER_DELETE_ME)
			return
	if(!defender.finish_colony_kidnap(victim, nest_turf))
		victim.clear_kidnap_reservation(defender)
	qdel(src)

/// TRUE while nobody took the prey, it lies where it was put, and defender, core and time allow it.
/datum/tentacle_handoff/proc/can_continue(mob/living/victim, mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender, obj/structure/tentacle_growth/colony_core/core)
	if(QDELETED(victim) || QDELETED(defender) || QDELETED(core) || defender.stat == DEAD)
		return FALSE
	if(defender.get_colony_core() != core || world.time > started_at + TENTACLE_HANDOFF_TIMEOUT)
		return FALSE
	if(victim.pulledby || victim.buckled || !isturf(victim.loc) || victim.loc != expected_turf)
		return FALSE
	if(victim.get_kidnap_reserver() != defender)
		return FALSE
	return defender.is_colony_kidnap_candidate(victim, allow_own_reservation = TRUE)

/// Keeps a free nest turf as the goal, picking a new one when the old one filled up. FALSE when none is left.
/datum/tentacle_handoff/proc/update_nest_turf(mob/living/victim, obj/structure/tentacle_growth/colony_core/core)
	if(nest_turf && get_turf(victim) == nest_turf)
		return TRUE
	var/obj/structure/tentacle_growth/nest/nest = nest_turf ? (locate() in nest_turf) : null
	if(nest_turf && !nest?.has_buckled_mobs() && !nest_turf.is_blocked_turf(TRUE, victim))
		return TRUE
	nest_turf = core.get_available_nest_turf()
	path = null
	return !!nest_turf

/// Moves the prey to the next turf of its path, finding a new path once when the way is blocked.
/datum/tentacle_handoff/proc/pass_one_tile(mob/living/victim)
	for(var/attempt in 1 to 2)
		if(!length(path) || attempt == 2)
			find_path(victim)
		// Path finding can sleep; someone may have taken the prey meanwhile.
		if(QDELETED(victim) || victim.loc != expected_turf || victim.pulledby || victim.buckled)
			return FALSE
		if(!length(path))
			return FALSE
		var/turf/next_turf = path[1]
		if(get_dist(victim, next_turf) == 1 && victim.Move(next_turf, get_dir(victim, next_turf)) && victim.loc == next_turf)
			path.Cut(1, 2)
			expected_turf = next_turf
			return TRUE
	return FALSE

/// Fills path with the turfs from the prey to the nest turf, without the turf the prey lies on.
/datum/tentacle_handoff/proc/find_path(mob/living/victim)
	path = get_path_to(victim, nest_turf, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 0, 60)
	while(length(path) && path[1] == get_turf(victim))
		path.Cut(1, 2)

/// Lets go: frees the reservation the defender holds and ends the hand-off. Cuffs stay on.
/datum/tentacle_handoff/proc/stop(mob/living/victim, mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender)
	if(!QDELETED(victim))
		victim.clear_kidnap_reservation(defender)
		victim.visible_message(span_notice("The small tentacles let go of [victim] and sink back into the ground."))
	qdel(src)

/// Small tentacles that rise under prey being passed along, then sink again.
/obj/effect/temp_visual/tentacle_handoff
	name = "small tentacles"
	icon = 'modular_rmh/icons/mob/monster/tentacles_grey.dmi'
	icon_state = "tentacle_group_rise"
	layer = BELOW_MOB_LAYER
	randomdir = FALSE
	// The one-shot state has 11 frames of one tick each.
	duration = 11

/obj/effect/temp_visual/tentacle_handoff/Initialize(mapload)
	. = ..()
	apply_tentacle_palette(tentacle_palette_for_turf(get_turf(src)))
	flick("tentacle_group_rise", src)

// --- Rules shared by every tentacle ---------------------------------------------------------------

/// TRUE when another captor holds the prey's reservation, or a hand-off passes the prey along.
/proc/tentacle_prey_is_claimed(mob/living/tentacle, atom/target)
	if(!isliving(target))
		return FALSE
	var/mob/living/victim = target
	if(HAS_TRAIT(victim, TRAIT_TENTACLE_PASSED_ALONG))
		return TRUE
	var/mob/living/reserver = victim.get_kidnap_reserver()
	return reserver && reserver != tentacle

/// TRUE while a sex act involves the prey, or a knot ties it to someone.
/proc/tentacle_prey_in_scene_or_tie(mob/living/victim)
	if(length(victim.sex_scene?.get_actions_involving(victim)))
		return TRUE
	var/datum/component/knotting/own_knot = victim.GetComponent(/datum/component/knotting)
	if(own_knot?.knotted_recipient)
		return TRUE
	for(var/mob/living/nearby in range(1, victim))
		if(nearby == victim)
			continue
		var/datum/component/knotting/knot = nearby.GetComponent(/datum/component/knotting)
		if(knot?.knotted_recipient == victim)
			return TRUE
	return FALSE

// --- Play first, then pass the prey along ---------------------------------------------------------

/// Downed prey a colony has had its scene with; the hand-off may take it.
/datum/status_effect/tentacle_colony_played
	id = "tentacle_colony_played"
	duration = TENTACLE_PLAYED_TIME
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/// Downed prey a colony wants to play with before it passes it on. Holds no mob references.
/datum/status_effect/tentacle_colony_play
	id = "tentacle_colony_play"
	duration = 5 MINUTES
	alert_type = null
	/// world.time when the colony first held the prey back for play.
	var/started_at
	/// world.time when a colony act was first seen on the prey; null until then.
	var/first_act_at

/datum/status_effect/tentacle_colony_play/on_apply()
	. = ..()
	started_at = world.time

/// Ends the pending play and marks the prey played.
/proc/mark_tentacle_colony_played(mob/living/victim)
	victim.remove_status_effect(/datum/status_effect/tentacle_colony_play)
	victim.apply_status_effect(/datum/status_effect/tentacle_colony_played)

/// TRUE when a colony tentacle may start or keep a scene with the prey. Played prey takes no new scenes.
/proc/tentacle_colony_play_allows_scene(mob/living/tentacle, mob/living/victim)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/colony_tentacle = tentacle
	if(!istype(colony_tentacle) || !isliving(victim) || !colony_tentacle.get_colony_core())
		return TRUE
	var/played = victim.has_status_effect(/datum/status_effect/tentacle_colony_played)
	if(!played && !victim.has_status_effect(/datum/status_effect/tentacle_colony_play))
		return TRUE
	var/datum/ai_controller/controller = tentacle.ai_controller
	var/hunt_started = controller?.blackboard[BB_HORNY_TIME_START]
	// A running hunt on this prey goes on until the cap.
	if(controller?.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == victim && !isnull(hunt_started))
		return world.time - hunt_started < TENTACLE_PLAY_CAP
	return !played

/// TRUE when the prey counts as played: the mark, or a horny defeat that a tentacle caused.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/colony_prey_is_played(mob/living/victim)
	if(victim.has_status_effect(/datum/status_effect/tentacle_colony_played))
		return TRUE
	if(!victim.has_status_effect(/datum/status_effect/defeat_knockout) || victim.last_defeat_snapshot?.reason != DEFEAT_REASON_HORNY)
		return FALSE
	// A horny defeat by some other mob gave the tentacles nothing yet, so they play first.
	var/mob/living/defeat_source = victim.last_defeat_snapshot.source_weakref?.resolve() || victim.recent_damage_source_attacker_weakref?.resolve()
	return istype(defeat_source, /mob/living/simple_animal/hostile/retaliate/tentacle)

/// TRUE when this tentacle's preference gates would allow a scene with the prey, at any range.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/colony_may_play_with(mob/living/victim)
	var/datum/targetting_datum/basic/tentacle/ambusher/targeting = ai_controller?.blackboard[BB_TARGETTING_DATUM]
	if(!istype(targeting))
		return FALSE
	return targeting.can_horny_at_any_range(src, victim)

/// TRUE when an act by a tentacle of this colony runs on the prey.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/colony_acts_on(mob/living/victim)
	var/obj/structure/tentacle_growth/colony_core/core = get_colony_core()
	for(var/datum/sex_action/action as anything in victim.sex_scene?.get_actions_involving(victim))
		var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/user = action.action_user
		if(istype(user) && user.get_colony_core() == core)
			return TRUE
	return FALSE

/// TRUE when the hand-off may take adjacent prey now. Otherwise it keeps the pending play and its caps.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/colony_play_allows_handoff(mob/living/victim)
	// Held or in a scene: wait for the release; the pending play caps how long that lasts.
	if((victim.pulledby && victim.pulledby != src) || tentacle_prey_in_scene_or_tie(victim))
		note_colony_play(victim)
		return FALSE
	if(colony_prey_is_played(victim) || !colony_may_play_with(victim))
		return TRUE
	note_colony_play(victim)
	return FALSE

/// Starts or updates the pending play; marks the prey played once a cap runs out.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/note_colony_play(mob/living/victim)
	if(victim.has_status_effect(/datum/status_effect/tentacle_colony_played))
		return
	var/datum/status_effect/tentacle_colony_play/play = victim.has_status_effect(/datum/status_effect/tentacle_colony_play)
	if(!play)
		play = victim.apply_status_effect(/datum/status_effect/tentacle_colony_play)
	if(!play)
		return
	if(isnull(play.first_act_at) && colony_acts_on(victim))
		play.first_act_at = world.time
	var/play_from = isnull(play.first_act_at) ? play.started_at : play.first_act_at
	if(world.time - play_from >= TENTACLE_PLAY_CAP)
		mark_tentacle_colony_played(victim)

/// A colony hunt that ends after acts on pending prey marks it played.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/on_hunt_phase_changed(datum/source, old_phase, new_phase, mob/living/target)
	SIGNAL_HANDLER
	if(new_phase || !old_phase || !isliving(target) || !get_colony_core())
		return
	var/datum/status_effect/tentacle_colony_play/play = target.has_status_effect(/datum/status_effect/tentacle_colony_play)
	if(!play)
		return
	var/last_scene = LAZYACCESS(target.horny_scene_captors, REF(src))
	if(!isnull(play.first_act_at) || (last_scene && last_scene >= play.started_at))
		mark_tentacle_colony_played(target)

#undef TENTACLE_ROOTED_TRAIT
#undef TENTACLE_HANDOFF_STEP
#undef TENTACLE_HANDOFF_TIMEOUT
#undef TRAIT_TENTACLE_PASSED_ALONG
#undef TENTACLE_PLAY_CAP
#undef TENTACLE_PLAYED_TIME
