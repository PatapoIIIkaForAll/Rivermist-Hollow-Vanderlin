// Prosthetics window: saved choices, quirk point cost, fitting at spawn and the creator's data and actions.

/datum/preferences
	/// Prosthetics window choices: slot = option id. Natural slots are left out.
	var/list/prosthetics = list()
	/// Implants in the sockets of chosen prosthetics: slot = implant id.
	var/list/implants = list()

/// Automaton bodies are built, not grown, so the window has nothing to replace.
/datum/preferences/proc/prosthetics_locked_by_species()
	return ispath(pref_species?.type, /datum/species/automaton)

/// Can this character take a choice in this slot? Organ slots need the species to have that organ.
/datum/preferences/proc/prosthetic_slot_available(slot)
	var/list/slot_data = GLOB.prosthetic_slots[slot]
	if(!slot_data || prosthetics_locked_by_species())
		return FALSE
	var/organ_slot = slot_data["kind"] == PROSTHETIC_KIND_EYE ? ORGAN_SLOT_EYES : slot_data["organ"]
	if(organ_slot && pref_species && !(organ_slot in pref_species.organs))
		return FALSE
	return TRUE

/datum/preferences/proc/validate_prosthetics()
	if(!islist(prosthetics))
		prosthetics = list()
		return
	for(var/slot in prosthetics.Copy())
		if(!prosthetic_slot_available(slot) || !prosthetic_option_for(slot, prosthetics[slot]))
			prosthetics -= slot
	validate_implants()

/// Drops implants whose slot has no fitted prosthetic of a kind they suit.
/datum/preferences/proc/validate_implants()
	if(!islist(implants))
		implants = list()
		return
	for(var/slot in implants.Copy())
		var/datum/prosthetic_option/option = prosthetic_option_for(slot, LAZYACCESS(prosthetics, slot))
		if(!option || option.missing || !implant_fits_kind(implants[slot], prosthetic_slot_kind(slot)))
			implants -= slot

/// Quirk points the prosthetic choices give (positive) or cost (negative).
/datum/preferences/proc/prosthetic_point_value()
	. = 0
	for(var/slot in prosthetics)
		var/datum/prosthetic_option/option = prosthetic_option_for(slot, prosthetics[slot])
		if(option)
			. += option.point_value
	for(var/slot in implants)
		var/datum/augment/prototype = GLOB.implant_catalog[implants[slot]]
		if(prototype)
			. += prototype.point_value

/// Drops implants, then the costliest prosthetic choices, until the quirk balance is not below zero.
/datum/preferences/proc/trim_unaffordable_prosthetics()
	while(calculate_quirk_balance() < 0 && length(implants))
		implants.Cut(1, 2)
	while(calculate_quirk_balance() < 0)
		var/costliest_slot
		var/lowest_value = 0
		for(var/slot in prosthetics)
			var/datum/prosthetic_option/option = prosthetic_option_for(slot, prosthetics[slot])
			if(option && option.point_value < lowest_value)
				lowest_value = option.point_value
				costliest_slot = slot
		if(!costliest_slot)
			return
		prosthetics -= costliest_slot

/*
 * FITTING
 *
 * Runs in apply_prefs_to() after quirks. A preview body is reused, so it first
 * undoes the parts this window fitted last time.
 */

/datum/preferences/proc/apply_prosthetics_to_human(mob/living/carbon/human/character, character_setup = FALSE)
	if(!ishuman(character))
		return
	var/is_preview = character_setup || istype(character, /mob/living/carbon/human/dummy)
	if(is_preview)
		character.undo_prosthetic_fittings()
	if(prosthetics_locked_by_species())
		return
	for(var/slot in GLOB.prosthetic_slots)
		var/datum/prosthetic_option/option = prosthetic_option_for(slot, LAZYACCESS(prosthetics, slot))
		if(option && prosthetic_slot_available(slot))
			character.fit_prosthetic_option(slot, option, is_preview)
			var/implant_id = LAZYACCESS(implants, slot)
			if(implant_id && !option.missing)
				character.fit_slot_implant(slot, implant_id)

/// Puts back what an earlier fitting removed or replaced. Preview bodies only.
/mob/living/carbon/human/proc/undo_prosthetic_fittings()
	for(var/obj/item/bodypart/part as anything in bodyparts.Copy())
		if(part.prosthetic_option_id)
			part.drop_limb(TRUE)
			qdel(part)
	for(var/obj/item/organ/organ as anything in internal_organs.Copy())
		if(organ.prosthetic_option_id)
			organ.Remove(src, TRUE)
			qdel(organ)
	REMOVE_TRAITS_IN(src, PROSTHETIC_PREF_TRAIT)
	for(var/limb_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		regenerate_limb(limb_zone)
	dna?.species?.regenerate_organs(src, null, FALSE)
	// regenerate_organs keeps a lone eye and does not grow its pair back.
	for(var/side in list(LEFT_SIDE, RIGHT_SIDE))
		if(!get_eye_on_side(side))
			regrow_natural_eye(side)

/mob/living/carbon/human/proc/regrow_natural_eye(side)
	var/datum/organ_dna/eyes/eye_dna = dna?.organ_dna[ORGAN_SLOT_EYES]
	var/eye_type = eye_dna?.organ_type || dna?.species?.organs[ORGAN_SLOT_EYES]
	if(!ispath(eye_type, /obj/item/organ/eyes))
		return
	var/obj/item/organ/eyes/eye = new eye_type()
	eye.switch_side(side)
	eye_dna?.imprint_organ(eye, dna.species)
	eye.Insert(src, TRUE, FALSE)

/mob/living/carbon/human/proc/fit_prosthetic_option(slot, datum/prosthetic_option/option, is_preview)
	switch(prosthetic_slot_kind(slot))
		if(PROSTHETIC_KIND_ARM, PROSTHETIC_KIND_LEG)
			fit_prosthetic_limb(slot, option, is_preview)
		if(PROSTHETIC_KIND_EYE)
			fit_prosthetic_eye(slot, option, is_preview)
		else
			var/list/slot_data = GLOB.prosthetic_slots[slot]
			fit_prosthetic_organ(slot_data["organ"], option.get_part_type(slot), option.id)

/mob/living/carbon/human/proc/fit_prosthetic_limb(limb_zone, datum/prosthetic_option/option, is_preview)
	var/obj/item/bodypart/old_limb = get_bodypart(limb_zone)
	if(old_limb)
		old_limb.drop_limb(TRUE)
		qdel(old_limb)
	if(option.missing)
		// Late spawn steps can regrow limbs, so check once more after they ran.
		if(!is_preview)
			addtimer(CALLBACK(src, PROC_REF(enforce_missing_limb), limb_zone), 0.5 SECONDS)
		return
	var/part_type = option.get_part_type(limb_zone)
	if(!part_type)
		return
	var/obj/item/bodypart/new_limb = new part_type()
	new_limb.prosthetic_option_id = option.id
	new_limb.attach_limb(src, TRUE)

/mob/living/carbon/human/proc/enforce_missing_limb(limb_zone)
	var/obj/item/bodypart/limb = get_bodypart(limb_zone)
	if(limb && !limb.prosthetic_option_id && limb.status == BODYPART_ORGANIC)
		limb.drop_limb(TRUE)
		qdel(limb)

/// The eye organ sitting on one side, if any.
/mob/living/carbon/proc/get_eye_on_side(side)
	for(var/obj/item/organ/eyes/eye in getorganslotlist(ORGAN_SLOT_EYES))
		if(eye.side == side)
			return eye
	return null

/mob/living/carbon/human/proc/fit_prosthetic_eye(slot, datum/prosthetic_option/option, is_preview)
	var/side = slot == PROSTHETIC_SLOT_L_EYE ? LEFT_SIDE : RIGHT_SIDE
	var/obj/item/organ/eyes/old_eye = get_eye_on_side(side)
	if(old_eye)
		old_eye.Remove(src, TRUE)
		qdel(old_eye)
	if(option.missing)
		ADD_TRAIT(src, side == LEFT_SIDE ? TRAIT_CYCLOPS_LEFT : TRAIT_CYCLOPS_RIGHT, PROSTHETIC_PREF_TRAIT)
		update_fov_angles()
		if(!is_preview)
			put_on_missing_eye_patch(side)
		return
	var/part_type = option.get_part_type(slot)
	if(!part_type)
		return
	var/obj/item/organ/eyes/new_eye = new part_type()
	var/datum/organ_dna/eyes/eye_dna = dna?.organ_dna[ORGAN_SLOT_EYES]
	eye_dna?.imprint_organ(new_eye, dna.species)
	new_eye.prosthetic_option_id = option.id
	new_eye.Insert(src, TRUE, FALSE)

/// An eyepatch over the empty socket, moving any worn mask to the hands.
/mob/living/carbon/human/proc/put_on_missing_eye_patch(side)
	if(wear_mask)
		var/obj/item/old_mask = wear_mask
		dropItemToGround(old_mask, TRUE)
		put_in_hands(old_mask)
	var/patch_type = side == LEFT_SIDE ? /obj/item/clothing/face/eyepatch/left : /obj/item/clothing/face/eyepatch
	equip_to_slot_or_del(new patch_type(src), ITEM_SLOT_MASK)

/mob/living/carbon/human/proc/fit_prosthetic_organ(organ_slot, part_type, option_id)
	if(!organ_slot || !part_type)
		return
	var/obj/item/organ/old_organ = getorganslot(organ_slot)
	if(old_organ)
		old_organ.Remove(src, TRUE)
		qdel(old_organ)
	var/obj/item/organ/new_organ = new part_type()
	new_organ.prosthetic_option_id = option_id
	new_organ.Insert(src, TRUE, FALSE)

/*
 * CHARACTER CREATOR
 */

/// Options grouped by slot kind, the same for every character.
/proc/prosthetic_options_by_kind()
	var/static/list/by_kind
	if(by_kind)
		return by_kind
	by_kind = list()
	for(var/option_id in GLOB.prosthetic_options)
		var/datum/prosthetic_option/option = GLOB.prosthetic_options[option_id]
		var/list/stat_rows = list()
		for(var/stat_name in option.stats)
			stat_rows += list(list("name" = stat_name, "value" = option.stats[stat_name]))
		var/list/option_data = list(
			"id" = option.id,
			"name" = option.name,
			"desc" = option.desc,
			"points" = option.point_value,
			"tint" = option.tint,
			"missing" = option.missing,
			"stats" = stat_rows,
		)
		for(var/kind in option.kinds)
			if(!by_kind[kind])
				by_kind[kind] = list()
			by_kind[kind] += list(option_data)
	return by_kind

/datum/preferences/proc/character_creator_prosthetic_data()
	var/list/slots = list()
	for(var/slot in GLOB.prosthetic_slots)
		var/list/slot_data = GLOB.prosthetic_slots[slot]
		slots += list(list(
			"id" = slot,
			"name" = slot_data["name"],
			"kind" = slot_data["kind"],
			"available" = prosthetic_slot_available(slot),
			"choice" = LAZYACCESS(prosthetics, slot) || PROSTHETIC_NATURAL,
			"implant" = LAZYACCESS(implants, slot) || "",
		))
	return list(
		"slots" = slots,
		"options" = prosthetic_options_by_kind(),
		"balance" = calculate_quirk_balance(),
		"points" = prosthetic_point_value(),
		"locked" = prosthetics_locked_by_species(),
		"implants" = implants_by_kind(),
	)

/// Sets one slot from the window. TRUE when the saved choices changed.
/datum/preferences/proc/character_creator_prosthetic_act(mob/user, list/params)
	var/slot = params["slot"]
	if(!istext(slot) || !prosthetic_slot_available(slot))
		return FALSE
	var/option_id = params["option"]
	var/old_choice = LAZYACCESS(prosthetics, slot)
	if(option_id == PROSTHETIC_NATURAL)
		if(!old_choice)
			return FALSE
		prosthetics -= slot
	else
		var/datum/prosthetic_option/option = prosthetic_option_for(slot, option_id)
		if(!option || old_choice == option_id)
			return FALSE
		LAZYINITLIST(prosthetics)
		prosthetics[slot] = option_id
		if(calculate_quirk_balance() < 0)
			if(old_choice)
				prosthetics[slot] = old_choice
			else
				prosthetics -= slot
			to_chat(user, span_warning("Not enough quirk points for [option.name]."))
			return FALSE
	validate_implants()
	update_menu_data(user)
	return TRUE

/// Implant data grouped by socket kind, the same for every character.
/proc/implants_by_kind()
	var/static/list/by_kind
	if(by_kind)
		return by_kind
	by_kind = list()
	for(var/implant_id in GLOB.implant_catalog)
		var/datum/augment/prototype = GLOB.implant_catalog[implant_id]
		var/list/implant_data = list(
			"id" = implant_id,
			"name" = capitalize(prototype.name),
			"desc" = prototype.desc,
			"points" = prototype.point_value,
			"effect" = prototype.get_effect_summary(),
		)
		for(var/kind in prototype.socket_kinds)
			if(!by_kind[kind])
				by_kind[kind] = list()
			by_kind[kind] += list(implant_data)
	return by_kind

/// Sets or clears the implant of one slot from the window. TRUE when the saved choices changed.
/datum/preferences/proc/character_creator_implant_act(mob/user, list/params)
	var/slot = params["slot"]
	if(!istext(slot) || !prosthetic_slot_available(slot))
		return FALSE
	var/implant_id = params["implant"]
	var/old_implant = LAZYACCESS(implants, slot)
	if(!implant_id)
		if(!old_implant)
			return FALSE
		implants -= slot
	else
		var/datum/prosthetic_option/option = prosthetic_option_for(slot, LAZYACCESS(prosthetics, slot))
		if(!option || option.missing || !implant_fits_kind(implant_id, prosthetic_slot_kind(slot)) || old_implant == implant_id)
			return FALSE
		LAZYINITLIST(implants)
		implants[slot] = implant_id
		if(calculate_quirk_balance() < 0)
			if(old_implant)
				implants[slot] = old_implant
			else
				implants -= slot
			to_chat(user, span_warning("Not enough quirk points for that implant."))
			return FALSE
	update_menu_data(user)
	return TRUE

/// The fitted prosthetic part of a slot, if the window fitted one.
/mob/living/carbon/human/proc/get_prosthetic_slot_part(slot)
	switch(prosthetic_slot_kind(slot))
		if(PROSTHETIC_KIND_ARM, PROSTHETIC_KIND_LEG)
			return get_bodypart(slot)
		if(PROSTHETIC_KIND_EYE)
			return get_eye_on_side(slot == PROSTHETIC_SLOT_L_EYE ? LEFT_SIDE : RIGHT_SIDE)
	var/list/slot_data = GLOB.prosthetic_slots[slot]
	return getorganslot(slot_data?["organ"])

/mob/living/carbon/human/proc/fit_slot_implant(slot, implant_id)
	var/datum/augment/prototype = GLOB.implant_catalog[implant_id]
	var/obj/item/part = get_prosthetic_slot_part(slot)
	if(!prototype || !part?.implant_socket_kind || part.socket_implant)
		return
	var/implant_type = prototype.type
	part.set_socket_implant(new implant_type())
