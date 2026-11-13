/mob/living/carbon/human/species/demon
	race = /datum/species/demon

/obj/item/organ/horns/demon
	name = "demon horns"
	accessory_type = /datum/sprite_accessory/horns/longhorns

/obj/item/organ/wings/flight/demon
	name = "demon wings"
	accessory_type = /datum/sprite_accessory/wings/wide/succubus
	flight_for_species = list(SPEC_ID_DEMON)
	flight_time = 30 SECONDS

/// The Succubus's natural body. This species is assigned by antagonist code, never selected in preferences.
/datum/species/demon
	parent_type = /datum/species/tieberian
	name = "Demon"
	id = SPEC_ID_DEMON
	desc = "A fiend in natural flesh, bearing long horns, a barbed tail, and powerful wings."

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
		ORGAN_SLOT_HORNS = /obj/item/organ/horns/demon,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/tiefling,
		ORGAN_SLOT_WINGS = /obj/item/organ/wings/flight/demon
	)

	// The infernal anatomy above is fixed. Personal details can still come from the selected character.
	customizers = list(
		/datum/customizer/organ/ears/tiefling,
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
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
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair
	)

/datum/species/demon/check_roundstart_eligible()
	return FALSE

/datum/species/demon/on_species_gain(mob/living/carbon/carbon, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	var/datum/component/bad_luck = carbon.GetComponent(/datum/component/malaguero)
	bad_luck?.RemoveComponent()

	var/mob/living/carbon/human/human = carbon
	if(!istype(human))
		return

	var/list/demon_skin_tones = get_skin_list()
	human.skin_tone = pick_assoc(demon_skin_tones)
	human.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

	var/static/list/fixed_demon_accessories = list(
		ORGAN_SLOT_HORNS = /datum/sprite_accessory/horns/longhorns,
		ORGAN_SLOT_TAIL = /datum/sprite_accessory/tail/tiefling,
		ORGAN_SLOT_WINGS = /datum/sprite_accessory/wings/wide/succubus,
	)
	for(var/accessory_slot in fixed_demon_accessories)
		var/obj/item/organ/fixed_organ = human.getorganslot(accessory_slot)
		if(!fixed_organ)
			continue
		fixed_organ.set_accessory_type(fixed_demon_accessories[accessory_slot])

	human.update_organ_colors()
	for(var/dna_slot in fixed_demon_accessories)
		var/obj/item/organ/dna_organ = human.getorganslot(dna_slot)
		if(dna_organ)
			human.dna.organ_dna[dna_slot] = dna_organ.create_organ_dna()
