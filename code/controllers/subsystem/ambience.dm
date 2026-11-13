// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	var/list/client_old_areas = list()
	///Cache for sanic speed :D
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(length(cached_clients))
		var/client/client_iterator = cached_clients[length(cached_clients)]
		cached_clients.len--
		//Check to see if the client exists and isn't held by a new player
		var/mob/client_mob = client_iterator?.mob
		if(isnull(client_iterator) || !client_mob ||isnewplayer(client_mob))
			ambience_listening_clients -= client_iterator
			client_old_areas -= client_iterator
			continue

		if(!client_mob.can_hear()) //WHAT? I CAN'T HEAR YOU
			continue

		//Check to see if the client-mob is in a valid area
		var/area/current_area = get_area(client_mob)
		if(!current_area) //Something's gone horribly wrong
			stack_trace("[key_name(client_mob)] has somehow ended up in nullspace. WTF did you do")
			remove_ambience_client(client_iterator)
			continue

		if(ambience_listening_clients[client_iterator] > world.time)
			if(!(current_area.forced_ambience && (client_old_areas?[client_iterator] != current_area) && prob(5)))
				continue

		//Run play_ambience() on the client-mob and set a cooldown
		ambience_listening_clients[client_iterator] = world.time + current_area.play_ambience(client_mob)

		//We REALLY don't want runtimes in SSambience
		if(client_iterator)
			client_old_areas[client_iterator] = current_area

		if(MC_TICK_CHECK)
			return

///Attempts to play an ambient sound to a mob, returning the cooldown in deciseconds
/area/proc/play_ambience(mob/M, sound/override_sound, volume = 50)
	var/sound_source
	var/spooky_sounds = ambientsounds
	if(override_sound)
		sound_source = override_sound
	else
		if(ambientnight && GLOB.tod == "night")
			spooky_sounds = ambientnight
		if(islist(spooky_sounds))
			if(length(spooky_sounds))
				sound_source = pick(spooky_sounds)
		else
			sound_source = spooky_sounds

	if(!sound_source)
		return

	var/sound/new_sound = sound(sound_source, repeat = 0, wait = 0, volume = volume, channel = CHANNEL_AMBIENCE)
	if(!new_sound?.file)
		stack_trace("[type] ([name]) tried to play invalid ambience source [sound_source].")
		return rand(min_ambience_cooldown, max_ambience_cooldown)
	SEND_SOUND(M, new_sound)

	var/sound_length = SSsounds.get_sound_length(new_sound.file)
	return sound_length + rand(min_ambience_cooldown, max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	client_old_areas -= to_remove
	currentrun -= to_remove

/**
 * Ambience buzz handling called by either area/Enter() or refresh_looping_ambience()
 */
/mob/proc/update_ambience_area(area/new_area)
	var/old_tracked_area = ambience_tracked_area

	if(old_tracked_area)
		ambience_tracked_area = null
	if(!client)
		return
	if(new_area)
		ambience_tracked_area = new_area

	refresh_looping_ambience()

/// Get the buzz that should play in accordance with the time
/area/proc/get_current_buzz(is_lit)
	var/time = GLOB.tod
	var/used = background_track
	if(is_lit)
		if(time == "night" && background_track_night)
			used = background_track_night
		else if (time == "dusk" && background_track_dusk)
			used = background_track_dusk
		else if (time == "dawn" && background_track_dawn)
			used = background_track_dawn
	else if(uses_alt_droning)
		used = safepick(alternative_droning)
		if(time == "night" && length(alternative_droning_night))
			used = pick(alternative_droning_night)

	return used

/// Tries to play looping ambience to the mob
/mob/proc/refresh_looping_ambience(sound/buzz_to_use)
	if(!client || isobserver(client.mob))
		return

	var/datum/component/theme_music/theme_music = src.GetComponent(/datum/component/theme_music)

	if(!can_hear() || theme_music?.music_enabled)
		cancel_looping_ambience()
		return

	var/music_enabled = client.prefs?.read_preference(/datum/preference/bitwise/toggles) & SOUND_SHIP_AMBIENCE
	var/area/my_area = get_area(src)
	var/vol = client.prefs?.read_preference(/datum/preference/numeric/musicvol)
	var/used = buzz_to_use

	if(!used && music_enabled)
		used = my_area?.get_current_buzz(has_light_nearby())
		if(!used || islist(used))
			return
	if(cmode && cmode_music)
		if(length(cmode_music_override))
			used = pick(cmode_music_override)
		else
			used = cmode_music
		vol *= 1.2
	else if(music_enabled && HAS_TRAIT(src, TRAIT_SCHIZO_AMBIENCE))
		used = 'sound/music/dreamer_is_still_asleep.ogg'
	else if(music_enabled && HAS_TRAIT(src, TRAIT_DRUQK))
		used = 'sound/music/spice.ogg'

	if(!used || vol <= 0)
		cancel_looping_ambience()
		return

	if(used == client.current_ambient_sound)
		return

	client.current_ambient_sound = used
	var/sound/buzz = sound(used, repeat = 1, wait = 0, volume = vol, channel = CHANNEL_BUZZ)
	buzz.status = SOUND_STREAM
	SEND_SOUND(src, buzz)

/mob/proc/cancel_looping_ambience()
	if(!client)
		return
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_BUZZ))
	client.current_ambient_sound = null

/mob/proc/test_area_sounds()
	for(var/area/area as anything in subtypesof(/area))
		if(!initial(area.background_track))
			continue
		to_chat(src, initial(area.name))
		refresh_looping_ambience(initial(area.background_track))
		sleep(0.2 SECONDS)
		if(!client)
			world << "Crashed at [initial(area.name)]"

	for(var/area/area as anything in subtypesof(/area))
		if(!initial(area.background_track_dusk))
			continue
		to_chat(src, initial(area.name))
		refresh_looping_ambience(initial(area.background_track_dusk))
		sleep(0.2 SECONDS)
		if(!client)
			world << "Crashed at [initial(area.name)] dusk"

	for(var/area/area as anything in subtypesof(/area))
		if(!initial(area.background_track_night))
			continue
		to_chat(src, initial(area.name))
		refresh_looping_ambience(initial(area.background_track_night))
		sleep(0.2 SECONDS)
		if(!client)
			world << "Crashed at [initial(area.name)] night"

/datum/controller/subsystem/ambience/proc/play_combat_music(music = null, client/dreamer)
	if(!music || !dreamer)
		return

	var/frenq = 1

	if(HAS_TRAIT(dreamer.mob, TRAIT_DRUQK))
		frenq = -1

	if(ishuman(dreamer.mob))
		var/mob/living/carbon/human/H = dreamer.mob
		if(H.has_status_effect(/datum/status_effect/buff/moondust))
			frenq = 2
		if(H.has_status_effect(/datum/status_effect/buff/weed))
			frenq = 0.5

	var/mob/living/L = dreamer.mob
	//kill the previous droning sound
	L.cancel_looping_ambience()
	var/music_volume = dreamer?.prefs?.read_preference(/datum/preference/numeric/musicvol) || 0
	var/sound/combat_music = sound(pick(music), repeat = TRUE, wait = 0, channel = CHANNEL_BUZZ, volume = music_volume * 1.2)
	combat_music.frequency = frenq
	if(!HAS_TRAIT(dreamer.mob, TRAIT_DRUQK))
		combat_music.pitch = 1 / combat_music.frequency
	SEND_SOUND(dreamer, combat_music)
	dreamer.current_ambient_sound = combat_music
