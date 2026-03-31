/mob/living/carbon/human/species/gnoll
	race = /datum/species/gnoll
	footstep_type = FOOTSTEP_MOB_HEAVY

/datum/species/gnoll
	name = "Gnoll"
	id = SPEC_ID_GNOLL
	desc = "Gnolls are tall hyena-folk known for relentless marches, brutal charges, and a talent for surviving where softer folk would starve. \
	Many are feared as raiders in frontier tales, yet just as many live as hunters, scouts, sellswords, and clanless wanderers in the wider world. \
	They are rough-humored, hard to cow, and dangerous up close once teeth and claws are in play. \
	\n\n\
	(+2 STR, +1 PER, +1 SPD, -1 INT, -1 LCK)."

	use_titles = FALSE
	use_skintones = TRUE
	skin_tone_wording = "Fur Color"
	default_color = "8C6A43"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, MUTCOLORS)
	possible_ages = NORMAL_AGES_LIST
	changesource_flags = WABBAJACK
	limbs_icon_m = 'modular_rmh/icons/mob/bodies/m/mta.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/bodies/f/fma.dmi'
	inherent_traits = list(
		TRAIT_LONGSTRIDER,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NASTY_EATER,
		TRAIT_ORGAN_EATER,
		TRAIT_BREADY,
		TRAIT_STEELHEARTED,
		TRAIT_BASHDOORS,
		TRAIT_STRONGBITE,
	)

	order_num = 36
	soundpack_m = /datum/voicepack/werewolf
	soundpack_f = /datum/voicepack/werewolf

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


	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/anthro,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/anthro,
		ORGAN_SLOT_SNOUT = /obj/item/organ/snout/anthro,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)

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
		/datum/customizer/organ/ears/gnoll,
		/datum/customizer/organ/snout/gnoll,
		/datum/customizer/organ/tail/gnoll,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
	)

	body_marking_sets = list(/datum/body_marking_set/none)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/spotted,
		/datum/body_marking/tips,
		/datum/body_marking/belly,
		/datum/body_marking/bellyslim,
		/datum/body_marking/butt,
		/datum/body_marking/tie,
		/datum/body_marking/tiesmall,
		/datum/body_marking/backspots,
		/datum/body_marking/front,
		/datum/body_marking/tonage,
	)

	descriptor_choices = list(
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/fur,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one_wild,
		/datum/descriptor_choice/prominent_two_wild,
		/datum/descriptor_choice/prominent_three_wild,
		/datum/descriptor_choice/prominent_four_wild,
	)

	specstats_m = list(STATKEY_STR = 2, STATKEY_PER = 1, STATKEY_INT = -1, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = -1)
	specstats_f = list(STATKEY_STR = 2, STATKEY_PER = 1, STATKEY_INT = -1, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = -1)

	enflamed_icon = "widefire"
	native_language = "Common"

/datum/species/gnoll/check_roundstart_eligible()
	return TRUE

/datum/species/gnoll/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/gnoll/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/beast)

/datum/species/gnoll/after_creation(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/beast)
	to_chat(C, "<span class='info'>I can speak Beastish with ,b before my speech.</span>")

/datum/species/gnoll/get_skin_list()
	return ..()

/datum/species/gnoll/get_random_body_markings(list/passed_features)
	return list()

/datum/species/gnoll/get_random_features()
	return ..()
