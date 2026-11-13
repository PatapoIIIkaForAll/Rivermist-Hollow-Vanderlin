/// ERP pref gate that lets characters no player owns through, as other mob ERP gates do.
/proc/mothbug_target_allows(mob/living/target, pref_type)
	if(!target.client && !target.mind?.key && !target.mind?.cached_erp_preferences && !target.cached_erp_preferences)
		return TRUE
	return target.has_erp_pref(pref_type)

/// Someone a mothbug may nibble: asleep, bound, floored, lying or tied down.
/proc/is_mothbug_helpless(mob/living/target)
	if(!isliving(target))
		return FALSE
	if(target.stat != CONSCIOUS || target.IsSleeping() || target.IsUnconscious())
		return TRUE
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		if(carbon_target.handcuffed || carbon_target.legcuffed)
			return TRUE
	if(HAS_TRAIT(target, TRAIT_RESTRAINED) || HAS_TRAIT(target, TRAIT_FLOORED) || HAS_TRAIT(target, TRAIT_INCAPACITATED))
		return TRUE
	return target.body_position == LYING_DOWN || !!target.buckled

/// Worn slots over a body zone, outermost layer first.
/proc/get_mothbug_zone_slots(zone)
	switch(zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE)
			return list(ITEM_SLOT_HEAD, ITEM_SLOT_MASK)
		if(BODY_ZONE_PRECISE_MOUTH)
			return list(ITEM_SLOT_MASK, ITEM_SLOT_MOUTH)
		if(BODY_ZONE_PRECISE_NECK)
			return list(ITEM_SLOT_CLOAK, ITEM_SLOT_NECK, ITEM_SLOT_CHOKER)
		if(BODY_ZONE_CHEST)
			return list(ITEM_SLOT_CLOAK, ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_UNDERSHIRT, ITEM_SLOT_UNDER_TOP)
		if(BODY_ZONE_PRECISE_STOMACH)
			return list(ITEM_SLOT_CLOAK, ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_BELT, ITEM_SLOT_UNDERSHIRT)
		if(BODY_ZONE_PRECISE_GROIN)
			return list(ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_PANTS, ITEM_SLOT_GARTER, ITEM_SLOT_UNDER_BOTTOM)
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return list(ITEM_SLOT_CLOAK, ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_WRISTS, ITEM_SLOT_ARMSLEEVES, ITEM_SLOT_UNDERSHIRT)
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return list(ITEM_SLOT_GLOVES)
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return list(ITEM_SLOT_ARMOR, ITEM_SLOT_PANTS, ITEM_SLOT_GARTER, ITEM_SLOT_SOCKS)
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return list(ITEM_SLOT_SHOES, ITEM_SLOT_SOCKS)
	return list()

/// Body garments only count over the zones they cover; slot-bound items always cover their zone.
/proc/does_mothbug_garment_cover(obj/item/garment, slot, zone)
	if(!(slot in list(ITEM_SLOT_CLOAK, ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_UNDERSHIRT, ITEM_SLOT_PANTS)))
		return TRUE
	if(!garment.body_parts_covered)
		return TRUE
	return zone in cover_flags2body_zones(garment.body_parts_covered)

/// The outermost garment over the zone, edible or not; null when the skin is bare.
/proc/get_mothbug_outer_garment(mob/living/carbon/human/target, zone)
	for(var/slot in get_mothbug_zone_slots(zone))
		var/obj/item/garment = target.get_item_by_slot(slot)
		if(garment && does_mothbug_garment_cover(garment, slot, zone))
			return garment
	return null

/proc/get_mothbug_tickle_area(mob/living/target, zone)
	switch(zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE)
			return "face"
		if(BODY_ZONE_PRECISE_EARS)
			return "ear"
		if(BODY_ZONE_PRECISE_NOSE)
			return "nose"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "lips"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_CHEST)
			return "chest"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "belly"
		if(BODY_ZONE_PRECISE_GROIN)
			return "groin and inner thighs"
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return "armpit"
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return "palm"
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return "thigh"
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return "soles"
	return parse_zone(zone)

/proc/get_mothbug_tickle_arousal(zone)
	switch(zone)
		if(BODY_ZONE_PRECISE_GROIN)
			return 1.5
		if(BODY_ZONE_CHEST)
			return 1
		if(BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_STOMACH, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return 0.6
	return 0.3

/mob/living/simple_animal/mothbug/proc/touch_living(mob/living/target)
	if(!ishuman(target) || !is_mothbug_helpless(target))
		visible_message(span_notice("[src] flutters its antennae at [target]."), span_notice("I flutter my antennae at [target]. I can only nibble someone who cannot fight me off."), vision_distance = 3)
		return FALSE
	var/zone = zone_selected || BODY_ZONE_CHEST
	var/obj/item/garment = get_mothbug_outer_garment(target, zone)
	if(!garment)
		return tickle_bare_skin(target, zone)
	if(!get_mothbug_fabric_value(garment))
		to_chat(src, span_warning("[target]'s [garment.name] is too tough to chew through."))
		return FALSE
	if(is_mothbug_repelled(garment))
		to_chat(src, span_warning("[target] reeks of lavender. I can't bring myself to chew."))
		return FALSE
	return nibble_garment(target, garment, zone)

/mob/living/simple_animal/mothbug/proc/can_keep_nibbling(mob/living/carbon/human/target, obj/item/garment)
	return !QDELETED(target) && !QDELETED(garment) && garment.loc == target && Adjacent(target) && is_mothbug_helpless(target)

/mob/living/simple_animal/mothbug/proc/nibble_garment(mob/living/carbon/human/target, obj/item/garment, zone)
	var/garment_name = garment.name
	visible_message(
		span_warning("[src] nibbles at [target]'s [garment_name]!"),
		span_notice("I nibble at [target]'s [garment_name]."),
		vision_distance = 4,
	)
	if(!do_after(src, MOTHBUG_NIBBLE_TIME, target, extra_checks = CALLBACK(src, PROC_REF(can_keep_nibbling), target, garment)))
		return FALSE
	// Worn fabric gives half silk, so wardrobes stay the better meal.
	bite_fabric(garment, 0.5)
	if(QDELETED(garment))
		target.visible_message(span_warning("[target]'s [garment_name] falls away in tatters!"), span_userdanger("My [garment_name] falls away in tatters!"))
		return TRUE
	if(istype(garment, /obj/item/clothing/legwears))
		var/obj/item/clothing/legwears/legwear = garment
		legwear.tear_open()
	return TRUE

/mob/living/simple_animal/mothbug/proc/tickle_bare_skin(mob/living/carbon/human/target, zone)
	var/area_name = get_mothbug_tickle_area(target, zone)
	visible_message(
		span_notice("[src] brushes its feathery antennae over [target]'s bare [area_name]."),
		span_notice("There is no fabric left there. I tickle [target]'s bare [area_name] instead."),
		vision_distance = 4,
	)
	if(!do_after(src, MOTHBUG_TICKLE_TIME, target, extra_checks = CALLBACK(src, PROC_REF(can_keep_tickling), target)))
		return FALSE
	to_chat(target, span_love("Feathery antennae flutter across my [area_name]!"))
	if(target.stat == CONSCIOUS)
		target.emote(pick("giggle", "laugh"), forced = TRUE)
	if(mothbug_target_allows(target, /datum/erp_preference/boolean/lust_magic_targetable))
		SEND_SIGNAL(target, COMSIG_SEX_ADJUST_AROUSAL, get_mothbug_tickle_arousal(zone))
	return TRUE

/mob/living/simple_animal/mothbug/proc/can_keep_tickling(mob/living/carbon/human/target)
	return !QDELETED(target) && Adjacent(target) && is_mothbug_helpless(target)
