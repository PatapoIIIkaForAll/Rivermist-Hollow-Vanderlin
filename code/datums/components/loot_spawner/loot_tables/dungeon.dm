// -- Infinite dungeon cache tables ---------------------------------------------
// A tier ladder for dungeon reward caches. Tables compose themselves in New()
// by absorbing donor tables' entries (same build-in-New pattern as
// potion_ingredient), so the generic pools stay the single source of truth.
// Donors must be plain-sublist tables; stat/skill veins are authored here to
// avoid assoc-key collisions between donors.
//
// Donors are NORMALIZED to a weight budget. return_list() unions every sublist
// into one weighted pool, so a donor's raw mass is what decides its share - the
// 15-entry food table used to outweigh a curated list three times over. Each
// donor now contributes exactly its budget, whatever its entry count.

/datum/loot_table/dungeon
	abstract_type = /datum/loot_table/dungeon
	/// assoc donor loot_table type -> total weight it contributes after scaling.
	/// Compare against this table's own loot_table weights to read the mix.
	var/list/donor_types = list()
	/// Typepaths dropped from every donor before its budget is spread
	var/list/donor_exclude = list()

/datum/loot_table/dungeon/New()
	for(var/donor_type in donor_types)
		var/datum/loot_table/donor = new donor_type
		var/budget = donor_types[donor_type]
		var/total_weight = 0
		for(var/list/sublist as anything in donor.loot_table)
			if(!islist(sublist))
				continue
			for(var/entry in sublist)
				if(isnum(entry)) // skill-gate delimiters carry no weight
					continue
				if(entry in donor_exclude)
					continue
				total_weight += sublist[entry]
		if(total_weight > 0 && budget > 0)
			var/scale = budget / total_weight
			for(var/list/sublist as anything in donor.loot_table)
				if(!islist(sublist))
					continue
				var/list/scaled = list()
				for(var/entry in sublist)
					if(isnum(entry) || (entry in donor_exclude))
						continue
					// Floats are fine here; return_list turns the final pool into whole-number weights.
					scaled[entry] = max(0.05, round(sublist[entry] * scale, 0.01))
				loot_table += list(scaled)
		qdel(donor)
	..()

/// Dungeon caches pay half the coin and roll coins and gems at a third of their usual chance.
/datum/loot_table/dungeon/return_list(mob/looter = null, delve_level = 1, item_rarity = 1.0)
	var/list/base_list = ..()
	var/static/list/half_coin_types = list(
		/obj/item/coin/gold = /obj/item/coin/electrum,
		/obj/item/coin/gold/pile = /obj/item/coin/gold/pile/dungeon,
		/obj/item/coin/silver = /obj/item/coin/copper/five,
		/obj/item/coin/silver/pile = /obj/item/coin/silver/pile/dungeon,
		/obj/item/coin/copper/pile = /obj/item/coin/copper/pile/dungeon,
	)
	var/list/weighted_list = list()
	var/total_weight = 0
	var/valuable_weight = 0
	for(var/path in base_list)
		var/weight = base_list[path]
		var/final_path = half_coin_types[path] || path
		weighted_list[final_path] += weight
		total_weight += weight
		if(ispath(final_path, /obj/item/coin) || ispath(final_path, /obj/item/gem))
			valuable_weight += weight
	// Scale valuables so their share of the pool is a third of what it was.
	var/valuable_scale = 1
	if(valuable_weight > 0 && valuable_weight < total_weight)
		valuable_scale = (total_weight - valuable_weight) / (3 * total_weight - valuable_weight)
	for(var/path in weighted_list)
		var/weight = weighted_list[path]
		if(ispath(path, /obj/item/coin) || ispath(path, /obj/item/gem))
			weight *= valuable_scale
		// pickweight rolls whole numbers, so keep two decimals of precision as integers.
		weighted_list[path] = max(1, round(weight * 100, 1))
	return weighted_list

/// Cache table for a run floor: shallow, mid, deep. Shrines and traders roll
/// through this; room templates pin their own tier by hand.
/proc/get_dungeon_loot_table_type_for_floor(floor)
	switch(floor)
		if(1 to 2)
			return /datum/loot_table/dungeon/tier1
		if(3 to 4)
			return /datum/loot_table/dungeon/tier2
	return /datum/loot_table/dungeon/tier3

/// Floors 1-2: travel rations, copper arms, small coin. Enough to feel paid,
/// never enough to skip the surface economy.
/datum/loot_table/dungeon/tier1
	name = "dungeon spoils (shallow)"
	// Curated gear below sums to ~53; these budgets keep it the headline.
	donor_types = list(
		/datum/loot_table/food = 10,
		/datum/loot_table/coin/low = 30,
		/datum/loot_table/potion_vitals = 15,
	)
	loot_table = list(
		list(
			/obj/item/weapon/knife/copper = 10,
			/obj/item/weapon/axe/copper = 8,
			/obj/item/weapon/knife/hunting = 8,
			/obj/item/clothing/armor/leather = 8,
			/obj/item/clothing/head/helmet/coppercap = 6,
			/obj/item/clothing/wrists/bracers/copper = 6,
			/obj/item/lockpick = 4,
			/obj/item/gem/green = 3,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/silver = 10,
			/obj/item/gem/blue = 4,
		),
	)
	base_min = 2
	base_max = 3
	scaling_factor = 0.2

/// Floors 3-4: iron gear, silver, stat draughts. The dungeon starts paying
/// like a profession.
/datum/loot_table/dungeon/tier2
	name = "dungeon spoils (mid)"
	donor_types = list(
		/datum/loot_table/medium = 35,
		/datum/loot_table/coin/med = 30,
		/datum/loot_table/potion_vitals = 12,
		/datum/loot_table/potion_stats = 12,
	)
	loot_table = list(
		list(
			/obj/item/weapon/sword/short/iron = 8,
			/obj/item/weapon/axe/iron = 8,
			/obj/item/clothing/armor/chainmail/iron = 6,
			/obj/item/clothing/pants/chainlegs/iron = 6,
			/obj/item/alch/herb/salvia = 5,
			/obj/item/alch/herb/valeriana = 5,
		),
		/datum/attribute/skill/misc/stealing = list(
			/obj/item/gem/green = 6,
			/obj/item/gem/blue = 6,
			/obj/item/lockpick = 8,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/gold = 8,
			/obj/item/gem = 4,
		),
	)
	base_min = 2
	base_max = 4
	scaling_factor = 0.2

/// Floor 5+: the rare pool, single gold coins, and a thin seam of true
/// magic. The ceiling of what the dark pays out.
/datum/loot_table/dungeon/tier3
	name = "dungeon spoils (deep)"
	donor_types = list(
		/datum/loot_table/rare = 40,
		/datum/loot_table/coin/high = 30,
		/datum/loot_table/potion_stats = 12,
	)
	// A gold pile averages 900 amna; the deep tier pays in single coins.
	donor_exclude = list(/obj/item/coin/gold/pile)
	loot_table = list(
		list(
			/obj/item/weapon/sword/long/greatsword = 5,
			/obj/item/clothing/armor/plate = 5,
			/obj/item/reagent_containers/glass/bottle/stronghealthpot = 1,
			/obj/item/reagent_containers/glass/bottle/strongmanapot = 1,
			// The thin magic seam: low weights, and delve scaling is what
			// makes them findable at all (rare weights scale x1.3^delve).
			/obj/item/clothing/ring/active/nomag = 3,
			/obj/item/clothing/ring/gold/protection = 2,
			/obj/item/clothing/neck/talkstone = 2,
			/obj/item/clothing/head/crown/circlet/stink = 1,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/silver/pile = 6,
			/obj/item/gem = 6,
		),
	)
	base_min = 3
	base_max = 4
	scaling_factor = 0.2

/// The Sunken Warrens' own spoils: goblin crudework, bog herbs, and the ore
/// veins the warrens are dug through (the old mining flavor kept as a vein).
/datum/loot_table/dungeon/swampgob
	name = "sunken warren spoils"
	donor_types = list(
		/datum/loot_table/coin/low = 25,
		/datum/loot_table/potion_vitals = 12,
	)
	loot_table = list(
		list(
			/obj/item/weapon/knife/dagger/bronze = 10,
			/obj/item/weapon/mace/bronze = 8,
			/obj/item/weapon/axe/bronze = 8,
			/obj/item/weapon/polearm/spear/stone/copper = 8,
			/obj/item/clothing/armor/leather = 8,
			/obj/item/clothing/face/facemask/copper = 5,
			/obj/item/alch/herb/atropa = 5,
			/obj/item/alch/herb/urtica = 5,
			/obj/item/alch/herb/artemisia = 5,
			/obj/item/reagent_containers/food/snacks/hardtack = 5,
			/obj/item/statue/bronze/totem = 3,
			/obj/item/statue/bronze/figurine = 3,
		),
		/datum/attribute/skill/labor/mining = list(
			/obj/item/ore/coal = 10,
			/obj/item/ore/iron = 8,
			/obj/item/ore/tin = 6,
			/obj/item/ore/gold = 6,
			/obj/item/gem = 4,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/silver = 10,
			/obj/item/gem/green = 5,
		),
	)
	base_min = 2
	base_max = 3
	scaling_factor = 0.2

/// Drow caches follow the normal shallow/mid/deep equipment curve, but carry
/// less restorative and stat-boosting stock than their generic counterparts.
/proc/get_drow_loot_table_type_for_floor(floor)
	switch(floor)
		if(1 to 2)
			return /datum/loot_table/dungeon/drow/tier1
		if(3 to 4)
			return /datum/loot_table/dungeon/drow/tier2
	return /datum/loot_table/dungeon/drow/tier3

/datum/loot_table/dungeon/drow
	abstract_type = /datum/loot_table/dungeon/drow

/// A hypothetical shallow Drow set, retained for themed entrances and future
/// floor arrangements. Copper necessities sit beside their shadow-silk kit.
/datum/loot_table/dungeon/drow/tier1
	name = "drow dungeon spoils (shallow)"
	donor_types = list(
		/datum/loot_table/food = 8,
		/datum/loot_table/coin/low = 25,
		/datum/loot_table/potion_vitals = 6,
	)
	loot_table = list(
		list(
			/obj/item/weapon/knife/copper = 8,
			/obj/item/weapon/axe/copper = 6,
			/obj/item/weapon/knife/hunting = 6,
			/obj/item/clothing/armor/leather = 8,
			/obj/item/clothing/head/helmet/coppercap = 5,
			/obj/item/clothing/wrists/bracers/copper = 5,
			/obj/item/lockpick = 5,
			/obj/item/weapon/whip = 8,
			/obj/item/clothing/shirt/shadowshirt = 6,
			/obj/item/clothing/pants/trou/shadowpants = 6,
			/obj/item/clothing/gloves/fingerless/shadowgloves = 6,
			/obj/item/gem/green = 3,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/silver = 8,
			/obj/item/gem/blue = 4,
		),
	)
	base_min = 2
	base_max = 3
	scaling_factor = 0.2

/// Floors 3-4: the normal iron-era reward band, headed by Drow weapons and
/// armor. Healing and stat draught budgets are roughly half the generic pool.
/datum/loot_table/dungeon/drow/tier2
	name = "drow dungeon spoils (mid)"
	donor_types = list(
		/datum/loot_table/medium = 35,
		/datum/loot_table/coin/med = 30,
		/datum/loot_table/potion_vitals = 6,
		/datum/loot_table/potion_stats = 5,
	)
	loot_table = list(
		list(
			/obj/item/weapon/sword/short/iron = 6,
			/obj/item/weapon/axe/iron = 6,
			/obj/item/clothing/armor/chainmail/iron = 4,
			/obj/item/clothing/pants/chainlegs/iron = 4,
			/obj/item/alch/herb/salvia = 4,
			/obj/item/alch/herb/valeriana = 4,
			/obj/item/weapon/whip = 10,
			/obj/item/weapon/sword/sabre/stalker = 8,
			/obj/item/weapon/knife/dagger/steel/dirk = 8,
			/obj/item/clothing/armor/leather/jacket/silk_coat = 7,
			/obj/item/clothing/shirt/shadowshirt = 6,
			/obj/item/clothing/pants/trou/shadowpants = 6,
			/obj/item/clothing/gloves/fingerless/shadowgloves = 6,
		),
		/datum/attribute/skill/misc/stealing = list(
			/obj/item/gem/green = 6,
			/obj/item/gem/blue = 6,
			/obj/item/lockpick = 8,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/gold = 8,
			/obj/item/gem = 4,
			/obj/item/gem/violet = 4,
		),
	)
	base_min = 2
	base_max = 4
	scaling_factor = 0.2

/// Floor 5+: deep generic rewards remain possible, while the best Drow arms
/// dominate the pool. Strong restoratives and magic accessories are scarcer.
/datum/loot_table/dungeon/drow/tier3
	name = "drow dungeon spoils (deep)"
	donor_types = list(
		/datum/loot_table/rare = 40,
		/datum/loot_table/coin/high = 30,
		/datum/loot_table/potion_stats = 5,
	)
	donor_exclude = list(/obj/item/coin/gold/pile)
	loot_table = list(
		list(
			/obj/item/weapon/sword/long/greatsword = 3,
			/obj/item/clothing/armor/plate = 3,
			/obj/item/reagent_containers/glass/bottle/stronghealthpot = 0.5,
			/obj/item/reagent_containers/glass/bottle/strongmanapot = 0.5,
			/obj/item/clothing/ring/active/nomag = 2,
			/obj/item/clothing/ring/gold/protection = 1,
			/obj/item/clothing/neck/talkstone = 1,
			/obj/item/clothing/head/crown/circlet/stink = 0.5,
			/obj/item/weapon/whip = 10,
			/obj/item/weapon/whip/spiderwhip = 5,
			/obj/item/weapon/sword/sabre/stalker = 9,
			/obj/item/weapon/knife/dagger/steel/dirk = 8,
			/obj/item/clothing/armor/leather/jacket/silk_coat = 8,
			/obj/item/clothing/shirt/shadowshirt = 6,
			/obj/item/clothing/pants/trou/shadowpants = 6,
			/obj/item/clothing/gloves/fingerless/shadowgloves = 6,
		),
		STAT_FORTUNE = list(
			/obj/item/coin/silver/pile = 6,
			/obj/item/gem = 6,
			/obj/item/gem/violet = 5,
		),
	)
	base_min = 3
	base_max = 4
	scaling_factor = 0.2
