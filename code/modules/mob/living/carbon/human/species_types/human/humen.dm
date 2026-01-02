	/*==============*
	*				*
	*	 Humen		*
	*				*
	*===============*/

//	( +1 Fortune )

/mob/living/carbon/human/species/human/northern
	race = /datum/species/human/northern

/datum/species/human/northern
	name = "Human"
	id = SPEC_ID_HUMEN
	desc = "Humans are the most numerous and diverse people of Faerûn. \
	n\n\
	Found in every land from the Sword Coast to Kara-Tur, human cultures vary wildly in language, customs, and beliefs. \
	\n\n\
	Their short lifespans drive them to ambition, innovation, and conquest, allowing human nations to rise and fall with remarkable speed. \
	\n\n\
	While they lack the innate magic or longevity of other races, humans compensate with adaptability and determination, shaping much of Faerûn’s history through sheer will and population. \
	\n\n\
	(+1 To All Stats, +1 To One Stat Of Choice).\
	\n\n\
	Proficiencies: Swords(2), Polearms(2), Shields(2), Crafting(2), Carepntry(2), Cooking(2), Farming(2), Athletics(2), Reading(2), Riding(1)."


	default_color = "FFFFFF"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	inherent_skills = list(
		/datum/skill/combat/swords = 2,
		/datum/skill/combat/polearms = 2,
		/datum/skill/combat/shields = 2,

		/datum/skill/craft/crafting = 2,
		/datum/skill/craft/carpentry = 2,
		/datum/skill/craft/cooking = 2,

		/datum/skill/labor/farming = 2,

		/datum/skill/misc/athletics = 2,
		/datum/skill/misc/reading = 2,
		/datum/skill/misc/riding = 1,
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
		OFFSET_UNDIES = list(0,0),\
	)

	specstats_m = list(STATKEY_STR = 1, STATKEY_PER = 1, STATKEY_INT = 1, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_SPD = 1, STATKEY_LCK = 1)
	specstats_f = list(STATKEY_STR = 1, STATKEY_PER = 1, STATKEY_INT = 1, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_SPD = 1, STATKEY_LCK = 1)

	enflamed_icon = "widefire"

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/underwear,
		/datum/customizer/bodypart_feature/legwear,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/human,
		/datum/customizer/organ/genitals/vagina/human,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
		/datum/customizer/organ/genitals/testicles/human,
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

/datum/species/human/northern/check_roundstart_eligible()
	return TRUE

/datum/species/human/northern/get_skin_list()
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

/datum/species/human/northern/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/human/humnorm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/human/humnorf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/human/northern/get_possible_surnames(gender = MALE)
	var/static/list/last_names = world.file2list('strings/rt/names/human/humnorlast.txt')
	return last_names

/datum/species/human/northern/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()

	spawn(10)
		if(!C || !C.client)
			return

		var/list/choices = list(
			"Strength"      = STATKEY_STR,
			"Perception"   = STATKEY_PER,
			"Intelligence" = STATKEY_INT,
			"Constitution" = STATKEY_CON,
			"Endurance"    = STATKEY_END,
			"Speed"        = STATKEY_SPD,
			"Fortune"      = STATKEY_LCK
		)

		var/choice = input(
			C,
			"Choose an attribute to gain +1:",
			"Human Versatility"
		) as null|anything in choices

		if(!choice)
			return

		switch(choices[choice])
			if(STATKEY_STR) C.base_strength++
			if(STATKEY_PER) C.base_perception++
			if(STATKEY_INT) C.base_intelligence++
			if(STATKEY_CON) C.base_constitution++
			if(STATKEY_END) C.base_endurance++
			if(STATKEY_SPD) C.base_speed++
			if(STATKEY_LCK) C.base_fortune++

	spawn(5)
		if(!C || QDELETED(C))
			return

		if(!C.GetComponent(/datum/component/darkling))
			C.AddComponent(/datum/component/darkling)

/datum/species/human/northern/on_species_loss(mob/living/carbon/human/C)
	. = ..()

	var/datum/component/darkling/D = C.GetComponent(/datum/component/darkling)
	if(D)
		qdel(D)
