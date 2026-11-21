/**
 * Spell Library: a visual catalogue for granting and revoking spells (port of Ratwood 2.0 PR 156).
 *
 * Opened by the "Give Spell" verb and by the Spells button of the Admin Menu player panel.
 * Browsing never instantiates a spell: every card is built from initial() values.
 */

/// Power sources shown as the main filter, keyed by the spell_type define as text.
/proc/admin_spell_sources()
	var/static/list/sources = list(
		"[SPELL_MANA]" = "Arcane (mana)",
		"[SPELL_MIRACLE]" = "Miracle (devotion)",
		"[SPELL_PSYDONIC_MIRACLE]" = "Psydonic miracle",
		"[SPELL_STAMINA]" = "Stamina",
		"[SPELL_ESSENCE]" = "Essence",
		"[SPELL_BLOOD]" = "Blood",
		"[SPELL_RAGE]" = "Rage",
		"none" = "No cost type",
	)
	return sources

/// How the spell is delivered. First matching root wins, so keep specific families above broad ones.
/proc/admin_spell_kinds()
	var/static/list/kinds = list(
		"healing" = list("name" = "Healing", "roots" = list(/datum/action/cooldown/spell/healing, /datum/action/cooldown/spell/revive, /datum/action/cooldown/spell/attach_bodypart)),
		"projectile" = list("name" = "Projectile", "roots" = list(/datum/action/cooldown/spell/projectile)),
		"area" = list("name" = "Area", "roots" = list(/datum/action/cooldown/spell/aoe, /datum/action/cooldown/spell/cone, /datum/action/cooldown/spell/beam)),
		"conjure" = list("name" = "Conjuration", "roots" = list(/datum/action/cooldown/spell/conjure)),
		"status" = list("name" = "Status effect", "roots" = list(/datum/action/cooldown/spell/status, /datum/action/cooldown/spell/enchantment)),
		"essence" = list("name" = "Essence", "roots" = list(/datum/action/cooldown/spell/essence)),
		"self" = list("name" = "Self-cast", "roots" = list(/datum/action/cooldown/spell/undirected)),
		"targeted" = list("name" = "Targeted", "roots" = list()),
	)
	return kinds

/proc/admin_spell_kind(spell_type)
	var/list/kinds = admin_spell_kinds()
	for(var/kind_id in kinds)
		for(var/root in kinds[kind_id]["roots"])
			if(ispath(spell_type, root))
				return kind_id
	return "targeted"

/// Spell types that can be handed out: concrete and named.
/proc/admin_spell_types()
	var/static/list/spell_types
	if(spell_types)
		return spell_types
	spell_types = list()
	for(var/datum/action/cooldown/spell/spell_type as anything in subtypesof(/datum/action/cooldown/spell))
		if(IS_ABSTRACT(spell_type))
			continue
		var/spell_name = initial(spell_type.name)
		if(!spell_name || spell_name == "Spell") // abstract or un-named spells
			continue
		spell_types[spell_type] = TRUE
	return spell_types

/proc/admin_spell_icon(datum/action/cooldown/spell/spell_type)
	var/static/list/states_by_file = list()
	var/icon_file = initial(spell_type.button_icon)
	var/state = initial(spell_type.button_icon_state)
	if(icon_file && state)
		var/list/states = states_by_file[icon_file]
		if(!states)
			states = icon_states(icon_file)
			states_by_file[icon_file] = states
		if(state in states)
			return list(icon_file, state)
	return list('icons/mob/actions/roguespells.dmi', "shieldsparkles")

/// The card data of every grantable spell. Built once and shared by all admins.
/proc/admin_spell_catalog()
	var/static/list/catalog
	if(catalog)
		return catalog
	var/list/entries = list()
	var/static/regex/line_breaks = regex("<br\\s*/?>", "gi")
	var/static/regex/html_tags = regex("<.*?>", "g")
	var/list/sources = admin_spell_sources()
	for(var/datum/action/cooldown/spell/spell_type as anything in admin_spell_types())
		var/description = initial(spell_type.desc) || ""
		description = html_decode(html_tags.Replace(line_breaks.Replace(description, "\n"), ""))
		var/source = "[initial(spell_type.spell_type)]"
		if(!sources[source])
			source = "none"
		var/list/sprite = admin_spell_icon(spell_type)
		var/school = initial(spell_type.school)
		entries += list(list(
			"path" = "[spell_type]",
			"name" = initial(spell_type.name),
			"desc" = description,
			"source" = source,
			"kind" = admin_spell_kind(spell_type),
			"school" = (school && school != SCHOOL_UNSET) ? "[school]" : null,
			"icon" = "[sprite[1]]",
			"icon_state" = sprite[2],
			"cooldown" = initial(spell_type.cooldown_time) / 10,
			"charge_time" = initial(spell_type.charge_required) ? initial(spell_type.charge_time) / 10 : 0,
			"cost" = initial(spell_type.spell_cost),
			"range" = initial(spell_type.cast_range),
		))
	catalog = entries
	return catalog

/datum/admin_spell_library
	/// ckey of the admin this window belongs to.
	var/owner_ckey
	var/datum/weakref/target_ref
	/// Last feedback line shown in the window.
	var/status_message
	/// "info", "good" or "bad".
	var/status_type = "info"

/datum/admin_spell_library/New(client/owner, mob/target)
	. = ..()
	owner_ckey = owner?.ckey
	target_ref = WEAKREF(target)

/datum/admin_spell_library/Destroy()
	SStgui.close_uis(src)
	target_ref = null
	return ..()

/datum/admin_spell_library/proc/can_access(mob/user)
	return user?.client && owner_ckey && user.ckey == owner_ckey && check_rights_for(user.client, R_FUN)

/datum/admin_spell_library/proc/get_target()
	var/mob/target = target_ref?.resolve()
	return QDELETED(target) ? null : target

/datum/admin_spell_library/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_spell_library/ui_status(mob/user, datum/ui_state/state)
	return can_access(user) ? UI_INTERACTIVE : UI_CLOSE

/datum/admin_spell_library/ui_interact(mob/user, datum/tgui/ui)
	if(!can_access(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminSpellLibrary", "Spell Library")
		ui.set_autoupdate(FALSE) // changes come from its own buttons; 400 spells are not resent every second
		ui.open()

/datum/admin_spell_library/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/admin_spell_library/ui_static_data(mob/user)
	if(!can_access(user))
		return list()
	var/list/sources = list()
	var/list/source_names = admin_spell_sources()
	for(var/id in source_names)
		sources += list(list("id" = id, "name" = source_names[id]))
	var/list/kinds = list()
	var/list/kind_data = admin_spell_kinds()
	for(var/id in kind_data)
		kinds += list(list("id" = id, "name" = kind_data[id]["name"]))
	return list("spells" = admin_spell_catalog(), "sources" = sources, "kinds" = kinds)

/// Typepath text -> number of copies the target holds.
/datum/admin_spell_library/proc/known_spells(mob/target)
	var/list/known = list()
	if(!target)
		return known
	for(var/datum/action/cooldown/spell/spell in target.actions)
		if(!QDELETED(spell))
			known["[spell.type]"]++
	return known

/datum/admin_spell_library/ui_data(mob/user)
	if(!can_access(user))
		return list()
	var/mob/target = get_target()
	return list(
		"target_name" = target ? target.name : "Recipient unavailable",
		"target_key" = target?.key,
		"target_valid" = !!target,
		"mindless" = target && !target.mind,
		"known_spells" = known_spells(target),
		"status_message" = status_message,
		"status_type" = status_type,
	)

/datum/admin_spell_library/proc/set_status(text, type = "info")
	status_message = text
	status_type = type

/datum/admin_spell_library/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(!can_access(user))
		return FALSE
	switch(action)
		if("grant")
			return grant_spell(user, params["path"])
		if("revoke")
			return revoke_spell(user, params["path"])
		if("revoke_all")
			return revoke_all(user)
	return FALSE

/// Validates a typepath sent by the window. Returns the spell type or null.
/datum/admin_spell_library/proc/resolve_spell_type(path_text)
	if(!istext(path_text))
		return null
	var/spell_type = text2path(path_text)
	if(!ispath(spell_type, /datum/action/cooldown/spell) || !admin_spell_types()[spell_type])
		return null
	return spell_type

/datum/admin_spell_library/proc/grant_spell(mob/user, path_text)
	var/mob/target = get_target()
	if(!target)
		set_status("The recipient is gone. Open the library again.", "bad")
		return TRUE
	var/datum/action/cooldown/spell/spell_type = resolve_spell_type(path_text)
	if(!spell_type)
		return FALSE
	if(known_spells(target)["[spell_type]"])
		set_status("[target.name] already has [initial(spell_type.name)].", "bad")
		return TRUE
	var/datum/action/cooldown/spell/new_spell = new spell_type(target.mind || target)
	// Constructors may sleep: make sure nothing changed in the meantime.
	if(QDELETED(new_spell) || !can_access(user) || get_target() != target)
		if(!QDELETED(new_spell))
			qdel(new_spell)
		return TRUE
	new_spell.Grant(target)
	log_admin("[key_name(user)] gave [key_name(target)] the spell [spell_type].")
	message_admins("[key_name_admin(user)] gave [key_name_admin(target)] the spell [initial(spell_type.name)] ([spell_type]).")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell")
	set_status("Granted [initial(spell_type.name)] to [target.name].", "good")
	return TRUE

/datum/admin_spell_library/proc/revoke_spell(mob/user, path_text)
	var/mob/target = get_target()
	if(!target)
		set_status("The recipient is gone. Open the library again.", "bad")
		return TRUE
	var/datum/action/cooldown/spell/spell_type = resolve_spell_type(path_text)
	if(!spell_type)
		return FALSE
	// A card stands for one exact type: subtypes are left alone.
	var/removed = 0
	for(var/datum/action/cooldown/spell/spell in target.actions)
		if(spell.type == spell_type && !QDELETED(spell))
			qdel(spell)
			removed++
	if(!removed)
		set_status("[target.name] no longer has [initial(spell_type.name)].", "bad")
		return TRUE
	log_admin("[key_name(user)] removed the spell [spell_type] from [key_name(target)].")
	message_admins("[key_name_admin(user)] removed the spell [initial(spell_type.name)] ([spell_type]) from [key_name_admin(target)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Spell")
	set_status("Removed [initial(spell_type.name)] from [target.name].", "good")
	return TRUE

/datum/admin_spell_library/proc/revoke_all(mob/user)
	var/mob/target = get_target()
	if(!target)
		set_status("The recipient is gone. Open the library again.", "bad")
		return TRUE
	var/removed = 0
	for(var/datum/action/cooldown/spell/spell in target.actions)
		if(!QDELETED(spell))
			qdel(spell)
			removed++
	if(!removed)
		set_status("[target.name] has no spells.", "info")
		return TRUE
	log_admin("[key_name(user)] removed all [removed] spells from [key_name(target)].")
	message_admins("[key_name_admin(user)] removed all [removed] spells from [key_name_admin(target)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove All Spells")
	set_status("Removed [removed] spells from [target.name].", "good")
	return TRUE

/// Opens the Spell Library on a mob for this admin.
/client/proc/open_spell_library(mob/spell_recipient)
	if(!check_rights(R_FUN))
		return
	if(QDELETED(spell_recipient))
		to_chat(src, span_warning("The intended spell recipient no longer exists."))
		return
	var/datum/admin_spell_library/library = new(src, spell_recipient)
	library.ui_interact(mob)
