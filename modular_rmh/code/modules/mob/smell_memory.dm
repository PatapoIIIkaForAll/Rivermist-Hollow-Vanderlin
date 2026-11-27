// A scent once noticed is not announced again for a while, so a lingering smell does not repeat in chat.

/// How long a scent goes unannounced after it was last announced.
#define SMELL_REPEAT_COOLDOWN (2 MINUTES)

/mob/living
	/// Pollutant type to the world.time its smell was last announced.
	var/list/smell_memory

/// TRUE if this scent was announced recently; otherwise remembers it as announced now.
/mob/living/proc/smelled_recently(pollutant_type)
	var/last_smelled = LAZYACCESS(smell_memory, pollutant_type)
	if(last_smelled && world.time - last_smelled < SMELL_REPEAT_COOLDOWN)
		return TRUE
	LAZYSET(smell_memory, pollutant_type, world.time)
	return FALSE

#undef SMELL_REPEAT_COOLDOWN
