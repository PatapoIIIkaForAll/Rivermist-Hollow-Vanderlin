// A map control never shows less than this many tiles; smaller premises are centred in the frame.
#define ENTERPRISE_MAP_MIN_WIDTH 20
#define ENTERPRISE_MAP_MIN_HEIGHT 15

// Pins the size of the enterprise's map and stays under the pictures; shared by every viewer.
/atom/movable/screen/background/enterprise_map
	layer = GAME_PLANE - 1
	del_on_map_removal = FALSE

// Lies over the whole map: takes the mouse wheel and keeps clicks off the pictures under it.
/atom/movable/screen/enterprise_map_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = ABOVE_HUD_PLANE
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	del_on_map_removal = FALSE
	var/datum/enterprise/enterprise

/atom/movable/screen/enterprise_map_catcher/Destroy()
	enterprise = null
	return ..()

/atom/movable/screen/enterprise_map_catcher/MouseWheel(delta_x, delta_y, location, control, params)
	if(enterprise && delta_y)
		enterprise.wheel_floor(usr, delta_y > 0 ? 1 : -1)

/**
 * The premises are shown on one map control. Its frame covers every floor, so a floor keeps its place
 * on the screen when another one is switched to, and switching only swaps the picture.
 */
/datum/enterprise
	var/map_key
	var/atom/movable/screen/background/enterprise_map/map_backdrop
	var/atom/movable/screen/enterprise_map_catcher/map_catcher
	var/list/atom/movable/screen/plane_master/map_plane_masters
	// The south-west corner all floors are measured from, and the margins that centre them in the frame.
	var/frame_min_x = 1
	var/frame_min_y = 1
	var/frame_pad_x = 0
	var/frame_pad_y = 0
	// The z-level each open ledger is showing on its premises page, by REF of the viewer.
	var/list/viewed_z = list()

/**
 * The map control has no plane masters of its own, and without them the lighting and emissive planes
 * are drawn as plain pictures over everything. It gets its own set; the planes that only darken the
 * picture are switched off, so the premises are shown fully lit.
 */
/datum/enterprise/proc/build_map()
	var/static/maps_made = 0
	maps_made++
	// A map key has to start and end with a letter.
	map_key = "enterprisemap[maps_made]view"
	map_backdrop = new
	map_backdrop.assigned_map = map_key
	map_catcher = new
	map_catcher.assigned_map = map_key
	map_catcher.enterprise = src
	map_plane_masters = list()
	for(var/plane_type in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/plane_master = new plane_type()
		if(plane_master.blend_mode_override == BLEND_MULTIPLY)
			plane_master.alpha = 0
		else if(plane_master.blend_mode_override)
			plane_master.blend_mode = plane_master.blend_mode_override
		plane_master.assigned_map = map_key
		plane_master.del_on_map_removal = FALSE
		plane_master.screen_loc = "[map_key]:CENTER"
		map_plane_masters += plane_master

/datum/enterprise/proc/update_map_frame()
	if(!map_key)
		build_map()
	var/min_x
	var/min_y
	var/max_x
	var/max_y
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(!floor)
			continue
		if(isnull(min_x))
			min_x = floor.min_x
			min_y = floor.min_y
			max_x = floor.min_x + floor.width - 1
			max_y = floor.min_y + floor.height - 1
			continue
		min_x = min(min_x, floor.min_x)
		min_y = min(min_y, floor.min_y)
		max_x = max(max_x, floor.min_x + floor.width - 1)
		max_y = max(max_y, floor.min_y + floor.height - 1)
	if(isnull(min_x))
		return
	var/width = max_x - min_x + 1
	var/height = max_y - min_y + 1
	var/frame_width = max(width, ENTERPRISE_MAP_MIN_WIDTH)
	var/frame_height = max(height, ENTERPRISE_MAP_MIN_HEIGHT)
	frame_min_x = min_x
	frame_min_y = min_y
	frame_pad_x = round((frame_width - width) / 2)
	frame_pad_y = round((frame_height - height) / 2)
	map_backdrop.fill_rect(1, 1, frame_width, frame_height)
	map_catcher.fill_rect(1, 1, frame_width, frame_height)

// Puts the picture of one floor on the viewer's map, in place of the floor shown there before.
/datum/enterprise/proc/show_floor(mob/user, z)
	var/client/viewer = user?.client
	var/datum/enterprise_floor/floor = get_floor(z)
	if(!viewer || !floor || !map_key || !is_owner(user))
		return FALSE
	var/viewer_key = REF(user)
	var/shown_z = viewed_z[viewer_key]
	if(shown_z == z)
		return FALSE
	if(shown_z)
		var/datum/enterprise_floor/shown = get_floor(shown_z)
		if(shown && length(shown.picture))
			viewer.screen -= shown.picture
			viewer.screen_maps[map_key] -= shown.picture
	else
		viewer.register_map_obj(map_backdrop)
		viewer.register_map_obj(map_catcher)
		for(var/atom/movable/screen/plane_master/plane_master as anything in map_plane_masters)
			viewer.register_map_obj(plane_master)
	for(var/atom/movable/screen/enterprise_picture/strip as anything in floor.picture)
		viewer.register_map_obj(strip)
	viewed_z[viewer_key] = z
	return TRUE

// Opens the lowest floor that is not a basement, or the lowest floor there is.
/datum/enterprise/proc/open_premises(mob/user)
	var/datum/enterprise_floor/chosen
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(!floor)
			continue
		if(!chosen)
			chosen = floor
		if(!floor.basement)
			chosen = floor
			break
	return chosen ? show_floor(user, chosen.z) : FALSE

// Moves the viewer one floor up or down, skipping the levels the enterprise does not reach.
/datum/enterprise/proc/step_floor(mob/user, direction)
	var/z = viewed_z[REF(user)]
	if(!z)
		return FALSE
	var/next_z = get_next_floor_z(z, direction)
	return next_z ? show_floor(user, next_z) : FALSE

/datum/enterprise/proc/get_next_floor_z(z, direction)
	z += direction
	while(z >= 1 && z <= length(floors))
		if(floors[z])
			return z
		z += direction
	return null

/datum/enterprise/proc/wheel_floor(mob/user, direction)
	if(step_floor(user, direction))
		SStgui.update_uis(src)

/datum/enterprise/proc/hide_floors(mob/user)
	viewed_z -= REF(user)
	var/client/viewer = user?.client
	if(viewer && map_key)
		viewer.clear_map(map_key)

// After a survey the pictures are new objects: whoever is looking gets them in place of the old ones.
/datum/enterprise/proc/reshow_floors()
	for(var/viewer_key in viewed_z.Copy())
		var/z = viewed_z[viewer_key]
		var/mob/user = locate(viewer_key)
		viewed_z -= viewer_key
		if(!istype(user) || !user.client)
			continue
		user.client.clear_map(map_key)
		if(!show_floor(user, z))
			open_premises(user)

#undef ENTERPRISE_MAP_MIN_WIDTH
#undef ENTERPRISE_MAP_MIN_HEIGHT
