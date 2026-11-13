/// Keyhole button right of the heart; opens the holes window and lights up on hover like the heart.
/atom/movable/screen/hole_status_button
	name = "holes"
	desc = "Look inward at the state of your holes."
	icon = 'modular_rmh/icons/hud/hole_status_hud.dmi'
	icon_state = "holes"
	screen_loc = rogueui_holes
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/atom/movable/screen/hole_status_button/Click(location, control, params)
	var/mob/living/carbon/human/user = hud?.mymob
	if(user != usr || !user.client)
		return
	user.playsound_local(user, 'sound/misc/click.ogg', 100)
	user.view_holes()

/atom/movable/screen/hole_status_button/MouseEntered(location, control, params)
	. = ..()
	icon_state = "holes_hover"

/atom/movable/screen/hole_status_button/MouseExited(location, control, params)
	. = ..()
	icon_state = "holes"
