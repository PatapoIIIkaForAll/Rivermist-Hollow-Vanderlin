/mob/living/carbon/human/species/halfling
	race = /datum/species/halfling

/datum/species/halfling
	name = "Halfling"
	id = SPEC_ID_HALFLING
	desc = "Halflings are a cheerful and resilient people, valuing comfort, community, and simple pleasures. \
	n\n\
	Though they prefer peaceful lives, halflings are far from helpless, often displaying remarkable courage when faced with danger. \
	n\n\
	In Faerûn, halflings are known for their good fortune and ability to endure hardship with a smile. \
	n\n\
	Their loyalty to friends and family runs deep, and they believe that perseverance and kindness are strengths greater than physical might. \
	n\n\
	(-1 STR, 1+ END, +1 SPD, +2 LCK).\
	\n\n\
	Proficiencies: Sneaking(4), Stealing(3), Lockpicking(3), Knives(2), Farming(3), Cooking(3), Fishing(2)."

	default_color = "FFFFFF"
	native_language = "Halfling"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_LIGHT_STEP, TRAIT_COIN_ILLITERATE, TRAIT_LUCKY_COOK)
	inherent_skills = list(
		/datum/skill/misc/sneaking = 4,
		/datum/skill/misc/stealing = 3,
		/datum/skill/misc/lockpicking = 3,

		/datum/skill/combat/knives = 2,

		/datum/skill/labor/farming = 3,
		/datum/skill/craft/cooking = 3,
		/datum/skill/labor/fishing = 2,
	)

	use_skintones = TRUE

	possible_ages = NORMAL_AGES_LIST_CHILD

	changesource_flags = WABBAJACK

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/male_short.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fd.dmi'
	swap_male_clothes = TRUE
	custom_clothes = TRUE
	custom_id = SPEC_ID_DWARF

	// Both from female dwarf
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

	// Gets 2 SPD if they aren't wearing shoes
	// Gets 0 / 1 END if they eat enough
	specstats_m = list(STATKEY_STR = -1, STATKEY_PER = 0, STATKEY_CON = 0, STATKEY_END = 1, STATKEY_SPD = 1, STATKEY_LCK = 2)
	specstats_f = list(STATKEY_STR = -1, STATKEY_PER = 0, STATKEY_CON = 0, STATKEY_END = 1, STATKEY_SPD = 1, STATKEY_LCK = 2)

	enflamed_icon = "widefire"

	customizers = list(
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
		/datum/customizer/bodypart_feature/piercing,
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

	nutrition_mod = 2

/datum/species/halfling/check_roundstart_eligible()
	return TRUE

/datum/species/halfling/after_creation(mob/living/carbon/C)
	..()
	C.dna.species.accent_language = C.dna.species.get_accent(native_language, 1)
	C.grant_language(/datum/language/halfling)
	to_chat(C, span_info("I can speak Halfspeak with ,p before my speech."))

/datum/species/halfling/get_skin_list()
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

/datum/species/halfling/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()

	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/halfling)

	RegisterSignal(C, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(handle_equip))

	if(!C.shoes)
		C.apply_status_effect(/datum/status_effect/buff/free_feet)

/datum/species/halfling/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	if(QDELETED(C))
		return
	C.remove_language(/datum/language/common)
	C.remove_language(/datum/language/halfling)
	UnregisterSignal(C, COMSIG_MOB_SAY)
	UnregisterSignal(C, COMSIG_MOB_EQUIPPED_ITEM)
	C.remove_status_effect(/datum/status_effect/buff/free_feet)
	C.remove_status_effect(/datum/status_effect/buff/stuffed)

/datum/species/halfling/proc/handle_equip(mob/living/carbon/source, obj/item/equipping, slot)
	if(QDELETED(source) || !istype(source))
		return

	// This is bad :(
	if(slot & ITEM_SLOT_SHOES)
		source.remove_status_effect(/datum/status_effect/buff/free_feet)
	else if(!source.shoes)
		source.apply_status_effect(/datum/status_effect/buff/free_feet)

/datum/species/halfling/handle_digestion(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD || HAS_TRAIT(H, TRAIT_NOHUNGER))
		return

	if(H.nutrition > NUTRITION_LEVEL_FAT)
		H.apply_status_effect(/datum/status_effect/buff/stuffed)
	else
		H.remove_status_effect(/datum/status_effect/buff/stuffed)
