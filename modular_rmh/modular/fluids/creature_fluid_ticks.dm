// Simple creatures never tick organs in Life, so an emptied creature organ refills on the slow object loop instead.

/// Longest stretch one creature tick may catch up on, so a stalled loop cannot dump a burst of fluid.
#define CREATURE_FLUID_TICK_CAP (1 MINUTES)
/// Fluid below this many units counts as none, matching the reagent floor.
#define CREATURE_FLUID_SETTLED_MARGIN 0.05

/obj/item/organ/genitals/filling_organ
	/// TRUE while this creature organ ticks on SSslowobj.
	var/creature_fluid_ticking = FALSE
	/// world.time of the last creature tick, so each tick runs on real elapsed time.
	var/creature_fluid_ticked_at = 0

/obj/item/organ/genitals/filling_organ/process(delta_time, times_fired)
	if(owner && creature_fluid_ticking)
		process_creature_fluids()
		return
	return ..()

/// Starts creature ticks when the organ loses fluid or takes in someone else's.
/obj/item/organ/genitals/filling_organ/proc/consider_creature_fluid_ticks(changetype)
	switch(changetype)
		if(REM_REAGENT, DEL_REAGENT, CLEAR_REAGENTS)
			start_creature_fluid_ticks()
		if(ADD_REAGENT)
			if(reagents.total_volume - get_own_fluid_amount() > CREATURE_FLUID_SETTLED_MARGIN)
				start_creature_fluid_ticks()

/obj/item/organ/genitals/filling_organ/proc/start_creature_fluid_ticks()
	if(creature_fluid_ticking || !owner || iscarbon(owner) || owner.stat == DEAD || !reagents)
		return
	creature_fluid_ticking = TRUE
	creature_fluid_ticked_at = world.time
	START_PROCESSING(SSslowobj, src)

/obj/item/organ/genitals/filling_organ/proc/stop_creature_fluid_ticks()
	if(!creature_fluid_ticking)
		return
	creature_fluid_ticking = FALSE
	STOP_PROCESSING(SSslowobj, src)

/// One creature tick: the normal fluid upkeep over the time since the last tick, then rest once settled.
/obj/item/organ/genitals/filling_organ/proc/process_creature_fluids()
	if(!reagents || owner.stat == DEAD)
		stop_creature_fluid_ticks()
		return
	var/seconds = min((world.time - creature_fluid_ticked_at) / (1 SECONDS), CREATURE_FLUID_TICK_CAP / (1 SECONDS))
	creature_fluid_ticked_at = world.time
	if(seconds > 0)
		process_fluids(seconds)
	if(is_fluid_settled())
		stop_creature_fluid_ticks()

/// Nothing left to refill, drain or exchange, so the organ can rest until it is emptied again.
/obj/item/organ/genitals/filling_organ/proc/is_fluid_settled()
	if(locate(/obj/item/reagent_containers) in contents)
		return FALSE
	var/own_amount = get_own_fluid_amount()
	if(reagents.total_volume - own_amount > CREATURE_FLUID_SETTLED_MARGIN)
		return FALSE
	return own_amount >= get_resting_fluid_amount() - CREATURE_FLUID_SETTLED_MARGIN

/// Own fluid the organ tops itself up to when left alone.
/obj/item/organ/genitals/filling_organ/proc/get_resting_fluid_amount()
	return is_producing() ? reagents.maximum_volume : 0

/obj/item/organ/genitals/filling_organ/vagina/get_resting_fluid_amount()
	return is_producing() ? get_wetness_target() : 0

/obj/item/organ/genitals/filling_organ/vagina/is_fluid_settled()
	if(burst_to_drip > CREATURE_FLUID_SETTLED_MARGIN)
		return FALSE
	return ..()

#undef CREATURE_FLUID_TICK_CAP
#undef CREATURE_FLUID_SETTLED_MARGIN
