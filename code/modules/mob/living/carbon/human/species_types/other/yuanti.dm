/mob/living/carbon/human/species/yuanti
	race = /datum/species/yuanti

/datum/species/yuanti
	name = "Yuan-ti"
	id = SPEC_ID_YUANTI
	desc = "<b>Yuan-ti</b><br>\
	Yuan-ti are a communal race of serpentfolk, also known as the snake people of Malatra.\
	They are often viewed with distrust by other races, seen as corrupt and degenerate monsters. \
	(+1 CON, +1 WIL)"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,STUBBLE,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	disliked_food = NONE
	liked_food = NONE
	possible_ages = NORMAL_AGES_LIST
	changesource_flags = WABBAJACK
	disliked_food = NONE
	liked_food = NONE
	order_num = 30
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mt.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
	allowed_body_builds = HUMANOID_BODY_BUILDS
	default_body_build_m = BODY_BUILD_BROAD
	default_body_build_f = BODY_BUILD_SLIM

	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female

	use_titles = TRUE
	race_titles = list(
		"Lamia", "Snake-man",
	)

	offset_features_m = list(
		OFFSET_RING = list(0,1),\
		OFFSET_GLOVES = list(0,1),\
		OFFSET_WRISTS = list(0,1),\
		OFFSET_HANDS = list(0,1),\
		OFFSET_CLOAK = list(0,1),\
		OFFSET_FACEMASK = list(0,1),\
		OFFSET_HEAD = list(0,1),\
		OFFSET_FACE = list(0,1),\
		OFFSET_BELT = list(0,1),\
		OFFSET_BACK = list(0,1),\
		OFFSET_NECK = list(0,1),\
		OFFSET_MOUTH = list(0,1),\
		OFFSET_PANTS = list(0,1),\
		OFFSET_SHIRT = list(0,1),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,0),\
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

	statsheet_male = /datum/attribute_holder/sheet/job/species/yuanti/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/yuanti/stats/female

	enflamed_icon = "widefire"
	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/horns/humanoid/aura,
		/datum/customizer/organ/tail/aura,
		/datum/customizer/organ/genitals/testicles/human,
		/datum/customizer/organ/genitals/penis/human,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/vagina/human,
		/datum/customizer/organ/genitals/womb,
		)
	body_marking_sets = list(
		/datum/body_marking_set/aura/tranquility,
		/datum/body_marking_set/aura/word,
		/datum/body_marking_set/aura/balance,
		/datum/body_marking_set/aura/force,
	)
	body_markings = list(
		/datum/body_marking/aura/tranquility,
		/datum/body_marking/aura/word,
		/datum/body_marking/aura/balance,
		/datum/body_marking/aura/force,

	)

	descriptor_choices = list(
		/datum/descriptor_choice/trait,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/skin_lamia,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one_wild,
		/datum/descriptor_choice/prominent_two_wild,
		/datum/descriptor_choice/prominent_three_wild,
		/datum/descriptor_choice/prominent_four_wild,
	)
	allowed_taur_types = list(
		/obj/item/bodypart/taur/lamia,
		/obj/item/bodypart/taur/lamiastriped,
		/obj/item/bodypart/taur/fatlamia,
	)
/datum/species/yuanti/check_roundstart_eligible()
	return TRUE

/datum/species/yuanti/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/yuanti/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

/datum/species/yuanti/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/common)

/datum/species/yuanti/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[pick(body_marking_sets)], passed_features, src)


/datum/species/yuanti/get_skin_list()
	return sortList(list(
		"Pale"         = SKIN_TONE_PALE,
		"White 1"      = SKIN_TONE_WHITE1,
		"White 2"      = SKIN_TONE_WHITE2,
		"White 3"      = SKIN_TONE_WHITE3,
		"White 4"      = SKIN_TONE_WHITE4,
		"Tan"          = SKIN_TONE_TAN,
		"Mediterranean 1" = SKIN_TONE_MEDIT1,
		"Mediterranean 2" = SKIN_TONE_MEDIT2,
		"Latin"        = SKIN_TONE_LATIN,
		"Middle-east 1" = SKIN_TONE_MID_EAST1,
		"Middle-east 2" = SKIN_TONE_MID_EAST2,
		"Native American 1" = SKIN_TONE_NATIVE1,
		"Native American 2" = SKIN_TONE_NATIVE2,
		"Polynesian"   = SKIN_TONE_POLYNESIAN,
		"Melanesian"   = SKIN_TONE_MELANESIAN,
		"Black 1"      = SKIN_TONE_BLACK1,
		"Black 2"      = SKIN_TONE_BLACK2,
		"Black 3"      = SKIN_TONE_BLACK3,

	))

/datum/attribute_holder/sheet/job/species/yuanti/stats/male
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = 1, STAT_ENDURANCE = 1, STAT_SPEED = 0, STAT_FORTUNE = -1)


/datum/attribute_holder/sheet/job/species/yuanti/stats/female
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = 1, STAT_ENDURANCE = 1, STAT_SPEED = 0, STAT_FORTUNE = -1)
