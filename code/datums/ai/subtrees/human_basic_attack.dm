#define HUMAN_NPC_BASE_JUKE_CHANCE              15
#define HUMAN_NPC_JUKE_MIN_SPD                  10
#define HUMAN_NPC_JUKE_PER_OVERSPD              5
#define HUMAN_NPC_WEAKPOINT_BASE_SCAN_CHANCE    20
#define HUMAN_NPC_WEAKPOINT_PERCEPTION_SCALE    5
#define HUMAN_NPC_WEAKPOINT_SNEAK_SCALE         5
#define HUMAN_NPC_WEAKPOINT_FORTUNE_SCALE       2
#define HUMAN_NPC_WEAKPOINT_MIN_SCAN_CHANCE     5
#define HUMAN_NPC_WEAKPOINT_MAX_SCAN_CHANCE     80
#define HUMAN_NPC_WEAKPOINT_AIM_CHANCE          65
#define HUMAN_NPC_WEAKPOINT_SCAN_COOLDOWN       (8 SECONDS)
#define HUMAN_NPC_WEAKPOINT_CACHE_DURATION      (6 SECONDS)
#define HUMAN_NPC_WEAPON_SPECIAL_CHANCE         35
#define HUMAN_NPC_INTENT_SWITCH_CHANCE          25  // chance per attack to start a new intent sequence
#define HUMAN_NPC_RMB_ATTEMPT_CHANCE			25
#define HUMAN_NPC_REACTION_TIME_BASE            (0.35 SECONDS)
#define HUMAN_NPC_REACTION_TIME_MIN             (0.12 SECONDS)
#define HUMAN_NPC_REACTION_PER_STAT_POINT       12
#define HUMAN_NPC_GAP_CLOSE_COOLDOWN            (6 SECONDS)
#define HUMAN_NPC_GAP_CLOSE_MIN_DIST            2
#define HUMAN_NPC_GAP_CLOSE_MAX_DIST            3
#define HUMAN_NPC_GAP_CLOSE_OPEN_CHANCE         20
#define HUMAN_NPC_COMBAT_BARK_COOLDOWN          (3 SECONDS)


//Note alot of this is just adapted from old code so its probably not the best

/proc/human_npc_combat_state_balloon(datum/ai_controller/controller, mob/living/pawn, message, chance = 100)
	if(!controller || !pawn || !message)
		return FALSE
	if(!prob(chance))
		return FALSE
	if(world.time < (controller.blackboard[BB_HUMAN_NPC_COMBAT_BARK_COOLDOWN] || 0))
		return FALSE

	pawn.balloon_alert_to_viewers("<font color='#c7c6c6'>[message]</font>", balloon_flag = DISABLE_BALLOON_COMBAT, y_offset = -8)
	controller.set_blackboard_key(BB_HUMAN_NPC_COMBAT_BARK_COOLDOWN, world.time + HUMAN_NPC_COMBAT_BARK_COOLDOWN)
	return TRUE

/proc/human_npc_ai_turf_blocked_for_walk(turf/checking, atom/movable/mover)
	if(!checking || checking.density || !checking.can_traverse_safely(mover))
		return TRUE
	for(var/atom/movable/blocker in checking)
		if(blocker == mover)
			continue
		if(!blocker.CanPass(mover, checking))
			return TRUE
	return FALSE

/proc/human_npc_gap_close_landing(mob/living/carbon/human/pawn, atom/target)
	var/turf/pawn_turf = get_turf(pawn)
	var/turf/target_turf = get_turf(target)
	if(!pawn_turf || !target_turf)
		return null

	var/turf/landing_turf = get_step(target_turf, get_dir(target_turf, pawn_turf))
	if(!landing_turf || landing_turf == pawn_turf)
		landing_turf = target_turf
	if(get_dist(pawn_turf, landing_turf) < HUMAN_NPC_GAP_CLOSE_MIN_DIST || get_dist(pawn_turf, landing_turf) > HUMAN_NPC_GAP_CLOSE_MAX_DIST)
		return null
	if(human_npc_ai_turf_blocked_for_walk(landing_turf, pawn))
		return null

	var/turf/next_step = get_step_towards(pawn_turf, landing_turf)
	if(human_npc_ai_turf_blocked_for_walk(next_step, pawn))
		return landing_turf
	if(prob(HUMAN_NPC_GAP_CLOSE_OPEN_CHANCE))
		return landing_turf
	return null

/datum/ai_planning_subtree/human_npc_gap_close

/datum/ai_planning_subtree/human_npc_gap_close/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!pawn || QDELETED(target) || !controller.can_move())
		return

	var/datum/targetting_datum/td = controller.blackboard[BB_TARGETTING_DATUM]
	if(!td || !td.can_engage_target(pawn, target))
		return
	if(controller.blackboard[BB_HUMAN_NPC_COMMITTED_SWING_TOKEN])
		return
	if(world.time < (controller.blackboard[BB_HUMAN_NPC_JUMP_COOLDOWN] || 0))
		return
	if(pawn.throwing || pawn.body_position == LYING_DOWN || pawn.incapacitated(IGNORE_GRAB))
		return
	if(pawn.CanReach(target, pawn.get_active_held_item()))
		return
	if(!human_npc_gap_close_landing(pawn, target))
		return

	controller.queue_behavior(/datum/ai_behavior/human_npc_gap_close, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/human_npc_gap_close
	action_cooldown = 0.2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/human_npc_gap_close/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/td = controller.blackboard[targetting_datum_key]
	if(!pawn || QDELETED(target) || !td || !td.can_engage_target(pawn, target) || !controller.can_move())
		finish_action(controller, FALSE)
		return

	var/turf/landing_turf = human_npc_gap_close_landing(pawn, target)
	if(!landing_turf)
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(BB_HUMAN_NPC_JUMP_COOLDOWN, world.time + HUMAN_NPC_GAP_CLOSE_COOLDOWN)
	human_npc_combat_state_balloon(controller, pawn, "vaults in")
	pawn.face_atom(target)
	INVOKE_ASYNC(pawn, TYPE_PROC_REF(/mob/living, jump_action), landing_turf)
	finish_action(controller, TRUE)

/datum/ai_planning_subtree/basic_melee_attack_subtree/human_npc
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/human_npc
	end_planning = TRUE

/datum/ai_behavior/basic_melee_attack/human_npc
	action_cooldown = 0.2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/human_npc/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	var/obj/item/held_item = pawn.get_active_held_item()
	if((!isweapon(held_item)))
		pawn.swap_hand()
		for(var/slot in list(ITEM_SLOT_BACK, ITEM_SLOT_HIP, ITEM_SLOT_BELT_L, ITEM_SLOT_BACK_L, ITEM_SLOT_BACK_R, ITEM_SLOT_BELT_R))
			if(!pawn.get_item_by_slot(slot))
				if(pawn.equip_to_slot_if_possible(held_item, slot, disable_warning = TRUE))
					break

	_try_wield_reach_weapon(pawn)
	_choose_reach_capable_intent(pawn, target)

/datum/ai_behavior/basic_melee_attack/human_npc/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	controller.behavior_cooldowns[src] = world.time + get_cooldown(controller) //we don't wanna call parent tbh
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/td = controller.blackboard[targetting_datum_key]

	var/obj/item/weapon/held_weapon = pawn.get_active_held_item()
	if(!held_weapon)
		for(var/obj/item/weapon/candidate in range(1, pawn))
			if(!isturf(candidate.loc))
				continue
			pawn.put_in_active_hand(candidate)
			break

	if(!td.can_engage_target(pawn, target))
		finish_action(controller, FALSE, target_key)
		return
	if(ismob(target) && target:stat == DEAD)
		finish_action(controller, FALSE, target_key)
		return

	SEND_SIGNAL(pawn, COMSIG_MOB_TRY_BARK)
	var/hiding_target = td.find_hidden_mobs(pawn, target)
	controller.set_blackboard_key(hiding_location_key, hiding_target)

	pawn.face_atom(target)
	_choose_attack_zone(controller, pawn, target)

	if(td.should_disarm(pawn, target) && ishuman(target))
		var/mob/living/carbon/human/h_target = target
		if(attempt_nonlethal_mob_erp_subdue(td, pawn, h_target))
			return

	if(!pawn.CanReach(target, pawn.get_active_held_item()))
		finish_action(controller, FALSE, target_key)
		return

	if(_try_weapon_special(controller))
		return

	_update_combat_intent(controller, pawn, target)
	_choose_reach_capable_intent(pawn, target)
	var/list/modifiers = list()
	var/attempt_rmb = prob(HUMAN_NPC_RMB_ATTEMPT_CHANCE)
	if(attempt_rmb)
		if(pawn.stamina < pawn.maximum_stamina * 0.7 && istype(pawn.rmb_intent, /datum/rmb_intent/feint))
			modifiers = list(RIGHT_CLICK = TRUE)

	var/turf/locked_turf = get_turf(target)
	var/atom/locked_target = target
	var/atom/locked_hiding_target = hiding_target
	var/obj/item/locked_weapon = pawn.get_active_held_item()
	var/list/swing_token = list()
	controller.set_blackboard_key(BB_HUMAN_NPC_COMMITTED_SWING_TOKEN, swing_token)

	var/reaction_time = max(HUMAN_NPC_REACTION_TIME_MIN, HUMAN_NPC_REACTION_TIME_BASE - round((GET_MOB_ATTRIBUTE_VALUE(pawn, STAT_PERCEPTION) + GET_MOB_ATTRIBUTE_VALUE(pawn, STAT_INTELLIGENCE)) / HUMAN_NPC_REACTION_PER_STAT_POINT))
	controller.behavior_cooldowns[src] = world.time + reaction_time + get_cooldown(controller)
	addtimer(CALLBACK(src, PROC_REF(_resolve_committed_swing), controller, target_key, targetting_datum_key, locked_target, locked_turf, locked_hiding_target, locked_weapon, modifiers, attempt_rmb, swing_token), reaction_time)

	return

/datum/ai_behavior/basic_melee_attack/human_npc/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/carbon/human/pawn = controller.pawn
	if(!QDELETED(pawn))
		pawn.cmode = FALSE
	controller.clear_blackboard_key(BB_HUMAN_NPC_COMMITTED_SWING_TOKEN)
	if(!QDELETED(pawn))
		SEND_SIGNAL(pawn, COMSIG_COMBAT_TARGET_SET, FALSE)

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_cancel_committed_swing(datum/ai_controller/controller, target_key)
	if(QDELETED(controller))
		return
	if(LAZYACCESS(controller.current_behaviors, src))
		finish_action(controller, FALSE, target_key)
		return
	controller.clear_blackboard_key(BB_HUMAN_NPC_COMMITTED_SWING_TOKEN)

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_resolve_committed_swing(datum/ai_controller/controller, target_key, targetting_datum_key, atom/locked_target, turf/locked_turf, atom/locked_hiding_target, obj/item/locked_weapon, list/modifiers, attempt_rmb, list/swing_token)
	if(QDELETED(controller))
		return
	if(QDELETED(locked_target))
		_cancel_committed_swing(controller, target_key)
		return
	if(!LAZYACCESS(controller.current_behaviors, src))
		if(controller.blackboard[BB_HUMAN_NPC_COMMITTED_SWING_TOKEN] == swing_token)
			controller.clear_blackboard_key(BB_HUMAN_NPC_COMMITTED_SWING_TOKEN)
		return
	var/mob/living/carbon/human/pawn = controller.pawn
	if(QDELETED(pawn) || controller.pawn != pawn)
		_cancel_committed_swing(controller, target_key)
		return
	if(controller.blackboard[BB_HUMAN_NPC_COMMITTED_SWING_TOKEN] != swing_token)
		return
	if(controller.blackboard[target_key] != locked_target)
		finish_action(controller, FALSE, target_key)
		return

	var/datum/targetting_datum/td = controller.blackboard[targetting_datum_key]
	if(!td || !td.can_engage_target(pawn, locked_target))
		finish_action(controller, FALSE, target_key)
		return
	if(ismob(locked_target) && locked_target:stat == DEAD)
		finish_action(controller, FALSE, target_key)
		return
	if(pawn.get_active_held_item() != locked_weapon)
		finish_action(controller, FALSE, target_key)
		return
	if(pawn.doing() || pawn.throwing || pawn.body_position == LYING_DOWN || pawn.incapacitated(IGNORE_GRAB) || pawn.next_move > world.time)
		finish_action(controller, FALSE, target_key)
		return

	var/swing_reach = pawn.used_intent?.reach || 1
	if(!locked_turf || (!pawn.CanReach(locked_target, locked_weapon) && get_dist(pawn, locked_turf) > swing_reach))
		finish_action(controller, FALSE, target_key)
		return

	var/atom/swing_at = locked_hiding_target || locked_target
	if(!locked_hiding_target && get_turf(locked_target) != locked_turf)
		swing_at = locked_turf
		if(world.time >= (controller.blackboard[BB_HUMAN_NPC_COMBAT_BARK_COOLDOWN] || 0))
			locked_turf.balloon_alert_to_viewers("<font color='#c7c6c6'>whiff</font>", balloon_flag = DISABLE_BALLOON_COMBAT, y_offset = -8)
			controller.set_blackboard_key(BB_HUMAN_NPC_COMBAT_BARK_COOLDOWN, world.time + HUMAN_NPC_COMBAT_BARK_COOLDOWN)

	var/old_cmode = pawn.cmode
	if(attempt_rmb)
		pawn.cmode = TRUE
	controller.ai_interact(swing_at, TRUE, TRUE, modifiers)
	pawn.cmode = old_cmode
	controller.clear_blackboard_key(BB_HUMAN_NPC_COMMITTED_SWING_TOKEN)
	// A lethal counter during the swing can gib the pawn.
	if(QDELETED(pawn))
		return

	if(pawn.next_click < world.time)
		pawn.next_click = world.time + (pawn.used_intent?.clickcd * (1 + rand(0.2, 0.4)))
		SEND_SIGNAL(pawn, COMSIG_MOB_BREAK_SNEAK)

	_scan_for_weakpoint(controller, pawn, locked_target)

	_try_backstep(pawn, locked_target)

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_try_wield_reach_weapon(mob/living/carbon/human/pawn)
	var/obj/item/held_item = pawn.get_active_held_item()
	if(!held_item?.GetComponent(/datum/component/two_handed) || HAS_TRAIT(held_item, TRAIT_WIELDED))
		return FALSE
	if(!length(held_item.gripped_intents))
		return FALSE

	var/datum/component/two_handed/twohanded = held_item.GetComponent(/datum/component/two_handed)
	twohanded.wield(pawn)
	return HAS_TRAIT(held_item, TRAIT_WIELDED)

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_choose_reach_capable_intent(mob/living/carbon/human/pawn, atom/target)
	if(!pawn || !target)
		return FALSE

	var/list/possible_intents = list()
	var/list/reach_intents = list()
	var/list/longest_intents = list()
	var/target_distance = get_dist(pawn, target)
	var/longest_reach = 0

	for(var/datum/intent/intent as anything in pawn.possible_a_intents)
		if(istype(intent, /datum/intent/unarmed/help) || istype(intent, /datum/intent/unarmed/shove) || istype(intent, /datum/intent/unarmed/grab))
			continue

		possible_intents |= intent
		var/intent_reach = intent.reach || 1
		if(intent_reach >= target_distance)
			reach_intents |= intent
		if(intent_reach > longest_reach)
			longest_reach = intent_reach
			longest_intents = list(intent)
		else if(intent_reach == longest_reach)
			longest_intents |= intent

	var/list/candidates = length(reach_intents) ? reach_intents : longest_intents
	if(!length(candidates))
		candidates = possible_intents
	if(!length(candidates))
		return FALSE

	if(pawn.used_intent in candidates)
		return TRUE

	pawn.a_intent = pick(candidates)
	pawn.used_intent = pawn.a_intent
	return TRUE

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_update_combat_intent(datum/ai_controller/controller, mob/living/carbon/human/pawn, mob/living/target)
	var/attacks_left = controller.blackboard[BB_HUMAN_NPC_CURRENT_INTENT_ATTACKS_LEFT]

	if(attacks_left > 0)
		controller.set_blackboard_key(BB_HUMAN_NPC_CURRENT_INTENT_ATTACKS_LEFT, attacks_left - 1)
		return

	if(!prob(HUMAN_NPC_INTENT_SWITCH_CHANCE))
		return

	var/skill_level = SKILL_RANK_NONE
	var/obj/item/held = pawn.get_active_held_item()
	if(held?.associated_skill)
		skill_level = GET_MOB_SKILL_VALUE_OLD(pawn, held.associated_skill)

	var/list/weighted = list(
		/datum/rmb_intent/strong = 45,
		/datum/rmb_intent/swift  = 40,
		/datum/rmb_intent/feint  = 15,
	)

	if(pawn.stamina > pawn.maximum_stamina * 0.6)
		weighted[/datum/rmb_intent/strong] = 0  // force swift when tired
	else if(pawn.stamina > pawn.maximum_stamina * 0.4)
		weighted[/datum/rmb_intent/strong] -= 20
		weighted[/datum/rmb_intent/swift] += 20

	// Skilled fighters use strong more
	if(skill_level >= SKILL_RANK_JOURNEYMAN)
		weighted[/datum/rmb_intent/strong] += 15

	// Feint more against defenders
	if(isliving(target))
		var/mob/living/carbon/human/htarget = target
		if(istype(htarget?.rmb_intent, /datum/rmb_intent/riposte) || istype(htarget?.rmb_intent, /datum/rmb_intent/guard))
			weighted[/datum/rmb_intent/feint] += 25

	var/chosen_type = pickweight(weighted)
	var/datum/rmb_intent/chosen = locate(chosen_type) in pawn.possible_rmb_intents
	if(chosen)
		pawn.rmb_intent = chosen
		human_npc_combat_state_balloon(controller, pawn, "changes grip", 35)

	controller.set_blackboard_key(BB_HUMAN_NPC_CURRENT_INTENT_ATTACKS_LEFT, rand(3, 6))


/datum/ai_behavior/basic_melee_attack/human_npc/proc/_choose_attack_zone(datum/ai_controller/controller, mob/living/carbon/human/pawn, mob/living/target)
	var/weakpoint_zone = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT]
	var/weakpoint_target = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_TARGET]
	var/weakpoint_expires = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_EXPIRES]
	var/weakpoint_armor_type = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_ARMOR_TYPE]
	var/current_armor_type = normalize_armor_attack_flag(pawn.used_intent?.blade_class || BCLASS_BLUNT)
	var/valid_weakpoint = weakpoint_zone && weakpoint_target == target && world.time < weakpoint_expires && weakpoint_armor_type == current_armor_type

	if(valid_weakpoint)
		if(prob(HUMAN_NPC_WEAKPOINT_AIM_CHANCE))
			var/aimheight = _zone_to_aimheight(weakpoint_zone)
			if(aimheight)
				pawn.aimheight_change(aimheight)
				return
		_choose_standard_attack_zone(pawn, target)
		return
	if(weakpoint_zone || weakpoint_target || weakpoint_expires || weakpoint_armor_type)
		_clear_weakpoint_cache(controller)

	var/counter = controller.blackboard[BB_HUMAN_NPC_ATTACK_ZONE_COUNTER]
	if(counter < 4)
		controller.set_blackboard_key(BB_HUMAN_NPC_ATTACK_ZONE_COUNTER, counter + 1)
		return

	controller.set_blackboard_key(BB_HUMAN_NPC_ATTACK_ZONE_COUNTER, 0)
	_choose_standard_attack_zone(pawn, target)

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_choose_standard_attack_zone(mob/living/carbon/human/pawn, mob/living/target)
	// Parity with npc_choose_attack_zone aimheight picks
	if(pawn.mind?.has_antag_datum(/datum/antagonist/zombie))
		pawn.aimheight_change(pawn.deadite_get_aimheight(target))
		return
	if(!(pawn.mobility_flags & MOBILITY_STAND))
		pawn.aimheight_change(rand(1, 4))
		return
	if(HAS_TRAIT(target, TRAIT_BLOODLOSS_IMMUNE))
		pawn.aimheight_change(rand(12, 19))
		return
	pawn.aimheight_change(pick(rand(5, 8), rand(9, 11), rand(12, 19)))

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_try_weapon_special(datum/ai_controller/controller)
	var/mob/living/carbon/human/pawn = controller.pawn

	if(pawn.has_status_effect(/datum/status_effect/debuff/specialcd))
		return FALSE

	var/obj/item/weapon/held_weapon = pawn.get_active_held_item()
	if(!istype(held_weapon) || !held_weapon.weapon_special)
		return FALSE

	if(!prob(HUMAN_NPC_WEAPON_SPECIAL_CHANCE))
		return FALSE

	// Check we can actually afford the stamina cost before attempting
	var/datum/special_intent/special = held_weapon.weapon_special
	if(special.stamina_cost)
		var/cost = (special.stamina_cost < 1) ? (pawn.maximum_stamina * special.stamina_cost) : special.stamina_cost
		if(!pawn.check_stamina(cost))
			return FALSE

	var/datum/rmb_intent/strong/strong_intent = locate(/datum/rmb_intent/strong) in pawn.possible_rmb_intents
	if(!strong_intent)
		return FALSE

	var/prev_intent = pawn.rmb_intent.type
	pawn.swap_rmb_intent(strong_intent)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/success = pawn.rmb_intent.special_attack(pawn, target)
	pawn.swap_rmb_intent(prev_intent)
	return success
/// Attempts a read-only armor scan after a completed swing, then caches a real weakness.
/datum/ai_behavior/basic_melee_attack/human_npc/proc/_scan_for_weakpoint(datum/ai_controller/controller, mob/living/carbon/human/pawn, mob/living/target)
	if(!istype(target, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/htarget = target
	var/armor_type = normalize_armor_attack_flag(pawn.used_intent?.blade_class || BCLASS_BLUNT)
	var/cached_zone = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT]
	var/cached_target = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_TARGET]
	var/cache_expires = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_EXPIRES]
	var/cached_armor_type = controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_ARMOR_TYPE]
	if(cached_zone && cached_target == target && world.time < cache_expires && cached_armor_type == armor_type)
		return
	if(cached_zone || cached_target || cache_expires || cached_armor_type)
		_clear_weakpoint_cache(controller)

	if(world.time < (controller.blackboard[BB_HUMAN_NPC_WEAKPOINT_SCAN_COOLDOWN] || 0))
		return
	controller.set_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_SCAN_COOLDOWN, world.time + HUMAN_NPC_WEAKPOINT_SCAN_COOLDOWN)

	var/perception = GET_MOB_ATTRIBUTE_VALUE(pawn, STAT_PERCEPTION)
	var/target_sneaking = GET_MOB_SKILL_VALUE_OLD(htarget, /datum/attribute/skill/misc/sneaking)
	var/target_fortune = GET_MOB_ATTRIBUTE_VALUE(htarget, STAT_FORTUNE)
	var/scan_chance = HUMAN_NPC_WEAKPOINT_BASE_SCAN_CHANCE + ((perception - 10) * HUMAN_NPC_WEAKPOINT_PERCEPTION_SCALE) - (target_sneaking * HUMAN_NPC_WEAKPOINT_SNEAK_SCALE) - ((target_fortune - 10) * HUMAN_NPC_WEAKPOINT_FORTUNE_SCALE)
	scan_chance = clamp(scan_chance, HUMAN_NPC_WEAKPOINT_MIN_SCAN_CHANCE, HUMAN_NPC_WEAKPOINT_MAX_SCAN_CHANCE)
	if(!prob(scan_chance))
		return

	var/lowest_tier = INFINITY
	var/highest_tier = ARMOR_TIER_NONE
	var/list/weakest_zones = list()

	for(var/obj/item/bodypart/part in htarget.bodyparts)
		if(!part)
			continue
		var/protection_tier = htarget.get_armor_protection_tier(part.body_zone, armor_type)
		highest_tier = max(highest_tier, protection_tier)
		if(protection_tier < lowest_tier)
			lowest_tier = protection_tier
			weakest_zones = list(part.body_zone)
		else if(protection_tier == lowest_tier)
			weakest_zones += part.body_zone

	if(!length(weakest_zones) || highest_tier - lowest_tier < 1)
		return

	var/chosen_zone = pick(weakest_zones)
	controller.set_blackboard_key(BB_HUMAN_NPC_WEAKPOINT, chosen_zone)
	controller.set_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_ARMOR_TYPE, armor_type)
	controller.set_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_EXPIRES, world.time + HUMAN_NPC_WEAKPOINT_CACHE_DURATION)
	controller.set_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_TARGET, target)
	pawn.balloon_alert_to_viewers("<font color='#d6b36a'>spots a gap — [parse_zone(chosen_zone)]!</font>", balloon_flag = DISABLE_BALLOON_COMBAT, y_offset = -8)
	controller.set_blackboard_key(BB_HUMAN_NPC_COMBAT_BARK_COOLDOWN, world.time + HUMAN_NPC_COMBAT_BARK_COOLDOWN)

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_clear_weakpoint_cache(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_HUMAN_NPC_WEAKPOINT)
	controller.clear_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_ARMOR_TYPE)
	controller.clear_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_EXPIRES)
	controller.clear_blackboard_key(BB_HUMAN_NPC_WEAKPOINT_TARGET)

/// Zone string -> aimheight int.
/datum/ai_behavior/basic_melee_attack/human_npc/proc/_zone_to_aimheight(zone)
	switch(zone)
		if(BODY_ZONE_HEAD)
			return rand(12, 19)
		if(BODY_ZONE_CHEST)
			return rand(9, 11)
		if(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
			return rand(5, 8)
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return rand(1, 4)
	return null

/datum/ai_behavior/basic_melee_attack/human_npc/proc/_try_backstep(mob/living/carbon/human/pawn, atom/target)
	if(pawn.mind?.has_antag_datum(/datum/antagonist/zombie))
		return FALSE
	if(pawn.body_position == LYING_DOWN)
		return FALSE
	if(pawn.ai_controller.blackboard[BB_HUMAN_NPC_HARASS_MODE])
		return FALSE
	if(!target || !isturf(pawn.loc) || !isturf(target.loc) || !pawn.ai_controller.can_move())
		return FALSE

	if(world.time < pawn.ai_controller.blackboard[BB_HUMAN_NPC_JUKE_COOLDOWN])
		return FALSE

	var/juke_chance = HUMAN_NPC_BASE_JUKE_CHANCE
	if(GET_MOB_ATTRIBUTE_VALUE(pawn, STAT_SPEED) > HUMAN_NPC_JUKE_MIN_SPD)
		juke_chance += (GET_MOB_ATTRIBUTE_VALUE(pawn, STAT_SPEED) - HUMAN_NPC_JUKE_MIN_SPD) * HUMAN_NPC_JUKE_PER_OVERSPD

	if(!prob(juke_chance))
		return FALSE

	pawn.tempfixeye = TRUE
	pawn.atom_flags |= NO_DIR_CHANGE_ON_MOVE
	var/was_fixedeye = pawn.fixedeye
	if(!was_fixedeye)
		pawn.fixedeye = TRUE

	var/list/candidates = pawn.get_dodge_destinations(target, null)
	if(!length(candidates))
		pawn.tempfixeye = FALSE
		if(!was_fixedeye)
			pawn.fixedeye = FALSE
		return FALSE

	var/turf/juke_turf = pick(candidates)
	pawn.Move(juke_turf, get_dir(pawn, juke_turf), pawn.cached_multiplicative_slowdown)
	pawn.atom_flags &= ~NO_DIR_CHANGE_ON_MOVE
	pawn.face_atom(target)
	human_npc_combat_state_balloon(pawn.ai_controller, pawn, "circles wide", 50)

	pawn.ai_controller.set_blackboard_key(BB_HUMAN_NPC_JUKE_COOLDOWN, world.time + 1.5 SECONDS)
	pawn.tempfixeye = FALSE
	if(!was_fixedeye)
		pawn.fixedeye = FALSE
	return TRUE

/mob/living/proc/get_dodge_destinations(mob/living/attacker, atom/origin = src)
	var/dodge_dir = get_dir(attacker, origin)
	if(!dodge_dir)
		return null
	var/list/dirry = list(turn(dodge_dir, -90), dodge_dir, turn(dodge_dir, 90))
	var/list/turf/dodge_candidates = list()
	for(var/dir_to_check in dirry)
		var/turf/dodge_candidate = get_step(origin, dir_to_check)
		if(!dodge_candidate)
			continue
		if(dodge_candidate.density)
			continue
		var/has_impassable_atom = FALSE
		for(var/atom/movable/AM in dodge_candidate)
			if(!AM.CanPass(src, dodge_candidate))
				has_impassable_atom = TRUE
				break
		if(has_impassable_atom)
			continue
		dodge_candidates += dodge_candidate
	return dodge_candidates

/mob/living/carbon/human/proc/deadite_get_aimheight(victim)
	if(!(mobility_flags & MOBILITY_STAND))
		return rand(1, 2) // Bite their ankles!
	return pick(rand(11, 13), rand(14, 17), rand(5, 8)) // Chest, neck, and mouth; face and ears; arms and hands.

#undef HUMAN_NPC_BASE_JUKE_CHANCE
#undef HUMAN_NPC_JUKE_MIN_SPD
#undef HUMAN_NPC_JUKE_PER_OVERSPD
#undef HUMAN_NPC_REACTION_TIME_BASE
#undef HUMAN_NPC_REACTION_TIME_MIN
#undef HUMAN_NPC_REACTION_PER_STAT_POINT
#undef HUMAN_NPC_GAP_CLOSE_COOLDOWN
#undef HUMAN_NPC_GAP_CLOSE_MIN_DIST
#undef HUMAN_NPC_GAP_CLOSE_MAX_DIST
#undef HUMAN_NPC_GAP_CLOSE_OPEN_CHANCE
#undef HUMAN_NPC_COMBAT_BARK_COOLDOWN
#undef HUMAN_NPC_WEAKPOINT_BASE_SCAN_CHANCE
#undef HUMAN_NPC_WEAKPOINT_PERCEPTION_SCALE
#undef HUMAN_NPC_WEAKPOINT_SNEAK_SCALE
#undef HUMAN_NPC_WEAKPOINT_FORTUNE_SCALE
#undef HUMAN_NPC_WEAKPOINT_MIN_SCAN_CHANCE
#undef HUMAN_NPC_WEAKPOINT_MAX_SCAN_CHANCE
#undef HUMAN_NPC_WEAKPOINT_AIM_CHANCE
#undef HUMAN_NPC_WEAKPOINT_SCAN_COOLDOWN
#undef HUMAN_NPC_WEAKPOINT_CACHE_DURATION
#undef HUMAN_NPC_WEAPON_SPECIAL_CHANCE
#undef HUMAN_NPC_INTENT_SWITCH_CHANCE
#undef HUMAN_NPC_RMB_ATTEMPT_CHANCE
