/datum/mob_descriptor
	abstract_type = /datum/mob_descriptor
	var/name = "Descriptor"
	var/show_obscured = FALSE
	var/describe
	var/prefix
	var/suffix
	var/verbage
	var/slot = MOB_DESCRIPTOR_SLOT_NOTHING
	var/pre_string
	var/post_string
	/// Text colour for viewers who turned on coloured descriptors.
	var/descriptor_color
	/// Colour used instead once the described mob's arousal passes aroused_descriptor_threshold.
	var/aroused_descriptor_color
	var/aroused_descriptor_threshold = 30
	/// Index into the mob's custom_descriptors for player-written descriptors.
	var/custom_index
	/// How a custom entry's prefix reads: a full verb choice, an article only, or nothing.
	var/custom_prefix_mode = CUSTOM_PREFIX_MODE_NONE

/datum/mob_descriptor/New()
	. = ..()
	if(!describe)
		describe = LOWER_TEXT(name)
	if(prefix)
		pre_string = "[prefix] "
	if(suffix)
		post_string = " [suffix]"

/datum/mob_descriptor/proc/get_custom_entry(mob/living/described)
	if(!custom_index || length(described.custom_descriptors) < custom_index)
		return null
	return described.custom_descriptors[custom_index]

/datum/mob_descriptor/proc/get_pre_string(mob/living/described)
	if(!custom_index)
		return pre_string
	var/datum/custom_descriptor_entry/entry = get_custom_entry(described)
	switch(custom_prefix_mode)
		if(CUSTOM_PREFIX_MODE_FULL)
			switch(entry?.prefix_type)
				if(CUSTOM_PREFIX_HAS_A)
					return "a "
				if(CUSTOM_PREFIX_HAS_AN)
					return "an "
		if(CUSTOM_PREFIX_MODE_ARTICLE)
			return entry?.prefix_type == CUSTOM_PREFIX_HAS_AN ? "an " : "a "
	return null

/datum/mob_descriptor/proc/get_verbage(mob/living/described)
	if(custom_prefix_mode != CUSTOM_PREFIX_MODE_FULL)
		return verbage
	var/datum/custom_descriptor_entry/entry = get_custom_entry(described)
	switch(entry?.prefix_type)
		if(CUSTOM_PREFIX_IS)
			return "%ARE%"
		if(CUSTOM_PREFIX_LOOKS)
			return "%LOOK%"
	return "%HAVE%"

/datum/mob_descriptor/proc/can_describe(mob/living/described)
	if(custom_index)
		return !!get_custom_entry(described)
	return TRUE

/datum/mob_descriptor/proc/can_user_see(mob/living/described, mob/user)
	return TRUE

/datum/mob_descriptor/proc/should_add_verbage(mob/living/described, list/used_verbage)
	var/verbage_to_use = get_verbage(described)
	if(!verbage_to_use)
		return FALSE
	if(!used_verbage)
		return TRUE
	if(verbage_to_use in used_verbage)
		return FALSE
	return TRUE

/datum/mob_descriptor/proc/get_standalone_text(mob/living/described, mob/watcher)
	return "%THEY% [get_coalesce_text(described, null, watcher)]"

/datum/mob_descriptor/proc/get_coalesce_text(mob/living/described, list/used_verbage, mob/watcher)
	var/descriptor_text = "[get_pre_string(described)][get_description_for_watcher(described, watcher)][post_string]"
	var/color = get_descriptor_color(described, watcher)
	if(color)
		descriptor_text = "<span style='color:[color]'>[descriptor_text]</span>"
	if(should_add_verbage(described, used_verbage))
		descriptor_text = "[get_verbage(described)] [descriptor_text]"
	return descriptor_text

/datum/mob_descriptor/proc/get_coalesce_text_nofluff(mob/living/described, list/used_verbage)
	return "[get_description(described)]"

/datum/mob_descriptor/proc/get_description(mob/living/described)
	if(custom_index)
		var/datum/custom_descriptor_entry/entry = get_custom_entry(described)
		return entry?.content_text
	return describe

/// Text for one viewer; overrides add viewer-only detail such as hair colour.
/datum/mob_descriptor/proc/get_description_for_watcher(mob/living/described, mob/watcher)
	return get_description(described)

/datum/mob_descriptor/proc/get_descriptor_color(mob/living/described, mob/watcher)
	if(!descriptor_color || !wants_descriptor_color(watcher))
		return null
	return get_color_for_arousal(described)

/// The colour this descriptor shows at the described mob's current arousal.
/datum/mob_descriptor/proc/get_color_for_arousal(mob/living/described)
	if(aroused_descriptor_color)
		var/list/arousal_data = list()
		SEND_SIGNAL(described, COMSIG_SEX_GET_AROUSAL, arousal_data)
		if(arousal_data["arousal"] > aroused_descriptor_threshold)
			return aroused_descriptor_color
	return descriptor_color

/// Whether this viewer has coloured descriptor text turned on in their settings.
/proc/wants_descriptor_color(mob/watcher)
	return !!watcher?.client?.prefs?.read_preference(/datum/preference/toggle/descriptor_color)
