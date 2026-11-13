/mob/living/carbon/human/say_mod(input, list/message_mods = list())
	verb_say = dna.species.say_mod
	if(slurring || aroused_slurring)
		return "slurs"
	else
		. = ..()

/mob/living/carbon/human/GetVoice()
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return name

/mob/living/carbon/human/IsVocal()
	// how do species that don't breathe talk? magic, that's what.
	if(!HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT) && !getorganslot(ORGAN_SLOT_LUNGS))
		return FALSE
	if(mind)
		return !mind.miming
	return TRUE

/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/// The voice name strangers hear when the face does not match the voice; force skips that check.
/mob/living/carbon/human/get_alt_name(force = FALSE)
	if(!force && get_face_name("") == GetVoice())
		return
	return get_voice_descriptor_name()

/// "Deep-voiced Woman": the voice descriptor and the voice gender, or "Unknown Woman" without one.
/mob/living/carbon/human/proc/get_voice_descriptor_name()
	var/voice_gender = "Figure"
	switch(voice_type)
		if(VOICE_TYPE_FEM)
			voice_gender = "Woman"
		if(VOICE_TYPE_MASC)
			voice_gender = "Man"
		if(null)
			if(gender == FEMALE)
				voice_gender = "Woman"
			else if(gender == MALE)
				voice_gender = "Man"
	var/voice_word = get_descriptor_word(MOB_DESCRIPTOR_SLOT_VOICE)
	if(!voice_word)
		return "Unknown [voice_gender]"
	return "[voice_word]-voiced [voice_gender]"

/mob/living/carbon/human/proc/forcesay(list/append) //this proc is at the bottom of the file because quote fuckery makes notepad++ cri
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtextEx(temp, "Say \"", 1, 7) && length(temp) > 5)	//"case sensitive means

				temp = replacetext(temp, ";", "")	//general radio

				if(findtext(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext_char(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext_char(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext_char(trim_left(temp), 3)

				if(findtext(temp, "*", 1, 2))	//emotes
					return

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")

/mob/living/carbon/human/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, list/message_mods = list(), original_message)
	. = ..()
	send_voice(message, message_mods)
	queue_speech_barks(message, message_range, message_mods)

/mob/living/carbon/human/proc/send_voice(message, list/message_mods)
	if(!length(message))
		return
	dna?.species?.send_voice(src, message, message_mods)

/datum/species/proc/send_voice(mob/living/carbon/human/H, message, list/message_mods)
	if(!H)
		return

	//If high arousal - moan, for speakers who turned it on
	if(H.should_speech_moan())
		H.emote(H.can_speak() ? "sexmoanlight" : "sexmoangag", intentional = FALSE)
		return
	// --------------------------


	// Whisper
	if(message_mods[WHISPER_MODE])
		playsound(H, 'sound/vo/psst.ogg', 20, FALSE, -1, ignore_walls = FALSE)
		return
	// Singing
	if(message_mods[MODE_SING])
		H.emote("hum", intentional = FALSE)
		return
	// Speech
	switch(say_test(message))
		if("1") // ?
			if(prob(30))
				switch(H.voice_type)
					if(VOICE_TYPE_MASC)
						playsound(H, pick(list('sound/vo/male/gen/huh (1).ogg','sound/vo/male/gen/huh (2).ogg','sound/vo/male/gen/huh (3).ogg')), 100, FALSE, -1, ignore_walls = FALSE)
						return
					else
						playsound(H, pick(list('sound/vo/female/gen/huh (1).ogg','sound/vo/female/gen/huh (2).ogg','sound/vo/female/gen/huh (3).ogg')), 100, FALSE, -1, ignore_walls = FALSE)
						return
			else
				playsound(H, 'sound/misc/talk.ogg', 100, FALSE, -1, ignore_walls = FALSE)
				return
		if("2") // !
			if(prob(30))
				switch(H.voice_type)
					if(VOICE_TYPE_MASC)
						playsound(H, 'modular_rmh/sound/vo/speech/mexclaim.ogg', 100, FALSE, -1, ignore_walls = FALSE)
						return
					else
						playsound(H, 'modular_rmh/sound/vo/speech/fexclaim.ogg', 100, FALSE, -1, ignore_walls = FALSE)
						return
			else
				playsound(H, 'sound/misc/talk.ogg', 100, FALSE, -1, ignore_walls = FALSE)
				return
		if("3") // !!
			playsound(H, 'sound/misc/talk.ogg', 100, FALSE, -1, ignore_walls = FALSE)
		else
			if(prob(30))
				switch(H.voice_type)
					if(VOICE_TYPE_MASC)
						playsound(H, 'modular_rmh/sound/vo/speech/mtalk.ogg', 100, FALSE, -1, ignore_walls = FALSE)
						return
					else
						playsound(H, 'modular_rmh/sound/vo/speech/ftalk.ogg', 100, FALSE, -1, ignore_walls = FALSE)
						return
			else
				playsound(H, 'sound/misc/talk.ogg', 100, FALSE, -1, ignore_walls = FALSE)
				return
