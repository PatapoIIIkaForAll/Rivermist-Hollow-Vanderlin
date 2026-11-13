// Draughts and salves that change how tight an opening rests, stretches and recovers.

/// Units of a draught in the blood and stomach needed before it takes effect.
#define ORIFICE_POTION_DOSE 4
/// How long Gaper's Gall holds each opening gaping.
#define GAPERS_GALL_LOCK_TIME (10 MINUTES)

/// Takes effect once a dose is in the body, then the rest of it is used up.
/datum/reagent/orifice_potion
	abstract_type = /datum/reagent/orifice_potion
	name = "Tightness Draught"
	description = "A draught that meddles with how the body's openings rest and stretch."
	reagent_state = LIQUID
	metabolization_rate = REAGENTS_METABOLISM
	/// Status effect applied when the dose takes effect.
	var/datum/status_effect/applied_effect
	/// Set when the dose is spent, so it cannot fire twice.
	var/used_up = FALSE

/datum/reagent/orifice_potion/on_mob_life(mob/living/carbon/M, efficiency)
	if(!used_up && get_dose_volume(M) >= ORIFICE_POTION_DOSE)
		used_up = TRUE
		take_effect(M)
		purge_from_body(M)
	return ..()

/// A dose from someone else is refused at once when the drinker's preference forbids it.
/datum/reagent/orifice_potion/on_transfer(atom/A, method = TOUCH, trans_volume, mob/transfered_by = null)
	. = ..()
	var/mob/living/drinker = get_body_of(A)
	if(!drinker)
		return
	var/mob/living/giver = isliving(transfered_by) ? transfered_by : get_body_of(holder?.my_atom)
	if(drinker.accepts_tightness_potion_from(giver))
		return
	A.reagents?.remove_reagent(type, trans_volume)
	to_chat(drinker, span_warning("My body shrugs off the draught."))

/// Only a swallowed draught works; vapour carries no dose, so nobody is dosed unseen.
/datum/reagent/orifice_potion/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, target_zone = null)
	return

/// The living body an atom belongs to: the mob itself, or the owner of its organ.
/datum/reagent/orifice_potion/proc/get_body_of(atom/target)
	if(isliving(target))
		return target
	if(istype(target, /obj/item/organ))
		var/obj/item/organ/organ = target
		return organ.owner
	return null

/// Units in the blood and stomachs together, so a dose still digesting counts.
/datum/reagent/orifice_potion/proc/get_dose_volume(mob/living/drinker)
	. = drinker.reagents?.get_reagent_amount(type) || 0
	for(var/obj/item/organ/stomach/stomach in drinker.getorganslotlist(ORGAN_SLOT_STOMACH))
		. += stomach.reagents?.get_reagent_amount(type) || 0

/// Removes the draught from stomach and blood, so leftovers cannot trigger it again.
/datum/reagent/orifice_potion/proc/purge_from_body(mob/living/drinker)
	for(var/obj/item/organ/stomach/stomach in drinker.getorganslotlist(ORGAN_SLOT_STOMACH))
		stomach.reagents?.del_reagent(type)
	drinker.reagents?.del_reagent(type)

/datum/reagent/orifice_potion/proc/take_effect(mob/living/drinker)
	drinker.apply_status_effect(applied_effect)

/datum/reagent/orifice_potion/yielding
	name = "Yielding Draught"
	description = "A relaxing draught that leaves the body's openings resting a step looser for a while."
	color = "#e8a0b4"
	taste_description = "warm honey and chamomile"
	scent_description = "chamomile"
	applied_effect = /datum/status_effect/buff/orifice_potion/yielding

/datum/reagent/orifice_potion/maidens_knot
	name = "Maiden's Knot"
	description = "An astringent draught that draws the body's openings a step tighter, ends a gape and helps stretched flesh spring back."
	color = "#a8c8a0"
	taste_description = "sharp sage and green bark"
	scent_description = "sage"
	applied_effect = /datum/status_effect/buff/orifice_potion/maidens_knot

/datum/reagent/orifice_potion/limber_draught
	name = "Limber Draught"
	description = "A draught that makes the flesh of the body's openings supple, so they stretch further and more easily."
	color = "#c8eef7"
	taste_description = "mint and milky sap"
	scent_description = "mint"
	applied_effect = /datum/status_effect/buff/orifice_potion/limber

/datum/reagent/orifice_potion/wanton
	name = "Draught of the Wanton"
	description = "A potent draught that leaves the body's openings resting a step looser for good."
	color = "#c2185b"
	taste_description = "spiced wine and musk"
	scent_description = "musk"
	applied_effect = /datum/status_effect/buff/orifice_potion/yielding/wanton

/datum/reagent/orifice_potion/maiden
	name = "Draught of the Maiden"
	description = "A potent draught that knots the body's openings a step tighter for good."
	color = "#e0f2f1"
	taste_description = "cold spring water and white petals"
	scent_description = "white petals"
	applied_effect = /datum/status_effect/buff/orifice_potion/maidens_knot/maiden

/// Forces every opening to gape and holds each open for a while.
/datum/reagent/orifice_potion/gapers_gall
	name = "Gaper's Gall"
	description = "A bitter prank draught that makes the body's openings give way and holds them gaping for a while."
	color = "#6b8e23"
	taste_description = "bitter bile"
	scent_description = "bile"

/datum/reagent/orifice_potion/gapers_gall/take_effect(mob/living/drinker)
	var/list/holes = drinker.get_orifices(TRUE)
	if(!length(holes))
		return
	to_chat(drinker, span_boldwarning("A bitter heat floods my loins, and everything down there gives way!"))
	for(var/datum/orifice/hole as anything in holes)
		hole.force_gape(GAPERS_GALL_LOCK_TIME)

/// Worked in like balm; while it sits inside, the opening recovers fast and soreness fades.
/datum/reagent/lubricant/rosewater
	name = "Rosewater Salve"
	description = "A soft rose salve worked in like balm. While it lingers, stretched flesh closes up fast and soreness fades."
	color = "#f7c6d0"
	taste_description = "rose petals and oil"
	scent_description = "roses"
	lubricity = 0.6
	/// Set once this application has soothed the opening it sits in.
	var/soothed = FALSE

/// Arriving in an opening soothes it at once; reads of the opening catch arrivals without data.
/datum/reagent/lubricant/rosewater/on_new(list/incoming_data)
	. = ..()
	var/obj/item/organ/genitals/filling_organ/hole = holder?.my_atom
	if(istype(hole) && hole.orifice_type)
		hole.get_orifice(FALSE)?.update_salve_soothing()

/// Adds an orifice modifier for the duration, sourced by its own id; a new dose replaces the old.
/datum/status_effect/buff/orifice_potion
	id = "orifice_potion"
	duration = 20 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/buff/orifice_potion
	var/datum/orifice_modifier/modifier_type
	/// Line the drinker reads as the draught takes hold.
	var/apply_message

/datum/status_effect/buff/orifice_potion/on_apply()
	. = ..()
	owner.add_orifice_modifier(modifier_type, id)
	if(apply_message)
		to_chat(owner, span_love(apply_message))

/datum/status_effect/buff/orifice_potion/on_remove()
	owner.remove_orifice_modifier(modifier_type, id)
	return ..()

/datum/status_effect/buff/orifice_potion/yielding
	id = "orifice_yielding"
	modifier_type = /datum/orifice_modifier/yielding
	alert_type = /atom/movable/screen/alert/status_effect/buff/orifice_potion/yielding
	apply_message = "A warm looseness spreads through my loins."

/// Shares the Yielding modifier, so the two never stack.
/datum/status_effect/buff/orifice_potion/yielding/wanton
	id = "orifice_wanton"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/buff/orifice_potion/wanton
	apply_message = "A deep looseness settles into my loins. It will not wear off."

/datum/status_effect/buff/orifice_potion/maidens_knot
	id = "orifice_maidens_knot"
	modifier_type = /datum/orifice_modifier/maidens_knot
	alert_type = /atom/movable/screen/alert/status_effect/buff/orifice_potion/maidens_knot
	apply_message = "My loins draw tight as a knotted cord."

/datum/status_effect/buff/orifice_potion/maidens_knot/on_apply()
	. = ..()
	for(var/datum/orifice/hole as anything in owner.get_orifices())
		hole.clench_down()

/// Shares the Maiden's Knot modifier, so the two never stack.
/datum/status_effect/buff/orifice_potion/maidens_knot/maiden
	id = "orifice_maiden"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/buff/orifice_potion/maiden
	apply_message = "My loins knot tight as a maiden's, and they will stay that way."

/datum/status_effect/buff/orifice_potion/limber
	id = "orifice_limber"
	modifier_type = /datum/orifice_modifier/limber
	alert_type = /atom/movable/screen/alert/status_effect/buff/orifice_potion/limber
	apply_message = "My flesh down there turns soft and supple."

/// Holds one opening's gape open, whatever its girth, until it runs out.
/datum/status_effect/debuff/orifice_gape_lock
	id = "orifice_gape_lock"
	duration = 10 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/debuff/orifice_gape_lock
	var/datum/orifice_modifier/modifier_type
	var/organ_slot

/datum/status_effect/debuff/orifice_gape_lock/vagina
	id = "orifice_gape_lock_vagina"
	modifier_type = /datum/orifice_modifier/gape_lock/vagina
	organ_slot = ORGAN_SLOT_VAGINA

/datum/status_effect/debuff/orifice_gape_lock/anus
	id = "orifice_gape_lock_anus"
	modifier_type = /datum/orifice_modifier/gape_lock/anus
	organ_slot = ORGAN_SLOT_ANUS

/datum/status_effect/debuff/orifice_gape_lock/on_apply()
	. = ..()
	owner.add_orifice_modifier(modifier_type, id)

/datum/status_effect/debuff/orifice_gape_lock/on_remove()
	owner.remove_orifice_modifier(modifier_type, id)
	// With the hold gone, a hole that has already closed up stops gaping now.
	var/obj/item/organ/genitals/filling_organ/hole = owner.getorganslot(organ_slot)
	if(istype(hole))
		hole.get_orifice(FALSE)?.get_current_girth()
	return ..()

/// A second hold keeps whichever lasts longer.
/datum/status_effect/debuff/orifice_gape_lock/refresh(mob/living/new_owner, duration_override)
	if(duration == -1)
		return
	duration = max(duration, world.time + (isnum(duration_override) ? duration_override : initial(duration)))

// Alerts borrow the spent loins icon until they get their own art.
/atom/movable/screen/alert/status_effect/buff/orifice_potion
	name = "Draught"
	desc = "A draught is working on my holes."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "spent_loins"

/atom/movable/screen/alert/status_effect/buff/orifice_potion/yielding
	name = "Yielding"
	desc = "My holes rest a step looser than usual for a while."

/atom/movable/screen/alert/status_effect/buff/orifice_potion/wanton
	name = "Wanton"
	desc = "My holes rest a step looser than usual, and they will stay that way."

/atom/movable/screen/alert/status_effect/buff/orifice_potion/maidens_knot
	name = "Maiden's Knot"
	desc = "My holes rest a step tighter for a while and spring back twice as fast after a stretch."

/atom/movable/screen/alert/status_effect/buff/orifice_potion/maiden
	name = "Maidenly"
	desc = "My holes rest a step tighter and spring back twice as fast, and they will stay that way."

/atom/movable/screen/alert/status_effect/buff/orifice_potion/limber
	name = "Limber"
	desc = "My holes stretch further and more easily for a while."

/atom/movable/screen/alert/status_effect/debuff/orifice_gape_lock
	name = "Held Open"
	desc = "Something keeps me gaping open. It will not close for a while."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "spent_loins"

#undef ORIFICE_POTION_DOSE
#undef GAPERS_GALL_LOCK_TIME
