/datum/emote
	var/key = "" //What calls the emote
	var/key_third_person = "" //This will also call the emote
	var/message = "" //Message displayed when emote is used
	var/message_mime = "" //Message displayed if the user is a mime
	var/message_monkey = "" //Message displayed if the user is a monkey
	var/message_simple = "" //Message to display if the user is a simple_animal
	var/message_param = "" //Message to display if a param was given
	var/message_muffled = null //Message to display if the user is muffled
	var/emote_type = EMOTE_VISIBLE //Whether the emote is visible or audible
	/// Checks if the mob is restrained before performing the emote
	var/restraint_check = FALSE
	/// Checks if the mob can use its hands before performing the emote.
	var/hands_use_check = FALSE
	/// Checks if the mob is not incapacitated before performing the emote.
	var/incapacitated_check = FALSE
	var/muzzle_ignore = FALSE //Will only work if the emote is EMOTE_AUDIBLE
	var/list/mob_type_allowed_typecache = /mob //Types that are allowed to use that emote
	var/list/mob_type_blacklist_typecache //Types that are NOT allowed to use that emote
	var/list/mob_type_ignore_stat_typecache
	var/stat_allowed = CONSCIOUS
	var/sound //Sound to play when emote is called
	var/vary = FALSE	//used for the honk borg emote
	var/only_forced_audio = FALSE //can only code call this event instead of the player.
	var/nomsg = FALSE
	var/soundping = TRUE
	var/ignore_silent = FALSE
	var/snd_vol = 100
	var/snd_range = -1
	var/mute_time = 30//time after where someone can't do another emote
	// Whether this should show on runechat
	var/show_runechat = TRUE
	// Explicitly defined runechat message, if it's not defined and `show_runechat` is TRUE then it will use `message` instaed
	var/runechat_msg = null

/datum/emote/New()
	if(!runechat_msg)
		runechat_msg = strip_punctuation(message)
	if (ispath(mob_type_allowed_typecache))
		switch (mob_type_allowed_typecache)
			if (/mob)
				mob_type_allowed_typecache = GLOB.typecache_mob
			if (/mob/living)
				mob_type_allowed_typecache = GLOB.typecache_living
			else
				mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	else
		mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

/datum/emote/proc/adjacentaction(mob/user, mob/target)
	return

/datum/emote/proc/send_sneaky_visible_emote_message(atom/message_source, message, obfuscated_message, runechat_message = null, obfuscated_runechat_message = null)
	if(QDELETED(message_source))
		return
	if(isnull(obfuscated_message))
		obfuscated_message = message
	if(isnull(obfuscated_runechat_message))
		obfuscated_runechat_message = runechat_message

	var/list/viewers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, message_source)
	var/rendered_message = span_italics(message)
	var/rendered_obfuscated_message = span_italics(obfuscated_message)
	var/static/list/sneaky_runechat_spans = list("emote", SPAN_ITALICS)

	// Sneaky emotes behave like whispers: nearby viewers get the full emote, farther viewers only get an obfuscated version.
	for(var/mob/viewer in viewers)
		if(!viewer.client)
			continue
		if(viewer.see_invisible < message_source.invisibility)
			continue

		var/displayed_message = rendered_message
		var/runechat_message_to_use = runechat_message
		if(get_dist(message_source, viewer) > SNEAKY_EMOTE_VISIBLE_RANGE)
			displayed_message = rendered_obfuscated_message
			runechat_message_to_use = obfuscated_runechat_message

		if(viewer != message_source && !viewer.is_blind())
			viewer.log_message("saw [key_name(message_source)] emote: [displayed_message]", LOG_EMOTE, log_globally = FALSE)
		viewer.show_message(displayed_message, MSG_VISUAL, null, MSG_AUDIBLE)
		if(runechat_message_to_use && viewer.can_hear())
			viewer.create_chat_message(message_source, raw_message = runechat_message_to_use, spans = sneaky_runechat_spans)

	message_source.relay_visible_message_to_portals(rendered_obfuscated_message, viewers)

/datum/emote/proc/send_visible_emote_message(mob/user, atom/message_source, message, runechat_message = null, intentional = FALSE, obfuscated_message = null, obfuscated_runechat_message = null)
	if(QDELETED(user))
		return
	if(QDELETED(message_source))
		return

	if(intentional && isliving(user))
		var/mob/living/living_user = user
		if(living_user.m_intent == MOVE_INTENT_SNEAK)
			var/sneaking_skill = GET_MOB_SKILL_VALUE(living_user, /datum/attribute/skill/misc/sneaking)
			if(isnull(sneaking_skill))
				sneaking_skill = 0
			var/scaled_sneaking_skill = max(sneaking_skill, 0)
			var/sneaky_emote_success_chance = SNEAKY_EMOTE_BASE_SUCCESS_CHANCE
			if(scaled_sneaking_skill < SNEAKY_EMOTE_FULL_SUCCESS_SKILL)
				var/success_range = SNEAKY_EMOTE_BASE_SUCCESS_CHANCE - SNEAKY_EMOTE_MIN_SUCCESS_CHANCE
				sneaky_emote_success_chance = SNEAKY_EMOTE_MIN_SUCCESS_CHANCE + round(success_range * (scaled_sneaking_skill / SNEAKY_EMOTE_FULL_SUCCESS_SKILL))
			if(prob(sneaky_emote_success_chance))
				send_sneaky_visible_emote_message(message_source, message, obfuscated_message, runechat_message, obfuscated_runechat_message)
				return

	message_source.visible_message(message, runechat_message = runechat_message)

/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE, targetted = FALSE)
	. = TRUE
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	if(only_forced_audio && intentional)
		return FALSE
	if(targetted)
		var/list/mobsadjacent = list()
		var/mob/chosenmob
		for(var/mob/living/target_mob in view(user, 2))
			if(target_mob == user)
				continue
			if(target_mob.rogue_sneaking) // No detecting sneaky people.
				continue
			mobsadjacent += target_mob
		if(length(mobsadjacent))
			chosenmob = browser_input_list(user, "[key] who?", "XYLIX", mobsadjacent)
		if(istype(chosenmob))
			if(user.Adjacent(chosenmob))
				params = chosenmob.name
				adjacentaction(user, chosenmob)
	var/raw_msg = select_message_type(user, intentional)
	var/msg = raw_msg
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(!msg && nomsg == FALSE)
		return

	var/obfuscated_msg = null
	if(!nomsg)
		user.log_message(msg, LOG_EMOTE)
		var/name_html = user.get_emote_name_html()
		obfuscated_msg = "[name_html] [stars(msg)]"
		msg = "[name_html] " + msg

	var/pitch = 1 //bespoke vary system so deep voice/high voiced humans
	if(isliving(user))
		var/mob/living/L = user
		pitch = L.get_emote_pitch()

	var/sound/tmp_sound = get_sound(user)
	if(!istype(tmp_sound))
		tmp_sound = sound(get_sfx(tmp_sound))
	tmp_sound.frequency = pitch
	if(tmp_sound && (!only_forced_audio || !intentional))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.voice_type == VOICE_TYPE_ANDRO)
				tmp_sound.frequency = pitch * 0.92
		playsound(user, tmp_sound, snd_vol, FALSE, snd_range, soundping = soundping)
	if(!nomsg)
		for(var/mob/M in GLOB.dead_mob_list)
			if(!M.client || isnewplayer(M))
				continue
			var/T = get_turf(user)
			if(M.stat == DEAD && M.client && (M.client.prefs?.read_preference(/datum/preference/bitwise/chat_toggles) & CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
				M.show_message(msg)
		var/runechat_msg_to_use = null
		var/obfuscated_runechat_msg_to_use = null
		if(show_runechat && !(emote_type & EMOTE_AUDIBLE))
			runechat_msg_to_use = runechat_msg ? runechat_msg : raw_msg
			obfuscated_runechat_msg_to_use = stars(runechat_msg_to_use)
		if((emote_type & EMOTE_AUDIBLE))
			user.audible_message(msg, runechat_message = runechat_msg_to_use)
		else
			send_visible_emote_message(user, user, msg, runechat_message = runechat_msg_to_use, intentional = intentional, obfuscated_message = obfuscated_msg, obfuscated_runechat_message = obfuscated_runechat_msg_to_use)

/// Bold name that starts an emote line, in the voice colour when there is one.
/mob/proc/get_emote_name_html()
	var/name_color = get_emote_name_color()
	if(!name_color)
		return "<b>[src]</b>"
	return "<span style='color:#[name_color];text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b>[src]</b></span>"

/// Colour for the emote name, or null for plain text.
/mob/proc/get_emote_name_color()
	return voicecolor_override

/// A hidden face shows a descriptor name, so the voice colour must not give the person away.
/mob/living/carbon/human/get_emote_name_color()
	if(!get_face_name(""))
		return null
	return voicecolor_override || voice_color

/mob/living/proc/get_emote_pitch()
	return clamp(voice_pitch, 0.5, 2)

/mob/living/carbon/human/get_emote_pitch()
	var/final_pitch = ..()
	var/pitch_modifier = 0
	if(HAS_TRAIT(src, TRAIT_DECEIVING_MEEKNESS))
		return final_pitch
	if(GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH) > 10)
		pitch_modifier -= (GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH) - 10) * 0.03
	else if(GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH) < 10)
		pitch_modifier += (10 - GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH)) * 0.03
	return clamp(final_pitch + pitch_modifier, 0.5, 2)




/datum/emote/proc/get_env(mob/living/user)
	return

/datum/emote/living/get_env(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.head)
			var/obj/item/clothing/I = H.head
			if(I.emote_environment)
				return I.emote_environment

/datum/emote/proc/get_sound(mob/living/user)
	if(sound)
		return sound

/datum/emote/living/get_sound(mob/living/user)
	if(sound)
		return sound
	else
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/used_sound
			var/possible_sounds
			var/modifier
			if(H.age == AGE_OLD)
				modifier = "old"
			if(!ignore_silent && !H.can_speak() || (!ignore_silent && HAS_TRAIT(H, TRAIT_MUTE)) || (!ignore_silent && HAS_TRAIT(H, TRAIT_BAGGED)))
				modifier = "silenced"
			var/datum/voicepack/soundpack_m = H.dna.species.get_soundpack_m()
			var/datum/voicepack/soundpack_f = H.dna.species.get_soundpack_f()
			if(user.gender == FEMALE && soundpack_f)
				possible_sounds = soundpack_f.get_sound(key,modifier)
			else if(soundpack_m)
				possible_sounds = soundpack_m.get_sound(key,modifier)
			//RMH ADD - manual voicepack selection
			if(H.moan_selection && (key in list("sexmoanlight","sexmoanmed","sexmoanhvy","groan","painmoan","whimper","sexmoangag","sexmoangag_org")))
				var/datum/moan_pack/vpath
				if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100) //stealth sex, keep your voice down.
					vpath = new /datum/moan_pack/female/quiet //gender dont matter ig, they are quiet
				else
					vpath = new H.moan_selection
				switch(key)
					if("sexmoanlight")
						if(vpath.sounds_sexmoanlight)
							possible_sounds = vpath.get_moans(key)
					if("sexmoanmed")
						if(vpath.sounds_sexmoanmed)
							possible_sounds = vpath.get_moans(key)
					if("sexmoanhvy")
						if(vpath.sounds_sexmoanhvy)
							possible_sounds = vpath.get_moans(key)
					if("groan")
						if(vpath.sounds_groan)
							possible_sounds = vpath.get_moans(key)
					if("painmoan")
						if(vpath.sounds_painmoan)
							possible_sounds = vpath.get_moans(key)
					if("whimper")
						if(vpath.sounds_whimper)
							possible_sounds = vpath.get_moans(key)
					if("sexmoangag")
						if(vpath.sounds_sexmoangag)
							possible_sounds = vpath.get_moans(key)
					if("sexmoangag_org")
						if(vpath.sounds_sexmoangag_org)
							possible_sounds = vpath.get_moans(key)

			else if(H.voice_type)
				switch (H.voice_type)
					if (VOICE_TYPE_MASC)
						possible_sounds = soundpack_m?.get_sound(key, modifier)
					if (VOICE_TYPE_FEM, VOICE_TYPE_ANDRO)
						if (soundpack_f)
							possible_sounds = soundpack_f.get_sound(key, modifier)
						else
							possible_sounds = soundpack_m?.get_sound(key, modifier)
			if(possible_sounds)
				if(islist(possible_sounds))
					var/list/PS = possible_sounds
					if(PS.len > 1)
						used_sound = pick_n_take(possible_sounds)
						if(used_sound == H.last_sound)
							used_sound = pick(possible_sounds)
					else
						used_sound = pick(possible_sounds)
				else //direct file
					used_sound = possible_sounds
				H.last_sound = used_sound
				return used_sound
		else
			return user.get_sound(key)

/mob/living/proc/get_sound(input)
	return

/datum/emote/proc/replace_pronoun(mob/user, message)
	if(findtext(message, "their"))
		message = replacetext(message, "their", user.p_their())
	if(findtext(message, "them"))
		message = replacetext(message, "them", user.p_them())
	if(findtext(message, "%s"))
		message = replacetext(message, "%s", user.p_s())
	return message

/datum/emote/proc/select_message_type(mob/user, intentional)
	. = message
	if(message_muffled && iscarbon(user))
		var/mob/living/carbon/C = user
		if(!C.can_speak_vocal())
			. = message_muffled
		if(!muzzle_ignore && C.mouth?.muteinmouth && (emote_type & EMOTE_AUDIBLE))
			. = message_muffled
		if(!muzzle_ignore && (emote_type & EMOTE_AUDIBLE) && HAS_TRAIT(C, TRAIT_BAGGED))
			. = message_muffled

	if(!muzzle_ignore && HAS_TRAIT(user, TRAIT_MUTE) && (emote_type & EMOTE_AUDIBLE))
		return "makes a [pick("strong ", "weak ", "")]noise."
	if(user.mind && user.mind.miming && message_mime)
		. = message_mime
	else if(isanimal(user) && message_simple)
		. = message_simple

/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)

/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	. = TRUE
	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE
	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if(user.stat > stat_allowed)
			if(!intentional)
				return FALSE
/*			switch(user.stat)
				if(SOFT_CRIT)
					to_chat(user, "<span class='warning'>I cannot [key] while dying!</span>")
				if(UNCONSCIOUS)
					to_chat(user, "<span class='warning'>I cannot [key] while unconscious!</span>")
				if(DEAD)
					to_chat(user, "<span class='warning'>I cannot [key] while dead!</span>")*/
			return FALSE
		if(restraint_check && HAS_TRAIT(user, TRAIT_RESTRAINED))
			if(!intentional)
				return FALSE
			to_chat(user, "<span class='warning'>I cannot [key] while restrained!</span>")
			return FALSE
		if(hands_use_check && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			if(!intentional)
				return FALSE
			to_chat(user, "<span class='warning'>I cannot use my hands to [key] right now!</span>")
			return FALSE
		if(incapacitated_check && HAS_TRAIT(user, TRAIT_INCAPACITATED))
			if(!intentional)
				return FALSE
			// to_chat(user, "<span class='warning'>You cannot use your hands to [key] right now!</span>")
			return FALSE

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_EMOTEMUTE))
			return FALSE
