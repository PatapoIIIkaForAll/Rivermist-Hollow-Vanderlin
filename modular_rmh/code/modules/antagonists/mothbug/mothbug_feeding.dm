/obj
	/// Bites a mothbug has taken; the object is gone once this reaches get_mothbug_bites_needed().
	var/moth_bites = 0

/// Cloth structures a mothbug can eat whole.
GLOBAL_LIST_INIT(mothbug_cloth_structures, typecacheof(list(
	/obj/structure/curtain,
	/obj/structure/carpet,
	/obj/structure/dryclothes,
	/obj/structure/fluff/canopy,
	/obj/structure/fluff/celebration/canopy,
	/obj/structure/fluff/celebration/flags,
	/obj/structure/fluff/festive_flags,
	/obj/structure/fluff/littlebanners,
	/obj/structure/fluff/moonrug,
	/obj/structure/fluff/walldeco/artificerflag,
	/obj/structure/fluff/walldeco/customflag,
	/obj/structure/fluff/walldeco/maidendrape,
	/obj/structure/fluff/walldeco/masonflag,
	/obj/structure/fluff/walldeco/psybanner,
	/obj/structure/fluff/walldeco/selune_banner,
	/obj/structure/fluff/walldeco/serpflag,
	/obj/structure/fluff/walldeco/sparrowflag,
	/obj/structure/roguetent,
	/obj/structure/tent_wall,
	/obj/structure/camp_shelter/tent,
)))

/proc/is_mothbug_fabric_type(path)
	return ispath(path, /obj/item/natural/cloth) || ispath(path, /obj/item/natural/silk) || ispath(path, /obj/item/natural/fibers) || ispath(path, /obj/item/natural/fur)

/proc/get_mothbug_piece_value(path)
	if(ispath(path, /obj/item/natural/silk))
		return MOTHBUG_VALUE_SILK_PIECE
	if(ispath(path, /obj/item/natural/fur))
		return MOTHBUG_VALUE_SCRAP * 1.25
	return MOTHBUG_VALUE_SCRAP

/// Fabric value of a whole item or cloth structure, or 0 when a mothbug cannot eat it.
/proc/get_mothbug_fabric_value(obj/target)
	if(!isobj(target) || QDELETED(target) || (target.resistance_flags & INDESTRUCTIBLE))
		return 0
	if(isstructure(target))
		return is_type_in_typecache(target, GLOB.mothbug_cloth_structures) ? MOTHBUG_VALUE_CLOTH_STRUCTURE : 0
	var/obj/item/item = target
	if(!istype(item) || item.anvilrepair || ispath(item.smeltresult, /obj/item/ingot))
		return 0
	if(istype(item, /obj/item/natural/bundle))
		var/obj/item/natural/bundle/bundle = item
		if(!is_mothbug_fabric_type(bundle.stacktype) || bundle.amount <= 0)
			return 0
		return get_mothbug_piece_value(bundle.stacktype) * bundle.amount
	if(is_mothbug_fabric_type(item.type))
		return get_mothbug_piece_value(item.type)
	if(istype(item, /obj/item/bedsheet))
		return MOTHBUG_VALUE_BEDSHEET * (istype(item, /obj/item/bedsheet/pelt) || istype(item, /obj/item/bedsheet/double_pelt) ? 1.25 : 1)
	if(!istype(item, /obj/item/clothing) || !is_mothbug_fabric_type(item.salvage_result))
		return 0
	var/value = MOTHBUG_VALUE_CLOTHING
	if(item.w_class <= WEIGHT_CLASS_SMALL)
		value = MOTHBUG_VALUE_SMALL_CLOTHING
	else if(item.w_class >= WEIGHT_CLASS_BULKY)
		value = MOTHBUG_VALUE_BULKY_CLOTHING
	if(ispath(item.salvage_result, /obj/item/natural/silk) || ispath(item.salvage_result, /obj/item/natural/fur))
		value *= 1.25
	return value

/proc/get_mothbug_bites_needed(obj/target)
	if(!isitem(target))
		return MOTHBUG_STRUCTURE_BITES
	var/obj/item/item = target
	if(item.w_class <= WEIGHT_CLASS_SMALL)
		return 1
	if(item.w_class >= WEIGHT_CLASS_BULKY)
		return 4
	return 3

/// Edible items inside a closed container or a storage item, one storage level deep.
/proc/get_mothbug_edible_contents(atom/container)
	. = list()
	if(!istype(container, /obj/structure/closet) && !container.GetComponent(/datum/component/storage))
		return
	for(var/obj/item/item in container.contents)
		if(get_mothbug_fabric_value(item))
			if(!is_mothbug_repelled(item))
				. += item
		else if(item.GetComponent(/datum/component/storage))
			for(var/obj/item/nested in item.contents)
				if(get_mothbug_fabric_value(nested) && !is_mothbug_repelled(nested))
					. += nested

/datum/element/moth_eaten
	element_flags = ELEMENT_DETACH

/datum/element/moth_eaten/Attach(datum/target)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/element/moth_eaten/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/element/moth_eaten/proc/on_examine(obj/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("It is riddled with small, ragged holes, as if something has been chewing it.")

/mob/living/simple_animal/mothbug/proc/can_eat_more(feedback = TRUE)
	if(silk_charge < max_silk_charge)
		return TRUE
	if(feedback)
		to_chat(src, span_warning("I am too full of silk to eat any more."))
	return FALSE

/mob/living/simple_animal/mothbug/proc/try_eat_fabric(obj/food)
	if(!can_eat_more())
		return FALSE
	if(is_mothbug_repelled(food))
		to_chat(src, span_warning("The smell of lavender drives me back from [food]."))
		return FALSE
	if(!do_after(src, eat_time, food, extra_checks = CALLBACK(src, PROC_REF(can_reach_fabric), food)))
		return FALSE
	if(!get_mothbug_fabric_value(food) || !can_reach_fabric(food))
		return FALSE
	return bite_fabric(food)

/mob/living/simple_animal/mothbug/proc/can_reach_fabric(obj/food)
	if(QDELETED(food) || stat != CONSCIOUS)
		return FALSE
	var/atom/holder = food.loc
	while(holder && !isturf(holder) && !Adjacent(holder))
		holder = holder.loc
	return !!holder && Adjacent(holder)

/// Closets offer open or close, plus anything edible inside while shut.
/mob/living/simple_animal/mothbug/proc/use_closet(obj/structure/closet/closet)
	var/toggle_choice = closet.opened ? "Close" : "Open"
	var/list/choices = list()
	choices[toggle_choice] = image(closet)
	if(!closet.opened && can_eat_more(FALSE))
		for(var/obj/item/item as anything in get_mothbug_edible_contents(closet))
			choices[item] = image(item)
	var/choice = length(choices) == 1 ? toggle_choice : show_radial_menu(src, closet, choices, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(closet))
		return FALSE
	if(choice == toggle_choice)
		return toggle_closet(closet)
	if(!(choice in get_mothbug_edible_contents(closet)))
		return FALSE
	visible_message(span_notice("[src] squeezes its head into [closet] and starts to chew."), span_notice("I squeeze my head into [closet] and chew at [choice]."), vision_distance = 3)
	return try_eat_fabric(choice)

/mob/living/simple_animal/mothbug/proc/toggle_closet(obj/structure/closet/closet)
	var/opening = !closet.opened
	if(opening && !closet.can_open(src))
		return FALSE
	visible_message(span_notice("[src] wedges itself into the gap and pries [closet] [opening ? "open" : "shut"]."), span_notice("I pry [closet] [opening ? "open" : "shut"]."), vision_distance = 4)
	if(!do_after(src, MOTHBUG_CLOSET_TIME, closet) || closet.opened != !opening)
		return FALSE
	return closet.toggle(src)

/mob/living/simple_animal/mothbug/proc/try_eat_from_container(atom/container)
	if(!can_eat_more())
		return FALSE
	var/list/edible = get_mothbug_edible_contents(container)
	if(!length(edible))
		return FALSE
	var/list/choices = list()
	for(var/obj/item/item as anything in edible)
		choices[item] = image(item)
	var/obj/item/picked = show_radial_menu(src, container, choices, require_near = TRUE, tooltips = TRUE)
	if(!picked || !(picked in get_mothbug_edible_contents(container)))
		return FALSE
	visible_message(span_notice("[src] squeezes its head into [container] and starts to chew."), span_notice("I squeeze my head into [container] and chew at [picked]."), vision_distance = 3)
	return try_eat_fabric(picked)

/// Takes one bite from fabric; returns its base silk value before eater multipliers.
/proc/take_mothbug_bite(obj/food)
	var/value = get_mothbug_fabric_value(food)
	if(!value)
		return 0
	if(istype(food, /obj/item/natural/bundle))
		var/obj/item/natural/bundle/bundle = food
		. = value / bundle.amount
		bundle.amount--
		if(bundle.amount <= 0)
			qdel(bundle)
		else
			bundle.update_bundle()
		return
	var/bites_needed = get_mothbug_bites_needed(food)
	. = value / bites_needed
	food.moth_bites++
	if(food.moth_bites >= bites_needed)
		destroy_eaten_fabric(food)
	else if(food.moth_bites == 1)
		food.AddElement(/datum/element/moth_eaten)

/proc/destroy_eaten_fabric(obj/food)
	var/turf/drop_turf = get_turf(food)
	for(var/atom/movable/inside as anything in food.contents)
		inside.forceMove(drop_turf)
	if(ismob(food.loc))
		var/mob/wearer = food.loc
		wearer.temporarilyRemoveItemFromInventory(food, TRUE)
	food.visible_message(span_warning("[food] falls apart into dust and loose threads."))
	qdel(food)

/// Takes one bite; returns the silk gained.
/mob/living/simple_animal/mothbug/proc/bite_fabric(obj/food, value_multiplier = 1)
	var/food_name = "[food]"
	var/gained = take_mothbug_bite(food)
	if(!gained)
		return 0
	gained = credit_fabric(gained * value_multiplier)
	playsound(src, 'sound/foley/cloth_rip.ogg', 15, TRUE, -4)
	if(QDELETED(food))
		to_chat(src, span_notice("I finish [food_name]. (+[round(gained, 0.1)] silk)"))
	else
		to_chat(src, span_notice("I chew a hole in [food_name]. (+[round(gained, 0.1)] silk)"))
	return gained

/// Adds eaten fabric to charge, health and colony totals; returns the silk gained.
/mob/living/simple_animal/mothbug/proc/credit_fabric(base_value)
	var/gained = base_value * food_multiplier
	adjust_silk_charge(gained)
	fabric_eaten += gained
	heal_overall_damage(MOTHBUG_BITE_HEAL, MOTHBUG_BITE_HEAL)
	var/datum/team/mothbug_colony/colony = get_mothbug_colony()
	colony?.record_fabric(gained)
	return gained
