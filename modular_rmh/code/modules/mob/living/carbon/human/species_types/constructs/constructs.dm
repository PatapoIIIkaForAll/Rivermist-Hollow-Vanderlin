/mob/living/carbon/human/species/construct
	race = /datum/species/automaton/construct

/mob/living/carbon/human/species/doll
	race = /datum/species/automaton/construct/doll

/datum/species/automaton/construct
	name = "Warforged"
	id = SPEC_ID_CONSTRUCT
	desc = "Warforged are artificial people forged from metal, stone, and alchemy, then roused to thought by binding rites or patient craftsmanship. \
	They do not eat, breathe, or sleep, and their bodies can be repaired like finely-made machines. \
	\n\n\
	Instead of sleep they rest in a still Dormancy, where they recover, mend small dents and still dream. \
	Larger damage needs a hammer and material held in the other hand; finer material mends more. Potions do nothing for them. \
	\n\n\
	(+1 STR, +1 CON, +1 END, -2 SPD)."

	skin_tone_wording = "Material"
	default_color = "BABBB9"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY, NOBLOOD, MUTCOLORS)
	use_skintones = TRUE
	possible_ages = ALL_AGES_LIST

	inherent_traits = list(
		TRAIT_NOHUNGER,
		TRAIT_BLOODLOSS_IMMUNE,
		TRAIT_NOBREATH,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOSLEEP,
		TRAIT_NOMETABOLISM,
		TRAIT_NOPAIN,
		TRAIT_LIMBATTACHMENT,
	)

	changesource_flags = WABBAJACK
	order_num = 28
	voice_locked = FALSE
	movespeed_slowdown = 0
	reverie_name = "Dormancy"
	reverie_voice_line = null
	allowed_pronouns = PRONOUNS_LIST
	actions = list()
	no_equip = list()

	limbs_icon_m = 'modular_rmh/icons/mob/species/construct_male.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/species/construct_female.dmi'
	lips_state_m = "construct_male"

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/automaton/construct,
		ORGAN_SLOT_HEART = /obj/item/organ/heart/automaton/construct,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/automaton/construct,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
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
		/datum/customizer/organ/ears/elf,
		/datum/customizer/organ/horns/demihuman,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/breasts/human,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/belly/human,
		/datum/customizer/organ/genitals/butt/human,
	)

	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/construct_plating_light,
		/datum/body_marking_set/construct_plating_medium,
		/datum/body_marking_set/construct_plating_heavy,
	)

	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/tonage,
		/datum/body_marking/construct_plating_light,
		/datum/body_marking/construct_plating_medium,
		/datum/body_marking/construct_plating_heavy,
		/datum/body_marking/construct_head_standard,
		/datum/body_marking/construct_head_round,
		/datum/body_marking/construct_standard_eyes,
		/datum/body_marking/construct_visor_eyes,
		/datum/body_marking/construct_psyclops_eye,
	)

	statsheet_male = /datum/attribute_holder/sheet/job/species/construct/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/construct/stats/female

	enflamed_icon = "widefire"
	native_language = "Common"
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
		OFFSET_BRA = list(0,0),\
	)
	offset_features_f = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,-1),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
		OFFSET_BRA = list(0,0),\
	)


/datum/species/automaton/construct/add_synthetic_components(mob/living/carbon/C)
	C.AddComponent(/datum/component/augmentable)
	C.AddComponent(/datum/component/easy_repair)
	C.AddComponent(/datum/component/damage_shutdown)

/datum/species/automaton/construct/check_roundstart_eligible()
	return TRUE

/datum/species/automaton/construct/get_skin_list()
	var/list/colors = ..()
	var/list/additional_colors = list(
		"Brass" = "DFBD6C",
		"Iron" = "525352",
		"Steel" = "BABBB9",
		"Bronze" = "E2A670",
		"Topaz" = "FFFB9E",
		"Coal" = "1F1F1F",
		"Cobalt" = "323666",
		"Granite" = "FF8F8F",
		"Jade" = "517051",
		"Amethyst" = "3A0B3D",
		"Silver" = "94B9C0",
		"Coral" = "FF96D6",
		"Gold" = "D4AF37",
		"Limestone" = "E6E4D8",
		"Copper" = "B87333",
		"Rust" = "B71F1F",
		"Obsidian" = "19132A",
		"Lapis" = "26619C",
		"Basalt" = "474A4C",
	)
	return additional_colors + colors

/datum/species/automaton/construct/get_random_body_markings(list/passed_features)
	return assemble_body_markings_from_set(GLOB.body_marking_sets_by_type[pick(body_marking_sets)], passed_features, src)

/datum/species/automaton/construct/get_random_features()
	return ..()

/datum/species/automaton/construct/doll
	name = "Doll"
	id = SPEC_ID_DOLL
	desc = "Awakened dolls are porcelain, wood, or lacquered companions shaped in mortal form and granted a will of their own. \
	They are graceful, clever, and light on their feet, but their delicate frames can crack where sturdier constructs would endure. \
	\n\n\
	Like other constructs they rest in Dormancy instead of sleep, and are mended with a hammer and material rather than potions. \
	\n\n\
	(-2 STR, +2 INT, +1 SPD)."

	inherent_traits = list(
		TRAIT_NOHUNGER,
		TRAIT_BLOODLOSS_IMMUNE,
		TRAIT_NOBREATH,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOSLEEP,
		TRAIT_NOMETABOLISM,
		TRAIT_NOPAIN,
		TRAIT_LIMBATTACHMENT,
		TRAIT_BEAUTIFUL,
		TRAIT_EASYDISMEMBER,
	)

	body_marking_sets = list(/datum/body_marking_set/none)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/tonage,
	)

	statsheet_male = /datum/attribute_holder/sheet/job/species/construct/doll/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/construct/doll/stats/female

/datum/species/automaton/construct/doll/get_skin_list()
	var/list/colors = ..()
	var/list/additional_colors = list(
		"Porcelain" = "FFFFFF",
		"Sienna" = "A0522D",
		"Lotus" = "DBCCA9",
		"Scarlet" = "DAA99C",
		"Walnut" = "BA9882",
		"Gloom" = "897489",
		"Ebon" = "4E3729",
	)
	return additional_colors + colors

/datum/species/automaton/construct/doll/get_random_body_markings(list/passed_features)
	return list()

/datum/species/automaton/construct/doll/get_random_features()
	return ..()

/obj/item/organ/brain/automaton/construct
	name = "animus core"
	desc = "A rune-etched core where a living soul has settled into its crafted body."

/obj/item/organ/heart/automaton/construct
	name = "binding engine"
	desc = "A small alchemical engine of runes and quicksilver that keeps a crafted body moving."

/obj/item/organ/eyes/automaton/construct
	name = "crafted eyes"
	desc = "Polished lenses of glass or crystal, set by a patient maker."

/datum/attribute_holder/sheet/job/species/construct/stats/male
	raw_attribute_list = list(STAT_STRENGTH = 1, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = 1, STAT_ENDURANCE = 1, STAT_SPEED = -2, STAT_FORTUNE = 0)


/datum/attribute_holder/sheet/job/species/construct/stats/female
	raw_attribute_list = list(STAT_STRENGTH = 1, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 0, STAT_CONSTITUTION = 1, STAT_ENDURANCE = 1, STAT_SPEED = -2, STAT_FORTUNE = 0)


/datum/attribute_holder/sheet/job/species/construct/doll/stats/male
	raw_attribute_list = list(STAT_STRENGTH = -2, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 2, STAT_CONSTITUTION = 0, STAT_ENDURANCE = 0, STAT_SPEED = 1, STAT_FORTUNE = 0)


/datum/attribute_holder/sheet/job/species/construct/doll/stats/female
	raw_attribute_list = list(STAT_STRENGTH = -2, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = 2, STAT_CONSTITUTION = 0, STAT_ENDURANCE = 0, STAT_SPEED = 1, STAT_FORTUNE = 0)
