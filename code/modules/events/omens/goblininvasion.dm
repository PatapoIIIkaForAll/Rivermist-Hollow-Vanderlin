/datum/round_event_control/gobinvade
	name = "Gob Invasion"
	track = EVENT_TRACK_OMENS
	typepath = /datum/round_event/gobinvade
	weight = 10
	max_occurrences = 2
	min_players = 0
	req_omen = TRUE
	earliest_start = 35 MINUTES
	todreq = list("night", "dawn", "day", "dusk")

	tags = list(
		TAG_RAID,
		TAG_BATTLE,
	)

/datum/round_event/gobinvade
	announceWhen	= 50
	var/spawncount = 5
	var/list/starts

/datum/round_event_control/gobinvade/canSpawnEvent(players_amt, gamemode, fake_check)
	if(!length(get_invasion_spawn_turfs()))
		return FALSE
	. = ..()

/datum/round_event/gobinvade/start()
	var/list/spawn_turfs = get_invasion_spawn_turfs()
	for(var/i in 1 to spawncount)
		if(!length(spawn_turfs))
			break
		var/turf/spawn_turf = pick_n_take(spawn_turfs)
		if(locate(/obj/structure/gob_portal) in spawn_turf)
			continue
		new /obj/structure/gob_portal(spawn_turf)

/// Omen raid spawn turfs: mapped haunt markers, else quest markers for maps that have no haunts.
/proc/get_invasion_spawn_turfs()
	var/list/spawn_turfs = list()
	for(var/obj/effect/landmark/events/haunts/haunt as anything in GLOB.hauntstart)
		var/turf/haunt_turf = get_turf(haunt)
		if(isfloorturf(haunt_turf))
			spawn_turfs |= haunt_turf
	if(length(spawn_turfs))
		return spawn_turfs
	for(var/obj/effect/landmark/quest_spawner/marker as anything in GLOB.quest_landmarks_list)
		var/turf/marker_turf = get_turf(marker)
		if(isfloorturf(marker_turf) && !marker_turf.is_blocked_turf(TRUE))
			spawn_turfs |= marker_turf
	return spawn_turfs
