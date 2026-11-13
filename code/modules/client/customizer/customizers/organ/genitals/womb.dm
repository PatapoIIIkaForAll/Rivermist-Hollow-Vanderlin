/datum/customizer/organ/genitals/womb
	name = "Womb"
	customizer_choices = list(/datum/customizer_choice/organ/genitals/womb)

/// Shown and spawned only while the vagina entry is enabled; NPC bodies pass the mob and keep entries on their species.
/datum/customizer/organ/genitals/womb/is_allowed(datum/preferences/prefs)
	if(istype(prefs))
		return prefs.has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/vagina)
	var/datum/species/species = return_species(prefs)
	for(var/datum/customizer_entry/entry as anything in species?.customizer_entries)
		if(istype(entry, /datum/customizer_entry/organ/genitals/vagina))
			return !entry.disabled
	return FALSE

/datum/customizer_choice/organ/genitals/womb
	name = "Womb"
	customizer_entry_type = /datum/customizer_entry/organ/genitals/womb
	organ_type = /obj/item/organ/genitals/filling_organ/womb
	organ_slot = ORGAN_SLOT_WOMB
	organ_dna_type = /datum/organ_dna/womb

/datum/customizer_entry/organ/genitals/womb
	var/fertility = TRUE

/// A womb entry made for an older save inherits the fertility that save kept on its vagina entry.
/datum/customizer_choice/organ/genitals/womb/make_default_customizer_entry(datum/preferences/prefs, customizer_type, changed_entry = TRUE)
	. = ..()
	if(!istype(prefs))
		return
	var/datum/customizer_entry/organ/genitals/womb/womb_entry = .
	var/datum/customizer_entry/organ/genitals/vagina/vagina_entry = prefs.get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/vagina)
	if(vagina_entry)
		womb_entry.fertility = vagina_entry.fertility

/datum/customizer_choice/organ/genitals/womb/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/genitals/womb/womb_entry = entry
	dat += "<br>Fertile: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=fertile'>[womb_entry.fertility ? "Fertile" : "Sterile"]</a>"

/datum/customizer_choice/organ/genitals/womb/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/womb/womb_dna = organ_dna
	var/datum/customizer_entry/organ/genitals/womb/womb_entry = entry
	womb_dna.fertility = womb_entry.fertility

/datum/customizer_choice/organ/genitals/womb/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/genitals/womb/womb_entry = entry
	switch(href_list["customizer_task"])
		if("fertile")
			womb_entry.fertility = !womb_entry.fertility
