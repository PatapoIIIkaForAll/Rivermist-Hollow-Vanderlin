/// Counts quirk
/proc/cmp_quirk_cost(datum/quirk/A, datum/quirk/B)
	return B.point_value - A.point_value

/// Penalize player for picking quirks that don't affect them for some reason and give free points
/// Penalizes a player for picking a vice that didn't affect them, removing boons to compensate
/datum/quirk/proc/penalize_points(penalize_text = "")
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	var/list/boons = list() // Get all boons that the player has
	for(var/datum/quirk/Q in H.quirks)
		if(Q.quirk_category == QUIRK_POSITIVE)
			boons += Q
	if(!length(boons))
		return

	var/debt = abs(point_value)
	sortTim(boons, /proc/cmp_quirk_cost)
	// Look for a boon that exactly covers the debt
	var/datum/quirk/exact = null
	for(var/datum/quirk/Q in boons)
		if(abs(Q.point_value) == debt)
			exact = Q
			break
	if(exact)
		H.remove_quirk(exact.type)
	else
		// No exact match — remove cheapest boons until debt is covered
		while(debt > 0 && length(boons))
			var/datum/quirk/first = boons[1]
			var/list/candidates = list()
			for(var/datum/quirk/Q in boons)
				if(Q.point_value == first.point_value)
					candidates += Q
			var/datum/quirk/chosen = pick(candidates)
			debt -= abs(chosen.point_value)
			boons -= chosen
			H.remove_quirk(chosen.type)

	to_chat(H, span_warning(penalize_text))
