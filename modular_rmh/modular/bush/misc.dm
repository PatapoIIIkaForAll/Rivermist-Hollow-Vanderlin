/datum/customizer_entry/body_hair
	var/growth_enabled = FALSE

/datum/customizer_entry/pubic_hair
	var/growth_enabled = FALSE
	var/grooming_state = HAIR_GROOMING_NATURAL
	var/style
	var/material

/datum/customizer_entry/armpit_hair
	var/growth_enabled = FALSE
	var/material

/proc/body_hair_growth_link(customizer_type, growth_enabled)
	return "<br>Regrowth: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=toggle_body_hair_growth'>[growth_enabled ? "Enabled" : "Disabled"]</a>"

/proc/body_hair_material_link(customizer_type, material)
	return "<br>Material: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=body_hair_material'>[capitalize(material)]</a>"

/proc/pick_body_hair_material(mob/user, current_material, list/allowed_materials)
	var/list/choices = list()
	for(var/material_name in GLOB.body_hair_materials)
		if(GLOB.body_hair_materials[material_name] in allowed_materials)
			choices[material_name] = GLOB.body_hair_materials[material_name]
	var/chosen_input = browser_input_list(user, "Choose what grows there:", "Character Preference", choices, find_key_by_value(choices, current_material))
	if(!chosen_input)
		return null
	return choices[chosen_input]

/proc/get_species_body_hair_materials(datum/customizer_choice/choice, datum/preferences/prefs)
	var/datum/species/species = choice.return_species(prefs)
	return length(species?.body_hair_materials) ? species.body_hair_materials : BODY_HAIR_MATERIALS_HUMANOID

/proc/body_hair_growth_extra(growth_enabled)
	return list("task" = "toggle_body_hair_growth", "label" = "Regrowth", "kind" = "text", "value" = growth_enabled ? "On" : "Off")

/proc/body_hair_material_extra(material)
	return list("task" = "body_hair_material", "label" = "Material", "kind" = "text", "value" = capitalize(material))

/// Pubic shape name for menus, flagged when the chosen length is too short to hold it.
/proc/pubic_hair_shape_label(datum/customizer_entry/pubic_hair/entry)
	var/style_name = find_key_by_value(GLOB.pubic_hair_styles, entry.style)
	if(!style_name)
		return "None"
	var/datum/sprite_accessory/body_hair/level_accessory = SPRITE_ACCESSORY(entry.accessory_type)
	if(level_accessory?.hairiness_level < HAIRINESS_SOME_HAIR)
		return "[style_name] (needs some hair)"
	return style_name

/datum/customizer/bodypart_feature/body_hair
	name = "Body Hair"
	customizer_choices = list(/datum/customizer_choice/bodypart_feature/body_hair)
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = MALE

/// Starts disabled for every sex, so species given chest hair later keep existing characters unchanged.
/datum/customizer/bodypart_feature/body_hair/optional
	gender_enabled = null

/datum/customizer_choice/bodypart_feature/body_hair
	name = "Body Hair"
	feature_type = /datum/bodypart_feature/hair/body_hair
	customizer_entry_type = /datum/customizer_entry/body_hair
	sprite_accessories = list(
		/datum/sprite_accessory/body_hair/body/some_hair,
		/datum/sprite_accessory/body_hair/body/hairy,
		/datum/sprite_accessory/body_hair/body/very_hairy,
	)

/datum/customizer_choice/bodypart_feature/body_hair/make_default_customizer_entry(datum/preferences/prefs, customizer_type, changed_entry = TRUE)
	. = ..()
	var/datum/species/species = return_species(prefs)
	if(species?.hairyness)
		set_accessory_type(prefs, body_hair_species_default_accessory(species), .)

/datum/customizer_choice/bodypart_feature/body_hair/customize_feature(datum/bodypart_feature/feature, mob/living/carbon/human/human, datum/preferences/prefs, datum/customizer_entry/body_hair/entry)
	var/datum/bodypart_feature/hair/body_hair/body_hair_feature = feature
	body_hair_feature.growth_enabled = entry.growth_enabled

/datum/customizer_choice/bodypart_feature/body_hair/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/body_hair/body_hair_entry = entry
	dat += body_hair_growth_link(customizer_type, body_hair_entry.growth_enabled)

/datum/customizer_choice/bodypart_feature/body_hair/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/body_hair/body_hair_entry = entry
	return list(body_hair_growth_extra(body_hair_entry.growth_enabled))

/datum/customizer_choice/bodypart_feature/body_hair/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/body_hair/body_hair_entry = entry
	if(href_list["customizer_task"] == "toggle_body_hair_growth")
		body_hair_entry.growth_enabled = !body_hair_entry.growth_enabled

/datum/customizer_choice/bodypart_feature/body_hair/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/body_hair/body_hair_entry = entry
	body_hair_entry.growth_enabled = body_hair_entry.growth_enabled ? TRUE : FALSE

/datum/customizer/bodypart_feature/pubic_hair
	name = "Pubic Hair"
	customizer_choices = list(/datum/customizer_choice/bodypart_feature/pubic_hair)

/datum/customizer_choice/bodypart_feature/pubic_hair
	name = "Pubic Hair"
	feature_type = /datum/bodypart_feature/hair/body_hair/pubic
	customizer_entry_type = /datum/customizer_entry/pubic_hair
	sprite_accessories = list(
		/datum/sprite_accessory/body_hair/pubic/shaved,
		/datum/sprite_accessory/body_hair/pubic/stubble,
		/datum/sprite_accessory/body_hair/pubic/some_hair,
		/datum/sprite_accessory/body_hair/pubic/hairy,
		/datum/sprite_accessory/body_hair/pubic/very_hairy,
	)

/datum/customizer_choice/bodypart_feature/pubic_hair/make_default_customizer_entry(datum/preferences/prefs, customizer_type, changed_entry = TRUE)
	. = ..()
	var/datum/customizer_entry/pubic_hair/pubic_hair_entry = .
	pubic_hair_entry.material = get_species_body_hair_materials(src, prefs)[1]

/datum/customizer_choice/bodypart_feature/pubic_hair/customize_feature(datum/bodypart_feature/feature, mob/living/carbon/human/human, datum/preferences/prefs, datum/customizer_entry/pubic_hair/entry)
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = feature
	pubic_hair_feature.growth_enabled = entry.growth_enabled
	pubic_hair_feature.set_material(entry.material)
	pubic_hair_feature.set_style(entry.style)

/datum/customizer_choice/bodypart_feature/pubic_hair/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/pubic_hair/pubic_hair_entry = entry
	dat += body_hair_growth_link(customizer_type, pubic_hair_entry.growth_enabled)
	dat += body_hair_material_link(customizer_type, pubic_hair_entry.material)
	dat += "<br>Shape: <a href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=pubic_hair_style'>[pubic_hair_shape_label(pubic_hair_entry)]</a>"

/datum/customizer_choice/bodypart_feature/pubic_hair/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/pubic_hair/pubic_hair_entry = entry
	return list(
		list("task" = "pubic_hair_style", "label" = "Shape", "kind" = "text", "value" = pubic_hair_shape_label(pubic_hair_entry)),
		body_hair_material_extra(pubic_hair_entry.material),
		body_hair_growth_extra(pubic_hair_entry.growth_enabled),
	)

/datum/customizer_choice/bodypart_feature/pubic_hair/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/pubic_hair/pubic_hair_entry = entry
	switch(href_list["customizer_task"])
		if("toggle_body_hair_growth")
			pubic_hair_entry.growth_enabled = !pubic_hair_entry.growth_enabled
		if("body_hair_material")
			var/new_material = pick_body_hair_material(user, pubic_hair_entry.material, get_species_body_hair_materials(src, prefs))
			if(new_material)
				pubic_hair_entry.material = new_material
		if("pubic_hair_style")
			var/list/style_choices = list("None") + GLOB.pubic_hair_styles
			var/chosen_input = browser_input_list(user, "Choose how your pubic hair is groomed:", "Character Preference", style_choices)
			if(!chosen_input)
				return
			pubic_hair_entry.style = GLOB.pubic_hair_styles[chosen_input]
			pubic_hair_entry.grooming_state = pubic_hair_entry.style ? HAIR_GROOMING_STYLED : HAIR_GROOMING_NATURAL

/datum/customizer_choice/bodypart_feature/pubic_hair/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/pubic_hair/pubic_hair_entry = entry
	pubic_hair_entry.growth_enabled = pubic_hair_entry.growth_enabled ? TRUE : FALSE
	pubic_hair_entry.material = sanitize_body_hair_material(pubic_hair_entry.material, get_species_body_hair_materials(src, prefs))
	if(!find_key_by_value(GLOB.pubic_hair_styles, pubic_hair_entry.style))
		pubic_hair_entry.style = null
	pubic_hair_entry.grooming_state = pubic_hair_entry.style ? HAIR_GROOMING_STYLED : HAIR_GROOMING_NATURAL

/datum/customizer/bodypart_feature/armpit_hair
	name = "Armpit Hair"
	customizer_choices = list(/datum/customizer_choice/bodypart_feature/armpit_hair)
	allows_disabling = TRUE
	default_disabled = TRUE

/// Armpit hair that starts enabled, for species known for it.
/datum/customizer/bodypart_feature/armpit_hair/enabled
	default_disabled = FALSE

/datum/customizer_choice/bodypart_feature/armpit_hair
	name = "Armpit Hair"
	feature_type = /datum/bodypart_feature/hair/body_hair/armpit
	customizer_entry_type = /datum/customizer_entry/armpit_hair
	sprite_accessories = list(
		/datum/sprite_accessory/body_hair/armpit/stubble,
		/datum/sprite_accessory/body_hair/armpit/some_hair,
		/datum/sprite_accessory/body_hair/armpit/hairy,
		/datum/sprite_accessory/body_hair/armpit/very_hairy,
	)
	default_accessory = /datum/sprite_accessory/body_hair/armpit/some_hair

/datum/customizer_choice/bodypart_feature/armpit_hair/make_default_customizer_entry(datum/preferences/prefs, customizer_type, changed_entry = TRUE)
	. = ..()
	var/datum/customizer_entry/armpit_hair/armpit_hair_entry = .
	armpit_hair_entry.material = get_species_body_hair_materials(src, prefs)[1]
	var/datum/species/species = return_species(prefs)
	if(species?.hairyness == "t2" || species?.hairyness == "t3")
		set_accessory_type(prefs, /datum/sprite_accessory/body_hair/armpit/hairy, armpit_hair_entry)

/datum/customizer_choice/bodypart_feature/armpit_hair/customize_feature(datum/bodypart_feature/feature, mob/living/carbon/human/human, datum/preferences/prefs, datum/customizer_entry/armpit_hair/entry)
	var/datum/bodypart_feature/hair/body_hair/armpit/armpit_hair_feature = feature
	armpit_hair_feature.growth_enabled = entry.growth_enabled
	armpit_hair_feature.set_material(entry.material)

/datum/customizer_choice/bodypart_feature/armpit_hair/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/armpit_hair/armpit_hair_entry = entry
	dat += body_hair_growth_link(customizer_type, armpit_hair_entry.growth_enabled)
	dat += body_hair_material_link(customizer_type, armpit_hair_entry.material)

/datum/customizer_choice/bodypart_feature/armpit_hair/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/armpit_hair/armpit_hair_entry = entry
	return list(
		body_hair_material_extra(armpit_hair_entry.material),
		body_hair_growth_extra(armpit_hair_entry.growth_enabled),
	)

/datum/customizer_choice/bodypart_feature/armpit_hair/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/armpit_hair/armpit_hair_entry = entry
	switch(href_list["customizer_task"])
		if("toggle_body_hair_growth")
			armpit_hair_entry.growth_enabled = !armpit_hair_entry.growth_enabled
		if("body_hair_material")
			var/new_material = pick_body_hair_material(user, armpit_hair_entry.material, get_species_body_hair_materials(src, prefs))
			if(new_material)
				armpit_hair_entry.material = new_material

/datum/customizer_choice/bodypart_feature/armpit_hair/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/armpit_hair/armpit_hair_entry = entry
	armpit_hair_entry.growth_enabled = armpit_hair_entry.growth_enabled ? TRUE : FALSE
	armpit_hair_entry.material = sanitize_body_hair_material(armpit_hair_entry.material, get_species_body_hair_materials(src, prefs))
