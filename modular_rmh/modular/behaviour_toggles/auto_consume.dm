/// Pause before the next gulp or bite of held food and drink.
#define AUTO_CONSUME_GAP CLICK_CD_MELEE

/// Still thirsty: below the hydration where the thirst debuff clears.
/proc/auto_consume_thirsty(mob/living/consumer)
	return !HAS_TRAIT(consumer, TRAIT_NOHUNGER) && consumer.hydration < HYDRATION_LEVEL_SMALLTHIRST

/// Still hungry: below the nutrition where the hunger debuff clears.
/proc/auto_consume_hungry(mob/living/consumer)
	return !HAS_TRAIT(consumer, TRAIT_NOHUNGER) && consumer.nutrition < NUTRITION_LEVEL_FED

/// Whether another gulp or bite follows. quenches/feeds: which need the source meets; source_left: not empty.
/proc/auto_consume_should_continue(mob/living/consumer, pref_enabled, quenches, feeds, source_left)
	if(!pref_enabled || !source_left || QDELETED(consumer) || consumer.stat != CONSCIOUS)
		return FALSE
	if(quenches && auto_consume_thirsty(consumer))
		return TRUE
	if(feeds && auto_consume_hungry(consumer))
		return TRUE
	return FALSE

/// The non-stop eating and drinking toggle; mobs without a player eat one bite at a time.
/mob/living/proc/auto_consume_pref()
	return client?.prefs?.read_preference(/datum/preference/toggle/auto_consume)

/mob/living/proc/auto_consume_continues(quenches, feeds, source_left)
	return auto_consume_should_continue(src, auto_consume_pref(), quenches, feeds, source_left)

/// Waits before the next gulp or bite. FALSE when the mob moves, turns, swaps items, clicks or is interrupted.
/mob/living/proc/auto_consume_wait(delay, atom/source)
	return do_after(src, delay, source, extra_checks = CALLBACK(src, PROC_REF(auto_consume_idle_since), world.time))

/mob/living/proc/auto_consume_idle_since(started)
	return last_client_interact <= started

/// Bowls fill as well as quench; other containers count as drinks.
/obj/item/reagent_containers/proc/auto_consume_feeds()
	return istype(src, /obj/item/reagent_containers/glass/bowl)

/// Queues the next gulp after drinking from this container by yourself.
/obj/item/reagent_containers/proc/start_auto_drinking(mob/living/drinker)
	if(drinker.auto_consume_pref())
		INVOKE_ASYNC(src, PROC_REF(continue_drinking), drinker)

/obj/item/reagent_containers/proc/continue_drinking(mob/living/drinker)
	var/feeds = auto_consume_feeds()
	if(!drinker.auto_consume_continues(TRUE, feeds, reagents?.total_volume))
		return
	if(!drinker.auto_consume_wait(AUTO_CONSUME_GAP, src))
		return
	if(QDELETED(src) || loc != drinker || drinker.used_intent?.type != INTENT_POUR)
		return
	if(!drinker.auto_consume_continues(TRUE, feeds, reagents?.total_volume))
		return
	try_feed(drinker, drinker)

/// Queues the next spoonful after eating from this bowl by yourself.
/obj/item/reagent_containers/glass/bowl/proc/start_auto_spooning(mob/living/eater, obj/item/spoon)
	if(eater.auto_consume_pref())
		INVOKE_ASYNC(src, PROC_REF(continue_spooning), eater, spoon)

/obj/item/reagent_containers/glass/bowl/proc/continue_spooning(mob/living/eater, obj/item/spoon)
	if(!eater.auto_consume_continues(TRUE, TRUE, reagents?.total_volume))
		return
	if(!eater.auto_consume_wait(AUTO_CONSUME_GAP, src))
		return
	if(QDELETED(src) || QDELETED(spoon) || eater.get_active_held_item() != spoon || !eater.Adjacent(src))
		return
	if(!eater.auto_consume_continues(TRUE, TRUE, reagents?.total_volume))
		return
	item_interaction(eater, spoon, list())

/// Queues the next bite after eating this by yourself, from the hand or with a fork.
/obj/item/reagent_containers/food/snacks/proc/start_auto_eating(mob/living/eater)
	if(eater.auto_consume_pref())
		INVOKE_ASYNC(src, PROC_REF(continue_eating), eater)

/obj/item/reagent_containers/food/snacks/proc/continue_eating(mob/living/eater)
	if(!eater.auto_consume_continues(FALSE, TRUE, TRUE))
		return
	if(!eater.auto_consume_wait(AUTO_CONSUME_GAP, src))
		return
	if(QDELETED(src))
		return
	var/obj/item/held_item = eater.get_active_held_item()
	if(held_item != src && !(istype(held_item, /obj/item/kitchen/fork) && eater.Adjacent(src)))
		return
	if(!eater.auto_consume_continues(FALSE, TRUE, TRUE))
		return
	interact_with_atom(eater, eater, list())

#undef AUTO_CONSUME_GAP
