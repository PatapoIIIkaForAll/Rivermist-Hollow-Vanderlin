#define AUTO_CLIMB_FEEDBACK_COOLDOWN "auto_climb_feedback"
#define AUTO_CLIMB_FEEDBACK_DELAY (3 SECONDS)

/// Directions of the movement keys held now; none while Ctrl turns in place.
/client/proc/held_movement_dir()
	. = NONE
	if(keys_held["Ctrl"])
		return
	for(var/held_key in keys_held)
		. |= movement_keys[held_key]

/// Whether a step toward climb_dir starts a climb. The caller passes the toggle and held keys.
/proc/auto_climb_allowed(mob/living/climber, climb_dir, pref_enabled, held_dir)
	if(!pref_enabled || !climb_dir || QDELETED(climber))
		return FALSE
	if(climber.dir != climb_dir || !(held_dir & climb_dir))
		return FALSE
	if(climber.m_intent == MOVE_INTENT_RUN || HAS_TRAIT(climber, TRAIT_STUMBLE))
		return FALSE
	if(climber.cmode)
		return FALSE
	if(climber.stat != CONSCIOUS || climber.body_position != STANDING_UP)
		return FALSE
	if(climber.buckled || climber.pulledby || climber.throwing)
		return FALSE
	if(HAS_TRAIT(climber, TRAIT_HANDS_BLOCKED) || climber.incapacitated(IGNORE_GRAB))
		return FALSE
	// Same as a click-climb: anything in the active hand would hit the wall instead.
	if(climber.get_active_held_item())
		return FALSE
	if(climber.doing())
		return FALSE
	return TRUE

/// The auto-climb toggle; mobs without a player never auto-climb.
/mob/living/proc/auto_climb_pref()
	return client?.prefs?.read_preference(/datum/preference/toggle/auto_climb)

/mob/living/proc/auto_climb_held_dir()
	return client?.held_movement_dir()

/mob/living/proc/should_auto_climb(climb_dir)
	return auto_climb_allowed(src, climb_dir, auto_climb_pref(), auto_climb_held_dir())

/// Starts a climb when a walk presses into a climbable wall, or toward the edge above a foothold. TRUE when one starts.
/mob/living/proc/try_bump_climb(atom/bumped)
	var/turf/here = loc
	if(!isturf(here))
		return FALSE
	var/climb_dir = get_dir(src, bumped)
	if(!should_auto_climb(climb_dir))
		return FALSE
	var/obj/structure/climbable_ledge/ledge = locate() in here
	var/turf/ledge_dest = ledge?.climb_destination()
	if(ledge_dest && get_dir(GET_TURF_ABOVE(here), ledge_dest) == climb_dir)
		INVOKE_ASYNC(ledge, TYPE_PROC_REF(/obj/structure/climbable_ledge, try_climb), src)
		return TRUE
	if(!isclosedturf(bumped))
		return FALSE
	var/turf/closed/wall = bumped
	if(!wall.can_bump_climb(src))
		return FALSE
	var/feedback = !TIMER_COOLDOWN_CHECK(src, AUTO_CLIMB_FEEDBACK_COOLDOWN)
	if(feedback)
		TIMER_COOLDOWN_START(src, AUTO_CLIMB_FEEDBACK_COOLDOWN, AUTO_CLIMB_FEEDBACK_DELAY)
	INVOKE_ASYNC(wall, TYPE_PROC_REF(/turf/closed, try_wallclimb), src, feedback)
	return TRUE

#undef AUTO_CLIMB_FEEDBACK_COOLDOWN
#undef AUTO_CLIMB_FEEDBACK_DELAY
