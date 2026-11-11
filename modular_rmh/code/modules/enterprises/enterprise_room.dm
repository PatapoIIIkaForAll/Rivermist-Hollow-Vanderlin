/atom/movable/screen/enterprise_picture
	plane = GAME_PLANE
	layer = GAME_PLANE
	appearance_flags = PIXEL_SCALE
	del_on_map_removal = FALSE

/datum/enterprise_floor
	var/datum/enterprise/enterprise
	var/z
	var/basement = FALSE
	var/list/turf/turfs = list()
	var/min_x = 0
	var/min_y = 0
	var/width = 0
	var/height = 0
	var/list/mask
	var/list/datum/enterprise_room/rooms = list()
	var/list/datum/enterprise_room/room_cells
	var/list/atom/movable/screen/enterprise_picture/picture
	var/list/atom/movable/screen/enterprise_zone/zones

/datum/enterprise_floor/New(z, datum/enterprise/enterprise)
	src.z = z
	src.enterprise = enterprise

/datum/enterprise_floor/Destroy()
	QDEL_LIST(picture)
	QDEL_LIST(zones)
	enterprise = null
	turfs = null
	mask = null
	rooms = null
	room_cells = null
	return ..()

/datum/enterprise_floor/proc/set_turfs(list/turf/new_turfs)
	turfs = new_turfs
	room_cells = null
	var/turf/first = turfs[1]
	min_x = first.x
	min_y = first.y
	var/max_x = first.x
	var/max_y = first.y
	for(var/turf/member as anything in turfs)
		min_x = min(min_x, member.x)
		min_y = min(min_y, member.y)
		max_x = max(max_x, member.x)
		max_y = max(max_y, member.y)
	width = max_x - min_x + 1
	height = max_y - min_y + 1
	mask = new /list(width * height)
	for(var/turf/member as anything in turfs)
		mask[(member.y - min_y) * width + (member.x - min_x) + 1] = TRUE

/datum/enterprise_floor/proc/set_rooms(list/datum/enterprise_room/new_rooms)
	rooms = new_rooms
	room_cells = new /list(width * height)
	for(var/datum/enterprise_room/room as anything in rooms)
		for(var/turf/member as anything in room.turfs)
			room_cells[cell_index(member)] = room

/datum/enterprise_floor/proc/contains(turf/checked)
	if(!checked || checked.z != z)
		return FALSE
	var/column = checked.x - min_x
	var/row = checked.y - min_y
	if(column < 0 || row < 0 || column >= width || row >= height)
		return FALSE
	return !!mask[row * width + column + 1]

/datum/enterprise_floor/proc/cell_index(turf/member)
	return (member.y - min_y) * width + (member.x - min_x) + 1

/datum/enterprise_floor/proc/get_room(turf/checked)
	if(!room_cells || !contains(checked))
		return null
	return room_cells[cell_index(checked)]

/datum/enterprise_floor/proc/get_atoms(atom_type)
	var/list/found = list()
	for(var/turf/member as anything in turfs)
		for(var/atom/movable/thing as anything in member)
			if(istype(thing, atom_type))
				found += thing
	return found

/datum/enterprise_floor/proc/get_screen_x()
	return enterprise.frame_pad_x + 1 + (min_x - enterprise.frame_min_x)

/datum/enterprise_floor/proc/get_screen_y()
	return enterprise.frame_pad_y + 1 + (min_y - enterprise.frame_min_y)

/datum/enterprise_floor/proc/get_pixel_x()
	return (get_screen_x() - 1) * ICON_SIZE_X

/datum/enterprise_floor/proc/get_pixel_y()
	return (get_screen_y() - 1) * ICON_SIZE_Y

/datum/enterprise_floor/proc/copy_appearance(atom/source, offset)
	var/mutable_appearance/copy = new
	copy.appearance = source.appearance
	copy.pixel_x += offset
	return copy

/datum/enterprise_floor/proc/take_picture()
	QDEL_LIST(picture)
	picture = list()
	var/origin_x = get_pixel_x()
	var/origin_y = get_pixel_y()

	for(var/row in 0 to height - 1)
		var/list/strip_overlays = list()
		for(var/column in 0 to width - 1)
			if(!mask[row * width + column + 1])
				continue
			var/turf/member = locate(min_x + column, min_y + row, z)
			var/offset = column * ICON_SIZE_X
			strip_overlays += copy_appearance(member, offset)
			for(var/obj/thing in member)
				if(!thing.invisibility)
					strip_overlays += copy_appearance(thing, offset)
		if(!length(strip_overlays))
			continue
		var/atom/movable/screen/enterprise_picture/strip = new
		strip.pixel_x = origin_x
		strip.pixel_y = origin_y + row * ICON_SIZE_Y
		strip.overlays = strip_overlays
		picture += strip

	var/list/label_overlays = list()
	for(var/datum/enterprise_room/room as anything in rooms)
		if(!room.name || (room.kind != ENTERPRISE_ROOM_GUEST && length(room.turfs) < ENTERPRISE_ROOM_LABEL_MIN_TILES))
			continue
		var/turf/first = room.turfs[1]
		var/room_min_x = first.x
		var/room_max_x = first.x
		var/room_min_y = first.y
		var/room_max_y = first.y
		for(var/turf/member as anything in room.turfs)
			room_min_x = min(room_min_x, member.x)
			room_max_x = max(room_max_x, member.x)
			room_min_y = min(room_min_y, member.y)
			room_max_y = max(room_max_y, member.y)
		var/mutable_appearance/label = mutable_appearance()
		label.plane = RUNECHAT_PLANE
		label.appearance_flags = RESET_COLOR | RESET_ALPHA
		label.maptext = MAPTEXT_CENTER(room.name)
		label.maptext_width = (room_max_x - room_min_x + 1) * ICON_SIZE_X
		label.maptext_height = ICON_SIZE_Y
		label.pixel_x = (room_min_x - min_x) * ICON_SIZE_X
		label.pixel_y = (round((room_min_y + room_max_y) / 2) - min_y) * ICON_SIZE_Y
		label_overlays += label
	if(length(label_overlays))
		var/atom/movable/screen/enterprise_picture/labels = new
		labels.pixel_x = origin_x
		labels.pixel_y = origin_y
		labels.overlays = label_overlays
		picture += labels
	mark_zones()

/datum/enterprise_floor/proc/mark_zones()
	QDEL_LIST(zones)
	zones = list()
	var/origin_x = get_pixel_x()
	var/origin_y = get_pixel_y()
	for(var/datum/enterprise_room/room as anything in rooms)
		var/list/mutable_appearance/shape = list()
		for(var/turf/member as anything in room.turfs)
			var/mutable_appearance/square = mutable_appearance('modular_rmh/icons/enterprises/zone.dmi', "white")
			square.pixel_x = (member.x - min_x) * ICON_SIZE_X
			square.pixel_y = (member.y - min_y) * ICON_SIZE_Y
			shape += square
		room.shape = shape
		var/atom/movable/screen/enterprise_zone/zone = new
		zone.room = room
		zone.pixel_x = origin_x
		zone.pixel_y = origin_y
		zone.overlays = shape
		zones += zone

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
	var/marked = get_marked_purpose()
	for(var/datum/enterprise_room_template/candidate as anything in templates)
		if(marked ? candidate.id == marked : candidate.matches(src))
			template = candidate
			break
	build_seatings()

/datum/enterprise_room/proc/get_marked_purpose()
	for(var/turf/member as anything in turfs)
		var/obj/effect/landmark/enterprise_room/marker = locate() in member
		if(marker)
			return marker.purpose
	return null

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
	var/turf/best
	var/best_rank = 0
	for(var/datum/weakref/door_ref as anything in doors)
		var/obj/structure/door/door = door_ref.resolve()
		if(QDELETED(door))
			continue
		var/turf/door_turf = get_turf(door)
		for(var/direction in GLOB.cardinals)
			var/turf/outside = get_step(door_turf, direction)
			if(!outside || isclosedturf(outside))
				continue
			var/datum/enterprise_room/beyond = enterprise.get_room(outside)
			if(beyond == src)
				continue
			var/rank = 1
			if(!beyond)
				if(enterprise.contains(outside))
					continue
				rank = 3
			else if(beyond.kind == ENTERPRISE_ROOM_COMMON)
				rank = 2
			if(door.name == name)
				rank += 4
			if(rank > best_rank)
				best = outside
				best_rank = rank
	return best

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

/datum/enterprise_seating
	var/datum/enterprise_room/room
	var/list/datum/enterprise_fixture/tables = list()
	var/list/datum/enterprise_fixture/chairs = list()
	var/datum/weakref/patron

/datum/enterprise_seating/New(datum/enterprise_room/room)
	src.room = room

/datum/enterprise_seating/Destroy()
	room = null
	tables = null
	chairs = null
	patron = null
	return ..()

/datum/enterprise_seating/proc/get_level()
	return room ? room.level : ENTERPRISE_LEVEL_BARE

/datum/enterprise_seating/proc/has_chair(obj/structure/chair/seat)
	for(var/datum/enterprise_fixture/fixture as anything in chairs)
		if(fixture.get_thing() == seat)
			return TRUE
	return FALSE

/datum/enterprise_seating/proc/get_patron()
	var/mob/living/found = patron?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_seating/proc/is_free()
	return !get_patron()

/obj/effect/landmark/enterprise_room
	name = "enterprise room purpose"
	var/purpose

/obj/effect/landmark/enterprise_room/guest_room
	purpose = ENTERPRISE_PURPOSE_GUEST_ROOM

/obj/effect/landmark/enterprise_room/kitchen
	purpose = ENTERPRISE_PURPOSE_KITCHEN

/obj/effect/landmark/enterprise_room/staff_quarters
	purpose = ENTERPRISE_PURPOSE_STAFF_QUARTERS

/obj/effect/landmark/enterprise_room/drink_storage
	purpose = ENTERPRISE_PURPOSE_DRINK_STORAGE

/obj/effect/landmark/enterprise_room/storage
	purpose = ENTERPRISE_PURPOSE_STORAGE

/obj/effect/landmark/enterprise_room/service_hall
	purpose = ENTERPRISE_PURPOSE_SERVICE_HALL
