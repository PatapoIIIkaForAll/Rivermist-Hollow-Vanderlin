
/datum/sex_action/blowjob
	name = "Blowjob"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	requires_hole_storage = TRUE
	hole_id = BODY_ZONE_PRECISE_MOUTH
	stored_item_type = /obj/item/organ/genitals/penis
	stored_item_name = "receiving member"
	require_grab = FALSE
	check_same_tile = FALSE
	requires_hole_storage = FALSE
	gags_user = TRUE
	flipped = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_PENIS

/datum/sex_action/blowjob/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target && !allows_self_use(user))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/blowjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target && !allows_self_use(user))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE

	return TRUE

/datum/sex_action/blowjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts sucking [target]'s cock..."))

/datum/sex_action/blowjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	user.make_mouth_noise(get_oral_noise_kind())
	do_thrust_animate(user, target)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] sucks [target] off."))

	perform_sex_action(target, user, 2, 0, 2)
	handle_passive_ejaculation(target)
	perform_sex_action(user, target, 1, 0, 0.2)
	handle_passive_ejaculation(user)
	coat_penis_with_saliva(user, target, 0.5, 3)

/datum/sex_action/blowjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops sucking [target]'s cock ..."))

/datum/sex_action/blowjob/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, ORGAN_SLOT_PENIS, null, FALSE)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/blowjob/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		target.visible_message(span_love("[user] cums into [target]'s mouth!"))
		return ORGASM_LOCATION_ORAL
	else
		target.visible_message(span_love("[user] creams themselves from sucking [target]'s cock!"))
		return ORGASM_LOCATION_SELF
