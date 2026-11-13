/// Fits the pump in the user's hand over the matching organ, on themselves or a partner.
/datum/sex_action/attach_fluid_pump
	name = "Attach pump"
	description = "Fit the pump in your hand over the matching organ. It covers the organ until removed."
	continous = FALSE
	do_time = 3 SECONDS
	requires_free_hands = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS | SEX_UI_ZONE_BODY

/datum/sex_action/attach_fluid_pump/proc/get_held_pump(mob/living/user)
	var/obj/item/reagent_containers/glass/fluid_pump/pump = user?.get_active_held_item()
	return istype(pump) ? pump : null

/datum/sex_action/attach_fluid_pump/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_held_pump(user)
	if(!pump || !target.getorganslot(pump.pump_slot))
		return FALSE
	return !target.is_organ_slot_blocked(pump.pump_slot)

/datum/sex_action/attach_fluid_pump/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_held_pump(user)
	if(!pump || !target.getorganslot(pump.pump_slot) || target.is_organ_slot_blocked(pump.pump_slot))
		return FALSE
	if(check_sex_lock(target, pump.pump_slot))
		return FALSE
	return check_location_accessible(user, target, pump.pump_zone, TRUE)

/datum/sex_action/attach_fluid_pump/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_held_pump(user)
	if(!pump)
		return
	var/whose = user == target ? user.p_their() : "[target]'s"
	user.visible_message(span_warning("[user] lines \the [pump] up with [whose] [pump.organ_word]..."))

/datum/sex_action/attach_fluid_pump/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_held_pump(user)
	if(!pump)
		return
	var/result = pump.attach_to(target)
	if(result != INSERT_FEEDBACK_OK && result != INSERT_FEEDBACK_ALMOST_FULL)
		to_chat(user, span_warning("\The [pump] will not fit there right now."))
		return
	var/whose = user == target ? user.p_their() : "[target]'s"
	user.visible_message(span_love("[user] fits \the [pump] over [whose] [pump.organ_word], and the brass pump wheezes to life."))
	playsound(target, list('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg'), sex_volume, TRUE, ignore_walls = FALSE)
	user.update_inv_hands()

/datum/sex_action/attach_fluid_pump/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, user.get_active_precise_hand())

/// Takes a fitted pump off, into the user's hand; works on yourself or a partner.
/datum/sex_action/remove_fluid_pump
	name = "Remove pump"
	description = "Pop a fitted pump off, reservoir and all."
	continous = FALSE
	do_time = 2 SECONDS
	requires_free_hands = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS | SEX_UI_ZONE_BODY

/// The first pump fitted on the target: breasts, then cock, then pussy.
/datum/sex_action/remove_fluid_pump/proc/get_fitted_pump(mob/living/target)
	for(var/slot in list(ORGAN_SLOT_BREASTS, ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA))
		var/obj/item/organ/organ = target?.getorganslot(slot)
		if(!organ)
			continue
		var/obj/item/reagent_containers/glass/fluid_pump/pump = locate() in organ.contents
		if(pump)
			return pump
	return null

/datum/sex_action/remove_fluid_pump/shows_on_menu(mob/living/user, mob/living/target)
	return !!get_fitted_pump(target)

/datum/sex_action/remove_fluid_pump/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_fitted_pump(target)
	if(!pump)
		return FALSE
	return check_location_accessible(user, target, pump.pump_zone, TRUE)

/datum/sex_action/remove_fluid_pump/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_fitted_pump(target)
	if(!pump)
		return
	var/whose = user == target ? user.p_their() : "[target]'s"
	user.visible_message(span_warning("[user] works at the seal of \the [pump] on [whose] [pump.organ_word]..."))

/datum/sex_action/remove_fluid_pump/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/reagent_containers/glass/fluid_pump/pump = get_fitted_pump(target)
	if(!pump)
		return
	var/whose = user == target ? user.p_their() : "[target]'s"
	var/organ_word = pump.organ_word
	if(!pump.detach(user))
		to_chat(user, span_warning("\The [pump] will not come off."))
		return
	user.visible_message(span_notice("[user] pops \the [pump] off [whose] [organ_word] with a wet sound."))
	playsound(target, 'sound/misc/mat/insert (1).ogg', sex_volume, TRUE, ignore_walls = FALSE)
	user.update_inv_hands()
