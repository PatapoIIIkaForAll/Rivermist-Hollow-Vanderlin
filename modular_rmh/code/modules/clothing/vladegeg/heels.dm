/// Percent chance per running step that heeled shoes trip their wearer.
#define HEEL_TRIP_CHANCE 1

/obj/item/clothing/shoes/heels
	name = "black heels"
	desc = "A real fashion statement in these parts. Don't trip."
	icon = 'modular_rmh/icons/clothing/vladegeg/heels.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/vladegeg/onmob/heels.dmi'
	icon_state = "heels"
	item_state = "heels"
	misc_flags = CRAFTING_TEST_EXCLUDE //add crafing later
	heeled = TRUE

/obj/item/clothing/shoes/heels/color
	name = "heels"
	icon_state = "heels_color"
	item_state = "heels_color"
	misc_flags = CRAFTING_TEST_EXCLUDE

/// Turns heels on or off, updating a current wearer. Returns TRUE if the state changed.
/obj/item/clothing/shoes/proc/set_heeled(new_heeled)
	new_heeled = !!new_heeled
	if(heeled == new_heeled)
		return FALSE
	heeled = new_heeled
	var/mob/living/wearer = loc
	if(isliving(wearer) && wearer.get_item_by_slot(ITEM_SLOT_SHOES) == src)
		if(heeled)
			start_heel_effects(wearer)
		else
			stop_heel_effects(wearer)
	return TRUE

/obj/item/clothing/shoes/proc/start_heel_effects(mob/living/wearer)
	if(heel_effects_active || !isliving(wearer))
		return
	heel_effects_active = TRUE
	wearer.AddElement(/datum/element/heeled_gait)

/obj/item/clothing/shoes/proc/stop_heel_effects(mob/living/wearer)
	if(!heel_effects_active)
		return
	heel_effects_active = FALSE
	if(isliving(wearer))
		wearer.RemoveElement(/datum/element/heeled_gait)

/// Whether this step can trip: heeled shoes on a running wearer who moves on their own feet.
/obj/item/clothing/shoes/proc/can_heel_trip(mob/living/wearer)
	if(!heeled || !isliving(wearer) || wearer.get_item_by_slot(ITEM_SLOT_SHOES) != src)
		return FALSE
	if(HAS_TRAIT(wearer, TRAIT_HEEL_WALKER) || wearer.m_intent != MOVE_INTENT_RUN)
		return FALSE
	if(!isturf(wearer.loc) || wearer.buckled || wearer.pulledby || wearer.throwing)
		return FALSE
	if(wearer.body_position == LYING_DOWN || (wearer.movement_type & (FLYING|FLOATING|VENTCRAWLING)))
		return FALSE
	if(HAS_TRAIT(wearer, TRAIT_IMMOBILIZED))
		return FALSE
	return TRUE

/// Rolls a trip for one running step. Returns TRUE if the wearer fell.
/obj/item/clothing/shoes/proc/roll_heel_trip(mob/living/wearer, chance = HEEL_TRIP_CHANCE)
	if(!can_heel_trip(wearer) || !prob(chance))
		return FALSE
	wearer.visible_message(span_warning("[wearer] trips over [wearer.p_their()] heels!"), span_warning("I trip over my heels!"))
	wearer.Knockdown(1 SECONDS)
	wearer.Immobilize(2 SECONDS)
	return TRUE

/// Put on a mob while it wears heeled shoes: lowers Speed and rolls trips on running steps.
/datum/element/heeled_gait
	element_flags = ELEMENT_DETACH

/datum/element/heeled_gait/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignals(target, list(SIGNAL_ADDTRAIT(TRAIT_HEEL_WALKER), SIGNAL_REMOVETRAIT(TRAIT_HEEL_WALKER)), PROC_REF(on_walker_trait_changed))
	update_speed_penalty(target)

/datum/element/heeled_gait/Detach(mob/living/source)
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, SIGNAL_ADDTRAIT(TRAIT_HEEL_WALKER), SIGNAL_REMOVETRAIT(TRAIT_HEEL_WALKER)))
	source.remove_stat_modifier(STATMOD_HEELS)
	return ..()

/// One Speed lost, unless the wearer is used to heels.
/datum/element/heeled_gait/proc/update_speed_penalty(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_HEEL_WALKER))
		target.remove_stat_modifier(STATMOD_HEELS)
	else
		target.set_stat_modifier(STATMOD_HEELS, STATKEY_SPD, -1)

/datum/element/heeled_gait/proc/on_walker_trait_changed(mob/living/source)
	SIGNAL_HANDLER
	update_speed_penalty(source)

/datum/element/heeled_gait/proc/on_moved(mob/living/source, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	if(forced || source.moving_diagonally == FIRST_DIAG_STEP)
		return
	var/obj/item/clothing/shoes/worn_shoes = source.get_item_by_slot(ITEM_SLOT_SHOES)
	if(istype(worn_shoes))
		worn_shoes.roll_heel_trip(source)

#undef HEEL_TRIP_CHANCE
