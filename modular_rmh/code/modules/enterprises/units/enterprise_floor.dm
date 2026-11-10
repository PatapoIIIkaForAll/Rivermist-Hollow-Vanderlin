// A map control never shows less than this many tiles; a smaller floor is centred in the frame.
#define FLOOR_VIEW_MIN_WIDTH 20
#define FLOOR_VIEW_MIN_HEIGHT 15

// Pins the size of the floor's map and stays under the view; shared by every viewer.
/atom/movable/screen/background/enterprise_floor
	layer = GAME_PLANE - 1
	del_on_map_removal = FALSE

/datum/enterprise_floor
	var/z
	var/basement = FALSE
	var/list/turf/turfs = list()
	var/min_x = 0
	var/min_y = 0
	var/width = 0
	var/height = 0
	// One cell per turf of the bounding box, row by row; TRUE where the turf belongs to the floor.
	var/list/mask
	var/map_key
	var/atom/movable/screen/map_view/view
	var/atom/movable/screen/background/enterprise_floor/backdrop

/datum/enterprise_floor/New(z)
	var/static/keys_made = 0
	keys_made++
	src.z = z
	// A map key has to start and end with a letter.
	map_key = "enterprisefloor[keys_made]map"

/datum/enterprise_floor/Destroy()
	QDEL_NULL(view)
	QDEL_NULL(backdrop)
	turfs = null
	mask = null
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
	view.set_position(1 + round((frame_width - width) / 2), 1 + round((frame_height - height) / 2))
	view.vis_contents.Cut()
	view.vis_contents += turfs

/datum/enterprise_floor/proc/build_view()
	backdrop = new
	backdrop.assigned_map = map_key
	view = new
	view.generate_view(map_key)
	update_view()

/datum/enterprise_floor/proc/show_to(client/viewer)
	if(!view)
		build_view()
	viewer.register_map_obj(backdrop)
	viewer.register_map_obj(view)

/datum/enterprise_floor/proc/hide_from(client/viewer)
	viewer.clear_map(map_key)

#undef FLOOR_VIEW_MIN_WIDTH
#undef FLOOR_VIEW_MIN_HEIGHT
