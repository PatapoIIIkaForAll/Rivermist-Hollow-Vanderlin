/mob/living/carbon/human/species/ooze
	race = /datum/species/ooze
	footstep_type = FOOTSTEP_MOB_SLIME

/datum/species/ooze
	name = "Ooze"
	id = SPEC_ID_OOZE
	desc = "Oozes arise where the land consumes the dead and remembers them. Some take a humanoid form and carry fragments of a former life. Their mutable bodies have no blood or bones, and lost limbs can grow back while they sleep. (+2 CON, -1 INT)"
	default_color = "79F299"
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY, MUTCOLORS, NOBLOOD)
	use_skintones = FALSE
	possible_ages = ALL_AGES_LIST
	liked_food = NONE
	disliked_food = NONE
	changesource_flags = WABBAJACK
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mt.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
	allowed_body_builds = HUMANOID_BODY_BUILDS
	default_body_build_m = BODY_BUILD_BROAD
	default_body_build_f = BODY_BUILD_SLIM
	body_hair_materials = BODY_HAIR_MATERIALS_ANY
	dam_icon_m = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female
	enflamed_icon = "widefire"
	order_num = 38
	native_language = "Common"
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_BLOODLOSS_IMMUNE,
		TRAIT_NORMALIZED_BLOOD,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_EASYDISMEMBER,
		TRAIT_NASTY_EATER,
	)
	allowed_taur_types = list(
		/obj/item/bodypart/taur/lamia,
		/obj/item/bodypart/taur/spider,
		/obj/item/bodypart/taur/horse,
		/obj/item/bodypart/taur/tentacle,
		/obj/item/bodypart/taur/feline,
		/obj/item/bodypart/taur/drake,
		/obj/item/bodypart/taur/otie,
		/obj/item/bodypart/taur/deer,
		/obj/item/bodypart/taur/wasp,
		/obj/item/bodypart/taur/mermaid,
	)
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/ooze,
		ORGAN_SLOT_HEART = /obj/item/organ/heart/ooze,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/ooze,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/ooze,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/ooze,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/ooze,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)
	bodypart_features = list(/datum/bodypart_feature/hair/head, /datum/bodypart_feature/hair/facial)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
		/datum/customizer/organ/tail/anthro,
		/datum/customizer/organ/tail_feature/anthro,
		/datum/customizer/organ/snout/anthro,
		/datum/customizer/organ/ears/anthro,
		/datum/customizer/organ/horns/anthro,
		/datum/customizer/organ/frills/anthro,
		/datum/customizer/organ/wings/anthro,
		/datum/customizer/organ/neck_feature/anthro,
	)
	body_marking_sets = list(/datum/body_marking_set/none, /datum/body_marking_set/belly, /datum/body_marking_set/bellysocks, /datum/body_marking_set/tiger, /datum/body_marking_set/tiger_dark)
	body_markings = list(
		/datum/body_marking/eyeliner, /datum/body_marking/tonage,
		/datum/body_marking/flushed_cheeks, /datum/body_marking/plain, /datum/body_marking/tiger,
		/datum/body_marking/tiger/dark, /datum/body_marking/sock, /datum/body_marking/socklonger,
		/datum/body_marking/tips, /datum/body_marking/bellyscale, /datum/body_marking/bellyscaleslim,
		/datum/body_marking/bellyscalesmooth, /datum/body_marking/bellyscaleslimsmooth,
		/datum/body_marking/buttscale, /datum/body_marking/belly, /datum/body_marking/bellyslim,
		/datum/body_marking/butt, /datum/body_marking/tie, /datum/body_marking/tiesmall,
		/datum/body_marking/backspots, /datum/body_marking/front, /datum/body_marking/drake_eyes,
		/datum/body_marking/spotted,
	)
	statsheet_male = /datum/attribute_holder/sheet/job/species/ooze/stats/male
	statsheet_female = /datum/attribute_holder/sheet/job/species/ooze/stats/female

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

/datum/species/ooze/check_roundstart_eligible()
	return TRUE

/datum/species/ooze/on_species_gain(mob/living/carbon/carbon_mob, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	if(!ishuman(carbon_mob))
		return
	var/mob/living/carbon/human/human = carbon_mob
	human.grant_language(/datum/language/common)
	human.add_spell(/datum/action/cooldown/spell/undirected/shapeshift/ooze)
	human.add_spell(/datum/action/cooldown/spell/undirected/ooze_reshape)
	RegisterSignal(human, COMSIG_LIVING_DEATH, PROC_REF(on_ooze_death))

/datum/species/ooze/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	UnregisterSignal(human, COMSIG_LIVING_DEATH)
	QDEL_NULL(human.active_ooze_editor)
	human.remove_spell(/datum/action/cooldown/spell/undirected/shapeshift/ooze)
	human.remove_spell(/datum/action/cooldown/spell/undirected/ooze_reshape)
	return ..()

/datum/species/ooze/spec_life(mob/living/carbon/human/human)
	. = ..()
	if(human.stat == DEAD || !human.IsSleeping() || human.nutrition < 250)
		return
	for(var/zone in list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		if(human.get_bodypart(zone))
			continue
		if(human.regenerate_limb(zone, FALSE))
			human.adjust_nutrition(-150)
		break

/datum/species/ooze/proc/on_ooze_death(mob/living/carbon/human/source, gibbed)
	SIGNAL_HANDLER
	if(gibbed || !source?.mind || source.defeat_final_death || source.defeat_mode == DEFEAT_MODE_NO_RETURN)
		return
	var/mob/living/simple_animal/hostile/retaliate/ooze_blob/suffering/blob = new(get_turf(source))
	blob.link_body(source)
	blob.color = "#[source.dna.features["mcolor"] || "79F299"]"
	source.mind.transfer_to(blob, TRUE)
	to_chat(blob, span_warning("My body has collapsed. I must be revived to regain it."))

/datum/attribute_holder/sheet/job/species/ooze/stats/male
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = -1, STAT_CONSTITUTION = 2, STAT_ENDURANCE = 0, STAT_SPEED = 0, STAT_FORTUNE = 0)

/datum/attribute_holder/sheet/job/species/ooze/stats/female
	raw_attribute_list = list(STAT_STRENGTH = 0, STAT_PERCEPTION = 0, STAT_INTELLIGENCE = -1, STAT_CONSTITUTION = 2, STAT_ENDURANCE = 0, STAT_SPEED = 0, STAT_FORTUNE = 0)

// Organ sprites by VelSlime, ported from Ratwood/Ochre Valley.
/obj/item/organ/brain/ooze
	name = "ooze neural core"
	icon = 'modular_rmh/icons/obj/ooze_organs.dmi'
	decoy_override = TRUE

/obj/item/organ/heart/ooze
	name = "ooze fluid pump"
	icon = 'modular_rmh/icons/obj/ooze_organs.dmi'

/obj/item/organ/eyes/ooze
	name = "ooze ocular sensors"
	icon = 'modular_rmh/icons/obj/ooze_organs.dmi'

/obj/item/organ/tongue/ooze
	name = "ooze taste buds"
	icon = 'modular_rmh/icons/obj/ooze_organs.dmi'

/obj/item/organ/liver/ooze
	name = "ooze detoxification organelle"
	icon = 'modular_rmh/icons/obj/ooze_organs.dmi'

/obj/item/organ/stomach/ooze
	name = "ooze digestive chamber"
	icon = 'modular_rmh/icons/obj/ooze_organs.dmi'
