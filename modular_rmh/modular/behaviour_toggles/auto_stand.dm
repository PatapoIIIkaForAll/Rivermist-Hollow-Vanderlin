/// Wait between tries to stand while auto-stand keeps a player trying.
#define AUTO_STAND_RETRY_DELAY (1.5 SECONDS)

/mob/living
	/// Pending auto-stand retry timer; at most one.
	var/auto_stand_timer

/// The auto-stand toggle of the player in this mob.
/mob/living/proc/auto_stand_pref()
	return client?.prefs?.read_preference(/datum/preference/toggle/auto_stand)

/// TRUE for a player with auto-stand on: a failed stand-up is tried again.
/mob/living/proc/auto_stand_retries()
	return client && auto_stand_pref()

/// TRUE for a player with auto-stand off: they stay lying when a knockdown ends.
/mob/living/proc/auto_stand_declined()
	return client && !auto_stand_pref()

/// A stand-up try failed: players with auto-stand try again shortly, everyone else rests as before.
/mob/living/proc/stand_up_failed()
	if(!auto_stand_retries())
		set_resting(TRUE, silent = TRUE)
		return
	if(auto_stand_timer)
		return
	auto_stand_timer = addtimer(CALLBACK(src, PROC_REF(retry_get_up)), AUTO_STAND_RETRY_DELAY, TIMER_STOPPABLE)

/// Tries to stand again unless the player chose to rest, is up, or something still holds them down.
/mob/living/proc/retry_get_up()
	auto_stand_timer = null
	if(resting || body_position == STANDING_UP)
		return
	if(!auto_stand_retries())
		set_resting(TRUE, silent = TRUE)
		return
	// Waking up or the knockdown ending calls get_up again.
	if(stat != CONSCIOUS || buckled || HAS_TRAIT(src, TRAIT_FLOORED))
		return
	if(pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE)
		stand_up_failed()
		return
	get_up()

#undef AUTO_STAND_RETRY_DELAY
