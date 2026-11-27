/datum/sex_action/spanking
	name = "Spank butt"
	remote_phrase = "Spank their butt"
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	// Allow through all clothes, so no body zone accessibility check for clothing
	check_same_tile = FALSE
	do_time = 2.5 SECONDS // Slightly faster than average for repeated action
	stamina_cost = 0
	requires_free_hands = TRUE
	mage_hand_allowed = TRUE
	mage_hand_overlay_zone = MAGE_HAND_ZONE_BUTT

/datum/sex_action/spanking/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/spanking/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!find_available_hand(user))
		return FALSE
	if(user == target)
		return FALSE
	if(!user.Adjacent(target) && !can_mage_hand_reach(user, target))
		return FALSE
	// No clothing or body zone checks, can always spank
	return TRUE

/datum/sex_action/spanking/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] positions [user.p_their()] hand to spank [target]'s butt!"))

/datum/sex_action/spanking/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/sound = get_slap_sound("spank")
	playsound(target, sound, get_sound_volume(user, 50), TRUE, -2, ignore_walls = FALSE)

	var/obj/item/tool = get_spank_tool(user, target)
	var/msg = "[user] [get_generic_force_adjective()] spanks [target]'s butt[tool ? " with [tool]" : ""]."
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(msg))

	// Arousal and pain logic
	var/arousal_amt = 1.2 + (force * 0.5)
	var/pain_amt = 2 * force
	perform_sex_action(target, user, arousal_amt, pain_amt, arousal_amt)
	handle_passive_ejaculation(target)
	if(ishuman(target))
		var/mob/living/carbon/human/spanked = target
		spanked.take_impact_mark(user, BODY_ZONE_PRECISE_GROIN, force, tool)

	// Soreness messaging depending on force
	if(force >= SEX_FORCE_HIGH)
		to_chat(target, span_warning("Your butt is starting to feel sore from the spanking!"))
	else if(force == SEX_FORCE_MID)
		if(prob(30))
			to_chat(target, span_notice("You feel a pleasant sting on your rear."))
	else if(force == SEX_FORCE_LOW)
		if(prob(10))
			to_chat(target, span_notice("A gentle warmth spreads across your buttocks."))

/datum/sex_action/spanking/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops spanking [target]."))

/datum/sex_action/spanking/lock_sex_object(mob/living/user, mob/living/target)
	selected_hand = find_spank_hand(user)
	if(selected_hand)
		add_sex_lock(user, selected_hand)

/// The impact tool held in hand_slot, if it is free to use.
/datum/sex_action/spanking/proc/get_hand_impact_tool(mob/living/user, hand_slot)
	var/obj/item/held = user.get_item_for_held_index(hand_slot == BODY_ZONE_PRECISE_L_HAND ? 1 : 2)
	if(!is_impact_tool(held) || check_sex_lock(user, null, held))
		return null
	return held

/// A free hand holding an impact tool, active hand first; else any free hand.
/datum/sex_action/spanking/proc/find_spank_hand(mob/living/user)
	if(!user || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return null
	for(var/hand_slot in list(user.get_active_precise_hand(), user.get_inactive_precise_hand()))
		if(!user.get_bodypart(hand_slot) || check_sex_lock(user, hand_slot))
			continue
		if(get_hand_impact_tool(user, hand_slot))
			return hand_slot
	return find_available_hand(user)

/// The impact tool in the spanking hand; a mage hand spank from afar strikes bare.
/datum/sex_action/spanking/proc/get_spank_tool(mob/living/user, mob/living/target)
	if(!user.Adjacent(target))
		return null
	var/hand_slot = selected_hand || find_spank_hand(user)
	return hand_slot ? get_hand_impact_tool(user, hand_slot) : null
