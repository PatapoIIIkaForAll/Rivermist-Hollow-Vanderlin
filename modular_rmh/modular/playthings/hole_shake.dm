#define HOLE_SHAKE_MAX_PIXELS 3
#define PORTAL_TWITCH_COOLDOWN (20 SECONDS)
#define PORTAL_TWITCH_RANGE 3

/datum/preference/toggle/hole_shake
	savefile_key = "hole_shake"
	savefile_identifier = PREF_PLAYER
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/client/verb/toggle_hole_shake()
	set name = "Toggle Body Shake"
	set desc = "Let your character shake when toys, eggs, births or portals move inside them."
	set category = "Preferences"
	prefs.write_preference(/datum/preference/toggle/hole_shake, !prefs.read_preference(/datum/preference/toggle/hole_shake))
	prefs.save_preferences()
	to_chat(usr, span_notice("Body shake [prefs.read_preference(/datum/preference/toggle/hole_shake) ? "enabled" : "disabled"] for your character."))

/// Whether shaker may play body shakes. Mobs without a player shake.
/proc/hole_shake_enabled(mob/living/shaker)
	var/datum/preferences/prefs = shaker?.client?.prefs
	if(!prefs)
		return TRUE
	return prefs.read_preference(/datum/preference/toggle/hole_shake)

/mob/living
	/// world.time the current body shake ends; a new shake waits for it.
	var/next_hole_shake = 0

/mob/living/carbon/human
	COOLDOWN_DECLARE(portal_twitch_cooldown)

/// Shakes the body for toys, eggs, births and portals moving inside; [kind] picks the pattern, [strength] scales it.
/mob/living/proc/hole_shake_hook(kind, strength = 1)
	if(stat == DEAD || world.time < next_hole_shake || !hole_shake_enabled(src))
		return
	var/list/steps = get_hole_shake_steps(kind, strength)
	if(!length(steps))
		return
	next_hole_shake = world.time + play_hole_shake(steps)

/// Relative (w, z, time) steps per kind; play_hole_shake() adds the way back.
/mob/living/proc/get_hole_shake_steps(kind, strength = 1)
	var/px = clamp(round(strength * 1.5), 1, HOLE_SHAKE_MAX_PIXELS)
	switch(kind)
		if("stir")
			return list(list(1, 0, 1), list(-2, 0, 1.5))
		if("insert", "push_deeper")
			return list(list(0, -px, 0.8), list(0, px, 2), list(1, 0, 0.8), list(-2, 0, 0.8))
		if("remove")
			return list(list(0, px, 0.8), list(0, -px, 2))
		if("contraction")
			return list(list(1, 0, 1.5), list(-2, 0, 1.5), list(2, 0, 1.5), list(-2, 0, 1.5))
		if("push")
			return list(list(0, -px, 3), list(0, 0, 3), list(1, 0, 1), list(-2, 0, 1), list(2, 0, 1))
		if("birth")
			return list(list(px, 0, 0.8), list(-px * 2, 0, 0.8), list(px * 2, 0, 0.8), list(-px * 2, 0, 0.8), list(px * 2, 0, 0.8), list(0, -px, 2))
		if("hatchling")
			return list(list(1, 0, 1), list(0, 1, 1), list(-2, 0, 1.5), list(0, -1, 1))
		if("knot")
			return list(list(0, -px, 0.6), list(px, 0, 0.6), list(-px * 2, 0, 0.6), list(px * 2, 0, 0.6))
		if("portal")
			return list(list(px, 0, 0.5), list(-px * 2, 0, 0.5), list(px, -1, 0.8))
	return list(list(1, 0, 0.8), list(-2, 0, 0.8))

/// Plays steps relative and parallel, then returns to the start offset; gives the total time.
/mob/living/proc/play_hole_shake(list/steps)
	var/total_w = 0
	var/total_z = 0
	var/total_time = 0
	for(var/list/step as anything in steps)
		if(total_time)
			animate(pixel_w = step[1], pixel_z = step[2], time = step[3], easing = SINE_EASING, flags = ANIMATION_RELATIVE)
		else
			animate(src, pixel_w = step[1], pixel_z = step[2], time = step[3], easing = SINE_EASING, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)
		total_w += step[1]
		total_z += step[2]
		total_time += step[3]
	if(total_w || total_z)
		animate(pixel_w = -total_w, pixel_z = -total_z, time = 1, easing = SINE_EASING, flags = ANIMATION_RELATIVE)
		total_time += 1
	return total_time

// ---- Portals ----

/datum/sex_action/portal_base
	/// What people beside the portal wearer see now and then; null shows nothing.
	var/portal_twitch_text = "twitches, hips jerking at some unseen touch."

/datum/sex_action/portal_base/proc/get_portal_shake_strength()
	var/static/list/by_force = list(0.5, 1, 1.5, 2, 2.5)
	return by_force[clamp(force, SEX_FORCE_LOW, SEX_FORCE_UNRELENTING) - SEX_FORCE_LOW + 1]

/// The wearer shakes, and people beside them sometimes see a twitch; the portal user already reads their own lines.
/datum/sex_action/portal_base/proc/portal_touch_feedback(mob/living/user, mob/living/carbon/human/wearer, kind = "portal")
	if(!istype(wearer))
		return
	wearer.hole_shake_hook(kind, get_portal_shake_strength())
	if(!portal_twitch_text || !COOLDOWN_FINISHED(wearer, portal_twitch_cooldown))
		return
	COOLDOWN_START(wearer, portal_twitch_cooldown, PORTAL_TWITCH_COOLDOWN)
	wearer.visible_message(span_notice("[wearer] [portal_twitch_text]"), vision_distance = PORTAL_TWITCH_RANGE, ignored_mobs = list(user, wearer))

/datum/sex_action/portal_base/portal_oral_base
	portal_twitch_text = "shivers, thighs twitching as if something unseen licks at them."

/datum/sex_action/portal_base/portal_penis_base
	portal_twitch_text = "jolts, hips jerking to some unseen rhythm."

/datum/sex_action/portal_base/portal_vagina_base
	portal_twitch_text = "squirms, hips rocking against some slick, unseen weight."

/datum/sex_action/portal_base/portal_store_base
	portal_twitch_text = "flinches, as if something was pushed into them from nowhere."

/datum/sex_action/portal_base/portal_remove_base
	portal_twitch_text = "flinches, as if something was pulled out of them from nowhere."

#undef HOLE_SHAKE_MAX_PIXELS
#undef PORTAL_TWITCH_COOLDOWN
#undef PORTAL_TWITCH_RANGE
