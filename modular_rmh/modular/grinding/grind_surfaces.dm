// Things a crotch can grind against: their kind, the words for them, and the hazards that are refused.

/// Pixels from the tile bottom to a standing human's crotch.
#define GRIND_CROTCH_PIXELS 15
/// A table edge this many pixels above the crotch makes a short grinder clamber up.
#define GRIND_CLIMB_MARGIN 1

/// Kind of thing: table, seat, bed, pillow, barrel, rail, wall, door, tree, statue, soft, toy, floor or thing.
/proc/get_grind_kind(atom/thing)
	if(isclosedturf(thing))
		return "wall"
	if(isopenturf(thing))
		return "floor"
	if(is_pillow(thing))
		return "pillow"
	if(istype(thing, /obj/structure/table))
		return "table"
	if(istype(thing, /obj/structure/chair) || istype(thing, /obj/structure/throne))
		return "seat"
	if(istype(thing, /obj/structure/bed))
		return "bed"
	if(istype(thing, /obj/structure/fermentation_keg) || findtext(thing.name, "barrel"))
		return "barrel"
	if(istype(thing, /obj/structure/fluff/railing) || istype(thing, /obj/structure/bars))
		return "rail"
	if(istype(thing, /obj/structure/door))
		return "door"
	if(istype(thing, /obj/structure/flora/tree) || istype(thing, /obj/structure/flora/newtree))
		return "tree"
	if(istype(thing, /obj/structure/statue) || istype(thing, /obj/structure/fluff/statue))
		return "statue"
	if(istype(thing, /obj/item/dildo))
		var/obj/item/dildo/toy = thing
		if(toy.get_toy_mount())
			return "toy"
	if(is_soft_grind_item(thing))
		return "soft"
	return "thing"

/// Cloth, sheets, hides and cloth garments.
/proc/is_soft_grind_item(atom/thing)
	if(istype(thing, /obj/item/clothing))
		var/obj/item/clothing/garment = thing
		return garment.can_soak_fluid()
	return istype(thing, /obj/item/natural/cloth) || istype(thing, /obj/item/bedsheet) || istype(thing, /obj/item/natural/hide)

/// "soft" for cushioned things, "rough" for bark and stone, or null.
/proc/get_grind_surface_feel(atom/thing)
	switch(get_grind_kind(thing))
		if("soft", "pillow", "bed")
			return "soft"
		if("tree", "wall", "statue")
			return "rough"
	return null

/// Why grinding on [thing] would hurt, as a refusal line, or null when it is safe.
/proc/get_grind_hazard(atom/thing)
	var/static/sharp = "Not against that, unless I want to lose something."
	var/static/hot = "Too hot for that."
	var/static/unsafe = "That's no place to grind."
	if(isturf(thing))
		if(istype(thing, /turf/open/lava))
			return hot
		if(istype(thing, /turf/open/openspace))
			return unsafe
		if(istype(thing, /turf/open/water))
			var/turf/open/water/water = thing
			if(water.water_height >= WATER_HEIGHT_DEEP)
				return unsafe
		return null
	if(!isobj(thing))
		return unsafe
	var/obj/object = thing
	if(object.resistance_flags & ON_FIRE)
		return hot
	if(isitem(thing))
		var/obj/item/item = thing
		if(item.get_temperature() > 0)
			return hot
		if(item.get_sharpness() || istype(item, /obj/item/weapon) || istype(item, /obj/item/ammo_casing))
			return sharp
		if(istype(item, /obj/item/restraints/legcuffs/beartrap) || istype(item, /obj/item/natural/glass/shard))
			return sharp
		return null
	if(istype(thing, /obj/machinery/light/fueled))
		var/obj/machinery/light/fueled/fire = thing
		return fire.on ? hot : null
	if(istype(thing, /obj/structure/trap) || istype(thing, /obj/structure/flora/grass/thorn_bush))
		return sharp
	if(istype(thing, /obj/structure/meatvine))
		return unsafe
	return null

/// What a grind on [thing] presses against: "the corner of the table".
/mob/living/proc/get_grind_thing_spot(atom/thing)
	var/held = (thing in held_items)
	switch(get_grind_kind(thing))
		if("table")
			return "the corner of \the [thing]"
		if("seat")
			return "the seat of \the [thing]"
		if("bed")
			return body_position == LYING_DOWN ? "\the [thing]" : "the edge of \the [thing]"
		if("barrel")
			return "the curve of \the [thing]"
		if("door")
			return "the frame of \the [thing]"
		if("tree")
			return "the trunk of \the [thing]"
		if("soft")
			return held ? "\the [thing]" : "the bunched-up [thing.name]"
		if("floor")
			return "the floor"
	return "\the [thing]"

/// How the grinder settles on [thing]: "straddle", "climb", "lie", "thighs" or null for a plain press.
/mob/living/proc/get_grind_thing_pose(atom/thing)
	if(body_position == LYING_DOWN)
		return "lie"
	switch(get_grind_kind(thing))
		if("seat", "barrel", "bed", "pillow")
			return "straddle"
		if("soft")
			return "thighs"
		if("table")
			var/obj/structure/table/table = thing
			var/crotch = GRIND_CROTCH_PIXELS * get_grind_body_height()
			return table.toy_mount_height > crotch + GRIND_CLIMB_MARGIN ? "climb" : null
	return null

/// Why this mob cannot grind on [thing] now, or null when it can.
/mob/living/proc/get_grind_thing_refusal(atom/thing)
	if(thing == src)
		return "I can't grind against myself."
	if(isliving(thing))
		return get_grind_refusal(thing, zone_selected)
	var/held = (thing in held_items)
	if(!held)
		if(ismovable(thing) && !isturf(thing.loc))
			return thing.loc == src ? "I'd have to take it off first." : "I can't get at it."
		if(get_turf(thing) != get_turf(src) && !Adjacent(thing))
			return "It's too far away."
	var/hazard = get_grind_hazard(thing)
	if(hazard)
		return hazard
	if(get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, src))
		return "My armor is in the way."
	var/obj/seat = get_grind_seat()
	if(seat && thing != seat)
		return "I can't grind on that sitting down."
	var/kind = get_grind_kind(thing)
	if(kind == "floor" && body_position != LYING_DOWN)
		return "I'd have to lie down for that."
	if(kind == "toy" && get_turf(thing) != get_turf(src))
		return "I have to stand over it."
	if(body_position == LYING_DOWN && !held && !(kind in list("floor", "bed", "pillow", "soft")) && get_turf(thing) != get_turf(src))
		return "I can't reach it lying down."
	return null

/// TRUE for kinds the panel may pick by itself; pillows, toys and seats have their own panel actions.
/proc/is_auto_grind_kind(kind)
	var/static/list/kinds = list("table", "seat", "bed", "barrel", "rail", "door", "tree", "statue", "wall", "soft")
	return kind in kinds

/// The thing the panel grinds on: soft cloth in hand, then what the mob faces, its own tile, the tiles around.
/mob/living/proc/find_grind_thing()
	for(var/obj/item/held in held_items)
		if(get_grind_kind(held) == "soft" && !get_grind_thing_refusal(held))
			return held
	var/turf/here = get_turf(src)
	if(!here)
		return null
	var/list/places = list()
	if(body_position != LYING_DOWN)
		places += get_step(here, dir)
	places += here
	if(body_position != LYING_DOWN)
		for(var/turf/near in orange(1, here))
			places |= near
	var/obj/seat = get_grind_seat()
	for(var/turf/place as anything in places)
		if(!place)
			continue
		if(isclosedturf(place))
			if(!get_grind_thing_refusal(place))
				return place
			continue
		for(var/obj/thing in place)
			if(thing == seat || !is_auto_grind_kind(get_grind_kind(thing)))
				continue
			if(!get_grind_thing_refusal(thing))
				return thing
	// Lying with nothing better, the floor itself will do.
	if(body_position == LYING_DOWN && !get_grind_thing_refusal(here))
		return here
	return null

#undef GRIND_CROTCH_PIXELS
#undef GRIND_CLIMB_MARGIN
