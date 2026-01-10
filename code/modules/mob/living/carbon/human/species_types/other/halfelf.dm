	/*==============*
	*				*
	*	Half-Elf	*
	*				*
	*===============*/

/mob/living/carbon/human/species/human/halfelf
	race = /datum/species/human/halfelf

/datum/species/human/halfelf
	name = "Half-Elf"
	id = SPEC_ID_HALF_ELF
	multiple_accents = list(
		"Humen Accent" = "Imperial",
		"Elf Accent" = "Elfish"
	)
	desc = "Half-Elves are born of human and elven unions, inheriting traits from both worlds yet fully belonging to neither. \
	\n\n\
	In Faerûn, they are often natural diplomats, wanderers, or intermediaries, capable of moving between cultures with ease. \
	\n\n\
	Their adaptability and charm make them well-suited to social roles, though many struggle with identity and acceptance. \
	\n\n\
	(+2 LCK, +1 To Two Stats Of Choice, Allure, Elvish Language).\
	\n\n\
	Proficiencies: Swords(2), Bows(2), Arcane(2), Reading(2), Music(2), Sneaking(2)."


	default_color = "FFFFFF"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_ALLURE)
	inherent_skills = list(
		/datum/skill/combat/swords = 2,
		/datum/skill/combat/bows = 2,

		/datum/skill/magic/arcane = 2,

		/datum/skill/misc/reading = 3,
		/datum/skill/misc/music = 2,
		/datum/skill/misc/sneaking = 2,
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

	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 0, STATKEY_LCK = 2)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 0, STATKEY_LCK = 2)

	enflamed_icon = "widefire"

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/elf/less,
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

/datum/species/human/halfelf/check_roundstart_eligible()
	return TRUE

/datum/species/human/halfelf/get_skin_list()
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

/datum/species/human/halfelf/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/elf/elfwm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/elf/elfwf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/human/halfelf/get_possible_surnames(gender = MALE)
	return null

/datum/species/human/halfelf/after_creation(mob/living/carbon/human/C)
	..()
	//If a donator picks the Elf Accent as a Half Elf, it will work the same as a non donator.
	if(C.accent == ACCENT_ELF)
		C.dna.species.native_language = "Elfish"
		C.dna.species.accent_language = C.dna.species.get_accent(C.dna.species.native_language, 1)
	if(!(C.accent in GLOB.accent_list))
		C.dna.species.native_language = C.accent
	C.dna.species.accent_language = C.dna.species.get_accent(C.dna.species.native_language, 1)
	C.grant_language(/datum/language/elvish)
	to_chat(C, "<span class='info'>I can speak Elvish with ,e before my speech.</span>")

/mob/living/carbon/human
	var/halfelf_stats_picked = FALSE

/datum/species/human/halfelf/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()

	if(!istype(C) || C.halfelf_stats_picked)
		return

	spawn(10)
		if(C && C.client && !C.halfelf_stats_picked)
			pick_halfelf_stats(C)


/datum/species/human/halfelf/proc/pick_halfelf_stats(mob/living/carbon/human/C)
	C.halfelf_stats_picked = TRUE

	var/list/choices = list(
		"Strength"      = STATKEY_STR,
		"Perception"   = STATKEY_PER,
		"Intelligence" = STATKEY_INT,
		"Constitution" = STATKEY_CON,
		"Endurance"    = STATKEY_END,
		"Speed"        = STATKEY_SPD,
		"Fortune"      = STATKEY_LCK
	)

	var/picks_remaining = 2

	while(picks_remaining > 0 && choices.len)
		var/choice = input(
			C,
			"Choose an attribute to gain +1 ([picks_remaining] remaining):",
			"Half-Elf Versatility"
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

		choices -= choice
		picks_remaining--
