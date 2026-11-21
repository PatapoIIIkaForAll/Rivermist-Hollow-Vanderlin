// Inline skin marks editor in the character creator's Markings window: tattoos, brands and body writing.

/// Offered pigment hex matching a colour case-insensitively, or null. Loaded colours are lowercased.
/proc/tattoo_offered_pigment(color)
	return skin_mark_offered_color(GLOB.tattoo_ink_colors, color)

/// Which cap a medium counts against: ink, brand or surface.
/proc/skin_mark_cap_group(medium)
	if(is_brand_mark(medium))
		return TATTOO_MEDIUM_BRAND
	if(is_surface_body_mark(medium))
		return TATTOO_MEDIUM_CHARCOAL
	return TATTOO_MEDIUM_INK

/proc/skin_mark_cap(medium)
	switch(skin_mark_cap_group(medium))
		if(TATTOO_MEDIUM_BRAND)
			return MAXIMUM_BRANDS_PER_ZONE
		if(TATTOO_MEDIUM_CHARCOAL)
			return 1
	return MAXIMUM_TATTOOS_PER_ZONE

/proc/skin_mark_text_cap(medium)
	return is_brand_mark(medium) ? BRAND_TEXT_MAX_LENGTH : TATTOO_TEXT_MAX_LENGTH

/// Saved marks on a zone that count against the same cap as medium.
/datum/preferences/proc/count_saved_skin_marks(zone, medium)
	. = 0
	var/group = skin_mark_cap_group(medium)
	for(var/list/entry in LAZYACCESS(tattoos, zone))
		if(skin_mark_cap_group(entry["medium"]) == group)
			.++

/datum/preferences/proc/skin_mark_zone_has_room(zone, medium)
	return count_saved_skin_marks(zone, medium) < skin_mark_cap(medium)

/proc/skin_mark_color_options(list/offered)
	. = list()
	for(var/offered_name in offered)
		. += list(list("name" = offered_name, "color" = offered[offered_name]))

/// Inline editor data: zones this body has, grouped by limb, with saved entries, colours and caps.
/datum/preferences/proc/character_creator_tattoo_data()
	var/list/limbs = list()
	for(var/limb in GLOB.tattoo_zones_by_limb)
		var/list/zones = list()
		for(var/zone in GLOB.tattoo_zones_by_limb[limb])
			var/list/saved = LAZYACCESS(tattoos, zone)
			var/present = !!preview_has_tattoo_zone(zone)
			// A zone the body lost still lists its saved marks, so they can be removed.
			if(!present && !length(saved))
				continue
			var/list/entries = list()
			for(var/index in 1 to length(saved))
				var/list/entry = saved[index]
				var/shown_color = entry["medium"] == TATTOO_MEDIUM_INK ? (tattoo_offered_pigment(entry["color"]) || entry["color"]) : entry["color"]
				entries += list(list(
					"index" = index,
					"text" = html_decode(entry["text"]),
					"style" = entry["style"],
					"color" = shown_color,
					"pigment" = tattoo_mark_tooltip(entry),
					"medium" = entry["medium"],
				))
			zones += list(list(
				"id" = zone,
				"name" = capitalize(tattoo_zone_name(zone)),
				"intimate" = tattoo_zone_is_intimate(zone),
				"present" = present,
				"ink" = count_saved_skin_marks(zone, TATTOO_MEDIUM_INK),
				"brands" = count_saved_skin_marks(zone, TATTOO_MEDIUM_BRAND),
				"writing" = count_saved_skin_marks(zone, TATTOO_MEDIUM_CHARCOAL),
				"entries" = entries,
			))
		if(length(zones))
			limbs += list(list(
				"id" = limb,
				"name" = capitalize(tattoo_zone_name(limb)),
				"zones" = zones,
			))
	var/static/list/static_rules
	if(!static_rules)
		static_rules = list(
			"styles" = list(TATTOO_STYLE_LETTERING, TATTOO_STYLE_DESIGN),
			"pigments" = skin_mark_color_options(GLOB.tattoo_ink_colors),
			"glows" = skin_mark_color_options(GLOB.arcane_brand_glows),
			"writing" = list(
				list("id" = TATTOO_MEDIUM_CHARCOAL, "colors" = list(list("name" = "Charcoal", "color" = TATTOO_CHARCOAL_COLOR))),
				list("id" = TATTOO_MEDIUM_QUILL, "colors" = list(list("name" = "Quill ink", "color" = TATTOO_QUILL_COLOR))),
				list("id" = TATTOO_MEDIUM_LIPSTICK, "colors" = skin_mark_color_options(lipstick_skin_shades())),
				list("id" = TATTOO_MEDIUM_PAINT, "colors" = list()),
			),
			"brand_color" = TATTOO_BRAND_COLOR,
			"max_per_zone" = MAXIMUM_TATTOOS_PER_ZONE,
			"max_brands" = MAXIMUM_BRANDS_PER_ZONE,
			"max_length" = TATTOO_TEXT_MAX_LENGTH,
			"brand_max_length" = BRAND_TEXT_MAX_LENGTH,
		)
	var/list/data = static_rules.Copy()
	data["limbs"] = limbs
	return data

/// Index of a saved mark in a zone from a client param, or 0 when there is none.
/datum/preferences/proc/character_creator_tattoo_index(zone, raw_index)
	var/list/entries = LAZYACCESS(tattoos, zone)
	var/index = text2num("[raw_index]")
	if(!islist(entries) || !isnum(index) || index != round(index) || index < 1 || index > length(entries))
		return 0
	return index

/// Asks for mark text and cleans it like the in-round tools do; null when cancelled or blank.
/datum/preferences/proc/character_creator_prompt_tattoo_text(mob/user, zone, default_text, medium = TATTOO_MEDIUM_INK)
	var/max_length = skin_mark_text_cap(medium)
	var/question = "Describe the tattoo"
	var/title = "Tattoo"
	if(is_brand_mark(medium))
		question = "What does the brand read or show"
		title = medium == TATTOO_MEDIUM_ARCANE ? "Arcane brand" : "Brand"
	else if(is_surface_body_mark(medium))
		question = "What is written there"
		title = "Writing"
	var/raw_text = tgui_input_text(user, "[question] (max [max_length] characters)?", "[title] - [tattoo_zone_name(zone)]", default_text, max_length = max_length, encode = FALSE)
	if(!istext(raw_text))
		return null
	var/clean_text = trim(sanitize(raw_text), max_length)
	return length(clean_text) ? clean_text : null

/// Colour a new or recoloured mark gets from a client param; null when the medium refuses it.
/datum/preferences/proc/character_creator_mark_color(mob/user, medium, requested, current)
	switch(medium)
		if(TATTOO_MEDIUM_INK)
			return tattoo_offered_pigment(requested)
		if(TATTOO_MEDIUM_ARCANE)
			return skin_mark_offered_color(GLOB.arcane_brand_glows, requested)
		if(TATTOO_MEDIUM_LIPSTICK)
			return skin_mark_offered_color(lipstick_skin_shades(), requested)
		if(TATTOO_MEDIUM_PAINT)
			var/picked = input(user, "Choose the paint colour.", "Body writing", current || "#7c1f1f") as color|null
			return picked ? sanitize_hexcolor(picked, 6, TRUE) : null
	return null

/// Inline editor tasks: add, edit, set_style, set_color, remove. TRUE when the saved marks changed.
/datum/preferences/proc/character_creator_tattoo_act(mob/user, list/params)
	var/zone = params["zone"]
	if(!istext(zone) || !(zone in GLOB.tattoo_zone_data))
		return FALSE
	var/task = params["task"]
	var/index = character_creator_tattoo_index(zone, params["index"])
	// Removal stays possible on a zone the body lost; every other task needs the zone.
	if(task != "remove" && !preview_has_tattoo_zone(zone))
		return FALSE
	var/style = (params["style"] == TATTOO_STYLE_LETTERING) ? TATTOO_STYLE_LETTERING : TATTOO_STYLE_DESIGN
	var/slot = default_slot
	switch(task)
		if("add")
			var/medium = params["medium"]
			if(!is_known_skin_medium(medium) || !skin_mark_zone_has_room(zone, medium))
				return FALSE
			var/color = sanitize_skin_mark_color(medium, null)
			if(medium in list(TATTOO_MEDIUM_INK, TATTOO_MEDIUM_ARCANE, TATTOO_MEDIUM_LIPSTICK, TATTOO_MEDIUM_PAINT))
				color = character_creator_mark_color(user, medium, params["color"])
				if(!color)
					return FALSE
			var/text = character_creator_prompt_tattoo_text(user, zone, null, medium)
			// The prompts sleep, so the slot, body or zone may have changed meanwhile.
			if(!text || slot != default_slot || !preview_has_tattoo_zone(zone) || !skin_mark_zone_has_room(zone, medium))
				return FALSE
			LAZYINITLIST(tattoos)
			if(!tattoos[zone])
				tattoos[zone] = list()
			tattoos[zone] += list(list(
				"zone" = zone,
				"text" = text,
				"style" = style,
				"color" = color,
				"medium" = medium,
				"state" = TATTOO_STATE_FRESH,
			))
		if("edit")
			if(!index)
				return FALSE
			var/list/entry = tattoos[zone][index]
			var/text = character_creator_prompt_tattoo_text(user, zone, html_decode(entry["text"]), entry["medium"])
			if(!text)
				return FALSE
			// The prompt sleeps, so the entry may have moved or the slot changed meanwhile.
			var/list/entries = LAZYACCESS(tattoos, zone)
			if(slot != default_slot || !islist(entries) || index > length(entries) || entries[index] != entry)
				return FALSE
			entry["text"] = text
		if("set_style")
			if(!index)
				return FALSE
			var/list/entry = tattoos[zone][index]
			if(entry["style"] == style)
				return FALSE
			entry["style"] = style
		if("set_color")
			if(!index)
				return FALSE
			var/list/entry = tattoos[zone][index]
			var/color = character_creator_mark_color(user, entry["medium"], params["color"], entry["color"])
			var/list/entries = LAZYACCESS(tattoos, zone)
			if(!color || slot != default_slot || !islist(entries) || index > length(entries) || entries[index] != entry || entry["color"] == color)
				return FALSE
			entry["color"] = color
		if("remove")
			if(!index)
				return FALSE
			var/list/entries = tattoos[zone]
			entries.Cut(index, index + 1)
			if(!length(entries))
				tattoos -= zone
		else
			return FALSE
	update_menu_data(user)
	return TRUE
