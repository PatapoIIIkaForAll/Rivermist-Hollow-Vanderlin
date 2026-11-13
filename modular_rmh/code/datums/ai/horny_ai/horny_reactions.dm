// Temper and lust: how a hunter answers what its target does. Handlers only write keys; the hunt acts on them.

/// Feeds a reaction into a running hunt. Strength is damage for hits, else a count. TRUE when it applied.
/datum/ai_controller/proc/horny_react(reaction, atom/source, strength = 0)
	var/mob/living/hunter = pawn
	if(!istype(hunter) || isnull(blackboard[BB_HORNY_TIME_START]))
		return FALSE
	var/mob/living/target = blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]
	var/datum/horny_family_profile/profile = hunter.get_horny_family_profile()
	var/went_lethal = FALSE
	switch(reaction)
		if(HORNY_REACT_HIT)
			add_horny_temper(strength * HORNY_TEMPER_PER_DAMAGE * profile.pain_factor)
			if(source == target)
				went_lethal = note_horny_target_damage(hunter, target, strength)
		if(HORNY_REACT_RANGED_HIT)
			add_horny_temper(HORNY_TEMPER_RANGED_HIT * profile.pain_factor)
			if(source == target)
				went_lethal = note_horny_target_damage(hunter, target, strength)
			// A bolt or a fireball brings the hunter on faster, not slower.
			if(!went_lethal && profile.pain_factor > 0)
				set_blackboard_key(BB_HORNY_RUSH_UNTIL, world.time + HORNY_RUSH_TIME)
				hunter.Immobilize(HORNY_FLINCH_TIME)
				hunter.visible_message(span_danger(profile.get_flinch_message(hunter, source)))
		if(HORNY_REACT_GRAB_BROKEN)
			add_horny_temper(HORNY_TEMPER_GRAB_BROKEN)
		if(HORNY_REACT_SHOVED_OFF)
			add_horny_temper(HORNY_TEMPER_SHOVED_OFF)
		if(HORNY_REACT_CLENCH)
			add_horny_temper(HORNY_TEMPER_CLENCH)
			add_horny_lust(HORNY_LUST_PER_CLENCH)
		if(HORNY_REACT_YIELD)
			set_blackboard_key(BB_HORNY_TEMPER, 0)
			set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)
		if(HORNY_REACT_TEASE)
			add_horny_lust(HORNY_LUST_PER_TEASE)
		if(HORNY_REACT_SEDUCE)
			add_horny_lust(HORNY_LUST_PER_SEDUCE)
		if(HORNY_REACT_EDGE)
			add_horny_lust(HORNY_LUST_PER_EDGE)
		if(HORNY_REACT_CLIMAX)
			add_horny_lust(HORNY_LUST_PER_CLIMAX)
	SEND_SIGNAL(hunter, COMSIG_HORNY_REACTION, reaction, source, strength)
	return TRUE

/datum/ai_controller/proc/add_horny_temper(amount)
	decay_horny_temper()
	var/temper = clamp((blackboard[BB_HORNY_TEMPER] || 0) + amount, 0, HORNY_TEMPER_MAX)
	set_blackboard_key(BB_HORNY_TEMPER, temper)
	return temper

/datum/ai_controller/proc/add_horny_lust(amount)
	var/lust = clamp((blackboard[BB_HORNY_LUST] || 0) + amount, 0, HORNY_LUST_MAX)
	set_blackboard_key(BB_HORNY_LUST, lust)
	return lust

/// Temper cools with time; called before every read.
/datum/ai_controller/proc/decay_horny_temper()
	var/last_time = blackboard[BB_HORNY_TEMPER_TIME]
	if(isnull(last_time))
		set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)
		return
	var/elapsed = (world.time - last_time) / 10
	if(elapsed <= 0)
		return
	var/temper = max(0, (blackboard[BB_HORNY_TEMPER] || 0) - elapsed * HORNY_TEMPER_DECAY_PER_SECOND)
	set_blackboard_key(BB_HORNY_TEMPER, temper)
	set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)

/// Counts damage from the hunted target. Past the budget the hunt ends and a real fight begins; TRUE when it did.
/datum/ai_controller/proc/note_horny_target_damage(mob/living/hunter, mob/living/target, damage)
	if(!target || !(damage > 0))
		return FALSE
	var/total = (blackboard[BB_HORNY_TARGET_DAMAGE] || 0) + damage
	set_blackboard_key(BB_HORNY_TARGET_DAMAGE, total)
	var/budget = max(hunter.maxHealth, 1)
	var/lethal = total >= budget * HORNY_LETHAL_DAMAGE_SHARE
	if(!lethal && hunter.get_ai_hurt_fraction() >= HORNY_LETHAL_HURT_FRACTION && total >= budget * HORNY_LETHAL_HURT_DAMAGE_SHARE)
		lethal = TRUE
	if(!lethal)
		return FALSE
	turn_hunt_into_fight(hunter, target)
	return TRUE

/// Mortal danger beats lust: drop the hunt and treat the attacker as a threat.
/datum/ai_controller/proc/turn_hunt_into_fight(mob/living/hunter, atom/attacker)
	var/datum/targetting_datum/targetting_datum = blackboard[BB_TARGETTING_DATUM]
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker, world.time)
	targetting_datum?.set_horny_target_hostile(hunter, attacker)
	set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, attacker)
	var/atom/potential_hiding_location = targetting_datum?.find_hidden_mobs(hunter, attacker)
	if(potential_hiding_location)
		set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, potential_hiding_location)
	else
		clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	hunt.stop_active_horny_actions(hunter)
	clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
	CancelActions()

/// Hits on the hunter: the target's blows feed temper, a packmate's are ignored, anyone else is a threat.
/datum/ai_behavior/horny/proc/on_attacked(mob/living/source, atom/attacker, damage)
	SIGNAL_HANDLER
	if(!source?.ai_controller || !attacker)
		return
	if(attacker == source || QDELETED(attacker) || isturf(attacker))
		return
	if(ismob(attacker))
		var/mob/M = attacker
		if(M.status_flags & GODMODE || M.stat == DEAD)
			return
	if(source.see_invisible < attacker.invisibility)
		return

	var/datum/ai_controller/controller = source.ai_controller
	var/atom/current_horny_target = controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]
	if(attacker == current_horny_target)
		var/ranged = controller.blackboard[BB_LAST_RANGED_ATTACKER] == attacker && controller.blackboard[BB_LAST_RANGED_HIT_TIME] == world.time
		controller.horny_react(ranged ? HORNY_REACT_RANGED_HIT : HORNY_REACT_HIT, attacker, damage || 0)
		return
	if(isliving(attacker) && source.kidnap_is_packmate(attacker))
		return
	controller.turn_hunt_into_fight(source, attacker)

/// The hunter's own climax feeds its lust.
/datum/ai_behavior/horny/proc/on_hunter_climax(mob/living/source, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer)
	SIGNAL_HANDLER
	var/mob/living/partner = action_target == source ? action_initiator : action_target
	source.ai_controller?.horny_react(HORNY_REACT_CLIMAX, partner, 1)
	bark(source.ai_controller, source, partner, HORNY_BARK_ACT_CLIMAX)
