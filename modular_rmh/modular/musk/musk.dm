/datum/quirk/neutral/smell_and_musk
	name = "Smell & Musk"
	desc = "My body runs hot. Hard toil soaks me through, and what it leaves on my skin is no common sweat but a heavy, heady musk that clings to my armpits, my groin and my hair, and turns the heads of those with a nose for such things."
	desc_hint = "The harder I labour, the stronger I smell, in four degrees; every quarter-hour of rest softens it by one, and water washes it all away. Those who answer to it, with Musk Susceptibility in their ERP preferences, grow dizzy and dull-witted near me and cannot cool their wanting. My sweat gathers in my armpits, my crotch and between my cheeks, twice as fast where hair grows, ready to be pressed into a face or licked away. The bloodless never sweat."
	preview_render = FALSE

/datum/quirk/neutral/smell_and_musk/on_spawn()
	. = ..()
	owner?.AddComponent(/datum/component/musk)

/datum/quirk/neutral/smell_and_musk/on_remove()
	if(!QDELETED(owner))
		owner.remove_status_effect(/datum/status_effect/musk)
		qdel(owner.GetComponent(/datum/component/musk))
	return ..()

/datum/erp_preference/boolean/musk_susceptibility
	name = "Musk Susceptibility"
	description = "The rank, heady musk of a body worked to a sweat. Near someone with the Smell & Musk quirk it goes to your head, dulls your wits and keeps you wanting, and their sweat-soaked armpits, crotch and cheeks can be pressed into your face or licked clean. A press also makes you climax, up to twice in a row."
	default_value = FALSE
	category = "General"

/datum/component/musk
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/musk_sweat/sweat
	var/energy_spent = 0
	var/next_level_cost = 0

/datum/component/musk/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	sweat = new(parent)

/datum/component/musk/Destroy(force)
	QDEL_NULL(sweat)
	return ..()

/datum/component/musk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ENERGY_SPENT, PROC_REF(on_energy_spent))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_wash))

/datum/component/musk/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_ENERGY_SPENT, COMSIG_COMPONENT_CLEAN_ACT))

/datum/component/musk/proc/can_sweat()
	var/mob/living/carbon/human/owner = parent
	if(owner.stat == DEAD)
		return FALSE
	if(NOBLOOD in owner.dna?.species?.species_traits)
		return FALSE
	return owner.blood_volume > 0

/datum/component/musk/proc/roll_level_cost()
	var/mob/living/carbon/human/owner = parent
	return max(owner.max_energy, 1) * rand(MUSK_LEVEL_COST_MIN_PERCENT, MUSK_LEVEL_COST_MAX_PERCENT) / 100

/datum/component/musk/proc/on_energy_spent(datum/source, amount)
	SIGNAL_HANDLER
	if(amount <= 0 || !can_sweat())
		return
	if(!next_level_cost)
		next_level_cost = roll_level_cost()
	energy_spent += amount
	var/levels_gained = 0
	while(energy_spent >= next_level_cost && levels_gained < MUSK_LEVEL_MAX)
		energy_spent -= next_level_cost
		next_level_cost = roll_level_cost()
		levels_gained++
		work_up_musk()

/datum/component/musk/proc/work_up_musk()
	var/mob/living/carbon/human/owner = parent
	sweat.add_layer()
	var/datum/status_effect/musk/musk = owner.has_status_effect(/datum/status_effect/musk)
	if(musk)
		musk.strengthen()
		return
	owner.apply_status_effect(/datum/status_effect/musk, 1)

/datum/component/musk/proc/on_wash(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & (CLEAN_WASH | CLEAN_SCRUB | CLEAN_ALL)))
		return
	var/mob/living/carbon/human/owner = parent
	energy_spent = 0
	var/washed = sweat.wash()
	if(owner.remove_status_effect(/datum/status_effect/musk))
		washed = TRUE
	if(washed)
		to_chat(owner, span_notice(musk_wash_text(owner)))

/datum/musk_sweat
	var/mob/living/carbon/human/owner
	var/list/stacks

/datum/musk_sweat/New(mob/living/carbon/human/new_owner)
	owner = new_owner
	stacks = list(
		MUSK_ZONE_ARMPITS = 0,
		MUSK_ZONE_GROIN = 0,
		MUSK_ZONE_BUTT = 0,
	)

/datum/musk_sweat/Destroy(force)
	owner = null
	return ..()

/datum/musk_sweat/proc/get_stacks(zone)
	return stacks[zone] || 0

/datum/musk_sweat/proc/get_hair_level(zone)
	var/feature_slot
	switch(zone)
		if(MUSK_ZONE_ARMPITS)
			feature_slot = BODYPART_FEATURE_ARMPIT_HAIR
		if(MUSK_ZONE_GROIN)
			feature_slot = BODYPART_FEATURE_PUBIC_HAIR
	if(!feature_slot || QDELETED(owner))
		return HAIRINESS_SHAVED
	var/datum/bodypart_feature/hair/body_hair/hair = owner.get_bodypart_feature_of_slot(feature_slot)
	return hair ? hair.current_level : HAIRINESS_SHAVED

/datum/musk_sweat/proc/get_quality(zone)
	var/hair_level = get_hair_level(zone)
	if(hair_level >= HAIRINESS_HAIRY)
		return MUSK_QUALITY_VERY_HAIRY
	if(hair_level >= HAIRINESS_SOME_HAIR)
		return MUSK_QUALITY_HAIRY
	return MUSK_QUALITY_BARE

/datum/musk_sweat/proc/get_tier(zone)
	var/tier = get_stacks(zone)
	if(get_quality(zone) == MUSK_QUALITY_VERY_HAIRY)
		tier += 1
	return clamp(tier, 1, MUSK_TIER_MAX)

/datum/musk_sweat/proc/add_layer()
	for(var/zone in stacks)
		var/gain = get_quality(zone) >= MUSK_QUALITY_HAIRY ? MUSK_SWEAT_HAIRY_GAIN : MUSK_SWEAT_BARE_GAIN
		stacks[zone] = min(stacks[zone] + gain, MUSK_SWEAT_MAX_STACKS)

/datum/musk_sweat/proc/wipe(zone)
	if(!(zone in stacks))
		return 0
	. = stacks[zone]
	stacks[zone] = 0

/datum/musk_sweat/proc/wash()
	. = FALSE
	for(var/zone in stacks)
		if(stacks[zone])
			. = TRUE
			stacks[zone] = 0

/mob/living/proc/get_musk_sweat()
	RETURN_TYPE(/datum/musk_sweat)
	var/datum/component/musk/musk = GetComponent(/datum/component/musk)
	return musk?.sweat

/mob/living/carbon/human/proc/is_musk_susceptible()
	return get_erp_pref(/datum/erp_preference/boolean/musk_susceptibility) == TRUE

/mob/living/carbon/human/proc/smell_musk(level, mob/living/source)
	if(stat != CONSCIOUS || !can_smell() || HAS_TRAIT(src, TRAIT_NOBREATH) || HAS_TRAIT(src, TRAIT_DEADNOSE))
		return FALSE
	return take_musk_hit(level, source)

/mob/living/carbon/human/proc/take_musk_hit(level, mob/living/source, silent = FALSE)
	var/datum/status_effect/debuff/musk_haze/haze = has_status_effect(/datum/status_effect/debuff/musk_haze)
	if(haze && haze.level >= level)
		// The same scent keeps the haze going, with no new screen effect or message.
		if(haze.level == level && is_musk_susceptible())
			haze.refresh()
		return FALSE
	if(!is_musk_susceptible())
		return FALSE
	if(haze)
		return haze.intensify(level, silent, source)
	return !!apply_status_effect(/datum/status_effect/debuff/musk_haze, level, silent, source)
