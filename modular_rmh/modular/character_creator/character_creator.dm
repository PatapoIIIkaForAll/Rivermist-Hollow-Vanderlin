/// Character Creator: data and actions for the "CharacterCreator" TGUI interface, the BG3-style
/// character setup window. It reuses every existing character setup action and only adds what the
/// new layout needs: origins (cultures), preferred subclasses, native descriptors and markings,
/// interface language, rivals counter, the loadout tab with worn and carried items, and a
/// validated character export/import. The succubus disguise and ooze reshape editors open the
/// same interface in an appearance-only layout.

#define CC_LANG_EN "en"
#define CC_LANG_RU "ru"
#define CC_EXPORT_FORMAT "rmh_character"
#define CC_EXPORT_VERSION 1
#define CC_IMPORT_MAX_LENGTH 200000
#define CC_TEXT_CAP 512

/// Interface language, stored once per account.
/datum/preferences/var/character_creator_lang = CC_LANG_EN
/// Preferred subclass per job title: list("Adventurer" = "/datum/job/advclass/..."). Stored per character.
/datum/preferences/var/list/character_creator_subclasses
/// TRUE after any character edit until the slot is saved or reloaded; DONE asks before closing.
/datum/preferences/var/character_creator_unsaved = FALSE
/// Counts saves, so a handler that saves on its own does not leave the flag raised.
/datum/preferences/var/character_creator_save_count = 0

/datum/asset/simple/character_creator
	assets = list(
		"cc_origin_map.jpg" = 'modular_rmh/icons/character_creator/origin_map.jpg',
	)

/// "pref" links that only open menus or move the view. Every other handled action marks the character unsaved.
GLOBAL_LIST_INIT(character_creator_view_links, list(
	"character_setup_hover", "character_setup_report_geometry", "character_setup_preview_layer",
	"character_setup_preview_rotate", "character_setup_preview_background",
	"character_setup_preferences_fullscreen", "character_setup_preferences_scale",
	"character_setup_round_action", "playerquality", "ooc_preview", "triumphs", "triumph_buy_menu",
	"keybinds", "multi", "skin_color_ref_list", "finished", "save", "load", "changeslot", "tab",
	"defeat_guide", "voicepreview", "moanpreview", "hotkeys", "action_buttons", "tgui_fancy",
	"tgui_lock", "winflash", "see_chat_non_mob", "ambientocclusion", "auto_fit_viewport",
	"balloon_alerts", "runechat", "lobby_music", "hear_midis", "ambience", "background_music",
	"allow_midround_antag", "be_voice", "pixel_size", "scaling_method", "player_language",
))
/// Actions that read or open things without changing the character.
GLOBAL_LIST_INIT(character_creator_view_actions, list(
	"job_explain", "cc_subclass_explain", "cc_export", "cc_set_lang",
))

/datum/preferences/proc/character_creator_mark_unsaved(action, list/params)
	if(action in GLOB.character_creator_view_actions)
		return
	if(action == "pref")
		var/link = params?["preference"]
		if(link in GLOB.character_creator_view_links)
			return
		// Opening a sub-menu changes nothing by itself.
		if(params?["task"] == "menu")
			return
	character_creator_unsaved = TRUE

/// FALSE for the sandbox editors (succubus disguise, ooze reshape): they use the
/// appearance-only layout and skip the character data they cannot change.
/datum/preferences/proc/character_creator_active()
	return TRUE

/datum/preferences/succubus_disguise/character_creator_active()
	return FALSE

/datum/preferences/ooze_body/character_creator_active()
	return FALSE

// ---- Sandbox editors: succubus disguise and ooze reshape ----

/datum/preferences/succubus_disguise/ui_static_data(mob/user)
	. = ..()
	.["cc_species_groups"] = character_creator_species_groups()
	.["cc_species_desc"] = character_creator_species_descriptions()

/datum/preferences/succubus_disguise/ui_data(mob/user)
	. = ..()
	// The sandbox is a fresh datum; the interface language lives on the player's own preferences.
	var/datum/preferences/own_prefs = parent?.prefs
	.["cc_lang"] = own_prefs?.character_creator_lang || CC_LANG_EN
	.["cc_markings"] = body_marking_data()

// ---- Savefile hooks ----

/datum/preferences/character_setup_load_menu_prefs(savefile/S)
	. = ..()
	if(!S)
		return
	S.cd = "/"
	var/loaded_lang
	S["character_creator_lang"] >> loaded_lang
	character_creator_lang = (loaded_lang == CC_LANG_RU) ? CC_LANG_RU : CC_LANG_EN

/datum/preferences/character_setup_save_menu_prefs(savefile/S)
	. = ..()
	if(!S)
		return
	S.cd = "/"
	WRITE_FILE(S["character_creator_lang"], character_creator_lang)

/datum/preferences/load_character(slot)
	. = ..()
	character_creator_unsaved = FALSE
	character_creator_subclasses = list()
	character_creator_equip = list()
	character_creator_bag = list()
	if(!. || !path)
		return
	var/savefile/S = new /savefile(path)
	S.cd = "/character[default_slot]"
	var/raw
	S["character_creator_subclasses"] >> raw
	if(istext(raw))
		character_creator_subclasses = character_creator_sanitize_subclasses(safe_json_decode(raw))
	var/raw_loadout
	S["character_creator_loadout"] >> raw_loadout
	character_creator_read_loadout_state(istext(raw_loadout) ? safe_json_decode(raw_loadout) : null)

/datum/preferences/save_character()
	. = ..()
	if(.)
		character_creator_unsaved = FALSE
		character_creator_save_count++
	if(!. || !path)
		return
	var/savefile/S = new /savefile(path)
	S.cd = "/character[default_slot]"
	WRITE_FILE(S["character_creator_subclasses"], json_encode(character_creator_subclasses || list()))
	WRITE_FILE(S["character_creator_loadout"], json_encode(character_creator_loadout_state()))

// ---- Origins (cultures) ----

/// Position of the origin pin on the realm map, in percent of the map size. Null keeps it off the map.
/datum/culture/var/character_creator_map_x
/datum/culture/var/character_creator_map_y

// Pins match the Sword Coast art in modular_rmh/icons/character_creator/origin_map.jpg.
/datum/culture/universal/icewind
	character_creator_map_x = 34
	character_creator_map_y = 5

/datum/culture/universal/luskan
	character_creator_map_x = 38.8
	character_creator_map_y = 11.8

/datum/culture/universal/silvermarch
	character_creator_map_x = 55.8
	character_creator_map_y = 13.2

/datum/culture/universal/neverwinter
	character_creator_map_x = 39.5
	character_creator_map_y = 18.7

/datum/culture/universal/highforest
	character_creator_map_x = 58.8
	character_creator_map_y = 20.8

/datum/culture/universal/marches
	character_creator_map_x = 39.6
	character_creator_map_y = 27

/datum/culture/universal/waterdeep
	character_creator_map_x = 45
	character_creator_map_y = 36.5

/datum/culture/universal/moonshae
	character_creator_map_x = 30
	character_creator_map_y = 56

/datum/culture/universal/heartlands
	character_creator_map_x = 62
	character_creator_map_y = 60

/datum/culture/universal/baldursgate
	character_creator_map_x = 52
	character_creator_map_y = 64

/datum/culture/universal/cormyr
	character_creator_map_x = 81.8
	character_creator_map_y = 65.3

/datum/culture/universal/amn
	character_creator_map_x = 60
	character_creator_map_y = 85.4

// Duskmar is Rivermist's own duchy; the art has no name for it, so it sits between Amn and Calimshan.
/datum/culture/universal/duskmar
	character_creator_map_x = 66
	character_creator_map_y = 89.5

// Calimshan, Lantan and the Hordelands lie past the edges of the art; their pins sit on the matching edge.
/datum/culture/universal/calimshan
	character_creator_map_x = 72
	character_creator_map_y = 93

/datum/culture/universal/lantan
	character_creator_map_x = 40
	character_creator_map_y = 93

/datum/culture/universal/hordelads
	character_creator_map_x = 92
	character_creator_map_y = 38

/// Display names for abstract culture parents that group selectable sub-origins.
/datum/preferences/proc/character_creator_origin_group_name(group_type)
	var/static/list/group_names = list(
		/datum/culture/species/half_orc = "Orc Clans",
	)
	return group_names[group_type] || "Kindred"

/datum/preferences/proc/character_creator_origin_catalog()
	var/list/origins = list()
	var/list/groups = list()
	for(var/culture_type in GLOB.culture_singletons)
		var/datum/culture/culture = GLOB.culture_singletons[culture_type]
		if(!culture)
			continue
		var/datum/culture/parent = culture.parent_type
		var/group_id = null
		// Children of an abstract culture that is not one of the two roots form a sub-origin group.
		if(parent != /datum/culture/universal && parent != /datum/culture/species && parent != /datum/culture && IS_ABSTRACT(parent))
			group_id = "[parent]"
			if(!groups[group_id])
				groups[group_id] = list(
					"id" = group_id,
					"name" = character_creator_origin_group_name(parent),
				)
		var/on_map = isnum(culture.character_creator_map_x) && isnum(culture.character_creator_map_y)
		origins += list(list(
			"id" = "[culture_type]",
			"name" = culture.name,
			"description" = character_setup_chargen_clean_text(culture.description, 900),
			"group" = group_id,
			"map_x" = on_map ? culture.character_creator_map_x : null,
			"map_y" = on_map ? culture.character_creator_map_y : null,
			"accent" = culture.accent ? "[culture.accent]" : null,
		))
	var/list/group_list = list()
	for(var/group_id in groups)
		group_list += list(groups[group_id])
	return list("origins" = origins, "groups" = group_list)

/datum/preferences/proc/character_creator_available_cultures()
	. = list()
	for(var/culture_type in GLOB.culture_singletons)
		var/datum/culture/culture = GLOB.culture_singletons[culture_type]
		if(culture?.is_selectable(src))
			. += "[culture_type]"

/datum/preferences/proc/character_creator_set_culture(mob/user, culture_id)
	var/culture_type = text2path(culture_id)
	var/datum/culture/culture = culture_type ? GLOB.culture_singletons[culture_type] : null
	if(!culture || !culture.is_selectable(src))
		return FALSE
	if(read_preference(/datum/preference/choiced/culture) == culture_type)
		return TRUE
	write_preference(/datum/preference/choiced/selected_accent, ACCENT_NONE)
	write_preference(/datum/preference/choiced/culture, culture_type)
	to_chat(user, span_notice("[culture.name]"))
	return TRUE

// ---- Roles and subclasses ----

/// Subclasses a job can roll at spawn, grouped from its advclass categories.
/datum/preferences/proc/character_creator_job_subclasses(datum/job/job)
	. = list()
	if(!job || !length(job.advclass_cat_rolls) || !SSrole_class_handler)
		return
	for(var/category in job.advclass_cat_rolls)
		for(var/datum/job/advclass/subclass as anything in SSrole_class_handler.sorted_class_categories[category])
			if(!(subclass in .))
				. += subclass

/datum/preferences/proc/character_creator_subclass_catalog()
	. = list()
	if(!SSjob)
		return
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/list/entries = list()
		for(var/datum/job/advclass/subclass as anything in character_creator_job_subclasses(job))
			entries += list(list(
				"id" = "[subclass.type]",
				"title" = subclass.title,
				"tutorial" = character_setup_chargen_clean_text(subclass.tutorial, 700),
				"has_info" = !!subclass.class_setup_examine,
			))
		if(length(entries))
			.[job.title] = entries

/datum/preferences/proc/character_creator_sanitize_subclasses(list/raw)
	. = list()
	if(!islist(raw) || !SSjob)
		return
	for(var/job_title in raw)
		if(!istext(job_title))
			continue
		var/datum/job/job = SSjob.GetJob(job_title)
		var/subclass_type = text2path("[raw[job_title]]")
		if(!job || !subclass_type)
			continue
		for(var/datum/job/advclass/subclass as anything in character_creator_job_subclasses(job))
			if(subclass.type == subclass_type)
				.[job.title] = "[subclass_type]"
				break

/// Doll clothes: roles that only give gear through a subclass (adventurers and the like)
/// show the preferred subclass kit, or the first subclass when none is preferred yet.
/datum/preferences/character_setup_preview_job()
	. = ..()
	var/datum/job/job = .
	if(!job || !character_creator_active())
		return
	var/list/subclasses = character_creator_job_subclasses(job)
	if(!length(subclasses))
		return
	var/preferred_type = text2path("[LAZYACCESS(character_creator_subclasses, job.title)]")
	if(preferred_type)
		for(var/datum/job/advclass/subclass as anything in subclasses)
			if(subclass.type == preferred_type)
				return subclass
	if(!job.outfit)
		return subclasses[1]

/datum/preferences/proc/character_creator_set_subclass(job_title, subclass_id)
	var/datum/job/job = SSjob?.GetJob(job_title)
	if(!job)
		return FALSE
	LAZYINITLIST(character_creator_subclasses)
	if(!subclass_id || character_creator_subclasses[job.title] == subclass_id)
		character_creator_subclasses -= job.title
		return TRUE
	var/subclass_type = text2path(subclass_id)
	for(var/datum/job/advclass/subclass as anything in character_creator_job_subclasses(job))
		if(subclass.type == subclass_type)
			character_creator_subclasses[job.title] = "[subclass_type]"
			return TRUE
	return FALSE

/// Lists the preferred subclass first when this roll already offers it. It never adds a class.
/datum/class_select_handler/assemble_the_CLASSES()
	. = ..()
	character_creator_offer_preferred()

/datum/class_select_handler/proc/character_creator_offer_preferred()
	var/mob/living/carbon/human/human_mob = linked_client?.mob
	if(!istype(human_mob) || !linked_client.prefs || !human_mob.job)
		return
	var/subclass_type = text2path("[LAZYACCESS(linked_client.prefs.character_creator_subclasses, human_mob.job)]")
	if(!subclass_type)
		return
	var/datum/job/advclass/preferred = SSjob.GetJobType(subclass_type)
	if(preferred)
		rolled_classes = character_creator_order_classes(rolled_classes, preferred)

/// The roll decides which classes are offered; the preference only moves an offered one to the front.
/// Returns the same list when the preferred class was not rolled, so no class is ever added.
/proc/character_creator_order_classes(list/rolled, preferred)
	if(!islist(rolled) || !(preferred in rolled))
		return rolled
	var/list/reordered = list()
	reordered[preferred] = rolled[preferred]
	for(var/rolled_class in rolled)
		if(rolled_class != preferred)
			reordered[rolled_class] = rolled[rolled_class]
	return reordered

// ---- Abilities, quirks, descriptors, markings ----

/datum/preferences/proc/character_creator_stats()
	. = list()
	var/list/species_mods = list()
	var/sheet_type = pref_species?.statsheet_male
	if(read_preference(/datum/preference/choiced/gender) == FEMALE && pref_species?.statsheet_female)
		sheet_type = pref_species.statsheet_female
	for(var/list/modifier as anything in character_setup_stat_modifiers_for_sheet(sheet_type))
		species_mods[modifier["label"]] = modifier["value"]
	var/list/age_mods = list()
	for(var/list/modifier as anything in character_setup_stat_modifiers_for_sheet(character_setup_age_sheet_type(read_preference(/datum/preference/choiced/age))))
		age_mods[modifier["label"]] = modifier["value"]
	for(var/stat_type in MOBSTATS)
		var/datum/attribute/stat/stat = GET_ATTRIBUTE_DATUM(stat_type)
		var/label = stat ? stat.shorthand : "[stat_type]"
		var/species_value = species_mods[label] || 0
		var/age_value = age_mods[label] || 0
		. += list(list(
			"name" = stat ? stat.name : "[stat_type]",
			"desc" = stat ? character_setup_chargen_clean_text(stat.desc, 600) : "",
			"icon" = stat ? "[stat.icon]" : null,
			"icon_state" = stat?.icon_state,
			"label" = label,
			"base" = 10,
			"species" = species_value,
			"age" = age_value,
			"total" = 10 + species_value + age_value,
		))

/datum/preferences/proc/character_creator_quirks()
	var/list/names = list()
	var/list/entries = list()
	for(var/quirk_type in quirks)
		var/datum/quirk/quirk = GLOB.quirk_singletons[quirk_type]
		if(quirk)
			names += quirk.name
			entries += list(list("name" = quirk.name, "desc" = character_setup_chargen_clean_text(quirk.desc, 500)))
	return list(
		"entries" = entries,
		"names" = names,
		"balance" = calculate_quirk_balance(),
	)

/datum/preferences/proc/character_creator_descriptors()
	var/list/entries = list()
	if(!pref_species)
		return list("entries" = entries, "custom" = list())
	for(var/choice_type in pref_species.descriptor_choices)
		var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
		var/datum/descriptor_entry/entry = get_descriptor_entry_for_choice(choice_type)
		if(!choice || !entry)
			continue
		var/list/options = list()
		for(var/desc_type in choice.descriptors)
			var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
			if(descriptor)
				options += list(list("value" = "[desc_type]", "name" = descriptor.name))
		var/datum/mob_descriptor/current = MOB_DESCRIPTOR(entry.descriptor_type)
		entries += list(list(
			"choice" = "[choice_type]",
			"name" = choice.name,
			"value" = "[entry.descriptor_type]",
			"value_name" = current ? current.name : "None",
			"options" = options,
		))
	var/static/list/custom_types = CUSTOM_DESCRIPTOR_TYPE_LIST
	var/list/custom = list()
	for(var/index in 1 to min(CUSTOM_DESCRIPTOR_AMOUNT, length(custom_descriptors)))
		var/datum/custom_descriptor_entry/custom_entry = custom_descriptors[index]
		var/datum/mob_descriptor/custom_descriptor = MOB_DESCRIPTOR(custom_types[index])
		custom += list(list(
			"index" = index,
			"name" = custom_descriptor?.name,
			"prefix" = get_custom_descriptor_prefix_text(index),
			"text" = custom_entry.content_text,
			"visible" = is_custom_descriptor_selected(index),
		))
	return list("entries" = entries, "custom" = custom)

/datum/preferences/proc/character_creator_set_descriptor(choice_id, value_id)
	var/choice_type = text2path(choice_id)
	var/desc_type = text2path(value_id)
	if(!pref_species || !choice_type || !desc_type || !(choice_type in pref_species.descriptor_choices))
		return FALSE
	var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
	if(!choice || !(desc_type in choice.descriptors))
		return FALSE
	var/datum/descriptor_entry/entry = get_or_create_descriptor_entry_for_choice(choice_type)
	if(!entry)
		return FALSE
	entry.descriptor_type = desc_type
	return TRUE

/datum/preferences/proc/character_creator_marking_data()
	var/list/zones = list()
	for(var/zone in GLOB.marking_zones)
		var/list/entries = list()
		for(var/marking_name in body_markings[zone])
			entries += list(list(
				"name" = marking_name,
				"color" = "#[body_markings[zone][marking_name]]",
				"emissive" = !!(marking_name in emissive_markings[zone]),
			))
		var/list/available = marking_list_of_zone_for_species(zone, pref_species)
		for(var/used_name in body_markings[zone])
			available -= used_name
		zones += list(list(
			"id" = zone,
			"name" = capitalize(replacetext("[zone]", "_", " ")),
			"entries" = entries,
			"can_add" = !!(length(entries) < MAXIMUM_MARKINGS_PER_LIMB && length(available)),
		))
	return zones

/// Loadout catalog category, derived from the spawned item type.
/proc/character_creator_loadout_category(obj/item/item_type)
	if(ispath(item_type, /obj/item/clothing/head))
		return "head"
	if(ispath(item_type, /obj/item/clothing/face))
		return "face"
	if(ispath(item_type, /obj/item/clothing/neck) || ispath(item_type, /obj/item/clothing/ring) || ispath(item_type, /obj/item/clothing/wrists))
		return "accessories"
	if(ispath(item_type, /obj/item/clothing/cloak))
		return "cloaks"
	if(ispath(item_type, /obj/item/clothing/armor))
		return "armor"
	if(ispath(item_type, /obj/item/clothing))
		return "clothing"
	if(ispath(item_type, /obj/item/weapon))
		return "weapons"
	return "misc"

/datum/preferences/proc/character_creator_loadout_categories()
	. = list()
	for(var/datum/loadout_item/item as anything in GLOB.loadout_items)
		if(item.item_path)
			.["[item.type]"] = character_creator_loadout_category(item.item_path)

// ---- TGUI data ----

/datum/preferences/ui_static_data(mob/user)
	. = ..()
	if(!character_creator_active())
		return
	.["cc_origins"] = character_creator_origin_catalog()
	.["cc_subclasses"] = character_creator_subclass_catalog()
	.["cc_loadout_categories"] = character_creator_loadout_categories()
	.["cc_species_groups"] = character_creator_species_groups()
	.["cc_species_desc"] = character_creator_species_descriptions()
	.["cc_loadout_catalog"] = character_creator_loadout_catalog()
	.["cc_loadout_roles"] = character_creator_loadout_roles()
	.["cc_loadout_locked"] = character_creator_loadout_locked(user)

/datum/preferences/ui_data(mob/user)
	. = ..()
	if(!character_creator_active())
		return
	.["cc_lang"] = character_creator_lang
	.["cc_culture"] = "[read_preference(/datum/preference/choiced/culture)]"
	.["cc_cultures_available"] = character_creator_available_cultures()
	.["cc_subclass_prefs"] = character_creator_subclasses || list()
	.["cc_stats"] = character_creator_stats()
	.["cc_quirks"] = character_creator_quirks()
	.["cc_descriptors"] = character_creator_descriptors()
	.["cc_markings"] = character_creator_marking_data()
	.["cc_rivals"] = read_preference(/datum/preference/numeric/rival_count) || 0
	.["cc_tattoo_count"] = character_creator_tattoo_count()
	.["cc_tattoos"] = character_creator_tattoo_data()
	.["cc_prosthetics"] = character_creator_prosthetic_data()
	.["cc_texts"] = list(
		"flavortext" = read_preference(/datum/preference/text/flavortext) || "",
		"nsfwflavortext" = read_preference(/datum/preference/text/nsfwflavortext) || "",
		"ooc_notes" = read_preference(/datum/preference/text/ooc_notes) || "",
		"erpprefs_flavor" = read_preference(/datum/preference/text/erpprefs_flavor) || "",
	)
	.["cc_ooc_media"] = read_preference(/datum/preference/text/ooc_extra_link) || ""
	.["cc_unsaved"] = character_creator_unsaved
	.["cc_loadout"] = character_creator_loadout_data()

/datum/preferences/proc/character_creator_tattoo_count()
	. = 0
	for(var/zone in tattoos)
		var/list/entries = tattoos[zone]
		if(islist(entries))
			. += length(entries)

// ---- Actions ----

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/saves_before = character_creator_save_count
	. = ..()
	if(!character_creator_active())
		return
	if(!.)
		. = character_creator_act(action, params, ui)
	if(. && character_creator_save_count == saves_before)
		character_creator_mark_unsaved(action, params)

/datum/preferences/proc/character_creator_act(action, list/params, datum/tgui/ui)
	var/mob/user = ui?.user || usr
	if(!user || !character_setup_action_allowed(user, action, params))
		return FALSE
	switch(action)
		if("cc_tattoo")
			return character_creator_tattoo_act(user, params)
		if("cc_prosthetic")
			return character_creator_prosthetic_act(user, params)
		if("cc_implant")
			return character_creator_implant_act(user, params)
		if("cc_set_lang")
			character_creator_lang = (params["lang"] == CC_LANG_RU) ? CC_LANG_RU : CC_LANG_EN
			save_preferences()
			return TRUE
		if("cc_set_culture")
			if(character_creator_set_culture(user, params["id"]))
				update_menu_data(user)
			return TRUE
		if("cc_set_subclass")
			if(SSticker?.job_change_locked)
				return FALSE
			if(character_creator_set_subclass(params["job"], params["id"]))
				// The doll wears the preferred subclass kit, so redraw it.
				update_menu_data(user)
			return TRUE
		if("cc_subclass_explain")
			var/datum/job/advclass/subclass = SSjob?.GetJobType(text2path(params["id"]))
			if(istype(subclass) && subclass.class_setup_examine)
				subclass.show_explain(user)
			return FALSE
		if("cc_set_descriptor")
			if(character_creator_set_descriptor(params["choice"], params["value"]))
				update_menu_data(user)
			return TRUE
		if("cc_set_rivals")
			var/new_count = text2num("[params["value"]]")
			if(!isnum(new_count))
				return FALSE
			write_preference(/datum/preference/numeric/rival_count, clamp(round(new_count), 0, 5))
			return TRUE
		if("cc_set_text")
			if(character_creator_set_text(user, params["field"], params["value"]))
				update_menu_data(user)
			return TRUE
		if("cc_ooc_media")
			var/datum/preference/text/ooc_extra/media_entry = GLOB.preference_entries[/datum/preference/text/ooc_extra]
			media_entry?.handle_link(src, user)
			update_menu_data(user)
			return TRUE
		if("cc_marking_emissive")
			var/zone = params["zone"]
			var/marking_name = params["name"]
			if(!(zone in GLOB.marking_zones) || !body_markings[zone] || !(marking_name in body_markings[zone]))
				return FALSE
			if(!emissive_markings[zone])
				emissive_markings[zone] = list()
			if(marking_name in emissive_markings[zone])
				emissive_markings[zone] -= marking_name
			else
				emissive_markings[zone] += marking_name
			update_menu_data(user)
			return TRUE
		if("cc_smallclothes_color")
			var/list/smallclothes_category = character_setup_smallclothes_category(params["category"])
			if(!smallclothes_category)
				return FALSE
			var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
			var/color_key = smallclothes_category["color_pref"]
			if(params["clear"])
				smallclothes_preferences[color_key] = null
			else
				var/new_color = tgui_color_picker(user, "Choose a color.", "[smallclothes_category["name"]] Colour", sanitize_hexcolor(smallclothes_preferences[color_key], 6, TRUE, "#ffffff"))
				if(!new_color)
					return FALSE
				smallclothes_preferences[color_key] = sanitize_hexcolor(new_color, include_crunch = 1)
			write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)
			update_menu_data(user)
			return TRUE
		if("cc_export")
			character_creator_export(user)
			return FALSE
		if("cc_import")
			character_creator_import(user)
			return TRUE
		if("cc_loadout")
			character_creator_loadout_link(user, params)
			update_menu_data(user)
			return TRUE
		if("cc_loadout_equip")
			var/slot_number = text2num("[params["slot"]]")
			if(!isnum(slot_number) || slot_number < 1 || slot_number > 10)
				return FALSE
			var/slot_key = "[slot_number]"
			var/datum/loadout_item/item = vars["loadout[slot_number]"]
			var/slot_id = params["equip"]
			if(!item)
				return FALSE
			LAZYINITLIST(character_creator_equip)
			if(!slot_id)
				character_creator_equip -= slot_key
			else
				if(!character_creator_item_fits(item.item_path, slot_id))
					return FALSE
				// One item per slot: whatever sat there goes back to the list.
				for(var/other_key in character_creator_equip.Copy())
					if(character_creator_equip[other_key] == slot_id)
						character_creator_equip -= other_key
				character_creator_equip[slot_key] = slot_id
				LAZYREMOVE(character_creator_bag, slot_key)
			update_menu_data(user)
			return TRUE
		if("cc_loadout_bag")
			var/slot_number = text2num("[params["slot"]]")
			if(!isnum(slot_number) || slot_number < 1 || slot_number > 10)
				return FALSE
			var/slot_key = "[slot_number]"
			if(!vars["loadout[slot_number]"] || LAZYACCESS(character_creator_equip, slot_key))
				return FALSE
			LAZYINITLIST(character_creator_bag)
			if(slot_key in character_creator_bag)
				character_creator_bag -= slot_key
			else
				character_creator_bag += slot_key
			update_menu_data(user)
			return TRUE
		if("cc_loadout_preset_rename")
			var/preset_slot = text2num("[params["preset"]]")
			if(!isnum(preset_slot) || preset_slot < 1 || preset_slot > 3)
				return FALSE
			var/list/meta = character_creator_preset_meta(preset_slot)
			var/new_name = tgui_input_text(user, "Name this preset.", "Preset name", meta["name"], max_length = 32)
			if(isnull(new_name))
				return FALSE
			character_creator_set_preset_meta(preset_slot, "cc_name", STRIP_HTML_SIMPLE(new_name, 32) || null)
			update_menu_data(user)
			return TRUE
		if("cc_loadout_preset_role")
			var/preset_slot = text2num("[params["preset"]]")
			var/role = params["role"]
			if(role && !SSjob?.GetJob(role))
				return FALSE
			if(!character_creator_set_preset_meta(preset_slot, "cc_role", role || null))
				to_chat(user, span_warning("Save the preset first, then bind it to a role."))
				return FALSE
			update_menu_data(user)
			return TRUE
		if("cc_loadout_dye")
			var/slot_number = text2num("[params["slot"]]")
			if(!isnum(slot_number) || slot_number < 1 || slot_number > 10 || !vars["loadout[slot_number]"])
				return FALSE
			if(params["clear"])
				vars["loadout_[slot_number]_hex"] = null
			else
				var/new_color = tgui_color_picker(user, "Choose a dye for this item.", "Item Color", sanitize_hexcolor(vars["loadout_[slot_number]_hex"], 6, TRUE, "#ffffff"))
				if(!new_color)
					return FALSE
				vars["loadout_[slot_number]_hex"] = sanitize_hexcolor(new_color, include_crunch = 1)
			update_menu_data(user)
			return TRUE
		if("cc_loadout_clear_all")
			for(var/slot in 1 to 10)
				vars["loadout[slot]"] = null
				vars["loadout_[slot]_name"] = null
				vars["loadout_[slot]_desc"] = null
				vars["loadout_[slot]_hex"] = null
			character_creator_equip = list()
			character_creator_bag = list()
			update_menu_data(user)
			return TRUE

// ---- Export / import ----

/// Character preference entries the importer never takes from text. Display fields are rebuilt,
/// family links point at other players, raw HTML fields and links are validated on their own.
/datum/preferences/proc/character_creator_import_skip_keys()
	var/static/list/skip = list(
		"flavortext_display", "ooc_notes_display", "ooc_extra", "ooc_extra_link",
		"setparent", "setspouse", "setchild", "was_divorced",
		"headshot_link", "nsfw_headshot_link", "song_link",
	)
	return skip

/// List-type character entries that validate themselves on deserialize or right after import.
/datum/preferences/proc/character_creator_import_list_keys()
	var/static/list/allowed = list(
		"smallclothes_preferences", "culinary_preferences", "img_gallery", "nsfw_img_gallery",
	)
	return allowed

/datum/preferences/proc/character_creator_export_payload()
	var/list/pref_values = list()
	for(var/datum/preference/entry as anything in GLOB.preferences_in_priority_order)
		if(entry.savefile_identifier != PREF_CHARACTER)
			continue
		var/value = entry.serialize(read_preference(entry.type))
		pref_values[entry.savefile_key] = ispath(value) ? "[value]" : value

	var/list/customizers = list()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/list/entry_vars = list(
			"customizer_type" = "[entry.customizer_type]",
			"customizer_choice_type" = "[entry.customizer_choice_type]",
		)
		for(var/var_name in character_creator_customizer_fields(entry))
			var/value = entry.vars[var_name]
			if(isnum(value) || istext(value))
				entry_vars[var_name] = value
			else if(ispath(value))
				entry_vars[var_name] = "[value]"
		customizers += list(entry_vars)

	var/list/descriptors = list()
	for(var/datum/descriptor_entry/entry as anything in descriptor_entries)
		descriptors += list(list("choice" = "[entry.descriptor_choice_type]", "value" = "[entry.descriptor_type]"))
	var/list/custom_descriptor_list = list()
	for(var/datum/custom_descriptor_entry/custom_entry as anything in custom_descriptors)
		custom_descriptor_list += list(list("prefix" = custom_entry.prefix_type, "text" = custom_entry.content_text))

	var/list/quirk_list = list()
	for(var/quirk_type in quirks)
		var/custom_value = quirk_customizations[quirk_type]
		quirk_list += list(list(
			"type" = "[quirk_type]",
			"value" = ispath(custom_value) ? "[custom_value]" : custom_value,
			"extra" = quirk_extra_customizations[quirk_type],
		))

	var/list/loadout = list()
	for(var/slot in 1 to 10)
		var/datum/loadout_item/item = vars["loadout[slot]"]
		loadout += list(list(
			"type" = item ? "[item.type]" : null,
			"name" = vars["loadout_[slot]_name"],
			"desc" = vars["loadout_[slot]_desc"],
			"hex" = vars["loadout_[slot]_hex"],
		))

	return list(
		"format" = CC_EXPORT_FORMAT,
		"version" = CC_EXPORT_VERSION,
		"prefs" = pref_values,
		"links" = list(
			"headshot_link" = read_preference(/datum/preference/text/headshot_link),
			"nsfw_headshot_link" = read_preference(/datum/preference/text/nsfw_headshot_link),
			"song_link" = read_preference(/datum/preference/text/song_link),
		),
		"mutant_colors" = list(features["mcolor"], features["mcolor2"], features["mcolor3"]),
		"customizers" = customizers,
		"markings" = body_markings,
		"emissive_markings" = emissive_markings,
		"tattoos" = tattoos,
		"prosthetics" = prosthetics,
		"implants" = implants,
		"descriptors" = descriptors,
		"custom_descriptors" = custom_descriptor_list,
		"quirks" = quirk_list,
		"loadout" = loadout,
		"jobs" = job_preferences,
		"alt_jobs" = alt_job_selections,
		"subclasses" = character_creator_subclasses,
		"loadout_state" = character_creator_loadout_state(),
	)

/datum/preferences/proc/character_creator_export(mob/user)
	var/text = json_encode(character_creator_export_payload())
	tgui_input_text(user, "Copy this text and keep it somewhere safe. Import pastes it back into a character slot.", "Export Character", text, max_length = CC_IMPORT_MAX_LENGTH, multiline = TRUE, encode = FALSE)

/datum/preferences/proc/character_creator_import(mob/user)
	// A readied character must not change roles under the round start.
	if(isnewplayer(user))
		var/mob/dead/new_player/lobby_player = user
		if(lobby_player.ready == PLAYER_READY_TO_PLAY)
			to_chat(user, span_warning("Unready before importing a character."))
			return
	var/text = tgui_input_text(user, "Paste an exported character. It replaces the character in this slot and is saved right away.", "Import Character", null, max_length = CC_IMPORT_MAX_LENGTH, multiline = TRUE, encode = FALSE)
	if(!text)
		return
	var/list/payload
	try
		payload = json_decode(text)
	catch
		payload = null
	if(!islist(payload) || payload["format"] != CC_EXPORT_FORMAT || !isnum(payload["version"]))
		to_chat(user, span_warning("That text is not an exported character."))
		return
	if(tgui_alert(user, "Replace [read_preference(/datum/preference/text/real_name)] in this slot with the imported character?", "Import Character", list("Replace", "Cancel")) != "Replace")
		return
	// A failed import must not leave a half-built character that the next Save would write.
	var/import_failed = FALSE
	try
		character_creator_apply_import(user, payload)
	catch(var/exception/import_error)
		import_failed = TRUE
		log_runtime("Character import by [key_name(user)] failed: [import_error] ([import_error.file]:[import_error.line])")
	if(import_failed)
		load_character(default_slot)
		character_setup_ui_heavy_cache = null
		update_static_data(user)
		update_menu_data(user)
		to_chat(user, span_warning("That character could not be imported. This slot was left as it was."))
		return
	save_character()
	character_setup_ui_heavy_cache = null
	update_static_data(user)
	update_menu_data(user)
	to_chat(user, span_notice("Character imported and saved."))
	log_game("[key_name(user)] imported a character into slot [default_slot].")

/// Converts JSON-safe typepath strings back into paths, leaves other values alone.
/proc/character_creator_unstring_path(value)
	if(istext(value) && length(value) > 1 && copytext(value, 1, 2) == "/")
		var/path = text2path(value)
		if(path)
			return path
	return value

/datum/preferences/proc/character_creator_apply_import(mob/user, list/payload)
	var/datum/species/previous_species = pref_species
	var/previous_patron = read_preference(/datum/preference/choiced/patron)
	var/previous_culture = read_preference(/datum/preference/choiced/culture)

	// Preference datums: each value goes through deserialize and is_valid, exactly like a savefile load.
	var/list/pref_values = payload["prefs"]
	if(islist(pref_values))
		var/list/skip_keys = character_creator_import_skip_keys()
		var/list/list_keys = character_creator_import_list_keys()
		for(var/datum/preference/entry as anything in GLOB.preferences_in_priority_order)
			if(entry.savefile_identifier != PREF_CHARACTER || (entry.savefile_key in skip_keys))
				continue
			if(!(entry.savefile_key in pref_values))
				continue
			if(istype(entry, /datum/preference/list_type) && !(entry.savefile_key in list_keys))
				continue
			if(istype(entry, /datum/preference/text))
				var/datum/preference/text/text_entry = entry
				if(!text_entry.should_strip_html)
					continue
			var/raw = character_creator_unstring_path(pref_values[entry.savefile_key])
			if(isnull(raw))
				continue
			var/value = entry.deserialize(raw, src)
			if(isnull(value) || !entry.is_valid(value, src))
				continue
			write_preference(entry.type, value)
			if(entry.type == /datum/preference/choiced/species)
				set_species_preference(value)

	// Species and patron must stay inside what this player may pick.
	if(!pref_species?.preference_accessible(src))
		set_species_preference(previous_species.type)
		write_preference(/datum/preference/choiced/species, previous_species.type)
	var/datum/patron/imported_patron = read_preference(/datum/preference/choiced/patron)
	if(istype(imported_patron) && !imported_patron.preference_accessible(src))
		write_preference(/datum/preference/choiced/patron, previous_patron)
	var/culture_type = read_preference(/datum/preference/choiced/culture)
	var/datum/culture/imported_culture = culture_type ? GLOB.culture_singletons[culture_type] : null
	if(culture_type && (!imported_culture || !imported_culture.is_selectable(src)))
		write_preference(/datum/preference/choiced/culture, previous_culture)

	var/cached_name = reject_bad_name(read_preference(/datum/preference/text/real_name))
	write_preference(/datum/preference/text/real_name, cached_name || random_unique_name(read_preference(/datum/preference/choiced/gender)))

	// Rendered text is rebuilt from the plain fields, never imported.
	var/flavor = read_preference(/datum/preference/text/flavortext)
	write_preference(/datum/preference/text/flavortext_display, flavor ? replacetext(parsemarkdown_basic(html_encode(flavor)), "\n", "<BR>") : null)
	var/ooc_notes = read_preference(/datum/preference/text/ooc_notes)
	write_preference(/datum/preference/text/ooc_notes_display, ooc_notes ? replacetext(parsemarkdown_basic(html_encode(ooc_notes)), "\n", "<BR>") : null)

	// Links only pass through the same host checks as the regular inputs.
	var/list/links = payload["links"]
	if(islist(links))
		var/headshot = links["headshot_link"]
		write_preference(/datum/preference/text/headshot_link, (istext(headshot) && is_valid_headshot_link(null, headshot, TRUE)) ? headshot : null)
		var/nsfw_headshot = links["nsfw_headshot_link"]
		write_preference(/datum/preference/text/nsfw_headshot_link, (istext(nsfw_headshot) && is_valid_nsfw_headshot_link(null, nsfw_headshot, TRUE)) ? nsfw_headshot : null)
		var/song = links["song_link"]
		write_preference(/datum/preference/text/song_link, (istext(song) && is_valid_media_link(null, song, TRUE, list("mp3"))) ? song : null)

	var/list/mutant_colors = payload["mutant_colors"]
	if(islist(mutant_colors) && length(mutant_colors) >= 3)
		features["mcolor"] = sanitize_hexcolor(mutant_colors[1], 6, 0)
		features["mcolor2"] = sanitize_hexcolor(mutant_colors[2], 6, 0)
		features["mcolor3"] = sanitize_hexcolor(mutant_colors[3], 6, 0)
		sanitize_species_mutant_colors()

	character_creator_import_customizers(payload["customizers"])
	character_creator_import_markings(payload["markings"])
	emissive_markings = list()
	var/list/imported_emissive = payload["emissive_markings"]
	if(islist(imported_emissive))
		for(var/zone in imported_emissive)
			var/list/zone_names = imported_emissive[zone]
			if(!(zone in GLOB.marking_zones) || !islist(zone_names) || !body_markings[zone])
				continue
			for(var/marking_name in zone_names)
				if(marking_name in body_markings[zone])
					if(!emissive_markings[zone])
						emissive_markings[zone] = list()
					emissive_markings[zone] |= marking_name
	character_creator_import_descriptors(payload["descriptors"], payload["custom_descriptors"])

	var/list/imported_tattoos = payload["tattoos"]
	if(islist(imported_tattoos))
		for(var/zone in imported_tattoos)
			var/list/zone_entries = imported_tattoos[zone]
			if(!islist(zone_entries))
				continue
			for(var/list/tattoo_entry in zone_entries)
				if(istext(tattoo_entry["text"]))
					tattoo_entry["text"] = html_encode(html_decode(tattoo_entry["text"]))
		tattoos = imported_tattoos
		validate_tattoos()

	prosthetics = islist(payload["prosthetics"]) ? payload["prosthetics"] : list()
	implants = islist(payload["implants"]) ? payload["implants"] : list()
	validate_prosthetics()
	character_creator_import_quirks(payload["quirks"])
	// Genital set rules depend on quirks, so they are enforced once both halves are in place.
	validate_customizer_entries()
	character_creator_import_loadout(user, payload["loadout"])
	character_creator_read_loadout_state(payload["loadout_state"])

	character_creator_import_jobs(user, payload["jobs"])
	var/list/imported_alt_jobs = payload["alt_jobs"]
	alt_job_selections = islist(imported_alt_jobs) ? imported_alt_jobs : list()
	sanitize_alt_job_selections()
	character_creator_subclasses = character_creator_sanitize_subclasses(payload["subclasses"])

	validate_culinary_preferences()
	validate_smallclothes_preferences()
	ensure_erp_preferences()

/// Job priorities from an export. Same rules as the role menu: the job must be open to this
/// player and only one job may stay at High (a later High demotes the earlier one to Medium).
/datum/preferences/proc/character_creator_import_jobs(mob/user, list/imported)
	job_preferences = list()
	if(!islist(imported) || !SSjob)
		return
	for(var/job_title in imported)
		if(!istext(job_title))
			continue
		var/level = imported[job_title]
		if(!(level in list(JP_LOW, JP_MEDIUM, JP_HIGH)))
			continue
		var/datum/job/job = SSjob.GetJob(job_title)
		if(!job || (user && !job_is_available(job, user)))
			continue
		set_job_preference_level(job, level)

/// Customizer entry fields the editor can change: the shared appearance fields plus the fields a
/// subtype declares itself (sizes, eye and hair colours, gradients). Datum internals never qualify.
/proc/character_creator_customizer_fields(datum/customizer_entry/entry)
	var/static/list/inherited_fields
	var/static/list/fields_by_type = list()
	if(!inherited_fields)
		var/datum/customizer_entry/probe = new
		inherited_fields = list()
		for(var/var_name in probe.vars)
			inherited_fields += var_name
		qdel(probe)
	if(fields_by_type[entry.type])
		return fields_by_type[entry.type]
	var/list/fields = list("accessory_type", "accessory_colors", "disabled")
	for(var/var_name in entry.vars)
		if(!(var_name in inherited_fields))
			fields += var_name
	fields_by_type[entry.type] = fields
	return fields

/// The top two levels of a typepath, e.g. /datum/hair_gradient for /datum/hair_gradient/none.
/proc/character_creator_path_family(path)
	var/list/parts = splittext("[path]", "/")
	if(length(parts) < 3)
		return null
	return text2path("/[parts[2]]/[parts[3]]")

/// Validates one imported customizer field against the kind of value the fresh entry holds.
/// Returns the value to store, or null to keep the fresh entry's own value.
/proc/character_creator_customizer_value(datum/customizer_entry/entry, var_name, raw)
	var/current = entry.vars[var_name]
	var/value = character_creator_unstring_path(raw)
	if(var_name == "disabled" || isnum(current))
		return isnum(value) ? value : null
	if(var_name == "accessory_type" || ispath(current))
		var/family = current ? character_creator_path_family(current) : /datum/sprite_accessory
		return (family && ispath(value, family)) ? value : null
	if(!istext(value))
		return null
	if(var_name == "accessory_colors" || findtext(var_name, "color"))
		// Colour strings only ever hold hex digits, '#' and separators.
		var/static/regex/not_color = regex(@"[^#0-9a-fA-F;,]", "g")
		return copytext(not_color.Replace(value, ""), 1, 128)
	return copytext(STRIP_HTML_SIMPLE(value, CC_TEXT_CAP), 1, CC_TEXT_CAP)

/datum/preferences/proc/character_creator_import_customizers(list/imported)
	if(!islist(imported) || !pref_species)
		return
	var/list/new_entries = list()
	for(var/list/entry_vars in imported)
		if(!islist(entry_vars))
			continue
		var/customizer_type = text2path("[entry_vars["customizer_type"]]")
		var/choice_type = text2path("[entry_vars["customizer_choice_type"]]")
		if(!customizer_type || !choice_type || !(customizer_type in pref_species.customizers))
			continue
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer || !(choice_type in customizer.customizer_choices))
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
		var/datum/customizer_entry/entry = customizer.create_customizer_entry(src, choice_type)
		if(!choice || !entry)
			continue
		// Only whitelisted editor fields are copied, each checked against its kind of value;
		// validate_entry() then clamps sizes and accessories like a savefile load does.
		for(var/var_name in character_creator_customizer_fields(entry))
			if(!(var_name in entry_vars))
				continue
			var/value = character_creator_customizer_value(entry, var_name, entry_vars[var_name])
			if(!isnull(value))
				entry.vars[var_name] = value
		new_entries += entry
	customizer_entries = new_entries
	validate_customizer_entries(enforce_genital_rules = FALSE)

/datum/preferences/proc/character_creator_import_markings(list/imported)
	body_markings = list()
	if(!islist(imported))
		return
	for(var/zone in imported)
		if(!(zone in GLOB.marking_zones))
			continue
		var/list/zone_markings = imported[zone]
		if(!islist(zone_markings))
			continue
		var/list/allowed = marking_list_of_zone_for_species(zone, pref_species)
		for(var/marking_name in zone_markings)
			if(!(marking_name in allowed) || length(body_markings[zone]) >= MAXIMUM_MARKINGS_PER_LIMB)
				continue
			if(!body_markings[zone])
				body_markings[zone] = list()
			body_markings[zone][marking_name] = sanitize_hexcolor(zone_markings[marking_name], 6)
	validate_body_markings()

/datum/preferences/proc/character_creator_import_descriptors(list/imported, list/imported_custom)
	if(islist(imported))
		for(var/list/descriptor in imported)
			if(islist(descriptor))
				character_creator_set_descriptor(descriptor["choice"], descriptor["value"])
	if(islist(imported_custom))
		for(var/index in 1 to min(CUSTOM_DESCRIPTOR_AMOUNT, length(imported_custom), length(custom_descriptors)))
			var/list/custom = imported_custom[index]
			if(!islist(custom))
				continue
			var/datum/custom_descriptor_entry/custom_entry = custom_descriptors[index]
			custom_entry.prefix_type = sanitize_integer(custom["prefix"], 1, CUSTOM_PREFIX_AMOUNT, CUSTOM_PREFIX_HAS_A)
			if(istext(custom["text"]))
				custom_entry.content_text = STRIP_HTML_SIMPLE(LOWER_TEXT(custom["text"]), CUSTOM_DESCRIPTOR_TEXT_LENGTH)
	validate_descriptors()

/datum/preferences/proc/character_creator_import_quirks(list/imported)
	quirks = list()
	quirk_customizations = list()
	quirk_extra_customizations = list()
	if(!islist(imported))
		return
	for(var/list/quirk_data in imported)
		if(!islist(quirk_data))
			continue
		var/quirk_type = text2path(migrate_legacy_quirk_text("[quirk_data["type"]]"))
		if(!ispath(quirk_type, /datum/quirk) || (quirk_type in quirks))
			continue
		quirks += quirk_type
		var/custom_value = character_creator_quirk_value(quirk_type, quirk_data["value"])
		if(!isnull(custom_value))
			quirk_customizations[quirk_type] = custom_value
	validate_quirks()
	// Extra fields go through the regular per-field sanitizer once the quirk list is final.
	for(var/list/quirk_data in imported)
		var/quirk_type = text2path(migrate_legacy_quirk_text("[quirk_data["type"]]"))
		var/list/extra = quirk_data["extra"]
		if(!(quirk_type in quirks) || !islist(extra))
			continue
		for(var/key in extra)
			set_quirk_extra_customization(quirk_type, key, extra[key])

/// A quirk customization from an export: one of the options the quirk offers this character,
/// or plain text for text quirks. Anything else is dropped, never trusted as a path to spawn.
/datum/preferences/proc/character_creator_quirk_value(quirk_type, raw)
	var/datum/quirk/singleton = GLOB.quirk_singletons[quirk_type]
	if(!singleton || isnull(raw))
		return null
	switch(singleton.customization_type)
		if(QUIRK_TEXT)
			return istext(raw) ? STRIP_HTML_SIMPLE(raw, CC_TEXT_CAP) : null
		if(QUIRK_NUMBER)
			return isnum(raw) ? raw : null
	var/value = character_creator_unstring_path(raw)
	var/list/options = singleton.return_customization(src)
	return (value in options) ? value : null

/datum/preferences/proc/character_creator_import_loadout(mob/user, list/imported)
	for(var/slot in 1 to 10)
		vars["loadout[slot]"] = null
		vars["loadout_[slot]_name"] = null
		vars["loadout_[slot]_desc"] = null
		vars["loadout_[slot]_hex"] = null
	if(!islist(imported))
		return
	var/points_left = get_base_points()
	var/skipped = 0
	var/list/taken_types = list()
	for(var/slot in 1 to min(10, length(imported)))
		var/list/slot_data = imported[slot]
		if(!islist(slot_data))
			continue
		var/item_type = text2path("[slot_data["type"]]")
		if(!ispath(item_type, /datum/loadout_item))
			continue
		// Same rules as picking the item by hand (nobility, one of each, points), without a chat line per item.
		var/datum/loadout_item/item = new item_type
		if((user && !item.nobility_check(user)) || (item_type in taken_types) || item.point_cost > points_left)
			qdel(item)
			skipped++
			continue
		points_left -= item.point_cost
		taken_types += item_type
		vars["loadout[slot]"] = item
		if(istext(slot_data["name"]))
			vars["loadout_[slot]_name"] = STRIP_HTML_SIMPLE(slot_data["name"], MAX_NAME_LEN)
		if(istext(slot_data["desc"]))
			vars["loadout_[slot]_desc"] = STRIP_HTML_SIMPLE(slot_data["desc"], MAX_MESSAGE_LEN)
		if(istext(slot_data["hex"]))
			vars["loadout_[slot]_hex"] = sanitize_hexcolor(slot_data["hex"], 6, TRUE)
	if(skipped && user)
		to_chat(user, span_warning("[skipped] loadout item\s could not be taken: not available for this character or over the point limit."))

// ---- Character texts edited in place ----

/datum/preferences/proc/character_creator_set_text(mob/user, field, value)
	var/static/list/fields = list(
		"flavortext" = /datum/preference/text/flavortext,
		"nsfwflavortext" = /datum/preference/text/nsfwflavortext,
		"ooc_notes" = /datum/preference/text/ooc_notes,
		"erpprefs_flavor" = /datum/preference/text/erpprefs_flavor,
	)
	var/pref_type = fields[field]
	if(!pref_type || !(istext(value) || isnull(value)))
		return FALSE
	value = copytext("[value]", 1, MAX_FLAVOR_TEXT_LENGTH + 1)
	if(!length(trim(value)))
		value = null
	write_preference(pref_type, value)
	// Rendered copies are rebuilt the same way the old input popups did it.
	switch(field)
		if("flavortext")
			var/flavor = read_preference(/datum/preference/text/flavortext)
			write_preference(/datum/preference/text/flavortext_display, flavor ? replacetext(parsemarkdown_basic(html_encode(flavor)), "\n", "<BR>") : null)
			log_game("[key_name(user)] has set their flavortext.")
		if("ooc_notes")
			var/notes = read_preference(/datum/preference/text/ooc_notes)
			write_preference(/datum/preference/text/ooc_notes_display, notes ? replacetext(parsemarkdown_basic(html_encode(notes)), "\n", "<BR>") : null)
			log_game("[key_name(user)] has set their OOC notes.")
	return TRUE

// ---- Races and subraces ----

/// Species that are one race with several subraces. Members missing from the roundstart list are skipped.
/datum/preferences/proc/character_creator_species_groups()
	var/static/list/group_defs = list(
		list("id" = "elf", "name" = "Elf", "species" = list(SPEC_ID_ELF, SPEC_ID_ELF_W)),
		list("id" = "halfelf", "name" = "Half-Elf", "species" = list(SPEC_ID_HALF_ELF, SPEC_ID_HALF_DROW)),
		list("id" = "dwarf", "name" = "Dwarf", "species" = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR)),
		list("id" = "gnome", "name" = "Gnome", "species" = list(SPEC_ID_GNOME, SPEC_ID_GNOME_D)),
		list("id" = "kobold", "name" = "Kobold", "species" = list(SPEC_ID_KOBOLD, SPEC_ID_KOBOLD_CLASSIC, SPEC_ID_KOBOLD_FORMIKRAG)),
		list("id" = "beastkin", "name" = "Beast-Kin", "species" = list(SPEC_ID_BEASTKIN, SPEC_ID_BEASTKINSMALL, SPEC_ID_HALF_BEASTKINSMALL)),
	)
	. = list()
	for(var/list/group_def in group_defs)
		var/list/members = list()
		for(var/species_id in group_def["species"])
			if(species_id in GLOB.roundstart_species)
				members += species_id
		if(length(members) >= 2)
			. += list(list("id" = group_def["id"], "name" = group_def["name"], "species" = members))

/// Full species descriptions. The legacy catalog cuts them at 900 characters, which drops the bonus lines.
/datum/preferences/proc/character_creator_species_descriptions()
	var/static/regex/stray_n = regex(@"(^|\s)n(?=\n)", "g")
	var/static/regex/many_breaks = regex(@"\n{3,}", "g")
	. = list()
	for(var/species_id in GLOB.roundstart_species)
		var/species_type = GLOB.species_list[species_id]
		if(!species_type)
			continue
		var/datum/species/species = new species_type()
		var/clean = GLOB.html_tags.Replace("[species.desc]", "")
		clean = stray_n.Replace(clean, "$1")
		clean = many_breaks.Replace(clean, "\n\n")
		.[species_id] = trim(copytext(clean, 1, 4000))
		qdel(species)

// ---- Loadout: equipment slots, bags and role presets ----

/// Loadout slot number (as text) -> equipment slot id the item is worn in at spawn.
/datum/preferences/var/list/character_creator_equip
/// Loadout slot numbers (as text) carried in bags at spawn instead of the stash.
/datum/preferences/var/list/character_creator_bag

GLOBAL_LIST_INIT(character_creator_equip_slots, list(
	"mask" = ITEM_SLOT_MASK,
	"head" = ITEM_SLOT_HEAD,
	"mouth" = ITEM_SLOT_MOUTH,
	"backr" = ITEM_SLOT_BACK_R,
	"cloak" = ITEM_SLOT_CLOAK,
	"backl" = ITEM_SLOT_BACK_L,
	"neck" = ITEM_SLOT_NECK,
	"armor" = ITEM_SLOT_ARMOR,
	"wrists" = ITEM_SLOT_WRISTS,
	"ring" = ITEM_SLOT_RING,
	"shirt" = ITEM_SLOT_SHIRT,
	"gloves" = ITEM_SLOT_GLOVES,
	"beltr" = ITEM_SLOT_BELT_R,
	"belt" = ITEM_SLOT_BELT,
	"beltl" = ITEM_SLOT_BELT_L,
	"rhand" = 0,
	"pants" = ITEM_SLOT_PANTS,
	"lhand" = 0,
	"shoes" = ITEM_SLOT_SHOES,
	"under_top" = ITEM_SLOT_UNDER_TOP,
	"under_bottom" = ITEM_SLOT_UNDER_BOTTOM,
	"undershirt" = ITEM_SLOT_UNDERSHIRT,
	"socks" = ITEM_SLOT_SOCKS,
	"garter" = ITEM_SLOT_GARTER,
	"armsleeves" = ITEM_SLOT_ARMSLEEVES,
	"earring_l" = ITEM_SLOT_EARRING_L,
	"earring_r" = ITEM_SLOT_EARRING_R,
	"choker" = ITEM_SLOT_CHOKER,
))

/// Whether an item type can be worn in an equipment slot id. Hands take anything.
/proc/character_creator_item_fits(obj/item/item_path, slot_id)
	if(!ispath(item_path, /obj/item) || !(slot_id in GLOB.character_creator_equip_slots))
		return FALSE
	var/flag = GLOB.character_creator_equip_slots[slot_id]
	if(!flag)
		return TRUE
	var/item_flags = initial(item_path.slot_flags)
	if(flag & ITEM_SLOT_EXTRA)
		return (item_flags & flag) == flag
	// Extra-slot items reuse low bits, so they never count for the regular slots.
	if(item_flags & ITEM_SLOT_EXTRA)
		return FALSE
	return !!(item_flags & flag)

/datum/preferences/proc/character_creator_loadout_state()
	return list(
		"equip" = character_creator_equip || list(),
		"bag" = character_creator_bag || list(),
	)

/// Reads untrusted equip/bag state and keeps only entries that match the current loadout.
/datum/preferences/proc/character_creator_read_loadout_state(list/raw)
	character_creator_equip = list()
	character_creator_bag = list()
	if(!islist(raw))
		return
	var/list/raw_equip = raw["equip"]
	if(islist(raw_equip))
		var/list/used_slots = list()
		for(var/slot_key in raw_equip)
			var/slot_number = text2num("[slot_key]")
			if(!isnum(slot_number) || slot_number < 1 || slot_number > 10)
				continue
			var/datum/loadout_item/item = vars["loadout[slot_number]"]
			var/slot_id = raw_equip[slot_key]
			if(!item || !istext(slot_id) || (slot_id in used_slots) || !character_creator_item_fits(item.item_path, slot_id))
				continue
			used_slots += slot_id
			character_creator_equip["[slot_key]"] = slot_id
	var/list/raw_bag = raw["bag"]
	if(islist(raw_bag))
		for(var/slot_key in raw_bag)
			var/slot_number = text2num("[slot_key]")
			if(!isnum(slot_number) || slot_number < 1 || slot_number > 10)
				continue
			if(vars["loadout[slot_number]"] && !character_creator_equip["[slot_key]"])
				character_creator_bag |= "[slot_key]"

/// Drops equip/bag marks that no longer point at an item (after clears, swaps and preset loads).
/datum/preferences/proc/character_creator_validate_loadout_state()
	character_creator_read_loadout_state(character_creator_loadout_state())

/datum/preferences/proc/character_creator_preset_meta(preset_slot)
	var/list/preset = vars["loadout_preset_[preset_slot]"]
	if(!islist(preset))
		return list("name" = null, "role" = null)
	return list("name" = preset["cc_name"], "role" = preset["cc_role"])

/// Loadout link tasks from the creator. Presets keep their name, role and equip marks.
/datum/preferences/proc/character_creator_loadout_link(mob/user, list/params)
	var/list/href_list = list()
	for(var/key in params)
		href_list[key] = params[key]
	href_list["preference"] = "character_setup_loadout"
	var/task = href_list["task"]
	var/preset_slot = text2num("[href_list["slot"]]")
	var/list/kept_meta
	if(task == "preset_save" && isnum(preset_slot))
		kept_meta = character_creator_preset_meta(preset_slot)
	character_setup_handle_loadout_link(user, href_list)
	if(task == "preset_save" && islist(vars["loadout_preset_[preset_slot]"]))
		var/list/preset = vars["loadout_preset_[preset_slot]"]
		preset["cc_name"] = kept_meta["name"]
		preset["cc_role"] = kept_meta["role"]
		preset["cc_equip"] = character_creator_equip ? character_creator_equip.Copy() : list()
		preset["cc_bag"] = character_creator_bag ? character_creator_bag.Copy() : list()
		save_character()
	else if(task == "preset_load" && islist(vars["loadout_preset_[preset_slot]"]))
		var/list/preset = vars["loadout_preset_[preset_slot]"]
		character_creator_read_loadout_state(list("equip" = preset["cc_equip"], "bag" = preset["cc_bag"]))
		save_character()
	else
		character_creator_validate_loadout_state()

/datum/preferences/proc/character_creator_set_preset_meta(preset_slot, key, value)
	if(!isnum(preset_slot) || preset_slot < 1 || preset_slot > 3)
		return FALSE
	var/list/preset = vars["loadout_preset_[preset_slot]"]
	if(!islist(preset) || !length(preset))
		return FALSE
	preset[key] = value
	save_character()
	return TRUE

/// Static info for a spawnable item, shaped like the Examine Closer tooltip data. Cached per type.
/proc/character_creator_item_info(item_path)
	var/static/list/cache = list()
	var/static/regex/line_breaks = regex(@"<\s*/?\s*br\s*/?\s*>", "gi")
	if(cache[item_path])
		return cache[item_path]
	var/list/info = list()
	var/obj/item/item = new item_path()
	if(istype(item))
		// Line breaks become spaces so "line.<br>Next" does not glue into one word.
		var/clean_desc = trim(GLOB.html_tags.Replace(line_breaks.Replace("[item.desc]", " "), ""))
		info["desc"] = clean_desc
		info["weight"] = item.item_weight
		info["slot_flags"] = item.slot_flags
		if(istype(item, /obj/item/clothing))
			var/obj/item/clothing/clothing_item = item
			if(clothing_item.armor_class)
				info["armorClassLabel"] = armor_class_to_label(clothing_item.armor_class)
		if(item.force)
			info["weaponDamage"] = list("force" = item.force)
			info["weaponCategory"] = item.get_weapon_category()
		if(item.force || item.associated_skill)
			info["intents"] = item.get_weapon_intent_names()
		if(isweapon(item))
			var/obj/item/weapon/weapon_item = item
			if(weapon_item.weapon_special)
				info["specialAttack"] = list(
					"name" = initial(weapon_item.weapon_special:name),
					"desc" = initial(weapon_item.weapon_special:desc),
				)
		var/list/tag_badges = item.get_weapon_tag_badges()
		if(length(tag_badges))
			info["tags"] = tag_badges
	qdel(item)
	cache[item_path] = info
	return info

/// Loadout catalog entries shared by every player. Per-player nobility locks are sent apart.
GLOBAL_LIST_EMPTY(character_creator_loadout_catalog)

/proc/character_creator_loadout_catalog()
	if(length(GLOB.character_creator_loadout_catalog))
		return GLOB.character_creator_loadout_catalog
	var/datum/asset/spritesheet/spritesheet = get_asset_datum(/datum/asset/spritesheet/loadout_items)
	var/list/catalog = list()
	for(var/datum/loadout_item/item as anything in GLOB.loadout_items)
		var/obj/item/item_type = item.item_path
		if(!item_type)
			continue
		var/list/info = character_creator_item_info(item_type)
		var/list/fits = list()
		for(var/slot_id in GLOB.character_creator_equip_slots)
			if(GLOB.character_creator_equip_slots[slot_id] && character_creator_item_fits(item_type, slot_id))
				fits += slot_id
		catalog += list(list(
			"name" = item.name,
			"desc" = info["desc"] || item.description,
			"point_cost" = item.point_cost,
			"typepath" = "[item.type]",
			"icon" = spritesheet.icon_class_name(sanitize_css_class_name("loadout_item_[REF(item)]")),
			"category" = character_creator_loadout_category(item_type),
			"fits" = fits,
			"info" = info,
		))
		// The first build spawns every item for its tooltip info, so it yields between ticks.
		CHECK_TICK
	// A spritesheet still loading has no class names yet, so build again next time.
	if(spritesheet.fully_generated)
		GLOB.character_creator_loadout_catalog = catalog
	return catalog

/// Titles a loadout preset can be bound to.
/proc/character_creator_loadout_roles()
	var/list/roles = list()
	for(var/datum/job/job as anything in SSjob?.joinable_occupations)
		if(job.enabled && (job.job_flags & JOB_NEW_PLAYER_JOINABLE))
			roles += job.title
	return sortList(roles)

/// Loadout item typepaths this player may not pick.
/proc/character_creator_loadout_locked(mob/user)
	var/list/locked = list()
	for(var/datum/loadout_item/item as anything in GLOB.loadout_items)
		if(item.item_path && !item.nobility_check(user))
			locked += "[item.type]"
	return locked

/datum/preferences/proc/character_creator_loadout_data()
	var/list/presets = list()
	for(var/preset_slot in 1 to 3)
		var/list/meta = character_creator_preset_meta(preset_slot)
		var/list/preset = vars["loadout_preset_[preset_slot]"]
		presets += list(list(
			"slot" = preset_slot,
			"name" = meta["name"],
			"role" = meta["role"],
			"empty" = !(islist(preset) && length(preset)),
			"summary" = get_preset_summary(preset_slot),
		))
	return list(
		"slots" = character_setup_loadout_slots_data(),
		"points" = character_setup_loadout_points_data(),
		"presets" = presets,
		"equip" = character_creator_equip || list(),
		"bag" = character_creator_bag || list(),
	)

// ---- Spawn: worn, carried and stashed loadout items ----

/datum/outfit/character_creator_kit
	name = "Character Creator Kit"
	can_be_admin_equipped = FALSE

/datum/outfit/character_creator_kit/proc/store(mob/living/carbon/human/target, obj/item/new_item)
	for(var/slot_flag in list(ITEM_SLOT_BACK_L, ITEM_SLOT_BACK_R, ITEM_SLOT_BELT, ITEM_SLOT_NECK))
		var/obj/item/container = target.get_item_by_slot(slot_flag)
		if(container && container != new_item && attempt_insert_with_flipping(container, new_item, null, TRUE, FALSE))
			return TRUE
	return FALSE

/// Loadout entries for this spawn: a preset bound to the role wins over the current picks.
/datum/preferences/proc/character_creator_spawn_entries(mob/living/carbon/human/character)
	var/list/role_titles = list(character.job)
	var/datum/job/current_job = SSjob.GetJob(character.job)
	if(istype(current_job, /datum/job/advclass))
		var/datum/job/advclass/advclass_job = current_job
		if(advclass_job.parent_job)
			role_titles += advclass_job.parent_job.title
	var/list/source
	for(var/preset_slot in 1 to 3)
		var/list/preset = vars["loadout_preset_[preset_slot]"]
		if(islist(preset) && length(preset) && preset["cc_role"] && (preset["cc_role"] in role_titles))
			source = preset
			break
	. = list()
	var/points_left = get_base_points()
	for(var/slot in 1 to 10)
		var/item_type
		var/list/entry
		if(source)
			var/list/source_equip = islist(source["cc_equip"]) ? source["cc_equip"] : null
			var/list/source_bag = islist(source["cc_bag"]) ? source["cc_bag"] : null
			item_type = string_to_typepath(source["loadout[slot]"])
			entry = list(
				"name" = source["loadout_[slot]_name"],
				"desc" = source["loadout_[slot]_desc"],
				"hex" = source["loadout_[slot]_hex"],
				"equip" = LAZYACCESS(source_equip, "[slot]"),
				"bag" = ("[slot]" in source_bag),
			)
		else
			var/datum/loadout_item/current = vars["loadout[slot]"]
			item_type = current?.type
			entry = list(
				"name" = vars["loadout_[slot]_name"],
				"desc" = vars["loadout_[slot]_desc"],
				"hex" = vars["loadout_[slot]_hex"],
				"equip" = LAZYACCESS(character_creator_equip, "[slot]"),
				"bag" = ("[slot]" in character_creator_bag),
			)
		if(!ispath(item_type, /datum/loadout_item))
			continue
		var/datum/loadout_item/loadout_datum
		for(var/datum/loadout_item/candidate as anything in GLOB.loadout_items)
			if(candidate.type == item_type)
				loadout_datum = candidate
				break
		if(!loadout_datum?.item_path || !loadout_datum.nobility_check(character) || loadout_datum.point_cost > points_left)
			continue
		points_left -= loadout_datum.point_cost
		entry["path"] = loadout_datum.item_path
		. += list(entry)

/// Puts loadout items where the player placed them. Returns TRUE when it handled the loadout.
/datum/preferences/proc/character_creator_apply_loadout(mob/living/carbon/human/character)
	if(!character?.mind)
		return FALSE
	var/datum/outfit/character_creator_kit/kit = new()
	var/stashed = 0
	for(var/list/entry in character_creator_spawn_entries(character))
		var/item_path = entry["path"]
		var/slot_id = entry["equip"]
		if(!slot_id && !entry["bag"])
			character_creator_stash_path(character, item_path)
			stashed++
			continue
		var/obj/item/new_item = new item_path(character.drop_location())
		if(istext(entry["hex"]) && length(entry["hex"]))
			new_item.add_atom_colour(entry["hex"], FIXED_COLOUR_PRIORITY)
			new_item.update_icon()
		if(istext(entry["name"]) && length(entry["name"]))
			new_item.original_name = new_item.name
			new_item.name = entry["name"]
		if(istext(entry["desc"]) && length(entry["desc"]))
			new_item.desc = entry["desc"]
		if(slot_id && character_creator_item_fits(item_path, slot_id) && character_creator_wear(character, new_item, slot_id, kit))
			continue
		if(kit.store(character, new_item))
			continue
		qdel(new_item)
		character_creator_stash_path(character, item_path)
		stashed++
	qdel(kit)
	if(stashed)
		to_chat(character, span_notice("[stashed] of my belongings wait for me in my stash."))
	return TRUE

/// Wears a loadout item in its slot. The role item already there moves whole into the bags,
/// with its contents and state (stack amounts, key IDs). Nothing from the role is deleted:
/// when the bags cannot take the role item, it stays where it was and the loadout item is not
/// worn, so the caller packs or stashes the loadout item instead.
/datum/preferences/proc/character_creator_wear(mob/living/carbon/human/character, obj/item/new_item, slot_id, datum/outfit/character_creator_kit/kit)
	var/slot_flag = GLOB.character_creator_equip_slots[slot_id]
	var/obj/item/displaced
	if(!slot_flag)
		displaced = (slot_id == "rhand") ? character.get_item_for_held_index(2) : character.get_item_for_held_index(1)
	else
		displaced = character.get_item_by_slot(slot_flag)
	if(displaced && !character.temporarilyRemoveItemFromInventory(displaced, TRUE))
		return FALSE
	if(!character_creator_put_in_slot(character, new_item, slot_id, slot_flag))
		if(displaced)
			character_creator_put_in_slot(character, displaced, slot_id, slot_flag)
		return FALSE
	if(!displaced || kit.store(character, displaced))
		return TRUE
	// No room for the role item: undo the swap.
	character.temporarilyRemoveItemFromInventory(new_item, TRUE)
	if(!character_creator_put_in_slot(character, displaced, slot_id, slot_flag))
		displaced.forceMove(character.drop_location())
	return FALSE

/datum/preferences/proc/character_creator_put_in_slot(mob/living/carbon/human/character, obj/item/item, slot_id, slot_flag)
	if(!slot_flag)
		return (slot_id == "rhand") ? character.put_in_r_hand(item) : character.put_in_l_hand(item)
	return character.equip_to_slot_if_possible(item, slot_flag, FALSE, TRUE, TRUE, TRUE, TRUE)

/proc/character_creator_stash_path(mob/living/carbon/human/character, item_path, display_name)
	if(!character.mind)
		return
	var/obj/item/item_type = item_path
	var/base_name = display_name || initial(item_type.name)
	var/key = base_name
	var/suffix = 1
	while(character.mind.special_items[key])
		suffix++
		key = "[base_name] ([suffix])"
	character.mind.special_items[key] = item_path

#undef CC_LANG_EN
#undef CC_LANG_RU
#undef CC_EXPORT_FORMAT
#undef CC_EXPORT_VERSION
#undef CC_IMPORT_MAX_LENGTH
#undef CC_TEXT_CAP
