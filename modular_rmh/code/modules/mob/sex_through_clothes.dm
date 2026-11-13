/// Arousal of a touch through a garment, as a share of the bare touch.
#define THROUGH_CLOTHES_AROUSAL_MULT 0.5

/datum/sex_action
	/// Body zone a hand touch reaches through soft clothes, BODY_ZONE_CHEST or BODY_ZONE_PRECISE_GROIN, or null.
	var/through_clothes_zone
	/// The touched one is the target (TRUE) or the user themselves (FALSE).
	var/through_clothes_on_target = TRUE

/// Outermost soft worn garment covering zone on wearer, or null when the spot is bare or opened for access.
/proc/get_covering_soft_garment(mob/living/carbon/wearer, zone)
	if(!iscarbon(wearer))
		return null
	var/cover_flag = zone == BODY_ZONE_CHEST ? CHEST : GROIN
	var/list/candidates = list()
	if(ishuman(wearer))
		var/mob/living/carbon/human/human_wearer = wearer
		candidates += list(human_wearer.cloak, human_wearer.wear_armor, human_wearer.wear_shirt, human_wearer.wear_pants)
	candidates += list(wearer.undershirt, wearer.bra, wearer.underwear)
	for(var/obj/item/clothing/garment in candidates)
		if(!(garment.body_parts_covered & cover_flag))
			continue
		if(garment.armor_class > AC_LIGHT || garment.genital_access || garment.allow_erp_equipped)
			continue
		// Ropes cover nothing.
		if(istype(garment, /obj/item/clothing/bra/shibari))
			continue
		return garment
	return null

/// "her linen shirt", "her damp linen shirt" or "her soaked linen shirt".
/proc/get_through_clothes_name(mob/living/wearer, obj/item/clothing/garment)
	var/wet = ""
	var/datum/component/fluid_soaked/soak = garment.GetComponent(/datum/component/fluid_soaked)
	if(soak?.stain_level >= 2)
		wet = "soaked "
	else if(soak?.stain_level >= 1)
		wet = "damp "
	return "[wearer.p_their()] [wet][garment.name]"

/// Inserts text before the final punctuation of string, ending it with a period when it had none.
/proc/insert_before_end_punctuation(string, insert)
	var/end = length(string)
	var/tail = ""
	while(end > 0 && (copytext(string, end, end + 1) in list(".", "!", "?")))
		tail = copytext(string, end, end + 1) + tail
		end--
	return "[copytext(string, 1, end + 1)][insert][tail || "."]"

/// The garment this action touches through right now, or null.
/datum/sex_action/proc/get_through_clothes_garment()
	if(!through_clothes_zone)
		return null
	var/mob/living/touched = through_clothes_on_target ? action_target : action_user
	return get_covering_soft_garment(touched, through_clothes_zone)

/// Arousal multiplier for pleasure_receiver: less when the touched one feels it through a soft garment.
/datum/sex_action/proc/get_through_clothes_multiplier(mob/living/pleasure_receiver)
	if(!through_clothes_zone)
		return 1
	var/mob/living/touched = through_clothes_on_target ? action_target : action_user
	if(pleasure_receiver != touched || !get_covering_soft_garment(touched, through_clothes_zone))
		return 1
	return THROUGH_CLOTHES_AROUSAL_MULT

/// The per-cycle line with "through <garment>" before its final punctuation, when a soft garment is in between.
/datum/sex_action/proc/add_through_clothes_suffix(string)
	var/obj/item/clothing/garment = get_through_clothes_garment()
	if(!garment || !istext(string))
		return string
	var/mob/living/touched = through_clothes_on_target ? action_target : action_user
	return insert_before_end_punctuation(string, " through [get_through_clothes_name(touched, garment)]")

// Rubbing and squeezing by hand; penetrating actions need bare skin and are left out.
/datum/sex_action/masturbate/breasts
	through_clothes_zone = BODY_ZONE_CHEST
	through_clothes_on_target = FALSE

/datum/sex_action/masturbate/nipples
	through_clothes_zone = BODY_ZONE_CHEST
	through_clothes_on_target = FALSE

/datum/sex_action/masturbate/other/breasts
	through_clothes_zone = BODY_ZONE_CHEST

/datum/sex_action/masturbate/other/nipples
	through_clothes_zone = BODY_ZONE_CHEST

/datum/sex_action/masturbate/other/squeeze_breasts
	through_clothes_zone = BODY_ZONE_CHEST

/datum/sex_action/masturbate/clit_rub
	through_clothes_zone = BODY_ZONE_PRECISE_GROIN
	through_clothes_on_target = FALSE

/datum/sex_action/masturbate/vagina
	through_clothes_zone = BODY_ZONE_PRECISE_GROIN
	through_clothes_on_target = FALSE

/datum/sex_action/masturbate/other/clit_rub
	through_clothes_zone = BODY_ZONE_PRECISE_GROIN

/datum/sex_action/masturbate/other/clit
	through_clothes_zone = BODY_ZONE_PRECISE_GROIN

/datum/sex_action/masturbate/penis
	through_clothes_zone = BODY_ZONE_PRECISE_GROIN
	through_clothes_on_target = FALSE

/datum/sex_action/masturbate/other/penis
	through_clothes_zone = BODY_ZONE_PRECISE_GROIN

#undef THROUGH_CLOTHES_AROUSAL_MULT
