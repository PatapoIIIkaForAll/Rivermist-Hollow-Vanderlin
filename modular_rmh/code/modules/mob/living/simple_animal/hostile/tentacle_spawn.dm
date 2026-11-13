// The BB_TENTACLE_* keys are defined in tentacle_rooted.dm, which loads first.

/// Holds a burrow tentacle near its hole. Skips bounds resolution while either end is off the map.
/datum/component/bounded/tentacle_burrow

/datum/component/bounded/tentacle_burrow/resolve_stranded()
	if(QDELETED(src) || QDELETED(parent) || QDELETED(master) || !get_turf(parent) || !get_turf(master))
		return
	return ..()

/datum/targetting_datum/basic/tentacle/ambusher
	/// Set only during one synchronous can_horny call that ignores the home range.
	var/tmp/skip_home_range = FALSE

/// can_horny without the home range: the preference and claim gates alone.
/datum/targetting_datum/basic/tentacle/ambusher/proc/can_horny_at_any_range(mob/living/living_mob, atom/target)
	skip_home_range = TRUE
	. = can_horny(living_mob, target)
	skip_home_range = FALSE

/datum/targetting_datum/basic/tentacle/ambusher/proc/is_within_home_range(mob/living/living_mob, atom/target)
	var/turf/home_turf = living_mob.ai_controller?.blackboard[BB_TENTACLE_AMBUSH_HOME]
	// Rooted tentacles store their strike range here, mobile ones their leash.
	var/leash_distance = living_mob.ai_controller?.blackboard[BB_TENTACLE_AMBUSH_LEASH]
	var/turf/pawn_turf = get_turf(living_mob)
	var/turf/target_turf = get_turf(target)
	if(!home_turf || !pawn_turf || !target_turf || leash_distance <= 0)
		return FALSE
	if(home_turf.z != pawn_turf.z || home_turf.z != target_turf.z)
		return FALSE
	if(get_dist(home_turf, pawn_turf) > leash_distance)
		return FALSE
	return get_dist(home_turf, target_turf) <= leash_distance

/datum/targetting_datum/basic/tentacle/ambusher/can_attack(mob/living/living_mob, atom/target)
	// Prey another captor reserved or a hand-off passes along is off limits.
	if(tentacle_prey_is_claimed(living_mob, target))
		return FALSE
	if(!..())
		return FALSE
	return is_within_home_range(living_mob, target)

/datum/targetting_datum/basic/tentacle/ambusher/can_horny(mob/living/living_mob, atom/target)
	if(tentacle_prey_is_claimed(living_mob, target))
		return FALSE
	if(!..())
		return FALSE
	if(!skip_home_range && !is_within_home_range(living_mob, target))
		return FALSE
	return tentacle_colony_play_allows_scene(living_mob, target)

/datum/targetting_datum/basic/tentacle/ambusher/maneater

/datum/targetting_datum/basic/tentacle/ambusher/maneater/is_horny_pref_target(mob/living/living_mob, atom/target)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if(!is_horny_mob_family_allowed(living_mob, human_target))
		return FALSE
	// Maneater vines are sexless plants. Either ordinary horny-mob gender opt-in enables them;
	// the dedicated family preference remains the authoritative plant-specific gate.
	return !!get_horny_mob_pref_flags(human_target)

/datum/ai_planning_subtree/basic_melee_attack_subtree/agile/tentacle_ambusher

/datum/ai_planning_subtree/basic_melee_attack_subtree/agile/tentacle_ambusher/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	if(!tentacle?.rooted)
		tentacle?.emerge_from_ground()
		return ..()
	// A rooted tentacle cannot follow; a target out of reach is dropped and the tentacle stays down.
	if(!tentacle.is_in_ambush_reach(target))
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return
	tentacle.emerge_from_ground()
	controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/tentacle_rooted, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/tentacle_return_home

/datum/ai_planning_subtree/tentacle_return_home/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] || controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	// Prey being lashed in keeps the tentacle out of its hole.
	if(controller.blackboard[BB_KIDNAP_TARGET] || controller.blackboard[BB_TENTACLE_COLONY_KIDNAP_TARGET])
		return

	var/turf/home_turf = controller.blackboard[BB_TENTACLE_AMBUSH_HOME]
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	if(!home_turf || !istype(tentacle))
		return

	if(tentacle.rooted || get_turf(tentacle) == home_turf || tentacle.Adjacent(home_turf))
		tentacle.hide_in_ground()
		return

	controller.queue_behavior(/datum/ai_behavior/tentacle_return_home, BB_TENTACLE_AMBUSH_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/tentacle_return_home
	action_cooldown = 0.5 SECONDS
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/tentacle_return_home/setup(datum/ai_controller/controller, home_key)
	. = ..()
	var/turf/home_turf = controller.blackboard[home_key]
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	if(!home_turf || !istype(tentacle))
		return FALSE
	if(get_turf(tentacle) == home_turf || tentacle.Adjacent(home_turf))
		tentacle.hide_in_ground()
		return FALSE

	tentacle.emerge_from_ground()
	set_movement_target(controller, home_turf)
	return TRUE

/datum/ai_behavior/tentacle_return_home/perform(seconds_per_tick, datum/ai_controller/controller, home_key)
	. = ..()
	var/turf/home_turf = controller.blackboard[home_key]
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = controller.pawn
	if(!home_turf || !istype(tentacle))
		finish_action(controller, FALSE, home_key)
		return
	if(get_turf(tentacle) != home_turf && !tentacle.Adjacent(home_turf))
		return

	tentacle.hide_in_ground()
	finish_action(controller, TRUE, home_key)

/datum/ai_controller/tentacle_ambusher
	movement_delay = 0.5 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	horny_pref_family_flag = HORNY_MOB_TYPE_TENTACLES

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/tentacle/ambusher(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/kidnap_defeated_prey/tentacle_rooted,
		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/horny,

		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/agile/tentacle_ambusher,

		/datum/ai_planning_subtree/tentacle_return_home,
	)

	idle_behavior = /datum/idle_behavior/nothing

/datum/ai_controller/tentacle_ambusher/maneater
	horny_pref_family_flag = HORNY_MOB_TYPE_MANEATERS
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/tentacle/ambusher/maneater(),
	)

/datum/ai_controller/tentacle_colony_defender
	movement_delay = 0.5 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	horny_pref_family_flag = HORNY_MOB_TYPE_TENTACLES

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/tentacle/ambusher(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/tentacle_colony_kidnap,
		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/horny,

		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/agile/tentacle_ambusher,

		/datum/ai_planning_subtree/tentacle_return_home,
	)

	idle_behavior = /datum/idle_behavior/nothing

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher
	name = "greater burrow tentacle"
	desc = "A thick, wine-dark tentacle rooted beneath the soil. It looks unwilling to stray far from its burrow."
	icon = 'modular_rmh/icons/mob/monster/tentacles_grey.dmi'
	icon_state = "tentacle_big"
	icon_living = "tentacle_big"
	icon_dead = "tentacle_big_dead"
	ai_controller = /datum/ai_controller/tentacle_ambusher
	retint_on_move = FALSE

	health = 80
	maxHealth = 80
	base_constitution = 7
	base_strength = 8
	base_speed = 10
	melee_damage_lower = 8
	melee_damage_upper = 14
	vision_range = 7
	aggro_vision_range = 7

	/// Maximum distance a mobile tentacle can move or select a target from its initial turf.
	var/leash_distance = 7
	/// Whether the tentacle never leaves its hole and strikes only within strike_range.
	var/rooted = TRUE
	/// Reach of a rooted tentacle from its hole: a hit at one tile, the lash at two.
	var/strike_range = 2
	/// Icon state used while lying in wait. Null keeps the living sprite.
	var/hide_icon_state = "tentacle_big_hide_on"
	/// One-shot emergence animation. Null means the living sprite simply appears.
	var/emerge_icon_state = "tentacle_big_hide_off"
	/// Name shown while hidden.
	var/hidden_name = "burrow"
	/// Description shown while hidden.
	var/hidden_desc = "A hole in the ground with a slick rim. Now and then a slick tip comes up and tests the air."
	/// Whether the tentacle is currently withdrawn into its burrow.
	var/ambush_hidden = FALSE
	/// Real name, kept while the hidden one shows.
	var/tmp/revealed_name
	/// Real description, kept while the hidden one shows.
	var/tmp/revealed_desc
	/// Colony which produced this defender. A weak reference lets the defender harmlessly fall back to
	/// ordinary ambush behavior if its core is destroyed.
	var/tmp/datum/weakref/colony_core_ref

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/Initialize(mapload)
	. = ..()
	apply_tentacle_kind()
	var/turf/home_turf = get_turf(src)
	if(home_turf)
		var/reach = rooted ? strike_range : leash_distance
		ai_controller?.set_blackboard_key(BB_TENTACLE_AMBUSH_HOME, home_turf)
		ai_controller?.set_blackboard_key(BB_TENTACLE_AMBUSH_LEASH, reach)
		AddComponent(/datum/component/bounded/tentacle_burrow, home_turf, 0, rooted ? 0 : leash_distance, null, null, FALSE, FALSE)
	if(rooted)
		root_in_place()
	RegisterSignal(src, COMSIG_HORNY_TARGET_SET, PROC_REF(on_horny_target_set))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_ambush_attacked))
	RegisterSignal(src, COMSIG_HORNY_HUNT_PHASE_CHANGED, PROC_REF(on_hunt_phase_changed))
	hide_in_ground()

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/Destroy()
	if(isliving(pulling))
		var/mob/living/pulled_victim = pulling
		pulled_victim.clear_kidnap_reservation(src)
	if(pulling)
		stop_pulling()
	colony_core_ref = null
	UnregisterSignal(src, list(COMSIG_HORNY_TARGET_SET, COMSIG_ATOM_WAS_ATTACKED, COMSIG_HORNY_HUNT_PHASE_CHANGED))
	return ..()

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/death(gibbed)
	if(ambush_hidden)
		ambush_hidden = FALSE
		density = initial(density)
		restore_revealed_name()
	return ..()

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/on_horny_target_set(datum/source, has_target)
	SIGNAL_HANDLER
	if(has_target)
		emerge_from_ground()

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/on_ambush_attacked()
	SIGNAL_HANDLER
	emerge_from_ground()

/// A captive who watches the lair keeps its tentacles up, so the lair looks alive.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/captive_in_view()
	for(var/mob/living/watcher in view(vision_range, src))
		if(watcher == src)
			continue
		if(watcher.GetComponent(/datum/component/kidnap_captivity) || HAS_TRAIT(watcher, TRAIT_DEFEAT_REFUSE_ADVANCES))
			return TRUE
	return FALSE

/// Withdraws into the hole: the hide sprite, the hole's name, no density. It can still be examined and hit.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/hide_in_ground()
	if(ambush_hidden || stat == DEAD || captive_in_view())
		return
	ambush_hidden = TRUE
	density = FALSE
	revealed_name = name
	revealed_desc = desc
	if(hidden_name)
		name = hidden_name
	if(hidden_desc)
		desc = hidden_desc
	if(hide_icon_state)
		icon_state = hide_icon_state

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/emerge_from_ground()
	if(!ambush_hidden || stat == DEAD)
		return
	ambush_hidden = FALSE
	density = initial(density)
	restore_revealed_name()
	icon_state = icon_living
	if(emerge_icon_state)
		flick(emerge_icon_state, src)

/// Puts back the name and description the hidden ones replaced.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/restore_revealed_name()
	if(revealed_name)
		name = revealed_name
	if(revealed_desc)
		desc = revealed_desc
	revealed_name = null
	revealed_desc = null

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/set_colony_core(obj/structure/tentacle_growth/colony_core/core)
	colony_core_ref = core ? WEAKREF(core) : null
	if(core)
		refresh_tentacle_palette()

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/get_colony_core()
	var/obj/structure/tentacle_growth/colony_core/core = colony_core_ref?.resolve()
	if(istype(core) && !QDELETED(core))
		return core
	colony_core_ref = null
	return null

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/is_colony_kidnap_candidate(mob/living/victim, allow_own_reservation = FALSE)
	if(!get_colony_core() || world.time < kidnap_retry_after)
		return FALSE
	if(!istype(victim) || victim == src || victim.buckled)
		return FALSE
	if(world.time < victim.kidnap_protected_until)
		return FALSE
	var/mob/living/reserving_captor = victim.get_kidnap_reserver()
	if(reserving_captor && (!allow_own_reservation || reserving_captor != src))
		return FALSE
	if(!allow_own_reservation && tentacle_prey_is_claimed(src, victim))
		return FALSE
	if(victim.GetComponent(/datum/component/kidnap_captivity))
		return FALSE
	// Any defender claims horny-defeated prey; bound prey needs the usual scene and quiet first.
	return is_defeated_kidnap_prey(victim, require_pack = FALSE) || is_restrained_kidnap_prey(victim)

/// Binds adjacent prey and starts the hand-off that passes it to a nest. Returns the hand-off, or FALSE.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/begin_colony_kidnap(mob/living/victim)
	if(!Adjacent(victim) || (victim.pulledby && victim.pulledby != src) || !is_colony_kidnap_candidate(victim) || kidnap_is_outnumbered(victim))
		return FALSE
	if(tentacle_prey_in_scene_or_tie(victim))
		return FALSE
	var/obj/structure/tentacle_growth/colony_core/core = get_colony_core()
	if(!core.get_available_nest_turf())
		kidnap_retry_after = world.time + KIDNAP_RETRY_COOLDOWN
		return FALSE
	if(!victim.try_reserve_kidnap(src))
		return FALSE

	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(human_victim.get_num_arms(TRUE) > 1 && !human_victim.handcuffed)
			var/obj/item/rope/spider_silk/tentacle_resin/restraints = new
			if(!restraints.apply_cuffs(human_victim))
				qdel(restraints)

	emerge_from_ground()
	if(pulling == victim)
		stop_pulling()
	visible_message(
		span_userdanger("[src] winds around [victim] and lowers [victim.p_them()] to the ground. Small tentacles come up below and start to pass [victim.p_them()] toward the core!"),
		null,
		span_hear("I hear resin stretch and something wet slither over the ground."),
	)
	to_chat(victim, span_userdanger("[src] binds me in resin. Small tentacles come up under me and pass me toward its core!"))
	return new /datum/tentacle_handoff(src, victim, core)

/// Nests prey that the hand-off brought to the nest turf. The defender is the captor and may be far away.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/finish_colony_kidnap(mob/living/victim, turf/nest_turf)
	if(!is_colony_kidnap_candidate(victim, allow_own_reservation = TRUE))
		return FALSE
	if(!nest_turf || get_turf(victim) != nest_turf)
		return FALSE

	var/obj/structure/tentacle_growth/nest/nest = locate() in nest_turf
	if(nest?.has_buckled_mobs())
		return FALSE
	if(!nest)
		nest = new(nest_turf)
	if(!nest.buckle_mob(victim, TRUE, check_loc = FALSE))
		victim.clear_kidnap_reservation(src)
		return FALSE
	if(!victim.kidnap_at_physical_anchor(/datum/defeat_captivity_profile/shared/tentacle, src, faction, "tentacle_nest", nest))
		nest.unbuckle_mob(victim, force = TRUE)
		victim.clear_kidnap_reservation(src)
		return FALSE

	victim.clear_kidnap_reservation(src)
	nest.visible_message(
		span_userdanger("The tentacles press [victim] into [nest] and seal [victim.p_them()] beneath fresh resin!"),
		null,
		span_hear("I hear a wet, fibrous cocoon tightening."),
	)
	to_chat(victim, span_userdanger("The tentacles seal me into [nest]. I can struggle free, or hope someone cuts me loose."))
	return TRUE

/// Map path kept for mappers: the same tentacle, always pink-purple.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/alternative
	fixed_palette = TENTACLE_PALETTE_PINK

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium
	name = "burrow tentacle"
	desc = "A searching tentacle that can vanish almost completely into a narrow burrow."
	icon_state = "tentacle_medium"
	icon_living = "tentacle_medium"
	icon_dead = "tentacle_medium_dead"
	health = 55
	maxHealth = 55
	base_constitution = 6
	base_strength = 6
	base_speed = 11
	melee_damage_lower = 6
	melee_damage_upper = 11
	vision_range = 6
	aggro_vision_range = 6
	leash_distance = 6
	hide_icon_state = "tentacle_medium_hide_on"
	emerge_icon_state = "tentacle_medium_hide_off"

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium/alternative
	fixed_palette = TENTACLE_PALETTE_PINK

/// Colony defenders take the colour of the growth mat they sprout from.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium/alternative/colony
	ai_controller = /datum/ai_controller/tentacle_colony_defender
	kidnap_lair_tag = null
	kidnap_captivity_profile = null
	fixed_palette = null

/// Green stomach vines use the burrow-tentacle movement and combat model, but belong to the
/// maneater preference family and produce seedlings rather than more tentacles.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater
	name = "maneater stomach vine"
	desc = "A slick green feeding vine rooted in the yielding walls of a maneater's stomach."
	icon_state = "vine_medium"
	icon_living = "vine_medium"
	icon_dead = "vine_medium_dead"
	ai_controller = /datum/ai_controller/tentacle_ambusher/maneater
	faction = list("maneater")
	kidnap_lair_tag = null
	kidnap_captivity_profile = null
	fixed_palette = TENTACLE_PALETTE_VINE
	rooted = FALSE
	hidden_name = "coiled vine"
	hidden_desc = "A green vine lies coiled flat against the stomach floor. Its tip twitches now and then."
	health = 55
	maxHealth = 55
	base_constitution = 6
	base_strength = 6
	base_speed = 11
	melee_damage_lower = 6
	melee_damage_upper = 11
	vision_range = 8
	aggro_vision_range = 8
	leash_distance = 8
	hide_icon_state = "vine_medium_hide_on"
	emerge_icon_state = "vine_medium_hide_off"

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/Initialize(mapload)
	. = ..()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = ensure_maneater_ovipositor(src)
	if(ovipositor)
		ovipositor.name = "seed-bearing vine"
		ovipositor.desc = "A prehensile plant tendril adapted to implant soft, root-filled eggs."

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/small
	name = "lesser maneater stomach vine"
	desc = "A thin green tendril searching the stomach floor for something warm to coil around."
	icon_state = "vine_small"
	icon_living = "vine_small"
	icon_dead = "vine_small_dead"
	hide_icon_state = "vine_small_hide_on"
	emerge_icon_state = "vine_small_hide_off"
	health = 35
	maxHealth = 35
	base_constitution = 4
	base_strength = 4
	base_speed = 12
	melee_damage_lower = 3
	melee_damage_upper = 7
	leash_distance = 7

/// Rooted in the stomach floor; it barely leaves its pit and regrows there after each swallow.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/big
	name = "greater maneater stomach vine"
	desc = "A thick, thorny feeding vine rooted deep in the stomach floor. Its closed red bud twitches toward anything warm."
	icon = 'modular_rmh/icons/mob/monster/maneater_big_vine.dmi'
	icon_state = "vine_big"
	icon_living = "vine_big"
	icon_dead = "vine_big_dead"
	uses_palette = FALSE
	health = 80
	maxHealth = 80
	base_constitution = 7
	base_strength = 8
	base_speed = 10
	melee_damage_lower = 8
	melee_damage_upper = 14
	leash_distance = 1
	hide_icon_state = "vine_big_hide_on"
	emerge_icon_state = "vine_big_hide_off"

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small
	name = "lesser burrow tentacle"
	desc = "A slim, furtive tentacle. Where one waits, several more are usually close by."
	icon_state = "tentacle_small"
	icon_living = "tentacle_small"
	icon_dead = "tentacle_small_dead"
	health = 35
	maxHealth = 35
	base_constitution = 4
	base_strength = 4
	base_speed = 12
	melee_damage_lower = 3
	melee_damage_upper = 7
	vision_range = 5
	aggro_vision_range = 5
	leash_distance = 5
	hide_icon_state = "tentacle_small_hide_on"
	emerge_icon_state = "tentacle_small_hide_off"

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small/alternative
	fixed_palette = TENTACLE_PALETTE_PINK

/// Colony-created defenders pass defeated prey to their core's nests. They deliberately do
/// not inherit the roaming tentacle's mapped-lair teleport behavior.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small/alternative/colony
	ai_controller = /datum/ai_controller/tentacle_colony_defender
	kidnap_lair_tag = null
	kidnap_captivity_profile = null
	fixed_palette = null

/obj/effect/spawner/tentacle_pack
	name = "mixed tentacle pack spawner"
	icon = 'modular_rmh/icons/mob/monster/tentacles_grey.dmi'
	icon_state = "tentacle_medium"
	/// Minimum number of individual tentacles produced by this mapper helper.
	var/minimum_tentacles = 2
	/// Maximum number of individual tentacles produced by this mapper helper.
	var/maximum_tentacles = 4
	/// Radius used to cluster the pack around the mapped spawner.
	var/spawn_radius = 2
	/// Weighted mob paths available to this pack.
	var/list/tentacle_types = list(
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher = 1,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium = 4,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small = 5,
	)

/obj/effect/spawner/tentacle_pack/Initialize(mapload)
	var/list/valid_turfs = list()
	for(var/turf/open/candidate_turf as anything in RANGE_TURFS(spawn_radius, src))
		if(candidate_turf.is_blocked_turf())
			continue
		valid_turfs += candidate_turf
	if(!length(valid_turfs))
		return ..()

	var/spawn_count = min(rand(minimum_tentacles, maximum_tentacles), length(valid_turfs))
	for(var/index in 1 to spawn_count)
		var/turf/spawn_turf = pick_n_take(valid_turfs)
		var/mob_type = pickweight(tentacle_types)
		new mob_type(spawn_turf)

	return ..()

/obj/effect/spawner/tentacle_pack/large
	name = "large tentacle pack spawner"
	minimum_tentacles = 2
	maximum_tentacles = 3
	tentacle_types = list(
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher = 2,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium = 3,
	)

/obj/effect/spawner/tentacle_pack/small
	name = "small tentacle pack spawner"
	icon_state = "tentacle_small"
	minimum_tentacles = 3
	maximum_tentacles = 5
	tentacle_types = list(
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium = 1,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small = 6,
	)

/obj/effect/spawner/tentacle_pack/alternative
	name = "alternative mixed tentacle pack spawner"
	tentacle_types = list(
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/alternative = 1,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium/alternative = 4,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small/alternative = 5,
	)

/obj/effect/spawner/tentacle_pack/alternative/large
	name = "alternative large tentacle pack spawner"
	minimum_tentacles = 2
	maximum_tentacles = 3
	tentacle_types = list(
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/alternative = 2,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium/alternative = 3,
	)

/obj/effect/spawner/tentacle_pack/alternative/small
	name = "alternative small tentacle pack spawner"
	icon_state = "tentacle_small"
	minimum_tentacles = 3
	maximum_tentacles = 5
	tentacle_types = list(
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium/alternative = 1,
		/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small/alternative = 6,
	)

#undef BB_TENTACLE_AMBUSH_HOME
#undef BB_TENTACLE_AMBUSH_LEASH
#undef BB_TENTACLE_COLONY_KIDNAP_TARGET
