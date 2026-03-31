// Protection from Evil and Good
// Self-buff miracle for paladins/clerics
// Grants protection against aberrations, fiends, celestials, undead, fey, and elementals
// Those creatures attack with disadvantage, and the target gains fear/charm immunity

/datum/action/cooldown/spell/undirected/protection_evil_good
	name = "Protection from Evil and Good"
	desc = "Grants divine protection against aberrations, fiends, celestials, undead, fey, and elementals."
	button_icon_state = "shieldsparkles"

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy

	invocation = "By divine will, evil and good shall not touch me!"
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 5 MINUTES
	spell_cost = 30

/datum/action/cooldown/spell/undirected/protection_evil_good/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	return isliving(owner)

/datum/action/cooldown/spell/undirected/protection_evil_good/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/buff/protection_evil_good)

// Status effect
/datum/status_effect/buff/protection_evil_good
	id = "protection_evil_good"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 1 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/buff/protection_evil_good
	var/static/mutable_appearance/ward_overlay = mutable_appearance('icons/effects/beam.dmi', "purple_lightning", -MUTATIONS_LAYER)
	/// Whether the caster follows an inhumen patron (affects message color)
	var/is_inhumen = FALSE

/atom/movable/screen/alert/status_effect/buff/protection_evil_good
	name = "Protection from Evil and Good"
	desc = "I am protected from aberrations, fiends, celestials, undead, fey, and elementals."
	icon_state = "buff"

/datum/status_effect/buff/protection_evil_good/on_apply()
	. = ..()
	is_inhumen = istype(owner.patron, /datum/patron/inhumen) || istype(owner.patron, /datum/patron/faerun/evil_gods)
	ADD_TRAIT(owner, TRAIT_PROTECTION_EVIL_GOOD, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FEARLESS, TRAIT_STATUS_EFFECT(id))
	owner.add_overlay(ward_overlay)
	var/ward_color = is_inhumen ? "#8B0000" : "#FFD700"
	owner.visible_message(
		"<b><font color='[ward_color]'>[owner] is surrounded by a [is_inhumen ? "sinister blood-red" : "shimmering golden"] ward!</font></b>",
		"<b><font color='[ward_color]'>[is_inhumen ? "Dark power shields me from the otherworldly." : "A shimmering golden ward surrounds me."]</font></b>",
	)

/datum/status_effect/buff/protection_evil_good/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PROTECTION_EVIL_GOOD, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_FEARLESS, TRAIT_STATUS_EFFECT(id))
	owner.cut_overlay(ward_overlay)
	var/ward_color = is_inhumen ? "#8B0000" : "#FFD700"
	owner.visible_message(
		"<b><font color='[ward_color]'>[owner]'s [is_inhumen ? "blood-red" : "golden"] ward fades away.</font></b>",
		"<b><font color='[ward_color]'>My [is_inhumen ? "dark" : "divine"] ward fades.</font></b>",
	)

/// Returns TRUE if the given mob is a valid target for this protection (matching biotype or vampire)
/datum/status_effect/buff/protection_evil_good/proc/is_warded_against(mob/living/attacker)
	if(attacker.mob_biotypes & MOB_PROTECTION_EVIL_GOOD)
		return TRUE
	if(attacker.mind?.has_antag_datum(/datum/antagonist/vampire))
		return TRUE
	return FALSE

/// Returns a colored protection message for combat feedback
/datum/status_effect/buff/protection_evil_good/proc/get_ward_message(mob/living/attacker)
	var/ward_color = is_inhumen ? "#8B0000" : "#FFD700"
	var/attacker_name = attacker.name
	if(is_inhumen)
		return "<b><font color='[ward_color]'>Dark power flares around me, warding off [attacker_name]!</font></b>"
	return "<b><font color='[ward_color]'>My golden ward flares with divine light, warding off [attacker_name]!</font></b>"

/datum/status_effect/buff/protection_evil_good/proc/get_ward_message_visible(mob/living/attacker)
	var/ward_color = is_inhumen ? "#8B0000" : "#FFD700"
	if(is_inhumen)
		return "<b><font color='[ward_color]'>A sinister blood-red aura flares around [owner], repelling [attacker]!</font></b>"
	return "<b><font color='[ward_color]'>A golden ward flares around [owner], repelling [attacker]!</font></b>"
