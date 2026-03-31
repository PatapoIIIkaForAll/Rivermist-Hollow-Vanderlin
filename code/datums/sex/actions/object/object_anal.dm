/datum/sex_action/object_fuck/object_anal
	name = "Fuck ass with object"
	hole_id = ORGAN_SLOT_ANUS
	var/ouchietext = "owie"
	do_time = 5 SECONDS
	user_priority = 100
	target_priority = 1

/datum/sex_action/object_fuck/object_anal/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!get_sextoy_in_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/object_fuck/object_anal/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_ANUS))
		return FALSE
	if(!get_sextoy_in_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/object_fuck/object_anal/on_start(mob/living/user, mob/living/target)
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
			to_chat(user, span_info("\the [contdildo] will likely spill inside me."))
			to_chat(user, span_smallred("I can pump it with <bold>speed</bold> for faster success."))

	user.visible_message(span_warning("[user] stuffs \the [dildo] in their ass..."))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/object_fuck/object_anal/on_perform(mob/living/user, mob/living/target)
	var/pain_amt = 3 //base pain amt to use
	var/obj/item/dildo = user.get_active_held_item()

	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(can_show_action_message(user, target))
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] fucks their ass with \the [dildo]."))
	if(user.rogue_sneaking || user.alpha <= 100)
		action_volume *= 0.5
	playsound(target, sex_session.get_force_sound(), 50, TRUE, -2, ignore_walls = FALSE)

	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)

	if(istype(user.get_active_held_item(), /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/contdildo = dildo
		var/spillchance = 15*sex_session.speed //multiplies with speed
		if(target.body_position == LYING_DOWN) //double spill odds if lying down due gravity and stuff.
			spillchance *= 2
		if(contdildo.spillable && prob(spillchance) && contdildo.reagents.total_volume)
			var/obj/item/organ/genitals/filling_organ/targetass = target.getorganslot(ORGAN_SLOT_ANUS)
			if(targetass.reagents.total_volume >= (targetass.reagents.maximum_volume -0.5))
				target.visible_message(span_notice("[contdildo] splashes it's contents around [target]'s hole as it is packed full!"))
				contdildo.reagents.reaction(target, TOUCH, sex_session.speed, FALSE)
				contdildo.reagents.remove_all(sex_session.speed)
			else
				target.visible_message(span_notice(pick("[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] fill [target]'s ass.", "[user] feeds [target]'s ass with [english_list(contdildo.reagents.reagent_list)] from \The [contdildo]", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] splash into [target]'s ass.", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] flood into [target]'s ass.")), span_notice(pick("[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] fill my ass.", "I feed my ass with [english_list(contdildo.reagents.reagent_list)] from \The [contdildo]", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] splash into my ass.", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] flood into me.")))
				contdildo.reagents.trans_to(targetass, sex_session.speed, 1, TRUE, FALSE, targetass, FALSE, INJECT, FALSE, TRUE)
			playsound(user.loc, 'sound/misc/mat/endin.ogg', 20, TRUE)
			pain_amt = -8 //liquid ease pain i guess
			target.heal_bodypart_damage(0,1,0,TRUE) //water on burn i guess.

	sex_session.perform_sex_action(user, target, 2, pain_amt, 2, src)
	sex_session.handle_passive_ejaculation()

/datum/sex_action/object_fuck/object_anal/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] cums with their ass!"))
	user.lose_virginity()
	return ORGASM_LOCATION_SELF

/datum/sex_action/object_fuck/object_anal/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo = get_sextoy_in_hand(user)
	user.visible_message(span_warning("[user] pulls \the [dildo] from their ass."))

