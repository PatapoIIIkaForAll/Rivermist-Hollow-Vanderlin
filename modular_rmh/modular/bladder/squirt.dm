/datum/component/arousal
	COOLDOWN_DECLARE(next_squirt)

/datum/component/arousal/after_ejaculation(intimate = FALSE, mob/living/user, mob/living/target, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer)
	try_squirt(target == parent ? null : target, action)
	return ..()

/datum/component/arousal/proc/try_squirt(mob/living/partner, datum/sex_action/action)
	var/mob/living/carbon/human/squirter = parent
	if(!istype(squirter) || !COOLDOWN_FINISHED(src, next_squirt) || !squirter.can_squirt(partner))
		return FALSE
	if(!prob(get_squirt_chance()) || !squirter.squirt(partner, action))
		return FALSE
	COOLDOWN_START(src, next_squirt, SQUIRT_COOLDOWN)
	return TRUE

/datum/component/arousal/proc/get_squirt_chance()
	var/static/list/urge_chances = SQUIRT_URGE_CHANCES
	var/mob/living/squirter = parent
	. = SQUIRT_BASE_CHANCE
	. += SQUIRT_AROUSAL_CHANCE * min(arousal / MAX_AROUSAL, 1)
	. += SQUIRT_EDGING_CHANCE * min(edging_charge / MAX_EDGING, 1)
	var/datum/component/bladder/bladder = squirter.get_bladder()
	if(bladder)
		. += urge_chances[bladder.urge + 1]
	if(squirter.is_bladder_pressed())
		. += SQUIRT_PRESS_CHANCE
	return min(., SQUIRT_MAX_CHANCE)

/mob/living/proc/is_bladder_pressed()
	for(var/datum/sex_action/bladder/press/press in sex_scene?.active_actions)
		if(press.action_target == src)
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/can_squirt(mob/living/partner)
	if(!watersports_allowed() || is_bladder_at_rest() || climaxes_dry())
		return FALSE
	if((partner?.client || partner?.mind) && !partner.watersports_allowed())
		return FALSE
	return !!get_real_organ(src, ORGAN_SLOT_VAGINA)

/mob/living/carbon/human/proc/squirt(mob/living/partner, datum/sex_action/action)
	var/datum/component/bladder/bladder = get_bladder()
	var/urge_before = bladder?.urge
	var/datum/reagents/gush = gather_squirt(bladder)
	if(gush.total_volume < SQUIRT_MIN_UNITS)
		qdel(gush)
		return FALSE
	var/atom/catcher = get_squirt_catcher(partner, action)
	var/zone = catcher ? null : get_squirt_zone(partner, action)
	watersports_message(span_love(squirt_room_text(src, partner, zone, catcher)), span_love(squirt_own_text(src)))
	if(bladder && bladder.urge < urge_before)
		to_chat(src, span_notice(squirt_eased_text(src)))
	if(zone)
		to_chat(partner, span_love(squirt_partner_text(partner, zone)))
		SEND_SIGNAL(partner, COMSIG_SEX_ADJUST_AROUSAL, SQUIRT_PARTNER_AROUSAL)
	playsound(src, pick(BLADDER_STREAM_SOUNDS), 30, TRUE, -2, ignore_walls = FALSE)
	if(catcher)
		catch_squirt(catcher, gush)
	land_squirt(partner, zone, gush)
	add_stress(/datum/stress_event/squirted)
	qdel(gush)
	return TRUE

/mob/living/carbon/human/proc/gather_squirt(datum/component/bladder/bladder)
	RETURN_TYPE(/datum/reagents)
	var/datum/reagents/gush = new(SQUIRT_MAX_UNITS, NO_REACT)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_real_organ(src, ORGAN_SLOT_VAGINA)
	vagina?.squirt_into(gush)
	if(bladder)
		bladder.release_into(gush, min(bladder.get_volume() * SQUIRT_BLADDER_SHARE, SQUIRT_BLADDER_MAX_UNITS))
	if(HAS_TRAIT(src, TRAIT_HOLY_URINE))
		hallow_fluid(gush)
	return gush

/obj/item/organ/genitals/filling_organ/vagina/proc/squirt_into(datum/reagents/gush)
	if(!reagents || !is_producing())
		return
	var/amount = SQUIRT_NECTAR_UNITS * get_climax_multiplier()
	pay_for_fluid(add_produced_fluid(amount))
	tag_femcum_donor()
	reagents.trans_to(gush, amount, no_react = TRUE)

/mob/living/carbon/human/proc/get_squirt_catcher(mob/living/partner, datum/sex_action/action)
	RETURN_TYPE(/atom)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_real_organ(src, ORGAN_SLOT_VAGINA)
	var/atom/catcher = vagina?.get_leak_pump()
	if(!catcher && action)
		catcher = action.get_climax_container(src, partner, action.action_user, action.action_target, action.action_user)
	if(istype(catcher, /obj/item/reagent_containers) && !catcher.reagents?.holder_full())
		return catcher
	return istype(catcher, /obj/item/clothing) || is_pillow(catcher) ? catcher : null

/mob/living/carbon/human/proc/catch_squirt(atom/catcher, datum/reagents/gush)
	if(istype(catcher, /obj/item/clothing))
		var/obj/item/clothing/garment = catcher
		garment.soak_fluid(gush, gush.total_volume)
	else if(is_pillow(catcher))
		soak_pillow(catcher, gush, gush.total_volume, src)
	else
		gush.trans_to(catcher, gush.total_volume, transfered_by = src)

/mob/living/carbon/human/proc/get_squirt_zone(mob/living/partner, datum/sex_action/action)
	if(!action || !ishuman(partner) || (partner != action.action_user && partner != action.action_target))
		return null
	var/turf/here = get_turf(src)
	return here?.Adjacent(partner) ? action.get_squirt_zone(src) : null

/mob/living/carbon/human/proc/land_squirt(mob/living/carbon/human/partner, zone, datum/reagents/gush)
	if(gush.total_volume <= 0)
		return
	var/mob/living/carbon/human/soaked = src
	var/coat_zone = get_coat_zone_cover(FLUID_COAT_GROIN) ? FLUID_COAT_GROIN : FLUID_COAT_THIGHS
	if(zone && zone != SQUIRT_ZONE_HAND)
		soaked = partner
		coat_zone = zone
	if(coat_zone == FLUID_COAT_FACE && soaked.getorganslot(ORGAN_SLOT_STOMACH))
		sip_reagents(gush, soaked, gush.total_volume * SQUIRT_SWALLOW_SHARE, src)
	if(gush.has_reagent(/datum/reagent/consumable/urine))
		soaked.adjust_hygiene(-BLADDER_PEE_HYGIENE_LOSS)
	var/left = soaked.coat_with_fluid(coat_zone, gush, gush.total_volume)
	var/turf/below = get_turf(soaked)
	if(left <= 0 || !below)
		return
	if(!below.drains_relief())
		leave_fluid_scent(below, src, get_fluid_scent_kind(gush.get_master_reagent()))
	spill_relief(below, gush, left, TRUE)

/datum/sex_action/proc/uses_vagina_of(mob/living/holder)
	if(!holder)
		return FALSE
	if(hole_id == ORGAN_SLOT_VAGINA && get_orifice_receiver(action_user, action_target) == holder)
		return TRUE
	if(holder == action_user && (get_scene_user_slot() == ORGAN_SLOT_VAGINA || (ORGAN_SLOT_VAGINA in uses_user_organs)))
		return TRUE
	return holder == action_target && (get_scene_target_slot() == ORGAN_SLOT_VAGINA || (ORGAN_SLOT_VAGINA in uses_target_organs))

/datum/sex_action/proc/get_squirt_zone(mob/living/squirter)
	if(!uses_vagina_of(squirter))
		return null
	var/by_user = squirter == action_user
	switch(by_user ? get_scene_target_slot() : get_scene_user_slot())
		if(BODY_ZONE_PRECISE_MOUTH)
			return FLUID_COAT_FACE
		if(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
			return FLUID_COAT_GROIN
	switch(by_user ? target_menu_zone_mask : user_menu_zone_mask)
		if(SEX_UI_ZONE_MOUTH)
			return FLUID_COAT_FACE
		if(SEX_UI_ZONE_GENITALS)
			return FLUID_COAT_GROIN
		if(SEX_UI_ZONE_LEGS)
			return FLUID_COAT_FEET
		if(SEX_UI_ZONE_ARMS)
			return SQUIRT_ZONE_HAND
	return null

/datum/sex_action/facesitting/get_squirt_zone(mob/living/squirter)
	return squirter == action_user ? FLUID_COAT_CHEST : null

/datum/sex_action/grind/partner/get_squirt_zone(mob/living/squirter)
	if(get_grind_crotch_cover(squirter))
		return null
	if(squirter == action_user)
		return get_grind_pussy(squirter) ? get_grind_spot_coat_zone(spot, from_behind) : null
	return (spot == GRIND_SPOT_CROTCH && !from_behind) || spot == GRIND_SPOT_LAP ? FLUID_COAT_GROIN : null

/datum/stress_event/squirted
	stress_change = -2
	desc = span_green("I came so hard that I gushed.")
	timer = 5 MINUTES

/datum/stress_event/squirted/get_desc(mob/living/user)
	return span_green(bladder_localized(user, "I came so hard that I gushed.", "На самом пике меня прорвало."))
