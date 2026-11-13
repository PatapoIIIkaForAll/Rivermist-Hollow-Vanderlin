/atom/movable/screen/buildmode
	icon = 'icons/misc/buildmode.dmi'
	// If we don't do this, we get occluded by item action buttons
	plane = ABOVE_HUD_PLANE
	var/datum/buildmode/bd

/atom/movable/screen/buildmode/Initialize(mapload, datum/hud/hud_owner, datum/buildmode/build_datum)
	. = ..()
	bd = build_datum

/atom/movable/screen/buildmode/Destroy()
	bd = null
	return ..()

/atom/movable/screen/buildmode/Click(location, control, params)
	// A stale button can still be clicked after its buildmode datum is gone.
	if(QDELETED(bd) || usr?.client != bd.holder)
		return TRUE
	buildmode_click(params2list(params))
	return TRUE

/atom/movable/screen/buildmode/proc/buildmode_click(list/modifiers)
	return

/atom/movable/screen/buildmode/mode
	name = "Toggle Mode"
	icon_state = "buildmode_basic"
	screen_loc = "NORTH,WEST"

/atom/movable/screen/buildmode/mode/buildmode_click(list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		bd.mode.change_settings(bd.holder)
		return
	bd.toggle_modeswitch()

/atom/movable/screen/buildmode/mode/update_icon_state()
	if(bd?.mode)
		icon_state = bd.mode.get_button_iconstate()
	return ..()

/atom/movable/screen/buildmode/mode/update_name(updates)
	if(bd?.mode)
		name = "Mode: [bd.mode.name] (right click for settings)"
	return ..()

/atom/movable/screen/buildmode/help
	name = "Buildmode Help"
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"

/atom/movable/screen/buildmode/help/buildmode_click(list/modifiers)
	bd.mode.show_help(bd.holder)

/atom/movable/screen/buildmode/bdir
	name = "Change Dir"
	icon_state = "build"
	screen_loc = "NORTH,WEST+2"

/atom/movable/screen/buildmode/bdir/buildmode_click(list/modifiers)
	bd.toggle_dirswitch()

/atom/movable/screen/buildmode/bdir/update_icon_state()
	if(bd)
		setDir(bd.build_dir)
	return ..()

/atom/movable/screen/buildmode/quit
	name = "Quit Buildmode"
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"

/atom/movable/screen/buildmode/quit/buildmode_click(list/modifiers)
	bd.quit()

/atom/movable/screen/buildmode/items
	name = "Item Browser"
	icon_state = "builditems"
	screen_loc = "NORTH,WEST+4"

/atom/movable/screen/buildmode/items/buildmode_click(list/modifiers)
	bd.item_browser.toggle()

/atom/movable/screen/buildmode/modeswitch
	var/datum/buildmode_mode/modetype

/atom/movable/screen/buildmode/modeswitch/Initialize(mapload, datum/hud/hud_owner, datum/buildmode/build_datum, mode_type)
	. = ..()
	modetype = mode_type
	var/datum/buildmode_mode/mode_path = mode_type
	icon_state = "buildmode_[initial(mode_path.key)]"
	name = initial(mode_path.name)

/atom/movable/screen/buildmode/modeswitch/buildmode_click(list/modifiers)
	bd.change_mode(modetype)

/atom/movable/screen/buildmode/dirswitch
	icon_state = "build"
	var/dir_type

/atom/movable/screen/buildmode/dirswitch/Initialize(mapload, datum/hud/hud_owner, datum/buildmode/build_datum, new_dir)
	. = ..()
	dir_type = new_dir
	setDir(new_dir)
	name = dir2text(new_dir)

/atom/movable/screen/buildmode/dirswitch/buildmode_click(list/modifiers)
	bd.change_dir(dir_type)

/// Invisible map-wide catcher shown while Shift is held; reports the cursor pixel.
/atom/movable/screen/buildmode/pixel_catcher
	name = "pixel placement"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "WEST,SOUTH to EAST,NORTH"

/atom/movable/screen/buildmode/pixel_catcher/MouseMove(location, control, params)
	if(QDELETED(bd) || usr?.client != bd.holder)
		return
	bd.track_cursor(params2list(params))

/atom/movable/screen/buildmode/pixel_catcher/buildmode_click(list/modifiers)
	bd.catcher_click(modifiers)
