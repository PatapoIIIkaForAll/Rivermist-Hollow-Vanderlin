/obj/item/organ/genitals/penis
	var/foreskin = TRUE

/obj/item/organ/genitals/penis/proc/can_have_foreskin()
	return penis_type == PENIS_TYPE_PLAIN && sheath_type == SHEATH_TYPE_NONE && !is_false_organ()

/obj/item/organ/genitals/penis/proc/has_foreskin()
	return foreskin && can_have_foreskin()

/obj/item/organ/genitals/penis/proc/get_docking_kind()
	if(is_false_organ())
		return null
	switch(sheath_type)
		if(SHEATH_TYPE_NORMAL)
			return DOCKING_KIND_SHEATH
		if(SHEATH_TYPE_SLIT)
			return DOCKING_KIND_SLIT
	if(has_foreskin())
		return DOCKING_KIND_FORESKIN
	return null

/obj/item/organ/genitals/penis/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/penis/penis_dna = organ_dna
	if(istype(penis_dna))
		penis_dna.foreskin = foreskin

/datum/organ_dna/penis
	var/foreskin = TRUE

/datum/organ_dna/penis/imprint_organ(obj/item/organ/organ, datum/species/species)
	..()
	var/obj/item/organ/genitals/penis/penis_organ = organ
	if(istype(penis_organ))
		penis_organ.foreskin = foreskin

/datum/customizer_entry/organ/genitals/penis
	var/foreskin = TRUE

/datum/customizer_choice/organ/genitals/penis/proc/allows_foreskin()
	var/obj/item/organ/genitals/penis/penis_path = organ_type
	return initial(penis_path.penis_type) == PENIS_TYPE_PLAIN && initial(penis_path.sheath_type) == SHEATH_TYPE_NONE

/datum/customizer_choice/organ/genitals/penis/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/penis/penis_dna = organ_dna
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	if(istype(penis_dna) && istype(penis_entry))
		penis_dna.foreskin = penis_entry.foreskin

/datum/customizer_choice/organ/genitals/penis/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	if(!allows_foreskin() || !istype(penis_entry))
		return
	dat += "<br>Foreskin: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=foreskin'>[penis_entry.foreskin ? "YES" : "NO"]</a>"

/datum/customizer_choice/organ/genitals/penis/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	. = ..()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	if(!allows_foreskin() || !istype(penis_entry))
		return
	. += list(list("task" = "foreskin", "label" = "Foreskin", "kind" = "text", "value" = penis_entry.foreskin ? "Uncut" : "Cut"))

/datum/customizer_choice/organ/genitals/penis/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	if(href_list["customizer_task"] != "foreskin" || !allows_foreskin())
		return
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	if(istype(penis_entry))
		penis_entry.foreskin = !penis_entry.foreskin

/datum/quirk/neutral/extra_genitals_base/copy_penis_entry(datum/customizer_entry/organ/genitals/penis/source, datum/customizer_entry/organ/genitals/penis/target)
	..()
	target.foreskin = source.foreskin
