/mob/living/carbon/human/species/gnome
	race = /datum/species/gnome

/datum/species/gnome
	name = "Gnome"
	id = SPEC_ID_GNOME
	desc = "Gnomes are curious and inventive folk, driven by an insatiable desire to learn and create. \
	n\n\
	Found throughout Faerûn, they favor hidden settlements where clever craftsmanship, illusion magic, and experimentation flourish. \
	n\n\
	Despite their small stature, gnomes possess sharp intellects and quick wits. \
	n\n\
	They approach life with humor and optimism, believing that curiosity and cleverness can overcome challenges far larger than themselves. \
	n\n\
	(+1 INT, +2 LCK).\
	\n\n\
	Proficiencies: Engineering(4), Crafting(3), Alchemy(3), Crossbows(2), Reading(4), Mathematics(4), Arcane(3)."

	default_color = "FFFFFF"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_TINY, TRAIT_NOMOBSWAP, TRAIT_LIGHT_STEP, TRAIT_COIN_ILLITERATE, TRAIT_LUCKY_COOK)
	inherent_sheet = /datum/attribute_holder/sheet/job/species/gnome/inherent

	use_skintones = TRUE

	possible_ages = NORMAL_AGES_LIST

	changesource_flags = WABBAJACK

	order_num = 12

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/male_short.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fd.dmi'
	swap_male_clothes = TRUE
	custom_clothes = TRUE
	custom_id = SPEC_ID_DWARF

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/elf,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)

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
	statsheet_male = /datum/attribute_holder/sheet/job/species/gnome/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/gnome/stats/female

	enflamed_icon = "widefire"

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
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/testicles/human,
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

	nutrition_mod = 2

/datum/species/gnome/check_roundstart_eligible()
	return TRUE

/datum/species/gnome/after_creation(mob/living/carbon/C)
	..()

/datum/species/gnome/get_skin_list()
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

/datum/species/gnome/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()

	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

	RegisterSignal(C, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(handle_equip))

	if(!C.shoes)
		C.apply_status_effect(/datum/status_effect/buff/free_feet)

/datum/species/gnome/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	if(QDELETED(C))
		return
	C.remove_language(/datum/language/common)
	UnregisterSignal(C, COMSIG_MOB_SAY)
	UnregisterSignal(C, COMSIG_MOB_EQUIPPED_ITEM)
	C.remove_status_effect(/datum/status_effect/buff/free_feet)
	C.remove_status_effect(/datum/status_effect/buff/stuffed)

/datum/species/gnome/proc/handle_equip(mob/living/carbon/source, obj/item/equipping, slot)
	if(QDELETED(source) || !istype(source))
		return

	// This is bad :(
	if(slot & ITEM_SLOT_SHOES)
		source.remove_status_effect(/datum/status_effect/buff/free_feet)
	else if(!source.shoes)
		source.apply_status_effect(/datum/status_effect/buff/free_feet)

/datum/species/gnome/handle_digestion(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD || HAS_TRAIT(H, TRAIT_NOHUNGER))
		return

	if(H.nutrition > NUTRITION_LEVEL_FAT)
		H.apply_status_effect(/datum/status_effect/buff/stuffed)
	else
		H.remove_status_effect(/datum/status_effect/buff/stuffed)

/datum/attribute_holder/sheet/job/species/gnome/inherent
	raw_attribute_list = list(
		/datum/attribute/skill/craft/engineering = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/alchemy = 30,

		/datum/attribute/skill/combat/crossbows = 20,

		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/labor/mathematics = 40,

		/datum/attribute/skill/magic/arcane = 30,
	)


/datum/attribute_holder/sheet/job/species/gnome/stats/male
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 1, STAT_CONSTITUTION = 0, STAT_ENDURANCE = 0, STAT_SPEED = 0, STAT_FORTUNE = 2)


/datum/attribute_holder/sheet/job/species/gnome/stats/female
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 1, STAT_CONSTITUTION = 0, STAT_ENDURANCE = 0, STAT_SPEED = 0, STAT_FORTUNE = 2)
