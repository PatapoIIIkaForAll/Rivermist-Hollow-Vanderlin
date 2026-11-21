#define HORNY_ACTION_BLEED_HEAL_AMOUNT 30
#define BB_HORNY_BLEED_HEAL_DONE "BB_horny_bleed_heal_done"

/// The hunt: notice, stalk, seize, subdue, use and aftermath, with break-off and present as side states.
/datum/ai_behavior/horny
	action_cooldown = 1.5 SECONDS
	// Targets are often "close" but blocked by a bush or a nest edge; reach keeps the pawn pathing until adjacency is real.
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// A chase ends after this long without closing the distance.
	var/seek_timeout = HORNY_CHASE_STALL_TIMEOUT
	var/failed_seek_cooldown = 10 SECONDS
	var/successful_seek_cooldown = 15 SECONDS
	/// Phase changes allowed in one perform, so a tick can flow stalk -> seize -> subdue.
	var/max_phase_hops = 3

/datum/ai_behavior/horny/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	// A brooding spider finishes its cocoon before it hunts again.
	if(controller.blackboard[BB_SPIDER_BROOD_COCOON])
		return FALSE
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if(isnull(targetting_datum))
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/target = controller.blackboard[target_key]
	var/mob/living/target_living = target
	var/mob/living/basic_mob = controller.pawn

	if(!basic_mob.GetComponent(/datum/component/arousal))
		basic_mob.AddComponent(/datum/component/arousal)

	if((basic_mob.gender == MALE && !basic_mob.getorganslot(ORGAN_SLOT_PENIS)) || (basic_mob.gender == FEMALE && !basic_mob.getorganslot(ORGAN_SLOT_VAGINA)))
		basic_mob.give_genitals()

	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN])
		return FALSE

	if(!targetting_datum.can_horny(basic_mob, target_living))
		return FALSE

	// A lair's captive NPC takes one denizen at a time; hold the claim for the whole hunt.
	var/datum/component/npc_in_distress/distress = target_living.GetComponent(/datum/component/npc_in_distress)
	if(distress && !distress.claim_scene(basic_mob))
		return FALSE

	controller.set_blackboard_key(BB_HORNY_TIME_START, world.time)
	controller.set_blackboard_key(BB_HORNY_TEMPER, 0)
	controller.set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)
	controller.set_blackboard_key(BB_HORNY_TARGET_DAMAGE, 0)
	if(isnull(controller.blackboard[BB_HORNY_LUST]))
		controller.set_blackboard_key(BB_HORNY_LUST, 0)
	controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)
	controller.clear_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE)
	controller.clear_blackboard_key(BB_HORNY_BLEED_HEAL_DONE)
	controller.clear_blackboard_key(BB_HORNY_RUSH_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_BREAK_OFF_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_BREAK_OFF_COOLDOWN)
	controller.clear_blackboard_key(BB_HORNY_PRESENT_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_LAST_SEEN_TURF)
	controller.clear_blackboard_key(BB_HORNY_LAST_SEEN_TIME)
	controller.clear_blackboard_key(BB_HORNY_CHASE_BEST_DISTANCE)
	controller.clear_blackboard_key(BB_HORNY_CHASE_GAIN_TIME)
	controller.set_blackboard_key(BB_HORNY_STAND_UP_COUNTER, 0)
	controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
	controller.clear_blackboard_key(BB_HORNY_PACK_CALLED)
	controller.clear_blackboard_key(BB_HORNY_CIRCLE_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_SCENT_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_TIE_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_TIE_NEXT_TUG)
	controller.clear_blackboard_key(BB_HORNY_WEB_SPAT_AT)
	controller.clear_blackboard_key(BB_HORNY_PRESENTED_UNTIL)

	basic_mob.visible_message(span_boldwarning(basic_mob.get_horny_seek_message(target_living)))

	SEND_SIGNAL(basic_mob, COMSIG_SET_ERECT_STATE, 4)

	var/obj/item/organ/genitals/picked_organ
	if(basic_mob.getorganslot(ORGAN_SLOT_PENIS))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_PENIS)
	else if(basic_mob.getorganslot(ORGAN_SLOT_VAGINA))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
	if(picked_organ)
		picked_organ.toggle_visibility("Show Above clothes")

	if(QDELETED(target))
		return FALSE

	RegisterSignal(basic_mob, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(basic_mob, COMSIG_SEX_CLIMAX, PROC_REF(on_hunter_climax))
	SEND_SIGNAL(controller.pawn, COMSIG_HORNY_TARGET_SET, TRUE)

	// No tell when the hunter already stands over them.
	var/atom/interaction_anchor = get_horny_interaction_anchor(controller, basic_mob, target_living)
	if(basic_mob.Adjacent(interaction_anchor))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_SEIZE)
		set_movement_target(controller, interaction_anchor)
	else
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_NOTICE)
		set_movement_target(controller, get_turf(basic_mob))

/datum/ai_behavior/horny/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN])
		controller.CancelActions()
		controller.modify_cooldown(src, world.time)
		return FALSE

	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	var/mob/living/basic_mob = controller.pawn

	if(should_interrupt_for_aggro(controller, targetting_datum, current_target))
		stop_active_horny_actions(basic_mob)
		finish_action(controller, FALSE, target_key)
		return

	if(basic_mob.stat > SOFT_CRIT)
		return

	if(!targetting_datum.can_horny(basic_mob, current_target))
		finish_action(controller, FALSE, target_key)
		return

	if(ismob(current_target))
		if(current_target:stat == DEAD)
			finish_action(controller, FALSE, target_key)
			return

	var/mob/living/target_living = current_target
	var/obj/item/portallight/expected_portal_light = controller.blackboard[BB_HORNY_PORTAL_LIGHT]
	var/obj/item/portallight/portal_light = get_target_portal_light(controller, basic_mob, target_living)
	if(expected_portal_light && !portal_light)
		clear_completed_target_hostility(controller, target_living)
		finish_action(controller, FALSE, target_key)
		return
	var/atom/interaction_anchor = portal_light ? portal_light : target_living

	controller.decay_horny_temper()
	var/datum/horny_family_profile/profile = basic_mob.get_horny_family_profile()
	if(profile.spits_web)
		horny_note_webbed_fall(target_living, controller)
	if(target_living.surrendering && controller.blackboard[BB_HORNY_TEMPER] > 0)
		controller.horny_react(HORNY_REACT_YIELD, target_living)

	var/phase = controller.blackboard[BB_HORNY_PHASE] || HORNY_PHASE_STALK
	if(phase != HORNY_PHASE_PRESENT && basic_mob.body_position == LYING_DOWN)
		if(!basic_mob.stand_up())
			var/stand_up_counter = (controller.blackboard[BB_HORNY_STAND_UP_COUNTER] || 0) + 1
			controller.set_blackboard_key(BB_HORNY_STAND_UP_COUNTER, stand_up_counter)
			if(stand_up_counter >= 5)
				finish_action(controller, FALSE, target_key)
			return
		controller.set_blackboard_key(BB_HORNY_STAND_UP_COUNTER, 0)
		return

	if(phase != HORNY_PHASE_PRESENT && (controller.blackboard[BB_HORNY_LUST] || 0) >= HORNY_LUST_MAX)
		enter_present(controller, basic_mob, target_living)
		phase = HORNY_PHASE_PRESENT

	if(phase != HORNY_PHASE_BREAK_OFF && phase != HORNY_PHASE_PRESENT)
		if(basic_mob.get_ai_hurt_fraction() >= profile.flee_limit)
			finish_action(controller, FALSE, target_key)
			return
		if(should_break_off(controller, basic_mob, profile))
			begin_break_off(controller, basic_mob, target_living, profile)
			phase = HORNY_PHASE_BREAK_OFF

	for(var/hop in 1 to max_phase_hops)
		var/hop_again = FALSE
		switch(phase)
			if(HORNY_PHASE_NOTICE)
				hop_again = perform_notice(controller, basic_mob, target_living, profile)
			if(HORNY_PHASE_STALK)
				hop_again = perform_stalk(controller, basic_mob, target_living, interaction_anchor, portal_light, profile, target_key)
			if(HORNY_PHASE_SEIZE)
				hop_again = perform_seize(controller, basic_mob, target_living, interaction_anchor, portal_light, profile)
			if(HORNY_PHASE_SUBDUE)
				hop_again = perform_subdue(controller, basic_mob, target_living, interaction_anchor, portal_light, profile, target_key)
			if(HORNY_PHASE_USE)
				hop_again = perform_use(controller, basic_mob, target_living, interaction_anchor, portal_light, profile, target_key)
			if(HORNY_PHASE_BREAK_OFF)
				hop_again = perform_break_off(controller, basic_mob, target_living, profile, target_key)
			if(HORNY_PHASE_PRESENT)
				hop_again = perform_present(controller, basic_mob, target_living)
		if(!hop_again || !LAZYACCESS(controller.current_behaviors, src))
			break
		phase = controller.blackboard[BB_HORNY_PHASE]

// --- Phases --------------------------------------------------------------------------------------

/// Sets the hunt phase and tells both sides about it.
/datum/ai_behavior/horny/proc/set_phase(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, new_phase)
	var/old_phase = controller.blackboard[BB_HORNY_PHASE]
	if(old_phase == new_phase)
		return
	controller.set_blackboard_key(BB_HORNY_PHASE, new_phase)
	controller.set_blackboard_key(BB_HORNY_PHASE_SINCE, world.time)
	SEND_SIGNAL(basic_mob, COMSIG_HORNY_HUNT_PHASE_CHANGED, old_phase, new_phase, target_living)
	if(target_living)
		SEND_SIGNAL(target_living, COMSIG_LIVING_HUNTED, basic_mob, new_phase)
	switch(new_phase)
		if(HORNY_PHASE_NOTICE)
			bark(controller, basic_mob, target_living, HORNY_BARK_NOTICE)
		if(HORNY_PHASE_SEIZE)
			// The catch is called once, on the way in; not every time the hold slips and the hunt resets to it.
			if(old_phase != HORNY_PHASE_SUBDUE && old_phase != HORNY_PHASE_USE && old_phase != HORNY_PHASE_PRESENT)
				bark(controller, basic_mob, target_living, HORNY_BARK_SEIZE)
		if(HORNY_PHASE_BREAK_OFF)
			bark(controller, basic_mob, target_living, HORNY_BARK_BREAK_OFF)
		if(HORNY_PHASE_PRESENT)
			bark(controller, basic_mob, target_living, HORNY_BARK_PRESENT)

/// Hunters that talk say a short line over their head; the family profile picks the words.
/datum/ai_behavior/horny/proc/bark(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, context)
	if(!ishuman(basic_mob))
		return FALSE
	var/datum/horny_family_profile/profile = basic_mob.get_horny_family_profile()
	var/line = profile.get_bark(basic_mob, target_living, context)
	if(!line)
		return FALSE
	return human_npc_combat_state_balloon(controller, basic_mob, line)

/// The tell: the hunter stands and stares for a beat before it moves.
/datum/ai_behavior/horny/proc/perform_notice(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/horny_family_profile/profile)
	horny_call_pack(basic_mob, target_living, controller, profile)
	if(world.time - (controller.blackboard[BB_HORNY_PHASE_SINCE] || 0) < profile.notice_time)
		set_movement_target(controller, get_turf(basic_mob))
		basic_mob.face_atom(target_living)
		return FALSE
	set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)
	return TRUE

/// The approach: keep the target in sight, remember where it went, give up when the chase stalls.
/datum/ai_behavior/horny/proc/perform_stalk(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, atom/interaction_anchor, obj/item/portallight/portal_light, datum/horny_family_profile/profile, target_key)
	if(basic_mob.Adjacent(interaction_anchor))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_SEIZE)
		return TRUE

	if(portal_light || can_see(basic_mob, target_living, HORNY_SIGHT_RANGE))
		controller.set_blackboard_key(BB_HORNY_LAST_SEEN_TURF, get_turf(target_living))
		controller.set_blackboard_key(BB_HORNY_LAST_SEEN_TIME, world.time)
		controller.clear_blackboard_key(BB_HORNY_SCENT_UNTIL)
		set_movement_target(controller, interaction_anchor)
		if(!portal_light && try_hunt_tactics(controller, basic_mob, target_living, profile))
			return FALSE
	else
		follow_scent_trail(controller, basic_mob, target_living, profile)
		var/last_seen_time = controller.blackboard[BB_HORNY_LAST_SEEN_TIME]
		if(isnull(last_seen_time))
			last_seen_time = world.time
			controller.set_blackboard_key(BB_HORNY_LAST_SEEN_TIME, last_seen_time)
		if(world.time - last_seen_time >= HORNY_LOST_SIGHT_GIVE_UP)
			finish_action(controller, FALSE, target_key)
			return FALSE
		var/turf/last_seen_turf = controller.blackboard[BB_HORNY_LAST_SEEN_TURF]
		set_movement_target(controller, last_seen_turf || interaction_anchor)

	// The chase timer only counts time in which the hunter is not gaining ground.
	var/distance = get_dist(basic_mob, interaction_anchor)
	var/best_distance = controller.blackboard[BB_HORNY_CHASE_BEST_DISTANCE]
	if(isnull(best_distance) || distance < best_distance)
		controller.set_blackboard_key(BB_HORNY_CHASE_BEST_DISTANCE, distance)
		controller.set_blackboard_key(BB_HORNY_CHASE_GAIN_TIME, world.time)
	else if(world.time - (controller.blackboard[BB_HORNY_CHASE_GAIN_TIME] || world.time) >= seek_timeout)
		finish_action(controller, FALSE, target_key)
		return FALSE

	try_hunt_lunge(controller, basic_mob, interaction_anchor, profile)
	update_hunt_speed(controller, basic_mob, interaction_anchor, profile)
	return FALSE

/// Throw, circle, lash or pounce, in that order. TRUE when a move took this beat.
/datum/ai_behavior/horny/proc/try_hunt_tactics(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/horny_family_profile/profile)
	if(horny_throw_trap(basic_mob, target_living, controller, profile))
		return TRUE
	if(profile.circles_behind && horny_circle_target(basic_mob, target_living, controller, src))
		return TRUE
	if(horny_lash(basic_mob, target_living, controller, profile))
		return TRUE
	return horny_pounce(basic_mob, target_living, controller, profile)

/// A hunter with a nose keeps the trail warm for a while after sight is lost.
/datum/ai_behavior/horny/proc/follow_scent_trail(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/horny_family_profile/profile)
	if(!profile.follows_scent)
		return FALSE
	var/scent_until = controller.blackboard[BB_HORNY_SCENT_UNTIL]
	if(isnull(scent_until))
		scent_until = world.time + HORNY_SCENT_FOLLOW_TIME
		controller.set_blackboard_key(BB_HORNY_SCENT_UNTIL, scent_until)
	if(world.time >= scent_until)
		return FALSE
	var/turf/scent_turf = horny_find_scent_turf(basic_mob, target_living)
	if(!scent_turf)
		return FALSE
	controller.set_blackboard_key(BB_HORNY_LAST_SEEN_TURF, scent_turf)
	controller.set_blackboard_key(BB_HORNY_LAST_SEEN_TIME, world.time)
	return TRUE

/// A humanoid two or three tiles out vaults the gap, the same jump the fighters use.
/datum/ai_behavior/horny/proc/try_hunt_lunge(datum/ai_controller/controller, mob/living/basic_mob, atom/interaction_anchor, datum/horny_family_profile/profile)
	if(!profile.can_sprint || !ishuman(basic_mob) || !controller.can_move())
		return FALSE
	if(world.time < (controller.blackboard[BB_HUMAN_NPC_JUMP_COOLDOWN] || 0))
		return FALSE
	var/turf/landing_turf = human_npc_gap_close_landing(basic_mob, interaction_anchor)
	if(!landing_turf)
		return FALSE
	controller.set_blackboard_key(BB_HUMAN_NPC_JUMP_COOLDOWN, world.time + HORNY_LUNGE_COOLDOWN)
	basic_mob.face_atom(interaction_anchor)
	INVOKE_ASYNC(basic_mob, TYPE_PROC_REF(/mob/living, jump_action), landing_turf)
	return TRUE

/// The catch: handed hunters climb the real ladder, handless ones still roll until their own moves land.
/datum/ai_behavior/horny/proc/perform_seize(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, atom/interaction_anchor, obj/item/portallight/portal_light, datum/horny_family_profile/profile)
	if(!basic_mob.Adjacent(interaction_anchor))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)
		return TRUE
	set_hunt_speed_normal(controller, basic_mob)
	if(portal_light || !ishuman(target_living))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_USE)
		return TRUE
	if(tick_lust_near_aroused_target(controller, basic_mob, target_living))
		return TRUE

	var/mob/living/carbon/human/human_target = target_living
	// Handed hunters climb the real ladder: grab, grip, tackle, get on top, pin.
	if(iscarbon(basic_mob))
		switch(horny_seize_step(basic_mob, human_target, controller))
			if(HORNY_SEIZE_DONE)
				set_phase(controller, basic_mob, target_living, HORNY_PHASE_SUBDUE)
				return TRUE
			if(HORNY_SEIZE_FAILED)
				set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)
				return TRUE
		return FALSE

	// Handless hunters bear down, coil or hoist, then hold.
	var/was_standing = human_target.body_position != LYING_DOWN
	var/seize_result = horny_handless_seize_step(basic_mob, human_target, controller, profile)
	// A pounce that puts a standing target down bites as it lands.
	if(was_standing && profile.seize_move == HORNY_MOVE_POUNCE && human_target.body_position == LYING_DOWN && !human_target.surrendering)
		basic_mob.spider_bite_landed(human_target)
	switch(seize_result)
		if(HORNY_SEIZE_DONE)
			set_phase(controller, basic_mob, target_living, HORNY_PHASE_SUBDUE)
			return TRUE
		if(HORNY_SEIZE_FAILED)
			set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)
			return TRUE
	return FALSE

/// Prep on a held or floored target, one step per beat, then on to the act.
/datum/ai_behavior/horny/proc/perform_subdue(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, atom/interaction_anchor, obj/item/portallight/portal_light, datum/horny_family_profile/profile, target_key)
	if(!basic_mob.Adjacent(interaction_anchor))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)
		return TRUE
	if(portal_light || !ishuman(target_living))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_USE)
		return TRUE

	var/mob/living/carbon/human/human_target = target_living
	if(!horny_target_is_subdued(basic_mob, human_target))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_SEIZE)
		return TRUE
	if(tick_lust_near_aroused_target(controller, basic_mob, target_living))
		return TRUE
	if(ensure_hold(controller, basic_mob, human_target, profile))
		pause_after_prep(controller)
		return FALSE
	horny_squeeze(basic_mob, human_target, profile)

	var/datum/sex_scene_controller/scene_controller = basic_mob.open_sex_scene(human_target, FALSE)
	if(!scene_controller)
		finish_action(controller, FALSE, target_key)
		return FALSE
	if(length(scene_controller.get_active_actions()))
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_USE)
		return TRUE

	var/has_valid_act = !isnull(select_horny_ai_act(controller, basic_mob, human_target, scene_controller))
	for(var/datum/horny_prep_step/step as anything in profile.prep_steps)
		if(!step.can_run(controller, basic_mob, human_target, profile, has_valid_act))
			continue
		if(step.perform_step(controller, basic_mob, human_target, profile, has_valid_act))
			pause_after_prep(controller)
			return FALSE
	set_phase(controller, basic_mob, target_living, HORNY_PHASE_USE)
	return TRUE

/// The act. Nothing starts on a target that is still on its feet and free.
/datum/ai_behavior/horny/proc/perform_use(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, atom/interaction_anchor, obj/item/portallight/portal_light, datum/horny_family_profile/profile, target_key)
	var/datum/component/knotting/tied = horny_knot_between(basic_mob, target_living)
	if(!tied)
		controller.clear_blackboard_key(BB_HORNY_TIE_UNTIL)
		controller.clear_blackboard_key(BB_HORNY_TIE_NEXT_TUG)
	if(!basic_mob.Adjacent(interaction_anchor))
		stop_active_horny_actions(basic_mob)
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)
		return TRUE
	// The knot is the hold while it lasts.
	if(!tied && !portal_light && !horny_target_is_subdued(basic_mob, target_living))
		stop_active_horny_actions(basic_mob)
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_SEIZE)
		return TRUE

	var/list/arousal_data = list()
	SEND_SIGNAL(basic_mob, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/last_orgasm_time = arousal_data["last_ejaculation_time"]
	var/horny_start_time = controller.blackboard[BB_HORNY_TIME_START]
	if(isnull(horny_start_time))
		horny_start_time = world.time
		controller.set_blackboard_key(BB_HORNY_TIME_START, horny_start_time)

	var/datum/sex_scene_controller/scene_controller = basic_mob.open_sex_scene(target_living, FALSE)
	if(!scene_controller)
		finish_action(controller, FALSE, target_key)
		return FALSE

	var/interaction_timed_out = horny_start_time + HORNY_INTERACTION_TIMEOUT <= world.time
	if(tied)
		return perform_tied(controller, basic_mob, target_living, scene_controller, profile, target_key, tied, interaction_timed_out)
	if(last_orgasm_time > world.time - 10 SECONDS || interaction_timed_out)
		if(interaction_timed_out && length(scene_controller.get_active_actions()))
			offer_target_rune_escape(target_living)
		scene_controller.stop_action()
		finish_action(controller, TRUE, target_key)
		return FALSE

	if(tick_lust_near_aroused_target(controller, basic_mob, target_living, length(scene_controller.get_active_actions())))
		return TRUE

	if(portal_light)
		if(ishuman(basic_mob) && prepare_portal_light(controller, basic_mob, portal_light))
			pause_after_prep(controller)
			return FALSE
		start_horny_action(controller, basic_mob, target_living, scene_controller, target_key)
		return FALSE

	if(ishuman(target_living))
		ensure_hold(controller, basic_mob, target_living, profile)
		horny_squeeze(basic_mob, target_living, profile)
	// Worked up by the ordinary act: an ovipositor hunter pulls out and lays instead.
	if(should_switch_to_egg_act(basic_mob, target_living, scene_controller))
		scene_controller.stop_action()
		return FALSE
	if(start_horny_action(controller, basic_mob, target_living, scene_controller, target_key))
		return FALSE
	if(!LAZYACCESS(controller.current_behaviors, src))
		return FALSE
	// Nothing fits yet: go back and strip or bind some more.
	set_phase(controller, basic_mob, target_living, HORNY_PHASE_SUBDUE)
	return TRUE

/// Tied by a knot: tug now and then, and once the tie time is up slip free and end sated.
/datum/ai_behavior/horny/proc/perform_tied(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_scene_controller/scene_controller, datum/horny_family_profile/profile, target_key, datum/component/knotting/tied, interaction_timed_out)
	var/tie_until = controller.blackboard[BB_HORNY_TIE_UNTIL]
	if(isnull(tie_until))
		tie_until = world.time + profile.tie_time
		controller.set_blackboard_key(BB_HORNY_TIE_UNTIL, tie_until)
		controller.set_blackboard_key(BB_HORNY_TIE_NEXT_TUG, world.time + HORNY_TIE_TUG_INTERVAL)

	if(world.time >= tie_until || interaction_timed_out)
		if(interaction_timed_out && length(scene_controller.get_active_actions()))
			offer_target_rune_escape(target_living)
		scene_controller.stop_action()
		// The owner may be the victim when the hunter rides a knot.
		if(tied.knotted_owner)
			SEND_SIGNAL(tied.knotted_owner, COMSIG_SEX_REMOVE_KNOT, FALSE, TRUE)
		finish_action(controller, TRUE, target_key)
		return FALSE

	if(world.time < (controller.blackboard[BB_HORNY_TIE_NEXT_TUG] || 0))
		return FALSE
	controller.set_blackboard_key(BB_HORNY_TIE_NEXT_TUG, world.time + HORNY_TIE_TUG_INTERVAL)
	var/list/lines = profile.get_tie_lines(basic_mob, target_living)
	target_living.felt_visible_message(span_love(lines["tug"]), span_love(lines["tug_me"]), span_hear(lines["tug_hear"]))
	var/list/active_actions = scene_controller.get_active_actions()
	if(length(active_actions))
		var/datum/sex_action/action = active_actions[1]
		action.perform_sex_action(target_living, basic_mob, 2, 1, 1.5)
	return FALSE

/// TRUE when temper or pain says this family stops hunting for a while.
/datum/ai_behavior/horny/proc/should_break_off(datum/ai_controller/controller, mob/living/basic_mob, datum/horny_family_profile/profile)
	if(profile.break_off == HORNY_BREAK_OFF_NONE || profile.break_off == HORNY_BREAK_OFF_ENRAGE)
		return FALSE
	if(world.time < (controller.blackboard[BB_HORNY_BREAK_OFF_COOLDOWN] || 0))
		return FALSE
	if((controller.blackboard[BB_HORNY_TEMPER] || 0) >= HORNY_TEMPER_FURIOUS)
		return TRUE
	return basic_mob.get_ai_hurt_fraction() >= profile.hurt_limit

/datum/ai_behavior/horny/proc/begin_break_off(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/horny_family_profile/profile)
	stop_active_horny_actions(basic_mob)
	if(basic_mob.pulling == target_living)
		basic_mob.stop_pulling()
	var/window = profile.break_off == HORNY_BREAK_OFF_SUBDUE ? HORNY_SUBDUE_WINDOW : HORNY_BREAK_OFF_TIME
	controller.set_blackboard_key(BB_HORNY_BREAK_OFF_UNTIL, world.time + window)
	basic_mob.visible_message(span_danger(profile.get_break_off_message(basic_mob, target_living)))
	set_phase(controller, basic_mob, target_living, HORNY_PHASE_BREAK_OFF)

/// Furious: wrestle without using, back off and circle, or sink away. Then come back calmer.
/datum/ai_behavior/horny/proc/perform_break_off(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/horny_family_profile/profile, target_key)
	if(world.time >= (controller.blackboard[BB_HORNY_BREAK_OFF_UNTIL] || 0))
		end_break_off(controller, basic_mob, target_living)
		return TRUE

	switch(profile.break_off)
		if(HORNY_BREAK_OFF_SUBDUE)
			set_movement_target(controller, target_living)
			if(!basic_mob.Adjacent(target_living) || !ishuman(target_living))
				return FALSE
			var/mob/living/carbon/human/human_target = target_living
			// The subdue window is the ladder without the act: wrestle them down and keep them there.
			if(iscarbon(basic_mob))
				horny_seize_step(basic_mob, human_target, controller)
				return FALSE
			horny_handless_seize_step(basic_mob, human_target, controller, profile)
			return FALSE
		if(HORNY_BREAK_OFF_SINK)
			var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/burrow = basic_mob
			if(istype(burrow))
				burrow.hide_in_ground()
				finish_action(controller, FALSE, target_key)
				return FALSE
			keep_away(controller, basic_mob, target_living, HORNY_CIRCLE_RANGE)
			return FALSE
		if(HORNY_BREAK_OFF_FLEE)
			keep_away(controller, basic_mob, target_living, HORNY_FLEE_RANGE)
			return FALSE

	// Circle: hold a distance, and pounce the moment the target shows its back or goes down.
	if(get_dist(basic_mob, target_living) <= HORNY_CIRCLE_RANGE && basic_mob.get_positioning_modifier(target_living) >= 1.3)
		end_break_off(controller, basic_mob, target_living)
		return TRUE
	keep_away(controller, basic_mob, target_living, HORNY_CIRCLE_RANGE)
	return FALSE

/// Steps to a tile the given range away from the target and waits there, facing it.
/datum/ai_behavior/horny/proc/keep_away(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, range)
	if(get_dist(basic_mob, target_living) >= range)
		set_movement_target(controller, get_turf(basic_mob))
		basic_mob.face_atom(target_living)
		return
	var/turf/away = get_ranged_target_turf_direct(basic_mob, target_living, range, 180)
	set_movement_target(controller, away || get_turf(basic_mob))

/datum/ai_behavior/horny/proc/end_break_off(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	controller.clear_blackboard_key(BB_HORNY_BREAK_OFF_UNTIL)
	controller.set_blackboard_key(BB_HORNY_BREAK_OFF_COOLDOWN, world.time + HORNY_BREAK_OFF_TIME)
	controller.set_blackboard_key(BB_HORNY_TEMPER, min(controller.blackboard[BB_HORNY_TEMPER] || 0, HORNY_TEMPER_ROUGH))
	controller.set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)
	set_phase(controller, basic_mob, target_living, HORNY_PHASE_STALK)

/// Overwhelmed: the hunter lets go and lies open for a while.
/datum/ai_behavior/horny/proc/enter_present(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(controller.blackboard[BB_HORNY_PHASE] == HORNY_PHASE_PRESENT)
		return
	var/datum/horny_family_profile/profile = basic_mob.get_horny_family_profile()
	stop_active_horny_actions(basic_mob)
	if(basic_mob.pulling)
		basic_mob.stop_pulling()
	controller.set_blackboard_key(BB_HORNY_PRESENT_UNTIL, world.time + HORNY_PRESENT_TIME)
	basic_mob.visible_message(span_love(profile.get_present_message(basic_mob, target_living)))
	set_phase(controller, basic_mob, target_living, HORNY_PHASE_PRESENT)
	profile.on_overwhelmed(controller, basic_mob, target_living)

/datum/ai_behavior/horny/proc/perform_present(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(world.time >= (controller.blackboard[BB_HORNY_PRESENT_UNTIL] || 0))
		controller.clear_blackboard_key(BB_HORNY_PRESENT_UNTIL)
		controller.set_blackboard_key(BB_HORNY_LUST, HORNY_LUST_AFTER_PRESENT)
		if(basic_mob.resting)
			basic_mob.set_resting(FALSE, TRUE, TRUE)
		set_phase(controller, basic_mob, target_living, HORNY_PHASE_SEIZE)
		return TRUE
	set_movement_target(controller, get_turf(basic_mob))
	if(!basic_mob.resting)
		basic_mob.set_resting(TRUE, TRUE, TRUE)
	return FALSE

// --- Speed ---------------------------------------------------------------------------------------

/// Humans run inside the sprint range or during a rush; handless hunters rush by shortening their step delay.
/datum/ai_behavior/horny/proc/update_hunt_speed(datum/ai_controller/controller, mob/living/basic_mob, atom/interaction_anchor, datum/horny_family_profile/profile)
	var/rushing = world.time < (controller.blackboard[BB_HORNY_RUSH_UNTIL] || 0)
	if(ishuman(basic_mob))
		var/want_run = profile.can_sprint && (rushing || get_dist(basic_mob, interaction_anchor) <= profile.sprint_range)
		if(want_run)
			if(basic_mob.m_intent != MOVE_INTENT_RUN)
				basic_mob.toggle_rogmove_intent(MOVE_INTENT_RUN, TRUE)
			if(basic_mob.m_intent == MOVE_INTENT_RUN)
				controller.set_blackboard_key(BB_HORNY_SPRINTING, TRUE)
		else if(controller.blackboard[BB_HORNY_SPRINTING])
			set_hunt_speed_normal(controller, basic_mob)
		return
	if(rushing && profile.pain_factor > 0)
		if(isnull(controller.blackboard[BB_HORNY_BASE_MOVE_DELAY]))
			controller.set_blackboard_key(BB_HORNY_BASE_MOVE_DELAY, controller.movement_delay)
			controller.movement_delay = controller.movement_delay * profile.rush_speed_mult
	else if(!rushing)
		set_hunt_speed_normal(controller, basic_mob)

/// Back to a walk and the normal step delay.
/datum/ai_behavior/horny/proc/set_hunt_speed_normal(datum/ai_controller/controller, mob/living/basic_mob)
	if(controller.blackboard[BB_HORNY_SPRINTING])
		controller.clear_blackboard_key(BB_HORNY_SPRINTING)
		if(basic_mob.m_intent == MOVE_INTENT_RUN)
			basic_mob.toggle_rogmove_intent(MOVE_INTENT_WALK, TRUE)
	var/base_delay = controller.blackboard[BB_HORNY_BASE_MOVE_DELAY]
	if(!isnull(base_delay))
		controller.movement_delay = base_delay
		controller.clear_blackboard_key(BB_HORNY_BASE_MOVE_DELAY)

// --- Holds and the catch -------------------------------------------------------------------------

/// Floored, bound, buckled or yielded: only then may an act start. A hold on a standing target is not enough.
/proc/horny_target_is_subdued(mob/living/hunter, mob/living/target)
	if(!target)
		return FALSE
	if(target.buckled)
		return TRUE
	if(HAS_TRAIT(target, TRAIT_RESTRAINED))
		return TRUE
	if(target.surrendering)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/defeat_knockout))
		return TRUE
	return target.body_position == LYING_DOWN

/// The knot tying a to b or b to a right now, else null.
/proc/horny_knot_between(mob/living/a, mob/living/b)
	if(QDELETED(a) || QDELETED(b))
		return null
	var/datum/component/knotting/knot = a.GetComponent(/datum/component/knotting)
	if(knot?.knotted_recipient == b)
		return knot
	knot = b.GetComponent(/datum/component/knotting)
	if(knot?.knotted_recipient == a)
		return knot
	return null

/// Keeps a grip on the target. A handless hold prints its line and returns TRUE when newly set.
/datum/ai_behavior/horny/proc/ensure_hold(datum/ai_controller/controller, mob/living/basic_mob, mob/living/carbon/human/human_target, datum/horny_family_profile/profile)
	if(iscarbon(basic_mob))
		horny_ensure_grab(basic_mob, human_target, controller)
		return FALSE
	return horny_handless_hold(basic_mob, human_target, profile)

// --- The act -------------------------------------------------------------------------------------

/// A target already dripping with arousal feeds the hunter's lust while it closes in and holds, not during the act.
/datum/ai_behavior/horny/proc/tick_lust_near_aroused_target(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, act_running = FALSE)
	if(act_running)
		return FALSE
	var/list/arousal_data = list()
	SEND_SIGNAL(target_living, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if((arousal_data["arousal"] || 0) < HORNY_LUST_TARGET_AROUSAL)
		return FALSE
	controller.add_horny_lust(HORNY_LUST_PER_SECOND_NEAR_AROUSED * (action_cooldown / 10))
	if(controller.blackboard[BB_HORNY_LUST] < HORNY_LUST_MAX)
		return FALSE
	enter_present(controller, basic_mob, target_living)
	return TRUE

/// Starts or keeps an act. FALSE when nothing fits; gives the hunt up after enough empty tries.
/datum/ai_behavior/horny/proc/start_horny_action(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_scene_controller/scene_controller, target_key)
	if(!scene_controller)
		return FALSE
	if(length(scene_controller.get_active_actions()))
		controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
		return TRUE

	var/action_type = select_horny_ai_act(controller, basic_mob, target_living, scene_controller)
	if(!isnull(action_type))
		pace_for_knot(basic_mob, scene_controller.try_start_action(action_type, "ai"))
	if(!length(scene_controller.get_active_actions()))
		var/actionless_ticks = (controller.blackboard[BB_HORNY_ACTIONLESS_TICKS] || 0) + 1
		controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, actionless_ticks)
		if(actionless_ticks >= 6)
			finish_action(controller, FALSE, target_key)
		return FALSE

	controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
	bark(controller, basic_mob, target_living, HORNY_BARK_ACT_START)
	target_living.note_horny_scene_captor(basic_mob)
	var/atom/interaction_anchor = get_horny_interaction_anchor(controller, basic_mob, target_living)
	basic_mob.face_atom(interaction_anchor ? interaction_anchor : target_living)
	// A calm hunter varies its pace; a rough one does not hold back.
	var/temper = controller.blackboard[BB_HORNY_TEMPER] || 0
	var/force = temper >= HORNY_TEMPER_ROUGH ? SEX_FORCE_MAX : rand(SEX_FORCE_MID, SEX_FORCE_MAX)
	var/speed = temper >= HORNY_TEMPER_ROUGH ? SEX_SPEED_MAX : rand(SEX_SPEED_MID, SEX_SPEED_MAX)
	scene_controller.set_current_force(force)
	scene_controller.set_current_speed(speed)
	if(target_living.gender == MALE)
		target_living.apply_status_effect(/datum/status_effect/debuff/mob_fucked/male)
	else
		target_living.apply_status_effect(/datum/status_effect/debuff/mob_fucked)
	try_heal_horny_action_bleeding(controller, target_living)
	return TRUE

/// A knotted hunter keeps a knotting act running past its climax, so the tie can hold.
/datum/ai_behavior/horny/proc/pace_for_knot(mob/living/basic_mob, datum/sex_action/action)
	if(!action?.knot_on_finish || !basic_mob.GetComponent(/datum/component/knotting))
		return FALSE
	action.stop_on_climax = FALSE
	return TRUE

/datum/ai_behavior/horny/proc/select_horny_ai_act(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_scene_controller/scene_controller)
	var/list/weighted_actions = list()
	if(get_target_portal_light(controller, basic_mob, target_living))
		add_portal_horny_ai_actions(weighted_actions, basic_mob, target_living)
	else
		add_local_horny_ai_actions(weighted_actions, basic_mob, target_living)

	if(!length(weighted_actions))
		return null

	var/list/valid_actions = list()
	for(var/datum/sex_action/action_type as anything in weighted_actions)
		var/datum/sex_action_proposal/proposal = scene_controller.create_action_proposal(action_type, "ai")
		var/can_start = proposal?.can_start()
		qdel(proposal)
		if(can_start)
			valid_actions += action_type

	if(!length(valid_actions))
		return null

	var/list/scored_action_types = list()
	for(var/action_type in valid_actions.Copy())
		if(action_type in scored_action_types)
			continue
		scored_action_types += action_type
		var/datum/sex_action_proposal/proposal = scene_controller.create_action_proposal(action_type, "ai")
		var/pattern_desirability = proposal?.get_pattern_desirability()
		qdel(proposal)
		if(pattern_desirability > 0)
			add_weighted_horny_ai_choice(valid_actions, action_type, pattern_desirability)

	return pick(valid_actions)

/// TRUE when an ordinary act runs, the hunter is ready to lay and nothing ties them together.
/datum/ai_behavior/horny/proc/should_switch_to_egg_act(mob/living/basic_mob, mob/living/target_living, datum/sex_scene_controller/scene_controller)
	var/list/active = scene_controller.get_active_actions()
	if(!length(active))
		return FALSE
	for(var/datum/sex_action/action as anything in active)
		if(is_lay_egg_act(action))
			return FALSE
	return horny_should_pull_out_to_lay(basic_mob, target_living)

/// TRUE when an AI hunter's ordinary act should end so its hunt starts a lay act.
/proc/horny_should_pull_out_to_lay(mob/living/hunter, mob/living/target)
	if(!hunter?.ai_controller || hunter.client || horny_knot_between(hunter, target))
		return FALSE
	return horny_egg_lay_ready(hunter, target)

/// The AI's egg acts, by type.
/proc/is_lay_egg_act(datum/sex_action/action)
	return istype(action, /datum/sex_action/npc/npc_vaginal_sex/lay_eggs) \
		|| istype(action, /datum/sex_action/npc/npc_anal_sex/lay_eggs) \
		|| istype(action, /datum/sex_action/npc/npc_throat_sex/lay_eggs)

/// Holds the next prep step back a moment, so the moves read one at a time.
/datum/ai_behavior/horny/proc/pause_after_prep(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
	controller.modify_cooldown(src, max(controller.behavior_cooldowns[src], world.time + HORNY_PREP_PAUSE))

/datum/ai_behavior/horny/proc/stop_active_horny_actions(mob/living/basic_mob)
	if(!basic_mob)
		return

	var/list/actions_to_stop = basic_mob.sex_scene?.get_actions_involving(basic_mob)
	for(var/datum/sex_action/action as anything in actions_to_stop)
		if(action.action_user != basic_mob)
			continue
		basic_mob.sex_scene.stop_action(action)

/datum/ai_behavior/horny/proc/offer_target_rune_escape(mob/living/target_living)
	if(!ishuman(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	var/datum/resurrection_rune_controller/rune_controller = get_resurrection_rune_controller_for_user(human_target)
	if(!rune_controller)
		return FALSE
	return rune_controller.offer_mob_erp_escape(human_target)

/datum/ai_behavior/horny/proc/heal_horny_action_bleeding(mob/living/participant)
	if(!participant || QDELETED(participant))
		return FALSE
	if(participant.get_bleed_rate() <= 0)
		return FALSE

	var/list/wounds = participant.get_wounds()
	if(!length(wounds))
		return FALSE

	var/processed_any = FALSE
	for(var/datum/wound/wound as anything in wounds)
		if(QDELETED(wound) || !(wound.bleed_rate > 0))
			continue
		processed_any = TRUE
		if(wound.can_sew)
			wound.sew_wound()
		if(QDELETED(wound))
			continue
		if(wound.bleed_rate > 0 && wound.can_cauterize)
			wound.cauterize_wound()
		if(QDELETED(wound))
			continue
		if(wound.bleed_rate > 0)
			wound.bleed_rate = 0
		wound.heal_wound(HORNY_ACTION_BLEED_HEAL_AMOUNT)

	if(!processed_any)
		return FALSE

	participant.update_damage_overlays()
	return TRUE

/datum/ai_behavior/horny/proc/try_heal_horny_action_bleeding(datum/ai_controller/controller, mob/living/target_living)
	if(!controller || controller.blackboard[BB_HORNY_BLEED_HEAL_DONE])
		return

	if(!heal_horny_action_bleeding(target_living))
		return

	controller.set_blackboard_key(BB_HORNY_BLEED_HEAL_DONE, TRUE)

// --- Threats -------------------------------------------------------------------------------------

/datum/ai_behavior/horny/proc/is_valid_aggro_interrupt_target(mob/living/basic_mob, datum/targetting_datum/targetting_datum, atom/target)
	if(!target || target == basic_mob || QDELETED(target))
		return FALSE
	if(!basic_mob.ai_controller?.is_threat_in_reach(target))
		return FALSE

	// Human NPCs can consider prone, armed victims "disarm targets"; that should not
	// override horny retargeting while this same mob is still a valid horny partner.
	if(targetting_datum.can_horny(basic_mob, target))
		return FALSE

	if(!targetting_datum.can_attack(basic_mob, target) && !targetting_datum.should_disarm(basic_mob, target))
		return FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return FALSE
		if(living_target.alpha <= 100 || living_target.rogue_sneaking)
			var/extra_chance = basic_mob.get_npc_sneak_alert_bonus()
			if(!basic_mob.npc_detect_sneak(living_target, extra_chance))
				return FALSE

	return TRUE

/datum/ai_behavior/horny/proc/should_interrupt_for_aggro(datum/ai_controller/controller, datum/targetting_datum/targetting_datum, atom/current_horny_target)
	var/mob/living/basic_mob = controller?.pawn
	if(!basic_mob || !targetting_datum)
		return FALSE

	if(current_horny_target && targetting_datum.is_horny_target_now_hostile(basic_mob, current_horny_target))
		return TRUE

	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(current_target != current_horny_target && is_valid_aggro_interrupt_target(basic_mob, targetting_datum, current_target))
		return TRUE

	var/atom/highest_threat = controller.blackboard[BB_HIGHEST_THREAT_MOB]
	if(highest_threat != current_horny_target && is_valid_aggro_interrupt_target(basic_mob, targetting_datum, highest_threat))
		return TRUE

	return FALSE

// --- Portal lights -------------------------------------------------------------------------------

/datum/ai_behavior/horny/proc/get_target_portal_light(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!controller || !basic_mob || !target_living)
		return null

	var/obj/item/portallight/portal_light = controller.blackboard[BB_HORNY_PORTAL_LIGHT]
	if(!istype(portal_light))
		return null
	if(QDELETED(portal_light))
		controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
		return null
	if(portal_light.get_wearer() != target_living)
		controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
		return null

	if(iscarbon(basic_mob))
		if(portal_light.loc != basic_mob && !isturf(portal_light.loc))
			controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
			return null
	else if(!isturf(portal_light.loc))
		controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
		return null

	return portal_light

/datum/ai_behavior/horny/proc/get_horny_interaction_anchor(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	var/obj/item/portallight/portal_light = get_target_portal_light(controller, basic_mob, target_living)
	if(portal_light)
		return portal_light
	return target_living

/datum/ai_behavior/horny/proc/prepare_portal_light(datum/ai_controller/controller, mob/living/carbon/human/human_basic_mob, obj/item/portallight/portal_light)
	if(human_basic_mob.get_active_held_item() == portal_light)
		return FALSE

	if(human_basic_mob.get_inactive_held_item() == portal_light)
		human_basic_mob.swap_hand()
		return TRUE

	if(!isturf(portal_light.loc))
		return FALSE
	if(!human_basic_mob.Adjacent(portal_light))
		return FALSE

	if(human_basic_mob.get_active_held_item())
		human_basic_mob.swap_hand()
		if(human_basic_mob.get_active_held_item())
			human_basic_mob.swap_hand()
			var/obj/item/active_item = human_basic_mob.get_active_held_item()
			var/datum/component/ai_inventory_manager/inventory = controller.get_inventory()
			if(active_item && !(inventory && inventory.stow_item(active_item)))
				human_basic_mob.dropItemToGround(active_item)
		if(human_basic_mob.get_active_held_item())
			return FALSE

	human_basic_mob.visible_message(span_notice("[human_basic_mob] reaches for [portal_light]."))
	if(!human_basic_mob.put_in_active_hand(portal_light) && !human_basic_mob.put_in_hands(portal_light))
		return FALSE
	if(human_basic_mob.get_inactive_held_item() == portal_light)
		human_basic_mob.swap_hand()
	return TRUE

// --- Aftermath -----------------------------------------------------------------------------------

/datum/ai_behavior/horny/proc/clear_completed_target_hostility(datum/ai_controller/controller, atom/finished_target)
	if(!controller || !finished_target)
		return

	// A partner who just completed an encounter with us should not stay stuck in combat
	// memory and block horny retargeting after the seek cooldown ends.
	var/mob/living/basic_mob = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]
	if(targetting_datum && basic_mob)
		targetting_datum.clear_horny_target_hostility(basic_mob, finished_target)
		return

	var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	if(hostile_targets && !isnull(hostile_targets[finished_target]))
		controller.remove_thing_from_blackboard_key(BB_HORNY_HOSTILE_TARGETS, finished_target)
	if(controller.blackboard[BB_HORNY_AGGRO_TARGET] == finished_target)
		controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)

	var/list/retaliate_list = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if(retaliate_list && !isnull(retaliate_list[finished_target]))
		controller.remove_thing_from_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST, finished_target)

	var/list/aggro_table = controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(aggro_table && !isnull(aggro_table[finished_target]))
		aggro_table -= finished_target

	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == finished_target)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

	if(controller.blackboard[BB_HIGHEST_THREAT_MOB] == finished_target)
		controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)

/datum/ai_behavior/horny/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic_mob = controller.pawn
	var/atom/finished_target = controller.blackboard[target_key]
	var/hunt_started = controller.blackboard[BB_HORNY_TIME_START]
	var/datum/sex_scene_controller/scene_controller = basic_mob.sex_scene?.get_controller(basic_mob)

	stop_active_horny_actions(basic_mob)
	if(scene_controller && !QDELETED(scene_controller))
		qdel(scene_controller)

	UnregisterSignal(basic_mob, list(COMSIG_ATOM_WAS_ATTACKED, COMSIG_SEX_CLIMAX))
	var/datum/component/npc_in_distress/distress = finished_target?.GetComponent(/datum/component/npc_in_distress)
	distress?.release_scene(basic_mob)

	SEND_SIGNAL(basic_mob, COMSIG_SET_ERECT_STATE, 0)

	var/obj/item/organ/genitals/picked_organ
	if(basic_mob.getorganslot(ORGAN_SLOT_PENIS))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_PENIS)
		picked_organ.toggle_visibility(FALSE)
	if(basic_mob.getorganslot(ORGAN_SLOT_VAGINA))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
		picked_organ.toggle_visibility(FALSE)

	// A knot still tied comes out now: slipped free after a sated end, torn out otherwise.
	var/datum/component/knotting/knot = isliving(finished_target) ? horny_knot_between(basic_mob, finished_target) : null
	if(knot?.knotted_owner)
		SEND_SIGNAL(knot.knotted_owner, COMSIG_SEX_REMOVE_KNOT, !succeeded, TRUE)

	basic_mob.stop_pulling()
	basic_mob.cmode = FALSE
	set_hunt_speed_normal(controller, basic_mob)
	var/old_phase = controller.blackboard[BB_HORNY_PHASE]
	if(old_phase == HORNY_PHASE_PRESENT && basic_mob.resting)
		basic_mob.set_resting(FALSE, TRUE, TRUE)
	if(old_phase)
		SEND_SIGNAL(basic_mob, COMSIG_HORNY_HUNT_PHASE_CHANGED, old_phase, null, finished_target)
		if(isliving(finished_target))
			SEND_SIGNAL(finished_target, COMSIG_LIVING_HUNTED, basic_mob, null)

	controller.clear_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE)
	controller.clear_blackboard_key(BB_HORNY_BLEED_HEAL_DONE)
	controller.clear_blackboard_key(BB_HORNY_STAND_UP_COUNTER)
	controller.clear_blackboard_key(BB_HORNY_ACTIONLESS_TICKS)
	controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)
	controller.clear_blackboard_key(BB_HORNY_PACK_CALLED)
	controller.clear_blackboard_key(BB_HORNY_CIRCLE_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_SCENT_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
	controller.clear_blackboard_key(BB_HORNY_PHASE)
	controller.clear_blackboard_key(BB_HORNY_PHASE_SINCE)
	controller.clear_blackboard_key(BB_HORNY_TEMPER)
	controller.clear_blackboard_key(BB_HORNY_TEMPER_TIME)
	controller.clear_blackboard_key(BB_HORNY_TARGET_DAMAGE)
	controller.clear_blackboard_key(BB_HORNY_LAST_SEEN_TURF)
	controller.clear_blackboard_key(BB_HORNY_LAST_SEEN_TIME)
	controller.clear_blackboard_key(BB_HORNY_CHASE_BEST_DISTANCE)
	controller.clear_blackboard_key(BB_HORNY_CHASE_GAIN_TIME)
	controller.clear_blackboard_key(BB_HORNY_RUSH_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_BREAK_OFF_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_BREAK_OFF_COOLDOWN)
	controller.clear_blackboard_key(BB_HORNY_PRESENT_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_WRESTLE_PRESSURE)
	controller.clear_blackboard_key(BB_HORNY_PINNED)
	controller.clear_blackboard_key(BB_HORNY_TIE_UNTIL)
	controller.clear_blackboard_key(BB_HORNY_TIE_NEXT_TUG)
	controller.clear_blackboard_key(BB_HORNY_WEB_SPAT_AT)
	controller.clear_blackboard_key(BB_HORNY_PRESENTED_UNTIL)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_HORNY_DIRECTED_TARGET)
	controller.clear_blackboard_key(BB_HORNY_TIME_START)
	if(basic_mob.is_dead())
		return
	// Planning handed this partner to the kidnap behaviour: no sulking, just a short pause.
	if(!succeeded && finished_target && controller.blackboard[BB_KIDNAP_TARGET] == finished_target)
		controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + failed_seek_cooldown)
		controller.modify_cooldown(src, world.time)
		return
	if(!succeeded)
		controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + failed_seek_cooldown)
		basic_mob.visible_message(span_danger(basic_mob.get_horny_unsatisfied_message()))
		bark(controller, basic_mob, finished_target, HORNY_BARK_LOST)
		controller.modify_cooldown(src, world.time)
		return

	// Sated: the hunger is gone for a while, and so is the lust.
	clear_completed_target_hostility(controller, finished_target)
	controller.set_blackboard_key(BB_HORNY_LUST, 0)
	var/success_cooldown = successful_seek_cooldown
	var/datum/component/arousal/arousal_component = basic_mob.GetComponent(/datum/component/arousal)
	var/heavily_sated = arousal_component?.recent_orgasm_count >= 3
	if(heavily_sated)
		success_cooldown += 3 MINUTES
	controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + success_cooldown)
	basic_mob.visible_message(span_danger(basic_mob.get_horny_sated_message(finished_target, heavily_sated)))
	bark(controller, basic_mob, finished_target, HORNY_BARK_SATED)
	controller.modify_cooldown(src, world.time)
	spider_claim_spent_partner(controller, basic_mob, finished_target, hunt_started)

/// A spider that came winds up a partner who yields or lies senseless; a willing one walks away.
/datum/ai_behavior/horny/proc/spider_claim_spent_partner(datum/ai_controller/controller, mob/living/basic_mob, atom/finished_target, hunt_started)
	if(controller.horny_pref_family_flag != HORNY_MOB_TYPE_SPIDERS || !isliving(finished_target))
		return FALSE
	var/list/arousal_data = list()
	SEND_SIGNAL(basic_mob, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if((arousal_data["last_ejaculation_time"] || 0) < (hunt_started || world.time))
		return FALSE
	controller.set_blackboard_key(BB_SPIDER_SATED_WITH, finished_target)
	if(!spider_can_wrap(basic_mob, finished_target))
		controller.clear_blackboard_key(BB_SPIDER_SATED_WITH)
		return FALSE
	controller.set_blackboard_key(BB_BASIC_MOB_COCOON_TARGET, finished_target)
	return TRUE

#undef HORNY_ACTION_BLEED_HEAL_AMOUNT
#undef BB_HORNY_BLEED_HEAL_DONE
