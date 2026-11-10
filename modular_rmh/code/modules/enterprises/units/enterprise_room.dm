/datum/enterprise_room
	var/datum/enterprise/enterprise
	var/kind = ENTERPRISE_ROOM_COMMON
	var/datum/enterprise_room_template/template
	var/level = ENTERPRISE_LEVEL_BARE
	var/lock_id
	var/name
	var/z
	var/beds = 0
	var/list/turf/turfs = list()
	var/list/datum/weakref/doors = list()
	var/list/datum/enterprise_fixture/fixtures = list()
	var/list/datum/enterprise_seating/seatings = list()
	var/list/mutable_appearance/shape

	var/datum/weakref/tenant
	var/tenant_name
	var/datum/weakref/tenant_key
	var/tenant_since = 0
	var/tenant_seen = 0
	var/datum/weakref/patron
	var/patron_until = 0
	var/datum/enterprise_stock/stock

	var/list/shown_pages = list()

	var/enclosed = TRUE
	var/kept = FALSE
	var/name_weight = 0
	var/list/obj/structure/door/lock_doors = list()
	var/list/datum/enterprise_room/links = list()
	var/datum/enterprise_room/merged_into

/datum/enterprise_room/New(z, datum/enterprise/enterprise)
	src.z = z
	src.enterprise = enterprise

/datum/enterprise_room/Destroy()
	SStgui.close_uis(src)
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		if(fixture.room == src)
			fixture.room = null
	QDEL_LIST(seatings)
	QDEL_NULL(stock)
	enterprise = null
	template = null
	turfs = null
	doors = null
	fixtures = null
	shape = null
	lock_doors = null
	links = null
	merged_into = null
	shown_pages = null
	tenant = null
	tenant_key = null
	patron = null
	return ..()

/datum/enterprise_room/proc/resolve()
	var/datum/enterprise_room/current = src
	while(current.merged_into)
		current = current.merged_into
	return current

/datum/enterprise_room/proc/link_with(datum/enterprise_room/other)
	if(other == src)
		return
	links |= other
	other.links |= src

/datum/enterprise_room/proc/finish_survey()
	for(var/obj/structure/door/door as anything in lock_doors)
		doors += WEAKREF(door)
	lock_doors = null
	links = null

/datum/enterprise_room/proc/inherit(datum/enterprise_room/former)
	level = max(level, former.level)
	if(former.tenant_name && !tenant_name)
		tenant = former.tenant
		tenant_name = former.tenant_name
		tenant_key = former.tenant_key
		tenant_since = former.tenant_since
		tenant_seen = former.tenant_seen
	if(former.patron && !patron)
		patron = former.patron
		patron_until = former.patron_until
		var/mob/living/simple_animal/enterprise_patron/lodger = get_patron()
		if(lodger)
			lodger.lodging = src
	if(former.stock && !stock)
		stock = former.stock
		former.stock = null
		stock.storage = src

/datum/enterprise_room/proc/furnish(list/datum/enterprise_room_template/templates)
	beds = count_fixtures(/obj/structure/bed)
	template = null
	for(var/datum/enterprise_room_template/candidate as anything in templates)
		if(candidate.matches(src))
			template = candidate
			break
	build_seatings()

/datum/enterprise_room/proc/get_purpose()
	return template?.id

/datum/enterprise_room/proc/set_level(new_level)
	new_level = clamp(round(new_level), ENTERPRISE_LEVEL_BARE, ENTERPRISE_MAX_LEVEL)
	if(new_level == level)
		return FALSE
	level = new_level
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		fixture.apply_level(level)
	return TRUE

/datum/enterprise_room/proc/raise_level(new_level)
	return new_level > level ? set_level(new_level) : FALSE

/datum/enterprise_room/proc/build_seatings()
	QDEL_LIST(seatings)
	seatings = list()
	var/list/table_at = list()
	var/list/datum/enterprise_fixture/seats = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		if(ispath(fixture.fixture_type, /obj/structure/table))
			table_at[fixture.home] = fixture
		else if(ispath(fixture.fixture_type, /obj/structure/chair))
			seats += fixture
	var/list/seating_of = list()
	for(var/turf/start as anything in table_at)
		if(seating_of[table_at[start]])
			continue
		var/datum/enterprise_seating/seating = new(src)
		var/list/turf/queue = list(start)
		seating_of[table_at[start]] = seating
		var/position = 1
		while(position <= length(queue))
			var/turf/current = queue[position]
			position++
			seating.tables += table_at[current]
			for(var/direction in GLOB.cardinals)
				var/turf/next = get_step(current, direction)
				var/datum/enterprise_fixture/neighbour = table_at[next]
				if(neighbour && !seating_of[neighbour])
					seating_of[neighbour] = seating
					queue += next
		seatings += seating
	for(var/datum/enterprise_fixture/seat as anything in seats)
		for(var/direction in GLOB.cardinals)
			var/datum/enterprise_fixture/table = table_at[get_step(seat.home, direction)]
			if(!table)
				continue
			var/datum/enterprise_seating/seating = seating_of[table]
			seating.chairs += seat
			break
	for(var/datum/enterprise_seating/seating as anything in seatings)
		if(!length(seating.chairs))
			seatings -= seating
			qdel(seating)

/datum/enterprise_room/proc/get_seating(obj/structure/chair/seat)
	for(var/datum/enterprise_seating/seating as anything in seatings)
		if(seating.has_chair(seat))
			return seating
	return null

/datum/enterprise_room/proc/count_fixtures(fixture_type)
	var/found = 0
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		if(ispath(fixture.fixture_type, fixture_type) && fixture.is_present())
			found++
	return found

/datum/enterprise_room/proc/get_interior(atom_type)
	var/list/obj/found = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		if(atom_type && !ispath(fixture.fixture_type, atom_type))
			continue
		if(fixture.is_present())
			found += fixture.get_thing()
	return found

/datum/enterprise_room/proc/get_damaged_fixtures()
	var/list/datum/enterprise_fixture/damaged = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		if(fixture.needs_repair())
			damaged += fixture
	return damaged

/datum/enterprise_room/proc/get_repair_cost()
	var/worth = 0
	for(var/datum/enterprise_fixture/fixture as anything in get_damaged_fixtures())
		worth += fixture.value
	return worth * ENTERPRISE_REPAIR_MULTIPLIER

/datum/enterprise_room/proc/repair()
	var/restored = 0
	for(var/datum/enterprise_fixture/fixture as anything in get_damaged_fixtures())
		var/obj/structure/door/door = fixture.restore()
		if(istype(door))
			doors |= WEAKREF(door)
		restored++
	return restored

/datum/enterprise_room/proc/get_door_step()
	for(var/datum/weakref/door_ref as anything in doors)
		var/obj/structure/door/door = door_ref.resolve()
		if(QDELETED(door))
			continue
		var/turf/door_turf = get_turf(door)
		for(var/direction in GLOB.cardinals)
			var/turf/outside = get_step(door_turf, direction)
			var/datum/enterprise_room/beyond = enterprise.get_room(outside)
			if(beyond && beyond != src)
				return outside
	return null

/datum/enterprise_room/proc/get_loose_items()
	var/list/known = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		var/obj/thing = fixture.get_thing()
		if(thing)
			known[thing] = TRUE
	var/list/obj/item/loose = list()
	for(var/turf/member as anything in turfs)
		for(var/obj/item/thing in member)
			if(!known[thing] && !thing.anchored)
				loose += thing
	for(var/obj/structure/closet/chest in known)
		for(var/obj/item/thing in chest)
			loose += thing
	return loose
