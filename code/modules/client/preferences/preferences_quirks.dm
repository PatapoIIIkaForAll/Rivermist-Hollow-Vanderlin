/datum/preferences/proc/save_quirks(savefile/S)
	if(!S)
		return

	// Save as list of lists: list(list("type" = type, "value" = value, "extra" = list(...)), ...)
	var/list/quirk_data = list()
	for(var/quirk_type in quirks)
		var/custom_val = quirk_customizations[quirk_type]
		var/list/extra_val = quirk_extra_customizations[quirk_type]
		if(islist(extra_val))
			extra_val = extra_val.Copy()
		quirk_data += list(list("type" = quirk_type, "value" = custom_val, "extra" = extra_val))

	WRITE_FILE(S["quirks"], quirk_data)

/datum/preferences/proc/load_quirks(savefile/S)
	if(!S)
		return

	if(read_saved_quirks(S))
		validate_quirks()
	if(pref_species && islist(customizer_entries))
		validate_customizer_entries()

/// Rewrites quirk paths from before the positive/negative/neutral rename in saved or exported text.
/proc/migrate_legacy_quirk_text(text)
	var/static/regex/old_addictions = regex(@"/datum/quirk/vice/(alcoholic|smoker|junkie|kleptomaniac|godfearing|sadist|lovefiend|masochist)\b", "g")
	var/static/regex/old_maniac = regex(@"/datum/quirk/vice/maniac\b", "g")
	text = old_addictions.Replace(text, "/datum/quirk/negative/addiction/$1")
	text = old_maniac.Replace(text, "/datum/quirk/negative/addiction/sadist")
	text = replacetext(text, "/datum/quirk/vice/", "/datum/quirk/negative/")
	text = replacetext(text, "/datum/quirk/boon/", "/datum/quirk/positive/")
	return replacetext(text, "/datum/quirk/peculiarity/", "/datum/quirk/neutral/")

/// Fills the quirk lists from the savefile without validating them. Returns FALSE when the slot has no quirk data.
/datum/preferences/proc/read_saved_quirks(savefile/S)
	quirks = list()
	quirk_customizations = list()
	quirk_extra_customizations = list()

	var/list/quirk_data
	S["quirks"] >> quirk_data

	if(!islist(quirk_data))
		return FALSE

	for(var/entry in quirk_data)
		if(!islist(entry))
			continue
		var/quirk_type = entry["type"]
		var/custom_val = entry["value"]
		var/list/extra_val = entry["extra"]

		if(ispath(quirk_type, /datum/quirk))
			quirks += quirk_type
			if(custom_val)
				quirk_customizations[quirk_type] = custom_val
			if(islist(extra_val) && length(extra_val))
				quirk_extra_customizations[quirk_type] = extra_val.Copy()
	return TRUE


/datum/preferences/proc/set_quirk_customization(quirk_type, value)
	if(quirk_type in quirks)
		quirk_customizations[quirk_type] = value
		save_character()
		return TRUE
	return FALSE

/datum/preferences/proc/get_quirk_customization(quirk_type)
	return quirk_customizations[quirk_type]

/datum/preferences/proc/set_quirk_extra_customization(quirk_type, key, value)
	if(!(quirk_type in quirks))
		return FALSE
	var/datum/quirk/quirk = GLOB.quirk_singletons[quirk_type]
	var/list/field_definition
	for(var/list/field in quirk?.extra_customization_fields)
		if(field["key"] == key)
			field_definition = field
			break
	if(!field_definition)
		return FALSE
	var/field_type = field_definition["type"]
	switch(field_type)
		if(QUIRK_NUMBER)
			var/min_value = field_definition["min"] || 1
			var/max_value = field_definition["max"] || 10
			var/default_value = field_definition["default"] || min_value
			var/number_value = text2num("[value]")
			if(isnull(number_value))
				value = default_value
			else
				value = clamp(round(number_value), min_value, max_value)
		if(QUIRK_SELECT)
			var/list/options = field_definition["options"]
			if(!(value in options))
				value = field_definition["default"]
		if(QUIRK_TEXT)
			var/max_length = field_definition["max_length"] || 64
			var/allow_newlines = field_definition["multiline"] ? TRUE : FALSE
			value = sanitize_oviposition_text(value, max_length, allow_newlines)
		if(QUIRK_COLOR)
			var/sanitized_color = sanitize_oviposition_color(value)
			value = sanitized_color ? sanitized_color : ""
	if(!islist(quirk_extra_customizations[quirk_type]))
		quirk_extra_customizations[quirk_type] = list()
	quirk_extra_customizations[quirk_type][key] = value
	save_character()
	return TRUE

/datum/preferences/proc/get_quirk_extra_customization(quirk_type, key)
	var/list/extra = quirk_extra_customizations[quirk_type]
	if(islist(extra))
		return extra[key]
	return null

/datum/preferences/proc/validate_quirks()
	if(!quirks || !islist(quirks))
		quirks = list()
		quirk_customizations = list()
		quirk_extra_customizations = list()
		return
	if(!islist(quirk_customizations))
		quirk_customizations = list()
	if(!islist(quirk_extra_customizations))
		quirk_extra_customizations = list()

	// Remove invalid quirk types
	var/list/valid_quirks = list()
	for(var/quirk_type in quirks)
		if(ispath(quirk_type, /datum/quirk))
			valid_quirks += quirk_type

	quirks = valid_quirks

	// Remove quirks that are no longer available due to character changes
	var/list/available_quirks = list()
	for(var/quirk_type in quirks)
		var/datum/quirk/Q = new quirk_type()
		if(Q.is_available(src))
			available_quirks += quirk_type
		qdel(Q)

	quirks = available_quirks

	// Check point balance
	var/balance = calculate_quirk_balance()
	if(balance < 0)
		// Can't afford all boons, remove some
		while(balance < 0 && length(quirks))
			var/datum/quirk/most_expensive = find_most_expensive_boon()
			if(most_expensive)
				quirks -= most_expensive
				balance = calculate_quirk_balance()
			else
				break

	// Check boon limit
	var/boon_count = count_boons_in_list()
	while(boon_count > MAX_POSITIVE)
		var/datum/quirk/first_boon = find_first_boon()
		if(first_boon)
			quirks -= first_boon
			boon_count = count_boons_in_list()
		else
			break

	var/list/valid_customizations = list()
	var/list/valid_extra_customizations = list()
	for(var/quirk_type in quirks)
		if(quirk_customizations[quirk_type])
			valid_customizations[quirk_type] = quirk_customizations[quirk_type]
		var/list/extra_values = quirk_extra_customizations[quirk_type]
		if(islist(extra_values) && length(extra_values))
			valid_extra_customizations[quirk_type] = extra_values.Copy()
	quirk_customizations = valid_customizations
	quirk_extra_customizations = valid_extra_customizations
	trim_unaffordable_prosthetics() // RMH EDIT

/datum/preferences/proc/calculate_quirk_balance()
	var/balance = STARTING_QUIRK_POINTS
	for(var/datum/quirk/quirk as anything in quirks)
		balance += initial(quirk.point_value)
	balance += prosthetic_point_value() // RMH EDIT - Prosthetics window choices share the quirk balance
	return balance

/datum/preferences/proc/count_boons_in_list()
	var/count = 0
	for(var/datum/quirk/quirk as anything in quirks)
		if(initial(quirk.quirk_category) == QUIRK_POSITIVE)
			count++
	return count

/datum/preferences/proc/find_most_expensive_boon()
	var/most_expensive = null
	var/lowest_value = 0
	for(var/datum/quirk/quirk as anything in quirks)
		if(initial(quirk.quirk_category) == QUIRK_POSITIVE)
			if(initial(quirk.point_value) < lowest_value)
				lowest_value = initial(quirk.point_value)
				most_expensive = quirk
	return most_expensive

/datum/preferences/proc/find_first_boon()
	for(var/datum/quirk/quirk in quirks)
		if(initial(quirk.quirk_category) == QUIRK_POSITIVE)
			return quirk
	return null

/datum/preferences/proc/can_add_quirk(quirk_type)
	return isnull(quirk_refusal_reason(quirk_type))

/// Plain sentence saying why this character cannot take quirk_type, or null when it can.
/datum/preferences/proc/quirk_refusal_reason(quirk_type)
	var/datum/quirk/singleton = ispath(quirk_type, /datum/quirk) ? GLOB.quirk_singletons[quirk_type] : null
	if(!singleton)
		return "That quirk does not exist."
	if(quirk_type in quirks)
		return "You already have [singleton.name]."
	if(!singleton.is_available(src))
		return quirk_unavailable_reason(singleton)
	if(singleton.quirk_category == QUIRK_POSITIVE && count_boons_in_list() >= MAX_POSITIVE)
		return "You cannot take more than [MAX_POSITIVE] positive quirks."
	var/balance = calculate_quirk_balance()
	if(singleton.point_value < 0 && balance + singleton.point_value < 0)
		return "Not enough quirk points: [singleton.name] costs [-singleton.point_value], you have [balance]."
	for(var/existing_type in quirks)
		var/datum/quirk/existing = GLOB.quirk_singletons[existing_type]
		if((existing_type in singleton.incompatible_quirks) || (existing && (quirk_type in existing.incompatible_quirks)))
			return "[singleton.name] conflicts with [existing ? existing.name : "a quirk you have"]."
	return null

/// Names the failed age or species gate of is_available(); other gates get a general line.
/datum/preferences/proc/quirk_unavailable_reason(datum/quirk/singleton)
	var/age = read_preference(/datum/preference/choiced/age)
	if((length(singleton.allowed_ages) && !(age in singleton.allowed_ages)) || (age in singleton.blocked_ages))
		return "[singleton.name] is not available at your character's age."
	var/species_type = pref_species?.type
	if((length(singleton.allowed_species) && !(species_type in singleton.allowed_species)) || (species_type in singleton.blocked_species))
		return "[singleton.name] is not available to the [pref_species.name] species."
	return "[singleton.name] does not fit your character's current setup."

/// Adds quirk_type; when refused, tells user why in chat.
/datum/preferences/proc/add_quirk(quirk_type, custom_value = null, mob/user = null)
	var/refusal = quirk_refusal_reason(quirk_type)
	if(refusal)
		if(user)
			to_chat(user, span_warning(refusal))
		return FALSE
	quirks += quirk_type
	if(custom_value)
		quirk_customizations[quirk_type] = custom_value
	validate_customizer_entries()
	save_character()
	return TRUE

/datum/preferences/proc/remove_quirk(quirk_type)
	if(quirk_type in quirks)
		quirks -= quirk_type
		quirk_customizations -= quirk_type
		quirk_extra_customizations -= quirk_type

		// After removing a quirk, validate that the remaining quirks are still affordable
		var/balance = calculate_quirk_balance()

		// If balance is now negative, we need to remove some boons
		while(balance < 0 && length(quirks))
			var/datum/quirk/most_expensive = find_most_expensive_boon()
			if(most_expensive)
				quirks -= most_expensive
				quirk_customizations -= most_expensive
				quirk_extra_customizations -= most_expensive
				balance = calculate_quirk_balance()
			else
				break

		validate_customizer_entries()
		save_character()
		return TRUE
	return FALSE

/datum/preferences/proc/clear_quirks()
	quirks = list()
	quirk_customizations = list()
	quirk_extra_customizations = list()
	save_character()

/datum/preferences/proc/apply_quirks_to_character(mob/living/carbon/human/H)
	if(!H)
		return

	H.clear_quirks()

	// Revalidate and apply quirks
	var/list/valid_quirks = list()
	var/list/valid_customizations = list()
	var/list/valid_extra_customizations = list()

	for(var/quirk_type in quirks)
		var/datum/quirk/Q = new quirk_type()

		// Check if quirk is still available
		if(!Q.is_available(src))
			to_chat(H, span_warning("The '[initial(Q.name)]' quirk is no longer available for your character."))
			qdel(Q)
			continue

		// Special handling for backstory quirk
		if(istype(Q, /datum/quirk/positive/backstory))
			var/custom_val = quirk_customizations[quirk_type]
			if(custom_val && ispath(custom_val, /datum/backstory))
				var/datum/backstory/B = new custom_val()
				if(!B.is_available(src))
					to_chat(H, span_warning("The '[initial(B.name)]' background is no longer available for your character."))
					qdel(B)
					qdel(Q)
					continue
				qdel(B)

		valid_quirks += quirk_type
		if(quirk_customizations[quirk_type])
			valid_customizations[quirk_type] = quirk_customizations[quirk_type]
		var/list/extra_values = quirk_extra_customizations[quirk_type]
		if(islist(extra_values) && length(extra_values))
			valid_extra_customizations[quirk_type] = extra_values.Copy()

		qdel(Q)

	// Update the quirk lists to only valid quirks
	var/had_invalid_quirks = length(quirks) != length(valid_quirks)
	quirks = valid_quirks
	quirk_customizations = valid_customizations
	quirk_extra_customizations = valid_extra_customizations

	quirks = sort_quirks(quirks)

	var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_ARM)
	if(!O)
		H.regenerate_limb(BODY_ZONE_R_ARM)
	O = H.get_bodypart(BODY_ZONE_L_ARM)
	if(!O)
		H.regenerate_limb(BODY_ZONE_L_ARM)

	// Apply valid quirks to character
	for(var/quirk_type in quirks)
		var/custom_val = quirk_customizations[quirk_type]
		var/list/extra_val = quirk_extra_customizations[quirk_type]
		H.add_quirk(quirk_type, custom_val, extra_val)

	// Save if anything changed
	if(had_invalid_quirks)
		save_character()

/datum/preferences/proc/open_quirk_menu(mob/user)
	var/datum/browser/popup = new(user, "quirk_menu", "Quirk Selection", 1000, 650, src)

	popup.add_stylesheet("quirk_menu", 'html/browser/quirk_menu.css')
	popup.add_script("quirk_menu", 'html/browser/quirk_menu.js')

	popup.set_content(get_quirk_menu_content())
	popup.open()

/datum/preferences/proc/get_quirk_menu_content()
	var/balance = calculate_quirk_balance()
	var/boon_count = count_boons_in_list()

	var/dat = ""

	// Header with point balance
	dat += "<div class='quirk-header'>"
	dat += "<div class='quirk-stats'>"
	dat += "<span class='stat-label'>Point Balance:</span> <span class='stat-value [balance < 0 ? "negative" : ""]'>[balance]</span>"
	dat += "<span class='stat-separator'>|</span>"
	dat += "<span class='stat-label'>Positive:</span> <span class='stat-value [boon_count >= MAX_POSITIVE ? "at-limit" : ""]'>[boon_count]/[MAX_POSITIVE]</span>"
	dat += "</div>"
	dat += "<div class='quirk-actions'>"
	dat += "<a href='byond://?src=\ref[src];quirk_clear=1' class='action-button clear-button'>Clear All</a>"
	dat += "</div>"
	dat += "</div>"

	// Two column layout
	dat += "<div class='quirk-container'>"

	// Left column - Available quirks with tabs
	dat += "<div class='quirk-left'>"
	dat += "<div class='panel-header'>Available Quirks</div>"

	// Tab navigation
	dat += "<div class='quirk-tabs'>"
	dat += "<button class='tab-button active' data-tab='boons'>Positive</button>"
	dat += "<button class='tab-button' data-tab='vices'>Negative</button>"
	dat += "<button class='tab-button' data-tab='peculiarities'>Neutral</button>"
	dat += "</div>"

	// Tab content
	dat += "<div class='tab-panels'>"

	// Boons tab
	dat += "<div class='tab-panel active' id='tab-boons'>"
	dat += get_quirk_category_content(QUIRK_POSITIVE, "positive")
	dat += "</div>"

	// Vices tab
	dat += "<div class='tab-panel' id='tab-vices'>"
	dat += get_quirk_category_content(QUIRK_NEGATIVE, "negative")
	dat += "</div>"

	// Peculiarities tab
	dat += "<div class='tab-panel' id='tab-peculiarities'>"
	dat += get_quirk_category_content(QUIRK_NEUTRAL, "neutral")
	dat += "</div>"

	dat += "</div>" // tab-panels
	dat += "</div>" // quirk-left

	// Right column - Selected quirks
	dat += "<div class='quirk-right'>"
	dat += "<div class='panel-header'>Selected Quirks ([length(quirks)])</div>"
	dat += "<div class='selected-panel' id='selected-panel'>"
	dat += get_selected_quirks_content()
	dat += "</div>"
	dat += "</div>" // quirk-right

	dat += "</div>" // quirk-container

	return dat

/datum/preferences/proc/get_quirk_category_content(category, category_class)
	var/dat = "<div class='quirk-list'>"

	for(var/quirk_data in GLOB.quirk_points_by_type[category])
		var/quirk_type = quirk_data["type"]
		var/is_selected = FALSE
		if(quirk_type in quirks)
			is_selected = TRUE
		var/refusal = is_selected ? null : quirk_refusal_reason(quirk_type)
		var/can_add = isnull(refusal)

		var/card_classes = "quirk-card [category_class]"
		if(is_selected)
			card_classes += " selected"
		else if(!can_add)
			card_classes += " disabled"

		dat += "<div class='[card_classes]' data-quirk='\ref[quirk_type]'>"
		dat += "<div class='quirk-card-header'>"
		dat += "<span class='quirk-name'>[quirk_data["name"]]</span>"
		dat += "<span class='quirk-points'>[quirk_data["value"]] pts</span>"
		dat += "</div>"
		dat += "<div class='quirk-desc'>[quirk_data["desc"]]</div>"
		dat += "<div class='quirk-desc_hint'>[quirk_data["desc_hint"]]</div>"

		if(is_selected)
			dat += "<div class='quirk-status'>Selected</div>"
		else if(!can_add)
			dat += "<div class='quirk-status disabled-text'>[html_encode(refusal)]</div>"
		dat += "</div>"

	dat += "</div>"
	return dat

/datum/preferences/proc/get_selected_quirks_content()
	if(!length(quirks))
		return "<div class='empty-state'>No quirks selected.<br><br>Click on quirks from the left panel to add them.</div>"

	var/dat = "<div class='quirk-list'>"

	for(var/quirk_type in quirks)
		var/datum/quirk/quirk = GLOB.quirk_singletons[quirk_type]
		var/category = quirk.quirk_category
		var/category_class = ""

		switch(category)
			if(QUIRK_POSITIVE)
				category_class = "positive"
			if(QUIRK_NEGATIVE)
				category_class = "negative"
			if(QUIRK_NEUTRAL)
				category_class = "neutral"

		dat += "<div class='quirk-card [category_class] selected' data-quirk='\ref[quirk_type]'>"
		dat += "<div class='quirk-card-header'>"
		dat += "<span class='quirk-name'>[quirk.name]</span>"
		dat += "<span class='quirk-points'>[quirk.point_value] pts</span>"
		dat += "</div>"
		dat += "<div class='quirk-desc'>[quirk.get_desc(src)]</div>"
		dat += "<div class='quirk-desc_hint'>[quirk.get_desc_hint(src)]</div>"

		var/custom_type = quirk.customization_type
		var/list/options = quirk?.return_customization(src)

		if(custom_type == QUIRK_TEXT)
			// Text input customization
			var/label = quirk.customization_label
			var/placeholder = quirk.customization_placeholder
			var/current_value = quirk_customizations[quirk_type]

			dat += "<div class='quirk-customization'>"
			dat += "<label>[label]:</label>"
			dat += "<input type='text' class='quirk-text-input' data-quirk='\ref[quirk_type]' "
			dat += "placeholder='[placeholder]' value='[current_value ? current_value : ""]' "
			dat += "onclick='event.stopPropagation()' />"
			dat += "</div>"

		else if(length(options))
			// Dropdown customization
			var/label = quirk.customization_label
			var/current_value = quirk_customizations[quirk_type]

			dat += "<div class='quirk-customization'>"
			dat += "<label>[label]:</label>"
			dat += "<select class='quirk-select' data-quirk='\ref[quirk_type]'>"

			if(!current_value)
				dat += "<option value='' selected>-- Select --</option>"

			for(var/option in options)
				var/option_name = quirk.get_option_name(option)
				var/selected = (current_value == option) ? "selected" : ""
				dat += "<option value='\ref[option]' [selected]>[option_name]</option>"

			dat += "</select>"
			dat += "</div>"

		// Extra customization fields
		var/list/extra_fields = quirk.extra_customization_fields
		if(LAZYLEN(extra_fields))
			for(var/list/field in extra_fields)
				var/field_key = field["key"]
				var/field_label = field["label"]
				var/field_type = field["type"]
				var/field_current = get_quirk_extra_customization(quirk_type, field_key)
				if(isnull(field_current))
					field_current = field["default"]

				dat += "<div class='quirk-customization'>"
				dat += "<label>[field_label]:</label>"

				if(field_type == QUIRK_TEXT)
					var/field_placeholder = field["placeholder"] || ""
					var/field_value = field_current ? field_current : ""
					var/field_max_length = field["max_length"] || 64
					if(field["multiline"])
						dat += "<textarea class='quirk-text-input' data-quirk='\ref[quirk_type]' data-field='[field_key]' "
						dat += "placeholder='[escape_html_attribute(field_placeholder)]' onclick='event.stopPropagation()' "
						dat += "maxlength='[field_max_length]' rows='4'>[html_encode(field_value)]</textarea>"
					else
						dat += "<input type='text' class='quirk-text-input' data-quirk='\ref[quirk_type]' data-field='[field_key]' "
						dat += "placeholder='[escape_html_attribute(field_placeholder)]' value='[escape_html_attribute(field_value)]' "
						dat += "onclick='event.stopPropagation()' maxlength='[field_max_length]' />"

				else if(field_type == QUIRK_NUMBER)
					var/field_min = field["min"] || 1
					var/field_max = field["max"] || 10
					dat += "<input type='number' class='quirk-text-input' data-quirk='\ref[quirk_type]' data-field='[field_key]' "
					dat += "value='[field_current]' min='[field_min]' max='[field_max]' "
					dat += "onclick='event.stopPropagation()' />"

				else if(field_type == QUIRK_SELECT)
					var/list/field_options = field["options"]
					dat += "<select class='quirk-select' data-quirk='\ref[quirk_type]' data-field='[field_key]'>"
					for(var/opt in field_options)
						var/opt_selected = (field_current == opt) ? "selected" : ""
						dat += "<option value='[opt]' [opt_selected]>[opt]</option>"
					dat += "</select>"

				else if(field_type == QUIRK_COLOR)
					var/field_value = field_current ? field_current : ""
					var/display_color = sanitize_oviposition_color(field_value)
					if(!display_color)
						display_color = "#eee3c7"
					dat += "<div class='quirk-color-row'>"
					dat += "<span class='quirk-color-swatch' style='background-color: [display_color];'></span>"
					dat += "<span class='quirk-color-value'>[field_value ? html_encode(field_value) : "Default"]</span>"
					dat += "<button type='button' class='quirk-color-button' data-quirk='\ref[quirk_type]' data-field='[field_key]' onclick='event.stopPropagation(); pickQuirkColor(this);'>Set Colour</button>"
					if(field_value)
						dat += "<button type='button' class='quirk-color-button reset' data-quirk='\ref[quirk_type]' data-field='[field_key]' onclick='event.stopPropagation(); resetQuirkColor(this);'>Reset</button>"
					dat += "</div>"

				dat += "</div>"

		dat += "<div class='quirk-status'>Click to remove</div>"
		dat += "</div>"

	dat += "</div>"
	return dat

/mob/living/carbon/human/proc/apply_character_quirks()
	if(client?.prefs)
		client.prefs.apply_quirks_to_character(src)

/client/Topic(href, href_list)
	. = ..()
	if(href_list["quirk_add"])
		var/quirk_ref = locate(href_list["quirk_add"])
		if(quirk_ref && ispath(quirk_ref, /datum/quirk))
			if(prefs.add_quirk(quirk_ref, user = usr))
				prefs.open_quirk_menu(usr)
		return TRUE

	if(href_list["quirk_remove"])
		var/quirk_ref = locate(href_list["quirk_remove"])
		if(quirk_ref)
			prefs.remove_quirk(quirk_ref)
			prefs.open_quirk_menu(usr)
		return TRUE

	if(href_list["quirk_customize"])
		var/quirk_ref = locate(href_list["quirk_customize"])
		var/value_ref = href_list["value"] // Can be a reference or plain text now

		if(quirk_ref)
			// Try to locate the value (for dropdown options)
			var/actual_value = locate(value_ref)
			if(!actual_value)
				// If locate fails, it's plain text (for text inputs)
				actual_value = value_ref

			prefs.set_quirk_customization(quirk_ref, actual_value)
			prefs.open_quirk_menu(usr)
		return TRUE

	if(href_list["quirk_text_update"])
		var/quirk_ref = locate(href_list["quirk_text_update"])
		var/text_value = href_list["text"]

		if(quirk_ref)
			prefs.set_quirk_customization(quirk_ref, text_value)
		return TRUE

	if(href_list["quirk_extra_field"])
		var/quirk_ref = locate(href_list["quirk_extra_field"])
		var/field_key = href_list["field_key"]
		var/field_value = href_list["field_value"]

		if(quirk_ref && field_key)
			prefs.set_quirk_extra_customization(quirk_ref, field_key, field_value)
		return TRUE

	if(href_list["quirk_color_field"])
		var/quirk_ref = locate(href_list["quirk_color_field"])
		var/field_key = href_list["field_key"]

		if(quirk_ref && field_key)
			var/current_color = prefs.get_quirk_extra_customization(quirk_ref, field_key)
			if(!sanitize_oviposition_color(current_color))
				current_color = "#eee3c7"
			var/new_color = tgui_color_picker(usr, "Choose the custom egg color.", "Egg Color", current_color)
			if(new_color)
				prefs.set_quirk_extra_customization(quirk_ref, field_key, new_color)
				prefs.open_quirk_menu(usr)
		return TRUE

	if(href_list["quirk_color_reset"])
		var/quirk_ref = locate(href_list["quirk_color_reset"])
		var/field_key = href_list["field_key"]

		if(quirk_ref && field_key)
			prefs.set_quirk_extra_customization(quirk_ref, field_key, "")
			prefs.open_quirk_menu(usr)
		return TRUE

	if(href_list["quirk_clear"])
		prefs.clear_quirks()
		prefs.open_quirk_menu(usr)
		return TRUE

	if(href_list["quirk_close"])
		var/mob/user = usr
		user << browse(null, "window=quirk_menu")
		return TRUE
