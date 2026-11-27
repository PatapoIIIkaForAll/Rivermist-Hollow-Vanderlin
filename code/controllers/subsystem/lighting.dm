SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 0

	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER
	priority = FIRE_PRIORITY_DEFAULT
	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/turf_queue = list() // List of turfs queued to pick their lighting look again.
	/// Shared lighting looks: look_cache[z][a][b][c][d], z-indexed list of /alist tries keyed by corner ids.
	var/list/look_cache = list()
	/// Looks whose user count reached zero, oldest first; the prune deletes the ones still unused.
	var/list/idle_looks = list()
	processing_flag = PROCESSING_LIGHTING

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[length(sources_queue)]|C:[length(corners_queue)]|T:[length(turf_queue)]|I:[length(idle_looks)]")


/datum/controller/subsystem/lighting/Initialize(timeofday)
	#ifdef ABSOLUTE_MINIMUM_MODE
	return ..()
	#endif
	if(!initialized)
		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/list/queue = sources_queue
	var/i = 0
	for (i in 1 to length(queue))
		var/datum/light_source/L = queue[i]

		L.update_corners()

		L.needs_update = LIGHTING_NO_UPDATE

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		queue.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = corners_queue
	for (i in 1 to length(queue))
		var/datum/lighting_corner/C = queue[i]

		C.update_objects()
		C.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		queue.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = turf_queue
	for (i in 1 to length(queue))
		var/turf/T = queue[i]

		T.update_lighting_look()
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		queue.Cut(1, i+1)

	if (length(idle_looks) > LIGHTING_LOOK_IDLE_MAX)
		prune_idle_looks(init_tick_checks)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	look_cache = SSlighting.look_cache
	idle_looks = SSlighting.idle_looks
	..()

/datum/controller/subsystem/lighting/proc/create_all_lighting_objects()
	for(var/area/dynamic_area in GLOB.areas)
		if(!IS_DYNAMIC_LIGHTING(dynamic_area))
			continue
		for(var/turf/contained_turf in dynamic_area.get_turfs_from_all_zlevels())
			if(!IS_DYNAMIC_LIGHTING(contained_turf) || IS_FILLER_TURF(contained_turf))
				continue
			contained_turf.set_lighting_look(get_look(contained_turf.z, 0, 0, 0, 0))
			CHECK_TICK

/// Returns a shared look for z-level z and corner ids a, b, c, d, making one if needed.
/// Does not change the look's user count.
/datum/controller/subsystem/lighting/proc/get_look(z, a, b, c, d)
	LISTASSERTLEN(look_cache, z, null)
	var/alist/level_a = look_cache[z]
	if(!level_a)
		level_a = alist()
		look_cache[z] = level_a
	var/alist/level_b = level_a[a]
	if(!level_b)
		level_b = alist()
		level_a[a] = level_b
	var/alist/level_c = level_b[b]
	if(!level_c)
		level_c = alist()
		level_b[b] = level_c
	var/alist/level_d = level_c[c]
	if(!level_d)
		level_d = alist()
		level_c[c] = level_d

	var/atom/movable/lighting_look/look = level_d[d]
	if(look)
		if(look.users < LIGHTING_LOOK_MAX_USERS)
			return look
		look.retired = TRUE

	look = new /atom/movable/lighting_look(null)
	look.look_z = z
	look.look_a = a
	look.look_b = b
	look.look_c = c
	look.look_d = d
	look.layer = LIGHTING_LOOK_LAYER(z)
	if(!a && !b && !c && !d)
		look.icon_state = "lighting_dark"
		look.color = null
		look.luminosity = 0
	else if(a == LIGHTING_LOOK_FULL_ID && b == LIGHTING_LOOK_FULL_ID && c == LIGHTING_LOOK_FULL_ID && d == LIGHTING_LOOK_FULL_ID)
		look.icon_state = "lighting_transparent"
		look.color = null
	else
		look.icon_state = null
		look.color = list(
			(a % 65) / 64, (round(a / 65) % 65) / 64, round(a / 4225) / 64, 0,
			(b % 65) / 64, (round(b / 65) % 65) / 64, round(b / 4225) / 64, 0,
			(c % 65) / 64, (round(c / 65) % 65) / 64, round(c / 4225) / 64, 0,
			(d % 65) / 64, (round(d / 65) % 65) / 64, round(d / 4225) / 64, 0,
			0, 0, 0, 1
		)
	level_d[d] = look
	return look

/// Drops one user from look. An unused retired look is deleted, an unused cached one is marked idle.
/datum/controller/subsystem/lighting/proc/release_look(atom/movable/lighting_look/look)
	look.users--
	if(look.users > 0)
		return
	if(look.retired)
		if(look.idle)
			idle_looks -= look
		qdel(look, TRUE)
		return
	if(!look.idle)
		look.idle = TRUE
		idle_looks += look

/// Deletes idle looks that are still unused, oldest first, until half of LIGHTING_LOOK_IDLE_MAX remain.
/datum/controller/subsystem/lighting/proc/prune_idle_looks(init_tick_checks = FALSE)
	var/list/queue = idle_looks
	var/i = 0
	for (i in 1 to length(queue) - LIGHTING_LOOK_IDLE_MAX / 2)
		var/atom/movable/lighting_look/look = queue[i]
		look.idle = FALSE
		if(look.users > 0 || QDELETED(look))
			if(init_tick_checks)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		var/z = look.look_z
		var/a = look.look_a
		var/b = look.look_b
		var/c = look.look_c
		var/d = look.look_d
		var/alist/level_a = length(look_cache) >= z ? look_cache[z] : null
		var/alist/level_b = level_a?[a]
		var/alist/level_c = level_b?[b]
		var/alist/level_d = level_c?[c]
		if(level_d?[d] == look)
			level_d -= d
			if(!length(level_d))
				level_c -= c
				if(!length(level_c))
					level_b -= b
					if(!length(level_b))
						level_a -= a
						if(!length(level_a))
							look_cache[z] = null
		qdel(look, TRUE)

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		queue.Cut(1, i+1)
