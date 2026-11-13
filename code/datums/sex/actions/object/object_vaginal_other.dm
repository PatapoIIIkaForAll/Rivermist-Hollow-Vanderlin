/datum/sex_action/object_fuck/object_vaginal_other
	name = "Toy pussy"
	var/ouchietext = "owie"
	check_same_tile = FALSE

/datum/sex_action/object_fuck/object_vaginal_other/shows_on_menu(mob/living/user, mob/living/target)
	var/obj/item/dildo = get_sextoy_in_hand(user)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA, null, dildo))
		return FALSE
	if(!dildo)
		return FALSE
	return TRUE

/datum/sex_action/object_fuck/object_vaginal_other/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/dildo = get_sextoy_in_hand(user)
	if(user == target)
		return FALSE
	if(!dildo)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_VAGINA, null, dildo))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/object_fuck/object_vaginal_other/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/dildo = user.get_active_held_item()
	if(istype(user.get_active_held_item(), /obj/item/weapon) || istype(user.get_active_held_item(), /obj/item/ammo_casing))
		to_chat(user, span_userdanger("\the [dildo] will hurt [target]!"))
		return FALSE

	if(istype(user.get_active_held_item(), /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/contdildo = dildo
		if(contdildo.spillable)
			to_chat(user, span_info("\the [contdildo] will likely spill inside [target]."))
			to_chat(user, span_smallred("I can pump it with <bold>speed</bold> for faster success."))

	// Still pressing at the opening: nothing went in yet, so no entry line or sound.
	if(orifice_pressing)
		return .
	user.visible_message(span_warning("[user] stuffs \the [dildo] in [target]'s cunt..."))
	var/used_sex_volume = sex_volume
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/object_fuck/object_vaginal_other/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 3 //base pain amt to use
	var/obj/item/dildo = user.get_active_held_item()

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks [target]'s cunt with \the [dildo]."))
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		action_volume *= 0.5
	var/used_sex_volume = sex_volume
	playsound(target, get_force_sound(), used_sex_volume, TRUE, -2, ignore_walls = FALSE)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	if(istype(user.get_active_held_item(), /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/contdildo = dildo
		var/spillchance = 15*speed //multiplies with speed
		if(target.body_position == LYING_DOWN) //double spill odds if lying down due gravity and stuff.
			spillchance *= 2
		if(contdildo.spillable && prob(spillchance) && contdildo.reagents.total_volume)
			var/obj/item/organ/genitals/filling_organ/targetpuss = target.getorganslot(ORGAN_SLOT_VAGINA)
			if(targetpuss.reagents.total_volume >= (targetpuss.reagents.maximum_volume -0.5))
				target.visible_message(span_notice("[contdildo] splashes it's contents around [target]'s hole as it is packed full!"))
				contdildo.reagents.reaction(target, TOUCH, speed, FALSE)
				var/turf/targetloc = target.loc
				targetloc.add_liquid_from_reagents(contdildo.reagents, amount = speed)
			else
				target.visible_message(span_notice(pick("[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] fill [target]'s pussy.", "[user] feeds [target]'s pussy with [english_list(contdildo.reagents.reagent_list)] from \The [contdildo]", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] splash into [target]'s pussy.", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] flood into [target]'s pussy.")), span_notice(pick("[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] fill my pussy.", "I feed my pussy with [english_list(contdildo.reagents.reagent_list)] from \The [contdildo]", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] splash into my pussy.", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] flood into me.")))
				contdildo.reagents.trans_to(targetpuss, speed, 1, TRUE, FALSE, targetpuss, FALSE, INJECT, FALSE, TRUE)
			playsound(user.loc, 'sound/misc/mat/endin.ogg', 20, TRUE)
			pain_amt = max(pain_amt - 8, 0) //liquid ease pain i guess
			target.heal_bodypart_damage(0,1,0,TRUE) //water on burn i guess.

	perform_sex_action(target, user, 2, pain_amt, 2)
	handle_passive_ejaculation(target)


/datum/sex_action/object_fuck/object_vaginal_other/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		target.visible_message(span_love("[user] creams themselves around [target]'s thrusting dildo!"))
		user.lose_virginity()
		return ORGASM_LOCATION_SELF

/datum/sex_action/object_fuck/object_vaginal_other/on_finish(mob/living/user, mob/living/target)
	var/obj/item/dildo = selected_toy || get_sextoy_in_hand(user)
	// The parent clears the pressing state, so read it first.
	var/was_pressing = orifice_pressing
	. = ..()
	if(was_pressing)
		user.visible_message(span_warning("[user] gives up pressing \the [dildo] against [target]'s cunt."))
		return
	user.visible_message(span_warning("[user] pulls \the [dildo] from [target]'s cunt."))

