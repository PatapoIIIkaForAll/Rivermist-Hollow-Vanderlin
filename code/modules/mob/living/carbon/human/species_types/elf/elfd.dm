	/*==============*
	*				*
	*	Dark Elf	*
	*				*
	*===============*/

//	( + Night Vision Plus )

/mob/living/carbon/human/species/elf/dark
	race = /datum/species/elf/dark

/datum/species/elf/dark
	name = "Drow"
	id = SPEC_ID_DROW
	desc = "Drow are dark elves who dwell primarily in the Underdark beneath Faerûn. \
	\n\n\
	Long ago exiled from elven society, most drow live in cruel, theocratic city-states devoted to the Spider Queen, Lolth. \
	n\n\
	Their culture emphasizes ambition, betrayal, and survival.. \
	\n\n\
	Though often feared on the surface, not all drow follow Lolth—some reject her tyranny and seek redemption or freedom in the world above. \
	n\n\
	(+1 PER, +2 SPD, +1 LCK, Allure, Darkvision, Sunlight Sensitivity, Elvish Language).\
	\n\n\
	Proficiencies: Knives(4), Swords(3), Crossbows(3), Whipflails(3), Sneaking(4), Lockpicking(3), Arcane(3), Blood(2), Alchemy(3), Weaponsmithing(2), Traps(1).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_ALLURE)
	inherent_skills = list(
		/datum/skill/combat/knives = 4,
		/datum/skill/combat/swords = 3,
		/datum/skill/combat/crossbows = 4,
		/datum/skill/combat/whipsflails = 3,

		/datum/skill/misc/sneaking = 4,
		/datum/skill/misc/lockpicking = 3,

		/datum/skill/magic/arcane = 3,
		/datum/skill/magic/blood = 2,

		/datum/skill/craft/alchemy = 3,
		/datum/skill/craft/weaponsmithing = 2,
		/datum/skill/craft/traps = 2,
	)
	use_skintones = 1
	disliked_food = NONE
	liked_food = NONE
	possible_ages = NORMAL_AGES_LIST_CHILD
	changesource_flags = WABBAJACK
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mem.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/ft.dmi'
	hairyness = "t3"
	exotic_bloodtype = /datum/blood_type/human/delf

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/elf,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)


	customizers = list(
		/datum/customizer/organ/ears/elf,
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
		/datum/customizer/organ/genitals/testicles/human,
	)

	swap_male_clothes = TRUE

	soundpack_m = /datum/voicepack/male/elf
	soundpack_f = /datum/voicepack/female/elf

	offset_features_m = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,1),\
		OFFSET_WRISTS = list(0,1),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,1),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,1),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,1),\
		OFFSET_SHIRT = list(0,1),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,1),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,1),\
		OFFSET_WRISTS = list(0,1),\
		OFFSET_HANDS = list(0,1),\
		OFFSET_CLOAK = list(0,1),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,1),\
		OFFSET_SHIRT = list(0,1),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,1),\
	)

	offset_genitals_m = list(
		OFFSET_BREASTS = list(0, 0),\
	)

	offset_genitals_f = list(
		OFFSET_BREASTS = list(0, 0),\
	)

	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 1, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 2, STATKEY_LCK = 1)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 1, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 2, STATKEY_LCK = 1)
	enflamed_icon = "widefire"

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

/datum/species/elf/dark/get_span_language(datum/language/message_language)
	if(!message_language)
		return
	if(message_language.type == /datum/language/elvish)
		return list(SPAN_DELF)
	return message_language.spans
/*
/datum/species/elf/dark/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.remove_language(/datum/language/common)

/datum/species/elf/dark/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/common)
*/
/datum/species/elf/dark/check_roundstart_eligible()
	return TRUE

/datum/species/elf/dark/get_skin_list()
	return sortList(list(
		"Pale Blue"       = SKIN_TONE_DROW_PALE_BLUE,       // #9796a9
		"Pale Purple"     = SKIN_TONE_DROW_PALE_PURPLE,     // #897489
		"Pale Grey"       = SKIN_TONE_DROW_PALE_GREY,       // #938f9c
		"Deep Grey"       = SKIN_TONE_DROW_DEEP_GREY,       // #737373
		"Grey-Purple"     = SKIN_TONE_DROW_GREY_PURPLE,     // #6a616d
		"Grey-Blue"       = SKIN_TONE_DROW_GREY_BLUE,       // #5f5f70
		"Black-Blue"      = SKIN_TONE_DROW_BLACK_BLUE,      // #2F2F38
		"Very Pale"       = SKIN_TONE_DROW_VERY_PALE,       // #fff0e9
		"Light Purple"    = SKIN_TONE_DROW_LIGHT_PURPLE,    // #a191a1
		"Mid Purple"      = SKIN_TONE_DROW_MID_PURPLE,      // #897489
		"Dark Purple"     = SKIN_TONE_DROW_DARK_PURPLE,     // #5f5f70
		"Depth Grey-Blue" = SKIN_TONE_DROW_DEPTH_GREY_BLUE, // #5f5f70
		"Pink"            = SKIN_TONE_DROW_PINK,            // #897489
		"Very Pale"		  = SKIN_COLOR_DROW_PALE,	       // #fff0e9

	))

/datum/species/elf/dark/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/elf/elfdm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/elf/elfdf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/elf/dark/get_possible_surnames(gender = MALE)
	var/static/list/last_names = world.file2list('strings/rt/names/elf/elfsnf.txt')
	return last_names

/datum/species/elf/dark/after_creation(mob/living/carbon/human/C)
	C.dna.species.accent_language = C.dna.species.get_accent(native_language, 2)

/datum/species/elf/dark/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	spawn(5)
		if(!C || QDELETED(C))
			return

		if(!C.GetComponent(/datum/component/darkling))
			C.AddComponent(/datum/component/darkling)

/datum/species/elf/dark/on_species_loss(mob/living/carbon/human/C)
	. = ..()

	var/datum/component/darkling/D = C.GetComponent(/datum/component/darkling)
	if(D)
		qdel(D)
