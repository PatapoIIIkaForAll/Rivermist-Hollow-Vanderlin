/mob/living/simple_animal/enterprise_patron
	name = "traveller"
	desc = "A traveller after a meal and a bed."
	maxHealth = 100
	health = 100
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_TOWN)
	wander = FALSE
	cmode = FALSE
	ai_controller = /datum/ai_controller/enterprise_patron
	var/datum/enterprise/enterprise
	var/datum/enterprise_room/lodging
	var/datum/enterprise_seating/table_set
	var/datum/weakref/seat
	var/obj/item/key/room_key
	var/datum/weakref/key_vendor
	var/list/key_entry
	var/turf/origin
	var/leaves_at = 0
	var/list/requests = list()
	var/list/goals = list(
		ENTERPRISE_PATRON_GOAL_BAR,
		ENTERPRISE_PATRON_GOAL_ORDER,
		ENTERPRISE_PATRON_GOAL_ROOM,
	)
	var/goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
	var/stay_until = 0
	var/walk_until = 0
	var/leaving = FALSE
	var/displeasure = 0
	var/max_displeasure = 3
	var/bar_time = 45 SECONDS
	var/table_time = 2 MINUTES
	var/walk_time = 3 MINUTES
	var/list/remarks = list()
	var/static/list/lines = list(
		ENTERPRISE_PATRON_LINE_ORDER = list(
			"A mug of your best, keeper.",
			"Something to wet the throat, if you please.",
			"What is on the tap today?",
		),
		ENTERPRISE_PATRON_LINE_NO_BAR = list(
			"No bar to stand at? What kind of house is this?",
			"Where does one get a drink here?",
		),
		ENTERPRISE_PATRON_LINE_NO_TABLE = list(
			"Not a single free table. Shameful.",
			"Nowhere to sit? I will remember this.",
		),
		ENTERPRISE_PATRON_LINE_NO_ROOM = list(
			"No rooms left? I walked all day for this.",
			"Full up, are you? Bah.",
		),
		ENTERPRISE_PATRON_LINE_LOST = list(
			"I cannot even get there. What a maze.",
			"The way is shut. Wonderful.",
		),
		ENTERPRISE_PATRON_LINE_OFFENDED = list(
			"That is MY table! I am not staying here another moment.",
			"Eat at your own table! I am leaving.",
		),
		ENTERPRISE_PATRON_LINE_FED_UP = list(
			"I have had enough of this place.",
			"Never again. Good day.",
		),
		ENTERPRISE_PATRON_LINE_FAREWELL = list(
			"My thanks, keeper. Until next time.",
			"A fine house. Farewell.",
		),
	)

/mob/living/simple_animal/enterprise_patron/Initialize(mapload)
	. = ..()
	dress()

/mob/living/simple_animal/enterprise_patron/Destroy()
	vacate()
	seat = null
	origin = null
	forget_enterprise()
	return ..()

/mob/living/simple_animal/enterprise_patron/death(gibbed)
	leave_seat()
	vacate()
	forget_enterprise()
	. = ..()
	if(!QDELETED(src))
		transform = transform.Turn(90)

/mob/living/simple_animal/enterprise_patron/Moved(atom/old_loc, movement_dir, forced)
	. = ..()
	var/turf/here = loc
	if(!isturf(here))
		return
	open_door(locate(/obj/structure/door) in here)
	var/turf/ahead = movement_dir ? get_step(here, movement_dir) : null
	if(ahead)
		open_door(locate(/obj/structure/door) in ahead)

/mob/living/simple_animal/enterprise_patron/proc/open_door(obj/structure/door/door)
	if(QDELETED(door) || door.door_opened || door.switching_states || !door.anchored || (door.locked() && !has_key_for(door)))
		return FALSE
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/structure/door, SwitchState), FALSE, src)
	door.bump_close_later(src)
	return TRUE

/obj/structure/door/CanAStarPass(ID, to_dir, datum/requester)
	. = ..()
	if(!. && istype(requester, /mob/living/simple_animal/enterprise_patron) && anchored)
		var/mob/living/simple_animal/enterprise_patron/patron = requester
		if(!locked() || patron.has_key_for(src))
			return TRUE

/obj/structure/door/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!. && istype(mover, /mob/living/simple_animal/enterprise_patron) && anchored)
		var/mob/living/simple_animal/enterprise_patron/patron = mover
		if(!locked() || patron.has_key_for(src))
			return TRUE

/mob/living/simple_animal/enterprise_patron/proc/has_key_for(obj/structure/door/door)
	var/datum/lock/key/key_lock = door?.lock
	return istype(key_lock) && !QDELETED(room_key) && room_key.loc == src && key_lock.check_access(room_key)

/mob/living/simple_animal/enterprise_patron/proc/return_room_key()
	var/obj/item/key/key = room_key
	var/obj/structure/fake_machine/vendor/vendor = key_vendor?.resolve()
	var/list/entry = key_entry
	room_key = null
	key_vendor = null
	key_entry = null
	if(QDELETED(key) || key.loc != src)
		return FALSE
	if(QDELETED(vendor))
		key.forceMove(get_turf(src))
		return FALSE
	key.forceMove(vendor)
	vendor.held_items[key] = entry || list("NAME" = key.name, "PRICE" = 0)
	vendor.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/mob/living/simple_animal/enterprise_patron/proc/forget_enterprise()
	if(!enterprise)
		return
	var/datum/enterprise/visited = enterprise
	enterprise = null
	visited.patrons -= src
	visited.guests_changed()

/mob/living/simple_animal/enterprise_patron/proc/visit(datum/enterprise/visited)
	if(enterprise)
		enterprise.patrons -= src
	enterprise = visited
	visited.patrons |= src
	origin = get_turf(src)
	leaves_at = world.time + ENTERPRISE_PATRON_STAY_TIME

/mob/living/simple_animal/enterprise_patron/proc/take_room(datum/enterprise_room/wanted)
	if(wanted.tenant_name || wanted.get_patron() || wanted.kind != ENTERPRISE_ROOM_GUEST)
		return FALSE
	if(lodging)
		lodging.patron = null
	return_room_key()
	lodging = wanted
	wanted.patron = WEAKREF(src)
	wanted.patron_until = leaves_at
	wanted.set_doors_locked(!!enterprise?.take_room_key(wanted, src))
	enterprise?.guests_changed()
	return TRUE

/mob/living/simple_animal/enterprise_patron/proc/take_seat(datum/enterprise_seating/wanted)
	if(!wanted.is_free())
		return FALSE
	free_table()
	table_set = wanted
	wanted.patron = WEAKREF(src)
	return TRUE

/mob/living/simple_animal/enterprise_patron/proc/free_table()
	if(!table_set)
		return
	if(table_set.patron?.resolve() == src)
		table_set.patron = null
	table_set = null

/mob/living/simple_animal/enterprise_patron/proc/vacate()
	if(lodging)
		if(lodging.patron?.resolve() == src)
			lodging.patron = null
			lodging.patron_until = 0
			lodging.set_doors_locked(TRUE)
		lodging = null
		enterprise?.guests_changed()
	return_room_key()
	free_table()

/mob/living/simple_animal/enterprise_patron/proc/get_rent_due()
	if(!lodging || !enterprise || leaving || !(ENTERPRISE_PATRON_GOAL_ROOM in goals))
		return 0
	return enterprise.get_patron_rent(lodging)

/mob/living/simple_animal/enterprise_patron/proc/get_goal()
	if(leaving)
		return ENTERPRISE_PATRON_GOAL_LEAVE
	return length(goals) ? goals[1] : null

/mob/living/simple_animal/enterprise_patron/proc/stop_walking()
	var/datum/ai_controller/controller = ai_controller
	if(!istype(controller))
		return
	for(var/datum/ai_behavior/enterprise_patron_walk/walk in controller.current_behaviors)
		walk.finish_action(controller, FALSE, BB_ENTERPRISE_PATRON_TARGET)
	controller.movement_path = null
	controller.clear_blackboard_key(BB_FUTURE_MOVEMENT_PATH)

/mob/living/simple_animal/enterprise_patron/proc/leave_seat()
	seat = null
	if(buckled)
		buckled.unbuckle_mob(src, TRUE)

/mob/living/simple_animal/enterprise_patron/proc/claim_seat(obj/structure/wanted)
	seat = wanted ? WEAKREF(wanted) : null
	return get_turf(wanted)

/mob/living/simple_animal/enterprise_patron/proc/seat_lost()
	if(!seat)
		return FALSE
	var/obj/structure/wanted = seat.resolve()
	return QDELETED(wanted) || seat_blocked(wanted)

/mob/living/simple_animal/enterprise_patron/proc/seat_blocked(obj/structure/wanted)
	for(var/mob/living/sitter as anything in wanted.buckled_mobs)
		if(sitter != src)
			return TRUE
	for(var/mob/living/other in get_turf(wanted))
		if(other != src && other.density)
			return TRUE
	return FALSE

/mob/living/simple_animal/enterprise_patron/proc/next_goal()
	if(get_goal() == ENTERPRISE_PATRON_GOAL_TABLE)
		free_table()
	if(length(goals))
		goals.Cut(1, 2)
	goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
	stay_until = 0
	walk_until = 0
	stop_walking()
	leave_seat()
	enterprise?.guests_changed()

/mob/living/simple_animal/enterprise_patron/proc/remark(kind)
	var/list/choices = lines[kind]
	if(length(choices))
		remarks += pick(choices)

/mob/living/simple_animal/enterprise_patron/proc/complain(kind, weight = 1)
	remark(kind)
	displeasure += weight
	if(displeasure >= max_displeasure && !leaving)
		remark(ENTERPRISE_PATRON_LINE_FED_UP)
		start_leaving()

/mob/living/simple_animal/enterprise_patron/proc/depart()
	if(leaving)
		return
	if(displeasure < max_displeasure)
		remark(ENTERPRISE_PATRON_LINE_FAREWELL)
	start_leaving()

/mob/living/simple_animal/enterprise_patron/proc/start_leaving()
	if(leaving)
		return
	leaving = TRUE
	goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
	stay_until = 0
	walk_until = 0
	stop_walking()
	leave_seat()
	free_table()
	enterprise?.guests_changed()

/mob/living/simple_animal/enterprise_patron/proc/take_offence(mob/living/offender)
	if(leaving)
		return
	remark(ENTERPRISE_PATRON_LINE_OFFENDED)
	displeasure = max_displeasure
	start_leaving()

/mob/living/simple_animal/enterprise_patron/proc/leave()
	qdel(src)

/mob/living/simple_animal/enterprise_patron/proc/turn_away()
	remark(ENTERPRISE_PATRON_LINE_LOST)
	start_leaving()

/mob/living/simple_animal/enterprise_patron/proc/arrive()
	var/goal = get_goal()
	if(goal == ENTERPRISE_PATRON_GOAL_LEAVE)
		leave()
		return
	if(seat && !sit_down())
		goal_stage = ENTERPRISE_PATRON_STAGE_SEEK
		return
	goal_stage = ENTERPRISE_PATRON_STAGE_STAY
	switch(goal)
		if(ENTERPRISE_PATRON_GOAL_BAR)
			remark(ENTERPRISE_PATRON_LINE_ORDER)
			stay_until = world.time + bar_time
		if(ENTERPRISE_PATRON_GOAL_TABLE)
			stay_until = world.time + table_time
		if(ENTERPRISE_PATRON_GOAL_ROOM)
			stay_until = leaves_at
	enterprise?.guests_changed()

/mob/living/simple_animal/enterprise_patron/proc/sit_down()
	var/obj/structure/wanted = seat?.resolve()
	if(QDELETED(wanted) || wanted.loc != loc || length(wanted.buckled_mobs))
		return FALSE
	if(!wanted.buckle_mob(src, TRUE))
		return FALSE
	if(istype(wanted, /obj/structure/chair))
		face_table()
	return TRUE

/mob/living/simple_animal/enterprise_patron/proc/face_table()
	var/turf/here = get_turf(src)
	var/list/turf/pieces = list()
	for(var/datum/enterprise_fixture/fixture as anything in table_set?.tables)
		var/obj/structure/table/table = fixture.get_present(table_set.room)
		if(table)
			pieces += get_turf(table)
	for(var/direction in GLOB.cardinals)
		var/turf/beside = get_step(here, direction)
		if(beside && ((beside in pieces) || (!length(pieces) && (locate(/obj/structure/table) in beside))))
			setDir(direction)
			return TRUE
	return FALSE

/mob/living/simple_animal/enterprise_patron/proc/give_up()
	if(leaving)
		leave()
		return
	complain(ENTERPRISE_PATRON_LINE_LOST)
	if(!leaving)
		next_goal()

/datum/enterprise/proc/get_claimed_seats(mob/living/simple_animal/enterprise_patron/asking)
	var/list/obj/structure/claimed = list()
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		var/obj/structure/taken = patron == asking ? null : patron.seat?.resolve()
		if(taken)
			claimed += taken
	return claimed

/datum/enterprise/proc/find_seating(bar, list/claimed, mob/living/asking)
	var/list/datum/enterprise_seating/found = list()
	var/turf/bar_turf = find_note_table()
	for(var/datum/enterprise_room/room as anything in rooms)
		if(!room.template?.seats_patrons)
			continue
		for(var/datum/enterprise_seating/seating as anything in room.seatings)
			if(seating.has_table_at(bar_turf) != bar || !seating.get_free_chair(claimed, asking))
				continue
			if(bar || seating.is_free())
				found += seating
	var/mob/living/simple_animal/enterprise_patron/walker = asking
	for(var/attempt in 1 to min(length(found), ENTERPRISE_PATRON_SEAT_TRIES))
		var/datum/enterprise_seating/seating = pick_n_take(found)
		if(!istype(walker) || walker.can_walk_to(seating.get_free_chair(claimed, asking)))
			return seating
	return null

/datum/enterprise/proc/find_free_room()
	if(!has_patron_room_left())
		return null
	var/list/datum/enterprise_room/found = list()
	for(var/lock_id in guest_rooms)
		var/datum/enterprise_room/room = guest_rooms[lock_id]
		if(!room.tenant_name && !room.get_patron() && room.template?.lodges_patrons)
			found += room
	return length(found) ? pick(found) : null

/datum/enterprise/proc/get_outside_step(obj/structure/door/door)
	for(var/direction in GLOB.cardinals)
		var/turf/outside = get_step(door, direction)
		if(outside && !isclosedturf(outside) && !isopenspace(outside) && !contains(outside))
			return outside
	return null

/datum/enterprise/proc/find_exit_doors()
	exit_doors = list()
	var/list/obj/structure/door/seen = list()
	for(var/datum/enterprise_room/room as anything in rooms)
		for(var/datum/weakref/door_ref as anything in room.doors)
			var/obj/structure/door/door = door_ref.resolve()
			if(!QDELETED(door))
				seen |= door
		for(var/turf/member as anything in room.turfs)
			for(var/obj/structure/door/door in member)
				seen |= door
	for(var/obj/structure/door/door as anything in seen)
		if(!get_outside_step(door))
			continue
		var/penalty = ENTERPRISE_PATRON_BACK_DOOR_PENALTY
		var/list/turf/near = list(get_turf(door))
		for(var/direction in GLOB.cardinals)
			near += get_step(door, direction)
		for(var/turf/beside as anything in near)
			var/datum/enterprise_room/inside = get_room(beside)
			if(inside?.kind == ENTERPRISE_ROOM_COMMON)
				penalty = 0
				break
		exit_doors[WEAKREF(door)] = penalty

/datum/enterprise/proc/get_exit_turf(atom/from)
	if(isnull(exit_doors))
		find_exit_doors()
	var/turf/start = get_turf(from)
	var/turf/best
	var/best_distance = INFINITY
	for(var/datum/weakref/door_ref as anything in exit_doors)
		var/obj/structure/door/door = door_ref.resolve()
		if(QDELETED(door) || door.locked())
			continue
		var/turf/outside = get_outside_step(door)
		if(!outside)
			continue
		var/distance = get_dist(start, outside) + exit_doors[door_ref]
		if(start && outside.z != start.z)
			distance += ENTERPRISE_PATRON_OTHER_FLOOR_PENALTY
		if(distance < best_distance)
			best = outside
			best_distance = distance
	return best

/datum/enterprise/proc/summon_patron(patron_type, turf/entrance)
	if(!ispath(patron_type, /mob/living/simple_animal/enterprise_patron) || !isturf(entrance))
		return null
	var/mob/living/simple_animal/enterprise_patron/patron = new patron_type(entrance)
	patron.visit(src)
	return patron
