GLOBAL_DATUM_INIT(openspace_backdrop_one_for_all, /atom/movable/openspace_backdrop, new)
GLOBAL_DATUM_INIT(openspace_reflection_dimmer_one_for_all, /atom/movable/openspace_reflection_dimmer, new)

/atom/movable/openspace_backdrop
	name = "openspace_backdrop"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grey"
	anchored = TRUE
	plane = OPENSPACE_BACKDROP_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_ID

/**
 * The backdrop above dims a hole by multiplying grey over it, but it lives on OPENSPACE_BACKDROP_PLANE,
 * which composites below REFLECTION_PLANE - so it can darken the level below without ever touching the
 * reflections cast down there, leaving them brighter than the mobs casting them. Openspace turfs carry no
 * colour of their own to inherit either, so nothing else dims them. This does the same multiply, with the
 * same grey, on the reflection plane itself and only over the hole's own tile.
 */
/atom/movable/openspace_reflection_dimmer
	name = "openspace_reflection_dimmer"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grey"
	anchored = TRUE
	plane = REFLECTION_PLANE
	// Above any reflection appearance, which carry the layer of the mob that cast them.
	layer = OPENSPACE_LAYER
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_ID

/turf/open/openspace
	name = "open space"
	desc = "My eyes can see far down below."
	icon_state = MAP_SWITCH("openspace", "openspacemap")
	baseturfs = /turf/open/openspace
	intact = FALSE
	CanAtmosPassVertical = ATMOS_PASS_YES
	var/can_cover_up = TRUE
	var/can_build_on = TRUE
	dynamic_lighting = 1
	path_weight = 500
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_FLOOR_OPEN_SPACE
	smoothing_list = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_CLOSED_WALL
	neighborlay_self = "staticedge"

/turf/open/openspace/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	vis_contents += GLOB.openspace_backdrop_one_for_all //Special grey square for projecting backdrop darkness filter on it.
	vis_contents += GLOB.openspace_reflection_dimmer_one_for_all //Same darkness, but on the plane reflections escape to.
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_created))
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, is_openspace = TRUE)

/turf/open/openspace/ChangeTurf(path, list/new_baseturfs, flags)
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	return ..()

/// Mark ordinary Move() traversal so the fall starts only after the move finishes.
/turf/open/openspace/Enter(atom/movable/movable, atom/oldloc)
	if(isliving(movable) && try_auto_climb_down(movable, oldloc))
		return FALSE
	. = ..()
	if(.)
		movable.set_currently_z_moving(CURRENTLY_Z_FALLING_FROM_MOVE)

/// Make movables placed here by forceMove() fall without re-entering an active z-move.
/turf/open/openspace/Entered(atom/movable/movable)
	. = ..()
	if(movable.set_currently_z_moving(CURRENTLY_Z_FALLING))
		zFall(movable, falling_from_move = TRUE)

/// Drop atoms created directly on open space after their initialization succeeds.
/turf/open/openspace/proc/on_atom_created(datum/source, atom/created_atom)
	SIGNAL_HANDLER
	if(ismovable(created_atom))
		zfall_if_on_turf(created_atom)

/turf/open/openspace/proc/zfall_if_on_turf(atom/movable/movable)
	if(QDELETED(movable) || movable.loc != src)
		return
	zFall(movable)

/turf/open/openspace/can_traverse_safely(atom/movable/traveler)
	return !traveler.can_z_move(DOWN, src, z_move_flags = ZMOVE_FALL_FLAGS)

/turf/open/openspace/add_neighborlay(dir, edgeicon, offset = FALSE)
	var/add
	var/y = 0
	var/x = 0
	switch(dir)
		if(NORTH)
			add = "[edgeicon]-n"
			y = -32
		if(SOUTH)
			add = "[edgeicon]-s"
			y = 32
		if(EAST)
			add = "[edgeicon]-e"
			x = -32
		if(WEST)
			add = "[edgeicon]-w"
			x = 32

	if(!add)
		return

	var/image/overlay = image(icon, src, add, pixel_x = offset ? x : 0, pixel_y = offset ? y : 0 )

	LAZYADDASSOC(neighborlay_list, "[dir]", overlay)
	add_overlay(overlay)

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	if(A.anchored && !isprojectile(A))
		return FALSE
	if(HAS_TRAIT(A, TRAIT_I_AM_INVISIBLE_ON_A_BOAT))
		return FALSE
	if(HAS_TRAIT(A, "hooked"))
		return FALSE
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE


/turf/open/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/openspace/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/openspace/attack_hand(mob/user)
	if(isliving(user))
		try_climb_down(user)

/// Flags for climbing down into this hole; lying climbers may climb too.
#define OPENSPACE_CLIMB_DOWN_FLAGS (Z_MOVE_CLIMBING_FLAGS & ~ZMOVE_LYING_CHECKS)

/// Climbs down through this hole to the turf below.
/turf/open/openspace/proc/try_climb_down(mob/living/climber)
	if(climber.stat != CONSCIOUS)
		return
	var/turf/target = GET_TURF_BELOW(src)
	if(!target)
		to_chat(climber, "<span class='warning'>I can't climb there.</span>")
		return
	var/z_move_flags = OPENSPACE_CLIMB_DOWN_FLAGS | ZMOVE_FEEDBACK
	if(!climber.can_z_move(DOWN, src, target, z_move_flags))
		to_chat(climber, "<span class='warning'>I can't climb here.</span>")
		return
	if(climber.m_intent != MOVE_INTENT_SNEAK)
		playsound(climber, 'sound/foley/climb.ogg', 100, TRUE)
	climber.visible_message("<span class='warning'>[climber] starts to climb down.</span>", "<span class='warning'>I start to climb down.</span>")
	if(do_after(climber, 3 SECONDS, src))
		if(!climber.can_z_move(DOWN, src, target, z_move_flags))
			return
		if(climber.m_intent != MOVE_INTENT_SNEAK)
			playsound(climber, 'sound/foley/climb.ogg', 100, TRUE)
		climber.set_currently_z_moving(CURRENTLY_Z_CLIMBING_DOWN)
		climber.zMove(DOWN, target, z_move_flags & ~ZMOVE_FEEDBACK)

/// Walking off this edge with auto-climb on climbs down instead of falling. TRUE blocks the step.
/turf/open/openspace/proc/try_auto_climb_down(mob/living/climber, atom/oldloc)
	if(DOING_INTERACTION_WITH_TARGET(climber, src))
		return TRUE
	if(!isturf(oldloc) || climber.loc != oldloc)
		return FALSE
	if(!climber.should_auto_climb(get_dir(oldloc, src)))
		return FALSE
	if(!climber.can_z_move(DOWN, src, null, ZMOVE_FALL_FLAGS))
		return FALSE
	var/turf/below = GET_TURF_BELOW(src)
	if(!below || !climber.can_z_move(DOWN, src, below, OPENSPACE_CLIMB_DOWN_FLAGS))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(try_climb_down), climber)
	return TRUE

#undef OPENSPACE_CLIMB_DOWN_FLAGS

/turf/open/openspace/attack_ghost(mob/dead/observer/user)
	var/turf/target = GET_TURF_BELOW(src)
	if(!user.Adjacent(src))
		return
	if(!target)
		to_chat(user, "<span class='warning'>I can't go there.</span>")
		return
	if(user.can_z_move(DOWN, src, target, ZMOVE_IGNORE_OBSTACLES | ZMOVE_FEEDBACK))
		user.zMove(DOWN, target, ZMOVE_IGNORE_OBSTACLES)
		to_chat(user, "<span class='warning'>I glide down.</span>")
	. = ..()
