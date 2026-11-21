// Standing toys: a finished toy set upright on the floor or on furniture, ready to be ridden.

/// Empty sprite rows under every toy's foot in dildo.dmi and plug.dmi.
#define TOY_SPRITE_LIFT 3
/// Pixels above the tile bottom where a toy's foot rests on bare floor.
#define TOY_FLOOR_HEIGHT 8
#define TOY_SETUP_TIME (1.5 SECONDS)
/// Two toys may share a tile, side by side, so someone can ride both.
#define TOY_MAX_PER_TILE 2
#define TOY_SIDE_SHIFT 2
/// How long after a ride the toy still reads as warm and wet.
#define TOY_FRESH_TIME (3 MINUTES)
#define TOY_KNOCK_OVER_CHANCE 50

/obj/structure
	/// Pixels above the tile bottom where a standing toy's foot rests; null means no toy stands here.
	var/toy_mount_height
	/// Surface word for riding lines: chair, stool, bench, bed or table.
	var/toy_surface_kind

/obj/structure/table
	toy_mount_height = 14
	toy_surface_kind = "table"

/obj/structure/chair
	toy_mount_height = 11
	toy_surface_kind = "chair"

/obj/structure/chair/stool
	toy_mount_height = 15
	toy_surface_kind = "stool"

/obj/structure/chair/bench
	toy_mount_height = 8
	toy_surface_kind = "bench"

/obj/structure/bed
	toy_mount_height = 13
	toy_surface_kind = "bed"

/obj/structure/bed/sleepingbag
	toy_mount_height = 9

/// The furniture on [target_turf] a toy would stand on, best first: table, bed, then seats; null is the floor.
/proc/get_toy_mount_surface(turf/target_turf)
	var/obj/structure/best
	var/best_rank = 0
	for(var/obj/structure/structure in target_turf)
		if(isnull(structure.toy_mount_height))
			continue
		var/rank = istype(structure, /obj/structure/table) ? 3 : (istype(structure, /obj/structure/bed) ? 2 : 1)
		if(rank > best_rank)
			best = structure
			best_rank = rank
	return best

/// Every toy standing upright on [target_turf].
/proc/get_standing_toys(turf/target_turf)
	. = list()
	for(var/obj/item/dildo/toy in target_turf)
		if(toy.get_toy_mount())
			. += toy

/// A toy standing on this mob's tile that nobody else is riding; [exclude] skips one already taken.
/mob/living/proc/get_free_standing_toy(obj/item/dildo/exclude)
	RETURN_TYPE(/obj/item/dildo)
	for(var/obj/item/dildo/toy as anything in get_standing_toys(get_turf(src)))
		if(toy == exclude)
			continue
		var/datum/component/toy_mount/mount = toy.get_toy_mount()
		if(mount.rider && mount.rider != src)
			continue
		return toy
	return null

/// A standing toy within arm's reach, this mob's own tile first.
/mob/living/proc/get_reachable_standing_toy()
	RETURN_TYPE(/obj/item/dildo)
	var/list/toys = get_standing_toys(get_turf(src))
	if(!length(toys))
		for(var/turf/near in orange(1, src))
			toys += get_standing_toys(near)
	return length(toys) ? toys[1] : null

// ---- The toy ----

/obj/item/dildo
	/// World time the last ride on this toy ended.
	var/last_ridden = 0
	/// TRUE while the toy stands on a surface; it then shows its straight sprite.
	var/standing_sprite = FALSE

/obj/item/dildo/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(on_secondary_interact))

/obj/item/dildo/proc/get_toy_icon_state()
	return "dildo_[dildo_type]_[dildo_size][standing_sprite ? "_stand" : ""]"

/// Swaps between the leaning item sprite and the straight standing sprite.
/obj/item/dildo/proc/set_standing_sprite(standing)
	standing_sprite = standing
	icon_state = get_toy_icon_state()

// Plugs have one sprite for both.
/obj/item/dildo/plug/set_standing_sprite(standing)
	standing_sprite = standing

/obj/item/dildo/proc/get_toy_mount()
	RETURN_TYPE(/datum/component/toy_mount)
	return GetComponent(/datum/component/toy_mount)

/// TRUE for a finished toy with a flat foot to stand on.
/obj/item/dildo/proc/can_stand_upright()
	return !can_custom

// A tail tuft hangs under the foot, so these plugs fall over.
/obj/item/dildo/plug/tail/can_stand_upright()
	return FALSE

/obj/item/dildo/plug/bunny/can_stand_upright()
	return FALSE

/// The word for where this toy stands, as "the floor" or "the chair".
/obj/item/dildo/proc/get_stand_place()
	var/obj/structure/surface = get_toy_mount()?.get_surface()
	return surface ? "\the [surface]" : "the floor"

/// Right-click a floor or a piece of furniture with the toy in hand to stand it up there.
/obj/item/dildo/proc/on_secondary_interact(datum/source, mob/living/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(user.cmode || !can_stand_upright() || user.get_active_held_item() != src)
		return NONE
	var/obj/structure/furniture = target
	if(!isturf(target) && !(istype(furniture) && !isnull(furniture.toy_mount_height)))
		return NONE
	var/turf/target_turf = get_turf(target)
	if(!target_turf || get_dist(user, target_turf) > 1)
		return NONE
	var/reason = get_stand_block_reason(target_turf)
	if(reason)
		to_chat(user, span_warning(reason))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(stand_up_on), user, target_turf)
	return ITEM_INTERACT_SUCCESS

/// Why the toy cannot stand on [target_turf], or null when it can.
/obj/item/dildo/proc/get_stand_block_reason(turf/target_turf)
	if(!isopenturf(target_turf) || istype(target_turf, /turf/open/water) || istype(target_turf, /turf/open/openspace) || istype(target_turf, /turf/open/lava))
		return "It will not stand up there."
	if(length(get_standing_toys(target_turf)) >= TOY_MAX_PER_TILE)
		return "There is no room for another toy there."
	if(get_toy_mount_surface(target_turf))
		return null
	for(var/atom/movable/blocker in target_turf)
		if(blocker.density && !ismob(blocker))
			return "\The [blocker] is in the way."
	return null

/obj/item/dildo/proc/stand_up_on(mob/living/user, turf/target_turf)
	if(!do_after(user, TOY_SETUP_TIME, target_turf))
		return FALSE
	if(QDELETED(src) || user.get_active_held_item() != src || get_dist(user, target_turf) > 1)
		return FALSE
	var/reason = get_stand_block_reason(target_turf)
	if(reason)
		to_chat(user, span_warning(reason))
		return FALSE
	var/obj/structure/surface = get_toy_mount_surface(target_turf)
	if(!user.transferItemToLoc(src, target_turf))
		return FALSE
	AddComponent(/datum/component/toy_mount, surface)
	var/where = surface ? "\the [surface]" : "the floor"
	user.visible_message(span_notice("[user] plants \the [src] upright on [where], pressing its foot down until it stands on its own."), span_notice("I plant \the [src] upright on [where]. It stands proud and ready."))
	if(prob(33))
		user.visible_message(span_love("[user] gives it a testing wobble."))
	playsound(target_turf, 'sound/foley/dropsound/gen_drop.ogg', 30, TRUE, -2)
	return TRUE

/obj/item/dildo/examine(mob/user)
	. = ..()
	if(lube_reagents?.total_volume)
		var/list/names = list()
		for(var/datum/reagent/reagent as anything in lube_reagents.reagent_list)
			names += LOWER_TEXT(reagent.name)
		. += span_love("It glistens with [english_list(names)].")
	if(last_ridden && world.time < last_ridden + TOY_FRESH_TIME)
		. += span_love("It is still warm and wet from use.")

/// A lube container used on a standing toy slicks it, the same as on a held one.
/obj/item/dildo/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.cmode || !get_toy_mount() || get_container_lubricity(tool) <= 0)
		return ..()
	user.lube_up_toy(src)
	return ITEM_INTERACT_SUCCESS

// ---- The stand ----

/datum/component/toy_mount
	/// Furniture the toy stands on; null is the bare floor.
	var/datum/weakref/surface_ref
	var/turf/mount_turf
	/// Whoever sits on the toy right now, riding or stuck on it.
	var/mob/living/rider
	/// Horizontal shift when two toys share a tile.
	var/side_shift = 0
	/// TRUE while a ride seats its own rider, so the empty-seat prank stays quiet.
	var/seating_rider = FALSE

/datum/component/toy_mount/Initialize(obj/structure/surface)
	if(!istype(parent, /obj/item/dildo))
		return COMPONENT_INCOMPATIBLE
	mount_turf = get_turf(parent)
	if(!mount_turf)
		return COMPONENT_INCOMPATIBLE
	if(surface)
		surface_ref = WEAKREF(surface)
	for(var/obj/item/dildo/other as anything in get_standing_toys(mount_turf))
		if(other == parent)
			continue
		var/datum/component/toy_mount/other_mount = other.get_toy_mount()
		other_mount.side_shift = -TOY_SIDE_SHIFT
		other_mount.update_position()
		side_shift = TOY_SIDE_SHIFT
	update_position()

/datum/component/toy_mount/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_toy_moved))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_toy_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_toy_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mount_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_turf_entered))
	var/obj/structure/surface = get_surface()
	if(surface)
		RegisterSignals(surface, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), PROC_REF(on_surface_lost))
		RegisterSignal(surface, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_surface_prebuckle))
	var/obj/item/dildo/toy = parent
	toy.set_standing_sprite(TRUE)

/datum/component/toy_mount/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_HAND_SECONDARY, COMSIG_PARENT_EXAMINE))
	if(mount_turf)
		UnregisterSignal(mount_turf, COMSIG_ATOM_ENTERED)
	var/obj/structure/surface = get_surface()
	if(surface)
		UnregisterSignal(surface, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_PREBUCKLE))
	var/obj/item/dildo/toy = parent
	toy.pixel_x = toy.base_pixel_x
	toy.pixel_y = toy.base_pixel_y
	toy.layer = initial(toy.layer)
	toy.set_standing_sprite(FALSE)

/datum/component/toy_mount/Destroy(force)
	set_rider(null)
	. = ..()
	surface_ref = null
	mount_turf = null

/datum/component/toy_mount/proc/get_surface()
	RETURN_TYPE(/obj/structure)
	var/obj/structure/surface = surface_ref?.resolve()
	return QDELETED(surface) ? null : surface

/// Surface word for riding lines: floor, chair, stool, bench, bed or table.
/datum/component/toy_mount/proc/get_surface_kind()
	return get_surface()?.toy_surface_kind || "floor"

/// Stands the toy on the surface; the scale transform pulls the foot toward the icon centre, hence the lift sum.
/datum/component/toy_mount/proc/update_position()
	var/obj/item/dildo/toy = parent
	var/obj/structure/surface = get_surface()
	var/height = surface ? surface.toy_mount_height : TOY_FLOOR_HEIGHT
	var/scale = toy.dropshrink || 1
	var/foot = 16 + (TOY_SPRITE_LIFT - 16) * scale
	toy.pixel_x = toy.base_pixel_x + side_shift
	toy.pixel_y = toy.base_pixel_y + round(height - foot)
	toy.layer = ABOVE_OBJ_LAYER

/datum/component/toy_mount/proc/set_rider(mob/living/new_rider)
	if(rider == new_rider)
		return
	if(rider)
		UnregisterSignal(rider, COMSIG_PARENT_QDELETING)
	rider = new_rider
	if(rider)
		RegisterSignal(rider, COMSIG_PARENT_QDELETING, PROC_REF(on_rider_deleted))

/datum/component/toy_mount/proc/on_rider_deleted(datum/source)
	SIGNAL_HANDLER
	set_rider(null)

/datum/component/toy_mount/proc/on_toy_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	qdel(src)

/// Nobody plucks a toy out from under the one sitting on it.
/datum/component/toy_mount/proc/on_toy_attack_hand(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(!rider)
		return NONE
	to_chat(user, span_warning("[rider == user ? "I am" : "[rider] is"] sitting on it."))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Right-click with an empty hand: slick the standing toy with a held lube or with spit.
/datum/component/toy_mount/proc/on_toy_attack_hand_secondary(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(user) || user.cmode)
		return NONE
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living, lube_up_toy), parent)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/toy_mount/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/obj/item/dildo/toy = parent
	examine_list += span_notice("It stands upright on [toy.get_stand_place()].")
	if(rider)
		examine_list += span_love("[rider] is sitting on it.")

/datum/component/toy_mount/proc/on_surface_lost(datum/source)
	SIGNAL_HANDLER
	var/obj/item/dildo/toy = parent
	var/obj/structure/surface = source
	toy.visible_message(span_notice("\The [toy] topples off \the [surface] and rolls away."))
	qdel(src)
	toy.pixel_x = toy.base_pixel_x + rand(-6, 6)
	toy.pixel_y = toy.base_pixel_y + rand(-6, 0)

/// A runner who blunders onto the tile kicks a floor toy over.
/datum/component/toy_mount/proc/on_turf_entered(datum/source, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	if(!isliving(arrived) || arrived == rider || arrived.throwing || get_surface())
		return
	var/mob/living/runner = arrived
	if(runner.m_intent != MOVE_INTENT_RUN || runner.body_position == LYING_DOWN || !prob(TOY_KNOCK_OVER_CHANCE))
		return
	var/obj/item/dildo/toy = parent
	runner.visible_message(span_notice("[runner] stumbles into \the [toy] and knocks it over."), span_notice("I stumble into \the [toy] and knock it flat."))
	playsound(mount_turf, 'sound/foley/dropsound/gen_drop.ogg', 40, TRUE, -2)
	qdel(src)
	toy.pixel_x = toy.base_pixel_x + rand(-6, 6)
	toy.pixel_y = toy.base_pixel_y + rand(-6, 0)

/// Someone sitting or lying down on furniture with a toy standing on it gets a fright instead.
/datum/component/toy_mount/proc/on_surface_prebuckle(datum/source, mob/living/sitter, force, buckle_mob_flags)
	SIGNAL_HANDLER
	if(seating_rider || !ishuman(sitter) || sitter == rider)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(seat_prank), sitter)
	return COMPONENT_BLOCK_BUCKLE

/datum/component/toy_mount/proc/seat_prank(mob/living/carbon/human/sitter)
	var/obj/item/dildo/toy = parent
	var/obj/structure/surface = get_surface()
	if(!surface || QDELETED(sitter))
		return
	var/obj/item/garment = sitter.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN) || get_covering_soft_garment(sitter, BODY_ZONE_PRECISE_GROIN)
	if(istype(surface, /obj/structure/bed))
		sitter.visible_message(span_love("[sitter] goes to lie down on \the [surface] and finds \the [toy] standing in it, right where [sitter.p_their()] hips would go."), span_love("I almost lie down right on \the [toy]! Someone left it standing in the bed."))
	else if(garment)
		sitter.visible_message(span_love("[sitter] sits down on \the [surface] and shoots right back up, \the [toy] poking into [sitter.p_their()] [garment.name]!"), span_love("Something hard is standing on this seat! It pokes right into me through my [garment.name]."))
	else
		sitter.visible_message(span_love("[sitter] starts to sit on \the [surface] and leaps up with a squeal; \the [toy] was standing right there!"), span_love("I nearly sit straight down on \the [toy]! It brushes right against me."))
		SEND_SIGNAL(sitter, COMSIG_SEX_ADJUST_AROUSAL, 3)
	sitter.emote("gasp", forced = TRUE)

#undef TOY_SPRITE_LIFT
#undef TOY_FLOOR_HEIGHT
#undef TOY_SETUP_TIME
#undef TOY_MAX_PER_TILE
#undef TOY_SIDE_SHIFT
#undef TOY_FRESH_TIME
#undef TOY_KNOCK_OVER_CHANCE
