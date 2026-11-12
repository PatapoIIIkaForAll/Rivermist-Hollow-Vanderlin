// Speech barks: short voice blips played while a character speaks. Speaker picks the sound, listeners opt in.

/// Message length per bark is speed divided by this; keeps total bark time steady across speeds.
#define SPEECH_BARK_SPEED_BASELINE 4
/// Most barks one message can queue.
#define SPEECH_BARK_MAX_BARKS 128
/// Barks stop being queued after this delay.
#define SPEECH_BARK_MAX_TIME (10 SECONDS)
/// Bark volume before the listener's master volume.
#define SPEECH_BARK_VOLUME 70
/// Arousal at which speech turns into a light moan for speakers who allow it.
#define SPEECH_MOAN_AROUSAL 40

/datum/speech_bark
	var/name = "Default"
	var/soundpath
	var/minpitch = 0.6
	var/maxpitch = 1.4
	var/minvariance = 0.1
	var/maxvariance = 0.4
	/// Speed is message letters per bark; lower is denser.
	var/minspeed = 2
	var/maxspeed = 8

/datum/speech_bark/muted_low
	name = "Muted String (Low)"
	soundpath = 'sound/vo/barks/misc/guitar_crisis_muted/C2.ogg'

/datum/speech_bark/muted_medium
	name = "Muted String (Medium)"
	soundpath = 'sound/vo/barks/misc/guitar_crisis_muted/C3.ogg'

/datum/speech_bark/muted_high
	name = "Muted String (High)"
	soundpath = 'sound/vo/barks/misc/guitar_crisis_muted/C4.ogg'

/datum/speech_bark/banjo_medium
	name = "Banjo (Medium)"
	soundpath = 'sound/vo/barks/misc/banjo/Cn3.ogg'

/datum/speech_bark/banjo_high
	name = "Banjo (High)"
	soundpath = 'sound/vo/barks/misc/banjo/Cn4.ogg'

/datum/speech_bark/squeaky
	name = "Squeaky"
	soundpath = 'sound/vo/barks/misc/toysqueak1.ogg'
	maxspeed = 4

/datum/speech_bark/chitter
	name = "Chittery"
	soundpath = 'sound/vo/barks/chitter.ogg'
	minspeed = 4

/datum/speech_bark/chitter/alt
	name = "Chittery Alt"
	soundpath = 'sound/vo/barks/moth/mothchitter2.ogg'

/datum/speech_bark/windy
	name = "Windy"
	soundpath = 'sound/vo/barks/bulletflyby.ogg'
	maxpitch = 1.6

/datum/speech_bark/brassy
	name = "Brassy"
	soundpath = 'sound/vo/barks/integration_cog_install.ogg'

/datum/speech_bark/moth_squeak
	name = "Moth Squeak"
	soundpath = 'sound/vo/barks/mothsqueak.ogg'

/datum/speech_bark/meow
	name = "Meow"
	soundpath = 'sound/vo/barks/meow1.ogg'
	minspeed = 5
	maxspeed = 11

/datum/speech_bark/chirp
	name = "Chirp"
	soundpath = 'sound/vo/barks/chirp.ogg'

/datum/speech_bark/caw
	name = "Caw"
	soundpath = 'sound/vo/barks/caw.ogg'

/datum/speech_bark/hiss
	name = "Hiss"
	soundpath = 'sound/vo/barks/Xenohiss.ogg'
	minspeed = 10
	maxspeed = 16

/// Bark name to its shared datum.
GLOBAL_LIST_INIT(speech_barks, init_speech_barks())

/proc/init_speech_barks()
	. = list()
	for(var/bark_type in subtypesof(/datum/speech_bark))
		var/datum/speech_bark/bark = new bark_type()
		.[bark.name] = bark

/mob/living/carbon/human
	/// Bark name from GLOB.speech_barks, or null for no barks.
	var/speech_bark
	var/speech_bark_speed = 4
	var/speech_bark_pitch = 1
	var/speech_bark_variance = 0.2
	/// world.time of the newest queued message; older queued barks stop when it changes.
	var/speech_bark_queue
	/// Whether high arousal turns this character's speech into moans.
	var/speech_moans = FALSE

/// Whether this speech should bark: a bark is set, the words are not whispered and the mouth is not muffled.
/mob/living/carbon/human/proc/can_speech_bark(list/message_mods)
	if(!speech_bark || !GLOB.speech_barks[speech_bark])
		return FALSE
	if(message_mods && message_mods[WHISPER_MODE])
		return FALSE
	// A gagged mumble keeps the voice hidden, so no bark.
	if(is_speech_muffled())
		return FALSE
	return TRUE

/// Whether high arousal turns this speech into a moan.
/mob/living/carbon/human/proc/should_speech_moan()
	if(!speech_moans)
		return FALSE
	var/datum/component/arousal/arousal = GetComponent(/datum/component/arousal)
	return arousal?.arousal >= SPEECH_MOAN_AROUSAL

/// Whether this listener wants to hear speech barks.
/proc/client_hears_speech_barks(client/listener)
	return !!listener?.prefs?.read_preference(/datum/preference/toggle/hear_speech_barks)

/// Number of barks for a message: one per speed letters, plus one, capped.
/proc/speech_bark_count(message_length, speed)
	return min(round(message_length / max(speed, 1)) + 1, SPEECH_BARK_MAX_BARKS)

/// Queues the barks for one message to every listener in range who opted in.
/mob/living/carbon/human/proc/queue_speech_barks(message, message_range, list/message_mods)
	if(!length(message) || !can_speech_bark(message_mods))
		return
	var/datum/speech_bark/bark = GLOB.speech_barks[speech_bark]
	var/list/listeners = list()
	for(var/mob/hearer in get_hearers_in_view(message_range, src))
		if(client_hears_speech_barks(hearer.client))
			listeners += hearer.client
	if(!length(listeners))
		return
	var/speed = clamp(speech_bark_speed, bark.minspeed, bark.maxspeed)
	var/pitch = clamp(speech_bark_pitch, bark.minpitch, bark.maxpitch)
	var/variance = clamp(speech_bark_variance, bark.minvariance, bark.maxvariance)
	var/gap = DS2TICKS(speed / SPEECH_BARK_SPEED_BASELINE)
	var/total_delay = 0
	speech_bark_queue = world.time
	for(var/i in 1 to speech_bark_count(length(message), speed))
		if(total_delay > SPEECH_BARK_MAX_TIME)
			break
		var/bark_pitch = rand(pitch * 100 - variance * 50, pitch * 100 + variance * 50) / 100
		addtimer(CALLBACK(src, PROC_REF(play_speech_bark), listeners, bark.soundpath, bark_pitch, message_range, speech_bark_queue), total_delay)
		total_delay += rand(gap, gap * 2) TICKS

/// Plays one bark to the stored listeners unless a newer message replaced the queue.
/mob/living/carbon/human/proc/play_speech_bark(list/listeners, soundpath, pitch, message_range, queue_id)
	if(queue_id != speech_bark_queue)
		return
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return
	for(var/client/listener as anything in listeners)
		listener?.mob?.playsound_local(source_turf, soundpath, SPEECH_BARK_VOLUME, FALSE, pitch, max_distance = message_range + 2)

/client/verb/toggle_hear_speech_barks()
	set category = "Preferences.Sound"
	set name = "Hear Speech Barks"
	if(!prefs)
		return
	prefs.toggle_preference(/datum/preference/toggle/hear_speech_barks)
	prefs.save_preferences()
	to_chat(src, span_notice("You will [prefs.read_preference(/datum/preference/toggle/hear_speech_barks) ? "now" : "no longer"] hear other characters' speech barks."))

/client/verb/set_speech_bark()
	set category = "Preferences.Sound"
	set name = "Speech Bark"
	if(!prefs)
		return
	var/list/choices = list(SPEECH_BARK_NONE)
	for(var/bark_name in GLOB.speech_barks)
		choices += bark_name
	var/current = prefs.read_preference(/datum/preference/choiced/speech_bark)
	var/picked = tgui_input_list(src, "Pick the blip your character makes while speaking. Others hear it only if they turn on Hear Speech Barks.", "Speech Bark", choices, current)
	if(!picked)
		return
	prefs.write_preference(/datum/preference/choiced/speech_bark, picked)
	var/datum/speech_bark/bark = GLOB.speech_barks[picked]
	if(bark)
		var/speed = tgui_input_number(src, "Letters per bark, [bark.minspeed] to [bark.maxspeed]. Lower is faster.", "Bark Speed", prefs.read_preference(/datum/preference/numeric/speech_bark_speed), bark.maxspeed, bark.minspeed)
		if(!isnull(speed))
			prefs.write_preference(/datum/preference/numeric/speech_bark_speed, speed)
		var/pitch = tgui_input_number(src, "Pitch, [bark.minpitch] to [bark.maxpitch].", "Bark Pitch", prefs.read_preference(/datum/preference/numeric/speech_bark_pitch), bark.maxpitch, bark.minpitch, round_value = FALSE)
		if(!isnull(pitch))
			prefs.write_preference(/datum/preference/numeric/speech_bark_pitch, pitch)
		var/variance = tgui_input_number(src, "Pitch variance per bark, [bark.minvariance] to [bark.maxvariance].", "Bark Variance", prefs.read_preference(/datum/preference/numeric/speech_bark_variance), bark.maxvariance, bark.minvariance, round_value = FALSE)
		if(!isnull(variance))
			prefs.write_preference(/datum/preference/numeric/speech_bark_variance, variance)
	prefs.save_character()
	if(ishuman(mob))
		var/mob/living/carbon/human/speaker = mob
		speaker.speech_bark = bark ? picked : null
		speaker.speech_bark_speed = prefs.read_preference(/datum/preference/numeric/speech_bark_speed)
		speaker.speech_bark_pitch = prefs.read_preference(/datum/preference/numeric/speech_bark_pitch)
		speaker.speech_bark_variance = prefs.read_preference(/datum/preference/numeric/speech_bark_variance)
	if(bark)
		mob?.playsound_local(get_turf(mob), bark.soundpath, SPEECH_BARK_VOLUME, FALSE, clamp(prefs.read_preference(/datum/preference/numeric/speech_bark_pitch), bark.minpitch, bark.maxpitch))
		to_chat(src, span_notice("Your character now speaks with the [bark.name] bark."))
	else
		to_chat(src, span_notice("Your character no longer barks while speaking."))

/client/verb/toggle_speech_moans()
	set category = "Preferences.Options"
	set name = "Moan While Speaking"
	if(!prefs)
		return
	prefs.toggle_preference(/datum/preference/toggle/speech_moans)
	prefs.save_character()
	var/enabled = prefs.read_preference(/datum/preference/toggle/speech_moans)
	if(ishuman(mob))
		var/mob/living/carbon/human/speaker = mob
		speaker.speech_moans = enabled
	to_chat(src, span_notice("At high arousal your character will [enabled ? "now" : "no longer"] moan instead of making speech sounds."))

#undef SPEECH_BARK_SPEED_BASELINE
#undef SPEECH_BARK_MAX_BARKS
#undef SPEECH_BARK_MAX_TIME
#undef SPEECH_BARK_VOLUME
#undef SPEECH_MOAN_AROUSAL
