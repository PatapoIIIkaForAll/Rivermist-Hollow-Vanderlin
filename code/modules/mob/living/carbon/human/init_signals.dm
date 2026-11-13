/mob/living/carbon/human/register_init_signals()
	. = ..()

	/* ROGUE */
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_CRATEMOVER), PROC_REF(on_cratemover_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_CRATEMOVER), PROC_REF(on_cratemover_trait_loss))

	RegisterSignal(src, SIGNAL_ADDCHEMEFFECT(CE_STIMULANT), PROC_REF(receive_actionboost))
	RegisterSignal(src, SIGNAL_REMOVECHEMEFFECT(CE_STIMULANT), PROC_REF(remove_actionboost))

/mob/living/carbon/proc/receive_actionboost(mob/living/carbon/source, chem_effect)
	var/speedboost = get_chem_effect(chem_effect)
	add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/stimulants, STIMULANT_ACTIONSPEED_INCREASE * speedboost)

/mob/living/carbon/proc/remove_actionboost(mob/living/carbon/source, chem_effect)
	remove_actionspeed_modifier(/datum/actionspeed_modifier/stimulants, TRUE)
