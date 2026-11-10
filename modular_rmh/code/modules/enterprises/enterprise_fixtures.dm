/datum/enterprise
	var/list/datum/enterprise_fixture/fixtures = list()
	var/list/datum/enterprise_room_template/room_templates

/datum/enterprise/proc/is_fixture(obj/thing)
	var/static/list/ignored = list(
		/obj/item/reagent_containers/food,
		/obj/structure/flora,
		/obj/structure/flowerpot,
		/obj/structure/fluff/clutter/shrub,
		/obj/structure/fake_machine,
	)
	if(is_type_in_list(thing, ignored))
		return FALSE
	return istype(thing, /obj/structure) || istype(thing, /obj/machinery) || istype(thing, /obj/item)

/datum/enterprise/proc/take_fixtures(list/turf/fresh)
	var/list/datum/enterprise_fixture/taken = list()
	for(var/turf/member as anything in fresh)
		if(!contains(member))
			continue
		for(var/obj/thing in member)
			if(thing.invisibility || !is_fixture(thing))
				continue
			var/datum/enterprise_fixture/fixture = new(thing)
			fixture.family = get_furnishing(thing.type)
			fixtures += fixture
			taken += fixture
	return taken

/datum/enterprise/proc/get_adjoining_room(turf/place)
	var/static/list/kind_ranks = list(
		ENTERPRISE_ROOM_GUEST = 1,
		ENTERPRISE_ROOM_SERVICE = 2,
		ENTERPRISE_ROOM_COMMON = 3,
	)
	var/datum/enterprise_room/chosen
	for(var/direction in GLOB.cardinals)
		var/datum/enterprise_room/candidate = get_room(get_step(place, direction))
		if(!candidate || candidate == chosen)
			continue
		if(!chosen)
			chosen = candidate
			continue
		var/rank_gap = kind_ranks[candidate.kind] - kind_ranks[chosen.kind]
		if(rank_gap < 0 || (!rank_gap && length(candidate.turfs) < length(chosen.turfs)))
			chosen = candidate
	return chosen

/datum/enterprise/proc/get_room_templates()
	if(room_templates)
		return room_templates
	room_templates = list()
	for(var/template_type in subtypesof(/datum/enterprise_room_template))
		var/datum/enterprise_room_template/template = new template_type
		var/position = 1
		while(position <= length(room_templates))
			var/datum/enterprise_room_template/other = room_templates[position]
			if(other.priority > template.priority)
				break
			position++
		room_templates.Insert(position, template)
	return room_templates

/datum/enterprise/proc/furnish_rooms()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.fixtures = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		var/datum/enterprise_room/room = get_room(fixture.home) || get_adjoining_room(fixture.home)
		fixture.room = room
		if(room)
			room.fixtures += fixture
	var/list/datum/enterprise_room_template/templates = get_room_templates()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.furnish(templates)
