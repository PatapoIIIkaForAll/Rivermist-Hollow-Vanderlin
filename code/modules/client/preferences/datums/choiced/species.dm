/datum/preference/choiced/species
	savefile_key = "species"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	priority = PREF_PRIORITY_SPECIES

/datum/preference/choiced/species/init_possible_values(datum/preferences/prefs)
	var/list/out = list()
	for (var/id in GLOB.species_list)
		out += GLOB.species_list[id]
	return out

/datum/preference/choiced/species/apply_to_client(client/C, value)
	C.prefs.set_species_preference(value)

/datum/preferences/proc/set_species_preference(species_value)
	var/datum/species/new_species
	if(istype(species_value, /datum/species))
		new_species = species_value
	else if(ispath(species_value, /datum/species))
		new_species = new species_value()
	else
		return FALSE

	if(new_species != pref_species)
		QDEL_NULL(pref_species)
		pref_species = new_species
	return write_preference(/datum/preference/choiced/species, pref_species.id)

/datum/preference/choiced/species/create_default_value(datum/preferences/prefs)
	return /datum/species/human/northern

/datum/preference/choiced/species/serialize(input)
	if (ispath(input))
		var/datum/species/S = new input
		return S.id
	if (istype(input, /datum/species))
		var/datum/species/spec = input
		return spec.id
	return "[input]"

/datum/preference/choiced/species/deserialize(input, datum/preferences/prefs)
	if(input == "slime")
		input = SPEC_ID_OOZE
	var/species_type = GLOB.species_list[input]
	if (!species_type)
		species_type = /datum/species/human/northern
	return species_type

/datum/preference/choiced/species/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.set_species(value, FALSE, prefs)

/datum/preference/choiced/species/handle_link(datum/preferences/prefs, mob/user)
	prefs.write_preference(/datum/preference/choiced/selected_accent, ACCENT_NONE)

	var/list/selectable = list()
	for(var/species_id in GLOB.roundstart_species)
		var/species_type = GLOB.species_list[species_id]

		var/datum/species/species = new species_type()
		if(!species.preference_accessible(prefs))
			continue

		selectable[species.name] = species.type

	var/result = browser_input_list(user, "SELECT YOUR HERO'S PEOPLE:", "VANDERLIN FAUNA", selectable, prefs.pref_species)

	if(result)
		var/datum/species/picked_species = selectable[result]
		prefs.character_setup_apply_species(user, picked_species::id)
