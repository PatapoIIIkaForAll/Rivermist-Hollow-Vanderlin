// Giving birth before the Divines: a full-term carrier sees the action only while standing in a chapel.

/// Labour pains before the birth, each this long; moving or turning away stops the labour.
#define CHAPEL_BIRTH_CONTRACTIONS 3
#define CHAPEL_BIRTH_CONTRACTION_TIME (20 SECONDS)
/// Stamina each contraction costs; the birth itself costs twice as much.
#define CHAPEL_BIRTH_CONTRACTION_STAMINA 15

/// TRUE inside a town chapel. The crypt under the Rivermist chapel does not count.
/proc/is_chapel_area(area/place)
	if(istype(place, /area/indoors/town/rmh/chapel/basement))
		return FALSE
	return istype(place, /area/indoors/town/rmh/chapel) || istype(place, /area/indoors/town/church/chapel)

/// On a full-term womb: grants its carrier the birth action in a chapel and takes it away outside.
/datum/component/chapel_birth
	var/datum/action/chapel_birth/birth_action
	var/in_labour = FALSE

/datum/component/chapel_birth/Initialize()
	if(!istype(parent, /obj/item/organ/genitals/filling_organ))
		return COMPONENT_INCOMPATIBLE
	birth_action = new(src)

/datum/component/chapel_birth/Destroy()
	QDEL_NULL(birth_action)
	return ..()

/datum/component/chapel_birth/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_INSERTED, PROC_REF(on_womb_inserted))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_womb_removed))
	var/obj/item/organ/womb = parent
	if(womb.owner)
		watch_carrier(womb.owner)

/datum/component/chapel_birth/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ORGAN_INSERTED, COMSIG_ORGAN_REMOVED))
	var/obj/item/organ/womb = parent
	if(womb.owner)
		stop_watching_carrier(womb.owner)

/datum/component/chapel_birth/proc/on_womb_inserted(obj/item/organ/source, mob/living/new_carrier)
	SIGNAL_HANDLER
	watch_carrier(new_carrier)

/datum/component/chapel_birth/proc/on_womb_removed(obj/item/organ/source, mob/living/old_carrier)
	SIGNAL_HANDLER
	stop_watching_carrier(old_carrier)

/datum/component/chapel_birth/proc/watch_carrier(mob/living/carrier)
	RegisterSignal(carrier, COMSIG_ENTER_AREA, PROC_REF(on_carrier_entered_area))
	update_button(carrier, get_area(carrier))

/datum/component/chapel_birth/proc/stop_watching_carrier(mob/living/carrier)
	UnregisterSignal(carrier, COMSIG_ENTER_AREA)
	if(birth_action?.owner)
		birth_action.Remove(birth_action.owner)

/datum/component/chapel_birth/proc/on_carrier_entered_area(mob/living/carrier, area/new_area)
	SIGNAL_HANDLER
	update_button(carrier, new_area)

/datum/component/chapel_birth/proc/update_button(mob/living/carrier, area/current_area)
	if(is_chapel_area(current_area))
		birth_action.Grant(carrier)
	else if(birth_action.owner)
		birth_action.Remove(birth_action.owner)

/// Checked before and through the labour: conscious, still full-term, still in a chapel.
/datum/component/chapel_birth/proc/can_give_birth(mob/living/carbon/mother)
	if(QDELETED(src) || QDELETED(mother) || mother.stat != CONSCIOUS)
		return FALSE
	var/obj/item/organ/genitals/filling_organ/womb = parent
	if(womb.owner != mother || !womb.pregnant || womb.conventional_pregnancy_stage < PREGNANCY_MAX_STAGE)
		return FALSE
	return is_chapel_area(get_area(mother))

/datum/component/chapel_birth/proc/give_birth(mob/living/carbon/mother)
	if(in_labour || !can_give_birth(mother))
		return FALSE
	in_labour = TRUE
	mother.visible_message(
		span_notice("[mother] kneels before the altar, one hand pressed to [mother.p_their()] swollen belly."),
		span_love("I kneel before the Divines and let the pains come."),
	)
	var/datum/callback/still_able = CALLBACK(src, PROC_REF(can_give_birth), mother)
	for(var/contraction in 1 to CHAPEL_BIRTH_CONTRACTIONS)
		if(!do_after(mother, CHAPEL_BIRTH_CONTRACTION_TIME, extra_checks = still_able))
			in_labour = FALSE
			if(!QDELETED(src))
				to_chat(mother, span_warning("The pains ebb away. The child will have to wait."))
			return FALSE
		if(contraction < CHAPEL_BIRTH_CONTRACTIONS)
			contract(mother, contraction)
	in_labour = FALSE
	deliver(mother)
	return TRUE

/datum/component/chapel_birth/proc/contract(mob/living/carbon/mother, contraction)
	if(contraction == 1)
		mother.visible_message(
			span_warning("[mother] doubles over with a groan, clutching [mother.p_their()] belly."),
			span_love("A deep cramp rolls through my belly. The child is coming."),
		)
	else
		mother.visible_message(
			span_warning("[mother] bears down hard before the altar, breath ragged."),
			span_love("The pains come hard and close now. I have to push."),
		)
	mother.emote("painmoan", forced = TRUE)
	mother.adjust_stamina(CHAPEL_BIRTH_CONTRACTION_STAMINA)

/datum/component/chapel_birth/proc/deliver(mob/living/carbon/mother)
	var/obj/item/organ/genitals/filling_organ/womb = parent
	mother.visible_message(
		span_love_climax("[mother] gives birth before the altar. A soft light gathers around the newborn, and when it fades, the child is gone."),
		span_love_climax("My child is born. Warm light gathers around the little one, and when it fades, the Divines have taken my child into their keeping."),
	)
	mother.adjust_stamina(CHAPEL_BIRTH_CONTRACTION_STAMINA * 2)
	mother.record_labour()
	mother.apply_status_effect(/datum/status_effect/birth_worn)
	// Ending the pregnancy deletes this component, so it comes last.
	womb.clear_conventional_pregnancy(silent = TRUE)

/datum/action/chapel_birth
	name = "Give Birth Before the Divines"
	desc = "Labour before the altar for a minute without moving. The Divines take the child into their keeping, and the pregnancy ends."
	button_icon_state = "eora_bless"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/chapel_birth/Trigger(trigger_flags)
	. = ..()
	if(!. || !iscarbon(owner))
		return FALSE
	var/datum/component/chapel_birth/birth = target
	var/mob/living/carbon/mother = owner
	birth.give_birth(mother)
	return TRUE

#undef CHAPEL_BIRTH_CONTRACTIONS
#undef CHAPEL_BIRTH_CONTRACTION_TIME
#undef CHAPEL_BIRTH_CONTRACTION_STAMINA
