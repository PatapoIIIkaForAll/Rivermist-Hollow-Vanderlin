// Potion and salve modifiers on an opening; the datum reads them through these hooks.

/// Soreness one fresh application of rosewater salve takes away at once.
#define ROSEWATER_SOOTHE 30
/// Share of the stretch past rest that is left after the ring clenches down.
#define CLENCH_KEEP_SHARE 0.3

/// Stateless tweak to an opening; a mob holds active ones by type, each with text sources.
/datum/orifice_modifier
	/// Organ slots this applies to; null applies to the vagina and the anus both.
	var/list/affected_slots
	/// Tightness steps added to the rest girth; negative is tighter.
	var/rest_step_shift = 0
	/// Added to the comfort elasticity.
	var/elasticity_bonus = 0
	/// Added to max_ratio, in rest girths.
	var/max_ratio_bonus = 0
	/// Multiplies recovery speed; 2 halves the half-life.
	var/recovery_multiplier = 1
	/// Multiplies how fast soreness fades.
	var/soreness_decay_multiplier = 1
	/// Holds a gape open whatever the girth.
	var/gape_lock = FALSE

/datum/orifice_modifier/proc/affects(obj/item/organ/organ)
	return !affected_slots || (organ?.slot in affected_slots)

/datum/orifice_modifier/yielding
	rest_step_shift = 1

/datum/orifice_modifier/maidens_knot
	rest_step_shift = -1
	recovery_multiplier = 2

/datum/orifice_modifier/limber
	elasticity_bonus = 0.3
	max_ratio_bonus = 0.5

/// Counts while rosewater salve sits inside the opening; no mob ever holds it.
/datum/orifice_modifier/rosewater
	recovery_multiplier = 4
	soreness_decay_multiplier = 3

/datum/orifice_modifier/gape_lock
	abstract_type = /datum/orifice_modifier/gape_lock
	gape_lock = TRUE

/datum/orifice_modifier/gape_lock/vagina
	affected_slots = list(ORGAN_SLOT_VAGINA)

/datum/orifice_modifier/gape_lock/anus
	affected_slots = list(ORGAN_SLOT_ANUS)

GLOBAL_LIST_INIT(orifice_modifiers, init_orifice_modifiers())

/proc/init_orifice_modifiers()
	. = list()
	for(var/datum/orifice_modifier/modifier_type as anything in subtypesof(/datum/orifice_modifier))
		if(!IS_ABSTRACT(modifier_type))
			.[modifier_type] = new modifier_type

/mob/living
	/// Active orifice modifier types, each mapped to a list of text sources.
	var/list/orifice_modifier_sources

/// Adds a source for an orifice modifier; the modifier stays active while any source remains.
/mob/living/proc/add_orifice_modifier(modifier_type, source)
	if(!ispath(modifier_type, /datum/orifice_modifier) || !istext(source))
		CRASH("add_orifice_modifier needs a modifier type and a text source, got [modifier_type] / [source]")
	LAZYORASSOCLIST(orifice_modifier_sources, modifier_type, source)

/mob/living/proc/remove_orifice_modifier(modifier_type, source)
	LAZYREMOVEASSOC(orifice_modifier_sources, modifier_type, source)

/mob/living/proc/has_orifice_modifier(modifier_type)
	return !!LAZYACCESS(orifice_modifier_sources, modifier_type)

/// Active modifiers that touch [organ], or every active one without it; null when none.
/mob/living/proc/get_orifice_modifiers(obj/item/organ/organ)
	for(var/modifier_type in orifice_modifier_sources)
		var/datum/orifice_modifier/modifier = GLOB.orifice_modifiers[modifier_type]
		if(modifier && (!organ || modifier.affects(organ)))
			LAZYADD(., modifier)

/// The vagina and anus openings of this mob; [create] also makes datums not yet in use.
/mob/living/proc/get_orifices(create = FALSE)
	. = list()
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		var/obj/item/organ/genitals/filling_organ/hole = getorganslot(slot)
		if(!istype(hole) || !hole.orifice_type)
			continue
		var/datum/orifice/orifice = hole.get_orifice(create)
		if(orifice)
			. += orifice

/datum/orifice
	/// Status that holds this opening's gape open for a while.
	var/gape_lock_status_type

/datum/orifice/vagina
	gape_lock_status_type = /datum/status_effect/debuff/orifice_gape_lock/vagina

/datum/orifice/anus
	gape_lock_status_type = /datum/status_effect/debuff/orifice_gape_lock/anus

/// Modifiers on this opening: the owner's draughts plus a salve worked into it; null when none.
/datum/orifice/proc/get_active_modifiers()
	. = get_owner()?.get_orifice_modifiers(organ)
	if(has_lube_effect(/datum/reagent/lubricant/rosewater))
		LAZYADD(., GLOB.orifice_modifiers[/datum/orifice_modifier/rosewater])

/// Index of the tightness step nearest the chargen rest girth.
/datum/orifice/proc/get_rest_step_index()
	var/list/steps = rest_steps
	. = 1
	for(var/i in 2 to length(steps))
		if(abs(steps[i] - rest_girth) < abs(steps[.] - rest_girth))
			. = i

/// Rest girth change in centimetres from active modifiers.
/datum/orifice/proc/get_modifier_rest_shift()
	// Every girth read passes here, so salve worked in by any path soothes promptly.
	update_salve_soothing()
	var/step_shift = 0
	for(var/datum/orifice_modifier/modifier as anything in get_active_modifiers())
		step_shift += modifier.rest_step_shift
	var/list/steps = rest_steps
	if(!step_shift || !length(steps))
		return 0
	var/index = get_rest_step_index()
	return steps[clamp(index + step_shift, 1, length(steps))] - steps[index]

/// Comfort elasticity added by active modifiers.
/datum/orifice/proc/get_modifier_elasticity()
	. = 0
	for(var/datum/orifice_modifier/modifier as anything in get_active_modifiers())
		. += modifier.elasticity_bonus

/// Added to max_ratio by active modifiers.
/datum/orifice/proc/get_modifier_max_ratio()
	. = 0
	for(var/datum/orifice_modifier/modifier as anything in get_active_modifiers())
		. += modifier.max_ratio_bonus

/// Recovery speed multiplier from active modifiers; 2 halves the half-life.
/datum/orifice/proc/get_recovery_multiplier()
	. = 1
	for(var/datum/orifice_modifier/modifier as anything in get_active_modifiers())
		. *= modifier.recovery_multiplier

/// Soreness decay multiplier from active modifiers.
/datum/orifice/proc/get_soreness_decay_multiplier()
	. = 1
	for(var/datum/orifice_modifier/modifier as anything in get_active_modifiers())
		. *= modifier.soreness_decay_multiplier

/// TRUE while something holds the gape open regardless of girth.
/datum/orifice/proc/has_gape_lock()
	for(var/datum/orifice_modifier/modifier as anything in get_active_modifiers())
		if(modifier.gape_lock)
			return TRUE
	return FALSE

/// The ring clenches down: the current girth snaps most of the way to rest and a gape ends.
/datum/orifice/proc/clench_down()
	recover_girth()
	var/rest = get_rest_girth()
	current_girth = rest + max(0, current_girth - rest) * CLENCH_KEEP_SHARE
	last_update = world.time
	gape_strain = 0
	last_gape_strain_update = world.time
	set_gaped(FALSE)
	// The clench breaks any draught holding this gape open.
	if(gape_lock_status_type)
		get_owner()?.remove_status_effect(gape_lock_status_type)
	after_girth_change()

/// Forces a gape open and keeps it for [duration].
/datum/orifice/proc/force_gape(duration)
	recover_girth()
	current_girth = max(current_girth, gape_ratio * get_rest_girth())
	last_update = world.time
	var/mob/living/owner = get_owner()
	if(owner && gape_lock_status_type)
		owner.apply_status_effect(gape_lock_status_type, duration)
	gape_strain = ORIFICE_GAPE_STRAIN_MAX
	last_gape_strain_update = world.time
	set_gaped(TRUE)
	after_girth_change()

/// Each fresh application of rosewater salve soothes the opening once, as soon as it is read.
/datum/orifice/proc/update_salve_soothing()
	if(!has_lube_effect(/datum/reagent/lubricant/rosewater))
		return
	var/datum/reagent/lubricant/rosewater/salve = organ.reagents.get_reagent(/datum/reagent/lubricant/rosewater)
	if(!salve || salve.soothed)
		return
	salve.soothed = TRUE
	var/soreness_before = get_soreness()
	soothe_soreness(ROSEWATER_SOOTHE)
	var/mob/living/owner = get_owner()
	if(owner && soreness_before > 0)
		to_chat(owner, span_notice("The rosewater salve cools my sore [opening_name]."))

/// Takes [amount] off the soreness at once and settles the soreness state.
/datum/orifice/proc/soothe_soreness(amount)
	get_soreness()
	soreness = max(0, soreness - amount)
	// Each update moves one state, so three settle even Overused down to Fine.
	for(var/i in 1 to 3)
		update_soreness_state()

#undef ROSEWATER_SOOTHE
#undef CLENCH_KEEP_SHARE
