// Chastity moods: devotion and church vows soothe, lust gods and lovefiends chafe, a flat cage cramps a big cock.

/datum/stress_event/chastity_devout
	stress_change = -1
	desc = span_green("This restraint steadies my spirit.")

/datum/stress_event/chastity_church
	stress_change = -1
	desc = span_green("My vows feel stronger in this restraint.")

/datum/stress_event/chastity_frustration
	stress_change = 1
	desc = span_red("This restraint is maddening.")

/datum/stress_event/chastity_cramped
	stress_change = 1
	desc = span_red("This flat cage is far too cramped for me.")

/// TRUE if the god would see a chastity device as virtue: good or neutral faiths, save the gods of love and pleasure.
/proc/patron_blesses_chastity(datum/patron/patron)
	if(!istype(patron, /datum/patron/faerun/good_gods) && !istype(patron, /datum/patron/faerun/neutral_gods))
		return FALSE
	return !is_pleasure_patron(patron)

/// Gods of love, pleasure and desire, whose followers chafe in chastity.
/proc/is_pleasure_patron(datum/patron/patron)
	return istype(patron, /datum/patron/faerun/good_gods/Sune) || istype(patron, /datum/patron/faerun/good_gods/Sharess) || istype(patron, /datum/patron/faerun/evil_gods/Blissara)

/obj/item/clothing/undies/chastity/proc/clear_moods(mob/living/carbon/human/target)
	target?.remove_stress(/datum/stress_event/chastity_devout)
	target?.remove_stress(/datum/stress_event/chastity_church)
	target?.remove_stress(/datum/stress_event/chastity_frustration)
	target?.remove_stress(/datum/stress_event/chastity_cramped)

/// Recomputes the wearer's chastity moods from their faith, job, vices and fit.
/obj/item/clothing/undies/chastity/proc/refresh_moods()
	clear_moods(wearer)
	if(!wearer || !get_front_anatomy())
		return
	if(wearer.has_quirk(/datum/quirk/negative/addiction/godfearing) && patron_blesses_chastity(wearer.patron))
		wearer.add_stress(/datum/stress_event/chastity_devout)
	if(wearer.mind?.assigned_role?.department_flag & CHAPEL)
		wearer.add_stress(/datum/stress_event/chastity_church)
	if(wearer.has_quirk(/datum/quirk/negative/addiction/lovefiend) || is_pleasure_patron(wearer.patron))
		wearer.add_stress(/datum/stress_event/chastity_frustration)
	if(flat_cage && cages_cock())
		var/obj/item/organ/genitals/penis/penis = wearer.getorganslot(ORGAN_SLOT_PENIS)
		if(penis.organ_size >= DEFAULT_PENIS_SIZE && penis.sheath_type == SHEATH_TYPE_NONE)
			wearer.add_stress(/datum/stress_event/chastity_cramped)
