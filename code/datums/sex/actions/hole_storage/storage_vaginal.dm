
/datum/sex_action/hole_storage/vagina_store
	name = "Stuff pussy"
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/hole_storage/vagina_store/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/dildo = user.get_active_held_item()
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA, null, dildo))
		return FALSE
	if(!dildo?.can_enter_body_storage_layer(STORAGE_LAYER_INNER))
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
	var/obj/item/dildo = user.get_active_held_item()

	if(user == target)
		target_organ = user.getorganslot(hole_id)
		to_chat(user, spanify_force("I start inserting \the [dildo] in my pussy..."))
	else
		target_organ = target.getorganslot(hole_id)
		user.visible_message(span_warning("[user] starts inserting \the [dildo] in [target]'s pussy..."))

	// The hole sets the pace: the same time the holes window would take for this toy.
	time_toy_insert_cycle(target_organ, dildo)

	play_toy_reach_sound(target_organ, target, sex_volume)


/datum/sex_action/hole_storage/vagina_store/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/pain_amt = 2 //base pain amt to use
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
	var/use_force = (force >= SEX_FORCE_HIGH)
	// The shared slip roll: a tight, dry fit fumbles unless forced; the next cycle tries again.
	var/obj/item/organ/genitals/filling_organ/hole = target_organ
	if(istype(hole) && hole.roll_toy_insert_slip(dildo, use_force))
		if(self)
			to_chat(user, spanify_force("\The [dildo] slips from my grip and will not go in. It wants a slicker pussy, or more force."))
		else
			user.visible_message(spanify_force("\The [dildo] slips from my grip and will not go into [target]'s pussy."))
		return
	// The feel is judged before the insert widens the opening to the toy.
	var/feel = istype(hole) ? hole.get_hole_feel("insert") : ""
	var/success = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_TRY_INSERT, dildo, STORAGE_LAYER_INNER, use_force)
	switch(success)
		if(INSERT_FEEDBACK_OK)
			if(self)
				to_chat(user, spanify_force("I stuff \the [dildo] in my pussy[feel]..."))
			else
				user.visible_message(spanify_force("I stuff \the [dildo] in [target]'s pussy[feel]..."))
		if(INSERT_FEEDBACK_OK_FORCE)
			if(prob(15))
				var/stuffed_res = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, use_force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					pain_amt += 4
					if(self)
						to_chat(user, spanify_force("\The [dildo] slips deep inside of my pussy!"))
					else
						user.visible_message(spanify_force("\The [dildo] slips deep inside of [target]'s pussy!"))
			else
				pain_amt += 4
				if(self)
					to_chat(user, spanify_force("I force \the [dildo] in my pussy, fighting the pressure!"))
				else
					user.visible_message(spanify_force("I force \the [dildo] in [target]'s pussy, fighting the pressure!"))
		if(INSERT_FEEDBACK_ALMOST_FULL)
			pain_amt += 2
			if(self)
				to_chat(user, spanify_force("I stuff the \the [dildo] in my pussy, seems like it won't fit much more..."))
			else
				user.visible_message(spanify_force("I stuff the \the [dildo] in [target]'s pussy, seems like it won't fit much more..."))
		if(INSERT_FEEDBACK_STUFFED)
			if(use_force && prob(50))
				var/stuffed_res = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, use_force)
				if(stuffed_res == INSERT_FEEDBACK_OK_FORCE || stuffed_res == INSERT_FEEDBACK_OK)
					pain_amt += 2
					if(self)
						to_chat(user, spanify_force("\The [dildo] slips deep inside of my pussy!"))
					else
						user.visible_message(spanify_force("\The [dildo] slips deep inside of [target]'s pussy!"))
			else
				if(self)
					to_chat(user, spanify_force("My pussy is too full to stuff even \the [dildo] in."))
				else
					user.visible_message(spanify_force("[target]'s pussy is too full to stuff even \the [dildo] in."))
				stop_runtime()
				return
		if(INSERT_FEEDBACK_TRY_FORCE)
			pain_amt += 3
			if(self)
				to_chat(user, spanify_force("I feel like \the [dildo] might fit with more force, or something slick."))
			else
				user.visible_message(spanify_force("I feel like \the [dildo] might fit in [target]'s pussy with more force, or something slick."))
		if(INSERT_FEEDBACK_BLOCKED)
			if(self)
				to_chat(user, spanify_force("My pussy is blocked."))
			else
				user.visible_message(spanify_force("[target]'s pussy is blocked."))
			stop_runtime()
			return
		if(FALSE)
			if(self)
				to_chat(user, spanify_force("I fail to stuff \the [dildo] in my pussy."))
			else
				user.visible_message(spanify_force("I fail to stuff \the [dildo] in [target]'s pussy."))
			stop_runtime()
			return

	user.update_inv_hands()
	user.update_a_intents()
	perform_sex_action(target, user, 0.5, pain_amt, 0.5)
	handle_passive_ejaculation()

/datum/sex_action/hole_storage/vagina_remove
	name = "Empty pussy"
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

	// Pick the first item now so the first cycle already takes the holes window's time for it.
	pending_toy = choose_toy_to_reach(target_organ, STORAGE_LAYER_INNER)

	play_toy_reach_sound(target_organ, target, sex_volume)


/datum/sex_action/hole_storage/vagina_remove/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/pain_amt = 1 //base pain amt to use

	var/self = (user == target)

	if(!target_organ)
		if(self)
			target_organ = user.getorganslot(hole_id)
		else
			target_organ = target.getorganslot(hole_id)

	var/obj/item/organ/genitals/filling_organ/hole = target_organ
	var/obj/item/removed_item = toy_still_in_reach(hole, pending_toy, STORAGE_LAYER_INNER) ? pending_toy : choose_toy_to_reach(hole, STORAGE_LAYER_INNER)
	pending_toy = null
	if(!removed_item || !istype(hole))
		to_chat(user, spanify_force("I couldn't find anything inside..."))
		stop_runtime()
		return
	// The shared grip roll: the same odds, slips and passage the holes window gives.
	var/feel = hole.get_hole_feel("withdraw")
	switch(hole.resolve_toy_removal(removed_item, STORAGE_LAYER_INNER, user))
		if(TOY_REMOVE_SLIPPED_DEEPER)
			if(self)
				to_chat(user, spanify_force("\The [removed_item] slips from my fingers and deeper into my pussy, past where I can reach."))
			else
				user.visible_message(spanify_force("\The [removed_item] slips from my fingers and deeper into [target]'s pussy."))
			pending_toy = choose_toy_to_reach(hole, STORAGE_LAYER_INNER)
			return
		if(TOY_REMOVE_NO_GRIP)
			to_chat(user, spanify_force("I can't get a grip on \the [removed_item]..."))
			pending_toy = removed_item
			return
		if(TOY_REMOVE_STUCK)
			to_chat(user, spanify_force("\The [removed_item] will not come."))
			stop_runtime()
			return
	if(user.get_active_held_item())
		user.visible_message(spanify_force("The [removed_item] falls down on the floor..."))
		removed_item.doMove(get_turf(user))
	else
		if(self)
			to_chat(user, spanify_force("I fish out the [removed_item] from my pussy[feel]..."))
		else
			user.visible_message(spanify_force("I fish out the [removed_item] from [target]'s pussy[feel]..."))
		removed_item.doMove(get_turf(user))
		user.put_in_active_hand(removed_item)
	perform_sex_action(target, user, 0.5, pain_amt, 0.5)
	handle_passive_ejaculation()
	pending_toy = choose_toy_to_reach(hole, STORAGE_LAYER_INNER)


/datum/sex_action/hole_storage/vagina_remove_deep
	name = "Deep-empty pussy"
	hole_id = ORGAN_SLOT_VAGINA
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
	// Pick the first item now so the first push already takes the holes window's time for it.
	pending_toy = choose_toy_to_reach(target_organ, STORAGE_LAYER_DEEP)

	to_chat(user, span_warning("I brace myself and start pushing out items from deep inside my pussy..."))


	play_toy_reach_sound(target_organ, target, sex_volume)


/datum/sex_action/hole_storage/vagina_remove_deep/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/pain_amt = 1 //base pain amt to use

	if(!target_organ)
		target_organ = target.getorganslot(hole_id)

	var/obj/item/organ/genitals/filling_organ/hole = target_organ
	var/obj/item/removed_item = toy_still_in_reach(hole, pending_toy, STORAGE_LAYER_DEEP) ? pending_toy : choose_toy_to_reach(hole, STORAGE_LAYER_DEEP)
	pending_toy = null

	target.adjust_stamina(15)
	target.adjust_energy(-20)

	to_chat(user, spanify_force("I *squeeze* my pussy and try to push..."))
	if(!removed_item || !istype(hole))
		to_chat(user, span_love("...But nothing comes out, and I finally feel empty."))
		stop_runtime()
		return
	// The shared push roll: deep items come hard, a flared base or lube helps, and they pass the opening.
	var/feel = hole.get_hole_feel("withdraw")
	switch(hole.resolve_toy_removal(removed_item, STORAGE_LAYER_DEEP, user))
		if(TOY_REMOVE_NO_GRIP, TOY_REMOVE_SLIPPED_DEEPER)
			to_chat(user, span_love("...But nothing comes out, yet I can still feel it in there."))
			pending_toy = removed_item
			return
		if(TOY_REMOVE_STUCK)
			to_chat(user, spanify_force("...But \the [removed_item] will not come."))
			stop_runtime()
			return

	user.visible_message("<span class='love_mid'>[user] tenses up and pushes [removed_item] out of their pussy.</span>", "<span class='love_mid'>With some effort, I push out [removed_item][feel].</span>")
	removed_item.doMove(get_turf(user))

	perform_sex_action(target, user, 0.5, pain_amt, 0.5)
	handle_passive_ejaculation()
	pending_toy = choose_toy_to_reach(hole, STORAGE_LAYER_DEEP)
