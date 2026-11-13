// Collect ejaculate (semen, or femcum if no penis) into a held glass container.
// Fills the gap left by the passive vagina/anus "bottle under the crotch" collection, which has no penis equivalent.
/datum/sex_action/collect_fluid
	abstract_type = /datum/sex_action/collect_fluid
	requires_free_hands = FALSE
	do_time = 4 SECONDS
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/// Returns the holder's active-hand glass container if it can still hold fluid, else null.
/datum/sex_action/collect_fluid/proc/get_held_container(mob/living/holder)
	if(!isliving(holder))
		return null
	var/obj/item/reagent_containers/glass/container = holder.get_active_held_item()
	if(istype(container) && container.reagents)
		return container
	return null

/// Putting the container down ends the collection, wherever it lands.
/datum/sex_action/collect_fluid/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!get_held_container(user)

/datum/sex_action/collect_fluid/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	// The climaxing mob is passed as `user`; the container may be held by whoever performed the action. Check all candidates.
	for(var/mob/living/candidate as anything in list(action_performer, action_initiator, user, target))
		var/obj/item/reagent_containers/glass/container = get_held_container(candidate)
		if(container)
			return container
	return null

// --- Self ---
/datum/sex_action/collect_fluid/self
	name = "Collect fluids"

/datum/sex_action/collect_fluid/self/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!get_free_organ(user, ORGAN_SLOT_PENIS) && !get_free_organ(user, ORGAN_SLOT_VAGINA))
		return FALSE
	if(!get_held_container(user))
		return FALSE
	return TRUE

/datum/sex_action/collect_fluid/self/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!get_held_container(user))
		return FALSE
	if(!get_free_organ(user, ORGAN_SLOT_PENIS) && !get_free_organ(user, ORGAN_SLOT_VAGINA))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/collect_fluid/self/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	user.visible_message(span_warning("[user] holds \the [get_held_container(user)] to their crotch and starts pleasuring themselves..."))

/datum/sex_action/collect_fluid/self/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/container = get_held_container(user)
	if(can_show_action_message(user, target))
		var/chosen_verb = pick("strokes themselves over \the [container]", "works themselves over \the [container]", "pleasures themselves into \the [container]")
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [chosen_verb]..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	perform_sex_action(user, user, 2, 0, 2)
	handle_passive_ejaculation()

/datum/sex_action/collect_fluid/self/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops."))

/datum/sex_action/collect_fluid/self/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] spills their release into \the [get_held_container(user)]!"))
	return ORGASM_LOCATION_CONTAINER

/datum/sex_action/collect_fluid/self/lock_sex_object(mob/living/user, mob/living/target)
	if(user.getorganslot(ORGAN_SLOT_PENIS))
		add_sex_lock(user, ORGAN_SLOT_PENIS, null, FALSE)
	if(user.getorganslot(ORGAN_SLOT_VAGINA))
		add_sex_lock(user, ORGAN_SLOT_VAGINA, null, FALSE)

// --- Other ---
/datum/sex_action/collect_fluid/other
	name = "Milk genitals"
	remote_phrase = "Milk them into a container"
	check_same_tile = FALSE
	mage_hand_allowed = TRUE
	mage_hand_overlay_zone = MAGE_HAND_ZONE_GROIN

/datum/sex_action/collect_fluid/other/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!get_free_organ(target, ORGAN_SLOT_PENIS) && !get_free_organ(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(!get_held_container(user))
		return FALSE
	return TRUE

/datum/sex_action/collect_fluid/other/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!get_held_container(user))
		return FALSE
	if(!get_free_organ(target, ORGAN_SLOT_PENIS) && !get_free_organ(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS) && check_sex_lock(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/collect_fluid/other/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	user.visible_message(span_warning("[user] holds \the [get_held_container(user)] up to [target]'s crotch..."))

/datum/sex_action/collect_fluid/other/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [target]'s release toward \the [get_held_container(user)]..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	// Arouse the partner being milked (perform_sex_action arouses its first arg), so THEY climax into our container.
	perform_sex_action(target, user, 2, 0, 2)
	handle_passive_ejaculation(target)

/datum/sex_action/collect_fluid/other/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/container = get_held_container(user)
	if(container)
		user.visible_message(span_warning("[user] lowers \the [container]."))
	else
		user.visible_message(span_warning("[user] stops."))

/datum/sex_action/collect_fluid/other/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	// `user` is the climaxing partner; `target` is the one holding the container.
	user.visible_message(span_love("[user] spills their release into the waiting container!"))
	return ORGASM_LOCATION_CONTAINER

/datum/sex_action/collect_fluid/other/lock_sex_object(mob/living/user, mob/living/target)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		add_sex_lock(target, ORGAN_SLOT_PENIS, null, FALSE)
	if(target.getorganslot(ORGAN_SLOT_VAGINA))
		add_sex_lock(target, ORGAN_SLOT_VAGINA, null, FALSE)
