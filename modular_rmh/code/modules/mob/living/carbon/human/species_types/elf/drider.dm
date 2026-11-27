/mob/living/carbon/human/species/elf/dark/drider
	race = /datum/species/elf/dark/drider

/datum/species/elf/dark/drider
	name = "Drider"
	id = SPEC_ID_DRIDER
	id_override = SPEC_ID_DROW
	desc = "Driders are drow whose upper bodies remain elven while their lower halves take the form of a great spider. \
	They keep the keen senses, grace, and underworld bearing of their kin, but move on eight legs and leave a far stronger impression wherever they go. \
	\n\n\
	(Darkvision, Sunlight Sensitivity, Elvish Language).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	// Reuse the existing drow limb states so the upper body renders cleanly.
	limbs_id = "Drow"
	forced_taur = TRUE
	allowed_taur_types = list(
		/obj/item/bodypart/taur/spider,
		/obj/item/bodypart/taur/arachne,
	)

	order_num = 33

/datum/species/elf/dark/drider/check_roundstart_eligible()
	return TRUE

/datum/species/elf/dark/drider/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.add_silk_weaving(SPECIES_TRAIT)

/datum/species/elf/dark/drider/on_species_loss(mob/living/carbon/human/C)
	C.remove_silk_weaving(SPECIES_TRAIT)
	return ..()
