/datum/sex_action/sex/other
	abstract_type = /datum/sex_action/sex/other
	flipped = TRUE

/datum/sex_action/sex/other/try_knot_on_climax(mob/living/user, mob/living/target)
	// Nothing is inside while still pressing at the opening.
	if(orifice_pressing)
		return FALSE
	if(!knot_on_finish)
		return FALSE
	if(!can_knot)
		return FALSE

	return SEND_SIGNAL(target, COMSIG_SEX_TRY_KNOT, user, force, src)

/datum/sex_action/sex/other/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/sex_action/sex/other/get_scene_user_role()
	if(hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		return SEX_SCENE_ROLE_RECEIVER
	return ..()

/datum/sex_action/sex/other/get_scene_user_slot()
	if(hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		return hole_id
	return ..()

/datum/sex_action/sex/other/get_scene_target_role()
	if(hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		return SEX_SCENE_ROLE_GIVER
	return ..()

/datum/sex_action/sex/other/get_scene_target_slot()
	if(hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		return ORGAN_SLOT_PENIS
	return ..()

/datum/sex_action/sex/other/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, ORGAN_SLOT_PENIS)
	if(hole_id)
		add_sex_lock(user, hole_id, null, FALSE)


/datum/sex_action/sex/other/check_hole_storage_available(mob/living/user, mob/living/target)
	return ..()
