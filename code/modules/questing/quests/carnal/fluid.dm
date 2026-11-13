/// Bring a creature's own seed or nectar back to the ledger.
/datum/quest/kill/carnal/fluid
	quest_type = QUEST_FLUID_HARVEST
	mob_types_to_spawn = QUEST_CARNAL_FLUID_LIST
	count_min = 1
	count_max = 2
	minimum_tier = QUEST_TIER_ROUTINE
	maximum_tier = QUEST_TIER_DEADLY
	/// QUEST_FLUID_SEED or QUEST_FLUID_NECTAR.
	var/fluid_kind
	/// The creature's main seed or nectar, which names the contract.
	var/datum/reagent/required_fluid_type
	/// The creature's whole load as reagent type = share; the main fluid's share sizes the load.
	var/list/required_fluid_mix
	var/units_required = 0

/datum/quest/kill/carnal/fluid/build_title()
	if(!target_mob_type)
		return "Harvest a creature's fluids"
	return "Harvest [initial(target_mob_type.name)] [fluid_kind == QUEST_FLUID_NECTAR ? "nectar" : "seed"]"

/datum/quest/kill/carnal/fluid/get_objective_text()
	var/fluid_name = get_required_fluid_name()
	var/source_hint = fluid_kind == QUEST_FLUID_NECTAR ? "Bring her to climax over a container" : "Milk him into a container, or take his load and expel it into a bottle"
	return "Bring [units_required] units of [fluid_name] in containers to the contract ledger, carried or on the marked area beside it, then turn the contract in. [source_hint]."

/datum/quest/kill/carnal/fluid/prepare_for_issuer(mob/living/carbon/human/issuer)
	..()
	fluid_kind = pick_fluid_kind()

/datum/quest/kill/carnal/fluid/is_visible_to(mob/living/carbon/human/viewer)
	if(!..())
		return FALSE
	var/needed_tag = fluid_kind == QUEST_FLUID_NECTAR ? HORNY_MOBS_TAG_FEMALES : HORNY_MOBS_TAG_MALES
	return !!(viewer.get_cached_horny_mob_pref_flags() & needed_tag)

/datum/quest/kill/carnal/fluid/proc/pick_fluid_kind()
	var/list/kinds = list()
	if(isnull(allowed_gender_tags) || (allowed_gender_tags & HORNY_MOBS_TAG_MALES))
		kinds += QUEST_FLUID_SEED
	if(isnull(allowed_gender_tags) || (allowed_gender_tags & HORNY_MOBS_TAG_FEMALES))
		kinds += QUEST_FLUID_NECTAR
	return length(kinds) ? pick(kinds) : QUEST_FLUID_SEED

/datum/quest/kill/carnal/fluid/generate(obj/effect/landmark/quest_spawner/landmark)
	if(!fluid_kind)
		fluid_kind = pick_fluid_kind()
	return ..()

/datum/quest/kill/carnal/fluid/pick_spawn_gender()
	return fluid_kind == QUEST_FLUID_NECTAR ? FEMALE : MALE

/datum/quest/kill/carnal/fluid/on_targets_spawned()
	required_fluid_type = null
	required_fluid_mix = null
	// Fluid lists are invisible to initial(), so a spawned creature is read instead.
	for(var/datum/weakref/target_ref as anything in tracked_atoms)
		var/mob/living/creature = target_ref.resolve()
		required_fluid_type = get_creature_fluid_type(creature, fluid_kind)
		if(required_fluid_type)
			required_fluid_mix = fluid_kind == QUEST_FLUID_NECTAR ? creature.get_femcum_mix() : creature.get_cum_mix()
			break
	if(!required_fluid_type)
		return FALSE
	units_required = get_units_for_tier(requested_tier)
	progress_required = 1
	return TRUE

/// Sized so one creature's starting load covers the contract; refills only speed it up.
/datum/quest/kill/carnal/fluid/proc/get_units_for_tier(tier)
	switch(tier)
		if(QUEST_TIER_ROUTINE)
			return 6
		if(QUEST_TIER_RISKY)
			return 10
		if(QUEST_TIER_DANGEROUS)
			return 14
	return 18

/datum/quest/kill/carnal/fluid/get_reward_multiplier()
	return QUEST_FLUID_REWARD_MULTIPLIER

/datum/quest/kill/carnal/fluid/get_task_reward_bonus()
	return units_required * QUEST_FLUID_REWARD_PER_UNIT

/// The load the ledger counts, as reagent type = share; the main fluid alone when nothing is mixed in.
/datum/quest/kill/carnal/fluid/proc/get_required_mix()
	if(length(required_fluid_mix))
		return required_fluid_mix
	return required_fluid_type ? normalize_fluid_mix(required_fluid_type) : null

/// The contract's fluid by name, with any mixed-in extras: "Honeyed Seed, honey and all".
/datum/quest/kill/carnal/fluid/proc/get_required_fluid_name()
	if(!required_fluid_type)
		return "creature fluid"
	var/list/extra_names = list()
	for(var/datum/reagent/reagent_type as anything in get_required_mix())
		if(reagent_type != required_fluid_type)
			extra_names += LOWER_TEXT(initial(reagent_type.name))
	if(!length(extra_names))
		return initial(required_fluid_type.name)
	return "[initial(required_fluid_type.name)], [english_list(extra_names)] and all"

/datum/quest/kill/carnal/fluid/proc/get_turn_in_containers(turf/input_point, mob/user)
	. = list()
	if(!required_fluid_type)
		return
	for(var/obj/item/reagent_containers/container as anything in find_turn_in_goods(input_point, user, /obj/item/reagent_containers))
		if(container.reagents?.get_reagent_amount(required_fluid_type) > 0)
			. += container

/// Load units the containers hold, judged by the main fluid; mixed-in extras never count alone.
/datum/quest/kill/carnal/fluid/proc/count_units(list/containers)
	var/list/mix = get_required_mix()
	var/main_share = mix?[required_fluid_type]
	if(!main_share)
		return 0
	. = 0
	for(var/obj/item/reagent_containers/container as anything in containers)
		. += container.reagents.get_reagent_amount(required_fluid_type)
	if(main_share < 1)
		// A float share could read an exact load a hair short.
		. = round(. / main_share, 0.01)

/datum/quest/kill/carnal/fluid/uses_turn_in_goods()
	return TRUE

/datum/quest/kill/carnal/fluid/has_turn_in_goods(turf/input_point, mob/user)
	return count_units(get_turn_in_containers(input_point, user)) >= units_required

/datum/quest/kill/carnal/fluid/get_turn_in_goods_report(turf/input_point, mob/user)
	var/fluid_name = get_required_fluid_name()
	var/units_found = round(count_units(get_turn_in_containers(input_point, user)), 0.1)
	return "The ledger counts [units_found] of [units_required] units of [fluid_name] in containers on its marked area and on you."

/datum/quest/kill/carnal/fluid/try_collect_turn_in_goods(turf/input_point, mob/user)
	var/list/containers = get_turn_in_containers(input_point, user)
	if(count_units(containers) < units_required)
		return FALSE
	// The ledger keeps the whole load: the main fluid, and the extras that came with it.
	var/list/mix = get_required_mix()
	for(var/reagent_type in mix)
		var/units_left = units_required * mix[reagent_type]
		for(var/obj/item/reagent_containers/container as anything in containers)
			var/taken = min(units_left, container.reagents.get_reagent_amount(reagent_type))
			container.reagents.remove_reagent(reagent_type, taken)
			units_left -= taken
			if(units_left <= 0)
				break
	progress_current = progress_required
	mark_complete()
	return TRUE

/// The main seed or nectar reagent a creature makes, or null if it has no creature fluid.
/proc/get_creature_fluid_type(mob/living/creature, fluid_kind)
	if(!isliving(creature))
		return null
	var/list/mix = fluid_kind == QUEST_FLUID_NECTAR ? creature.get_femcum_mix() : creature.get_cum_mix()
	var/fluid_type = length(mix) ? mix[1] : null
	if(ispath(fluid_type, /datum/reagent/consumable/cum/creature) || ispath(fluid_type, /datum/reagent/consumable/femcum/creature))
		return fluid_type
	return null
