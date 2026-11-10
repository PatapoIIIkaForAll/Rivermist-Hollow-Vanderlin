// A map control never shows less than this many tiles; a smaller floor is centred in the frame.
#define FLOOR_VIEW_MIN_WIDTH 20
#define FLOOR_VIEW_MIN_HEIGHT 15

// Pins the size of the floor's map and stays under the view; shared by every viewer.
/atom/movable/screen/background/enterprise_floor
	layer = GAME_PLANE - 1
	del_on_map_removal = FALSE

// Lies over the whole floor map: takes the mouse wheel and keeps clicks off the turfs shown under it.
/atom/movable/screen/enterprise_floor_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = ABOVE_HUD_PLANE
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	del_on_map_removal = FALSE
	var/datum/enterprise_floor/floor

/atom/movable/screen/enterprise_floor_catcher/Destroy()
	floor = null
	return ..()

/atom/movable/screen/enterprise_floor_catcher/MouseWheel(delta_x, delta_y, location, control, params)
	if(floor && delta_y)
		floor.enterprise.wheel_floor(usr, delta_y > 0 ? 1 : -1)

/datum/enterprise_floor
	var/datum/enterprise/enterprise
	var/z
	var/basement = FALSE
	var/list/turf/turfs = list()
	var/min_x = 0
	var/min_y = 0
	var/width = 0
	var/height = 0
	// One cell per turf of the bounding box, row by row; TRUE where the turf belongs to the floor.
	var/list/mask
	var/list/datum/enterprise_room/rooms = list()
	// Laid out like the mask; holds the guest room a turf belongs to, if any.
	var/list/datum/enterprise_room/room_cells
	var/map_key
	var/atom/movable/screen/map_view/view
	var/atom/movable/screen/background/enterprise_floor/backdrop
	var/atom/movable/screen/enterprise_floor_catcher/catcher
	var/list/atom/movable/screen/plane_master/plane_masters

/datum/enterprise_floor/New(z, datum/enterprise/enterprise)
	var/static/keys_made = 0
	keys_made++
	src.z = z
	src.enterprise = enterprise
	// A map key has to start and end with a letter.
	map_key = "enterprisefloor[keys_made]map"

/datum/enterprise_floor/Destroy()
	QDEL_NULL(view)
	QDEL_NULL(backdrop)
	QDEL_NULL(catcher)
	QDEL_LIST(plane_masters)
	enterprise = null
	turfs = null
	mask = null
	rooms = null
	room_cells = null
	return ..()

/datum/enterprise_floor/proc/add_turfs(list/turf/added)
	turfs += added
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
	if(view)
		update_view()

/datum/enterprise_floor/proc/contains(turf/checked)
	if(!checked || checked.z != z)
		return FALSE
	var/column = checked.x - min_x
	var/row = checked.y - min_y
	if(column < 0 || row < 0 || column >= width || row >= height)
		return FALSE
	return !!mask[row * width + column + 1]

// Only for a turf inside the bounding box, which every turf of the floor is.
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

/datum/enterprise_floor/proc/update_view()
	var/frame_width = max(width, FLOOR_VIEW_MIN_WIDTH)
	var/frame_height = max(height, FLOOR_VIEW_MIN_HEIGHT)
	backdrop.fill_rect(1, 1, frame_width, frame_height)
	catcher.fill_rect(1, 1, frame_width, frame_height)
	view.set_position(1 + round((frame_width - width) / 2), 1 + round((frame_height - height) / 2))
	view.vis_contents.Cut()
	view.vis_contents += turfs
	update_labels()

// Writes each guest room's name over the room, as overlays of the view.
/datum/enterprise_floor/proc/update_labels()
	if(!view)
		return
	view.overlays.Cut()
	for(var/datum/enterprise_room/room as anything in rooms)
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
		label.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		label.maptext = MAPTEXT_CENTER(room.name)
		label.maptext_width = (room_max_x - room_min_x + 1) * ICON_SIZE_X
		label.maptext_height = ICON_SIZE_Y
		label.pixel_x = (room_min_x - min_x) * ICON_SIZE_X
		label.pixel_y = (round((room_min_y + room_max_y) / 2) - min_y) * ICON_SIZE_Y
		view.overlays += label

/**
 * The map control of a floor has no plane masters of its own, and without them the lighting and
 * emissive planes are drawn as plain pictures over the turfs. Every floor gets its own set; the
 * planes that only darken the picture are switched off, so the floor is shown fully lit.
 */
/datum/enterprise_floor/proc/build_view()
	backdrop = new
	backdrop.assigned_map = map_key
	catcher = new
	catcher.assigned_map = map_key
	catcher.floor = src
	view = new
	view.generate_view(map_key)
	plane_masters = list()
	for(var/plane_type in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/plane_master = new plane_type()
		if(plane_master.blend_mode_override == BLEND_MULTIPLY)
			plane_master.alpha = 0
		else if(plane_master.blend_mode_override)
			plane_master.blend_mode = plane_master.blend_mode_override
		plane_master.assigned_map = map_key
		plane_master.del_on_map_removal = FALSE
		plane_master.screen_loc = "[map_key]:CENTER"
		plane_masters += plane_master
	update_view()

/datum/enterprise_floor/proc/show_to(client/viewer)
	if(!view)
		build_view()
	viewer.register_map_obj(backdrop)
	viewer.register_map_obj(view)
	viewer.register_map_obj(catcher)
	for(var/atom/movable/screen/plane_master/plane_master as anything in plane_masters)
		viewer.register_map_obj(plane_master)

/datum/enterprise_floor/proc/hide_from(client/viewer)
	viewer.clear_map(map_key)

#undef FLOOR_VIEW_MIN_WIDTH
#undef FLOOR_VIEW_MIN_HEIGHT
