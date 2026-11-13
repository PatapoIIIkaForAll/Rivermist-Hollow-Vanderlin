// Riding a standing toy, alone or held down onto it; the stand-in, fit, lube and pressing come from object_fuck.

#define RIDE_DRAG_TIME (2 SECONDS)
#define RIDE_KNOT_CHANCE_HIGH 15
#define RIDE_KNOT_CHANCE_EXTREME 35
#define RIDE_KNOT_CLIMAX_CHANCE 60
/// Chance per extreme cycle that a light chair tips over under its rider.
#define RIDE_TIP_CHANCE 4

/datum/sex_action/object_fuck/ride
	abstract_type = /datum/sex_action/object_fuck/ride
	name = "Toy ride"
	description = "Sink down onto a toy standing on your tile."
	toy_in_hand = FALSE
	requires_free_hands = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	do_time = 3.6 SECONDS
	stamina_cost = 0.5
	/// TRUE when the user holds the target down onto the toy.
	var/forced = FALSE
	/// Furniture this ride buckled its rider to; unbuckled again at the end.
	var/obj/structure/seated_on
	/// TRUE while the rider wears the ride's posture offset.
	var/posture_set = FALSE
	var/ride_cycles = 0
	/// Set when the furniture tipped over and threw the rider off.
	var/tipped = FALSE

/datum/sex_action/object_fuck/ride/Destroy()
	var/mob/living/rider = action_user && action_target ? get_storage_receiver(action_user, action_target) : null
	if(rider)
		unsettle_rider(rider)
		release_toy(rider, selected_toy)
	seated_on = null
	return ..()

/datum/sex_action/object_fuck/ride/get_storage_check_item(mob/living/user, mob/living/target)
	var/mob/living/rider = get_storage_receiver(user, target)
	if(!rider)
		return null
	var/obj/item/dildo/chosen = selected_toy
	if(chosen)
		if(QDELETED(chosen) || !chosen.get_toy_mount() || get_turf(chosen) != get_turf(rider))
			return null
		return chosen
	return find_ride_toy(user, rider)

/// The toy this ride would take: one on the rider's tile, or for a forced ride one beside both of them.
/datum/sex_action/object_fuck/ride/proc/find_ride_toy(mob/living/user, mob/living/rider)
	RETURN_TYPE(/obj/item/dildo)
	. = rider.get_free_standing_toy()
	if(. || !forced)
		return
	for(var/turf/near in orange(1, rider))
		if(get_dist(user, near) > 1)
			continue
		for(var/obj/item/dildo/toy as anything in get_standing_toys(near))
			if(!toy.get_toy_mount().rider)
				return toy

// The toy is the penetrator; nobody's cock feels this fit.
/datum/sex_action/object_fuck/ride/get_orifice_penetrator(mob/living/user, mob/living/target)
	return null

/datum/sex_action/object_fuck/ride/shows_on_menu(mob/living/user, mob/living/target)
	if(forced == (user == target))
		return FALSE
	var/mob/living/rider = get_storage_receiver(user, target)
	if(!rider.getorganslot(hole_id))
		return FALSE
	return !!get_storage_check_item(user, target)

/datum/sex_action/object_fuck/ride/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(forced == (user == target))
		return FALSE
	var/mob/living/rider = get_storage_receiver(user, target)
	if(!rider.getorganslot(hole_id) || rider.body_position == LYING_DOWN)
		return FALSE
	return check_location_accessible(user, rider, BODY_ZONE_PRECISE_GROIN, TRUE)

/datum/sex_action/object_fuck/ride/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/rider = get_storage_receiver(user, target)
	return rider.body_position != LYING_DOWN

/datum/sex_action/object_fuck/ride/get_stamina_cost_multiplier()
	. = ..()
	if(forced)
		return . * 0.6
	var/obj/item/dildo/toy = selected_toy
	switch(toy?.get_toy_mount()?.get_surface_kind())
		if("chair", "stool", "bench")
			return . * 0.6
		if("bed")
			return . * 0.8
	return . * 1.2

/datum/sex_action/object_fuck/ride/lock_sex_object(mob/living/user, mob/living/target)
	var/mob/living/rider = get_storage_receiver(user, target)
	if(rider && hole_id)
		add_sex_lock(rider, hole_id, null, FALSE)
	var/obj/item/dildo/toy = selected_toy
	toy?.get_toy_mount()?.set_rider(rider)

/datum/sex_action/object_fuck/ride/on_start(mob/living/user, mob/living/target)
	var/mob/living/rider = get_storage_receiver(user, target)
	var/obj/item/dildo/toy = get_storage_check_item(user, target)
	if(!toy || !bring_rider_to_toy(user, rider, toy))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	settle_rider(rider)
	if(orifice_pressing)
		return .
	announce_ride_start(user, rider)
	var/obj/item/organ/genitals/filling_organ/hole = rider.getorganslot(hole_id)
	if(istype(hole))
		hole.play_hole_sound("insert", sex_volume, pick('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg'))

/// A forced ride drags its target onto a toy beside them first.
/datum/sex_action/object_fuck/ride/proc/bring_rider_to_toy(mob/living/user, mob/living/rider, obj/item/dildo/toy)
	var/turf/toy_turf = get_turf(toy)
	if(get_turf(rider) == toy_turf)
		return TRUE
	if(!forced)
		return FALSE
	user.visible_message(span_warning("[user] drags [rider] over to \the [toy]..."), span_warning("I drag [rider] over to \the [toy]..."))
	if(!do_after(user, RIDE_DRAG_TIME, rider, IGNORE_USER_DOING | IGNORE_HELD_ITEM) || !is_runtime_active())
		return FALSE
	if(QDELETED(toy) || !toy.get_toy_mount() || get_dist(rider, toy_turf) > 1 || get_dist(user, toy_turf) > 1)
		return FALSE
	rider.forceMove(toy_turf)
	return get_turf(rider) == toy_turf

/// Seats the rider for the surface: buckled on a seat, kneeling on a bed, squatting on the floor.
/datum/sex_action/object_fuck/ride/proc/settle_rider(mob/living/rider)
	var/obj/item/dildo/toy = selected_toy
	var/datum/component/toy_mount/mount = toy?.get_toy_mount()
	if(!mount)
		return
	var/obj/structure/surface = mount.get_surface()
	if(istype(surface, /obj/structure/chair) && !rider.buckled && surface.can_buckle && !surface.has_buckled_mobs())
		mount.seating_rider = TRUE
		if(surface.buckle_mob(rider, check_loc = TRUE))
			seated_on = surface
		mount.seating_rider = FALSE
	var/lift = 0
	switch(mount.get_surface_kind())
		if("floor")
			lift = -2
		if("bed")
			lift = 5
	if(lift)
		rider.set_mob_offsets("toy_ride", _x = 0, _y = lift)
		posture_set = TRUE

/datum/sex_action/object_fuck/ride/proc/unsettle_rider(mob/living/rider)
	if(posture_set)
		rider.reset_offsets("toy_ride")
		posture_set = FALSE
	if(seated_on)
		if(rider.buckled == seated_on)
			seated_on.unbuckle_mob(rider)
		seated_on = null

/// Frees the toy for others unless its rider is still stuck on it.
/datum/sex_action/object_fuck/ride/proc/release_toy(mob/living/rider, obj/item/dildo/toy)
	if(!istype(toy) || QDELETED(toy))
		return
	toy.last_ridden = world.time
	var/datum/component/toy_mount/mount = toy.get_toy_mount()
	if(mount?.rider == rider && !rider.has_status_effect(/datum/status_effect/toy_stuck))
		mount.set_rider(null)

/datum/sex_action/object_fuck/ride/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/rider = get_storage_receiver(user, target)
	var/obj/item/dildo/toy = selected_toy
	if(!istype(toy))
		return
	ride_cycles++
	var/datum/component/toy_mount/mount = toy.get_toy_mount()
	mount?.set_rider(rider)
	var/kind = mount?.get_surface_kind() || "floor"
	var/datum/orifice/opening = get_penetrated_orifice(user, target, FALSE)
	if(can_show_action_message(user, target))
		show_ride_cycle_message(user, rider, toy, opening, kind)
	play_ride_sound(rider, opening, kind)
	if(rider.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(rider)
	ride_bob(user, rider)
	perform_ride_stimulation(user, rider)
	handle_passive_ejaculation(rider)
	try_pop_knot(rider, toy, opening)
	try_tip_furniture(rider, toy)

/datum/sex_action/object_fuck/ride/proc/perform_ride_stimulation(mob/living/user, mob/living/rider)
	if(!forced)
		perform_sex_action(rider, rider, 2.2, 2, 2.6)
		return
	perform_sex_action(rider, user, 2.2, 3, 2.4)
	var/dominant = user.has_kink(KINK_DOMINATION)
	perform_sex_action(user, rider, dominant ? 1.2 : 0.6, 0, dominant ? 0.6 : 0.3)

/// Wet riding squelches, a dry one drags; seats creak under rough riding, floorboards thump.
/datum/sex_action/object_fuck/ride/proc/play_ride_sound(mob/living/rider, datum/orifice/opening, kind)
	var/clip
	if(opening?.sounds_dry())
		clip = pick('modular_rmh/sound/erp/rub_dry1.ogg', 'modular_rmh/sound/erp/rub_dry2.ogg')
	else if(opening?.get_lube_id() == "slick")
		if(force >= SEX_FORCE_HIGH)
			clip = pick('modular_rmh/sound/erp/ride_wet_hard1.ogg', 'modular_rmh/sound/erp/ride_wet_hard2.ogg', 'modular_rmh/sound/erp/ride_wet_hard3.ogg')
		else
			clip = pick('modular_rmh/sound/erp/ride_wet_soft1.ogg', 'modular_rmh/sound/erp/ride_wet_soft2.ogg', 'modular_rmh/sound/erp/ride_wet_soft3.ogg')
	else
		clip = get_force_sound()
	playsound(rider, clip, sex_volume, TRUE, -2, ignore_walls = FALSE)
	if(force < SEX_FORCE_HIGH)
		return
	switch(kind)
		if("floor")
			if(force >= SEX_FORCE_EXTREME && prob(40))
				playsound(rider, pick('modular_rmh/sound/erp/floorboard1.ogg', 'modular_rmh/sound/erp/floorboard2.ogg'), 30, TRUE, -2, ignore_walls = FALSE)
		if("chair", "stool", "bench")
			playsound(rider, get_creak_sound(), 22, TRUE, -2, ignore_walls = FALSE)

/// The rider bobs up and down; a forcer leans into the push.
/datum/sex_action/object_fuck/ride/proc/ride_bob(mob/living/user, mob/living/rider)
	var/static/list/reach_by_force = list(1, 2, 2, 3)
	var/reach = reach_by_force[get_motion_force_index()]
	var/pumps = get_motion_pumps()
	var/list/timing = get_motion_steps(pumps)
	sex_motion_nudge(rider, 0, -reach, timing[1], timing[2], timing[3], pumps)
	if(forced)
		var/list/step = get_sex_motion_step(user, rider)
		sex_motion_nudge(user, step[1], step[2], timing[1], timing[2], timing[3], pumps)

/// A knotted toy may lock its knot in under rough riding, or when the rider comes on it.
/datum/sex_action/object_fuck/ride/proc/try_pop_knot(mob/living/rider, obj/item/dildo/toy, datum/orifice/opening, on_climax = FALSE)
	if(toy.dildo_type != "knotted" || orifice_pressing || !opening || !iscarbon(rider))
		return FALSE
	if(rider.has_status_effect(/datum/status_effect/toy_stuck))
		return FALSE
	var/chance = 0
	if(on_climax)
		chance = RIDE_KNOT_CLIMAX_CHANCE
	else if(force >= SEX_FORCE_EXTREME)
		chance = RIDE_KNOT_CHANCE_EXTREME
	else if(force >= SEX_FORCE_HIGH)
		chance = RIDE_KNOT_CHANCE_HIGH
	if(!prob(chance))
		return FALSE
	var/knot_girth = toy.get_insert_girth() * PENIS_KNOT_GIRTH_MULT
	var/feedback = opening.check_width(knot_girth, force >= SEX_FORCE_HIGH)
	if(feedback != INSERT_FEEDBACK_OK && feedback != INSERT_FEEDBACK_OK_FORCE)
		return FALSE
	var/mob/living/carbon/carbon_rider = rider
	return carbon_rider.take_toy_knot(toy, opening, knot_girth, action_user, force)

/// Riding a light chair too hard tips it over and throws the rider off.
/datum/sex_action/object_fuck/ride/proc/try_tip_furniture(mob/living/rider, obj/item/dildo/toy)
	if(force < SEX_FORCE_EXTREME || !prob(RIDE_TIP_CHANCE) || rider.has_status_effect(/datum/status_effect/toy_stuck))
		return
	var/obj/structure/chair/wood/alt/chair = toy.get_toy_mount()?.get_surface()
	if(!istype(chair) || !chair.item_chair)
		return
	tipped = TRUE
	if(rider.buckled == chair)
		chair.unbuckle_mob(rider, TRUE)
	seated_on = null
	rider.visible_message(span_warning("[rider] rocks so hard that \the [chair] tips over, tumbling [rider.p_them()] off \the [toy] and onto the floor!"), span_warning("I rock so hard that \the [chair] tips over and tumbles me off \the [toy]!"))
	chair.onkick(rider)
	rider.Knockdown(2 SECONDS)
	stop_requested = TRUE

/datum/sex_action/object_fuck/ride/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/obj/item/dildo/toy = selected_toy
	var/mob/living/rider = get_storage_receiver(action_user, action_target)
	if(!istype(toy) || !rider)
		return ORGASM_LOCATION_SELF
	announce_ride_climax(user, rider, toy)
	if(user == rider)
		if(hole_id == ORGAN_SLOT_VAGINA)
			rider.lose_virginity()
		addtimer(CALLBACK(toy, TYPE_PROC_REF(/obj/item/dildo, take_climax_coat), rider), 2)
		try_pop_knot(rider, toy, get_penetrated_orifice(action_user, action_target, FALSE), TRUE)
	return ORGASM_LOCATION_SELF

/datum/sex_action/object_fuck/ride/on_finish(mob/living/user, mob/living/target)
	var/mob/living/rider = get_storage_receiver(user, target)
	var/obj/item/dildo/toy = selected_toy
	var/was_pressing = orifice_pressing
	var/datum/orifice/opening = get_penetrated_orifice(user, target, FALSE)
	var/gaping = opening?.gives_no_resistance()
	var/dry = opening?.sounds_dry()
	var/girth = istype(toy) ? toy.get_insert_girth() : 0
	. = ..()
	unsettle_rider(rider)
	if(!istype(toy))
		return
	if(forced && !was_pressing && !tipped)
		try_leave_seated(user, rider, toy, girth)
	announce_ride_finish(user, rider, toy, was_pressing, opening, gaping, dry)
	release_toy(rider, toy)

/// A bound target is left impaled on the toy when the one holding them down lets go.
/datum/sex_action/object_fuck/ride/proc/try_leave_seated(mob/living/user, mob/living/rider, obj/item/dildo/toy, girth)
	if(!iscarbon(rider) || rider.has_status_effect(/datum/status_effect/toy_stuck))
		return FALSE
	if(!rider.handcuffed && !rider.legcuffed && !HAS_TRAIT(rider, TRAIT_RESTRAINED))
		return FALSE
	if(QDELETED(toy) || !toy.get_toy_mount() || get_turf(toy) != get_turf(rider))
		return FALSE
	return !!rider.apply_status_effect(/datum/status_effect/toy_stuck/impaled, null, toy, hole_id, girth)

// ---- The four rides ----

/datum/sex_action/object_fuck/ride/vagina
	name = "Ride toy"
	description = "Sink your pussy down onto a toy standing on your tile."
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/object_fuck/ride/anus
	name = "Anal ride"
	description = "Ease your ass down onto a toy standing on your tile."
	hole_id = ORGAN_SLOT_ANUS

/datum/sex_action/object_fuck/ride/forced
	abstract_type = /datum/sex_action/object_fuck/ride/forced
	forced = TRUE
	require_grab = TRUE
	required_grab_state = GRAB_PASSIVE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS

/datum/sex_action/object_fuck/ride/forced/vagina
	name = "Impale pussy"
	description = "Hold them and push their pussy down onto a standing toy beside them."
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/object_fuck/ride/forced/anus
	name = "Impale ass"
	description = "Hold them and push their ass down onto a standing toy beside them."
	hole_id = ORGAN_SLOT_ANUS

// ---- Both at once ----

/// Two toys on one tile: one in the pussy, one in the ass.
/datum/sex_action/object_fuck/ride/both
	name = "Double ride"
	description = "Two toys stand side by side: sink down onto both, one in each hole."
	hole_id = ORGAN_SLOT_VAGINA
	stamina_cost = 0.7
	var/obj/item/dildo/second_toy
	var/obj/item/penetration_standin/second_standin
	var/datum/weakref/second_orifice_ref

/datum/sex_action/object_fuck/ride/both/Destroy()
	clear_second_toy()
	return ..()

/datum/sex_action/object_fuck/ride/both/proc/find_second_toy(mob/living/rider)
	RETURN_TYPE(/obj/item/dildo)
	return rider.get_free_standing_toy(selected_toy || rider.get_free_standing_toy())

/datum/sex_action/object_fuck/ride/both/shows_on_menu(mob/living/user, mob/living/target)
	if(!..() || !user.getorganslot(ORGAN_SLOT_ANUS))
		return FALSE
	return !!find_second_toy(user)

/datum/sex_action/object_fuck/ride/both/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/dildo/first = get_storage_check_item(user, target)
	var/obj/item/dildo/second = find_second_toy(user)
	if(!first || !second || !user.getorganslot(ORGAN_SLOT_ANUS))
		return FALSE
	return both_fit(user, first, second)

/// Riding two at once never starts by pressing: both toys must already fit.
/datum/sex_action/object_fuck/ride/both/proc/both_fit(mob/living/rider, obj/item/dildo/first, obj/item/dildo/second)
	var/use_force = force >= SEX_FORCE_HIGH
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		var/obj/item/organ/genitals/filling_organ/hole = rider.getorganslot(slot)
		if(!istype(hole) || rider.is_organ_slot_blocked(slot))
			return FALSE
		var/datum/orifice/opening = hole.get_orifice()
		if(!opening)
			continue
		var/feedback = opening.check_width((slot == ORGAN_SLOT_VAGINA ? first : second).get_insert_girth(), use_force)
		if(feedback != INSERT_FEEDBACK_OK && feedback != INSERT_FEEDBACK_OK_FORCE)
			return FALSE
	return TRUE

/datum/sex_action/object_fuck/ride/both/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(orifice_pressing)
		to_chat(user, span_warning("One of them will not go in; I should take them one at a time."))
		return FALSE
	return take_second_toy(user)

/// Stores a stand-in for the second toy in the ass and opens a penetration there.
/datum/sex_action/object_fuck/ride/both/proc/take_second_toy(mob/living/rider)
	var/obj/item/dildo/second = find_second_toy(rider)
	var/obj/item/organ/genitals/filling_organ/anus = rider.getorganslot(ORGAN_SLOT_ANUS)
	if(!second || !istype(anus))
		return FALSE
	var/obj/item/penetration_standin/standin = new
	standin.standin_girth = second.get_insert_girth()
	standin.body_storage_bulk = max(1, round(standin.standin_girth / ORIFICE_BULK_PER_CM))
	switch(SEND_SIGNAL(anus, COMSIG_BODYSTORAGE_TRY_INSERT, standin, STORAGE_LAYER_INNER, force >= SEX_FORCE_HIGH))
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			second_standin = standin
		else
			qdel(standin)
			to_chat(rider, span_warning("My ass will not take \the [second] right now."))
			return FALSE
	second_toy = second
	second.get_toy_mount().set_rider(rider)
	add_sex_lock(rider, ORGAN_SLOT_ANUS, null, FALSE)
	var/datum/orifice/opening = anus.get_orifice()
	if(opening)
		second_orifice_ref = WEAKREF(opening)
		// Lube transfer reads selected_toy, so point it at the second toy for this entry only.
		var/obj/item/first = selected_toy
		selected_toy = second
		opening.begin_penetration(src, null, standin.standin_girth)
		selected_toy = first
	rider.visible_message(span_love("[rider] settles lower until \the [second] slips into [rider.p_their()] ass as well, filled in both holes at once."), span_love("I settle lower until \the [second] slips into my ass as well. Both holes, stuffed full."))
	return TRUE

/datum/sex_action/object_fuck/ride/both/proc/clear_second_toy()
	var/datum/orifice/opening = second_orifice_ref?.resolve()
	opening?.end_penetration(src)
	second_orifice_ref = null
	if(second_standin)
		var/obj/item/organ/genitals/filling_organ/anus = opening?.organ
		if(anus)
			remove_tracked_item_from_body_storage(anus, second_standin)
		qdel(second_standin)
		second_standin = null
	if(second_toy && !QDELETED(second_toy))
		second_toy.last_ridden = world.time
		var/datum/component/toy_mount/mount = second_toy.get_toy_mount()
		if(mount?.rider && !mount.rider.has_status_effect(/datum/status_effect/toy_stuck))
			mount.set_rider(null)
	second_toy = null

/datum/sex_action/object_fuck/ride/both/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/orifice/opening = second_orifice_ref?.resolve()
	opening?.on_penetration_cycle(src)
	if(second_toy && can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] rides both toys at once, one buried in [user.p_their()] pussy and one in [user.p_their()] ass."), span_love("Both holes stretched at once; every drop fills me twice over."))
	perform_sex_action(user, user, 1.2, 1, 1.2)

/datum/sex_action/object_fuck/ride/both/on_finish(mob/living/user, mob/living/target)
	var/obj/item/dildo/second = second_toy
	clear_second_toy()
	. = ..()
	if(second)
		user.visible_message(span_love("Both toys slide free of [user] with a pair of wet pops."), span_love("Both toys slide free of me with a pair of wet pops."))

// ---- Lube and help ----

/// Slicks a standing toy within reach from a held lube, else with spit.
/datum/sex_action/lube_up/standing_toy
	name = "Lube standing-toy"
	description = "Work a held balm or oil, or spit, over a toy standing beside you."
	target_menu_zone_mask = SEX_UI_ZONE_ARMS
	organ_slot = null

/datum/sex_action/lube_up/standing_toy/has_lube_target(mob/living/user, mob/living/target)
	return !!user.get_reachable_standing_toy()

/datum/sex_action/lube_up/standing_toy/shows_on_menu(mob/living/user, mob/living/target)
	return !!user.get_reachable_standing_toy()

/datum/sex_action/lube_up/standing_toy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo/toy = user.get_reachable_standing_toy()
	if(toy)
		user.lube_up_toy(toy)

/// Lifts someone stuck on a standing toy off it: a knot comes out with a pop.
/datum/sex_action/toy_lift_off
	name = "Lift off"
	description = "Haul someone stuck on a standing toy up off it."
	continous = FALSE
	do_time = 3 SECONDS
	requires_free_hands = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	creaks_furniture = FALSE

/datum/sex_action/toy_lift_off/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && !!target.has_status_effect(/datum/status_effect/toy_stuck)

/datum/sex_action/toy_lift_off/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return user != target && !!target.has_status_effect(/datum/status_effect/toy_stuck)

/datum/sex_action/toy_lift_off/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_notice("[user] takes hold of [target] under the arms and starts lifting..."), span_notice("I take hold of [target] and start lifting [target.p_them()] off the toy..."))

/datum/sex_action/toy_lift_off/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/status_effect/toy_stuck/stuck = target.has_status_effect(/datum/status_effect/toy_stuck)
	stuck?.roll_free(user)

#undef RIDE_DRAG_TIME
#undef RIDE_KNOT_CHANCE_HIGH
#undef RIDE_KNOT_CHANCE_EXTREME
#undef RIDE_KNOT_CLIMAX_CHANCE
#undef RIDE_TIP_CHANCE
