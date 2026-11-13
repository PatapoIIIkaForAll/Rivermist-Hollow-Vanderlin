/// Job-granted versions of alchemical utility spells are innate class abilities.
/// They deliberately do not draw from an essence gauntlet; the base types still do.
/datum/action/cooldown/spell/essence/healing_spring/class_granted
	name = "Innate Healing Spring"
	spell_type = NONE

/datum/action/cooldown/spell/essence/neutralize/class_granted
	name = "Innate Neutralize"
	spell_type = NONE

/datum/action/cooldown/spell/essence/probability_warp/class_granted
	name = "Innate Probability Warp"
	spell_type = NONE

/datum/action/cooldown/spell/essence/purify_water/class_granted
	name = "Innate Purify Water"
	spell_type = NONE

/datum/action/cooldown/spell/essence/spark/class_granted
	name = "Innate Spark"
	spell_type = NONE

/datum/action/cooldown/spell/essence/toxic_cleanse/class_granted
	name = "Innate Toxic Cleanse"
	spell_type = NONE

/datum/action/cooldown/spell/essence/fire_cascade/class_granted
	name = "Innate Fire Cascade"
	spell_type = NONE

/// A functional replacement for the old cosmetic-only essence silence spell used by RMH classes.
/datum/action/cooldown/spell/pointed/silence
	name = "Silence"
	desc = "Briefly suppresses the voices of everyone near the target."
	button_icon_state = "silence"
	click_to_activate = TRUE
	cast_range = 2
	cooldown_time = 30 SECONDS
	spell_type = NONE
	charge_required = FALSE

/datum/action/cooldown/spell/pointed/silence/is_valid_target(atom/cast_on)
	. = ..()
	return . && get_turf(cast_on)

/datum/action/cooldown/spell/pointed/silence/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	if(!target_turf)
		return FALSE

	owner.visible_message(span_notice("[owner] smothers the area in magical silence."))
	new /obj/effect/temp_visual/rmh_silence_zone(target_turf)
	for(var/mob/living/target in range(2, target_turf))
		target.set_silence_if_lower(10 SECONDS)
	return TRUE

/obj/effect/temp_visual/rmh_silence_zone
	name = "silence zone"
	desc = "Sound falters within the fading magical haze."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-grey"
	alpha = 150
	duration = 10 SECONDS
