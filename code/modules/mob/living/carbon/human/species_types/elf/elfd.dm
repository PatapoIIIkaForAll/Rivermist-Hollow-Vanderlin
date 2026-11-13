	/*==============*
	*				*
	*	Dark Elf	*
	*				*
	*===============*/

//	( + Night Vision Plus )

/mob/living/carbon/human/species/elf/dark
	race = /datum/species/elf/dark

/datum/attribute_holder/sheet/job/species/dark/stats
	raw_attribute_list = list(
		STAT_PERCEPTION = 1,
		STAT_SPEED = 2,
		STAT_FORTUNE = 1,
	)

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
	inherent_sheet = /datum/attribute_holder/sheet/job/species/dark/inherent
	use_skintones = 1
	disliked_food = NONE
	liked_food = NONE
	possible_ages = NORMAL_AGES_LIST
	changesource_flags = WABBAJACK
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mem.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/ft.dmi'
	allowed_body_builds = ELVEN_BODY_BUILDS
	default_body_build_m = BODY_BUILD_SLIM
	default_body_build_f = BODY_BUILD_LITHE
	hairyness = "t3"
	exotic_bloodtype = /datum/blood_type/human/delf

	order_num = 6

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/elf,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
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
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
		/datum/customizer/organ/genitals/testicles/human,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
	)

	swap_male_clothes_but_not_offsets  = TRUE

	soundpack_m = /datum/voicepack/male/elf
	soundpack_f = /datum/voicepack/female/elf

	offset_features_m = list(
		OFFSET_RING = list(0,1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,2),\
		OFFSET_HANDS = list(0,1),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,1),\
		OFFSET_HEAD = list(0,1),\
		OFFSET_FACE = list(0,1),\
		OFFSET_BELT = list(0,1),\
		OFFSET_BACK = list(0,1),\
		OFFSET_NECK = list(0,1),\
		OFFSET_MOUTH = list(0,1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
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
		OFFSET_BELT = list(0,1),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,1),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,0),\
	)

	statsheet_male = /datum/attribute_holder/sheet/job/species/dark/stats
	statsheet_female = /datum/attribute_holder/sheet/job/species/dark/stats
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
		"Mid Purple"      = SKIN_TONE_DROW_MID_PURPLE,      // #7b6680
		"Dark Purple"     = SKIN_TONE_DROW_DARK_PURPLE,     // #4f4256
		"Depth Grey-Blue" = SKIN_TONE_DROW_DEPTH_GREY_BLUE, // #4a5163
		"Pink"            = SKIN_TONE_DROW_PINK,            // #a07f92
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

	addtimer(CALLBACK(src, PROC_REF(give_darkling), C), 50)

/datum/species/elf/dark/on_species_loss(mob/living/carbon/human/C)
	. = ..()

	var/datum/component/darkling/D = C.GetComponent(/datum/component/darkling)
	if(D)
		qdel(D)

/datum/attribute_holder/sheet/job/species/dark/inherent
	raw_attribute_list = list(
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/whipsflails = 30,

		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/lockpicking = 30,

		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/magic/blood = 20,

		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/weaponsmithing = 20,
		/datum/attribute/skill/craft/traps = 20,
	)
