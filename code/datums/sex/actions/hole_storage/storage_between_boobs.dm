
/datum/sex_action/hole_storage/boobs_store
	name = "Stuff cleavage"
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	hole_id = ORGAN_SLOT_BREASTS

/datum/sex_action/hole_storage/boobs_store/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/dildo = user.get_active_held_item()
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_BREASTS, null, dildo))
		return FALSE
	if(!dildo?.can_enter_body_storage_layer(STORAGE_LAYER_INNER))
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/boobs_store/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/dildo = user.get_active_held_item()
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!dildo)
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_BREASTS, null, dildo))
		return FALSE
	if(!can_fit_item_in_hole(target, hole_id, dildo, get_hole_storage_force(user, target)))
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/boobs_store/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo = user.get_active_held_item()

	if(user == target)
		target_organ = user.getorganslot(hole_id)
		to_chat(user, spanify_force("I start inserting \the [dildo] between my boobs..."))
	else
		target_organ = target.getorganslot(hole_id)
		user.visible_message(span_warning("[user] starts inserting \the [dildo] between [target]'s boobs..."))

	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)


/datum/sex_action/hole_storage/boobs_store/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 0 //base pain amt to use
	var/self = (user == target)
	if(!target_organ)
		if(self)
			target_organ = user.getorganslot(hole_id)
		else
			target_organ = target.getorganslot(hole_id)


	var/obj/item/dildo = user.get_active_held_item()
	if(!dildo)
		stop_runtime()
		return
	var/success = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_TRY_INSERT, dildo, STORAGE_LAYER_INNER, FALSE)
	switch(success)
		if(INSERT_FEEDBACK_OK)
			if(self)
				to_chat(user, spanify_force("I stuff \the [dildo] between my boobs..."))
			else
				user.visible_message(spanify_force("I stuff \the [dildo] between [target]'s boobs..."))
		if(INSERT_FEEDBACK_ALMOST_FULL)
			if(self)
				to_chat(user, spanify_force("I stuff the \the [dildo] between my boobs, seems like they won't fit much more..."))
			else
				user.visible_message(spanify_force("I stuff the \the [dildo] between [target]'s boobs, seems like they won't fit much more..."))
		if(INSERT_FEEDBACK_STUFFED, INSERT_FEEDBACK_TRY_FORCE)
			if(self)
				to_chat(user, spanify_force("My boobs have too much between them to stuff \the [dildo] in."))
			else
				user.visible_message(spanify_force("[target]'s boobs have too much between them to stuff \the [dildo] in."))
			stop_runtime()
			return
		if(INSERT_FEEDBACK_BLOCKED)
			if(self)
				to_chat(user, spanify_force("My boobs are blocked."))
			else
				user.visible_message(spanify_force("[target]'s boobs are blocked."))
			stop_runtime()
			return
		if(FALSE)
			if(self)
				to_chat(user, spanify_force("I fail to stuff \the [dildo] between my boobs."))
			else
				user.visible_message(spanify_force("I fail to stuff \the [dildo] between [target]'s boobs."))
			stop_runtime()
			return

	user.update_inv_hands()
	user.update_a_intents()
	perform_sex_action(target, user, 0.5, pain_amt, 0)
	handle_passive_ejaculation()

/datum/sex_action/hole_storage/boobs_remove //do_time
	name = "Empty cleavage"
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	hole_id = ORGAN_SLOT_BREASTS

/datum/sex_action/hole_storage/boobs_remove/shows_on_menu(mob/living/user, mob/living/target)
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_BREASTS))
		return FALSE
	if(user == target)
		target_organ = user.getorganslot(hole_id)
	else
		target_organ = target.getorganslot(hole_id)
	var/list/stored_items = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_GET_LISTS)
	var/list/stored_items_layer = stored_items[STORAGE_LAYER_INNER]
	if(!stored_items_layer.len)
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/boobs_remove/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(user.get_active_held_item())
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/boobs_remove/on_start(mob/living/user, mob/living/target)
	. = ..()
	self = (user == target)

	if(user == target)
		target_organ = user.getorganslot(hole_id)
		to_chat(user, span_warning("I start removing items from between my boobs..."))
	else
		target_organ = target.getorganslot(hole_id)
		user.visible_message(span_warning("[user] starts removing items from between [target]'s boobs..."))

	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)


/datum/sex_action/hole_storage/boobs_remove/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 0 //base pain amt to use

	var/self = (user == target)

	if(!target_organ)
		if(self)
			target_organ = user.getorganslot(hole_id)
		else
			target_organ = target.getorganslot(hole_id)

	var/obj/item/removed_item
	removed_item = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_REMOVE_RAND_ITEM, STORAGE_LAYER_INNER)
	if(!removed_item)
		to_chat(user, spanify_force("I couldn't find anything inside..."))
		stop_runtime()
		return
	if(user.get_active_held_item())
		user.visible_message(spanify_force("The [removed_item] falls down on the floor..."))
		removed_item.doMove(get_turf(user))
	else
		if(self)
			to_chat(user, spanify_force("I fish out the [removed_item] from between my boobs..."))
		else
			user.visible_message(spanify_force("I fish out the [removed_item] from between [target]'s boobs..."))
		removed_item.doMove(get_turf(user))
		user.put_in_active_hand(removed_item)
	perform_sex_action(target, user, 0.5, pain_amt, 0)
	handle_passive_ejaculation()

