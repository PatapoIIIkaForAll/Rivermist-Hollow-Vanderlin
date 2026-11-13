/mob/living/carbon/human/species/triton
	race = /datum/species/triton

/datum/attribute_holder/sheet/job/species/triton/inherent
	raw_attribute_list = list(
		/datum/attribute/skill/labor/fishing = 30,
		/datum/attribute/skill/misc/swimming = 40,
	)

/datum/attribute_holder/sheet/job/species/triton/stats/female
	raw_attribute_list = list(
		STAT_STRENGTH = -1,
		STAT_PERCEPTION = -2,
		STAT_CONSTITUTION = -2,
		STAT_SPEED = 1,
		STAT_INTELLIGENCE = 2
	)

/datum/attribute_holder/sheet/job/species/triton/stats/male
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_PERCEPTION = -4,
		STAT_CONSTITUTION = 3,
		STAT_SPEED = -3
	)

/datum/species/triton
	name = "Triton"
	id = SPEC_ID_TRITON
	native_language = "Deepspeak"
	changesource_flags = WABBAJACK

	desc = "The Children of The Seas, also known as Tritons or their colloquial name, \"Deep Folk,\" \
	are a strange species of people that live under the waves of The Seas. \
	Born from creatures of the deep, \
	these aquatic wayfarers all share a few common traits. \
	Similar to other creatures that dwell below the surface, their eyes are dull with disuse. \
	Tritons feel pain when gazing upon that which direct sunlight. \
	\n\n\
	Unlike most of the people of Faerun, their culture is often considered cold and dour; \
	an apathetic attitude to most negative or positive news. For them, the depths of oceans are cold and unforgiving. \
	Large beasts travel the waters that swallow their kin whole... \
	but the crushing depths have provided them a hearty disposition and resistance to most threats. \
	Born of The Seas, their normally placid emotions can swing into a wild rage when they view injustice done upon their kin at the hands of a sapient being. \
	\n\n\
	Tritons seen on the surface are very important trade partners, mercenaries, and surprising academics. \
	Merchants often spend vast amounts of coin to have them aboard their trade vessels, fending off pirates or guiding their boats through turbulent weather. \
	Be it on or within the sea, they excel- on land, however, they struggle. \
	With their awkward and gangly fins, long fingers, sharp talons, ghastly teeth, \
	and milky, foreign eyes, they seem foreign to the people. Human children are often afraid of them due to such appearances."

	possible_ages = NORMAL_AGES_LIST

	default_color = "9cc2e2"
	use_skintones = TRUE

	species_traits = list(NO_UNDERWEAR, HAIR, FACEHAIR, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_WATER_BREATHING, TRAIT_GOOD_SWIM, TRAIT_WATER_LOVER)
	inherent_traits_m = list(TRAIT_STRONGBITE)
	inherent_sheet = /datum/attribute_holder/sheet/job/species/triton/inherent

	statsheet_female = /datum/attribute_holder/sheet/job/species/triton/stats/female
	statsheet_male = /datum/attribute_holder/sheet/job/species/triton/stats/male

	limbs_icon_m = 'icons/roguetown/mob/bodies/f/triton.dmi' //This is intended, as triton sprite files are named in reverse
	limbs_icon_f = 'icons/roguetown/mob/bodies/m/triton.dmi'

	soundpack_f = /datum/voicepack/female
	soundpack_m = /datum/voicepack/male

	order_num = 20

	exotic_bloodtype = /datum/blood_type/human/triton
	enflamed_icon = "widefire"

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/triton,
		ORGAN_SLOT_SNOUT = /obj/item/organ/snout/triton,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/triton,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/fish,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_HORNS = /obj/item/organ/horns/triton,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/triton
	)

	customizers = list(
		/datum/customizer/organ/tail/triton,
		/datum/customizer/organ/snout/triton,
		/datum/customizer/organ/ears/triton,
		/datum/customizer/bodypart_feature/hair/head/humanoid/triton,
		/datum/customizer/bodypart_feature/hair/facial/humanoid/triton,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
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
	descriptor_choices = list(
		/datum/descriptor_choice/trait,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/skin_lamia,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one,
		/datum/descriptor_choice/prominent_two,
		/datum/descriptor_choice/prominent_three,
		/datum/descriptor_choice/prominent_four,
	)

/datum/species/triton/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/deepspeak)

	var/obj/item/bodypart/mouth/jaw = C.get_bodypart(BODY_ZONE_PRECISE_MOUTH)
	jaw.replace_teeth(/obj/item/natural/bundle/teeth/fang)

/datum/species/triton/after_creation(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/deepspeak)
	to_chat(C, "<span class='info'>I can speak Deepspeak with ,f before my speech.</span>")

/datum/species/triton/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/deepspeak)

/datum/species/triton/check_roundstart_eligible()
	return TRUE

/datum/species/triton/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/triton/get_skin_list()
	// Manually sorted please sort your new entries
	return list(
		"Algae Borne" = SKIN_COLOR_ALGAE,
		"Deep Borne" = SKIN_COLOR_DEEP,
		"Jellyfish Borne" = SKIN_COLOR_JELLYFISH,
		"kelp Borne" = SKIN_COLOR_KELP,
		"Reef Borne" = SKIN_COLOR_REEF,
		"Sand Borne" = SKIN_COLOR_SAND,
		"Shallow Borne" = SKIN_COLOR_SHALLOW,
		"Urchin Borne" = SKIN_COLOR_URCHIN,
		"Shell Borne" = SKIN_COLOR_SHELL,
	)

/datum/species/triton/get_hairc_list()
	return list(
		"Abyss" = HAIR_COLOR_ABYSS,
		"Clown" = HAIR_COLOR_CLOWN,
		"Hydrothermal" = HAIR_COLOR_HYDROTHERMAL,
		"Inky" = HAIR_COLOR_INKY,
		"Sea Foam" = HAIR_COLOR_SEA_FOAM,
	)

/datum/species/triton/get_oldhc_list()
	return list(
		"Fog" = HAIR_COLOR_SEA_FOG,
		"Gravel" = HAIR_COLOR_GRAVEL,
		"Mist" = HAIR_COLOR_MIST,
		"Photic" = HAIR_COLOR_PHOTIC,
		"Turtle Egg" = HAIR_COLOR_TURTLE,
	)
