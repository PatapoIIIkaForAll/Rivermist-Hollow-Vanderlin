///Datum for basic mobs to define what they can attack.
/datum/targetting_datum

///Returns true or false depending on if the target can be attacked by the mob
/datum/targetting_datum/proc/can_attack(mob/living/living_mob, atom/target)
	return

///Returns true or false depending on if the target can be used by horny AI
/datum/targetting_datum/proc/can_horny(mob/living/living_mob, atom/target)
	return FALSE

/datum/targetting_datum/proc/get_horny_hostility_duration(mob/living/living_mob)
	return 5 MINUTES

/datum/targetting_datum/proc/is_horny_pref_target(mob/living/living_mob, atom/target)
	return FALSE

/datum/targetting_datum/proc/set_horny_target_hostile(mob/living/living_mob, atom/target, duration)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller || !should_prioritize_horny_targets(living_mob) || !is_horny_pref_target(living_mob, target))
		return FALSE

	if(isnull(duration))
		duration = get_horny_hostility_duration(living_mob)

	var/hostile_until = world.time + duration
	var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	if(hostile_targets && !isnull(hostile_targets[target]))
		hostile_targets[target] = max(hostile_targets[target], hostile_until)
	else
		controller.add_blackboard_key_assoc_lazylist(BB_HORNY_HOSTILE_TARGETS, target, hostile_until)

	controller.set_blackboard_key(BB_HORNY_AGGRO_TARGET, target)
	return TRUE

/datum/targetting_datum/proc/clear_horny_target_hostility(mob/living/living_mob, atom/target)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller || !target)
		return FALSE

	var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	if(hostile_targets && !isnull(hostile_targets[target]))
		controller.remove_thing_from_blackboard_key(BB_HORNY_HOSTILE_TARGETS, target)

	if(controller.blackboard[BB_HORNY_AGGRO_TARGET] == target)
		controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)

	return TRUE

/datum/targetting_datum/proc/is_horny_target_now_hostile(mob/living/living_mob, atom/target)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller)
		return FALSE

	var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	var/hostile_until = hostile_targets ? hostile_targets[target] : null
	if(!isnull(hostile_until))
		if(QDELETED(target) || hostile_until < world.time)
			controller.remove_thing_from_blackboard_key(BB_HORNY_HOSTILE_TARGETS, target)
			if(controller.blackboard[BB_HORNY_AGGRO_TARGET] == target)
				controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)
			return FALSE
		return TRUE

	if(controller.blackboard[BB_HORNY_AGGRO_TARGET] != target)
		return FALSE

	var/list/retaliate_list = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	var/retaliate_time = retaliate_list ? retaliate_list[target] : null
	if(QDELETED(target) || isnull(retaliate_time) || retaliate_time + 2 MINUTES < world.time)
		controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)
		return FALSE

	return TRUE

/// Returns true if this targetting datum should let horny AI pre-empt combat targeting.
/datum/targetting_datum/proc/should_prioritize_horny_targets(mob/living/living_mob)
	return FALSE

///Returns something the target might be hiding inside of
/datum/targetting_datum/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	if(!target)
		return
	var/atom/target_hiding_location
	if(istype(target.loc, /obj/structure/closet))
		target_hiding_location = target.loc
	return target_hiding_location

/datum/targetting_datum/basic

/datum/targetting_datum/basic/can_attack(mob/living/living_mob, atom/the_target)
	if(isturf(the_target) || !the_target ) // bail out on invalids
		return FALSE
	var/mob/living/simple_animal/attacker = living_mob
	if(istype(attacker))
		if(attacker.binded == TRUE)
			return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(living_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(HAS_TRAIT(the_target, TRAIT_IMPERCEPTIBLE))
		return FALSE

	if(!isturf(the_target.loc))
		return FALSE

	if(isliving(the_target)) //Targetting vs living mobs
		var/mob/living/L = the_target

		var/matches_horny_pref = is_horny_pref_target(living_mob, L)
		if(L.stat >= DEAD) //basic targetting doesn't target dead people
			return FALSE
		if(is_horny_target_now_hostile(living_mob, L))
			return TRUE
		if(faction_check(living_mob, L))
			return FALSE
		var/list/retaliate_list = living_mob.ai_controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(should_prioritize_horny_targets(living_mob) && retaliate_list && !isnull(retaliate_list[L]))
			if(retaliate_list[L] + 2 MINUTES >= world.time)
				return TRUE
			living_mob.ai_controller.remove_thing_from_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST, L)
		if(matches_horny_pref || HAS_TRAIT(L, TRAIT_PACIFISM) || L.surrendering)
			return FALSE
		if((L.body_position == LYING_DOWN) && !L.get_active_held_item() && L.ckey && !L.cmode) //if is laying and holding nothing, and not in cmode. Ignore.
			return FALSE
		if(ishuman(L))
			var/mob/living/carbon/human/hum = L
			if(hum.handcuffed)
				return FALSE
		return TRUE

	return FALSE

/datum/targetting_datum/basic/can_horny(mob/living/living_mob, atom/the_target)
	if(isturf(the_target) || !the_target) // bail out on invalids
		return FALSE
	if(issimple(living_mob))
		var/mob/living/simple_animal/attacker = living_mob
		if(attacker.binded == TRUE)
			return FALSE
	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE
		if(M.stat == DEAD)
			return FALSE
	if(living_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isturf(the_target.loc) && living_mob.z != the_target.z)
		return FALSE

	if(ishuman(the_target))
		var/mob/living/carbon/human/th = the_target
		if(is_horny_target_now_hostile(living_mob, th))
			return FALSE

		if(is_horny_pref_target(living_mob, th))
			return TRUE
	return FALSE

/datum/targetting_datum/basic/is_horny_pref_target(mob/living/living_mob, atom/target)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	var/mobs_flags = human_target.client?.prefs?.erp_preferences[/datum/erp_preference/bitflag/horny_mobs]
	if(!mobs_flags)
		return FALSE

	return (((mobs_flags & HORNY_MOBS_TAG_MALES) && living_mob.gender == MALE) || ((mobs_flags & HORNY_MOBS_TAG_FEMALES) && living_mob.gender == FEMALE))

/datum/targetting_datum/basic/proc/faction_check(mob/living/living_mob, mob/living/the_target)
	if((living_mob in SSmatthios_mobs.matthios_mobs) && (the_target in SSmatthios_mobs.matthios_mobs))
		return TRUE
	return living_mob.faction_check_mob(the_target, exact_match = FALSE)

/// Subtype which doesn't care about faction
/// Mobs which retaliate but don't otherwise target seek should just attack anything which annoys them
/datum/targetting_datum/basic/ignore_faction

/datum/targetting_datum/basic/ignore_faction/faction_check(mob/living/living_mob, mob/living/the_target)
	return FALSE

/datum/targetting_datum/basic/zizoid/can_attack(mob/living/living_mob, atom/the_target)
	if(isliving(the_target))
		var/mob/living/target = the_target
		if(target.mind?.has_antag_datum(/datum/antagonist/zizocultist))
			return FALSE
	. = ..()

/datum/targetting_datum/basic/should_prioritize_horny_targets(mob/living/living_mob)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller)
		return FALSE
	return locate(/datum/ai_planning_subtree/horny) in controller.planning_subtrees

///Returns true or false depending on if the target can be attacked by the mob
/datum/targetting_datum/proc/should_disarm(mob/living/living_mob, atom/target)
	return


/datum/targetting_datum/basic/should_disarm(mob/living/living_mob, atom/the_target)
	if(isturf(the_target) || !the_target ) // bail out on invalids
		return FALSE
	var/mob/living/simple_animal/attacker = living_mob
	if(istype(attacker))
		if(attacker.binded == TRUE)
			return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(living_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(HAS_TRAIT(the_target, TRAIT_IMPERCEPTIBLE))
		return FALSE

	if(!isturf(the_target.loc))
		return FALSE

	if(isliving(the_target)) //Targetting vs living mobs
		var/mob/living/L = the_target
		if(faction_check(living_mob, L) || L.stat >= DEAD) //basic targetting doesn't target dead people
			return FALSE
		if(ishuman(L))
			var/mob/living/carbon/human/hum = L
			if(hum.handcuffed)
				return FALSE
		if((L.body_position == LYING_DOWN) && L.get_active_held_item() && L.ckey) //if is laying and holding nothing, and not in cmode. Ignore.
			return TRUE

	return FALSE
