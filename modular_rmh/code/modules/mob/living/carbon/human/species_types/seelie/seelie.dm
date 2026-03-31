#define SEELIE_SCALE 0.6
#define SEELIE_WING_TRAIT "seelie_nowings"
#define SEELIE_MOVESPEED_ID "seelie_move"

/mob/living/carbon/human/species/seelie
	race = /datum/species/seelie

/mob/living/carbon/human/proc/is_seelie()
	return istype(dna?.species, /datum/species/seelie)

/mob/living/carbon/human/proc/seelie_has_grand_glamour()
	return !!has_status_effect(/datum/status_effect/buff/seelie_grand_glamour)

/mob/living/carbon/human/proc/seelie_ensure_scale()
	if(!is_seelie())
		return

	if(seelie_has_grand_glamour())
		transform = matrix()
	else
		transform = matrix().Scale(SEELIE_SCALE, SEELIE_SCALE)

	update_transform()

/datum/species/seelie
	name = "Seelie"
	id = SPEC_ID_SEELIE
	changesource_flags = WABBAJACK
	desc = "Seelies are tiny fae wanderers whose size, speed, and knack for gentle magic let them slip through the world where larger folk cannot. Their bodies are delicate and their wings are essential, but in return they move with uncanny grace. \
	\n\n\
	(-6 STR, +4 PER, +2 INT, -6 CON, -1 END, +7 SPD)."

	native_language = "Common"

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_TINY, TRAIT_NOMOBSWAP, TRAIT_NOFALLDAMAGE1)
	allowed_pronouns = PRONOUNS_LIST_NO_IT

	possible_ages = ALL_AGES_LIST
	use_skintones = TRUE
	order_num = 37

	limbs_icon_m = 'icons/roguetown/mob/bodies/f/fm.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
	dam_icon_m = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'

	soundpack_m = /datum/voicepack/female/elf
	soundpack_f = /datum/voicepack/female/elf

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_WINGS = /obj/item/organ/wings/flight/seelie,
	)

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/organ/wings/seelie,
		/datum/customizer/organ/genitals/penis/human,
		/datum/customizer/organ/genitals/vagina/human,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/testicles/human,
	)

	specstats_m = list(STATKEY_STR = -6, STATKEY_PER = 4, STATKEY_INT = 2, STATKEY_CON = -6, STATKEY_END = -1, STATKEY_SPD = 7)
	specstats_f = list(STATKEY_STR = -6, STATKEY_PER = 4, STATKEY_INT = 2, STATKEY_CON = -6, STATKEY_END = -1, STATKEY_SPD = 7)

	enflamed_icon = "widefire"

	offset_features_m = list(
		OFFSET_RING = list(0,-1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,-1),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,-1),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,-1),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,-1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,-1),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,-1),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,-1),\
	)

/datum/species/seelie/spec_life(mob/living/carbon/human/human)
	. = ..()
	if(!istype(human))
		return

	enforce_wing_requirement(human)
	human.seelie_ensure_scale()

	if(!human.has_movespeed_modifier(SEELIE_MOVESPEED_ID))
		human.add_movespeed_modifier(SEELIE_MOVESPEED_ID, override = TRUE, multiplicative_slowdown = 0.5)

/datum/species/seelie/proc/enforce_wing_requirement(mob/living/carbon/human/human)
	if(!istype(human))
		return

	if(human.getorganslot(ORGAN_SLOT_WINGS))
		REMOVE_TRAIT(human, TRAIT_FLOORED, SEELIE_WING_TRAIT)
		human.mobility_flags |= MOBILITY_STAND
		if(human.body_position == LYING_DOWN && !human.resting)
			human.set_body_position(STANDING_UP)
		return

	ADD_TRAIT(human, TRAIT_FLOORED, SEELIE_WING_TRAIT)
	human.mobility_flags &= ~MOBILITY_STAND
	if(human.body_position != LYING_DOWN)
		human.set_body_position(LYING_DOWN)
	human.set_resting(TRUE, silent = TRUE)

/datum/species/seelie/on_species_gain(mob/living/carbon/carbon_mob, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	if(!ishuman(carbon_mob))
		return

	var/mob/living/carbon/human/human = carbon_mob
	human.grant_language(/datum/language/common)
	human.pass_flags |= (PASSTABLE | PASSMOB)
	human.seelie_ensure_scale()
	human.add_movespeed_modifier(SEELIE_MOVESPEED_ID, override = TRUE, multiplicative_slowdown = 0.5)
	ADD_TRAIT(human, TRAIT_PACIFISM, "[type]")
	ADD_TRAIT(human, TRAIT_MOVE_FLOATING, "[type]")
	human.add_spell(/datum/action/cooldown/spell/undirected/seelie_grand_glamour)

	if(!human.getorganslot(ORGAN_SLOT_WINGS))
		var/obj/item/organ/wings/flight/seelie/wings = new
		wings.Insert(human, TRUE, TRUE)

	enforce_wing_requirement(human)
	human.update_body()
	human.verbs |= /mob/living/carbon/human/proc/seelie_exit_container

/datum/species/seelie/on_species_loss(mob/living/carbon/carbon_mob)
	. = ..()
	if(!ishuman(carbon_mob))
		return

	var/mob/living/carbon/human/human = carbon_mob
	human.remove_status_effect(/datum/status_effect/buff/seelie_grand_glamour)
	human.pass_flags &= ~(PASSTABLE | PASSMOB)
	human.transform = matrix()
	human.update_transform()
	human.remove_movespeed_modifier(SEELIE_MOVESPEED_ID)
	human.mobility_flags |= MOBILITY_STAND
	REMOVE_TRAIT(human, TRAIT_FLOORED, SEELIE_WING_TRAIT)
	REMOVE_TRAIT(human, TRAIT_MOVE_FLOATING, "[type]")
	REMOVE_TRAIT(human, TRAIT_PACIFISM, "[type]")
	human.remove_spell(/datum/action/cooldown/spell/undirected/seelie_grand_glamour)
	human.verbs -= /mob/living/carbon/human/proc/seelie_exit_container

/datum/species/seelie/check_roundstart_eligible()
	return TRUE

/datum/species/seelie/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/seelie/get_skin_list()
	return sortList(list(
		"Moonlit" = "f4eef7",
		"Dewdrop" = "dceffc",
		"Lilac" = "cfb9f2",
		"Rose" = "f0c2cf",
		"Moss" = "9bbf9c",
		"Amber" = "d8bf7d",
		"Twilight" = "7383b5",
		"Willow" = "7d6d80",
	))

#undef SEELIE_SCALE
#undef SEELIE_WING_TRAIT
#undef SEELIE_MOVESPEED_ID
