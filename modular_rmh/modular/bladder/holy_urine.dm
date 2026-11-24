/datum/reagent/consumable/urine/holy
	name = "Holy Urine"
	description = "Golden water passed by a servant of the gods. A faint radiance lingers in it, and it mends those who drink it."
	color = "#fff1b0"
	taste_description = "holiness"

/datum/reagent/consumable/urine/holy/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_chem_effect(CE_BLOODRESTORE, HOLY_URINE_BLOOD * HOLY_URINE_POTENCY, "[type]")

/datum/reagent/consumable/urine/holy/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_chem_effect(CE_BLOODRESTORE, "[type]")

/datum/reagent/consumable/urine/holy/on_mob_life(mob/living/carbon/M, efficiency)
	var/potency = HOLY_URINE_POTENCY * efficiency
	M.heal_wounds(HOLY_URINE_WOUNDS * potency)
	if(volume > HOLY_URINE_MIN_VOLUME)
		M.adjustBruteLoss(-HOLY_URINE_FLESH * REM * potency, 0)
		M.adjustFireLoss(-HOLY_URINE_FLESH * REM * potency, 0)
		M.adjustCloneLoss(-HOLY_URINE_FLESH * REM * potency, 0)
		M.adjustToxLoss(-HOLY_URINE_POISON * potency, 0)
		M.adjustOxyLoss(-HOLY_URINE_BREATH * potency, 0)
		heal_organs(M, HOLY_URINE_ORGANS * potency)
	..()
	return TRUE

/datum/reagent/consumable/urine/holy/proc/heal_organs(mob/living/carbon/M, amount)
	for(var/obj/item/organ/organ as anything in M.internal_organs)
		if(organ.damage > 0)
			organ.applyOrganDamage(-amount)

/proc/hallow_fluid(datum/reagents/fluid)
	var/volume = fluid.total_volume
	if(volume <= 0)
		return
	fluid.clear_reagents()
	fluid.add_reagent(/datum/reagent/consumable/urine/holy, volume)
