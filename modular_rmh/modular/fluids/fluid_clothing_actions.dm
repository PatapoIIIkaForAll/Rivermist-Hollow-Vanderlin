/// Licks the fluid soaked into the clothes a partner is wearing.
/datum/sex_action/lick_soaked_clothes
	abstract_type = /datum/sex_action/lick_soaked_clothes
	name = "Lick clothes"
	description = "Suck the fluid out of the soaked clothes they are wearing."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	check_same_tile = FALSE
	/// Which wet spot is licked.
	var/stain_zone = FLUID_STAIN_GROIN
	/// How the spot is named in messages.
	var/spot_name = "crotch"

/datum/sex_action/lick_soaked_clothes/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && !!get_licked_garment(target)

/datum/sex_action/lick_soaked_clothes/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !get_licked_garment(target))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/lick_soaked_clothes/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!get_licked_garment(target)

/datum/sex_action/lick_soaked_clothes/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/clothing/garment = get_licked_garment(target)
	user.visible_message(span_warning("[user] presses [user.p_their()] mouth to the wet spot on [target]'s [garment?.name || spot_name]..."))

/datum/sex_action/lick_soaked_clothes/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/clothing/garment = get_licked_garment(target)
	if(!garment)
		return
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] licks the wet [spot_name] of [target]'s [garment.name]..."))
	user.make_sucking_noise()
	garment.drink_soaked_fluid(user, user)
	perform_sex_action(target, user, 0.6, 0, 0.3)
	handle_passive_ejaculation(target)
	perform_sex_action(user, target, 0.3, 0, 0)

/datum/sex_action/lick_soaked_clothes/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lifts [user.p_their()] mouth from [target]'s [spot_name]."))

/datum/sex_action/lick_soaked_clothes/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/lick_soaked_clothes/proc/get_licked_garment(mob/living/target)
	if(!ishuman(target))
		return null
	var/mob/living/carbon/human/human_target = target
	return human_target.get_soaked_cover(stain_zone)

/datum/sex_action/lick_soaked_clothes/crotch
	name = "Lick crotch"
	description = "Suck the fluid out of the soaked clothes over their crotch."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/lick_soaked_clothes/chest
	name = "Lick chest"
	description = "Suck the fluid out of the soaked clothes over their chest."
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	stain_zone = FLUID_STAIN_CHEST
	spot_name = "chest"

/// Units of wetness a rubbed vagina soaks into the garment per stroke.
#define GARMENT_RUB_SOAK_AMOUNT 0.5

/// Pleasures genitals with a held cloth garment; the climax soaks into it.
/datum/sex_action/garment_pleasure
	abstract_type = /datum/sex_action/garment_pleasure
	requires_free_hands = FALSE
	do_time = 4 SECONDS
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/// The holder's active-hand garment if it is cloth that soaks, else null.
/datum/sex_action/garment_pleasure/proc/get_held_garment(mob/living/holder)
	if(!isliving(holder))
		return null
	var/obj/item/clothing/garment = holder.get_active_held_item()
	if(istype(garment) && garment.can_soak_fluid())
		return garment
	return null

/datum/sex_action/garment_pleasure/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!get_held_garment(user)

/datum/sex_action/garment_pleasure/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	// The climaxing mob is passed as `user`; the garment may be held by whoever performed the action.
	for(var/mob/living/candidate as anything in list(action_performer, action_initiator, user, target))
		var/obj/item/clothing/garment = get_held_garment(candidate)
		if(garment)
			garment.prepare_fluid_holder()
			return garment
	return null

/// Rubbing a wet vagina with the garment soaks a little of it in.
/datum/sex_action/garment_pleasure/proc/soak_wetness(mob/living/rubbed, obj/item/clothing/garment)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_free_organ(rubbed, ORGAN_SLOT_VAGINA)
	if(vagina?.reagents?.total_volume)
		garment.soak_fluid(vagina.reagents, GARMENT_RUB_SOAK_AMOUNT)

/datum/sex_action/garment_pleasure/proc/get_rub_message(mob/living/performer, mob/living/rubbed, obj/item/clothing/garment)
	var/whose = performer == rubbed ? performer.p_their() : "[rubbed]'s"
	if(get_free_organ(rubbed, ORGAN_SLOT_PENIS))
		return "strokes [whose] cock with \the [garment]"
	return "rubs \the [garment] against [whose] pussy"

/datum/sex_action/garment_pleasure/proc/lock_genitals(mob/living/rubbed)
	if(rubbed.getorganslot(ORGAN_SLOT_PENIS))
		add_sex_lock(rubbed, ORGAN_SLOT_PENIS, null, FALSE)
	if(rubbed.getorganslot(ORGAN_SLOT_VAGINA))
		add_sex_lock(rubbed, ORGAN_SLOT_VAGINA, null, FALSE)

/datum/sex_action/garment_pleasure/self
	name = "Rub garment"
	description = "Rub the garment in your hand against yourself; your climax soaks into it."

/datum/sex_action/garment_pleasure/self/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target || !get_held_garment(user))
		return FALSE
	return get_free_organ(user, ORGAN_SLOT_PENIS) || get_free_organ(user, ORGAN_SLOT_VAGINA)

/datum/sex_action/garment_pleasure/self/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target || !get_held_garment(user))
		return FALSE
	if(!get_free_organ(user, ORGAN_SLOT_PENIS) && !get_free_organ(user, ORGAN_SLOT_VAGINA))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/garment_pleasure/self/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	user.visible_message(span_warning("[user] brings \the [get_held_garment(user)] down to [user.p_their()] crotch..."))

/datum/sex_action/garment_pleasure/self/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/clothing/garment = get_held_garment(user)
	if(!garment)
		return
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [get_rub_message(user, user, garment)]..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)
	soak_wetness(user, garment)
	perform_sex_action(user, user, 2, 0, 2)
	handle_passive_ejaculation()

/datum/sex_action/garment_pleasure/self/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops."))

/datum/sex_action/garment_pleasure/self/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	user.visible_message(span_love("[user] climaxes into \the [get_held_garment(user) || "garment"]!"))
	return ORGASM_LOCATION_CONTAINER

/datum/sex_action/garment_pleasure/self/lock_sex_object(mob/living/user, mob/living/target)
	lock_genitals(user)

/datum/sex_action/garment_pleasure/other
	name = "Garment rubbing"
	description = "Rub the garment in your hand against them; their climax soaks into it."

/datum/sex_action/garment_pleasure/other/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target || !get_held_garment(user))
		return FALSE
	return get_free_organ(target, ORGAN_SLOT_PENIS) || get_free_organ(target, ORGAN_SLOT_VAGINA)

/datum/sex_action/garment_pleasure/other/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !get_held_garment(user))
		return FALSE
	if(!get_free_organ(target, ORGAN_SLOT_PENIS) && !get_free_organ(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS) && check_sex_lock(target, ORGAN_SLOT_VAGINA))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/garment_pleasure/other/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	user.visible_message(span_warning("[user] brings \the [get_held_garment(user)] to [target]'s crotch..."))

/datum/sex_action/garment_pleasure/other/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/clothing/garment = get_held_garment(user)
	if(!garment)
		return
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [get_rub_message(user, target, garment)]..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	if(user.has_kink(KINK_ONOMATOPOEIA))
		do_onomatopoeia(user)
	soak_wetness(target, garment)
	// Arouses the partner, so they are the one who climaxes into the garment.
	perform_sex_action(target, user, 2, 0, 2)
	handle_passive_ejaculation(target)

/datum/sex_action/garment_pleasure/other/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers \the [get_held_garment(user) || "garment"]."))

/datum/sex_action/garment_pleasure/other/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	// `user` is the climaxing partner; `target` holds the garment.
	user.visible_message(span_love("[user] climaxes into \the [get_held_garment(target) || "garment"]!"))
	return ORGASM_LOCATION_CONTAINER

/datum/sex_action/garment_pleasure/other/lock_sex_object(mob/living/user, mob/living/target)
	lock_genitals(target)

#undef GARMENT_RUB_SOAK_AMOUNT
