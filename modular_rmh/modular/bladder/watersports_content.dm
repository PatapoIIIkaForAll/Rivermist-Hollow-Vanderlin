/// Off hides all watersports from this player and keeps them out of it.
/datum/preference/toggle/watersports_content
	savefile_key = "watersports_content"
	savefile_identifier = PREF_PLAYER
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE
	toggles_menu_category = "Content"
	toggles_menu_name = "Watersports content"
	toggles_menu_desc = "Show piss play, squirting, fidgeting from a full bladder and urine stains, and allow the Bladder quirk and the Watersports ERP preference. Off hides all of it and turns your Watersports preference off."

/datum/preference/toggle/watersports_content/apply_to_client_updated(client/player, value)
	. = ..()
	if(value || !player)
		return
	player.prefs?.turn_off_watersports()
	var/mob/living/carbon/human/body = player.mob
	if(!istype(body))
		return
	qdel(body.get_bladder())
	REMOVE_TRAIT(body, TRAIT_HOLY_URINE, JOB_TRAIT)

/proc/watersports_enabled()
	return CONFIG_GET(flag/watersports_enabled)

/datum/preferences/proc/shows_watersports()
	return watersports_enabled() && read_preference(/datum/preference/toggle/watersports_content)

/datum/preferences/proc/turn_off_watersports()
	var/datum/erp_preference/boolean/watersports/pref = new
	if(pref.get_value(src))
		pref.set_value(src, FALSE)
		save_character()

/// FALSE when the server has watersports off or this mob's player hides it, connected or not.
/mob/proc/sees_watersports()
	if(!watersports_enabled())
		return FALSE
	var/datum/preferences/prefs = client?.prefs || (ckey && GLOB.preferences_datums[ckey])
	return !prefs || prefs.shows_watersports()

/// visible_message() that leaves out everyone who hides watersports.
/atom/proc/watersports_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs)
	var/list/skipped = islist(ignored_mobs) ? ignored_mobs.Copy() : list()
	for(var/mob/viewer in get_hearers_in_view(vision_distance, src) | GLOB.sense_relay_mobs)
		if(viewer.client && !viewer.sees_watersports())
			skipped |= viewer
	visible_message(message, self_message, blind_message, vision_distance, skipped)

/// TRUE when this viewer should not learn that a fluid of fluid_type is urine.
/proc/is_fluid_hidden_from(fluid_type, mob/viewer)
	return ispath(fluid_type, /datum/reagent/consumable/urine) && viewer && !viewer.sees_watersports()

/datum/quirk/neutral/bladder/is_available(datum/preferences/prefs)
	if(!watersports_enabled() || (prefs && !prefs.shows_watersports()))
		return FALSE
	return ..()

/datum/quirk/neutral/bladder/is_listed(datum/preferences/prefs)
	return is_available(prefs)

/datum/preferences/quirk_unavailable_reason(datum/quirk/singleton)
	if(istype(singleton, /datum/quirk/neutral/bladder) && !shows_watersports())
		return watersports_enabled() ? "Turn on Watersports content in the Toggles window to take [singleton.name]." : "[singleton.name] is turned off on this server."
	return ..()

/datum/erp_preference/boolean/watersports/is_listed(datum/preferences/prefs)
	return !prefs || prefs.shows_watersports()

/datum/erp_preference/boolean/watersports/get_edit_lock_reason(mob/user, datum/preferences/prefs)
	if(!watersports_enabled())
		return "Watersports is turned off on this server."
	if(prefs && !prefs.shows_watersports())
		return "Turn on Watersports content in the Toggles window first."
	return ..()

/datum/erp_preference/boolean/watersports/set_value(datum/preferences/prefs, value)
	if(value && !prefs?.shows_watersports())
		return
	return ..()

/datum/job
	/// Spawns with Holy Urine when the server and the player allow watersports.
	var/grants_holy_urine = FALSE

/datum/job/after_spawn(mob/living/carbon/human/spawned, client/player_client, clear_job_stats = TRUE)
	. = ..()
	if(!grants_holy_urine || !ishuman(spawned) || !watersports_enabled())
		return
	var/datum/preferences/prefs = player_client?.prefs || spawned.client?.prefs
	if(!prefs || prefs.shows_watersports())
		ADD_TRAIT(spawned, TRAIT_HOLY_URINE, JOB_TRAIT)
