// Spiders wrap, brood and seal: the cocoon subtrees for every kind and the egg-pumping of a wrapped victim.

#define SPIDER_COCOON_SIGHT 6
#define SPIDER_BROOD_SIGHT 7
#define SPIDER_WRAP_TIME (5 SECONDS)
/// A brood that has not reached its cocoon by then gives up.
#define SPIDER_BROOD_WALK_LIMIT (30 SECONDS)
#define SPIDER_BROOD_TEAR_TIME (3 SECONDS)

// ---- Who is wrapped, and when ----

/// TRUE when [spider] may wind [victim] into a cocoon now: senseless, defeated, or yielding after its climax.
/proc/spider_can_wrap(mob/living/spider, mob/living/victim)
	if(!iscarbon(victim) || QDELETED(victim) || victim.stat == DEAD || !isturf(victim.loc))
		return FALSE
	if(world.time < victim.kidnap_protected_until)
		return FALSE
	if(spider_spares(spider, victim))
		return FALSE
	if(victim.stat != CONSCIOUS || victim.has_status_effect(/datum/status_effect/defeat_knockout))
		return TRUE
	return victim.surrendering && spider.ai_controller?.blackboard[BB_SPIDER_SATED_WITH] == victim

/// Friends and kin are never wrapped.
/proc/spider_spares(mob/living/spider, mob/living/victim)
	var/list/friends = spider.ai_controller?.blackboard[BB_FRIENDS_LIST]
	if(friends && (victim in friends))
		return TRUE
	return spider.ai_targeting_ally_check(victim)

/// TRUE while [spider] and [partner] share a running act.
/proc/spider_in_scene_with(mob/living/spider, mob/living/partner)
	var/datum/sex_scene/scene = spider?.sex_scene
	if(!scene || QDELETED(scene))
		return FALSE
	return length(scene.get_actions_between(spider, partner)) > 0

/// TRUE while the pawn fights a standing foe other than [except]; silk work waits for the fight.
/proc/spider_busy_fighting(datum/ai_controller/controller, atom/except)
	var/mob/living/foe = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!isliving(foe) || QDELETED(foe) || foe == except)
		return FALSE
	return foe.stat == CONSCIOUS && isturf(foe.loc) && !foe.has_status_effect(/datum/status_effect/defeat_knockout)

// ---- Wrapping ----

/datum/ai_planning_subtree/cocoon_target
	var/datum/ai_behavior/cocoon_target/behavior = /datum/ai_behavior/cocoon_target

/datum/ai_planning_subtree/cocoon_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_COCOON_TARGET]
	if(isnull(target))
		return
	if(QDELETED(target) || !isliving(target))
		controller.clear_blackboard_key(BB_BASIC_MOB_COCOON_TARGET)
		return
	var/mob/living/pawn = controller.pawn
	// Mid-act or mid-fight the wrap waits; the key keeps until then.
	if(pawn.doing() || spider_in_scene_with(pawn, target) || spider_busy_fighting(controller, target))
		return
	controller.queue_behavior(behavior, BB_BASIC_MOB_COCOON_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/cocoon_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 1 SECONDS

/datum/ai_behavior/cocoon_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isliving(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/cocoon_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isliving(target))
		finish_action(controller, FALSE, target_key)
		return
	if(istype(target.loc, /obj/structure/spider/cocoon))
		finish_action(controller, TRUE, target_key)
		return
	if(spider_in_scene_with(pawn, target) || !spider_can_wrap(pawn, target))
		finish_action(controller, FALSE, target_key)
		return
	finish_action(controller, spin_cocoon(pawn, target), target_key)

/// Three beats of silk over the wrap, then the cocoon. FALSE when cut short.
/datum/ai_behavior/cocoon_target/proc/spin_cocoon(mob/living/pawn, mob/living/target)
	var/list/beats = list(
		list("[pawn] winds silk around [target]'s ankles.", "[pawn] winds silk around my ankles."),
		list("[pawn] winds silk around [target]'s hips.", "[pawn] winds silk around my hips."),
		list("[pawn] winds silk over [target]'s face.", "[pawn] winds silk over my face."),
	)
	for(var/list/beat as anything in beats)
		target.felt_visible_message(span_warning(beat[1]), span_love(beat[2]))
		if(!do_after(pawn, SPIDER_WRAP_TIME / length(beats), target, IGNORE_USER_DIR_CHANGE))
			return FALSE
		if(QDELETED(target) || !spider_can_wrap(pawn, target))
			return FALSE
	var/obj/structure/spider/cocoon/cocoon = new(get_turf(target))
	cocoon.wrap(target)
	target.felt_visible_message(span_danger("[pawn] seals [target] inside a cocoon of silk!"), span_userdanger("[pawn] seals me inside a cocoon of silk!"))
	return TRUE

/datum/ai_behavior/cocoon_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	// A wrapped victim is no longer a fight.
	if(succeeded && target && controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == target)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	// The wrapper walks off and leaves the cocoon be.
	if(succeeded && istype(target?.loc, /obj/structure/spider/cocoon))
		spider_shun_cocoon(controller, target.loc)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_SPIDER_SATED_WITH)

/datum/ai_planning_subtree/find_cocoon_target
	var/vision_range = SPIDER_COCOON_SIGHT
	var/datum/ai_behavior/find_and_set/cocoon_target/behavior = /datum/ai_behavior/find_and_set/cocoon_target
	var/cocoon_target_key = BB_BASIC_MOB_COCOON_TARGET

/datum/ai_planning_subtree/find_cocoon_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/current = controller.blackboard[cocoon_target_key]
	if(!QDELETED(current))
		return
	if(spider_busy_fighting(controller))
		return
	controller.queue_behavior(behavior, cocoon_target_key, /mob/living/carbon, vision_range)

/datum/ai_behavior/find_and_set/cocoon_target
	action_cooldown = 10 SECONDS

/datum/ai_behavior/find_and_set/cocoon_target/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/pawn = controller.pawn
	var/list/found = list()
	for(var/mob/living/carbon/victim in oview(search_range, pawn))
		if(spider_can_wrap(pawn, victim))
			found += victim
	if(!length(found))
		return null
	return pick(found)

/// No field: a body that drops in view never walks in, so the rescan does the work.
/datum/ai_behavior/find_and_set/cocoon_target/failed_to_find_anything(datum/ai_controller/controller, set_key, locate_path, search_range)
	return

// ---- Brooding ----

/// TRUE when [spider] may lay into [cocoon]: unsealed, holding a living carbon who takes mob eggs and has room.
/proc/spider_can_brood(mob/living/spider, obj/structure/spider/cocoon/cocoon)
	if(QDELETED(cocoon) || cocoon.brooded)
		return FALSE
	var/mob/living/carbon/victim = cocoon.get_wrapped_victim()
	if(!victim || world.time < victim.kidnap_protected_until || !victim.allows_player_erp_while_disconnected())
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES))
		return FALSE
	if(should_apply_mob_erp_target_pref(spider, victim))
		var/datum/targetting_datum/targeting = spider.ai_controller?.blackboard[BB_TARGETTING_DATUM]
		if(!targeting?.is_horny_pref_target(spider, victim))
			return FALSE
	if(!target_allows_mob_erp_action(spider, victim, /datum/erp_preference/boolean/allow_mob_oviposition))
		return FALSE
	return victim.can_receive_oviposition_implant()

/datum/ai_planning_subtree/spider_brood
	var/vision_range = SPIDER_BROOD_SIGHT

/datum/ai_planning_subtree/spider_brood/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/mob/living/pawn = controller.pawn
	if(spider_busy_fighting(controller))
		return
	var/datum/ai_behavior/spider_brood/brood = GET_AI_BEHAVIOR(/datum/ai_behavior/spider_brood)
	var/brooding = LAZYACCESS(controller.current_behaviors, brood)
	var/obj/structure/spider/cocoon/cocoon = controller.blackboard[BB_SPIDER_BROOD_COCOON]
	// A running brood decides for itself when it is done; a fresh one needs eggs and a willing host.
	if(cocoon && (QDELETED(cocoon) || cocoon.brooded || (!brooding && (!has_egg_to_lay(pawn) || !spider_can_brood(pawn, cocoon)))))
		controller.clear_blackboard_key(BB_SPIDER_BROOD_COCOON)
		cocoon = null
	if(cocoon)
		controller.queue_behavior(/datum/ai_behavior/spider_brood, BB_SPIDER_BROOD_COCOON)
		return SUBTREE_RETURN_FINISH_PLANNING
	if(!has_egg_to_lay(pawn))
		return
	controller.queue_behavior(/datum/ai_behavior/find_and_set/spider_brood_cocoon, BB_SPIDER_BROOD_COCOON, /obj/structure/spider/cocoon, vision_range)

/datum/ai_behavior/find_and_set/spider_brood_cocoon
	action_cooldown = 5 SECONDS

/datum/ai_behavior/find_and_set/spider_brood_cocoon/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/pawn = controller.pawn
	var/obj/structure/spider/cocoon/nearest
	// Range, not view: spiders find their cocoons in the dark.
	for(var/obj/structure/spider/cocoon/cocoon in range(search_range, pawn))
		if(!spider_can_brood(pawn, cocoon))
			continue
		if(!nearest || get_dist(pawn, cocoon) < get_dist(pawn, nearest))
			nearest = cocoon
	return nearest

/datum/ai_behavior/find_and_set/spider_brood_cocoon/failed_to_find_anything(datum/ai_controller/controller, set_key, locate_path, search_range)
	return

/// Walks to a cocoon, lays egg after egg into the victim, then seals it and leaves.
/datum/ai_behavior/spider_brood
	action_cooldown = 1 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/spider_brood/setup(datum/ai_controller/controller, cocoon_key)
	. = ..()
	var/obj/structure/spider/cocoon/cocoon = controller.blackboard[cocoon_key]
	if(!has_egg_to_lay(controller.pawn) || !spider_can_brood(controller.pawn, cocoon))
		return FALSE
	controller.set_blackboard_key(BB_SPIDER_BROOD_SINCE, world.time)
	set_movement_target(controller, cocoon)

/// The act is a do_after chain, so this only runs between acts: start the next one, or seal.
/datum/ai_behavior/spider_brood/perform(seconds_per_tick, datum/ai_controller/controller, cocoon_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/structure/spider/cocoon/cocoon = controller.blackboard[cocoon_key]
	var/mob/living/carbon/victim = cocoon?.get_wrapped_victim()
	if(QDELETED(cocoon) || cocoon.brooded || !victim)
		finish_action(controller, FALSE, cocoon_key)
		return
	if(!spider_can_brood(pawn, cocoon))
		finish_action(controller, FALSE, cocoon_key)
		return
	if(get_dist(pawn, cocoon) > 1)
		if(world.time > controller.blackboard[BB_SPIDER_BROOD_SINCE] + SPIDER_BROOD_WALK_LIMIT)
			finish_action(controller, FALSE, cocoon_key)
		return
	var/datum/sex_scene_controller/scene = pawn.open_sex_scene(victim, FALSE)
	if(!scene)
		finish_action(controller, FALSE, cocoon_key)
		return
	if(isnull(controller.blackboard[BB_SPIDER_BROOD_OPENED_AT]))
		open_cocoon(controller, pawn, victim, cocoon, scene)
	if(length(scene.get_active_actions()))
		return
	note_last_act(controller, pawn)
	if(!has_egg_to_lay(pawn) || climaxed_since_opening(controller, pawn))
		seal_cocoon(pawn, victim, cocoon)
		finish_action(controller, TRUE, cocoon_key)
		return
	if(tear_covering(pawn, victim, cocoon))
		return
	if(!start_next_lay_act(controller, pawn, victim, scene))
		seal_cocoon(pawn, victim, cocoon)
		finish_action(controller, TRUE, cocoon_key)

/datum/ai_behavior/spider_brood/proc/open_cocoon(datum/ai_controller/controller, mob/living/pawn, mob/living/carbon/victim, obj/structure/spider/cocoon/cocoon, datum/sex_scene_controller/scene)
	controller.set_blackboard_key(BB_SPIDER_BROOD_OPENED_AT, world.time)
	controller.set_blackboard_key(BB_SPIDER_BROOD_REFUSED, list())
	scene.set_current_force(SEX_FORCE_MID)
	scene.set_current_speed(SEX_SPEED_HIGH)
	pawn.face_atom(cocoon)
	pawn.visible_message(span_warning("[pawn] tears open [cocoon] over [victim]'s hips."))
	to_chat(victim, span_love("[pawn] tears open the silk over my hips."))

/// An act that ended without laying an egg marks its hole as taking no more.
/datum/ai_behavior/spider_brood/proc/note_last_act(datum/ai_controller/controller, mob/living/pawn)
	var/last_act = controller.blackboard[BB_SPIDER_BROOD_LAST_ACT]
	if(isnull(last_act))
		return
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(pawn)
	if(!ovipositor || ovipositor.eggs_stored >= controller.blackboard[BB_SPIDER_BROOD_EGGS_BEFORE])
		var/list/refused = controller.blackboard[BB_SPIDER_BROOD_REFUSED]
		refused = refused ? refused.Copy() : list()
		refused |= last_act
		controller.set_blackboard_key(BB_SPIDER_BROOD_REFUSED, refused)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_LAST_ACT)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_EGGS_BEFORE)

/// TRUE once the spider came after it parted the silk; the climax rush already put its eggs in.
/datum/ai_behavior/spider_brood/proc/climaxed_since_opening(datum/ai_controller/controller, mob/living/pawn)
	var/list/arousal_data = list()
	SEND_SIGNAL(pawn, COMSIG_SEX_GET_AROUSAL, arousal_data)
	return (arousal_data["last_ejaculation_time"] || 0) > controller.blackboard[BB_SPIDER_BROOD_OPENED_AT]

/// Fangs cut away armour over the groin through the silk. TRUE when it tried.
/datum/ai_behavior/spider_brood/proc/tear_covering(mob/living/pawn, mob/living/carbon/victim, obj/structure/spider/cocoon/cocoon)
	var/obj/item/garment = victim.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN)
	if(!garment)
		return FALSE
	victim.felt_visible_message(span_danger("[pawn] cuts at [victim]'s [garment.name] through the silk."), span_userdanger("[pawn] cuts at my [garment.name] through the silk."))
	if(!do_after(pawn, SPIDER_BROOD_TEAR_TIME, victim, IGNORE_USER_DIR_CHANGE))
		return TRUE
	if(garment.loc != victim || !victim.dropItemToGround(garment))
		return FALSE
	victim.felt_visible_message(span_danger("[pawn] tears [victim]'s [garment.name] off inside [cocoon]."), span_userdanger("[pawn] tears my [garment.name] off."))
	return TRUE

/// Vaginal first, anal when the pussy is missing or refuses, the throat last. TRUE when one started.
/datum/ai_behavior/spider_brood/proc/start_next_lay_act(datum/ai_controller/controller, mob/living/pawn, mob/living/carbon/victim, datum/sex_scene_controller/scene)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(pawn)
	var/list/refused = controller.blackboard[BB_SPIDER_BROOD_REFUSED]
	for(var/act_type in list(/datum/sex_action/npc/npc_vaginal_sex/lay_eggs, /datum/sex_action/npc/npc_anal_sex/lay_eggs, /datum/sex_action/npc/npc_throat_sex/lay_eggs))
		if(refused && (act_type in refused))
			continue
		if(!brood_hole_fits(pawn, victim, act_type))
			continue
		if(!scene.try_start_action(act_type, "ai"))
			continue
		controller.set_blackboard_key(BB_SPIDER_BROOD_LAST_ACT, act_type)
		controller.set_blackboard_key(BB_SPIDER_BROOD_EGGS_BEFORE, ovipositor.eggs_stored)
		return TRUE
	return FALSE

/// The same fit rule the hunt's egg acts use; the throat always fits.
/datum/ai_behavior/spider_brood/proc/brood_hole_fits(mob/living/pawn, mob/living/carbon/victim, act_type)
	if(act_type == /datum/sex_action/npc/npc_vaginal_sex/lay_eggs)
		return victim.getorganslot(ORGAN_SLOT_VAGINA) && npc_penetration_can_fit(pawn, victim, ORGAN_SLOT_VAGINA)
	if(act_type == /datum/sex_action/npc/npc_anal_sex/lay_eggs)
		return npc_penetration_can_fit(pawn, victim, ORGAN_SLOT_ANUS)
	return TRUE

/datum/ai_behavior/spider_brood/proc/seal_cocoon(mob/living/pawn, mob/living/carbon/victim, obj/structure/spider/cocoon/cocoon)
	if(!cocoon.seal())
		return
	pawn.visible_message(span_warning("[pawn] spins more silk over [cocoon] and seals it."))
	to_chat(victim, span_love("[pawn] seals the silk over my hips."))
	spider_shun_cocoon(pawn.ai_controller, cocoon)

/datum/ai_behavior/spider_brood/finish_action(datum/ai_controller/controller, succeeded, cocoon_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/datum/sex_scene/scene = pawn?.sex_scene
	if(scene && !QDELETED(scene))
		for(var/datum/sex_action/action as anything in scene.get_actions_involving(pawn))
			if(action.action_user == pawn)
				scene.stop_action(action)
		var/datum/sex_scene_controller/scene_controller = scene.get_controller(pawn)
		if(scene_controller && !QDELETED(scene_controller))
			qdel(scene_controller)
	controller.clear_blackboard_key(cocoon_key)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_SINCE)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_OPENED_AT)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_LAST_ACT)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_EGGS_BEFORE)
	controller.clear_blackboard_key(BB_SPIDER_BROOD_REFUSED)

#undef SPIDER_COCOON_SIGHT
#undef SPIDER_BROOD_SIGHT
#undef SPIDER_WRAP_TIME
#undef SPIDER_BROOD_WALK_LIMIT
#undef SPIDER_BROOD_TEAR_TIME
