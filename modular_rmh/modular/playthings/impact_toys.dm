// Impact toys: crop, paddle and flogger. They sting and arouse through the sex menu and never wound.

/obj/item/impact_toy
	abstract_type = /obj/item/impact_toy
	name = "impact toy"
	icon = 'modular_rmh/icons/obj/lewd/playthings.dmi'
	possible_item_intents = list(/datum/intent/use)
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	experimental_onhip = TRUE
	resistance_flags = FLAMMABLE
	sellprice = 8
	/// Pain of one strike before zone and force scaling.
	var/impact_pain = 2
	/// Arousal of one strike before zone and force scaling.
	var/impact_arousal = 1
	/// Verb for one strike, such as "swats".
	var/impact_verb = "swats"
	/// What the struck person feels, for their own chat.
	var/impact_feel = "a bright sting"
	var/list/impact_sounds = list('modular_rmh/sound/effects/slap1.ogg', 'modular_rmh/sound/effects/slap2.ogg')
	/// How hard its marks land, from IMPACT_TOOL_HAND to IMPACT_TOOL_WHIP.
	var/impact_mark_tier = IMPACT_TOOL_STRAP

/obj/item/impact_toy/riding_crop
	name = "riding crop"
	desc = "A slim rod with a leather keeper at the tip, made for sharp and precise swats."
	icon_state = "riding_crop"
	impact_pain = 2.5
	impact_arousal = 1
	impact_verb = "flicks"
	impact_feel = "a sharp, precise sting"

/obj/item/impact_toy/paddle
	name = "spanking paddle"
	desc = "A flat paddle faced with leather. It lands broad and loud."
	icon_state = "paddle"
	impact_pain = 2
	impact_arousal = 1.3
	impact_verb = "paddles"
	impact_feel = "a broad, spreading warmth"
	impact_sounds = list('sound/foley/slap.ogg', 'sound/foley/smackspecial.ogg')

/obj/item/impact_toy/flogger
	name = "flogger"
	desc = "A handle with many soft leather tails. Each lash stings lightly and spreads wide."
	icon_state = "flogger"
	impact_pain = 1.2
	impact_arousal = 1.5
	impact_verb = "flogs"
	impact_feel = "a shower of light stings"
	impact_mark_tier = IMPACT_TOOL_HAND

/datum/sex_action/impact_play
	parent_type = /datum/sex_action/held_item_zone
	name = "Impact play"
	description = "Use a held crop, paddle or flogger on the body zone selected on your combat doll."
	action_item_type = /obj/item/impact_toy
	check_same_tile = FALSE
	stamina_cost = 0.3

/datum/sex_action/impact_play/is_supported_zone(zone)
	var/static/list/supported_zones = list(
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

/datum/sex_action/impact_play/proc/get_struck_area()
	switch(selected_zone)
		if(BODY_ZONE_CHEST)
			return "chest"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "belly"
		if(BODY_ZONE_PRECISE_GROIN)
			return "rear"
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return "arm"
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return "palm"
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return "thigh"
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return "sole"
	return parse_zone(selected_zone)

/// Arousal and pain multipliers for the struck zone, as list(arousal, pain).
/datum/sex_action/impact_play/proc/get_zone_multipliers()
	switch(selected_zone)
		if(BODY_ZONE_PRECISE_GROIN)
			return list(1.3, 1)
		if(BODY_ZONE_CHEST)
			return list(1.1, 1.2)
		if(BODY_ZONE_PRECISE_STOMACH)
			return list(0.8, 1)
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return list(0.4, 1.3)
	return list(0.6, 0.8)

/datum/sex_action/impact_play/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lines up [action_item] with [target]'s [get_struck_area()]..."))

/datum/sex_action/impact_play/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/impact_toy/toy = action_item
	if(!istype(toy))
		return
	var/list/multipliers = get_zone_multipliers()
	var/arousal_amt = toy.impact_arousal * multipliers[1] + force * 0.3
	var/pain_amt = toy.impact_pain * multipliers[2] * force
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [toy.impact_verb] [target]'s [get_struck_area()] with [toy]."))
	playsound(target, pick(toy.impact_sounds), 35 + force * 5, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, arousal_amt, pain_amt, arousal_amt * 0.5)
	handle_passive_ejaculation(target)
	if(ishuman(target))
		var/mob/living/carbon/human/struck = target
		struck.take_impact_mark(user, selected_zone, force, toy)
	if(force >= SEX_FORCE_HIGH)
		to_chat(target, span_warning("My [get_struck_area()] throbs with [toy.impact_feel]."))
	else if(prob(20))
		to_chat(target, span_notice("[capitalize(toy.impact_feel)] lingers on my [get_struck_area()]."))

/datum/sex_action/impact_play/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [action_item] from [target]'s [get_struck_area()]."))

// Sewn on cured hide with a needle, like other leatherwork.
/datum/repeatable_crafting_recipe/leather/impact_toy
	abstract_type = /datum/repeatable_crafting_recipe/leather/impact_toy
	category = "Lewd"
	craftdiff = 1

/datum/repeatable_crafting_recipe/leather/impact_toy/riding_crop
	name = "riding crop"
	output = /obj/item/impact_toy/riding_crop
	requirements = list(/obj/item/grown/log/tree/stick = 1, /obj/item/natural/hide/cured = 1)

/datum/repeatable_crafting_recipe/leather/impact_toy/paddle
	name = "spanking paddle"
	output = /obj/item/impact_toy/paddle
	requirements = list(/obj/item/natural/wood/plank = 1, /obj/item/natural/hide/cured = 1)

/datum/repeatable_crafting_recipe/leather/impact_toy/flogger
	name = "flogger"
	output = /obj/item/impact_toy/flogger
	requirements = list(/obj/item/grown/log/tree/stick = 1, /obj/item/natural/hide/cured = 2)
