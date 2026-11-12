#define SEX_STAMINA_MODIFIER 0.2 //Just a stopgap so that you don't tire out immediately

/datum/sex_scene_resource_claim
	var/datum/sex_action/owner
	var/datum/sex_scene/scene
	var/mob/living/locked_host
	var/locked_organ_slot
	var/obj/item/locked_item
	var/hard_lock = TRUE

/datum/sex_scene_resource_claim/New(datum/sex_action/owner, mob/_host, _locked_slot, obj/item/_locked_item, _hard_lock = TRUE)
	. = ..()
	src.owner = owner
	scene = owner?.scene
	locked_host = _host
	locked_organ_slot = _locked_slot
	locked_item = _locked_item
	hard_lock = _hard_lock
	scene?.add_resource_claim(src)

/datum/sex_scene_resource_claim/Destroy(force, ...)
	scene?.remove_resource_claim(src)
	owner = null
	scene = null
	locked_host = null
	locked_item = null
	return ..()

/datum/storage_tracking_entry
	var/obj/item/stored_item = null
	var/mob/living/original_owner = null
	var/insertion_time = null
	var/hole_id = null
	var/stored_by_ckey = null

/datum/storage_tracking_entry/New(obj/item/item, mob/living/owner, hole_id_param, mob/living/stored_by)
	stored_item = item
	original_owner = owner
	insertion_time = world.time
	hole_id = hole_id_param
	if(stored_by?.ckey)
		stored_by_ckey = stored_by.ckey

/datum/storage_tracking_entry/Destroy()
	stored_item = null
	original_owner = null
	return ..()


/datum/sex_action
	abstract_type = /datum/sex_action

	/// Display name of the action
	var/name = "Generic Action"
	///Description for hover
	var/description = "Generic desc"

	/// Actor controller carried by a pending proposal before acceptance.
	var/datum/sex_scene_controller/proposal_controller
	/// Shared scene which indexes this runtime action.
	var/datum/sex_scene/scene
	/// Optional remote interaction context captured by the proposal.
	var/datum/sex_remote_context/remote_context
	/// The participant performing this action.
	var/mob/living/action_user
	/// The participant this action is being performed on.
	var/mob/living/action_target
	/// Virginity is cleared by some climax handlers before downstream harvest effects run.
	var/action_user_was_virgin = FALSE
	var/action_target_was_virgin = FALSE
	/// Runtime speed for this individual action.
	var/speed = SEX_SPEED_MID
	/// Runtime force for this individual action.
	var/force = SEX_FORCE_MID
	/// Whether this runtime action stops when its user climaxes.
	var/stop_on_climax = TRUE
	/// Action-owned control settings copied from the accepted proposal.
	var/resistance_to_pleasure = RESIST_NONE
	var/edging_other = FALSE
	/// Whether this action has just caused its stopping climax.
	var/just_climaxed = FALSE
	/// Scene-level interaction family exposed to multi-action pattern matching.
	var/scene_interaction
	/// Scene role and occupied body slot for the action user.
	var/scene_user_role
	var/scene_user_slot
	/// Scene role and occupied body slot for the action target.
	var/scene_target_role
	var/scene_target_slot

	/// Whether this action can continue indefinitely
	var/continous = TRUE
	/// How long each iteration takes
	var/do_time = 3.3 SECONDS
	/// Stamina cost per iteration
	var/stamina_cost = 0.1
	/// Whether to check if user is incapacitated
	var/check_incapacitated = TRUE
	/// Whether participants must be on same tile
	var/check_same_tile = FALSE
	/// Whether the action can be performed at distance
	var/check_distance = TRUE
	/// Whether this requires a grab
	var/require_grab = FALSE
	/// Minimum grab state required
	var/required_grab_state = GRAB_PASSIVE
	/// Whether aggressive grab bypasses same tile requirement
	var/aggro_grab_instead_same_tile = FALSE
	/// Whether this action requires hole storage integration
	var/requires_hole_storage = FALSE
	/// Whether this action needs the initiator's hands to be free
	var/requires_free_hands = FALSE
	/// What hole ID this action uses (if any)
	var/hole_id = null
	/// What item type this action stores in the hole
	var/atom/stored_item_type = null
	/// Custom item name for the stored object
	var/stored_item_name = null
	/// Storage tracking for this action
	var/list/datum/storage_tracking_entry/tracked_storage = list()
	/// Scene-local body/item claims owned by this action.
	var/list/datum/sex_scene_resource_claim/resource_claims = list()
	/// Whether this action supports knotting on climax
	var/knot_on_finish = FALSE
	/// Whether this action can trigger knots
	var/can_knot = FALSE
	///basically for actions being done by the user where the target is the inserter set this to true // for example: riding, blowing, titjobbing etc
	var/flipped = FALSE
	/// Used for determining if the user should be gagged
	var/gags_user = FALSE
	/// Used for determining if the target should be gagged
	var/gags_target = FALSE
	/// Sound volume for actions
	var/action_volume = 50
	/// So that we don't spam messages with every thrust for example
	var/next_message_time = 0
	/// Whether this running action should stop on its next loop check
	var/stop_requested = FALSE
	/// Whether the current cycle produced nothing and should be skipped without ending the action
	var/cycle_interrupted = FALSE
	/// World time before which this action refuses another clench
	var/next_clench_time = 0
	/// World time before which this action will not re-send its clench prompt
	var/next_clench_prompt_time = 0
	/// Which hand this action reserved, if any
	var/selected_hand = null
	/// Which zone the local user is using for interaction-menu filtering
	var/user_menu_zone_mask = SEX_UI_ZONE_ANY
	/// Which zone on the other side this action focuses on for interaction-menu filtering
	var/target_menu_zone_mask = SEX_UI_ZONE_ANY
	/// Whether Mage Hand can perform this action remotely.
	var/mage_hand_allowed = FALSE
	/// Overlay zone used by Mage Hand while this action is active.
	var/mage_hand_overlay_zone = null
	var/remote_phrase
	var/sex_volume = 50 //volume for plaps
	/// User organ slots this action works on beyond its hole and stored penis; a covered organ disables it.
	var/list/uses_user_organs
	/// Target organ slots this action works on; see uses_user_organs.
	var/list/uses_target_organs
	/// Panel refusal text set when worn armor failed a reach check, or null.
	var/tmp/armor_refusal

/datum/sex_action/Destroy()
	if(action_user)
		UnregisterSignal(action_user, COMSIG_SEX_CLIMAX)
	// A scene torn down without on_finish must still free the hand on the cock.
	unlink_penis_grip()
	end_orifice_penetration()
	if(scene && !QDELETED(scene))
		scene.forget_action(src)
	proposal_controller = null
	scene = null
	remote_context = null
	action_user = null
	action_target = null

	// Clean up any tracked storage entries
	for(var/datum/storage_tracking_entry/entry in tracked_storage)
		qdel(entry)
	tracked_storage.Cut()

	for(var/datum/sex_scene_resource_claim/claim as anything in resource_claims)
		qdel(claim)
	resource_claims.Cut()

	return ..()

/datum/sex_action/proc/shows_on_menu(mob/living/user, mob/living/target)
	return TRUE

/datum/sex_action/proc/get_menu_action_key()
	return "[type]"

/datum/sex_action/proc/build_runtime_instance()
	return new type

/datum/sex_action/proc/get_scene_interaction()
	return scene_interaction

/datum/sex_action/proc/get_scene_user_role()
	return scene_user_role

/datum/sex_action/proc/get_scene_user_slot()
	return scene_user_slot

/datum/sex_action/proc/get_scene_target_role()
	return scene_target_role

/datum/sex_action/proc/get_scene_target_slot()
	return scene_target_slot

/datum/sex_action/proc/build_scene_roles()
	return build_scene_roles_for(action_user, action_target)

/datum/sex_action/proc/build_scene_roles_for(mob/living/user, mob/living/target)
	var/list/roles = list()
	var/interaction = get_scene_interaction()
	if(!interaction || !user || !target)
		return roles

	var/user_role = get_scene_user_role()
	if(user_role)
		roles += new /datum/sex_scene_role(src, user, target, interaction, user_role, get_scene_user_slot())

	var/target_role = get_scene_target_role()
	if(target_role)
		roles += new /datum/sex_scene_role(src, target, user, interaction, target_role, get_scene_target_slot())
	return roles

/datum/sex_action/proc/refresh_scene_roles()
	return scene?.refresh_action_roles(src)

/datum/sex_action/proc/prepare_proposal(datum/sex_scene_controller/controller)
	if(!controller || QDELETED(controller) || !controller.scene || QDELETED(controller.scene))
		return FALSE
	if(proposal_controller || scene || action_user || action_target)
		return FALSE

	proposal_controller = controller
	action_user = controller.user
	action_target = controller.target
	if(ishuman(action_user))
		var/mob/living/carbon/human/human_user = action_user
		action_user_was_virgin = HAS_TRAIT(human_user, TRAIT_VIRGIN)
	if(ishuman(action_target))
		var/mob/living/carbon/human/human_target = action_target
		action_target_was_virgin = HAS_TRAIT(human_target, TRAIT_VIRGIN)
	speed = controller.speed
	force = controller.force
	stop_on_climax = controller.do_until_finished
	resistance_to_pleasure = controller.resistance_to_pleasure
	edging_other = controller.edging_other
	remote_context = controller.scene.get_remote_context(action_user, action_target, src)
	return TRUE

/datum/sex_action/proc/was_participant_virgin_at_start(mob/living/participant)
	if(participant == action_user)
		return action_user_was_virgin
	if(participant == action_target)
		return action_target_was_virgin
	return FALSE

/datum/sex_action/proc/bind_runtime(datum/sex_scene_controller/controller)
	if(!controller || QDELETED(controller) || !controller.scene || QDELETED(controller.scene))
		return FALSE
	if(scene)
		return FALSE
	if(proposal_controller)
		if(proposal_controller != controller || action_user != controller.user || action_target != controller.target)
			return FALSE
	else if(!prepare_proposal(controller))
		return FALSE

	proposal_controller = null
	scene = controller.scene

	if(!scene.add_action(src))
		scene = null
		remote_context = null
		action_user = null
		action_target = null
		return FALSE

	RegisterSignal(action_user, COMSIG_SEX_CLIMAX, PROC_REF(on_action_user_climax))
	return TRUE

/datum/sex_action/proc/unbind_runtime()
	var/datum/sex_scene/action_scene = scene

	if(action_user)
		UnregisterSignal(action_user, COMSIG_SEX_CLIMAX)
	if(action_scene && !QDELETED(action_scene))
		action_scene.remove_action(src)

	proposal_controller = null
	scene = null
	remote_context = null
	action_user = null
	action_target = null

/datum/sex_action/proc/is_runtime_active()
	if(!scene || QDELETED(scene))
		return FALSE
	if(!action_user || QDELETED(action_user) || !action_target || QDELETED(action_target))
		return FALSE
	return src in scene.active_actions

/datum/sex_action/proc/start_runtime()
	if(!is_runtime_active())
		return
	INVOKE_ASYNC(src, PROC_REF(run_runtime))

/// Scene merges and splits move the action while it sleeps, so every stop goes through the current scene.
/datum/sex_action/proc/run_runtime()
	if(!is_runtime_active() || !can_run(TRUE))
		stop_runtime()
		return

	var/start_result = run_act_hook(PROC_REF(on_start), action_user, action_target)
	if(start_result == FALSE || !is_runtime_active())
		stop_runtime()
		return

	var/datum/sex_remote_context/action_remote_context = get_valid_remote_context()
	if(action_remote_context)
		action_remote_context.show_action_overlay(src)
		action_remote_context.show_action_message(src, MAGE_HAND_ACTION_MESSAGE_START)

	send_clench_prompt(force = TRUE)

	while(is_runtime_active())
		// Positive tires: stamina counts fatigue accumulated, so a cost adds to it.
		var/stamina_cost = src.stamina_cost * get_stamina_cost_multiplier() * SEX_STAMINA_MODIFIER
		if(!action_user.adjust_stamina(stamina_cost))
			break

		if(should_auto_clench())
			try_clench(action_target)
			if(stop_requested)
				break

		var/current_do_time = do_time / get_speed_multiplier()
		var/do_after_flags = IGNORE_USER_DIR_CHANGE | IGNORE_HELD_ITEM | IGNORE_SLOWDOWNS | IGNORE_USER_DOING | IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE
		var/interaction_key = "sex_action_[REF(src)]"
		// Mirrors can_run(): actions that opted out of proximity reach their target some other way.
		if(check_distance && !action_user.in_sex_interaction_range(action_target) && !can_remote_interact())
			stop_runtime()
			return
		if(!do_after(action_user, current_do_time, target = action_target, timed_action_flags = do_after_flags, interaction_key = interaction_key))
			if(!cycle_interrupted)
				break
			cycle_interrupted = FALSE
			continue

		if(!is_runtime_active())
			break
		if(!can_run(TRUE))
			break
		if(is_finished(action_user, action_target) || stop_requested)
			break

		if(cycle_interrupted)
			cycle_interrupted = FALSE
			continue

		// Pressing against a hole that will not take it yet replaces the thrust.
		if(orifice_pressing && run_orifice_press_cycle(action_user, action_target))
			send_clench_prompt()
			continue

		send_action_tick(action_user, action_target)
		run_act_hook(PROC_REF(on_perform), action_user, action_target)
		leave_perform_lipstick_marks()
		on_orifice_cycle()
		play_perform_breast_anim()
		play_perform_motion()
		play_furniture_noise()
		send_clench_prompt()
		if(!is_runtime_active())
			break

		action_remote_context = get_valid_remote_context()
		if(action_remote_context)
			action_remote_context.show_action_message(src, MAGE_HAND_ACTION_MESSAGE_PERFORM)
		if(istype(action_user.loc, /obj/structure/closet))
			var/obj/structure/closet/sex_shack = action_user.loc
			sex_shack.Shake(1, 3, 15)

		// Remote work stays anonymous - hearts over the caster would point straight back at them.
		if(action_user.has_kink(KINK_VISUAL_EFFECTS) && (!action_remote_context || action_remote_context.allows_visible_messages))
			show_sex_effects(action_user)

		if(is_finished(action_user, action_target) || !continous)
			break

	stop_runtime()

/datum/sex_action/proc/can_run(performing = FALSE)
	if(!action_user || !action_target || QDELETED(action_user) || QDELETED(action_target))
		return FALSE
	if(action_user != action_target)
		if(!action_user.allows_player_erp_while_disconnected())
			return FALSE
		if(!action_target.allows_player_erp_while_disconnected())
			return FALSE
	if(action_user.stat != CONSCIOUS || action_target.stat == DEAD)
		return FALSE

	var/remote_interaction = can_remote_interact()
	if(!remote_interaction && !action_user.adjacent_or_closet(action_target) && check_distance)
		return FALSE
	if(check_incapacitated)
		var/incapacitated_flags = IGNORE_GRAB
		if(!requires_free_hands)
			incapacitated_flags |= IGNORE_RESTRAINTS
		if(action_user.incapacitated(incapacitated_flags))
			return FALSE
	if(requires_free_hands && !action_user.has_free_sex_hands())
		return FALSE
	if(!remote_interaction && check_same_tile && !action_user.check_closet(action_target))
		var/same_tile = (get_turf(action_user) == get_turf(action_target))
		var/grab_bypass = (aggro_grab_instead_same_tile && action_user.get_effective_grab_state_on(action_target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE
	if(!remote_interaction && require_grab)
		var/grabstate = action_user.get_effective_grab_state_on(action_target)
		if(grabstate == null || grabstate < required_grab_state)
			return FALSE
	if(performing)
		if(!can_continue(action_user, action_target))
			return FALSE
	else if(!can_perform(action_user, action_target))
		return FALSE
	return TRUE

/// Mutes the pair under a secret remote context; returns the muted mobs for the end call.
/datum/sex_action/proc/begin_remote_visible_message_suppression()
	var/datum/sex_remote_context/suppressing_context = get_valid_remote_context()
	if(!suppressing_context || suppressing_context.allows_visible_messages)
		return null
	var/list/muted = list()
	if(action_user)
		muted += action_user
	if(action_target && action_target != action_user)
		muted += action_target
	for(var/mob/living/muted_mob as anything in muted)
		muted_mob.push_visible_message_suppression()
	return muted

/// Unmutes the mobs the begin call muted, even if the act lost its pair meanwhile.
/datum/sex_action/proc/end_remote_visible_message_suppression(list/muted)
	for(var/mob/living/muted_mob as anything in muted)
		muted_mob.pop_visible_message_suppression()

/// Runs an act hook inside its message scopes; a runtime in the hook still closes them.
/datum/sex_action/proc/run_act_hook(hook, mob/living/user, mob/living/target)
	var/list/muted = begin_remote_visible_message_suppression()
	begin_felt_lines(user, target)
	try
		. = call(src, hook)(user, target)
	catch(var/exception/hook_error)
		end_felt_lines(user, target)
		end_remote_visible_message_suppression(muted)
		throw hook_error
	end_felt_lines(user, target)
	end_remote_visible_message_suppression(muted)

/// Both bodies in the act get its lines while blind or asleep; pair with end_felt_lines().
/datum/sex_action/proc/begin_felt_lines(mob/living/user, mob/living/target)
	user?.push_feels_own_body()
	if(target && target != user)
		target.push_feels_own_body()

/datum/sex_action/proc/end_felt_lines(mob/living/user, mob/living/target)
	user?.pop_feels_own_body()
	if(target && target != user)
		target.pop_feels_own_body()

/// on_perform() inside its message scopes, for callers outside the act runtime.
/datum/sex_action/proc/felt_perform(mob/living/user, mob/living/target)
	send_action_tick(user, target)
	run_act_hook(PROC_REF(on_perform), user, target)

/// Tells both bodies a beat is about to be performed; handlers must not sleep.
/datum/sex_action/proc/send_action_tick(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	SEND_SIGNAL(user, COMSIG_SEX_ACTION_TICK, src, user, target)
	if(target != user)
		SEND_SIGNAL(target, COMSIG_SEX_ACTION_TICK, src, user, target)

/// Never returns null - the result divides do_time, so an unlisted speed would be a division by zero.
/datum/sex_action/proc/get_speed_multiplier()
	switch(speed)
		if(SEX_SPEED_LOW)
			return 1
		if(SEX_SPEED_MID)
			return 1.5
		if(SEX_SPEED_HIGH)
			return 2.25
		if(SEX_SPEED_EXTREME)
			return 3
		if(SEX_SPEED_UNRELENTING)
			return 3.75
	return 1.5

/datum/sex_action/proc/get_stamina_cost_multiplier()
	switch(force)
		if(SEX_FORCE_LOW)
			return 1.0
		if(SEX_FORCE_MID)
			return 1.5
		if(SEX_FORCE_HIGH)
			return 2.0
		if(SEX_FORCE_EXTREME)
			return 2.5
		if(SEX_FORCE_UNRELENTING)
			return 3.0
	return 1.5

/**
 * Applies one tick of stimulation using an explicit runtime action context.
 *
 * Every mechanical input comes from the accepted runtime action.
 */
/proc/apply_sex_action_stimulation(
	datum/sex_action/action,
	mob/living/action_user,
	mob/living/pleasure_receiver,
	mob/living/partner,
	arousal_amt,
	pain_amt,
	orgasm_prog_amt,
	action_force,
	action_speed,
)
	if(!action || QDELETED(action) || !action.scene || QDELETED(action.scene) || !action_user || !pleasure_receiver || !partner)
		return FALSE

	var/list/arousal_data_partner = list()
	SEND_SIGNAL(partner, COMSIG_SEX_GET_AROUSAL, arousal_data_partner)

	if(HAS_TRAIT(action_user, TRAIT_GOODLOVER) && action_user != pleasure_receiver)
		arousal_amt *= 1.5
		orgasm_prog_amt *= 1.5
		if(prob(10))
			var/lover_message = pick("This feels so good!","I am in nirvana!","This is too good to be possible!","By the Gods!","I can't stop, too good!~")
			to_chat(partner, span_love(lover_message))

	if(partner != action_user && action.edging_other)
		if(arousal_data_partner["arousal"] >= AROUSAL_EDGING_THRESHOLD + 15)
			var/success_chance = 100
			if(prob(5))
				to_chat(action_user, span_love("I try to match my movements so that they don't climax too soon..."))
			if(action_speed > SEX_SPEED_MID || action_force > SEX_FORCE_MID)
				success_chance *= 0.5
			if(partner.has_status_effect(/datum/status_effect/edging_overstimulation))
				success_chance *= 0.3
				if(prob(10))
					to_chat(action_user, span_love("They are just too sensitive for me to control their pleasure..."))
			if(action_user.get_stat_level(STATKEY_PER) < 7)
				success_chance *= 0.7
				if(prob(10))
					to_chat(action_user, span_love("I can't tell if they are close or not..."))
			if(prob(success_chance))
				SEND_SIGNAL(partner, COMSIG_SEX_EDGED_BY_OTHER_STATE, TRUE)

	var/giving = (action_user == pleasure_receiver)
	var/list/arousal_data_receiver = list()
	SEND_SIGNAL(pleasure_receiver, COMSIG_SEX_GET_AROUSAL, arousal_data_receiver)
	var/resistance = arousal_data_receiver["resistance_to_pleasure"]

	var/datum/sex_action_effect_context/effect_context = new(
		pleasure_receiver,
		partner,
		action,
		pleasure_receiver,
		partner,
		giving,
	)
	effect_context.action_performer = action_user
	effect_context.arousal_amt = arousal_amt
	effect_context.pain_amt = pain_amt
	effect_context.orgasm_prog_amt = orgasm_prog_amt
	effect_context.force = action_force
	effect_context.speed = action_speed
	effect_context.resistance = resistance
	var/list/effects = collect_sex_action_effects(effect_context)
	for(var/datum/sex_action_effect/effect as anything in effects)
		effect.modify_action(effect_context)
	action.scene.modify_action_effect(effect_context)

	SEND_SIGNAL(pleasure_receiver, COMSIG_SEX_RECEIVE_ACTION, action, pleasure_receiver, partner, effect_context.arousal_amt, effect_context.pain_amt, effect_context.orgasm_prog_amt, giving, action_force, action_speed, resistance, action_user)

	for(var/datum/sex_action_effect/effect as anything in effects)
		effect.after_action(effect_context)
	qdel_sex_action_effects(effects)
	return TRUE

/datum/sex_action/proc/perform_sex_action(mob/living/pleasure_receiver, mob/living/partner, arousal_amt, pain_amt, orgasm_prog_amt)
	var/through_clothes = get_through_clothes_multiplier(pleasure_receiver)
	arousal_amt *= through_clothes
	orgasm_prog_amt *= through_clothes
	strain_legwear(pleasure_receiver)
	return apply_sex_action_stimulation(
		src,
		action_user,
		pleasure_receiver,
		partner,
		arousal_amt,
		pain_amt,
		orgasm_prog_amt,
		force,
		speed,
	)

/// Brutal handling can snag the receiver's bare stockings.
/datum/sex_action/proc/strain_legwear(mob/living/receiver)
	if(!ishuman(receiver) || !prob(get_legwear_snag_chance()))
		return
	var/mob/living/carbon/human/human_receiver = receiver
	human_receiver.get_exposed_legwear()?.snag(get_legwear_snag_damage(), SLASH)

/// Per-cycle percent chance that this force snags bare stockings.
/datum/sex_action/proc/get_legwear_snag_chance()
	if(force >= SEX_FORCE_UNRELENTING)
		return SEX_LEGWEAR_SNAG_CHANCE_UNRELENTING
	if(force >= SEX_FORCE_EXTREME)
		return SEX_LEGWEAR_SNAG_CHANCE
	return 0

/datum/sex_action/proc/get_legwear_snag_damage()
	return force >= SEX_FORCE_UNRELENTING ? SEX_LEGWEAR_SNAG_DAMAGE_UNRELENTING : SEX_LEGWEAR_SNAG_DAMAGE

/datum/sex_action/proc/stop_runtime()
	scene?.stop_action(src)

/datum/sex_action/proc/on_action_user_climax(mob/source, datum/sex_action/climax_action)
	SIGNAL_HANDLER
	if(climax_action != src || !stop_on_climax)
		return
	// The action lasts through the climax's spurts, so stopping it meanwhile pulls out.
	var/datum/component/arousal/arousal = source.GetComponent(/datum/component/arousal)
	if(arousal?.active_spurts?.is_running_for(src))
		stop_after_spurts = TRUE
		return
	just_climaxed = TRUE
	stop_requested = TRUE

/datum/sex_action/proc/handle_passive_ejaculation(mob/living/handler)
	if(!handler)
		handler = action_user
	if(!handler || !action_user)
		return

	var/list/arousal_data = list()
	SEND_SIGNAL(handler, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal_multiplier = arousal_data["arousal_multiplier"]
	var/arousal_value = arousal_data["arousal"]

	if(arousal_multiplier <= 1.5 || !action_user.check_handholding())
		return
	var/mob/living/partner = handler == action_user ? action_target : action_user
	if(prob(5))
		SEND_SIGNAL(handler, COMSIG_SEX_RECEIVE_ACTION, src, handler, partner, 3, 0, 1, FALSE, force, speed, RESIST_NONE, action_user)
	if(arousal_value < 70)
		SEND_SIGNAL(handler, COMSIG_SEX_ADJUST_AROUSAL, 0.2)

	if(!iscarbon(handler))
		return
	var/mob/living/carbon/carbon_handler = handler
	if(!carbon_handler.handcuffed)
		return
	if(prob(8))
		var/chafe_pain = pick(10, 10, 10, 10, 20, 20, 30)
		SEND_SIGNAL(handler, COMSIG_SEX_RECEIVE_ACTION, src, handler, partner, 3, chafe_pain, 1, FALSE, force, speed, RESIST_NONE, action_user)
		handler.visible_message(
			"<span class='love_mid'>[handler] squirms uncomfortably in [handler.p_their()] restraints.</span>",
			"<span class='love_extreme'>I feel [carbon_handler.handcuffed] rub uncomfortably against my skin.</span>",
		)
	if(arousal_value < ACTIVE_EJAC_THRESHOLD)
		SEND_SIGNAL(handler, COMSIG_SEX_ADJUST_AROUSAL, 0.25)

/datum/sex_action/proc/perform_deepthroat_oxyloss(mob/living/affected_target, oxyloss_amt)
	var/oxyloss_multiplier = 0
	switch(force)
		if(SEX_FORCE_HIGH)
			oxyloss_multiplier = 0.5
		if(SEX_FORCE_EXTREME)
			oxyloss_multiplier = 1.0
		if(SEX_FORCE_UNRELENTING)
			oxyloss_multiplier = 1.5
	oxyloss_amt *= oxyloss_multiplier
	if(oxyloss_amt <= 0 || affected_target.getOxyLoss() > 30)
		return
	affected_target.adjustOxyLoss(oxyloss_amt)
	// The wet choke comes as the air runs short; the emote still fires on top at the old odds.
	if(affected_target.oxyloss >= 15 && prob(35))
		affected_target.make_mouth_noise("choke", 40)
	if(affected_target.oxyloss >= 25 && prob(33))
		affected_target.emote(pick(list("gag", "choke", "gasp")), forced = TRUE)

/datum/sex_action/proc/considered_limp(mob/living/limper)
	if(QDELETED(limper))
		return TRUE
	// A strapon toy is always hard.
	var/obj/item/organ/genitals/penis/penis = limper.getorganslot(ORGAN_SLOT_PENIS)
	if(penis?.is_false_organ())
		return FALSE
	var/list/arousal_data = list()
	SEND_SIGNAL(limper, COMSIG_SEX_GET_AROUSAL, arousal_data)
	return arousal_data["arousal"] < VISIBLE_AROUSAL_THRESHOLD

/datum/sex_action/proc/get_generic_force_adjective()
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(list("gently", "carefully", "tenderly", "gingerly", "delicately", "lazily"))
		if(SEX_FORCE_MID)
			return pick(list("firmly", "vigorously", "eagerly", "steadily", "intently"))
		if(SEX_FORCE_HIGH)
			return pick(list("roughly", "carelessly", "forcefully", "fervently", "fiercely"))
		if(SEX_FORCE_EXTREME)
			return pick(list("brutally", "violently", "relentlessly", "savagely", "mercilessly"))
		if(SEX_FORCE_UNRELENTING)
			return pick(list("unrelentingly", "ferociously", "furiously", "without pause", "without mercy"))

/datum/sex_action/proc/spanify_force(string)
	string = add_through_clothes_suffix(string)
	switch(force)
		if(SEX_FORCE_LOW)
			return "<span class='love_low'>[string]</span>"
		if(SEX_FORCE_MID)
			return "<span class='love_mid'>[string]</span>"
		if(SEX_FORCE_HIGH)
			return "<span class='love_high'>[string]</span>"
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			return "<span class='love_extreme'>[string]</span>"

/datum/sex_action/proc/get_force_sound()
	switch(force)
		if(SEX_FORCE_LOW, SEX_FORCE_MID)
			return pick(SEX_SOUNDS_SLOW)
		if(SEX_FORCE_HIGH, SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			return pick(SEX_SOUNDS_HARD)

/// TRUE when this action may be used on yourself even though it normally needs a partner.
/datum/sex_action/proc/allows_self_use(mob/living/user)
	return FALSE

/datum/sex_action/proc/can_perform(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	if(requires_hole_storage)
		if(!check_hole_storage_available(user, target))
			return FALSE
	if(get_blocked_organ_slot(user, target))
		return FALSE
	return TRUE

/**
 * Re-checked on every loop of an already running action, for the resources the action keeps
 * borrowing rather than the ones it only needed to start.
 *
 * can_perform() cannot be reused here: it is a start-time precondition, and its hole storage check
 * would fail against the action's own stored item the moment the action gets going.
 */
/datum/sex_action/proc/can_continue(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	// A device fitted mid-action, such as a pump, ends it.
	return !get_blocked_organ_slot(user, target)

/// The first organ slot this action needs that a worn device covers, or null when all are free.
/datum/sex_action/proc/get_blocked_organ_slot(mob/living/user, mob/living/target)
	var/mob/living/receiver = get_storage_receiver(user, target)
	if(hole_id && receiver?.is_organ_slot_blocked(hole_id))
		return hole_id
	if(ispath(stored_item_type, /obj/item/organ/genitals/penis))
		var/mob/living/insertor = get_storage_insertor(user, target)
		if(insertor?.is_organ_slot_blocked(ORGAN_SLOT_PENIS))
			return ORGAN_SLOT_PENIS
	for(var/slot in uses_user_organs)
		if(user?.is_organ_slot_blocked(slot))
			return slot
	for(var/slot in uses_target_organs)
		if(target?.is_organ_slot_blocked(slot))
			return slot
	return null

/// The holder's organ in the slot if it exists and no worn device covers it.
/datum/sex_action/proc/get_free_organ(mob/living/holder, slot)
	var/obj/item/organ/organ = holder?.getorganslot(slot)
	if(!organ || holder.is_organ_slot_blocked(slot))
		return null
	return organ

/datum/sex_action/proc/can_mage_hand_reach(mob/living/user, mob/living/target)
	return user == action_user && target == action_target && can_remote_interact()

/datum/sex_action/proc/get_valid_remote_context()
	if(!remote_context || QDELETED(remote_context))
		remote_context = null
		return null
	if(!scene && !proposal_controller?.scene)
		return null
	var/datum/sex_scene/context_scene = scene || proposal_controller.scene
	if(!remote_context.is_valid(context_scene))
		return null
	if(!remote_context.allows_action(src))
		return null
	return remote_context

/datum/sex_action/proc/can_remote_interact()
	return !!get_valid_remote_context()

/datum/sex_action/proc/try_knot_on_climax(mob/living/user, mob/living/target)
	// Nothing is inside while still pressing at the opening.
	if(orifice_pressing)
		return FALSE
	if(!knot_on_finish)
		return FALSE
	if(!can_knot)
		return FALSE
	if(!scene)
		return FALSE
	return SEND_SIGNAL(user, COMSIG_SEX_TRY_KNOT, target, force, src)

/// Keeps the panel refusal line for armor on [target] that stopped [actor].
/datum/sex_action/proc/note_armor_refusal(mob/living/target, mob/living/actor)
	armor_refusal = target == actor ? "My armor is in the way." : "[target]'s armor is in the way."

/datum/sex_action/proc/check_location_accessible(mob/living/user, mob/living/target, location = BODY_ZONE_CHEST, grabs = TRUE, skipundies = TRUE)
	var/obj/item/bodypart/bodypart = target.get_bodypart(location)
	var/self_target = FALSE
	if(target == user)
		self_target = TRUE

	var/mage_hand_reach = can_mage_hand_reach(user, target)
	if(!mage_hand_reach && src.check_same_tile && (user != target || self_target))
		var/same_tile = (get_turf(user) == get_turf(target))
		var/grab_bypass = (src.aggro_grab_instead_same_tile && user.get_effective_grab_state_on(target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE

	if(!mage_hand_reach && src.require_grab && (user != target || self_target))
		var/grabstate = user.get_effective_grab_state_on(target)
		if((grabstate == null || grabstate < src.required_grab_state))
			return FALSE

	// The holes window asks the same question, so the garment rule lives on the mob.
	var/mob/living/actor = action_user || user
	if(target.get_sex_covering_garment(location, actor))
		note_armor_refusal(target, actor)
		return FALSE

	if(location == BODY_ZONE_PRECISE_MOUTH)
		if(target.mouth_is_free(actor))
			return TRUE
		if(target.mouth_is_free(actor, ignore_armor = TRUE))
			note_armor_refusal(target, actor)
		return FALSE

	if(!bodypart)
		if(iscarbon(target))
			return FALSE
		if(location == BODY_ZONE_PRECISE_L_FOOT || location == BODY_ZONE_PRECISE_R_FOOT)
			return target.foot_is_free()
		return TRUE

	return TRUE
	/*if(self_target)
		grabs = FALSE

	var/result = get_location_accessible(target, location = location, grabs = grabs, skipundies = skipundies)
	return result*/

/datum/sex_action/proc/get_storage_receiver(mob/living/user, mob/living/target)
	return flipped ? user : target

/datum/sex_action/proc/get_storage_insertor(mob/living/user, mob/living/target)
	return flipped ? target : user

/datum/sex_action/proc/get_storage_check_item(mob/living/user, mob/living/target)
	if(stored_item_type == /obj/item/organ/genitals/penis)
		var/mob/living/storage_insertor = get_storage_insertor(user, target)
		return get_users_penis(storage_insertor)
	return null

/datum/sex_action/proc/get_hole_storage_force(mob/living/user, mob/living/target)
	return force >= SEX_FORCE_HIGH

/datum/sex_action/proc/can_fit_item_in_hole(mob/living/storage_owner, hole_slot, obj/item/item_to_check, force = FALSE)
	if(!storage_owner || !hole_slot || !item_to_check)
		return FALSE

	var/obj/item/organ/target_organ = storage_owner.getorganslot(hole_slot)
	if(!target_organ)
		return FALSE

	var/datum/component/body_storage/storage_comp = target_organ.GetComponent(/datum/component/body_storage)
	if(!storage_comp)
		return FALSE

	// Too wide is no refusal for a penetration: the act starts by pressing against the opening.
	if(is_orifice_penetration())
		var/width_feedback = target_organ.get_body_storage_width_feedback(item_to_check, STORAGE_LAYER_INNER, force)
		if(width_feedback != INSERT_FEEDBACK_OK && width_feedback != INSERT_FEEDBACK_OK_FORCE)
			return TRUE

	var/fit_result = storage_comp.check_fit(target_organ, item_to_check, STORAGE_LAYER_INNER, force)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return TRUE
	return FALSE

/datum/sex_action/proc/check_hole_storage_available(mob/living/user, mob/living/target)
	if(!hole_id || !stored_item_type)
		return TRUE // No storage requirements

	var/mob/living/storage_owner = get_storage_receiver(user, target)
	var/obj/item/item_to_check = get_storage_check_item(user, target)
	if(!item_to_check)
		return FALSE

	return can_fit_item_in_hole(storage_owner, hole_id, item_to_check, get_hole_storage_force(user, target))

/datum/sex_action/proc/get_users_penis(mob/living/user)
	if(!user)
		return null
	return user.getorganslot(ORGAN_SLOT_PENIS)

/datum/sex_action/proc/try_store_in_hole(mob/living/user, mob/living/target)
	if(!requires_hole_storage || !hole_id || !stored_item_type)
		return TRUE

	var/obj/item/organ/target_o = target.getorganslot(hole_id)
	if(!target_o)
		to_chat(user, span_warning("[target == user ? "My" : "[target]'s"] [hole_id] can't take items right now."))
		return FALSE

	var/datum/component/body_storage/storage_comp = target_o.GetComponent(/datum/component/body_storage)
	if(!storage_comp)
		to_chat(user, span_warning("[target == user ? "My" : "[target]'s"] [hole_id] can't take items right now."))
		return FALSE

	var/obj/item/item_to_store

	var/self = (user == target)
	var/use_force = (force >= SEX_FORCE_HIGH)
	// Handle penis storage specially - create fake variant
	if(stored_item_type == /obj/item/organ/genitals/penis)
		var/obj/item/organ/genitals/penis/user_penis = get_users_penis(user)
		if(!user_penis)
			to_chat(user, span_warning("You don't have a penis to use!"))
			return FALSE

		// Create fake variant instead of removing real penis
		item_to_store = user_penis.create_fake_variant(user)
	else
		// Create the item to store
		item_to_store = new stored_item_type()
		if(stored_item_name)
			item_to_store.name = stored_item_name

	item_to_store.on_penetration_standin_created(src)
	// Too wide for the opening: the act starts by pressing against it instead of failing.
	var/width_feedback = target_o.get_body_storage_width_feedback(item_to_store, STORAGE_LAYER_INNER, use_force)
	if(width_feedback != INSERT_FEEDBACK_OK && width_feedback != INSERT_FEEDBACK_OK_FORCE)
		qdel(item_to_store)
		begin_orifice_pressing(user, target, width_feedback)
		return TRUE

	// Try to fit it in the hole
	var/success = SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_TRY_INSERT, item_to_store, STORAGE_LAYER_INNER, use_force)
	switch(success)
		if(INSERT_FEEDBACK_OK_FORCE)
			if(prob(15))
				var/stuffed_res = SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, use_force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					if(self)
						to_chat(user, spanify_force("Something inside my [hole_id] slips deeper!"))
					else
						user.visible_message(spanify_force("Something inside [target]'s [hole_id] slips deeper!"))
		if(INSERT_FEEDBACK_ALMOST_FULL)
			if(self)
				to_chat(user, spanify_force("I feel like my [hole_id] can just barely fit [item_to_store.name]..."))
			else
				user.visible_message(spanify_force("I feel like [target]'s [hole_id] can just barely fit my [item_to_store.name]..."))
		if(INSERT_FEEDBACK_STUFFED)
			if(use_force && prob(50))
				var/stuffed_res = SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, use_force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					if(self)
						to_chat(user, spanify_force("Something inside my [hole_id] slips deeper!"))
					else
						user.visible_message(spanify_force("Something inside [target]'s [hole_id] slips deeper!"))
			else
				to_chat(user, span_warning("[target]'s [hole_id] can't accommodate my [item_to_store.name]!"))
				SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, item_to_store, STORAGE_LAYER_INNER)
				addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
				return FALSE

		if(INSERT_FEEDBACK_TRY_FORCE)
			if(self)
				to_chat(user, spanify_force("I feel like \the [item_to_store.name] might fit in my [hole_id] with more force, or something slick."))
			else
				user.visible_message(spanify_force("I feel like my [item_to_store.name] might fit in [target]'s [hole_id] with more force, or something slick."))
			SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, item_to_store, STORAGE_LAYER_INNER)
			addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
			return FALSE
		if(INSERT_FEEDBACK_BLOCKED)
			to_chat(user, span_warning("[target == user ? "My" : "[target]'s"] [hole_id] is blocked."))
			addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
			return FALSE
		if(FALSE)
			to_chat(user, span_warning("[target]'s [hole_id] can't accommodate [item_to_store.name]!"))
			SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, item_to_store, STORAGE_LAYER_INNER)
			addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
			return FALSE

	// Track the storage
	var/datum/storage_tracking_entry/entry = new(item_to_store, user, hole_id, user)
	tracked_storage += entry

	return TRUE

/datum/sex_action/proc/remove_from_hole(mob/living/user, mob/living/target, silent = FALSE)
	if(!requires_hole_storage || !hole_id)
		return TRUE

	var/obj/item/organ/target_o = target.getorganslot(hole_id)
	for(var/datum/storage_tracking_entry/entry in tracked_storage)
		if(entry.hole_id == hole_id && entry.stored_item)
			var/obj/item/stored_item = entry.stored_item

			if(istype(stored_item, /obj/item/penis_fake))
				var/obj/item/penis_fake/fake_penis = stored_item
				var/mob/living/original_owner = find_original_owner_by_ckey(fake_penis.original_owner_ckey)
				remove_tracked_item_from_body_storage(target_o, fake_penis)
				if(!silent)
					if(original_owner)
						to_chat(original_owner, span_notice("Your penis has been withdrawn from [target]'s [hole_id]."))
						if(original_owner != user)
							to_chat(user, span_notice("Withdrew [original_owner.name]'s penis from [target]'s [hole_id]."))
					else
						to_chat(user, span_notice("Withdrew penis from [target]'s [hole_id]."))
				qdel(stored_item)
			else
				remove_tracked_item_from_body_storage(target_o, stored_item)
				if(!silent)
					to_chat(user, span_notice("Removed [stored_item.name] from [target]'s [hole_id]."))
				qdel(stored_item)

			tracked_storage -= entry
			qdel(entry)

	return TRUE

/datum/sex_action/proc/remove_tracked_item_from_body_storage(obj/item/organ/target_organ, obj/item/stored_item)
	if(!target_organ || !stored_item)
		return FALSE

	var/current_layer = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, stored_item)
	if(!current_layer)
		return FALSE

	SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_FORCE_REMOVE, stored_item, current_layer)
	return TRUE

/datum/sex_action/proc/find_original_owner_by_ckey(target_ckey)
	if(!target_ckey)
		return null

	for(var/mob/living/H in GLOB.mob_living_list)
		if(H.ckey == target_ckey)
			return H

	return null

/datum/sex_action/proc/on_start(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	if(gags_user)
		user.mouth_blocked = TRUE
	if(gags_target)
		target.mouth_blocked = TRUE
	if(requires_hole_storage && !issimple(target)) //simple mobs dont have anything so skip.
		if(flipped)
			if(!try_store_in_hole(target, user))
				return FALSE
		else
			if(!try_store_in_hole(user, target))
				return FALSE
	lock_sex_object(user, target)
	sync_penis_grip(user, target)
	begin_orifice_penetration(user, target)
	sex_volume = initial(sex_volume)
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		sex_volume *= 0.5
	return TRUE

/datum/sex_action/proc/on_perform(mob/living/user, mob/living/target)
	sex_volume = initial(sex_volume)
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		sex_volume *= 0.5
	return

/datum/sex_action/proc/on_finish(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	if(gags_user)
		user.mouth_blocked = FALSE
	if(gags_target)
		target.mouth_blocked = FALSE
	if(requires_hole_storage)
		if(flipped)
			remove_from_hole(target, user)
		else
			remove_from_hole(user, target)
	end_orifice_penetration()
	unlink_penis_grip()
	unlock_sex_object(user, target)
	sex_volume = initial(sex_volume)
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		sex_volume *= 0.5
	return

/datum/sex_action/proc/is_finished(mob/living/user, mob/living/target)
	if(just_climaxed)
		just_climaxed = FALSE
		return TRUE
	return FALSE


/datum/sex_action/proc/lock_sex_object(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/proc/add_sex_lock(mob/living/locked_host, locked_organ_slot, obj/item/locked_item, hard_lock = TRUE)
	if(!scene || QDELETED(scene))
		return null
	var/datum/sex_scene_resource_claim/claim = new(src, locked_host, locked_organ_slot, locked_item, hard_lock)
	resource_claims |= claim
	return claim

/datum/sex_action/proc/find_available_hand(mob/living/user)
	if(!user || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return null

	var/list/hand_order = list(user.get_active_precise_hand(), user.get_inactive_precise_hand())
	for(var/hand_slot in hand_order)
		if(!hand_slot)
			continue
		if(!user.get_bodypart(hand_slot))
			continue
		if(check_sex_lock(user, hand_slot))
			continue
		return hand_slot
	return null

/datum/sex_action/proc/get_hand_lock_slot(mob/living/user)
	if(selected_hand)
		return selected_hand
	selected_hand = find_available_hand(user)
	return selected_hand

/datum/sex_action/proc/unlock_sex_object(mob/living/user, mob/living/target)
	for(var/datum/sex_scene_resource_claim/claim as anything in resource_claims)
		qdel(claim)
	resource_claims.Cut()

/**
 * Announces a climax and returns where the fluid goes, or null to fall back to the generic handling.
 *
 * Note the argument names do not mean what they mean everywhere else in this file: `user` is
 * whoever just climaxed and `target` is the other participant, regardless of who started the
 * action. Word the message with `user` as its subject. `must_flip` is set when the climaxing
 * participant is not the one performing the action, so it selects the partner's phrasing.
 */
/datum/sex_action/proc/handle_climax_message(mob/living/user, mob/living/target, must_flip = FALSE)
	return

/// Returns the reagent container an ORGASM_LOCATION_CONTAINER climax should be routed into, or null. Overridden by collect-fluid actions.
/datum/sex_action/proc/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	return null

/datum/sex_action/proc/check_sex_lock(mob/locked, organ_slot, obj/item/item, obj/item/storage_item)
	if(!organ_slot && !item)
		return FALSE
	var/mob/living/locked_living = locked
	var/datum/sex_scene/resource_scene = scene || proposal_controller?.scene
	return resource_scene?.is_resource_claimed(src, locked_living, organ_slot, item, storage_item) || FALSE


/datum/sex_action/proc/do_onomatopoeia(mob/living/user)
	user.balloon_alert_to_viewers("Plap!")

/datum/sex_action/proc/show_sex_effects(mob/living/user)
	for(var/i in 1 to rand(1, 3))
		if(!user.cmode) // Combat mode
			new /obj/effect/temp_visual/heart/sex_effects(get_turf(user))
		else
			new /obj/effect/temp_visual/heart/sex_effects/red_heart(get_turf(user))


/datum/sex_action/proc/can_show_action_message(mob/living/user, mob/living/target)
	// Secret contexts (the mage hand) stay silent; open ones (a held head) keep talking.
	var/datum/sex_remote_context/message_context = get_valid_remote_context()
	if(message_context && !message_context.allows_visible_messages)
		return FALSE
	if(user && (user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)) //stealth sex les go
		return FALSE
	if(world.time >= next_message_time)
		var/speed_time = rand(10, 100 - speed * 10)
		next_message_time = world.time + speed_time
		return TRUE
	return FALSE

/datum/sex_action/proc/matches_ui_filters(user_filter, target_filter)
	if(user_filter != SEX_UI_ZONE_ANY && !(user_menu_zone_mask & user_filter))
		return FALSE
	if(target_filter != SEX_UI_ZONE_ANY && !(target_menu_zone_mask & target_filter))
		return FALSE
	return TRUE

#undef SEX_STAMINA_MODIFIER
