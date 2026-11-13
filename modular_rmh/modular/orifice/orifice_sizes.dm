// Girths of the things that go in: toys, plugs, beads, eggs and held mobs.

/obj/item/dildo/get_insert_girth()
	switch(dildo_size)
		if("small")
			return 8
		if("big", "huge")
			return 14
	return 11

/// Plug heads pass the opening; the neck is what stays in it.
/obj/item/dildo/plug/get_insert_girth()
	switch(dildo_size)
		if("small")
			return 7
		if("big")
			return 13
		if("huge")
			return 16
	return 10

/obj/item/dildo/plug/get_held_open_girth()
	switch(dildo_size)
		if("small")
			return 4
		if("big")
			return 8
		if("huge")
			return 10
	return 6

/// Circumference of one anal bead by size.
/proc/get_bead_girth(size)
	switch(size)
		if(BEAD_SMALL)
			return 5
		if(BEAD_LARGE)
			return 10
		if(BEAD_GIANT)
			return 13
	return 7

/// The widest bead inside, or the tip before any goes in.
/obj/item/anal_beads/get_insert_girth()
	if(!shape)
		return ..()
	return get_bead_girth(get_bead(get_widest_bead_index(1, max(beads_inside, 1))))

/// The bead resting just inside the ring holds it open.
/obj/item/anal_beads/get_held_open_girth()
	if(!shape || beads_inside <= 0)
		return 0
	return get_bead_girth(get_bead(beads_inside))

/// The bead crossing the ring right now; a deleted string passes nothing.
/obj/item/anal_beads/get_pass_through_girth()
	if(QDELETED(src))
		return 0
	if(passing_bead)
		return get_bead_girth(get_bead(passing_bead))
	return get_insert_girth()

/obj/item/oviposition_egg/get_insert_girth()
	return min(18, 9 * get_egg_scale())

/obj/item/mob_holder/get_insert_girth()
	return MOB_HOLDER_GIRTH

/// A hatchling grows with its holder's bulk, never narrower than any held mob.
/obj/item/mob_holder/internal_womb/get_insert_girth()
	return max(MOB_HOLDER_GIRTH, body_storage_bulk * ORIFICE_GENERIC_GIRTH_PER_BULK)
