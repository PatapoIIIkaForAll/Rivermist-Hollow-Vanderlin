/**
 * Admin right-click menu: three entries (Admin..., GM..., Debug...) instead of thirty.
 *
 * The admin verbs listed here are hidden from the right-click menu (set popup_menu = FALSE in
 * their own files) but stay real verbs: the command bar, hotkeys and the Admin Menu keep working.
 * Each entry lists only the actions that fit the clicked target and that the admin's rights grant,
 * then calls the original verb, so its own checks, confirmations and logging all still apply.
 * Toggle Classic Right-Click Menu (a saved preference) swaps the three entries for the classic list.
 */

/// group -> list of list(name, proc path, required target type). Order is the order shown.
/proc/admin_context_actions()
	var/static/list/actions = list(
		"Admin" = list(
			list("Show Player Panel", /datum/admins/proc/show_player_panel, /mob),
			list("Admin PM", /client/proc/cmd_admin_pm_context, /mob),
			list("Subtle Message", /client/proc/cmd_admin_subtle_message, /mob),
			list("Get Mob", /client/proc/cmd_get_mob, /mob),
			list("Heal Mob", /datum/admins/proc/admin_heal, /mob/living),
			list("Rejuvenate", /client/proc/cmd_admin_rejuvenate, /mob/living),
			list("Godmode", /client/proc/cmd_admin_godmode, /mob),
			list("Toggle Sleeping", /datum/admins/proc/admin_sleep, /mob/living),
			list("Check Contents", /client/proc/cmd_admin_check_contents, /mob/living),
			list("Drop Everything", /client/proc/cmd_admin_drop_everything, /mob),
			list("Send To Cryo", /client/proc/send_to_cryo, /mob),
			list("Delete", /client/proc/cmd_admin_delete, /atom),
		),
		"GM" = list(
			list("Direct Narrate", /client/proc/cmd_admin_direct_narrate, /mob),
			list("Local Narrate", /client/proc/cmd_admin_local_narrate, /atom),
			list("Force Speech", /client/proc/force_say, /mob/living),
			list("Send Messenger Bird Letter", /client/proc/send_bird_letter, /mob),
			list("Give Spell", /client/proc/give_spell, /mob),
			list("Remove Spell", /client/proc/remove_spell, /mob),
			list("Bless", /datum/admins/proc/admin_bless, /mob/living/carbon/human),
			list("Curse", /datum/admins/proc/admin_curse, /mob/living/carbon/human),
			list("Anoint New Priest", /datum/admins/proc/anoint_priest, /mob/living/carbon/human),
			list("Trigger Subclass Menu", /datum/admins/proc/prompt_subclass, /mob/living),
			list("Select Equipment", /client/proc/cmd_admin_dress, /mob),
			list("Make Simple Animal", /client/proc/cmd_admin_animalize, /mob),
			list("Assume Direct Control", /client/proc/cmd_assume_direct_control, /mob),
			list("Give Control To Player", /client/proc/cmd_give_control_to_player, /mob),
			list("Smite", /client/proc/smite, /mob/living),
			list("Heart Attack", /client/proc/heart_attack, /mob/living/carbon),
			list("Explosion", /client/proc/cmd_admin_explosion, /atom),
			list("Gib", /client/proc/cmd_admin_gib, /mob),
		),
		"Debug" = list(
			list("View Variables", /client/proc/debug_variables, /datum),
			list("Mark Object", /client/proc/mark_datum_mapview, /datum),
			list("Atom ProcCall", /client/proc/callproc_datum, /datum),
		),
	)
	return actions

/client/proc/context_menu_admin(atom/target as mob|obj|turf in view())
	set name = "Admin..."
	set category = null
	set desc = "Player and moderation actions on this target."
	open_admin_context_group("Admin", target)

/client/proc/context_menu_gm(atom/target as mob|obj|turf in view())
	set name = "GM..."
	set category = null
	set desc = "Storytelling and game master actions on this target."
	open_admin_context_group("GM", target)

/client/proc/context_menu_debug(atom/target as mob|obj|turf in view())
	set name = "Debug..."
	set category = null
	set desc = "View Variables, marking and proc calls on this target."
	open_admin_context_group("Debug", target)

/// The three grouped right-click entries. refresh_admin_context_verbs() grants them unless the admin chose the classic menu.
/proc/admin_context_menu_verbs()
	return list(/client/proc/context_menu_admin, /client/proc/context_menu_gm, /client/proc/context_menu_debug)

/// Verb path -> the type its target must have, for every action in admin_context_actions().
/proc/admin_context_target_types()
	var/static/list/target_types
	if(target_types)
		return target_types
	target_types = list()
	for(var/group in admin_context_actions())
		for(var/list/action as anything in admin_context_actions()[group])
			target_types[action[2]] = action[3]
	return target_types

/// Classic right-click menu ----------------------------------------------------------------------

// The admin verbs above are hidden from the right-click menu at compile time, so the classic menu
// is a second set of thin verbs, named classic_context_<proc name of the verb they run>.
#define CLASSIC_ADMIN_CONTEXT_VERB(real_proc_name, verb_name, target_decl, real_verb) \
/client/proc/classic_context_##real_proc_name(target_decl) { \
	set name = verb_name; \
	set category = null; \
	run_classic_admin_context_verb(real_verb, target); \
}

CLASSIC_ADMIN_CONTEXT_VERB(show_player_panel, "Show Player Panel", mob/target in view(), /datum/admins/proc/show_player_panel)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_pm_context, "Admin PM Mob", mob/target in view(), /client/proc/cmd_admin_pm_context)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_subtle_message, "Subtle Message", mob/target in view(), /client/proc/cmd_admin_subtle_message)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_get_mob, "Get Mob", mob/target in view(), /client/proc/cmd_get_mob)
CLASSIC_ADMIN_CONTEXT_VERB(admin_heal, "Heal Mob", mob/living/target in view(), /datum/admins/proc/admin_heal)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_rejuvenate, "Rejuvenate", mob/living/target in view(), /client/proc/cmd_admin_rejuvenate)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_godmode, "Godmode", mob/target in view(), /client/proc/cmd_admin_godmode)
CLASSIC_ADMIN_CONTEXT_VERB(admin_sleep, "Toggle Sleeping", mob/living/target in view(), /datum/admins/proc/admin_sleep)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_check_contents, "Check Contents", mob/living/target in view(), /client/proc/cmd_admin_check_contents)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_drop_everything, "Drop Everything", mob/target in view(), /client/proc/cmd_admin_drop_everything)
CLASSIC_ADMIN_CONTEXT_VERB(send_to_cryo, "Send To Cryo", mob/target in view(), /client/proc/send_to_cryo)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_delete, "Delete", atom/target as mob|obj|turf in view(), /client/proc/cmd_admin_delete)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_direct_narrate, "Direct Narrate", mob/target in view(), /client/proc/cmd_admin_direct_narrate)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_local_narrate, "Local Narrate", atom/target as mob|obj|turf in view(), /client/proc/cmd_admin_local_narrate)
CLASSIC_ADMIN_CONTEXT_VERB(force_say, "Force Speech", mob/living/target in view(), /client/proc/force_say)
CLASSIC_ADMIN_CONTEXT_VERB(send_bird_letter, "Send Messenger Bird Letter", mob/target in view(), /client/proc/send_bird_letter)
CLASSIC_ADMIN_CONTEXT_VERB(give_spell, "Give Spell", mob/target in view(), /client/proc/give_spell)
CLASSIC_ADMIN_CONTEXT_VERB(remove_spell, "Remove Spell", mob/target in view(), /client/proc/remove_spell)
CLASSIC_ADMIN_CONTEXT_VERB(admin_bless, "Bless", mob/living/carbon/human/target in view(), /datum/admins/proc/admin_bless)
CLASSIC_ADMIN_CONTEXT_VERB(admin_curse, "Curse", mob/living/carbon/human/target in view(), /datum/admins/proc/admin_curse)
CLASSIC_ADMIN_CONTEXT_VERB(anoint_priest, "Anoint New Priest", mob/living/carbon/human/target in view(), /datum/admins/proc/anoint_priest)
CLASSIC_ADMIN_CONTEXT_VERB(prompt_subclass, "Trigger Subclass Menu", mob/living/target in view(), /datum/admins/proc/prompt_subclass)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_dress, "Select Equipment", mob/target in view(), /client/proc/cmd_admin_dress)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_animalize, "Make Simple Animal", mob/target in view(), /client/proc/cmd_admin_animalize)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_assume_direct_control, "Assume direct control", mob/target in view(), /client/proc/cmd_assume_direct_control)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_give_control_to_player, "Give Control To Player", mob/target in view(), /client/proc/cmd_give_control_to_player)
CLASSIC_ADMIN_CONTEXT_VERB(smite, "Smite", mob/living/target in view(), /client/proc/smite)
CLASSIC_ADMIN_CONTEXT_VERB(heart_attack, "Heart Attack", mob/living/carbon/target in view(), /client/proc/heart_attack)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_explosion, "Explosion", atom/target as mob|obj|turf in view(), /client/proc/cmd_admin_explosion)
CLASSIC_ADMIN_CONTEXT_VERB(cmd_admin_gib, "Gib", mob/target in view(), /client/proc/cmd_admin_gib)
CLASSIC_ADMIN_CONTEXT_VERB(debug_variables, "View Variables", atom/target as mob|obj|turf in view(), /client/proc/debug_variables)
CLASSIC_ADMIN_CONTEXT_VERB(mark_datum_mapview, "Mark Object", atom/target as mob|obj|turf in view(), /client/proc/mark_datum_mapview)
CLASSIC_ADMIN_CONTEXT_VERB(callproc_datum, "Atom ProcCall", atom/target as mob|obj|turf in view(), /client/proc/callproc_datum)

#undef CLASSIC_ADMIN_CONTEXT_VERB

/// Wrapper verb path -> the admin verb it runs, built from admin_context_actions().
/proc/classic_admin_context_verbs()
	var/static/list/wrappers
	if(wrappers)
		return wrappers
	wrappers = list()
	for(var/group in admin_context_actions())
		for(var/list/action as anything in admin_context_actions()[group])
			var/path_text = "[action[2]]"
			var/wrapper = text2path("/client/proc/classic_context_[copytext(path_text, findlasttext(path_text, "/") + 1)]")
			if(!wrapper)
				stack_trace("No classic right-click verb for [path_text].")
				continue
			wrappers[wrapper] = action[2]
	return wrappers

/// Runs one classic right-click entry, with the same checks as the grouped entries.
/client/proc/run_classic_admin_context_verb(verb_path, atom/target)
	if(!holder || QDELETED(target) || !istype(target, admin_context_target_types()[verb_path]))
		return
	if(!(verb_path in verbs))
		to_chat(src, span_warning("You do not have that command right now."))
		return
	run_admin_target_verb(verb_path, target)

/// Persistent, per-admin choice between the grouped right-click entries and the classic list.
/datum/preference/toggle/admin_classic_context_menu
	savefile_key = "admin_classic_context_menu"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Admin"
	toggles_menu_name = "Classic right-click menu"
	toggles_menu_desc = "List admin right-click actions one by one instead of under Admin..., GM... and Debug..."
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/datum/preference/toggle/admin_classic_context_menu/is_accessible(datum/preferences/prefs)
	. = ..()
	if(!.)
		return
	return !!prefs?.parent?.holder

/client/proc/uses_classic_context_menu()
	return !!prefs?.read_preference(/datum/preference/toggle/admin_classic_context_menu)

/// Grants the right-click entries of the chosen style. Call after the admin's other verbs are granted.
/client/proc/refresh_admin_context_verbs()
	var/list/wrappers = classic_admin_context_verbs()
	remove_verb(src, admin_context_menu_verbs() + wrappers)
	if(!holder)
		return
	if(!uses_classic_context_menu())
		add_verb(src, admin_context_menu_verbs())
		return
	var/list/granted = list()
	for(var/wrapper in wrappers)
		if(wrappers[wrapper] in verbs) // only the actions this admin's rights grant
			granted += wrapper
	add_verb(src, granted)

/client/proc/toggle_admin_context_menu_mode()
	set name = "Toggle Classic Right-Click Menu"
	set category = "Preferences.Admin"
	set desc = "Switch the admin right-click entries between Admin... / GM... / Debug... and the classic list."

	if(!holder || !prefs)
		return
	var/classic = !uses_classic_context_menu()
	prefs.write_preference(/datum/preference/toggle/admin_classic_context_menu, classic)
	prefs.save_preferences()
	refresh_admin_context_verbs()
	if(classic)
		to_chat(src, span_interface("Classic right-click menu is ON: admin actions are listed one by one again."))
	else
		to_chat(src, span_interface("Classic right-click menu is OFF: admin actions are under Admin..., GM... and Debug..."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Classic Right-Click Menu", "[classic ? "Enabled" : "Disabled"]"))

/// Lists the actions of one group that fit target and that this admin holds, then runs the pick.
/client/proc/open_admin_context_group(group, atom/target)
	if(!holder || QDELETED(target))
		return
	var/list/choices = list()
	for(var/list/action as anything in admin_context_actions()[group])
		var/verb_path = action[2]
		if(!istype(target, action[3]) || !(verb_path in verbs))
			continue
		choices[action[1]] = verb_path
	if(!length(choices))
		to_chat(src, span_warning("You have no [group] actions for [target]."))
		return
	var/picked = tgui_input_list(usr, "[target] ([target.type])", "[group]: [target]", choices)
	if(!picked || !holder || QDELETED(target))
		return
	var/verb_path = choices[picked]
	// Rights may have changed while the list was open.
	if(!(verb_path in verbs))
		return
	run_admin_target_verb(verb_path, target)

/// Calls an admin verb on target directly, asking for any extra argument the verb needs.
/client/proc/run_admin_target_verb(verb_path, atom/target)
	if(!holder || QDELETED(target) || !(verb_path in verbs))
		return
	var/list/arguments = list(target)
	if(verb_path == /client/proc/cmd_give_control_to_player)
		var/list/players = list()
		for(var/client/candidate as anything in GLOB.clients)
			players[candidate.key] = candidate
		var/player_key = tgui_input_list(usr, "Who takes control of [target]?", "Give Control To Player", sortList(players))
		var/client/player = players[player_key]
		if(!player || QDELETED(target))
			return
		arguments += player
	// ispath() does not work on proc paths: tell /datum/admins verbs apart by their path text.
	var/datum/verb_owner = findtext("[verb_path]", "/datum/admins/proc/") == 1 ? holder : src
	call(verb_owner, verb_path)(arglist(arguments))

/// Verb path -> mob type it targets, for the admin verbs that take a mob argument.
/proc/admin_mob_target_verbs()
	var/static/list/mob_verbs
	if(mob_verbs)
		return mob_verbs
	mob_verbs = list()
	for(var/group in admin_context_actions())
		for(var/list/action as anything in admin_context_actions()[group])
			if(ispath(action[3], /mob))
				mob_verbs[action[2]] = action[3]
	return mob_verbs

/**
 * Runs a mob-targeting verb from the Admin Menu: the mob comes from the Players / Nearby / All
 * picker instead of BYOND's list of every mob in the world.
 */
/client/proc/run_admin_mob_verb(verb_path)
	set waitfor = FALSE
	var/required_type = admin_mob_target_verbs()[verb_path]
	if(!required_type || !holder)
		return
	var/procpath/verb_ref = verb_path
	var/mob/target = admin_pick_mob(src, verb_ref.name)
	if(!target)
		return
	if(!istype(target, required_type))
		to_chat(src, span_warning("[verb_ref.name] cannot be used on [target]."))
		return
	run_admin_target_verb(verb_path, target)
