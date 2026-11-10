#define ENTERPRISE_MAP_MIN_WIDTH 20
#define ENTERPRISE_MAP_MIN_HEIGHT 15
#define ENTERPRISE_MENU_BUTTON_WIDTH 128
#define ENTERPRISE_MENU_BUTTON_HEIGHT 24
#define ENTERPRISE_MENU_BUTTON_STEP 26
#define ENTERPRISE_MENU_ALPHA_IDLE 170
#define ENTERPRISE_MENU_ALPHA_HOVER 255

/atom/movable/screen/background/enterprise_map
	layer = GAME_PLANE - 1
	del_on_map_removal = FALSE

/atom/movable/screen/enterprise_map_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = ABOVE_HUD_PLANE
	layer = 1
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

/atom/movable/screen/enterprise_map_catcher/Click(location, control, params)
	if(enterprise)
		enterprise.close_room_menu(usr)

/atom/movable/screen/enterprise_zone
	plane = ABOVE_HUD_PLANE
	layer = 2
	alpha = 1
	mouse_opacity = MOUSE_OPACITY_ICON
	mouse_over_pointer = MOUSE_HAND_POINTER
	del_on_map_removal = FALSE
	var/datum/enterprise_room/room

/atom/movable/screen/enterprise_zone/Destroy()
	room = null
	return ..()

/atom/movable/screen/enterprise_zone/MouseEntered(location, control, params)
	if(room)
		room.enterprise.hover_room(usr, room)

/atom/movable/screen/enterprise_zone/MouseExited(location, control, params)
	if(room)
		room.enterprise.unhover_room(usr, room)

/atom/movable/screen/enterprise_zone/Click(location, control, params)
	if(room)
		room.enterprise.open_room_menu(usr, room)

/atom/movable/screen/enterprise_zone/MouseWheel(delta_x, delta_y, location, control, params)
	if(room && delta_y)
		room.enterprise.wheel_floor(usr, delta_y > 0 ? 1 : -1)

/atom/movable/screen/enterprise_highlight
	plane = ABOVE_HUD_PLANE
	layer = 1.5
	alpha = 70
	color = "#ffd9a0"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE

/atom/movable/screen/enterprise_menu_button
	icon = 'modular_rmh/icons/enterprises/menu.dmi'
	icon_state = "button"
	plane = ABOVE_HUD_PLANE
	layer = 3
	alpha = ENTERPRISE_MENU_ALPHA_IDLE
	maptext_width = ENTERPRISE_MENU_BUTTON_WIDTH
	maptext_height = ENTERPRISE_MENU_BUTTON_HEIGHT
	maptext_y = 6
	mouse_over_pointer = MOUSE_HAND_POINTER
	del_on_map_removal = FALSE
	var/action
	var/datum/enterprise_viewer/viewer

/atom/movable/screen/enterprise_menu_button/Destroy()
	viewer = null
	return ..()

/atom/movable/screen/enterprise_menu_button/MouseEntered(location, control, params)
	alpha = ENTERPRISE_MENU_ALPHA_HOVER

/atom/movable/screen/enterprise_menu_button/MouseExited(location, control, params)
	alpha = ENTERPRISE_MENU_ALPHA_IDLE

/atom/movable/screen/enterprise_menu_button/Click(location, control, params)
	if(viewer && viewer.user == usr)
		viewer.choose(action)

/datum/enterprise_viewer
	var/datum/enterprise/enterprise
	var/mob/user
	var/client/viewing
	var/z
	var/datum/enterprise_room/hovered
	var/datum/enterprise_room/menu_room
	var/datum/enterprise_room/highlighted
	var/atom/movable/screen/enterprise_highlight/highlight
	var/list/atom/movable/screen/enterprise_menu_button/buttons = list()

/datum/enterprise_viewer/New(datum/enterprise/enterprise, mob/user)
	src.enterprise = enterprise
	src.user = user
	viewing = user.client
	highlight = new
	highlight.assigned_map = enterprise.map_key

/datum/enterprise_viewer/Destroy()
	QDEL_NULL(highlight)
	QDEL_LIST(buttons)
	enterprise = null
	user = null
	viewing = null
	hovered = null
	menu_room = null
	highlighted = null
	return ..()

/datum/enterprise_viewer/proc/add_to_screen(list/atom/movable/screen/shown)
	if(!viewing)
		return
	for(var/atom/movable/screen/screen_obj as anything in shown)
		viewing.register_map_obj(screen_obj)

/datum/enterprise_viewer/proc/remove_from_screen(list/atom/movable/screen/hidden)
	if(!viewing || !length(hidden))
		return
	viewing.screen -= hidden
	var/list/on_map = viewing.screen_maps[enterprise.map_key]
	if(on_map)
		on_map -= hidden

/datum/enterprise_viewer/proc/set_hovered(datum/enterprise_room/room)
	hovered = room
	update_highlight()

/datum/enterprise_viewer/proc/update_highlight()
	var/datum/enterprise_room/lit = hovered || menu_room
	if(lit == highlighted)
		return
	highlighted = lit
	highlight.overlays.Cut()
	var/datum/enterprise_floor/floor = lit ? enterprise.get_floor(lit.z) : null
	if(!floor || !length(lit.shape))
		return
	highlight.set_position(floor.get_screen_x(), floor.get_screen_y())
	highlight.overlays += lit.shape

/datum/enterprise_viewer/proc/close_menu()
	if(length(buttons))
		remove_from_screen(buttons)
		QDEL_LIST(buttons)
	menu_room = null
	update_highlight()

/datum/enterprise_viewer/proc/open_menu(datum/enterprise_room/room)
	close_menu()
	var/datum/enterprise_floor/floor = enterprise.get_floor(room.z)
	if(!floor || !length(room.turfs))
		return
	menu_room = room
	update_highlight()
	var/repair_cost = room.get_repair_cost()
	var/list/actions = list(ENTERPRISE_ROOM_ACTION_UPGRADE)
	if(repair_cost)
		actions += ENTERPRISE_ROOM_ACTION_REPAIR
	actions += ENTERPRISE_ROOM_ACTION_INFO

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
	var/screen_x = floor.get_screen_x() + round((room_min_x + room_max_x) / 2) - floor.min_x
	var/screen_y = floor.get_screen_y() + round((room_min_y + room_max_y) / 2) - floor.min_y
	screen_x = clamp(screen_x, 3, enterprise.frame_width - 2)
	screen_y = clamp(screen_y, 2, enterprise.frame_height - 1)
	var/offset_x = -(ENTERPRISE_MENU_BUTTON_WIDTH - ICON_SIZE_X) / 2
	var/offset_y = round((length(actions) - 1) * ENTERPRISE_MENU_BUTTON_STEP / 2) + (ICON_SIZE_Y - ENTERPRISE_MENU_BUTTON_HEIGHT) / 2
	var/russian = get_preferred_ui_language(user) == "ru"
	for(var/action in actions)
		var/atom/movable/screen/enterprise_menu_button/button = new
		button.assigned_map = enterprise.map_key
		button.action = action
		button.viewer = src
		button.maptext = MAPTEXT_CENTER(enterprise.get_room_action_label(action, russian, repair_cost))
		button.set_position(screen_x, screen_y, offset_x, offset_y)
		offset_y -= ENTERPRISE_MENU_BUTTON_STEP
		buttons += button
	add_to_screen(buttons)

/datum/enterprise_viewer/proc/choose(action)
	var/datum/enterprise_room/room = menu_room
	close_menu()
	if(room)
		enterprise.room_action(user, room, action)

/datum/enterprise
	var/map_key
	var/atom/movable/screen/background/enterprise_map/map_backdrop
	var/atom/movable/screen/enterprise_map_catcher/map_catcher
	var/list/atom/movable/screen/plane_master/map_plane_masters
	var/frame_min_x = 1
	var/frame_min_y = 1
	var/frame_pad_x = 0
	var/frame_pad_y = 0
	var/frame_width = ENTERPRISE_MAP_MIN_WIDTH
	var/frame_height = ENTERPRISE_MAP_MIN_HEIGHT
	var/list/datum/enterprise_viewer/viewers = list()

/datum/enterprise/proc/get_room_action_label(action, russian, repair_cost)
	switch(action)
		if(ENTERPRISE_ROOM_ACTION_UPGRADE)
			return russian ? "Улучшить" : "Upgrade"
		if(ENTERPRISE_ROOM_ACTION_REPAIR)
			return russian ? "Починить: [repair_cost]" : "Repair: [repair_cost]"
		if(ENTERPRISE_ROOM_ACTION_INFO)
			return russian ? "Сведения" : "Info"
	return action

/datum/enterprise/proc/build_map()
	var/static/maps_made = 0
	maps_made++
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
	frame_width = max(width, ENTERPRISE_MAP_MIN_WIDTH)
	frame_height = max(height, ENTERPRISE_MAP_MIN_HEIGHT)
	frame_min_x = min_x
	frame_min_y = min_y
	frame_pad_x = round((frame_width - width) / 2)
	frame_pad_y = round((frame_height - height) / 2)
	map_backdrop.fill_rect(1, 1, frame_width, frame_height)
	map_catcher.fill_rect(1, 1, frame_width, frame_height)

/datum/enterprise/proc/get_viewer(mob/user)
	return user ? viewers[REF(user)] : null

/datum/enterprise/proc/show_floor(mob/user, z)
	var/datum/enterprise_floor/floor = get_floor(z)
	if(!user?.client || !floor || !map_key || !is_owner(user))
		return FALSE
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer?.z == z)
		return FALSE
	if(viewer)
		viewer.hovered = null
		viewer.close_menu()
		var/datum/enterprise_floor/shown = get_floor(viewer.z)
		if(shown)
			viewer.remove_from_screen(shown.picture)
			viewer.remove_from_screen(shown.zones)
	else
		viewer = new(src, user)
		viewers[REF(user)] = viewer
		viewer.add_to_screen(list(map_backdrop, map_catcher, viewer.highlight))
		viewer.add_to_screen(map_plane_masters)
	viewer.add_to_screen(floor.picture)
	viewer.add_to_screen(floor.zones)
	viewer.z = z
	return TRUE

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

/datum/enterprise/proc/step_floor(mob/user, direction)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(!viewer)
		return FALSE
	var/next_z = get_next_floor_z(viewer.z, direction)
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
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(!viewer)
		return
	viewers -= REF(user)
	if(viewer.viewing)
		viewer.viewing.clear_map(map_key)
	qdel(viewer)

/datum/enterprise/proc/reshow_floors()
	for(var/viewer_key in viewers.Copy())
		var/datum/enterprise_viewer/viewer = viewers[viewer_key]
		var/mob/user = viewer.user
		var/z = viewer.z
		hide_floors(user)
		if(user?.client && !show_floor(user, z))
			open_premises(user)

/datum/enterprise/proc/hover_room(mob/user, datum/enterprise_room/room)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && (!room || room.z == viewer.z))
		viewer.set_hovered(room)

/datum/enterprise/proc/unhover_room(mob/user, datum/enterprise_room/room)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && viewer.hovered == room)
		viewer.set_hovered(null)

/datum/enterprise/proc/open_room_menu(mob/user, datum/enterprise_room/room)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && room.z == viewer.z && is_owner(user))
		viewer.open_menu(room)

/datum/enterprise/proc/close_room_menu(mob/user)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer)
		viewer.close_menu()

#undef ENTERPRISE_MAP_MIN_WIDTH
#undef ENTERPRISE_MAP_MIN_HEIGHT
#undef ENTERPRISE_MENU_BUTTON_WIDTH
#undef ENTERPRISE_MENU_BUTTON_HEIGHT
#undef ENTERPRISE_MENU_BUTTON_STEP
#undef ENTERPRISE_MENU_ALPHA_IDLE
#undef ENTERPRISE_MENU_ALPHA_HOVER
