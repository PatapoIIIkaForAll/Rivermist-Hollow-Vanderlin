/// Немота
/datum/quirk/negative/muted
	name = "Mute"
	desc = "Whether by a grim stroke of fate or born to the quietude, you're mute."
	desc_hint = "(Being mute is not an excuse to forego roleplay. Use of custom emotes is recommended)"
	point_value = 2

/datum/quirk/negative/muted/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_MUTE, "[type]")

/datum/quirk/negative/muted/on_remove()
	if(!owner)
		return
	if(HAS_TRAIT(owner, TRAIT_MUTE))
		REMOVE_TRAIT(owner, TRAIT_MUTE, "[type]")
