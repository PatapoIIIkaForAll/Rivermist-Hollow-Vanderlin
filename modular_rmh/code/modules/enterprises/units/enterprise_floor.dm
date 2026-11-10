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
