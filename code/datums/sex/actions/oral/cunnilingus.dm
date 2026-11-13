/datum/sex_action/cunnilingus
	name = "Cunnilingus"
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	gags_user = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_VAGINA

/datum/sex_action/cunnilingus/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target && !allows_self_use(user))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/cunnilingus/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target && !allows_self_use(user))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/cunnilingus/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts sucking [target]'s clit..."))

/datum/sex_action/cunnilingus/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] sucks [target]'s clit..."))
	user.make_mouth_noise("lick")
	do_thrust_animate(user, target)

	perform_sex_action(target, user, 2, 3, 2)
	handle_passive_ejaculation(target)
	perform_sex_action(user, target, 0.5, 0, 0)
	deposit_saliva_in_hole(user, target, ORGAN_SLOT_VAGINA, 0.5, 4)

/datum/sex_action/cunnilingus/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		target.visible_message(span_love("[user] squirts girlcum into [target]'s mouth!"))
		return ORGASM_LOCATION_ORAL
	else //I mean it's never gonna happen but ok
		target.visible_message(span_love("[user] cums from sucking [target]'s pussy somehow!"))
		return ORGASM_LOCATION_SELF


/datum/sex_action/cunnilingus/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops sucking [target]'s clit ..."))

/datum/sex_action/cunnilingus/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, ORGAN_SLOT_VAGINA, null, FALSE)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
