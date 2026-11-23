/datum/fluid_modifier/urethral_overfill
	affected_slots = list(ORGAN_SLOT_TESTICLES)
	capacity_multiplier = DOCKING_OVERFILL_MULTIPLIER
	blocks_production = TRUE

/datum/climax_spurts/container/proc/get_container_holder()
	var/obj/item/organ/organ = container
	if(istype(organ) && organ.owner)
		return organ.owner
	return container

/datum/sex_action/docking/urethra
	abstract_type = /datum/sex_action/docking/urethra
	dock_kind = DOCKING_KIND_URETHRA

/datum/sex_action/docking/urethra/fits(mob/living/user, mob/living/target)
	if(!user || !target || user == target)
		return FALSE
	return !!(get_real_penis(user) && get_real_penis(target))

/datum/sex_action/docking/urethra/is_stretched(obj/item/organ/genitals/penis/inner, obj/item/organ/genitals/penis/sleeve)
	return inner.get_insert_girth() > sleeve.get_insert_girth() * DOCKING_URETHRA_FIT_RATIO

/datum/sex_action/docking/urethra/get_sleeve_pain(stretched)
	return DOCKING_URETHRA_PAIN + (stretched ? DOCKING_URETHRA_STRETCH_PAIN : 0)

/datum/sex_action/docking/urethra/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/climaxer_is_sleeve = user == get_sleeve_holder(action_user, action_target)
	if(!has_seed(user))
		user.visible_message(span_love(docking_urethra_dry_text(user, target)))
		return ORGASM_LOCATION_ONTO
	var/obj/item/organ/genitals/filling_organ/testicles/balls = prepare_overfill(target)
	user.visible_message(span_love(docking_urethra_climax_text(user, target, climaxer_is_sleeve, !balls)))
	if(!balls)
		return ORGASM_LOCATION_ONTO
	playsound(target, 'sound/misc/mat/endin.ogg', 50, TRUE, ignore_walls = FALSE)
	return ORGASM_LOCATION_CONTAINER

/datum/sex_action/docking/urethra/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	return get_overfill_room(target)

/datum/sex_action/docking/urethra/proc/has_seed(mob/living/climaxer)
	var/obj/item/organ/genitals/filling_organ/testicles/load = climaxer?.getorganslot(ORGAN_SLOT_TESTICLES)
	return !!load?.reagents?.total_volume

/datum/sex_action/docking/urethra/proc/get_overfill_room(mob/living/receiver)
	var/obj/item/organ/genitals/filling_organ/testicles/balls = receiver?.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!istype(balls) || !balls.reagents || balls.reagents.holder_full())
		return null
	return balls

/datum/sex_action/docking/urethra/proc/prepare_overfill(mob/living/receiver)
	var/obj/item/organ/genitals/filling_organ/testicles/balls = receiver?.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!istype(balls) || !balls.reagents)
		return null
	if(!receiver.has_fluid_modifier(/datum/fluid_modifier/urethral_overfill, DOCKING_OVERFILL_SOURCE))
		receiver.add_fluid_modifier(/datum/fluid_modifier/urethral_overfill, DOCKING_OVERFILL_SOURCE)
	balls.update_reagent_capacity()
	receiver.apply_status_effect(/datum/status_effect/urethral_overfill)
	return get_overfill_room(receiver)

/datum/sex_action/docking/urethra/wrap
	name = "Dock with urethra"
	menu_tip = "Take the tip of their cock into your urethra."
	sleeve_is_user = TRUE

/datum/sex_action/docking/urethra/enter
	name = "Dock into urethra"
	menu_tip = "Push into their urethra and overfill their balls."
	sleeve_is_user = FALSE

/datum/status_effect/urethral_overfill
	id = "urethral_overfill"
	duration = -1
	tick_interval = DOCKING_OVERFILL_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/announced = FALSE
	COOLDOWN_DECLARE(next_reminder)

/datum/status_effect/urethral_overfill/on_remove()
	owner.remove_fluid_modifier(/datum/fluid_modifier/urethral_overfill, DOCKING_OVERFILL_SOURCE)
	var/obj/item/organ/genitals/filling_organ/testicles/balls = owner.getorganslot(ORGAN_SLOT_TESTICLES)
	if(istype(balls) && balls.reagents)
		balls.update_reagent_capacity()
	return ..()

/datum/status_effect/urethral_overfill/tick()
	var/obj/item/organ/genitals/filling_organ/testicles/balls = owner.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!istype(balls) || !balls.reagents)
		qdel(src)
		return
	var/plugged = is_plugged()
	var/excess = balls.reagents.total_volume - get_normal_capacity(balls)
	if(excess <= 0)
		if(!plugged)
			finish()
		return
	if(!announced)
		announce()
	if(!plugged)
		balls.leak_reagents(min(excess, DOCKING_OVERFILL_DRIP))
	if(owner.stat == CONSCIOUS && COOLDOWN_FINISHED(src, next_reminder))
		COOLDOWN_START(src, next_reminder, DOCKING_OVERFILL_REMINDER)
		to_chat(owner, span_love(docking_overfill_reminder_text(owner)))

/datum/status_effect/urethral_overfill/proc/is_plugged()
	for(var/datum/sex_action/docking/urethra/dock in owner.sex_scene?.active_actions)
		if(owner == dock.action_user || owner == dock.action_target)
			return TRUE
	return FALSE

/datum/status_effect/urethral_overfill/proc/get_normal_capacity(obj/item/organ/genitals/filling_organ/testicles/balls)
	owner.remove_fluid_modifier(/datum/fluid_modifier/urethral_overfill, DOCKING_OVERFILL_SOURCE)
	. = balls.get_reagent_capacity()
	owner.add_fluid_modifier(/datum/fluid_modifier/urethral_overfill, DOCKING_OVERFILL_SOURCE)

/datum/status_effect/urethral_overfill/proc/announce()
	announced = TRUE
	COOLDOWN_START(src, next_reminder, DOCKING_OVERFILL_REMINDER)
	var/atom/movable/screen/alert/status_effect/alert = owner.throw_alert(id, /atom/movable/screen/alert/status_effect/debuff/urethral_overfill)
	if(alert)
		alert.attached_effect = src
		alert.name = docking_overfill_alert_name(owner)
		alert.desc = docking_overfill_alert_desc(owner)
		linked_alert = alert
	if(owner.stat == CONSCIOUS)
		to_chat(owner, span_love(docking_overfill_start_text(owner)))

/datum/status_effect/urethral_overfill/proc/finish()
	if(announced && owner.stat == CONSCIOUS)
		to_chat(owner, span_notice(docking_overfill_relief_text(owner)))
	qdel(src)

/atom/movable/screen/alert/status_effect/debuff/urethral_overfill
	name = "Overfilled"
	desc = "My balls are swollen past full."
	icon_state = "debuff"
