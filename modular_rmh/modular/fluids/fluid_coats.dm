// Body fluids landing on skin: per-zone coats that dry to crust, draw clipped to the body sprite and wash off.

/// The garment globs plus a cool shadow, so they read on pale skin.
#define COAT_PATTERN_ICON 'modular_rmh/icons/obj/genitals/body_coat.dmi'
#define COAT_PATTERN_VARIANTS 3
/// Wet coats dry into crust after this long.
#define FLUID_COAT_DRY_TIME (12 MINUTES)

/// A fluid-coated body zone: wet fluid that can be licked, or the crust it dries into.
/datum/fluid_coat
	var/zone
	/// Wet fluid on the skin; null once dried.
	var/datum/reagents/fluids
	/// When the wet fluid dries into crust.
	var/dry_at = 0
	/// What the crust is made of, once dried: "semen", "milk", "nectar" or a fluid name.
	var/dried_kind
	var/dried_level = 0
	/// Which pattern this zone draws, so it keeps its look between redraws.
	var/variant = 1

/datum/fluid_coat/New(new_zone)
	zone = new_zone
	variant = rand(1, COAT_PATTERN_VARIANTS)

/datum/fluid_coat/Destroy(force)
	QDEL_NULL(fluids)
	return ..()

/datum/fluid_coat/proc/is_wet()
	return fluids?.total_volume > 0

/// Semen, milk and nectar get their own look; other fluids tint by colour.
/datum/fluid_coat/proc/get_kind()
	if(!is_wet())
		return dried_kind
	var/datum/reagent/main = fluids.get_master_reagent()
	if(istype(main, /datum/reagent/consumable/cum))
		return "semen"
	if(istype(main, /datum/reagent/consumable/milk))
		return "milk"
	if(istype(main, /datum/reagent/consumable/femcum))
		return "nectar"
	return LOWER_TEXT(main?.name)

/datum/fluid_coat/proc/get_level()
	if(!is_wet())
		return dried_level
	return fluids.total_volume >= FLUID_COAT_HEAVY_UNITS ? 2 : 1

/datum/fluid_coat/proc/dry()
	dried_kind = get_kind()
	dried_level = get_level()
	QDEL_NULL(fluids)

/// Per-zone fluid coats on a human; wet coats dry to crust, and washing clears them.
/datum/component/fluid_coated
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Coat zone mapped to its /datum/fluid_coat.
	var/list/coats = list()
	/// Overlays this component put on the mob.
	var/list/applied_overlays = list()

/datum/component/fluid_coated/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/fluid_coated/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_wash))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(on_wash_face))

/datum/component/fluid_coated/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_COMPONENT_CLEAN_FACE_ACT))

/datum/component/fluid_coated/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	var/atom/movable/owner = parent
	owner?.cut_overlay(applied_overlays)
	applied_overlays.Cut()
	QDEL_LIST_ASSOC_VAL(coats)
	return ..()

/// Coats a zone from the source and returns the units it took; the zone holds up to FLUID_COAT_CAPACITY.
/datum/component/fluid_coated/proc/add_coat(zone, datum/reagents/source, amount)
	var/datum/fluid_coat/coat = coats[zone]
	if(!coat)
		coat = new(zone)
		coats[zone] = coat
	if(!coat.fluids)
		coat.fluids = new /datum/reagents(FLUID_COAT_CAPACITY, NO_REACT)
	var/room = coat.fluids.maximum_volume - coat.fluids.total_volume
	if(room <= 0 || amount <= 0)
		return 0
	. = source.trans_to(coat.fluids, min(amount, room), no_react = TRUE) || 0
	coat.dry_at = world.time + FLUID_COAT_DRY_TIME
	START_PROCESSING(SSobj, src)
	update_coat_overlays()

/datum/component/fluid_coated/proc/remove_coat(zone)
	var/datum/fluid_coat/coat = coats[zone]
	if(!coat)
		return
	coats -= zone
	qdel(coat)
	if(!length(coats))
		qdel(src)
		return
	update_coat_overlays()

/datum/component/fluid_coated/process(seconds_per_tick)
	var/changed = FALSE
	var/any_wet = FALSE
	for(var/zone in coats)
		var/datum/fluid_coat/coat = coats[zone]
		if(!coat.is_wet())
			continue
		if(world.time >= coat.dry_at)
			coat.dry()
			changed = TRUE
		else
			any_wet = TRUE
	if(changed)
		update_coat_overlays()
	if(!any_wet)
		return PROCESS_KILL

/datum/component/fluid_coated/proc/on_wash(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & (CLEAN_WASH | CLEAN_SCRUB | CLEAN_ALL)))
		return
	var/mob/living/owner = parent
	if(!owner.has_stress_type(/datum/stress_event/bathcleaned))
		to_chat(owner, span_notice("I feel much cleaner now!"))
		owner.add_stress(/datum/stress_event/bathcleaned)
	qdel(src)

/datum/component/fluid_coated/proc/on_wash_face(datum/source, clean_types)
	SIGNAL_HANDLER
	remove_coat(FLUID_COAT_FACE)

/// The wet zone a partner can lick first, among those not hidden by clothes.
/datum/component/fluid_coated/proc/get_lickable_zone()
	var/mob/living/carbon/human/owner = parent
	for(var/zone in list(FLUID_COAT_FACE, FLUID_COAT_CHEST, FLUID_COAT_BELLY, FLUID_COAT_GROIN, FLUID_COAT_THIGHS, FLUID_COAT_FEET, FLUID_COAT_BACK))
		var/datum/fluid_coat/coat = coats[zone]
		if(coat?.is_wet() && !owner.get_coat_zone_cover(zone))
			return zone
	return null

/// Licks a mouthful off the zone into the licker; a licked-clean zone leaves no crust.
/datum/component/fluid_coated/proc/lick_zone(zone, mob/living/licker)
	var/datum/fluid_coat/coat = coats[zone]
	if(!coat?.is_wet())
		return 0
	. = sip_reagents(coat.fluids, licker, FLUID_LICK_AMOUNT, licker)
	if(coat.fluids.total_volume < FLUID_LICK_MIN_VOLUME)
		remove_coat(zone)
	else
		update_coat_overlays()

/datum/component/fluid_coated/proc/update_coat_overlays()
	var/mob/living/carbon/human/owner = parent
	owner.cut_overlay(applied_overlays)
	applied_overlays.Cut()
	var/list/part_sprites = owner.get_coat_part_sprites()
	for(var/zone in coats)
		var/datum/fluid_coat/coat = coats[zone]
		var/level = coat.get_level()
		if(!level)
			continue
		var/coat_icon = get_fluid_coat_icon(part_sprites, zone, level, coat.variant)
		if(!coat_icon)
			continue
		var/mutable_appearance/overlay = mutable_appearance(coat_icon, "", -BODY_LAYER)
		overlay.appearance_flags = RESET_COLOR | RESET_ALPHA
		apply_coat_tint(overlay, coat)
		applied_overlays += overlay
	owner.add_overlay(applied_overlays)

/datum/component/fluid_coated/proc/apply_coat_tint(mutable_appearance/overlay, datum/fluid_coat/coat)
	if(!coat.is_wet())
		overlay.color = "#e4d7ae"
		overlay.alpha = 175
		return
	switch(coat.get_kind())
		if("semen")
			overlay.color = "#f7f8fc"
		if("milk")
			overlay.color = "#fbf6e4"
			overlay.alpha = 225
		if("nectar")
			overlay.color = "#dce8ee"
			overlay.alpha = 150
		else
			overlay.color = mix_color_from_reagents(coat.fluids.reagent_list)
			overlay.alpha = 200

/// Examine lines for visible coats: one zone is named, several read as covered in juices.
/datum/component/fluid_coated/proc/get_examine_lines(mob/user, list/P)
	. = list()
	var/mob/living/carbon/human/owner = parent
	var/list/visible = list()
	for(var/zone in coats)
		if(isobserver(user) || !owner.get_coat_zone_cover(zone))
			visible += coats[zone]
	if(!length(visible))
		return
	var/mob/living/viewer = user
	if(user != owner && isliving(viewer) && (viewer.STAPER < 8 || viewer.STAINT < 5))
		. += span_warning("[P[THEYRE]] smeared with something glossy!")
		return
	if(length(visible) > 1)
		var/all_dry = TRUE
		for(var/datum/fluid_coat/coat as anything in visible)
			if(coat.is_wet())
				all_dry = FALSE
		. += span_info(all_dry ? "[P[THEYRE]] crusted with dried juices!" : "[P[THEYRE]] covered in juices!")
		return
	var/datum/fluid_coat/coat = visible[1]
	. += span_info(get_single_coat_line(coat, P))

/datum/component/fluid_coated/proc/get_single_coat_line(datum/fluid_coat/coat, list/P)
	var/mob/living/carbon/human/owner = parent
	var/kind = coat.get_kind()
	var/stuff = kind == "semen" ? "cum" : (kind == "nectar" ? "juices" : kind)
	var/wet = coat.is_wet()
	var/their = P[THEIR]
	switch(coat.zone)
		if(FLUID_COAT_FACE)
			return wet ? "[capitalize(their)] face is glazed with [stuff]!" : "[capitalize(their)] face is plastered with dried [stuff]!"
		if(FLUID_COAT_CHEST)
			var/chest = owner.getorganslot(ORGAN_SLOT_BREASTS) ? "tits are" : "chest is"
			return wet ? "[capitalize(their)] [chest] glazed with [stuff]!" : "[capitalize(their)] [chest] crusted with dried [stuff]!"
		if(FLUID_COAT_BELLY)
			return wet ? "[capitalize(their)] belly is glazed with [stuff]!" : "[capitalize(their)] belly is crusted with dried [stuff]!"
		if(FLUID_COAT_GROIN)
			return wet ? "[capitalize(their)] crotch is smeared with [stuff]!" : "[capitalize(their)] crotch is crusted with dried [stuff]!"
		if(FLUID_COAT_BACK)
			return wet ? "[capitalize(their)] back is glazed with [stuff]!" : "[capitalize(their)] back is crusted with dried [stuff]!"
		if(FLUID_COAT_THIGHS)
			return wet ? "[capitalize(stuff)] [stuff == "juices" ? "run" : "runs"] down [their] thighs!" : "[capitalize(their)] thighs are crusted with dried [stuff]!"
		if(FLUID_COAT_FEET)
			return wet ? "[capitalize(their)] feet are glazed with [stuff]!" : "[capitalize(their)] feet are crusted with dried [stuff]!"

/// Puts fluid on a body zone: cloth over it soaks it, bare skin gets coated; returns the units left for the floor.
/mob/living/carbon/human/proc/coat_with_fluid(zone, datum/reagents/source, amount)
	amount = min(amount, source?.total_volume)
	if(amount <= 0)
		return 0
	var/obj/item/clothing/cover = get_coat_zone_cover(zone)
	if(cover)
		if(cover.can_soak_fluid())
			amount -= cover.soak_fluid(source, amount, zone == FLUID_COAT_CHEST ? FLUID_STAIN_CHEST : cover.fluid_stain_zone)
		return max(amount, 0)
	var/datum/component/fluid_coated/coated = LoadComponent(/datum/component/fluid_coated)
	return max(amount - coated.add_coat(zone, source, amount), 0)

/// The outermost worn clothing over a coat zone, or null when the skin there is bare.
/mob/living/carbon/human/proc/get_coat_zone_cover(zone)
	var/static/list/zone_flags = list(
		FLUID_COAT_FACE = FACE,
		FLUID_COAT_CHEST = CHEST,
		FLUID_COAT_BELLY = CHEST | VITALS,
		FLUID_COAT_GROIN = GROIN,
		FLUID_COAT_BACK = CHEST,
		FLUID_COAT_THIGHS = LEGS,
		FLUID_COAT_FEET = FEET,
	)
	var/static/list/slots_outside_in = list(ITEM_SLOT_CLOAK, ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_PANTS, ITEM_SLOT_SHOES, ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_SOCKS, ITEM_SLOT_UNDER_TOP, ITEM_SLOT_UNDER_BOTTOM)
	var/flags = zone_flags[zone]
	for(var/slot in slots_outside_in)
		var/obj/item/clothing/garment = get_item_by_slot(slot)
		if(!istype(garment) || !(garment.body_parts_covered & flags))
			continue
		// Open garments, like skirts, let fluid reach the chest and crotch.
		if(garment.genital_access && (zone == FLUID_COAT_CHEST || zone == FLUID_COAT_GROIN))
			continue
		return garment
	return null

/// Each drawn bodypart's sprite as body zone -> list(icon file, icon state).
/mob/living/carbon/human/proc/get_coat_part_sprites()
	. = list()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(!part.species_icon)
			continue
		.[part.body_zone] = list(part.species_icon, part.is_organic_limb() ? part.body_zone : "pr_[part.body_zone]")

/// Which body parts and rows each coat zone covers, and the directions it shows from.
/proc/get_fluid_coat_zone_layout(zone)
	var/static/list/front = list(SOUTH, EAST, WEST)
	var/static/list/all_dirs = list(SOUTH, NORTH, EAST, WEST)
	var/static/list/layouts = list(
		FLUID_COAT_FACE = list("dirs" = front, "parts" = list(list(BODY_ZONE_HEAD, 0, 1))),
		FLUID_COAT_CHEST = list("dirs" = front, "parts" = list(list(BODY_ZONE_CHEST, 0, 0.45))),
		FLUID_COAT_BELLY = list("dirs" = front, "parts" = list(list(BODY_ZONE_CHEST, 0.45, 0.8))),
		FLUID_COAT_GROIN = list("dirs" = front, "parts" = list(list(BODY_ZONE_CHEST, 0.8, 1), list(BODY_ZONE_L_LEG, 0, 0.2), list(BODY_ZONE_R_LEG, 0, 0.2))),
		FLUID_COAT_BACK = list("dirs" = list(NORTH), "parts" = list(list(BODY_ZONE_CHEST, 0, 0.85))),
		FLUID_COAT_THIGHS = list("dirs" = all_dirs, "parts" = list(list(BODY_ZONE_L_LEG, 0, 0.55), list(BODY_ZONE_R_LEG, 0, 0.55))),
		FLUID_COAT_FEET = list("dirs" = all_dirs, "parts" = list(list(BODY_ZONE_L_LEG, 0.72, 1), list(BODY_ZONE_R_LEG, 0.72, 1))),
	)
	return layouts[zone]

/// Top and bottom rows (BYOND y, bottom is 1) of a sprite's visible pixels in one direction, cached.
/proc/get_sprite_row_span(icon_file, icon_state, dir)
	var/static/list/span_cache = list()
	var/cache_key = "[icon_file]|[icon_state]|[dir]"
	. = span_cache[cache_key]
	if(.)
		return
	var/icon/sprite = icon(icon_file, icon_state, dir)
	var/top = 0
	var/bottom = 0
	for(var/y in sprite.Height() to 1 step -1)
		for(var/x in 1 to sprite.Width())
			if(sprite.GetPixel(x, y))
				if(!top)
					top = y
				bottom = y
				break
	. = list(top, bottom)
	span_cache[cache_key] = .

/// A white mask of the rows between top_share and bottom_share of a part's height, measured from its top.
/proc/get_coat_zone_mask(icon_file, icon_state, dir, top_share, bottom_share)
	var/icon/mask = icon(icon_file, icon_state, dir)
	var/list/span = get_sprite_row_span(icon_file, icon_state, dir)
	if(!span[1])
		return null
	mask.Blend("#ffffff", ICON_ADD)
	var/height = span[1] - span[2] + 1
	var/zone_top = span[1] - round(height * top_share)
	var/zone_bottom = span[1] - round(height * bottom_share) + 1
	if(zone_top < mask.Height())
		mask.DrawBox(null, 1, zone_top + 1, mask.Width(), mask.Height())
	if(zone_bottom > 1)
		mask.DrawBox(null, 1, 1, mask.Width(), zone_bottom - 1)
	return mask

/// A 4-direction coat for one zone, the pattern clipped to the wearer's own body parts; cached as a resource.
/proc/get_fluid_coat_icon(list/part_sprites, zone, level, variant)
	var/list/layout = get_fluid_coat_zone_layout(zone)
	if(!layout)
		return null
	var/cache_key = "[zone]|[level]|[variant]"
	for(var/list/segment as anything in layout["parts"])
		var/list/sprite = part_sprites[segment[1]]
		cache_key += "|[sprite?[1]]:[sprite?[2]]"
	var/static/list/coat_cache = list()
	. = coat_cache[cache_key]
	if(.)
		return
	var/icon/result = new
	var/drew_any = FALSE
	for(var/dir in list(SOUTH, NORTH, EAST, WEST))
		var/icon/frame
		if(dir in layout["dirs"])
			for(var/list/segment as anything in layout["parts"])
				var/list/sprite = part_sprites[segment[1]]
				if(!sprite)
					continue
				var/icon/mask = get_coat_zone_mask(sprite[1], sprite[2], dir, segment[2], segment[3])
				if(!mask)
					continue
				if(frame)
					frame.Blend(mask, ICON_OVERLAY)
				else
					frame = mask
		var/icon/pattern = icon(COAT_PATTERN_ICON, "semen_[level]_[variant]", dir)
		if(frame)
			if(pattern.Width() != frame.Width() || pattern.Height() != frame.Height())
				pattern.Scale(frame.Width(), frame.Height())
			frame.Blend(pattern, ICON_MULTIPLY)
			drew_any = TRUE
		else
			frame = pattern
			frame.DrawBox(null, 1, 1, frame.Width(), frame.Height())
		result.Insert(frame, "", dir)
	if(!drew_any)
		return null
	. = fcopy_rsc(result)
	coat_cache[cache_key] = .

/// Where a bare leak from this organ runs down the body, or null if it just drips.
/obj/item/organ/genitals/filling_organ/proc/get_leak_coat_zone()
	switch(slot)
		if(ORGAN_SLOT_BREASTS)
			return FLUID_COAT_CHEST
		if(ORGAN_SLOT_VAGINA)
			return FLUID_COAT_THIGHS
		if(ORGAN_SLOT_TESTICLES)
			return FLUID_COAT_GROIN
	return null

/// Part of a bare leak clings to the skin below the opening; returns the units that still drip.
/obj/item/organ/genitals/filling_organ/proc/cling_to_skin(amount)
	var/zone = get_leak_coat_zone()
	if(!zone || !ishuman(owner))
		return amount
	var/mob/living/carbon/human/human_owner = owner
	var/share = amount * FLUID_COAT_LEAK_SHARE
	var/not_clinging = human_owner.coat_with_fluid(zone, reagents, share)
	return amount - (share - not_clinging)

/datum/sex_action
	/// Where a climax onto the partner lands; null means where the climaxer aims on the targeting doll.
	var/climax_coat_zone

/datum/sex_action/proc/get_climax_coat_zone(mob/living/climaxer)
	if(climax_coat_zone)
		return climax_coat_zone
	return body_zone_to_coat_zone(climaxer?.zone_selected)

/// Maps a targeting-doll zone to the coat zone it aims at; anything unmapped lands on the chest.
/proc/body_zone_to_coat_zone(body_zone)
	switch(body_zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NECK)
			return FLUID_COAT_FACE
		if(BODY_ZONE_PRECISE_STOMACH)
			return FLUID_COAT_BELLY
		if(BODY_ZONE_PRECISE_GROIN)
			return FLUID_COAT_GROIN
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return FLUID_COAT_THIGHS
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return FLUID_COAT_FEET
	return FLUID_COAT_CHEST

// Actions that finish onto the partner at a fixed spot; others follow the climaxer's aim.
/datum/sex_action/sex/vaginal
	climax_coat_zone = FLUID_COAT_BELLY

/datum/sex_action/sex/other/vagina
	climax_coat_zone = FLUID_COAT_BELLY

/datum/sex_action/bellyriding
	climax_coat_zone = FLUID_COAT_BELLY

/datum/sex_action/held_mob_fuck
	climax_coat_zone = FLUID_COAT_BELLY

/datum/sex_action/npc/npc_vaginal_sex
	climax_coat_zone = FLUID_COAT_BELLY

/datum/sex_action/npc/npc_vaginal_ride_sex
	climax_coat_zone = FLUID_COAT_BELLY

/// Licks body fluid off a partner's bare skin.
/datum/sex_action/lick_coat
	name = "Lick clean"
	description = "Lick the fluid off their bare skin."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	check_same_tile = FALSE

/datum/sex_action/lick_coat/proc/get_zone(mob/living/target)
	var/datum/component/fluid_coated/coated = target?.GetComponent(/datum/component/fluid_coated)
	return coated?.get_lickable_zone()

/datum/sex_action/lick_coat/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && !!get_zone(target)

/datum/sex_action/lick_coat/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !get_zone(target))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/lick_coat/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!get_zone(target)

/datum/sex_action/lick_coat/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] leans in to lick [target] clean..."))

/datum/sex_action/lick_coat/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/zone = get_zone(target)
	if(!zone)
		return
	var/datum/component/fluid_coated/coated = target.GetComponent(/datum/component/fluid_coated)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] licks the mess off [target]'s [zone]..."))
	user.make_sucking_noise()
	coated.lick_zone(zone, user)
	perform_sex_action(target, user, 0.4, 0, 0.2)
	perform_sex_action(user, target, 0.3, 0, 0)

/datum/sex_action/lick_coat/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops licking [target]."))

/datum/sex_action/lick_coat/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)

#undef COAT_PATTERN_ICON
#undef COAT_PATTERN_VARIANTS
#undef FLUID_COAT_DRY_TIME
