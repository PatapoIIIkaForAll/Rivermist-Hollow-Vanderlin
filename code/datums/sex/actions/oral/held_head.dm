// Using someone else's severed dullahan head: on a third person, on yourself, or tucked
// between your thighs. The head's owner is the giver; the holder sets pace and force.

/// A live detached dullahan head in `user`'s hands that belongs to someone else, or null.
/proc/get_held_foreign_dullahan_head(mob/living/user, datum/sex_scene/scene)
	RETURN_TYPE(/obj/item/bodypart/head/dullahan)
	if(!user)
		return null
	for(var/obj/item/bodypart/head/dullahan/head in user.held_items)
		if(!head.is_live_detached_head())
			continue
		var/mob/living/head_owner = head.get_dullahan_owner()
		if(!head_owner || head_owner == user)
			continue
		return head
	return null

/datum/sex_action/held_head_oral
	abstract_type = /datum/sex_action/held_head_oral
	user_menu_zone_mask = SEX_UI_ZONE_MISC
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	check_same_tile = FALSE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	/// Organ the receiver needs.
	var/receiver_slot
	/// How the receiver's part reads in messages.
	var/receiver_word = "crotch"
	/// The head in use, resolved at start so a dropped head ends the action.
	var/datum/weakref/head_ref

/datum/sex_action/held_head_oral/proc/get_head(mob/living/user)
	var/obj/item/bodypart/head/dullahan/head = head_ref?.resolve()
	if(head && !QDELETED(head))
		return head
	return get_held_foreign_dullahan_head(user, scene || user?.sex_scene)

/datum/sex_action/held_head_oral/proc/get_giver(mob/living/user)
	var/obj/item/bodypart/head/dullahan/head = get_head(user)
	return head?.get_dullahan_owner()

/datum/sex_action/held_head_oral/shows_on_menu(mob/living/user, mob/living/target)
	if(!target.getorganslot(receiver_slot))
		return FALSE
	return !!get_held_foreign_dullahan_head(user, user.sex_scene)

/datum/sex_action/held_head_oral/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/bodypart/head/dullahan/head = get_head(user)
	if(!head || !user.is_holding(head))
		return FALSE
	var/mob/living/giver = head.get_dullahan_owner()
	if(!giver || giver.stat == DEAD)
		return FALSE
	if(!target.getorganslot(receiver_slot))
		return FALSE
	if(check_sex_lock(target, receiver_slot))
		return FALSE
	if(check_sex_lock(giver, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!giver.mouth_is_free(action_user || user))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	head_ref = WEAKREF(head)
	return TRUE

/datum/sex_action/held_head_oral/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/bodypart/head/dullahan/head = head_ref?.resolve()
	return head && !QDELETED(head) && user.is_holding(head) && head.is_live_detached_head()

/datum/sex_action/held_head_oral/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, receiver_slot, null, FALSE)
	var/mob/living/giver = get_giver(user)
	if(giver)
		add_sex_lock(giver, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/held_head_oral/on_start(mob/living/user, mob/living/target)
	var/obj/item/bodypart/head/dullahan/head = get_held_foreign_dullahan_head(user, scene)
	head_ref = WEAKREF(head)
	var/mob/living/giver = head?.get_dullahan_owner()
	// The head's owner is part of this whether or not they were in the scene already.
	if(!giver || (scene && !(giver in scene.participants) && !scene.add_participant(giver)))
		return FALSE
	. = ..()
	var/whose = (target == user) ? user.p_their() : "[target]'s"
	user.visible_message(span_warning("[user] presses [giver]'s severed head against [whose] [receiver_word]..."))

/datum/sex_action/held_head_oral/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/giver = get_giver(user)
	if(!giver)
		return
	giver.make_mouth_noise(get_oral_noise_kind())
	do_thrust_animate(user, target)
	if(can_show_action_message(user, target))
		var/whose = (target == user) ? user.p_their() : "[target]'s"
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [giver]'s head over [whose] [receiver_word]."))
	perform_sex_action(target, giver, 2, 0, 2)
	handle_passive_ejaculation(target)
	perform_sex_action(giver, target, 1, 0, 0.2)
	handle_passive_ejaculation(giver)

/datum/sex_action/held_head_oral/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/giver = get_giver(user)
	user.visible_message(span_warning("[user] lifts [giver ? "[giver]'s" : "the"] head away..."))
	head_ref = null

/datum/sex_action/held_head_oral/penis
	name = "Head blowjob"
	description = "Press the severed head you hold to a cock and set the pace. Works on yourself too."
	receiver_slot = ORGAN_SLOT_PENIS
	receiver_word = "cock"

/datum/sex_action/held_head_oral/vagina
	name = "Head cunnilingus"
	description = "Press the severed head you hold to a cunt and set the pace. Works on yourself too."
	receiver_slot = ORGAN_SLOT_VAGINA
	receiver_word = "cunt"

// A position, not a mechanic: the head rides between the holder's thighs.
/datum/sex_action/thigh_head
	name = "Thigh-tuck head"
	description = "Hold their severed head snug between your legs. Mostly for the feeling of it."
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	check_same_tile = FALSE
	stamina_cost = 0.05

/datum/sex_action/thigh_head/proc/get_held_head(mob/living/user, mob/living/target)
	var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(target)
	if(!head || !user.is_holding(head))
		return null
	return head

/datum/sex_action/thigh_head/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return !!get_held_head(user, target)

/datum/sex_action/thigh_head/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target || !get_held_head(user, target))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/thigh_head/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!get_held_head(user, target)

/datum/sex_action/thigh_head/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/thigh_head/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] tucks [target]'s severed head snugly between [user.p_their()] thighs..."))

/datum/sex_action/thigh_head/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] squeezes [user.p_their()] thighs around [target]'s head."))
	perform_sex_action(target, user, 0.5, 0, 0.3)
	perform_sex_action(user, target, 0.5, 0, 0.3)

/datum/sex_action/thigh_head/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets [target]'s head slip from between [user.p_their()] thighs..."))
