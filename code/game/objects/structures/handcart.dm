/obj/structure/handcart
	name = "wooden handcart"
	desc = "A simple, reliable cart crafted from robust timber, offering modest storage space and serving as a practical means of transporting goods."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "cart-empty"
	density = TRUE
	max_integrity = 600
	anchored = FALSE
	climbable = TRUE
	attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg', 'sound/combat/hits/onwood/woodimpact (2).ogg')
	break_sound = 'sound/combat/hits/onwood/destroywalldoor.ogg'

	var/list/stuff_shit = list()

	var/current_capacity = 0
	var/maximum_capacity = 300 KILOGRAMS
	var/can_upgrade = TRUE
	var/cart_empty_state = "cart-empty"
	var/cart_full_state = "cart-full"

	var/obj/item/gear/wood/upgrade = null
	facepull = FALSE
	throw_range = 1
	drag_slowdown = 0.8 // weeping and gnashing of teeth

/obj/structure/handcart/bronze
	name = "bronze handcart"
	desc = "A spacious handcart crafted from bronze, offering ample storage but leaving no room for further upgrades."
	icon = 'icons/roguetown/misc/reinforcedhandcart.dmi'
	icon_state = "cart_bronze"
	cart_empty_state = "cart_bronze"
	cart_full_state = "cart_bronze_full"
	max_integrity = 800
	maximum_capacity = 800 KILOGRAMS
	can_upgrade = FALSE
	attacked_sound = list('sound/combat/hits/onmetal/metalimpact (2).ogg', 'sound/combat/hits/onmetal/metalimpact (1).ogg')
	break_sound = 'sound/combat/hits/onmetal/sheet (1).ogg'
	throw_range = 1

/obj/structure/handcart/iron
	name = "iron handcart"
	desc = "A sturdy handcart forged from durable iron, providing slightly more storage space than its wooden counterpart."
	icon = 'icons/roguetown/misc/reinforcedhandcart.dmi'
	icon_state = "cart_iron"
	cart_empty_state = "cart_iron"
	cart_full_state = "cart_iron_full"
	max_integrity = 1200
	maximum_capacity = 320 KILOGRAMS
	attacked_sound = list('sound/combat/hits/onmetal/metalimpact (2).ogg', 'sound/combat/hits/onmetal/metalimpact (1).ogg')
	break_sound = 'sound/combat/hits/onmetal/sheet (1).ogg'
	throw_range = 1

/obj/structure/handcart/steel
	name = "steel handcart"
	desc = "An exceptionally durable handcart crafted from steel, boasting greater storage capacity than the iron model."
	icon = 'icons/roguetown/misc/reinforcedhandcart.dmi'
	icon_state = "cart_steel"
	cart_empty_state = "cart_steel"
	cart_full_state = "cart_steel_full"
	max_integrity = 2000
	maximum_capacity = 350 KILOGRAMS
	attacked_sound = list('sound/combat/hits/onmetal/metalimpact (2).ogg', 'sound/combat/hits/onmetal/metalimpact (1).ogg')
	break_sound = 'sound/combat/hits/onmetal/sheet (1).ogg'
	throw_range = 1

/obj/structure/handcart/examine(mob/user)
	. = ..()
	if(upgrade)
		. += span_notice("This cart has \an [upgrade] installed.")

/obj/structure/handcart/Initialize(mapload)
	if(mapload)		// if closed, any item at the crate's loc is put in the contents
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/structure/handcart/container_resist(mob/living/user)
	var/atom/L = drop_location()
	for(var/atom/movable/AM in stuff_shit)
		if(AM == user)
			AM.forceMove(L)
			stuff_shit -= AM
			current_capacity = max(current_capacity - user.get_mob_weight() + user.carry_weight, 0)
			update_appearance(UPDATE_ICON)
			break

/obj/structure/handcart/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		if(AM == upgrade)
			continue
		AM.forceMove(L)
	stuff_shit = list()
	current_capacity = 0

/obj/structure/handcart/Destroy()
	dump_contents()
	QDEL_NULL(upgrade)
	return ..()

/obj/structure/handcart/MouseDrop_T(atom/movable/AM, mob/living/user)
	if(!istype(AM) || !isturf(AM.loc) || istype(AM, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated())
		return
	if(!Adjacent(user) || !user.Adjacent(AM))
		return
	if(user == AM) //try to climb into or onto it
		if(user.body_position == LYING_DOWN)
			if(!do_after(user, 2 SECONDS, src))
				return FALSE
			if(put_in(user, AM))
				playsound(src, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
			return TRUE
		return ..()

	if(isliving(AM))
		var/mob/living/L = AM
		// Require strong grab for living
		if(L.stat == CONSCIOUS && user.used_intent.type != /datum/intent/grab/move)
			return FALSE
		if(!do_after(user, 2 SECONDS, AM))
			return FALSE

	if(put_in(user, AM))
		playsound(src, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
	return TRUE

/obj/structure/handcart/attackby(obj/item/I, mob/user, list/modifiers)
	if(istype(I, /obj/item/gear/wood))
		if(!can_upgrade)
			to_chat(user, span_warning("[src] cannot be upgraded."))
			return
		var/obj/item/gear/wood/cog = I
		if(upgrade && cog.cart_capacity <= upgrade.cart_capacity)
			to_chat(user, span_warning("[src] already has a better upgrade installed!"))
			return
		if(!user.transferItemToLoc(cog, src))
			return
		QDEL_NULL(upgrade)
		upgrade = cog
		maximum_capacity = initial(maximum_capacity) + cog.cart_capacity
		playsound(src, pick('sound/combat/hits/onwood/fence_hit1.ogg', 'sound/combat/hits/onwood/fence_hit2.ogg', 'sound/combat/hits/onwood/fence_hit3.ogg'), 100, FALSE)
		shake_camera(user, 1, 1)
		to_chat(user, span_notice("I upgrade [src] with [cog]."))
		update_appearance(UPDATE_ICON)
		return
	if(!user.cmode)
		if(put_in(user, I))
			playsound(src, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
		return
	..()

/obj/structure/handcart/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.cmode)
		return
	var/turf/T = get_turf(user)
	if(isturf(T))
		user.changeNext_move(CLICK_CD_MELEE)

		//First, we do ores.
		var/list/ore_list = sieve_ores_and_gems(user, T)
		if(LAZYLEN(ore_list))
			for(var/obj/item/I as anything in ore_list)
				if(!interruptable_put(user, I))
					return
			return

		var/list/wood_list = sieve_wood(user, T)
		if(LAZYLEN(wood_list))
			for(var/obj/item/I as anything in wood_list)
				if(!interruptable_put(user, I))
					return
			return

		for(var/obj/item/I in T)
			if(!interruptable_put(user, I))
				return

/**
 * @brief This allows you to sieve through objects on a given turf and insert
 * them into the cart if they match the given type.
 *
 * @param user: The mob that clicked on the cart.
 * @param user_turf: The turf of the mob that clicked on this cart. This is checked by attack_hand, so
 * no need for much paranoia here.
 * @param types: Must be a list of type paths. Individually enforced for each item in the list.
 * This proc will partially succeed even if some of the typepaths in the typelist are bogus.
 *
 * @return sieved_items: A list containing the items on the user_turf that match any of the typepaths in types.
 */
/obj/structure/handcart/proc/item_sieve(mob/living/user, turf/user_turf, list/types)
	var/list/sieved_items

	for(var/obj/item/I in user_turf)
		for(var/typepath in types)
			//Make sure it's actually a path...
			if(!ispath(typepath))
				continue
			//Check the type of the object and insert if match.
			if(istype(I, typepath))
				LAZYADD(sieved_items, I)
				break //No duplicate insertions! (e.g. [/obj/item/ore, /obj/item/ore/ore_subtype])

	return sieved_items

/**
 * @brief This function provides a put operation that takes some time for the user to complete.
 * Used only in the "sieve" functions, which are used in the attack_hand proc.
 *
 * @param user: The mob that clicked on the cart.
 * @param O: The object you wish to insert.
 *
 * @return bool: FALSE if do_after or put_in fail, TRUE otherwise.
 */
/obj/structure/handcart/proc/interruptable_put(mob/living/user, atom/movable/AM)
	if(!do_after(user, 0.1 SECONDS, src))
		return FALSE
	if(!put_in(user, AM))
		return FALSE
	if(prob(30))
		playsound(src, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
	return TRUE

//Handles any object that's an ore or a gem (in the future, should change to raw gems if you add refinement steps)
/obj/structure/handcart/proc/sieve_ores_and_gems(mob/living/user, turf/user_turf)
	return item_sieve(user, user_turf, list(/obj/item/ore, /obj/item/gem))

//Handles logs (big, small), sticks. Big logs may run afoul of the cart's weight limits.
/obj/structure/handcart/proc/sieve_wood(mob/living/user, turf/user_turf)
	return item_sieve(user, user_turf, list(/obj/item/grown/log/tree, /obj/item/natural/bundle/stick))


/obj/structure/handcart/proc/put_in(mob/user, atom/movable/AM, forced = FALSE)
	if(!insertion_allowed(AM))
		return
	var/weight = NONE
	if(isitem(AM))
		var/obj/item/I = AM
		var/item_weight = I.get_carry_weight(user)
		if((current_capacity + item_weight) > maximum_capacity)
			return FALSE
		weight = item_weight
	if(isliving(AM))
		var/mob/living/mob = AM
		if((current_capacity + mob.get_mob_weight() + mob.carry_weight) > maximum_capacity)
			return FALSE
		weight = mob.get_mob_weight() + mob.carry_weight
	if(!forced && isitem(AM) && user && !user.transferItemToLoc(AM, src))
		return FALSE
	else
		AM.forceMove(src)
	current_capacity += weight
	stuff_shit += AM
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/handcart/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && put_in(null, AM)) // limit reached
			break

/obj/structure/handcart/update_icon_state()
	. = ..()
	if(length(stuff_shit))
		icon_state = cart_full_state
	else
		icon_state = cart_empty_state

/obj/structure/handcart/update_overlays()
	. = ..()
	if(upgrade)
		var/upgrade_icon_state = istype(upgrade, /obj/item/gear/wood/basic) ? "ov_upgrade" : "ov_upgrade2"
		. += image(icon = 'icons/roguetown/misc/structure.dmi', icon_state = upgrade_icon_state, dir = dir)

/obj/structure/handcart/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(length(stuff_shit))
		dump_contents()
		visible_message(span_info("[user] dumps out [src]!"))
		playsound(src, 'sound/foley/cartdump.ogg', 100, FALSE, -1)
		update_appearance(UPDATE_ICON)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/handcart/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || (L.buckled && L.buckled != src) || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(L.density)
				return FALSE
		L.stop_pulling()
		return TRUE
	if(isobj(AM))
		if((AM.density) || AM.anchored || AM.has_buckled_mobs() || iseffect(AM))
			return FALSE
		if(isitem(AM))
			var/obj/item/I = AM
			if(HAS_TRAIT(I, TRAIT_NODROP) || I.item_flags & ABSTRACT)
				return FALSE
		return TRUE
	return FALSE

/obj/structure/handcart/Move(atom/newloc, direct, glide_size_override)
	. = ..()
	if (. && pulledby && dir != pulledby.dir)
		setDir(pulledby.dir)
		update_appearance(UPDATE_ICON)
