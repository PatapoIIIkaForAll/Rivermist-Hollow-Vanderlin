//Generic system for picking up mobs.
//Currently works for head and hands.
/obj/item/mob_holder
	name = "bugged mob"
	desc = ""
	icon = null
	icon_state = ""
	grid_width = 64
	grid_height = 96
	sellprice = 20

	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = INDESTRUCTIBLE
	smeltresult = /obj/item/fertilizer/ash

	var/mob/living/held_mob
	var/can_head = TRUE
	var/destroying = FALSE
	var/obj/item/bodypart/organ_stored
	/// Set while a release is running or sleeping, so repeated resist/move input can't stack releases.
	var/releasing = FALSE
	/// Last turf this holder actually stood on. Body storage pulls a removed item out of contents
	/// before the caller relocates it, so a holder can sit in nullspace for a tick; without this
	/// there is nowhere to put the occupant if it is released or deleted during that window.
	var/turf/last_known_turf
	/// Body storage organ we are registered in. We hang off the body rather than sitting inside the
	/// organ (organs live in nullspace), so loc can't be used to answer "am I stored?".
	var/obj/item/organ/hole_storage_organ

/obj/item/mob_holder/dropped(mob/user)
	. = ..()
	if(isturf(loc) || isnull(loc))
		qdel(src)

// Storage calls dropped() while the holder is still inside the bag, so the turf check there never
// fires on this path. Without this, dragging a holder from a bag onto the floor left it lying there
// as an item with a mob still inside it.
/obj/item/mob_holder/on_exit_storage(datum/component/storage/concrete/S)
	. = ..()
	if(isturf(loc))
		qdel(src)

/obj/item/mob_holder/Initialize(mapload, mob/living/M)
	. = ..()
	if(M && !deposit(M))
		return INITIALIZE_HINT_QDEL

/obj/item/mob_holder/update_appearance(updates)
	. = ..()
	update_visuals(held_mob)

/obj/item/mob_holder/Destroy()
	destroying = TRUE
	if(held_mob)
		release_sleepless(FALSE)
	clear_organ_storage()
	hole_storage_organ = null
	return ..()

/obj/item/mob_holder/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	var/turf/current_turf = get_turf(src)
	if(current_turf)
		last_known_turf = current_turf

/// Where the occupant goes when it leaves. Never returns nullspace - a mob dumped there is
/// unrecoverable and trips the ambience subsystem's "ended up in nullspace" stack trace.
/obj/item/mob_holder/proc/find_release_destination()
	return get_turf(src) || get_turf(organ_stored?.owner) || last_known_turf

// The held mob can leave through paths this object doesn't drive: teleports, gibbing, or another
// holder depositing it. Dropping the reference here is what stops a stale holder from keeping the
// mob's name and appearance after it is gone.
/obj/item/mob_holder/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == held_mob)
		held_mob = null

/obj/item/mob_holder/proc/deposit(mob/living/L)
	if(!istype(L) || QDELETED(L))
		return FALSE
	if(held_mob)
		return FALSE
	// A mob already inside another holder has to be released from that one first. Moving it out
	// from under an occupied holder leaves that holder still claiming it, which is what produced
	// duplicate "held mob" items in hands and bags.
	if(ismobholder(L.loc))
		return FALSE
	L.setDir(SOUTH)
	if(!L.forceMove(src))
		return FALSE
	held_mob = L
	update_visuals(L)
	sellprice = L.sellprice
	name = L.name
	desc = L.desc
	item_weight = L.carry_weight + L.get_mob_weight()

	if(length(L.stored_enchantments))
		for(var/datum/enchantment/enchant as anything in L.stored_enchantments)
			enchant(enchant)
	return TRUE

/obj/item/mob_holder/enchant(datum/enchantment/path)
	if(..() && held_mob)
		// Has to be idempotent: deposit() replays this list back through enchant(), so a plain
		// append grows stored_enchantments by its own length on every pickup.
		LAZYOR(held_mob.stored_enchantments, path)


/obj/item/mob_holder/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(!held_mob)
		return ..()
	I.attack(held_mob, user, user.zone_selected)

/// The occupant is still a person, so opening the interaction menu on them goes through the same
/// scene the rest of the sex system uses - including its consent gate - rather than a side door.
/obj/item/mob_holder/attack_self(mob/living/user, list/modifiers)
	if(!isliving(user) || QDELETED(held_mob))
		return ..()
	if(!held_mob.client && !held_mob.mind)
		return ..()
	user.open_sex_scene(held_mob)
	return TRUE

/obj/item/mob_holder/proc/update_visuals(mob/living/L)
	if(!L)
		return
	appearance = L.appearance
	plane = ABOVE_HUD_PLANE

// An occupied holder hangs off the storage owner's body instead of going inside the organ, so the
// passenger keeps a resolvable turf. The organ is remembered rather than read off loc.
/obj/item/mob_holder/body_storage_destination(obj/item/organ/storage_organ, mob/living/storage_owner)
	if(held_mob && storage_owner)
		return storage_owner
	return ..()

/obj/item/mob_holder/on_body_storage_entered(obj/item/organ/storage_organ, target_layer)
	. = ..()
	hole_storage_organ = storage_organ

/obj/item/mob_holder/on_body_storage_exited(obj/item/organ/storage_organ)
	. = ..()
	hole_storage_organ = null

/obj/item/mob_holder/proc/get_storage_organ()
	if(!QDELETED(hole_storage_organ))
		return hole_storage_organ
	if(istype(loc, /obj/item/organ))
		return loc
	return null

/obj/item/mob_holder/proc/is_inside_storage_organ()
	return !isnull(get_storage_organ())

/obj/item/mob_holder/proc/is_in_hole_storage()
	var/obj/item/organ/storage_organ = get_storage_organ()
	if(!storage_organ)
		return FALSE

	return !!SEND_SIGNAL(storage_organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, src)

/// Whether the occupant is allowed to fight its own way out of a body cavity. True for an ordinary
/// scooped-up mob; the womb variant keeps its own gate so a hatchling can't crawl out early.
/obj/item/mob_holder/proc/can_release_from_hole_storage()
	return TRUE

/obj/item/mob_holder/proc/remove_from_hole_storage()
	var/obj/item/organ/storage_organ = get_storage_organ()
	if(!storage_organ || !is_in_hole_storage())
		return FALSE

	return SEND_SIGNAL(storage_organ, COMSIG_BODYSTORAGE_TRY_REMOVE, src, null, BODYSTORAGE_REMOVE_INTERNAL)

/// The occupant struggling out of a body cavity under its own power - what resist and movement do
/// while stored, since release() alone refuses to open a hole from the inside.
/obj/item/mob_holder/proc/struggle_out_of_hole_storage(mob/living/user)
	if(releasing)
		return FALSE
	if(!can_release_from_hole_storage())
		to_chat(user, span_warning("I'm sealed in. There's no way out from in here!"))
		return FALSE

	var/atom/squeezed_out_of = loc
	var/obj/item/organ/storage_organ = get_storage_organ()
	to_chat(user, span_warning("I start squirming my way out of [storage_organ || squeezed_out_of]..."))
	releasing = TRUE
	// Movement input is what triggers this, so a dir change must not cancel it, and the carrier is
	// free to walk around while the occupant works itself loose.
	var/struggled_free = do_after(user, 5 SECONDS, squeezed_out_of, IGNORE_USER_DIR_CHANGE|IGNORE_HELD_ITEM|IGNORE_TARGET_LOC_CHANGE)
	releasing = FALSE
	if(!struggled_free)
		return FALSE
	// Five seconds is long enough to have been pulled out, moved, or swallowed by something else.
	if(QDELETED(src) || held_mob != user || loc != squeezed_out_of)
		return FALSE
	if(!remove_from_hole_storage())
		to_chat(user, span_warning("I can't work myself loose!"))
		return FALSE
	return release()

/obj/item/mob_holder/proc/clear_organ_storage()
	if(!organ_stored)
		return
	LAZYREMOVE(organ_stored.cavity_items, src)
	organ_stored = null

/// Release that can sleep, for tearing out through an unopened body cavity.
/obj/item/mob_holder/proc/release(del_on_release = TRUE)
	if(releasing)
		return FALSE
	if(QDELETED(held_mob))
		return release_sleepless(del_on_release)
	if(!destroying && is_inside_storage_organ())
		return FALSE

	if(organ_stored && !organ_stored.get_incision())
		var/mob/living/clawing_out = held_mob
		var/obj/item/bodypart/cut_through = organ_stored
		releasing = TRUE
		var/clawed_free = do_after(clawing_out, 15 SECONDS, loc)
		releasing = FALSE
		if(!clawed_free)
			return FALSE
		// Fifteen seconds is long enough for the holder, the mob, or the limb to have changed hands.
		if(QDELETED(src) || held_mob != clawing_out || organ_stored != cut_through)
			return FALSE
		cut_through.owner?.emote("scream")
		cut_through.take_damage(40)

	return release_sleepless(del_on_release)

/// Release that never sleeps. Every release path ends here.
/obj/item/mob_holder/proc/release_sleepless(del_on_release = TRUE)
	// Destroy() has to be able to force past an in-flight release, or the mob stays inside a
	// deleted holder and hard-deletes along with it.
	if(releasing && !destroying)
		return FALSE
	// Covers both an empty holder and one whose occupant was deleted out from under it (sold,
	// gibbed, admin-deleted); forceMove would CRASH on the latter.
	var/mob/living/released = held_mob
	if(QDELETED(released))
		held_mob = null
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE

	var/turf/destination = find_release_destination()
	// Refusing to release beats stranding the occupant in nullspace. Destroy() has no such luxury:
	// staying inside a deleted holder would take the mob with it, so it falls through and shouts.
	if(!destination && !destroying)
		return FALSE

	releasing = TRUE
	var/obj/item/bodypart/burst_through = organ_stored
	var/atom/carrier = loc

	if(isliving(carrier))
		var/mob/living/holding_mob = carrier
		if(burst_through)
			to_chat(holding_mob, span_danger("[released] bursts from your [burst_through]!"))
		else
			to_chat(holding_mob, span_warning("[released] wriggles free!"))

	// Free the mob before unequipping ourselves. dropped() qdels this holder once it reaches a
	// turf, which re-enters Destroy -> release_sleepless; clearing held_mob first makes that pass
	// a no-op instead of running a second half-release.
	if(destination)
		released.forceMove(destination)
	else
		stack_trace("mob_holder deleted with no reachable turf; [released] had to be nullspaced")
		released.moveToNullspace()
	held_mob = null
	released.reset_perspective()
	released.setDir(SOUTH)
	if(burst_through)
		released.visible_message(span_danger("[released] bursts out of [carrier]'s [burst_through]!"))
	else
		released.visible_message(span_warning("[released] uncurls!"))

	clear_organ_storage()
	releasing = FALSE

	if(!destroying && isliving(loc))
		var/mob/living/holding_mob = loc
		holding_mob.dropItemToGround(src)
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE

/obj/item/mob_holder/relaymove(mob/living/user, direction)
	if(user != held_mob)
		return FALSE
	if(is_inside_storage_organ())
		return struggle_out_of_hole_storage(user)
	return release()

/obj/item/mob_holder/container_resist(mob/living/user)
	if(user != held_mob)
		return FALSE
	if(is_inside_storage_organ())
		return struggle_out_of_hole_storage(user)
	return release()

/obj/item/mob_holder/internal_womb
	name = "womb-held hatchling"
	desc = "Something alive is being held inside."
	slot_flags = NONE
	can_head = FALSE
	body_storage_bulk = 2
	body_storage_manual_removal = FALSE
	body_storage_random_removal = FALSE
	var/allow_internal_release = FALSE

/obj/item/mob_holder/internal_womb/Destroy()
	allow_internal_release = TRUE
	remove_from_hole_storage()
	return ..()

/obj/item/mob_holder/internal_womb/proc/set_internal_bulk(new_bulk)
	body_storage_bulk = max(1, round(new_bulk))
	return body_storage_bulk

/obj/item/mob_holder/internal_womb/can_release_from_hole_storage()
	return allow_internal_release

/obj/item/mob_holder/internal_womb/release(del_on_release = TRUE)
	if(is_inside_storage_organ())
		if(!allow_internal_release)
			return FALSE
		if(is_in_hole_storage() && !remove_from_hole_storage())
			return FALSE
		if(is_inside_storage_organ())
			return FALSE
	return ..()

/obj/item/mob_holder/internal_womb/relaymove(mob/living/user, direction)
	if(allow_internal_release)
		return ..()
	return FALSE

/obj/item/mob_holder/internal_womb/container_resist(mob/living/user)
	if(allow_internal_release)
		return ..()
	// A hatchling that cannot get out still squirms, and its host feels it.
	var/datum/component/internal_womb_hatchling/hatchling = GetComponent(/datum/component/internal_womb_hatchling)
	hatchling?.on_struggle(user)
	return FALSE
