/datum/organ_dna/penis
	var/penis_size = DEFAULT_PENIS_SIZE
	/// Length in centimetres; zero keeps the legacy size bucket.
	var/length_cm = 0
	var/functional = TRUE
	var/is_ovipositor = FALSE
	var/egg_type = null

/datum/organ_dna/penis/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/penis/penis_organ = organ
	penis_organ.length_cm = length_cm
	penis_organ.organ_size = length_cm > 0 ? get_penis_visual_size(length_cm) : penis_size
	penis_organ.functional = functional

/datum/organ_dna/testicles
	var/ball_size = DEFAULT_TESTICLES_SIZE
	var/virility = TRUE

/datum/organ_dna/testicles/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/filling_organ/testicles/testicles_organ = organ
	testicles_organ.organ_size = ball_size
	testicles_organ.virility = virility

/datum/organ_dna/breasts
	var/breast_size = DEFAULT_BREASTS_SIZE
	var/lactating = FALSE

/datum/organ_dna/breasts/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts_organ = organ
	breasts_organ.organ_size = breast_size
	breasts_organ.produces_fluid = lactating

/datum/organ_dna/vagina

/// Fertility belongs to the womb, which every vagina is paired with.
/datum/organ_dna/womb
	var/fertility = TRUE

/datum/organ_dna/womb/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/filling_organ/womb/womb_organ = organ
	womb_organ.fertility = fertility

/datum/organ_dna/butt
	var/butt_size = DEFAULT_BUTT_SIZE

/datum/organ_dna/butt/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/butt/butt_organ = organ
	butt_organ.organ_size = butt_size

/datum/organ_dna/belly
	var/belly_size = DEFAULT_BELLY_SIZE

/datum/organ_dna/belly/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/belly/belly_organ = organ
	belly_organ.organ_size = belly_size
	belly_organ.resting_size = belly_size
