#define OVIPOSITION_PREGNANCY_STAGES 4
#define OVIPOSITION_STAGE_DURATION 15 MINUTES
#define OVIPOSITION_LAY_COOLDOWN 1 MINUTES

/datum/component/pregnancy
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/hatch_result_type = /obj/item/reagent_containers/food/snacks/oviposition_egg/color/green //placeholder because we don't want human hatching
	var/obj/item/oviposition_egg/egg
	var/datum/oviposition_egg_profile/egg_profile
	var/obj/item/organ/container
	var/mob/living/carrier
	var/mob/living/mother
	var/mob/living/father
	var/mother_name
	var/father_name
	var/list/mother_features
	var/list/father_features
	var/egg_name
	var/stage = 0
	var/max_stage = OVIPOSITION_PREGNANCY_STAGES
	var/revealed = FALSE
	var/laid = FALSE
	var/fertilized = FALSE
	var/poll_for_ghost = FALSE
	var/require_ghost_to_hatch = TRUE
	var/stage_duration = OVIPOSITION_STAGE_DURATION
	var/processing_laid_auto_hatch = FALSE
	/// Where the ripe egg hatches, decided once it ripens; null until then.
	var/hatch_decision = null
	/// When a sealed host first kept this ripe egg from being laid.
	var/blocked_since = 0
	/// When the egg first ripened, for kinds that start labour after a fixed delay.
	var/ripe_since = 0
	COOLDOWN_DECLARE(stage_time)
	COOLDOWN_DECLARE(hatch_request_cooldown)
	COOLDOWN_DECLARE(lay_cooldown)

/datum/component/pregnancy/Initialize(mob/living/_mother, mob/living/_father = null, _hatch_result_type = null, _fertilized = FALSE, list/_father_features = null, _father_name = null)
	if(!istype(parent, /obj/item/oviposition_egg))
		return COMPONENT_INCOMPATIBLE

	egg = parent
	egg_profile = egg.get_egg_profile()

	if(_hatch_result_type && ispath(_hatch_result_type, /atom/movable))
		hatch_result_type = _hatch_result_type
	else if(egg_profile?.hatch_result_type && ispath(egg_profile.hatch_result_type, /atom/movable))
		hatch_result_type = egg_profile.hatch_result_type

	poll_for_ghost = egg.should_poll_for_ghost() && ispath(hatch_result_type, /mob/living)
	require_ghost_to_hatch = egg.requires_ghost_to_hatch() && poll_for_ghost
	stage_duration = egg.get_incubation_stage_duration()

	mother = egg.get_oviposition_mother(_mother)
	father = _father
	fertilized = _fertilized || !egg.requires_fertilization() || !isnull(father) || LAZYLEN(_father_features)
	mother_name = egg.oviposition_mother_name || mother?.real_name
	father_name = _father_name || father?.real_name
	mother_features = egg.oviposition_mother_features?.Copy()
	if(!LAZYLEN(mother_features))
		mother_features = get_oviposition_parent_features(mother)
	father_features = _father_features?.Copy()
	if(!LAZYLEN(father_features))
		father_features = get_oviposition_parent_features(father)

	refresh_container(TRUE)
	COOLDOWN_START(src, stage_time, stage_duration)

/datum/component/pregnancy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_hatch))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(egg_status))
	if(container)
		register_container()
	if(carrier && !laid)
		register_carrier()
	update_laid_auto_hatch_processing()

/datum/component/pregnancy/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	if(container)
		unregister_container()
	if(carrier)
		unregister_carrier()

/datum/component/pregnancy/Destroy()
	stop_laid_auto_hatch_processing()
	return ..()

/datum/component/pregnancy/proc/register_container()
	RegisterSignal(container, COMSIG_ORGAN_INSERTED, PROC_REF(on_container_changed))
	RegisterSignal(container, COMSIG_ORGAN_REMOVED, PROC_REF(on_container_changed))

/datum/component/pregnancy/proc/unregister_container()
	UnregisterSignal(container, COMSIG_ORGAN_INSERTED)
	UnregisterSignal(container, COMSIG_ORGAN_REMOVED)

/datum/component/pregnancy/proc/register_carrier()
	RegisterSignal(carrier, COMSIG_LIVING_LIFE, PROC_REF(handle_life))
	RegisterSignal(carrier, COMSIG_MOB_DEATH, PROC_REF(handle_death))

/datum/component/pregnancy/proc/unregister_carrier()
	UnregisterSignal(carrier, COMSIG_LIVING_LIFE)
	UnregisterSignal(carrier, COMSIG_MOB_DEATH)

/datum/component/pregnancy/proc/refresh_container(setup_only = FALSE)
	var/obj/item/organ/new_container = null
	if(istype(egg?.loc, /obj/item/organ))
		var/obj/item/organ/new_organ = egg.loc
		if(new_organ.is_oviposition_egg(egg))
			new_container = new_organ

	if(container != new_container)
		if(container && !setup_only)
			unregister_container()
		container = new_container
		if(container && !setup_only)
			register_container()

	var/mob/living/new_carrier = laid ? null : container?.owner
	if(carrier == new_carrier)
		update_egg_storage_bulk()
		update_laid_auto_hatch_processing()
		return

	if(carrier && !setup_only)
		unregister_carrier()

	carrier = new_carrier

	if(carrier && !setup_only)
		register_carrier()
	update_egg_storage_bulk()
	update_laid_auto_hatch_processing()

/datum/component/pregnancy/proc/on_moved(datum/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	refresh_container()

/datum/component/pregnancy/proc/on_container_changed(datum/source)
	SIGNAL_HANDLER
	refresh_container()

/datum/component/pregnancy/proc/start_laid_auto_hatch_processing()
	if(processing_laid_auto_hatch)
		return
	processing_laid_auto_hatch = TRUE
	START_PROCESSING(SSobj, src)

/datum/component/pregnancy/proc/stop_laid_auto_hatch_processing()
	if(!processing_laid_auto_hatch)
		return
	processing_laid_auto_hatch = FALSE
	STOP_PROCESSING(SSobj, src)

/datum/component/pregnancy/proc/update_laid_auto_hatch_processing()
	if(laid && stage >= max_stage && egg?.auto_hatches_when_laid())
		start_laid_auto_hatch_processing()
		return
	stop_laid_auto_hatch_processing()

/datum/component/pregnancy/proc/handle_life(seconds)
	SIGNAL_HANDLER

	if(laid || !carrier)
		return

	if(stage < max_stage && COOLDOWN_FINISHED(src, stage_time))
		stage += 1
		stage = min(stage, max_stage)
		on_stage_advanced()
		if(stage < max_stage)
			COOLDOWN_START(src, stage_time, stage_duration)

	if(stage < max_stage)
		return

	revealed = TRUE
	if(isnull(hatch_decision))
		decide_hatch_place()
	if(hatch_decision == OVI_HATCH_INSIDE)
		INVOKE_ASYNC(src, PROC_REF(try_hatch_inside_host))
		return

	// A host sealed shut for the grace period hatches the egg where it lies instead.
	if(is_laying_blocked())
		if(!blocked_since)
			blocked_since = world.time
		else if(world.time - blocked_since >= OVI_HATCH_BLOCKED_GRACE)
			hatch_decision = OVI_HATCH_INSIDE
			egg.hatch_inside_host = TRUE
			to_chat(carrier, span_warning("The egg in my [get_container_location_name()] has waited long enough. It is hatching where it lies."))
		return
	blocked_since = 0

	if(!ripe_since)
		ripe_since = world.time
		if(egg_profile?.labour_delay)
			to_chat(carrier, span_warning("The [egg.name] in my [get_container_location_name()] is ripe. It will not wait long."))
	// A kind with a fixed delay comes out once it is up; the rest roll for it every minute.
	var/wants_out = FALSE
	if(egg_profile?.labour_delay)
		wants_out = world.time - ripe_since >= egg_profile.labour_delay
	else if(COOLDOWN_FINISHED(src, lay_cooldown))
		COOLDOWN_START(src, lay_cooldown, OVIPOSITION_LAY_COOLDOWN)
		if(prob(20))
			to_chat(carrier, span_warning("The egg in my [get_container_location_name()] feels ready to come out."))
		wants_out = prob(egg_profile?.labour_chance || OVI_EGG_LABOUR_CHANCE)
	if(!wants_out)
		return
	// A ripe egg comes out through labour; only creatures still drop it on the spot.
	if(iscarbon(carrier))
		var/mob/living/carbon/carbon_carrier = carrier
		carbon_carrier.start_labour(egg, container)
	else
		lay_egg(get_turf(carrier), TRUE)

/// Picks where the ripe egg hatches: its kind's mode, the host's consent and, for an either, a fill-swayed roll.
/datum/component/pregnancy/proc/decide_hatch_place()
	var/mode = egg?.get_hatch_mode() || OVI_HATCH_OUTSIDE
	if(mode != OVI_HATCH_OUTSIDE && !carrier_allows_inside_hatching())
		mode = OVI_HATCH_OUTSIDE
	switch(mode)
		if(OVI_HATCH_INSIDE)
			hatch_decision = OVI_HATCH_INSIDE
		if(OVI_HATCH_EITHER)
			hatch_decision = prob(get_inside_hatch_chance()) ? OVI_HATCH_INSIDE : OVI_HATCH_OUTSIDE
		else
			hatch_decision = OVI_HATCH_OUTSIDE
	if(egg)
		egg.hatch_inside_host = (hatch_decision == OVI_HATCH_INSIDE)
	return hatch_decision

/// The kind's base chance plus what the host's fill adds: fluid and stored bulk make a nest.
/datum/component/pregnancy/proc/get_inside_hatch_chance()
	var/chance = egg?.get_inside_hatch_base_chance() || 0
	if(container?.reagents?.maximum_volume)
		chance += OVI_HATCH_FILL_FLUID_POINTS * (container.reagents.total_volume / container.reagents.maximum_volume)
	var/datum/component/body_storage/storage = container?.GetComponent(/datum/component/body_storage)
	if(storage)
		var/used = 0
		var/room = 0
		for(var/layer in storage.available_layers)
			used += storage.layer_storage_cur_bulk[layer]
			room += storage.layer_storage_max_bulk[layer]
		if(room > 0)
			chance += OVI_HATCH_FILL_BULK_POINTS * min(1, used / room)
	return clamp(chance, 0, OVI_HATCH_CHANCE_CAP)

/// A host who turned inside hatching off gets every egg laid instead; creatures and the unset allow it.
/datum/component/pregnancy/proc/carrier_allows_inside_hatching()
	if(!carrier)
		return FALSE
	if(!carrier.client && !carrier.mind?.key)
		return TRUE
	return carrier.get_erp_pref(/datum/erp_preference/boolean/allow_inside_hatching)

/// TRUE while the host's body itself keeps the egg from being laid: clothes, a device, a plug, a penetration, size.
/datum/component/pregnancy/proc/is_laying_blocked()
	if(!ishuman(carrier) || !egg || !container)
		return FALSE
	var/mob/living/carbon/human/human_carrier = carrier
	return !isnull(human_carrier.get_passage_block_reason(egg, container))

/// TRUE when the ripe egg would pass the carrier's opening within comfort, so the body looks forward to it.
/datum/component/pregnancy/proc/ripe_passage_feels_good()
	if(!egg || !iscarbon(carrier))
		return FALSE
	var/obj/item/organ/genitals/filling_organ/canal = container?.get_birth_canal()
	if(!istype(canal) || !canal.orifice_type)
		return FALSE
	var/mob/living/carbon/carbon_carrier = carrier
	return carbon_carrier.get_birth_pleasure_share(canal.get_orifice(), egg.get_birth_girth()) >= 0.66

/datum/component/pregnancy/proc/on_stage_advanced()
	if(!carrier)
		return

	var/message = egg.get_stage_message(stage)
	if(!message)
		switch(stage)
			if(1)
				message = "I feel a warm flutter deep in my %CONTAINER%."
			if(2)
				message = "One of the eggs in my %CONTAINER% starts to feel heavier."
			if(3)
				message = "A ripe pressure builds inside my %CONTAINER%."

	if(message)
		// Early stages read as pleasure and the ripe pressure as mixed; only a hard passage ahead reads as danger.
		to_chat(carrier, stage >= 3 ? "<span class='love_mid'>[format_container_message(message)]</span>" : span_love(format_container_message(message)))

	if(stage == max_stage)
		var/ready_message = egg.get_ready_message()
		if(!ready_message)
			ready_message = "The egg in my %CONTAINER% is fully developed and wants out."
		if(ripe_passage_feels_good())
			to_chat(carrier, span_love("[format_container_message(ready_message)] The thought of it sends a warm throb through me."))
		else
			to_chat(carrier, span_warning(format_container_message(ready_message)))

	update_egg_storage_bulk()

/datum/component/pregnancy/proc/get_container_location_name()
	return container?.get_oviposition_location_name() || "body"

/// Callers that already detached the egg pass their own snapshot, since ours is gone by then.
/datum/component/pregnancy/proc/format_container_message(message, location_name, mob/living/message_carrier)
	if(!message)
		return null

	var/formatted_message = replacetext(message, "%CONTAINER%", location_name || get_container_location_name())
	formatted_message = replacetext(formatted_message, "%EGG%", "[egg]")
	formatted_message = replacetext(formatted_message, "%CARRIER%", "[message_carrier || carrier]")
	return formatted_message

/datum/component/pregnancy/proc/update_egg_storage_bulk()
	if(!egg || laid)
		return

	var/datum/component/body_storage/storage = container?.GetComponent(/datum/component/body_storage)
	if(!storage || !max_stage)
		return

	var/new_bulk = egg.get_storage_bulk_for_stage(stage)
	if(egg.body_storage_bulk == new_bulk)
		return

	egg.body_storage_bulk = new_bulk
	storage.recalculate_current_bulk(container)

/datum/component/pregnancy/proc/remove_from_host(removal_reason = BODYSTORAGE_REMOVE_INTERNAL)
	if(!container)
		return FALSE
	return SEND_SIGNAL(container, COMSIG_BODYSTORAGE_TRY_REMOVE, egg, STORAGE_LAYER_DEEP, removal_reason)

/datum/component/pregnancy/proc/lay_egg(atom/location, forced = FALSE)
	if(laid || !carrier || !container || stage < max_stage)
		return FALSE

	// remove_from_host() relocates the egg, and our own COMSIG_MOVABLE_MOVED handler clears both of
	// these on the way through. Everything past that point has to work off the snapshot.
	var/mob/living/laying_carrier = carrier
	var/obj/item/organ/laying_container = container

	if(!location)
		location = get_turf(laying_carrier)
	if(!location)
		return FALSE
	if(!remove_from_host(BODYSTORAGE_REMOVE_INTERNAL))
		return FALSE

	// The egg leaves from the deep layer, which passes no opening on its own; judge the fit before it widens.
	var/obj/item/organ/genitals/filling_organ/laying_hole = laying_container.get_birth_canal()
	var/girth = egg.get_birth_girth()
	var/share = 0
	var/ease = 0
	var/feel = ""
	var/datum/orifice/opening
	var/laying_carbon = iscarbon(laying_carrier)
	if(istype(laying_hole) && laying_hole.orifice_type)
		opening = laying_hole.get_orifice()
		if(laying_carbon)
			var/mob/living/carbon/judging_carrier = laying_carrier
			share = judging_carrier.get_birth_pleasure_share(opening, girth)
			ease = judging_carrier.get_birth_pleasure_share(opening, girth, FALSE)
		feel = opening.get_passage_feel("pass")
		opening.pass_through(girth, SEX_FORCE_MID, laying_carrier)
		laying_hole.take_birth_residue(egg)

	laying_carrier.visible_message(
		span_notice("[laying_carrier] [laying_container.get_oviposition_lay_verb()] an egg!"),
		span_love(laying_container.get_oviposition_lay_self_message())
	)
	if(feel)
		to_chat(laying_carrier, span_love("It comes [feel]."))
	// Carbons sound the passage in feel_birth_passage; anything else keeps the old splatter.
	if(!laying_carbon)
		playsound(laying_carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	// A hard passage floors her; an easy one only takes her breath.
	if(ease < 0.5)
		laying_carrier.Knockdown(60, TRUE, TRUE)
		laying_carrier.Stun(60, TRUE, TRUE)
	laying_carrier.adjust_stamina((forced ? 120 : 80) * (1 - ease * 0.75))
	if(laying_carbon)
		var/mob/living/carbon/feeling_carrier = laying_carrier
		feeling_carrier.feel_birth_passage(share, opening)

	laid = TRUE
	// The floor hatch still counts toward the limit of the body that carried it.
	egg.birth_carrier_ref = WEAKREF(laying_carrier)
	egg.forceMove(location)
	refresh_container()
	return TRUE

/datum/component/pregnancy/proc/handle_death(datum/source)
	SIGNAL_HANDLER

	if(!egg)
		return

	var/turf/drop_location = get_turf(carrier)
	remove_from_host(BODYSTORAGE_REMOVE_INTERNAL)
	if(drop_location)
		new /obj/effect/decal/cleanable/food/egg_smudge(drop_location)
	qdel(egg)

/datum/component/pregnancy/proc/egg_status(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(laid && stage >= max_stage)
		if(egg?.auto_hatches_when_laid())
			examine_list += span_notice("It is warm, twitching, and looks ready to hatch on its own.")
		else
			examine_list += span_notice("It is warm, twitching, and ready to hatch if tapped with something.")
	else if(stage > 0)
		examine_list += span_notice("The shell feels warm and alive.")

/datum/component/pregnancy/process()
	if(!egg || !laid || stage < max_stage)
		stop_laid_auto_hatch_processing()
		return
	if(!egg.auto_hatches_when_laid())
		stop_laid_auto_hatch_processing()
		return

	hatch()

/datum/component/pregnancy/proc/handle_hatch(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(!laid || stage < max_stage)
		return

	INVOKE_ASYNC(src, PROC_REF(hatch), user)

/datum/component/pregnancy/proc/try_hatch_inside_host()
	if(!carrier || !container || !egg)
		return FALSE
	if(!COOLDOWN_FINISHED(src, hatch_request_cooldown))
		return FALSE

	COOLDOWN_START(src, hatch_request_cooldown, 30 SECONDS)

	var/mob/player = null
	if(poll_for_ghost)
		player = poll_hatch_candidate(carrier)
		if(require_ghost_to_hatch && !player)
			return FALSE

	// An egg inside an organ has no turf of its own; the hatchling appears where its host stands.
	var/atom/movable/hatch_result = create_hatch_result(get_turf(carrier))
	if(!hatch_result)
		return FALSE

	if(isliving(hatch_result))
		var/mob/living/hatchling = hatch_result
		finalize_living_hatch(player, hatchling)
		return hatch_living_inside_host(hatchling)

	if(isitem(hatch_result))
		var/obj/item/hatch_item = hatch_result
		return hatch_item_inside_host(hatch_item)

	qdel(hatch_result)
	return FALSE

/datum/component/pregnancy/proc/hatch(mob/user)
	if(!COOLDOWN_FINISHED(src, hatch_request_cooldown))
		return

	COOLDOWN_START(src, hatch_request_cooldown, 30 SECONDS)

	var/mob/player = null
	if(poll_for_ghost)
		player = poll_hatch_candidate(user)
		if(require_ghost_to_hatch && !player)
			return

	var/atom/movable/hatch_result = create_hatch_result()
	if(!hatch_result)
		return

	var/hatch_message = format_container_message(egg.get_hatch_message())
	egg.visible_message(span_notice(hatch_message || "[egg] cracks open!"))
	if(isliving(hatch_result))
		var/mob/living/hatchling = hatch_result
		finalize_living_hatch(player, hatchling)
	credit_hatch(carrier)

	playsound(egg, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	qdel(egg)

/// TRUE when this egg hatches into a creature, which counts toward the carrier's birth limit.
/datum/component/pregnancy/proc/spawns_offspring()
	return is_oviposition_offspring_type(hatch_result_type)

/// Counts a creature hatch for the body that carried the egg: its host now, or the one who laid it.
/datum/component/pregnancy/proc/credit_hatch(mob/living/known_carrier)
	if(!spawns_offspring())
		return FALSE
	var/mob/living/carbon/credited = known_carrier
	if(!istype(credited))
		credited = egg?.birth_carrier_ref?.resolve()
	if(!istype(credited))
		return FALSE
	credited.record_oviposition_birth()
	return TRUE

/datum/component/pregnancy/proc/poll_hatch_candidate(mob/user)
	var/poll_message = "Do you want to play as [mother_name ? "[mother_name]'s" : "someone's"] offspring?[egg_name ? " Their name will be [egg_name]." : ""]"
	var/list/mob/candidates = pollGhostCandidates(poll_message, null, null, FALSE, 30 SECONDS)

	if(!LAZYLEN(candidates))
		if(user && require_ghost_to_hatch)
			to_chat(user, span_info("The egg stays still. Maybe another soul will answer later."))
		return null

	return pick(candidates)

/datum/component/pregnancy/proc/create_hatch_result(atom/spawn_location = null)
	if(!egg || !hatch_result_type || !ispath(hatch_result_type, /atom/movable))
		return null
	var/atom/movable/hatch_result = new hatch_result_type(spawn_location || get_turf(egg))
	apply_hatch_result_appearance(hatch_result)
	return hatch_result

/datum/component/pregnancy/proc/apply_hatch_result_appearance(atom/movable/hatch_result)
	if(!egg || !istype(hatch_result, /obj/item/reagent_containers/food/snacks/oviposition_egg))
		return

	var/obj/item/reagent_containers/food/snacks/oviposition_egg/hatch_item = hatch_result
	hatch_item.name = egg.name
	hatch_item.desc = egg.desc
	hatch_item.icon = egg.icon
	hatch_item.icon_state = egg.icon_state
	hatch_item.color = egg.color
	hatch_item.transform = egg.transform
	egg.apply_trait_reagents_to(hatch_item)

/datum/component/pregnancy/proc/hatch_living_inside_host(mob/living/hatchling)
	if(!egg || !container || !carrier || !hatchling)
		qdel(hatchling)
		return FALSE

	// remove_from_host() relocates the egg, and our own COMSIG_MOVABLE_MOVED handler clears both of
	// these on the way through. Everything past that point has to work off the snapshot.
	var/mob/living/hatch_carrier = carrier
	var/obj/item/organ/hatch_container = container
	var/location_name = get_container_location_name()

	if(!remove_from_host(BODYSTORAGE_REMOVE_INTERNAL))
		qdel(hatchling)
		return FALSE

	var/holder_type = egg.internal_hatch_holder_type
	if(!ispath(holder_type, /obj/item/mob_holder/internal_womb))
		holder_type = /obj/item/mob_holder/internal_womb

	var/obj/item/mob_holder/internal_womb/holder = new holder_type(get_turf(hatch_carrier))
	if(!holder.deposit(hatchling))
		SEND_SIGNAL(hatch_container, COMSIG_BODYSTORAGE_FORCE_INSERT, egg, STORAGE_LAYER_DEEP)
		qdel(holder)
		return FALSE

	holder.set_internal_bulk(egg.internal_hatch_holder_bulk)
	// A newborn passes at the wider of its egg's birth width and its own body.
	holder.birth_girth = max(egg.get_birth_girth(), holder.get_insert_girth())

	var/datum/component/body_storage/storage = hatch_container.GetComponent(/datum/component/body_storage)
	var/holder_layer = egg.internal_hatch_layer
	if(!storage?.available_layers[holder_layer])
		holder_layer = STORAGE_LAYER_DEEP

	SEND_SIGNAL(hatch_container, COMSIG_BODYSTORAGE_FORCE_INSERT, holder, holder_layer)
	// The hatchling waits in the dark: no thinking until it is out.
	var/datum/ai_controller/hatchling_brain = hatchling.ai_controller
	if(istype(hatchling_brain))
		hatchling_brain.set_ai_status(AI_STATUS_OFF)
	holder.AddComponent(/datum/component/internal_womb_hatchling, hatch_container, hatch_carrier, location_name, egg.get_inside_behaviour_type(), egg.internal_contraction_message, egg.internal_birth_message)
	credit_hatch(hatch_carrier)

	var/hatch_message = egg.internal_hatch_message || egg.get_hatch_message()
	if(hatch_message)
		to_chat(hatch_carrier, span_warning(format_container_message(hatch_message, location_name, hatch_carrier)))
	playsound(hatch_carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	qdel(egg)
	return TRUE

/datum/component/pregnancy/proc/hatch_item_inside_host(obj/item/hatch_item)
	if(!egg || !container || !carrier || !hatch_item)
		qdel(hatch_item)
		return FALSE

	// remove_from_host() relocates the egg, and our own COMSIG_MOVABLE_MOVED handler clears both of
	// these on the way through. Everything past that point has to work off the snapshot.
	var/mob/living/hatch_carrier = carrier
	var/obj/item/organ/hatch_container = container
	var/location_name = get_container_location_name()

	var/target_layer = egg.internal_hatch_layer
	var/datum/component/body_storage/storage = hatch_container.GetComponent(/datum/component/body_storage)
	if(!storage?.available_layers[target_layer])
		target_layer = STORAGE_LAYER_DEEP

	var/hatch_message = egg.internal_hatch_message || egg.get_hatch_message()
	if(!remove_from_host(BODYSTORAGE_REMOVE_INTERNAL))
		qdel(hatch_item)
		return FALSE

	var/fit_result = SEND_SIGNAL(hatch_container, COMSIG_BODYSTORAGE_TRY_INSERT, hatch_item, target_layer, TRUE)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			if(hatch_message)
				to_chat(hatch_carrier, span_warning(format_container_message(hatch_message, location_name, hatch_carrier)))
			if(istype(hatch_item, /obj/item/natural/worms/leech/erotic))
				var/obj/item/natural/worms/leech/erotic/leech = hatch_item
				leech.on_hatched_inside_host(hatch_container, hatch_carrier, target_layer)
			credit_hatch(hatch_carrier)
			playsound(hatch_carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
			qdel(egg)
			return TRUE

	var/turf/drop_location = get_turf(hatch_carrier)
	if(drop_location)
		hatch_item.forceMove(drop_location)
		to_chat(hatch_carrier, span_warning("[hatch_item] hatches from [egg], but there is no room for it inside my [location_name]."))
		credit_hatch(hatch_carrier)
	else
		qdel(hatch_item)
	qdel(egg)
	return TRUE

/datum/component/pregnancy/proc/finalize_living_hatch(mob/player, mob/living/hatchling)
	if(ishuman(hatchling))
		var/mob/living/carbon/human/human_hatchling = hatchling
		human_hatchling.skip_initial_outfit = TRUE
		apply_baby_features(human_hatchling)

	remove_newborn_gear(hatchling)
	addtimer(CALLBACK(src, PROC_REF(remove_newborn_gear), hatchling), 2 SECONDS)

	var/newborn_start_scale = egg?.get_newborn_start_scale()
	var/newborn_growth_duration = egg?.get_newborn_growth_duration()
	var/mob/living/protected_parent = mother || carrier
	var/needs_newborn_scaling = newborn_start_scale > 0 && newborn_start_scale < 1 && newborn_growth_duration > 0
	if((protected_parent && newborn_growth_duration > 0) || needs_newborn_scaling)
		hatchling.AddComponent(/datum/component/newborn_growth, needs_newborn_scaling ? newborn_start_scale : 1, newborn_growth_duration, 1, protected_parent)

	if(player)
		player.leave_lobby_for_role()
		hatchling.mind_initialize()
		if(player.mind)
			player.mind.transfer_to(hatchling, TRUE)
		else if(player.key)
			hatchling.key = player.key

	to_chat(hatchling, "You are [mother_name ? "[mother_name]'s" : "someone's"] offspring.")

	if(egg_name)
		hatchling.real_name = egg_name
	else if(ishuman(hatchling))
		hatchling.real_name = random_unique_name(hatchling.gender)
	hatchling.update_name()
	register_hatchling_family(hatchling)

	if(hatchling.mind && mother_name)
		if(egg?.hatch_inside_host)
			hatchling.mind.store_memory("[mother_name] carried you inside an embryo.")
		else
			hatchling.mind.store_memory("[mother_name] laid your egg.")

/datum/component/pregnancy/proc/register_hatchling_family(mob/living/hatchling)
	if(!ishuman(hatchling))
		return FALSE

	var/mob/living/carbon/human/child = hatchling
	var/mob/living/carbon/human/mother_human = ishuman(mother) ? mother : null
	if(!mother_human && ishuman(carrier))
		mother_human = carrier

	var/mob/living/carbon/human/father_human = ishuman(father) ? father : null
	if(mother_human == father_human)
		father_human = null

	if(!mother_human && !father_human)
		return FALSE

	var/datum/heritage/child_family = mother_human?.family_datum || father_human?.family_datum
	if(!child_family)
		var/mob/living/carbon/human/founding_parent = mother_human || father_human
		child_family = new /datum/heritage(founding_parent, null, founding_parent.dna?.species?.type)

	var/datum/family_member/mother_member = get_family_parent_member(child_family, mother_human)
	var/datum/family_member/father_member = get_family_parent_member(child_family, father_human)
	return !!child_family.AddToFamily(child, mother_member, father_member, FALSE, TRUE)

/datum/component/pregnancy/proc/get_family_parent_member(datum/heritage/child_family, mob/living/carbon/human/parent_human)
	if(!child_family || !parent_human)
		return null

	if(parent_human.family_datum == child_family)
		return parent_human.family_member_datum || child_family.CreateFamilyMember(parent_human)

	if(!parent_human.family_datum)
		return child_family.CreateFamilyMember(parent_human)

	return parent_human.family_member_datum || parent_human.family_datum.CreateFamilyMember(parent_human)

/datum/component/pregnancy/proc/remove_newborn_gear(mob/living/hatchling)
	if(!hatchling)
		return

	var/list/equipped_items = hatchling.get_equipped_items(TRUE)
	if(length(equipped_items))
		equipped_items = equipped_items.Copy()
		for(var/obj/item/item as anything in equipped_items)
			if(QDELETED(item))
				continue
			if(!hatchling.temporarilyRemoveItemFromInventory(item, TRUE))
				hatchling.dropItemToGround(item, TRUE, TRUE)
			if(!QDELETED(item))
				qdel(item)

	var/list/held_items = hatchling.held_items
	if(length(held_items))
		held_items = held_items.Copy()
		for(var/obj/item/item as anything in held_items)
			if(QDELETED(item))
				continue
			if(!hatchling.temporarilyRemoveItemFromInventory(item, TRUE))
				hatchling.dropItemToGround(item, TRUE, TRUE)
			if(!QDELETED(item))
				qdel(item)

/datum/component/pregnancy/proc/apply_baby_features(mob/living/carbon/human/babby)
	if(!LAZYLEN(mother_features) && !LAZYLEN(father_features))
		return

	var/species_type = mother_features?["species"]
	if(egg?.hatch_inside_host && father_features?["species"])
		species_type = father_features["species"]
	else if(!species_type)
		species_type = father_features?["species"]
	if(species_type)
		babby.set_species(species_type, icon_update = FALSE)

	var/skin_tone = pick_inherited_feature("skin_tone")
	var/hair_color = pick_inherited_feature("hair_color")
	var/hair_style = pick_inherited_feature("hair_style")
	var/facial_hair_color = pick_inherited_feature("facial_hair_color")
	var/facial_hair_style = pick_inherited_feature("facial_hair_style")
	var/eye_color = pick_inherited_feature("eye_color")

	if(skin_tone)
		babby.skin_tone = skin_tone
	if(hair_color)
		babby.set_hair_color(hair_color, FALSE)
	if(hair_style)
		babby.set_hair_style(hair_style, FALSE)
	if(facial_hair_color)
		babby.set_facial_hair_color(facial_hair_color, FALSE)
	if(facial_hair_style)
		babby.set_facial_hair_style(facial_hair_style, FALSE)
	else
		babby.set_facial_hair_style(/datum/sprite_accessory/hair/facial/shaved, FALSE)
	if(eye_color)
		babby.set_eye_color(eye_color, null, FALSE)
	if(!hair_style)
		var/default_hair_style = pick(/datum/sprite_accessory/hair/head/azur/bedhead, /datum/sprite_accessory/hair/head/azur/bedhead2, /datum/sprite_accessory/hair/head/azur/bedhead3)
		babby.set_hair_style(default_hair_style, FALSE)
	babby.update_body()
	babby.update_body_parts()

/datum/component/pregnancy/proc/pick_inherited_feature(feature_key)
	var/mother_value = mother_features?[feature_key]
	var/father_value = father_features?[feature_key]

	if(mother_value && father_value)
		return prob(50) ? mother_value : father_value
	if(mother_value)
		return mother_value
	return father_value

/datum/component/internal_womb_hatchling
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/obj/item/mob_holder/internal_womb/holder
	var/obj/item/organ/container
	var/mob/living/carrier
	var/location_name = "womb"
	/// What the hatchling does inside, and when it leaves; null means it only waits.
	var/datum/hatchling_inside_behaviour/behaviour
	/// Time a struggling hatchling has shaved off its stay.
	var/struggle_credit = 0
	/// The holder's bulk and the newborn's scale at the hatch; growth scales the bulk up from there.
	var/base_bulk = 2
	var/start_scale = 1
	var/contraction_message = null
	var/birth_message = null
	var/hatch_time = 0
	COOLDOWN_DECLARE(contraction_cooldown)
	COOLDOWN_DECLARE(pulse_cooldown)
	COOLDOWN_DECLARE(struggle_cooldown)
	COOLDOWN_DECLARE(climb_cooldown)

/datum/component/internal_womb_hatchling/Initialize(obj/item/organ/_container, mob/living/_carrier, _location_name = "womb", behaviour_type = null, _contraction_message = null, _birth_message = null)
	if(!istype(parent, /obj/item/mob_holder/internal_womb))
		return COMPONENT_INCOMPATIBLE

	holder = parent
	container = _container
	carrier = _carrier
	location_name = _location_name || "womb"
	if(behaviour_type)
		behaviour = new behaviour_type
	base_bulk = holder.body_storage_bulk
	var/datum/component/newborn_growth/growth = holder.held_mob?.GetComponent(/datum/component/newborn_growth)
	start_scale = growth ? growth.start_scale : 1
	contraction_message = _contraction_message
	birth_message = _birth_message
	hatch_time = world.time
	return ..()

/datum/component/internal_womb_hatchling/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(container)
		register_container()
	if(carrier)
		register_carrier()

/datum/component/internal_womb_hatchling/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	if(container)
		unregister_container()
	if(carrier)
		unregister_carrier()

/datum/component/internal_womb_hatchling/proc/register_container()
	RegisterSignal(container, COMSIG_ORGAN_INSERTED, PROC_REF(on_container_changed))
	RegisterSignal(container, COMSIG_ORGAN_REMOVED, PROC_REF(on_container_changed))

/datum/component/internal_womb_hatchling/proc/unregister_container()
	UnregisterSignal(container, list(COMSIG_ORGAN_INSERTED, COMSIG_ORGAN_REMOVED))

/datum/component/internal_womb_hatchling/proc/register_carrier()
	RegisterSignal(carrier, COMSIG_LIVING_LIFE, PROC_REF(handle_life))
	RegisterSignal(carrier, COMSIG_MOB_DEATH, PROC_REF(handle_death))

/datum/component/internal_womb_hatchling/proc/unregister_carrier()
	UnregisterSignal(carrier, list(COMSIG_LIVING_LIFE, COMSIG_MOB_DEATH))

/datum/component/internal_womb_hatchling/proc/on_moved(datum/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	refresh_container()

/datum/component/internal_womb_hatchling/proc/on_container_changed(datum/source)
	SIGNAL_HANDLER
	refresh_container()

/datum/component/internal_womb_hatchling/proc/refresh_container()
	var/obj/item/organ/new_container = null
	if(istype(holder?.loc, /obj/item/organ))
		var/obj/item/organ/new_organ = holder.loc
		var/holder_layer = SEND_SIGNAL(new_organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, holder)
		if(holder_layer)
			new_container = new_organ

	if(container != new_container)
		if(container)
			unregister_container()
		container = new_container
		if(container)
			register_container()

	var/mob/living/new_carrier = container?.owner
	if(carrier == new_carrier)
		return
	if(carrier)
		unregister_carrier()
	carrier = new_carrier
	if(carrier)
		register_carrier()

/datum/component/internal_womb_hatchling/proc/handle_life(seconds)
	SIGNAL_HANDLER

	if(!holder?.held_mob || !carrier || !behaviour)
		return

	// Once labour has begun it carries the contractions and the birth itself.
	var/mob/living/carbon/carbon_carrier = carrier
	var/in_labour = istype(carbon_carrier) && carbon_carrier.has_status_effect(/datum/status_effect/labour)
	if(behaviour.contraction_lines && !in_labour && COOLDOWN_FINISHED(src, contraction_cooldown))
		COOLDOWN_START(src, contraction_cooldown, 25 SECONDS)
		var/message = contraction_message || "My %CONTAINER% contracts tightly around the hatchling inside."
		to_chat(carrier, span_warning(format_inside_message(message)))

	if(!in_labour && COOLDOWN_FINISHED(src, pulse_cooldown))
		COOLDOWN_START(src, pulse_cooldown, behaviour.interval)
		INVOKE_ASYNC(src, PROC_REF(pulse))

	follow_growth()
	if(!in_labour && wants_to_leave())
		if(leaves_by_mouth())
			INVOKE_ASYNC(src, PROC_REF(climb_out_by_mouth))
		else if(istype(carbon_carrier))
			carbon_carrier.start_labour(holder, container)
		else
			INVOKE_ASYNC(src, PROC_REF(birth_hatchling))

/datum/component/internal_womb_hatchling/proc/handle_death(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(release_hatchling), TRUE)

/datum/component/internal_womb_hatchling/proc/birth_hatchling()
	var/obj/item/organ/genitals/filling_organ/birth_hole = container?.get_birth_canal()
	var/mob/living/birth_carrier = carrier
	var/birth_girth = get_passenger_birth_girth(holder)
	var/has_opening = istype(birth_hole) && birth_hole.orifice_type
	// The canal's own storage hook passes inner-layer removals; a holder held elsewhere, or deeper, passes here.
	var/passes_opening = has_opening && (birth_hole != container || SEND_SIGNAL(birth_hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, holder) != STORAGE_LAYER_INNER)
	// Judge the fit before the passage widens the opening to the newborn.
	var/share = 0
	var/ease = 0
	var/datum/orifice/opening = has_opening ? birth_hole.get_orifice() : null
	if(has_opening && iscarbon(birth_carrier))
		var/mob/living/carbon/judging_carrier = birth_carrier
		share = judging_carrier.get_birth_pleasure_share(opening, birth_girth)
		ease = judging_carrier.get_birth_pleasure_share(opening, birth_girth, FALSE)
	if(!release_hatchling(FALSE, ease))
		return FALSE
	if(QDELETED(birth_hole))
		opening = null
	if(passes_opening && opening)
		opening.pass_through(birth_girth, SEX_FORCE_MID, birth_carrier)
	if(has_opening && iscarbon(birth_carrier))
		var/mob/living/carbon/feeling_carrier = birth_carrier
		feeling_carrier.feel_birth_passage(share, opening)
	return TRUE

/datum/component/internal_womb_hatchling/proc/release_hatchling(silent = FALSE, ease = 0)
	if(!holder?.held_mob)
		return FALSE

	var/turf/release_location = get_turf(carrier || holder)
	if(!release_location)
		return FALSE

	holder.allow_internal_release = FALSE

	// Keep the hatchling trapped until the holder is fully out of organ storage; it hangs off the body, so ask the list.
	if(holder.is_in_hole_storage() || (container && SEND_SIGNAL(container, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, holder)))
		var/removed_from_storage = FALSE
		if(container)
			removed_from_storage = SEND_SIGNAL(container, COMSIG_BODYSTORAGE_TRY_REMOVE, holder, null, BODYSTORAGE_REMOVE_INTERNAL)
		if(!removed_from_storage)
			removed_from_storage = holder.remove_from_hole_storage()
		if(!removed_from_storage || holder.is_in_hole_storage())
			return FALSE

	holder.forceMove(release_location)
	if(holder.is_inside_storage_organ())
		return FALSE

	holder.allow_internal_release = TRUE

	if(!silent && carrier)
		var/message = birth_message || "[carrier] gives birth from [carrier.p_their()] [location_name]!"
		message = replacetext(message, "%CONTAINER%", location_name)
		message = replacetext(message, "%CARRIER%", "[carrier]")
		carrier.visible_message(
			span_warning(message),
			span_love("My [location_name] clenches and forces the hatchling out!")
		)
		// A carbon with an opening sounds the passage in feel_birth_passage; the rest keep the splatter.
		var/obj/item/organ/genitals/filling_organ/sounding_canal = container?.get_birth_canal()
		if(!iscarbon(carrier) || !istype(sounding_canal) || !sounding_canal.orifice_type)
			playsound(carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
		// A hard passage floors her; an easy one only takes her breath.
		if(ease < 0.5)
			carrier.Knockdown(50, TRUE, TRUE)
			carrier.Stun(40, TRUE, TRUE)
		carrier.adjust_stamina(90 * (1 - ease * 0.75))

	var/mob/living/freed = holder.held_mob
	if(!holder.release(FALSE))
		return FALSE
	// Out in the world it may think again.
	var/datum/ai_controller/freed_brain = freed?.ai_controller
	if(istype(freed_brain) && !freed.client)
		freed_brain.set_ai_status(AI_STATUS_ON)
	// The hatch already counted toward the birth limit; the birth itself does not.
	qdel(holder)
	return TRUE
