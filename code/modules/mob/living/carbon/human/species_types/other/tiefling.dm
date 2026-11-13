	/*==============*
	*				*
	*	Tiefling	*
	*				*
	*===============*/

/mob/living/carbon/human/species/tieberian
	race = /datum/species/tieberian

/datum/attribute_holder/sheet/job/species/tieberian/stats
	raw_attribute_list = list(
		STAT_INTELLIGENCE = 1,
		STAT_FORTUNE = 2
	)

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
	inherent_sheet = /datum/attribute_holder/sheet/job/species/tieberian/inherent
	use_skintones = TRUE

	possible_ages = NORMAL_AGES_LIST

	changesource_flags = WABBAJACK

	order_num = 8

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mm.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
	allowed_body_builds = HUMANOID_BODY_BUILDS
	default_body_build_m = BODY_BUILD_AVERAGE
	default_body_build_f = BODY_BUILD_SLIM

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
		OFFSET_UNDIES = list(0,-1),\
	)

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,0),\
		OFFSET_BREASTS = list(0,0),\
		OFFSET_TESTICLES = list(0,0),\
		OFFSET_VAGINA = list(0,-3),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,0),\
		OFFSET_BREASTS = list(0,-1),\
		OFFSET_TESTICLES = list(0,0),\
		OFFSET_VAGINA = list(0,-4),\
	)
	statsheet_male = /datum/attribute_holder/sheet/job/species/tieberian/stats
	statsheet_female = /datum/attribute_holder/sheet/job/species/tieberian/stats

	enflamed_icon = "widefire"

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
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
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
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
	C.AddComponent(/datum/component/malaguero, 2, 1, 30 SECONDS)

/datum/species/tieberian/after_creation(mob/living/carbon/C)
	. = ..()
	to_chat(C, "<span class='info'>I can speak Infernal with ,h before my speech.</span>")

/datum/species/tieberian/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/hellspeak)
	var/datum/component/bad_luck = C.GetComponent(/datum/component/malaguero)
	if(bad_luck)
		bad_luck.RemoveComponent()

/datum/species/tieberian/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/tieberian/get_skin_list()
	return sortList(list(
		"Ash Gray"			= SKIN_COLOR_TIEFLING_GRAY_ASH,
		"Blood Red"			= SKIN_COLOR_TIEFLING_RED_BLOOD,
		"Brick Red"			= SKIN_COLOR_TIEFLING_RED_BRICK,
		"Bronze Brown"		= SKIN_COLOR_TIEFLING_BROWN_BRONZE,
		"Charcoal"			= SKIN_COLOR_TIEFLING_BLACK_CHAR,
		"Dark Scarlet"		= SKIN_COLOR_TIEFLING_RED_SCARLET,
		"Deep Crimson"		= SKIN_COLOR_TIEFLING_RED_DARK,
		"Deep Plum"			= SKIN_COLOR_TIEFLING_PURPLE_DARK,
		"Deep Umber"		= SKIN_COLOR_TIEFLING_BROWN_UMBER,
		"Dusky Violet"		= SKIN_COLOR_TIEFLING_VIOLET_DUSK,
		"Fiery Salmon"		= SKIN_COLOR_TIEFLING_PINK_SALMON,
		"Frostblue"			= SKIN_COLOR_TIEFLING_BLUE_FROST,
		"Gilded Gold"		= SKIN_COLOR_TIEFLING_GOLD_GILDED,
		"Glacial Cyan"		= SKIN_COLOR_TIEFLING_BLUE_GLACIAL,
		"Hellfire Orange"	= SKIN_COLOR_TIEFLING_ORANGE_HELLFIRE,
		"Ivory White"		= SKIN_COLOR_TIEFLING_WHITE_IVORY,
		"Lavender Mist"		= SKIN_COLOR_TIEFLING_VIOLET_LAVENDER,
		"Midnight Blue"		= SKIN_COLOR_TIEFLING_BLUE_MIDNIGHT,
		"Obsidian"			= SKIN_COLOR_TIEFLING_BLACK_OBSID,
		"Olive Green"		= SKIN_COLOR_TIEFLING_GREEN_OLIVE,
		"Orchid Pink"		= SKIN_COLOR_TIEFLING_PINK_ORCHID,
		"Plague Green"		= SKIN_COLOR_TIEFLING_GREEN_PLAGUE,
		"Royal Purple"		= SKIN_COLOR_TIEFLING_PURPLE_ROYAL,
		"Ruddy Pink"		= SKIN_COLOR_TIEFLING_HUMAN_RUDDY,
		"Steel Blue"		= SKIN_COLOR_TIEFLING_BLUE_STEEL,
		"Sulfur Yellow"		= SKIN_COLOR_TIEFLING_YELLOW_SULFUR,
		"Warm Tan"			= SKIN_COLOR_TIEFLING_TAN_WARM,
	))

/datum/species/tieberian/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/other/tiefm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/other/tiefm.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/tieberian/get_possible_surnames(gender = MALE)
	var/static/list/last_names = world.file2list('strings/rt/names/other/tieflast.txt')
	return last_names

/datum/attribute_holder/sheet/job/species/tieberian/inherent
	raw_attribute_list = list(
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/magic/blood = 20,

		/datum/attribute/skill/craft/alchemy = 20,

		/datum/attribute/skill/combat/knives = 20,

		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/reading = 20,
	)
