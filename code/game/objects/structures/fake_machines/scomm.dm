
/obj/structure/fake_machine/scomm
	name = "SCOM"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "scomm1"
	density = FALSE
	blade_dulling = DULLING_BASH
	SET_BASE_PIXEL(0, 32)
	anchored = TRUE
	var/next_decree = 0
	var/listening = TRUE
	var/speaking = TRUE
	var/dictating = FALSE
	//RMH EDITED START - garrison SCOM ring integration: stationary SCOMs can now
	//be retuned to the exclusive garrison line, same as crownstone/houndstone
	var/garrisonline = FALSE
	/// Auto-assigned sequential ID, shown in examine
	var/scom_number
	/// Free-text designation, settable per-instance in the map editor to label which SCOM this is (e.g. "Market Square")
	var/scom_tag
	//RMH EDITED END

/obj/structure/fake_machine/scomm/MiddleClick(mob/living/user, list/modifiers)
	if(.)
		return
	if(!HAS_TRAIT(user, TRAIT_GARRISON_ITEM))
		to_chat(user, span_warning("Nothing happens."))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/garrisonscom.ogg', 100, FALSE, -1)
	garrisonline = !garrisonline
	to_chat(user, span_info("I [garrisonline ? "connect to the garrison SCOMline" : "connect to the general SCOMline"]"))
	update_appearance(UPDATE_ICON_STATE)
	//RMH EDITED END

/obj/structure/fake_machine/scomm/r
	SET_BASE_PIXEL(32, 0)

/obj/structure/fake_machine/scomm/l
	SET_BASE_PIXEL(-32, 0)

/obj/structure/fake_machine/scomm/examine(mob/user)
	. = ..()
	//RMH EDITED START - garrison SCOM ring integration: show designation on examine
	if(scom_number)
		. += span_smallnotice("Its designation is #[scom_number][scom_tag ? ", labeled as [scom_tag]" : ""].")
	//RMH EDITED END
	. += "<b>THE LAWS OF THE LAND:</b>"
	if(!length(GLOB.laws_of_the_land))
		. += "<span class='danger'>The land has no laws! <b>We are doomed!</b></span>"
		return
	if(!user.is_literate())
		. += "<span class='warning'>Uhhh... I can't read them...</span>"
		return
	for(var/i in 1 to length(GLOB.laws_of_the_land))
		. += span_info("[i]. [GLOB.laws_of_the_land[i]]")

/obj/structure/fake_machine/scomm/process()
	if(obj_broken)
		return
	if(world.time > next_decree)
		next_decree = world.time + rand(3 MINUTES, 8 MINUTES)
		if(GLOB.lord_decrees.len)
			say("The King Decrees: [pick(GLOB.lord_decrees)]", spans = list("info"))

/obj/structure/fake_machine/scomm/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(obj_broken)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
	listening = !listening
	speaking = !speaking
	to_chat(user, "<span class='info'>I [speaking ? "unmute" : "mute"] the SCOM.</span>")
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/fake_machine/scomm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
	var/canread = user.can_read(src, TRUE)
	var/contents
	var/datum/job/lord/ruler_job = SSjob.GetJobType(/datum/job/lord)
	contents += "<center>[ruler_job.get_informed_title(SSticker.rulermob)]'s DECREES<BR>"

	contents += "-----------<BR><BR></center>"
	for(var/i = GLOB.lord_decrees.len to 1 step -1)
		contents += "[i]. <span class='info'>[GLOB.lord_decrees[i]]</span><BR>"
	if(!canread)
		contents = stars(contents)
	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 400)
	popup.set_content(contents)
	popup.open()

/obj/structure/fake_machine/scomm/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_SHAKY_SPEECH, TRAIT_GENERIC)
	become_hearing_sensitive()
	START_PROCESSING(SSroguemachine, src)
	SSroguemachine.scomm_machines += src
	//RMH EDITED START - garrison SCOM ring integration: sequential designation number
	scom_number = SSroguemachine.scomm_machines.len
	//RMH EDITED END

/obj/structure/fake_machine/scomm/update_icon_state()
	. = ..()
	//RMH EDITED START - garrison line gets its own dedicated sprite
	if(garrisonline)
		icon_state = "scomm3"
		return
	//RMH EDITED END
	icon_state = "scomm[listening]"

/obj/structure/fake_machine/scomm/atom_break(damage_flag)
	. = ..()
	set_light(0)
	speaking = FALSE
	listening = FALSE

/obj/structure/fake_machine/scomm/atom_fix()
	. = ..()
	speaking = TRUE
	listening = TRUE

/obj/structure/fake_machine/scomm/Destroy()
	lose_hearing_sensitivity()
	SSroguemachine.scomm_machines -= src
	STOP_PROCESSING(SSroguemachine, src)
	set_light(0)
	return ..()

/obj/structure/fake_machine/scomm/proc/repeat_message(message, atom/A, tcolor, message_language)
	if(A == src)
		return
	if(tcolor)
		voicecolor_override = tcolor
	if(speaking && message)
		playsound(src, 'sound/vo/mobs/rat/rat_life.ogg', 100, TRUE, -1)
		say(message, language = message_language)
	voicecolor_override = null

/obj/structure/fake_machine/scomm/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(speaker == src)
		return
	if(speaker.loc != loc)
		return
	if(!ishuman(speaker))
		return
	var/mob/living/carbon/human/H = speaker
	if(!listening)
		return
	var/usedcolor = H.voice_color
	if(H.voicecolor_override)
		usedcolor = H.voicecolor_override
	if(raw_message)
		if(LOWER_TEXT(raw_message) == "say laws")
			dictate_laws()
			return
		//RMH EDITED START - garrison SCOM ring integration: designation tag + garrison-line routing
		var/message_affix = ""
		if(scom_number)
			message_affix = "[scom_tag ? "([scom_tag])" : "(#[scom_number])"]"
		raw_message = "[message_affix][raw_message]"
		if(garrisonline)
			raw_message = "<big><span style='color: [GARRISON_SCOM_COLOR]'>[raw_message]</span></big>"
			for(var/obj/item/scomstone/bad/garrison/S in SSroguemachine.scomm_machines)
				S.repeat_message(raw_message, src, usedcolor, message_language)
			for(var/obj/item/scomstone/garrison/S in SSroguemachine.scomm_machines)
				S.repeat_message(raw_message, src, usedcolor, message_language)
			for(var/obj/structure/fake_machine/scomm/S in SSroguemachine.scomm_machines)
				if(S.garrisonline)
					S.repeat_message(raw_message, src, usedcolor, message_language)
			return
		//RMH EDITED END
		for(var/obj/structure/fake_machine/scomm/S in SSroguemachine.scomm_machines)
			S.repeat_message(raw_message, src, usedcolor, message_language)
		for(var/obj/item/scomstone/S in SSroguemachine.scomm_machines)
			S.repeat_message(raw_message, src, usedcolor, message_language)

/obj/structure/fake_machine/scomm/proc/dictate_laws()
	if(dictating)
		return
	dictating = TRUE
	repeat_message("THE LAWS OF THE LAND ARE...", tcolor = COLOR_RED)
	INVOKE_ASYNC(src, PROC_REF(dictation))

/obj/structure/fake_machine/scomm/proc/dictation()
	if(!length(GLOB.laws_of_the_land))
		sleep(2)
		repeat_message("THE LAND HAS NO LAWS!", tcolor = COLOR_RED)
		dictating = FALSE
		return
	for(var/i in 1 to length(GLOB.laws_of_the_land))
		sleep(2)
		repeat_message("[i]. [GLOB.laws_of_the_land[i]]", tcolor = COLOR_RED)
	dictating = FALSE

/proc/scom_announce(message)
	for(var/obj/structure/fake_machine/scomm/S in SSroguemachine.scomm_machines)
		S.say(message, spans = list("info"))



//SCOMSTONE                 SCOMSTONE

/obj/item/scomstone
	name = "scomstone ring"
	desc = "A heavy ring made of metal. There is a gem embedded in the center - dim, but alive."
	//RMH EDITED START - switched to active right-click messaging model, existing unused sprites wired in
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "ring_scom"
	//RMH EDITED END
	gripped_intents = null
	dropshrink = 0.75
	possible_item_intents = list(INTENT_GENERIC)
	force = 10
	throwforce = 10
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_RING

	w_class = WEIGHT_CLASS_SMALL
	muteinmouth = TRUE
	sellprice = 35
	//RMH EDITED START - active messaging vars ported from Twilight Axis
	var/listening = TRUE
	var/speaking = TRUE
	var/cooldown = 60 SECONDS
	var/on_cooldown = FALSE
	var/cooldown_end_time
	var/messagereceivedsound = 'sound/misc/scom.ogg'
	//RMH EDITED END

/obj/item/scomstone/Initialize()
	. = ..()
	become_hearing_sensitive()
	SSroguemachine.scomm_machines += src

/obj/item/scomstone/Destroy()
	lose_hearing_sensitivity()
	SSroguemachine.scomm_machines -= src
	return ..()

//RMH EDITED START - cooldown text helper, ported from Twilight Axis
/obj/item/scomstone/proc/get_cooldown_text()
	var/time_left = max(0, cooldown_end_time - world.time)
	var/total_seconds = round(time_left / 10)
	var/minutes = FLOOR(total_seconds / 60, 1)
	var/seconds = total_seconds % 60
	if(minutes)
		return "[minutes] minute[minutes == 1 ? "" : "s"] and [seconds] second[seconds == 1 ? "" : "s"]"
	return "[seconds] second[seconds == 1 ? "" : "s"]"

/obj/item/scomstone/proc/check_cooldown(mob/living/user)
	if(!on_cooldown)
		return FALSE
	to_chat(user, span_warning("The gemstone inside still radiates heat from its last transmission. It will cool in [get_cooldown_text()]."))
	playsound(loc, 'sound/misc/machineno.ogg', 100, FALSE, -1)
	return TRUE

/obj/item/scomstone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Most SCOMSTONEs function as handheld SCOMs. The only exception are HOUNDSTONES, which have access to an exclusive SCOMline for the Keep's royalty and guards.")
	. += span_info("Right-click a SCOMSTONE or CROWNSTONE to prepare a message. This message will be heard through every SCOM in the kingdom-and-abroad, but comes with a minor cooldown.")
	. += span_info("Middle-click a SCOMSTONE to mute or unmute it.")
	. += span_info("Activate a CROWNSTONE in your hand to swap between the general SCOMline and the royal SCOMline. The latter is denoted by crimson lettering, and is exclusively heard by those with either a HOUNDSTONE or retuned SCOM.")

/obj/item/scomstone/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	//RMH EDITED START - message-sending moved into an overridable proc so garrison
	//subtypes can fully replace it without ..() re-running this general-line send
	do_scom_broadcast(user)

/**
 * Everything that allowed the broadcast to start has to hold at the moment it
 * actually goes out: input() sleeps for as long as the player leaves the prompt
 * open, and the ring can be dropped, stolen or carried out of reach meanwhile.
 */
/obj/item/scomstone/proc/can_still_broadcast(mob/living/user)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH|NEED_DEXTERITY))
		return FALSE
	if(!can_speak_into(user))
		return FALSE
	if(check_cooldown(user))
		return FALSE
	return TRUE

/obj/item/scomstone/proc/can_speak_into(mob/living/user)
	if(!user.can_speak_vocal() || user.is_muzzled())
		to_chat(user, span_warning("I can't speak into [src]!"))
		return FALSE
	return TRUE

/**
 * Turns raw player input into something safe to hand every listener.
 *
 * The broadcast path writes this text straight into other people's chat without
 * going through mob speech encoding, so it is encoded and length-capped here,
 * before any server-owned markup is wrapped around it. Returns null for input
 * that is empty once trimmed.
 */
/obj/item/scomstone/proc/format_scom_message(input_text)
	var/message = trim(input_text, MAX_BROADCAST_LEN)
	if(!length(message))
		return null
	// Measured before encoding: entities inflate the length of ordinary text
	var/is_long = length(message) > 100
	message = sanitize(message)
	return is_long ? "<small>[message]</small>" : message

/obj/item/scomstone/proc/do_scom_broadcast(mob/living/user)
	if(check_cooldown(user))
		return
	if(!can_speak_into(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	visible_message(span_notice("[user] presses [user.p_their()] [src.name] against [user.p_their()] mouth."))
	var/input_text = input(user, "Enter your message:", "Message")
	if(!input_text)
		return
	//input() sleeps - recheck, or several prompts opened at once all fire
	if(!can_still_broadcast(user))
		return
	//voice_color only exists on /mob/living/carbon/human, guard against generic mob/living
	var/usedcolor = "a0a0a0"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		usedcolor = H.voice_color
	if(user.voicecolor_override)
		usedcolor = user.voicecolor_override
	input_text = format_scom_message(input_text)
	if(!input_text)
		return
	for(var/obj/structure/fake_machine/scomm/S in SSroguemachine.scomm_machines)
		S.repeat_message(input_text, src, usedcolor)
	for(var/obj/item/scomstone/S in SSroguemachine.scomm_machines)
		S.repeat_message(input_text, src, usedcolor)
	on_cooldown = TRUE
	cooldown_end_time = world.time + cooldown
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown), user), cooldown)
	//RMH EDITED END

/obj/item/scomstone/proc/reset_cooldown(mob/living/user)
	if(user)
		to_chat(user, span_notice("[src] is ready for use again."))
		playsound(loc, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
	on_cooldown = FALSE
	//RMH EDITED END

/obj/item/scomstone/MiddleClick(mob/user, list/modifiers)
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
	listening = !listening
	speaking = !speaking
	to_chat(user, "<span class='info'>I [speaking ? "unmute" : "mute"] the scomstone.</span>")
	//RMH EDITED START
	update_appearance(UPDATE_ICON_STATE)
	//RMH EDITED END

/obj/item/scomstone/proc/repeat_message(message, atom/A, tcolor, message_language)
	if(A == src)
		return
	if(!ismob(loc))
		return
	if(tcolor)
		voicecolor_override = tcolor
	if(speaking && message)
		//RMH EDITED START - use per-ring messagereceivedsound instead of a hardcoded scom.ogg
		playsound(src, messagereceivedsound, 100, TRUE, -1)
		//RMH EDITED END
		say(message, language = message_language)
	voicecolor_override = null


/obj/item/scomstone/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	spans |= speech_span
	if(!language)
		language = get_default_language()
	if(istype(loc, /obj/item))
		var/obj/item/I = loc
		I.send_speech(message, 1, I, , spans, message_language=language)
	else
		send_speech(message, 1, src, , spans, message_language=language)

//RMH EDITED START - passive Hear() broadcasting removed; scomstone/scomm no longer echoes everything the wearer says
/obj/item/scomstone/bad
	name = "serfstone"
	desc = "A rusty shoddily-made metal ring. The gem embedded within is barely holding on."
	icon_state = "ring_serfscom"
	listening = FALSE
	sellprice = 2

/obj/item/scomstone/bad/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// garrison scoms/houndstones

/obj/item/scomstone/garrison
	name = "crownstone"
	icon_state = "ring_crownscom"
	desc = "A lavish golden ring with the mark of the Crown. Heavy and garish. The gem embedded flickering in excitement."
	var/garrisonline = TRUE
	messagereceivedsound = 'sound/misc/garrisonscom.ogg'
	sellprice = 100

/obj/item/scomstone/garrison/hand
	name = "handpin"
	desc = "A unique crownstone, perfect for long days and short lives, both honor and burden."
	icon = 'icons/roguetown/clothing/special/hand.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/hand.dmi'
	icon_state = "handpin"

/obj/item/scomstone/garrison/equipped(mob/living/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_RING)
		ADD_TRAIT(user, TRAIT_GARRISON_ITEM, "[REF(src)]")

/obj/item/scomstone/garrison/dropped(mob/living/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GARRISON_ITEM, "[REF(src)]")

//RMH EDITED START - overriding do_scom_broadcast (not attack_hand_secondary) so this
//fully replaces the general-line send instead of running both; fixes crownstone
//always broadcasting uncolored on the general line regardless of garrisonline
/// A crownstone is spoken into, so a covered mouth blocks it - before the
/// prompt and again after it, since a sack can go over the head meanwhile.
/obj/item/scomstone/garrison/can_speak_into(mob/living/user)
	if(!..())
		return FALSE
	if(!get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH, grabs = TRUE))
		to_chat(user, span_warning("My mouth is covered!"))
		return FALSE
	return TRUE

/obj/item/scomstone/garrison/do_scom_broadcast(mob/living/user)
	if(check_cooldown(user))
		return
	if(!can_speak_into(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	visible_message(span_notice("[user] presses [user.p_their()] [src.name] against [user.p_their()] mouth."))
	var/input_text = input(user, "Enter your message:", "Message")
	if(!input_text)
		return
	//input() sleeps - recheck, or several prompts opened at once all fire
	if(!can_still_broadcast(user))
		return
	var/usedcolor = "a0a0a0"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		usedcolor = H.voice_color
	if(user.voicecolor_override)
		usedcolor = user.voicecolor_override
	input_text = format_scom_message(input_text)
	if(!input_text)
		return
	playsound(loc, 'sound/misc/garrisonscom.ogg', 100, FALSE, -1)
	if(garrisonline)
		input_text = "<big><span style='color: [GARRISON_SCOM_COLOR]'>[input_text]</span></big>"
		for(var/obj/item/scomstone/bad/garrison/S in SSroguemachine.scomm_machines)
			S.repeat_message(input_text, src, usedcolor)
		for(var/obj/item/scomstone/garrison/S in SSroguemachine.scomm_machines)
			S.repeat_message(input_text, src, usedcolor)
		for(var/obj/structure/fake_machine/scomm/S in SSroguemachine.scomm_machines)
			if(S.garrisonline)
				S.repeat_message(input_text, src, usedcolor)
	else
		for(var/obj/structure/fake_machine/scomm/S in SSroguemachine.scomm_machines)
			S.repeat_message(input_text, src, usedcolor)
		for(var/obj/item/scomstone/S in SSroguemachine.scomm_machines)
			S.repeat_message(input_text, src, usedcolor)
	on_cooldown = TRUE
	cooldown_end_time = world.time + cooldown
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown), user), cooldown)
//RMH EDITED END

/obj/item/scomstone/garrison/attack_self(mob/living/user)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	garrisonline = !garrisonline
	to_chat(user, span_info("I [garrisonline ? "connect to the garrison SCOMline" : "connect to the general SCOMline"]"))
	update_appearance(UPDATE_ICON_STATE)

/obj/item/scomstone/garrison/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][garrisonline ? "_on" : ""]"

/obj/item/scomstone/bad/garrison
	name = "houndstone"
	desc = "A basic metal ring. It has a well-cut, dismal gem embedded - bearing the mark of the Crown."
	icon_state = "ring_houndscom"
	listening = FALSE
	messagereceivedsound = 'sound/misc/garrisonscom.ogg'

/obj/item/scomstone/bad/garrison/equipped(mob/living/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_RING)
		ADD_TRAIT(user, TRAIT_GARRISON_ITEM, "[REF(src)]")

/obj/item/scomstone/bad/garrison/dropped(mob/living/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GARRISON_ITEM, "[REF(src)]")

//RMH EDITED START - houndstone can now transmit on the general line only (no garrison access)
/obj/item/scomstone/bad/garrison/attack_hand_secondary(mob/living/user, list/modifiers)
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	do_scom_broadcast(user)
//RMH EDITED END
