#define EGG_STAGE_TIME 1 MINUTES

/datum/component/ovipositor
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/mob/living/carrier
	var/egg_stage = 0
	var/eggs_stored = 1
	var/eggs_clutch_size = 1
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

	if(COOLDOWN_FINISHED(src, egg_timer))
		egg_stage += 1
		egg_stage = min(2, egg_stage)
		COOLDOWN_START(src, egg_timer, EGG_STAGE_TIME)

	if(egg_stage == 2)
		egg_stage = 0
		eggs_stored += 1
		eggs_stored = min(get_max_stored_eggs(), eggs_stored)

/datum/component/ovipositor/proc/get_clutch_size()
	var/obj/item/organ/genitals/penis/genital = parent
	if(genital)
		eggs_clutch_size = max(1, round(genital.egg_clutch_size || 1))
	return max(1, round(eggs_clutch_size || 1))

/datum/component/ovipositor/proc/get_max_stored_eggs()
	return max(3, get_clutch_size())

/datum/component/ovipositor/proc/set_clutch_size(new_size)
	if(isnull(new_size))
		return eggs_clutch_size

	eggs_clutch_size = max(1, round(new_size))
	eggs_stored = min(eggs_stored, get_max_stored_eggs())
	return eggs_clutch_size

/datum/component/ovipositor/proc/on_climax(datum/source)
	SIGNAL_HANDLER

	if(!carrier || eggs_stored <= 0)
		return FALSE

	var/list/climax_context = get_climax_context()
	if(climax_context)
		var/obj/item/organ/receiver = climax_context["receiver"]
		var/force = climax_context["force"]
		if(lay_egg(receiver, force))
			return TRUE

	return lay_egg(get_turf(carrier))

/datum/component/ovipositor/proc/get_climax_context()
	if(!carrier)
		return null

	var/list/sessions = return_sessions_with_user(carrier)
	var/datum/sex_session/session = return_highest_priority_action(sessions, carrier)
	if(!session || !session.current_action)
		return null

	var/datum/sex_action/action = SEX_ACTION(session.current_action)
	if(!action)
		return null
	if(!action_allows_internal_oviposition(action))
		return null

	var/mob/living/insertor = action.flipped ? session.target : session.user
	if(insertor != carrier)
		return null

	var/mob/living/receiver_owner = action.flipped ? session.user : session.target
	if(!receiver_owner)
		return null
	if(!target_allows_mob_erp_action(carrier, receiver_owner, /datum/erp_preference/boolean/allow_mob_oviposition))
		return null

	var/obj/item/organ/receiver = get_receiver_for_hole(receiver_owner, action.hole_id)
	if(!receiver)
		return null

	return list(
		"receiver" = receiver,
		"force" = session.get_current_force() >= SEX_FORCE_HIGH,
	)

/datum/component/ovipositor/proc/action_allows_internal_oviposition(datum/sex_action/action)
	if(!action)
		return FALSE

	// Only direct penetrative sex acts should deposit eggs automatically.
	return istype(action, /datum/sex_action/sex/vaginal) \
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
	egg.set_egg_type(egg_type)
	egg.set_oviposition_mother(carrier)
	return egg

/datum/component/ovipositor/proc/try_place_egg_in_host(obj/item/organ/receiver, obj/item/oviposition_egg/egg, force = FALSE)
	if(!receiver || !egg || !receiver.owner)
		return FALSE

	var/fit_result = SEND_SIGNAL(receiver, COMSIG_BODYSTORAGE_TRY_INSERT, egg, STORAGE_LAYER_DEEP, force)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			var/started_growing = receiver.start_oviposition_egg_growth(egg, carrier)
			carrier.visible_message(
				span_love("[carrier] lays an egg into [receiver.owner]'s [receiver.get_oviposition_location_name()]!"),
				span_love("I lai an egg into [receiver.owner]'s [receiver.get_oviposition_location_name()]!")
			)
			if(receiver.owner != carrier)
				to_chat(receiver.owner, span_love("[carrier] lays an egg into my [receiver.get_oviposition_location_name()]!"))
			if(started_growing)
				to_chat(receiver.owner, span_love("One of the eggs in my [receiver.get_oviposition_location_name()] immediately begins to grow."))
			return TRUE

	return FALSE

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

	for(var/i in 1 to clutch_size)
		var/obj/item/oviposition_egg/egg = create_egg()
		if(!egg)
			break

		var/success = FALSE
		if(receiver)
			success = try_place_egg_in_host(receiver, egg, force)
			if(success)
				internal_laid += 1
			else if(!warned_no_room)
				to_chat(carrier, span_warning("That [receiver.get_oviposition_location_name()] is too overfilled to lay an egg in."))
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
		var/laid_text = external_laid == 1 ? "an egg" : "[external_laid] eggs"
		carrier.visible_message(span_notice("[carrier] lays [laid_text]!"), span_nicegreen("I lay [laid_text]!"))

	playsound(carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	eggs_stored = max(0, eggs_stored - eggs_laid)
	return TRUE
