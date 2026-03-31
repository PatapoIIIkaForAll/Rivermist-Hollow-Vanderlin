#define SEELIE_GLAMOUR_ORGASM_BREAK_CHANCE 10
#define SEELIE_GLAMOUR_CHECK_INTERVAL 2 SECONDS

/datum/action/cooldown/spell/undirected/seelie_grand_glamour
	name = "Seelie Glamour"
	desc = "Wrap yourself in fae glamour and stand at mortal size until the spell is broken."
	button_icon_state = "trollshape"
	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 3 SECONDS
	invocation = "Blend in."
	invocation_type = INVOCATION_WHISPER

/datum/action/cooldown/spell/undirected/seelie_grand_glamour/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/seelie = owner
	if(istype(seelie) && seelie.is_seelie())
		return TRUE

	if(feedback)
		owner.balloon_alert(owner, "Only seelies can weave this glamour!")
	return FALSE

/datum/action/cooldown/spell/undirected/seelie_grand_glamour/cast(atom/cast_on)
	. = ..()

	var/mob/living/carbon/human/seelie = owner
	if(!istype(seelie))
		return

	if(seelie.has_status_effect(/datum/status_effect/buff/seelie_grand_glamour))
		seelie.remove_status_effect(/datum/status_effect/buff/seelie_grand_glamour)
		return

	if(seelie.apply_status_effect(/datum/status_effect/buff/seelie_grand_glamour))
		return

	reset_spell_cooldown()

/datum/status_effect/buff/seelie_grand_glamour
	id = "seelie_grand_glamour"
	duration = -1
	tick_interval = SEELIE_GLAMOUR_CHECK_INTERVAL
	alert_type = /atom/movable/screen/alert/status_effect/buff/seelie_grand_glamour

/atom/movable/screen/alert/status_effect/buff/seelie_grand_glamour
	name = "Grand Glamour"
	desc = "A fae glamour is holding you at mortal size."
	icon_state = "trollshape"

/datum/status_effect/buff/seelie_grand_glamour/on_apply()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/seelie = owner
	if(!istype(seelie) || !seelie.is_seelie())
		return FALSE
	if(seelie.IsSleeping())
		return FALSE
	if(interrupt_if_antimagic())
		return FALSE

	RegisterSignal(seelie, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(on_sleeping))
	RegisterSignal(seelie, COMSIG_SEX_ORGASM, PROC_REF(on_orgasm))
	RegisterSignal(seelie, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))
	RegisterSignal(seelie, COMSIG_MOB_APPLIED_STATUS_EFFECT, PROC_REF(on_status_effect_applied))

	if(!isturf(seelie.loc) && !ismob(seelie.loc))
		seelie.seelie_leave_container(TRUE)

	REMOVE_TRAIT(seelie, TRAIT_TINY, SPECIES_TRAIT)
	seelie.pass_flags &= ~(PASSTABLE | PASSMOB)
	seelie.seelie_ensure_scale()
	seelie.visible_message(
		span_notice("[seelie] swells to mortal size beneath a shimmering glamour."),
		span_notice("I swell to mortal size beneath a shimmering glamour."),
	)
	return TRUE

/datum/status_effect/buff/seelie_grand_glamour/on_remove()
	var/mob/living/carbon/human/seelie = owner
	if(istype(seelie))
		UnregisterSignal(seelie, list(
			COMSIG_LIVING_STATUS_SLEEP,
			COMSIG_SEX_ORGASM,
			COMSIG_MOB_EQUIPPED_ITEM,
			COMSIG_MOB_APPLIED_STATUS_EFFECT,
		))

	. = ..()

	if(!istype(seelie) || !seelie.is_seelie())
		return

	ADD_TRAIT(seelie, TRAIT_TINY, SPECIES_TRAIT)
	seelie.pass_flags |= (PASSTABLE | PASSMOB)
	seelie.seelie_ensure_scale()
	seelie.visible_message(
		span_notice("[seelie] shrinks back to a tiny fae form."),
		span_notice("I shrink back to my tiny fae form."),
	)

/datum/status_effect/buff/seelie_grand_glamour/tick()
	interrupt_if_antimagic()

/datum/status_effect/buff/seelie_grand_glamour/proc/interrupt_if_antimagic()
	var/mob/living/carbon/human/seelie = owner
	if(!istype(seelie))
		return FALSE
	if(seelie.can_cast_magic(MAGIC_RESISTANCE) && !HAS_TRAIT(seelie, TRAIT_ANTIMAGIC))
		return FALSE

	break_glamour("Antimagic tears my glamour apart!", TRUE)
	return TRUE

/datum/status_effect/buff/seelie_grand_glamour/proc/break_glamour(message, play_antimagic_sound = FALSE)
	var/mob/living/carbon/human/seelie = owner
	if(!istype(seelie))
		qdel(src)
		return

	if(message)
		to_chat(seelie, span_warning(message))
	if(play_antimagic_sound)
		playsound(seelie, 'sound/magic/antimagic.ogg', 100, FALSE)

	qdel(src)

/datum/status_effect/buff/seelie_grand_glamour/proc/on_sleeping(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER

	if(amount <= 0)
		return

	break_glamour("Sleep steals the words holding my glamour together.")

/datum/status_effect/buff/seelie_grand_glamour/proc/on_orgasm(datum/source)
	SIGNAL_HANDLER

	if(!prob(SEELIE_GLAMOUR_ORGASM_BREAK_CHANCE))
		return

	break_glamour("Pleasure breaks my concentration and the glamour slips.")

/datum/status_effect/buff/seelie_grand_glamour/proc/on_equipped_item(datum/source, obj/item/equipped_item, slot)
	SIGNAL_HANDLER

	interrupt_if_antimagic()

/datum/status_effect/buff/seelie_grand_glamour/proc/on_status_effect_applied(datum/source, datum/status_effect/applied_effect)
	SIGNAL_HANDLER

	if(istype(applied_effect, /datum/status_effect/antimagic))
		break_glamour("A dull aura snuffs out my glamour.", TRUE)

#undef SEELIE_GLAMOUR_ORGASM_BREAK_CHANCE
#undef SEELIE_GLAMOUR_CHECK_INTERVAL
