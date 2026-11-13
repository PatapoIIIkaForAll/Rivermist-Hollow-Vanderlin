// Fit and strain shape pleasure and pain for penetration; actions register their girth with the hole.

/// Receiver pleasure multiplier by fit, as x,y pairs.
GLOBAL_LIST_INIT(orifice_receiver_fit_curve, list(0.4, 0.3, 0.6, 0.6, 0.85, 1, 1.15, 1.3, 1.45, 0.9, 1.7, 0.6))
/// Penetrator pleasure multiplier by fit, as x,y pairs.
GLOBAL_LIST_INIT(orifice_penetrator_fit_curve, list(0.4, 0.35, 0.6, 0.6, 0.8, 0.9, 1, 1.15, 1.3, 1.3))
/// Size Queen receiver curve: the peak sits further right and nothing is too big.
GLOBAL_LIST_INIT(orifice_size_queen_fit_curve, list(0.65, 0.3, 0.85, 0.6, 1.1, 1, 1.4, 1.3, 1.7, 1, 2, 1))

/// Linear interpolation over sorted x,y pairs; clamps past either end.
/proc/interpolate_pairs(x, list/pairs)
	var/count = length(pairs)
	if(count < 2)
		return 1
	if(x <= pairs[1])
		return pairs[2]
	for(var/i = 3, i < count, i += 2)
		if(x <= pairs[i])
			var/x0 = pairs[i - 2]
			var/y0 = pairs[i - 1]
			return y0 + (pairs[i + 1] - y0) * (x - x0) / max(pairs[i] - x0, 0.001)
	return pairs[count]

/datum/orifice/proc/get_receiver_fit_multiplier(fit)
	var/mob/living/owner = get_owner()
	. = interpolate_pairs(fit, owner?.has_kink(KINK_SIZE_QUEEN) ? GLOB.orifice_size_queen_fit_curve : GLOB.orifice_receiver_fit_curve)
	// Numbed flesh feels less of everything.
	if(get_numbing_multiplier() < 1)
		. *= 0.8
	switch(get_soreness_state())
		if(ORIFICE_STATE_SORE)
			. *= 0.85
		if(ORIFICE_STATE_RAW)
			. *= 0.6
		if(ORIFICE_STATE_OVERUSED)
			. *= 0.3

/datum/orifice/proc/get_penetrator_fit_multiplier(fit)
	if(gaped)
		return 0.5
	return interpolate_pairs(fit, GLOB.orifice_penetrator_fit_curve)

// ---- The effect ----

/datum/sex_action_effect/orifice_fit
	var/datum/orifice/orifice
	var/mob/living/hole_owner
	var/mob/living/penetrator
	var/girth = 0

/datum/sex_action_effect/orifice_fit/New(datum/orifice/_orifice, datum/orifice_penetration/entry)
	. = ..(null)
	orifice = _orifice
	hole_owner = orifice.get_owner()
	penetrator = entry.penetrator_ref?.resolve()
	girth = orifice.get_combined_girth() || entry.girth

/datum/sex_action_effect/orifice_fit/Destroy(force)
	orifice = null
	hole_owner = null
	penetrator = null
	return ..()

/datum/sex_action_effect/orifice_fit/modify_action(datum/sex_action_effect_context/context)
	if(!orifice || QDELETED(orifice) || !context)
		return
	var/fit = orifice.get_fit(girth)
	if(context.receiver == hole_owner)
		var/mult = orifice.get_receiver_fit_multiplier(fit)
		context.arousal_amt *= mult
		context.orgasm_prog_amt *= mult
		context.pain_amt += orifice.get_capped_cycle_pain(girth, context.pain_amt, context.force, context.speed)
		return
	if(penetrator && context.receiver == penetrator)
		var/mult = orifice.get_penetrator_fit_multiplier(fit)
		if(istype(orifice, /datum/orifice/anus) && orifice.get_lube_level() < LUBE_DRY_LEVEL && !orifice.gaped)
			mult *= 0.9
			context.pain_amt += 4 * penetrator.get_strapon_pain_share()
		context.arousal_amt *= mult
		context.orgasm_prog_amt *= mult

/// The hole itself joins the effect pipeline while something is inside it.
/obj/item/organ/genitals/filling_organ/get_sex_action_effects(datum/sex_action_effect_context/context)
	. = ..()
	if(!orifice || !context?.action)
		return
	var/datum/orifice_penetration/entry = orifice.find_penetration(context.action)
	if(!entry)
		return
	LAZYADD(., new /datum/sex_action_effect/orifice_fit(orifice, entry))

// ---- Action side ----

/datum/sex_action
	/// The orifice this running action registered its penetration with.
	var/datum/weakref/orifice_ref

/// Whoever carries the penis in this action.
/datum/sex_action/proc/get_orifice_penetrator(mob/living/user, mob/living/target)
	if(get_scene_user_slot() == ORGAN_SLOT_PENIS)
		return user
	if(get_scene_target_slot() == ORGAN_SLOT_PENIS)
		return target
	return get_storage_insertor(user, target)

/// Whoever offers the hole in this action.
/datum/sex_action/proc/get_orifice_receiver(mob/living/user, mob/living/target)
	if(hole_id && get_scene_user_slot() == hole_id)
		return user
	if(hole_id && get_scene_target_slot() == hole_id)
		return target
	return get_storage_receiver(user, target)

/datum/sex_action/proc/is_orifice_penetration()
	if(hole_id != ORGAN_SLOT_VAGINA && hole_id != ORGAN_SLOT_ANUS)
		return FALSE
	return requires_hole_storage || get_scene_interaction() == SEX_SCENE_INTERACTION_PENETRATION

/// Girth in centimetres this action pushes into its hole; null when it does not penetrate.
/datum/sex_action/proc/get_penetration_girth(mob/living/user, mob/living/target)
	if(!is_orifice_penetration())
		return null
	var/mob/living/penetrator = get_orifice_penetrator(user, target)
	var/obj/item/organ/genitals/penis/penis = penetrator?.getorganslot(ORGAN_SLOT_PENIS)
	return penis?.get_insert_girth()

/datum/sex_action/object_fuck/get_penetration_girth(mob/living/user, mob/living/target)
	var/obj/item/toy = selected_toy || get_storage_check_item(user, target)
	return toy?.get_insert_girth()

/datum/sex_action/proc/get_penetrated_orifice(mob/living/user, mob/living/target, create = TRUE)
	if(hole_id != ORGAN_SLOT_VAGINA && hole_id != ORGAN_SLOT_ANUS)
		return null
	var/mob/living/receiver = get_orifice_receiver(user, target)
	var/obj/item/organ/genitals/filling_organ/hole = receiver?.getorganslot(hole_id)
	if(!istype(hole))
		return null
	return hole.get_orifice(create)

/datum/sex_action/proc/begin_orifice_penetration(mob/living/user, mob/living/target)
	if(orifice_pressing)
		return
	var/girth = get_penetration_girth(user, target)
	if(!girth)
		return
	var/datum/orifice/hole = get_penetrated_orifice(user, target)
	if(!hole)
		return
	orifice_ref = WEAKREF(hole)
	hole.begin_penetration(src, get_orifice_penetrator(user, target), girth)

/datum/sex_action/proc/on_orifice_cycle()
	var/datum/orifice/hole = orifice_ref?.resolve()
	if(!hole)
		return
	hole.on_penetration_cycle(src)
	apply_flare_drag(hole)

/datum/sex_action/proc/end_orifice_penetration()
	var/datum/orifice/hole = orifice_ref?.resolve()
	// A finished act with something still inside pulls out: a flared head catches on the way.
	if(hole && !orifice_pressing && is_runtime_active() && hole.find_penetration(src))
		flare_pop_out(hole)
	end_orifice_pressing()
	hole?.end_penetration(src)
	orifice_ref = null

// ---- Pressing against an opening that will not take it yet ----

/// Stand-in stored for a toy; it carries the toy's girth into the width check.
/obj/item/penetration_standin
	name = "penetrating object"
	w_class = WEIGHT_CLASS_SMALL
	var/standin_girth = 0

/obj/item/penetration_standin/get_insert_girth()
	return standin_girth || ..()

/obj/item/penetration_standin/can_random_body_storage_layer_swap()
	return FALSE

/// Lets a stand-in copy the girth of what it represents before it is stored.
/obj/item/proc/on_penetration_standin_created(datum/sex_action/action)
	return

/obj/item/penetration_standin/on_penetration_standin_created(datum/sex_action/action)
	standin_girth = action.get_penetration_girth(action.action_user, action.action_target) || 0
	body_storage_bulk = max(1, round(standin_girth / ORIFICE_BULK_PER_CM))

/datum/sex_action
	/// TRUE while the act presses against an opening that will not take it yet.
	var/orifice_pressing = FALSE
	/// Width feedback that kept the entry out, for the pressing lines.
	var/orifice_pressing_feedback

/// What the insertor presses with, for messages.
/datum/sex_action/proc/get_pressing_noun(mob/living/insertor)
	if(stored_item_type == /obj/item/organ/genitals/penis)
		var/obj/item/organ/genitals/penis/penis = insertor?.getorganslot(ORGAN_SLOT_PENIS)
		return "[insertor.p_their()] [penis ? penis.get_hold_word() : "cock"]"
	return "it"

/datum/sex_action/object_fuck/get_pressing_noun(mob/living/insertor)
	var/obj/item/toy = selected_toy || get_storage_check_item(action_user, action_target)
	return toy ? "\the [toy]" : ..()

/// Why the opening will not give, in the receiver's words.
/datum/sex_action/proc/get_pressing_reason(datum/orifice/hole)
	if(hole?.get_soreness_state() >= ORIFICE_STATE_OVERUSED)
		return "it is far too sore"
	if(orifice_pressing_feedback == INSERT_FEEDBACK_TRY_FORCE)
		return "it will not give without more force or something slick"
	return "it is far too big"

/// Entry refused for width: the act goes on as pressing against the opening.
/datum/sex_action/proc/begin_orifice_pressing(mob/living/insertor, mob/living/receiver, feedback)
	orifice_pressing = TRUE
	orifice_pressing_feedback = feedback
	var/datum/orifice/hole = get_penetrated_orifice(action_user, action_target)
	var/opening = hole ? hole.opening_name : "[hole_id]"
	var/what = get_pressing_noun(insertor)
	var/reason = get_pressing_reason(hole)
	if(insertor == receiver)
		insertor.visible_message(span_warning("[insertor] presses [what] against [insertor.p_their()] [opening], but it will not go in."), span_warning("I press [what] against my [opening], but [reason]."))
		return
	insertor.visible_message(span_warning("[insertor] presses [what] against [receiver]'s [opening], but it will not go in."), span_warning("I press [what] against [receiver]'s [opening], but [reason]."), ignored_mobs = list(receiver))
	to_chat(receiver, span_warning("[insertor] presses [what] against my [opening], but [reason]."))

/datum/sex_action/proc/end_orifice_pressing()
	orifice_pressing = FALSE
	orifice_pressing_feedback = null

/// One pressing cycle; TRUE while still outside, FALSE once it slid in and thrusting may start.
/datum/sex_action/proc/run_orifice_press_cycle(mob/living/user, mob/living/target)
	if(!orifice_pressing)
		return FALSE
	var/mob/living/insertor = get_storage_insertor(user, target)
	var/mob/living/receiver = get_storage_receiver(user, target)
	var/datum/orifice/hole = get_penetrated_orifice(user, target)
	var/girth = get_penetration_girth(user, target)
	if(!hole || !girth || !insertor || !receiver)
		end_orifice_pressing()
		return FALSE
	var/use_force = (force >= SEX_FORCE_HIGH)
	var/feedback = hole.check_width(girth, use_force)
	var/whose = receiver == insertor ? insertor.p_their() : "[receiver]'s"
	var/mine = receiver == insertor ? "my" : "[receiver]'s"
	var/what = get_pressing_noun(insertor)
	if(feedback == INSERT_FEEDBACK_OK || feedback == INSERT_FEEDBACK_OK_FORCE)
		// It gives: store the stand-in for real, then thrust from here on.
		end_orifice_pressing()
		if(!try_store_in_hole(insertor, receiver))
			stop_runtime()
			return TRUE
		begin_orifice_penetration(user, target)
		insertor.visible_message(span_love("[insertor] works [what] into [whose] [hole.opening_name] at last."), span_love("I work [what] into [mine] [hole.opening_name] at last."))
		// The entry sound held back while pressing plays now.
		playsound(receiver, pick('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg'), sex_volume, TRUE, ignore_walls = FALSE)
		return FALSE
	orifice_pressing_feedback = feedback
	// Still outside: press, tease and open it a little.
	if(can_show_action_message(user, target))
		insertor.visible_message(spanify_force("[insertor] [get_generic_force_adjective()] grinds [what] against [whose] [hole.opening_name]."), spanify_force("I [get_generic_force_adjective()] grind [what] against [mine] [hole.opening_name]; [get_pressing_reason(hole)]."))
	perform_sex_action(receiver, insertor, 0.8, 0, 0.4)
	// Only a cock feels the grinding; a hand on a toy does not.
	if(insertor != receiver && stored_item_type == /obj/item/organ/genitals/penis)
		perform_sex_action(insertor, receiver, 0.8, 0, 0.4)
	if(girth <= hole.get_max_girth())
		hole.stretch_toward(girth, force, 0.03)
	return TRUE

/// Menu hint for a penetration: how the target hole will take this action right now.
/datum/sex_action/proc/get_orifice_fit_hint(mob/living/user, mob/living/target)
	var/girth = get_penetration_girth(user, target)
	if(!girth)
		return null
	var/datum/orifice/hole = get_penetrated_orifice(user, target, FALSE)
	if(!hole)
		var/mob/living/receiver = get_orifice_receiver(user, target)
		var/obj/item/organ/genitals/filling_organ/organ = receiver?.getorganslot(hole_id)
		if(!istype(organ) || !organ.orifice_type)
			return null
		hole = organ.get_orifice()
	return hole.get_fit_hint(girth)
