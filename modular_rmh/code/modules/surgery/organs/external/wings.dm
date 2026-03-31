/obj/item/organ/wings/flight/moth
	name = "fluvian wings"
	desc = "A powdery pair of moth wings."
	accessory_type = /datum/sprite_accessory/wings/moth/plain
	flight_for_species = list(SPEC_ID_FLUVIAN)
	flight_time = 20 SECONDS

/obj/item/organ/wings/flight/seelie
	name = "seelie wings"
	desc = "A delicate set of shimmering faerie wings."
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 0.35
	accessory_type = /datum/sprite_accessory/wings/seelie/fairy
	flight_for_species = list(SPEC_ID_SEELIE)

/obj/item/organ/wings/flight/seelie/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(target))
		return ..()

	var/mob/living/carbon/human/target_human = target
	if(!target_human.is_seelie())
		return ..()
	if(target_human.getorganslot(ORGAN_SLOT_WINGS))
		to_chat(user, span_warning("[target_human] already has wings."))
		return TRUE
	if(!do_after(user, 2 SECONDS, target = target_human))
		return TRUE
	if(target_human.getorganslot(ORGAN_SLOT_WINGS))
		return TRUE

	Insert(target_human, TRUE, TRUE)
	target_human.set_resting(FALSE, silent = TRUE)
	target_human.set_body_position(STANDING_UP)
	target_human.seelie_ensure_scale()
	target_human.update_body()

	var/datum/species/seelie/seelie_species = target_human.dna?.species
	seelie_species?.enforce_wing_requirement(target_human)

	target_human.visible_message(
		span_notice("[user] carefully reattaches wings to [target_human]."),
		span_notice("My wings are reattached.")
	)
	return TRUE
