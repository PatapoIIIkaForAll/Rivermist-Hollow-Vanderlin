// Every cock climax comes in spurts: one to three pulses, each landing where it can at that moment.

/datum/component/arousal
	/// Spurts of a climax still in flight, so a squeeze can choke them off.
	var/datum/climax_spurts/active_spurts
	/// Coat zone a pull-out set for the climax being handled right now.
	var/climax_zone_override

/// TRUE when the climaxer lies under a partner whose cock is inside them.
/datum/component/arousal/proc/spurts_over_own_body(datum/sex_action/action, mob/living/climaxer)
	if(!action || climaxer.body_position != LYING_DOWN)
		return FALSE
	var/mob/living/penetrator = action.get_inserted_penis_owner(action.action_user, action.action_target)
	return penetrator && penetrator != climaxer

/// TRUE when the climaxer chose to finish outside and it is their cock inside someone.
/datum/component/arousal/proc/wants_to_finish_outside(datum/sex_action/action, mob/living/climaxer)
	if(!action || !climaxer.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	var/datum/sex_scene_controller/controller = climaxer.sex_scene?.get_controller(climaxer)
	if(!controller?.finish_outside)
		return FALSE
	return action.get_inserted_penis_owner(action.action_user, action.action_target) == climaxer

/// Rolls a pull-out at the climax; on a fail it says why, and the load goes inside after all.
/datum/component/arousal/proc/try_pull_out(mob/living/climaxer, mob/living/partner)
	if(!prob(get_pull_out_fail_chance(climaxer, partner)))
		return TRUE
	climaxer.visible_message(span_love("[climaxer] tries to pull out of [partner], but [get_failed_pull_out_reason(climaxer, partner)]!"))
	return FALSE

/// Percent chance a pull-out fails: 10 to 30% from high arousal, plus a lot more from a stronger partner's leg lock.
/proc/get_pull_out_fail_chance(mob/living/climaxer, mob/living/partner)
	. = 0
	var/list/arousal_data = list()
	SEND_SIGNAL(climaxer, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal_share = (arousal_data["arousal"] || 0) / MAX_AROUSAL
	if(arousal_share > PULL_OUT_FAIL_AROUSAL_SHARE)
		var/heat = min(1, (arousal_share - PULL_OUT_FAIL_AROUSAL_SHARE) / (1 - PULL_OUT_FAIL_AROUSAL_SHARE))
		. = PULL_OUT_FAIL_MIN_CHANCE + (PULL_OUT_FAIL_MAX_CHANCE - PULL_OUT_FAIL_MIN_CHANCE) * heat
	if(partner?.leg_locks_harder(climaxer))
		. = min(. + LEG_LOCK_PULL_OUT_FAIL_CHANCE, PULL_OUT_FAIL_MAX_TOTAL)

/proc/get_failed_pull_out_reason(mob/living/climaxer, mob/living/partner)
	if(partner?.leg_locks_harder(climaxer))
		return "[partner]'s legs lock [climaxer.p_them()] in place"
	return "[climaxer.p_they()] can't make it in time"

/// Pulls out at the last moment and returns an onto-the-partner climax.
/datum/component/arousal/proc/pull_out_for_climax(datum/sex_action/action, mob/living/climaxer, mob/living/partner)
	if(action.orifice_pressing)
		return climax_at_opening(action, climaxer)
	var/from_mouth = action.hole_id == BODY_ZONE_PRECISE_MOUTH
	var/place = from_mouth ? "[partner]'s mouth" : "[partner]"
	climaxer.visible_message(span_love("[climaxer] pulls out of [place] at the last moment and cums all over [partner.p_them()]!"))
	if(action.hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		climaxer.lose_virginity()
		partner.lose_virginity()
	climax_zone_override = from_mouth ? FLUID_COAT_FACE : action.get_climax_coat_zone(climaxer)
	return ORGASM_LOCATION_ONTO

/// A climax while still pressing at an opening stays outside and takes no virginity; null spills it the generic way.
/datum/component/arousal/proc/climax_at_opening(datum/sex_action/action, mob/living/climaxer)
	var/mob/living/insertor = action.get_storage_insertor(action.action_user, action.action_target)
	var/mob/living/receiver = action.get_storage_receiver(action.action_user, action.action_target)
	var/datum/orifice/hole = action.get_penetrated_orifice(action.action_user, action.action_target, FALSE)
	var/opening = hole ? hole.opening_name : "[action.hole_id]"
	var/what = action.get_pressing_noun(insertor)
	if(climaxer != insertor)
		climaxer.visible_message(span_love("[climaxer] climaxes as [insertor] grinds [what] against [climaxer.p_their()] [opening]!"))
		return null
	if(climaxer == receiver)
		climaxer.visible_message(span_love("[climaxer] climaxes grinding [what] against [climaxer.p_their()] [opening]!"))
		return null
	if(!ispath(action.stored_item_type, /obj/item/organ/genitals/penis))
		climaxer.visible_message(span_love("[climaxer] climaxes while grinding [what] against [receiver]'s [opening]!"))
		return null
	// The cock never got in, so the load spills over the opening it pressed at.
	climaxer.visible_message(span_love("[climaxer] cums against [receiver]'s [opening] without ever getting inside!"))
	climax_zone_override = FLUID_COAT_GROIN
	return ORGASM_LOCATION_ONTO

/// Everyone whose cock is inside this mob's vagina or anus right now.
/mob/living/proc/get_hole_penetrators()
	. = list()
	for(var/datum/sex_action/action as anything in sex_scene?.active_actions)
		if(action.hole_id == BODY_ZONE_PRECISE_MOUTH)
			continue
		var/mob/living/insertor = action.get_inserted_penis_owner(action.action_user, action.action_target)
		if(!insertor || insertor == src)
			continue
		var/mob/living/receiver = insertor == action.action_user ? action.action_target : action.action_user
		if(receiver == src)
			. |= insertor

/// TRUE while this mob lies with legs locked around someone inside them.
/mob/living/proc/is_leg_locking(mob/living/penetrator)
	if(body_position != LYING_DOWN || stat != CONSCIOUS)
		return FALSE
	var/datum/sex_scene_controller/controller = sex_scene?.get_controller(src)
	if(!controller?.leg_lock)
		return FALSE
	return (penetrator in get_hole_penetrators())

/// A leg lock only holds someone weaker in.
/mob/living/proc/leg_locks_harder(mob/living/penetrator)
	return is_leg_locking(penetrator) && get_stat_level(STATKEY_STR) > penetrator.get_stat_level(STATKEY_STR)

/// Locks or loosens the legs; locking needs the actor lying with someone inside them.
/datum/sex_scene_controller/proc/toggle_leg_lock()
	if(leg_lock)
		leg_lock = FALSE
		user.visible_message(span_love("[user] loosens [user.p_their()] legs."), span_love("I loosen my legs."))
		return
	var/list/penetrators = user.get_hole_penetrators()
	if(user.body_position != LYING_DOWN || !length(penetrators))
		return
	leg_lock = TRUE
	var/mob/living/partner = penetrators[1]
	user.visible_message(span_love("[user] wraps [user.p_their()] legs around [partner], locking [partner.p_them()] in."), span_love("I wrap my legs around [partner], locking [partner.p_them()] in."))

/datum/sex_action
	/// TRUE while this action's climax still spurts; it stops after the last one, so a stop meanwhile pulls out.
	var/stop_after_spurts = FALSE

/// The climax's last spurt is done, so an action set to stop at climax stops now.
/datum/sex_action/proc/end_after_spurts()
	if(!stop_after_spurts)
		return
	stop_after_spurts = FALSE
	just_climaxed = TRUE
	stop_requested = TRUE

/// Splits a load into one to three spurts, bigger loads in more of them.
/proc/get_climax_spurt_amounts(total)
	if(total < CLIMAX_SPURT_TWO_UNITS)
		return list(total)
	if(total <= CLIMAX_SPURT_THREE_UNITS)
		return list(total * 0.6, total * 0.4)
	return list(total * 0.5, total * 0.3, total * 0.2)

/// The aim on the climaxer's cock, when it has a target and this climax comes from a hand on it.
/datum/component/arousal/proc/get_steering_aim(datum/sex_action/action)
	var/mob/living/climaxer = parent
	var/obj/item/organ/genitals/penis/penis = climaxer.getorganslot(ORGAN_SLOT_PENIS)
	var/datum/climax_aim/aim = penis?.climax_aim
	if(!aim?.target)
		return null
	if(action && action.get_grip_owner(action.action_user, action.action_target) != climaxer)
		return null
	return aim

/// Lands a steered climax in spurts; FALSE when the aim is gone, so the normal routing runs.
/datum/component/arousal/proc/climax_at_aim(datum/climax_aim/aim, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer)
	var/mob/living/carbon/climaxer = parent
	var/obj/item/organ/genitals/filling_organ/testicles/testes = climaxer.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testes?.reagents)
		return FALSE
	if(!aim.get_valid_target())
		if(aim.aimer)
			to_chat(aim.aimer, span_warning("I lose my aim."))
		aim.clear()
		return FALSE
	var/mob/living/aimed_mob = isliving(aim.target) ? aim.target : null
	var/into_mouth = start_spurts(aim, testes.get_climax_release(ORGASM_LOCATION_ONTO), FALSE, action, action_initiator, action_target, action_performer)
	var/obj/item/organ/genitals/filling_organ/vagina/vag = climaxer.getorganslot(ORGAN_SLOT_VAGINA)
	if(vag?.reagents)
		vag.produce_climax_fluid()
	if(testes.reagents.total_volume <= testes.reagents.maximum_volume / 4)
		to_chat(climaxer, span_info("Damn, my [pick(testes.altnames)] are pretty dry now."))
	after_ejaculation(into_mouth, climaxer, aimed_mob, action, action_initiator, action_target, action_performer)
	return TRUE

/// Begins a spurting climax at the aim; returns TRUE when the first spurt went into a mouth.
/datum/component/arousal/proc/start_spurts(datum/climax_aim/aim, total, quiet_first, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer, transient_aim = FALSE)
	return begin_spurts(new /datum/climax_spurts/aimed(src, total, action, action_initiator, action_target, action_performer, aim, quiet_first, transient_aim))

/// Fires the first spurt of a climax, replacing any still in flight; returns what that spurt reports.
/datum/component/arousal/proc/begin_spurts(datum/climax_spurts/spurts)
	if(active_spurts)
		qdel(active_spurts)
	active_spurts = spurts
	return spurts.pulse()

/// One climax's spurts, fired one after another; each subtype decides where a spurt lands.
/datum/climax_spurts
	var/datum/component/arousal/arousal
	var/list/amounts
	var/pulse_index = 0
	var/datum/sex_action/action
	var/mob/living/action_initiator
	var/mob/living/action_target
	var/atom/action_performer
	var/timer_id

/datum/climax_spurts/New(datum/component/arousal/new_arousal, total, datum/sex_action/new_action, mob/living/new_initiator, mob/living/new_target, atom/new_performer)
	arousal = new_arousal
	amounts = get_climax_spurt_amounts(total)
	action = new_action
	action_initiator = new_initiator
	action_target = new_target
	action_performer = new_performer

/datum/climax_spurts/Destroy(force)
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(arousal?.active_spurts == src)
		arousal.active_spurts = null
	if(!QDELETED(action))
		action.end_after_spurts()
	arousal = null
	action = null
	action_initiator = null
	action_target = null
	action_performer = null
	return ..()

/// Fires the next spurt and schedules the one after; returns what the spurt reports.
/datum/climax_spurts/proc/pulse()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(QDELETED(arousal) || QDELETED(arousal.parent) || pulse_index >= length(amounts))
		qdel(src)
		return 0
	pulse_index++
	. = deliver(amounts[pulse_index], pulse_index > 1)
	if(QDELETED(src))
		return
	if(pulse_index < length(amounts))
		timer_id = addtimer(CALLBACK(src, PROC_REF(pulse)), CLIMAX_SPURT_INTERVAL, TIMER_STOPPABLE)
	else
		qdel(src)

/// Lands one spurt; follow-ups skip effects that belong to the climax as a whole.
/datum/climax_spurts/proc/deliver(amount, is_follow_up)
	return 0

/// TRUE while spurts of a climax from this action are still to come.
/datum/climax_spurts/proc/is_running_for(datum/sex_action/for_action)
	return for_action == action && pulse_index < length(amounts)

/// Fires every spurt still to come at once.
/datum/climax_spurts/proc/finish_now()
	for(var/i in 1 to length(amounts) + 1)
		if(QDELETED(src))
			return
		pulse()

/// A squeeze chokes off the spurts still to come; returns the units held back.
/datum/climax_spurts/proc/choke()
	. = 0
	for(var/i in (pulse_index + 1) to length(amounts))
		. += amounts[i]
	qdel(src)

/datum/climax_spurts/proc/get_climaxer()
	RETURN_TYPE(/mob/living)
	return arousal.parent

/// The balls the spurts come from, while they still hold anything.
/datum/climax_spurts/proc/get_load()
	RETURN_TYPE(/datum/reagents)
	var/mob/living/climaxer = get_climaxer()
	var/obj/item/organ/genitals/filling_organ/testicles/testes = climaxer.getorganslot(ORGAN_SLOT_TESTICLES)
	return testes?.reagents?.total_volume ? testes.reagents : null

/datum/climax_spurts/proc/get_live_action()
	return QDELETED(action) ? null : action

// --- Aimed: onto a body, a container, a garment or the floor ---

/// Spurts that land where an aim points, drifting down a body unless someone re-aims.
/datum/climax_spurts/aimed
	/// Where the spurts land; a private copy, so the rest still lands when the aim ends with its action.
	var/datum/climax_aim/aim
	/// The cock's own aim, watched for a fresh aim between spurts; null for an unaimed climax.
	var/datum/climax_aim/live_aim
	/// The live aim's revision when it was last followed; a newer one means someone re-aimed.
	var/start_revision
	/// TRUE once someone re-aimed, so the rest lands right where aimed instead of drifting.
	var/re_aimed = FALSE
	/// The action already announced the climax, so the first spurt stays quiet.
	var/quiet_first = FALSE

/datum/climax_spurts/aimed/New(datum/component/arousal/new_arousal, total, datum/sex_action/new_action, mob/living/new_initiator, mob/living/new_target, atom/new_performer, datum/climax_aim/new_aim, new_quiet_first, new_transient_aim)
	. = ..()
	quiet_first = new_quiet_first
	if(new_transient_aim)
		aim = new_aim
		return
	live_aim = new_aim
	start_revision = new_aim.revision
	aim = new /datum/climax_aim(new_aim.penis)
	aim.copy_target_from(new_aim)

/datum/climax_spurts/aimed/Destroy(force)
	QDEL_NULL(aim)
	live_aim = null
	return ..()

/// Returns TRUE when the spurt went into a mouth.
/datum/climax_spurts/aimed/deliver(amount, is_follow_up)
	follow_live_aim()
	var/drift = re_aimed ? 0 : pulse_index - 1
	return arousal.deliver_spurt(aim, amount, drift, !is_follow_up && quiet_first, is_follow_up, get_live_action(), action_initiator, action_target, action_performer)

/// A fresh aim on the cock sends the rest there; a cleared one changes nothing.
/datum/climax_spurts/aimed/proc/follow_live_aim()
	if(QDELETED(live_aim) || !live_aim.target || live_aim.revision == start_revision)
		return
	start_revision = live_aim.revision
	aim.copy_target_from(live_aim)
	re_aimed = TRUE

// --- Inside: a hole, or the partner's body when there is no hole to fill ---

/// Spurts pumped inside a partner; a full hole overflows, and once the cock is out the rest lands on them.
/datum/climax_spurts/inside
	var/mob/living/receiver
	var/obj/item/organ/genitals/filling_organ/hole
	/// FALSE for a climax with no action, which nothing can pull out of.
	var/tracks_action = FALSE
	/// TRUE when the action needs both on one tile, so stepping off it pulls out.
	var/needs_same_tile = FALSE
	/// Coat zone the first spurt after a pull-out lands on.
	var/outside_zone = FLUID_COAT_GROIN
	/// Coat zone what a full hole cannot take runs down to.
	var/overflow_zone = FLUID_COAT_THIGHS
	var/overflow_announced = FALSE
	/// The aim the rest follows after a pull-out.
	var/datum/climax_aim/outside_aim
	var/outside_from_pulse = 0
	/// Chance a pull-out mid-climax fails, set while the action still ran at the climax.
	var/pull_out_fail_chance = 0
	/// TRUE after a failed pull-out, so the rest stays inside.
	var/held_in = FALSE

/datum/climax_spurts/inside/New(datum/component/arousal/new_arousal, total, datum/sex_action/new_action, mob/living/new_initiator, mob/living/new_target, atom/new_performer, mob/living/new_receiver, obj/item/organ/genitals/filling_organ/new_hole)
	. = ..()
	receiver = new_receiver
	hole = new_hole
	tracks_action = !!action
	needs_same_tile = action?.check_same_tile && !action.aggro_grab_instead_same_tile
	pull_out_fail_chance = get_pull_out_fail_chance(get_climaxer(), receiver)

/datum/climax_spurts/inside/Destroy(force)
	QDEL_NULL(outside_aim)
	receiver = null
	hole = null
	return ..()

/// Returns the units that went inside.
/datum/climax_spurts/inside/deliver(amount, is_follow_up)
	var/datum/reagents/load = get_load()
	if(!load || amount <= 0 || QDELETED(receiver))
		return 0
	if(is_follow_up && has_pulled_out())
		spurt_outside(amount)
		return 0
	var/mob/living/climaxer = get_climaxer()
	var/into = min(amount, get_room())
	. = 0
	if(into > 0)
		. = arousal.route_climax_reagents(load, into, climaxer, receiver, get_live_action(), get_climax_type(), hole || receiver, INGEST, action_initiator, action_target, action_performer, FALSE, is_follow_up)
	if(amount > into)
		// The overflow is part of the same spurt; it counts once-per-climax effects only if nothing went in.
		spill_overflow(amount - max(into, 0), is_follow_up || into > 0)
	if(is_follow_up && .)
		announce_follow_up(climaxer)

/// TRUE once the cock is out for good; stopping while still together is a pull-out, which can fail.
/datum/climax_spurts/inside/proc/has_pulled_out()
	if(outside_aim)
		return TRUE
	if(held_in || is_still_inside())
		return FALSE
	if(are_together() && prob(pull_out_fail_chance))
		held_in = TRUE
		var/mob/living/climaxer = get_climaxer()
		// Timer-driven, outside the act's scope: the held-in partner feels it blind or asleep.
		receiver?.push_feels_own_body()
		climaxer.visible_message(span_love("[climaxer] tries to pull out of [receiver] mid-climax, but [get_failed_pull_out_reason(climaxer, receiver)]!"))
		receiver?.pop_feels_own_body()
		return FALSE
	return TRUE

/// TRUE while the cock is still inside: partners together, and the action still running.
/datum/climax_spurts/inside/proc/is_still_inside()
	if(!are_together())
		return FALSE
	if(!tracks_action)
		return TRUE
	return !QDELETED(action) && action.is_runtime_active()

/// TRUE while both are close enough for the cock to be in: adjacent, and on one tile when the action needs it.
/datum/climax_spurts/inside/proc/are_together()
	var/mob/living/climaxer = get_climaxer()
	if(!climaxer.adjacent_or_closet(receiver))
		return FALSE
	return !needs_same_tile || get_turf(climaxer) == get_turf(receiver)

/datum/climax_spurts/inside/proc/get_room()
	if(!hole)
		return INFINITY
	return hole.reagents ? hole.reagents.maximum_volume - hole.reagents.total_volume : 0

/datum/climax_spurts/inside/proc/get_climax_type()
	return ORGASM_LOCATION_INTO

/datum/climax_spurts/inside/proc/announce_follow_up(mob/living/climaxer)
	to_chat(climaxer, span_love("<i>Spurt!</i> Another rope pumps into [receiver]."))
	if(receiver != climaxer)
		to_chat(receiver, span_love("Another hot spurt pumps into me."))

/// What a full hole cannot take leaks back out over the partner.
/datum/climax_spurts/inside/proc/spill_overflow(amount, follow_up)
	var/mob/living/climaxer = get_climaxer()
	var/spilled = arousal.coat_climax_onto(get_load(), amount, climaxer, receiver, get_live_action(), ORGASM_LOCATION_ONTO, overflow_zone, action_initiator, action_target, action_performer, follow_up)
	if(spilled > 0 && !overflow_announced)
		overflow_announced = TRUE
		announce_overflow()

/datum/climax_spurts/inside/proc/announce_overflow()
	receiver.felt_visible_message(span_love("It is too much for [receiver] to hold; seed spills out of [receiver.p_them()] and runs down [receiver.p_their()] thighs."), span_love("It is too much to hold. It spills out of me and runs down my thighs."), vision_distance = 1)

/// Pulled out mid-climax: the rest spurts over the partner, drifting down from where the cock left.
/datum/climax_spurts/inside/proc/spurt_outside(amount)
	var/mob/living/climaxer = get_climaxer()
	if(!outside_aim)
		outside_aim = new(climaxer.getorganslot(ORGAN_SLOT_PENIS))
		outside_aim.target = receiver
		outside_aim.zone = outside_zone
		outside_from_pulse = pulse_index
	arousal.deliver_spurt(outside_aim, amount, pulse_index - outside_from_pulse, FALSE, TRUE, get_live_action(), action_initiator, action_target, action_performer)

/// Spurts into a mouth; once it pulls away, the rest lands on the face.
/datum/climax_spurts/inside/oral
	outside_zone = FLUID_COAT_FACE
	overflow_zone = FLUID_COAT_FACE

/datum/climax_spurts/inside/oral/get_room()
	return receiver.reagents ? receiver.reagents.maximum_volume - receiver.reagents.total_volume : 0

/datum/climax_spurts/inside/oral/get_climax_type()
	return ORGASM_LOCATION_ORAL

/datum/climax_spurts/inside/oral/announce_follow_up(mob/living/climaxer)
	to_chat(climaxer, span_love("<i>Spurt!</i> Another rope fills [receiver]'s mouth."))
	if(receiver != climaxer)
		to_chat(receiver, span_love("Another hot spurt fills my mouth."))

/datum/climax_spurts/inside/oral/announce_overflow()
	receiver.felt_visible_message(span_love("It is too much for [receiver] to swallow; seed spills from [receiver.p_their()] lips."), span_love("It is too much to swallow. It spills from my lips."), vision_distance = 1)

// --- Floor and container ---

/// Spurts with nothing to catch them but worn catchers and the floor.
/datum/climax_spurts/floor
	var/mob/living/partner
	/// Where the first spurt lands; later ones fall under the climaxer.
	var/turf/first_turf

/datum/climax_spurts/floor/New(datum/component/arousal/new_arousal, total, datum/sex_action/new_action, mob/living/new_initiator, mob/living/new_target, atom/new_performer, mob/living/new_partner, turf/new_turf)
	. = ..()
	partner = new_partner
	first_turf = new_turf

/datum/climax_spurts/floor/Destroy(force)
	partner = null
	first_turf = null
	return ..()

/// Returns the units that left the balls.
/datum/climax_spurts/floor/deliver(amount, is_follow_up)
	var/datum/reagents/load = get_load()
	if(!load || amount <= 0)
		return 0
	var/mob/living/climaxer = get_climaxer()
	var/turf/landing = is_follow_up ? get_turf(climaxer) : first_turf
	. = arousal.route_climax_reagents(load, amount, climaxer, partner, get_live_action(), ORGASM_LOCATION_SELF, landing, null, action_initiator, action_target, action_performer, TRUE, is_follow_up)
	if(is_follow_up)
		to_chat(climaxer, span_love("<i>Spurt!</i> Another rope pulses out of me."))

/// Spurts into a held cup or bottle; once it is gone or out of reach, the rest falls to the floor.
/datum/climax_spurts/container
	var/mob/living/partner
	var/obj/item/container

/datum/climax_spurts/container/New(datum/component/arousal/new_arousal, total, datum/sex_action/new_action, mob/living/new_initiator, mob/living/new_target, atom/new_performer, mob/living/new_partner, obj/item/new_container)
	. = ..()
	partner = new_partner
	container = new_container

/datum/climax_spurts/container/Destroy(force)
	partner = null
	container = null
	return ..()

/// Returns the units that went into the container.
/datum/climax_spurts/container/deliver(amount, is_follow_up)
	var/datum/reagents/load = get_load()
	if(!load || amount <= 0)
		return 0
	var/mob/living/climaxer = get_climaxer()
	var/turf/climaxer_turf = get_turf(climaxer)
	if(QDELETED(container) || !container.reagents || get_dist(get_turf(container), climaxer_turf) > 1)
		arousal.route_climax_reagents(load, amount, climaxer, partner, get_live_action(), ORGASM_LOCATION_SELF, climaxer_turf, null, action_initiator, action_target, action_performer, TRUE, is_follow_up)
		return 0
	amount = min(amount, container.reagents.maximum_volume - container.reagents.total_volume)
	if(amount <= 0)
		return 0
	. = arousal.route_climax_reagents(load, amount, climaxer, partner, get_live_action(), ORGASM_LOCATION_CONTAINER, container, INJECT, action_initiator, action_target, action_performer, FALSE, is_follow_up)
	if(is_follow_up && .)
		to_chat(climaxer, span_love("<i>Spurt!</i> Another rope pulses into \the [container]."))

// --- Landing an aimed spurt ---

/// Lands one spurt; TRUE when it went into a mouth.
/datum/component/arousal/proc/deliver_spurt(datum/climax_aim/aim, amount, drift_steps, quiet, is_follow_up, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer)
	var/mob/living/carbon/climaxer = parent
	var/obj/item/organ/genitals/filling_organ/testicles/testes = climaxer.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testes?.reagents?.total_volume || amount <= 0)
		return FALSE
	var/datum/reagents/load = testes.reagents
	var/atom/landing = aim.get_valid_target()
	if(!landing)
		// The aim was lost between spurts; the rest falls on the floor.
		route_climax_reagents(load, amount, climaxer, null, action, ORGASM_LOCATION_SELF, get_turf(climaxer), null, action_initiator, action_target, action_performer, TRUE, is_follow_up)
		return FALSE
	var/mob/living/aimer = aim.aimer || climaxer
	var/mob/living/aimed_mob = isliving(landing) ? landing : null
	var/zone = aimed_mob ? aim.resolve_zone(aimed_mob, drift_steps) : null
	var/obj/item/clothing/shoes/heels/heels = aim.get_worn_heels(aimed_mob, zone)
	var/into_mouth = zone == PENIS_AIM_MOUTH && aimed_mob.mouth_is_free(cloth_blocks = TRUE)
	if(zone == PENIS_AIM_MOUTH && !into_mouth)
		zone = FLUID_COAT_FACE
	var/whose = aimed_mob ? get_aim_whose(aimed_mob, is_follow_up ? climaxer : aimer) : null
	var/phrase
	if(into_mouth)
		phrase = "into [whose] open mouth"
	else if(heels)
		phrase = "into [whose] heels, where it pools around [aimed_mob.p_their()] toes"
	else if(aimed_mob)
		phrase = "all over [whose] [get_fluid_coat_zone_name(zone, aimed_mob, aim.is_from_behind(aimed_mob))]"
	else if(isturf(landing))
		phrase = "onto the floor"
	else
		phrase = "[is_aim_container(landing) ? "into" : "onto"] \the [landing]"
	// Follow-up spurts run on a timer; the mob they land on feels them blind or asleep.
	aimed_mob?.push_feels_own_body()
	if(is_follow_up)
		climaxer.visible_message(span_love("[climaxer]'s cock spurts again, [phrase]!"), span_love("<i>Spurt!</i> Another rope lands [phrase]!"))
	else if(!quiet)
		if(aimer == climaxer)
			climaxer.visible_message(span_love("[climaxer] shoots [climaxer.p_their()] load [phrase]!"))
		else
			aimer.visible_message(span_love("[aimer] aims [climaxer]'s cock as it shoots [phrase]!"))
	aimed_mob?.pop_feels_own_body()
	log_combat(climaxer, aimed_mob || climaxer, "came [phrase], aimed by [key_name(aimer)]")

	if(into_mouth)
		var/swallowed = amount * PENIS_AIM_MOUTH_SHARE
		route_climax_reagents(load, swallowed, climaxer, aimed_mob, action, ORGASM_LOCATION_ORAL, aimed_mob, INGEST, action_initiator, action_target, action_performer, FALSE, is_follow_up)
		// The face share is part of the same spurt, so its effects never count twice.
		coat_climax_onto(load, amount - swallowed, climaxer, aimed_mob, action, ORGASM_LOCATION_ONTO, FLUID_COAT_FACE, action_initiator, action_target, action_performer, TRUE)
	else if(heels)
		fill_aimed_container(heels, load, amount, climaxer, aimed_mob, action, action_initiator, action_target, action_performer, is_follow_up)
	else if(aimed_mob)
		coat_climax_onto(load, amount, climaxer, aimed_mob, action, ORGASM_LOCATION_ONTO, zone, action_initiator, action_target, action_performer, is_follow_up)
	else if(is_aim_container(landing))
		fill_aimed_container(landing, load, amount, climaxer, null, action, action_initiator, action_target, action_performer, is_follow_up)
	else if(is_aim_garment(landing))
		soak_aimed_garment(landing, load, amount, climaxer, action, action_initiator, action_target, action_performer, is_follow_up)
	else
		route_climax_reagents(load, amount, climaxer, null, action, ORGASM_LOCATION_SELF, get_turf(landing), null, action_initiator, action_target, action_performer, TRUE, is_follow_up)
	return into_mouth

/// An open container with room, such as a cup, a bucket or heels nobody wears.
/proc/is_aim_container(atom/target)
	return isobj(target) && target.reagents && target.is_refillable()

/proc/is_aim_garment(atom/target)
	var/obj/item/clothing/garment = target
	return istype(garment) && garment.can_soak_fluid()

/// Fills a container from the load and spills what does not fit under it; returns the units that went in.
/datum/component/arousal/proc/fill_aimed_container(obj/container, datum/reagents/load, amount, mob/living/climaxer, mob/living/aimed_mob, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer, follow_up = FALSE)
	var/into = min(amount, container.reagents.maximum_volume - container.reagents.total_volume)
	if(into > 0)
		route_climax_reagents(load, into, climaxer, aimed_mob, action, ORGASM_LOCATION_CONTAINER, container, INJECT, action_initiator, action_target, action_performer, FALSE, follow_up)
	var/overflow = amount - max(into, 0)
	if(overflow > 0)
		container.visible_message(span_warning("\The [container] overflows!"))
		route_climax_reagents(load, overflow, climaxer, aimed_mob, action, ORGASM_LOCATION_SELF, get_turf(container), null, action_initiator, action_target, action_performer, TRUE, TRUE)
	return max(into, 0)

/// Cloth soaks the load; what it cannot hold drips to the floor under it.
/datum/component/arousal/proc/soak_aimed_garment(obj/item/clothing/garment, datum/reagents/load, amount, mob/living/climaxer, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer, follow_up = FALSE)
	var/remaining = apply_sex_action_climax_effects(climaxer, null, action, ORGASM_LOCATION_CONTAINER, load, amount, garment, null, action_initiator, action_target, action_performer, follow_up)
	if(remaining <= 0)
		return
	var/dripping = remaining - garment.soak_fluid(load, remaining)
	if(dripping > 0)
		deposit_cum_on_turf(get_turf(garment), load, dripping)

/// An unaimed climax onto someone still spurts, drifting down the body from where it started.
/datum/component/arousal/proc/spurt_onto(mob/living/target, coat_zone, amount, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer)
	var/mob/living/climaxer = parent
	var/obj/item/organ/genitals/penis/penis = climaxer.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis || !target)
		return FALSE
	var/datum/climax_aim/aim = new(penis)
	aim.target = target
	aim.zone = coat_zone
	start_spurts(aim, amount, TRUE, action, action_initiator, action_target, action_performer, TRUE)
	return TRUE
