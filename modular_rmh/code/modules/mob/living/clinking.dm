// Drink clinking, ported from Ratwood.
// Offer your drink to someone who is already offering theirs to you and you clink them together instead.

/// Bigger drinks get the deeper clunk.
#define CLINK_BIG_DRINK_VOLUME 50
/// How long both hands stay up for the clink.
#define CLINK_HOLD_TIME (0.6 SECONDS)

/mob/living/offer_item(mob/living/offered_to, obj/offered_item)
	var/obj/item/reagent_containers/glass/their_drink = offered_to?.offered_item_ref?.resolve()
	if(m_intent == MOVE_INTENT_SNEAK || COOLDOWN_TIMELEFT(src, offer_cooldown) || !is_clinkable_drink(offered_item) || !is_clinkable_drink(their_drink))
		return ..()

	offered_item_ref = WEAKREF(offered_item)
	new /obj/effect/temp_visual/offered_item_effect(get_turf(src), offered_item, src, offered_to, FALSE)
	clink_drinks(offered_to, offered_item, their_drink)
	return TRUE

/mob/living/proc/clink_drinks(mob/living/partner, obj/item/our_drink, obj/item/their_drink)
	var/clink_sound = their_drink.reagents.maximum_volume > CLINK_BIG_DRINK_VOLUME ? 'modular_rmh/sound/emotes/clink_drink_big.ogg' : 'modular_rmh/sound/emotes/clink_drink.ogg'
	playsound(src, clink_sound, 100, TRUE)
	visible_message(
		span_notice("[src] clinks [our_drink] with [partner]!"),
		span_notice("I clink [our_drink] with [partner]!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = list(partner),
	)
	to_chat(partner, span_notice("[src] clinks [our_drink] with me!"))
	addtimer(CALLBACK(src, PROC_REF(stop_offering_item)), CLINK_HOLD_TIME)
	addtimer(CALLBACK(partner, PROC_REF(stop_offering_item)), CLINK_HOLD_TIME)

/proc/is_clinkable_drink(obj/item/thing)
	return istype(thing, /obj/item/reagent_containers/glass) && thing.reagents?.maximum_volume > 0

#undef CLINK_BIG_DRINK_VOLUME
#undef CLINK_HOLD_TIME
