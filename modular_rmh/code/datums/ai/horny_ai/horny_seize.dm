// The handed catch, with the engine's own wrestling: grab, second grab, grip, throw or tackle, get on top, pin.

/proc/get_horny_shove_intent()
	var/static/datum/intent/grab/shove/shove_intent = new()
	return shove_intent

/// How many of the hunter's grab items hold this target.
/proc/horny_grabs_on_target(mob/living/carbon/hunter, mob/living/target)
	var/count = 0
	for(var/obj/item/grabbing/grab in hunter.held_items)
		if(grab.grabbed == target)
			count++
	return count

/// TRUE when a grip on the target has gone loose after a failed throw.
/proc/horny_has_loose_grab(mob/living/carbon/hunter, mob/living/target)
	for(var/obj/item/grabbing/grab in hunter.held_items)
		if(grab.grabbed == target && grab.grab_state < GRAB_AGGRESSIVE)
			return TRUE
	return FALSE

/// TRUE when the hunter has a free hand, or holds something it may put away or drop.
/proc/horny_can_free_hand(mob/living/carbon/hunter)
	for(var/obj/item/held as anything in hunter.held_items)
		if(!held)
			return TRUE
	for(var/obj/item/held as anything in hunter.held_items)
		if(!held || istype(held, /obj/item/grabbing))
			continue
		if(held.item_flags & ABSTRACT || HAS_TRAIT(held, TRAIT_NODROP))
			continue
		return TRUE
	return FALSE

/// Frees one hand for a grab: stows the held item when the hunter has a pack, else drops it. TRUE when a hand is free.
/proc/horny_free_hand(mob/living/carbon/hunter, datum/ai_controller/controller)
	for(var/obj/item/held as anything in hunter.held_items)
		if(!held)
			return TRUE
	for(var/obj/item/held as anything in hunter.held_items)
		if(!held || istype(held, /obj/item/grabbing))
			continue
		if(held.item_flags & ABSTRACT || HAS_TRAIT(held, TRAIT_NODROP))
			continue
		var/datum/component/ai_inventory_manager/inventory = controller?.get_inventory()
		if(inventory && inventory.stow_item(held))
			return TRUE
		if(hunter.dropItemToGround(held))
			return TRUE
	return FALSE

/// TRUE when someone else's hold on the target is not ours to break: any aggressive hold, a packmate's, or a fellow hunter's.
/proc/horny_hold_is_spoken_for(mob/living/hunter, mob/living/target)
	var/mob/living/holder = target.pulledby
	if(!holder || holder == hunter)
		return FALSE
	if(holder.grab_state >= GRAB_AGGRESSIVE || hunter.kidnap_is_packmate(holder))
		return TRUE
	// Another hunter after the same target is a partner in the catch, whatever its faction.
	return holder.ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == target

/// Takes a passive grab on a limb, with a taste for the mouth, and says so. TRUE when the grip landed; the engine may refuse it.
/proc/horny_take_grab(mob/living/carbon/hunter, mob/living/carbon/human/target, datum/ai_controller/controller)
	if(horny_hold_is_spoken_for(hunter, target))
		return FALSE
	if(!horny_free_hand(hunter, controller))
		return FALSE
	var/old_zone = hunter.zone_selected
	hunter.zone_selected = prob(30) ? BODY_ZONE_PRECISE_MOUTH : pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_GROIN)
	var/list/grabs_before = list()
	for(var/obj/item/grabbing/grab in hunter.held_items)
		if(grab.grabbed == target)
			grabs_before += grab
	target.grabbedby(hunter, TRUE)
	hunter.zone_selected = old_zone
	var/obj/item/grabbing/new_grab
	for(var/obj/item/grabbing/grab in hunter.held_items)
		if(grab.grabbed == target && !(grab in grabs_before))
			new_grab = grab
			break
	if(hunter.pulling != target || !new_grab)
		return FALSE
	horny_jolt(hunter, target)
	// The engine's own grab line is suppressed above; this one names the limb, so a mouth grab reads as the gag it is.
	var/datum/horny_family_profile/profile = hunter.get_horny_family_profile()
	var/zone = parse_zone(new_grab.sublimb_grabbed) || "arm"
	target.felt_visible_message(span_danger(profile.get_grab_message(hunter, target, zone)), span_userdanger(profile.get_grab_message(hunter, target, zone, TRUE)), span_hear("I hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE)
	return TRUE

/// Keeps at least one grip on the target between beats; waits out a grace window after a break.
/proc/horny_ensure_grab(mob/living/carbon/hunter, mob/living/carbon/human/target, datum/ai_controller/controller)
	if(hunter.pulling == target && horny_grabs_on_target(hunter, target))
		return TRUE
	if(TIMER_COOLDOWN_RUNNING(target, "broke_free"))
		return FALSE
	return horny_take_grab(hunter, target, controller)

/// One grip roll tightens the whole hold: every grab on the target follows the mob's grab state.
/proc/horny_tighten_grabs(mob/living/carbon/hunter, mob/living/target)
	if(hunter.grab_state < GRAB_AGGRESSIVE)
		return
	for(var/obj/item/grabbing/grab in hunter.held_items)
		if(grab.grabbed != target || grab.grab_state >= GRAB_AGGRESSIVE)
			continue
		grab.grab_state = GRAB_AGGRESSIVE
		grab.update_grab_intents()

/// Uses a grab item on the target with the shove intent: the throw or tackle on a standing target, the pin on a floored one.
/proc/horny_grab_attack(mob/living/carbon/hunter, mob/living/carbon/human/target)
	var/obj/item/grabbing/grab
	if(istype(hunter.r_grab) && hunter.r_grab.grabbed == target)
		grab = hunter.r_grab
	else if(istype(hunter.l_grab) && hunter.l_grab.grabbed == target)
		grab = hunter.l_grab
	if(!grab)
		return FALSE
	var/datum/intent/cached_intent = hunter.used_intent
	hunter.used_intent = get_horny_shove_intent()
	grab.attack(target, hunter)
	hunter.used_intent = cached_intent
	return TRUE

/// One beat of the handed ladder. Call it every beat until it returns HORNY_SEIZE_DONE.
/proc/horny_seize_step(mob/living/carbon/hunter, mob/living/carbon/human/target, datum/ai_controller/controller)
	if(!hunter || !target || !hunter.Adjacent(target))
		return HORNY_SEIZE_FAILED
	if(hunter.body_position == LYING_DOWN)
		return HORNY_SEIZE_WAIT
	if(hunter.next_move > world.time)
		return HORNY_SEIZE_WAIT

	var/grabs = horny_grabs_on_target(hunter, target)
	var/held = hunter.pulling == target && grabs > 0
	// A target on their feet has not been pinned yet, whatever happened before.
	if(target.body_position != LYING_DOWN)
		controller?.clear_blackboard_key(BB_HORNY_PINNED)

	// A yielding target is eased down and held, never wrestled.
	if(target.surrendering)
		if(target.body_position != LYING_DOWN)
			target.Knockdown(50)
			target.felt_visible_message(span_danger("[hunter] eases the yielding [target] down."))
			hunter.changeNext_move(CLICK_CD_GRABBING)
			return HORNY_SEIZE_ACTED
		if(held || (target.pulledby && target.pulledby != hunter))
			return HORNY_SEIZE_DONE
		return horny_take_grab(hunter, target, controller) ? HORNY_SEIZE_ACTED : HORNY_SEIZE_WAIT

	// A weapon comes loose first.
	if(mob_has_ai_disarmable_held_item(target) && horny_disarm_target(hunter, target))
		hunter.changeNext_move(CLICK_CD_MELEE)
		return HORNY_SEIZE_ACTED

	// Strapped into something, the structure holds them; a grab of our own would only fail.
	if(target.buckled)
		hunter.cmode = FALSE
		return HORNY_SEIZE_DONE

	// Someone else holds the target. Floored, they are caught; standing, we hook at their legs rather than fight a packmate for the hold.
	if(!held && target.pulledby && target.pulledby != hunter)
		if(target.body_position == LYING_DOWN)
			hunter.cmode = FALSE
			return HORNY_SEIZE_DONE
		if(horny_hold_is_spoken_for(hunter, target))
			hunter.cmode = TRUE
			horny_bear_down(hunter, target, hunter.get_horny_family_profile(), controller)
			return HORNY_SEIZE_ACTED

	// The first grip. A target who just broke free slips any new grab for a moment.
	if(!held)
		if(TIMER_COOLDOWN_RUNNING(target, "broke_free"))
			controller?.horny_react(HORNY_REACT_GRAB_BROKEN, target)
			return HORNY_SEIZE_WAIT
		return horny_take_grab(hunter, target, controller) ? HORNY_SEIZE_ACTED : HORNY_SEIZE_WAIT

	// The second grip whenever a hand can be spared: two hands throw instead of tackling, and they pin.
	if(grabs < 2 && horny_can_free_hand(hunter))
		return horny_take_grab(hunter, target, controller) ? HORNY_SEIZE_ACTED : HORNY_SEIZE_WAIT

	if(target.body_position != LYING_DOWN)
		if(horny_target_is_subdued(hunter, target))
			hunter.cmode = FALSE
			return HORNY_SEIZE_DONE
		// Standing: this is a fight now. Tighten the grip, then the throw.
		hunter.cmode = TRUE
		if(hunter.grab_state < GRAB_AGGRESSIVE || horny_has_loose_grab(hunter, target))
			horny_jolt(hunter, target)
			target.grippedby(hunter)
			horny_tighten_grabs(hunter, target)
			return HORNY_SEIZE_ACTED
		// The engine's throw gets its tries; once it keeps failing, the body roll takes over and grows with every miss.
		if(horny_get_pressure(controller) >= HORNY_THROW_TRIES)
			var/datum/horny_family_profile/profile = hunter.get_horny_family_profile()
			horny_bear_down(hunter, target, profile, controller)
			return HORNY_SEIZE_ACTED
		horny_jolt(hunter, target)
		horny_grab_attack(hunter, target)
		if(target.body_position != LYING_DOWN)
			horny_add_pressure(controller, target)
		else
			horny_reset_pressure(controller)
		return HORNY_SEIZE_ACTED

	// Down: get on top, then the real pin, once. Its stun is short; the hold is what keeps them down afterwards.
	if(hunter.loc != target.loc)
		if(!step_towards(hunter, target))
			return HORNY_SEIZE_DONE
		return HORNY_SEIZE_ACTED
	if(grabs >= 2 && !target.IsStun() && !controller?.blackboard[BB_HORNY_PINNED])
		if(horny_grab_attack(hunter, target))
			controller?.set_blackboard_key(BB_HORNY_PINNED, TRUE)
		return HORNY_SEIZE_ACTED
	hunter.cmode = FALSE
	return HORNY_SEIZE_DONE
