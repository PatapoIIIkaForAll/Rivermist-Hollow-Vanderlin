// Status effects and moods for stretched or worn openings.

/// Slip chance in percent per rest girth of spare room around a stored item.
#define GAPE_SLIP_CHANCE_SCALE 35
/// Room an item needs, as a multiple of its girth, before it can slip.
#define GAPE_SLIP_GIRTH_MULT 1.2
#define GAPE_SLIP_CHANCE_MAX 60
/// A plug head at least this share of the opening stays seated.
#define GAPE_PLUG_HOLD_SHARE 0.9
/// Share of held fluid that gushes out when standing up while gaping.
#define GAPE_STAND_GUSH_SHARE 0.5
/// Fit band for the hole owner's climax mood, then the penetrator's tight and loose limits.
#define CLIMAX_FULL_FIT_MIN 1
#define CLIMAX_FULL_FIT_MAX 1.45
#define CLIMAX_TIGHT_FIT_MIN 1
#define CLIMAX_LOOSE_FIT_MAX 0.6

/datum/status_effect/orifice_gaping
	id = "orifice_gaping"
	duration = -1
	tick_interval = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/orifice_gaping
	var/organ_slot

/datum/status_effect/orifice_gaping/vagina
	id = "orifice_gaping_vagina"
	organ_slot = ORGAN_SLOT_VAGINA

/datum/status_effect/orifice_gaping/anus
	id = "orifice_gaping_anus"
	organ_slot = ORGAN_SLOT_ANUS

/// Size queens and masochists enjoy the gape instead of minding it.
/datum/status_effect/orifice_gaping/proc/enjoys_gaping()
	return owner.has_kink(KINK_SIZE_QUEEN) || owner.has_quirk(/datum/quirk/negative/addiction/masochist)

/datum/status_effect/orifice_gaping/on_apply()
	. = ..()
	if(enjoys_gaping())
		owner.add_stress(/datum/stress_event/gaped_loved)
		to_chat(owner, span_love("I am gaping open, and I love it."))
	else
		owner.add_stress(/datum/stress_event/gaped)
		to_chat(owner, span_warning("I am gaping open."))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position_changed))

/datum/status_effect/orifice_gaping/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	// The other opening may still gape and keep the mood.
	if(!owner.has_status_effect(/datum/status_effect/orifice_gaping/vagina) && !owner.has_status_effect(/datum/status_effect/orifice_gaping/anus))
		owner.remove_stress(/datum/stress_event/gaped)
		owner.remove_stress(/datum/stress_event/gaped_loved)
	return ..()

/datum/status_effect/orifice_gaping/tick()
	try_slip_item()

/datum/status_effect/orifice_gaping/proc/on_owner_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	try_slip_item()

/datum/status_effect/orifice_gaping/proc/on_body_position_changed(datum/source, new_position, old_position)
	SIGNAL_HANDLER
	if(new_position == STANDING_UP && old_position == LYING_DOWN)
		gush_held_fluid()

/// Lets at most one stored item slip out of the outermost occupied layer; returns it, or null.
/datum/status_effect/orifice_gaping/proc/try_slip_item()
	var/mob/living/holder = owner
	var/obj/item/organ/genitals/filling_organ/hole = holder?.getorganslot(organ_slot)
	if(!istype(hole) || !hole.orifice?.gaped)
		return null
	var/datum/orifice/orifice = hole.orifice
	var/current = orifice.get_current_girth()
	// Reading the girth can close the gape, which ends this status.
	if(QDELETED(src) || !orifice.gaped)
		return null
	var/list/layers = SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_GET_LISTS)
	if(!islist(layers))
		return null
	var/slip_layer
	for(var/layer in list(STORAGE_LAYER_OUTER, STORAGE_LAYER_INNER))
		if(length(layers[layer]))
			slip_layer = layer
			break
	if(!slip_layer)
		return null
	var/rest = max(orifice.get_rest_girth(), 1)
	for(var/obj/item/stored_item as anything in shuffle(layers[slip_layer]))
		if(QDELETED(stored_item) || istype(stored_item, /obj/item/penis_fake) || !stored_item.can_remove_from_body_storage(BODYSTORAGE_REMOVE_RANDOM))
			continue
		var/girth = stored_item.get_insert_girth()
		if(istype(stored_item, /obj/item/dildo/plug) && girth >= current * GAPE_PLUG_HOLD_SHARE)
			continue
		if(!prob(clamp(GAPE_SLIP_CHANCE_SCALE * (current - GAPE_SLIP_GIRTH_MULT * girth) / rest, 0, GAPE_SLIP_CHANCE_MAX)))
			continue
		if(!SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_TRY_REMOVE, stored_item, slip_layer, BODYSTORAGE_REMOVE_RANDOM))
			continue
		var/turf/landing = get_turf(holder)
		if(landing)
			stored_item.forceMove(landing)
		holder.visible_message(span_love("\The [stored_item] slips out of [holder]'s gaping [orifice.opening_name] and drops to the floor."), span_love("\The [stored_item] slips out of my gaping [orifice.opening_name]!"))
		playsound(holder, pick('modular_rmh/sound/effects/cork_pop.ogg', 'modular_rmh/sound/effects/cork_pop (2).ogg'), 50, TRUE, -2, ignore_walls = FALSE)
		return stored_item
	return null

/// Standing up while gaping lets half of the held fluid run out at once.
/datum/status_effect/orifice_gaping/proc/gush_held_fluid()
	var/obj/item/organ/genitals/filling_organ/hole = owner?.getorganslot(organ_slot)
	if(!istype(hole) || !hole.orifice?.gaped || !hole.reagents?.total_volume)
		return
	// Anything still inside keeps it in, as with Hold It In.
	if(length(hole.contents))
		return
	var/held = hole.reagents.total_volume
	hole.leak_reagents(held * GAPE_STAND_GUSH_SHARE)
	if(hole.reagents.total_volume < held)
		to_chat(owner, span_warning("It gushes out of my gaping [hole.orifice.opening_name] as I stand."))

/// TRUE while the vagina or anus is gaping open.
/mob/living/proc/has_gaped_orifice()
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		var/obj/item/organ/genitals/filling_organ/hole = getorganslot(slot)
		if(istype(hole) && hole.orifice?.gaped)
			return TRUE
	return FALSE

/atom/movable/screen/alert/status_effect/orifice_gaping
	name = "Gaping"
	desc = "I am stretched wide open. Things will not stay in, and nothing in there feels like much."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "orifice_gaping"

/datum/status_effect/orifice_sore
	id = "orifice_sore"
	duration = -1
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/orifice_sore
	var/organ_slot

/datum/status_effect/orifice_sore/vagina
	id = "orifice_sore_vagina"
	organ_slot = ORGAN_SLOT_VAGINA

/datum/status_effect/orifice_sore/anus
	id = "orifice_sore_anus"
	organ_slot = ORGAN_SLOT_ANUS

/datum/status_effect/orifice_sore/on_apply()
	. = ..()
	owner.add_stress(/datum/stress_event/sore_loins)

/datum/status_effect/orifice_sore/on_remove()
	owner.remove_stress(/datum/stress_event/sore_loins)
	return ..()

/atom/movable/screen/alert/status_effect/orifice_sore
	name = "Sore"
	desc = "Tender and a little raw down there. More of the same will hurt."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "orifice_sore"

/datum/status_effect/orifice_raw
	id = "orifice_raw"
	duration = -1
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/orifice_raw
	var/organ_slot

/datum/status_effect/orifice_raw/vagina
	id = "orifice_raw_vagina"
	organ_slot = ORGAN_SLOT_VAGINA

/datum/status_effect/orifice_raw/anus
	id = "orifice_raw_anus"
	organ_slot = ORGAN_SLOT_ANUS

/datum/status_effect/orifice_raw/on_apply()
	. = ..()
	owner.add_stress(/datum/stress_event/chafing)

/datum/status_effect/orifice_raw/on_remove()
	owner.remove_stress(/datum/stress_event/chafing)
	return ..()

/atom/movable/screen/alert/status_effect/orifice_raw
	name = "Raw"
	desc = "Chafed raw. Every touch there stings."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "orifice_raw"

/datum/status_effect/orifice_overused
	id = "orifice_overused"
	duration = -1
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/orifice_overused
	effectedstats = list("speed" = -1)
	var/organ_slot

/datum/status_effect/orifice_overused/vagina
	id = "orifice_overused_vagina"
	organ_slot = ORGAN_SLOT_VAGINA

/datum/status_effect/orifice_overused/anus
	id = "orifice_overused_anus"
	organ_slot = ORGAN_SLOT_ANUS

/datum/status_effect/orifice_overused/on_apply()
	. = ..()
	owner.add_stress(/datum/stress_event/chafing)

/datum/status_effect/orifice_overused/on_remove()
	owner.remove_stress(/datum/stress_event/chafing)
	return ..()

/atom/movable/screen/alert/status_effect/orifice_overused
	name = "Overused"
	desc = "Used past bearing. Nothing more goes in there until it has rested."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "orifice_overused"

// ---- Stress events ----

/datum/stress_event/gaped
	timer = -1
	stress_change = 2
	desc = span_red("I feel loose and empty.")

/datum/stress_event/gaped_loved
	timer = -1
	stress_change = -2
	desc = span_green("I love being stretched open.")

/datum/stress_event/sore_loins
	timer = -1
	stress_change = 1
	desc = span_red("I am sore down there.")

/datum/stress_event/chafing
	timer = -1
	stress_change = 3
	desc = span_red("I am chafed raw.")

/datum/stress_event/pleasantly_full
	timer = 10 MINUTES
	stress_change = -2
	desc = span_green("I was filled just right.")

/datum/stress_event/tight_fit_thrill
	timer = 10 MINUTES
	stress_change = -2
	desc = span_green("They were so tight around me.")

/datum/stress_event/could_barely_feel
	timer = 5 MINUTES
	stress_change = 1
	desc = span_red("I could barely feel them.")

/datum/stress_event/slick_and_ready
	timer = 5 MINUTES
	stress_change = -1
	desc = span_green("Slicked up and ready.")

/// Climax moods from the fit: the hole owner feels filled, the penetrator feels it tight or loose.
/proc/apply_orifice_climax_moods(mob/living/climaxer, datum/sex_action/action)
	var/datum/orifice/orifice = action?.orifice_ref?.resolve()
	if(!climaxer || !orifice || QDELETED(orifice) || !orifice.find_penetration(action))
		return
	var/girth = orifice.get_combined_girth()
	if(girth <= 0)
		return
	var/fit = orifice.get_fit(girth)
	if(climaxer == orifice.get_owner())
		if(fit >= CLIMAX_FULL_FIT_MIN && fit <= CLIMAX_FULL_FIT_MAX)
			climaxer.add_stress(/datum/stress_event/pleasantly_full)
		return
	if(climaxer != orifice.get_penetrator(action))
		return
	if(fit >= CLIMAX_TIGHT_FIT_MIN)
		climaxer.add_stress(/datum/stress_event/tight_fit_thrill)
	else if(fit <= CLIMAX_LOOSE_FIT_MAX)
		climaxer.add_stress(/datum/stress_event/could_barely_feel)

#undef GAPE_SLIP_CHANCE_SCALE
#undef GAPE_SLIP_GIRTH_MULT
#undef GAPE_SLIP_CHANCE_MAX
#undef GAPE_PLUG_HOLD_SHARE
#undef GAPE_STAND_GUSH_SHARE
#undef CLIMAX_FULL_FIT_MIN
#undef CLIMAX_FULL_FIT_MAX
#undef CLIMAX_TIGHT_FIT_MIN
#undef CLIMAX_LOOSE_FIT_MAX
