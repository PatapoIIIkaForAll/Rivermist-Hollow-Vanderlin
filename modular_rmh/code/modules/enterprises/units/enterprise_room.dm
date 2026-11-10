/datum/enterprise_room
	var/datum/enterprise/enterprise
	var/kind = ENTERPRISE_ROOM_COMMON
	var/datum/enterprise_room_template/template
	var/level = 1
	var/lock_id
	var/name
	var/z
	var/beds = 0
	var/list/turf/turfs = list()
	var/list/datum/weakref/doors = list()
	var/list/datum/enterprise_fixture/fixtures = list()
	var/list/mutable_appearance/shape

	var/tenant_name
	var/tenant_until
	var/tenant_rent = 0
	var/list/tenant_needs

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

/datum/enterprise_room/proc/furnish(list/datum/enterprise_room_template/templates)
	beds = count_fixtures(/obj/structure/bed)
	template = null
	for(var/datum/enterprise_room_template/candidate as anything in templates)
		if(candidate.matches(src))
			template = candidate
			break

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
