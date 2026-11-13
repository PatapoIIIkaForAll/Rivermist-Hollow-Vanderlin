	/*==============*
	*				*
	*	  Dwarf		*
	*				*
	*===============*/

//	( + Poison Resistance )

/mob/living/carbon/human/species/dwarf/mountain
	race = /datum/species/dwarf/mountain

/datum/attribute_holder/sheet/job/species/mountain_dwarf
	raw_attribute_list = list(
		/datum/attribute/skill/combat/axesmaces = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/craft/blacksmithing = 40,
		/datum/attribute/skill/craft/armorsmithing = 40,
		/datum/attribute/skill/craft/weaponsmithing = 30,
		/datum/attribute/skill/labor/mining = 40,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/misc/athletics = 30,
	)

/datum/attribute_holder/sheet/job/species/mountain_dwarf/stats
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 1
	)

/datum/species/dwarf/mountain
	name = "Dwarf"
	id = SPEC_ID_DWARF
	desc = "Dwarves are a stout and enduring people, known throughout Faerûn for their craftsmanship, resilience, and unyielding traditions.\
	\n\n\
	Most dwarves trace their ancestry to ancient mountain halls carved deep into stone, where clan, honor, and history are held sacred. \
	\n\n\
	Slow to trust but steadfast once bonds are formed, dwarves possess long memories—both for friendship and for grudges.\
	\n\n\
	Their lives are shaped by stone and steel, and many see perseverance itself as the highest virtue. \
	n\n\
	(+1 STR, 2+ CON, +1 END, Poison Resistance, Dwarvish Language).\
	\n\n\
	Proficiencies: Axemaces(4), Shields(4), Blacksmithing(4), Armorsmithing(4), Weaponsmithing(3), Mining(4), Masonry(3), Athletics(3)."

	default_color = "FFFFFF"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, YOUNGBEARD, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_POISON_RESILIENCE)
	inherent_sheet = /datum/attribute_holder/sheet/job/species/mountain_dwarf

	possible_ages = NORMAL_AGES_LIST
	use_skintones = TRUE

	order_num = 10

	changesource_flags = WABBAJACK

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/md.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fd.dmi'
	body_hair_materials = BODY_HAIR_MATERIALS_DWARVEN

	hairyness = "t3"

	soundpack_m = /datum/voicepack/male/dwarf
	soundpack_f = /datum/voicepack/female/dwarf

	custom_clothes = TRUE

	offset_features_m = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,-3),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-4),\
		OFFSET_HEAD = list(0,-4),\
		OFFSET_FACE = list(0,-4),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,-4),\
		OFFSET_NECK = list(0,-4),\
		OFFSET_MOUTH = list(0,-4),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
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
	statsheet_male = /datum/attribute_holder/sheet/job/species/mountain_dwarf/stats
	statsheet_female = /datum/attribute_holder/sheet/job/species/mountain_dwarf/stats

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
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
		/datum/customizer/organ/genitals/testicles/human,
		/datum/customizer/bodypart_feature/body_hair,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair/enabled,
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

/datum/species/dwarf/mountain/check_roundstart_eligible()
	return TRUE

/datum/species/dwarf/mountain/get_span_language(datum/language/message_language)
	if(!message_language)
		return
	if(message_language.type == /datum/language/dwarvish)
		return list(SPAN_DWARF)
	return message_language.spans

/datum/species/dwarf/mountain/get_skin_list()
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

/datum/species/dwarf/mountain/get_hairc_list()
	return sortList(list(
		"black - oil" = "181a1d",
		"black - cave" = "201616",
		"black - rogue" = "2b201b",
		"black - midnight" = "1d1b2b",

		"blond - pale" = "9d8d6e",
		"blond - dirty" = "88754f",
		"blond - drywheat" = "d5ba7b",
		"blond - strawberry" = "c69b71",

		"brown - mud" = "362e25",
		"brown - oats" = "7a4e1e",
		"brown - grain" = "58433b",
		"brown - soil" = "48322a",
		"brown - bark" = "2d1300",

		"red - berry" = "b23434",
		"red - wine" = "b87f77",
		"red - sunset" = "bf6821",
		"red - blood" = "822b2b",
		"red - maroon" = "612929",

		"white - withered" = "7c828a"
	))

/datum/species/dwarf/mountain/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/dwarf/dwarmm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/dwarf/dwarmf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/dwarf/mountain/get_possible_surnames(gender = MALE)
	var/static/list/last_names = world.file2list('strings/rt/names/dwarf/dwarmlast.txt')
	return last_names
