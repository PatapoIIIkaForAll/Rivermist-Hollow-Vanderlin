/datum/mind
	/// Round-local stored rune returns after the first free return has been used.
	var/defeat_rune_charges = DEFEAT_RUNE_MAX_CHARGES
	/// Last world.time recharge accounting touched this mind.
	var/defeat_rune_last_recharge_time = 0
	/// First defeat rune return is free once per round.
	var/defeat_rune_first_free_used = FALSE
	/// Set when the player gave this character up to captivity. No rune may rebuild the body.
	var/defeat_character_abandoned = FALSE

/datum/mind/proc/get_defeat_rune_charges()
	recharge_defeat_rune_charges()
	return defeat_rune_charges

/datum/mind/proc/recharge_defeat_rune_charges()
	if(defeat_rune_charges >= DEFEAT_RUNE_MAX_CHARGES)
		defeat_rune_charges = DEFEAT_RUNE_MAX_CHARGES
		defeat_rune_last_recharge_time = world.time
		return defeat_rune_charges

	if(!defeat_rune_last_recharge_time)
		defeat_rune_last_recharge_time = world.time

	var/elapsed = world.time - defeat_rune_last_recharge_time
	if(elapsed < DEFEAT_RUNE_RECHARGE_TIME)
		return defeat_rune_charges

	var/recharged = FLOOR(elapsed / DEFEAT_RUNE_RECHARGE_TIME, 1)
	if(recharged <= 0)
		return defeat_rune_charges

	defeat_rune_charges = min(DEFEAT_RUNE_MAX_CHARGES, defeat_rune_charges + recharged)
	defeat_rune_last_recharge_time += recharged * DEFEAT_RUNE_RECHARGE_TIME
	if(defeat_rune_charges >= DEFEAT_RUNE_MAX_CHARGES)
		defeat_rune_last_recharge_time = world.time
	return defeat_rune_charges

/datum/mind/proc/can_spend_defeat_rune_charge(emergency = FALSE)
	if(emergency)
		return TRUE
	recharge_defeat_rune_charges()
	return !defeat_rune_first_free_used || defeat_rune_charges > 0

/datum/mind/proc/spend_defeat_rune_charge(emergency = FALSE)
	if(emergency)
		return list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_EMERGENCY, DEFEAT_RUNE_CHARGES_REMAINING = max(defeat_rune_charges, 0))

	recharge_defeat_rune_charges()
	if(!defeat_rune_first_free_used)
		defeat_rune_first_free_used = TRUE
		return list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_FIRST_FREE, DEFEAT_RUNE_CHARGES_REMAINING = defeat_rune_charges)

	if(defeat_rune_charges <= 0)
		return null

	defeat_rune_charges--
	return list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_CHARGED, DEFEAT_RUNE_CHARGES_REMAINING = defeat_rune_charges)

/datum/mind/proc/get_defeat_rune_emergency_result()
	return list(DEFEAT_RUNE_SPEND_KIND = DEFEAT_RUNE_SPEND_EMERGENCY, DEFEAT_RUNE_CHARGES_REMAINING = max(defeat_rune_charges, 0))

/// Coin tithe + blood tax owed for spending a charge, keyed by how many charges were available BEFORE the spend.
/// "blood" of DEFEAT_RUNE_BLOOD_FRACTION_SENTINEL means "bill a fraction of current blood" (see the last-charge tier).
/proc/defeat_rune_charge_cost(charges_before)
	switch(charges_before)
		if(5)
			return list("coin" = 1, "blood" = 100)
		if(4)
			return list("coin" = 3, "blood" = 300)
		if(3)
			return list("coin" = 5, "blood" = 500)
		if(2)
			return list("coin" = 10, "blood" = 800)
		if(1)
			return list("coin" = 30, "blood" = DEFEAT_RUNE_BLOOD_FRACTION_SENTINEL)
	return list("coin" = 0, "blood" = 0)
