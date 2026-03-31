/mob/living/carbon/human/species/kobold/classic
	race = /datum/species/kobold/classic

/datum/species/kobold/classic
	name = "City Kobold"
	id = SPEC_ID_KOBOLD_CLASSIC
	id_override = SPEC_ID_KOBOLD
	desc = "City kobolds are small, quick, and intensely communal draconic folk who originated in warrens, cliffside camps, and cavern roads. \
	They moved to big cities, but still remain skilled trappers, and fiercely proud of the treasures and stories their clans preserve. \
	\n\n\
	(-1 STR, -1 CON, +1 SPD, +1 LCK).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	species_traits = list(EYECOLOR, LIPS, STUBBLE, MUTCOLORS)
	inherent_traits = list(TRAIT_TINY, TRAIT_DARKVISION)
	hungry_hungry_kobold = FALSE

	specstats_m = list(STATKEY_STR = -1, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = -1, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = 1)
	specstats_f = list(STATKEY_STR = -1, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = -1, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = 1)

	use_skintones = FALSE
	default_color = "EAA501"
	native_language = "Common"
	order_num = 18

	limbs_icon_m = 'modular_rmh/icons/mob/species/anthro_small_malea.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/species/anthro_small_femalea.dmi'

	custom_clothes = TRUE
	custom_id = SPEC_ID_DWARF
	swap_male_clothes = TRUE

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-3),\
		OFFSET_VAGINA = list(0,-4),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-3),\
		OFFSET_VAGINA = list(0,-4),\
	)

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/lizard,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/kobold,
		ORGAN_SLOT_SNOUT = /obj/item/organ/snout/lizard,
		ORGAN_SLOT_FRILLS = /obj/item/organ/frills/lizard,
		ORGAN_SLOT_HORNS = /obj/item/organ/horns,
	)

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid/bald_default,
		/datum/customizer/bodypart_feature/hair/facial/humanoid/shaved_default,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/tail/kobold,
		/datum/customizer/organ/snout/lizard,
		/datum/customizer/organ/frills/lizard,
		/datum/customizer/organ/horns/humanoid,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
	)

	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/kobold_scale,
	)

	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/kobold_scale,
		/datum/body_marking/small/plain,
		/datum/body_marking/small/sock,
		/datum/body_marking/small/socklonger,
		/datum/body_marking/small/tips,
		/datum/body_marking/small/belly,
		/datum/body_marking/small/bellyslim,
		/datum/body_marking/small/butt,
		/datum/body_marking/small/tie,
		/datum/body_marking/small/tiesmall,
		/datum/body_marking/small/backspots,
		/datum/body_marking/small/front,
		/datum/body_marking/small/spotted,
	)

	descriptor_choices = list(
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/scales,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one,
		/datum/descriptor_choice/prominent_two,
		/datum/descriptor_choice/prominent_three,
		/datum/descriptor_choice/prominent_four,
	)

/datum/species/kobold/classic/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[/datum/body_marking_set/kobold_scale], passed_features, src)

/datum/species/kobold/classic/get_random_features()
	return ..()
