#define TENTACLE_GROWTH_GLOBAL_CAP 600
#define TENTACLE_GROWTH_MOVESPEED_ID "tentacle_growth"
#define TENTACLE_TRIP_COOLDOWN_KEY "tentacle_growth_trip"
#define TENTACLE_TRIP_FACTION "tentacles"
#define TENTACLE_TRIP_CORE_RANGE 15
#define TENTACLE_TRIP_LOCAL_RADIUS 3
#define TENTACLE_TRIP_LOCAL_CAP 3

GLOBAL_VAR_INIT(tentacle_growth_tile_count, 0)
/// Active colony cores, so a tripping floor can find the core that feeds it.
GLOBAL_LIST_EMPTY(tentacle_colony_cores)

/**
 * A passive piece of the colony floor.
 *
 * These tiles never process or spread on their own. Colony cores own the only
 * growth timers, while this type owns the global count and movement slowdown.
 */
/obj/structure/tentacle_growth
	icon = 'modular_rmh/icons/obj/tentacle_growth.dmi'
	anchored = TRUE
	resistance_flags = CAN_BE_HIT

/obj/structure/tentacle_growth/floor
	name = "living tentacle growth"
	desc = "A warm mat of resin and intertwined tendrils clings to the ground."
	icon = 'modular_rmh/icons/obj/tentacle_growth_smooth.dmi'
	icon_state = "growth_a-0"
	pixel_x = -4
	pixel_y = -4
	density = FALSE
	layer = TURF_DECAL_LAYER
	plane = FLOOR_PLANE
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 35
	smoothing_flags = SMOOTH_BITMASK
	smoothing_icon = "growth_a"
	smoothing_groups = SMOOTH_GROUP_TENTACLE_GROWTH
	smoothing_list = SMOOTH_GROUP_TENTACLE_GROWTH
	/// Whether this floor deletes itself outside a mapped tentacle biome.
	var/requires_tentacle_biome = TRUE
	/// Whether this floor contributes to and obeys the shared biome cap.
	var/uses_global_growth_cap = TRUE
	/// Whether initialization completed far enough for movement cleanup to be needed.
	var/initialized_growth = FALSE
	/// Only initialized growth counts against the cap or decrements it on deletion.
	var/counted_toward_global_cap = FALSE
	/// Whether stepping on this floor can trip a carbon and raise a burrow tentacle.
	var/trip_enabled = TRUE
	/// Trip chance in percent for a running mover.
	var/trip_chance_run = 12
	/// Trip chance in percent for a walking mover.
	var/trip_chance_walk = 4
	/// Trip chance in percent for a sneaking mover.
	var/trip_chance_sneak = 0
	/// Knockdown applied by a successful trip.
	var/trip_knockdown = 2 SECONDS
	/// Time after a trip before the same mob can be tripped again.
	var/trip_cooldown = 15 SECONDS
	/// Time after a failed roll before the same mob rolls again.
	var/trip_miss_cooldown = 2 SECONDS

/obj/structure/tentacle_growth/floor/Initialize(mapload)
	smoothing_icon = pick("growth_a", "growth_b")
	icon_state = "[smoothing_icon]-0"
	. = ..()
	var/area/current_area = get_area(src)
	if(requires_tentacle_biome \
		&& !istype(current_area, /area/under/underdark/rmh/tentacle_biome) \
		&& !istype(current_area, /area/under/rmh_bogforest_caves/mindflayer))
		return INITIALIZE_HINT_QDEL

	var/turf/growth_turf = get_turf(src)
	for(var/obj/structure/tentacle_growth/floor/existing_growth in growth_turf)
		if(existing_growth != src && !QDELETED(existing_growth))
			return INITIALIZE_HINT_QDEL

	if(uses_global_growth_cap && GLOB.tentacle_growth_tile_count >= TENTACLE_GROWTH_GLOBAL_CAP)
		return INITIALIZE_HINT_QDEL

	if(uses_global_growth_cap)
		GLOB.tentacle_growth_tile_count++
		counted_toward_global_cap = TRUE
	initialized_growth = TRUE

/obj/structure/tentacle_growth/floor/luminescent
	name = "glimmering tentacle growth"
	desc = "A warm mat of resin and intertwined tendrils gives off a faint violet glow."
	color = "#dcb9ff"
	light_system = MOVABLE_LIGHT
	light_outer_range = 2
	light_power = 0.55
	light_color = "#c77dff"

/obj/structure/tentacle_growth/floor/unrestricted
	requires_tentacle_biome = FALSE
	uses_global_growth_cap = FALSE

/obj/structure/tentacle_growth/floor/luminescent/unrestricted
	requires_tentacle_biome = FALSE
	uses_global_growth_cap = FALSE

/obj/structure/tentacle_growth/floor/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	if(counted_toward_global_cap)
		GLOB.tentacle_growth_tile_count = max(0, GLOB.tentacle_growth_tile_count - 1)
		counted_toward_global_cap = FALSE
	if(initialized_growth && isturf(loc))
		for(var/mob/living/living_mob in loc)
			living_mob.remove_movespeed_modifier(TENTACLE_GROWTH_MOVESPEED_ID)
	initialized_growth = FALSE

	return ..()

/obj/structure/tentacle_growth/floor/Crossed(atom/movable/arrived)
	. = ..()
	if(!isliving(arrived) || istype(arrived, /mob/living/simple_animal/hostile/retaliate/tentacle))
		return

	var/mob/living/living_mob = arrived
	living_mob.add_movespeed_modifier(
		TENTACLE_GROWTH_MOVESPEED_ID,
		multiplicative_slowdown = 0.75,
		movetypes = GROUND,
	)
	if(trip_enabled && iscarbon(living_mob))
		try_trip(living_mob)

/// Rolls a trip for a mover by its move intent. Cheap checks first; lookups only after a hit.
/obj/structure/tentacle_growth/floor/proc/try_trip(mob/living/carbon/victim)
	if(victim.stat == DEAD \
		|| victim.body_position == LYING_DOWN \
		|| victim.buckled \
		|| victim.pulledby \
		|| victim.throwing \
		|| (victim.movement_type & (FLYING | FLOATING | PHASING | VENTCRAWLING)) \
		|| TIMER_COOLDOWN_RUNNING(victim, TENTACLE_TRIP_COOLDOWN_KEY))
		return FALSE

	var/trip_chance
	switch(victim.m_intent)
		if(MOVE_INTENT_RUN)
			trip_chance = trip_chance_run
		if(MOVE_INTENT_SNEAK)
			trip_chance = trip_chance_sneak
		else
			trip_chance = trip_chance_walk
	if(trip_chance <= 0)
		return FALSE
	if(!prob(trip_chance))
		TIMER_COOLDOWN_START(victim, TENTACLE_TRIP_COOLDOWN_KEY, trip_miss_cooldown)
		return FALSE

	if(victim.has_faction(TENTACLE_TRIP_FACTION) \
		|| HAS_TRAIT(victim, TRAIT_LIGHT_STEP) \
		|| victim.get_kidnap_reserver() \
		|| victim.GetComponent(/datum/component/kidnap_captivity))
		return FALSE

	TIMER_COOLDOWN_START(victim, TENTACLE_TRIP_COOLDOWN_KEY, trip_cooldown)
	var/turf/trip_turf = get_turf(src)
	new /obj/effect/temp_visual/tentacle_trip_rise(trip_turf)
	playsound(trip_turf, "plantcross", 60, FALSE, -1)
	victim.visible_message(
		span_warning("A tendril in the growth whips around [victim]'s ankle and pulls [victim.p_them()] down!"),
		span_userdanger("Something in the mat coils around my ankle. I go down!"),
	)
	victim.Knockdown(trip_knockdown)
	raise_trip_burrower(victim)
	return TRUE

/// Brings a burrow tentacle up beside a tripped victim, through the owning core if there is one.
/obj/structure/tentacle_growth/floor/proc/raise_trip_burrower(mob/living/victim)
	var/turf/victim_turf = get_turf(victim)
	if(!victim_turf)
		return null
	var/turf/spawn_turf = find_burrower_turf(victim_turf)
	if(!spawn_turf)
		return null

	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/burrower
	var/obj/structure/tentacle_growth/colony_core/core = find_trip_core(victim_turf)
	if(core)
		burrower = core.try_spawn_trip_defender(spawn_turf)
	else if(count_nearby_burrowers(victim_turf) < TENTACLE_TRIP_LOCAL_CAP)
		burrower = new /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small(spawn_turf)
		burrower.AddComponent(/datum/component/tentacle_trip_wither)
	if(!burrower)
		return null

	burrower.emerge_from_ground()
	burrower.visible_message(span_danger("A tentacle pushes up through the growth beside [victim]!"))
	return burrower

/// Picks a free growth tile next to the victim with no tentacle on it, else the victim's own tile.
/obj/structure/tentacle_growth/floor/proc/find_burrower_turf(turf/victim_turf)
	var/list/candidate_turfs
	for(var/direction in GLOB.alldirs)
		var/turf/candidate_turf = get_step(victim_turf, direction)
		if(!candidate_turf || !(locate(/obj/structure/tentacle_growth/floor) in candidate_turf))
			continue
		if(candidate_turf.is_blocked_turf(TRUE))
			continue
		if(locate(/mob/living) in candidate_turf)
			continue
		LAZYADD(candidate_turfs, candidate_turf)
	if(length(candidate_turfs))
		return pick(candidate_turfs)
	if(locate(/mob/living/simple_animal/hostile/retaliate/tentacle) in victim_turf)
		return null
	return victim_turf

/// Returns the core that knows this turf, else the nearest active core in range on this z-level.
/obj/structure/tentacle_growth/floor/proc/find_trip_core(turf/victim_turf)
	var/obj/structure/tentacle_growth/colony_core/nearest_core
	var/nearest_distance = INFINITY
	for(var/obj/structure/tentacle_growth/colony_core/core as anything in GLOB.tentacle_colony_cores)
		if(QDELETED(core) || core.z != victim_turf.z)
			continue
		var/distance = get_dist(core, victim_turf)
		if(distance > TENTACLE_TRIP_CORE_RANGE)
			continue
		if(victim_turf in core.known_growth_turfs)
			return core
		if(distance < nearest_distance)
			nearest_distance = distance
			nearest_core = core
	return nearest_core

/// Counts living burrow tentacles around a turf, for the coreless spawn cap.
/obj/structure/tentacle_growth/floor/proc/count_nearby_burrowers(turf/center_turf)
	var/burrower_count = 0
	for(var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/burrower in range(TENTACLE_TRIP_LOCAL_RADIUS, center_turf))
		if(burrower.stat != DEAD)
			burrower_count++
	return burrower_count

/obj/structure/tentacle_growth/floor/Uncrossed(atom/movable/departing)
	. = ..()
	if(!isliving(departing))
		return

	var/mob/living/living_mob = departing
	living_mob.remove_movespeed_modifier(TENTACLE_GROWTH_MOVESPEED_ID)

/**
 * An upright knot rooted into a colony floor.
 *
 * This deliberately reuses the independent tentacle's old anchored silhouette.
 * It has no processing; the only gameplay work happens when a player crosses it.
 */
/obj/structure/tentacle_growth/snare
	name = "rooted tentacle snare"
	desc = "A cluster of upright tentacles flexes from a broad, rooted base."
	icon = 'modular_rmh/icons/obj/tentacle_snare.dmi'
	icon_state = "snare"
	density = FALSE
	layer = BELOW_MOB_LAYER
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 60
	/// Minimum time before this particular snare can trip another player.
	var/trip_cooldown = 2 SECONDS
	var/tmp/last_trip_time

/obj/structure/tentacle_growth/snare/Crossed(atom/movable/arrived)
	. = ..()
	if(!isliving(arrived) || istype(arrived, /mob/living/simple_animal/hostile/retaliate/tentacle))
		return

	var/mob/living/living_mob = arrived
	if(!living_mob.client \
		|| living_mob.stat == DEAD \
		|| living_mob.body_position == LYING_DOWN \
		|| living_mob.buckled \
		|| living_mob.throwing \
		|| (living_mob.movement_type & (FLYING | FLOATING)) \
		|| HAS_TRAIT(living_mob, TRAIT_LIGHT_STEP) \
		|| (last_trip_time && last_trip_time + trip_cooldown > world.time))
		return

	last_trip_time = world.time
	living_mob.visible_message(
		span_warning("[living_mob] catches [living_mob.p_their()] foot in [src] and tumbles!"),
		span_userdanger("A slick tentacle coils around your ankle and trips you!"),
	)
	playsound(src, "plantcross", 60, FALSE, -1)
	living_mob.SetKnockdown(2 SECONDS)

/**
 * The sole active spreader for a tentacle colony.
 *
 * It records the exact area instance it was initialized in. Both its source
 * and destination turfs must remain in that same instance, so even another
 * tentacle-biome area across a boundary cannot be reached.
 */
/obj/structure/tentacle_growth/colony_core
	name = "tentacle colony core"
	desc = "A low mound of pulsing flesh feeds a web of resinous tendrils."
	icon_state = "colony_core"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	plane = GAME_PLANE_LOWER
	max_integrity = 250
	/// Minimum time between successful growth attempts.
	var/growth_delay_low = 8 SECONDS
	/// Maximum time between successful growth attempts.
	var/growth_delay_high = 14 SECONDS
	/// Slower retry used while the shared global cap is full.
	var/cap_retry_delay = 30 SECONDS
	/// Maximum number of known colony turfs checked during one growth tick.
	var/source_checks_per_growth = 16
	/// Chance that a newly spread floor tile is softly luminescent.
	var/luminescent_growth_chance = 10
	/// Defender allowance for a newly established colony.
	var/starting_defender_limit = 6
	/// Defender allowance once defender_scaling_tile_count tiles are known.
	var/maximum_defender_limit = 60
	/// Colony size at which the maximum defender allowance is reached.
	var/defender_scaling_tile_count = 300
	/// Snare allowance for a newly established colony.
	var/starting_snare_limit = 1
	/// Snare allowance once snare_scaling_tile_count tiles are known.
	var/maximum_snare_limit = 10
	/// Colony size at which the maximum snare allowance is reached.
	var/snare_scaling_tile_count = 300
	/// Stationary obstacle produced throughout the colony.
	var/snare_type = /obj/structure/tentacle_growth/snare
	/// Common defender produced throughout the colony's lifetime.
	var/lesser_defender_type = /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small/alternative/colony
	/// Rare heavier defender whose chance rises with colony size.
	var/medium_defender_type = /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium/alternative/colony
	/// Medium defender chance for a newly established colony.
	var/starting_medium_defender_chance = 10
	/// Medium defender chance at defender_scaling_tile_count tiles.
	var/maximum_medium_defender_chance = 30
	/// Whether this core must be initialized inside a tentacle biome.
	var/requires_tentacle_biome = TRUE
	/// Whether growth is confined to the exact area instance where the core initialized.
	var/confined_to_initial_area = TRUE
	/// Floor type produced by ordinary growth steps.
	var/growth_floor_type = /obj/structure/tentacle_growth/floor
	/// Floor type produced by a successful luminescent growth roll.
	var/luminescent_growth_floor_type = /obj/structure/tentacle_growth/floor/luminescent
	/// The exact mapped area instance this core is allowed to grow inside.
	var/tmp/area/allowed_growth_area
	/// All floor turfs discovered or produced by this core.
	var/tmp/list/known_growth_turfs
	/// Living defenders produced by this core, used only to enforce its local cap.
	var/tmp/list/tracked_defenders
	/// Rooted snares produced by this core, used only to enforce its local cap.
	var/tmp/list/tracked_snares
	/// Stoppable, parent-owned timer for the next growth attempt.
	var/tmp/growth_timer_id

/obj/structure/tentacle_growth/colony_core/Initialize(mapload)
	. = ..()
	allowed_growth_area = get_area(src)
	if(requires_tentacle_biome \
		&& !istype(allowed_growth_area, /area/under/underdark/rmh/tentacle_biome) \
		&& !istype(allowed_growth_area, /area/under/rmh_bogforest_caves/mindflayer))
		allowed_growth_area = null
		return

	known_growth_turfs = list()
	tracked_defenders = list()
	tracked_snares = list()
	GLOB.tentacle_colony_cores += src
	var/turf/core_turf = get_turf(src)
	if(core_turf)
		known_growth_turfs += core_turf
		if(!(locate(/obj/structure/tentacle_growth/floor) in core_turf))
			new growth_floor_type(core_turf)

	schedule_growth()

/obj/structure/tentacle_growth/colony_core/Destroy()
	GLOB.tentacle_colony_cores -= src
	if(growth_timer_id)
		deltimer(growth_timer_id)
		growth_timer_id = null
	for(var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender as anything in tracked_defenders)
		if(!QDELETED(defender))
			UnregisterSignal(defender, COMSIG_PARENT_QDELETING)
	for(var/obj/structure/tentacle_growth/snare/snare as anything in tracked_snares)
		if(!QDELETED(snare))
			UnregisterSignal(snare, COMSIG_PARENT_QDELETING)
	tracked_defenders = null
	tracked_snares = null
	allowed_growth_area = null
	known_growth_turfs = null
	return ..()

/obj/structure/tentacle_growth/colony_core/proc/on_defender_qdeleting(datum/source)
	SIGNAL_HANDLER
	tracked_defenders -= source

/obj/structure/tentacle_growth/colony_core/proc/on_snare_qdeleting(datum/source)
	SIGNAL_HANDLER
	tracked_snares -= source

/obj/structure/tentacle_growth/colony_core/proc/get_colony_size()
	var/colony_size = 0
	var/turf/core_turf = get_turf(src)
	for(var/turf/growth_turf as anything in known_growth_turfs.Copy())
		if(confined_to_initial_area && get_area(growth_turf) != allowed_growth_area)
			known_growth_turfs -= growth_turf
			continue
		if(!(locate(/obj/structure/tentacle_growth/floor) in growth_turf))
			if(growth_turf != core_turf)
				known_growth_turfs -= growth_turf
			continue
		colony_size++
	return colony_size

/obj/structure/tentacle_growth/colony_core/proc/get_defender_limit(colony_size)
	if(colony_size <= 0)
		return 0
	if(defender_scaling_tile_count <= 1)
		return maximum_defender_limit

	var/scaled_tile_count = clamp(colony_size, 1, defender_scaling_tile_count)
	var/scaling_progress = (scaled_tile_count - 1) / (defender_scaling_tile_count - 1)
	return round(starting_defender_limit + ((maximum_defender_limit - starting_defender_limit) * scaling_progress))

/obj/structure/tentacle_growth/colony_core/proc/get_medium_defender_chance(colony_size)
	if(colony_size <= 1)
		return clamp(starting_medium_defender_chance, 0, 100)
	if(defender_scaling_tile_count <= 1)
		return clamp(maximum_medium_defender_chance, 0, 100)

	var/scaled_tile_count = clamp(colony_size, 1, defender_scaling_tile_count)
	var/scaling_progress = (scaled_tile_count - 1) / (defender_scaling_tile_count - 1)
	var/medium_chance = starting_medium_defender_chance + ((maximum_medium_defender_chance - starting_medium_defender_chance) * scaling_progress)
	return clamp(medium_chance, 0, 100)

/obj/structure/tentacle_growth/colony_core/proc/get_snare_limit(colony_size)
	if(colony_size <= 0)
		return 0
	if(snare_scaling_tile_count <= 1)
		return maximum_snare_limit

	var/scaled_tile_count = clamp(colony_size, 1, snare_scaling_tile_count)
	var/scaling_progress = (scaled_tile_count - 1) / (snare_scaling_tile_count - 1)
	return round(starting_snare_limit + ((maximum_snare_limit - starting_snare_limit) * scaling_progress))

/// Finds an empty existing nest first, then an open growth tile close enough for defenders to guard.
/obj/structure/tentacle_growth/colony_core/proc/get_available_nest_turf()
	for(var/obj/structure/tentacle_growth/nest/existing_nest in range(2, src))
		if(!existing_nest.has_buckled_mobs())
			return get_turf(existing_nest)

	var/list/possible_turfs = list()
	for(var/turf/open/candidate_turf as anything in RANGE_TURFS(2, src))
		if(candidate_turf == get_turf(src))
			continue
		if(!(locate(/obj/structure/tentacle_growth/floor) in candidate_turf))
			continue
		if(candidate_turf.is_blocked_turf(TRUE, src))
			continue
		if(locate(/obj/structure/tentacle_growth/nest) in candidate_turf)
			continue
		possible_turfs += candidate_turf
	return length(possible_turfs) ? pick(possible_turfs) : null

/obj/structure/tentacle_growth/colony_core/proc/has_reached_growth_limit(colony_size)
	return GLOB.tentacle_growth_tile_count >= TENTACLE_GROWTH_GLOBAL_CAP

/obj/structure/tentacle_growth/colony_core/proc/prune_defenders()
	for(var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/defender as anything in tracked_defenders.Copy())
		if(QDELETED(defender))
			tracked_defenders -= defender
			continue
		if(defender.stat != DEAD)
			continue
		UnregisterSignal(defender, COMSIG_PARENT_QDELETING)
		tracked_defenders -= defender

/obj/structure/tentacle_growth/colony_core/proc/prune_snares()
	for(var/obj/structure/tentacle_growth/snare/snare as anything in tracked_snares.Copy())
		if(!QDELETED(snare))
			continue
		tracked_snares -= snare

/obj/structure/tentacle_growth/colony_core/proc/try_spawn_defender(turf/preferred_turf, colony_size)
	prune_defenders()
	if(length(tracked_defenders) >= get_defender_limit(colony_size))
		return FALSE

	var/turf/defender_turf
	if(preferred_turf \
		&& (locate(/obj/structure/tentacle_growth/floor) in preferred_turf) \
		&& !preferred_turf.is_blocked_turf() \
		&& !(locate(/mob/living/simple_animal/hostile/retaliate/tentacle) in preferred_turf))
		defender_turf = preferred_turf

	var/checks_remaining = min(source_checks_per_growth, length(known_growth_turfs))
	while(!defender_turf && checks_remaining-- > 0)
		var/turf/candidate_turf = pick(known_growth_turfs)
		if(!(locate(/obj/structure/tentacle_growth/floor) in candidate_turf))
			continue
		if(candidate_turf.is_blocked_turf())
			continue
		if(locate(/mob/living/simple_animal/hostile/retaliate/tentacle) in candidate_turf)
			continue
		defender_turf = candidate_turf

	if(!defender_turf)
		return FALSE
	return !!spawn_tracked_defender(defender_turf, colony_size)

/// Creates one tracked defender on the turf. Returns the defender, or null.
/obj/structure/tentacle_growth/colony_core/proc/spawn_tracked_defender(turf/defender_turf, colony_size)
	var/defender_type = prob(get_medium_defender_chance(colony_size)) \
		? medium_defender_type \
		: lesser_defender_type
	if(!defender_type)
		return null

	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/new_defender = new defender_type(defender_turf)
	new_defender.set_colony_core(src)
	tracked_defenders += new_defender
	RegisterSignal(new_defender, COMSIG_PARENT_QDELETING, PROC_REF(on_defender_qdeleting))
	return new_defender

/// Raises a defender on a turf the floor already chose for a tripped victim, under the defender cap.
/obj/structure/tentacle_growth/colony_core/proc/try_spawn_trip_defender(turf/spawn_turf)
	if(!allowed_growth_area || !spawn_turf)
		return null
	var/colony_size = get_colony_size()
	prune_defenders()
	if(length(tracked_defenders) >= get_defender_limit(colony_size))
		return null
	return spawn_tracked_defender(spawn_turf, colony_size)

/obj/structure/tentacle_growth/colony_core/proc/try_spawn_snare(turf/preferred_turf, colony_size)
	prune_snares()
	if(length(tracked_snares) >= get_snare_limit(colony_size))
		return FALSE

	var/turf/snare_turf
	if(preferred_turf \
		&& (locate(/obj/structure/tentacle_growth/floor) in preferred_turf) \
		&& !preferred_turf.is_blocked_turf(TRUE) \
		&& !(locate(/mob/living) in preferred_turf) \
		&& !(locate(/obj/structure/tentacle_growth/snare) in preferred_turf))
		snare_turf = preferred_turf

	var/checks_remaining = min(source_checks_per_growth, length(known_growth_turfs))
	while(!snare_turf && checks_remaining-- > 0)
		var/turf/candidate_turf = pick(known_growth_turfs)
		if(!(locate(/obj/structure/tentacle_growth/floor) in candidate_turf))
			continue
		if(candidate_turf.is_blocked_turf(TRUE))
			continue
		if(locate(/mob/living) in candidate_turf)
			continue
		if(locate(/obj/structure/tentacle_growth/snare) in candidate_turf)
			continue
		snare_turf = candidate_turf

	if(!snare_turf)
		return FALSE

	var/obj/structure/tentacle_growth/snare/new_snare = new snare_type(snare_turf)
	tracked_snares += new_snare
	RegisterSignal(new_snare, COMSIG_PARENT_QDELETING, PROC_REF(on_snare_qdeleting))
	return TRUE

/obj/structure/tentacle_growth/colony_core/proc/schedule_growth(delay)
	if(!allowed_growth_area || QDELETED(src))
		return
	if(growth_timer_id)
		deltimer(growth_timer_id)

	if(isnull(delay))
		delay = rand(growth_delay_low, growth_delay_high)
	growth_timer_id = addtimer(CALLBACK(src, PROC_REF(try_spread)), delay, TIMER_STOPPABLE | TIMER_DELETE_ME)

/obj/structure/tentacle_growth/colony_core/proc/try_spread()
	growth_timer_id = null
	if(!allowed_growth_area || QDELETED(src))
		return
	if(confined_to_initial_area && get_area(src) != allowed_growth_area)
		return

	var/colony_size = get_colony_size()
	if(has_reached_growth_limit(colony_size))
		try_spawn_defender(null, colony_size)
		try_spawn_snare(null, colony_size)
		schedule_growth(cap_retry_delay)
		return

	var/turf/new_growth_turf
	var/checks_remaining = min(source_checks_per_growth, length(known_growth_turfs))
	while(checks_remaining-- > 0 && length(known_growth_turfs))
		var/turf/source_turf = pick(known_growth_turfs)
		if(confined_to_initial_area && get_area(source_turf) != allowed_growth_area)
			known_growth_turfs -= source_turf
			continue

		var/turf/core_turf = get_turf(src)
		if(source_turf != core_turf && !(locate(/obj/structure/tentacle_growth/floor) in source_turf))
			known_growth_turfs -= source_turf
			continue

		var/list/possible_destinations = list()
		for(var/direction in GLOB.cardinals)
			var/turf/candidate_turf = get_step(source_turf, direction)
			if(!candidate_turf)
				continue
			if(confined_to_initial_area && get_area(candidate_turf) != allowed_growth_area)
				continue

			if(locate(/obj/structure/tentacle_growth/floor) in candidate_turf)
				if(!(candidate_turf in known_growth_turfs))
					known_growth_turfs += candidate_turf
				continue

			if(!isopenturf(candidate_turf) || isgroundlessturf(candidate_turf))
				continue
			if(candidate_turf.is_blocked_turf(TRUE, src))
				continue
			possible_destinations += candidate_turf

		if(!length(possible_destinations))
			continue

		var/turf/growth_turf = pick(possible_destinations)
		var/growth_type = prob(luminescent_growth_chance) \
			? luminescent_growth_floor_type \
			: growth_floor_type
		new growth_type(growth_turf)
		if(!(growth_turf in known_growth_turfs))
			known_growth_turfs += growth_turf
		colony_size++
		new_growth_turf = growth_turf
		break

	try_spawn_defender(new_growth_turf, colony_size)
	try_spawn_snare(new_growth_turf, colony_size)
	schedule_growth()

/**
 * Admin event core. It crosses area boundaries and uses its own VV-editable
 * tile limit instead of the shared biome cap. A limit of zero disables its cap.
 */
/obj/structure/tentacle_growth/colony_core/unlimited
	name = "unrestricted tentacle colony core"
	desc = "An unnaturally vigorous colony core intended for administrator-run events."
	color = "#e6c2ff"
	requires_tentacle_biome = FALSE
	confined_to_initial_area = FALSE
	growth_floor_type = /obj/structure/tentacle_growth/floor/unrestricted
	luminescent_growth_floor_type = /obj/structure/tentacle_growth/floor/luminescent/unrestricted
	/// VV-editable local tile cap. Zero allows unlimited growth.
	var/local_growth_limit = 1000

/obj/structure/tentacle_growth/colony_core/unlimited/has_reached_growth_limit(colony_size)
	return local_growth_limit > 0 && colony_size >= local_growth_limit

/obj/structure/tentacle_growth/colony_core/unlimited/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, local_growth_limit))
		if(!isnum(var_value))
			return FALSE
		var_value = max(0, round(var_value))
	return ..()

/// Small tentacles that come up and sink again where the growth trips someone.
/obj/effect/temp_visual/tentacle_trip_rise
	name = "small tentacles"
	icon = 'modular_rmh/icons/mob/monster/tentacles_grey.dmi'
	icon_state = "tentacle_group_rise"
	layer = BELOW_MOB_LAYER
	randomdir = FALSE
	duration = 1.1 SECONDS

/obj/effect/temp_visual/tentacle_trip_rise/Initialize(mapload)
	. = ..()
	apply_tentacle_palette(tentacle_palette_for_turf(get_turf(src)))

/// Deletes a coreless trip tentacle once it has stayed hidden without a target for wither_delay.
/datum/component/tentacle_trip_wither
	/// How long the tentacle must stay hidden and idle before it sinks away.
	var/wither_delay = 3 MINUTES
	/// Time between idle checks.
	var/check_interval = 30 SECONDS
	/// When the current idle stretch began, or null while the tentacle is active.
	var/idle_since
	/// Looping check timer.
	var/check_timer_id

/datum/component/tentacle_trip_wither/Initialize()
	if(!istype(parent, /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher))
		return COMPONENT_INCOMPATIBLE
	check_timer_id = addtimer(CALLBACK(src, PROC_REF(check_wither)), check_interval, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)

/datum/component/tentacle_trip_wither/Destroy(force)
	if(check_timer_id)
		deltimer(check_timer_id)
		check_timer_id = null
	return ..()

/// Whether the tentacle is hidden, holds nobody and has no target.
/datum/component/tentacle_trip_wither/proc/is_idle(mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle)
	if(!tentacle.ambush_hidden || tentacle.pulling)
		return FALSE
	var/datum/ai_controller/controller = tentacle.ai_controller
	if(controller && (controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] || controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]))
		return FALSE
	return TRUE

/// Sinks and deletes the tentacle after a long enough idle stretch. Returns TRUE when it withered.
/datum/component/tentacle_trip_wither/proc/check_wither()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = parent
	if(QDELETED(tentacle))
		return FALSE
	if(tentacle.stat == DEAD)
		qdel(src)
		return FALSE
	if(!is_idle(tentacle))
		idle_since = null
		return FALSE
	if(isnull(idle_since))
		idle_since = world.time
		return FALSE
	if(world.time - idle_since < wither_delay)
		return FALSE
	tentacle.visible_message(span_notice("The burrow closes and the growth knits shut over it."))
	qdel(tentacle)
	return TRUE

#undef TENTACLE_GROWTH_GLOBAL_CAP
#undef TENTACLE_GROWTH_MOVESPEED_ID
#undef TENTACLE_TRIP_COOLDOWN_KEY
#undef TENTACLE_TRIP_FACTION
#undef TENTACLE_TRIP_CORE_RANGE
#undef TENTACLE_TRIP_LOCAL_RADIUS
#undef TENTACLE_TRIP_LOCAL_CAP
