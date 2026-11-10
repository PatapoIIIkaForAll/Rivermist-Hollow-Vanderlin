/datum/enterprise
	var/list/datum/enterprise_fixture/fixtures = list()
	var/list/datum/enterprise_room_template/room_templates

/datum/enterprise/proc/is_fixture(obj/thing)
	if(istype(thing, /obj/item/reagent_containers/food))
		return FALSE
	return istype(thing, /obj/structure) || istype(thing, /obj/machinery) || istype(thing, /obj/item)

/datum/enterprise/proc/take_fixtures(list/turf/fresh)
	for(var/turf/member as anything in fresh)
		if(!get_room(member))
			continue
		for(var/obj/thing in member)
			if(!thing.invisibility && is_fixture(thing))
				fixtures += new /datum/enterprise_fixture(thing)

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
		var/datum/enterprise_room/room = get_room(fixture.home)
		fixture.room = room
		if(room)
			room.fixtures += fixture
	var/list/datum/enterprise_room_template/templates = get_room_templates()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.furnish(templates)
