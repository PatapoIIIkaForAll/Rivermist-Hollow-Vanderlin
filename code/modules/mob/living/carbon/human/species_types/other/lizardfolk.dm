/mob/living/carbon/human/species/lizardfolk
	race = /datum/species/lizardfolk

/datum/species/lizardfolk
	name = "Lizardfolk"
	id = SPEC_ID_LIZARDFOLK
	desc = "<b>Lizardfolk</b><br>\
	Lizardfolk are hardy, reptilian people that share a unique bond among their kind due to being the target of oppression \
	and enslavement by other races, particularly by Humans and Drakians. They take pride in their resilience and adaptability,\
	and they can be found all over the world for one reason or another. Once a nomadic, tribal people, Lizardfolk are often forced \
	to hide and settle in deserts, swamps, bogs, and other typically inhospitable lands. Their appearance changes based on the lands \
	they adapt to, allowing for crocodilian appearance if from the swamp to lizard-like appearances if from the desert. \
	<br><br> \
	They can also be found in large, bustling cities, particularly slave cities where their strength, toughness, and endurance \
	makes them particularly valuable. Lizardfolk often despise weakness and instead find solace in suffering. They tend to be \
	highly religious, although of course, no race is monolithic. In fact, some Lizardfolk have become successful with some rising to \
	the rank of nobility in many different kingdoms despite all adversity, but this often makes them targets of their jealous peers."
	skin_tone_wording = "Skin Colors"
	species_traits = list(EYECOLOR,LIPS,STUBBLE,MUTCOLORS)
	possible_ages = NORMAL_AGES_LIST
	changesource_flags =  WABBAJACK
	limbs_icon_m = 'modular_rmh/icons/mob/bodies/m/mta.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/bodies/f/fma.dmi'

	order_num = 34

	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female

	offset_features_m = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,-1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,1),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,2),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,-1),\
	)


	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = -1, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_SPD = 0, STATKEY_LCK = 0)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = -1, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_SPD = 0, STATKEY_LCK = 0)

	inherent_traits = list(TRAIT_NASTY_EATER)
	enflamed_icon = "widefire"


	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/lizard,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/lizard,
		ORGAN_SLOT_SNOUT = /obj/item/organ/snout/lizard,
		ORGAN_SLOT_TAIL_FEATURE = /obj/item/organ/tail_feature/lizard_spines,
		ORGAN_SLOT_FRILLS = /obj/item/organ/frills/lizard,
		ORGAN_SLOT_HORNS = /obj/item/organ/horns,
		)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid/bald_default,
		/datum/customizer/bodypart_feature/hair/facial/humanoid/shaved_default,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/organ/tail/lizard,
		/datum/customizer/organ/tail_feature/lizard_spines,
		/datum/customizer/organ/snout/lizard,
		/datum/customizer/organ/ears/lizard,
		/datum/customizer/organ/frills/lizard,
		/datum/customizer/organ/horns/humanoid/lizardfolk,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/anthro,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/bellyscale,
		/datum/body_marking_set/tiger,
		/datum/body_marking_set/tiger_dark,
	)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/bellyscale,
		/datum/body_marking/bellyscaleslim,
		/datum/body_marking/bellyscaleslimsmooth,
		/datum/body_marking/buttscale,
		/datum/body_marking/tie,
		/datum/body_marking/tiesmall,
		/datum/body_marking/front,
		/datum/body_marking/tiger,
		/datum/body_marking/tiger/dark,
		/datum/body_marking/drake_eyes,
		/datum/body_marking/tonage,
		/datum/body_marking/tips,
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

/datum/species/lizardfolk/check_roundstart_eligible()
	return TRUE

/datum/species/lizardfolk/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/lizardfolk/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/lizardfolk/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/lizardfolk/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[/datum/body_marking_set/bellyscale], passed_features, src)

/datum/species/lizardfolk/get_skin_list()
	return get_common_mutant_color_palette()
