/datum/sex_session_lock
	var/mob/living/locked_host
	var/locked_organ_slot
	var/obj/item/locked_item
	var/hard_lock = TRUE

/datum/sex_session_lock/New(mob/_host, _locked_slot, obj/item/_locked_item, _hard_lock = TRUE)
	. = ..()
	locked_host = _host
	locked_organ_slot = _locked_slot
	locked_item = _locked_item
	hard_lock = _hard_lock
	LAZYADD(GLOB.locked_sex_objects, src)

/datum/sex_session_lock/Destroy(force, ...)
	. = ..()
	LAZYREMOVE(GLOB.locked_sex_objects, src)
	locked_host = null
	locked_item = null
	hard_lock = null

/datum/storage_tracking_entry
	var/obj/item/stored_item = null
	var/mob/living/original_owner = null
	var/insertion_time = null
	var/hole_id = null
	var/stored_by_ckey = null

/datum/storage_tracking_entry/New(obj/item/item, mob/living/owner, hole_id_param, mob/living/stored_by)
	stored_item = item
	original_owner = owner
	insertion_time = world.time
	hole_id = hole_id_param
	if(stored_by?.ckey)
		stored_by_ckey = stored_by.ckey

/datum/storage_tracking_entry/Destroy()
	stored_item = null
	original_owner = null
	return ..()


/datum/sex_action
	abstract_type = /datum/sex_action

	/// Display name of the action
	var/name = "Generic Action"
	///Description for hover
	var/description = "Generic desc"

	/// Whether this action can continue indefinitely
	var/continous = TRUE
	/// How long each iteration takes
	var/do_time = 3.3 SECONDS
	/// Stamina cost per iteration
	var/stamina_cost = 0.5
	/// Whether to check if user is incapacitated
	var/check_incapacitated = TRUE
	/// Whether participants must be on same tile
	var/check_same_tile = FALSE
	/// Whether the action can be performed at distance
	var/check_distance = TRUE
	/// Whether this requires a grab
	var/require_grab = FALSE
	/// Minimum grab state required
	var/required_grab_state = GRAB_PASSIVE
	/// Whether aggressive grab bypasses same tile requirement
	var/aggro_grab_instead_same_tile = FALSE
	/// Whether this action requires hole storage integration
	var/requires_hole_storage = FALSE
	/// Whether this action needs the initiator's hands to be free
	var/requires_free_hands = FALSE
	/// What hole ID this action uses (if any)
	var/hole_id = null
	/// What item type this action stores in the hole
	var/atom/stored_item_type = null
	/// Custom item name for the stored object
	var/stored_item_name = null
	/// Storage tracking for this action
	var/list/datum/storage_tracking_entry/tracked_storage = list()
	///this is a list of locks we created to prevent penis portal powers
	var/list/datum/sex_session_lock/sex_locks = list()
	///this is the priority of our action for the target so when ejaculate messages are looked at its highest priority
	var/target_priority = 10
	///this is the priority of our action for the user
	var/user_priority = 10
	/// Whether this action supports knotting on climax
	var/knot_on_finish = FALSE
	/// Whether this action can trigger knots
	var/can_knot = FALSE
	///basically for actions being done by the user where the target is the inserter set this to true // for example: riding, blowing, titjobbing etc
	var/flipped = FALSE
	/// Used for determining if the user should be gagged
	var/gags_user = FALSE
	/// Used for determining if the target should be gagged
	var/gags_target = FALSE
	/// Sound volume for actions
	var/action_volume = 50
	/// So that we don't spam messages with every thrust for example
	var/next_message_time = 0
	/// Whether this running action should stop on its next loop check
	var/stop_requested = FALSE
	/// Which hand this action reserved, if any
	var/selected_hand = null
	/// Which zone the local user is using for interaction-menu filtering
	var/user_menu_zone_mask = SEX_UI_ZONE_ANY
	/// Which zone on the other side this action focuses on for interaction-menu filtering
	var/target_menu_zone_mask = SEX_UI_ZONE_ANY

/datum/sex_action/Destroy()
	// Clean up any tracked storage entries
	for(var/datum/storage_tracking_entry/entry in tracked_storage)
		qdel(entry)
	tracked_storage.Cut()

	for(var/datum/sex_session_lock/lock in sex_locks)
		qdel(lock)
	sex_locks.Cut()

	return ..()

/datum/sex_action/proc/shows_on_menu(mob/living/user, mob/living/target)
	return TRUE

/datum/sex_action/proc/get_menu_action_key()
	return "[type]"

/datum/sex_action/proc/build_runtime_instance()
	return new type

/datum/sex_action/proc/can_perform(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	if(requires_hole_storage)
		if(!check_hole_storage_available(user, target))
			return FALSE
	return TRUE

/datum/sex_action/proc/try_knot_on_climax(mob/living/user, mob/living/target)
	if(!knot_on_finish)
		return FALSE
	if(!can_knot)
		return FALSE

	var/datum/sex_session/session = get_sex_session(user, target)
	if(!session)
		return FALSE
	return SEND_SIGNAL(user, COMSIG_SEX_TRY_KNOT, target, session.force)

/datum/sex_action/proc/check_location_accessible(mob/living/user, mob/living/target, location = BODY_ZONE_CHEST, grabs = TRUE, skipundies = TRUE)
	var/obj/item/bodypart/bodypart = target.get_bodypart(location)
	var/self_target = FALSE
	if(target == user)
		self_target = TRUE

	if(src.check_same_tile && (user != target || self_target))
		var/same_tile = (get_turf(user) == get_turf(target))
		var/grab_bypass = (src.aggro_grab_instead_same_tile && user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE

	if(src.require_grab && (user != target || self_target))
		var/grabstate = user.get_highest_grab_state_on(target)
		if((grabstate == null || grabstate < src.required_grab_state))
			return FALSE

	var/hidden_slots = NONE
	for(var/obj/item/I in target.get_equipped_items())
		if(istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = I
			if(C.armor_class > AC_LIGHT && !C.allow_erp_equipped)
				hidden_slots |= C.body_parts_covered
	if(location in body_parts_covered2organ_names(hidden_slots))
		return FALSE

	if(location == BODY_ZONE_PRECISE_MOUTH)
		return target.has_mouth() && target.mouth_is_free()

	if(!bodypart)
		if(iscarbon(target))
			return FALSE
		if(location == BODY_ZONE_PRECISE_L_FOOT || location == BODY_ZONE_PRECISE_R_FOOT)
			return target.foot_is_free()
		return TRUE

	return TRUE
	/*if(self_target)
		grabs = FALSE

	var/result = get_location_accessible(target, location = location, grabs = grabs, skipundies = skipundies)
	return result*/

/datum/sex_action/proc/get_storage_receiver(mob/living/user, mob/living/target)
	return flipped ? user : target

/datum/sex_action/proc/get_storage_insertor(mob/living/user, mob/living/target)
	return flipped ? target : user

/datum/sex_action/proc/get_storage_check_item(mob/living/user, mob/living/target)
	if(stored_item_type == /obj/item/organ/genitals/penis)
		var/mob/living/storage_insertor = get_storage_insertor(user, target)
		return get_users_penis(storage_insertor)
	return null

/datum/sex_action/proc/get_hole_storage_force(mob/living/user, mob/living/target)
	var/datum/sex_session/session = get_sex_session(user, target)
	if(!session)
		return FALSE
	return session.get_current_force() >= SEX_FORCE_HIGH

/datum/sex_action/proc/can_fit_item_in_hole(mob/living/storage_owner, hole_slot, obj/item/item_to_check, force = FALSE)
	if(!storage_owner || !hole_slot || !item_to_check)
		return FALSE

	var/obj/item/organ/target_organ = storage_owner.getorganslot(hole_slot)
	if(!target_organ)
		return FALSE

	var/datum/component/body_storage/storage_comp = target_organ.GetComponent(/datum/component/body_storage)
	if(!storage_comp)
		return FALSE

	var/fit_result = storage_comp.check_fit(target_organ, item_to_check, STORAGE_LAYER_INNER, force)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return TRUE
	return FALSE

/datum/sex_action/proc/check_hole_storage_available(mob/living/user, mob/living/target)
	if(!hole_id || !stored_item_type)
		return TRUE // No storage requirements

	var/mob/living/storage_owner = get_storage_receiver(user, target)
	var/obj/item/item_to_check = get_storage_check_item(user, target)
	if(!item_to_check)
		return FALSE

	return can_fit_item_in_hole(storage_owner, hole_id, item_to_check, get_hole_storage_force(user, target))

/datum/sex_action/proc/get_users_penis(mob/living/user)
	if(!user)
		return null
	return user.getorganslot(ORGAN_SLOT_PENIS)

/datum/sex_action/proc/try_store_in_hole(mob/living/user, mob/living/target)
	if(!requires_hole_storage || !hole_id || !stored_item_type)
		return TRUE

	var/obj/item/organ/target_o = target.getorganslot(hole_id)
	if(!target_o)
		to_chat(user, span_warning("[target == user ? "My" : "[target]'s"] [hole_id] can't take items right now."))
		return FALSE

	var/datum/component/body_storage/storage_comp = target_o.GetComponent(/datum/component/body_storage)
	if(!storage_comp)
		to_chat(user, span_warning("[target == user ? "My" : "[target]'s"] [hole_id] can't take items right now."))
		return FALSE

	var/obj/item/item_to_store

	var/self = (user == target)
	var/datum/sex_session/session = get_sex_session(user, target)
	if(!session)
		return FALSE
	var/force = FALSE
	if(session.get_current_force() >= SEX_FORCE_HIGH)
		force = TRUE
	// Handle penis storage specially - create fake variant
	if(stored_item_type == /obj/item/organ/genitals/penis)
		var/obj/item/organ/genitals/penis/user_penis = get_users_penis(user)
		if(!user_penis)
			to_chat(user, span_warning("You don't have a penis to use!"))
			return FALSE

		// Create fake variant instead of removing real penis
		item_to_store = user_penis.create_fake_variant(user)
	else
		// Create the item to store
		item_to_store = new stored_item_type()
		if(stored_item_name)
			item_to_store.name = stored_item_name

	// Try to fit it in the hole
	var/success = SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_TRY_INSERT, item_to_store, STORAGE_LAYER_INNER, force)
	switch(success)
		if(INSERT_FEEDBACK_OK_FORCE)
			if(prob(15))
				var/stuffed_res = SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					if(self)
						to_chat(user, session.spanify_force("Something inside my [hole_id] slips deeper!"))
					else
						user.visible_message(session.spanify_force("Something inside [target]'s [hole_id] slips deeper!"))
		if(INSERT_FEEDBACK_ALMOST_FULL)
			if(self)
				to_chat(user, session.spanify_force("I feel like my [hole_id] can just barely fit [item_to_store.name]..."))
			else
				user.visible_message(session.spanify_force("I feel like [target]'s [hole_id] can just barely fit my [item_to_store.name]..."))
		if(INSERT_FEEDBACK_STUFFED)
			if(force && prob(50))
				var/stuffed_res = SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					if(self)
						to_chat(user, session.spanify_force("Something inside my [hole_id] slips deeper!"))
					else
						user.visible_message(session.spanify_force("Something inside [target]'s [hole_id] slips deeper!"))
			else
				to_chat(user, span_warning("[target]'s [hole_id] can't accommodate my [item_to_store.name]!"))
				SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, item_to_store, STORAGE_LAYER_INNER)
				addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
				return FALSE

		if(INSERT_FEEDBACK_TRY_FORCE)
			if(self)
				to_chat(user, session.spanify_force("I feel like \the [item_to_store.name] might fit in my [hole_id] if I just use more force."))
			else
				user.visible_message(session.spanify_force("I feel like my [item_to_store.name] might fit in [target]'s [hole_id] if I just use more force."))
			SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, item_to_store, STORAGE_LAYER_INNER)
			addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
			return FALSE
		if(FALSE)
			to_chat(user, span_warning("[target]'s [hole_id] can't accommodate [item_to_store.name]!"))
			SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, item_to_store, STORAGE_LAYER_INNER)
			addtimer(CALLBACK(src, PROC_REF(qdel), item_to_store), 2)
			return FALSE

	// Track the storage
	var/datum/storage_tracking_entry/entry = new(item_to_store, user, hole_id, user)
	tracked_storage += entry

	return TRUE

/datum/sex_action/proc/remove_from_hole(mob/living/user, mob/living/target, silent = FALSE)
	if(!requires_hole_storage || !hole_id)
		return TRUE

	var/obj/item/organ/target_o = target.getorganslot(hole_id)
	for(var/datum/storage_tracking_entry/entry in tracked_storage)
		if(entry.hole_id == hole_id && entry.stored_item)
			var/obj/item/stored_item = entry.stored_item

			if(istype(stored_item, /obj/item/penis_fake))
				var/obj/item/penis_fake/fake_penis = stored_item
				var/mob/living/original_owner = find_original_owner_by_ckey(fake_penis.original_owner_ckey)
				if(target_o)
					SEND_SIGNAL(target_o, COMSIG_BODYSTORAGE_FORCE_REMOVE, fake_penis, STORAGE_LAYER_INNER)
				if(!silent)
					if(original_owner)
						to_chat(original_owner, span_notice("Your penis has been withdrawn from [target]'s [hole_id]."))
						if(original_owner != user)
							to_chat(user, span_notice("Withdrew [original_owner.name]'s penis from [target]'s [hole_id]."))
					else
						to_chat(user, span_notice("Withdrew penis from [target]'s [hole_id]."))
				qdel(stored_item)
			else
				if(!silent)
					to_chat(user, span_notice("Removed [stored_item.name] from [target]'s [hole_id]."))
				qdel(stored_item)

			tracked_storage -= entry
			qdel(entry)

	return TRUE

/datum/sex_action/proc/find_original_owner_by_ckey(target_ckey)
	if(!target_ckey)
		return null

	for(var/mob/living/H in GLOB.mob_living_list)
		if(H.ckey == target_ckey)
			return H

	return null

/datum/sex_action/proc/on_start(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	if(gags_user)
		user.mouth_blocked = TRUE
	if(gags_target)
		target.mouth_blocked = TRUE
	if(requires_hole_storage)
		if(flipped)
			if(!try_store_in_hole(target, user))
				return FALSE
		else
			if(!try_store_in_hole(user, target))
				return FALSE
	lock_sex_object(user, target)
	return TRUE

/datum/sex_action/proc/on_perform(mob/living/user, mob/living/target)
	return

/datum/sex_action/proc/on_finish(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	if(gags_user)
		user.mouth_blocked = FALSE
	if(gags_target)
		target.mouth_blocked = FALSE
	if(requires_hole_storage)
		if(flipped)
			remove_from_hole(target, user)
		else
			remove_from_hole(user, target)
	unlock_sex_object(user, target)
	return

/datum/sex_action/proc/is_finished(mob/living/user, mob/living/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(sex_session.finished_check())
		return TRUE
	return FALSE


/datum/sex_action/proc/lock_sex_object(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/proc/add_sex_lock(mob/living/locked_host, locked_organ_slot, obj/item/locked_item, hard_lock = TRUE)
	sex_locks |= new /datum/sex_session_lock(locked_host, locked_organ_slot, locked_item, hard_lock)

/datum/sex_action/proc/find_available_hand(mob/living/user)
	if(!user || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return null

	var/list/hand_order = list(user.get_active_precise_hand(), user.get_inactive_precise_hand())
	for(var/hand_slot in hand_order)
		if(!hand_slot)
			continue
		if(!user.get_bodypart(hand_slot))
			continue
		if(check_sex_lock(user, hand_slot))
			continue
		return hand_slot
	return null

/datum/sex_action/proc/get_hand_lock_slot(mob/living/user)
	if(selected_hand)
		return selected_hand
	selected_hand = find_available_hand(user)
	return selected_hand

/datum/sex_action/proc/unlock_sex_object(mob/living/user, mob/living/target)
	for(var/datum/sex_session_lock/lock as anything in sex_locks)
		qdel(lock)
	sex_locks.Cut()

/datum/sex_action/proc/handle_climax_message(mob/living/user, mob/living/target, must_flip = FALSE) //must_flip is for handling partner's message
	return

/datum/sex_action/proc/check_sex_lock(mob/locked, organ_slot, obj/item/item, obj/item/storage_item)
	if(!organ_slot && !item)
		return FALSE

	for(var/datum/sex_session_lock/lock as anything in GLOB.locked_sex_objects)
		if(lock.locked_host == locked)
			if(!lock.hard_lock)
				continue
			var/item_lock = ((lock.locked_item == item) && lock.locked_item)
			var/organ_lock = ((lock.locked_organ_slot == organ_slot) && lock.locked_organ_slot)
			if(!item_lock && !organ_lock)
				continue
			if(organ_lock && storage_item && can_fit_item_in_hole(locked, organ_slot, storage_item))
				continue
			return TRUE
	return FALSE


/datum/sex_action/proc/do_onomatopoeia(mob/living/user)
	user.balloon_alert_to_viewers("Plap!")

/datum/sex_action/proc/show_sex_effects(mob/living/user)
	for(var/i in 1 to rand(1, 3))
		if(!user.cmode) // Combat mode
			new /obj/effect/temp_visual/heart/sex_effects(get_turf(user))
		else
			new /obj/effect/temp_visual/heart/sex_effects/red_heart(get_turf(user))


/datum/sex_action/proc/can_show_action_message(mob/living/user, mob/living/target)
	if(world.time >= next_message_time)
		var/datum/sex_session/sex_session = get_sex_session(user, target)
		var/speed_time = 40
		if(sex_session)
			speed_time = rand(10, 100 - sex_session.get_current_speed() * 10)
		next_message_time = world.time + speed_time
		return TRUE
	return FALSE

/datum/sex_action/proc/matches_ui_filters(user_filter, target_filter)
	if(user_filter != SEX_UI_ZONE_ANY && !(user_menu_zone_mask & user_filter))
		return FALSE
	if(target_filter != SEX_UI_ZONE_ANY && !(target_menu_zone_mask & target_filter))
		return FALSE
	return TRUE
