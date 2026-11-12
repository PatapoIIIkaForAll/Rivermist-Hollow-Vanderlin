#define ENTERPRISE_MENU_BUTTON_WIDTH 320
#define ENTERPRISE_MENU_BUTTON_HEIGHT 60
#define ENTERPRISE_MENU_BUTTON_STEP 66
#define ENTERPRISE_MENU_ALPHA_IDLE 170
#define ENTERPRISE_MENU_ALPHA_HOVER 255
#define ENTERPRISE_MENU_TEXT(text) {"<span style='font-family: "Pixelify Sans"; font-size: 18pt; color: #f0e2c4; text-align: center; vertical-align: middle; -dm-text-outline: 1px black'>[##text]</span>"}
#define ENTERPRISE_LABEL_TEXT(text, size, outline) {"<span style='font-family: "Pixelify Sans"; font-size: [size]pt; color: #f0e2c4; text-align: center; vertical-align: middle; -dm-text-outline: [outline]px black'>[##text]</span>"}
#define ENTERPRISE_LABEL_POINTS 7
#define ENTERPRISE_DRAG_THRESHOLD 4
#define ENTERPRISE_DRAG_CLICK_GRACE 2
#define ENTERPRISE_FIT_MAX 16

/atom/movable/screen/enterprise_menu_button
	icon = 'modular_rmh/icons/enterprises/menu.dmi'
	icon_state = "button"
	plane = ABOVE_HUD_PLANE
	layer = 3
	alpha = ENTERPRISE_MENU_ALPHA_IDLE
	maptext_width = ENTERPRISE_MENU_BUTTON_WIDTH
	maptext_height = ENTERPRISE_MENU_BUTTON_HEIGHT
	mouse_over_pointer = MOUSE_HAND_POINTER
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	blockscharging = TRUE
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
	if(viewer && viewer.get_user() == usr && !viewer.just_dragged())
		viewer.choose(action)

/atom/movable/screen/enterprise_menu_button/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	viewer?.enterprise?.drag_view(usr, params)

/atom/movable/screen/enterprise_label
	icon = 'modular_rmh/icons/enterprises/zone.dmi'
	icon_state = "blank"
	plane = RUNECHAT_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE
	var/label_text
	var/label_width = 0

/atom/movable/screen/enterprise_label/proc/place(text, centre_x, centre_y, width)
	label_text = text
	label_width = width
	pixel_x = round(centre_x - ICON_SIZE_X / 2)
	pixel_y = round(centre_y - ICON_SIZE_Y / 2)
	dress(1)

/atom/movable/screen/enterprise_label/proc/dress(scale)
	var/width = round(label_width * scale)
	var/height = round(ICON_SIZE_Y * scale)
	maptext = ENTERPRISE_LABEL_TEXT(label_text, ENTERPRISE_LABEL_POINTS * scale, max(round(scale), 1))
	maptext_width = width
	maptext_height = height
	maptext_x = round((ICON_SIZE_X - width) / 2)
	maptext_y = round((ICON_SIZE_Y - height) / 2)
	transform = scale == 1 ? null : matrix(1 / scale, 0, 0, 0, 1 / scale, 0)

/datum/enterprise_viewer
	var/datum/enterprise/enterprise
	var/datum/weakref/user_ref
	var/client/viewing
	var/z
	var/scale = 1
	var/fit
	var/shift_x = 0
	var/shift_y = 0
	var/list/drag_from
	var/list/drag_shift
	var/dragging = FALSE
	var/drag_ended = -ENTERPRISE_DRAG_CLICK_GRACE - 1
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
	if(viewing)
		RegisterSignal(viewing, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_mouse_down))
		RegisterSignal(viewing, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_mouse_up))

/datum/enterprise_viewer/Destroy()
	UnregisterSignal(viewing, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP))
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
	viewport.vis_contents += floor.labels
	z = floor.z
	dress_labels()

/datum/enterprise_viewer/proc/dress_labels()
	var/datum/enterprise_floor/floor = enterprise.get_floor(z)
	if(!floor)
		return
	for(var/atom/movable/screen/enterprise_label/label as anything in floor.labels)
		label.dress(scale)

/datum/enterprise_viewer/proc/set_view(new_scale, new_shift_x, new_shift_y)
	close_menu()
	var/rescaled = new_scale != scale
	scale = new_scale
	var/reach_x = enterprise.frame_width * ICON_SIZE_X * (1 - 1 / scale) / 2
	var/reach_y = enterprise.frame_height * ICON_SIZE_Y * (1 - 1 / scale) / 2
	shift_x = clamp(new_shift_x, -reach_x, reach_x)
	shift_y = clamp(new_shift_y, -reach_y, reach_y)
	viewport.transform = matrix(1, 0, shift_x, 0, 1, shift_y)
	if(rescaled)
		dress_labels()
		apply_zoom()

/datum/enterprise_viewer/proc/set_fit(new_fit)
	fit = clamp(new_fit, 0, ENTERPRISE_FIT_MAX)
	apply_zoom()

/datum/enterprise_viewer/proc/apply_zoom()
	if(!viewing)
		return
	if(scale <= 1 || !fit)
		winset(viewing, enterprise.map_key, "zoom=0;zoom-mode=normal")
		return
	winset(viewing, enterprise.map_key, "zoom=[fit * scale];zoom-mode=distort")

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

/datum/enterprise_viewer/proc/drag(params)
	var/list/cursor = get_cursor(params)
	if(!cursor)
		return
	if(!drag_from)
		drag_from = cursor
		drag_shift = list(shift_x, shift_y)
		return
	var/delta_x = cursor[1] - drag_from[1]
	var/delta_y = cursor[2] - drag_from[2]
	if(!dragging)
		if(abs(delta_x) + abs(delta_y) < ENTERPRISE_DRAG_THRESHOLD)
			return
		dragging = TRUE
	set_view(scale, drag_shift[1] + delta_x, drag_shift[2] + delta_y)

/datum/enterprise_viewer/proc/just_dragged()
	return dragging || world.time - drag_ended <= ENTERPRISE_DRAG_CLICK_GRACE

/datum/enterprise_viewer/proc/on_mouse_down(client/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	drag_from = null
	drag_shift = null
	dragging = FALSE

/datum/enterprise_viewer/proc/on_mouse_up(client/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	if(dragging)
		drag_ended = world.time
	drag_from = null
	drag_shift = null
	dragging = FALSE

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
	var/factor = menu_factor()
	var/half_width = ENTERPRISE_MENU_BUTTON_WIDTH / 2 / factor
	var/half_stack = ((length(actions) - 1) * ENTERPRISE_MENU_BUTTON_STEP + ENTERPRISE_MENU_BUTTON_HEIGHT) / 2 / factor
	var/frame_x = enterprise.frame_width * ICON_SIZE_X / 2
	var/frame_y = enterprise.frame_height * ICON_SIZE_Y / 2
	centre_x = clamp(centre_x, frame_x - frame_x / scale + half_width, frame_x + frame_x / scale - half_width)
	centre_y = clamp(centre_y, frame_y - frame_y / scale + half_stack, frame_y + frame_y / scale - half_stack)
	var/russian = get_preferred_ui_language(get_user()) == "ru"
	var/matrix/shrink = factor == 1 ? null : matrix(1 / factor, 0, 0, 0, 1 / factor, 0)
	var/button_y = centre_y + half_stack - ENTERPRISE_MENU_BUTTON_HEIGHT / 2 / factor
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
		button_y -= ENTERPRISE_MENU_BUTTON_STEP / factor
		buttons += button
	add_to_screen(buttons)

/datum/enterprise_viewer/proc/menu_factor()
	return scale * (fit > 0 ? fit : 1)

/datum/enterprise_viewer/proc/choose(action)
	var/datum/enterprise_room/room = menu_room
	close_menu()
	var/mob/user = get_user()
	if(!room || !user || !enterprise.can_run_rooms(user))
		return
	if(action != ENTERPRISE_ROOM_ACTION_REPAIR || enterprise.press(user, action))
		enterprise.room_action(user, room, action)

#undef ENTERPRISE_MENU_BUTTON_WIDTH
#undef ENTERPRISE_MENU_BUTTON_HEIGHT
#undef ENTERPRISE_MENU_BUTTON_STEP
#undef ENTERPRISE_MENU_ALPHA_IDLE
#undef ENTERPRISE_MENU_ALPHA_HOVER
#undef ENTERPRISE_MENU_TEXT
#undef ENTERPRISE_LABEL_TEXT
#undef ENTERPRISE_LABEL_POINTS
#undef ENTERPRISE_DRAG_THRESHOLD
#undef ENTERPRISE_DRAG_CLICK_GRACE
#undef ENTERPRISE_FIT_MAX
