/datum/bodypart_feature/hair/body_hair
	name = "Body Hair"
	feature_slot = BODYPART_FEATURE_BODY_HAIR
	body_zone = BODY_ZONE_CHEST
	var/current_level = HAIRINESS_SHAVED
	var/target_level = HAIRINESS_SHAVED
	var/growth_enabled = FALSE
	var/material = BODY_HAIR_MATERIAL_HAIR
	var/list/accessory_by_level = list(
		/datum/sprite_accessory/body_hair/body/shaved,
		/datum/sprite_accessory/body_hair/body/shaved,
		/datum/sprite_accessory/body_hair/body/some_hair,
		/datum/sprite_accessory/body_hair/body/hairy,
		/datum/sprite_accessory/body_hair/body/very_hairy,
	)

/datum/bodypart_feature/hair/body_hair/set_accessory_type(new_accessory_type, colors, mob/living/carbon/owner)
	..()
	var/datum/sprite_accessory/body_hair/accessory = SPRITE_ACCESSORY(new_accessory_type)
	if(!accessory)
		return
	set_hairiness_level(accessory.hairiness_level, TRUE)

/datum/bodypart_feature/hair/body_hair/proc/get_accessory_for_level(level)
	level = clamp(level, HAIRINESS_MINIMUM, HAIRINESS_MAXIMUM)
	return accessory_by_level[level]

/// The accessory actually drawn, which grooming may change from the plain level sprite.
/datum/bodypart_feature/hair/body_hair/proc/get_display_accessory()
	return get_accessory_for_level(current_level)

/datum/bodypart_feature/hair/body_hair/proc/set_hairiness_level(level, updates_target = FALSE)
	current_level = clamp(level, HAIRINESS_MINIMUM, HAIRINESS_MAXIMUM)
	if(updates_target)
		target_level = current_level
	accessory_type = get_display_accessory()
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/get_next_growth_level()
	if(current_level < HAIRINESS_SOME_HAIR)
		return min(target_level, HAIRINESS_SOME_HAIR)
	return min(current_level + 1, target_level)

/datum/bodypart_feature/hair/body_hair/proc/grow_one_level()
	if(current_level >= target_level)
		return FALSE
	set_hairiness_level(get_next_growth_level())
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/shave()
	if(current_level <= HAIRINESS_SHAVED)
		return FALSE
	set_hairiness_level(HAIRINESS_SHAVED)
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/trim()
	if(current_level <= HAIRINESS_SOME_HAIR)
		return FALSE
	set_hairiness_level(HAIRINESS_SOME_HAIR)
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/set_material(new_material)
	material = sanitize_body_hair_material(new_material)

/datum/bodypart_feature/hair/body_hair/proc/get_material_name()
	return material

/// tint_material colours the material word with the hair colour, for viewers who want coloured descriptors.
/datum/bodypart_feature/hair/body_hair/proc/get_description(tint_material = FALSE)
	if(current_level <= HAIRINESS_SHAVED)
		return null
	var/datum/sprite_accessory/body_hair/accessory = SPRITE_ACCESSORY(accessory_type)
	if(!accessory?.description)
		return null
	var/material_text = get_material_name()
	var/hair_color = tint_material ? LAZYACCESS(color_string_to_list(accessory_colors), 1) : null
	if(hair_color)
		material_text = "<span style='color:[sanitize_hexcolor(hair_color, 6, TRUE, "#FFFFFF")]'>[material_text]</span>"
	return replacetext(accessory.description, "%MATERIAL%", material_text)

/datum/bodypart_feature/hair/body_hair/pubic
	name = "Pubic Hair"
	feature_slot = BODYPART_FEATURE_PUBIC_HAIR
	body_zone = BODY_ZONE_CHEST
	var/grooming_state = HAIR_GROOMING_NATURAL
	/// Style accessory drawn instead of the level sprite while there is enough hair to shape.
	var/style_accessory
	accessory_by_level = list(
		/datum/sprite_accessory/body_hair/pubic/shaved,
		/datum/sprite_accessory/body_hair/pubic/stubble,
		/datum/sprite_accessory/body_hair/pubic/some_hair,
		/datum/sprite_accessory/body_hair/pubic/hairy,
		/datum/sprite_accessory/body_hair/pubic/very_hairy,
	)

/datum/bodypart_feature/hair/body_hair/pubic/get_display_accessory()
	if(style_accessory && current_level >= HAIRINESS_SOME_HAIR)
		return style_accessory
	return ..()

/datum/bodypart_feature/hair/body_hair/pubic/get_next_growth_level()
	return min(current_level + 1, target_level)

/datum/bodypart_feature/hair/body_hair/pubic/get_material_name()
	return "pubic [material]"

/// Applies a style, or clears it with null. Styles need at least some hair to shape.
/datum/bodypart_feature/hair/body_hair/pubic/proc/set_style(new_style)
	if(new_style && current_level < HAIRINESS_SOME_HAIR)
		return FALSE
	style_accessory = new_style
	grooming_state = new_style ? HAIR_GROOMING_STYLED : HAIR_GROOMING_NATURAL
	accessory_type = get_display_accessory()
	return TRUE

/// Razor styling: cuts the hair to trim length and shapes it, so regrowth wears the style off.
/datum/bodypart_feature/hair/body_hair/pubic/proc/shape(new_style)
	if(!new_style || style_accessory == new_style || current_level < HAIRINESS_SOME_HAIR)
		return FALSE
	set_hairiness_level(HAIRINESS_SOME_HAIR)
	return set_style(new_style)

/datum/bodypart_feature/hair/body_hair/pubic/grow_one_level()
	if(!..())
		return FALSE
	style_accessory = null
	grooming_state = current_level >= target_level ? HAIR_GROOMING_NATURAL : HAIR_GROOMING_TRIMMED
	accessory_type = get_display_accessory()
	return TRUE

/datum/bodypart_feature/hair/body_hair/pubic/shave()
	if(!..())
		return FALSE
	style_accessory = null
	grooming_state = HAIR_GROOMING_SHAVED
	accessory_type = get_display_accessory()
	return TRUE

/datum/bodypart_feature/hair/body_hair/pubic/trim()
	if(!..())
		return FALSE
	style_accessory = null
	grooming_state = HAIR_GROOMING_TRIMMED
	accessory_type = get_display_accessory()
	return TRUE

/datum/bodypart_feature/hair/body_hair/armpit
	name = "Armpit Hair"
	feature_slot = BODYPART_FEATURE_ARMPIT_HAIR
	body_zone = BODY_ZONE_CHEST
	accessory_by_level = list(
		/datum/sprite_accessory/body_hair/armpit/shaved,
		/datum/sprite_accessory/body_hair/armpit/stubble,
		/datum/sprite_accessory/body_hair/armpit/some_hair,
		/datum/sprite_accessory/body_hair/armpit/hairy,
		/datum/sprite_accessory/body_hair/armpit/very_hairy,
	)

/datum/bodypart_feature/hair/body_hair/armpit/get_next_growth_level()
	return min(current_level + 1, target_level)

/datum/bodypart_feature/hair/body_hair/armpit/get_material_name()
	return "armpit [material]"

/mob/living/carbon/human
	var/next_body_hair_growth = 0

/mob/living/carbon/human/proc/get_body_hair_features()
	. = list()
	for(var/feature_slot in list(BODYPART_FEATURE_BODY_HAIR, BODYPART_FEATURE_PUBIC_HAIR, BODYPART_FEATURE_ARMPIT_HAIR))
		var/datum/bodypart_feature/hair/body_hair/feature = get_bodypart_feature_of_slot(feature_slot)
		if(feature)
			. += feature

/mob/living/carbon/human/proc/handle_body_hair_growth()
	if(next_body_hair_growth > world.time)
		return
	next_body_hair_growth = world.time + BODY_HAIR_GROWTH_INTERVAL
	var/grew = FALSE
	for(var/datum/bodypart_feature/hair/body_hair/feature as anything in get_body_hair_features())
		if(feature.growth_enabled)
			grew |= feature.grow_one_level()
	if(grew)
		update_body_parts()

/// Organ slot whose examine text carries the pubic hair, so it is described once.
/mob/living/carbon/human/proc/get_pubic_hair_host_slot()
	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	if(getorganslot(ORGAN_SLOT_TESTICLES) && penis?.sheath_type != SHEATH_TYPE_SLIT)
		return ORGAN_SLOT_TESTICLES
	if(get_real_organ(src, ORGAN_SLOT_PENIS))
		return ORGAN_SLOT_PENIS
	if(getorganslot(ORGAN_SLOT_VAGINA))
		return ORGAN_SLOT_VAGINA
	return null

/// ", framed by ..." for the host genital's examine text, else an empty string.
/mob/living/carbon/human/proc/get_pubic_hair_clause(organ_slot, mob/watcher)
	if(organ_slot != get_pubic_hair_host_slot())
		return ""
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
	var/description = pubic_hair_feature?.get_description(wants_descriptor_color(watcher))
	return description ? ", framed by [description]" : ""

/mob/living/carbon/human/proc/restore_head_hair_to_natural_target()
	var/datum/bodypart_feature/hair/head/head_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!head_hair?.natural_accessory_type || head_hair.accessory_type == head_hair.natural_accessory_type)
		return FALSE
	head_hair.accessory_type = head_hair.natural_accessory_type
	return TRUE

/mob/living/carbon/human/proc/restore_facial_hair_to_natural_target()
	var/datum/bodypart_feature/hair/facial/facial_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!facial_hair?.natural_accessory_type)
		return FALSE
	var/grew = FALSE
	if(facial_hair.accessory_type != facial_hair.natural_accessory_type)
		facial_hair.accessory_type = facial_hair.natural_accessory_type
		grew = TRUE
	if(has_stubble)
		has_stubble = FALSE
		grew = TRUE
	return grew

/mob/living/carbon/human/proc/remove_head_hair()
	var/datum/bodypart_feature/hair/head/head_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!head_hair || head_hair.accessory_type == /datum/sprite_accessory/hair/head/bald)
		return FALSE
	head_hair.accessory_type = /datum/sprite_accessory/hair/head/bald
	return TRUE

/mob/living/carbon/human/proc/remove_facial_hair()
	var/datum/bodypart_feature/hair/facial/facial_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!facial_hair)
		return FALSE
	var/removed = FALSE
	if(facial_hair.accessory_type != /datum/sprite_accessory/hair/facial/none)
		facial_hair.accessory_type = /datum/sprite_accessory/hair/facial/none
		removed = TRUE
	if(has_stubble)
		has_stubble = FALSE
		removed = TRUE
	return removed

/mob/living/carbon/human/proc/grow_hair_toward_natural_targets()
	var/grew = FALSE
	grew |= restore_head_hair_to_natural_target()
	grew |= restore_facial_hair_to_natural_target()
	for(var/datum/bodypart_feature/hair/body_hair/feature as anything in get_body_hair_features())
		grew |= feature.grow_one_level()
	if(grew)
		update_body_parts()
	return grew

/proc/body_hair_slot_for_zone(target_zone)
	switch(target_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			return BODYPART_FEATURE_BODY_HAIR
		if(BODY_ZONE_PRECISE_GROIN)
			return BODYPART_FEATURE_PUBIC_HAIR
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return BODYPART_FEATURE_ARMPIT_HAIR
	return null

/mob/living/carbon/human/proc/grow_hair_at_zone(target_zone)
	var/grew = FALSE
	switch(target_zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL)
			grew = restore_head_hair_to_natural_target()
		if(BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NECK)
			grew = restore_facial_hair_to_natural_target()
		else
			var/feature_slot = body_hair_slot_for_zone(target_zone)
			if(!feature_slot)
				return FALSE
			var/datum/bodypart_feature/hair/body_hair/feature = get_bodypart_feature_of_slot(feature_slot)
			grew = feature?.grow_one_level()
	if(grew)
		update_body_parts()
	return grew

/mob/living/carbon/human/proc/remove_hair_at_zone(target_zone)
	var/removed = FALSE
	switch(target_zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL)
			removed = remove_head_hair()
		if(BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NECK)
			removed = remove_facial_hair()
		else
			var/feature_slot = body_hair_slot_for_zone(target_zone)
			if(!feature_slot)
				return FALSE
			var/datum/bodypart_feature/hair/body_hair/feature = get_bodypart_feature_of_slot(feature_slot)
			removed = feature?.shave()
	if(removed)
		update_body_parts()
	return removed

/mob/living/carbon/human/proc/remove_all_hair()
	var/removed = FALSE
	removed |= remove_head_hair()
	removed |= remove_facial_hair()
	for(var/datum/bodypart_feature/hair/body_hair/feature as anything in get_body_hair_features())
		removed |= feature.shave()
	if(removed)
		update_body_parts()
	return removed

/// Grooming choices a razor offers for this feature right now, name -> style type or action.
/mob/living/carbon/human/proc/get_body_hair_grooming_options(datum/bodypart_feature/hair/body_hair/feature)
	. = list()
	if(feature.current_level > HAIRINESS_SHAVED)
		.["Shave bare"] = "shave"
	if(feature.current_level > HAIRINESS_SOME_HAIR)
		.["Trim short"] = "trim"
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = feature
	if(!istype(pubic_hair_feature) || feature.current_level < HAIRINESS_SOME_HAIR)
		return
	for(var/style_name in GLOB.pubic_hair_styles)
		var/style_type = GLOB.pubic_hair_styles[style_name]
		if(style_type != pubic_hair_feature.style_accessory)
			.["Style: [LOWER_TEXT(style_name)]"] = style_type

/// Applies one grooming option; returns TRUE when the hair changed.
/datum/bodypart_feature/hair/body_hair/proc/apply_grooming(option)
	switch(option)
		if("shave")
			return shave()
		if("trim")
			return trim()
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = src
	if(istype(pubic_hair_feature) && ispath(option, /datum/sprite_accessory/body_hair/pubic/style))
		return pubic_hair_feature.shape(option)
	return FALSE

/mob/living/carbon/human/proc/try_groom_body_hair(mob/user, obj/item/held_item, feature_slot, hair_name, body_zone, groom_time = 10 SECONDS)
	var/datum/bodypart_feature/hair/body_hair/hair_feature = get_bodypart_feature_of_slot(feature_slot)
	if(!hair_feature)
		return FALSE
	var/list/options = get_body_hair_grooming_options(hair_feature)
	if(!length(options))
		return FALSE
	if(!get_location_accessible(src, body_zone, skipundies = FALSE))
		to_chat(user, span_warning("[src == user ? "Your" : "[src]'s"] [hair_name] is covered."))
		return TRUE
	var/chosen = options[1]
	if(length(options) > 1)
		chosen = browser_input_list(user, "How do you groom [src == user ? "your" : "[src]'s"] [hair_name]?", "Grooming", options)
		if(!chosen || QDELETED(src) || QDELETED(hair_feature))
			return TRUE
	var/option = options[chosen]
	var/verb_name = option == "shave" ? "shave" : (option == "trim" ? "trim" : "style")
	playsound(src, 'sound/foley/shaving.ogg', 100, TRUE, -1)
	if(user == src)
		user.visible_message(span_danger("[user] starts to [verb_name] [user.p_their()] [hair_name] with [held_item]."))
	else
		user.visible_message(span_danger("[user] starts to [verb_name] [src]'s [hair_name] with [held_item]."))
	if(!do_after(user, groom_time, src))
		return TRUE
	if(user.get_active_held_item() != held_item || !get_location_accessible(src, body_zone, skipundies = FALSE))
		return TRUE
	if(!hair_feature.apply_grooming(option))
		return TRUE
	update_body_parts()
	return TRUE
