// Lube-up actions: a held balm or oil first, else spit, worked into a hole or onto the toy in hand.

/datum/sex_action/lube_up
	abstract_type = /datum/sex_action/lube_up
	name = "Lube up"
	description = "Work something slick in: a held balm or oil, else spit."
	do_time = 2 SECONDS
	continous = FALSE
	requires_free_hands = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	var/organ_slot = ORGAN_SLOT_VAGINA

/datum/sex_action/lube_up/proc/get_hole(mob/living/target)
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ)
	var/obj/item/organ/genitals/filling_organ/hole = target?.getorganslot(organ_slot)
	if(!istype(hole) || !hole.orifice_type)
		return null
	return hole

/// A held lube beats spit; with no lube and a covered mouth there is nothing to use.
/datum/sex_action/lube_up/proc/has_lube_source(mob/living/user)
	return user.get_held_lube_container() || user.mouth_is_free(user, cloth_blocks = TRUE)

/datum/sex_action/lube_up/proc/has_lube_target(mob/living/user, mob/living/target)
	if(!get_hole(target))
		return FALSE
	return check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE)

/datum/sex_action/lube_up/shows_on_menu(mob/living/user, mob/living/target)
	return !!get_hole(target)

/datum/sex_action/lube_up/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return has_lube_target(user, target) && has_lube_source(user)

/datum/sex_action/lube_up/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/organ/genitals/filling_organ/hole = get_hole(target)
	if(hole)
		user.lube_up_hole(hole.get_orifice())

/datum/sex_action/lube_up/vagina
	name = "Lube pussy"
	organ_slot = ORGAN_SLOT_VAGINA
	uses_target_organs = list(ORGAN_SLOT_VAGINA)

/datum/sex_action/lube_up/anus
	name = "Lube ass"
	organ_slot = ORGAN_SLOT_ANUS
	uses_target_organs = list(ORGAN_SLOT_ANUS)

/// Slicks the toy in the active hand from a container in the other hand, else with spit.
/datum/sex_action/lube_up/toy
	name = "Lube toy"
	target_menu_zone_mask = SEX_UI_ZONE_ARMS
	organ_slot = null

/datum/sex_action/lube_up/toy/proc/get_toy(mob/living/user)
	RETURN_TYPE(/obj/item/dildo)
	var/obj/item/dildo/toy = user?.get_active_held_item()
	return istype(toy) ? toy : null

/datum/sex_action/lube_up/toy/has_lube_target(mob/living/user, mob/living/target)
	return user == target && !!get_toy(user)

/datum/sex_action/lube_up/toy/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && !!get_toy(user)

/datum/sex_action/lube_up/toy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo/toy = get_toy(user)
	if(toy)
		user.lube_up_toy(toy)
