
#define HELD_MOB_SQUIRM_BASE_DRAIN 4

#define HELD_MOB_SQUIRM_BREAK_CHANCE 25

/**
 * The occupant's counterplay. Not an escape - container_resist and the hole-storage struggle still
 * own getting out - this is for making the person using you regret the grip they have on you.
 */
/datum/sex_action/held_mob_squirm
	name = "Squirm"
	description = "Thrash about to throw off whoever is using you."
	do_time = 2 SECONDS
	stamina_cost = 1

	check_same_tile = FALSE
	requires_free_hands = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_ANY
	target_menu_zone_mask = SEX_UI_ZONE_ANY


/datum/sex_action/held_mob_squirm/proc/get_captor_holder(mob/living/user, mob/living/target)
	if(!user || !target)
		return null
	var/obj/item/mob_holder/holder = user.loc
	if(!istype(holder) || QDELETED(holder) || holder.held_mob != user)
		return null
	if(holder.loc != target)
		return null
	return holder


/datum/sex_action/held_mob_squirm/proc/get_interrupted_action(mob/living/user)
	var/datum/sex_scene/current_scene = scene || user?.sex_scene
	if(!current_scene || QDELETED(current_scene))
		return null
	for(var/datum/sex_action/held_mob_fuck/running as anything in current_scene.active_actions)
		if(!istype(running))
			continue
		if(running.action_target != user)
			continue
		return running
	return null

/datum/sex_action/held_mob_squirm/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!get_captor_holder(user, target))
		return FALSE
	return TRUE

/datum/sex_action/held_mob_squirm/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return get_captor_holder(user, target) != null

/datum/sex_action/held_mob_squirm/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return get_captor_holder(user, target) != null

/datum/sex_action/held_mob_squirm/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	user.visible_message(span_warning("[target]'s hand jerks as [user] thrashes inside it!"))

/datum/sex_action/held_mob_squirm/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/mob_holder/holder = get_captor_holder(user, target)
	if(!holder)
		return


	var/leverage = 1
	var/user_weight = user.get_mob_weight()
	var/target_weight = target.get_mob_weight()
	if(user_weight > 0 && target_weight > 0)
		leverage = clamp(user_weight / target_weight, 0.1, 1)

	// Positive tires: stamina counts fatigue accumulated, so a drain adds to it.
	target.adjust_stamina(HELD_MOB_SQUIRM_BASE_DRAIN * leverage)

	if(can_show_action_message(user, target))
		user.visible_message(span_warning("[user] bucks and kicks against [target]'s fingers."))

	var/datum/sex_action/held_mob_fuck/interrupted = get_interrupted_action(user)
	if(!interrupted)
		return
	if(!prob(HELD_MOB_SQUIRM_BREAK_CHANCE * leverage))
		return
	interrupted.stop_requested = TRUE
	to_chat(target, span_warning("[user] wrenches out of rhythm and I lose my grip on them!"))
	to_chat(user, span_notice("I throw [target] off their stride!"))

#undef HELD_MOB_SQUIRM_BASE_DRAIN
#undef HELD_MOB_SQUIRM_BREAK_CHANCE
