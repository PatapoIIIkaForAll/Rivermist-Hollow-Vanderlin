
/obj/item/reagent_containers/glass
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	sellprice = 1
	reagent_flags = OPENCONTAINER
	spillable = TRUE
	possible_item_intents = list(INTENT_POUR, /datum/intent/fill, INTENT_SPLASH, INTENT_GENERIC)
	// Feeding is the common case; splash stays available but must not be picked up by accident.
	default_item_intent = INTENT_POUR
	resistance_flags = ACID_PROOF

/obj/item/reagent_containers/glass/Initialize(mapload, vol)
	. = ..()
	AddComponent(/datum/component/liquids_interaction, TYPE_PROC_REF(/obj/item/reagent_containers/glass, attack_on_liquids_turf))

/obj/item/reagent_containers/glass/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with) || user.used_intent?.type != INTENT_FILL)
		return ..()

	var/mob/living/carbon/human/human_target = interacting_with
	switch(user.zone_selected)
		if(BODY_ZONE_CHEST)
			if(human_target.wear_shirt && !human_target.has_bared_chest() && ((human_target.wear_shirt.flags_inv & HIDEBOOB) || !human_target.wear_shirt.genital_access))
				to_chat(user, span_warning("[human_target]'s chest must be exposed before I can milk [human_target.p_them()]!"))
				return ITEM_INTERACT_BLOCKING

			var/obj/item/organ/genitals/filling_organ/breasts/breasts = human_target.getorganslot(ORGAN_SLOT_BREASTS)
			if(!breasts)
				to_chat(user, span_warning("[human_target] cannot be milked!"))
				return ITEM_INTERACT_BLOCKING
			if(human_target.is_organ_slot_blocked(ORGAN_SLOT_BREASTS))
				to_chat(user, span_warning("Something covers [human_target]'s breasts."))
				return ITEM_INTERACT_BLOCKING
			if(!breasts.reagents?.total_volume)
				to_chat(user, span_warning("[human_target] is out of milk!"))
				return ITEM_INTERACT_BLOCKING
			if(reagents.holder_full())
				to_chat(user, span_warning("[src] is full."))
				return ITEM_INTERACT_BLOCKING

			user.visible_message(span_notice("[user] starts to gently massage [human_target]'s breasts, trying to fill [src] with milk..."), span_notice("I start to gently massage [human_target]'s breasts, trying to fill [src] with milk..."))
			if(!do_after(user, 2 SECONDS, target = human_target))
				return ITEM_INTERACT_BLOCKING

			var/milk_to_take = CLAMP(breasts.reagents.maximum_volume / 6, 1, min(breasts.reagents.total_volume, reagents.maximum_volume - reagents.total_volume))
			breasts.reagents.trans_to(src, milk_to_take, transfered_by = user)
			user.visible_message(span_notice("[user] milks [human_target] into [src]."), span_notice("I milk [human_target] into [src]."))
			return ITEM_INTERACT_SUCCESS

		if(BODY_ZONE_PRECISE_GROIN)
			if(human_target.wear_pants && ((human_target.wear_pants.flags_inv & HIDECROTCH) || !human_target.wear_pants.genital_access))
				to_chat(user, span_warning("[human_target]'s groin must be exposed before I can collect [human_target.p_their()] fluids!"))
				return ITEM_INTERACT_BLOCKING

			var/obj/item/organ/genitals/filling_organ/vagina/vagina = human_target.getorganslot(ORGAN_SLOT_VAGINA)
			if(!vagina)
				to_chat(user, span_warning("[human_target] has nothing to collect from!"))
				return ITEM_INTERACT_BLOCKING
			if(human_target.is_organ_slot_blocked(ORGAN_SLOT_VAGINA))
				to_chat(user, span_warning("Something covers [human_target]'s loins."))
				return ITEM_INTERACT_BLOCKING
			if(!vagina.reagents?.total_volume)
				to_chat(user, span_warning("[human_target]'s loins are empty!"))
				return ITEM_INTERACT_BLOCKING
			if(reagents.holder_full())
				to_chat(user, span_warning("[src] is full."))
				return ITEM_INTERACT_BLOCKING

			user.visible_message(span_notice("[user] positions [src] under [human_target]'s loins and waits..."), span_notice("I position [src] under [human_target]'s loins..."))
			if(!do_after(user, 4 SECONDS, target = human_target))
				return ITEM_INTERACT_BLOCKING

			var/fluid_to_take = CLAMP(vagina.reagents.maximum_volume / 2, 1, min(vagina.reagents.total_volume, reagents.maximum_volume - reagents.total_volume))
			vagina.reagents.trans_to(src, fluid_to_take, transfered_by = user)
			user.visible_message(span_notice("[user] collects fluid from [human_target]'s loins into [src]."), span_notice("I collect fluid from [human_target]'s loins into [src]."))
			return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/item/reagent_containers/glass/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/reagent_containers/food/snacks/egg))
		return ..()

	if(reagents.holder_full())
		to_chat(user, span_notice("[src] is full."))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/reagent_containers/food/snacks/egg/egg = tool
	to_chat(user, span_notice("I break [egg] into [src]."))
	egg.reagents.trans_to(src, egg.reagents.total_volume, transfered_by = user)
	qdel(egg)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/glass/proc/attack_on_liquids_turf(obj/item/reagent_containers/my_beaker, turf/T, mob/living/user, obj/effect/abstract/liquid_turf/liquids)
	if(user.used_intent != /datum/intent/fill)
		return FALSE

	if(!my_beaker.spillable)
		return FALSE

	if(user.cmode)
		return FALSE

	if(liquids.fire_state) //Use an extinguisher first
		to_chat(user, span_danger("You can't scoop up anything while it's on fire!"))
		return FALSE

	if(liquids.liquid_group.expected_turf_height == 1)
		to_chat(user, span_danger("The puddle is too shallow to scoop anything up!"))
		return FALSE

	var/free_space = my_beaker.reagents.maximum_volume - my_beaker.reagents.total_volume
	if(free_space <= 0)
		to_chat(user, span_danger("You can't fit any more liquids inside [my_beaker]!"))
		return FALSE

	var/desired_transfer = my_beaker.amount_per_transfer_from_this
	if(desired_transfer > free_space)
		desired_transfer = free_space

	if(desired_transfer > liquids.liquid_group.reagents_per_turf)
		desired_transfer = liquids.liquid_group.reagents_per_turf

	liquids.liquid_group.trans_to_seperate_group(my_beaker.reagents, desired_transfer, liquids)
	to_chat(user, span_notice("You scoop up around [UNIT_FORM_STRING(round(desired_transfer))] of liquids with [my_beaker]."))
	user.changeNext_move(CLICK_CD_MELEE)

	return TRUE

/datum/intent/fill
	name = "fill"
	icon_state = "infill"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0

/datum/intent/pour
	name = "feed"
	icon_state = "infeed"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0

/datum/intent/splash
	name = "splash"
	icon_state = "insplash"
	chargetime = 0
	noaa = TRUE
	candodge = TRUE
	misscost = 0
	reach = 2

/datum/intent/soak
	name = "soak"
	icon_state = "insoak"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0

/datum/intent/wring
	name = "wring"
	icon_state = "inwring"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0
