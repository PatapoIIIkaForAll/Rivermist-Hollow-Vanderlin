	/*=================*
	*				   *
	*	 Hollow-kin	   *
	*				   *
	*==================*/

// ( -1 STR, +2 PER, +1 INT, -1 CON, +1 SPD, -1 FOR)

/mob/living/carbon/human/species/demihuman
	race = /datum/species/demihuman

/datum/species/demihuman
	name = "Half-Beastkin"
	id = SPEC_ID_HOLLOWKIN
	desc = "Half-Beastkin are short lived, widely diverse, and have an insatiable hatred for dark elves. \
	This hate stems from their long standing political neighbor and rival, \
	the dark-elven kingdoms of Underdark. \
	Silvanus and Tymora stand as the 'patron-deities' of this species despite having no hand in their creation. \
	Half-Beastkin view freedom to be of the upmost importance due to their dark-elven neighbors' tendencies toward slavery and their own history of subjugation. \
	They also, often mistakenly, worship Silvanus for the boon of their animalistic nature, perceiving him as the source of their traits, talents, and instinct. \
	\n\n\
	Their true origin is much darker. Half-Beastkin are the product of dark-elven ingenuity and fleshcrafting. \
	Their creation is a simple story of malice and greed- of sapient animal hybrid slave homunculi, \
	a person turned product which they could market and sell to other great houses of modern Underdark. \
	The true nature of their existence is largely lost to the half-beastkin through centuries. \
	The dark elves still recall, of course, viciously mocking their creations from deep within their caves, \
	declaring them but nothing more than animals or pets. \
	Half-Beastkin react violently to dark-elven attempts at oppression, this leads to conflicts across Faerun. \
	\n\n\
	To the unaligned observer, half-beastkin are often seen amongst bandit bands, working openly with agents of Mask, \
	conflating the idea of freedom between the two deities. There is, of course, the old wives' tales that circulate... \
	how half-beastkin lead to infestations of Werewolves. Half-Beastkin are often denied nobility from this rumour alone. \
	Whether this is true or not is unknown to the common person, \
	but to those familiar with the horrendous magics used by the dark elves, they must only assume the worst. \
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. EXPECT A MORE DIFFICULT EXPERIENCE. PLAY AT YOUR OWN RISK."

	use_titles = TRUE
	race_titles = list(
	"Half-Cat", "Half-Dog", "Half-Volf", "Half-Lion", "Half-Venard",
	"Half-Tiger", "Half-Sheep", "Half-Goat", "Half-Rous", "Half-Possum",
	"Half-Pig", "Half-Boar", "Half-Rabbit", "Half-Horse", "Half-Donkey",
	"Half-Hyena", "Half-Deer", "Half-Bear", "Half-Panda", "Half-Coyote",
	"Half-Moose", "Half-Jackal", "Half-Panther", "Half-Lynx", "Half-Leopard",
	"Half-Monkey", "Half-Bird", "Half-Seal", "Half-Frog", "Half-Bat", "Half-Otter", "Half-Cow",
	"Half-Bull", "Half-Bee", "Half-Lizard", "Half-Insect", "Half-Spider", "Half-Monster"
	)

	allowed_pronouns = PRONOUNS_LIST
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR, HAIR ,FACEHAIR, LIPS, STUBBLE, OLDGREY)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = TRUE
	possible_ages = NORMAL_AGES_LIST
	disliked_food = NONE
	liked_food = NONE
	changesource_flags = WABBAJACK

	order_num = 19

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mt.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'

	meat = list(/obj/item/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/natural/fur/gote = 0.1,
		/obj/item/natural/fur/volf = 0.1,
		/obj/item/natural/fur/rous = 0.1,
		/obj/item/natural/fur/cabbit = 0.1,
		/obj/item/natural/fur/fox = 0.1,
		/obj/item/natural/fur/bobcat = 0.1,
	)
	exotic_bloodtype = /datum/blood_type/human/demihuman

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

	specstats_m = list(STATKEY_STR = -1, STATKEY_PER = 2, STATKEY_INT = 1, STATKEY_CON = -1, STATKEY_SPD = 1, STATKEY_LCK = -1)
	specstats_f = list(STATKEY_STR = -1, STATKEY_PER = 2, STATKEY_INT = 1, STATKEY_CON = -1, STATKEY_SPD = 1, STATKEY_LCK = -1)

	enflamed_icon = "widefire"

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
		ORGAN_SLOT_TAIL = /obj/item/organ/tail,
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
		/datum/customizer/organ/ears/demihuman,
		/datum/customizer/organ/horns/demihuman,
		/datum/customizer/organ/tail/demihuman,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
	)

	descriptor_choices = list(
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/skin,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one_wild,
		/datum/descriptor_choice/prominent_two_wild,
		/datum/descriptor_choice/prominent_three_wild,
		/datum/descriptor_choice/prominent_four_wild,
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

/datum/species/demihuman/check_roundstart_eligible()
	return TRUE

/datum/species/demihuman/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/demihuman/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

/datum/species/demihuman/after_creation(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/beast)
	to_chat(C, "<span class='info'>I can speak Beastish with ,b before my speech.</span>")

/datum/species/demihuman/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/beast)

/datum/species/demihuman/get_skin_list()
	if((MUTCOLORS in species_traits) || (MUTCOLORS_PARTSONLY in species_traits))
		return get_common_mutant_color_palette()
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
