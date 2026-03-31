/datum/component/abberant_eater
	var/list/extra_foods = list()
	var/list/extra_reagents = list()
	var/excluding_subtypes = FALSE
	var/list/edible_turfs = list()
	var/reagent_bite_size = 5
	var/reagent_nutrition = 10

/datum/component/abberant_eater/Initialize(list/food_list, exclude_subtypes = FALSE, list/turf_list, list/reagent_list, reagent_sip_size = 5, nutrition_from_reagents = 10)
	if(!length(food_list) && !length(turf_list) && !length(reagent_list))
		return COMPONENT_INCOMPATIBLE

	excluding_subtypes = exclude_subtypes
	if(length(food_list))
		extra_foods = excluding_subtypes ? typecacheof(food_list, only_root_path = TRUE) : food_list
	else
		extra_foods = list()
	extra_reagents = reagent_list || list()
	edible_turfs = turf_list || list()
	reagent_bite_size = max(reagent_sip_size, 1)
	reagent_nutrition = max(nutrition_from_reagents, 1)

/datum/component/abberant_eater/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(try_eat))
	RegisterSignal(parent, COMSIG_LIVING_POSTBITE_SELF, PROC_REF(eat_turf))

/datum/component/abberant_eater/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_POSTBITE_SELF))

/datum/component/abberant_eater/proc/try_eat(mob/living/user, mob/living/M, obj/item/source)
	if(user.cmode)
		return FALSE
	if(user != M)
		return FALSE
	if(try_drink_reagents(user, source))
		return TRUE

	var/can_we_eat = excluding_subtypes ? is_type_in_typecache(source, extra_foods) : is_type_in_list(source, extra_foods)
	if(!can_we_eat)
		return FALSE

	var/eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	M.nutrition += 10

	switch(M.nutrition)
		if(NUTRITION_LEVEL_FAT to INFINITY)
			user.visible_message("<span class='notice'>[user] forces [M.p_them()]self to eat \the [source].</span>", "<span class='notice'>I force myself to eat \the [source].</span>")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FAT)
			user.visible_message("<span class='notice'>[user] [eatverb]s \the [source].</span>", "<span class='notice'>I [eatverb] \the [source].</span>")
		if(0 to NUTRITION_LEVEL_STARVING)
			user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [source], gobbling it down!</span>", "<span class='notice'>I hungrily [eatverb] \the [source], gobbling it down!</span>")
			M.changeNext_move(CLICK_CD_MELEE * 0.5)

	playsound(M,'sound/misc/eat.ogg', rand(30,60), TRUE)
	SEND_SIGNAL(source, COMSIG_FOOD_EATEN, M, user)
	SEND_SIGNAL(user, COMSIG_MOB_FOOD_EAT, source)
	source.on_consume(user)
	qdel(source)
	return TRUE

/datum/component/abberant_eater/proc/try_drink_reagents(mob/living/consumer, obj/item/source)
	if(!length(extra_reagents))
		return FALSE
	if(!source?.reagents)
		return FALSE

	var/datum/reagent/edible_reagent = get_edible_reagent(source)
	if(!edible_reagent)
		return FALSE

	var/removed_amount = min(edible_reagent.volume, reagent_bite_size)
	if(removed_amount <= 0)
		return FALSE

	var/drinkverb = pick("drink", "sip", "drain", "swallow")
	var/nutrition_gain = max(1, round(reagent_nutrition * (removed_amount / reagent_bite_size)))
	consumer.nutrition += nutrition_gain
	source.reagents.remove_reagent(edible_reagent.type, removed_amount)

	switch(consumer.nutrition)
		if(NUTRITION_LEVEL_FAT to INFINITY)
			consumer.visible_message("<span class='notice'>[consumer] tops [consumer.p_them()]self off with \the [source].</span>", "<span class='notice'>I top myself off with \the [source].</span>")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FAT)
			consumer.visible_message("<span class='notice'>[consumer] [drinkverb]s from \the [source].</span>", "<span class='notice'>I [drinkverb] from \the [source].</span>")
		if(0 to NUTRITION_LEVEL_STARVING)
			consumer.visible_message("<span class='notice'>[consumer] greedily [drinkverb]s from \the [source]!</span>", "<span class='notice'>I greedily [drinkverb] from \the [source]!</span>")
			consumer.changeNext_move(CLICK_CD_MELEE * 0.5)

	playsound(consumer, pick('sound/items/drink_gen (1).ogg', 'sound/items/drink_gen (2).ogg', 'sound/items/drink_gen (3).ogg'), rand(30,60), TRUE)
	SEND_SIGNAL(consumer, COMSIG_MOB_FOOD_EAT, source)
	return TRUE

/datum/component/abberant_eater/proc/get_edible_reagent(obj/item/source)
	for(var/reagent_path as anything in extra_reagents)
		var/datum/reagent/found_reagent = source.reagents.has_reagent(reagent_path, 0, FALSE, !excluding_subtypes)
		if(found_reagent)
			return found_reagent
	return FALSE

/datum/component/abberant_eater/proc/eat_turf(mob/living/user, turf/T, finished_attack_chain)
	if(!length(edible_turfs))
		return
	if(!finished_attack_chain)
		return
	if(!turf_check(T))
		return
	var/count = 0
	while(do_after(user, rand(2.5, 1.75) SECONDS, T, display_over_user = TRUE, extra_checks = CALLBACK(src, PROC_REF(turf_check), T)) && user.adjust_stamina(7))
		var/damage = user.STASTR * (HAS_TRAIT(user, TRAIT_STRONGBITE) ? 30 : 15) * rand(0.8, 1.2)
		T.take_damage(damage, BRUTE, "stab", FALSE)
		playsound(T, 'sound/combat/hits/onstone/stonedeath.ogg', rand(50,75), TRUE)
		playsound(user, 'sound/misc/eat.ogg', rand(50,75), TRUE)
		count %= 3
		if(!count)
			user.visible_message(span_warning("[user] tunnels into [T]!"), span_warning("I tunnel into [T]!"), span_warning("I hear the sound of crunching terrain."))
		count++

// when a turf gets eaten it just becomes another turf, so we have to make sure it didn't change
/datum/component/abberant_eater/proc/turf_check(turf/T)
	if(!is_type_in_list(T, edible_turfs))
		return FALSE
	if(T.resistance_flags & INDESTRUCTIBLE)
		return FALSE
	return TRUE
