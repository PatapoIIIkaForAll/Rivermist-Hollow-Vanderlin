// Hunt tactics beyond the chase: pack calls, scent, circling, the pounce, the lash and thrown traps.

/// A fall on the web this soon after a spit counts as webbed.
#define HORNY_WEB_FALL_WINDOW (8 SECONDS)
/// How long a webbed, fallen target lies presented.
#define HORNY_PRESENTED_TIME (10 SECONDS)

/// Thrown trap this mob carries for a target it cannot reach; null for most mobs.
/mob/living/var/horny_trap_type = null

/// The tell calls the pack: packmates in earshot who may want the target take it up, up to the cap. Returns how many did.
/proc/horny_call_pack(mob/living/hunter, mob/living/target, datum/ai_controller/controller, datum/horny_family_profile/profile)
	if(!profile.pack_call || controller.blackboard[BB_HORNY_PACK_CALLED])
		return 0
	controller.set_blackboard_key(BB_HORNY_PACK_CALLED, TRUE)
	var/hunters = 1
	var/list/candidates = list()
	for(var/mob/living/mate in range(HORNY_PACK_RANGE, hunter))
		if(mate == hunter || mate.stat != CONSCIOUS || !mate.ai_controller || !hunter.kidnap_is_packmate(mate))
			continue
		if(mate.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == target)
			hunters++
			continue
		candidates += mate
	if(!length(candidates))
		return 0

	var/answered = 0
	for(var/mob/living/mate as anything in candidates)
		if(profile.pack_cap && hunters >= profile.pack_cap)
			break
		var/datum/ai_controller/mate_controller = mate.ai_controller
		if(mate_controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] || !isnull(mate_controller.blackboard[BB_HORNY_TIME_START]))
			continue
		// Every packmate passes its own pref gate; the call only points the way.
		var/datum/targetting_datum/targeting = mate_controller.blackboard[BB_TARGETTING_DATUM]
		if(!targeting?.can_horny(mate, target))
			continue
		mate_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, target)
		mate_controller.recalculate_idle()
		hunters++
		answered++
	hunter.visible_message(span_danger(profile.get_pack_call_message(hunter, target)), null, span_hear(profile.get_pack_call_hear_message(hunter)))
	return answered

/// Sight lost: the freshest scent mark the target left nearby, when the target lets scents matter. Null otherwise.
/proc/horny_find_scent_turf(mob/living/hunter, mob/living/target)
	if(!target || !target.get_erp_pref(/datum/erp_preference/bitflag/pheromones))
		return null
	var/datum/fluid_scent_mark/best
	for(var/datum/fluid_scent_mark/mark as anything in GLOB.fluid_scent_marks)
		if(!mark.turf || mark.source_ref?.resolve() != target)
			continue
		if(mark.turf.z != hunter.z || get_dist(hunter, mark.turf) > HORNY_SCENT_RANGE)
			continue
		if(!best || mark.time > best.time)
			best = mark
	return best?.turf

/// Beasts work round to the target's back before they close. TRUE while the detour is on.
/proc/horny_circle_target(mob/living/hunter, mob/living/target, datum/ai_controller/controller, datum/ai_behavior/hunt)
	if(get_dist(hunter, target) > HORNY_CIRCLE_RANGE)
		return FALSE
	var/until = controller.blackboard[BB_HORNY_CIRCLE_UNTIL]
	if(isnull(until))
		until = world.time + HORNY_CIRCLE_TIME
		controller.set_blackboard_key(BB_HORNY_CIRCLE_UNTIL, until)
	if(world.time >= until)
		return FALSE
	// Already out of their eye line: go straight in.
	if(get_dir(target, hunter) != target.dir)
		return FALSE
	var/turf/behind = get_step(target, turn(target.dir, 180))
	if(!behind || behind.density || behind == get_turf(hunter))
		return FALSE
	hunt.set_movement_target(controller, behind)
	return TRUE

/// Pounce families leap the last two or three tiles with the engine's own jump. TRUE when they jumped.
/proc/horny_pounce(mob/living/hunter, mob/living/target, datum/ai_controller/controller, datum/horny_family_profile/profile)
	if(!profile.pounces)
		return FALSE
	var/distance = get_dist(hunter, target)
	if(distance < HORNY_POUNCE_MIN_RANGE || distance > HORNY_POUNCE_MAX_RANGE)
		return FALSE
	if(world.time < (controller.blackboard[BB_HORNY_POUNCE_COOLDOWN] || 0))
		return FALSE
	if(hunter.pulledby || hunter.IsOffBalanced() || hunter.lying_angle || hunter.usable_legs < 2)
		return FALSE
	if(!can_see(hunter, target, HORNY_POUNCE_MAX_RANGE))
		return FALSE
	controller.set_blackboard_key(BB_HORNY_POUNCE_COOLDOWN, world.time + HORNY_POUNCE_COOLDOWN)
	hunter.visible_message(span_danger(profile.get_pounce_message(hunter, target)))
	INVOKE_ASYNC(hunter, TYPE_PROC_REF(/mob/living, jump_action), get_turf(target))
	return TRUE

/// Lash families reach two tiles: a pull that drags the target a step closer, resisted with the same roll. TRUE when it lashed.
/proc/horny_lash(mob/living/hunter, mob/living/target, datum/ai_controller/controller, datum/horny_family_profile/profile)
	if(!profile.lashes || get_dist(hunter, target) != HORNY_LASH_RANGE)
		return FALSE
	if(world.time < (controller.blackboard[BB_HORNY_LASH_COOLDOWN] || 0))
		return FALSE
	if(target.buckled || !can_see(hunter, target, HORNY_LASH_RANGE))
		return FALSE
	// No tug of war: a held target, or one a packmate works on next to it, stays put.
	if(horny_hold_is_spoken_for(hunter, target) || horny_packmate_works_on(hunter, target))
		return FALSE
	controller.set_blackboard_key(BB_HORNY_LASH_COOLDOWN, world.time + HORNY_LASH_COOLDOWN)
	hunter.face_atom(target)
	horny_jolt(hunter, target)
	if(!prob(horny_bear_down_chance(hunter, target, profile.bear_down_bonus, horny_get_pressure(controller)) + rand(-5, 5)))
		horny_add_pressure(controller, target)
		hunter.visible_message(span_danger(profile.get_lash_miss_message(hunter, target)), null, span_hear("I hear something whip through the air."))
		return TRUE
	var/turf/closer = get_step(target, get_dir(target, hunter))
	if(closer && !closer.density && step_towards(target, hunter))
		target.felt_visible_message(span_danger(profile.get_lash_message(hunter, target)), null, span_hear("I hear a wet lash and a stumble."))
	return TRUE

/// TRUE when a packmate next to the target holds it or has it as its horny or combat target.
/proc/horny_packmate_works_on(mob/living/hunter, mob/living/target)
	for(var/mob/living/mate in orange(1, target))
		if(mate == hunter || mate.stat == DEAD || !hunter.kidnap_is_packmate(mate))
			continue
		if(mate.pulling == target)
			return TRUE
		var/datum/ai_controller/mate_controller = mate.ai_controller
		if(mate_controller?.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == target || mate_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == target)
			return TRUE
	return FALSE

/// Angered hunters throw their trap at a target they cannot reach; web spitters spit. TRUE when something flew.
/proc/horny_throw_trap(mob/living/hunter, mob/living/target, datum/ai_controller/controller, datum/horny_family_profile/profile)
	if((controller.blackboard[BB_HORNY_TEMPER] || 0) < HORNY_TEMPER_ROUGH)
		return FALSE
	var/distance = get_dist(hunter, target)
	if(distance < HORNY_TRAP_MIN_RANGE || distance > HORNY_TRAP_MAX_RANGE)
		return FALSE
	if(world.time < (controller.blackboard[BB_HORNY_TRAP_COOLDOWN] || 0))
		return FALSE
	if(!can_see(hunter, target, HORNY_TRAP_MAX_RANGE))
		return FALSE

	if(hunter.horny_trap_type && iscarbon(hunter))
		var/mob/living/carbon/thrower = hunter
		if(!horny_free_hand(thrower, controller))
			return FALSE
		var/obj/item/trap = new hunter.horny_trap_type(get_turf(thrower))
		if(!thrower.put_in_active_hand(trap))
			thrower.swap_hand()
			if(!thrower.put_in_active_hand(trap))
				qdel(trap)
				return FALSE
		controller.set_blackboard_key(BB_HORNY_TRAP_COOLDOWN, world.time + HORNY_TRAP_COOLDOWN)
		controller.set_blackboard_key(BB_HORNY_RUSH_UNTIL, world.time + HORNY_RUSH_TIME)
		thrower.visible_message(span_danger("[thrower] whirls [trap] and lets it fly at [target]!"), null, span_hear("I hear rope whistle through the air."))
		thrower.throw_item(target)
		return TRUE

	if(profile.spits_web && istype(hunter, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/spitter = hunter
		if(!spitter.ranged || !spitter.projectiletype || world.time < spitter.ranged_cooldown)
			return FALSE
		controller.set_blackboard_key(BB_HORNY_TRAP_COOLDOWN, world.time + HORNY_TRAP_COOLDOWN)
		controller.set_blackboard_key(BB_HORNY_RUSH_UNTIL, world.time + HORNY_RUSH_TIME)
		controller.set_blackboard_key(BB_HORNY_WEB_SPAT_AT, world.time)
		spitter.OpenFire(target)
		return TRUE
	return FALSE

/// A target the spit caught who goes down on the web lies presented a while. TRUE when it just began.
/proc/horny_note_webbed_fall(mob/living/target, datum/ai_controller/controller)
	var/spat_at = controller.blackboard[BB_HORNY_WEB_SPAT_AT]
	if(isnull(spat_at))
		return FALSE
	if(world.time > spat_at + HORNY_WEB_FALL_WINDOW)
		controller.clear_blackboard_key(BB_HORNY_WEB_SPAT_AT)
		return FALSE
	if(target.body_position != LYING_DOWN || !(locate(/obj/structure/spider/stickyweb) in get_turf(target)))
		return FALSE
	controller.clear_blackboard_key(BB_HORNY_WEB_SPAT_AT)
	controller.set_blackboard_key(BB_HORNY_PRESENTED_UNTIL, world.time + HORNY_PRESENTED_TIME)
	target.felt_visible_message(span_danger("[target] goes down tangled in silk, legs stuck wide."), span_userdanger("I go down in the silk, my legs stuck wide."))
	return TRUE

/// TRUE while a webbed target lies presented: the handless bear-down lands without its roll.
/proc/horny_target_presented(datum/ai_controller/controller)
	return world.time < (controller?.blackboard[BB_HORNY_PRESENTED_UNTIL] || 0)

#undef HORNY_WEB_FALL_WINDOW
#undef HORNY_PRESENTED_TIME
