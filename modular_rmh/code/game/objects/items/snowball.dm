/obj/item/natural/snowball
	name = "snowball"
	desc = "A tightly packed ball of snow."
	icon = 'modular_rmh/icons/obj/items/snowball.dmi'
	icon_state = "snowball"
	dropshrink = 0
	force = 0
	throwforce = 0
	throw_speed = 2
	w_class = WEIGHT_CLASS_TINY

/obj/item/natural/snowball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.) // Caught snowballs remain intact.
		return
	playsound(get_turf(src), 'sound/foley/footsteps/ftsnow4.ogg', 50, TRUE)
	qdel(src)
