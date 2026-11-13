// Conception while seed stays inside: timed checks, and a record of whose seed is in there and how much.

/// One donor's seed inside an organ.
/datum/seed_deposit
	var/datum/weakref/father_ref
	var/father_name
	var/list/father_features
	var/hatch_result_type
	var/allow_embryo_pregnancy = FALSE
	/// Seed strength; weighs both who fathers and how likely conception is.
	var/virility = 1
	/// Virile units of this donor's seed still inside.
	var/units = 0
	/// A quickening draught makes the next check certain.
	var/quickened = FALSE

/obj/item/organ/genitals/filling_organ
	/// Donor key to /datum/seed_deposit, for virile seed that may still conceive.
	var/list/seed_ledger
	COOLDOWN_DECLARE(conception_cooldown)

/// Notes seed that just came in; the first check waits a full interval from the first deposit.
/obj/item/organ/genitals/filling_organ/proc/record_seed(datum/reagent/consumable/cum/seed, amount, allow_embryo_pregnancy, quickened)
	if(amount <= 0)
		return
	sync_seed_ledger()
	if(!LAZYLEN(seed_ledger))
		COOLDOWN_START(src, conception_cooldown, CONCEPTION_CHECK_INTERVAL)
	var/mob/living/father = seed.get_parent_from_transfer()
	var/father_name = seed.get_parent_name_from_transfer(father)
	var/key = father ? REF(father) : "[father_name]"
	var/datum/seed_deposit/deposit = LAZYACCESS(seed_ledger, key)
	if(!deposit)
		deposit = new
		deposit.father_ref = father ? WEAKREF(father) : null
		deposit.father_name = father_name
		LAZYSET(seed_ledger, key, deposit)
	deposit.father_features = seed.get_parent_features_from_transfer(father)
	deposit.hatch_result_type = seed.get_parent_hatch_result_type_from_transfer(father)
	deposit.allow_embryo_pregnancy = allow_embryo_pregnancy
	var/virility_multiplier = father ? father.get_seed_virility_multiplier() : 1
	deposit.virility = seed.vitilty_factor * virility_multiplier
	deposit.units += amount
	// A contraceptive wins over a quickening draught.
	deposit.quickened = deposit.quickened || (quickened && virility_multiplier >= 1)

/obj/item/organ/genitals/filling_organ/proc/get_virile_seed_units()
	. = 0
	for(var/datum/reagent/consumable/cum/seed in reagents?.reagent_list)
		if(seed.virile)
			. += seed.volume

/// Shrinks every donor's share as seed leaks or is absorbed, so the record matches what is inside.
/obj/item/organ/genitals/filling_organ/proc/sync_seed_ledger()
	if(!LAZYLEN(seed_ledger))
		return
	var/inside = get_virile_seed_units()
	if(inside <= 0)
		seed_ledger = null
		return
	var/recorded = 0
	for(var/key in seed_ledger)
		var/datum/seed_deposit/deposit = seed_ledger[key]
		recorded += deposit.units
	if(recorded <= inside)
		return
	var/share = inside / recorded
	for(var/key in seed_ledger)
		var/datum/seed_deposit/deposit = seed_ledger[key]
		deposit.units *= share

/// Called every fluid tick; rolls once per interval while seed is recorded.
/obj/item/organ/genitals/filling_organ/proc/check_conception()
	// Creature wombs tick only for fluids; conception stays a carbon feature for now.
	if(!iscarbon(owner))
		return
	if(!LAZYLEN(seed_ledger) || !COOLDOWN_FINISHED(src, conception_cooldown))
		return
	COOLDOWN_START(src, conception_cooldown, CONCEPTION_CHECK_INTERVAL)
	roll_conception()

/// One conception check: picks a father by seed and virility, then rolls; TRUE on conception.
/obj/item/organ/genitals/filling_organ/proc/roll_conception()
	sync_seed_ledger()
	var/inside = get_virile_seed_units()
	// A staged unit can land a hair under one, so the minimum gets a little slack.
	if(!LAZYLEN(seed_ledger) || inside < CONCEPTION_MIN_SEED - 0.01)
		return FALSE
	var/list/weights = get_seed_weights()
	if(!length(weights))
		return FALSE
	var/list/quickened = list()
	var/total_units = 0
	var/total_weight = 0
	for(var/datum/seed_deposit/deposit as anything in weights)
		if(deposit.quickened)
			quickened[deposit] = weights[deposit]
		total_units += deposit.units
		total_weight += weights[deposit]
	var/certain = is_conception_certain(length(quickened))
	var/datum/seed_deposit/chosen = pick_seed_deposit(length(quickened) ? quickened : weights)
	if(!can_attempt_impregnation(chosen.allow_embryo_pregnancy))
		return FALSE
	if(!certain && !prob(get_conception_chance(inside, total_weight / total_units)))
		return FALSE
	var/mob/living/father = chosen.father_ref?.resolve()
	if(!be_impregnated(father, chosen.allow_embryo_pregnancy, chosen.hatch_result_type, chosen.father_features, chosen.father_name))
		return FALSE
	seed_ledger = null
	return TRUE

/// Each recorded donor's claim to fatherhood: seed left inside times its virility.
/obj/item/organ/genitals/filling_organ/proc/get_seed_weights()
	. = list()
	for(var/key in seed_ledger)
		var/datum/seed_deposit/deposit = seed_ledger[key]
		var/weight = deposit.units * deposit.virility
		if(weight > 0)
			.[deposit] = weight

/// Percent chance for one check: base chance, scaled by how much seed there is, its virility, and heat.
/obj/item/organ/genitals/filling_organ/proc/get_conception_chance(inside, average_virility)
	. = CONCEPTION_BASE_CHANCE * get_seed_dose(inside) * average_virility * get_conception_multiplier()
	if(owner?.has_fluid_modifier(/datum/fluid_modifier/in_heat))
		. *= CONCEPTION_HEAT_MULT

/// Dose multiplier: rises to 1 at a full dose, then on to 2 as more seed is held.
/proc/get_seed_dose(inside)
	if(inside <= CONCEPTION_FULL_SEED)
		return max(0, inside / CONCEPTION_FULL_SEED)
	return 1 + min(1, (inside - CONCEPTION_FULL_SEED) / (CONCEPTION_DOUBLE_SEED - CONCEPTION_FULL_SEED))

/// Quickened seed or a quickened carrier conceives for sure, unless a contraceptive is at work.
/obj/item/organ/genitals/filling_organ/proc/is_conception_certain(has_quickened_seed)
	if(get_conception_multiplier() < 1)
		return FALSE
	return has_quickened_seed || owner?.has_reagent(/datum/reagent/medicine/pregplus)

/// Contraceptives and other modifiers on the carrier that make held seed take less often.
/obj/item/organ/genitals/filling_organ/proc/get_conception_multiplier()
	. = 1
	for(var/datum/fluid_modifier/modifier as anything in owner?.get_fluid_modifiers(src))
		. *= modifier.conception_multiplier

/// How strong this mob's seed is right now, from modifiers on its testicles.
/mob/living/proc/get_seed_virility_multiplier()
	. = 1
	var/obj/item/organ/genitals/filling_organ/testicles/testicles = getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testicles)
		return
	for(var/datum/fluid_modifier/modifier as anything in get_fluid_modifiers(testicles))
		. *= modifier.virility_multiplier

/// Weighted pick that allows fractional weights.
/obj/item/organ/genitals/filling_organ/proc/pick_seed_deposit(list/weights)
	var/total = 0
	for(var/datum/seed_deposit/deposit as anything in weights)
		total += weights[deposit]
	var/roll = rand() * total
	for(var/datum/seed_deposit/deposit as anything in weights)
		roll -= weights[deposit]
		if(roll <= 0)
			return deposit
	return weights[length(weights)]
