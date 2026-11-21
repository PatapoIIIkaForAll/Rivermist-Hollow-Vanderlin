/**
 * Admin Menu: registry of the verbs that are handed out through admin rights.
 *
 * The right-hand stat panel builds its tabs from verb categories. Every verb listed here is
 * still added to (and removed from) the admin's client exactly as before, so rights, hotkeys,
 * the command bar and right-click menus keep working. The only thing that changes is that these
 * verbs are no longer listed on the stat panel: they are reached through the Admin Menu window.
 *
 * A verb is admin-granted when it is handed out by add_admin_verbs() (or one of the other
 * holder-only grants below). This is decided by how the verb is granted, never by its name or tab.
 */

/// Verbs that stay on the right-hand "Admin" tab even while the Admin Menu is in use.
GLOBAL_LIST_INIT(admin_menu_tab_verbs, list(
	/client/proc/deadmin = TRUE,
	/client/proc/readmin = TRUE,
	/client/proc/open_admin_menu = TRUE,
	/client/proc/show_verbs = TRUE, // the only way back after "Adminverbs - Hide All"
))
GLOBAL_PROTECT(admin_menu_tab_verbs)

/// Admin-granted verbs that only exist in this build's Admin Menu (ports and re-enabled tools). list(rights flag = list(verbs)).
GLOBAL_LIST_INIT(admin_menu_extra_verbs, list(
	// Existing tools of this build that were never handed out (they all check R_ADMIN themselves),
	// plus ports from Azure Peak / Ratwood 2.0 (see admin_menu_ports.dm).
	"[R_ADMIN]" = list(
		/client/proc/toggleannouncelogin,
		/client/proc/cmd_admin_godmode,
		/client/proc/cmd_admin_rejuvenate,
		/client/proc/cmd_admin_drop_everything,
		/client/proc/cmd_admin_gib,
		/client/proc/cmd_admin_explosion,
		/client/proc/send_to_cryo,
		/client/proc/sendmob,
		/datum/admins/proc/sleep_view,
		/datum/admins/proc/wake_view,
		/client/proc/local_lightsout,
		/client/proc/vv_history_panel,
	),
	"[R_FUN]" = list(
		/client/proc/give_spell,
		/client/proc/remove_spell,
		/client/proc/open_scene_editor,
		/client/proc/cmd_give_control_to_player,
		/client/proc/force_say,
	),
	"[R_SPAWN]" = list(
		/client/proc/cmd_admin_animalize,
	),
	"[R_DEBUG]" = list(
		/client/proc/fix_next_move,
		/client/proc/enable_browser_debug,
	),
))
GLOBAL_PROTECT(admin_menu_extra_verbs)

/// Cache for get_admin_menu_verbs(): verb path -> rights bitfield that grants it (0 = any admin).
GLOBAL_LIST_EMPTY(admin_menu_verbs)
GLOBAL_PROTECT(admin_menu_verbs)
/// Cheap signature of the source lists, so runtime additions to them (modular code does that) are picked up.
GLOBAL_VAR_INIT(admin_menu_verbs_signature, -1)
GLOBAL_PROTECT(admin_menu_verbs_signature)
/// world.time of the last signature check, so a burst of lookups in one tick only checks once.
GLOBAL_VAR_INIT(admin_menu_verbs_checked, -1)
GLOBAL_PROTECT(admin_menu_verbs_checked)

/// Every source of admin-granted verbs, as list(list(verbs, rights flag)). Mirrors add_admin_verbs().
/proc/admin_menu_verb_sources()
	. = list(
		list(GLOB.admin_verbs_default, NONE),
		list(list(/client/proc/togglebuildmodeself), R_BUILD),
		list(GLOB.admin_verbs_admin, R_ADMIN),
		list(GLOB.admin_verbs_ban, R_BAN),
		list(GLOB.admin_verbs_fun, R_FUN),
		list(GLOB.admin_verbs_server, R_SERVER),
		list(GLOB.admin_verbs_debug, R_DEBUG),
		list(GLOB.admin_verbs_possess, R_POSSESS),
		list(GLOB.admin_verbs_permissions, R_PERMISSIONS),
		list(list(/client/proc/stealth), R_STEALTH),
		list(GLOB.admin_verbs_poll, R_ADMIN),
		list(GLOB.admin_verbs_sounds, R_SOUND),
		list(list(/client/proc/play_web_sound), R_SOUND),
		list(GLOB.admin_verbs_spawn, R_SPAWN),
		list(GLOB.admin_verbs_debug_mapping, R_DEBUG),
		list(list(/client/proc/disable_debug_verbs), R_DEBUG),
		list(list(/client/proc/show_verbs, /client/proc/open_admin_menu, /client/proc/readmin), NONE),
		list(admin_menu_toggle_verbs(), NONE),
	)
	for(var/flag_text in GLOB.admin_menu_extra_verbs)
		. += list(list(GLOB.admin_menu_extra_verbs[flag_text], text2num(flag_text)))

/// Per-admin preference toggles. Every admin gets them, whatever their rights.
/proc/admin_menu_toggle_verbs()
	return list(/client/proc/toggle_admin_menu_mode, /client/proc/toggle_admin_context_menu_mode, /client/proc/toggle_admin_ghost_hands)

/// Returns the assoc list of admin-granted verbs: verb path -> rights bitfield (0 = any admin).
/proc/get_admin_menu_verbs()
	if(GLOB.admin_menu_verbs_checked == world.time && GLOB.admin_menu_verbs_signature != -1)
		return GLOB.admin_menu_verbs
	GLOB.admin_menu_verbs_checked = world.time
	var/list/sources = admin_menu_verb_sources()
	var/signature = 0
	for(var/list/source as anything in sources)
		signature += length(source[1])
	if(signature == GLOB.admin_menu_verbs_signature)
		return GLOB.admin_menu_verbs

	var/list/built = list()
	for(var/list/source as anything in sources)
		var/flag = source[2]
		for(var/verb_path in source[1])
			if(isnull(built[verb_path]))
				built[verb_path] = flag
			else if(!flag || !built[verb_path])
				built[verb_path] = NONE // also available without that flag
			else
				built[verb_path] |= flag
	GLOB.admin_menu_verbs = built
	GLOB.admin_menu_verbs_signature = signature
	return built

/// Adds the Admin Menu specific verbs the holder has the rights for. Called from add_admin_verbs().
/client/proc/add_admin_menu_verbs()
	if(!holder)
		return
	add_verb(src, list(/client/proc/open_admin_menu) + admin_menu_toggle_verbs())
	// Build the spawn catalogue in the background now, so the first F7 does not freeze the server.
	if(holder.rank.rights & R_BUILD)
		warm_buildmode_catalog()
	var/rights = holder.rank.rights
	for(var/flag_text in GLOB.admin_menu_extra_verbs)
		if(rights & text2num(flag_text))
			add_verb(src, GLOB.admin_menu_extra_verbs[flag_text])
	// Right-click entries last: the classic list only offers verbs the admin was granted above.
	refresh_admin_context_verbs()

/// Removes everything add_admin_menu_verbs() adds. Called from remove_admin_verbs().
/client/proc/remove_admin_menu_verbs()
	var/list/to_remove = list(/client/proc/open_admin_menu) + admin_menu_toggle_verbs() + admin_context_menu_verbs() + classic_admin_context_verbs()
	for(var/flag_text in GLOB.admin_menu_extra_verbs)
		to_remove += GLOB.admin_menu_extra_verbs[flag_text]
	remove_verb(src, to_remove)

/// Whether this client uses the new Admin Menu (TRUE) or the classic admin tabs on the stat panel (FALSE).
/// The stat panel asks this for every admin on every fire, so the preference is read once and cached.
/client/var/admin_menu_mode_cache

/client/proc/uses_admin_menu()
	if(!isnull(admin_menu_mode_cache))
		return admin_menu_mode_cache
	if(!prefs)
		return TRUE
	admin_menu_mode_cache = !!prefs.read_preference(/datum/preference/toggle/admin_new_menu)
	return admin_menu_mode_cache

/// TRUE when this verb must not be listed on the stat panel of this client.
/client/proc/admin_menu_hides_verb(verb_path)
	if(!holder) // only admins ever hold these verbs; keeps this free for everyone else
		return FALSE
	if(GLOB.admin_menu_tab_verbs[verb_path])
		return FALSE
	if(isnull(get_admin_menu_verbs()[verb_path]))
		return FALSE
	return uses_admin_menu()

/// Persistent, per-admin choice between the new Admin Menu and the classic admin tabs.
/datum/preference/toggle/admin_new_menu
	savefile_key = "admin_new_menu"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/datum/preference/toggle/admin_new_menu/apply_to_client(client/C, value)
	C?.admin_menu_mode_cache = !!value

/datum/preference/toggle/admin_new_menu/is_accessible(datum/preferences/prefs)
	. = ..()
	if(!.)
		return
	return !!prefs?.parent?.holder

/// Switches between the new Admin Menu and the classic admin tabs, then rebuilds the stat panel.
/client/proc/set_admin_menu_mode(use_new_menu)
	if(!holder || !prefs)
		return FALSE
	prefs.write_preference(/datum/preference/toggle/admin_new_menu, !!use_new_menu)
	admin_menu_mode_cache = !!use_new_menu
	prefs.save_preferences()
	init_verbs()
	if(stat_panel?.is_ready())
		stat_panel.send_message("admin_tab_mode", list("classic" = !use_new_menu))
		if(use_new_menu)
			panel_tabs -= "MC"
			panel_tabs -= "SDQL2"
	return TRUE

/client/proc/toggle_admin_menu_mode()
	set name = "Toggle New-Adm. Menu"
	set category = "Preferences.Admin"
	set desc = "Switch between the new Admin Menu window and the classic admin tabs on the right panel."

	if(!holder)
		return
	var/use_new_menu = !uses_admin_menu()
	if(!set_admin_menu_mode(use_new_menu))
		return
	if(use_new_menu)
		to_chat(src, span_interface("New-Adm. menu is ON: admin commands live in the Admin Menu window (Admin tab → Admin Menu)."))
	else
		to_chat(src, span_interface("New-Adm. menu is OFF: the classic admin tabs are back on the right panel. The Admin Menu button still works."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle New-Adm. Menu", "[use_new_menu ? "Enabled" : "Disabled"]"))
