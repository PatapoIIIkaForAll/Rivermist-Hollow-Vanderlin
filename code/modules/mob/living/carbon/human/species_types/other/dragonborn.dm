/mob/living/carbon/human/species/dragonborn
	race = /datum/species/dragonborn

/datum/species/dragonborn
	name = "Dragonborn"
	id = SPEC_ID_DRAGONBORN
	desc = "Dragonborn are a proud and ancient race that trace their heritage to dragons of old. \
	They are highly protective of their bloodline and do everything in their power to make sure it does not spread beyond their own, \
	as they believe themselves to be guardians of tradition and that it is their ultimate duty to maintain their prestige as a race. \
	After all, a single drop of draconic blood in ones bloodline means that they will experience all of the benefits of having draconic ancestors such as agelessness.\
	<br><br> \
	Yet, it comes at a cost. \
	While initially viewed as one of the noblest races, \
	they are now hated for their insufferable arrogance and often appear completely out of touch with the rest of society. \
	Their inability to have a concept of time, refusal to compromise or intermarry, \
	along with their rejection of any technology that threatens their supremacy have earned them countless enemies from Axians to Dwarves. \
	For instance, they view any Wild-kin with draconic features or blood as inherently inferior. \
	Yet, not all Dragonborn are like this with some believing it is their duty to help lesser races, although many still view these Dragonborn to be just as insufferable.\
	<br><br> \
	In the past, Dragonborn held positions of power and prestige across all the realms. \
	Many try to style themselves after knight-philosophers in an attempt to hide their brutish ways. \
	When in reality, most Dragonborn are known for being bloody conquerors. \
	However, the rise of humans have caused their ambitions to crumble, forcing them to work with other races, especially at the climax of the Great Lizard Uprising. \
	Furthermore, dwindling numbers have caused Dragonborn to increasingly abandon the ways of old, forcing them to adapt to a more modern way of life."
	species_traits = list(EYECOLOR,LIPS,STUBBLE,MUTCOLORS)
	possible_ages = ALL_AGES_LIST
	changesource_flags = WABBAJACK
	limbs_icon_m = 'modular_rmh/icons/mob/bodies/m/mta.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/bodies/f/fma.dmi'
	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female
	order_num = 27

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
		OFFSET_CLOAK = list(0,1),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,2),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,-1),\
	)


	specstats_m = list(STATKEY_STR = 2, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = -1, STATKEY_LCK = 0)
	specstats_f = list(STATKEY_STR = 2, STATKEY_PER = 0, STATKEY_INT = 0, STATKEY_CON = 0, STATKEY_END = 0, STATKEY_SPD = -1, STATKEY_LCK = 0)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/lizard,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/dragontail,
		ORGAN_SLOT_SNOUT = /obj/item/organ/snout/lizard,
		ORGAN_SLOT_TAIL_FEATURE = /obj/item/organ/tail_feature/lizard_spines,
		ORGAN_SLOT_FRILLS = /obj/item/organ/frills/lizard,
		ORGAN_SLOT_HORNS = /obj/item/organ/horns,
		)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/organ/wings/dragonborn,
		/datum/customizer/organ/tail/lizard,
		/datum/customizer/organ/tail_feature/lizard_spines,
		/datum/customizer/organ/snout/lizard/dragonborn,
		/datum/customizer/organ/ears/lizard,
		/datum/customizer/organ/frills/lizard,
		/datum/customizer/organ/horns/humanoid,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/animal,
		/datum/customizer/organ/ears/anthro,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/bellyscale,
		/datum/body_marking_set/tiger,
		/datum/body_marking_set/tiger_dark,
	)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/tiger,
		/datum/body_marking/tiger/dark,
		/datum/body_marking/sock,
		/datum/body_marking/socklonger,
		/datum/body_marking/tips,
		/datum/body_marking/bellyscale,
		/datum/body_marking/bellyscaleslim,
		/datum/body_marking/bellyscalesmooth,
		/datum/body_marking/bellyscaleslimsmooth,
		/datum/body_marking/buttscale,
		/datum/body_marking/belly,
		/datum/body_marking/bellyslim,
		/datum/body_marking/butt,
		/datum/body_marking/tie,
		/datum/body_marking/tiesmall,
		/datum/body_marking/backspots,
		/datum/body_marking/front,
		/datum/body_marking/drake_eyes,
		/datum/body_marking/tonage,
		/datum/body_marking/spotted,
	)

	descriptor_choices = list(
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/scales,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one,
		/datum/descriptor_choice/prominent_two,
		/datum/descriptor_choice/prominent_three,
		/datum/descriptor_choice/prominent_four,
	)

/datum/species/dragonborn/check_roundstart_eligible()
	return TRUE

/datum/species/dragonborn/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/dragonborn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/dragonborn/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/dragonborn/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[/datum/body_marking_set/bellyscale], passed_features, src)

/datum/species/dragonborn/get_skin_list()
	return get_common_mutant_color_palette()
