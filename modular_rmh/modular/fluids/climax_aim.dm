// Where a cock's next climax lands. A hand on it (the grip) or an NPC action sets it; spurts read it.

#define ALERT_COCK_AIMED "cock_aimed"

/obj/item/organ/genitals/penis
	/// Where this cock's next climax lands, if anyone is aiming it.
	var/datum/climax_aim/climax_aim

/obj/item/organ/genitals/penis/Destroy()
	QDEL_NULL(climax_aim)
	return ..()

/// Returns this cock's aim, making one on first use.
/obj/item/organ/genitals/penis/proc/get_climax_aim()
	RETURN_TYPE(/datum/climax_aim)
	if(!climax_aim)
		climax_aim = new(src)
	return climax_aim

/datum/climax_aim
	var/obj/item/organ/genitals/penis/penis
	/// A mob, a container, a garment or a turf.
	var/atom/target
	/// Coat zone, or PENIS_AIM_MOUTH, when the target is a mob.
	var/zone
	/// Who points it; they alone see the marker.
	var/mob/living/aimer
	var/image/marker
	/// TRUE while this aim has an alert up on its target.
	var/warned = FALSE
	/// Goes up with every new aim, so spurts can tell a fresh aim from the one they started with.
	var/revision = 0
	/// The target and the cock's owner, watched so the aim drops once they move apart.
	var/list/atom/movable/watched_movers

/datum/climax_aim/New(obj/item/organ/genitals/penis/new_penis)
	penis = new_penis

/datum/climax_aim/Destroy(force)
	clear()
	penis = null
	return ..()

/datum/climax_aim/proc/get_owner()
	return penis?.owner

/datum/climax_aim/proc/set_target(atom/new_target, new_zone, mob/living/new_aimer)
	clear()
	target = new_target
	zone = new_zone
	aimer = new_aimer
	revision++
	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
	watch_reach()
	show_marker()
	warn_target()

/datum/climax_aim/proc/clear()
	if(target && !isturf(target))
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	for(var/atom/movable/mover as anything in watched_movers)
		UnregisterSignal(mover, COMSIG_MOVABLE_MOVED)
	watched_movers = null
	hide_marker()
	unwarn_target()
	target = null
	zone = null
	aimer = null

/// Points where another aim points, without its marker or alert.
/datum/climax_aim/proc/copy_target_from(datum/climax_aim/source)
	target = source.target
	zone = source.zone
	aimer = source.aimer

/datum/climax_aim/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	clear()

/// Either side moving away drops the aim, with its marker and alert.
/datum/climax_aim/proc/watch_reach()
	watched_movers = list()
	if(ismovable(target))
		watched_movers |= target
	var/mob/living/owner = get_owner()
	if(owner)
		watched_movers |= owner
	for(var/atom/movable/mover as anything in watched_movers)
		RegisterSignal(mover, COMSIG_MOVABLE_MOVED, PROC_REF(on_reach_changed))

/datum/climax_aim/proc/on_reach_changed(datum/source)
	SIGNAL_HANDLER
	if(can_reach(target))
		return
	if(aimer)
		to_chat(aimer, span_warning("I lose my aim."))
	clear()

/// The cock only reaches what is next to its owner.
/datum/climax_aim/proc/can_reach(atom/thing)
	var/turf/thing_turf = get_turf(thing)
	var/turf/owner_turf = get_turf(get_owner())
	return thing_turf && owner_turf && thing_turf.z == owner_turf.z && get_dist(thing_turf, owner_turf) <= 1

/// The target when it still exists, is in reach, and still allows ERP if its player logged off; else null.
/datum/climax_aim/proc/get_valid_target()
	if(QDELETED(target) || !can_reach(target))
		return null
	var/mob/living/aimed = target
	if(isliving(aimed) && aimed != get_owner() && aimed != aimer && !aimed.allows_player_erp_while_disconnected())
		return null
	return target

/// The zone a shot lands on: a chest shot on someone facing away hits the back, and later spurts drift down.
/datum/climax_aim/proc/resolve_zone(mob/living/aimed, drift_steps = 0)
	var/landing = zone
	if(landing == FLUID_COAT_CHEST && is_from_behind(aimed))
		landing = FLUID_COAT_BACK
	for(var/i in 1 to drift_steps)
		landing = get_spurt_drift_zone(landing)
	return landing

/// TRUE when the aimed body faces away from the cock.
/datum/climax_aim/proc/is_from_behind(mob/living/aimed)
	var/mob/living/owner = get_owner()
	return aimed != owner && aimed.dir == get_dir(owner, aimed)

/// Heels on the aimed feet, which fill up like a cup.
/datum/climax_aim/proc/get_worn_heels(mob/living/aimed, landing_zone)
	if(landing_zone != FLUID_COAT_FEET || !ishuman(aimed))
		return null
	var/mob/living/carbon/human/wearer = aimed
	var/obj/item/clothing/shoes/heels/heels = wearer.shoes
	if(!istype(heels) || !heels.reagents)
		return null
	return heels

/// "Bob's" for anyone but the subject of the sentence, who gets "his own".
/proc/get_aim_whose(mob/living/aimed, mob/living/subject)
	return aimed == subject ? "[subject.p_their()] own" : "[aimed]'s"

/// "his cock" for its owner, "Bob's cock" for anyone else.
/proc/get_aim_cock_phrase(mob/living/owner, mob/living/subject)
	return owner == subject ? "[subject.p_their()] cock" : "[owner]'s cock"

/datum/climax_aim/proc/get_text(mob/living/subject)
	if(isliving(target))
		return "[get_aim_whose(target, subject)] [get_fluid_coat_zone_name(resolve_zone(target), target, is_from_behind(target))]"
	if(isturf(target))
		return "the floor"
	return "\the [target]"

/datum/climax_aim/proc/show_marker()
	if(!aimer?.client || !target)
		return
	var/static/list/zone_offsets = list(
		PENIS_AIM_MOUTH = 8,
		FLUID_COAT_FACE = 10,
		FLUID_COAT_CHEST = 4,
		FLUID_COAT_BACK = 4,
		FLUID_COAT_BELLY = 0,
		FLUID_COAT_GROIN = -3,
		FLUID_COAT_THIGHS = -7,
		FLUID_COAT_FEET = -13,
	)
	marker = image('modular_rmh/icons/obj/genitals/penis_aim.dmi', target, "aim", ABOVE_ALL_MOB_LAYER)
	marker.plane = GAME_PLANE_UPPER
	marker.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	if(zone)
		marker.pixel_y = zone_offsets[zone]
	aimer.client.images += marker

/datum/climax_aim/proc/hide_marker()
	if(marker)
		aimer?.client?.images -= marker
		marker = null

/// A mob being aimed at always knows, privately, and sees an alert while it lasts.
/datum/climax_aim/proc/warn_target()
	var/mob/living/aimed = target
	if(!isliving(aimed) || aimed == aimer)
		return
	var/mob/living/owner = get_owner()
	var/where = "your [get_fluid_coat_zone_name(resolve_zone(aimed), aimed, is_from_behind(aimed))]"
	var/who = aimer || owner
	var/whose_cock = owner == aimed ? "your cock" : get_aim_cock_phrase(owner, who)
	to_chat(aimed, span_love("[who] points [whose_cock] at [where]."))
	var/atom/movable/screen/alert/cock_aimed/alert = aimed.throw_alert(get_alert_category(), /atom/movable/screen/alert/cock_aimed)
	// throw_alert returns null or 0 when it does not show an alert.
	if(alert)
		alert.desc = "[who] is aiming [whose_cock] at [where]."
	warned = TRUE

/datum/climax_aim/proc/unwarn_target()
	var/mob/living/aimed = target
	if(warned && isliving(aimed))
		aimed.clear_alert(get_alert_category())
	warned = FALSE

/// Each aim keeps its own alert, so one aim ending leaves the others up.
/datum/climax_aim/proc/get_alert_category()
	return "[ALERT_COCK_AIMED]_[REF(src)]"

/atom/movable/screen/alert/cock_aimed
	name = "Aimed At"
	desc = "Someone is aiming at me."
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "aimed"

/// The next zone down the body for a spurt that follows the first without a new aim.
/proc/get_spurt_drift_zone(zone)
	var/static/list/next_zone = list(
		PENIS_AIM_MOUTH = FLUID_COAT_FACE,
		FLUID_COAT_FACE = FLUID_COAT_CHEST,
		FLUID_COAT_CHEST = FLUID_COAT_BELLY,
		FLUID_COAT_BELLY = FLUID_COAT_GROIN,
		FLUID_COAT_GROIN = FLUID_COAT_THIGHS,
		FLUID_COAT_THIGHS = FLUID_COAT_FEET,
		FLUID_COAT_BACK = FLUID_COAT_BACK,
		FLUID_COAT_FEET = FLUID_COAT_FEET,
	)
	return next_zone[zone] || zone

/// A groin seen from behind is an ass; the coat zone stays the same.
/proc/get_fluid_coat_zone_name(zone, mob/living/body, from_behind = FALSE)
	switch(zone)
		if(PENIS_AIM_MOUTH)
			return "mouth"
		if(FLUID_COAT_FACE)
			return "face"
		if(FLUID_COAT_CHEST)
			return body?.getorganslot(ORGAN_SLOT_BREASTS) ? "tits" : "chest"
		if(FLUID_COAT_BELLY)
			return "belly"
		if(FLUID_COAT_GROIN)
			return from_behind ? "ass" : "crotch"
		if(FLUID_COAT_BACK)
			return "back"
		if(FLUID_COAT_THIGHS)
			return "thighs"
		if(FLUID_COAT_FEET)
			return "feet"
	return "body"

#undef ALERT_COCK_AIMED
