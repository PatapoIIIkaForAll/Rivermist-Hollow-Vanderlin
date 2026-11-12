#define ENTERPRISE_MAP_MIN_WIDTH 20
#define ENTERPRISE_MAP_MIN_HEIGHT 15

/atom/movable/screen/enterprise_map_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = ABOVE_HUD_PLANE
	layer = 1
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	blockscharging = TRUE
	del_on_map_removal = FALSE
	var/datum/enterprise/enterprise

/atom/movable/screen/enterprise_map_catcher/Destroy()
	enterprise = null
	return ..()

/atom/movable/screen/enterprise_map_catcher/MouseWheel(delta_x, delta_y, location, control, params)
	if(enterprise && delta_y)
		enterprise.zoom_view(usr, delta_y > 0 ? 1 : -1, params)

/atom/movable/screen/enterprise_map_catcher/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	enterprise?.drag_view(usr, params)

/atom/movable/screen/enterprise_map_catcher/Click(location, control, params)
	if(enterprise)
		enterprise.close_room_menu(usr)

/atom/movable/screen/enterprise_viewport
	icon = 'modular_rmh/icons/enterprises/zone.dmi'
	icon_state = "blank"
	plane = GAME_PLANE
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE

/atom/movable/screen/enterprise_zone
	plane = ABOVE_HUD_PLANE
	layer = 2
	alpha = 1
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_ICON
	mouse_over_pointer = MOUSE_HAND_POINTER
	blockscharging = TRUE
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
		room.enterprise.zoom_view(usr, delta_y > 0 ? 1 : -1, params)

/atom/movable/screen/enterprise_zone/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	room?.enterprise?.drag_view(usr, params)

/atom/movable/screen/enterprise_highlight
	plane = ABOVE_HUD_PLANE
	layer = 1.5
	alpha = 70
	color = "#ffd9a0"
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE

/datum/enterprise
	var/map_key
	var/atom/movable/screen/enterprise_map_catcher/map_catcher
	var/list/atom/movable/screen/plane_master/map_plane_masters
	var/list/atom/movable/screen/plane_master/shown_plane_masters = list()
	var/frame_min_x = 1
	var/frame_min_y = 1
	var/frame_pad_x = 0
	var/frame_pad_y = 0
	var/frame_width = ENTERPRISE_MAP_MIN_WIDTH
	var/frame_height = ENTERPRISE_MAP_MIN_HEIGHT
	var/list/datum/enterprise_viewer/viewers = list()
	var/list/map_fits = list()

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

/datum/enterprise/proc/shapes_picture(atom/movable/screen/plane_master/plane_master)
	if(plane_master.render_target || length(plane_master.filters) || plane_master.color || plane_master.alpha < 255)
		return TRUE
	return plane_master.blend_mode != BLEND_DEFAULT && plane_master.blend_mode != BLEND_OVERLAY

/datum/enterprise/proc/update_plane_masters()
	if(!map_key)
		return
	var/list/used = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor?.used_planes)
			used |= floor.used_planes
	var/list/atom/movable/screen/plane_master/wanted = list()
	for(var/atom/movable/screen/plane_master/plane_master as anything in map_plane_masters)
		if((plane_master.plane in used) && shapes_picture(plane_master))
			wanted += plane_master
	var/list/atom/movable/screen/plane_master/added = wanted - shown_plane_masters
	var/list/atom/movable/screen/plane_master/removed = shown_plane_masters - wanted
	if(!length(added) && !length(removed))
		return
	shown_plane_masters = wanted
	for(var/viewer_key in viewers)
		var/datum/enterprise_viewer/viewer = viewers[viewer_key]
		viewer.remove_from_screen(removed)
		viewer.add_to_screen(added)

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
	map_catcher.fill_rect(1, 1, frame_width, frame_height)

/datum/enterprise/proc/get_viewer(mob/user)
	RETURN_TYPE(/datum/enterprise_viewer)
	return user?.ckey ? viewers[user.ckey] : null

/datum/enterprise/proc/show_floor(mob/user, z)
	var/datum/enterprise_floor/floor = get_floor(z)
	if(!user?.client || !floor || !map_key || !is_owner(user))
		return FALSE
	check_rooms(floor.rooms)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer?.z == z)
		return FALSE
	floor.ensure_picture()
	if(!viewer)
		viewer = new(src, user)
		if(map_fits[user.ckey])
			viewer.set_fit(map_fits[user.ckey])
		viewers[user.ckey] = viewer
		viewer.add_to_screen(list(map_catcher, viewer.viewport))
		viewer.add_to_screen(shown_plane_masters)
	viewer.show(floor)
	return TRUE

/datum/enterprise/proc/open_premises(mob/user)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && get_floor(viewer.z))
		return FALSE
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

/datum/enterprise/proc/zoom_view(mob/user, direction, params)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && can_run_rooms(user))
		viewer.zoom(direction, params)

/datum/enterprise/proc/drag_view(mob/user, params)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && can_run_rooms(user))
		viewer.drag(params)

/datum/enterprise/proc/reset_view(mob/user)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(!viewer || (viewer.scale == 1 && !viewer.shift_x && !viewer.shift_y))
		return FALSE
	viewer.set_view(1, 0, 0)
	return TRUE

/datum/enterprise/proc/set_map_fit(mob/user, fit)
	if(!user?.ckey || !isnum(fit) || fit <= 0)
		return FALSE
	map_fits[user.ckey] = fit
	get_viewer(user)?.set_fit(fit)
	return TRUE

/datum/enterprise/proc/hide_floors(mob/user)
	drop_viewer(user?.ckey)

/datum/enterprise/proc/drop_viewer(viewer_key)
	var/datum/enterprise_viewer/viewer = viewer_key ? viewers[viewer_key] : null
	if(!viewer)
		return
	viewers -= viewer_key
	if(viewer.viewing)
		viewer.viewing.clear_map(map_key)
	qdel(viewer)

/datum/enterprise/proc/refresh_viewers()
	for(var/viewer_key in viewers.Copy())
		var/datum/enterprise_viewer/viewer = viewers[viewer_key]
		var/mob/user = viewer.get_user()
		if(!user?.client || user.client != viewer.viewing)
			drop_viewer(viewer_key)
			continue
		var/datum/enterprise_floor/floor = get_floor(viewer.z)
		if(!floor)
			drop_viewer(viewer_key)
			open_premises(user)
			continue
		floor.ensure_picture()
		viewer.show(floor)
		viewer.set_view(viewer.scale, viewer.shift_x, viewer.shift_y)

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
	if(viewer && room.z == viewer.z && can_run_rooms(user) && !viewer.just_dragged())
		viewer.open_menu(room)

/datum/enterprise/proc/close_room_menu(mob/user)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer && !viewer.just_dragged())
		viewer.close_menu()

#undef ENTERPRISE_MAP_MIN_WIDTH
#undef ENTERPRISE_MAP_MIN_HEIGHT
