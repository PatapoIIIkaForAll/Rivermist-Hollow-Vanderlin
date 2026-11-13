/mob/living/carbon/human/species/half_anthromorphsmall
	race = /datum/species/half_anthromorphsmall

/datum/species/half_anthromorphsmall
	name = "Half-Critter-Kin"
	id = SPEC_ID_HALF_BEASTKINSMALL
	desc = "<b>Critterkin</b><br>\
	A race akin to wild-kin, except afflicted with significantly smaller stature. \
	Sometimes referred to with the derogatory term 'verminfolk' by those that disrespect the small.<br>\
	(+1 Speed, Keen Ears Trait)"

	default_color = "444"

	use_titles = TRUE
	race_titles = list(
	"Catfolk", "Dogfolk", "Volffolk", "Lionfolk", "Venardfolk", "Tigerfolk", "Sheepfolk",
	"Goatfolk", "Rousfolk", "Possumfolk", "Pigfolk", "Boarfolk", "Rabbitfolk", "Horsefolk",
	"Donkeyfolk", "Hyenafolk", "Deerfolk", "Bearfolk", "Pandafolk", "Coyotefolk", "Moosefolk",
	"Jackalfolk", "Pantherfolk", "Lynxfolk", "Leopardfolk", "Monkeyfolk", "Birdfolk", "Sealfolk", "Frogfolk",
	"Batfolk", "Otterfolk", "Cowfolk", "Bullfolk", "Beefolk", "Monsterfolk", "Chimerafolk"
	)

	allowed_pronouns = PRONOUNS_LIST
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = TRUE
	possible_ages = NORMAL_AGES_LIST
	disliked_food = NONE
	liked_food = NONE
	species_traits = list(
		EYECOLOR,
		LIPS,
		HAIR,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	changesource_flags = WABBAJACK

	limbs_icon_m = 'modular_rmh/icons/mob/species/anthro_small_malea.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/species/anthro_small_femalea.dmi'
	body_hair_materials = BODY_HAIR_MATERIALS_FURRED
	dam_icon_m = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'

	soundpack_m = /datum/voicepack/male/elf
	soundpack_f = /datum/voicepack/female/elf

	order_num = 24

	custom_id = "dwarf"
	custom_clothes = TRUE

	offset_features_m = list(
		OFFSET_RING = list(0,-4),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,-4),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-5),\
		OFFSET_HEAD = list(0,-5),\
		OFFSET_FACE = list(0,-5),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,-5),\
		OFFSET_NECK = list(0,-5),\
		OFFSET_MOUTH = list(0,-5),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0)\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,-4),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,-4),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-5),\
		OFFSET_HEAD = list(0,-5),\
		OFFSET_FACE = list(0,-5),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,-5),\
		OFFSET_NECK = list(0,-5),\
		OFFSET_MOUTH = list(0,-5),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0)\
	)

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-2),\
		OFFSET_VAGINA = list(0,-4),\
		OFFSET_BUTT = list(0,-4),\
		OFFSET_BELLY = list(0,-4),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-2),\
		OFFSET_VAGINA = list(0,-4),\
		OFFSET_BUTT = list(0,-4),\
		OFFSET_BELLY = list(0,-4),\
	)

	inherent_traits = list(TRAIT_KEENEARS)

	statsheet_male = /datum/attribute_holder/sheet/job/species/halfanthromorphsmall/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/halfanthromorphsmall/stats/female
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,///wild_tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
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
		/datum/customizer/organ/tail/anthro,
		/datum/customizer/organ/ears/anthro,
		/datum/customizer/organ/horns/anthro,
		/datum/customizer/organ/neck_feature/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
	)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
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

/datum/species/half_anthromorphsmall/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

/datum/species/half_anthromorphsmall/after_creation(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/beast)
	to_chat(C, "<span class='info'>I can speak Beastish with ,b before my speech.</span>")

/datum/species/half_anthromorphsmall/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/beast)

/datum/species/half_anthromorphsmall/check_roundstart_eligible()
	return TRUE

/datum/species/half_anthromorphsmall/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/attribute_holder/sheet/job/species/halfanthromorphsmall/stats/male
	raw_attribute_list = list(STAT_PERCEPTION = 2, STAT_INTELLIGENCE = -1, STAT_CONSTITUTION = -1, STAT_SPEED = 1, STAT_FORTUNE = -1, STAT_ENDURANCE = -1)


/datum/attribute_holder/sheet/job/species/halfanthromorphsmall/stats/female
	raw_attribute_list = list(STAT_PERCEPTION = 2, STAT_INTELLIGENCE = -1, STAT_CONSTITUTION = -1, STAT_SPEED = 1, STAT_FORTUNE = -1, STAT_ENDURANCE = -1)
