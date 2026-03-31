/mob/living/carbon/human/species/goblin/player
	race = /datum/species/goblin/player

/datum/species/goblin/player
	name = "Goblin"
	id = SPEC_ID_PLAYER_GOBLIN
	id_override = SPEC_ID_GOBLIN
	desc = "Goblins are clever, wiry opportunists who survive through speed, nerve, and an instinct for finding advantage where others miss it. \
	They are common in badlands, caves, and frontier warrens, though some leave their tribes to make a place in larger realms. \
	\n\n\
	(+1 SPD, Darkvision).\
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_DARKVISION)
	possible_ages = NORMAL_AGES_LIST
	use_skintones = TRUE
	skin_tone_wording = "Skin Color"
	damage_overlay_type = "human"
	dam_icon_m = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	exotic_bloodtype = null
	meat = list(/obj/item/reagent_containers/food/snacks/meat/steak/human = 1)
	changesource_flags = WABBAJACK
	order_num = 24

	limbs_icon_m = 'modular_rmh/icons/mob/species/goblin_male.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/species/goblin_female.dmi'

	soundpack_m = /datum/voicepack/goblin
	soundpack_f = /datum/voicepack/goblin

	custom_clothes = TRUE
	custom_id = SPEC_ID_DWARF
	swap_male_clothes = TRUE

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)

	offset_features_m = list(
		OFFSET_ID = list(0,-4),\
		OFFSET_GLOVES = list(0,-4),\
		OFFSET_WRISTS = list(0,-4),\
		OFFSET_HANDS = list(0,-3),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-5),\
		OFFSET_HEAD = list(0,-4),\
		OFFSET_FACE = list(0,-5),\
		OFFSET_BELT = list(0,-4),\
		OFFSET_BACK = list(0,-4),\
		OFFSET_NECK = list(0,-4),\
		OFFSET_MOUTH = list(0,-4),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,-4),\
	)

	offset_features_f = list(
		OFFSET_ID = list(0,-5),\
		OFFSET_GLOVES = list(0,-4),\
		OFFSET_WRISTS = list(0,-4),\
		OFFSET_HANDS = list(0,-4),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,-5),\
		OFFSET_HEAD = list(0,-5),\
		OFFSET_FACE = list(0,-5),\
		OFFSET_BELT = list(0,-4),\
		OFFSET_BACK = list(0,-5),\
		OFFSET_NECK = list(0,-5),\
		OFFSET_MOUTH = list(0,-5),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,-4),\
	)

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-3),\
		OFFSET_VAGINA = list(0,-4),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-5),\
		OFFSET_TESTICLES = list(0,-3),\
		OFFSET_VAGINA = list(0,-5),\
	)

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/anthro,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/ears/goblin,
		/datum/customizer/organ/horns/tusks,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
	)

	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/spotted,
		/datum/body_marking/tiger,
		/datum/body_marking/tiger/dark,
		/datum/body_marking/sock,
		/datum/body_marking/socklonger,
		/datum/body_marking/tips,
		/datum/body_marking/belly,
		/datum/body_marking/bellyslim,
		/datum/body_marking/butt,
		/datum/body_marking/tie,
		/datum/body_marking/tiesmall,
		/datum/body_marking/backspots,
		/datum/body_marking/front,
	)

	specstats_m = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = 0)
	specstats_f = list(STATKEY_STR = 0, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = 1, STATKEY_LCK = 0)

	enflamed_icon = "widefire"
	native_language = "Orcish"

/datum/species/goblin/player/check_roundstart_eligible()
	return TRUE

/datum/species/goblin/player/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/orcish)

/datum/species/goblin/player/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/orcish)

/datum/species/goblin/player/regenerate_icons(mob/living/carbon/human/H)
	return FALSE

/datum/species/goblin/player/get_skin_list()
	return list(
		"Ochre" = "B98A48",
		"Meadow" = "6C8D4E",
		"Olive" = "708238",
		"Green" = "4F8A43",
		"Moss" = "4A6B39",
		"Taiga" = "4B6F56",
		"Bronze" = "8C6B4A",
		"Red" = "8B4C3A",
		"Frost" = "9DB7B8",
		"Abyss" = "314350",
		"Teal" = "2D7B75",
		"Hadal" = "1C4552",
	)
