/datum/sex_action/bellyriding
	abstract_type = /datum/sex_action/bellyriding
	name = "Bellyriding"
	description = "Internal bellyriding interaction."
	continous = FALSE
	stamina_cost = 0.2
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/bellyriding/proc/has_harness_link(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/component/bellyriding/user_comp = user.GetComponent(/datum/component/bellyriding)
	if(user_comp?.current_victim == target)
		return TRUE
	var/datum/component/bellyriding/target_comp = target.GetComponent(/datum/component/bellyriding)
	if(target_comp?.current_victim == user)
		return TRUE
	return FALSE

/datum/sex_action/bellyriding/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	// Hidden from the main interactions list; use the dedicated tab instead.
	return FALSE

/datum/sex_action/bellyriding/groin_rub
	name = "Bellyriding Grind"

/datum/sex_action/bellyriding/groin_rub/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!has_harness_link(user, target))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/bellyriding/groin_rub/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(can_show_action_message(user, target))
		user.visible_message(
			spanify_force("[user] grinds [user.p_their()] cock along [target]'s belly."),
			spanify_force("You grind your cock along [target]'s belly."),
			ignored_mobs = list(target)
		)
		to_chat(target, spanify_force("[user] grinds [user.p_their()] cock across your belly."))
	do_thrust_animate(user, target, 4, 2)

	perform_sex_action(user, target, 1, 0, 1)
	handle_passive_ejaculation(user)
	perform_sex_action(target, user, 0.5, 0, 0)

/datum/sex_action/bellyriding/groin_rub/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(user && target)
		user.visible_message(span_love("[user] cums across [target]'s body from the harness!"))
	return ORGASM_LOCATION_ONTO

/datum/sex_action/bellyriding/frot
	name = "Bellyriding Frot"

/datum/sex_action/bellyriding/frot/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!has_harness_link(user, target))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS) || !target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/bellyriding/frot/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(can_show_action_message(user, target))
		user.visible_message(
			spanify_force("[user] frots [user.p_their()] cock against [target]'s while they hang from the harness."),
			spanify_force("You frot your cock against [target]'s while they hang from the harness."),
			ignored_mobs = list(target)
		)
		to_chat(target, spanify_force("[user]'s shaft grinds against yours while you're strapped in place."))
	do_thrust_animate(user, target, 4, 2)

	perform_sex_action(user, target, 1, 0, 1)
	handle_passive_ejaculation(user)
	perform_sex_action(target, user, 1, 0, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/bellyriding/frot/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(user && target)
		user.visible_message(span_love("[user] cums while grinding against [target] in the harness!"))
	return ORGASM_LOCATION_ONTO

/datum/sex_action/bellyriding/anal
	name = "Bellyriding Anal"
	hole_id = ORGAN_SLOT_ANUS

/datum/sex_action/bellyriding/anal/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!has_harness_link(user, target))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS) || !target.getorganslot(ORGAN_SLOT_ANUS))
		return FALSE
	return TRUE

/datum/sex_action/bellyriding/anal/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(can_show_action_message(user, target))
		user.visible_message(
			spanify_force("[user] [get_generic_force_adjective()] thrusts into [target]'s ass while they dangle from the harness."),
			spanify_force("You [get_generic_force_adjective()] thrust into [target]'s ass while they dangle from the harness."),
			ignored_mobs = list(target)
		)
		to_chat(target, spanify_force("[user]'s cock drives into your ass while the harness holds you still!"))
	do_thrust_animate(user, target, 4, 2)

	perform_sex_action(user, target, 2, 0, 2)
	handle_passive_ejaculation(user)
	perform_sex_action(target, user, 1.5, 5, 1.5)
	handle_passive_ejaculation(target)

/datum/sex_action/bellyriding/anal/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		if(user && target)
			user.visible_message(span_love("[user] cums from [target]'s cock while hanging in the harness!"))
			user.lose_virginity()
			target.lose_virginity()
		return ORGASM_LOCATION_SELF

	if(user && target)
		user.visible_message(span_love("[user] cums into [target]'s ass while the harness holds them still!"))
		user.lose_virginity()
		target.lose_virginity()
	return ORGASM_LOCATION_INTO

/datum/sex_action/bellyriding/vaginal
	name = "Bellyriding Vaginal"
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/bellyriding/vaginal/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!has_harness_link(user, target))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS) || !target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/bellyriding/vaginal/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(can_show_action_message(user, target))
		user.visible_message(
			spanify_force("[user] [get_generic_force_adjective()] pistons into [target]'s pussy, held tight by the harness."),
			spanify_force("You [get_generic_force_adjective()] piston into [target]'s pussy, held tight by the harness."),
			ignored_mobs = list(target)
		)
		to_chat(target, spanify_force("[user]'s cock pounds into your pussy while the harness keeps you in place!"))
	do_thrust_animate(user, target, 4, 2)

	perform_sex_action(user, target, 2, 0, 2)
	handle_passive_ejaculation(user)
	perform_sex_action(target, user, 1.5, 2, 1.5)
	handle_passive_ejaculation(target)

/datum/sex_action/bellyriding/vaginal/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		if(user && target)
			user.visible_message(span_love("[user] creams themselves around [target]'s cock while hanging in the harness!"))
			user.lose_virginity()
			target.lose_virginity()
		return ORGASM_LOCATION_ONTO

	if(user && target)
		user.visible_message(span_love("[user] cums into [target]'s pussy while the harness holds them tight!"))
		user.lose_virginity()
		target.lose_virginity()
	return ORGASM_LOCATION_INTO
