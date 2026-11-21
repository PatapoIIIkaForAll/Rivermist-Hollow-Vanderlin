/// Pins a mob shoved by someone out of combat mode against this wall. TRUE if they were pinned.
/turf/closed/proc/try_shove_press(mob/living/user, mob/living/target)
	if(!wallpress || !density || user.cmode || target.buckled || target.body_position == LYING_DOWN)
		return FALSE
	var/dir2wall = get_dir(target, src)
	if(!(dir2wall in GLOB.cardinals) || !target.Adjacent(src))
		return FALSE
	// A target in combat mode resists with the usual shove roll.
	if(target.cmode && !prob(clamp(30 + (user.stat_compare(target, STAT_STRENGTH, STAT_CONSTITUTION) * 10), 0, 100)))
		return FALSE

	var/face_first = (target.dir == dir2wall)
	target.wallpressed = FALSE
	wallshove(target)
	if(!target.wallpressed)
		return FALSE

	if(face_first)
		target.visible_message(span_notice("[user] presses [target] face-first against [src]."), \
			span_notice("[user] presses me face-first against [src]."), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_notice("I press [target] face-first against [src]."))
	else
		target.setDir(REVERSE_DIR(dir2wall))
		target.visible_message(span_notice("[user] presses [target] up against [src]."), \
			span_notice("[user] presses me up against [src]."), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_notice("I press [target] up against [src]."))
	log_combat(user, target, "pressed", "against [src]")
	return TRUE
