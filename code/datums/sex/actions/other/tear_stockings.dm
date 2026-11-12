/datum/sex_action/tear_stockings
	name = "Tear stockings"
	description = "Hook your fingers into the stockings and rip them into ragged ladders."
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_LEGS
	check_same_tile = FALSE
	requires_free_hands = TRUE
	continous = FALSE
	do_time = 3 SECONDS
	stamina_cost = 0.3

/// Worn stockings that can still be torn and that no armor keeps [actor] off, or null.
/datum/sex_action/tear_stockings/proc/get_tearable_stockings(mob/living/target, mob/living/actor)
	RETURN_TYPE(/obj/item/clothing/legwears)
	if(!ishuman(target))
		return null
	var/mob/living/carbon/human/human_target = target
	var/obj/item/clothing/legwears/stockings = human_target.get_sex_reachable_legwear(action_user || actor)
	if(!stockings?.damaged_icon || stockings.obj_broken)
		return null
	return stockings

/datum/sex_action/tear_stockings/proc/whose(mob/living/user, mob/living/target)
	return user == target ? user.p_their() : "[target]'s"

/datum/sex_action/tear_stockings/shows_on_menu(mob/living/user, mob/living/target)
	return !!get_tearable_stockings(target, user)

/datum/sex_action/tear_stockings/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!find_available_hand(user))
		return FALSE
	return !!get_tearable_stockings(target, user)

/datum/sex_action/tear_stockings/lock_sex_object(mob/living/user, mob/living/target)
	var/hand = get_hand_lock_slot(user)
	if(hand)
		add_sex_lock(user, hand)

/datum/sex_action/tear_stockings/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/clothing/legwears/stockings = get_tearable_stockings(target, user)
	user.visible_message(span_warning("[user] hooks [user.p_their()] fingers into [whose(user, target)] [stockings?.name || "stockings"]..."))

/datum/sex_action/tear_stockings/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/clothing/legwears/stockings = get_tearable_stockings(target, user)
	if(!stockings)
		stop_runtime()
		return
	var/stockings_name = stockings.name
	if(!stockings.tear_open())
		return
	user.visible_message(spanify_force("[user] [get_generic_force_adjective()] tears [whose(user, target)] [stockings_name] open, the fabric laddering up [user == target ? user.p_their() : target.p_their()] thighs!"))
	perform_sex_action(target, user, 1, 0, 0)
