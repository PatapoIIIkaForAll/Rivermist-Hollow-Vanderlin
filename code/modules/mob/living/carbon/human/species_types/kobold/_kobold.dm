	/*==============*
	*				*
	*	  Kobold	*
	*				*
	*===============*/

///mmmm yumymumyumuymuymym
#define DIET_KOBOLD list(\
	/obj/item/natural/dirtclod,\
	/obj/item/natural/stone,\
	/obj/item/coin,\
	/obj/item/gem,\
)

#define DIET_TURF_KOBOLD list(\
	/turf/closed/mineral,\
	/turf/closed/wall/mineral/stone,\
	/turf/closed/wall/mineral/craftstone,\
	/turf/closed/wall/mineral/decostone,\
	/turf/closed/wall/mineral/desert_sandstone,\
)

/mob/living/carbon/human/species/kobold
	race = /datum/species/kobold

/datum/species/kobold
	name = "Kobold"
	id = SPEC_ID_KOBOLD
	desc = "Speculated to have originated from the dank depths of Underdark, \
	Kobolds are a species of stout sea-faring and mountain-dwelling lizardfolk infamous for their skills in trap-making, \
	their habit of hoarding grandiose amounts of trinkets and artifacts, and their opportunism.\
	\n\n\
	They are often in servitude to great beasts such as dragons and giants - trapping their lairs and utilizing pack tactics to dispose of ambitious adventurers and thieves alike. \
	But in their lonesome, Kobolds are generally weak and quick to die, as they noticeably lack the meaningful amount of constitution, strength, and endurance that other species usually have. \
	\n\n\
	WARNING: THIS IS A HEAVILY DISCRIMINATED AGAINST CHALLENGE SPECIES WITH ACTIVE SPECIES DETRIMENTS. YOU CAN AND WILL DIE A LOT; PLAY AT YOUR OWN RISK!"

	default_color = "FFFFFF"

	species_traits = list(NO_UNDERWEAR)
	inherent_traits = list(TRAIT_TINY, TRAIT_DARKVISION)

	specstats_m = list(STATKEY_STR = -4, STATKEY_PER = -2, STATKEY_INT = -2, STATKEY_CON = -4, STATKEY_END = 2, STATKEY_SPD = 2, STATKEY_LCK = 0)
	specstats_f = list(STATKEY_STR = -4, STATKEY_PER = -2, STATKEY_INT = -2, STATKEY_CON = -4, STATKEY_END = 2, STATKEY_SPD = 2, STATKEY_LCK = 0)

	// allowed_pronouns = PRONOUNS_LIST_IT_ONLY // Чтобы могли брать любые местоимения

	possible_ages = NORMAL_AGES_LIST
	use_skintones = TRUE

	changesource_flags = WABBAJACK

	order_num = 17

	native_language = "Gutter"

	limbs_icon_m = 'icons/roguetown/mob/bodies/f/kobold.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/kobold.dmi'

	enflamed_icon = "widefire"

	soundpack_m = /datum/voicepack/male/kobold
	soundpack_f = /datum/voicepack/female/dwarf // Поменял на женский, так как мужской - это уродск

	exotic_bloodtype = /datum/blood_type/human/kobold
	meat = list(/obj/item/reagent_containers/food/snacks/meat/fatty/kobold = 1)

	custom_id = "dwarf"
	custom_clothes = TRUE

	swap_male_clothes = TRUE

	// Uses female dwarf sprites
	offset_features_m = list()

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
		OFFSET_UNDIES = list(0,0),\
	)

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-3),\
		OFFSET_VAGINA = list(0,-4),\
		OFFSET_BUTT = list(0,-4),\
		OFFSET_BELLY = list(0,-4),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,-4),\
		OFFSET_BREASTS = list(0,-4),\
		OFFSET_TESTICLES = list(0,-3),\
		OFFSET_VAGINA = list(0,-4),\
		OFFSET_BUTT = list(0,-4),\
		OFFSET_BELLY = list(0,-4),\
	)

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/smooth,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/kobold,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/kobold
	)

	customizers = list(
		/datum/customizer/organ/tail/kobold,
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
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

	COOLDOWN_DECLARE(kobold_cooldown)

	// Sorry for this
	/// If we can eat turfs and items defined above
	var/hungry_hungry_kobold = TRUE

/datum/species/kobold/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	if(hungry_hungry_kobold)
		C.AddComponent(/datum/component/abberant_eater, DIET_KOBOLD, FALSE, DIET_TURF_KOBOLD)
	C.grant_language(/datum/language/common)

/datum/species/kobold/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(hungry_hungry_kobold)
		var/datum/component/abberant_eater = C.GetComponent(/datum/component/abberant_eater)
		if(abberant_eater)
			abberant_eater.RemoveComponent()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/common)

/datum/species/kobold/check_roundstart_eligible()
	return TRUE

/datum/species/kobold/after_creation(mob/living/carbon/C)
	..()
	C.dna.species.accent_language = C.dna.species.get_accent(native_language, 1)

/datum/species/kobold/get_skin_list()
	return sortList(list(
		"Moonshade" = SKIN_COLOR_MOONSHADE,
		"Sunstreak" = SKIN_COLOR_SUNSTREAK,
		"Stonepaw" = SKIN_COLOR_STONEPAW,
		"Emberhide" = SKIN_COLOR_EMBERHIDE,
		"Sandswept" = SKIN_COLOR_SANDSWEPT,
		"Icepack" = SKIN_COLOR_ICEPACK,
	))

/datum/species/kobold/get_possible_names(gender = MALE)
	var/static/list/male_names = world.file2list('strings/rt/names/dwarf/dwarmm.txt')
	var/static/list/female_names = world.file2list('strings/rt/names/dwarf/dwarmf.txt')
	return (gender == FEMALE) ? female_names : male_names

/datum/species/kobold/get_possible_surnames(gender = MALE)
	var/static/list/last_names = world.file2list('strings/rt/names/dwarf/dwarmlast.txt')
	return last_names

#undef DIET_TURF_KOBOLD
#undef DIET_KOBOLD
