// "View holes": every hole's wear, fill and contents, with the womb and any egg host behind them.

/mob/living/carbon/human/verb/view_holes()
	set name = "View holes"
	set category = "IC"
	set desc = "Look inward at the state of your holes."

	if(stat == DEAD)
		to_chat(src, span_warning("I can't feel anything. I'm dead."))
		return
	open_hole_status(src)

/mob/living/carbon/human
	/// The one holes window datum per body; another open call refreshes it instead of stacking windows.
	var/datum/hole_status_menu/hole_status_menu

/mob/living/carbon/human/proc/open_hole_status(mob/user = src)
	if(QDELETED(hole_status_menu))
		hole_status_menu = new(src)
	hole_status_menu.ui_interact(user)

/datum/hole_status_menu
	var/mob/living/carbon/human/owner

/datum/hole_status_menu/New(mob/living/carbon/human/_owner)
	owner = _owner

/datum/hole_status_menu/Destroy()
	if(owner?.hole_status_menu == src)
		owner.hole_status_menu = null
	owner = null
	return ..()

/datum/hole_status_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/hole_status_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, get_interface_name(user))
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/hole_status_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui?.user
	if(action == "toggle_art")
		return toggle_hole_art(user)
	if(!owner || QDELETED(owner) || user != owner)
		return FALSE

	switch(action)
		if("set_organ_setting")
			return set_organ_setting(params)
		if("toggle_organ_trait")
			return toggle_organ_trait(params)
		if("edit_organ_text")
			return edit_organ_text(params, user)
		if("pick_organ_color")
			return pick_organ_color(params, user)
		if("push_out_hatchling")
			return push_out_hatchling(params)
		if("retch_up")
			return retch_up(params)
		if("extract_egg")
			return extract_egg(params)
		if("extract_organ_eggs")
			return extract_organ_eggs(params)
		if("lay_ovipositor_eggs")
			return lay_ovipositor_eggs()
		if("insert_item")
			return owner.try_insert_toy(params["hole"])
		if("remove_item")
			var/obj/item/toy = find_owned_toy(params["item_ref"])
			return toy ? owner.try_remove_toy(toy) : FALSE
		if("push_deeper")
			var/obj/item/toy = find_owned_toy(params["item_ref"])
			return toy ? owner.try_push_toy_deeper(toy) : FALSE
		if("push_out")
			return owner.try_push_out_random_toy(owner.get_toy_hole(params["hole"]))

	return FALSE

/// A stored item of the owner's by ref, looked up through the holes so a stale ref finds nothing.
/datum/hole_status_menu/proc/find_owned_toy(item_ref)
	if(!item_ref)
		return null
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, ORGAN_SLOT_BREASTS))
		var/obj/item/organ/hole = get_real_organ(owner, slot)
		var/list/layers = hole ? SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_GET_LISTS) : null
		if(!islist(layers))
			continue
		for(var/layer in layers)
			for(var/obj/item/stored as anything in layers[layer])
				if(REF(stored) == item_ref)
					return stored
	return null

/datum/hole_status_menu/ui_close(mob/user)
	qdel(src)

/datum/hole_status_menu/proc/get_interface_name(mob/user)
	return get_preferred_ui_language(user) == "ru" ? "HoleStatusRu" : "HoleStatus"

/datum/hole_status_menu/ui_data(mob/user)
	var/list/data = list()
	if(!owner || QDELETED(owner))
		return data

	data["show_art"] = hole_art_enabled(user)
	data["nutriment"] = round(owner.get_reagent_amount(/datum/reagent/consumable/nutriment), 0.1)
	data["holding_in"] = owner.is_holding_fluids_in()
	data["holes"] = list()
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_real_organ(owner, ORGAN_SLOT_VAGINA)
	if(istype(vagina))
		UNTYPED_LIST_ADD(data["holes"], build_hole(vagina, "vagina"))
	var/obj/item/organ/genitals/filling_organ/anus/anus = get_real_organ(owner, ORGAN_SLOT_ANUS)
	if(istype(anus))
		UNTYPED_LIST_ADD(data["holes"], build_hole(anus, "anus"))
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = get_real_organ(owner, ORGAN_SLOT_BREASTS)
	if(istype(breasts))
		UNTYPED_LIST_ADD(data["holes"], build_hole(breasts, "breasts"))
	data["womb"] = build_womb()
	data["stomach"] = build_stomach()
	data["ovipositor"] = build_ovipositor()
	data["labour"] = build_labour()
	data["births"] = owner.get_oviposition_birth_status()
	return data

/datum/hole_status_menu/proc/build_labour()
	var/datum/status_effect/labour/labour = owner.has_status_effect(/datum/status_effect/labour)
	if(!labour)
		return null
	return list(
		"pushing" = labour.is_pushing(),
		"contractions" = labour.contractions_done,
		"needed" = labour.contractions_needed,
		"births" = labour.births,
	)

// ---- Holes ----

/datum/hole_status_menu/proc/build_hole(obj/item/organ/genitals/filling_organ/hole, hole_id)
	var/list/d = list()
	d["id"] = hole_id
	d["name"] = hole.name
	d["wear"] = build_wear(hole)
	d["fill"] = build_fill(hole)
	d["can_hold_in"] = hole.can_hold_in
	d["items"] = build_items(hole)
	d["can_push_out"] = can_push_out_blind(hole)
	d["insert"] = build_insert(hole)
	d["eggs"] = list()
	d["hatchling_count"] = 0
	d["hatchlings"] = list()
	if(istype(hole, /obj/item/organ/genitals/filling_organ/breasts))
		d["size"] = clamp(round(hole.organ_size), MIN_BREASTS_SIZE, MAX_BREASTS_SIZE)
	if(hole.supports_oviposition_pregnancy())
		for(var/obj/item/oviposition_egg/egg as anything in hole.get_oviposition_eggs())
			UNTYPED_LIST_ADD(d["eggs"], build_single_egg(egg))
		d["hatchling_count"] = hole.count_internal_womb_hatchlings()
		d["hatchlings"] = build_hatchlings(hole)
	d["egg_count"] = length(d["eggs"])
	return d

/// Wear and tear words come as ids; the window translates them.
/datum/hole_status_menu/proc/build_wear(obj/item/organ/genitals/filling_organ/hole)
	var/datum/orifice/opening = hole.get_orifice()
	if(!opening)
		return null
	var/list/w = list()
	var/tightness = owner.get_erp_pref(opening.tightness_pref_type)
	w["tightness"] = istext(tightness) ? tightness : null
	w["stretch"] = opening.get_stretch_id()
	w["stretch_pct"] = round(opening.get_stretch_ratio() * 100)
	w["lube"] = opening.get_lube_id()
	w["soreness"] = opening.get_soreness_id()
	w["gaped"] = opening.gaped
	w["gaping_soon"] = !opening.gaped && opening.get_gape_strain() >= ORIFICE_GAPE_WARN_STRAIN
	w["open_frac"] = round(opening.get_open_fraction(), 0.01)
	return w

/datum/hole_status_menu/proc/build_fill(obj/item/organ/genitals/filling_organ/organ)
	var/list/f = list()
	f["volume"] = round(organ.reagents?.total_volume, 0.1)
	f["capacity"] = round(organ.reagents?.maximum_volume, 0.1)
	var/datum/reagent/main_fluid = organ.reagents?.get_master_reagent()
	f["main_fluid"] = main_fluid ? LOWER_TEXT(main_fluid.name) : null
	f["seed_units"] = round(get_seed_units(organ), 0.1)
	f["own_units"] = round(organ.get_own_fluid_amount(), 0.1)
	return f

/// Every kind of seed inside, fertile or not.
/datum/hole_status_menu/proc/get_seed_units(obj/item/organ/genitals/filling_organ/organ)
	. = 0
	for(var/datum/reagent/consumable/cum/seed in organ.reagents?.reagent_list)
		. += seed.volume

/// Stored items by layer; eggs, hatchlings and the penetration stand-in are shown elsewhere or not at all.
/datum/hole_status_menu/proc/build_items(obj/item/organ/genitals/filling_organ/hole)
	var/list/items = list()
	var/list/layers = SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_GET_LISTS)
	if(!islist(layers))
		return items
	var/static/list/layer_ids = list(STORAGE_LAYER_OUTER = "outer", STORAGE_LAYER_INNER = "inner", STORAGE_LAYER_DEEP = "deep")
	var/free = isnull(owner.get_hole_toy_block_reason(hole))
	// Picking one item by feel needs Sensitiveness; everyone else pushes blind.
	var/by_feel = owner.can_feel_stored_items()
	for(var/layer in layer_ids)
		for(var/obj/item/stored as anything in layers[layer])
			if(istype(stored, /obj/item/oviposition_egg) || istype(stored, /obj/item/mob_holder/internal_womb) || istype(stored, /obj/item/penis_fake))
				continue
			var/can_remove = stored.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL)
			UNTYPED_LIST_ADD(items, list(
				"ref" = REF(stored),
				"name" = stored.name,
				"layer" = layer_ids[layer],
				"can_remove" = can_remove,
				"can_take" = free && by_feel && can_remove,
				"take_seconds" = round(hole.get_toy_remove_time(stored, layer) / 10, 1),
				"take_fail_pct" = round(hole.get_toy_remove_fail_chance(stored, layer)),
				"can_push_deeper" = free && by_feel && isnull(owner.get_toy_push_deeper_block_reason(hole, stored)),
			))
	return items

/// Whether the blind push-out button shows: something removable in there, and no feel for which.
/datum/hole_status_menu/proc/can_push_out_blind(obj/item/organ/genitals/filling_organ/hole)
	if(owner.can_feel_stored_items() || !isnull(owner.get_hole_toy_block_reason(hole)))
		return FALSE
	return length(owner.get_pushable_toys(hole)) > 0

/// What the held item would take to work in: time, fail chance, or the reason it cannot.
/datum/hole_status_menu/proc/build_insert(obj/item/organ/genitals/filling_organ/hole)
	var/obj/item/held = owner.get_active_held_item()
	if(!held)
		return null
	var/list/d = list("name" = held.name)
	var/reason = owner.get_hole_toy_block_reason(hole) || owner.get_toy_insert_block_reason(hole, held)
	d["reason"] = reason
	if(!reason)
		d["seconds"] = round(hole.get_toy_insert_time(held) / 10, 1)
		d["fail_pct"] = round(hole.get_toy_insert_fail_chance(held))
		var/datum/orifice/opening = hole.get_orifice()
		d["fit"] = opening ? opening.get_fit_hint(held.get_insert_girth()) : null
	return d

// ---- Womb and the other egg hosts ----

/datum/hole_status_menu/proc/build_womb()
	var/obj/item/organ/genitals/filling_organ/womb/womb = owner.get_womb()
	if(!womb)
		return null
	var/list/d = list()
	d["fertile"] = womb.fertility
	d["contraceptive"] = owner.has_fluid_modifier(/datum/fluid_modifier/barren_womb)
	d["fill"] = build_fill(womb)
	// A new pregnancy stays hidden until the belly shows it.
	d["pregnancy_stage"] = (womb.pregnant && womb.conventional_pregnancy_stage >= 1) ? womb.conventional_pregnancy_stage : 0
	d["max_stage"] = PREGNANCY_MAX_STAGE
	d["organ"] = build_womb_organ(womb)
	return d

/datum/hole_status_menu/proc/build_womb_organ(obj/item/organ/genitals/filling_organ/womb/womb)
	var/list/womb_eggs = womb.supports_oviposition_pregnancy() ? womb.get_oviposition_eggs() : list()
	var/is_egg_layer = HAS_TRAIT(owner, TRAIT_EGG_LAYER)
	var/list/od = list()
	od["id"] = "womb"
	od["title"] = "WOMB"
	od["icon"] = "venus"
	od["egg_count"] = length(womb_eggs)
	od["is_egg_layer"] = is_egg_layer
	od["hatchling_count"] = womb.count_internal_womb_hatchlings()
	od["hatchlings"] = build_hatchlings(womb)
	if(is_egg_layer)
		od["egg_capacity"] = womb.oviposition_egg_production_limit
		od["resource_dependent"] = womb.resource_dependent_yield
		od["settings"] = build_womb_settings(womb)
		if(womb.next_oviposition_egg_generation > 0 && length(womb_eggs) < womb.oviposition_egg_production_limit)
			var/remaining = max(0, womb.next_oviposition_egg_generation - world.time)
			od["next_egg_seconds"] = round(remaining / 10, 1)
			od["interval_seconds"] = round(womb.get_oviposition_egg_generation_interval() / 10, 1)
	od["eggs"] = list()
	for(var/obj/item/oviposition_egg/egg as anything in womb_eggs)
		UNTYPED_LIST_ADD(od["eggs"], build_single_egg(egg))
	return od

/// The stomach shows only while something grows in it.
/datum/hole_status_menu/proc/build_stomach()
	var/obj/item/organ/organ = owner.getorganslot(ORGAN_SLOT_GUTS)
	if(!organ || !organ.supports_oviposition_pregnancy())
		return null
	var/list/organ_eggs = organ.get_oviposition_eggs()
	if(!length(organ_eggs) && !organ.count_internal_womb_hatchlings())
		return null
	var/list/od = list()
	od["id"] = ORGAN_SLOT_GUTS
	od["title"] = uppertext(organ.get_oviposition_location_name())
	od["icon"] = "circle"
	od["egg_count"] = length(organ_eggs)
	od["hatchling_count"] = organ.count_internal_womb_hatchlings()
	od["hatchlings"] = build_hatchlings(organ)
	od["eggs"] = list()
	for(var/obj/item/oviposition_egg/egg as anything in organ_eggs)
		UNTYPED_LIST_ADD(od["eggs"], build_single_egg(egg))
	return od

/datum/hole_status_menu/proc/build_ovipositor()
	var/obj/item/organ/genitals/penis/ovipositor/ovi_organ = owner.getorganslot(ORGAN_SLOT_PENIS)
	if(!istype(ovi_organ))
		return null
	var/datum/component/ovipositor/ovi_comp = ovi_organ.GetComponent(/datum/component/ovipositor)
	if(!ovi_comp)
		return null
	var/list/ovi = list()
	ovi["id"] = "ovipositor"
	ovi["title"] = "OVIPOSITOR"
	ovi["icon"] = "mars"
	ovi["egg_count"] = ovi_comp.eggs_stored
	ovi["egg_capacity"] = ovi_comp.get_max_stored_eggs()
	ovi["clutch_size"] = ovi_comp.get_clutch_size()
	ovi["egg_type_name"] = get_egg_type_short_name(ovi_organ.ovi_egg_type)
	ovi["custom_color"] = ovi_organ.custom_egg_color
	ovi["custom_name"] = ovi_organ.custom_egg_name
	ovi["resource_dependent"] = ovi_organ.resource_dependent_yield
	ovi["egg_stage"] = ovi_comp.egg_stage
	ovi["interval_seconds"] = round((ovi_comp.get_egg_stage_time() * 2) / 10, 1)
	ovi["settings"] = build_ovipositor_settings(ovi_organ, ovi_comp)
	ovi["eggs"] = list()
	return ovi

// ---- Egg settings ----

/datum/hole_status_menu/proc/build_egg_type_options()
	var/list/options = list()
	for(var/egg_type in get_oviposition_egg_type_options(FALSE))
		UNTYPED_LIST_ADD(options, list(
			"id" = egg_type,
			"name" = get_egg_type_short_name(egg_type),
		))
	return options

/datum/hole_status_menu/proc/build_trait_options()
	var/list/options = list()
	for(var/trait_flag in get_oviposition_egg_trait_options())
		UNTYPED_LIST_ADD(options, list(
			"id" = trait_flag,
			"name" = get_oviposition_egg_trait_name(trait_flag),
		))
	return options

/datum/hole_status_menu/proc/build_ovipositor_settings(obj/item/organ/genitals/penis/ovipositor/ovipositor, datum/component/ovipositor/ovipositor_component)
	var/list/settings = list()
	settings["can_configure"] = TRUE
	settings["egg_type"] = ovipositor.ovi_egg_type
	settings["egg_type_name"] = get_egg_type_short_name(ovipositor.ovi_egg_type)
	settings["clutch_size"] = ovipositor_component?.get_clutch_size() || ovipositor.egg_clutch_size
	settings["capacity"] = ovipositor_component?.get_max_stored_eggs() || OVI_EGG_MAX_CLUTCH
	settings["max_capacity"] = OVI_EGG_MAX_CLUTCH
	settings["max_clutch"] = OVI_EGG_MAX_CLUTCH
	settings["custom_name"] = ovipositor.custom_egg_name
	settings["custom_desc"] = ovipositor.custom_egg_desc
	settings["custom_organ_desc"] = ovipositor.custom_organ_desc
	settings["custom_color"] = ovipositor.custom_egg_color
	settings["resource_dependent"] = ovipositor.resource_dependent_yield
	settings["egg_scale"] = sanitize_oviposition_scale(ovipositor.egg_scale)
	settings["egg_traits"] = islist(ovipositor.egg_traits) ? ovipositor.egg_traits.Copy() : list()
	settings["available_egg_types"] = build_egg_type_options()
	settings["available_traits"] = build_trait_options()
	settings["color_presets"] = get_oviposition_color_presets(owner)
	settings["nutrient_cost"] = get_oviposition_nutrient_cost(ovipositor.ovi_egg_type, ovipositor.egg_scale, ovipositor.egg_traits, settings["clutch_size"])
	return settings

/datum/hole_status_menu/proc/build_womb_settings(obj/item/organ/genitals/filling_organ/womb/womb)
	var/egg_type = womb.get_generated_oviposition_egg_type() || OVI_EGG_NORMAL
	var/list/settings = list()
	settings["can_configure"] = TRUE
	settings["egg_type"] = egg_type
	settings["egg_type_name"] = get_egg_type_short_name(egg_type)
	settings["clutch_size"] = womb.oviposition_egg_production_limit
	settings["capacity"] = womb.oviposition_egg_production_limit
	settings["max_clutch"] = OVI_EGG_MAX_CLUTCH
	settings["custom_name"] = womb.custom_egg_name
	settings["custom_desc"] = womb.custom_egg_desc
	settings["custom_organ_desc"] = womb.custom_organ_desc
	settings["custom_color"] = womb.custom_egg_color
	settings["resource_dependent"] = womb.resource_dependent_yield
	settings["egg_scale"] = sanitize_oviposition_scale(womb.egg_scale)
	settings["egg_traits"] = islist(womb.egg_traits) ? womb.egg_traits.Copy() : list()
	settings["available_egg_types"] = build_egg_type_options()
	settings["available_traits"] = build_trait_options()
	settings["color_presets"] = get_oviposition_color_presets(owner)
	settings["nutrient_cost"] = get_oviposition_nutrient_cost(egg_type, womb.egg_scale, womb.egg_traits, womb.oviposition_egg_production_limit)
	return settings

/datum/hole_status_menu/proc/build_single_egg(obj/item/oviposition_egg/egg)
	var/list/d = list()
	d["ref"] = REF(egg)
	d["name"] = egg.name
	d["desc"] = egg.desc
	d["type_name"] = get_egg_type_short_name(egg.egg_type)
	d["is_hatchling"] = egg.egg_type == OVI_EGG_EMBRYO
	d["display_color"] = egg.custom_egg_color || egg.color
	d["color_hex"] = egg.custom_egg_color
	d["scale"] = egg.get_egg_scale()
	d["traits"] = islist(egg.egg_traits) ? egg.egg_traits.Copy() : list()
	d["can_remove"] = egg.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL)
	d["mother_name"] = egg.oviposition_mother_name
	d["hatch"] = build_egg_hatch(egg)

	var/datum/component/pregnancy/preg = egg.get_pregnancy_component()
	if(preg)
		d["has_preg"] = TRUE
		d["stage"] = preg.stage
		d["max_stage"] = preg.max_stage
		d["progress_pct"] = round((preg.stage / max(1, preg.max_stage)) * 100)
		d["fertilized"] = preg.fertilized
		d["mother_name"] = egg.oviposition_mother_name
		d["father_name"] = preg.father_name
		if(preg.stage >= preg.max_stage)
			d["status"] = "ready"
		else if(preg.stage > 0)
			d["status"] = "growing"
		else
			d["status"] = "dormant"
		if(preg.stage < preg.max_stage && preg.max_stage > 0)
			d["time_left"] = round(((preg.max_stage - preg.stage) * preg.stage_duration) / 10, 1)
		else
			d["time_left"] = 0
	else
		d["has_preg"] = FALSE
		d["stage"] = 0
		d["max_stage"] = 0
		d["progress_pct"] = 0
		d["status"] = "dormant"
		d["time_left"] = 0

	// Only the stomach has a way up, and only for what fits the throat.
	var/obj/item/organ/host_organ = egg.loc
	d["can_retch"] = istype(host_organ) && host_organ.slot == ORGAN_SLOT_GUTS && isnull(owner.get_retch_block_reason(egg, host_organ))
	return d

// ---- Actions ----

/datum/hole_status_menu/proc/get_configurable_organ(organ_id)
	if(!owner)
		return null
	switch(organ_id)
		if("ovipositor")
			var/obj/item/organ/genitals/penis/ovipositor/ovipositor = owner.getorganslot(ORGAN_SLOT_PENIS)
			return istype(ovipositor) ? ovipositor : null
		if("womb")
			return owner.get_womb()
	return null

/datum/hole_status_menu/proc/set_organ_setting(list/params)
	var/organ_id = params["organ_id"]
	var/field = params["field"]
	var/value = params["value"]
	var/obj/item/organ/organ = get_configurable_organ(organ_id)
	if(!organ || !field)
		return FALSE

	var/obj/item/organ/genitals/penis/ovipositor/ovipositor
	var/obj/item/organ/genitals/filling_organ/womb/womb
	if(istype(organ, /obj/item/organ/genitals/penis/ovipositor))
		ovipositor = organ
	else if(istype(organ, /obj/item/organ/genitals/filling_organ/womb))
		womb = organ

	switch(field)
		if("egg_type")
			if(!(value in get_oviposition_egg_type_options(FALSE)))
				return FALSE
			if(istype(ovipositor))
				ovipositor.set_egg_type(value)
			else if(istype(womb))
				womb.oviposition_egg_production_type = value
		if("clutch_size")
			var/clutch_size = text2num("[value]")
			if(isnull(clutch_size))
				return FALSE
			clutch_size = clamp(round(clutch_size), 1, OVI_EGG_MAX_CLUTCH)
			if(istype(ovipositor))
				ovipositor.set_clutch_size(clutch_size)
			else if(istype(womb))
				womb.oviposition_egg_production_limit = clutch_size
		if("storage_capacity")
			var/storage_capacity = text2num("[value]")
			if(isnull(storage_capacity) || !istype(ovipositor))
				return FALSE
			ovipositor.set_storage_capacity(storage_capacity)
		if("egg_scale")
			var/scale = sanitize_oviposition_scale(value)
			if(istype(ovipositor))
				ovipositor.egg_scale = scale
			else if(istype(womb))
				womb.egg_scale = scale
		if("custom_name")
			var/custom_name = sanitize_oviposition_text(value, OVI_EGG_MAX_CUSTOM_NAME_LENGTH, FALSE)
			if(istype(ovipositor))
				ovipositor.custom_egg_name = custom_name
			else if(istype(womb))
				womb.custom_egg_name = custom_name
		if("custom_desc")
			var/custom_desc = sanitize_oviposition_text(value, OVI_EGG_MAX_CUSTOM_DESC_LENGTH, TRUE)
			if(istype(ovipositor))
				ovipositor.custom_egg_desc = custom_desc
			else if(istype(womb))
				womb.custom_egg_desc = custom_desc
		if("custom_organ_desc")
			var/custom_organ_desc = sanitize_oviposition_text(value, OVI_EGG_MAX_CUSTOM_DESC_LENGTH, TRUE)
			if(istype(ovipositor))
				ovipositor.custom_organ_desc = custom_organ_desc
				ovipositor.update_custom_organ_desc()
			else if(istype(womb))
				womb.custom_organ_desc = custom_organ_desc
				womb.update_custom_organ_desc()
		if("custom_color")
			var/custom_color = sanitize_oviposition_color(value)
			if(istype(ovipositor))
				ovipositor.custom_egg_color = custom_color
			else if(istype(womb))
				womb.custom_egg_color = custom_color
		if("resource_dependent")
			var/enabled = text2num("[value]") ? TRUE : FALSE
			if(istype(ovipositor))
				ovipositor.resource_dependent_yield = enabled
			else if(istype(womb))
				womb.resource_dependent_yield = enabled
		else
			return FALSE
	return TRUE

/datum/hole_status_menu/proc/edit_organ_text(list/params, mob/user)
	if(!user)
		return FALSE
	var/organ_id = params["organ_id"]
	var/field = params["field"]
	var/obj/item/organ/organ = get_configurable_organ(organ_id)
	if(!organ || !(field in list("custom_name", "custom_desc", "custom_organ_desc")))
		return FALSE

	var/current_value = ""
	var/title = "Egg Setting"
	var/message = "Enter a value."
	var/max_length = OVI_EGG_MAX_CUSTOM_DESC_LENGTH
	var/multiline = TRUE

	var/obj/item/organ/genitals/penis/ovipositor/ovipositor
	var/obj/item/organ/genitals/filling_organ/womb/womb
	if(istype(organ, /obj/item/organ/genitals/penis/ovipositor))
		ovipositor = organ
	else if(istype(organ, /obj/item/organ/genitals/filling_organ/womb))
		womb = organ

	switch(field)
		if("custom_name")
			current_value = ovipositor ? ovipositor.custom_egg_name : womb.custom_egg_name
			title = "Egg Name"
			message = "Choose the custom egg name."
			max_length = OVI_EGG_MAX_CUSTOM_NAME_LENGTH
			multiline = FALSE
		if("custom_desc")
			current_value = ovipositor ? ovipositor.custom_egg_desc : womb.custom_egg_desc
			title = "Egg Description"
			message = "Write the custom egg description."
		if("custom_organ_desc")
			current_value = ovipositor ? ovipositor.custom_organ_desc : womb.custom_organ_desc
			title = "Organ Description"
			message = "Write the custom organ description."

	var/new_value = tgui_input_text(user, message, title, current_value, max_length, multiline, encode = FALSE)
	if(isnull(new_value))
		return FALSE
	return set_organ_setting(list("organ_id" = organ_id, "field" = field, "value" = new_value))

/datum/hole_status_menu/proc/pick_organ_color(list/params, mob/user)
	if(!user)
		return FALSE
	var/organ_id = params["organ_id"]
	var/obj/item/organ/organ = get_configurable_organ(organ_id)
	if(!organ)
		return FALSE

	var/current_color = "#eee3c7"
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor
	var/obj/item/organ/genitals/filling_organ/womb/womb
	if(istype(organ, /obj/item/organ/genitals/penis/ovipositor))
		ovipositor = organ
		current_color = ovipositor.custom_egg_color || current_color
	else if(istype(organ, /obj/item/organ/genitals/filling_organ/womb))
		womb = organ
		current_color = womb.custom_egg_color || current_color

	var/new_color = tgui_color_picker(user, "Choose the custom egg color.", "Egg Color", current_color)
	if(!new_color)
		return FALSE
	return set_organ_setting(list("organ_id" = organ_id, "field" = "custom_color", "value" = new_color))

/datum/hole_status_menu/proc/toggle_organ_trait(list/params)
	var/organ_id = params["organ_id"]
	var/trait_flag = params["trait"]
	if(!(trait_flag in get_oviposition_egg_trait_options()))
		return FALSE
	var/obj/item/organ/organ = get_configurable_organ(organ_id)
	if(!organ)
		return FALSE

	var/list/traits
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor
	var/obj/item/organ/genitals/filling_organ/womb/womb
	if(istype(organ, /obj/item/organ/genitals/penis/ovipositor))
		ovipositor = organ
	else if(istype(organ, /obj/item/organ/genitals/filling_organ/womb))
		womb = organ
	if(istype(ovipositor))
		traits = islist(ovipositor.egg_traits) ? ovipositor.egg_traits.Copy() : list()
		if(trait_flag in traits)
			traits -= trait_flag
		else
			traits += trait_flag
		ovipositor.egg_traits = sanitize_oviposition_trait_list(traits)
		return TRUE
	if(istype(womb))
		traits = islist(womb.egg_traits) ? womb.egg_traits.Copy() : list()
		if(trait_flag in traits)
			traits -= trait_flag
		else
			traits += trait_flag
		womb.egg_traits = sanitize_oviposition_trait_list(traits)
		return TRUE
	return FALSE

/datum/hole_status_menu/proc/find_owned_egg(egg_ref)
	if(!egg_ref)
		return null
	for(var/slot in list(ORGAN_SLOT_WOMB, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, ORGAN_SLOT_GUTS))
		var/obj/item/organ/organ = owner.getorganslot(slot)
		if(!organ || !organ.supports_oviposition_pregnancy())
			continue
		for(var/obj/item/oviposition_egg/egg as anything in organ.get_oviposition_eggs())
			if(REF(egg) == egg_ref)
				return egg
	return null

/// Pushing an egg out takes time, costs effort and follows the body's rules; see birthing.dm.
/datum/hole_status_menu/proc/extract_egg(list/params)
	var/obj/item/oviposition_egg/egg = find_owned_egg(params["egg_ref"])
	if(!egg)
		return FALSE
	return owner.try_push_out_passenger(egg)

/datum/hole_status_menu/proc/extract_organ_eggs(list/params)
	var/obj/item/organ/organ = get_configurable_organ(params["organ_id"])
	if(!organ || !organ.supports_oviposition_pregnancy())
		return FALSE
	if(!length(organ.get_oviposition_eggs()))
		to_chat(owner, span_warning("There are no eggs there."))
		return FALSE
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, push_out_all_eggs), organ)
	return TRUE

/// One egg onto the floor per press, the same beat the panel's floor act loops.
/datum/hole_status_menu/proc/lay_ovipositor_eggs()
	var/datum/component/ovipositor/ovipositor_component = get_working_ovipositor(owner)
	if(!ovipositor_component)
		return FALSE
	if(owner.stat != CONSCIOUS || owner.incapacitated())
		return FALSE
	// The panel's rules: only armor above light is in the way, and a worn device seals the slot.
	if(owner.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, owner) || owner.is_organ_slot_blocked(ORGAN_SLOT_PENIS))
		to_chat(owner, span_warning("I cannot get my ovipositor free for that."))
		return FALSE
	var/obj/item/oviposition_egg/egg = ovipositor_component.lay_one_egg_on_floor()
	if(!egg)
		if(ovipositor_component.last_lay_reason)
			to_chat(owner, span_warning(ovipositor_component.last_lay_reason))
		return FALSE
	var/word = ovipositor_component.get_egg_kind_is_seed() ? "seed" : "egg"
	owner.visible_message(span_love("[owner] squats and lays a [word] with a shiver."), span_love("I squat and a [word] slides out of me onto the ground."))
	playsound(owner, 'sound/effects/wounds/splatter.ogg', 30, TRUE)
	SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, 2.5, 0, 3, owner)
	return TRUE

/// How the egg will hatch: its kind's mode and chance, and the outcome once it is ripe.
/datum/hole_status_menu/proc/build_egg_hatch(obj/item/oviposition_egg/egg)
	var/list/h = list()
	switch(egg.get_hatch_mode())
		if(OVI_HATCH_INSIDE)
			h["mode"] = "inside"
		if(OVI_HATCH_EITHER)
			h["mode"] = "either"
		else
			h["mode"] = "outside"
	var/datum/component/pregnancy/preg = egg.get_pregnancy_component()
	h["chance"] = preg ? round(preg.get_inside_hatch_chance()) : egg.get_inside_hatch_base_chance()
	if(preg && !isnull(preg.hatch_decision))
		h["decided"] = (preg.hatch_decision == OVI_HATCH_INSIDE) ? "inside" : "outside"
	return h

/// Hatchlings waiting inside [organ]: what they do, and whether the owner may push them out.
/datum/hole_status_menu/proc/build_hatchlings(obj/item/organ/organ)
	var/list/out = list()
	var/list/layers = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_GET_LISTS)
	if(!islist(layers))
		return out
	var/free = TRUE
	var/obj/item/organ/genitals/filling_organ/canal = organ.get_birth_canal()
	if(istype(canal) && canal.orifice_type)
		free = isnull(owner.get_hole_toy_block_reason(canal))
	for(var/layer in layers)
		for(var/obj/item/mob_holder/internal_womb/holder in layers[layer])
			var/datum/component/internal_womb_hatchling/hatchling = holder.GetComponent(/datum/component/internal_womb_hatchling)
			UNTYPED_LIST_ADD(out, list(
				"ref" = REF(holder),
				"name" = holder.held_mob?.name || holder.name,
				"word" = hatchling?.get_word() || "stirring",
				"can_push" = free && holder.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL),
				"can_retch" = organ.slot == ORGAN_SLOT_GUTS && isnull(owner.get_retch_block_reason(holder, organ)),
			))
	return out

/datum/hole_status_menu/proc/find_owned_hatchling(holder_ref)
	if(!holder_ref)
		return null
	for(var/slot in list(ORGAN_SLOT_WOMB, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, ORGAN_SLOT_GUTS))
		var/obj/item/organ/organ = owner.getorganslot(slot)
		var/list/layers = organ ? SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_GET_LISTS) : null
		if(!islist(layers))
			continue
		for(var/layer in layers)
			for(var/obj/item/mob_holder/internal_womb/holder in layers[layer])
				if(REF(holder) == holder_ref)
					return holder
	return null

/// Pushing a hatchling out is a small birth: the push-out rules and the birth feel apply.
/datum/hole_status_menu/proc/push_out_hatchling(list/params)
	var/obj/item/mob_holder/internal_womb/holder = find_owned_hatchling(params["ref"])
	if(!holder)
		return FALSE
	return owner.try_push_out_passenger(holder)

/// Bringing a stomach passenger up by the mouth: a costly heave, no feel, small things only.
/datum/hole_status_menu/proc/retch_up(list/params)
	var/obj/item/passenger = find_owned_egg(params["ref"]) || find_owned_hatchling(params["ref"])
	if(!passenger)
		return FALSE
	return owner.try_retch_up(passenger)

/// Short display name for egg types.
/proc/get_egg_type_short_name(egg_type)
	switch(egg_type)
		if(OVI_EGG_NORMAL)
			return "Hardshell"
		if(OVI_EGG_AVIAN)
			return "Avian"
		if(OVI_EGG_SOFTSHELL)
			return "Softshell"
		if(OVI_EGG_PARASITIC)
			return "Parasitic"
		if(OVI_EGG_SPIDER)
			return "Spider"
		if(OVI_EGG_BOG_BUG)
			return "Bog Bug"
		if(OVI_EGG_HARPY)
			return "Harpy"
		if(OVI_EGG_EMBRYO)
			return "Embryo"
		if(OVI_EGG_MANEATER)
			return "Maneater"
		if(OVI_EGG_MOTHBUG)
			return "Mothbug"
	return "[egg_type]"

/proc/get_oviposition_egg_trait_name(trait_flag)
	switch(trait_flag)
		if(OVI_EGG_TRAIT_APHRODISIAC)
			return "Aphrodisiac"
		if(OVI_EGG_TRAIT_POISON)
			return "Poison"
		if(OVI_EGG_TRAIT_PARASITE)
			return "Parasite"
		if(OVI_EGG_TRAIT_FAST_GROWTH)
			return "Accelerated"
	return "[trait_flag]"

// ---- Pictures ----

/datum/preference/toggle/hole_view_pictures
	savefile_key = "hole_view_pictures"
	savefile_identifier = PREF_PLAYER
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/// Whether viewer sees the organ pictures in the holes window; on unless they turned it off.
/proc/hole_art_enabled(mob/viewer)
	var/datum/preferences/prefs = viewer?.client?.prefs
	if(!prefs)
		return TRUE
	return prefs.read_preference(/datum/preference/toggle/hole_view_pictures)

/datum/hole_status_menu/proc/toggle_hole_art(mob/viewer)
	var/datum/preferences/prefs = viewer?.client?.prefs
	if(!prefs)
		return FALSE
	prefs.toggle_preference(/datum/preference/toggle/hole_view_pictures)
	prefs.save_preferences()
	return TRUE

/datum/hole_status_menu/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/hole_art))

/// 0 to 1: the girth now, from the tightest rest girth to the loosest one stretched to a gape.
/datum/orifice/proc/get_open_fraction()
	var/low = rest_steps[1]
	var/high = rest_steps[length(rest_steps)] * gape_ratio
	return clamp((get_current_girth() - low) / max(high - low, 1), 0, 1)

/// Organ pictures for the holes window; built by hole_art_generator, credits in hole_art/attributions.txt.
/datum/asset/simple/hole_art
	assets = list(
		"hole_anus_0.png" = 'modular_rmh/icons/hole_art/hole_anus_0.png',
		"hole_anus_1.png" = 'modular_rmh/icons/hole_art/hole_anus_1.png',
		"hole_anus_2.png" = 'modular_rmh/icons/hole_art/hole_anus_2.png',
		"hole_anus_3.png" = 'modular_rmh/icons/hole_art/hole_anus_3.png',
		"hole_anus_4.png" = 'modular_rmh/icons/hole_art/hole_anus_4.png',
		"hole_anus_gaped_vagina.png" = 'modular_rmh/icons/hole_art/hole_anus_gaped_vagina.png',
		"hole_anus_slit.png" = 'modular_rmh/icons/hole_art/hole_anus_slit.png',
		"hole_breasts_0.png" = 'modular_rmh/icons/hole_art/hole_breasts_0.png',
		"hole_breasts_1.png" = 'modular_rmh/icons/hole_art/hole_breasts_1.png',
		"hole_breasts_2.png" = 'modular_rmh/icons/hole_art/hole_breasts_2.png',
		"hole_breasts_3.png" = 'modular_rmh/icons/hole_art/hole_breasts_3.png',
		"hole_breasts_4.png" = 'modular_rmh/icons/hole_art/hole_breasts_4.png',
		"hole_breasts_5.png" = 'modular_rmh/icons/hole_art/hole_breasts_5.png',
		"hole_vagina_0.png" = 'modular_rmh/icons/hole_art/hole_vagina_0.png',
		"hole_vagina_1.png" = 'modular_rmh/icons/hole_art/hole_vagina_1.png',
		"hole_vagina_10.png" = 'modular_rmh/icons/hole_art/hole_vagina_10.png',
		"hole_vagina_11.png" = 'modular_rmh/icons/hole_art/hole_vagina_11.png',
		"hole_vagina_2.png" = 'modular_rmh/icons/hole_art/hole_vagina_2.png',
		"hole_vagina_3.png" = 'modular_rmh/icons/hole_art/hole_vagina_3.png',
		"hole_vagina_4.png" = 'modular_rmh/icons/hole_art/hole_vagina_4.png',
		"hole_vagina_5.png" = 'modular_rmh/icons/hole_art/hole_vagina_5.png',
		"hole_vagina_6.png" = 'modular_rmh/icons/hole_art/hole_vagina_6.png',
		"hole_vagina_7.png" = 'modular_rmh/icons/hole_art/hole_vagina_7.png',
		"hole_vagina_8.png" = 'modular_rmh/icons/hole_art/hole_vagina_8.png',
		"hole_vagina_9.png" = 'modular_rmh/icons/hole_art/hole_vagina_9.png',
		"hole_womb.png" = 'modular_rmh/icons/hole_art/hole_womb.png',
		"hole_womb_eggs_1.png" = 'modular_rmh/icons/hole_art/hole_womb_eggs_1.png',
		"hole_womb_eggs_2.png" = 'modular_rmh/icons/hole_art/hole_womb_eggs_2.png',
		"hole_womb_eggs_3.png" = 'modular_rmh/icons/hole_art/hole_womb_eggs_3.png',
		"hole_womb_eggs_4.png" = 'modular_rmh/icons/hole_art/hole_womb_eggs_4.png',
		"hole_womb_eggs_5.png" = 'modular_rmh/icons/hole_art/hole_womb_eggs_5.png',
		"hole_womb_fill_1.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_1.png',
		"hole_womb_fill_10.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_10.png',
		"hole_womb_fill_2.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_2.png',
		"hole_womb_fill_3.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_3.png',
		"hole_womb_fill_4.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_4.png',
		"hole_womb_fill_5.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_5.png',
		"hole_womb_fill_6.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_6.png',
		"hole_womb_fill_7.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_7.png',
		"hole_womb_fill_8.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_8.png',
		"hole_womb_fill_9.png" = 'modular_rmh/icons/hole_art/hole_womb_fill_9.png',
		"hole_womb_preg_1.png" = 'modular_rmh/icons/hole_art/hole_womb_preg_1.png',
		"hole_womb_preg_2.png" = 'modular_rmh/icons/hole_art/hole_womb_preg_2.png',
		"hole_womb_preg_3.png" = 'modular_rmh/icons/hole_art/hole_womb_preg_3.png',
		"hole_womb_preg_4.png" = 'modular_rmh/icons/hole_art/hole_womb_preg_4.png',
		"hole_womb_preg_5.png" = 'modular_rmh/icons/hole_art/hole_womb_preg_5.png',
		"hole_womb_preg_6.png" = 'modular_rmh/icons/hole_art/hole_womb_preg_6.png',
		"hole_womb_stuffed_1.png" = 'modular_rmh/icons/hole_art/hole_womb_stuffed_1.png',
		"hole_womb_stuffed_2.png" = 'modular_rmh/icons/hole_art/hole_womb_stuffed_2.png',
		"hole_womb_stuffed_3.png" = 'modular_rmh/icons/hole_art/hole_womb_stuffed_3.png',
		"hole_womb_stuffed_4.png" = 'modular_rmh/icons/hole_art/hole_womb_stuffed_4.png',
		"hole_womb_stuffed_5.png" = 'modular_rmh/icons/hole_art/hole_womb_stuffed_5.png'
	)
