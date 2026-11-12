#define ENTERPRISE_MAP_MIN_WIDTH 20
#define ENTERPRISE_MAP_MIN_HEIGHT 15
#define ENTERPRISE_MENU_BUTTON_WIDTH 320
#define ENTERPRISE_MENU_BUTTON_HEIGHT 60
#define ENTERPRISE_MENU_BUTTON_STEP 66
#define ENTERPRISE_MENU_ALPHA_IDLE 170
#define ENTERPRISE_MENU_ALPHA_HOVER 255
#define ENTERPRISE_MENU_TEXT(text) {"<span style='font-family: "Pixelify Sans"; font-size: 18pt; color: #f0e2c4; text-align: center; vertical-align: middle; -dm-text-outline: 1px black'>[##text]</span>"}

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
		enterprise.zoom_view(usr, delta_y > 0 ? 1 : -1, params)

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

/atom/movable/screen/enterprise_highlight
	plane = ABOVE_HUD_PLANE
	layer = 1.5
	alpha = 70
	color = "#ffd9a0"
	appearance_flags = PIXEL_SCALE
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
	if(viewer && viewer.get_user() == usr)
		viewer.choose(action)

/datum/enterprise_viewer
	var/datum/enterprise/enterprise
	var/datum/weakref/user_ref
	var/client/viewing
	var/z
	var/scale = 1
	var/shift_x = 0
	var/shift_y = 0
	var/datum/enterprise_room/hovered
	var/datum/enterprise_room/menu_room
	var/datum/enterprise_room/highlighted
	var/atom/movable/screen/enterprise_viewport/viewport
	var/atom/movable/screen/enterprise_highlight/highlight
	var/list/atom/movable/screen/enterprise_menu_button/buttons = list()

/datum/enterprise_viewer/New(datum/enterprise/enterprise, mob/user)
	src.enterprise = enterprise
	user_ref = WEAKREF(user)
	viewing = user.client
	viewport = new
	viewport.assigned_map = enterprise.map_key
	viewport.set_position(1, 1)
	highlight = new

/datum/enterprise_viewer/Destroy()
	QDEL_NULL(viewport)
	QDEL_NULL(highlight)
	QDEL_LIST(buttons)
	enterprise = null
	user_ref = null
	viewing = null
	hovered = null
	menu_room = null
	highlighted = null
	return ..()

/datum/enterprise_viewer/proc/get_user()
	var/mob/user = user_ref?.resolve()
	return QDELETED(user) ? null : user

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

/datum/enterprise_viewer/proc/show(datum/enterprise_floor/floor)
	hovered = null
	close_menu()
	viewport.vis_contents.Cut()
	viewport.vis_contents += floor.picture
	viewport.vis_contents += floor.zones
	viewport.vis_contents += highlight
	z = floor.z

/datum/enterprise_viewer/proc/set_view(new_scale, new_shift_x, new_shift_y)
	close_menu()
	scale = new_scale
	var/reach_x = enterprise.frame_width * ICON_SIZE_X * (1 - 1 / scale) / 2
	var/reach_y = enterprise.frame_height * ICON_SIZE_Y * (1 - 1 / scale) / 2
	shift_x = clamp(new_shift_x, -reach_x, reach_x)
	shift_y = clamp(new_shift_y, -reach_y, reach_y)
	viewport.transform = matrix(1, 0, shift_x, 0, 1, shift_y)

/datum/enterprise_viewer/proc/get_cursor(params)
	var/screen_loc = params2list(params)["screen-loc"]
	if(!screen_loc)
		return null
	var/list/axes = splittext(screen_loc, ",")
	if(length(axes) != 2)
		return null
	var/list/x_parts = splittext(axes[1], ":")
	var/list/y_parts = splittext(axes[2], ":")
	var/x_count = length(x_parts)
	if(x_count < 2 || length(y_parts) < 2)
		return null
	var/tile_x = text2num(x_parts[x_count - 1])
	var/pixel_x = text2num(x_parts[x_count])
	var/tile_y = text2num(y_parts[1])
	var/pixel_y = text2num(y_parts[2])
	if(isnull(tile_x) || isnull(pixel_x) || isnull(tile_y) || isnull(pixel_y))
		return null
	return list((tile_x - 1) * ICON_SIZE_X + pixel_x, (tile_y - 1) * ICON_SIZE_Y + pixel_y)

/datum/enterprise_viewer/proc/zoom(direction, params)
	var/static/list/scales = list(1, 1.5, 2, 3, 4)
	var/new_scale = scales[clamp(scales.Find(scale) + direction, 1, length(scales))]
	if(new_scale == scale)
		return FALSE
	var/centre_x = enterprise.frame_width * ICON_SIZE_X / 2
	var/centre_y = enterprise.frame_height * ICON_SIZE_Y / 2
	var/list/cursor = get_cursor(params)
	var/cursor_x = cursor ? cursor[1] : centre_x
	var/cursor_y = cursor ? cursor[2] : centre_y
	var/ratio = scale / new_scale
	set_view(new_scale, shift_x + centre_x + (cursor_x - centre_x) * ratio - cursor_x, shift_y + centre_y + (cursor_y - centre_y) * ratio - cursor_y)
	return TRUE

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
	if(!floor)
		return
	highlight.pixel_x = floor.get_pixel_x()
	highlight.pixel_y = floor.get_pixel_y()
	for(var/datum/enterprise_room/member as anything in lit.get_members())
		if(member.z == floor.z && member.outline)
			highlight.overlays += member.outline

/datum/enterprise_viewer/proc/close_menu()
	if(length(buttons))
		remove_from_screen(buttons)
		QDEL_LIST(buttons)
	menu_room = null
	update_highlight()

/datum/enterprise_viewer/proc/open_menu(datum/enterprise_room/room)
	close_menu()
	enterprise.check_rooms(room.get_members())
	if(QDELETED(src))
		return
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
	var/centre_x = floor.get_pixel_x() + ((room_min_x + room_max_x) / 2 - floor.min_x + 0.5) * ICON_SIZE_X + shift_x
	var/centre_y = floor.get_pixel_y() + ((room_min_y + room_max_y) / 2 - floor.min_y + 0.5) * ICON_SIZE_Y + shift_y
	var/half_width = ENTERPRISE_MENU_BUTTON_WIDTH / 2 / scale
	var/half_stack = ((length(actions) - 1) * ENTERPRISE_MENU_BUTTON_STEP + ENTERPRISE_MENU_BUTTON_HEIGHT) / 2 / scale
	var/frame_x = enterprise.frame_width * ICON_SIZE_X / 2
	var/frame_y = enterprise.frame_height * ICON_SIZE_Y / 2
	centre_x = clamp(centre_x, frame_x - frame_x / scale + half_width, frame_x + frame_x / scale - half_width)
	centre_y = clamp(centre_y, frame_y - frame_y / scale + half_stack, frame_y + frame_y / scale - half_stack)
	var/russian = get_preferred_ui_language(get_user()) == "ru"
	var/matrix/shrink = scale == 1 ? null : matrix(1 / scale, 0, 0, 0, 1 / scale, 0)
	var/button_y = centre_y + half_stack - ENTERPRISE_MENU_BUTTON_HEIGHT / 2 / scale
	for(var/action in actions)
		var/atom/movable/screen/enterprise_menu_button/button = new
		button.assigned_map = enterprise.map_key
		button.action = action
		button.viewer = src
		button.maptext = ENTERPRISE_MENU_TEXT(enterprise.get_room_action_label(action, russian, repair_cost))
		var/left = round(centre_x - ENTERPRISE_MENU_BUTTON_WIDTH / 2)
		var/bottom = round(button_y - ENTERPRISE_MENU_BUTTON_HEIGHT / 2)
		var/tile_x = round(left / ICON_SIZE_X)
		var/tile_y = round(bottom / ICON_SIZE_Y)
		button.set_position(1 + tile_x, 1 + tile_y, left - tile_x * ICON_SIZE_X, bottom - tile_y * ICON_SIZE_Y)
		if(shrink)
			button.transform = shrink
		button_y -= ENTERPRISE_MENU_BUTTON_STEP / scale
		buttons += button
	add_to_screen(buttons)

/datum/enterprise_viewer/proc/choose(action)
	var/datum/enterprise_room/room = menu_room
	close_menu()
	var/mob/user = get_user()
	if(!room || !user || !enterprise.can_run_rooms(user))
		return
	if(action != ENTERPRISE_ROOM_ACTION_REPAIR || enterprise.press(user, action))
		enterprise.room_action(user, room, action)

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
	if(viewer && can_run_rooms(user) && viewer.zoom(direction, params))
		SStgui.update_user_uis(user, src)

/datum/enterprise/proc/reset_view(mob/user)
	var/datum/enterprise_viewer/viewer = get_viewer(user)
	if(viewer)
		viewer.set_view(1, 0, 0)

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
	if(viewer && room.z == viewer.z && can_run_rooms(user))
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
#undef ENTERPRISE_MENU_TEXT
