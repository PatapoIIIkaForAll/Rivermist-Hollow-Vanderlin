/datum/customizer/organ/genitals/penis
	abstract_type = /datum/customizer/organ/genitals/penis
	name = "Penis"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = MALE

/datum/customizer/organ/genitals/penis/is_allowed(datum/preferences/prefs)
	return TRUE

/datum/customizer_choice/organ/genitals/penis
	name = "Penis"
	organ_type = /obj/item/organ/genitals/penis
	organ_slot = ORGAN_SLOT_PENIS
	customizer_entry_type = /datum/customizer_entry/organ/genitals/penis
	organ_dna_type = /datum/organ_dna/penis

/datum/customizer_choice/organ/genitals/penis/make_default_customizer_entry(datum/preferences/prefs, customizer_type, changed_entry = TRUE)
	. = ..()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = .
	if(istype(prefs))
		penis_entry.penis_length_cm = prefs.get_default_penis_length()
	else
		// NPC bodies pass the mob in place of preferences.
		var/datum/species/species = return_species(prefs)
		penis_entry.penis_length_cm = species ? species.default_penis_length : PENIS_LENGTH_DEFAULT
	penis_entry.penis_size = get_penis_visual_size(penis_entry.penis_length_cm)

/datum/customizer_choice/organ/genitals/penis/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	// Unset lengths and saves from before lengths existed take the length of their size bucket.
	if(!isnum(penis_entry.penis_length_cm) || penis_entry.penis_length_cm < PENIS_LENGTH_MIN)
		penis_entry.penis_length_cm = get_penis_length_for_size(penis_entry.penis_size)
	// Short lengths were migrated above, so anything still out of range is past the cap.
	penis_entry.penis_length_cm = sanitize_integer(penis_entry.penis_length_cm, PENIS_LENGTH_MIN, PENIS_LENGTH_MAX, PENIS_LENGTH_MAX)
	penis_entry.penis_size = get_penis_visual_size(penis_entry.penis_length_cm)

/datum/customizer_choice/organ/genitals/penis/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/penis/penis_dna = organ_dna
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	penis_dna.penis_size = penis_entry.penis_size
	penis_dna.length_cm = penis_entry.penis_length_cm
	penis_dna.functional = penis_entry.functional

/datum/customizer_choice/organ/genitals/penis/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	dat += "<br>Penis length: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=penis_length_cm'>[penis_entry.penis_length_cm] cm</a> ([find_key_by_value(PENIS_SIZES_BY_NAME, get_penis_visual_size(penis_entry.penis_length_cm))])"
	dat += "<br>Functional: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=functional''>[penis_entry.functional ? "YES" : "NO"]</a>"

/datum/customizer_choice/organ/genitals/penis/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	switch(href_list["customizer_task"])
		if("penis_length_cm")
			var/new_length
			// The menu sends a value; plain links prompt for one.
			if(isnull(href_list["value"]))
				new_length = input(user, "Choose your penis length in centimetres, [PENIS_LENGTH_MIN] to [PENIS_LENGTH_MAX]:", "Character Preference", penis_entry.penis_length_cm) as num|null
			else
				new_length = text2num("[href_list["value"]]")
			if(!isnum(new_length))
				return
			penis_entry.penis_length_cm = clamp(round(new_length, 1), PENIS_LENGTH_MIN, PENIS_LENGTH_MAX)
			penis_entry.penis_size = get_penis_visual_size(penis_entry.penis_length_cm)
		if("penis_size")
			var/named_size = browser_input_list(user, "Choose your penis size:", "Character Preference", PENIS_SIZES_BY_NAME, penis_entry.penis_size)
			if(isnull(named_size))
				return
			var/new_size = sanitize_integer(PENIS_SIZES_BY_NAME[named_size], MIN_PENIS_SIZE, MAX_PENIS_SIZE, DEFAULT_PENIS_SIZE)
			penis_entry.penis_length_cm = get_penis_length_for_size(new_size)
			penis_entry.penis_size = get_penis_visual_size(penis_entry.penis_length_cm)
		if("functional")
			penis_entry.functional = !penis_entry.functional

/datum/customizer_entry/organ/genitals/penis
	/// Visual size bucket, derived from the length.
	var/penis_size = DEFAULT_PENIS_SIZE
	/// Length in centimetres; zero means unset or saved before lengths existed.
	var/penis_length_cm = 0
	var/functional = TRUE

/datum/customizer/organ/genitals/penis/human
	customizer_choices = list(/datum/customizer_choice/organ/genitals/penis/human)

/datum/customizer/organ/genitals/penis/anthro
	customizer_choices = list(
		/datum/customizer_choice/organ/genitals/penis/human_anthro,
		/datum/customizer_choice/organ/genitals/penis/knotted,
		/datum/customizer_choice/organ/genitals/penis/equine,
		/datum/customizer_choice/organ/genitals/penis/tapered_mammal,
		/datum/customizer_choice/organ/genitals/penis/tapered,
		/datum/customizer_choice/organ/genitals/penis/tapered_double,
		/datum/customizer_choice/organ/genitals/penis/tapered_double_knot,
		/datum/customizer_choice/organ/genitals/penis/barbed,
		/datum/customizer_choice/organ/genitals/penis/barbed_knotted,
		/datum/customizer_choice/organ/genitals/penis/tentacle,
		/datum/customizer_choice/organ/genitals/penis/ovipositor,
		)

/datum/customizer/organ/genitals/penis/canine
	customizer_choices = list(
		/datum/customizer_choice/organ/genitals/penis/human_anthro,
		/datum/customizer_choice/organ/genitals/penis/knotted,
		)

/datum/customizer/organ/genitals/penis/feline
	customizer_choices = list(
		/datum/customizer_choice/organ/genitals/penis/human_anthro,
		/datum/customizer_choice/organ/genitals/penis/barbed,
		/datum/customizer_choice/organ/genitals/penis/barbed_knotted,
		)

/datum/customizer/organ/genitals/penis/lizard
	customizer_choices = list(
		/datum/customizer_choice/organ/genitals/penis/human_anthro,
		/datum/customizer_choice/organ/genitals/penis/tapered,
		/datum/customizer_choice/organ/genitals/penis/tapered_double,
		/datum/customizer_choice/organ/genitals/penis/tapered_double_knot,
		)

/datum/customizer/organ/genitals/penis/equine
	customizer_choices = list(
		/datum/customizer_choice/organ/genitals/penis/human_anthro,
		/datum/customizer_choice/organ/genitals/penis/equine,
		)

/datum/customizer_choice/organ/genitals/penis/human
	name = "Plain Penis"
	organ_type = /obj/item/organ/genitals/penis
	sprite_accessories = list(/datum/sprite_accessory/genitals/penis/human)
	allows_accessory_color_customization = FALSE

/datum/customizer_choice/organ/genitals/penis/human_anthro
	name = "Plain Penis"
	organ_type = /obj/item/organ/genitals/penis
	sprite_accessories = list(/datum/sprite_accessory/genitals/penis/human)
	allows_accessory_color_customization = TRUE

/datum/customizer_choice/organ/genitals/penis/knotted
	name = "Knotted Penis"
	organ_type = /obj/item/organ/genitals/penis/knotted
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/knotted,
		/datum/sprite_accessory/genitals/penis/knotted2,
		)

/datum/customizer_choice/organ/genitals/penis/equine
	name = "Equine Penis"
	organ_type = /obj/item/organ/genitals/penis/equine
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/flared,
		)

/datum/customizer_choice/organ/genitals/penis/tapered_mammal
	name = "Tapered Penis (Mammal)"
	organ_type = /obj/item/organ/genitals/penis/tapered_mammal
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/tapered_mammal,
		)

/datum/customizer_choice/organ/genitals/penis/tapered
	name = "Tapered Penis"
	organ_type = /obj/item/organ/genitals/penis/tapered
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/tapered,
		)

/datum/customizer_choice/organ/genitals/penis/tapered_double
	name = "Hemi Tapered Penis"
	organ_type = /obj/item/organ/genitals/penis/tapered
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/hemi,
		)

/datum/customizer_choice/organ/genitals/penis/tapered_double_knot
	name = "Knotted Hemi Tapered Penis"
	organ_type = /obj/item/organ/genitals/penis/tapered
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/hemiknot,
		)

/datum/customizer_choice/organ/genitals/penis/barbed
	name = "Barbed Penis"
	organ_type = /obj/item/organ/genitals/penis/barbed
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/barbknot,
		)

/datum/customizer_choice/organ/genitals/penis/barbed_knotted
	name = "Barbed Knotted Penis"
	organ_type = /obj/item/organ/genitals/penis/barbed_knotted
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/barbknot,
		)

/datum/customizer_choice/organ/genitals/penis/tentacle
	name = "Tentacle Penis"
	organ_type = /obj/item/organ/genitals/penis/tentacle
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/penis/tentacle,
		)
