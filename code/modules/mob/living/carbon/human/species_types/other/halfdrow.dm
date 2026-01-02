	/*==============*
	*				*
	*	Half-Drow	*
	*				*
	*===============*/

/mob/living/carbon/human/species/human/halfdrow
	race = /datum/species/human/halfdrow

/datum/species/human/halfdrow
	name = "Half-Drow"
	id = SPEC_ID_HALF_DROW
	multiple_accents = list(
		"Humen Accent" = "Imperial",
		"Dark Elf Accent" = "Elfish"
	)
	desc = "Half-Drow are born from unions between drow and surface folk, most often humans or elves. \
	\n\n\
	They inherit the physical traits of the drow but often lack full acceptance in either Underdark or surface societies. \
	\n\n\
	Some Half-Drow struggle against prejudice and suspicion, while others leverage their mixed heritage to navigate both worlds. \
	\n\n\
	(+2 LCK, +1 To One Stat Of Choice, Allure, Darkvision, Sunlight Sensitivity, Elvish Language).\
	\n\n\
	Proficiencies: Knives(3), Swords(2), Bows(2), Sneaking(3), Lockpicking(2), Reading(2), Arcane(2).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."
	default_color = "FFFFFF"

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_ALLURE)
	inherent_skills = list(
		/datum/skill/combat/knives = 3,
		/datum/skill/combat/swords = 2,
		/datum/skill/combat/bows = 2,

		/datum/skill/misc/sneaking = 3,
		/datum/skill/misc/lockpicking = 2,
		/datum/skill/misc/reading = 2,

		/datum/skill/magic/arcane = 2,
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
		OFFSET_BELT = list(0,-1),\
		OFFSET_BACK = list(0,-1),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = 2)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = 2)

	enflamed_icon = "widefire"

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

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
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

/datum/species/human/halfdrow/check_roundstart_eligible()
	return TRUE

/datum/species/human/halfdrow/get_skin_list()
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

/datum/species/human/halfdrow/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/elf/elfwm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/elf/elfwf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/human/halfdrow/get_possible_surnames(gender = MALE)
	return null

/datum/species/human/halfdrow/after_creation(mob/living/carbon/human/C)
	..()
	//If a donator picks the Dark Elf Accent as a Half Drow, it will work the same as a non donator.
	if(C.accent == ACCENT_DELF)
		C.dna.species.native_language = "Elfish"
		C.dna.species.accent_language = C.dna.species.get_accent(C.dna.species.native_language, 2)
	if(!(C.accent in GLOB.accent_list))
		C.dna.species.native_language = C.accent
	C.dna.species.accent_language = C.dna.species.get_accent(C.dna.species.native_language, 2)

	C.grant_language(/datum/language/elvish)
	to_chat(C, "<span class='info'>I can speak Elvish with ,e before my speech.</span>")

/datum/species/human/halfdrow/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
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
			"Half-Drow Heritage"
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

/datum/species/human/halfdrow/on_species_loss(mob/living/carbon/human/C)
	. = ..()

	var/datum/component/darkling/D = C.GetComponent(/datum/component/darkling)
	if(D)
		qdel(D)
