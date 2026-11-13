// The numbing silk-venom most spiders bite with, and the habits element every spider kind shares.

/// Sent by a spider whose melee bite landed: (mob/living/victim).
#define COMSIG_SPIDER_BITE_LANDED "spider_bite_landed"
/// Units of numbing venom one bite injects.
#define WEAK_VENOM_BITE_UNITS 2
/// A bite never tops the numbing venom up past this.
#define WEAK_VENOM_MAX_UNITS 4
/// Cycles between numbing rolls.
#define WEAK_VENOM_ROLL_CYCLES 4
/// Units a resisted roll purges.
#define WEAK_VENOM_RESIST_PURGE 0.5
/// Units one shake-off through Resist purges.
#define WEAK_VENOM_SHAKE_PURGE 1
/// Arousal the tingling skin adds each cycle.
#define WEAK_VENOM_AROUSAL 0.5

/// Habits every spider kind shares: web-walking and the numbing bite.
/datum/element/spider_habits
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Percent chance a landed bite injects numbing venom; 0 for none.
	var/venom_chance = 0

/datum/element/spider_habits/Attach(datum/target, venom_chance = 0)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.venom_chance = venom_chance
	ADD_TRAIT(target, TRAIT_WEBWALK, ELEMENT_TRAIT(type))
	if(venom_chance > 0)
		RegisterSignal(target, COMSIG_SPIDER_BITE_LANDED, PROC_REF(on_bite_landed))

/datum/element/spider_habits/Detach(datum/source, ...)
	REMOVE_TRAIT(source, TRAIT_WEBWALK, ELEMENT_TRAIT(type))
	UnregisterSignal(source, COMSIG_SPIDER_BITE_LANDED)
	return ..()

/datum/element/spider_habits/proc/on_bite_landed(mob/living/source, mob/living/victim)
	SIGNAL_HANDLER
	if(prob(venom_chance))
		inject_numbing_venom(victim)

/// Tells the spider's habits that its bite landed on [victim]; the hunt's pounce calls it too.
/mob/living/proc/spider_bite_landed(mob/living/victim)
	SEND_SIGNAL(src, COMSIG_SPIDER_BITE_LANDED, victim)

/// One bite of numbing venom, never past the cap; returns the units added.
/proc/inject_numbing_venom(mob/living/victim)
	if(!iscarbon(victim) || !victim.reagents)
		return 0
	var/held = victim.reagents.get_reagent_amount(/datum/reagent/toxin/spidervenom_paralytic/weak)
	var/dose = min(WEAK_VENOM_BITE_UNITS, WEAK_VENOM_MAX_UNITS - held)
	if(dose <= 0)
		return 0
	victim.reagents.add_reagent(/datum/reagent/toxin/spidervenom_paralytic/weak, dose)
	return dose

/// A mild venom: the legs go heavy now and then, never full paralysis, and it fades within a minute.
/datum/reagent/toxin/spidervenom_paralytic/weak
	name = "Numbing Silk-Venom"
	description = "A mild spider venom that weighs the legs down and leaves the skin tingling."
	reagent_state = LIQUID
	color = "#c48fb0"
	taste_description = "sweet numbness"
	// With the default quality's faster rate, 2 u last about 40 s of 2 s life ticks.
	metabolization_rate = 0.08
	/// TRUE while a shake-off is under way.
	var/shaking_off = FALSE

/datum/reagent/toxin/spidervenom_paralytic/weak/on_mob_metabolize(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_LIVING_RESIST, PROC_REF(on_resist))
	to_chat(L, span_love("My skin tingles."))

/datum/reagent/toxin/spidervenom_paralytic/weak/on_mob_end_metabolize(mob/living/L)
	UnregisterSignal(L, COMSIG_LIVING_RESIST)
	return ..()

/datum/reagent/toxin/spidervenom_paralytic/weak/venom_tick(mob/living/carbon/M, efficiency)
	if(QDELETED(src))
		return
	SEND_SIGNAL(M, COMSIG_SEX_ADJUST_AROUSAL, WEAK_VENOM_AROUSAL * efficiency)
	if(current_cycle % WEAK_VENOM_ROLL_CYCLES)
		return
	if(prob(venom_resistance))
		holder?.remove_reagent(type, WEAK_VENOM_RESIST_PURGE)
		return
	M.Immobilize(3 SECONDS)
	to_chat(M, span_warning("A warm heaviness spreads down my legs."))

/datum/reagent/toxin/spidervenom_paralytic/weak/proc/on_resist(mob/living/source)
	SIGNAL_HANDLER
	if(shaking_off)
		return
	// A tick later, so cuffs, grabs and silk get the resist first.
	addtimer(CALLBACK(src, PROC_REF(try_shake_off), source), 1)

/// Works 1 u of venom loose over 4 s, unless the resist went to something else.
/datum/reagent/toxin/spidervenom_paralytic/weak/proc/try_shake_off(mob/living/victim)
	if(shaking_off || QDELETED(victim) || victim.doing() || victim.pulledby || victim.buckled || !isturf(victim.loc))
		return
	shaking_off = TRUE
	to_chat(victim, span_notice("I fight the numbness, flexing my legs."))
	var/shook = do_after(victim, 4 SECONDS, timed_action_flags = IGNORE_USER_DIR_CHANGE|IGNORE_HELD_ITEM, interaction_key = "spider_venom")
	if(QDELETED(src))
		return
	shaking_off = FALSE
	if(!shook || !holder)
		return
	to_chat(victim, span_notice("Feeling creeps back into my legs."))
	holder.remove_reagent(type, WEAK_VENOM_SHAKE_PURGE)

// The summoned companion bites clean and makes no honey.
/mob/living/simple_animal/hostile/retaliate/spider/companion
	bite_venom_chance = 0
	makes_honey = FALSE

#undef COMSIG_SPIDER_BITE_LANDED
#undef WEAK_VENOM_BITE_UNITS
#undef WEAK_VENOM_MAX_UNITS
#undef WEAK_VENOM_ROLL_CYCLES
#undef WEAK_VENOM_RESIST_PURGE
#undef WEAK_VENOM_SHAKE_PURGE
#undef WEAK_VENOM_AROUSAL
