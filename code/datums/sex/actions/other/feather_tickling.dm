/datum/sex_action/feather_tickling
	parent_type = /datum/sex_action/held_item_zone
	name = "Feather tickle"
	description = "Use a held feather on the body zone selected on your combat doll."
	action_item_type = /obj/item/natural/feather

/datum/sex_action/feather_tickling/is_supported_zone(zone)
	var/static/list/supported_zones = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_EARS,
		BODY_ZONE_PRECISE_MOUTH,
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

/datum/sex_action/feather_tickling/proc/get_tickled_area(mob/living/target)
	switch(selected_zone)
		if(BODY_ZONE_HEAD)
			return "jawline"
		if(BODY_ZONE_PRECISE_EARS)
			return "ear"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "lips"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_CHEST)
			return "nipples on [target.p_their()] [get_nipple_chest_description(target)]"
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
			return "armpit"
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return "palm"
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return "inner thigh"
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return "sole and toes"
	return parse_zone(selected_zone)

/datum/sex_action/feather_tickling/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] brings [action_item] toward [target]'s [get_tickled_area(target)]..."))

/datum/sex_action/feather_tickling/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "traces"
	var/arousal_amt = 0.5
	var/orgasm_amt = 0.1

	switch(selected_zone)
		if(BODY_ZONE_PRECISE_GROIN)
			action_text = "teases"
			arousal_amt = 1.5
			orgasm_amt = 0.8
		if(BODY_ZONE_CHEST)
			action_text = "flutters across"
			arousal_amt = 1.1
			orgasm_amt = 0.5
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			action_text = "mercilessly tickles"
			arousal_amt = 0.8
			orgasm_amt = 0.2
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NECK)
			action_text = "delicately brushes"
			arousal_amt = 0.7
			orgasm_amt = 0.2

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] [action_item] over [target]'s [get_tickled_area(target)]."))
	if(prob(35))
		target.do_jitter_animation(5)
	perform_sex_action(target, user, arousal_amt, 0, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/feather_tickling/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] draws [action_item || "the feather"] away from [target]."))
