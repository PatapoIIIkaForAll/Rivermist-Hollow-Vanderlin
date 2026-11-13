GLOBAL_LIST_INIT(quirk_registry, list())
GLOBAL_LIST_EMPTY(quirk_singletons)
GLOBAL_LIST_EMPTY(quirk_points_by_type)

/proc/init_quirk_registry()
	GLOB.quirk_registry = list()
	GLOB.quirk_points_by_type = list(
		QUIRK_POSITIVE = list(),
		QUIRK_NEGATIVE = list(),
		QUIRK_NEUTRAL = list()
	)

	for(var/datum/quirk/quirk_type as anything in subtypesof(/datum/quirk))
		if(IS_ABSTRACT(quirk_type))
			continue

		var/category = initial(quirk_type.quirk_category)
		GLOB.quirk_registry[initial(quirk_type.name)] = quirk_type
		GLOB.quirk_points_by_type[category] += list(list(
			"name" = initial(quirk_type.name),
			"type" = quirk_type,
			"desc" = initial(quirk_type.desc),
			"desc_hint" = initial(quirk_type.desc_hint),
			"value" = initial(quirk_type.point_value)
		))
		LAZYADDASSOC(GLOB.quirk_singletons, quirk_type, new quirk_type)

/proc/sort_quirks(list/quirk_types)
	// Sort by apply_order (descending), then alphabetically by name
	var/list/sorted = quirk_types.Copy()

	for(var/i = 1 to length(sorted))
		for(var/j = 1 to length(sorted) - 1)
			var/datum/quirk/current = sorted[j]
			var/datum/quirk/next = sorted[j + 1]

			var/current_order = initial(current.apply_order)
			var/next_order = initial(next.apply_order)
			var/current_name = initial(current.name)
			var/next_name = initial(next.name)

			if(current_order < next_order)
				sorted[j] = next
				sorted[j + 1] = current
			else if(current_order == next_order && sorttext(current_name, next_name) > 0)
				sorted[j] = next
				sorted[j + 1] = current

	return sorted

/datum/quirk
	abstract_type = /datum/quirk
	///this is basically our apply order, if 0 we don't care, higher is better
	var/apply_order = 0
	/// Multiplier applied to the holder's defeat damage threshold (see the Defeat system). Below 1 means they are defeated sooner.
	var/defeat_threshold_mult = 1

	/// The quirk's name shown to players
	var/name = "Quirk"
	/// Description of what this quirk does
	var/desc = "A quirk."
	/// Optional hint to show below the desc, for OOC or important info
	var/desc_hint = ""
	/// Category: QUIRK_POSITIVE, QUIRK_NEGATIVE, or QUIRK_NEUTRAL
	var/quirk_category = QUIRK_NEUTRAL
	/// Point value (negative = costs points, positive = gives points)
	var/point_value = 0
	/// List of quirk types incompatible with this one
	var/list/incompatible_quirks = list()
	/// The mob this quirk is attached to
	var/mob/living/owner
	/// Can this be randomly selected?
	var/random_exempt = FALSE
	/// Does this render in the preview?
	var/preview_render = TRUE

	/// List of options the player can select from (can be paths or strings)
	var/list/customization_options = list()
	/// The selected customization value
	var/customization_value = null
	/// Label for the customization dropdown
	var/customization_label = "Select Option"

	/// Type of customization: "select" for dropdown, "text" for text input, "number" for numeric
	var/customization_type = QUIRK_SELECT
	/// Placeholder text for text inputs
	var/customization_placeholder = "Enter text..."

	/// Extra customization fields: list of lists, each with keys: key, label, type, default, options, min, max, placeholder
	var/list/extra_customization_fields = null
	/// Stored values for extra fields, keyed by field key
	var/list/extra_customization_values = null

	/// List of allowed ages (empty = all allowed)
	var/list/allowed_ages = list()
	/// List of blocked ages
	var/list/blocked_ages = list()
	/// List of allowed species (empty = all allowed)
	var/list/allowed_species = list()
	/// List of blocked species
	var/list/blocked_species = list()
	/// Whether this quirk is reapplied on mob death
	var/revive_reapply = FALSE
	/// Text shown on quirk gain
	var/gain_text
	/// Text shown on quirk loss
	var/lose_text
	/// Traits granted for as long as this quirk remains attached.
	var/list/traits_to_add = list()

/datum/quirk/New(mob/living/new_owner, custom_value = null, list/extra_values = null)
	. = ..()
	if(new_owner)
		owner = new_owner
		if(custom_value)
			customization_value = custom_value
		if(extra_values)
			extra_customization_values = extra_values.Copy()
		if(!preview_render && istype(owner, /mob/living/carbon/human/dummy))
			return
		on_spawn()

/datum/quirk/Destroy()
	on_remove()
	owner = null
	return ..()

/datum/quirk/proc/get_desc(datum/preferences/prefs)
	return desc

/datum/quirk/proc/get_desc_hint(datum/preferences/prefs)
	return desc_hint

/datum/quirk/proc/after_job_spawn(datum/job/job)
	return

/datum/quirk/proc/get_option_name(option)
	if(ispath(option))
		// Try to get the name from the type
		var/atom/A = option
		return initial(A.name)
	return "[option]"

/// Called when the quirk is applied to a character runs before everything (you probably want a real good rason to use this)
/datum/quirk/proc/on_pre_spawn()
	return

/// Called when the quirk is applied to a character
/datum/quirk/proc/on_spawn()
	owner?.add_traits(traits_to_add, "[type]")
	return

/// Called when the quirk is removed
/datum/quirk/proc/on_remove()
	if(!QDELETED(owner))
		REMOVE_TRAITS_IN(owner, "[type]")
	return

/datum/quirk/proc/reapply()
	if(revive_reapply)
		if(!QDELETED(src) && !QDELETED(owner))
			on_spawn()

/// Called when you are examined
/datum/quirk/proc/on_examined(mob/user, list/P, list/examine_contents)
	return

/// Called every life tick if implemented
/datum/quirk/proc/on_life(mob/living/user)
	return

/// Check if this quirk is compatible with a list of existing quirks
/datum/quirk/proc/is_compatible_with(list/datum/quirk/existing_quirks)
	for(var/datum/quirk/Q in existing_quirks)
		if(Q.type in incompatible_quirks)
			return FALSE
		if(type in Q.incompatible_quirks)
			return FALSE
	return TRUE

/datum/quirk/proc/return_customization(datum/preferences/prefs)
	return customization_options.Copy()

/datum/quirk/proc/get_extra_value(key, default_value = null)
	if(!key)
		return default_value
	if(LAZYLEN(extra_customization_values) && !isnull(extra_customization_values[key]))
		return extra_customization_values[key]
	// Fall back to field default
	for(var/list/field in extra_customization_fields)
		if(field["key"] == key)
			return field["default"]
	return default_value

/datum/quirk/proc/set_extra_value(key, value)
	LAZYINITLIST(extra_customization_values)
	extra_customization_values[key] = value

/// Check if this quirk is available for the given preferences
/datum/quirk/proc/is_available(datum/preferences/prefs)
	if(!prefs)
		return TRUE

	// Check age restrictions
	if(length(allowed_ages) && !(prefs.read_preference(/datum/preference/choiced/age) in allowed_ages))
		return FALSE
	if(prefs.read_preference(/datum/preference/choiced/age) in blocked_ages)
		return FALSE

	// Check species restrictions
	if(length(allowed_species) && !(prefs.pref_species.type in allowed_species))
		return FALSE
	if(prefs.pref_species.type in blocked_species)
		return FALSE

	return TRUE

/mob/living/proc/add_quirk(quirk_type)
	return

/mob/living/carbon/human/add_quirk(quirk_type, custom_value = null, list/extra_values = null)
	if(!ispath(quirk_type, /datum/quirk))
		return FALSE

	for(var/datum/quirk/Q in quirks)
		if(Q.type == quirk_type)
			return FALSE

	var/datum/quirk/new_quirk = new quirk_type(src, custom_value, extra_values)
	quirks += new_quirk
	return TRUE

/mob/living/proc/remove_quirk(quirk_type)
	return

/mob/living/carbon/human/remove_quirk(quirk_type)
	for(var/datum/quirk/Q in quirks)
		if(Q.type == quirk_type)
			quirks -= Q
			qdel(Q)
			return TRUE
	return FALSE

/mob/proc/has_quirk(quirk_type)
	return

/mob/living/carbon/human/has_quirk(quirk_type)
	for(var/datum/quirk/Q in quirks)
		if(istype(Q, quirk_type))
			return TRUE
	return FALSE

/mob/living/proc/get_quirk(quirk_type)
	return

/mob/living/carbon/human/get_quirk(quirk_type)
	for(var/datum/quirk/Q in quirks)
		if(istype(Q, quirk_type))
			return Q
	return null

/mob/living/carbon/human/proc/get_quirk_names_by_category(category)
	var/list/quirk_names = list()
	for(var/datum/quirk/Q in quirks)
		if(Q.quirk_category == category)
			// span_tooltip_html so desc_hint can sit in its own paragraph.
			var/tooltip_text = Q.desc
			if(Q.desc_hint)
				tooltip_text += "<br><br>[Q.desc_hint]"
			quirk_names += span_tooltip_html(tooltip_text, Q.name)
	if(!length(quirk_names))
		return "None"
	return quirk_names.Join(", ")

/mob/living/carbon/human/proc/get_active_addiction_names()
	var/list/addiction_names = list()
	for(var/datum/status_effect/status_effect as anything in status_effects)
		if(!istype(status_effect, /datum/status_effect/debuff/addiction))
			continue
		var/atom/movable/screen/alert/status_effect/status_alert = status_effect.alert_type
		var/addiction_name = initial(status_alert.name) || "Addiction"
		var/addiction_desc = initial(status_alert.desc)
		if(addiction_desc)
			addiction_names += span_tooltip_html(addiction_desc, addiction_name)
		else
			addiction_names += addiction_name
	if(!length(addiction_names))
		return "None active"
	return addiction_names.Join(", ")

/mob/living/carbon/human/proc/show_self_quirk_summary()
	to_chat(src, span_info("Positive: [get_quirk_names_by_category(QUIRK_POSITIVE)]"))
	to_chat(src, span_info("Negative: [get_quirk_names_by_category(QUIRK_NEGATIVE)]"))
	to_chat(src, span_info("Addictions: [get_active_addiction_names()]"))

/mob/living/carbon/human/proc/clear_quirks()
	for(var/datum/quirk/Q in quirks)
		qdel(Q)
	quirks = list()

// Calculate total point balance from quirks
/mob/living/carbon/human/proc/get_quirk_balance()
	var/balance = STARTING_QUIRK_POINTS
	for(var/datum/quirk/Q in quirks)
		balance += Q.point_value
	return balance

// Count boons (negative point quirks)
/mob/living/carbon/human/proc/count_boons()
	var/count = 0
	for(var/datum/quirk/Q in quirks)
		if(Q.quirk_category == QUIRK_POSITIVE)
			count++
	return count

// Validate quirk selection
/mob/living/carbon/human/proc/can_add_quirk(quirk_type)
	if(!ispath(quirk_type, /datum/quirk))
		return FALSE

	var/datum/quirk/temp_quirk = quirk_type

	// Check boon limit
	if(initial(temp_quirk.quirk_category) == QUIRK_POSITIVE)
		if(count_boons() >= MAX_POSITIVE)
			return FALSE

	// Check point balance
	var/balance = get_quirk_balance()
	if(initial(temp_quirk.point_value) < 0) // Costs points
		if(balance + initial(temp_quirk.point_value) < 0)
			return FALSE

	// Check compatibility
	var/datum/quirk/test_quirk = new quirk_type()
	var/compatible = test_quirk.is_compatible_with(quirks)
	qdel(test_quirk)

	return compatible

/mob/living/proc/cleanse_quirks() //removes all quirks
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		qdel(T)

/mob/living/proc/reapply_quirks()
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		if(T.revive_reapply)
			T.reapply()
