/datum/mob_descriptor/armpit_hair
	name = "armpit hair"
	slot = MOB_DESCRIPTOR_SLOT_ARMPITS
	verbage = "%HAVE%"
	show_obscured = TRUE

/datum/mob_descriptor/armpit_hair/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	if(!get_location_accessible(described, BODY_ZONE_CHEST))
		return FALSE
	return !!get_description(described)

/datum/mob_descriptor/armpit_hair/get_description(mob/living/described)
	return get_description_for_watcher(described, null)

/datum/mob_descriptor/armpit_hair/get_description_for_watcher(mob/living/described, mob/watcher)
	var/mob/living/carbon/human/human = described
	var/datum/bodypart_feature/hair/body_hair/armpit/armpit_hair_feature = human.get_bodypart_feature_of_slot(BODYPART_FEATURE_ARMPIT_HAIR)
	return armpit_hair_feature?.get_description(wants_descriptor_color(watcher))
