#define KNOT_ESCAPE_TIME 5 SECONDS
#define KNOT_ESCAPE_INTERACTION_KEY "knot_escape"
#define KNOT_RELEASE_SPILL_AMOUNT 10

/datum/component/knotting
	/// Active knots indexed by their recipient. A recipient can only be tied to one knotter at a time.
	var/static/list/active_knots_by_recipient = list()
	/// Whether we're currently tugging a knot
	var/tugging_knot = FALSE
	/// Check counter for tugging validation
	var/tugging_knot_check = 0
	/// Whether knot area is blocked by clothing
	var/tugging_knot_blocked = FALSE
	/// Who owns the knot (the one with the penis)
	var/mob/living/knotted_owner = null
	/// Who received the knot (the one being knotted)
	var/mob/living/knotted_recipient = null
	/// Runtime action which created this knot, if it is still active.
	var/datum/weakref/knotted_action_ref
	/// The filling organ currently plugged by this knot, if any.
	var/datum/weakref/knotted_hole_ref
	/// Allows the knotter to withdraw voluntarily.
	var/datum/action/knot_release/knotter_release_action
	/// Allows the recipient to struggle free.
	var/datum/action/knot_release/recipient_release_action

/datum/component/knotting/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/knotting/Destroy(force)
	if(knotted_recipient)
		knot_exit()
	return ..()

/datum/component/knotting/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_SEX_TRY_KNOT, PROC_REF(try_knot))
	RegisterSignal(parent, COMSIG_SEX_REMOVE_KNOT, PROC_REF(on_remove_knot))

/datum/component/knotting/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_SEX_TRY_KNOT)
	UnregisterSignal(parent, COMSIG_SEX_REMOVE_KNOT)

/datum/component/knotting/proc/check_knot_penis_type()
	var/mob/living/user = parent
	var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return FALSE
	switch(penis.penis_type)
		if(PENIS_TYPE_KNOTTED, PENIS_TYPE_TAPERED_DOUBLE_KNOTTED, PENIS_TYPE_BARBED_KNOTTED)
			return TRUE
	return FALSE

/datum/component/knotting/proc/try_knot(datum/source, mob/living/target, force_level, datum/sex_action/originating_action)
	SIGNAL_HANDLER

	var/mob/living/user = parent

	if(!can_knot(user, target))
		return FALSE
	if(knotted_recipient == target)
		knotted_action_ref = originating_action ? WEAKREF(originating_action) : null
		return TRUE
	if(knotted_recipient)
		knot_remove()

	var/datum/component/knotting/other_knot = active_knots_by_recipient[target]
	if(other_knot && other_knot != src)
		if(QDELETED(other_knot) || other_knot.knotted_recipient != target)
			active_knots_by_recipient -= target
		else
			other_knot.knot_remove(forceful_removal = TRUE)

	apply_knot(user, target, force_level, originating_action)
	return TRUE

/datum/component/knotting/proc/can_knot(mob/living/user, mob/living/target)
	if(!istype(user) || !istype(target) || user == target)
		return FALSE

	if(!check_knot_penis_type())
		return FALSE

	// A toy knot is always hard enough to tie.
	var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
	if(penis?.is_false_organ())
		return TRUE

	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] < VISIBLE_AROUSAL_THRESHOLD)
		to_chat(user, span_notice("My knot is too soft to tie."))
		if(knotted_recipient)
			knot_remove()
		return FALSE

	//! VERY IMPORTANT A BETTER CONSENT SYSTEM

	return TRUE

/datum/component/knotting/proc/on_remove_knot(datum/source, forceful_removal = FALSE, notify = TRUE, keep_top_status = FALSE, keep_btm_status = FALSE)
	SIGNAL_HANDLER
	knot_remove(forceful_removal, notify, keep_top_status, keep_btm_status)

/datum/component/knotting/proc/apply_knot(mob/living/user, mob/living/target, force_level, datum/sex_action/originating_action)
	knotted_owner = user
	knotted_recipient = target
	knotted_action_ref = originating_action ? WEAKREF(originating_action) : null
	tugging_knot_blocked = FALSE
	active_knots_by_recipient[target] = src

	handle_knot_force_effects(user, target, force_level)
	// The receiver gets its own line, so the room line skips it.
	user.visible_message(span_notice("[user] shoves deep and [user.p_their()] knot swells, locking [user.p_them()] inside [target]!"),
		span_notice("I shove deep and my knot swells, locking me inside [target]."),
		span_hear("I hear a yelp and a wet, final push."),
		ignored_mobs = list(target))

	if(target.stat != DEAD)
		to_chat(target, span_userdanger("[user]'s knot swells inside me and locks us together!"))

	apply_knot_status_effects(user, target)
	if(originating_action?.hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		var/obj/item/organ/genitals/filling_organ/affected_hole = target.getorganslot(originating_action.hole_id)
		if(affected_hole)
			knotted_hole_ref = WEAKREF(affected_hole)
			ADD_TRAIT(affected_hole, TRAIT_PASSIVE_LEAK_BLOCKED, REF(src))
			RegisterSignal(affected_hole, list(COMSIG_ORGAN_REMOVED, COMSIG_PARENT_QDELETING), PROC_REF(on_knotted_hole_lost))
			var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
			// The swelling knot opens the hole to its girth at once.
			if(penis && istype(affected_hole) && affected_hole.orifice_type)
				affected_hole.get_orifice().stretch_toward(penis.get_knot_girth(), force_level, 1)

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(knot_movement))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(knot_movement))
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_recipient_qdeleting))

	knotter_release_action = new(src, FALSE)
	knotter_release_action.Grant(user)
	recipient_release_action = new(src, TRUE)
	recipient_release_action.Grant(target)

	log_combat(user, target, "Started knot tugging")

/datum/component/knotting/proc/handle_knot_force_effects(mob/living/user, mob/living/target, force_level)
	if(force_level > SEX_FORCE_MID)
		var/datum/component/arousal/target_arousal = target.GetComponent(/datum/component/arousal)
		if(force_level >= SEX_FORCE_EXTREME)
			//target.apply_damage(30, BRUTE, BODY_ZONE_CHEST)
			target_arousal?.try_do_pain_effect(PAIN_HIGH_EFFECT, FALSE)
		else
			target_arousal?.try_do_pain_effect(PAIN_MILD_EFFECT, FALSE)
		target.Stun(80)

/datum/component/knotting/proc/apply_knot_status_effects(mob/living/user, mob/living/target)
	var/should_apply_fucked_stupid = FALSE
	// Patrons are a human matter; beasts never carry Baotha's blessing.
	if(ishuman(user) && user.patron && istype(user.patron, /datum/patron/inhumen/baotha))
		should_apply_fucked_stupid = TRUE

	if(should_apply_fucked_stupid && !target.has_status_effect(/datum/status_effect/knot_fucked_stupid))
		target.apply_status_effect(/datum/status_effect/knot_fucked_stupid)

	if(!target.has_status_effect(/datum/status_effect/knot_tied))
		target.apply_status_effect(/datum/status_effect/knot_tied)
	if(!user.has_status_effect(/datum/status_effect/knotted))
		user.apply_status_effect(/datum/status_effect/knotted)

/datum/component/knotting/proc/knot_movement(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(!knotted_recipient)
		return

	if(QDELETED(mover) || !isliving(mover))
		knot_exit()
		return

	if(mover == knotted_owner)
		addtimer(CALLBACK(src, PROC_REF(knot_movement_top)), 1, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)
	else if(mover == knotted_recipient && !tugging_knot)
		addtimer(CALLBACK(src, PROC_REF(knot_movement_btm)), 1, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

/datum/component/knotting/proc/on_recipient_qdeleting(datum/source)
	SIGNAL_HANDLER
	knot_exit()

/datum/component/knotting/proc/on_knotted_hole_lost(datum/source)
	SIGNAL_HANDLER
	knot_remove()

/datum/component/knotting/proc/try_escape(mob/living/escapee)
	set waitfor = FALSE

	if(escapee != knotted_recipient || DOING_INTERACTION(escapee, KNOT_ESCAPE_INTERACTION_KEY))
		return

	var/mob/living/top = knotted_owner
	if(!validate_knot_participants(top, escapee))
		return

	escapee.visible_message(
		span_warning("[escapee] starts working [top]'s knot out of [escapee.p_them()]!"),
		span_notice("I start working [top]'s knot out of me."),
	)

	if(!do_after(escapee, KNOT_ESCAPE_TIME, target = top, timed_action_flags = IGNORE_HELD_ITEM, interaction_key = KNOT_ESCAPE_INTERACTION_KEY))
		if(!QDELETED(escapee) && escapee == knotted_recipient)
			to_chat(escapee, span_warning("I fail to work [top]'s knot out of me."))
		return

	if(QDELETED(src) || QDELETED(escapee) || QDELETED(top))
		return
	if(escapee != knotted_recipient || top != knotted_owner)
		return

	knot_remove(forceful_removal = TRUE, remover = escapee)

/datum/component/knotting/proc/knot_movement_top()
	var/mob/living/top = knotted_owner
	var/mob/living/btm = knotted_recipient

	if(!validate_knot_participants(top, btm))
		return

	if(handle_special_movement_cases(top, btm))
		return

	if(should_remove_knot_on_movement(top, btm))
		return

	handle_knot_distance_management(top, btm)

/datum/component/knotting/proc/knot_movement_btm()
	var/mob/living/top = knotted_owner
	var/mob/living/btm = knotted_recipient

	if(!validate_knot_participants(top, btm))
		return

	// Bottom-specific movement logic
	handle_bottom_movement(top, btm)

/datum/component/knotting/proc/validate_knot_participants(mob/living/top, mob/living/btm)
	if(!isliving(btm) || QDELETED(btm) || !isliving(top) || QDELETED(top))
		knot_exit()
		return FALSE

	return TRUE


/datum/component/knotting/proc/get_knotted_drag_target()
	var/mob/living/top = knotted_owner
	var/mob/living/btm = knotted_recipient

	if(parent != top)
		return null
	if(!validate_knot_participants(top, btm))
		return null

	return btm

/datum/component/knotting/proc/handle_special_movement_cases(mob/living/top, mob/living/btm)
	// Fireman carry case
	if(prob(10) && top.m_intent == MOVE_INTENT_WALK && (btm in top.buckled_mobs))
		var/obj/item/organ/genitals/penis/penis = top.getorganslot(ORGAN_SLOT_PENIS)
		var/datum/sex_action/action = knotted_action_ref?.resolve()
		if(action && ((action.action_user == top && action.action_target == btm) || (action.action_user == btm && action.action_target == top)))
			var/oversized = penis?.organ_size > DEFAULT_PENIS_SIZE
			action.perform_sex_action(btm, top, oversized ? 6.0 : 3.0, oversized ? 4 : 2, 3)
			var/datum/component/arousal/btm_arousal = btm.GetComponent(/datum/component/arousal)
			btm_arousal?.try_ejaculate(action, action.action_user, action.action_target, action.action_user == btm, top)
		if(prob(50))
			to_chat(top, span_love("I feel [btm] tightening over my knot."))
			to_chat(btm, span_love("I feel [top] rubbing inside."))
		return TRUE

	// Pulling case
	if(btm.pulling == top || top.pulling == btm)
		return TRUE

	return FALSE

/datum/component/knotting/proc/should_remove_knot_on_movement(mob/living/top, mob/living/btm)
	var/list/arousal_data = list()
	SEND_SIGNAL(top, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] < VISIBLE_AROUSAL_THRESHOLD)
		knot_remove()
		return TRUE

	var/dist = get_dist(top, btm)
	if(dist > 1 && dist < 6)
		return FALSE

	if(dist > 1)
		knot_remove(forceful_removal = TRUE)
		return TRUE

	var/strong_enough_to_run = top.STASTR > (btm.STACON + 3)
	if(!strong_enough_to_run && top.m_intent == MOVE_INTENT_RUN && (top.mobility_flags & MOBILITY_STAND))
		knot_remove(forceful_removal = TRUE)
		return TRUE

	return FALSE

/datum/component/knotting/proc/handle_knot_distance_management(mob/living/top, mob/living/btm)
	var/dist = get_dist(top, btm)

	if(dist > 1 && dist < 6)
		tugging_knot = TRUE
		for(var/i in 1 to 3)
			step_towards(btm, top)
			dist = get_dist(top, btm)
			if(dist <= 1)
				break
		tugging_knot = FALSE

	btm.face_atom(top)
	top.set_pull_offsets(btm, GRAB_AGGRESSIVE)

	update_clothing_check()

	apply_movement_penalties(top, btm)

/datum/component/knotting/proc/update_clothing_check()
	if(tugging_knot_check == 0)
		var/mob/living/top = knotted_owner
		tugging_knot_blocked = !get_location_accessible(top, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE)
		tugging_knot_check = 5
	else
		tugging_knot_check--

/datum/component/knotting/proc/apply_movement_penalties(mob/living/top, mob/living/btm)
	if(!top.IsStun())
		var/stun_chance = !top.cmode && !tugging_knot_blocked ? 7 : 20
		if(prob(stun_chance))
			var/datum/component/arousal/top_arousal = top.GetComponent(/datum/component/arousal)
			top_arousal?.try_do_pain_effect(PAIN_MILD_EFFECT, FALSE)

			if(tugging_knot_blocked && (top.mobility_flags & MOBILITY_STAND))
				top.Knockdown(10)
				to_chat(top, span_warning("I trip trying to move while my knot is covered."))
				tugging_knot_blocked = FALSE
				tugging_knot_check = 0
			top.Stun(15)

	if(!btm.IsStun())
		if(prob(5))
			btm.emote("groan")
			var/datum/component/arousal/btm_arousal = btm.GetComponent(/datum/component/arousal)
			btm_arousal?.try_do_pain_effect(PAIN_MED_EFFECT, FALSE)
			btm.Stun(15)
		else if(prob(3))
			btm.emote("painmoan")

/datum/component/knotting/proc/handle_bottom_movement(mob/living/top, mob/living/btm)
	// Bottom-specific checks
	if(top.stat >= SOFT_CRIT)
		knot_remove()
		return

	var/list/arousal_data = list()
	SEND_SIGNAL(top, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] < VISIBLE_AROUSAL_THRESHOLD)
		knot_remove()
		return

	var/dist = get_dist(top, btm)
	if(dist > 2)
		knot_remove(forceful_removal = TRUE)
		return

	// Move bottom towards top
	for(var/i in 2 to dist)
		step_towards(btm, top)

	top.set_pull_offsets(btm, GRAB_AGGRESSIVE)

	// Handle running penalty
	if(btm.mobility_flags & MOBILITY_STAND && btm.m_intent == MOVE_INTENT_RUN)
		btm.Knockdown(10)
		btm.Stun(30)
		btm.emote("groan", forced = TRUE)
		return

	// Regular movement penalties
	if(!btm.IsStun())
		if(prob(10))
			btm.emote("groan")
			var/datum/component/arousal/btm_arousal = btm.GetComponent(/datum/component/arousal)
			btm_arousal?.try_do_pain_effect(PAIN_MED_EFFECT, FALSE)
			btm.Stun(15)
		else if(prob(4))
			btm.emote("painmoan")

	addtimer(CALLBACK(src, PROC_REF(knot_movement_btm_after)), 0.1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

/datum/component/knotting/proc/knot_movement_btm_after()
	var/mob/living/top = knotted_owner
	var/mob/living/btm = knotted_recipient
	if(!isliving(btm) || QDELETED(btm) || !isliving(top) || QDELETED(top))
		return
	btm.face_atom(top)

/datum/component/knotting/proc/knot_remove(forceful_removal = FALSE, notify = TRUE, keep_top_status = FALSE, keep_btm_status = FALSE, mob/living/remover)
	var/mob/living/top = knotted_owner
	var/mob/living/btm = knotted_recipient

	if(isliving(btm) && !QDELETED(btm) && isliving(top) && !QDELETED(top))
		handle_knot_removal_effects(top, btm, forceful_removal, notify, keep_btm_status, remover)

	knot_exit(keep_top_status, keep_btm_status)

/datum/component/knotting/proc/handle_knot_removal_effects(mob/living/top, mob/living/btm, forceful_removal, notify, keep_btm_status, mob/living/remover)
	if(forceful_removal)
		var/list/arousal_data = list()
		SEND_SIGNAL(top, COMSIG_SEX_GET_AROUSAL, arousal_data)

		if(arousal_data["arousal"] > MAX_AROUSAL / 2)
			btm.Knockdown(10)
			if(notify && !keep_btm_status)
				gape_knotted_hole(top)

		btm.Stun(80)
		playsound(btm, pick('sound/misc/mat/pop.ogg', 'modular_rmh/sound/effects/cork_pop.ogg', 'modular_rmh/sound/effects/cork_pop (2).ogg'), 100, TRUE, -2, ignore_walls = FALSE)
		playsound(top, 'sound/misc/mat/segso.ogg', 50, TRUE, -2, ignore_walls = FALSE)
		INVOKE_ASYNC(btm, TYPE_PROC_REF(/mob, emote), "paincrit", forced = TRUE)

		if(notify)
			if(remover == btm)
				btm.visible_message(span_warning("[btm] forces [top]'s knot out of [btm.p_them()]!"),
					span_userdanger("I force [top]'s knot out of me!"))
			else if(remover == top)
				top.visible_message(span_notice("[top] yanks [top.p_their()] knot out of [btm]!"),
					span_notice("I yank my knot out of [btm]."), ignored_mobs = list(btm))
				to_chat(btm, span_userdanger("[top]'s knot tears out of me!"))
			else
				top.visible_message(span_warning("[top]'s knot is forced out of [btm]!"),
					span_userdanger("My knot is forced out of [btm]!"), ignored_mobs = list(btm))
				to_chat(btm, span_userdanger("[top]'s knot tears out of me!"))
			var/datum/component/arousal/btm_arousal = btm.GetComponent(/datum/component/arousal)
			btm_arousal?.try_do_pain_effect(PAIN_HIGH_EFFECT, FALSE)
	else if(notify)
		playsound(btm, 'sound/misc/mat/insert (1).ogg', 50, TRUE, -2, ignore_walls = FALSE)
		top.visible_message(span_notice("[top] slips [top.p_their()] knot out of [btm]."),
			span_notice("I slip my knot out of [btm]."), ignored_mobs = list(btm))
		to_chat(btm, span_notice("[top]'s knot slips out of me."))
		INVOKE_ASYNC(btm, TYPE_PROC_REF(/mob, emote), "painmoan", forced = TRUE)
		var/datum/component/arousal/btm_arousal = btm.GetComponent(/datum/component/arousal)
		btm_arousal?.try_do_pain_effect(PAIN_MILD_EFFECT, FALSE)

/// Ends the tie; [spill] FALSE keeps the hole's contents in, for a knot that stays lodged inside.
/datum/component/knotting/proc/knot_exit(keep_top_status = FALSE, keep_btm_status = FALSE, spill = TRUE)
	var/mob/living/top = knotted_owner
	var/mob/living/btm = knotted_recipient
	var/obj/item/organ/genitals/filling_organ/affected_hole = knotted_hole_ref?.resolve()
	knotted_hole_ref = null

	if(affected_hole && !QDELETED(affected_hole))
		UnregisterSignal(affected_hole, list(COMSIG_ORGAN_REMOVED, COMSIG_PARENT_QDELETING))
		REMOVE_TRAIT(affected_hole, TRAIT_PASSIVE_LEAK_BLOCKED, REF(src))
		if(spill && istype(btm) && !QDELETED(btm) && affected_hole.reagents?.total_volume)
			var/turf/release_turf = get_turf(btm)
			if(release_turf)
				var/release_amount = min(KNOT_RELEASE_SPILL_AMOUNT, affected_hole.reagents.total_volume)
				affected_hole.drip_to_turf(release_turf, release_amount)
				to_chat(btm, span_notice("A warm gush spills from my [affected_hole.name] as the knot comes free."))

	if(btm && active_knots_by_recipient[btm] == src)
		active_knots_by_recipient -= btm

	QDEL_NULL(knotter_release_action)
	QDEL_NULL(recipient_release_action)

	if(istype(top))
		if(!keep_top_status)
			top.remove_status_effect(/datum/status_effect/knotted)
		UnregisterSignal(top, COMSIG_MOVABLE_MOVED)
		log_combat(top, top, "Stopped knot tugging")

	if(istype(btm))
		if(!keep_btm_status)
			btm.remove_status_effect(/datum/status_effect/knot_tied)
		UnregisterSignal(btm, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
		log_combat(btm, btm, "Stopped knot tugging")

	knotted_owner = null
	knotted_recipient = null
	knotted_action_ref = null
	tugging_knot = FALSE
	tugging_knot_check = 0
	tugging_knot_blocked = FALSE

	if(istype(btm) && !QDELETED(btm))
		btm.reset_pull_offsets(btm)
	if(istype(top) && !QDELETED(top))
		top.reset_pull_offsets(top)

/datum/action/knot_release
	name = "Release Knot"
	desc = "Withdraw your knot safely."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "ravox_tug"
	check_flags = AB_CHECK_CONSCIOUS
	var/is_escape_action = FALSE

/datum/action/knot_release/New(Target, is_escape_action = FALSE)
	. = ..()
	src.is_escape_action = is_escape_action
	if(is_escape_action)
		name = "Struggle Free"
		desc = "Try to force the knot out. This will hurt if you succeed."

/datum/action/knot_release/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	var/datum/component/knotting/knot = target
	if(!istype(knot) || QDELETED(knot))
		return FALSE
	if(is_escape_action)
		return owner == knot.knotted_recipient
	return owner == knot.knotted_owner

/datum/action/knot_release/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/datum/component/knotting/knot = target
	if(is_escape_action)
		knot.try_escape(owner)
	else
		knot.knot_remove(remover = owner)
	return TRUE

#undef KNOT_ESCAPE_TIME
#undef KNOT_ESCAPE_INTERACTION_KEY
#undef KNOT_RELEASE_SPILL_AMOUNT

