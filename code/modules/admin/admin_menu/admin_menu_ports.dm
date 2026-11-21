/**
 * Admin tools ported for the Admin Menu.
 *
 * Adapted from Azure Peak (https://github.com/Azure-Peak/Azure-Peak, commit 5c720fe6) and
 * Ratwood 2.0 (https://github.com/Rotwood-Vale/Ratwood-2.0, commit 56d4ec22), both AGPL-3.0,
 * the same licence as this repository. Rights checks and logging follow this build's conventions.
 */

/// Azure Peak / Ratwood 2.0: "inview Sleep".
/datum/admins/proc/sleep_view()
	set name = "inview Sleep"
	set category = "GameMaster.Gods"
	set desc = "Put every living mob in your view range to sleep."

	if(!check_rights(R_ADMIN))
		return
	if(alert(usr, "This will sleep ALL mobs within your view range. Are you sure?", "inview Sleep", "Yes", "Cancel") != "Yes")
		return
	if(!check_rights(R_ADMIN)) // the alert sleeps, rights may have changed meanwhile
		return

	var/count = 0
	for(var/mob/living/sleeper in view(usr.client))
		sleeper.SetSleeping(999999)
		count++

	log_admin("[key_name(usr)] put [count] mobs in view to sleep at [AREACOORD(usr)].")
	message_admins("[key_name_admin(usr)] used inview Sleep ([count] mobs) at [AREACOORD(usr)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Inview Sleep")

/// Azure Peak / Ratwood 2.0: "inview Wake".
/datum/admins/proc/wake_view()
	set name = "inview Wake"
	set category = "GameMaster.Gods"
	set desc = "Wake up every living mob in your view range."

	if(!check_rights(R_ADMIN))
		return
	if(alert(usr, "This will wake ALL mobs within your view range. Are you sure?", "inview Wake", "Yes", "Cancel") != "Yes")
		return
	if(!check_rights(R_ADMIN))
		return

	var/count = 0
	for(var/mob/living/sleeper in view(usr.client))
		var/datum/status_effect/incapacitating/sleeping/sleep_effect = sleeper.IsSleeping()
		if(!sleep_effect)
			continue
		sleeper.remove_status_effect(sleep_effect)
		sleeper.set_resting(FALSE, TRUE)
		sleeper.fallingas = FALSE
		count++

	log_admin("[key_name(usr)] woke [count] mobs in view at [AREACOORD(usr)].")
	message_admins("[key_name_admin(usr)] used inview Wake ([count] mobs) at [AREACOORD(usr)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Inview Wake")

/// Azure Peak / Ratwood 2.0: "Force Speech" as a verb. This build only had it as a player panel link.
/client/proc/force_say(mob/living/target in GLOB.mob_list)
	set name = "Force Speech"
	set popup_menu = FALSE // reached through the Admin.../GM.../Debug... right-click entries
	set category = "GameMaster.Interactions"
	set desc = "Make a living mob say something."

	if(!check_rights(R_FUN))
		return
	if(!isliving(target) || QDELETED(target))
		to_chat(usr, span_warning("Target must be a living mob."))
		return
	if(!target.loc)
		to_chat(usr, span_warning("Target mob has no location."))
		return

	var/speech = input(usr, "What will [key_name(target)] say?", "Force Speech") as text|null
	if(!speech || QDELETED(target) || !check_rights(R_FUN))
		return

	target.say(speech, forced = "admin speech")
	speech = sanitize(speech)
	log_admin("[key_name(usr)] forced [key_name(target)] at [AREACOORD(target)] to say: [speech]")
	message_admins(span_adminnotice("[key_name_admin(usr)] forced [key_name_admin(target)] to say: [speech]"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Force Speech")

/// Azure Peak / Ratwood 2.0: "Local Lightsout".
/client/proc/local_lightsout()
	set name = "Local Lightsout"
	set category = "GameMaster.Fun"
	set desc = "Extinguish every light source in your view range."

	if(!check_rights(R_ADMIN))
		return
	if(alert(usr, "Extinguish every light in your view range?", "Local Lightsout", "Yes", "Cancel") != "Yes")
		return
	if(!check_rights(R_ADMIN))
		return

	for(var/obj/thing in view(usr.client))
		thing.extinguish()
		if(istype(thing, /obj/machinery/light/fueledstreet))
			var/obj/machinery/light/fueledstreet/streetlamp = thing
			streetlamp.lights_out()

	log_admin("[key_name(usr)] turned the lights out at [AREACOORD(usr)].")
	message_admins(span_adminnotice("[key_name_admin(usr)] turned the lights out at [AREACOORD(usr)]."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Local Lightsout")

/// Azure Peak / Ratwood 2.0: lets the admin use browser devtools, find and refresh in browser windows.
/client/proc/enable_browser_debug()
	set name = "Enable Browser Debug"
	set category = "Debug"
	set desc = "Enable devtools, find and refresh in your own browser windows."

	if(!check_rights(R_DEBUG))
		return
	winset(src, null, "browser-options=devtools,find,refresh")
	to_chat(src, span_notice("Browser tools are now enabled for your client."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Enable Browser Debug")
