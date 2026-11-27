/obj/item/clothing/proc/get_washed_wet(dirty, mob/living/washer)
	wet?.add_water(LAUNDRY_WATER, dirty, TRUE)
	if(washer)
		to_chat(washer, dirty ? span_warning("I wash \the [src], but the water is foul.") : span_notice("I wash \the [src] clean."))

/obj/item/clothing/proc/wash_in_vessel(obj/item/reagent_containers/vessel, mob/living/washer)
	var/datum/reagents/water = vessel.reagents
	if(get_wash_water(water) < LAUNDRY_VESSEL_MIN_UNITS)
		to_chat(washer, span_warning("There is too little water in \the [vessel] to wash \the [src]."))
		return FALSE
	washer.visible_message(span_info("[washer] starts to wash \the [src] in \the [vessel]."))
	playsound(vessel, pick(LAUNDRY_SOUNDS), 100, FALSE)
	if(!do_after(washer, LAUNDRY_WASH_TIME, vessel) || get_wash_water(water) < LAUNDRY_VESSEL_MIN_UNITS)
		return FALSE
	var/clean_water = water.get_reagent_amount(/datum/reagent/water)
	wash(CLEAN_WASH)
	get_washed_wet(!clean_water, washer)
	water.remove_reagent(/datum/reagent/water, clean_water)
	water.add_reagent(/datum/reagent/water/gross, clean_water)
	washer.nobles_seen_servant_work()
	playsound(vessel, pick(LAUNDRY_SOUNDS), 100, FALSE)
	return TRUE

/obj/item/clothing/proc/get_wash_water(datum/reagents/water)
	return water ? water.get_reagent_amount(/datum/reagent/water) + water.get_reagent_amount(/datum/reagent/water/gross) : 0

/obj/item/reagent_containers/proc/holds_wash_water()
	var/static/list/wash_water = list(/datum/reagent/water, /datum/reagent/water/gross)
	var/datum/reagent/main_fluid = reagents?.get_master_reagent()
	return is_open_container() && (main_fluid?.type in wash_water)

/obj/item/reagent_containers/proc/try_wash_garment(mob/living/user, obj/item/clothing/garment)
	if(user.cmode || !istype(garment) || garment.is_refillable() || !holds_wash_water())
		return NONE
	return garment.wash_in_vessel(src, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/reagent_containers/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return try_wash_garment(user, tool) || ..()

/obj/item/reagent_containers/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	return try_wash_garment(user, tool) || ..()

/obj/structure/dryclothes/examine(mob/user)
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	for(var/obj/item/clothing/garment in storage?.contents())
		. += span_notice("\The [garment] hangs here, [garment.wet?.water_stacks < 0 || garment.has_soaked_fluid() ? "still wet" : "dry"].")
