/// Pass enforce_genital_rules = FALSE to sanitize the entry list without touching which genital
/// entries are enabled. Only load_customizer_and_quirk_data() needs that, because the rules
/// depend on quirks that have not been read out of the savefile yet.
/datum/preferences/proc/validate_customizer_entries(enforce_genital_rules = TRUE)
	customizer_entries = SANITIZE_LIST(customizer_entries)
	list_clear_nulls(customizer_entries)
	var/datum/species/species = pref_species
	var/list/customizers = species.customizers
	/// Check if we have any customizer entries that don't match.
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/validated = FALSE
		for(var/customizer_type in customizers)
			if(customizer_type != entry.customizer_type)
				continue
			var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
			if(!(entry.customizer_choice_type in customizer.customizer_choices))
				continue
			var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
			if(entry.type != customizer_choice.customizer_entry_type)
				continue
			validated = TRUE
			break

		if(!validated)
			customizer_entries -= entry

	/// Check if we have any missing customizer entries
	for(var/customizer_type in customizers)
		var/found = FALSE
		for(var/datum/customizer_entry/entry as anything in customizer_entries)
			if(entry.customizer_type != customizer_type)
				continue
			found = TRUE
			break
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!found)
			customizer_entries += customizer.make_default_customizer_entry(src, FALSE)

	/// Validate the variables within customizer entries
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		customizer_choice.validate_entry(src, entry)

	if(enforce_genital_rules)
		enforce_genital_access_rules()

/datum/preferences/proc/print_customizers_page()
	var/list/dat = list()
	. = dat
	if(!pref_species)
		return

	// Keep older or partially initialized preference records from opening a broken customizer UI.
	validate_customizer_entries()

	var/list/customizers = pref_species.customizers
	if(!customizers)
		return
	dat += "<div class='genital-set-card'>"
	dat += "<div><b>Genital Set:</b> [get_current_genital_set_label()]</div>"
	dat += "<a href='byond://?_src_=prefs;task=change_customizer;customizer_task=toggle_genital_set'>Toggle Genitals</a>"
	if(has_extra_genital_customizer_unlock())
		dat += (pref_species?.id == SPEC_ID_OOZE ? "<small>Oozes can mix and match genital features.</small>" : "<small>Extra Genitals lets you mix and match genital features.</small>")
	else
		dat += "<small>You can swap between complete masculine and feminine sets.</small>"
	dat += "</div>"
	dat += "<div class='feature-grid'>"
	for(var/customizer_type in customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer.is_allowed(src))
			continue
		var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
		if(!entry)
			stack_trace("Missing customizer entry in preferences for customizer [customizer_type]")
			continue
		if(!can_access_gendered_genital_entry(entry))
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)

		var/card_class = entry.disabled ? "feature-card disabled" : "feature-card"
		dat += "<div class='[card_class]'>"
		if(customizer.allows_disabling)
			var/title_status = entry.disabled ? "Enable" : "Disable"
			dat += "<a class='feature-title' href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=toggle_missing'>[customizer.name]<small>[title_status]</small></a>"
		else
			dat += "<div class='feature-title static'>[customizer.name]<small>Fixed</small></div>"
		if(!entry.disabled)
			var/choice_link
			if(length(customizer.customizer_choices) > 1)
				choice_link = "href='byond://?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=change_choice'"
			else
				choice_link = "class='linkOff'"
			if(length(customizer.customizer_choices) > 1)
				dat += "<a class='feature-choice' [choice_link]>[choice.name]<small>Change type</small></a>"
			else
				dat += "<div class='feature-choice static'>[choice.name]</div>"

			var/list/choice_list = choice.show_pref_choices(src, entry, customizer_type)
			if(choice_list)
				dat += "<div class='feature-controls'>"
				dat += choice_list
				dat += "</div>"
		else
			dat += "<div class='muted'>Disabled</div>"

		dat += "</div>"
	dat += "</div>"
	return

/// We dont associate the entries just to be safer for save/load, so we can't lookup easily and we do this.
/datum/preferences/proc/get_customizer_entry_for_customizer_type(customizer_type)
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(entry.customizer_type == customizer_type)
			return entry

/datum/preferences/proc/get_customizer_entry_for_entry_type(entry_type)
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(istype(entry, entry_type))
			return entry

/datum/preferences/proc/has_enabled_customizer_entry_type(entry_type)
	var/datum/customizer_entry/entry = get_customizer_entry_for_entry_type(entry_type)
	return entry && !entry.disabled

/datum/preferences/proc/set_customizer_entry_type_enabled(entry_type, enabled)
	var/datum/customizer_entry/entry = get_customizer_entry_for_entry_type(entry_type)
	if(entry)
		if(entry.disabled == !enabled)
			return FALSE
		entry.disabled = !enabled
		return TRUE
	return FALSE

/datum/preferences/proc/has_selected_quirk(quirk_type)
	return islist(quirks) && (quirk_type in quirks)

/datum/preferences/proc/has_extra_genital_customizer_unlock()
	return pref_species?.id == SPEC_ID_OOZE || has_selected_quirk(/datum/quirk/neutral/extra_genitals)

/datum/preferences/proc/has_ovipositor_customizer_override()
	return has_selected_quirk(/datum/quirk/neutral/ovipositor)

/datum/preferences/proc/has_generous_figure_size_unlock()
	return has_selected_quirk(/datum/quirk/neutral/generous_figure)

/datum/preferences/proc/get_max_breast_size()
	return has_generous_figure_size_unlock() ? MAX_BREASTS_SIZE : BREAST_SIZE_LARGE

/datum/preferences/proc/get_max_butt_size()
	return has_generous_figure_size_unlock() ? MAX_BUTT_SIZE : BUTT_SIZE_MEDIUM

/datum/preferences/proc/get_max_belly_size()
	return has_generous_figure_size_unlock() ? MAX_BELLY_SIZE : BELLY_SIZE_MEDIUM

/proc/sanitize_body_size_by_max(size, min_size, max_size, default_size)
	if(isnum(size) && round(size) > max_size)
		return max_size
	return sanitize_integer(size, min_size, max_size, default_size)

/datum/preferences/proc/get_named_body_size_choices(list/named_sizes, max_size)
	var/list/allowed_sizes = list()
	if(!islist(named_sizes))
		return allowed_sizes
	for(var/size_name in named_sizes)
		if(named_sizes[size_name] <= max_size)
			allowed_sizes[size_name] = named_sizes[size_name]
	return allowed_sizes

/datum/preferences/proc/sanitize_body_size_choice(size, min_size, max_size, default_size)
	return sanitize_body_size_by_max(size, min_size, max_size, default_size)

/datum/preferences/proc/get_breast_size_choices()
	return get_named_body_size_choices(BREAST_SIZES_BY_NAME, get_max_breast_size())

/datum/preferences/proc/get_butt_size_choices()
	return get_named_body_size_choices(BUTT_SIZES_BY_NAME, get_max_butt_size())

/datum/preferences/proc/get_belly_size_choices()
	return get_named_body_size_choices(BELLY_SIZES_BY_NAME, get_max_belly_size())

/datum/preferences/proc/get_body_type_genital_set()
	if(read_preference(/datum/preference/choiced/gender) == FEMALE)
		return "feminine"
	return "masculine"

/datum/preferences/proc/get_entry_genital_set(datum/customizer_entry/entry)
	if(istype(entry, /datum/customizer_entry/organ/genitals/penis) || istype(entry, /datum/customizer_entry/organ/genitals/testicles))
		return "masculine"
	if(istype(entry, /datum/customizer_entry/organ/genitals/breasts) || istype(entry, /datum/customizer_entry/organ/genitals/vagina) || istype(entry, /datum/customizer_entry/organ/genitals/womb))
		return "feminine"
	return null

/datum/preferences/proc/is_gendered_genital_entry(datum/customizer_entry/entry)
	return !!get_entry_genital_set(entry)

/datum/preferences/proc/can_access_gendered_genital_entry(datum/customizer_entry/entry)
	var/genital_set = get_entry_genital_set(entry)
	if(!genital_set)
		return TRUE
	if(has_extra_genital_customizer_unlock())
		return TRUE
	if(istype(entry, /datum/customizer_entry/organ/genitals/penis) && has_ovipositor_customizer_override())
		return TRUE
	return genital_set == get_preferred_genital_set()

/datum/preferences/proc/has_any_enabled_genital_entry()
	return has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/penis) \
		|| has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/testicles) \
		|| has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/breasts) \
		|| has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/vagina)

/datum/preferences/proc/species_has_masculine_genital_set()
	return get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/penis) && get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/testicles)

/datum/preferences/proc/species_has_feminine_genital_set()
	return get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/breasts) && get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/vagina)

/datum/preferences/proc/has_masculine_genital_set()
	return has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/penis) && has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/testicles)

/datum/preferences/proc/has_feminine_genital_set()
	return has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/breasts) && has_enabled_customizer_entry_type(/datum/customizer_entry/organ/genitals/vagina)

/datum/preferences/proc/get_preferred_genital_set()
	if(has_masculine_genital_set())
		return "masculine"
	if(has_feminine_genital_set())
		return "feminine"
	return get_body_type_genital_set()

/datum/preferences/proc/get_current_genital_set_label()
	var/has_masculine = has_masculine_genital_set()
	var/has_feminine = has_feminine_genital_set()
	if(has_masculine && has_feminine)
		return "Mixed"
	if(has_masculine)
		return "Masculine"
	if(has_feminine)
		return "Feminine"
	return "Unset"

/datum/preferences/proc/set_genital_set(genital_set)
	var/masculine = genital_set == "masculine"
	. = FALSE
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/penis, masculine)
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/testicles, masculine)
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/breasts, !masculine)
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/vagina, !masculine)

/// Enables every gendered genital entry at once. Only legal with the Extra Genitals unlock.
/datum/preferences/proc/set_mixed_genital_set()
	. = FALSE
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/penis, TRUE)
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/testicles, TRUE)
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/breasts, TRUE)
	. |= set_customizer_entry_type_enabled(/datum/customizer_entry/organ/genitals/vagina, TRUE)

/datum/preferences/proc/toggle_genital_set()
	// A mixed set is a state the player deliberately built, so with Extra Genitals the toggle
	// cycles through it (mixed -> masculine -> feminine -> mixed) instead of silently
	// discarding half of the selection on the first press.
	if(has_extra_genital_customizer_unlock() && species_has_masculine_genital_set() && species_has_feminine_genital_set())
		var/had_masculine = has_masculine_genital_set()
		var/had_feminine = has_feminine_genital_set()
		if(had_masculine && had_feminine)
			set_genital_set("masculine")
		else if(had_masculine)
			set_genital_set("feminine")
		else
			set_mixed_genital_set()
	else if(has_masculine_genital_set() && !has_feminine_genital_set())
		set_genital_set("feminine")
	else
		set_genital_set("masculine")
	apply_genital_quirk_overrides()

/datum/preferences/proc/enforce_required_genital_set(preferred_set)
	return enforce_genital_access_rules(preferred_set)

/datum/preferences/proc/enforce_genital_access_rules(preferred_set)
	. = FALSE
	if(has_extra_genital_customizer_unlock())
		if(!has_any_enabled_genital_entry())
			if(!preferred_set)
				preferred_set = get_body_type_genital_set()
			. |= set_genital_set(preferred_set)
		. |= apply_genital_quirk_overrides()
		return

	var/current_set
	if(has_masculine_genital_set() && !has_feminine_genital_set())
		current_set = "masculine"
	else if(has_feminine_genital_set() && !has_masculine_genital_set())
		current_set = "feminine"

	if(!preferred_set)
		preferred_set = current_set || get_body_type_genital_set()

	if(preferred_set == "feminine" && species_has_feminine_genital_set())
		. |= set_genital_set("feminine")
	else if(preferred_set == "masculine" && species_has_masculine_genital_set())
		. |= set_genital_set("masculine")
	else if(species_has_masculine_genital_set())
		. |= set_genital_set("masculine")
	else if(species_has_feminine_genital_set())
		. |= set_genital_set("feminine")

	. |= apply_genital_quirk_overrides()

/datum/preferences/proc/apply_genital_quirk_overrides()
	. = FALSE
	if(has_ovipositor_customizer_override())
		. |= force_ovipositor_genital_entry()

/datum/preferences/proc/force_ovipositor_genital_entry()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/penis)
	if(!penis_entry)
		return FALSE

	var/datum/customizer/penis_customizer = CUSTOMIZER(penis_entry.customizer_type)
	if(!(/datum/customizer_choice/organ/genitals/penis/ovipositor in penis_customizer.customizer_choices))
		return FALSE

	. = FALSE
	if(penis_entry.customizer_choice_type != /datum/customizer_choice/organ/genitals/penis/ovipositor)
		var/old_size = penis_entry.penis_size
		var/old_length = penis_entry.penis_length_cm
		var/old_functional = penis_entry.functional
		customizer_entries -= penis_entry
		qdel(penis_entry)
		penis_entry = penis_customizer.create_customizer_entry(src, /datum/customizer_choice/organ/genitals/penis/ovipositor)
		penis_entry.penis_size = old_size
		penis_entry.penis_length_cm = old_length
		penis_entry.functional = old_functional
		customizer_entries += penis_entry
		. = TRUE
	if(penis_entry.disabled)
		penis_entry.disabled = FALSE
		. = TRUE

/datum/preferences/proc/can_support_ovipositor_genitals()
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/penis)
	if(!penis_entry)
		return FALSE
	var/datum/customizer/penis_customizer = CUSTOMIZER(penis_entry.customizer_type)
	return /datum/customizer_choice/organ/genitals/penis/ovipositor in penis_customizer.customizer_choices

/datum/preferences/proc/has_both_gendered_genital_sets()
	return species_has_masculine_genital_set() && species_has_feminine_genital_set()

/datum/preferences/proc/cleanup_quirks_for_customizer_entry(datum/customizer_entry/entry)
	return FALSE

/// Gets an associative list of organ slots to organ dna created from organ customization
/datum/preferences/proc/get_organ_dna_list()
	enforce_genital_access_rules()
	var/list/organ_list = list()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		if(entry.disabled)
			continue
		var/datum/organ_dna/dna = customizer_choice.create_organ_dna(entry, src)
		if(!dna)
			continue
		organ_list[customizer_choice.get_organ_slot()] = dna

	return organ_list

/datum/preferences/proc/customize_organ(obj/item/organ/organ)
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		if(entry.disabled)
			continue
		if(!(customizer_choice.get_organ_slot() == organ.slot))
			continue
		customizer_choice.customize_organ(organ, entry)

/datum/preferences/proc/apply_customizers_to_character(mob/living/carbon/human/human)
	enforce_genital_access_rules()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		if(entry.disabled)
			continue
		customizer_choice.apply_customizer_to_character(human, src, entry)

/datum/preferences/proc/handle_customizer_topic(mob/user, href_list)
	//needs_update = TRUE
	if(href_list["customizer_task"] == "toggle_genital_set")
		toggle_genital_set()
		mark_preview_appearance_dirty()
		return
	var/previous_genital_set = get_preferred_genital_set()
	var/customizer_type = text2path(href_list["customizer"])
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
	if(!entry)
		return
	if(!can_access_gendered_genital_entry(entry))
		to_chat(user, span_warning("That genital customizer is not available for your current set."))
		enforce_genital_access_rules()
		mark_preview_appearance_dirty()
		return
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	switch(href_list["customizer_task"])
		if("toggle_missing")
			if(customizer.allows_disabling)
				entry.disabled = !entry.disabled
				if(entry.disabled)
					cleanup_quirks_for_customizer_entry(entry)
		if("change_choice")
			var/list/choice_list = list()
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				choice_list[iter_choice.name] = choice_type
			var/chosen_input = input(user, "Choose your [LOWER_TEXT(customizer.name)]:", "Character Preference")  as null|anything in choice_list
			if(!chosen_input)
				return
			var/choice_type = choice_list[chosen_input]
			if(choice_type == choice.type)
				return
			customizer_entries -= entry
			entry = customizer.create_customizer_entry(src, choice_type)
			customizer_entries += entry
			cleanup_quirks_for_customizer_entry(entry)
		else
			choice.handle_topic(user, href_list, src, entry, customizer_type)
	if(enforce_genital_access_rules(previous_genital_set))
		to_chat(user, span_warning("Your genital selection was adjusted to match your available set."))
	mark_preview_appearance_dirty()

/datum/preferences/proc/reset_all_customizer_accessory_colors()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		choice.reset_accessory_colors(src, entry)

/datum/preferences/proc/randomize_all_customizer_accessories()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		choice.randomize_entry(entry, src)

/datum/preferences/proc/ShowCustomizers(mob/user)
	var/list/dat = list()
	dat += {"
	<html lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<style>
			body {
				margin: 0;
				background: #1a1a1a;
				color: #d8cf9f;
				font-family: Verdana, Geneva, sans-serif;
				font-size: 12px;
			}
			.wrap {
				padding: 14px;
			}
			.panel {
				background: #2a2723;
				border: 2px solid #5b4b40;
				box-shadow: inset 0 0 0 1px #141211;
				padding: 12px;
			}
			h2 {
				margin: 0 0 10px;
				color: #eee69c;
				font-size: 16px;
				text-transform: uppercase;
				letter-spacing: 0;
			}
			a {
				color: #eee69c;
				font-weight: bold;
				text-decoration: none;
			}
			a:hover {
				color: #f1e78b;
			}
			.genital-set-card {
				background: #342d28;
				border: 1px solid #5b4b40;
				box-shadow: inset 0 0 0 1px #171515;
				margin-bottom: 12px;
				padding: 9px 10px;
				text-align: center;
			}
			.genital-set-card small {
				display: block;
				color: #9f9377;
				margin-top: 3px;
			}
			.feature-grid {
				text-align: left;
			}
			.feature-card {
				display: inline-block;
				vertical-align: top;
				width: 31.8%;
				min-height: 138px;
				box-sizing: border-box;
				background: #342d28;
				border: 1px solid #5b4b40;
				box-shadow: inset 0 0 0 1px #171515;
				margin: 0 1% 10px 0;
				padding: 8px;
			}
			.feature-card.disabled {
				background: #211f1d;
				opacity: 0.78;
			}
			.feature-title {
				display: block;
				background: #705d4f;
				border: 1px solid #171515;
				color: #161418;
				font-weight: bold;
				margin-bottom: 6px;
				padding: 6px 7px;
				text-transform: uppercase;
			}
			.feature-title:hover {
				background: #8b735f;
				color: #161418;
			}
			.feature-title small {
				float: right;
				color: #2b2320;
				font-weight: normal;
				text-transform: none;
			}
			.feature-title.static {
				cursor: default;
			}
			.feature-choice {
				display: block;
				background: #171515;
				border: 1px solid #5b4b40;
				margin-bottom: 7px;
				padding: 5px 7px;
			}
			.feature-choice small {
				display: block;
				color: #8f846c;
				font-weight: normal;
				margin-top: 2px;
			}
			.feature-choice.static {
				color: #bcae82;
				font-weight: bold;
			}
			.feature-controls {
				color: #d8cf9f;
				line-height: 1.55;
			}
			.feature-controls a {
				color: #eee69c;
			}
			.linkOff {
				color: #8f846c !important;
			}
			.muted {
				color: #8f846c;
				margin-top: 8px;
			}
			.accessory-box {
				text-align: center;
				margin: 9px 0;
			}
			.accessory-frame {
				background: #161418;
				border: 1px solid #5b4b40;
				display: inline-block;
				padding: 8px;
			}
			.accessory-preview {
				margin-bottom: 5px;
				line-height: 64px;
				min-height: 64px;
			}
			.accessory-preview img {
				height: 64px;
				image-rendering: pixelated;
				vertical-align: middle;
				width: 64px;
			}
			.accessory-controls {
				margin-top: 5px;
			}
			.accessory-arrow {
				font-size: 16px;
				padding: 0 5px;
			}
			.accessory-dropdown {
				background: #1d1a17;
				border: 1px solid #5b4b40;
				margin: 9px 0;
				max-height: 300px;
				overflow-y: auto;
				padding: 8px;
			}
			.accessory-grid-card {
				display: inline-block;
				vertical-align: top;
				width: 92px;
				min-height: 96px;
				background: #161418;
				border: 1px solid #43372f;
				margin: 3px;
				padding: 5px;
				text-align: center;
			}
			.accessory-grid-card.selected {
				border-color: #eee69c;
			}
			.accessory-grid-card img {
				display: block;
				height: 64px;
				image-rendering: pixelated;
				margin: 0 auto;
				width: 64px;
			}
			.accessory-grid-label {
				color: #d8cf9f;
				font-size: 10px;
				margin-top: 3px;
			}
			.accessory-grid-card.selected .accessory-grid-label {
				color: #eee69c;
			}
			.color_holder_box {
				display: inline-block;
				width: 24px;
				height: 10px;
				border: 1px solid #161616;
				padding: 0;
				vertical-align: middle;
			}
			.footer {
				margin-top: 12px;
				text-align: right;
			}
		</style>
	</head>
	<body>
		<div class="wrap">
			<div class="panel">
				<h2>Features</h2>
	"}
	dat += print_customizers_page()
	dat += {"
				<div class="footer"><a href='byond://?_src_=prefs;preference=body_customize;task=menu'>Customize Appearance</a></div>
			</div>
		</div>
		<script>
			(function() {
				function getDirection(step) {
					switch(step) {
						case 1:
							return "&dir=4";
						case 2:
							return "&dir=8";
						case 3:
							return "&dir=1";
					}
					return "";
				}
				function setPreview(card, step) {
					var img = card.getElementsByTagName("img").item(0);
					if(!img) {
						return;
					}
					img.src = card.getAttribute("data-icon") + "?state=" + card.getAttribute("data-state") + getDirection(step);
				}
				function wireCard(card) {
					if(!card.addEventListener) {
						return;
					}
					card.addEventListener("mouseenter", function() {
						card.spinStep = 0;
						card.spinTimer = setInterval(function() {
							card.spinStep = (card.spinStep + 1) % 4;
							setPreview(card, card.spinStep);
						}, 200);
					});
					card.addEventListener("mouseleave", function() {
						clearInterval(card.spinTimer);
						card.spinStep = 0;
						setPreview(card, 0);
					});
				}
				var divs = document.getElementsByTagName("div");
				var i = 0;
				while(i < divs.length) {
					var card = divs.item(i);
					if((" " + card.className + " ").indexOf(" accessory-grid-card ") >= 0) {
						wireCard(card);
					}
					i++;
				}
			})();
		</script>
	</body>
	</html>
	"}
	var/datum/browser/popup = new(user, "customization", "<div align='center'>Customization</div>", 630, 730)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/get_hair_color()
	var/datum/customizer_entry/hair/entry = get_customizer_entry_of_type(/datum/customizer_entry/hair/head)
	if(entry)
		return entry.hair_color
	else
		return "FFFFFF"

/datum/preferences/proc/get_facial_hair_color()
	var/datum/customizer_entry/hair/entry = get_customizer_entry_of_type(/datum/customizer_entry/hair/facial)
	if(entry)
		return entry.hair_color
	else
		return "FFFFFF"

/datum/preferences/proc/get_eye_color(side = RIGHT_SIDE)
	var/datum/customizer_entry/organ/eyes/entry = get_customizer_entry_of_type(/datum/customizer_entry/organ/eyes)
	if(!entry)
		return "FFFFFF"
	return (side == RIGHT_SIDE) ? entry.right_eye_color : entry.left_eye_color

/datum/preferences/proc/get_chest_color()
	var/list/zone_list = body_markings[BODY_ZONE_CHEST]
	if(!zone_list)
		return null
	for(var/marking_name in zone_list)
		var/datum/body_marking/marking = GLOB.body_markings[marking_name]
		if(!marking.covers_chest)
			continue
		var/marking_color = zone_list[marking_name]
		return marking_color
	return null

/datum/preferences/proc/get_customizer_entry_of_type(entry_type)
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(entry.type == entry_type)
			return entry
	return null

/datum/preferences/proc/has_enabled_customizer_entry(entry_type)
	var/datum/customizer_entry/entry = get_customizer_entry_of_type(entry_type)
	return entry && !entry.disabled


/datum/preferences/proc/genderize_customizer_entries()
	customizer_entries = SANITIZE_LIST(customizer_entries)
	set_genital_set(get_body_type_genital_set())
	apply_genital_quirk_overrides()

/datum/preferences/proc/clear_flavor()
	write_preference(/datum/preference/text/flavortext, null)
	write_preference(/datum/preference/text/flavortext_display, null)
	write_preference(/datum/preference/text/nsfwflavortext, null)
	write_preference(/datum/preference/text/erpprefs_flavor, null)
	write_preference(/datum/preference/text/ooc_notes, null)
	write_preference(/datum/preference/text/ooc_notes_display, null)
	write_preference(/datum/preference/text/ooc_extra, null)
	write_preference(/datum/preference/text/ooc_extra_link, null)
	write_preference(/datum/preference/text/song_title, null)
	write_preference(/datum/preference/text/song_artist, null)
	write_preference(/datum/preference/text/song_link, null)
	write_preference(/datum/preference/text/headshot_link, null)
	write_preference(/datum/preference/text/nsfw_headshot_link, null)
	write_preference(/datum/preference/list_type/profile_gallery/images, list())
	write_preference(/datum/preference/list_type/profile_gallery/nsfw_images, list())
