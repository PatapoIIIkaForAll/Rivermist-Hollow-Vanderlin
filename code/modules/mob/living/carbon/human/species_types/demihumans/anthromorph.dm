/mob/living/carbon/human/species/anthromorph
	race = /datum/species/anthromorph

/datum/species/anthromorph
	name = "Beast-Kin"
	id = SPEC_ID_BEASTKIN

	desc = "Beast-kins are a highly diverse and varied group of people, the majority of which are descendants of the \
	first followers of Silvanus who rejected civilization in favour of the deep forests. However, some came from \
	magical anomalies or curses, Divine or otherwise. \
	<br><br> \ Their bloodlines were blessed by Silvanus for their ancestor&#39;s devotion \
	and this is reflected in their appearance. Some descendants of the first forest-blessed beast-kins, \
	especially those not as devoted to the ways of Silvanus and filled \
	with wanderlust, emerged from their remote communities to embrace the civilization their ancestors had once rejected. \
	<br><br> \
	At first, they faced discrimination from people wary of their abnormal appearances. Yet, their appearance was a blessing \
	from Silvanus, and the clergy of the gods made this known throughout the lands of the faithful. Beast-kins are now fully \
	accepted, with many even holding titles of landed nobility. However, there is still an air of distrust and uncertainty \
	surrounding them, especially for those who acquired their features during life rather than through birth."

	use_titles = TRUE
	race_titles = list(
	"Cat-Kin", "Dog-Kin", "Volf-Kin", "Lion-Kin", "Venard-Kin", "Tiger-Kin", "Sheep-Kin",
	"Goat-Kin", "Rous-Kin", "Possum-Kin", "Pig-Kin", "Boar-Kin", "Rabbit-Kin", "Horse-Kin",
	"Donkey-Kin", "Hyena-Kin", "Deer-Kin", "Bear-Kin", "Panda-Kin", "Coyote-Kin", "Moose-Kin",
	"Jackal-Kin", "Panther-Kin", "Lynx-Kin", "Leopard-Kin", "Monkey-Kin", "Bird-Kin", "Seal-Kin", "Frog-Kin",
	"Bat-Kin", "Otter-Kin", "Cow-Kin", "Bull-Kin", "Bee-Kin", "Lizard-Kin", "Insect-Kin", "Spider-Kin", "Monster-Kin", "Chimera"
	)
	allowed_pronouns = PRONOUNS_LIST
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = TRUE
	possible_ages = NORMAL_AGES_LIST
	disliked_food = NONE
	liked_food = NONE
	default_color = "444"
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		LIPS,
		HAIR,
	)

	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	changesource_flags = WABBAJACK
	possible_ages = NORMAL_AGES_LIST
	limbs_icon_m = 'modular_rmh/icons/mob/bodies/m/mta.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/bodies/f/fma.dmi'

	order_num = 23

	exotic_bloodtype = /datum/blood_type/human/demihuman
	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female

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

	specstats_m = list(STATKEY_STR = 1, STATKEY_PER = 2, STATKEY_INT = -1, STATKEY_CON = 1, STATKEY_SPD = 1, STATKEY_LCK = -1, STATKEY_END = -1)
	specstats_f = list(STATKEY_STR = 1, STATKEY_PER = 2, STATKEY_INT = -1, STATKEY_CON = 1, STATKEY_SPD = 1, STATKEY_LCK = -1, STATKEY_END = -1)
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
		/datum/customizer/organ/tail/anthro,
		/datum/customizer/organ/tail_feature/anthro,
		/datum/customizer/organ/snout/anthro,
		/datum/customizer/organ/ears/anthro,
		/datum/customizer/organ/horns/anthro,
		/datum/customizer/organ/frills/anthro,
		/datum/customizer/organ/wings/anthro,
		/datum/customizer/organ/neck_feature/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/horns/tusks,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/belly,
		/datum/body_marking_set/bellysocks,
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

/datum/species/anthromorph/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

/datum/species/anthromorphsmall/after_creation(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/beast)
	to_chat(C, "<span class='info'>I can speak Beastish with ,b before my speech.</span>")

/datum/species/anthromorph/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/beast)

/datum/species/anthromorph/check_roundstart_eligible()
	return TRUE

/datum/species/anthromorph/qualifies_for_rank(rank, list/features)
	return TRUE


