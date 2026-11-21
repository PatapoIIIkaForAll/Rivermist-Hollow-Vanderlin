// Toy riding extras: bed creaks, flare drag, toy knots, being left impaled, grinding, sucking and seating plugs.

/// Units of the rider's own juices a climax leaves on the toy.
#define RIDE_CLIMAX_COAT 3
#define BED_CREAK_VOLUME 32
#define BED_CREAK_VOLUME_EXTREME 45
/// A flare is this much wider than the shaft it caps.
#define FLARE_GIRTH_MULT 1.15
#define FLARE_DRAG_MESSAGE_CHANCE 20
#define TOY_STUCK_TICK (6 SECONDS)
#define TOY_FREE_TIME (3 SECONDS)
#define TOY_FREE_STAMINA 15
#define TOY_SEAT_STAMINA 10
/// Girth from which a toy counts as big in the mouth.
#define TOY_BIG_GIRTH 14

// ---- Creaking furniture ----

/datum/sex_action
	/// Quiet acts such as lubing never creak the bed.
	var/creaks_furniture = TRUE
	var/next_creak_time = 0

/datum/sex_action/lube_up
	creaks_furniture = FALSE

/datum/sex_action/collect_fluid
	creaks_furniture = FALSE

/// A wooden creak, fast or slow to match the pace.
/datum/sex_action/proc/get_creak_sound()
	if(speed >= SEX_SPEED_HIGH)
		return pick('modular_rmh/sound/erp/bed_creak_fast1.ogg', 'modular_rmh/sound/erp/bed_creak_fast2.ogg', 'modular_rmh/sound/erp/bed_creak_fast3.ogg', 'modular_rmh/sound/erp/bed_creak_fast4.ogg')
	return pick('modular_rmh/sound/erp/bed_creak_slow1.ogg', 'modular_rmh/sound/erp/bed_creak_slow2.ogg', 'modular_rmh/sound/erp/bed_creak_slow3.ogg', 'modular_rmh/sound/erp/bed_creak_slow4.ogg')

/// The wooden bed under [someone], if any; sleeping bags do not creak.
/proc/find_creaky_bed(mob/living/someone)
	if(!someone)
		return null
	if(istype(someone.buckled, /obj/structure/bed) && !istype(someone.buckled, /obj/structure/bed/sleepingbag))
		return someone.buckled
	for(var/obj/structure/bed/bed in get_turf(someone))
		if(!istype(bed, /obj/structure/bed/sleepingbag))
			return bed
	return null

/// Once per cycle: rough acts on a bed make it creak.
/datum/sex_action/proc/play_furniture_noise()
	if(!creaks_furniture || force < SEX_FORCE_HIGH || world.time < next_creak_time || can_remote_interact())
		return
	var/obj/structure/bed/bed = find_creaky_bed(action_user) || find_creaky_bed(action_target)
	if(!bed)
		return
	playsound(bed, get_creak_sound(), force >= SEX_FORCE_EXTREME ? BED_CREAK_VOLUME_EXTREME : BED_CREAK_VOLUME, TRUE, -1, ignore_walls = FALSE)
	next_creak_time = world.time + (speed >= SEX_SPEED_HIGH ? 0 : 1 SECONDS)

// ---- The toy keeps the mess ----

/// After a climax on the toy, some of the rider's juices coat it and slick the next ride.
/obj/item/dildo/proc/take_climax_coat(mob/living/climaxer)
	var/obj/item/organ/genitals/filling_organ/vagina = climaxer?.getorganslot(ORGAN_SLOT_VAGINA)
	if(QDELETED(src) || !vagina?.reagents?.total_volume)
		return
	var/datum/reagents/coat = get_lube_reagents(TRUE)
	var/room = min(RIDE_CLIMAX_COAT, coat.maximum_volume - coat.total_volume)
	if(room > 0)
		vagina.reagents.trans_to(coat, room, transfered_by = climaxer)

// ---- Flare drag ----

/// TRUE when what penetrates in this action has a flared head: a horse cock, a flared strapon.
/datum/sex_action/proc/has_flared_penetrator()
	var/mob/living/penetrator = get_orifice_penetrator(action_user, action_target)
	var/obj/item/organ/genitals/penis/penis = penetrator?.getorganslot(ORGAN_SLOT_PENIS)
	return penis?.penis_type == PENIS_TYPE_EQUINE

/datum/sex_action/object_fuck/has_flared_penetrator()
	var/obj/item/dildo/toy = selected_toy
	return istype(toy) && toy.dildo_type == "flared"

/// The flare's share of pleasure for the hole's owner, judged before anything widens the opening.
/datum/sex_action/proc/get_flare_share(mob/living/receiver, datum/orifice/hole)
	var/datum/orifice_penetration/entry = hole.find_penetration(src)
	if(!entry || !iscarbon(receiver))
		return 0.5
	var/mob/living/carbon/carbon_receiver = receiver
	return carbon_receiver.get_birth_pleasure_share(hole, entry.girth * FLARE_GIRTH_MULT)

/// Rough strokes with a flared head tug at the rim on every pull back.
/datum/sex_action/proc/apply_flare_drag(datum/orifice/hole)
	if(force < SEX_FORCE_HIGH || !has_flared_penetrator())
		return
	var/mob/living/receiver = hole.get_owner()
	if(!receiver)
		return
	var/share = get_flare_share(receiver, hole)
	SEND_SIGNAL(receiver, COMSIG_SEX_GENERIC_ACTION, receiver, 1.2 * share, 3 * (1 - share), 0.6 * share, action_user)
	if(!prob(FLARE_DRAG_MESSAGE_CHANCE))
		return
	if(share >= 0.5)
		to_chat(receiver, span_love("The flare drags along my insides on every pull back, and I love it."))
	else
		to_chat(receiver, span_warning("The flare catches and tugs at my [hole.opening_name] on every pull back."))

/// When a flared head leaves, it catches at the rim before it pops free.
/datum/sex_action/proc/flare_pop_out(datum/orifice/hole)
	if(!has_flared_penetrator())
		return
	var/mob/living/receiver = hole.get_owner()
	if(!receiver)
		return
	var/share = get_flare_share(receiver, hole)
	SEND_SIGNAL(receiver, COMSIG_SEX_GENERIC_ACTION, receiver, 2 * share, 4 * (1 - share), share, action_user)
	playsound(receiver, pick('modular_rmh/sound/erp/pop_wet1.ogg', 'modular_rmh/sound/erp/pop_wet2.ogg'), 40, TRUE, -2, ignore_walls = FALSE)
	receiver.visible_message(span_love("The flare catches at [receiver]'s [hole.opening_name] before it pops free."), share >= 0.5 ? span_love("The flare catches at my [hole.opening_name] and pops free, leaving me shivering.") : span_warning("The flare catches at my [hole.opening_name] and tears free with a sting."))

// ---- Knots on toys ----

/// The knot of [toy] pops inside: the passage is felt by fit, then the rider is stuck on it.
/mob/living/carbon/proc/take_toy_knot(obj/item/dildo/toy, datum/orifice/opening, knot_girth, mob/living/performer, force = SEX_FORCE_MID)
	var/share = get_birth_pleasure_share(opening, knot_girth)
	opening.pass_through(knot_girth, force, performer || src)
	opening.play_passage_sound("pass", 45, src)
	if(share >= 0.66)
		visible_message(span_love("[src] sinks all the way down and the knot of \the [toy] pops inside [p_them()] with a lewd squelch!"), span_love("I sink all the way down and the knot pops inside me. Oh gods, it fits."))
	else if(share > 0.33)
		visible_message(span_love("[src] cries out as the knot of \the [toy] forces its way inside [p_them()]!"), span_love("The knot forces its way inside me, stretching me wide. I'm stuck on it."))
	else
		visible_message(span_warning("[src] howls as the knot of \the [toy] is driven in past [p_their()] rim!"), span_warning("The knot rams in past my rim. It's far too big, and now it won't come out."))
	SEND_SIGNAL(src, COMSIG_SEX_GENERIC_ACTION, src, 4 * share, 6 * (1 - share), 2 * share, performer || src)
	toy_voice(share >= 0.66 ? "sexmoanhvy" : (share > 0.33 ? "groan" : "painmoan"), opening)
	hole_shake_hook("knot", 2)
	return !!apply_status_effect(/datum/status_effect/toy_stuck/knot, null, toy, opening.organ?.slot, knot_girth)

// ---- Stuck on a toy ----

/// Sitting on a standing toy and unable to get off it: a knot inside, or bound and left there.
/datum/status_effect/toy_stuck
	id = "toy_stuck"
	duration = -1
	tick_interval = TOY_STUCK_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/toy_stuck
	var/obj/item/dildo/toy
	var/organ_slot
	var/girth = 0
	/// Set while someone works the owner free.
	var/struggling = FALSE
	var/next_tug_time = 0

/datum/status_effect/toy_stuck/on_creation(mob/living/new_owner, duration_override, obj/item/dildo/stuck_toy, stuck_slot, stuck_girth)
	toy = stuck_toy
	organ_slot = stuck_slot
	girth = stuck_girth
	return ..()

/datum/status_effect/toy_stuck/on_apply()
	. = ..()
	if(!. || QDELETED(toy) || !hold_owner())
		return FALSE
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(on_resist))
	RegisterSignals(toy, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), PROC_REF(on_toy_lost))
	return TRUE

/// Ties the owner to the toy; a standing toy pins them to its tile. FALSE when the toy is out of place.
/datum/status_effect/toy_stuck/proc/hold_owner()
	var/datum/component/toy_mount/mount = toy.get_toy_mount()
	if(!mount || get_turf(toy) != get_turf(owner))
		return FALSE
	mount.set_rider(owner)
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	return TRUE

/// Undoes hold_owner() once the owner is free.
/datum/status_effect/toy_stuck/proc/release_owner()
	toy.last_ridden = world.time
	var/datum/component/toy_mount/mount = toy.get_toy_mount()
	if(mount?.rider == owner)
		mount.set_rider(null)

/datum/status_effect/toy_stuck/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_RESIST))
	if(toy)
		UnregisterSignal(toy, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
		release_owner()
	toy = null
	return ..()

/datum/status_effect/toy_stuck/proc/get_opening()
	RETURN_TYPE(/datum/orifice)
	var/obj/item/organ/genitals/filling_organ/hole = owner?.getorganslot(organ_slot)
	return istype(hole) ? hole.get_orifice(FALSE) : null

/datum/status_effect/toy_stuck/tick()
	var/datum/orifice/opening = get_opening()
	opening?.stretch_toward(girth, SEX_FORCE_LOW, 0.2)
	SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, 1.5, 0.5, 0.6, owner)
	if(prob(50))
		show_squirm_line()

/datum/status_effect/toy_stuck/proc/show_squirm_line()
	owner.visible_message(span_love("[owner] squirms on \the [toy], stuck fast on it."), span_love("I squirm on \the [toy]; every wriggle shifts it inside me."))

/// Stuck mobs cannot walk off the toy; trying tugs at whatever holds them.
/datum/status_effect/toy_stuck/proc/on_pre_move(datum/source, atom/newloc)
	SIGNAL_HANDLER
	if(newloc == get_turf(owner))
		return NONE
	if(world.time >= next_tug_time)
		next_tug_time = world.time + 2 SECONDS
		INVOKE_ASYNC(src, PROC_REF(tug))
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/status_effect/toy_stuck/proc/tug()
	to_chat(owner, span_warning("I try to rise, but \the [toy] holds me down on it. I have to work myself free first."))
	SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, 1, 2, 0.3, owner)

/// Carried or thrown off the toy all at once: it is yanked out.
/datum/status_effect/toy_stuck/proc/on_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	if(QDELETED(toy) || get_turf(owner) == get_turf(toy))
		return
	INVOKE_ASYNC(src, PROC_REF(free), TRUE, null)

/datum/status_effect/toy_stuck/proc/on_toy_lost(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/toy_stuck/proc/on_resist(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_free), owner)

/// A timed try to get the owner off the toy, by themself or by a helper.
/datum/status_effect/toy_stuck/proc/try_free(mob/living/helper)
	if(struggling || QDELETED(src) || !helper)
		return FALSE
	struggling = TRUE
	show_free_start(helper)
	var/done = do_after(helper, TOY_FREE_TIME, owner, IGNORE_USER_DOING | IGNORE_HELD_ITEM)
	if(QDELETED(src))
		return FALSE
	struggling = FALSE
	if(!done)
		return FALSE
	return roll_free(helper)

/datum/status_effect/toy_stuck/proc/show_free_start(mob/living/helper)
	if(helper == owner)
		owner.visible_message(span_notice("[owner] braces and tries to work [owner.p_them()]self off \the [toy]..."), span_notice("I brace myself and try to work free of \the [toy]..."))
	else
		helper.visible_message(span_notice("[helper] takes hold of [owner] and tries to lift [owner.p_them()] off \the [toy]..."), span_notice("I take hold of [owner] and try to lift [owner.p_them()] off \the [toy]..."))

/datum/status_effect/toy_stuck/proc/get_free_chance(mob/living/helper)
	. = 40 + (helper.get_stat_level(STATKEY_STR) - 10) * 6
	if(helper != owner)
		. += 25
	switch(get_opening()?.get_lube_id())
		if("slick")
			. += 25
		if("damp")
			. += 10
	. = clamp(., 5, 95)

/// One roll to get free; a miss costs a little pain.
/datum/status_effect/toy_stuck/proc/roll_free(mob/living/helper)
	if(QDELETED(src) || !helper)
		return FALSE
	if(helper == owner)
		owner.adjust_stamina(TOY_FREE_STAMINA)
	if(!prob(get_free_chance(helper)))
		show_free_fail(helper)
		SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, 0.5, 3, 0, helper)
		return FALSE
	free(helper != owner, helper)
	return TRUE

/datum/status_effect/toy_stuck/proc/show_free_fail(mob/living/helper)
	owner.visible_message(span_warning("[owner] stays stuck fast on \the [toy]."), span_warning("It won't let go of me yet."))

/// Gets the owner off the toy; yanked frees cost more.
/datum/status_effect/toy_stuck/proc/free(yanked, mob/living/helper)
	if(QDELETED(src))
		return
	var/datum/orifice/opening = get_opening()
	owner.visible_message(span_love("[owner] slides up off \the [toy] at last."), span_love("I slide up off \the [toy] at last."))
	opening?.play_passage_sound("withdraw", 40, owner)
	qdel(src)

/datum/status_effect/toy_stuck/knot
	alert_type = /atom/movable/screen/alert/status_effect/toy_stuck/knot
	/// World time the knot slips out by itself.
	var/slip_time = 0

/datum/status_effect/toy_stuck/knot/on_apply()
	. = ..()
	if(!.)
		return
	var/datum/orifice/opening = get_opening()
	var/wait = 70 SECONDS
	switch(opening?.get_lube_id())
		if("slick")
			wait = 30 SECONDS
		if("damp")
			wait = 50 SECONDS
	slip_time = world.time + wait
	var/obj/item/organ/hole = owner.getorganslot(organ_slot)
	if(hole)
		ADD_TRAIT(hole, TRAIT_PASSIVE_LEAK_BLOCKED, REF(src))

/datum/status_effect/toy_stuck/knot/on_remove()
	var/obj/item/organ/hole = owner?.getorganslot(organ_slot)
	if(hole)
		REMOVE_TRAIT(hole, TRAIT_PASSIVE_LEAK_BLOCKED, REF(src))
	return ..()

/datum/status_effect/toy_stuck/knot/tick()
	if(world.time >= slip_time)
		free(FALSE, null)
		return
	return ..()

/datum/status_effect/toy_stuck/knot/show_squirm_line()
	owner.visible_message(span_love("[owner] rocks on \the [toy], the knot locked inside [owner.p_them()]."), span_love(pick("The knot tugs at my rim every time I shift.", "I'm locked on it. Every wriggle grinds the knot deeper.", "Everything stays in; the knot plugs me up tight.")))

/datum/status_effect/toy_stuck/knot/show_free_fail(mob/living/helper)
	owner.visible_message(span_warning("The knot of \the [toy] holds; [owner] stays locked on it."), span_warning("I pull, but the knot holds fast and tugs at my rim."))

/datum/status_effect/toy_stuck/knot/free(yanked, mob/living/helper)
	if(QDELETED(src))
		return
	var/datum/orifice/opening = get_opening()
	var/share = 0.5
	if(opening && iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		share = carbon_owner.get_birth_pleasure_share(opening, girth)
	opening?.pass_through(girth, yanked ? SEX_FORCE_HIGH : SEX_FORCE_LOW, helper || owner)
	opening?.play_passage_sound("pass", 45, owner)
	if(!yanked)
		owner.visible_message(span_love("The knot of \the [toy] finally slips free of [owner] with a wet pop."), span_love("The knot finally slips free of me with a wet pop."))
	else if(share >= 0.5)
		owner.visible_message(span_love("The knot of \the [toy] pops out of [owner] as [owner.p_theyre()] pulled free!"), span_love("The knot pops out of me in one shuddering rush."))
	else
		owner.visible_message(span_warning("The knot of \the [toy] is wrenched out of [owner]!"), span_warning("The knot is wrenched out of me. It burns!"))
	SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, 3 * share, (yanked ? 6 : 2) * (1 - share), 1.5 * share, helper || owner)
	qdel(src)

/datum/status_effect/toy_stuck/impaled

/datum/status_effect/toy_stuck/impaled/tick()
	if(!owner.handcuffed && !owner.legcuffed && !HAS_TRAIT(owner, TRAIT_RESTRAINED))
		owner.visible_message(span_love("With [owner.p_their()] limbs free again, [owner] climbs off \the [toy]."), span_love("Free to move again, I climb off \the [toy]."))
		free(FALSE, null)
		return
	return ..()

/datum/status_effect/toy_stuck/impaled/show_squirm_line()
	if(owner.is_blind() && prob(50))
		owner.visible_message(span_love("[owner] squirms blindly on \the [toy], bound and impaled."), span_love(pick("I can't see who is watching me squirm on it.", "Blind and bound, all I know is the toy inside me.")))
		return
	owner.visible_message(span_love("[owner] squirms on \the [toy], bound and unable to rise off it."), span_love(pick("Every wriggle sinks it deeper. I can't get up.", "Bound like this, all I can do is sit on it.", "My own weight keeps me impaled on it.")))

/datum/status_effect/toy_stuck/impaled/get_free_chance(mob/living/helper)
	. = ..()
	if(helper == owner)
		. = max(5, . - 20)

/atom/movable/screen/alert/status_effect/toy_stuck
	name = "Stuck on a toy"
	desc = "I can't get off it. Resist or click here to work myself free."
	icon_state = "debuff"
	overlay_icon = 'modular_rmh/icons/hud/toy_alerts.dmi'
	overlay_state = "toy_impaled"

/atom/movable/screen/alert/status_effect/toy_stuck/knot
	name = "Knotted on a toy"
	desc = "The knot is locked inside me. Wait for it to slip free, or resist or click here to pull."
	overlay_state = "toy_knotted"

/atom/movable/screen/alert/status_effect/toy_stuck/Click(location, control, params)
	if(usr != mob_viewer)
		return
	var/datum/status_effect/toy_stuck/stuck = attached_effect
	if(istype(stuck))
		INVOKE_ASYNC(stuck, TYPE_PROC_REF(/datum/status_effect/toy_stuck, try_free), mob_viewer)

// ---- Grinding ----

/// Rub along a standing toy without taking it; a wet pussy slicks it for the ride.
/datum/sex_action/toy_grind
	name = "Straddle toy"
	description = "Rub yourself along a standing toy without taking it in; your wetness slicks it."
	do_time = 3 SECONDS
	stamina_cost = 0.3
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/// The pussy to grind with, or null to grind with the ass.
/datum/sex_action/toy_grind/proc/get_slit(mob/living/user)
	return get_free_organ(user, ORGAN_SLOT_VAGINA)

/datum/sex_action/toy_grind/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA) && !user.getorganslot(ORGAN_SLOT_ANUS))
		return FALSE
	return !!user.get_free_standing_toy()

/datum/sex_action/toy_grind/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || user.body_position == LYING_DOWN || !user.get_free_standing_toy())
		return FALSE
	return check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE)

/datum/sex_action/toy_grind/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return user.body_position != LYING_DOWN && !!user.get_free_standing_toy()

/datum/sex_action/toy_grind/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo/toy = user.get_free_standing_toy()
	if(get_slit(user))
		user.visible_message(span_love("[user] straddles \the [toy] and presses [user.p_their()] slit against its side."), span_love("I straddle \the [toy] and press my slit against it."))
	else
		user.visible_message(span_love("[user] settles \the [toy] between [user.p_their()] cheeks and starts to grind."), span_love("I settle \the [toy] between my cheeks and start to grind."))

/datum/sex_action/toy_grind/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo/toy = user.get_free_standing_toy()
	if(!toy)
		return
	var/obj/item/organ/genitals/filling_organ/vagina = get_slit(user)
	if(can_show_action_message(user, target))
		if(vagina)
			user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] slit along \the [toy], smearing it with [user.p_their()] wetness."), spanify_force("I grind my slit along \the [toy], smearing it with my wetness."))
		else
			user.visible_message(spanify_force("[user] [get_generic_force_adjective()] slides the cleft of [user.p_their()] ass along \the [toy], teasing [user.p_them()]self with it."), spanify_force("I slide my cleft along \the [toy], teasing myself with it."))
	if(vagina?.reagents)
		var/datum/reagents/coat = toy.get_lube_reagents(TRUE)
		var/room = coat.maximum_volume - coat.total_volume
		if(room > 0)
			vagina.reagents.trans_id_to(coat, /datum/reagent/consumable/femcum, min(0.5, room))
	playsound(user, pick('modular_rmh/sound/erp/grind1.ogg', 'modular_rmh/sound/erp/grind2.ogg'), sex_volume * 0.6, TRUE, -2, ignore_walls = FALSE)
	var/list/timing = get_motion_steps(1)
	sex_motion_nudge(user, 0, -1, timing[1], timing[2])
	perform_sex_action(user, user, 1.6, 0, 0.9)
	handle_passive_ejaculation()

/datum/sex_action/toy_grind/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo/toy = user.get_free_standing_toy()
	if(toy)
		user.visible_message(span_love("[user] lifts away from \the [toy], leaving it glistening."), span_love("I lift away from \the [toy]; it glistens now."))

// ---- Sucking it wet ----

/// Slobber over a standing toy until it shines; the forced twin pushes someone else's mouth onto it.
/datum/sex_action/toy_suck
	name = "Suck toy"
	description = "Kneel and slobber over a standing toy until it shines."
	do_time = 3 SECONDS
	stamina_cost = 0.2
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	var/forced = FALSE

/datum/sex_action/toy_suck/proc/get_sucker(mob/living/user, mob/living/target)
	return forced ? target : user

/datum/sex_action/toy_suck/proc/get_toy(mob/living/user, mob/living/target)
	RETURN_TYPE(/obj/item/dildo)
	var/mob/living/sucker = get_sucker(user, target)
	return sucker?.get_reachable_standing_toy()

/datum/sex_action/toy_suck/shows_on_menu(mob/living/user, mob/living/target)
	if(forced == (user == target))
		return FALSE
	return !!get_toy(user, target)

/datum/sex_action/toy_suck/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || forced == (user == target))
		return FALSE
	var/mob/living/sucker = get_sucker(user, target)
	return sucker.mouth_is_free(action_user || user) && !!get_toy(user, target)

/datum/sex_action/toy_suck/can_continue(mob/living/user, mob/living/target)
	. = ..()
	return . && !!get_toy(user, target)

/datum/sex_action/toy_suck/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo/toy = get_toy(user, target)
	if(forced)
		user.visible_message(span_warning("[user] grabs [target] by the hair and pushes [target.p_their()] mouth down onto \the [toy]."), span_warning("I push [target]'s mouth down onto \the [toy]."))
	else
		user.visible_message(span_love("[user] kneels by \the [toy] and wraps [user.p_their()] lips around it."), span_love("I kneel by \the [toy] and wrap my lips around it."))

/datum/sex_action/toy_suck/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/sucker = get_sucker(user, target)
	var/obj/item/dildo/toy = get_toy(user, target)
	if(!toy)
		return
	var/datum/reagents/coat = toy.get_lube_reagents(TRUE)
	var/room = coat.maximum_volume - coat.total_volume
	if(room > 0)
		coat.add_reagent(/datum/reagent/consumable/saliva, min(1, room))
	var/choking = toy.get_insert_girth() >= TOY_BIG_GIRTH && force >= SEX_FORCE_HIGH
	if(can_show_action_message(user, target))
		if(forced)
			user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [target]'s head up and down on \the [toy], making [target.p_them()] slobber all over it."), spanify_force("I work [target]'s head up and down on \the [toy]."))
		else
			user.visible_message(spanify_force("[user] [get_generic_force_adjective()] bobs [user.p_their()] head on \the [toy], slobbering it slick."), spanify_force("I bob my head on \the [toy], slobbering it slick."))
	if(choking && prob(40))
		sucker.make_mouth_noise("gag", 35)
		sucker.visible_message(span_warning("[sucker] gags as \the [toy] hits the back of [sucker.p_their()] throat."), span_warning("I gag on \the [toy]!"))
		if(forced)
			perform_deepthroat_oxyloss(sucker, 2)
	else
		sucker.make_mouth_noise(force >= SEX_FORCE_HIGH ? "slurp" : "suck", 25)
	if(forced)
		perform_sex_action(target, user, 0.3, choking ? 2 : 0, 0.1)
		perform_sex_action(user, target, user.has_kink(KINK_DOMINATION) ? 1 : 0.5, 0, 0.3)
	else
		perform_sex_action(user, user, 0.5, 0, 0.2)

/datum/sex_action/toy_suck/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/sucker = get_sucker(user, target)
	var/obj/item/dildo/toy = get_toy(user, target)
	if(toy && sucker)
		sucker.visible_message(span_love("[sucker] pulls off \the [toy], leaving it shiny with spit."), span_love("I pull off \the [toy], leaving it shiny with spit."))

/datum/sex_action/toy_suck/forced
	name = "Force suck"
	description = "Push their mouth down onto a standing toy and get it wet for them."
	forced = TRUE
	require_grab = TRUE
	required_grab_state = GRAB_PASSIVE
	gags_target = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS

// ---- Sitting down on a plug ----

/// Sit down on a standing plug and rise with it seated inside, by the holes window's own rules.
/datum/sex_action/toy_seat_plug
	abstract_type = /datum/sex_action/toy_seat_plug
	name = "Seat plug"
	continous = FALSE
	do_time = 3 SECONDS
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	creaks_furniture = FALSE
	var/organ_slot = ORGAN_SLOT_ANUS

/datum/sex_action/toy_seat_plug/proc/get_plug(mob/living/user)
	RETURN_TYPE(/obj/item/dildo/plug)
	for(var/obj/item/dildo/plug/plug in get_standing_toys(get_turf(user)))
		var/datum/component/toy_mount/mount = plug.get_toy_mount()
		if(!mount.rider || mount.rider == user)
			return plug
	return null

/datum/sex_action/toy_seat_plug/proc/get_block_reason(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	var/obj/item/dildo/plug/plug = get_plug(user)
	var/obj/item/organ/genitals/filling_organ/hole = human_user.get_toy_hole(organ_slot)
	if(!plug || !istype(hole))
		return "There is no plug here to sit on."
	return human_user.get_hole_toy_block_reason(hole) || human_user.get_toy_insert_block_reason(hole, plug)

/datum/sex_action/toy_seat_plug/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && ishuman(user) && user.getorganslot(organ_slot) && !!get_plug(user)

/datum/sex_action/toy_seat_plug/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || !ishuman(user) || user.body_position == LYING_DOWN)
		return FALSE
	return !get_block_reason(user)

/datum/sex_action/toy_seat_plug/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/human/human_user = user
	var/obj/item/dildo/plug/plug = get_plug(user)
	var/obj/item/organ/genitals/filling_organ/hole = human_user.get_toy_hole(organ_slot)
	if(!plug || !istype(hole))
		return FALSE
	do_time = hole.get_toy_insert_time(plug)
	user.visible_message(span_love("[user] squats over \the [plug] and starts lowering [user.p_them()]self onto it..."), span_love("I squat over \the [plug] and start lowering myself onto it..."))
	play_toy_reach_sound(hole, user, 40)

/datum/sex_action/toy_seat_plug/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/human/human_user = user
	var/obj/item/dildo/plug/plug = get_plug(user)
	var/obj/item/organ/genitals/filling_organ/hole = human_user.get_toy_hole(organ_slot)
	var/reason = get_block_reason(user)
	if(reason)
		to_chat(user, span_warning(reason))
		return
	var/hole_word = hole.get_orifice()?.opening_name || pick(hole.altnames)
	var/feel = hole.get_hole_feel("insert")
	SEND_SIGNAL(user, COMSIG_SEX_HOLE_BEFORE_INSERT, plug, hole.slot, user)
	user.adjust_stamina(TOY_SEAT_STAMINA)
	if(hole.roll_toy_insert_slip(plug))
		user.visible_message(span_warning("[user] wobbles and \the [plug] skids off [user.p_their()] [hole_word]."), span_warning("\The [plug] skids off my [hole_word]. It wants a slicker hole, or a gentler angle."))
		return
	switch(SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_TRY_INSERT, plug, STORAGE_LAYER_INNER, FALSE))
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			SEND_SIGNAL(user, COMSIG_SEX_HOLE_AFTER_INSERT, plug, hole.slot, user)
			user.hole_shake_hook("insert", 1)
			user.visible_message(span_love("[user] sits down on \the [plug] and rises with it seated snugly in [user.p_their()] [hole_word]."), span_love("I sit down on \the [plug] and rise with it seated snugly in my [hole_word][feel]."))
			SEND_SIGNAL(user, COMSIG_SEX_GENERIC_ACTION, user, plug.get_body_storage_stir_pleasure(STORAGE_LAYER_INNER) * 2, 0, 0.5, user)
			return
	to_chat(user, span_warning("\The [plug] will not go in after all."))

/datum/sex_action/toy_seat_plug/anus
	name = "Plug ass"
	description = "Sit down on a standing plug and rise with it seated in your ass."
	organ_slot = ORGAN_SLOT_ANUS

/datum/sex_action/toy_seat_plug/vagina
	name = "Plug pussy"
	description = "Sit down on a standing plug and rise with it seated in your pussy."
	organ_slot = ORGAN_SLOT_VAGINA

#undef RIDE_CLIMAX_COAT
#undef BED_CREAK_VOLUME
#undef BED_CREAK_VOLUME_EXTREME
#undef FLARE_GIRTH_MULT
#undef FLARE_DRAG_MESSAGE_CHANCE
#undef TOY_STUCK_TICK
#undef TOY_FREE_TIME
#undef TOY_FREE_STAMINA
#undef TOY_SEAT_STAMINA
#undef TOY_BIG_GIRTH
