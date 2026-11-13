/datum/sex_action/wax_play
	parent_type = /datum/sex_action/held_item_zone
	name = "Drip wax"
	description = "Drip wax from a held lit candle onto the body zone selected on your combat doll."
	action_item_type = /obj/item/candle

/datum/sex_action/wax_play/is_action_item_usable(obj/item/item)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/candle/candle = item
	return candle.lit && (candle.infinite || candle.wax > 0)

/datum/sex_action/wax_play/is_supported_zone(zone)
	var/static/list/supported_zones = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_EARS,
		BODY_ZONE_PRECISE_NECK,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_STOMACH,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)
	return zone in supported_zones

/datum/sex_action/wax_play/proc/get_waxed_area(mob/living/target)
	switch(selected_zone)
		if(BODY_ZONE_HEAD)
			return "neck and shoulders"
		if(BODY_ZONE_PRECISE_EARS)
			return "skin behind [target.p_their()] ear"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck and collarbone"
		if(BODY_ZONE_CHEST)
			return "nipples and [get_nipple_chest_description(target)]"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "belly"
		if(BODY_ZONE_PRECISE_GROIN)
			if(target.getorganslot(ORGAN_SLOT_TESTICLES))
				return "balls and inner thighs"
			if(target.getorganslot(ORGAN_SLOT_PENIS))
				return "cock and inner thighs"
			if(target.getorganslot(ORGAN_SLOT_VAGINA))
				return "cunt and inner thighs"
			return "inner thighs"
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return "arm"
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return "palm and wrist"
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return "thigh"
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return "foot"
	return parse_zone(selected_zone)

/datum/sex_action/wax_play/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] tilts [action_item] over [target]'s [get_waxed_area(target)]..."))

/datum/sex_action/wax_play/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/arousal_amt = 0.6
	var/pain_amt = 1.5
	var/orgasm_amt = 0.2

	switch(selected_zone)
		if(BODY_ZONE_PRECISE_GROIN)
			arousal_amt = 1.4
			pain_amt = 3
			orgasm_amt = 1
		if(BODY_ZONE_CHEST)
			arousal_amt = 1.2
			pain_amt = 2.5
			orgasm_amt = 0.8
		if(BODY_ZONE_PRECISE_STOMACH)
			arousal_amt = 0.9
			pain_amt = 2
			orgasm_amt = 0.5
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_NECK)
			arousal_amt = 0.5
			pain_amt = 2.2
			orgasm_amt = 0.2

	arousal_amt += force * 0.3
	pain_amt += force * 1.2
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] trails hot wax over [target]'s [get_waxed_area(target)]."))
	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

	var/obj/item/candle/candle = action_item
	if(!candle || QDELETED(candle))
		return
	if(!candle.infinite)
		candle.wax = max(candle.wax - 5, 0)
		candle.update_appearance(UPDATE_ICON_STATE)

/datum/sex_action/wax_play/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rights [action_item || "the candle"] and stops dripping wax onto [target]."))
