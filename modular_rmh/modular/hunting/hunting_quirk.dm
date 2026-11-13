// Hunting & Tracking pack - the character-creation entry for TRAIT_PERFECT_TRACKER.
//
// Traits themselves are not picked at chargen in this codebase; quirks are, and quirks grant
// traits. init_quirk_registry() builds the picker from subtypesof(/datum/quirk), so declaring the
// boon here is enough - no core traits list needs editing.
//
// Pattern copied from /datum/quirk/positive/light_footed in code/datums/quirks/boon/_boon.dm.

/datum/quirk/positive/master_tracker
	name = "Master Tracker"
	desc = "You were raised reading the ground. A bent stem, a scuffed stone, a print half-washed by rain - \
	nothing on the trail hides from you, and you can tell at a glance what left it and where it went."
	point_value = -6
	incompatible_quirks = list(
		/datum/quirk/negative/bad_sight,
	)

/datum/quirk/positive/master_tracker/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_PERFECT_TRACKER, "[type]")

/datum/quirk/positive/master_tracker/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_PERFECT_TRACKER, "[type]")
