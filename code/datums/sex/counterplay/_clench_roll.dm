#define CLENCH_CON_WEIGHT 0.6
#define CLENCH_STR_WEIGHT 0.4
#define CLENCH_LEVERAGE_MIN 0.5
#define CLENCH_LEVERAGE_MAX 1.5
#define CLENCH_BASE_CHANCE 30
#define CLENCH_MARGIN_SCALE 4
#define CLENCH_CHANCE_FLOOR 5
#define CLENCH_CHANCE_CEIL 85
#define CLENCH_CRIT_FRACTION 0.2
/// Clench chance multiplier while the clencher gapes open.
#define CLENCH_GAPED_MULT 0.5

/// Clencher power from raw stat values, scaled by a weight leverage ratio.
/proc/get_clench_power_from_stats(constitution, strength, leverage = 1)
	var/power = (constitution * CLENCH_CON_WEIGHT) + (strength * CLENCH_STR_WEIGHT)
	return power * clamp(leverage, CLENCH_LEVERAGE_MIN, CLENCH_LEVERAGE_MAX)

/// Weight ratio between the two mobs, 1 when either weight is unusable.
/proc/get_clench_leverage(mob/living/clencher, mob/living/aggressor)
	if(!clencher || !aggressor)
		return 1
	var/clencher_weight = clencher.get_mob_weight()
	var/aggressor_weight = aggressor.get_mob_weight()
	if(clencher_weight <= 0 || aggressor_weight <= 0)
		return 1
	return clencher_weight / aggressor_weight

/// Clencher power read off a live pair of mobs.
/proc/get_clench_power(mob/living/clencher, mob/living/aggressor)
	if(!clencher)
		return 0
	var/constitution = clencher.get_stat_level(STATKEY_CON) || 0
	var/strength = clencher.get_stat_level(STATKEY_STR) || 0
	return get_clench_power_from_stats(constitution, strength, get_clench_leverage(clencher, aggressor))

/// Success chance as a percentage, clamped at both ends.
/proc/get_clench_chance(clench_power, aggressor_strength)
	var/margin = clench_power - aggressor_strength
	return clamp(CLENCH_BASE_CHANCE + (margin * CLENCH_MARGIN_SCALE), CLENCH_CHANCE_FLOOR, CLENCH_CHANCE_CEIL)

/// Maps one roll onto the fail / interrupt / stop bands. Crit is nested inside success.
/proc/resolve_clench_roll(roll, chance)
	if(chance <= 0 || roll > chance)
		return CLENCH_RESULT_FAIL
	if(roll <= (chance * CLENCH_CRIT_FRACTION))
		return CLENCH_RESULT_STOP
	return CLENCH_RESULT_INTERRUPT

/// Rolls a live clench between two mobs.
/proc/roll_clench(mob/living/clencher, mob/living/aggressor)
	var/aggressor_strength = aggressor ? (aggressor.get_stat_level(STATKEY_STR) || 0) : 0
	var/chance = get_clench_chance(get_clench_power(clencher, aggressor), aggressor_strength)
	// A gaping opening has little left to clench with.
	if(clencher?.has_gaped_orifice())
		chance *= CLENCH_GAPED_MULT
	return resolve_clench_roll(rand(1, 100), chance)

#undef CLENCH_GAPED_MULT
