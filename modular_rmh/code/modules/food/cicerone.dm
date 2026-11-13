/**
 * Identifying what's in a container.
 *
 * Base game only lets the dead and silicons read a container's exact contents;
 * a living character sees the vague "it contains something" line no matter how
 * skilled they are. A trained palate - either the Cicerone quirk or a skilled
 * cook or alchemist - can now name what's in the cup, but only up close: you
 * have to be near enough to smell it.
 *
 * Sealed containers (barrels, kegs) stay unreadable by design - pour some out
 * into a cup first.
 */

#define TRAIT_CICERONE "Cicerone"

/// Skill rank at which a character can identify reagents unaided.
#define CICERONE_SKILL_RANK SKILL_RANK_EXPERT

/mob/living/can_see_reagents(atom/target)
	. = ..()
	if(.)
		return
	// A nose, not x-ray vision: only works within reach.
	if(!target || get_dist(get_turf(target), get_turf(src)) > 1)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_CICERONE))
		return TRUE
	if(!mind)
		return FALSE
	if(GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/craft/cooking) >= CICERONE_SKILL_RANK)
		return TRUE
	if(GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/craft/alchemy) >= CICERONE_SKILL_RANK)
		return TRUE

/**
 * Contents of a vessel that isn't see-through.
 *
 * Base examine only lists reagents through TRANSPARENT containers, so carafes,
 * pots and shot glasses showed nothing at all. A trained palate reads them by
 * nose, up close. Scoped to carried vessels on purpose: barrels and kegs are
 * structures, so they stay unreadable and you must pour a measure out first.
 */
/obj/item/reagent_containers/proc/get_trained_palate_contents(mob/user)
	if(!reagents || (reagents.flags & TRANSPARENT))
		return null
	if(!user?.can_see_reagents(src))
		return null
	if(!length(reagents.reagent_list))
		return null
	var/list/lines = list("A sniff tells me it holds:")
	for(var/datum/reagent/listed as anything in reagents.reagent_list)
		lines += "[(UNIT_FORM_STRING(listed.volume))] of <font color=[listed.color]>[listed.name]</font>"
	return lines

/datum/quirk/positive/cicerone
	name = "Cicerone"
	desc = "A lifetime spent around pots, casks, and apothecary shelves has sharpened your palate. A sip or a sniff is all it takes for you to name what's in a cup or bottle."
	point_value = -4

/datum/quirk/positive/cicerone/on_spawn()
	ADD_TRAIT(owner, TRAIT_CICERONE, "[type]")

/datum/quirk/positive/cicerone/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_CICERONE, "[type]")

#undef CICERONE_SKILL_RANK
