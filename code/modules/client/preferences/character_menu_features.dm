/// TGUI character setup menu — customizer feature data + thumbnail spritesheet.
/// Ported from neurolin's features_tgui.dm; adapted to our customizer typepaths.

/// Which accessory types a choice offers in the menu. Base: everything the choice has.
/datum/customizer_choice/proc/character_setup_accessory_types(datum/preferences/prefs)
	return sprite_accessories

/// Optional grouping key for the frontend ("underwear", "taur", ...). Base: none.
/datum/customizer_choice/proc/character_setup_section()
	return null

/datum/sprite_accessory/proc/character_setup_thumb_state()
	if(!icon || isnull(icon_state) || icon_state == "")
		return null
	var/state = icon_state
	if(length(relevant_layers))
		var/layer_for_thumb = (BODY_FRONT_LAYER in relevant_layers) ? BODY_FRONT_LAYER : relevant_layers[1]
		state = "[icon_state]_[get_layer_suffix(layer_for_thumb)]"
	if(color_keys > 1)
		state = "[state]_1"
	var/list/states = icon_states(icon)
	if(!(state in states))
		state = (icon_state in states) ? icon_state : null
	return state

/datum/asset/spritesheet/character_setup_chargen
	name = "character_setup_chargen"

/datum/asset/spritesheet/character_setup_chargen/create_spritesheets()
	var/list/seen = list()
	for(var/choice_type in subtypesof(/datum/customizer_choice))
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
		if(!choice || !LAZYLEN(choice.sprite_accessories))
			continue
		for(var/accessory_type in choice.sprite_accessories)
			character_setup_insert_chargen_sprite(accessory_type, seen)

/datum/asset/spritesheet/character_setup_chargen/proc/character_setup_insert_chargen_sprite(accessory_type, list/seen)
	var/key = sanitize_css_class_name("[accessory_type]")
	if(seen[key])
		return
	seen[key] = TRUE
	var/datum/sprite_accessory/acc = SPRITE_ACCESSORY(accessory_type)
	if(!acc)
		return
	var/state = acc.character_setup_thumb_state()
	if(!state)
		return
	var/icon/spr = icon(acc.icon, state)
	if(!spr)
		return
	spr.Scale(48, 48)
	Insert(key, spr)

/datum/customizer_choice/proc/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	return null

/datum/customizer_choice/bodypart_feature/hair/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/hair/hair_entry = entry
	var/list/out = list()
	out += list(list("task" = "hair_color", "label" = "Hair Color", "kind" = "color", "value" = hair_entry.hair_color))
	if(allows_natural_gradient)
		var/datum/hair_gradient/natural_gradient = HAIR_GRADIENT(hair_entry.natural_gradient)
		out += list(list("task" = "natural_gradient", "label" = "Natural Gradient", "kind" = "text", "value" = natural_gradient.name))
		if(hair_entry.natural_gradient != /datum/hair_gradient/none)
			out += list(list("task" = "natural_gradient_color", "label" = "Natural Color", "kind" = "color", "value" = hair_entry.natural_color))
	if(allows_dye_gradient)
		var/datum/hair_gradient/dye_gradient = HAIR_GRADIENT(hair_entry.dye_gradient)
		out += list(list("task" = "dye_gradient", "label" = "Dye Gradient", "kind" = "text", "value" = dye_gradient.name))
		if(hair_entry.dye_gradient != /datum/hair_gradient/none)
			out += list(list("task" = "dye_gradient_color", "label" = "Dye Color", "kind" = "color", "value" = hair_entry.dye_color))
	return out

/datum/customizer_choice/organ/eyes/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/eyes/eyes_entry = entry
	var/list/out = list()
	out += list(list("task" = "right_eye_color", "label" = "Right Eye Color", "kind" = "color", "value" = eyes_entry.right_eye_color))
	if(allows_heterochromia)
		out += list(list("task" = "left_eye_color", "label" = "Left Eye Color", "kind" = "color", "value" = eyes_entry.left_eye_color))
	out += list(list("task" = "eye_glowing", "label" = "Glowing", "kind" = "text", "value" = eyes_entry.eye_glowing ? "Yes" : "No"))
	return out

/datum/customizer_choice/organ/genitals/penis/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = entry
	return list(
		list("task" = "penis_length_cm", "label" = "Length", "kind" = "number", "value" = penis_entry.penis_length_cm, "min" = PENIS_LENGTH_MIN, "max" = PENIS_LENGTH_MAX, "step" = 1, "unit" = "cm"),
		list("task" = "penis_size", "label" = "Size", "kind" = "text", "value" = find_key_by_value(PENIS_SIZES_BY_NAME, get_penis_visual_size(penis_entry.penis_length_cm)), "readonly" = TRUE),
		list("task" = "functional", "label" = "Functional", "kind" = "text", "value" = penis_entry.functional ? "Yes" : "No"),
	)

/datum/customizer_choice/organ/genitals/testicles/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/genitals/testicles/testicles_entry = entry
	return list(
		list("task" = "ball_size", "label" = "Size", "kind" = "text", "value" = find_key_by_value(TESTICLE_SIZES_BY_NAME, testicles_entry.ball_size)),
		list("task" = "virile", "label" = "Fertility", "kind" = "text", "value" = testicles_entry.virility ? "Virile" : "Sterile"),
	)

/datum/customizer_choice/organ/genitals/breasts/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/genitals/breasts/breasts_entry = entry
	return list(
		list("task" = "breast_size", "label" = "Size", "kind" = "text", "value" = find_key_by_value(BREAST_SIZES_BY_NAME, breasts_entry.breast_size)),
		list("task" = "lactating", "label" = "Lactation", "kind" = "text", "value" = breasts_entry.lactating ? "Enabled" : "Disabled"),
	)

/datum/customizer_choice/organ/genitals/womb/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/genitals/womb/womb_entry = entry
	return list(
		list("task" = "fertile", "label" = "Fertility", "kind" = "text", "value" = womb_entry.fertility ? "Fertile" : "Sterile"),
	)

/datum/customizer_choice/organ/genitals/belly/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/genitals/belly/belly_entry = entry
	return list(
		list("task" = "belly_size", "label" = "Size", "kind" = "text", "value" = find_key_by_value(prefs.get_belly_size_choices(), belly_entry.belly_size)),
	)

/datum/customizer_choice/organ/genitals/butt/character_setup_tgui_extras(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/genitals/butt/butt_entry = entry
	return list(
		list("task" = "butt_size", "label" = "Size", "kind" = "text", "value" = find_key_by_value(prefs.get_butt_size_choices(), butt_entry.butt_size)),
	)

/datum/customizer_choice/proc/character_setup_is_erp()
	return FALSE

/// All genital customizer choices are gated behind the Intimacy tab.
/datum/customizer_choice/organ/genitals/character_setup_is_erp()
	return TRUE

// ---- Item-based smallclothes (native underwear tab) ----

GLOBAL_LIST_EMPTY(character_setup_smallclothes_thumbs)

/// Cached flat-icon data URI for a smallclothes item type.
/proc/character_setup_smallclothes_thumb(item_type)
	if(!ispath(item_type, /obj/item))
		return null
	var/cache_key = "[item_type]"
	if(!GLOB.character_setup_smallclothes_thumbs[cache_key])
		var/obj/item/clothing/cast_type = item_type
		var/image/dummy = image(initial(cast_type.icon), null, initial(cast_type.icon_state), initial(cast_type.layer))
		GLOB.character_setup_smallclothes_thumbs[cache_key] = "data:image/png;base64, [icon2base64(getFlatIcon(dummy))]"
	return GLOB.character_setup_smallclothes_thumbs[cache_key]

/// Single source of truth for the six smallclothes categories.
/datum/preferences/proc/character_setup_smallclothes_categories()
	validate_smallclothes_preferences()
	return list(
		list("id" = "undies", "name" = "Undies", "pref" = SMALCLOTHES_UNDIE_PREFERENCES, "color_pref" = SMALCLOTHES_UNDIE_COLOR_PREFERENCES, "options" = GLOB.selectable_undies, "base" = /obj/item/clothing/undies),
		list("id" = "bra", "name" = "Bra", "pref" = SMALCLOTHES_BRA_PREFERENCES, "color_pref" = SMALCLOTHES_BRA_COLOR_PREFERENCES, "options" = GLOB.selectable_bras, "base" = /obj/item/clothing/bra),
		list("id" = "undershirt", "name" = "Undershirt", "pref" = SMALCLOTHES_UNDERSHIRT_PREFERENCES, "color_pref" = SMALCLOTHES_UNDERSHIRT_COLOR_PREFERENCES, "options" = GLOB.selectable_undershirts, "base" = /obj/item/clothing/undershirt),
		list("id" = "garter", "name" = "Garter", "pref" = SMALCLOTHES_GARTER_PREFERENCES, "color_pref" = SMALCLOTHES_GARTER_COLOR_PREFERENCES, "options" = GLOB.selectable_garters, "base" = /obj/item/clothing/garter),
		list("id" = "legwear", "name" = "Legwear", "pref" = SMALCLOTHES_LEGWEAR_PREFERENCES, "color_pref" = SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES, "options" = GLOB.selectable_legwear, "base" = /obj/item/clothing/legwears),
		list("id" = "armsleeves", "name" = "Armsleeves", "pref" = SMALCLOTHES_ARMSLEEVE_PREFERENCES, "color_pref" = SMALCLOTHES_ARMSLEEVE_COLOR_PREFERENCES, "options" = GLOB.selectable_armsleeves, "base" = /obj/item/clothing/armsleeves),
	)

/datum/preferences/proc/character_setup_smallclothes_category(category_id)
	for(var/list/category as anything in character_setup_smallclothes_categories())
		if(category["id"] == category_id)
			return category
	return null

/// Static per-category option catalogs with thumbnails ("None" entry first).
/datum/preferences/proc/character_setup_smallclothes_static()
	. = list()
	for(var/list/category as anything in character_setup_smallclothes_categories())
		var/list/options = list(list("name" = "None", "value" = ""))
		for(var/obj/item/clothing/item_type as anything in category["options"])
			if(isnull(item_type))
				continue
			options += list(list(
				"name" = "[initial(item_type.name)]",
				"value" = "[item_type]",
				"thumb" = character_setup_smallclothes_thumb(item_type),
			))
		. += list(list(
			"id" = category["id"],
			"name" = category["name"],
			"options" = options,
		))

/// Live selections + colors for the underwear tab.
/datum/preferences/proc/character_setup_smallclothes_data()
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	var/list/entries = list()
	for(var/list/category as anything in character_setup_smallclothes_categories())
		var/obj/item/clothing/current_type = smallclothes_preferences[category["pref"]]
		entries += list(list(
			"id" = category["id"],
			"value" = current_type ? "[current_type]" : "",
			"name" = current_type ? "[initial(current_type.name)]" : "None",
			"color" = smallclothes_preferences[category["color_pref"]],
		))
	return list(
		"random" = !!smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES],
		"entries" = entries,
	)

/datum/preferences/proc/character_setup_build_features_data()
	var/_t = world.timeofday
	var/list/features = list()
	if(!pref_species)
		return features
	if(length(customizer_entries) < length(pref_species.customizers))
		validate_customizer_entries()
	for(var/customizer_type in pref_species.customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer || !customizer.is_allowed(src))
			continue
		var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
		if(!entry)
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		if(!choice)
			continue

		var/list/feature = list(
			"key" = "[customizer_type]",
			"name" = customizer.name,
			"enabled" = !entry.disabled,
			"can_disable" = customizer.allows_disabling,
			"choice_name" = choice.name,
			"choice_value" = "[entry.customizer_choice_type]",
			"erp" = choice.character_setup_is_erp() ? TRUE : FALSE,
		)
		var/feature_section = choice.character_setup_section()
		if(feature_section)
			feature["section"] = feature_section

		if(length(customizer.customizer_choices) > 1)
			var/list/choice_options = list()
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				choice_options += list(list("name" = iter_choice.name, "value" = "[choice_type]"))
			feature["choice_options"] = choice_options

		var/list/accessory_types = choice.character_setup_accessory_types(src)
		if(length(accessory_types) && entry.accessory_type)
			var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
			if(accessory)
				feature["accessory_name"] = accessory.name
				feature["accessory_value"] = "[entry.accessory_type]"
				if(length(accessory_types) > 1)
					var/list/accessory_options = list()
					for(var/accessory_type in accessory_types)
						var/datum/sprite_accessory/iter_accessory = SPRITE_ACCESSORY(accessory_type)
						accessory_options += list(list(
							"name" = iter_accessory.name,
							"value" = "[accessory_type]",
						))
					feature["accessory_options"] = accessory_options
				if(choice.allows_accessory_color_customization && accessory.color_keys)
					var/list/colors = list()
					var/list/color_list = color_string_to_list(entry.accessory_colors)
					for(var/index in 1 to accessory.color_keys)
						if(index > length(color_list))
							break
						colors += list(list(
							"name" = (accessory.color_keys == 1) ? accessory.color_key_name : accessory.color_key_names[index],
							"value" = color_list[index],
							"index" = "[index]",
						))
					if(length(colors))
						feature["colors"] = colors

		var/list/extras = choice.character_setup_tgui_extras(src, entry)
		if(length(extras))
			feature["extras"] = extras

		features += list(feature)
	character_setup_log_op("build_features_data", _t, "features=[length(features)]")
	return features
