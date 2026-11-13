/// Beast muzzle choices for the werewolf profile; output e.g. "a long muzzle".
/datum/mob_descriptor/face/werewolf
	abstract_type = /datum/mob_descriptor/face/werewolf
	suffix = "muzzle"

/datum/mob_descriptor/face/werewolf/long
	name = "Long"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/broad
	name = "Broad"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/narrow
	name = "Narrow"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/blunt
	name = "Blunt"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/scarred
	name = "Scarred"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/grizzled
	name = "Grizzled"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/torn
	name = "Torn"
	prefix = "a"

/datum/mob_descriptor/face/werewolf/slavering
	name = "Slavering"
	prefix = "a"

/datum/mob_descriptor/stature/werewolf
	name = "Werewolf"

/datum/mob_descriptor/stature/werewolf/get_description(mob/living/described)
	return "werewolf"
