/mob/living/carbon/human/species/tabaxi
	race = /datum/species/tabaxi

/datum/species/tabaxi
	name = "Tabaxi"
	id = SPEC_ID_TABAXI

	changesource_flags = WABBAJACK

	desc = "Tabaxi are taller than most humans at six to seven feet. \
	Their bodies are slender and covered in spotted or striped fur. \
	Like most felines, Tabaxi have long tails and retractable claws. \
	Tabaxi fur color ranges from light yellow to brownish red. \
	Tabaxi eyes are slit-pupilled and usually green or yellow. \
	Tabaxi are competent swimmers and climbers as well as speedy runners. \
	They have a good sense of balance and an acute sense of smell."


	skin_tone_wording = "Fur Colors"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,STUBBLE, MUTCOLORS)
	possible_ages = NORMAL_AGES_LIST
	limbs_icon_m = 'modular_rmh/icons/mob/bodies/m/mta.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/bodies/f/fma.dmi'
	allowed_body_builds = HUMANOID_BODY_BUILDS
	default_body_build_m = BODY_BUILD_BROAD
	default_body_build_f = BODY_BUILD_SLIM
	body_build_palette = BODY_PALETTE_GREY
	body_hair_materials = BODY_HAIR_MATERIALS_FURRED

	soundpack_m = /datum/voicepack/male/tabaxi
	soundpack_f = /datum/voicepack/female/tabaxi
	order_num = 35
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
	inherent_traits = list(TRAIT_LIGHT_STEP)

	statsheet_male = /datum/attribute_holder/sheet/job/species/tabaxi/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/tabaxi/stats/female

	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/rakshari,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/cat,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/cat,
		ORGAN_SLOT_SNOUT = /obj/item/organ/snout/cat,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
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
		/datum/customizer/organ/snout/tabaxi,
		/datum/customizer/organ/tail/rakshari,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/animal,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/ears/tajaran,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/bellysocks,
		/datum/body_marking_set/bellysockstertiary,
		/datum/body_marking_set/belly,
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
		/datum/body_marking/belly,
		/datum/body_marking/bellyslim,
		/datum/body_marking/butt,
		/datum/body_marking/tie,
		/datum/body_marking/tiesmall,
		/datum/body_marking/backspots,
		/datum/body_marking/front,
		/datum/body_marking/tonage,
		/datum/body_marking/spotted,
	)
	descriptor_choices = list(
		/datum/descriptor_choice/trait,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/fur,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one,
		/datum/descriptor_choice/prominent_two,
		/datum/descriptor_choice/prominent_three,
		/datum/descriptor_choice/prominent_four,
	)
	COOLDOWN_DECLARE(cat_meow_cooldown)

/datum/species/tabaxi/check_roundstart_eligible()
	return TRUE

/datum/species/tabaxi/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/tabaxi/get_skin_list()
	return list(
		"Orange" = ORANGE_FUR,
		"Light grey" = LIGHTGREY_FUR,
		"Dark grey" = DARKGREY_FUR,
		"Light orange" = LIGHTORANGE_FUR,
		"Light brown" = LIGHTBROWN_FUR,
		"White brown" = WHITEBROWN_FUR,
		"Dark brown" = DARKBROWN_FUR,
		"Black" = BLACK_FUR,
	)

/datum/species/tabaxi/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[/datum/body_marking_set/tiger_dark], passed_features, src)

/datum/species/tabaxi/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/zalad)
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	add_verb(C, /mob/living/carbon/human/species/rakshari/verb/emote_meow)
	add_verb(C, /mob/living/carbon/human/species/rakshari/verb/emote_purr)
	var/datum/action/cooldown/keen_nose/sniff_action = new(C)
	sniff_action.Grant(C)
	to_chat(C, "<span class='info'>I can speak Zakhara with ,z before my speech.</span>")

/datum/species/tabaxi/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	for(var/datum/action/cooldown/keen_nose/sniff_action in C.actions)
		if(sniff_action.target == C)
			qdel(sniff_action)

/datum/species/tabaxi/after_creation(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/zalad)

/datum/species/tabaxi/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(prob(1) && !(H.rogue_sneaking))
		if(!COOLDOWN_FINISHED(src, cat_meow_cooldown))
			return
		var/emote = "meow"
		if(prob(15))
			emote = "purr"
		H.emote(emote, forced = TRUE)

		COOLDOWN_START(src, cat_meow_cooldown, 5 MINUTES)

/datum/attribute_holder/sheet/job/species/tabaxi/stats/male
	raw_attribute_list = list(STAT_STRENGTH = -2, STAT_PERCEPTION = 2, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = -2, STAT_ENDURANCE = 0, STAT_SPEED = 2, STAT_FORTUNE = 0)


/datum/attribute_holder/sheet/job/species/tabaxi/stats/female
	raw_attribute_list = list(STAT_STRENGTH = -2, STAT_PERCEPTION = 2, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = -2, STAT_ENDURANCE = 0, STAT_SPEED = 2, STAT_FORTUNE = 0)
