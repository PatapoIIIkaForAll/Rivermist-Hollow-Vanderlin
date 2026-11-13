/// Generation is confined to this dungeon subtype; other pockets retain DMM loading.
/datum/pocket_dimension/dungeon/procedural
	var/procedural_seed = 0
	var/datum/dungeon_room_plan/procedural_plan
	var/spawn_random_state = 1

/datum/pocket_dimension/dungeon/procedural/Destroy(force)
	QDEL_NULL(procedural_plan)
	return ..()

/datum/pocket_dimension/dungeon/procedural/set_generation_seed(room_seed)
	procedural_seed = clamp(round(room_seed), 0, 65535)

/datum/pocket_dimension/dungeon/procedural/load_layout()
	var/datum/map_template/pocket/dungeon/dungeon_template = get_dungeon_template()
	if(!dungeon_template?.procedural_recipe)
		return FALSE
	if(!procedural_seed)
		procedural_seed = rand(1, 65535)
	QDEL_NULL(procedural_plan)
	// Invalid plans are discarded before any world atoms are created.
	for(var/attempt in 1 to 3)
		var/attempt_seed = ((procedural_seed + attempt - 2) % 65535) + 1
		var/datum/dungeon_room_plan/candidate = new(attempt_seed, dungeon_template.procedural_recipe)
		if(candidate.build() && candidate.validate())
			procedural_plan = candidate
			break
		qdel(candidate)
	if(!procedural_plan)
		return FALSE
	var/origin_x = load_turf.x
	var/origin_y = load_turf.y
	var/origin_z = load_turf.z
	if(!..())
		return FALSE
	if(QDELETED(src) || !reservation || QDELETED(procedural_plan))
		return FALSE
	// Loading and ChangeTurf replace turf datums; retain coordinates, not stale turfs.
	var/turf/origin = locate(origin_x, origin_y, origin_z)
	if(!procedural_plan.materialize(origin))
		return FALSE
	spawn_random_state = procedural_plan.seed
	log_game("Generated dungeon [dungeon_template.id], seed [procedural_plan.seed], instance [instance_key].")
	return TRUE

/datum/pocket_dimension/dungeon/procedural/get_guardian_spawn_turfs()
	var/list/turf/available = list()
	if(!procedural_plan || !load_turf)
		return available
	for(var/slot in procedural_plan.guardian_slots)
		var/turf/spot = procedural_plan.get_turf_for_index(load_turf, slot)
		if(!contains_turf(spot) || !is_valid_drop_turf(spot, null))
			continue
		var/occupied = FALSE
		for(var/mob/living/occupant in spot)
			if(occupant.stat != DEAD)
				occupied = TRUE
				break
		if(!occupied)
			available += spot
	return available

/datum/pocket_dimension/dungeon/procedural/pick_guardian_spawn_turf(list/turf/available)
	// Small integer arithmetic stays exact in DM; independent from global rand().
	spawn_random_state = (spawn_random_state * 109 + 1021) % 65536
	return available[(spawn_random_state % length(available)) + 1]

/datum/map_template/pocket/dungeon/swampgob/procedural/get_fallback_template()
	var/list/pool = get_dungeon_template_pool(room_kind, theme, max(1, difficulty_tier - 1), difficulty_tier + 1)
	for(var/datum/map_template/pocket/dungeon/candidate as anything in pool.Copy())
		if(candidate.procedural_recipe)
			pool -= candidate
	return length(pool) ? pickweight(pool) : null
