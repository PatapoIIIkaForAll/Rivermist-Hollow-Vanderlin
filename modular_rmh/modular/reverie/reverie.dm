#define REVERIE_DEPTH_SURFACE 15
#define REVERIE_DEPTH_FLOOR 25
#define REVERIE_ROUSE_TIME (2 SECONDS)
/// Mechanical injuries at or under this damage mend in deep Reverie; bigger ones need a repairer.
#define REVERIE_REPAIR_CUTOFF 15
#define REVERIE_REPAIR_RATE 0.5

/// Lets a mob that never sleeps rest, mend small damage and dream through a still Reverie.
/datum/component/reverie
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Shown on the action, the alert and messages, such as "Dormancy".
	var/rest_name = "Reverie"
	/// Automaton voice line key spoken on entry.
	var/voice_line
	/// Grant sources; the component deletes itself when the last one is revoked.
	var/list/sources = list()
	var/datum/action/reverie/action

/datum/component/reverie/Initialize(source, rest_name, voice_line)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	sources |= source
	if(rest_name)
		src.rest_name = rest_name
	src.voice_line = voice_line

/datum/component/reverie/InheritComponent(datum/component/new_comp, i_am_original, source, rest_name, voice_line)
	sources |= source

/datum/component/reverie/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_REVERIE, REF(src))
	action = new(src)
	action.name = rest_name
	action.Grant(parent)

/datum/component/reverie/UnregisterFromParent()
	var/mob/living/carbon/human/holder = parent
	holder.remove_status_effect(/datum/status_effect/reverie)
	REMOVE_TRAIT(parent, TRAIT_REVERIE, REF(src))
	QDEL_NULL(action)

/// Whether the holder can begin a Reverie now; tells them why not.
/datum/component/reverie/proc/can_enter(mob/living/carbon/human/holder)
	if(holder.stat != CONSCIOUS)
		return FALSE
	if(holder.cmode)
		to_chat(holder, span_warning("I can't go still while I'm ready to fight."))
		return FALSE
	if(!holder.in_reverie_posture())
		to_chat(holder, span_warning("I need to lie down, or settle onto a bed or seat, first."))
		return FALSE
	return TRUE

/datum/component/reverie/proc/enter(mob/living/carbon/human/holder)
	var/datum/status_effect/reverie/effect = holder.apply_status_effect(/datum/status_effect/reverie)
	if(!effect)
		return
	effect.rest_name = rest_name
	effect.linked_alert?.name = rest_name
	holder.visible_message(span_notice("[holder] goes utterly still."), span_notice("I go still and turn inward. My [LOWER_TEXT(rest_name)] begins."))
	if(voice_line)
		holder.play_voice_line(voice_line)

/mob/living/carbon/human/proc/grant_reverie(source, rest_name, voice_line)
	AddComponent(/datum/component/reverie, source, rest_name, voice_line)

/mob/living/carbon/human/proc/revoke_reverie(source)
	var/datum/component/reverie/reverie = GetComponent(/datum/component/reverie)
	if(!reverie)
		return
	reverie.sources -= source
	if(!length(reverie.sources))
		qdel(reverie)

/// Lying down, or buckled to something made for rest.
/mob/living/carbon/human/proc/in_reverie_posture()
	return body_position == LYING_DOWN || buckled?.sleepy

/datum/action/reverie
	name = "Reverie"
	desc = "Lie down or settle onto a bed, then go still. Restores energy, mends small damage and lets me dream at night."
	button_icon_state = "dream_lotus"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/reverie/Trigger(trigger_flags)
	. = ..()
	if(!. || !ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/holder = owner
	if(holder.has_status_effect(/datum/status_effect/reverie))
		holder.remove_status_effect(/datum/status_effect/reverie)
		return TRUE
	var/datum/component/reverie/reverie = target
	if(!reverie.can_enter(holder))
		return FALSE
	reverie.enter(holder)
	return TRUE

/datum/status_effect/reverie
	id = "reverie"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/reverie
	/// Shown in messages; copied from the granting component.
	var/rest_name = "Reverie"
	/// Still ticks so far; the Reverie is deep once this reaches the depth for the current surface.
	var/depth = 0
	/// Brute plus burn after the last tick, to notice fresh harm.
	var/last_damage = 0

/datum/status_effect/reverie/on_apply()
	. = ..()
	if(!ishuman(owner))
		return FALSE
	owner.set_eyes_closed(TRUE)
	last_damage = owner.getBruteLoss() + owner.getFireLoss()
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_move_attempt))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position))

/datum/status_effect/reverie/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	owner.set_eyes_closed(FALSE)
	if(owner.stat == CONSCIOUS && !QDELETED(owner))
		owner.Immobilize(REVERIE_ROUSE_TIME)
		to_chat(owner, span_notice("I stir from my [LOWER_TEXT(rest_name)]."))
	return ..()

/datum/status_effect/reverie/get_examine_text(mob/user, list/P)
	return "[P[THEYRE]] utterly still, lost in [LOWER_TEXT(rest_name)]."

/datum/status_effect/reverie/tick()
	var/mob/living/carbon/human/holder = owner
	if(holder.stat != CONSCIOUS || holder.cmode || !holder.eyesclosed || !holder.in_reverie_posture())
		qdel(src)
		return
	if(holder.getBruteLoss() + holder.getFireLoss() > last_damage)
		to_chat(holder, span_warning("Harm jolts me out of my [LOWER_TEXT(rest_name)]!"))
		qdel(src)
		return
	var/atom/movable/rest_surface = holder.get_rest_surface()
	var/sleepy_mod = rest_surface?.sleepy || 0.5
	var/needed_depth = rest_surface?.sleepy ? REVERIE_DEPTH_SURFACE : REVERIE_DEPTH_FLOOR
	depth++
	if(depth < needed_depth)
		return
	if(depth == needed_depth)
		to_chat(holder, span_notice("My [LOWER_TEXT(rest_name)] deepens and my soul drifts inward."))
	if(holder.apply_rest_recovery(sleepy_mod) & BODYPART_LIFE_UPDATE_HEALTH)
		holder.updatehealth()
	repair_minor_damage(holder, sleepy_mod)
	last_damage = holder.getBruteLoss() + holder.getFireLoss()
	if(holder.has_status_effect(/datum/status_effect/debuff/dreamytime))
		holder.restore_all_dnd_spell_slots()
		holder.finish_night_rest()

/// Mends small mechanical injuries; larger damage still needs a repairer.
/datum/status_effect/reverie/proc/repair_minor_damage(mob/living/carbon/human/holder, sleepy_mod)
	for(var/obj/item/bodypart/part as anything in holder.bodyparts)
		if(part.status != BODYPART_ROBOTIC || !LAZYLEN(part.injuries))
			continue
		var/repaired = FALSE
		for(var/datum/injury/injury as anything in part.injuries.Copy())
			if(!injury.can_heal() || injury.damage_per_injury() > REVERIE_REPAIR_CUTOFF)
				continue
			injury.heal_damage(REVERIE_REPAIR_RATE * sleepy_mod)
			repaired = TRUE
		if(repaired && part.post_damage_change())
			holder.update_damage_overlays()

/datum/status_effect/reverie/proc/on_move_attempt(datum/source, list/move_args)
	SIGNAL_HANDLER
	qdel(src)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/status_effect/reverie/proc/on_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/reverie/proc/on_body_position(datum/source, new_value, old_value)
	SIGNAL_HANDLER
	if(new_value == STANDING_UP && !owner.buckled)
		qdel(src)

/atom/movable/screen/alert/status_effect/reverie
	name = "Reverie"
	desc = "I am still and turned inward. Moving, fighting or harm will end it."
	icon_state = "sleepy"

#undef REVERIE_DEPTH_SURFACE
#undef REVERIE_DEPTH_FLOOR
#undef REVERIE_ROUSE_TIME
#undef REVERIE_REPAIR_CUTOFF
#undef REVERIE_REPAIR_RATE
