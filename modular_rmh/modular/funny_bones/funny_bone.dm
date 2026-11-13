/// A skeleton's stand-in penis: all bone, no testicles, so nothing is ever released.
/obj/item/organ/genitals/penis/funny_bone
	name = "funny bone"
	desc = "A long, polished bone of dubious purpose. Not quite the humerus, but humorous all the same."
	accessory_type = /datum/sprite_accessory/genitals/penis/human
	accessory_colors = "#E3DAC9#E3DAC9"

/// Flesh genitals do not survive skeletonizing; a male gets a funny bone in their place.
/mob/living/carbon/human/species/skeleton/proc/replace_genitals_with_bones()
	for(var/obj/item/organ/genitals/flesh in internal_organs.Copy())
		if(istype(flesh, /obj/item/organ/genitals/penis/funny_bone))
			continue
		flesh.Remove(src, TRUE)
		qdel(flesh)
	give_genitals()

/// Bones only: a male grows a funny bone, anyone else makes do with their hands.
/mob/living/carbon/human/species/skeleton/give_genitals()
	if(gender != MALE || getorganslot(ORGAN_SLOT_PENIS))
		return
	var/obj/item/organ/genitals/penis/funny_bone/bone = new
	bone.Insert(src, TRUE)

/mob/living/carbon/human/species/skeleton/get_horny_seek_message(mob/living/target)
	if(getorganslot(ORGAN_SLOT_PENIS))
		return "[src] fixes [p_their()] empty sockets on [target], funny bone rattling!"
	return "[src] fixes [p_their()] empty sockets on [target], finger bones twitching eagerly!"

/mob/living/carbon/human/species/skeleton/get_dry_climax_message()
	if(getorganslot(ORGAN_SLOT_PENIS))
		return "[src]'s bones rattle in a clattering climax, but nothing comes of it!"
	return "[src] lets out a long, contented rattle!"
