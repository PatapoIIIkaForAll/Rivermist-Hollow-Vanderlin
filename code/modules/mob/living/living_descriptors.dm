/mob/living/proc/add_mob_descriptor(descriptor_type)
	if(!mob_descriptors)
		mob_descriptors = list()
	if(descriptor_type in mob_descriptors)
		return
	mob_descriptors += descriptor_type

/mob/living/proc/remove_mob_descriptor(descriptor_type)
	if(!mob_descriptors)
		return
	mob_descriptors -= descriptor_type
	if(!length(mob_descriptors))
		mob_descriptors = null

/mob/living/proc/clear_mob_descriptors()
	mob_descriptors = null

/mob/living/proc/get_mob_descriptors(is_obscured, mob/watcher)
	var/list/descriptors = list()
	if(mob_descriptors)
		descriptors += mob_descriptors
	var/list/extras = get_extra_mob_descriptors()
	if(extras)
		descriptors += extras
	var/list/passed_descriptors = list()
	for(var/desc_type in descriptors)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
		if(is_obscured && !descriptor.show_obscured)
			continue
		if(!descriptor.can_describe(src))
			continue
		if(!descriptor.can_user_see(src, watcher))
			continue
		passed_descriptors += desc_type
	return passed_descriptors

/mob/living/proc/get_extra_mob_descriptors()
	return list(
		/datum/mob_descriptor/age,
		/datum/mob_descriptor/penis,
		/datum/mob_descriptor/testicles,
		/datum/mob_descriptor/breasts,
		/datum/mob_descriptor/vagina,
		/datum/mob_descriptor/butt,
		/datum/mob_descriptor/armpit_hair,
		///datum/mob_descriptor/defiant,
		)

/mob/living/proc/get_descriptor_of_slot(descriptor_slot, list/descs)
	for(var/descriptor_type in descs)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(descriptor_type)
		if(descriptor.slot != descriptor_slot)
			continue
		return descriptor_type
	return null

/mob/living/proc/get_descriptor_slot_list(list/slots, list/descriptors)
	var/list/descs = list()
	var/list/desc_copy = descriptors.Copy()
	for(var/slot in slots)
		var/desc_type = get_descriptor_of_slot(slot, desc_copy)
		if(!desc_type)
			continue
		desc_copy -= desc_type
		descs += desc_type
	if(descs.len != slots.len)
		return null
	return descs

/// face_hidden drops the face, age and skin line and keeps what the body and voice show.
/proc/build_cool_description(list/descriptors, mob/living/described, face_hidden = FALSE, mob/watcher)
	var/list/lines = list()
	var/list/desc_copy = descriptors.Copy()
	// Spots and wordings already used by the marks that follow the genital lines.
	var/list/marks_used = list()

	if(face_hidden)
		lines += build_coalesce_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_HEIGHT, MOB_DESCRIPTOR_SLOT_BODY, MOB_DESCRIPTOR_SLOT_STATURE), "You see %DESC1%, %DESC2% %DESC3%.", watcher)
		lines += build_coalesce_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_VOICE), "%THEY% %DESC1%.", watcher)
	else
		lines += build_coalesce_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_HEIGHT, MOB_DESCRIPTOR_SLOT_BODY, MOB_DESCRIPTOR_SLOT_STATURE, MOB_DESCRIPTOR_SLOT_FACE_SHAPE, MOB_DESCRIPTOR_SLOT_FACE_EXPRESSION), "You see %DESC1%, %DESC2% %DESC3% with %DESC4%, %DESC5%.", watcher)
		lines += build_coalesce_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_AGE, MOB_DESCRIPTOR_SLOT_SKIN, MOB_DESCRIPTOR_SLOT_VOICE), "%THEY% %DESC1%, %DESC2% and %DESC3%.", watcher)

	lines += build_coalesce_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_TRAIT), "%THEY% %DESC1%.", watcher)
	lines += build_joined_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_PROMINENT, MOB_DESCRIPTOR_SLOT_PROMINENT), watcher)
	lines += build_joined_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_PROMINENT, MOB_DESCRIPTOR_SLOT_PROMINENT), watcher)
	lines += build_coalesce_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_ARMPITS), "%THEY% %DESC1%.", watcher)
	lines += build_marked_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_PENIS, MOB_DESCRIPTOR_SLOT_TESTICLES), watcher, marks_used)
	lines += build_marked_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_BREASTS), watcher, marks_used)
	lines += build_marked_description(desc_copy, described, list(MOB_DESCRIPTOR_SLOT_VAGINA, MOB_DESCRIPTOR_SLOT_BUTT), watcher, marks_used)

	/// Print the remaining ones in seperate lines
	for(var/descriptor_type in desc_copy)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(descriptor_type)
		lines += treat_mob_descriptor_string("[descriptor.get_standalone_text(described, watcher)].", described)

	list_clear_nulls(lines)
	return lines

/// One "%THEY% a, b and c." sentence from whichever of the slots are present.
/proc/build_joined_description(list/descriptors, mob/living/described, list/slots, mob/watcher)
	var/list/parts = list()
	var/list/used_verbage = list()
	for(var/slot in slots)
		var/desc_type = described.get_descriptor_of_slot(slot, descriptors)
		if(!desc_type)
			continue
		descriptors -= desc_type
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
		parts += descriptor.get_coalesce_text(described, used_verbage, watcher)
		var/used_verb = descriptor.get_verbage(described)
		if(used_verb)
			used_verbage |= used_verb
	if(!length(parts))
		return
	return treat_mob_descriptor_string("%THEY% [english_list(parts)].", described)

/// A joined description followed by what the body carries on those parts, such as lipstick marks.
/proc/build_marked_description(list/descriptors, mob/living/described, list/slots, mob/watcher, list/marks_used)
	var/list/before = descriptors.Copy()
	. = build_joined_description(descriptors, described, slots, watcher)
	if(!.)
		return
	var/marks = described.get_descriptor_marks(before - descriptors, watcher, marks_used)
	if(marks)
		. = "[.] [marks]"

/proc/build_coalesce_description(list/descriptors, mob/living/described, list/slots, string, mob/watcher)
	var/list/descs = described.get_descriptor_slot_list(slots, descriptors)
	if(!descs)
		return
	var/list/used_verbage = list()
	descriptors -= descs
	for(var/i in 1 to descs.len)
		var/desc_type = descs[i]
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
		string = replacetext(string, "%DESC[i]%", descriptor.get_coalesce_text(described, used_verbage, watcher))
		var/used_verb = descriptor.get_verbage(described)
		if(used_verb)
			used_verbage |= used_verb
	string = treat_mob_descriptor_string(string, described)
	return string

/proc/treat_mob_descriptor_string(string, mob/living/described)
	var/they_replace
	if(described.gender == MALE)
		they_replace = "he"
	else
		they_replace = "she"
	var/man_replace
	if(described.gender == MALE)
		man_replace = "man"
	else
		man_replace = "woman"
	var/him_replace
	if(described.gender == MALE)
		him_replace = "him"
	else
		him_replace = "her"
	if (described.pronouns)
		switch (described.pronouns)
			if (HE_HIM)
				they_replace = "he"
				man_replace = "man"
				him_replace = "him"
			if (SHE_HER)
				they_replace = "she"
				man_replace = "woman"
				him_replace = "her"
			if (THEY_THEM)
				they_replace = "they"
				man_replace = "person"
				him_replace = "them"
			if (IT_ITS)
				they_replace = "it"
				man_replace = "thing"
				him_replace = "it"
	// Verb tokens follow the pronoun, so they/them reads "they have", not "they has".
	var/plural = they_replace == "they"
	string = replacetext(string, "%THEY%", they_replace)
	string = replacetext(string, "%HAVE%", plural ? "have" : "has")
	string = replacetext(string, "%ARE%", plural ? "are" : "is")
	string = replacetext(string, "%LOOK%", plural ? "look" : "looks")
	string = replacetext(string, "%SPEAK%", plural ? "speak with" : "speaks with")
	string = replacetext(string, "%APPEAR%", plural ? "appear" : "appears")
	string = replacetext(string, "%MOVE%", plural ? "move" : "moves")
	string = replacetext(string, "%MAN%", man_replace)
	string = replacetext(string, "%HIM%", him_replace)
	string = capitalize(string)
	return string
