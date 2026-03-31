/mob/living/MouseDrop_T(atom/dropping, mob/user)
	if(ishuman(dropping))
		var/mob/living/carbon/human/seelie = dropping
		if(user == seelie && seelie.is_seelie() && seelie.seelie_perch_on(src))
			return TRUE

	return ..()

/mob/living/carbon/human/MouseDrop_T(mob/living/target, mob/living/user)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/seelie = target
		if(user == seelie && seelie.is_seelie() && seelie.seelie_perch_on(src))
			return TRUE

	return ..()

/mob/living/carbon/human/proc/seelie_perch_on(mob/living/target)
	if(!is_seelie() || !istype(target) || get_dist(src, target) > 1)
		return FALSE
	if(target == src || target.buckled)
		return FALSE
	if(!ishuman(target) && !istype(target, /mob/living/simple_animal/hostile/retaliate/bigrat))
		return FALSE

	target.buckle_mob(src, TRUE, TRUE, FALSE, 0, 0)
	if(buckled != target)
		return FALSE

	visible_message(
		span_notice("[src] flutters onto [target]'s shoulder."),
		span_notice("I perch on [target].")
	)
	return TRUE

/mob/living/carbon/human/proc/seelie_enter_container(atom/target)
	if(!is_seelie() || QDELETED(target) || get_dist(src, target) > 1 || loc == target)
		return FALSE
	if(seelie_has_grand_glamour())
		to_chat(src, span_warning("I'm too large to squeeze into [target] while the glamour holds."))
		return FALSE

	if(istype(target, /obj/item/flashlight/flare/torch/lantern))
		var/obj/item/flashlight/flare/torch/lantern/lantern = target
		if(lantern.on || lantern.get_seelie_occupant())
			return FALSE

		lantern.seelie_inside = WEAKREF(src)
		forceMove(lantern)
		seelie_ensure_scale()
		to_chat(src, span_notice("I squeeze into [lantern]."))
		lantern.update_brightness()
		return TRUE

	if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/closet = target
		if(!closet.opened)
			closet.open()
		if(!closet.opened)
			return FALSE
		if(closet.insert(src) != TRUE)
			return FALSE

		seelie_ensure_scale()
		to_chat(src, span_notice("I slip into [closet]."))
		return TRUE

	if(istype(target, /obj/item/storage))
		var/obj/item/storage/storage = target
		forceMove(storage)
		seelie_ensure_scale()
		to_chat(src, span_notice("I tuck myself inside [storage]."))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/seelie_force_into_container(atom/target, mob/living/forcer)
	if(!is_seelie() || QDELETED(target))
		return FALSE

	if(forcer)
		var/highest_grab_state = forcer.get_highest_grab_state_on(src)
		if(isnull(highest_grab_state))
			highest_grab_state = forcer.grab_state
		if(highest_grab_state < GRAB_AGGRESSIVE)
			return FALSE

	if(get_dist(src, target) > 1 && (!forcer || get_dist(src, forcer) > 1))
		return FALSE

	return seelie_enter_container(target)

/mob/living/carbon/human/proc/seelie_exit_container()
	set name = "Leave Container"
	set category = "Seelie"

	if(!is_seelie())
		return
	if(!seelie_leave_container())
		if(handcuffed || legcuffed)
			to_chat(src, span_warning("I'm bound and can't wriggle free. I need to escape my restraints first!"))
			resist_restraints()

/mob/living/carbon/human/proc/seelie_leave_container(force_exit = FALSE)
	if(!is_seelie())
		return FALSE
	if(isturf(loc) || ismob(loc))
		return FALSE
	if(!force_exit && (handcuffed || legcuffed))
		return FALSE

	var/atom/old_container = loc
	var/turf/destination = get_turf(old_container)
	if(!destination)
		return FALSE

	var/obj/item/flashlight/flare/torch/lantern/lantern = old_container
	if(istype(lantern))
		lantern.seelie_inside = null

	forceMove(destination)
	seelie_ensure_scale()
	to_chat(src, span_notice("I flutter out of [old_container]."))

	if(istype(lantern))
		lantern.update_brightness()

	return TRUE

/obj/structure/closet/MouseDrop_T(atom/movable/dropping, mob/living/user)
	if(ishuman(dropping))
		var/mob/living/carbon/human/seelie = dropping
		if(seelie.is_seelie())
			if(user == seelie)
				if(seelie.seelie_enter_container(src))
					return TRUE
			else if(seelie.seelie_force_into_container(src, user))
				return TRUE

	return ..()

/obj/item/storage/MouseDrop_T(atom/dropping, mob/user)
	if(ishuman(dropping))
		var/mob/living/carbon/human/seelie = dropping
		if(seelie.is_seelie())
			if(user == seelie)
				if(seelie.seelie_enter_container(src))
					return TRUE
			else if(isliving(user) && seelie.seelie_force_into_container(src, user))
				return TRUE

	return ..()

/obj/item/flashlight/flare/torch/lantern
	var/datum/weakref/seelie_inside

/obj/item/flashlight/flare/torch/lantern/proc/get_seelie_occupant()
	var/mob/living/carbon/human/seelie = seelie_inside?.resolve()
	if(!istype(seelie) || !seelie.is_seelie() || seelie.loc != src)
		seelie_inside = null
		return null
	return seelie

/obj/item/flashlight/flare/torch/lantern/MouseDrop_T(atom/dropping, mob/user)
	if(ishuman(dropping))
		var/mob/living/carbon/human/seelie = dropping
		if(seelie.is_seelie())
			if(user == seelie)
				if(seelie.seelie_enter_container(src))
					return TRUE
			else if(isliving(user) && seelie.seelie_force_into_container(src, user))
				return TRUE

	return ..()

/obj/item/flashlight/flare/torch/lantern/attack_self(mob/user, list/modifiers)
	if(!on && get_seelie_occupant())
		to_chat(user, span_warning("[src] is occupied. Lighting it now would roast its passenger."))
		return TRUE

	return ..()

/obj/item/flashlight/flare/torch/lantern/fire_act(added, maxstacks)
	if(!on && get_seelie_occupant())
		return FALSE

	return ..()
