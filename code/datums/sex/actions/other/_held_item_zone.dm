/datum/sex_action/held_item_zone
	abstract_type = /datum/sex_action/held_item_zone
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	do_time = 2.5 SECONDS
	stamina_cost = 0.2
	var/obj/item/action_item
	var/action_item_type
	var/action_item_hand
	var/selected_zone

/datum/sex_action/held_item_zone/Destroy(force, ...)
	action_item = null
	action_item_hand = null
	selected_zone = null
	return ..()

/datum/sex_action/held_item_zone/proc/is_action_item_usable(obj/item/item)
	if(!item || QDELETED(item))
		return FALSE
	return istype(item, action_item_type)

/datum/sex_action/held_item_zone/proc/find_held_action_item(mob/living/user)
	var/obj/item/held_item = user.get_active_held_item()
	if(is_action_item_usable(held_item))
		return held_item
	held_item = user.get_inactive_held_item()
	if(is_action_item_usable(held_item))
		return held_item
	return null

/datum/sex_action/held_item_zone/proc/find_action_item_hand(mob/living/user, obj/item/item)
	if(user.get_active_held_item() == item)
		return user.get_active_precise_hand()
	if(user.get_inactive_held_item() == item)
		if(user.get_active_precise_hand() == BODY_ZONE_PRECISE_L_HAND)
			return BODY_ZONE_PRECISE_R_HAND
		return BODY_ZONE_PRECISE_L_HAND
	return null

/datum/sex_action/held_item_zone/proc/is_supported_zone(zone)
	return FALSE

/datum/sex_action/held_item_zone/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	selected_zone = controller.user.zone_selected
	action_item = find_held_action_item(controller.user)
	action_item_hand = find_action_item_hand(controller.user, action_item)
	return TRUE

/datum/sex_action/held_item_zone/shows_on_menu(mob/living/user, mob/living/target)
	return !!action_item

/datum/sex_action/held_item_zone/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!is_action_item_usable(action_item))
		return FALSE
	if(find_action_item_hand(user, action_item) != action_item_hand)
		return FALSE
	if(!is_supported_zone(selected_zone))
		return FALSE
	if(!check_location_accessible(user, target, selected_zone, TRUE))
		return FALSE
	if(check_sex_lock(user, action_item_hand))
		return FALSE
	if(check_sex_lock(user, null, action_item))
		return FALSE
	return TRUE

/// Dropping the item or moving it to the other hand ends the action.
/datum/sex_action/held_item_zone/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!is_action_item_usable(action_item))
		return FALSE
	return find_action_item_hand(user, action_item) == action_item_hand

/datum/sex_action/held_item_zone/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, action_item_hand)
	add_sex_lock(user, null, action_item)
	add_sex_lock(target, selected_zone, null, FALSE)
