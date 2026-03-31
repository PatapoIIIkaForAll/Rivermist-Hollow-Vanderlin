/mob/living/carbon/human/species/elf/dark/drider
	race = /datum/species/elf/dark/drider

/datum/species/elf/dark/drider
	name = "Drider"
	id = SPEC_ID_DRIDER
	id_override = SPEC_ID_DROW
	desc = "Driders are drow whose upper bodies remain elven while their lower halves take the form of a great spider. \
	They keep the keen senses, grace, and underworld bearing of their kin, but move on eight legs and leave a far stronger impression wherever they go. \
	\n\n\
	(+1 PER, +2 SPD, +1 LCK, Allure, Darkvision, Sunlight Sensitivity, Elvish Language).\
	\n\n\
	Proficiencies: Knives(4), Swords(3), Crossbows(3), Whipflails(3), Sneaking(4), Lockpicking(3), Arcane(3), Blood(2), Alchemy(3), Weaponsmithing(2), Traps(1).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	// Reuse the existing drow limb states so the upper body renders cleanly.
	limbs_id = "Drow"
	forced_taur = TRUE
	allowed_taur_types = list(
		/obj/item/bodypart/taur/spider,
	)

	order_num = 33

/datum/species/elf/dark/drider/check_roundstart_eligible()
	return TRUE
