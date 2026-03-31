
/datum/sex_action/hole_storage/vagina_store
	name = "Store items in vagina"
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/hole_storage/vagina_store/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/dildo = user.get_active_held_item()
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA, null, dildo))
		return FALSE
	if(!dildo)
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/vagina_store/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/dildo = user.get_active_held_item()
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!dildo)
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA, null, dildo))
		return FALSE
	if(!can_fit_item_in_hole(target, hole_id, dildo, get_hole_storage_force(user, target)))
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/vagina_store/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/obj/item/dildo = user.get_active_held_item()

	if(user == target)
		target_organ = user.getorganslot(hole_id)
		to_chat(user, sex_session.spanify_force("I start inserting \the [dildo] in my pussy..."))
	else
		target_organ = target.getorganslot(hole_id)
		user.visible_message(span_warning("[user] starts inserting \the [dildo] in [target]'s pussy..."))

	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)


/datum/sex_action/hole_storage/vagina_store/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 2 //base pain amt to use
	var/self = (user == target)
	if(!target_organ)
		if(self)
			target_organ = user.getorganslot(hole_id)
		else
			target_organ = target.getorganslot(hole_id)
	var/datum/sex_session/sex_session = get_sex_session(user, target)

	var/obj/item/dildo = user.get_active_held_item()
	if(!dildo)
		sex_session.stop_current_action(src)
		return
	var/force = FALSE
	if(sex_session.get_current_force() >= SEX_FORCE_HIGH)
		force = TRUE
	var/success = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_TRY_INSERT, dildo, STORAGE_LAYER_INNER, force)
	switch(success)
		if(INSERT_FEEDBACK_OK)
			if(self)
				to_chat(user, sex_session.spanify_force("I stuff \the [dildo] in my pussy..."))
			else
				user.visible_message(sex_session.spanify_force("I stuff \the [dildo] in [target]'s pussy..."))
		if(INSERT_FEEDBACK_OK_FORCE)
			if(prob(15))
				var/stuffed_res = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					pain_amt += 4
					if(self)
						to_chat(user, sex_session.spanify_force("\The [dildo] slips deep inside of my pussy!"))
					else
						user.visible_message(sex_session.spanify_force("\The [dildo] slips deep inside of [target]'s pussy!"))
			else
				pain_amt += 4
				if(self)
					to_chat(user, sex_session.spanify_force("I force \the [dildo] in my pussy, fighting the pressure!"))
				else
					user.visible_message(sex_session.spanify_force("I force \the [dildo] in [target]'s pussy, fighting the pressure!"))
		if(INSERT_FEEDBACK_ALMOST_FULL)
			pain_amt += 2
			if(self)
				to_chat(user, sex_session.spanify_force("I stuff the \the [dildo] in my pussy, seems like it won't fit much more..."))
			else
				user.visible_message(sex_session.spanify_force("I stuff the \the [dildo] in [target]'s pussy, seems like it won't fit much more..."))
		if(INSERT_FEEDBACK_STUFFED)
			if(force && prob(50))
				var/stuffed_res = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					pain_amt += 2
					if(self)
						to_chat(user, sex_session.spanify_force("\The [dildo] slips deep inside of my pussy!"))
					else
						user.visible_message(sex_session.spanify_force("\The [dildo] slips deep inside of [target]'s pussy!"))
			else
				if(self)
					to_chat(user, sex_session.spanify_force("My pussy is too full to stuff even \the [dildo] in."))
				else
					user.visible_message(sex_session.spanify_force("[target]'s pussy is too full to stuff even \the [dildo] in."))
				sex_session.stop_current_action(src)
				return
		if(INSERT_FEEDBACK_TRY_FORCE)
			pain_amt += 3
			if(self)
				to_chat(user, sex_session.spanify_force("I feel like \the [dildo] might fit if I just use more force."))
			else
				user.visible_message(sex_session.spanify_force("I feel like \the [dildo] might fit in [target]'s pussy if I just use more force."))
		if(FALSE)
			if(self)
				to_chat(user, sex_session.spanify_force("I fail to stuff \the [dildo] in my pussy."))
			else
				user.visible_message(sex_session.spanify_force("I fail to stuff \the [dildo] in [target]'s pussy."))
			sex_session.stop_current_action(src)
			return

	user.update_inv_hands()
	user.update_a_intents()
	sex_session.perform_sex_action(user, target, 0.5, pain_amt, 0.5, src)
	sex_session.handle_passive_ejaculation()

/datum/sex_action/hole_storage/vagina_remove
	name = "Remove items from vagina"
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/hole_storage/vagina_remove/shows_on_menu(mob/living/user, mob/living/target)
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(user == target)
		target_organ = user.getorganslot(hole_id)
	else
		target_organ = target.getorganslot(hole_id)
	if(!length(target_organ.get_body_storage_items_for_interaction(STORAGE_LAYER_INNER, BODYSTORAGE_REMOVE_MANUAL)))
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/vagina_remove/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(user.get_active_held_item())
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/vagina_remove/on_start(mob/living/user, mob/living/target)
	. = ..()

	if(user == target)
		target_organ = user.getorganslot(hole_id)
		to_chat(user, span_warning("I start removing items from my pussy..."))
	else
		target_organ = target.getorganslot(hole_id)
		user.visible_message(span_warning("[user] starts removing items from [target]'s pussy..."))

	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)


/datum/sex_action/hole_storage/vagina_remove/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 1 //base pain amt to use

	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/self = (user == target)

	if(!target_organ)
		if(self)
			target_organ = user.getorganslot(hole_id)
		else
			target_organ = target.getorganslot(hole_id)

	var/list/interactable_items = target_organ.get_body_storage_items_for_interaction(STORAGE_LAYER_INNER, BODYSTORAGE_REMOVE_MANUAL)
	var/obj/item/removed_item = length(interactable_items) ? pick(interactable_items) : null
	if(removed_item && !SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_TRY_REMOVE, removed_item, STORAGE_LAYER_INNER, BODYSTORAGE_REMOVE_MANUAL))
		removed_item = null
	if(!removed_item)
		to_chat(user, sex_session.spanify_force("I couldn't find anything inside..."))
		sex_session.stop_current_action(src)
		return
	if(user.get_active_held_item())
		user.visible_message(sex_session.spanify_force("The [removed_item] falls down on the floor..."))
		removed_item.doMove(get_turf(user))
	else
		if(self)
			to_chat(user, sex_session.spanify_force("I fish out the [removed_item] from my pussy..."))
		else
			user.visible_message(sex_session.spanify_force("I fish out the [removed_item] from [target]'s pussy..."))
		removed_item.doMove(get_turf(user))
		user.put_in_active_hand(removed_item)
	sex_session.perform_sex_action(user, target, 0.5, pain_amt, 0.5, src)
	sex_session.handle_passive_ejaculation()


/datum/sex_action/hole_storage/vagina_remove_deep
	name = "Push out items from deep inside pussy"
	hole_id = ORGAN_SLOT_VAGINA
	do_time = 100
	var/fail_counter = 0
	var/list/stored_items_layer

/datum/sex_action/hole_storage/vagina_remove_deep/shows_on_menu(mob/living/user, mob/living/target)
	if(!target.getorganslot(hole_id))
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	if(user != target)
		return FALSE

	target_organ = target.getorganslot(hole_id)
	stored_items_layer = target_organ.get_body_storage_items_for_interaction(STORAGE_LAYER_DEEP, BODYSTORAGE_REMOVE_MANUAL)
	if(!stored_items_layer.len)
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/vagina_remove_deep/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(user.get_active_held_item())
		return FALSE
	if(user != target)
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/vagina_remove_deep/on_start(mob/living/user, mob/living/target)
	. = ..()
	target_organ = user.getorganslot(hole_id)
	stored_items_layer = target_organ.get_body_storage_items_for_interaction(STORAGE_LAYER_DEEP, BODYSTORAGE_REMOVE_MANUAL)

	to_chat(user, span_warning("I brace myself and start pushing out items from deep inside my pussy..."))

	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)


/datum/sex_action/hole_storage/vagina_remove_deep/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 1 //base pain amt to use

	if(!target_organ)
		target_organ = target.getorganslot(hole_id)

	stored_items_layer = target_organ.get_body_storage_items_for_interaction(STORAGE_LAYER_DEEP, BODYSTORAGE_REMOVE_MANUAL)

	var/datum/sex_session/sex_session = get_sex_session(user, target)

	target.adjust_stamina(15)
	target.adjust_energy(-20)

	to_chat(user, sex_session.spanify_force("I *squeeze* my pussy and try to push..."))
	if(prob(30))
		if(stored_items_layer.len)
			to_chat(user, span_love("...But nothing comes out, yet I can still feel it in there."))
			return
		else
			to_chat(user, span_love("...But nothing comes out, and I finally feel empty."))
			sex_session.stop_current_action(src)
			return

	var/obj/item/removed_item = length(stored_items_layer) ? pick(stored_items_layer) : null
	if(removed_item && !SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_TRY_REMOVE, removed_item, STORAGE_LAYER_DEEP, BODYSTORAGE_REMOVE_MANUAL))
		removed_item = null
	if(!removed_item)
		to_chat(user, sex_session.spanify_force("There was nothing inside."))
		sex_session.stop_current_action(src)
		return

	user.visible_message("<span class='love_mid'>[user] tenses up and pushes [removed_item] out of their pussy.</span>", "<span class='love_mid'>With some effort, I push out [removed_item].</span>")
	removed_item.doMove(get_turf(user))

	sex_session.perform_sex_action(user, target, 0.5, pain_amt, 0.5, src)
	sex_session.handle_passive_ejaculation()
