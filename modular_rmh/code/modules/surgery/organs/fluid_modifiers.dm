/// Stateless tweak to filling organ output; a mob holds active ones by type, each with string sources.
/datum/fluid_modifier
	/// Organ slots this applies to; null applies to every filling organ.
	var/list/affected_slots
	/// Multiplies units produced per second.
	var/rate_multiplier = 1
	/// Multiplies how much the organ can hold.
	var/capacity_multiplier = 1
	/// Multiplies nutrition spent per unit produced.
	var/nutrition_cost_multiplier = 1
	/// Multiplies passive leaking.
	var/leak_multiplier = 1
	/// Multiplies fluid released on climax.
	var/climax_multiplier = 1
	/// Makes a dormant organ produce, e.g. lactation.
	var/forces_production = FALSE
	/// Stops production; wins over forces_production.
	var/blocks_production = FALSE
	/// Multiplies the chance that seed held in this organ conceives.
	var/conception_multiplier = 1
	/// Multiplies the virility of seed this organ gives.
	var/virility_multiplier = 1
	/// Lets a vagina's own wetness fill all free room instead of stopping at its small lube reserve.
	var/lifts_wetness_cap = FALSE

/datum/fluid_modifier/proc/affects(obj/item/organ/genitals/filling_organ/organ)
	return !affected_slots || (organ.slot in affected_slots)

/datum/fluid_modifier/induced_lactation
	affected_slots = list(ORGAN_SLOT_BREASTS)
	forces_production = TRUE
	rate_multiplier = 1.5

/datum/fluid_modifier/pregnancy_lactation
	affected_slots = list(ORGAN_SLOT_BREASTS)
	forces_production = TRUE

/datum/fluid_modifier/fluid_surge
	rate_multiplier = 2
	climax_multiplier = 1.5
	lifts_wetness_cap = TRUE

/datum/fluid_modifier/fluid_ebb
	rate_multiplier = 0.5
	climax_multiplier = 0.5

/datum/fluid_modifier/fluid_drought
	blocks_production = TRUE

/datum/fluid_modifier/extra_productive
	rate_multiplier = 1.5

/// Species build: big bodies hold more.
/datum/fluid_modifier/large_frame
	capacity_multiplier = 1.5

/// Species build: small bodies hold less.
/datum/fluid_modifier/small_frame
	capacity_multiplier = 0.75

/// Species trait: seed comes faster.
/datum/fluid_modifier/prolific_seed
	affected_slots = list(ORGAN_SLOT_TESTICLES)
	rate_multiplier = 1.5

/datum/fluid_modifier/in_heat
	rate_multiplier = 1.5
	climax_multiplier = 1.25

/// Moon Tea: seed held in the womb or rear rarely takes.
/datum/fluid_modifier/barren_womb
	affected_slots = list(ORGAN_SLOT_WOMB, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
	conception_multiplier = CONTRACEPTIVE_MULTIPLIER

/// Cold Seed draught: seed given while it works rarely takes.
/datum/fluid_modifier/cold_seed
	affected_slots = list(ORGAN_SLOT_TESTICLES)
	virility_multiplier = CONTRACEPTIVE_MULTIPLIER

GLOBAL_LIST_INIT(fluid_modifiers, init_fluid_modifiers())

/proc/init_fluid_modifiers()
	. = list()
	for(var/modifier_type in subtypesof(/datum/fluid_modifier))
		.[modifier_type] = new modifier_type

/mob/living
	/// Active fluid modifier types, each mapped to a list of source strings.
	var/list/fluid_modifier_sources
	/// Organ slot mapped to the reagent type that organ makes instead of its own fluid.
	var/list/fluid_reagent_overrides

/// Makes the organ in the slot produce the given reagent; a later swap on the same slot replaces it.
/mob/living/proc/set_fluid_reagent_override(slot, datum/reagent/reagent_type)
	LAZYSET(fluid_reagent_overrides, slot, reagent_type)

/// Ends a swap only if it is still the given one, so a replaced swap cannot end its successor.
/mob/living/proc/clear_fluid_reagent_override(slot, datum/reagent/reagent_type)
	if(LAZYACCESS(fluid_reagent_overrides, slot) == reagent_type)
		LAZYREMOVE(fluid_reagent_overrides, slot)

/// Adds a source for a fluid modifier; the modifier stays active while any source remains.
/mob/living/proc/add_fluid_modifier(modifier_type, source)
	if(!ispath(modifier_type, /datum/fluid_modifier) || !istext(source))
		CRASH("add_fluid_modifier needs a modifier type and a text source, got [modifier_type] / [source]")
	LAZYORASSOCLIST(fluid_modifier_sources, modifier_type, source)

/mob/living/proc/remove_fluid_modifier(modifier_type, source)
	LAZYREMOVEASSOC(fluid_modifier_sources, modifier_type, source)

/mob/living/proc/has_fluid_modifier(modifier_type, source = null)
	var/list/sources = LAZYACCESS(fluid_modifier_sources, modifier_type)
	if(!sources)
		return FALSE
	if(isnull(source))
		return TRUE
	return (source in sources)

/// Returns the active modifiers that apply to the given organ, or null.
/mob/living/proc/get_fluid_modifiers(obj/item/organ/genitals/filling_organ/organ)
	for(var/modifier_type in fluid_modifier_sources)
		var/datum/fluid_modifier/modifier = GLOB.fluid_modifiers[modifier_type]
		if(modifier.affects(organ))
			LAZYADD(., modifier)
