/datum/sex_action/bladder
	abstract_type = /datum/sex_action/bladder
	menu_category = "fluids"
	stamina_cost = 0.05
	do_time = 3 SECONDS

/datum/sex_action/bladder/get_speed_multiplier()
	return 1

/datum/sex_action/bladder/proc/consented(mob/living/user, mob/living/target)
	return user.watersports_allowed() && target.watersports_allowed()

/datum/sex_action/bladder/proc/can_swallow(mob/living/drinker)
	return !!drinker.getorganslot(ORGAN_SLOT_STOMACH)

/datum/sex_action/bladder/proc/play_stream_sound(mob/living/target)
	playsound(target, pick(BLADDER_STREAM_SOUNDS), sex_volume * 0.5, TRUE, -2, ignore_walls = FALSE)

/datum/sex_action/bladder/stream
	abstract_type = /datum/sex_action/bladder/stream
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/bladder/stream/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target || !ishuman(target) || !user.get_bladder())
		return FALSE
	return consented(user, target)

/datum/sex_action/bladder/stream/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !ishuman(target) || !consented(user, target))
		return FALSE
	if(!(user.get_bladder()?.get_volume() >= BLADDER_STREAM_MIN_UNITS))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/bladder/stream/is_finished(mob/living/user, mob/living/target)
	if(..())
		return TRUE
	return !(user.get_bladder()?.get_volume() >= BLADDER_STREAM_MIN_UNITS)

/datum/sex_action/bladder/stream/onto
	abstract_type = /datum/sex_action/bladder/stream/onto
	var/coat_zone = FLUID_COAT_CHEST
	var/place_name = "chest"

/datum/sex_action/bladder/stream/onto/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] aims [user.p_their()] [bladder_stream_source(user)] at [target]'s [place_name] and lets go!"))

/datum/sex_action/bladder/stream/onto/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/component/bladder/bladder = user.get_bladder()
	if(!bladder)
		return
	var/mob/living/carbon/human/soaked = target
	bladder.release_onto_body(soaked, coat_zone, BLADDER_STREAM_UNITS)
	soaked.adjust_hygiene(-BLADDER_PEE_HYGIENE_LOSS)
	if(can_show_action_message(user, target))
		user.watersports_message(span_love("[user] pisses a hot, steady stream over [target]'s [place_name]..."))
	play_stream_sound(target)
	perform_sex_action(user, target, 0.5, 0, 0.2)
	perform_sex_action(target, user, 0.5, 0, 0.2)

/datum/sex_action/bladder/stream/onto/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] shakes the last drops over [target]'s [place_name]."))

/datum/sex_action/bladder/stream/onto/face
	name = "Piss on face"
	menu_tip = "Let a hot stream splash over their face."
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	coat_zone = FLUID_COAT_FACE
	place_name = "face"

/datum/sex_action/bladder/stream/onto/body
	name = "Piss on body"
	menu_tip = "Hose down their chest and belly."
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	coat_zone = FLUID_COAT_CHEST
	place_name = "chest"

/datum/sex_action/bladder/stream/onto/crotch
	name = "Piss on crotch"
	menu_tip = "Soak their crotch with a hot stream."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	coat_zone = FLUID_COAT_GROIN
	place_name = "crotch"

/datum/sex_action/bladder/stream/onto/legs
	name = "Piss on legs"
	menu_tip = "Let it run down their thighs."
	target_menu_zone_mask = SEX_UI_ZONE_LEGS
	coat_zone = FLUID_COAT_THIGHS
	place_name = "thighs"

/datum/sex_action/bladder/stream/mouth
	name = "Piss into mouth"
	menu_tip = "Fill their mouth with a hot stream to swallow."
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE

/datum/sex_action/bladder/stream/mouth/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!can_swallow(target))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/bladder/stream/mouth/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/bladder/stream/mouth/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] presses [user.p_their()] [bladder_stream_source(user)] to [target]'s lips and lets go!"))

/datum/sex_action/bladder/stream/mouth/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/component/bladder/bladder = user.get_bladder()
	if(!bladder)
		return
	var/stream = min(BLADDER_STREAM_UNITS, bladder.get_volume())
	var/swallowed = bladder.release_into(target, stream, INGEST, user)
	if(swallowed < stream)
		bladder.release_onto_body(target, FLUID_COAT_FACE, stream - swallowed)
	if(can_show_action_message(user, target))
		user.watersports_message(span_love("[target] gulps down [user]'s piss..."))
		to_chat(target, span_love(bladder_drink_text(target)))
	target.make_mouth_noise("gluck")
	perform_sex_action(user, target, 0.5, 0, 0.2)
	perform_sex_action(target, user, 0.5, 0, 0.2)

/datum/sex_action/bladder/stream/mouth/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] pulls away from [target]'s mouth."))

/datum/sex_action/bladder/stream/inside
	name = "Piss inside"
	menu_tip = "Let go while buried deep inside them."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS | SEX_UI_ZONE_MISC | SEX_UI_ZONE_MOUTH

/datum/sex_action/bladder/stream/inside/shows_on_menu(mob/living/user, mob/living/target)
	if(!..())
		return FALSE
	return !!find_penetration(user, target)

/datum/sex_action/bladder/stream/inside/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!find_penetration(user, target)

/datum/sex_action/bladder/stream/inside/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!find_penetration(user, target)

/datum/sex_action/bladder/stream/inside/proc/find_penetration(mob/living/user, mob/living/target)
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return null
	var/static/list/open_holes = list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, BODY_ZONE_PRECISE_MOUTH)
	for(var/datum/sex_action/action as anything in target.sex_scene?.active_actions)
		if(action == src)
			continue
		if(istype(action, /datum/sex_action/docking/urethra))
			var/datum/sex_action/docking/urethra/dock = action
			if(dock.get_inner_holder(dock.action_user, dock.action_target) == user && dock.get_sleeve_holder(dock.action_user, dock.action_target) == target)
				return dock
			continue
		if(!(action.hole_id in open_holes))
			continue
		if(action.get_inserted_penis_owner(action.action_user, action.action_target) != user)
			continue
		var/mob/living/receiver = user == action.action_user ? action.action_target : action.action_user
		if(receiver == target)
			return action
	return null

/datum/sex_action/bladder/stream/inside/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/datum/sex_action/penetration = find_penetration(user, target)
	user.watersports_message(span_warning("[user] holds still deep in [target]'s [bladder_hole_name(get_place_slot(penetration))] and lets go!"))

/datum/sex_action/bladder/stream/inside/proc/get_place_slot(datum/sex_action/penetration)
	if(istype(penetration, /datum/sex_action/docking/urethra))
		return DOCKING_KIND_URETHRA
	return penetration?.hole_id

/datum/sex_action/bladder/stream/inside/proc/get_spill_zone(hole_slot)
	switch(hole_slot)
		if(BODY_ZONE_PRECISE_MOUTH)
			return FLUID_COAT_FACE
		if(DOCKING_KIND_URETHRA)
			return FLUID_COAT_GROIN
	return FLUID_COAT_THIGHS

/datum/sex_action/bladder/stream/inside/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/component/bladder/bladder = user.get_bladder()
	var/datum/sex_action/penetration = find_penetration(user, target)
	if(!bladder || !penetration)
		return
	var/hole_slot = get_place_slot(penetration)
	var/stream = min(BLADDER_STREAM_UNITS, bladder.get_volume())
	var/moved = 0
	switch(hole_slot)
		if(BODY_ZONE_PRECISE_MOUTH)
			if(can_swallow(target))
				moved = bladder.release_into(target, stream, INGEST, user)
		if(DOCKING_KIND_URETHRA)
			var/datum/component/bladder/receiver = target.get_bladder()
			if(receiver)
				moved = receiver.receive_from(bladder.contents, stream, user)
				bladder.update_urge()
		else
			var/obj/item/organ/genitals/filling_organ/hole = target.getorganslot(hole_slot)
			if(istype(hole) && hole.reagents)
				moved = bladder.release_into(hole, stream, null, user)
	if(moved < stream)
		bladder.release_onto_body(target, get_spill_zone(hole_slot), stream - moved)
	if(can_show_action_message(user, target))
		user.watersports_message(span_love("[user] pumps hot piss deep into [target]'s [bladder_hole_name(hole_slot)]..."))
		if(hole_slot == DOCKING_KIND_URETHRA && moved <= 0)
			to_chat(target, span_love(bladder_urethra_backflow_text(target)))
		else
			to_chat(target, span_love(bladder_inside_text(target, hole_slot)))
	perform_sex_action(user, target, 0.5, 0, 0.2)
	perform_sex_action(target, user, 0.8, 0, 0.3)

/datum/sex_action/bladder/stream/inside/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] finishes emptying [user.p_them()]self into [target]."))

/datum/sex_action/bladder/press
	name = "Press on bladder"
	menu_tip = "Knead their belly right where it aches."
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	requires_free_hands = TRUE

/datum/sex_action/bladder/press/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target || !target.get_bladder())
		return FALSE
	return consented(user, target)

/datum/sex_action/bladder/press/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !ishuman(target) || !consented(user, target))
		return FALSE
	if(!target.get_bladder())
		return FALSE
	if(!find_available_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/bladder/press/lock_sex_object(mob/living/user, mob/living/target)
	var/locked = get_hand_lock_slot(user)
	if(locked)
		add_sex_lock(user, locked)

/datum/sex_action/bladder/press/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] presses a palm low on [target]'s belly, right over [target.p_their()] bladder."))

/datum/sex_action/bladder/press/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/component/bladder/bladder = target.get_bladder()
	if(!bladder)
		return
	var/urge = bladder.urge
	if(can_show_action_message(user, target))
		user.watersports_message(spanify_force("[user] [get_generic_force_adjective()] presses on [target]'s bladder..."))
		to_chat(target, span_love(bladder_press_text(target, urge)))
	perform_sex_action(target, user, 0.4 + 0.3 * urge, urge >= BLADDER_URGE_URGENT ? 1 : 0, 0.2)
	try_leak(user, target, bladder)

/datum/sex_action/bladder/press/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.watersports_message(span_warning("[user] takes [user.p_their()] hand off [target]'s belly."))

/datum/sex_action/bladder/press/proc/try_leak(mob/living/user, mob/living/target, datum/component/bladder/bladder)
	var/chance = 0
	switch(bladder.urge)
		if(BLADDER_URGE_URGENT)
			chance = BLADDER_PRESS_LEAK_CHANCE_URGENT
		if(BLADDER_URGE_BURSTING)
			chance = BLADDER_PRESS_LEAK_CHANCE_BURSTING
	if(!prob(chance))
		return
	var/mob/living/carbon/human/leaker = target
	if(bladder.urge >= BLADDER_URGE_BURSTING && prob(BLADDER_PRESS_FLOOD_CHANCE))
		var/half = bladder.get_volume() / 2
		bladder.release_onto_body(leaker, FLUID_COAT_GROIN, half)
		bladder.release_onto_body(leaker, FLUID_COAT_THIGHS, bladder.get_volume())
		leaker.watersports_message(span_love("[leaker] loses control under [user]'s hand; piss gushes out of [leaker.p_them()], soaking [leaker.p_their()] crotch and running down [leaker.p_their()] legs!"), span_love(bladder_flood_text(leaker)))
		play_stream_sound(leaker)
		return
	bladder.release_onto_body(leaker, FLUID_COAT_GROIN, BLADDER_PRESS_LEAK_UNITS)
	leaker.watersports_message(span_love("A warm spurt escapes [leaker] under [user]'s pressing hand."), span_love(bladder_leak_text(leaker)))
