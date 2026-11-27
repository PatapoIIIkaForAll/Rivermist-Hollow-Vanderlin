/datum/preference/toggle/breast_animation
	savefile_key = "breast_animation"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Content"
	toggles_menu_name = "Breast animation"
	toggles_menu_desc = "Animate your character's breasts when moving and on some emotes."
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/// Flips breast animation and refreshes the body. Set from the Toggles window.
/client/proc/toggle_breast_animation()
	prefs.write_preference(/datum/preference/toggle/breast_animation, !prefs.read_preference(/datum/preference/toggle/breast_animation))
	prefs.save_preferences()
	to_chat(usr, span_notice("Breast animation [prefs.read_preference(/datum/preference/toggle/breast_animation) ? "enabled" : "disabled"] for your character."))
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/human_mob = mob
	human_mob.update_body_parts(TRUE)
	var/datum/component/breast_animation/animation = human_mob.GetComponent(/datum/component/breast_animation)
	animation?.refresh()

/// Whether owner's breasts animate. Mobs without a player animate.
/proc/breast_animation_enabled(mob/living/carbon/owner)
	var/datum/preferences/prefs = owner?.client?.prefs
	if(!prefs)
		return TRUE
	return prefs.read_preference(/datum/preference/toggle/breast_animation)

/// Plays a breast one-shot by name, such as "bounce" or "squeeze", when the breasts animate.
/mob/living/carbon/human/proc/play_breast_shot(shot)
	var/datum/component/breast_animation/animation = GetComponent(/datum/component/breast_animation)
	animation?.play_shot(shot)
