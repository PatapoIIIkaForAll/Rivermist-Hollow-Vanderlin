/datum/component/ovipositor
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/mob/living/carrier
	var/egg_stage = 0
	var/eggs_stored = 1
	var/eggs_clutch_size = 1
	/// Why the last single lay gave nothing, and the host's pleasure share of the last one that went in.
	var/last_lay_reason
	var/last_lay_share = 0
	COOLDOWN_DECLARE(egg_timer)

/datum/component/ovipositor/Initialize()
	if(!istype(parent, /obj/item/organ/genitals/penis))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/genitals/penis/genital = parent
	carrier = genital.owner
	set_clutch_size(genital.egg_clutch_size)

/datum/component/ovipositor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_INSERTED, PROC_REF(on_inserted))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))
	if(carrier)
		register_carrier()

/datum/component/ovipositor/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ORGAN_INSERTED)
	UnregisterSignal(parent, COMSIG_ORGAN_REMOVED)
	if(carrier)
		unregister_carrier()

/datum/component/ovipositor/Destroy(force, ...)
	carrier = null
	return ..()

/datum/component/ovipositor/proc/register_carrier()
	RegisterSignal(carrier, COMSIG_LIVING_LIFE, PROC_REF(handle_life))
	RegisterSignal(carrier, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))

/datum/component/ovipositor/proc/unregister_carrier()
	UnregisterSignal(carrier, COMSIG_LIVING_LIFE)
	UnregisterSignal(carrier, COMSIG_SEX_CLIMAX)

/datum/component/ovipositor/proc/on_inserted(datum/source, mob/living/new_owner)
	SIGNAL_HANDLER

	if(carrier == new_owner)
		return
	if(carrier)
		unregister_carrier()
	carrier = new_owner
	if(carrier)
		register_carrier()

/datum/component/ovipositor/proc/on_removed(datum/source, mob/living/old_owner)
	SIGNAL_HANDLER

	if(carrier)
		unregister_carrier()
	carrier = null

/datum/component/ovipositor/proc/handle_life(seconds)
	SIGNAL_HANDLER

	// A full store grows nothing, so the egg after a lay starts from scratch.
	if(eggs_stored >= get_max_stored_eggs())
		if(egg_stage || COOLDOWN_FINISHED(src, egg_timer))
			egg_stage = 0
			COOLDOWN_START(src, egg_timer, get_egg_stage_time())
		return

	if(COOLDOWN_FINISHED(src, egg_timer))
		egg_stage += 1
		egg_stage = min(2, egg_stage)
		COOLDOWN_START(src, egg_timer, get_egg_stage_time())

	if(egg_stage == 2)
		var/obj/item/organ/genitals/penis/ovipositor/ovipositor = parent
		if(ovipositor?.resource_dependent_yield)
			var/cost = get_oviposition_nutrient_cost(ovipositor.ovi_egg_type, ovipositor.egg_scale, ovipositor.egg_traits, get_clutch_size())
			if(!consume_oviposition_nutrients(carrier, cost))
				if(prob(5))
					to_chat(carrier, span_warning("My ovipositor aches faintly - I need more nutrition to form eggs."))
				egg_stage = 1
				COOLDOWN_START(src, egg_timer, get_egg_stage_time())
				return
		egg_stage = 0
		eggs_stored += 1
		eggs_stored = min(get_max_stored_eggs(), eggs_stored)

/datum/component/ovipositor/proc/get_egg_stage_time()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = parent
	if(!ovipositor)
		return OVI_EGG_STAGE_TIME

	var/stage_time = OVI_EGG_STAGE_TIME
	stage_time *= get_oviposition_egg_type_interval_multiplier(ovipositor.ovi_egg_type)
	stage_time *= get_oviposition_capacity_interval_multiplier(get_clutch_size())
	stage_time *= sanitize_oviposition_scale(ovipositor.egg_scale)
	stage_time *= get_oviposition_trait_interval_multiplier(ovipositor.egg_traits)
	stage_time *= ovipositor.egg_stage_time_multiplier

	if(ovipositor.resource_dependent_yield && carrier)
		var/nutriment = carrier.get_reagent_amount(/datum/reagent/consumable/nutriment)
		var/speed_multiplier = 1.5 - clamp(nutriment / 10, 0, 1)
		stage_time *= speed_multiplier

	return max(30 SECONDS, round(stage_time))

/datum/component/ovipositor/proc/get_clutch_size()
	var/obj/item/organ/genitals/penis/genital = parent
	if(genital)
		eggs_clutch_size = clamp(round(genital.egg_clutch_size || 1), 1, OVI_EGG_MAX_CLUTCH)
	var/base = clamp(round(eggs_clutch_size || 1), 1, OVI_EGG_MAX_CLUTCH)
	// Resource-dependent yield: scale clutch by carrier's nutriment level
	var/obj/item/organ/genitals/penis/ovipositor/ovi = parent
	if(istype(ovi) && ovi.resource_dependent_yield && carrier)
		base = get_resource_adjusted_clutch(carrier, base)
	return base

/// Scales a base clutch size by the carrier's internal nutriment. Full nutrition = full clutch.
/proc/get_resource_adjusted_clutch(mob/living/carrier, base_clutch)
	if(!carrier || base_clutch <= 0)
		return max(1, base_clutch)
	var/nutriment = carrier.get_reagent_amount(/datum/reagent/consumable/nutriment)
	// 0 nutriment = 1 egg minimum, 5+ nutriment = full clutch, linear scale between
	var/ratio = clamp(nutriment / 5, 0, 1)
	return max(1, round(base_clutch * ratio))

/datum/component/ovipositor/proc/get_max_stored_eggs()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = parent
	if(istype(ovipositor))
		return clamp(round(max(ovipositor.egg_storage_capacity, get_clutch_size())), 1, OVI_EGG_MAX_CLUTCH)
	return OVI_EGG_MAX_CLUTCH

/datum/component/ovipositor/proc/set_clutch_size(new_size)
	if(isnull(new_size))
		return eggs_clutch_size

	eggs_clutch_size = clamp(round(new_size), 1, OVI_EGG_MAX_CLUTCH)
	eggs_stored = min(eggs_stored, get_max_stored_eggs())
	return eggs_clutch_size

/datum/component/ovipositor/proc/sync_storage_capacity()
	eggs_stored = min(eggs_stored, get_max_stored_eggs())

/datum/component/ovipositor/proc/on_climax(datum/source, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	SIGNAL_HANDLER

	if(!carrier || eggs_stored <= 0)
		return FALSE

	var/list/climax_context = get_climax_context(action)
	if(climax_context)
		var/obj/item/organ/receiver = climax_context["receiver"]
		var/force = climax_context["force"]
		if(iscarbon(receiver.owner))
			var/mob/living/carbon/receiver_owner = receiver.owner
			if(!receiver_owner.can_receive_oviposition_implant(TRUE))
				if(receiver_owner != carrier)
					to_chat(carrier, span_warning("[receiver_owner]'s body is still recovering from too many recent births and rejects another implantation."))
				return FALSE
		if(rush_eggs(receiver, force, get_rush_cap(action)))
			return TRUE

	return lay_egg(get_turf(carrier))

/datum/component/ovipositor/proc/get_climax_context(datum/sex_action/action)
	if(!carrier || !action || QDELETED(action))
		return null

	if(!action_allows_internal_oviposition(action))
		return null

	var/mob/living/insertor = action.get_storage_insertor(action.action_user, action.action_target)
	if(insertor != carrier)
		return null

	var/mob/living/receiver_owner = action.get_storage_receiver(action.action_user, action.action_target)
	if(!receiver_owner)
		return null
	if(!target_allows_mob_erp_action(carrier, receiver_owner, /datum/erp_preference/boolean/allow_mob_oviposition))
		return null

	var/obj/item/organ/receiver = get_receiver_for_hole(receiver_owner, action.hole_id)
	if(!receiver)
		return null

	return list(
		"receiver" = receiver,
		"force" = action.force >= SEX_FORCE_HIGH,
	)

/datum/component/ovipositor/proc/action_allows_internal_oviposition(datum/sex_action/action)
	if(!action)
		return FALSE

	// Only direct penetrative sex acts should deposit eggs automatically.
	return istype(action, /datum/sex_action/sex/lay_eggs) \
		|| istype(action, /datum/sex_action/sex/vaginal) \
		|| istype(action, /datum/sex_action/sex/anal) \
		|| istype(action, /datum/sex_action/sex/throat) \
		|| istype(action, /datum/sex_action/sex/other/vagina) \
		|| istype(action, /datum/sex_action/sex/other/anal) \
		|| istype(action, /datum/sex_action/npc/npc_vaginal_sex) \
		|| istype(action, /datum/sex_action/npc/npc_vaginal_ride_sex) \
		|| istype(action, /datum/sex_action/npc/npc_anal_sex) \
		|| istype(action, /datum/sex_action/npc/npc_anal_ride_sex) \
		|| istype(action, /datum/sex_action/npc/npc_throat_sex)

/datum/component/ovipositor/proc/get_receiver_for_hole(mob/living/receiver_owner, hole_id)
	if(!receiver_owner)
		return null

	var/obj/item/organ/receiver = null
	switch(hole_id)
		if(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
			receiver = receiver_owner.getorganslot(hole_id)
		if(BODY_ZONE_PRECISE_MOUTH)
			// Oral deep-storage is attached to guts/stomach internals rather than a visible hole organ.
			receiver = receiver_owner.getorganslot(ORGAN_SLOT_GUTS)
			if(!receiver)
				receiver = receiver_owner.getorganslot(ORGAN_SLOT_STOMACH)

	if(receiver?.supports_oviposition_pregnancy())
		return receiver
	return null

/datum/component/ovipositor/proc/create_egg()
	var/obj/item/oviposition_egg/egg = new
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = parent
	var/egg_type = ovipositor.ovi_egg_type
	if(egg_type == initial(ovipositor.ovi_egg_type))
		egg_type = get_species_oviposition_egg_type(carrier) || egg_type
	// Apply player custom overrides before setting type (so profile apply respects them)
	egg.apply_custom_overrides(ovipositor.custom_egg_name, ovipositor.custom_egg_desc, ovipositor.custom_egg_color, ovipositor.egg_scale, ovipositor.egg_traits)
	egg.set_egg_type(egg_type)
	egg.set_oviposition_mother(carrier)
	return egg

/// Puts [egg] where [receiver] routes it; [quiet] leaves the words to the caller.
/datum/component/ovipositor/proc/try_place_egg_in_host(obj/item/organ/receiver, obj/item/oviposition_egg/egg, force = FALSE, quiet = FALSE)
	if(!receiver || !egg || !receiver.owner)
		return FALSE
	if(iscarbon(receiver.owner))
		var/mob/living/carbon/receiver_owner = receiver.owner
		if(!receiver_owner.can_receive_oviposition_implant(TRUE))
			if(receiver_owner != carrier)
				to_chat(carrier, span_warning("[receiver_owner]'s body is still recovering from too many recent births and rejects another implantation."))
			return FALSE

	// The hole decides where the egg rests: a free womb behind it, or its own depths.
	var/obj/item/organ/host = receiver.get_oviposition_receiver(egg, force) || receiver
	var/fit_result = SEND_SIGNAL(host, COMSIG_BODYSTORAGE_TRY_INSERT, egg, STORAGE_LAYER_DEEP, force)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			var/started_growing = host.start_oviposition_egg_growth(egg, carrier)
			if(quiet)
				return TRUE
			var/plants_maneater_seed = egg.egg_type == OVI_EGG_MANEATER
			var/third_person_action = plants_maneater_seed ? "plants a seed in" : "lays an egg into"
			var/first_person_action = plants_maneater_seed ? "plant a seed in" : "lay an egg into"
			carrier.visible_message(
				span_love("[carrier] [third_person_action] [receiver.owner]'s [host.get_oviposition_location_name()]!"),
				span_love("I [first_person_action] [receiver.owner]'s [host.get_oviposition_location_name()]!")
			)
			if(receiver.owner != carrier)
				to_chat(receiver.owner, span_love("[carrier] [third_person_action] my [host.get_oviposition_location_name()]!"))
			if(started_growing == OVI_EGG_GROWTH_STARTED)
				if(plants_maneater_seed)
					to_chat(receiver.owner, span_love("The planted seed in my [host.get_oviposition_location_name()] immediately begins to grow."))
				else
					to_chat(receiver.owner, span_love("One of the eggs in my [host.get_oviposition_location_name()] immediately begins to grow."))
			return TRUE

	return FALSE

// ---- One egg at a time ----

/// Width a fresh egg passes the opening with: the unripe floor a birth uses.
/datum/component/ovipositor/proc/get_lay_girth(obj/item/oviposition_egg/egg)
	var/datum/oviposition_egg_profile/profile = egg.get_egg_profile()
	return (profile?.birth_girth || OVI_EGG_DEFAULT_BIRTH_GIRTH) * egg.get_egg_scale() * OVI_EGG_LAY_GIRTH_SHARE

/// Why no egg can go into [receiver] right now, or null when one can.
/datum/component/ovipositor/proc/get_lay_block_reason(obj/item/organ/receiver, feedback = FALSE)
	if(!carrier)
		return "Nothing to lay with."
	if(eggs_stored <= 0)
		return "I have no egg ready."
	var/mob/living/host_owner = receiver?.owner
	if(!host_owner || !receiver.supports_oviposition_pregnancy())
		return "There is nowhere to lay."
	if(iscarbon(host_owner))
		var/mob/living/carbon/carbon_host = host_owner
		if(!carbon_host.can_receive_oviposition_implant(feedback && host_owner == carrier))
			return "[host_owner == carrier ? "My" : "[host_owner]'s"] body is still recovering from too many births."
	if(host_owner != carrier && !target_allows_mob_erp_action(carrier, host_owner, /datum/erp_preference/boolean/allow_mob_oviposition))
		return "[host_owner] will not take my eggs."
	return null

/// TRUE when [receiver] has room for one more egg, by the same routing and fit a lay uses.
/datum/component/ovipositor/proc/has_room_for_egg(obj/item/organ/receiver, force = FALSE)
	if(!receiver?.owner || !receiver.supports_oviposition_pregnancy())
		return FALSE
	var/obj/item/oviposition_egg/egg = create_egg()
	if(!egg)
		return FALSE
	var/obj/item/organ/host = receiver.get_oviposition_receiver(egg, force) || receiver
	var/fit_result = SEND_SIGNAL(host, COMSIG_BODYSTORAGE_CHECK_FIT, egg, STORAGE_LAYER_DEEP, force)
	qdel(egg)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return TRUE
	return FALSE

/// Lays one egg into [receiver] by the hole's own routing; the egg, or null with last_lay_reason set.
/datum/component/ovipositor/proc/lay_one_egg(obj/item/organ/receiver, force = FALSE)
	last_lay_share = 0
	last_lay_reason = get_lay_block_reason(receiver)
	if(last_lay_reason)
		return null
	var/obj/item/oviposition_egg/egg = create_egg()
	if(!egg)
		last_lay_reason = "Nothing comes."
		return null
	if(!try_place_egg_in_host(receiver, egg, force, TRUE))
		qdel(egg)
		var/whose = receiver.owner == carrier ? "my" : "[receiver.owner]'s"
		last_lay_reason = "There is no more room in [whose] [receiver.get_oviposition_location_name()]."
		return null
	eggs_stored = max(0, eggs_stored - 1)
	var/obj/item/organ/resting = egg.loc
	if(istype(resting))
		last_lay_share = pass_egg_in(resting, egg, force)
	return egg

/// The egg's way in through the canal before [host]: stretch, coat, sound; the host's pleasure share.
/datum/component/ovipositor/proc/pass_egg_in(obj/item/organ/host, obj/item/oviposition_egg/egg, force = FALSE)
	var/obj/item/organ/genitals/filling_organ/canal = host.get_birth_canal()
	if(!istype(canal) || !canal.orifice_type || !canal.owner)
		return 0
	var/datum/orifice/opening = canal.get_orifice()
	var/girth = get_lay_girth(egg)
	var/share = 0
	if(iscarbon(canal.owner))
		var/mob/living/carbon/host_owner = canal.owner
		share = host_owner.get_birth_pleasure_share(opening, girth)
	opening.pass_through(girth, force ? SEX_FORCE_HIGH : SEX_FORCE_MID, carrier)
	canal.take_birth_residue(egg, OVI_EGG_DEPOSIT_RESIDUE_SHARE)
	opening.play_passage_sound("pass", 30, canal.owner)
	canal.owner.hole_shake_hook("insert", 1)
	return share

/// Lays one egg onto the floor under the carrier; the egg, or null with last_lay_reason set.
/datum/component/ovipositor/proc/lay_one_egg_on_floor()
	last_lay_share = 0
	last_lay_reason = null
	if(!carrier || eggs_stored <= 0)
		last_lay_reason = "I have no egg ready."
		return null
	var/turf/floor = get_turf(carrier)
	if(!floor)
		last_lay_reason = "There is no ground to lay on."
		return null
	var/obj/item/oviposition_egg/egg = create_egg()
	if(!egg)
		return null
	egg.forceMove(floor)
	eggs_stored = max(0, eggs_stored - 1)
	return egg

/// Most eggs a climax in [action] rushes: fewer once the act laid its cap.
/datum/component/ovipositor/proc/get_rush_cap(datum/sex_action/action)
	if(action?.eggs_laid_this_act >= LAY_EGG_ACT_CAP)
		return LAY_EGG_RUSH_CAP_AFTER_CAP
	return LAY_EGG_RUSH_CAP

/// The climax rush: up to [cap] eggs of a clutch into [receiver] at once. How many went in.
/datum/component/ovipositor/proc/rush_eggs(obj/item/organ/receiver, force = FALSE, cap = LAY_EGG_RUSH_CAP)
	var/count = 0
	var/share_sum = 0
	var/clutch = min(eggs_stored, get_clutch_size(), cap)
	for(var/i in 1 to clutch)
		var/obj/item/oviposition_egg/egg = lay_one_egg(receiver, force)
		if(!egg)
			break
		count++
		share_sum += last_lay_share
	if(!count)
		if(last_lay_reason)
			to_chat(carrier, span_warning(last_lay_reason))
		return 0
	var/mob/living/host_owner = receiver.owner
	var/location = receiver.get_oviposition_location_name()
	var/seeds = get_egg_kind_is_seed()
	var/what = count == 1 ? (seeds ? "a seed" : "an egg") : "[count] [seeds ? "seeds" : "eggs"]"
	var/share = share_sum / count
	if(host_owner == carrier)
		carrier.visible_message(span_love_flash("[carrier] shudders and [what] slide[count == 1 ? "s" : ""] deep into [carrier.p_their()] own [location]!"), span_love_flash("I clench and [what] rush[count == 1 ? "es" : ""] deep into my own [location]!"))
	else
		carrier.visible_message(span_love_flash("[carrier] goes rigid and [what] burst[count == 1 ? "s" : ""] into [host_owner]'s [location]!"), span_love_flash("I clench hard and [what] burst[count == 1 ? "s" : ""] out of me into [host_owner]'s [location]!"))
		to_chat(host_owner, share >= 0.66 ? span_love_flash("[what] rush[count == 1 ? "es" : ""] into my [location] in one hot, shuddering wave!") : span_love("[what] force[count == 1 ? "s" : ""] into my [location] in one hard rush!"))
	playsound(carrier, 'sound/effects/wounds/splatter.ogg', 60, TRUE)
	return count

/// TRUE when this ovipositor's eggs are seeds, for the words.
/datum/component/ovipositor/proc/get_egg_kind_is_seed()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = parent
	return istype(ovipositor) && ovipositor.ovi_egg_type == OVI_EGG_MANEATER

/datum/component/ovipositor/proc/lay_egg(atom/location, force = FALSE)
	if(!carrier || eggs_stored <= 0)
		return FALSE

	var/clutch_size = min(eggs_stored, get_clutch_size())
	if(clutch_size <= 0)
		return FALSE

	var/obj/item/organ/receiver = null
	var/atom/drop_location = null
	if(istype(location, /obj/item/organ))
		receiver = location
		if(!receiver.supports_oviposition_pregnancy())
			receiver = null
	else
		drop_location = location

	var/internal_laid = 0
	var/external_laid = 0
	var/warned_no_room = FALSE
	var/plants_maneater_seeds = FALSE

	for(var/i in 1 to clutch_size)
		var/obj/item/oviposition_egg/egg = create_egg()
		if(!egg)
			break
		if(egg.egg_type == OVI_EGG_MANEATER)
			plants_maneater_seeds = TRUE

		var/success = FALSE
		if(receiver)
			success = try_place_egg_in_host(receiver, egg, force)
			if(success)
				internal_laid += 1
			else if(!warned_no_room)
				var/lay_action = plants_maneater_seeds ? "plant a seed" : "lay an egg"
				to_chat(carrier, span_warning("That [receiver.get_oviposition_location_name()] is too overfilled to [lay_action] in."))
				warned_no_room = TRUE

		if(success)
			continue

		if(!drop_location)
			drop_location = get_turf(carrier)
		if(!drop_location)
			qdel(egg)
			continue

		egg.forceMove(drop_location)
		external_laid += 1

	var/eggs_laid = internal_laid + external_laid
	if(!eggs_laid)
		return FALSE

	if(external_laid)
		var/laid_text
		if(plants_maneater_seeds)
			laid_text = external_laid == 1 ? "a seed" : "[external_laid] seeds"
			carrier.visible_message(span_notice("[carrier] plants [laid_text]!"), span_nicegreen("I plant [laid_text]!"))
		else
			laid_text = external_laid == 1 ? "an egg" : "[external_laid] eggs"
			carrier.visible_message(span_notice("[carrier] lays [laid_text]!"), span_nicegreen("I lay [laid_text]!"))

	playsound(carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	eggs_stored = max(0, eggs_stored - eggs_laid)
	return TRUE
