// What a hatchling does while it stays inside its host: a datum per egg kind, run from the holder's life tick.

/// A hatchling in a stomach eats its host's food instead of fluid: this much nutrition per unit, never below the floor.
#define HATCHLING_NUTRITION_PER_UNIT 5
#define HATCHLING_NUTRITION_FLOOR 150

/datum/hatchling_inside_behaviour
	/// The id the window shows a word for.
	var/word = "stirring"
	/// Time between pulses.
	var/interval = 30 SECONDS
	/// Pleasure, climax progress and pain one fed pulse gives through the generic sex action.
	var/pleasure = 0
	var/climax = 0
	var/pain = 0
	/// Fluid drunk from the container each pulse; finding none makes the pulse hungry.
	var/drain_units = 0
	/// What a hungry pulse keeps of the pleasure, and what it adds in pain.
	var/hungry_pleasure_share = 0
	var/hungry_pain = 0
	/// Share of the way toward the hatchling's own width the canal stretches each pulse.
	var/stretch_share = 0
	/// Lube left in the canal each pulse, reagent type and units.
	var/slick_reagent
	var/slick_units = 0
	/// Lines for a fed pulse and for a hungry one; %CONTAINER% is the location word.
	var/list/lines_fed
	var/list/lines_hungry
	/// How it leaves on its own, and when.
	var/leave_mode = HATCHLING_LEAVE_NEVER
	var/leave_delay = 0
	/// Whether the host may push it out, and the chance per push that it slips back deeper.
	var/can_push_out = FALSE
	var/push_slip_chance = 0
	/// Whether the host feels contraction lines from it, as from an embryo.
	var/contraction_lines = FALSE
	/// Whether it leaves a stomach up through the mouth, instead of the long way down.
	var/exits_by_mouth = FALSE

/// A spider skitters and spins slick silk, then finds its own way out.
/datum/hatchling_inside_behaviour/spider
	word = "skittering"
	interval = 35 SECONDS
	pleasure = 2
	climax = 0.5
	slick_reagent = /datum/reagent/consumable/egg_slime
	slick_units = 1
	lines_fed = list(
		"Tiny legs skitter across the inside of my %CONTAINER%, and I shiver.",
		"Something small busies itself inside me, spinning silk against the walls.",
		"A ticklish scurry deep in my %CONTAINER% makes me gasp.",
	)
	leave_mode = HATCHLING_LEAVE_AFTER_DELAY
	leave_delay = 4 MINUTES
	can_push_out = TRUE
	exits_by_mouth = TRUE

/// A bog bug drinks what it finds; fed it hums with warmth, hungry it churns.
/datum/hatchling_inside_behaviour/bog_bug
	word = "feeding"
	interval = 30 SECONDS
	pleasure = 3
	climax = 1
	drain_units = 2
	hungry_pain = 2
	lines_fed = list(
		"The bug inside my %CONTAINER% drinks deep, and a warm hum spreads from it.",
		"Something laps at the wetness inside me, slow and content.",
	)
	lines_hungry = list(
		"The bug inside my %CONTAINER% churns, restless and hungry.",
		"A hungry squirming rolls through my %CONTAINER%. It wants feeding.",
	)
	leave_mode = HATCHLING_LEAVE_AFTER_DELAY
	leave_delay = 3 MINUTES
	can_push_out = TRUE
	push_slip_chance = 30

/// A tentacle writhes, drinks and works the passage wider until it has grown enough to leave.
/datum/hatchling_inside_behaviour/tentacle
	word = "writhing"
	interval = 20 SECONDS
	pleasure = 5
	climax = 2
	drain_units = 1
	hungry_pleasure_share = 0.6
	stretch_share = 0.15
	slick_reagent = /datum/reagent/consumable/egg_slime
	slick_units = 0.5
	lines_fed = list(
		"The tentacle inside my %CONTAINER% coils and uncoils, pressing everywhere at once.",
		"Slick coils work against my walls from the inside, slow and searching.",
		"Something presses outward from deep inside, stretching me a little wider.",
	)
	lines_hungry = list(
		"The tentacle inside my %CONTAINER% writhes, searching for something to drink.",
	)
	leave_mode = HATCHLING_LEAVE_WHEN_GROWN

/// An embryo kicks now and then; its contractions and the birth after a short wait stay as they were.
/datum/hatchling_inside_behaviour/embryo
	word = "kicking"
	interval = 40 SECONDS
	pleasure = 1
	lines_fed = list(
		"A small kick from inside my %CONTAINER%, and a warm flutter after it.",
		"The newborn inside me shifts and settles again.",
	)
	leave_mode = HATCHLING_LEAVE_AFTER_DELAY
	leave_delay = 20 SECONDS
	contraction_lines = TRUE

// ---- The hatchling component's part ----

/datum/component/internal_womb_hatchling/Destroy(force)
	QDEL_NULL(behaviour)
	return ..()

/// The word the window shows for what the hatchling is doing.
/datum/component/internal_womb_hatchling/proc/get_word()
	return behaviour?.word || "stirring"

/// Fills the location and carrier words into [message].
/datum/component/internal_womb_hatchling/proc/format_inside_message(message)
	message = replacetext(message, "%CONTAINER%", location_name)
	return replacetext(message, "%CARRIER%", "[carrier]")

/// Whether this kind lets the host push it out; one that leaves when grown lets go once it is.
/datum/component/internal_womb_hatchling/proc/can_be_pushed_out()
	if(!behaviour)
		return FALSE
	if(behaviour.can_push_out)
		return TRUE
	return behaviour.leave_mode == HATCHLING_LEAVE_WHEN_GROWN && is_grown()

/datum/component/internal_womb_hatchling/proc/get_push_slip_chance()
	return behaviour?.push_slip_chance || 0

/// Whether it leaves on its own at some point, so a labour may queue it.
/datum/component/internal_womb_hatchling/proc/leaves_on_its_own()
	return behaviour && behaviour.leave_mode != HATCHLING_LEAVE_NEVER

/// TRUE once the held mob has finished its newborn growth, or never had any.
/datum/component/internal_womb_hatchling/proc/is_grown()
	var/mob/living/held = holder?.held_mob
	if(!held)
		return FALSE
	return isnull(held.GetComponent(/datum/component/newborn_growth))

/// Whether the hatchling's stay is over by its kind's rule, less what struggling shaved off.
/datum/component/internal_womb_hatchling/proc/wants_to_leave()
	if(!behaviour)
		return FALSE
	switch(behaviour.leave_mode)
		if(HATCHLING_LEAVE_AFTER_DELAY)
			return world.time >= hatch_time + behaviour.leave_delay - struggle_credit
		if(HATCHLING_LEAVE_WHEN_GROWN)
			return is_grown()
	return FALSE

/// The holder's bulk follows the hatchling's growth, so the belly swells and the birth width grows with it.
/datum/component/internal_womb_hatchling/proc/follow_growth()
	var/mob/living/held = holder?.held_mob
	if(!held || !container)
		return
	var/datum/component/newborn_growth/growth = held.GetComponent(/datum/component/newborn_growth)
	var/factor = 1
	if(growth)
		factor = growth.current_scale / max(growth.start_scale, 0.1)
	else if(start_scale > 0 && start_scale < 1)
		factor = 1 / start_scale
	var/new_bulk = max(1, round(base_bulk * factor))
	if(new_bulk == holder.body_storage_bulk)
		return
	SEND_SIGNAL(container, COMSIG_BODYSTORAGE_TRY_RESIZE, holder, new_bulk, TRUE)
	holder.birth_girth = max(holder.birth_girth, holder.get_insert_girth())

/// One pulse of the hatchling's kind: it drinks, pleases or churns, stretches, slicks, and now and then speaks.
/datum/component/internal_womb_hatchling/proc/pulse()
	if(!behaviour || !carrier || !holder?.held_mob || carrier.stat == DEAD)
		return
	var/fed = TRUE
	if(behaviour.drain_units > 0)
		fed = drink(behaviour.drain_units) > 0
	var/pleasure = fed ? behaviour.pleasure : behaviour.pleasure * behaviour.hungry_pleasure_share
	var/pain = fed ? behaviour.pain : behaviour.hungry_pain
	var/climax = fed ? behaviour.climax : behaviour.climax * behaviour.hungry_pleasure_share
	if(pleasure > 0 || pain > 0)
		SEND_SIGNAL(carrier, COMSIG_SEX_GENERIC_ACTION, carrier, pleasure, pain, climax, carrier)
	var/obj/item/organ/genitals/filling_organ/canal = container?.get_birth_canal()
	if(istype(canal) && canal.orifice_type)
		var/datum/orifice/opening = canal.get_orifice()
		if(behaviour.stretch_share > 0)
			opening.stretch_toward(get_passenger_birth_girth(holder), SEX_FORCE_MID, behaviour.stretch_share)
		if(behaviour.slick_reagent && behaviour.slick_units > 0)
			opening.add_lube(behaviour.slick_reagent, behaviour.slick_units)
	var/list/lines = fed ? behaviour.lines_fed : (behaviour.lines_hungry || behaviour.lines_fed)
	if(length(lines) && prob(35))
		var/line = format_inside_message(pick(lines))
		to_chat(carrier, fed ? span_love(line) : span_warning(line))
	carrier.hole_shake_hook("hatchling", 1)

/// Drinks up to [units] of the fluid around it; returns what it got.
/datum/component/internal_womb_hatchling/proc/drink(units)
	var/datum/reagents/fluids = container?.reagents
	if(!fluids)
		return eat_from_host(units)
	if(!fluids.total_volume)
		return 0
	var/before = fluids.total_volume
	fluids.remove_any(min(units, before))
	return before - fluids.total_volume

/// A stomach holds no fluid of its own, so a hatchling there eats what its host ate; it never starves them.
/datum/component/internal_womb_hatchling/proc/eat_from_host(units)
	if(!iscarbon(carrier))
		return 0
	var/mob/living/carbon/host = carrier
	if(host.nutrition < HATCHLING_NUTRITION_FLOOR)
		return 0
	host.adjust_nutrition(-units * HATCHLING_NUTRITION_PER_UNIT)
	return units

/// Whether this hatchling leaves a stomach by the mouth: its kind climbs, and it fits the throat.
/datum/component/internal_womb_hatchling/proc/leaves_by_mouth()
	return behaviour?.exits_by_mouth && container?.slot == ORGAN_SLOT_GUTS && get_passenger_birth_girth(holder) <= OVI_RETCH_MAX_GIRTH

/// A small hatchling climbs up out of a stomach by the mouth: a tickle in the throat, then it is out.
/datum/component/internal_womb_hatchling/proc/climb_out_by_mouth()
	if(!iscarbon(carrier) || !COOLDOWN_FINISHED(src, climb_cooldown))
		return FALSE
	COOLDOWN_START(src, climb_cooldown, 15 SECONDS)
	var/mob/living/carbon/host = carrier
	to_chat(host, span_warning("Something small climbs up inside me, and a tickle rises in my throat."))
	host.hole_shake_hook("hatchling", 1)
	return host.bring_up_now(holder, container)

/// A hatchling with a mind squirms on purpose: the host feels a pulse and the stay gets shorter.
/datum/component/internal_womb_hatchling/proc/on_struggle(mob/living/user)
	if(!user || user != holder?.held_mob)
		return
	if(!COOLDOWN_FINISHED(src, struggle_cooldown))
		to_chat(user, span_warning("The walls around you give nothing yet. Wait a moment."))
		return
	COOLDOWN_START(src, struggle_cooldown, 10 SECONDS)
	struggle_credit += 20 SECONDS
	to_chat(user, span_notice("You squirm against the warm, slick walls around you."))
	if(carrier)
		to_chat(carrier, span_love("Something squirms hard inside my [location_name]."))
	pulse()

#undef HATCHLING_NUTRITION_PER_UNIT
#undef HATCHLING_NUTRITION_FLOOR
