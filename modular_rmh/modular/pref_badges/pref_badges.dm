// Player declarations for examine and the optional, viewer-specific overhead HUD.
#define PREFERENCE_BADGE_HUD "preference_badges"

GLOBAL_DATUM_INIT(preference_badge_hud, /datum/atom_hud/preference_badges, new)
GLOBAL_LIST_INIT(preference_badge_categories, list(
	"free_use" = list(
		"name" = "Free Use",
		"description" = "Advertise that free-use scenes are welcome. Check OOC notes for details.",
		"choices" = list("Enabled" = 1),
	),
	"role" = list(
		"name" = "Dom / Sub",
		"description" = "Switch means enjoying both roles; Any means having no particular preference.",
		"choices" = list("Dominant" = 1, "Submissive" = 2, "Switch" = 3, "Any" = 4),
	),
	"scene_access" = list(
		"name" = "Scene Access",
		"description" = "How others may join or interrupt an IC scene. Everyone can still pause or end their own participation.",
		"choices" = list("Open" = 1, "Ask First" = 2, "Join Without Disrupting" = 3, "Private" = 4),
		"details" = list(
			"Open" = "Joining and IC interruptions are welcome.",
			"Ask First" = "Ask before joining or interrupting.",
			"Join Without Disrupting" = "Joining is welcome; keep the scene going.",
			"Private" = "Please do not join or interrupt unsolicited.",
		),
	),
	"looking_for" = list(
		"name" = "Looking For",
		"description" = "Choose any combination of the kinds of scenes or connections you are seeking.",
		"multiple" = TRUE,
		"choices" = list("Romance" = 1, "Casual Encounters" = 2, "Ongoing Partners" = 4, "Story-Driven Scenes" = 8),
	),
	"scene_tone" = list(
		"name" = "Scene Tone",
		"description" = "Choose any combination of the tones you enjoy in a scene.",
		"multiple" = TRUE,
		"choices" = list("Affectionate" = 1, "Playful" = 2, "Dramatic" = 4, "Rough" = 8),
	),
	"willingness" = list(
		"name" = "Willingness",
		"description" = "Your preferred character willingness in scenes. Check OOC notes for details.",
		"multiple" = TRUE,
		"choices" = list("Willing" = 1, "Dubcon" = 2, "Unwilling" = 4),
	),
	"partner" = list(
		"name" = "Scene Partner Preference",
		"description" = "Advertise your preference for scene partners.",
		"choices" = list("Straight" = 1, "Gay" = 2, "Lesbian" = 3, "Bisexual" = 4, "Pansexual" = 5, "Asexual" = 6, "Demisexual" = 7),
	),
	"pvp" = list(
		"name" = "PvP",
		"description" = "Advertise your PvP preference. Normal escalation rules still apply.",
		"choices" = list("No PvP" = 1, "Ask First" = 2, "Open to PvP" = 3),
	),
	"futa" = list(
		"name" = "Futanari",
		"description" = "Advertise whether your character is a futa, you are looking for a futa, or you prefer no futa scenes.",
		"choices" = list("Is a Futa" = 1, "Looking for a Futa" = 2, "No Futa" = 3),
	),
))

/datum/preference/list_type/preference_badges
	savefile_key = "preference_badges"
	savefile_identifier = PREF_CHARACTER
	category = "character_ooc"

/datum/preference/list_type/preference_badges/create_default_value(datum/preferences/prefs)
	var/list/values = list("overhead" = "none")
	for(var/category in GLOB.preference_badge_categories)
		values[category] = 0
	return values

/datum/preference/list_type/preference_badges/deserialize(list/input, datum/preferences/prefs)
	var/list/values = create_default_value(prefs)
	if(!islist(input))
		return values
	for(var/category in GLOB.preference_badge_categories)
		var/value = input[category]
		if(!isnum(value) || value != round(value))
			continue
		var/list/definition = GLOB.preference_badge_categories[category]
		var/list/choices = definition["choices"]
		var/maximum = definition["multiple"] ? (1 << length(choices)) - 1 : length(choices)
		if(value >= 0 && value <= maximum)
			values[category] = value
	var/overhead = input["overhead"]
	if(overhead == "none" || (istext(overhead) && (overhead in GLOB.preference_badge_categories)))
		values["overhead"] = overhead
	return values

/datum/preference/list_type/preference_badges/apply_to_human(mob/living/carbon/human/character, list/value, datum/preferences/prefs)
	character.preference_badge_values = value.Copy()
	character.preference_badge_slot = prefs?.default_slot
	character.update_preference_badge()

/datum/preference/toggle/show_preference_badges
	savefile_key = "show_preference_badges"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Content"
	toggles_menu_name = "Show preference badges"
	toggles_menu_desc = "Show players' badges above their characters and when examining them."
	category = "chat"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/datum/preference/toggle/show_preference_badges/apply_to_client(client/player, value)
	player?.mob?.update_preference_badge_visibility()

/// Names are shared by the setup menu, hover text and the overhead selection.
/proc/get_preference_badge_label(category, value)
	if(!value)
		return "Disabled"
	var/list/definition = GLOB.preference_badge_categories[category]
	var/list/choices = definition?["choices"]
	var/list/selected = list()
	for(var/choice in choices)
		if(definition["multiple"] ? (value & choices[choice]) : value == choices[choice])
			selected += choice
	return english_list(selected)

/datum/preferences/proc/preference_badges_ui_data()
	var/list/values = read_preference(/datum/preference/list_type/preference_badges)
	var/list/categories = list()
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/preference_badges)
	for(var/category in GLOB.preference_badge_categories)
		var/list/definition = GLOB.preference_badge_categories[category]
		var/list/choices = definition["choices"]
		var/list/options = list()
		for(var/choice in choices)
			options += list(list(
				"name" = choice,
				"value" = choices[choice],
				"description" = definition["details"]?[choice] || "",
				"icon_class" = sheet.icon_class_name("[category]_[choices[choice]]"),
			))
		var/value = values[category]
		categories += list(list(
			"id" = category,
			"name" = definition["name"],
			"description" = definition["description"],
			"multiple" = !!definition["multiple"],
			"value" = value,
			"label" = get_preference_badge_label(category, value),
			"icon_class" = value ? sheet.icon_class_name("[category]_[value]") : null,
			"small_icon_class" = value ? sheet.icon_class_name("small-[category]_[value]") : null,
			"options" = options,
		))
	return list(
		"show" = read_preference(/datum/preference/toggle/show_preference_badges),
		"overhead" = values["overhead"],
		"categories" = categories,
	)

/datum/preferences/proc/handle_preference_badge_action(mob/user, list/params)
	if(user?.client?.prefs != src)
		return FALSE
	if(params["task"] == "toggle_view")
		return toggle_preference_badge_visibility(user)
	if(params["task"] != "set")
		return FALSE

	var/category = params["category"]
	var/value = params["value"]
	if(category == "overhead")
		if(value != "none" && (!istext(value) || !(value in GLOB.preference_badge_categories)))
			return FALSE
	else
		if(!istext(category) || !(category in GLOB.preference_badge_categories) || !isnum(value) || value != round(value))
			return FALSE
		var/list/definition = GLOB.preference_badge_categories[category]
		var/list/choices = definition["choices"]
		var/maximum = definition["multiple"] ? (1 << length(choices)) - 1 : length(choices)
		if(value < 0 || value > maximum)
			return FALSE

	var/list/values = read_preference(/datum/preference/list_type/preference_badges)
	values = values.Copy()
	values[category] = value
	if(!write_preference(/datum/preference/list_type/preference_badges, values))
		return FALSE
	save_character()

	// Editing another saved character must not alter the body currently in play.
	if(ishuman(parent?.mob))
		var/mob/living/carbon/human/character = parent.mob
		if(character.preference_badge_slot == default_slot)
			var/datum/preference/entry = GLOB.preference_entries[/datum/preference/list_type/preference_badges]
			entry.apply_to_human(character, read_preference(entry.type), src)
	return TRUE

/datum/preferences/proc/toggle_preference_badge_visibility(mob/user)
	if(user?.client?.prefs != src)
		return FALSE
	var/visible = !read_preference(/datum/preference/toggle/show_preference_badges)
	if(!update_preference(/datum/preference/toggle/show_preference_badges, visible))
		return FALSE
	save_preferences()
	return TRUE

/mob/proc/update_preference_badge_visibility()
	if(!client?.prefs || isnewplayer(src))
		return
	if(client.prefs.read_preference(/datum/preference/toggle/show_preference_badges))
		if(!GLOB.preference_badge_hud.hud_users_all_z_levels[src])
			GLOB.preference_badge_hud.show_to(src)
	else
		GLOB.preference_badge_hud.hide_from(src, absolute = TRUE)

/datum/atom_hud/preference_badges
	hud_icons = list(PREFERENCE_BADGE_HUD)
	uses_global_hud_category = FALSE

/datum/atom_hud/preference_badges/unregister_atom(datum/source, force)
	// The inherited signal handler is already marked non-sleeping.
	. = ..()
	if(ismob(source))
		var/mob/badge_owner = source
		badge_owner.clear_preference_badge_image()

/// Also releases the image's reference to its owner on logout or deletion.
/mob/proc/clear_preference_badge_image()
	set_hud_image_inactive(PREFERENCE_BADGE_HUD, exclusive_hud = GLOB.preference_badge_hud)
	GLOB.preference_badge_hud.remove_atom_from_hud(src)
	var/image/badge_image = hud_list?[PREFERENCE_BADGE_HUD]
	LAZYREMOVE(hud_list, PREFERENCE_BADGE_HUD)
	if(badge_image)
		qdel(badge_image)

/mob/living/carbon/human
	var/list/preference_badge_values
	/// Saved slot from which the body received its badge declarations.
	var/preference_badge_slot

/mob/living/carbon/human/Login()
	. = ..()
	if(!client?.prefs)
		return
	var/datum/preferences/prefs = client.prefs
	if(!preference_badge_values || preference_badge_slot == prefs.default_slot)
		var/datum/preference/entry = GLOB.preference_entries[/datum/preference/list_type/preference_badges]
		entry.apply_to_human(src, prefs.read_preference(entry.type), prefs)
	else
		update_preference_badge()

/mob/living/carbon/human/proc/update_preference_badge()
	var/category = preference_badge_values?["overhead"]
	var/value = preference_badge_values?[category]
	if(!client || !value || !(category in GLOB.preference_badge_categories))
		clear_preference_badge_image()
		return
	var/image/badge_image = hud_list?[PREFERENCE_BADGE_HUD]
	if(!badge_image)
		badge_image = image('modular_rmh/icons/pref_badges/pref_badges_small.dmi', src, "", ABOVE_ALL_MOB_LAYER)
		badge_image.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
		badge_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		badge_image.pixel_x = 24
		badge_image.pixel_y = 32
		LAZYSET(hud_list, PREFERENCE_BADGE_HUD, badge_image)
	badge_image.icon_state = "[category]_[value]"
	set_hud_image_active(PREFERENCE_BADGE_HUD, update_huds = FALSE)
	if(!GLOB.preference_badge_hud.hud_atoms_all_z_levels[src])
		GLOB.preference_badge_hud.add_atom_to_hud(src)

/mob/living/carbon/human/proc/build_preference_badges(mob/viewer)
	if(!viewer?.client?.prefs?.read_preference(/datum/preference/toggle/show_preference_badges))
		return ""
	var/list/badges = list()
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/preference_badges)
	for(var/category in GLOB.preference_badge_categories)
		var/value = preference_badge_values?[category]
		if(!value)
			continue
		var/list/definition = GLOB.preference_badge_categories[category]
		var/label = get_preference_badge_label(category, value)
		var/details = definition["details"]?[label] || ""
		var/tooltip = "[definition["name"]]: [label]. [details] Check OOC notes for details."
		badges += span_tooltip(tooltip, sheet.icon_tag("[category]_[value]"))
	return badges.Join(" ")

/datum/asset/spritesheet/preference_badges
	name = "rmh_pref_badges"

/datum/asset/spritesheet/preference_badges/create_spritesheets()
	InsertAll("", 'modular_rmh/icons/pref_badges/pref_badges.dmi')
	InsertAll("small", 'modular_rmh/icons/pref_badges/pref_badges_small.dmi')

#undef PREFERENCE_BADGE_HUD
