/datum/round_event_control/mothbug_infestation
	name = "Mothbug Infestation"
	tags = list(
		TAG_VILLAIN,
		TAG_UNEXPECTED,
	)
	typepath = /datum/round_event/mothbug_infestation
	track = EVENT_TRACK_CHARACTER_INJECTION
	// Zero weight: the storyteller never rolls it; admins force it from the event panel.
	weight = 0
	max_occurrences = 1
	earliest_start = 45 MINUTES
	min_players = 15

/datum/round_event/mothbug_infestation
	announceChance = 0
	fakeable = FALSE

/datum/round_event/mothbug_infestation/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_colony))

/datum/round_event/mothbug_infestation/proc/spawn_colony()
	var/turf/nest = find_mothbug_spawn_turf()
	if(!nest)
		message_admins("Mothbug Infestation found no dark, quiet indoor town turf to start in.")
		return
	var/list/candidates = pollGhostCandidates("A colony of mothbugs stirs in the town's dark corners. Play as a mothbug? You eat fabric, spin silk and hide; you cannot hurt anyone.", ROLE_MOTHBUG, null, FALSE, 30 SECONDS, POLL_IGNORE_MOTHBUG)
	var/spawned = 0
	for(var/mob/candidate as anything in shuffle(candidates))
		if(spawned >= MOTHBUG_EVENT_SPAWNS)
			break
		if(!candidate.client || is_total_antag_banned(candidate.ckey) || is_antag_banned(candidate.ckey, ROLE_MOTHBUG))
			continue
		if(spawn_mothbug_for(candidate, nest))
			spawned++
	if(!spawned)
		message_admins("Mothbug Infestation: nobody answered the poll.")
		return
	message_admins("Mothbug Infestation: [spawned] mothbug\s spawned at [ADMIN_VERBOSEJMP(nest)].")
	log_game("Mothbug Infestation spawned [spawned] mothbug\s at [AREACOORD(nest)].")

/datum/round_event/mothbug_infestation/proc/spawn_mothbug_for(mob/candidate, turf/nest)
	var/player_ckey = candidate.ckey
	if(!player_ckey)
		return FALSE
	var/mob/living/simple_animal/mothbug/moth = new(nest)
	candidate.leave_lobby_for_role()
	moth.PossessByPlayer(player_ckey)
	moth.sync_mind()
	if(!moth.client || !moth.mind)
		qdel(moth)
		return FALSE
	moth.ensure_mothbug_antag()
	moth.update_silk_display()
	return TRUE

/// A dark indoor town turf no player can see, preferring stores, taverns and cellars.
/proc/find_mothbug_spawn_turf()
	var/static/list/preferred_areas = typecacheof(list(
		/area/indoors/town/warehouse,
		/area/indoors/town/tavern,
		/area/indoors/town/keep/kitchen/cellar,
	))
	var/list/preferred = list()
	var/list/fallback = list()
	for(var/area/indoors/town/town_area in GLOB.areas)
		var/list/target_list = is_type_in_typecache(town_area, preferred_areas) ? preferred : fallback
		for(var/turf/open/place as anything in town_area.get_turfs_from_all_zlevels())
			if(place.density || isopenspace(place) || place.is_blocked_turf(TRUE))
				continue
			target_list += place
	for(var/list/pool in list(preferred, fallback))
		for(var/attempt in 1 to 40)
			if(!length(pool))
				break
			var/turf/open/place = pick_n_take(pool)
			if(place.get_lumcount() >= MOTHBUG_SPAWN_MAX_LIGHT || is_mothbug_spawn_watched(place))
				continue
			return place
	return null

/proc/is_mothbug_spawn_watched(turf/place)
	for(var/mob/living/watcher in range(7, place))
		if(watcher.client && watcher.stat != DEAD)
			return TRUE
	return FALSE
