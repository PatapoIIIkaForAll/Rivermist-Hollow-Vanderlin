/mob/living/carbon/human/species/ogre
	race = /datum/species/ogre

/datum/species/ogre
	name = "Ogre"
	id = SPEC_ID_OGRE
	native_language = "Orcish"
	desc = "Ogres are hulking giant-kin known for brutal strength, thick hides, and appetites to match. \
	They are most often found as raiders, mercenaries, caravan bruisers, and wandering clanfolk from beyond settled lands. \
	Their size makes daily life awkward, but in a straight fight few can match an ogre once steel starts swinging. \
	\n\n\
	(+2 STR, +2 CON, +1 END, -3 INT, -1 SPD).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	skin_tone_wording = "Hide Color"

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)

	allowed_voicetypes_m = VOICE_TYPES_MASCANDRO
	allowed_voicetypes_f = VOICE_TYPES_MASCANDRO

	use_skintones = TRUE
	possible_ages = ALL_AGES_LIST
	changesource_flags = WABBAJACK
	bleed_mod = 0.2
	pain_mod = 0.5
	nutrition_mod = 2
	hygiene_mod = 1.5
	order_num = 38

	limbs_icon_m = 'modular_rmh/icons/mob/species/ogre_male.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/species/ogre_female.dmi'
	dam_icon_m = 'modular_rmh/icons/mob/species/ogre_damage.dmi'
	dam_icon_f = 'modular_rmh/icons/mob/species/ogre_damage.dmi'

	soundpack_m = /datum/voicepack/male/warrior
	soundpack_f = /datum/voicepack/female/dwarf
	swap_female_clothes = TRUE

	offset_features_m = list(
		OFFSET_RING = list(0,1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,6),\
		OFFSET_FACEMASK = list(0,6),\
		OFFSET_HEAD = list(0,6),\
		OFFSET_FACE = list(0,6),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,6),\
		OFFSET_NECK = list(0,6),\
		OFFSET_MOUTH = list(0,6),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,6),\
		OFFSET_ARMOR = list(0,6),\
		OFFSET_UNDIES = list(0,0),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,1),\
		OFFSET_GLOVES = list(0,1),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,6),\
		OFFSET_FACEMASK = list(0,6),\
		OFFSET_HEAD = list(0,6),\
		OFFSET_FACE = list(0,6),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,6),\
		OFFSET_NECK = list(0,6),\
		OFFSET_MOUTH = list(0,6),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,6),\
		OFFSET_ARMOR = list(0,6),\
		OFFSET_UNDIES = list(0,-1),\
	)

	offset_genitals_m = list(
		OFFSET_BREASTS = list(0,5),\
	)

	offset_genitals_f = list(
		OFFSET_BREASTS = list(0,5),\
	)

	specstats_m = list(STATKEY_STR = 2, STATKEY_CON = 2, STATKEY_END = 1, STATKEY_INT = -3, STATKEY_SPD = -1)
	specstats_f = list(STATKEY_STR = 2, STATKEY_CON = 2, STATKEY_END = 1, STATKEY_INT = -3, STATKEY_SPD = -1)

	enflamed_icon = "widefire"

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
	)

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
	)

	body_markings = list(
		/datum/body_marking/tonage,
		/datum/body_marking/womb_tattoo,
		/datum/body_marking/butterfly,
		/datum/body_marking/waist,
		/datum/body_marking/diagonal_eyes,
		/datum/body_marking/wide_eyes,
		/datum/body_marking/stripes,
		/datum/body_marking/plain,
		/datum/body_marking/spotted,
		/datum/body_marking/tiger,
		/datum/body_marking/tiger/dark,
		/datum/body_marking/sock,
		/datum/body_marking/sock/tertiary,
		/datum/body_marking/socklonger,
		/datum/body_marking/tips,
		/datum/body_marking/bellyscale,
		/datum/body_marking/kobold_scale,
		/datum/body_marking/bellyscaleslim,
		/datum/body_marking/bellyscalesmooth,
		/datum/body_marking/bellyscaleslimsmooth,
		/datum/body_marking/buttscale,
		/datum/body_marking/belly,
		/datum/body_marking/bellyslim,
		/datum/body_marking/tie,
		/datum/body_marking/butt,
		/datum/body_marking/tiesmall,
		/datum/body_marking/backspots,
		/datum/body_marking/front,
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
	)

/datum/species/ogre/check_roundstart_eligible()
	return TRUE

/datum/species/ogre/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/orcish)

/datum/species/ogre/after_creation(mob/living/carbon/C)
	. = ..()
	to_chat(C, span_info("I can speak Orcish with ,o before my speech."))

/datum/species/ogre/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/orcish)

/datum/species/ogre/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/ogre/get_skin_list()
	return list(
		"Ash" = SKIN_COLOR_SHELLCREST,
		"Ochre" = SKIN_COLOR_BLOOD_AXE,
		"Moss" = SKIN_COLOR_GROONN,
		"Slate" = SKIN_COLOR_BLACK_HAMMER,
		"Olive" = SKIN_COLOR_SKULL_SEEKER,
		"Umber" = SKIN_COLOR_CRESCENT_FANG,
		"Mire" = SKIN_COLOR_MURKWALKER,
		"Storm" = SKIN_COLOR_SHATTERHORN,
		"Night" = SKIN_COLOR_SPIRITCRUSHER,
	)

/datum/species/ogre/get_hairc_list()
	return sortList(list(
		"brown - tawny" = "58433b",
		"brown - bark" = "48322a",
		"brown - dark bark" = "2d1300",
		"green - marsh" = "458745",
		"green - reed" = "2A3B2B",
		"black - coal" = "201616",
	))

/datum/species/ogre/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/other/halforcm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/other/halforcf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/ogre/get_possible_surnames(gender = MALE)
	return null
