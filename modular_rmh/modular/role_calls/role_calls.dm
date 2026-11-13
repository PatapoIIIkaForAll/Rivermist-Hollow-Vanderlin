/// Lets lobby players and ghosts answer ghost-role polls; the lobby "CALLS" button flips it.
/datum/preference/toggle/role_calls
	savefile_key = "role_calls"
	savefile_identifier = PREF_PLAYER
	category = "ghost"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/datum/preferences/proc/accepts_role_calls()
	return !!read_preference(/datum/preference/toggle/role_calls)

/// Whether these account settings let a lobby player receive ghost-role polls.
/datum/preferences/proc/accepts_lobby_role_calls()
	if(!defeat_introduction_complete || is_active_migrant())
		return FALSE
	return accepts_role_calls()

/// Flips the toggle, saves it and explains the new state to the user.
/datum/preferences/proc/toggle_role_calls(mob/user)
	var/enabled_calls = !accepts_role_calls()
	update_preference(/datum/preference/toggle/role_calls, enabled_calls)
	save_preferences()
	if(enabled_calls)
		to_chat(user, span_notice("You will be asked when a ghost role needs a player, while you wait in the lobby or spectate."))
	else
		to_chat(user, span_notice("You will no longer be asked to take ghost roles."))
	return enabled_calls

/// Whether this lobby player should be offered ghost roles right now.
/mob/dead/new_player/proc/can_answer_role_poll()
	if(!client?.prefs || spawning || QDELETED(src))
		return FALSE
	if(!SSticker.IsRoundInProgress())
		return FALSE
	return client.prefs.accepts_lobby_role_calls()

/// Call on a poll pick right before its key moves to the new body.
/mob/proc/leave_lobby_for_role()
	return

/mob/dead/new_player/leave_lobby_for_role()
	close_spawn_windows()
	stop_sound_channel(CHANNEL_LOBBYMUSIC)

/mob/dead/observer/verb/toggle_role_calls()
	set category = "Spirit"
	set name = "Toggle Ghost-Role Calls"
	client?.prefs?.toggle_role_calls(src)

/atom/movable/screen/lobby/button/role_calls
	name = "Ghost-Role Calls"
	screen_loc = "WEST:20,TOP:-101"
	icon = 'modular_rmh/icons/hud/lobby_role_calls.dmi'
	icon_state = "role_calls_on"
	base_icon_state = "role_calls_on"

/atom/movable/screen/lobby/button/role_calls/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	sync_to_preference()

/atom/movable/screen/lobby/button/role_calls/proc/sync_to_preference()
	var/enabled_calls = hud?.mymob?.client?.prefs?.accepts_role_calls()
	base_icon_state = enabled_calls ? "role_calls_on" : "role_calls_off"
	name = "Ghost-Role Calls: [enabled_calls ? "On" : "Off"]"
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/role_calls/Click(location, control, params)
	. = ..()
	if(!.)
		return
	hud.mymob.client?.prefs?.toggle_role_calls(hud.mymob)
	sync_to_preference()

/// Lets lobby players spectate as observers; set LOBBY_SPECTATE 0 in config to hide the button.
/datum/config_entry/flag/lobby_spectate
	config_entry_value = TRUE

/// ckey -> world.time when a player who spectated may join the round again.
GLOBAL_LIST_EMPTY(spectate_rejoin_times)

/// Minutes a spectator waits after returning to the lobby before joining; 0 disables the wait.
/datum/config_entry/number/spectate_rejoin_delay
	config_entry_value = 5
	min_val = 0

/proc/get_spectate_rejoin_delay()
	return CONFIG_GET(number/spectate_rejoin_delay) MINUTES

/// Warning shown in the spectate confirmation; admins skip the wait.
/proc/get_spectate_rejoin_warning(client/player)
	if(player?.holder || !get_spectate_rejoin_delay())
		return ""
	return " After you return, you must wait [DisplayTimeText(get_spectate_rejoin_delay())] before you can join the round."

/proc/note_spectate_rejoin(ckey)
	GLOB.spectate_rejoin_times[ckey] = world.time + get_spectate_rejoin_delay()

/// Starts the rejoin wait when a lobby spectator goes back to the lobby.
/mob/dead/observer/proc/start_spectate_rejoin_delay()
	if(started_as_observer && ckey)
		note_spectate_rejoin(ckey)

/// Deciseconds this ckey must still wait before joining the round.
/proc/get_spectate_rejoin_wait_for(ckey)
	return max(0, GLOB.spectate_rejoin_times[ckey] - world.time)

/// Deciseconds this client must still wait before joining; admins never wait.
/proc/get_spectate_rejoin_wait(client/player)
	if(!player || player.holder)
		return 0
	return get_spectate_rejoin_wait_for(player.ckey)

/// Tells the player and returns TRUE while their spectate rejoin wait is running.
/proc/spectate_rejoin_blocked(client/player)
	var/wait = get_spectate_rejoin_wait(player)
	if(!wait)
		return FALSE
	to_chat(player, span_warning("You spectated this round. You can join in [DisplayTimeText(wait)]."))
	return TRUE

/// Watch the round as an observer; shown once the game is setting up, like Join.
/atom/movable/screen/lobby/button/spectate
	name = "Spectate"
	screen_loc = "WEST:20,TOP:-233"
	icon = 'modular_rmh/icons/hud/lobby_spectate.dmi'
	icon_state = "spectate_disabled"
	base_icon_state = "spectate"
	enabled = FALSE

/atom/movable/screen/lobby/button/spectate/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(enable_spectate))
		if(GAME_STATE_SETTING_UP)
			set_button_status(TRUE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(disable_spectate))
		else
			set_button_status(TRUE)

/atom/movable/screen/lobby/button/spectate/proc/enable_spectate()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(disable_spectate))

/atom/movable/screen/lobby/button/spectate/proc/disable_spectate()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(enable_spectate))

/atom/movable/screen/lobby/button/spectate/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	if(!istype(new_player))
		return
	if(!CONFIG_GET(flag/lobby_spectate))
		to_chat(new_player, span_warning("Spectating is disabled on this server."))
		return
	if(!SSticker.IsRoundInProgress())
		to_chat(new_player, span_warning("You can spectate once the round has begun."))
		return
	if(new_player.client?.prefs?.is_active_migrant())
		to_chat(new_player, span_boldwarning("You are in the migrant queue."))
		return
	new_player.make_me_an_observer()
