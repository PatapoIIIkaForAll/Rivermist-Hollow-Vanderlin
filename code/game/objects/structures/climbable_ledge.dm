/obj/structure/climbable_ledge
	name = "hewn footholds"
	desc = "Rough hand- and footholds cut into the stone, leading to the level above."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stonestairs" // placeholder art until a dedicated sprite exists
	anchored = TRUE
	density = FALSE
	layer = 5
	plane = FLOOR_PLANE
	max_integrity = 100

/obj/structure/climbable_ledge/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	try_climb(user)
	return TRUE

/// Solid turf beside the hole above this foothold, where a climb ends; null when there is none.
/obj/structure/climbable_ledge/proc/climb_destination()
	var/turf/above = GET_TURF_ABOVE(get_turf(src))
	if(!istype(above, /turf/open/openspace))
		return null
	for(var/D in GLOB.cardinals)
		var/turf/open/candidate = get_step(above, D)
		if(!istype(candidate))
			continue
		if(istype(candidate, /turf/open/openspace))
			continue
		if(candidate.density)
			continue
		return candidate
	return null

/obj/structure/climbable_ledge/proc/try_climb(mob/living/user)
	if(!isliving(user) || user.incapacitated())
		return
	var/turf/above = GET_TURF_ABOVE(get_turf(src))
	if(!istype(above, /turf/open/openspace))
		to_chat(user, span_warning("The way up is sealed."))
		return
	var/turf/dest = climb_destination()
	if(!dest)
		to_chat(user, span_warning("There's no solid edge above to haul myself onto."))
		return
	var/climbskill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/climbing)
	var/climb_time = max(2 SECONDS, 6 SECONDS - (climbskill * 0.5 SECONDS))
	user.visible_message(span_notice("[user] begins climbing up [src]."), \
		span_notice("I begin climbing up [src]."))
	if(!do_after(user, climb_time, src))
		return
	movable_travel_z_level(user, dest)

/// Walking onto the foothold with auto-climb on starts the climb; forced moves, falls and climbs do not.
/obj/structure/climbable_ledge/Crossed(atom/movable/crosser, oldloc)
	. = ..()
	if(oldloc || !isliving(crosser) || crosser.currently_z_moving)
		return
	var/mob/living/climber = crosser
	if(!climb_destination() || !climber.should_auto_climb(climber.dir))
		return
	INVOKE_ASYNC(src, PROC_REF(try_climb), climber)

/obj/structure/climbable_ledge/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(istype(I, /obj/item/weapon/pick) && user.used_intent?.type == PICK_INTENT)
		user.visible_message(span_warning("[user] starts breaking apart [src]."), \
			span_warning("I start breaking apart [src]."))
		if(do_after(user, 3 SECONDS, src))
			user.visible_message(span_warning("[user] breaks apart [src]."), \
				span_warning("I break apart [src]."))
			qdel(src)
		return TRUE
	return ..()
