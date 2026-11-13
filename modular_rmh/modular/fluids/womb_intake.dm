// Seed moves from the vagina into the womb a little at a time; only what reaches the womb can take root.

/obj/item/organ/genitals/filling_organ/vagina
	COOLDOWN_DECLARE(womb_intake_cooldown)

/// One intake tick on its own interval; returns the units that moved.
/obj/item/organ/genitals/filling_organ/vagina/proc/stage_seed_into_womb()
	if(!COOLDOWN_FINISHED(src, womb_intake_cooldown))
		return 0
	COOLDOWN_START(src, womb_intake_cooldown, WOMB_SEED_INTAKE_INTERVAL)
	return move_seed_into_womb(WOMB_SEED_INTAKE_PER_TICK)

/// Moves up to [amount] units of seed into the womb; every other fluid stays behind. Returns the units moved.
/obj/item/organ/genitals/filling_organ/vagina/proc/move_seed_into_womb(amount)
	var/obj/item/organ/genitals/filling_organ/womb/womb = owner?.get_womb()
	if(!womb?.reagents || !reagents?.total_volume || amount <= 0)
		return 0
	var/list/kept_types = list()
	var/seed_units = 0
	for(var/datum/reagent/held as anything in reagents.reagent_list)
		if(istype(held, /datum/reagent/consumable/cum))
			seed_units += held.volume
		else
			kept_types += held.type
	if(seed_units <= 0)
		return 0
	var/before = womb.reagents.total_volume
	// INGEST makes the seed register at the womb, the same way it registered on the way in.
	reagents.trans_to(womb, min(amount, seed_units), method = INGEST, ignored_reagents = kept_types)
	return womb.reagents.total_volume - before
