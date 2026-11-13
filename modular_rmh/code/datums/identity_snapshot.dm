// Genital organs carry character-identity settings outside the common visible-organ
// fields. Give them matching DNA datums and teach live-organ capture about those
// settings so identity snapshots can round-trip a preference-built body exactly.
/obj/item/organ/genitals/penis
	organ_dna_type = /datum/organ_dna/penis

/obj/item/organ/genitals/penis/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/penis/penis_dna = organ_dna
	penis_dna.penis_size = organ_size
	penis_dna.length_cm = length_cm
	penis_dna.functional = functional

/obj/item/organ/genitals/filling_organ/testicles
	organ_dna_type = /datum/organ_dna/testicles

/obj/item/organ/genitals/filling_organ/testicles/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/testicles/testicles_dna = organ_dna
	testicles_dna.ball_size = organ_size
	testicles_dna.virility = virility

/obj/item/organ/genitals/filling_organ/breasts
	organ_dna_type = /datum/organ_dna/breasts

/obj/item/organ/genitals/filling_organ/breasts/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/breasts/breasts_dna = organ_dna
	breasts_dna.breast_size = organ_size
	breasts_dna.lactating = produces_fluid

/obj/item/organ/genitals/filling_organ/vagina
	organ_dna_type = /datum/organ_dna/vagina

/obj/item/organ/genitals/filling_organ/womb
	organ_dna_type = /datum/organ_dna/womb

/obj/item/organ/genitals/filling_organ/womb/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/womb/womb_dna = organ_dna
	womb_dna.fertility = fertility

/obj/item/organ/genitals/butt
	organ_dna_type = /datum/organ_dna/butt

/obj/item/organ/genitals/butt/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/butt/butt_dna = organ_dna
	butt_dna.butt_size = organ_size

/obj/item/organ/genitals/belly
	organ_dna_type = /datum/organ_dna/belly

/obj/item/organ/genitals/belly/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/belly/belly_dna = organ_dna
	belly_dna.belly_size = resting_size

/**
 * A portable copy of a human's visible identity. Capture from a live human, apply to any
 * human, keep as long as needed — holds no references to the source mob. Powers
 * changeling-style disguises; apply() works on any populated snapshot, captured or hand-built.
 */
/datum/identity_snapshot
	/// Deep copy of the source's DNA — never a live reference
	var/datum/dna/dna
	var/real_name
	var/gender
	var/pronouns
	var/age
	/// A mob var, not DNA-encoded, so it must be carried explicitly
	var/skin_tone
	var/voice_type
	var/voice_color
	var/honorary
	var/honorary_suffix
	/// Sprite accessory typepaths, as used by set_hair_style()/set_facial_hair_style()
	var/hair_style_type
	var/facial_hair_style_type
	var/hair_color
	var/facial_hair_color
	var/eye_color_right
	var/eye_color_left

/datum/identity_snapshot/Destroy()
	QDEL_NULL(dna)
	return ..()

/// Rebuilds one DNA datum from a body's live organs without sharing organ-DNA references.
/datum/identity_snapshot/proc/capture_organ_dna(mob/living/carbon/human/source, datum/dna/target_dna)
	target_dna.organ_dna = list()
	for(var/obj/item/organ/organ as anything in source.internal_organs)
		if(!organ.slot)
			continue
		var/datum/organ_dna/stored_organ_dna = target_dna.organ_dna[organ.slot]
		if(stored_organ_dna)
			organ.imprint_organ_dna(stored_organ_dna)
		else
			target_dna.organ_dna[organ.slot] = organ.create_organ_dna()

/// Fills this snapshot from a live human. Returns src for chaining.
/datum/identity_snapshot/proc/capture(mob/living/carbon/human/source)
	if(!istype(source) || !source.dna)
		return
	QDEL_NULL(dna)
	dna = new
	source.dna.copy_dna(dna)
	capture_organ_dna(source, dna)
	real_name = source.real_name
	gender = source.gender
	pronouns = source.pronouns
	age = source.age
	skin_tone = source.skin_tone
	voice_type = source.voice_type
	voice_color = source.voice_color
	honorary = source.honorary
	honorary_suffix = source.honorary_suffix
	var/datum/bodypart_feature/hair/head_feature = source.get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	var/datum/bodypart_feature/hair/facial_feature = source.get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	hair_style_type = head_feature?.accessory_type
	facial_hair_style_type = facial_feature?.accessory_type
	hair_color = source.get_hair_color()
	facial_hair_color = source.get_facial_hair_color()
	eye_color_right = source.get_eye_color(RIGHT_SIDE)
	eye_color_left = source.get_eye_color(LEFT_SIDE)
	return src

/// Applies this snapshot to a live human's current body. Returns TRUE on success.
/datum/identity_snapshot/proc/apply(mob/living/carbon/human/target)
	if(!istype(target) || !target.dna || !dna)
		return FALSE
	dna.transfer_identity(target)
	// set_species() randomizes clientless humans in this fork. Rebuild from the
	// captured live-organ DNA after the species swap, then detach the target's
	// DNA from the snapshot's owned list.
	target.dna.organ_dna = dna.organ_dna
	target.dna.species.regenerate_organs(target, target.dna.species)
	apply_markings_to_body_parts(target.dna.body_markings, target)
	capture_organ_dna(target, target.dna)
	target.real_name = real_name
	target.age = age
	target.pronouns = pronouns
	target.skin_tone = skin_tone
	target.voice_type = voice_type
	target.voice_color = voice_color
	target.honorary = honorary
	target.honorary_suffix = honorary_suffix
	target.set_hair_color(hair_color, FALSE)
	target.set_hair_style(hair_style_type, FALSE)
	target.set_facial_hair_color(facial_hair_color, FALSE)
	target.set_facial_hair_style(facial_hair_style_type, FALSE)
	target.set_eye_color(eye_color_right, eye_color_left, FALSE)
	// Organ sprites cache their colors from skin tone at build time; rebuild after the swap
	target.update_organ_colors()
	// updateappearance() re-derives gender from the DNA block, so gender is (re)applied AFTER it
	target.updateappearance(mutcolor_update = TRUE)
	target.update_body_parts(TRUE)
	target.gender = gender
	target.name = target.get_visible_name()
	return TRUE
