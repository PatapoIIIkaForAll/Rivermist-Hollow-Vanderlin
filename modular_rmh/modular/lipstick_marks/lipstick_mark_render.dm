// Draws lipstick marks: face marks on the body layer, limb marks per body sheet, organ marks inside the organ overlay.

/// Art states to try for a mark, the closest first; organs without a variant fall back to a plain kiss.
/proc/get_lipstick_art_variants(kind, count)
	var/static/list/variants_by_key = list()
	var/key = "[kind][count]"
	. = variants_by_key[key]
	if(.)
		return
	switch(kind)
		if(LIPSTICK_KIND_RING)
			. = list("ring[count]", "ring1", "kiss1")
		if(LIPSTICK_KIND_DEEP)
			. = list("deep", "ring1", "kiss1")
		if(LIPSTICK_KIND_SMEAR)
			. = list("smear", "kiss[count]", "kiss1")
		if(LIPSTICK_KIND_BITE)
			. = list("bite", "kiss1")
		else
			. = list("kiss[count]", "kiss2", "kiss1")
	variants_by_key[key] = .

/// The first art state that exists for a mark, built as "<prefix><variant><suffix>".
/proc/find_lipstick_art_state(icon_file, prefix, suffix, list/mark)
	for(var/variant in get_lipstick_art_variants(mark[LIPSTICK_MARK_KIND], mark[LIPSTICK_MARK_COUNT]))
		var/state = "[prefix][variant][suffix]"
		if(icon_exists(icon_file, state))
			return state
	return null

/// Mark sheet key of a body sheet: last folder and file name, so icons/.../m/mm.dmi gives "m_mm".
/proc/get_lipstick_sheet_key(sheet)
	var/static/list/keys_by_path = list()
	var/path = "[sheet]"
	. = keys_by_path[path]
	if(. || !length(path))
		return
	var/list/parts = splittext(path, "/")
	if(length(parts) < 2)
		return null
	. = "[parts[length(parts) - 1]]_[replacetext(parts[length(parts)], ".dmi", "")]"
	keys_by_path[path] = .

/// The mark sheet that holds a per-body state, or null when that body has no art for it.
/proc/get_lipstick_sheet_icon(state)
	if(icon_exists(LIPSTICK_MARK_ICON, state))
		return LIPSTICK_MARK_ICON
	if(icon_exists(LIPSTICK_MARK_TALL_ICON, state))
		return LIPSTICK_MARK_TALL_ICON
	return null

/proc/make_lipstick_overlay(icon_file, state, layer, list/mark, shown_alpha)
	var/mutable_appearance/overlay = mutable_appearance(icon_file, state, layer)
	overlay.color = mark[LIPSTICK_MARK_COLOR]
	overlay.alpha = shown_alpha
	return overlay

/// The standard face frame the face art is drawn for; species with their own lips state have another.
/mob/living/carbon/human/proc/has_standard_face_frame()
	var/datum/species/species = dna?.species
	if(!species)
		return FALSE
	if(get_body_build())
		return TRUE
	return !((gender == MALE) ? species.lips_state_m : species.lips_state_f)

/// Whether a snout covers the mouth and nose the face art is drawn for.
/mob/living/carbon/human/proc/has_visible_snout()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!istype(head))
		return FALSE
	for(var/obj/item/organ/snout/snout in head.get_organs())
		if(snout.accessory_type && snout.is_visible())
			return TRUE
	return FALSE

/// BODY_LAYER overlays for face and limb marks; organ marks ride the organ overlays instead.
/mob/living/carbon/human/proc/get_lipstick_mark_overlays()
	. = list()
	if(!length(lipstick_marks) || HAS_TRAIT(src, TRAIT_HUSK))
		return
	var/standard_face = has_standard_face_frame()
	var/snouted = has_visible_snout()
	var/obj/item/bodypart/taur/taur = get_bodypart(BODY_ZONE_TAUR)
	var/taur_offset = taur?.body_offset_y || 0
	for(var/spot in lipstick_marks)
		var/art = get_lipstick_art(spot)
		if(!art || art == LIPSTICK_ART_ORGAN || !is_lipstick_spot_visible(spot))
			continue
		var/list/mark = lipstick_marks[spot]
		var/shown_alpha = get_lipstick_shown_alpha(mark)
		if(shown_alpha <= 0)
			continue
		if(art == LIPSTICK_ART_FACE)
			if(!standard_face || (snouted && (spot == LIPSTICK_SPOT_LIPS || spot == LIPSTICK_SPOT_NOSE)))
				continue
			var/mutable_appearance/face_overlay = make_lipstick_overlay(LIPSTICK_MARK_ICON, spot, -BODY_LAYER, mark, shown_alpha)
			apply_offset(face_overlay, OFFSET_FACE)
			face_overlay.pixel_y += taur_offset
			. += face_overlay
			continue
		. += get_lipstick_sheet_overlays(spot, art, mark, shown_alpha, taur_offset)

/// The per-sheet overlays of one spot: the main limb layer, and the near-limb layer when that has pixels.
/mob/living/carbon/human/proc/get_lipstick_sheet_overlays(spot, art, list/mark, shown_alpha, taur_offset)
	. = list()
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	var/obj/item/bodypart/limb = get_bodypart(spot_data["limb"])
	// Same rule as the limb sprite: organic limbs and automaton frames draw from the body sheet.
	if(!limb || limb.animal_origin || !(limb.is_organic_limb() || is_species(src, /datum/species/automaton)))
		return
	var/key = get_lipstick_sheet_key(limb.species_icon)
	if(!key)
		return
	var/main_state = "[spot]_[key]"
	var/icon_file = get_lipstick_sheet_icon(main_state)
	if(icon_file)
		var/mutable_appearance/overlay = make_lipstick_overlay(icon_file, main_state, (art == LIPSTICK_ART_TOP) ? -BODY_LAYER : -LIPSTICK_LOW_LAYER, mark, shown_alpha)
		overlay.pixel_y += taur_offset
		. += overlay
	var/aux_layer = spot_data["aux_layer"]
	if(!aux_layer)
		return
	var/aux_state = "[main_state]_aux"
	icon_file = get_lipstick_sheet_icon(aux_state)
	if(icon_file)
		var/mutable_appearance/aux_overlay = make_lipstick_overlay(icon_file, aux_state, -(aux_layer - 0.2), mark, shown_alpha)
		aux_overlay.pixel_y += taur_offset
		. += aux_overlay

/// The spot whose marks draw on an organ slot's sprite, such as the anus on the butt.
/proc/get_lipstick_organ_spot(slot)
	var/static/list/spots_by_slot
	if(!spots_by_slot)
		spots_by_slot = list()
		for(var/spot in GLOB.lipstick_mark_spots)
			var/list/spot_data = GLOB.lipstick_mark_spots[spot]
			if(spot_data["organ_art"])
				spots_by_slot[spot_data["art_organ"]] = spot
	return spots_by_slot[slot]

/// Render key part for an organ's marks, so a marked organ gets its own limb cache slot.
/mob/living/carbon/human/proc/get_lipstick_organ_key(obj/item/organ/organ)
	if(!length(lipstick_marks))
		return null
	var/spot = get_lipstick_organ_spot(organ.slot)
	var/list/mark = spot && lipstick_marks[spot]
	if(!mark)
		return null
	return "lip[spot][get_lipstick_mark_look(mark)][is_lipstick_spot_visible(spot)]"

/obj/item/organ/genitals/bodypart_overlays(mutable_appearance/standing)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.add_lipstick_organ_mark(src, standing)

/// Adds the mark of this organ's spot over one organ overlay, for front layers only.
/mob/living/carbon/human/proc/add_lipstick_organ_mark(obj/item/organ/genitals/organ, mutable_appearance/standing)
	if(!length(lipstick_marks) || standing.plane == EMISSIVE_PLANE || HAS_TRAIT(src, TRAIT_HUSK))
		return
	var/spot = get_lipstick_organ_spot(organ.slot)
	var/list/mark = spot && lipstick_marks[spot]
	if(!mark || !is_lipstick_spot_visible(spot))
		return
	var/shown_alpha = get_lipstick_shown_alpha(mark)
	if(shown_alpha <= 0)
		return
	var/icon_file = LIPSTICK_ORGAN_MARK_ICON
	var/source_state = standing.icon_state
	if(!source_state)
		// Taur genitals are one baked icon without a state name.
		source_state = get_lipstick_taur_state(organ)
		icon_file = LIPSTICK_TAUR_MARK_ICON
	else if(!findtext(source_state, "_ADJ"))
		return
	if(!source_state)
		return
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	var/mark_state = find_lipstick_art_state(icon_file, "[spot_data["organ_art"]]-", "-[source_state]", mark)
	if(!mark_state)
		return
	var/mutable_appearance/overlay = mutable_appearance(icon_file, mark_state, appearance_flags = RESET_COLOR)
	overlay.color = mark[LIPSTICK_MARK_COLOR]
	overlay.alpha = shown_alpha
	standing.overlays += overlay

/// Mark sheet name of a taur organ sprite, "taur-<state>", or null when the organ draws the human way.
/mob/living/carbon/human/proc/get_lipstick_taur_state(obj/item/organ/genitals/organ)
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(organ.accessory_type)
	var/taur_state
	if(istype(accessory, /datum/sprite_accessory/genitals/penis))
		var/datum/sprite_accessory/genitals/penis/penis_accessory = accessory
		taur_state = penis_accessory.get_taur_icon_state(organ, src)
	else if(istype(accessory, /datum/sprite_accessory/genitals/testicles))
		var/datum/sprite_accessory/genitals/testicles/testicles_accessory = accessory
		taur_state = testicles_accessory.get_taur_icon_state(organ, src)
	return taur_state ? "taur-[taur_state]" : null

/// Nipple marks over the animated front breasts; flicks with the breasts so one-shots hide the marks.
/atom/movable/lipstick_breast_visual
	icon = LIPSTICK_BREAST_CHILD_ICON
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_DIR
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/datum/component/breast_animation
	/// Nipple marks drawn over the breasts child, a sibling in the parent's vis_contents.
	var/atom/movable/lipstick_breast_visual/lipstick_visual

/// Matches the marks child to the breasts child: rest state only, hidden while running or jiggling.
/datum/component/breast_animation/proc/update_lipstick_child()
	var/mob/living/carbon/human/human = parent
	var/new_state
	if(visual && !jiggling && !running && !QDELETED(human))
		new_state = human.get_lipstick_breast_child_state(size)
	if(!new_state)
		remove_lipstick_child()
		return
	if(!lipstick_visual)
		lipstick_visual = new
		human.vis_contents += lipstick_visual
	var/list/mark = human.lipstick_marks[LIPSTICK_SPOT_NIPPLES]
	lipstick_visual.icon_state = new_state
	lipstick_visual.color = mark[LIPSTICK_MARK_COLOR]
	lipstick_visual.alpha = get_lipstick_shown_alpha(mark)
	lipstick_visual.layer = visual.layer + 0.001
	lipstick_visual.pixel_x = visual.pixel_x
	lipstick_visual.pixel_y = visual.pixel_y
	if(visual.vis_flags & VIS_HIDE)
		lipstick_visual.vis_flags |= VIS_HIDE
	else
		lipstick_visual.vis_flags &= ~VIS_HIDE

/datum/component/breast_animation/proc/remove_lipstick_child()
	if(!lipstick_visual)
		return
	var/atom/movable/movable_parent = parent
	movable_parent?.vis_contents -= lipstick_visual
	QDEL_NULL(lipstick_visual)

/// Plays the empty copy of a one-shot on the marks child, so the marks vanish for exactly that long.
/datum/component/breast_animation/proc/flick_lipstick_child(shot)
	if(!lipstick_visual || (lipstick_visual.vis_flags & VIS_HIDE))
		return
	var/shot_state = "pair_[size]_[shot]_front_ADJ"
	if(icon_exists(LIPSTICK_BREAST_CHILD_ICON, shot_state))
		flick(shot_state, lipstick_visual)

/// Marks child state for the front breasts at a size, or null when the nipples show no mark.
/mob/living/carbon/human/proc/get_lipstick_breast_child_state(size)
	var/list/mark = lipstick_marks?[LIPSTICK_SPOT_NIPPLES]
	if(!mark || HAS_TRAIT(src, TRAIT_HUSK) || !is_lipstick_spot_visible(LIPSTICK_SPOT_NIPPLES))
		return null
	if(get_lipstick_shown_alpha(mark) <= 0)
		return null
	return find_lipstick_art_state(LIPSTICK_BREAST_CHILD_ICON, "nipples-", "-pair_[size]_front_ADJ", mark)
