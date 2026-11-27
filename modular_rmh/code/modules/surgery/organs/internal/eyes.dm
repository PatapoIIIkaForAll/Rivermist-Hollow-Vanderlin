/obj/item/organ/eyes
	/// Switch for eyes emissive glow
	var/user_glowing_pref = TRUE

/obj/item/organ/eyes/imprint_organ_dna(datum/organ_dna/eyes/eyes_dna)
	..()
	eyes_dna.eye_glowing = glows

/// Flips the glow of glowing eyes. Set from the Toggles window.
/mob/living/carbon/proc/set_eyes_glowing()
	for(var/obj/item/organ/eyes/eyes in internal_organs)
		eyes.user_glowing_pref = !eyes.user_glowing_pref
	update_body_parts(TRUE)
