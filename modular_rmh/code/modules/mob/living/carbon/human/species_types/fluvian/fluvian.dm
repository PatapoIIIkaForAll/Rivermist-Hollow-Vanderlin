/mob/living/carbon/human/species/fluvian
	race = /datum/species/fluvian

/datum/species/fluvian
	name = "Fluvian"
	id = SPEC_ID_FLUVIAN
	desc = "Fluvians are moth-folk wanderers known for moonlit pilgrimages, omen-reading, and a calm fascination with the uncanny. \
	They are rare in settled lands, but their knack for charm, luck, and quiet mysticism makes them memorable wherever they travel. \
	\n\n\
	(+1 SPD, Blackleg Trait).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	default_color = "EDCF7E"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY, MUTCOLORS)
	inherent_traits = list(TRAIT_BLACKLEG)

	possible_ages = NORMAL_AGES_LIST
	changesource_flags = WABBAJACK
	order_num = 20

	limbs_icon_m = 'modular_rmh/icons/mob/species/moth_male.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/species/moth_female.dmi'
	lips_state_m = "moth_male"
	lips_state_f = "moth_female"
	body_hair_materials = BODY_HAIR_MATERIALS_FUZZY

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
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_ANTENNAS = /obj/item/organ/antennas/moth,
		ORGAN_SLOT_NECK_FEATURE = /obj/item/organ/neck_feature/moth_fluff,
		ORGAN_SLOT_WINGS = /obj/item/organ/wings/flight/moth,
	)

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/wings/moth,
		/datum/customizer/organ/antennas/moth,
		/datum/customizer/organ/neck_feature/moth_fluff,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
	)

	body_marking_sets = list(
		/datum/body_marking_set/moth/reddish,
		/datum/body_marking_set/moth/royal,
		/datum/body_marking_set/moth/gothic,
		/datum/body_marking_set/moth/whitefly,
		/datum/body_marking_set/moth/burnt_off,
		/datum/body_marking_set/moth/deathhead,
		/datum/body_marking_set/moth/poison,
		/datum/body_marking_set/moth/ragged,
		/datum/body_marking_set/moth/moonfly,
		/datum/body_marking_set/moth/oakworm,
		/datum/body_marking_set/moth/jungle,
		/datum/body_marking_set/moth/witchwing,
		/datum/body_marking_set/moth/lovers,
	)

	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/moth/grayscale/reddish,
		/datum/body_marking/moth/grayscale/royal,
		/datum/body_marking/moth/grayscale/gothic,
		/datum/body_marking/moth/grayscale/whitefly,
		/datum/body_marking/moth/grayscale/burnt_off,
		/datum/body_marking/moth/grayscale/deathhead,
		/datum/body_marking/moth/grayscale/poison,
		/datum/body_marking/moth/grayscale/ragged,
		/datum/body_marking/moth/grayscale/moonfly,
		/datum/body_marking/moth/grayscale/oakworm,
		/datum/body_marking/moth/grayscale/jungle,
		/datum/body_marking/moth/grayscale/witchwing,
		/datum/body_marking/moth/grayscale/lovers,
	)
	descriptor_choices = list(
		/datum/descriptor_choice/trait,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/skin_all,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one_wild,
		/datum/descriptor_choice/prominent_two_wild,
		/datum/descriptor_choice/prominent_three_wild,
		/datum/descriptor_choice/prominent_four_wild,
	)

	statsheet_male = /datum/attribute_holder/sheet/job/species/fluvian/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/fluvian/stats/female

	enflamed_icon = "widefire"
	native_language = "Common"

/datum/species/fluvian/check_roundstart_eligible()
	return TRUE

/datum/species/fluvian/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

/datum/species/fluvian/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/common)

/datum/species/fluvian/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[pick(body_marking_sets)], passed_features, src)

/datum/species/fluvian/get_random_features()
	return ..()

/datum/attribute_holder/sheet/job/species/fluvian/stats/male
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = 0, STAT_ENDURANCE = 0, STAT_SPEED = 1, STAT_FORTUNE = 0)


/datum/attribute_holder/sheet/job/species/fluvian/stats/female
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = 0, STAT_ENDURANCE = 0, STAT_SPEED = 1, STAT_FORTUNE = 0)
