/datum/sex_action/suck_nipples
	name = "Suck nipples"
	description = "Suck and tease their nipples, with flavor matching the shape of their chest."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	check_same_tile = FALSE

/datum/sex_action/suck_nipples/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target && !allows_self_use(user))
		return FALSE
	return TRUE

/datum/sex_action/suck_nipples/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target && !allows_self_use(user))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(target.getorganslot(ORGAN_SLOT_BREASTS) && check_sex_lock(target, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/suck_nipples/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] mouth to the nipples on [target]'s [get_nipple_chest_description(target)]..."))

/datum/sex_action/suck_nipples/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] sucks the nipples on [target]'s [get_nipple_chest_description(target)]..."))
	user.make_sucking_noise()

	perform_sex_action(target, user, 1, 3, 0.1)
	handle_passive_ejaculation(target)

	var/obj/item/organ/genitals/filling_organ/breasts/breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts || !breasts.reagents || !user.reagents)
		return
	if(breasts.reagents.total_volume <= 0 || user.reagents.holder_full())
		return
	var/free_space = user.reagents.maximum_volume - user.reagents.total_volume
	var/milk_to_add = min(max(breasts.organ_size, 1), breasts.reagents.total_volume, free_space)
	if(milk_to_add <= 0)
		return
	breasts.reagents.trans_to(user, milk_to_add, transfered_by = user, method = INGEST, show_message = FALSE)
	if(prob(35))
		to_chat(user, span_notice("I can taste milk."))
		to_chat(target, span_notice("I can feel milk leak from my buds."))

/datum/sex_action/suck_nipples/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lifts [user.p_their()] mouth from [target]'s [get_nipple_chest_description(target)]."))

/datum/sex_action/suck_nipples/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)

