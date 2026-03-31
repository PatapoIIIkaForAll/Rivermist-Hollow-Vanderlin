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
	if(egg?.hatch_inside_host)
		INVOKE_ASYNC(src, PROC_REF(try_hatch_inside_host))
		return

	if(COOLDOWN_FINISHED(src, lay_cooldown))
		COOLDOWN_START(src, lay_cooldown, OVIPOSITION_LAY_COOLDOWN)
		if(prob(20))
			to_chat(carrier, span_warning("The egg in my [get_container_location_name()] feels ready to come out."))
		if(prob(10))
			lay_egg(get_turf(carrier), TRUE)

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
		to_chat(carrier, stage >= 3 ? span_warning(format_container_message(message)) : span_love(format_container_message(message)))

	if(stage == max_stage)
		var/ready_message = egg.get_ready_message()
		if(!ready_message)
			ready_message = "The egg in my %CONTAINER% is fully developed and wants out."
		to_chat(carrier, span_warning(format_container_message(ready_message)))

	update_egg_storage_bulk()

/datum/component/pregnancy/proc/get_container_location_name()
	return container?.get_oviposition_location_name() || "body"

/datum/component/pregnancy/proc/format_container_message(message)
	if(!message)
		return null

	var/formatted_message = replacetext(message, "%CONTAINER%", get_container_location_name())
	formatted_message = replacetext(formatted_message, "%EGG%", "[egg]")
	formatted_message = replacetext(formatted_message, "%CARRIER%", "[carrier]")
	return formatted_message

/datum/component/pregnancy/proc/update_egg_storage_bulk()
	if(!egg || laid)
		return

	var/datum/component/body_storage/storage = container?.GetComponent(/datum/component/body_storage)
	if(!storage || !max_stage)
		return

	var/new_bulk = max(1, stage) * 2
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

	if(!location)
		location = get_turf(carrier)
	if(!location)
		return FALSE
	if(!remove_from_host(BODYSTORAGE_REMOVE_INTERNAL))
		return FALSE

	carrier.visible_message(
		span_notice("[carrier] [container.get_oviposition_lay_verb()] an egg!"),
		span_love(container.get_oviposition_lay_self_message())
	)
	playsound(carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	carrier.Knockdown(60, TRUE, TRUE)
	carrier.Stun(60, TRUE, TRUE)
	carrier.adjust_stamina(forced ? 120 : 80)

	laid = TRUE
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

	var/atom/movable/hatch_result = create_hatch_result()
	if(!hatch_result)
		return FALSE

	if(isliving(hatch_result))
		var/mob/living/hatchling = hatch_result
		finalize_living_hatch(player, hatchling)
		return hatch_living_inside_host(hatchling)

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

	playsound(egg, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
	qdel(egg)

/datum/component/pregnancy/proc/poll_hatch_candidate(mob/user)
	var/poll_message = "Do you want to play as [mother_name ? "[mother_name]'s" : "someone's"] offspring?[egg_name ? " Their name will be [egg_name]." : ""]"
	var/list/mob/candidates = pollGhostCandidates(poll_message, null, null, FALSE, 30 SECONDS)

	if(!LAZYLEN(candidates))
		if(user && require_ghost_to_hatch)
			to_chat(user, span_info("The egg stays still. Maybe another soul will answer later."))
		return null

	return pick(candidates)

/datum/component/pregnancy/proc/create_hatch_result()
	if(!egg || !hatch_result_type || !ispath(hatch_result_type, /atom/movable))
		return null
	return new hatch_result_type(get_turf(egg))

/datum/component/pregnancy/proc/hatch_living_inside_host(mob/living/hatchling)
	if(!egg || !container || !carrier || !hatchling)
		qdel(hatchling)
		return FALSE

	if(!remove_from_host(BODYSTORAGE_REMOVE_INTERNAL))
		qdel(hatchling)
		return FALSE

	var/holder_type = egg.internal_hatch_holder_type
	if(!ispath(holder_type, /obj/item/mob_holder/internal_womb))
		holder_type = /obj/item/mob_holder/internal_womb

	var/obj/item/mob_holder/internal_womb/holder = new holder_type(get_turf(carrier))
	if(!holder.deposit(hatchling))
		SEND_SIGNAL(container, COMSIG_BODYSTORAGE_FORCE_INSERT, egg, STORAGE_LAYER_DEEP)
		qdel(holder)
		return FALSE

	holder.set_internal_bulk(egg.internal_hatch_holder_bulk)

	var/datum/component/body_storage/storage = container.GetComponent(/datum/component/body_storage)
	var/holder_layer = egg.internal_hatch_layer
	if(!storage?.available_layers[holder_layer])
		holder_layer = STORAGE_LAYER_DEEP

	SEND_SIGNAL(container, COMSIG_BODYSTORAGE_FORCE_INSERT, holder, holder_layer)
	holder.AddComponent(/datum/component/internal_womb_hatchling, container, carrier, get_container_location_name(), egg.internal_hatch_triggers_contractions, egg.internal_hatch_auto_birth, egg.internal_hatch_birth_delay, egg.internal_contraction_message, egg.internal_birth_message)

	var/hatch_message = egg.internal_hatch_message || egg.get_hatch_message()
	if(hatch_message)
		to_chat(carrier, span_warning(format_container_message(hatch_message)))
	playsound(carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
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
	if(newborn_start_scale > 0 && newborn_start_scale < 1 && newborn_growth_duration > 0)
		hatchling.AddComponent(/datum/component/newborn_growth, newborn_start_scale, newborn_growth_duration, 1, protected_parent)

	if(player)
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

	if(hatchling.mind && mother_name)
		if(egg?.hatch_inside_host)
			hatchling.mind.store_memory("[mother_name] carried you inside an embryo.")
		else
			hatchling.mind.store_memory("[mother_name] laid your egg.")

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
	var/trigger_contractions = FALSE
	var/auto_birth = FALSE
	var/birth_delay = 0
	var/contraction_message = null
	var/birth_message = null
	var/hatch_time = 0
	COOLDOWN_DECLARE(contraction_cooldown)

/datum/component/internal_womb_hatchling/Initialize(obj/item/organ/_container, mob/living/_carrier, _location_name = "womb", _trigger_contractions = FALSE, _auto_birth = FALSE, _birth_delay = 0, _contraction_message = null, _birth_message = null)
	if(!istype(parent, /obj/item/mob_holder/internal_womb))
		return COMPONENT_INCOMPATIBLE

	holder = parent
	container = _container
	carrier = _carrier
	location_name = _location_name || "womb"
	trigger_contractions = _trigger_contractions
	auto_birth = _auto_birth
	birth_delay = _birth_delay
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

	if(!holder?.held_mob || !carrier)
		return

	if(trigger_contractions && COOLDOWN_FINISHED(src, contraction_cooldown))
		COOLDOWN_START(src, contraction_cooldown, 25 SECONDS)
		var/message = contraction_message || "My %CONTAINER% contracts tightly around the hatchling inside."
		message = replacetext(message, "%CONTAINER%", location_name)
		message = replacetext(message, "%CARRIER%", "[carrier]")
		to_chat(carrier, span_warning(message))

	if(auto_birth && birth_delay > 0 && world.time >= hatch_time + birth_delay)
		birth_hatchling()

/datum/component/internal_womb_hatchling/proc/handle_death(datum/source)
	SIGNAL_HANDLER
	release_hatchling(TRUE)

/datum/component/internal_womb_hatchling/proc/birth_hatchling()
	return release_hatchling(FALSE)

/datum/component/internal_womb_hatchling/proc/release_hatchling(silent = FALSE)
	if(!holder?.held_mob)
		return FALSE

	var/turf/release_location = get_turf(carrier || holder)
	if(!release_location)
		return FALSE

	if(container)
		SEND_SIGNAL(container, COMSIG_BODYSTORAGE_TRY_REMOVE, holder, null, BODYSTORAGE_REMOVE_INTERNAL)

	holder.allow_internal_release = TRUE
	holder.forceMove(release_location)

	if(!silent && carrier)
		var/message = birth_message || "[carrier] gives birth from [carrier.p_their()] [location_name]!"
		message = replacetext(message, "%CONTAINER%", location_name)
		message = replacetext(message, "%CARRIER%", "[carrier]")
		carrier.visible_message(
			span_warning(message),
			span_love("My [location_name] clenches and forces the hatchling out!")
		)
		playsound(carrier, 'sound/effects/wounds/splatter.ogg', 70, TRUE)
		carrier.Knockdown(50, TRUE, TRUE)
		carrier.Stun(40, TRUE, TRUE)
		carrier.adjust_stamina(90)

	holder.release(TRUE)
	return TRUE
