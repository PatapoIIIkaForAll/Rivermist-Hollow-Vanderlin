///Datum for basic mobs to define what they can attack.
/proc/is_ai_disarmable_held_item(obj/item/held_item)
	if(!held_item)
		return FALSE
	if(held_item.item_flags & (ABSTRACT | DROPDEL))
		return FALSE
	if(HAS_TRAIT(held_item, TRAIT_NODROP))
		return FALSE
	return TRUE

/proc/mob_has_ai_disarmable_held_item(mob/living/living_target)
	if(!living_target)
		return FALSE

	for(var/obj/item/held_item as anything in living_target.held_items)
		if(is_ai_disarmable_held_item(held_item))
			return TRUE

	return FALSE

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

/datum/targetting_datum/proc/is_selected_horny_target(mob/living/living_mob, atom/target)
	if(!should_prioritize_horny_targets(living_mob))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(!can_use_horny_ai_target(living_mob, human_target))
			return FALSE
	return is_horny_pref_target(living_mob, target)

/datum/targetting_datum/proc/can_engage_target(mob/living/living_mob, atom/target)
	return can_attack(living_mob, target) || should_disarm(living_mob, target)

/datum/targetting_datum/proc/can_quickly_engage_target(mob/living/living_mob, atom/target)
	return can_engage_target(living_mob, target)

/datum/targetting_datum/proc/is_horny_mob_family_allowed(mob/living/living_mob, mob/living/carbon/human/human_target)
	if(!living_mob || !human_target)
		return FALSE

	var/family_flag = living_mob.ai_controller?.horny_pref_family_flag
	if(!family_flag)
		return FALSE
	if(!should_apply_mob_erp_target_pref(living_mob, human_target))
		return FALSE

	var/allowed_families = human_target.get_cached_horny_mob_family_flags()
	return !!(allowed_families & family_flag)

/datum/targetting_datum/proc/get_horny_mob_pref_flags(mob/living/carbon/human/human_target)
	if(!human_target)
		return NONE
	return human_target.get_cached_horny_mob_pref_flags()

/datum/targetting_datum/proc/has_any_horny_mob_pref_enabled(mob/living/carbon/human/human_target)
	return !!get_horny_mob_pref_flags(human_target)

/datum/targetting_datum/proc/can_use_horny_ai_target(mob/living/living_mob, mob/living/carbon/human/human_target)
	if(!living_mob || !human_target)
		return FALSE
	return !!human_target.client

/datum/targetting_datum/proc/should_use_nonlethal_mob_erp_handling(mob/living/living_mob, mob/living/carbon/human/human_target)
	if(!living_mob || !human_target)
		return FALSE
	if(!can_use_horny_ai_target(living_mob, human_target))
		return FALSE
	if(!should_apply_mob_erp_target_pref(living_mob, human_target))
		return FALSE
	if(!human_target.get_cached_nonmatching_horny_mobs_are_nonlethal())
		return FALSE
	if(!has_any_horny_mob_pref_enabled(human_target))
		return FALSE
	if(is_selected_horny_target(living_mob, human_target))
		return FALSE

	return TRUE

/datum/targetting_datum/proc/can_nonlethally_subdue_mob_erp_target(mob/living/living_mob, mob/living/carbon/human/human_target)
	if(!should_use_nonlethal_mob_erp_handling(living_mob, human_target))
		return FALSE
	if(HAS_TRAIT(human_target, TRAIT_PACIFISM))
		return FALSE
	if(human_target.surrendering)
		return FALSE
	if(human_target.body_position == LYING_DOWN)
		return FALSE
	return TRUE

/datum/targetting_datum/proc/get_active_other_sex_participant(mob/living/target_living, mob/living/excluded_participant)
	if(!target_living)
		return null

	for(var/datum/sex_action/action as anything in target_living.sex_scene?.get_actions_involving(target_living))
		if(QDELETED(action))
			continue

		var/mob/living/other_participant = action.action_user == target_living ? action.action_target : action.action_user
		if(!other_participant || QDELETED(other_participant))
			continue
		if(other_participant == target_living || other_participant == excluded_participant)
			continue

		return other_participant

	return null

/datum/targetting_datum/proc/is_protected_by_active_mob_sex(mob/living/living_mob, atom/target)
	if(!isliving(target))
		return FALSE

	var/mob/living/target_living = target
	if(!should_apply_mob_erp_target_pref(living_mob, target_living))
		return FALSE

	var/mob/living/other_participant = get_active_other_sex_participant(target_living, living_mob)
	if(!other_participant || other_participant.client)
		return FALSE

	return TRUE

/datum/targetting_datum/proc/set_horny_target_hostile(mob/living/living_mob, atom/target, duration)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller || !is_selected_horny_target(living_mob, target))
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

	var/list/retaliate_list = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if(retaliate_list && !isnull(retaliate_list[target]))
		controller.remove_thing_from_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST, target)

	var/list/aggro_table = controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(aggro_table && !isnull(aggro_table[target]))
		aggro_table -= target

	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == target)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

	if(controller.blackboard[BB_HIGHEST_THREAT_MOB] == target)
		controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)

	return TRUE

/datum/targetting_datum/proc/should_release_horny_target_hostility(mob/living/living_mob, mob/living/target_living)
	if(!living_mob || !target_living)
		return FALSE
	if(!is_selected_horny_target(living_mob, target_living))
		return FALSE
	if(target_living.body_position == LYING_DOWN)
		return TRUE
	if(target_living.has_status_effect(/datum/status_effect/debuff/mob_fucked) || target_living.has_status_effect(/datum/status_effect/debuff/mob_fucked/male))
		return TRUE
	if(get_active_other_sex_participant(target_living, living_mob))
		return TRUE

	return FALSE

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

	if(isliving(target))
		var/mob/living/target_living = target
		if(should_release_horny_target_hostility(living_mob, target_living))
			clear_horny_target_hostility(living_mob, target_living)
			return FALSE

	if(!isnull(hostile_until))
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

/datum/targetting_datum/basic/can_quickly_engage_target(mob/living/living_mob, atom/the_target)
	if(isturf(the_target) || !the_target)
		return FALSE
	var/mob/living/simple_animal/attacker = living_mob
	if(istype(attacker))
		if(attacker.binded == TRUE)
			return FALSE

	if(ismob(the_target))
		var/mob/mob_target = the_target
		if(mob_target.status_flags & GODMODE)
			return FALSE

	if(living_mob.see_invisible < the_target.invisibility)
		return FALSE

	if(HAS_TRAIT(the_target, TRAIT_IMPERCEPTIBLE))
		return FALSE

	if(!isturf(the_target.loc))
		return FALSE

	if(!isliving(the_target))
		return FALSE

	var/mob/living/living_target = the_target
	if(living_target.stat >= DEAD)
		return FALSE
	if(is_horny_target_now_hostile(living_mob, living_target))
		return TRUE
	if(faction_check(living_mob, living_target))
		return FALSE
	if(should_prioritize_horny_targets(living_mob) && is_selected_horny_target(living_mob, living_target))
		return FALSE

	var/can_attack_target = TRUE
	if(HAS_TRAIT(living_target, TRAIT_PACIFISM) || living_target.surrendering)
		can_attack_target = FALSE

	if(ishuman(living_target))
		var/mob/living/carbon/human/human_target = living_target
		if(human_target.handcuffed)
			return FALSE
		if((human_target.body_position == LYING_DOWN) && mob_has_ai_disarmable_held_item(human_target) && human_target.ckey)
			return TRUE

	if((living_target.body_position == LYING_DOWN) && !living_target.get_active_held_item() && living_target.ckey && !living_target.cmode)
		return FALSE

	return can_attack_target

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

		if(L.stat >= DEAD) //basic targetting doesn't target dead people
			return FALSE
		if(is_protected_by_active_mob_sex(living_mob, L))
			return FALSE
		if(is_horny_target_now_hostile(living_mob, L))
			return TRUE
		if(faction_check(living_mob, L))
			return FALSE
		if(ishuman(L) && should_use_nonlethal_mob_erp_handling(living_mob, L))
			return FALSE
		var/list/retaliate_list = living_mob.ai_controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(should_prioritize_horny_targets(living_mob) && retaliate_list && !isnull(retaliate_list[L]))
			if(retaliate_list[L] + 2 MINUTES >= world.time)
				return TRUE
			living_mob.ai_controller.remove_thing_from_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST, L)
		var/is_selected_horny_match = is_selected_horny_target(living_mob, L)
		if(is_selected_horny_match || HAS_TRAIT(L, TRAIT_PACIFISM) || L.surrendering)
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
	// A captive who has steeled themselves (the "Refuse Advances" opt-out) is off-limits to horny mobs.
	if(HAS_TRAIT(the_target, TRAIT_DEFEAT_REFUSE_ADVANCES))
		return FALSE
	// Someone just freed from a cocoon or a lair keeps their grace from every horny mob.
	var/mob/living/spared = the_target
	if(istype(spared) && world.time < spared.kidnap_protected_until)
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
	if(isliving(the_target))
		var/mob/living/living_target = the_target
		if(living_target.alpha <= 100 || living_target.rogue_sneaking)
			return FALSE
	if(living_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isturf(the_target.loc) && living_mob.z != the_target.z)
		return FALSE

	if(ishuman(the_target))
		var/mob/living/carbon/human/th = the_target
		if(is_horny_target_now_hostile(living_mob, th))
			return FALSE
		// Lair set piece: one denizen at a time takes up with a captive NPC of its own pack.
		var/datum/component/npc_in_distress/distress = th.GetComponent(/datum/component/npc_in_distress)
		if(distress)
			return distress.can_be_claimed_by(living_mob)

		if(!is_selected_horny_target(living_mob, th))
			return FALSE
		// Allies are off-limits unless an order pointed this mob at them.
		if(faction_check(living_mob, th, ignore_neutral = TRUE) && !is_directed_horny_target(living_mob, th))
			return FALSE
		return TRUE
	return FALSE

/// TRUE while a pet order's target is still this mob's horny target.
/datum/targetting_datum/proc/is_directed_horny_target(mob/living/living_mob, atom/target)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller || !target)
		return FALSE
	if(controller.blackboard[BB_HORNY_DIRECTED_TARGET] != target)
		return FALSE
	return controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == target

/datum/targetting_datum/basic/is_horny_pref_target(mob/living/living_mob, atom/target)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	if(!is_horny_mob_family_allowed(living_mob, human_target))
		return FALSE

	var/mobs_flags = get_horny_mob_pref_flags(human_target)
	if(!mobs_flags)
		return FALSE

	return (((mobs_flags & HORNY_MOBS_TAG_MALES) && living_mob.gender == MALE) || ((mobs_flags & HORNY_MOBS_TAG_FEMALES) && living_mob.gender == FEMALE))

/// ignore_neutral: the shared Neutral placeholder alone is no alliance.
/datum/targetting_datum/basic/proc/faction_check(mob/living/living_mob, mob/living/the_target, ignore_neutral = FALSE)
	if(!living_mob || !the_target)
		return FALSE
	if((living_mob in SSmatthios_mobs.matthios_mobs) && (the_target in SSmatthios_mobs.matthios_mobs))
		return TRUE
	return living_mob.ai_targeting_ally_check(the_target, ignore_neutral)

/// Subtype which doesn't care about faction
/// Mobs which retaliate but don't otherwise target seek should just attack anything which annoys them
/datum/targetting_datum/basic/ignore_faction

/datum/targetting_datum/basic/ignore_faction/faction_check(mob/living/living_mob, mob/living/the_target, ignore_neutral = FALSE)
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
		if(is_protected_by_active_mob_sex(living_mob, L))
			return FALSE
		if(faction_check(living_mob, L) || L.stat >= DEAD) //basic targetting doesn't target dead people
			return FALSE
		if(ishuman(L))
			var/mob/living/carbon/human/hum = L
			if(should_use_nonlethal_mob_erp_handling(living_mob, hum))
				return can_nonlethally_subdue_mob_erp_target(living_mob, hum)
			if(hum.handcuffed)
				return FALSE
		if((L.body_position == LYING_DOWN) && mob_has_ai_disarmable_held_item(L) && L.ckey)
			return TRUE

	return FALSE
