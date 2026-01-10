	/*==============*
	*				*
	*	Tiefling	*
	*				*
	*===============*/

/mob/living/carbon/human/species/tieberian
	race = /datum/species/tieberian

/datum/species/tieberian
	name = "Tiefling"
	id = SPEC_ID_TIEFLING
	native_language = "Infernal"
	desc = "Tieflings bear infernal blood, the legacy of ancient pacts or cursed bloodlines tied to the Nine Hells. \
	\n\n\
	In Faerûn, most tieflings trace their lineage to Asmodeus, Lord of the Nine, and are marked by horns, tails, infernal eyes, and unnatural hues. \
	\n\n\
	Though often mistrusted or feared, tieflings are no more evil than any other race, their struggles shaped by prejudice rather than destiny. \
	\n\n\
	(+1 INT, +2 LCK, Allure, Darkvision, Hellish Resistance, Infernal Language).\
	\n\n\
	Proficiencies: Arcane(3), Blood(2), Alchemy(2), Knives(2), Sneaking(2), Reading(2).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."


	exotic_bloodtype = /datum/blood_type/human/tiefling

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_NOFIRE, TRAIT_ALLURE)
	inherent_skills = list(
		/datum/skill/magic/arcane = 3,
		/datum/skill/magic/blood = 2,

		/datum/skill/craft/alchemy = 2,

		/datum/skill/combat/knives = 2,

		/datum/skill/misc/sneaking = 2,
		/datum/skill/misc/reading = 2,
	)
	use_skintones = TRUE

	possible_ages = NORMAL_AGES_LIST_CHILD

	changesource_flags = WABBAJACK

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mm.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'

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
		OFFSET_CLOAK_ = list(0,0),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,-1),\
		OFFSET_BELT = list(0,-1),\
		OFFSET_BACK = list(0,-1),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,0),\
		OFFSET_BREASTS = list(0,0),\
		OFFSET_TESTICLES = list(0,0),\
		OFFSET_VAGINA = list(0,-2),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,0),\
		OFFSET_BREASTS = list(0,-1),\
		OFFSET_TESTICLES = list(0,0),\
		OFFSET_VAGINA = list(0,0),\
	)

	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 1, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 0, STATKEY_LCK = 2)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 1, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 0, STATKEY_LCK = 2)

	enflamed_icon = "widefire"

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_HORNS = /obj/item/organ/horns/tiefling,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/tiefling
	)

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)

	customizers = list(
		/datum/customizer/organ/ears/tiefling,
		/datum/customizer/organ/horns/tiefling,
		/datum/customizer/organ/tail/tiefling,
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
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

/datum/species/tieberian/check_roundstart_eligible()
	return TRUE

/datum/species/tieberian/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/hellspeak)

/datum/species/tieberian/after_creation(mob/living/carbon/C)
	. = ..()
	to_chat(C, "<span class='info'>I can speak Infernal with ,h before my speech.</span>")

/datum/species/tieberian/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/hellspeak)

/datum/species/tieberian/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/tieberian/get_skin_list()
	return sortList(list(
		"Deep Crimson" = SKIN_COLOR_TIEFLING_RED_DARK,
		"Blood Red" = SKIN_COLOR_TIEFLING_RED_BLOOD,
		"Dark Scarlet" = SKIN_COLOR_TIEFLING_RED_SCARLET,
		"Brick Red" = SKIN_COLOR_TIEFLING_RED_BRICK,
		"Deep Plum" = SKIN_COLOR_TIEFLING_PURPLE_DARK,
		"Royal Purple" = SKIN_COLOR_TIEFLING_PURPLE_ROYAL,
		"Dusky Violet" = SKIN_COLOR_TIEFLING_VIOLET_DUSK,
		"Midnight Blue" = SKIN_COLOR_TIEFLING_BLUE_MIDNIGHT,
		"Slate Blue" = SKIN_COLOR_TIEFLING_BLUE_SLATE,
		"Steel Blue" = SKIN_COLOR_TIEFLING_BLUE_STEEL,
		"Ash Gray" = SKIN_COLOR_TIEFLING_GRAY_ASH,
		"Smoky Gray" = SKIN_COLOR_TIEFLING_GRAY_SMOKE,
		"Charcoal" = SKIN_COLOR_TIEFLING_BLACK_CHAR,
		"Obsidian" = SKIN_COLOR_TIEFLING_BLACK_OBSID,
		"Warm Tan" = SKIN_COLOR_TIEFLING_TAN_WARM,
		"Bronze Brown" = SKIN_COLOR_TIEFLING_BROWN_BRONZE,
		"Deep Umber" = SKIN_COLOR_TIEFLING_BROWN_UMBER,
		"Pale White" = SKIN_COLOR_TIEFLING_WHITE_PALE,
	))

/datum/species/tieberian/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/other/tiefm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/other/tiefm.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/tieberian/get_possible_surnames(gender = MALE)
	var/static/list/last_names = world.file2list('strings/rt/names/other/tieflast.txt')
	return last_names

