/// AI hurt fraction (pain included) that also counts as reaching the breaking point.
#define NPC_BREAK_HURT_FRACTION 0.75
/// Range at which a packmate that still fights makes an NPC less willing to yield.
#define NPC_BREAK_ALLY_RANGE 5
/// Yield chance multiplier while such a packmate is in view.
#define NPC_BREAK_ALLY_YIELD_MULT 0.5
/// How long an unbound NPC stays yielded before it gets up and fights again.
#define NPC_YIELD_DURATION (45 SECONDS)
/// A captive no player has seen for this long is removed.
#define NPC_CAPTIVE_CLEANUP_TIME (10 MINUTES)
#define NPC_CAPTIVE_CLEANUP_RECHECK (30 SECONDS)
/// A routed NPC is removed on the first check that finds no player watching.
#define NPC_ROUT_CHECK_INTERVAL (2 SECONDS)
/// Damage a forced death tops the corpse up to, so it stays down.
#define NPC_DEATH_DAMAGE_FLOOR 200

/mob/living/carbon/human
	/// Damage score at which this NPC rolls to yield or run. Null: it never breaks.
	var/npc_break_damage = null
	/// Percent chance to yield at the breaking point.
	var/npc_yield_chance = 0
	/// Percent chance to run at the breaking point. Rolled after the yield chance.
	var/npc_flee_chance = 0
	/// Damage score at which this NPC dies outright. Null: only the normal death rules apply.
	var/npc_death_damage = null
	/// Set once the breaking point roll is made; cleared when the NPC heals back below it.
	var/npc_break_rolled = FALSE

/// Damage the breaking point and forced death read. Limb brute and burn count half.
/mob/living/carbon/human/proc/get_npc_damage_score()
	return (getBruteLoss() + getFireLoss()) * 0.5 + getToxLoss() + getOxyLoss()

/mob/living/carbon/human/proc/npc_check_breaking_point()
	if(QDELETED(src) || stat == DEAD || client || mind?.key || (status_flags & GODMODE))
		return
	var/damage = get_npc_damage_score()
	if(npc_death_damage && damage >= npc_death_damage)
		npc_damage_death(damage)
		return
	if(!npc_break_damage)
		return
	if(damage < npc_break_damage && get_ai_hurt_fraction() < NPC_BREAK_HURT_FRACTION)
		npc_break_rolled = FALSE
		return
	if(!npc_break_rolled)
		npc_roll_breaking_point()

/mob/living/carbon/human/proc/npc_roll_breaking_point()
	npc_break_rolled = TRUE
	if(has_status_effect(/datum/status_effect/npc_yield) || has_status_effect(/datum/status_effect/npc_routed))
		return
	// Pets fight for their owner; lair captives and spent mobs already have their own state.
	if(GetComponent(/datum/component/obeys_commands) || GetComponent(/datum/component/npc_in_distress) || has_status_effect(/datum/status_effect/mob_horny_knockout))
		return
	var/yield_chance = npc_yield_chance
	if(yield_chance && npc_has_fighting_ally())
		yield_chance *= NPC_BREAK_ALLY_YIELD_MULT
	var/roll = rand(1, 100)
	if(roll <= yield_chance)
		apply_status_effect(/datum/status_effect/npc_yield)
	else if(roll <= yield_chance + npc_flee_chance)
		apply_status_effect(/datum/status_effect/npc_routed)

/// TRUE when a packmate that still fights can see this NPC.
/mob/living/carbon/human/proc/npc_has_fighting_ally()
	for(var/mob/living/ally in view(NPC_BREAK_ALLY_RANGE, src))
		if(ally == src || ally.stat != CONSCIOUS || ally.client)
			continue
		if(ally.has_status_effect(/datum/status_effect/npc_yield) || ally.has_status_effect(/datum/status_effect/npc_routed))
			continue
		if(kidnap_is_packmate(ally))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/npc_damage_death(damage)
	death(FALSE)
	if(stat != DEAD)
		return
	visible_message(span_danger("[src] dies!"))
	// Topped up only once dead, so the health update it sends cannot loop back here.
	if(damage < NPC_DEATH_DAMAGE_FLOOR)
		adjustOxyLoss(NPC_DEATH_DAMAGE_FLOOR - damage)

/// Runs the breaking point and forced death checks on every health update of an NPC.
/datum/element/npc_breaking_point

/datum/element/npc_breaking_point/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

/datum/element/npc_breaking_point/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_HEALTH_UPDATE)

/datum/element/npc_breaking_point/proc/on_health_update(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/carbon/human, npc_check_breaking_point))

/// A beaten NPC kneels and stops fighting. Bonds put on it now are accepted until removed.
/datum/status_effect/npc_yield
	id = "npc_yield"
	duration = NPC_YIELD_DURATION
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	remove_on_fullheal = TRUE
	/// Arms bound while yielding: the timer stops until the bonds come off.
	var/captive = FALSE
	var/cleanup_timer

/datum/status_effect/npc_yield/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	// A bare status change is undone by the next z-level or pause update; the trait holds it off.
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, TRAIT_STATUS_EFFECT(id))
	owner.ai_controller?.set_ai_status(AI_STATUS_OFF)
	// Surrendering also halves tie and strip times and stops bleeding.
	owner.surrendering = TRUE
	owner.drop_all_grabs()
	owner.drop_all_held_items()
	owner.show_surrender_flag()
	owner.visible_message(span_notice("[owner] yields, too beaten to fight on!"))
	playsound(owner, 'sound/misc/surrender.ogg', 100, FALSE, -1)
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_bound))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), PROC_REF(on_unbound))
	if(HAS_TRAIT(owner, TRAIT_RESTRAINED))
		become_captive()

/datum/status_effect/npc_yield/on_remove()
	if(cleanup_timer)
		deltimer(cleanup_timer)
		cleanup_timer = null
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED)))
	if(!QDELETED(owner))
		REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
		REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
		REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
		REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
		REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, TRAIT_STATUS_EFFECT(id))
		owner.surrendering = FALSE
		// Leg bonds can outlast the arm bonds; whatever is still on stays accepted.
		owner.remember_docile_restraints()
		owner.ai_controller?.set_ai_status(owner.ai_controller.get_expected_ai_status())
	return ..()

/datum/status_effect/npc_yield/proc/on_bound(datum/source)
	SIGNAL_HANDLER
	become_captive()

/datum/status_effect/npc_yield/proc/on_unbound(datum/source)
	SIGNAL_HANDLER
	if(captive)
		qdel(src)

/datum/status_effect/npc_yield/proc/become_captive()
	if(captive)
		return
	captive = TRUE
	duration = STATUS_EFFECT_PERMANENT
	STOP_PROCESSING(SSprocessing, src)
	owner.remember_docile_restraints()
	cleanup_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_check)), NPC_CAPTIVE_CLEANUP_TIME, TIMER_STOPPABLE)

/datum/status_effect/npc_yield/proc/cleanup_check()
	cleanup_timer = null
	if(QDELETED(owner))
		return
	if(owner.mob_horny_ko_players_nearby())
		cleanup_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_check)), NPC_CAPTIVE_CLEANUP_RECHECK, TIMER_STOPPABLE)
		return
	qdel(owner)

/// A beaten NPC runs from its target and is removed once no player can see it.
/datum/status_effect/npc_routed
	id = "npc_routed"
	tick_interval = NPC_ROUT_CHECK_INTERVAL
	alert_type = null

/datum/status_effect/npc_routed/on_apply()
	. = ..()
	if(!.)
		return
	if(!owner.ai_controller)
		return FALSE
	owner.ai_controller.CancelActions()
	owner.ai_controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, TRUE)
	owner.visible_message(span_warning("[owner] breaks and runs!"))

/datum/status_effect/npc_routed/tick()
	if(owner.stat == DEAD)
		qdel(src)
		return
	if(!owner.mob_horny_ko_players_nearby())
		qdel(owner)

/datum/status_effect/npc_routed/on_remove()
	if(!QDELETED(owner))
		owner.ai_controller?.set_blackboard_key(BB_BASIC_MOB_FLEEING, FALSE)
	return ..()

#undef NPC_BREAK_HURT_FRACTION
#undef NPC_BREAK_ALLY_RANGE
#undef NPC_BREAK_ALLY_YIELD_MULT
#undef NPC_YIELD_DURATION
#undef NPC_CAPTIVE_CLEANUP_TIME
#undef NPC_CAPTIVE_CLEANUP_RECHECK
#undef NPC_ROUT_CHECK_INTERVAL
#undef NPC_DEATH_DAMAGE_FLOOR
