/**
 * PORTAL CONTROL RING
*/
/*/obj/item/clothing/ring/portal_control //do something here
	name = "Portal control ring"
	desc = "Ring to control "
	icon_state = "g_ring_ruby"*/


/**
 * PORTAL LIGHT
*/

/obj/item/portallight
	name = "portal light"
	desc = "A softly pulsing arcane device."
	icon = 'modular_rmh/icons/obj/lewd/fleshlight.dmi'
	icon_state = "unpaired"
	var/obj/item/clothing/undies/portalpanties/linked_underwear = null
	var/mutable_appearance/organ_overlay
	var/mutable_appearance/sleeve_overlay
	var/org_target = ORGAN_SLOT_VAGINA
	loadout_blacklisted = TRUE
	w_class = WEIGHT_CLASS_SMALL
	body_storage_bulk = 100 //so that people can't stuff it in for now

/obj/item/portallight/Destroy()
	if(linked_underwear?.linked_light == src)
		linked_underwear.linked_light = null
	linked_underwear = null
	return ..()

/obj/item/portallight/proc/get_wearer()
	if(!linked_underwear)
		return null
	return linked_underwear.get_current_wearer()

/obj/item/portallight/proc/get_current_holder()
	if(!ishuman(loc))
		return null
	var/mob/living/carbon/human/holder = loc
	if(!(src in holder.held_items))
		return null
	return holder

/obj/item/portallight/proc/set_linked_underwear(obj/item/clothing/undies/portalpanties/new_underwear)
	var/obj/item/clothing/undies/portalpanties/old_underwear = linked_underwear
	var/obj/item/portallight/replaced_light = new_underwear?.linked_light

	if(old_underwear == new_underwear && (!replaced_light || replaced_light == src))
		if(linked_underwear)
			org_target = linked_underwear.org_target
		update_appearance()
		return

	if(old_underwear?.linked_light == src)
		old_underwear.linked_light = null

	if(replaced_light && replaced_light != src)
		replaced_light.linked_underwear = null
		replaced_light.update_appearance()

	linked_underwear = new_underwear

	if(new_underwear)
		new_underwear.linked_light = src
		org_target = new_underwear.org_target

	update_appearance()

/obj/item/portallight/proc/is_held_by(mob/living/carbon/human/user)
	return user?.get_active_held_item() == src

/obj/item/portallight/proc/get_target_for_user(mob/living/carbon/human/user)
	if(!user)
		return null
	if(!is_held_by(user))
		to_chat(user, span_info("You need to hold the portal in your active hand."))
		return null
	if(!linked_underwear)
		to_chat(user, span_info("The portal isn't connected to anything!"))
		return null

	var/mob/living/carbon/human/target = get_wearer()
	if(!target)
		to_chat(user, span_info("There's no one on the other side!"))
		return null

	return target

/obj/item/portallight/update_appearance()
	. = ..()
	cut_overlay(organ_overlay)
	cut_overlay(sleeve_overlay)
	icon_state = "unpaired"

	var/mob/living/carbon/human/user = get_wearer()
	if(!user)
		return
	if(user.underwear != linked_underwear)
		return

	org_target = linked_underwear.org_target

	sleeve_overlay = mutable_appearance(icon, "portal_sleeve_normal")
	var/sleevecolor = user.skin_tone
	sleeve_overlay.color = "#" + sleevecolor
	add_overlay(sleeve_overlay)

	if(linked_underwear.org_target == ORGAN_SLOT_VAGINA)
		organ_overlay = mutable_appearance(icon, "portal_vag")
	else
		organ_overlay = mutable_appearance(icon, "portal_anus")
	organ_overlay.color = "#f37272"
	add_overlay(organ_overlay)

	icon_state = "paired"


/obj/item/portallight/attack_self(mob/user, params)
	var/mob/living/carbon/human/user_human = user
	if(!user_human)
		return FALSE

	var/mob/living/carbon/human/target = get_target_for_user(user_human)
	if(!target)
		return FALSE

	user_human.open_sex_scene(target)

	. = ..()

/obj/item/portallight/MiddleClick(mob/user, params)
	. = ..()
	var/mob/living/carbon/human/user_human = user
	if(!user_human)
		return

	var/mob/living/carbon/human/target = get_target_for_user(user_human)
	if(!target)
		return

	if(linked_underwear.org_target == ORGAN_SLOT_VAGINA)
		to_chat(user_human, span_info("You refocus the portal to your target's backside!"))
		org_target = ORGAN_SLOT_ANUS
		linked_underwear.org_target = ORGAN_SLOT_ANUS
		update_appearance()
		return

	if(target.getorganslot(ORGAN_SLOT_VAGINA))
		to_chat(user_human, span_info("You refocus the portal to your target's loins!"))
		org_target = ORGAN_SLOT_VAGINA
		linked_underwear.org_target = ORGAN_SLOT_VAGINA
		update_appearance()
		return
/**
 * PORTAL PANTIES
*/

/obj/item/clothing/undies/portalpanties
	name = "portal panties"
	desc = "Laced with unstable portal magic."
	icon = 'modular_rmh/icons/obj/lewd/fleshlight.dmi'
	mob_overlay_icon = 'modular_rmh/icons/obj/lewd/portals_onmob.dmi'
	item_state = "panties"
	icon_state = "panties"
	gendered = TRUE
	slot_flags = ITEM_SLOT_UNDER_BOTTOM
	loadout_blacklisted = TRUE

	var/obj/item/portallight/linked_light = null
	var/org_target = ORGAN_SLOT_VAGINA
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/undies/portalpanties/proc/get_current_wearer()
	if(!ishuman(loc))
		return null
	var/mob/living/carbon/human/wearer = loc
	if(wearer.underwear != src)
		return null
	return wearer

/obj/item/clothing/undies/portalpanties/proc/set_linked_light(obj/item/portallight/new_light)
	if(new_light)
		new_light.set_linked_underwear(src)
		return

	if(linked_light)
		linked_light.set_linked_underwear(null)

/obj/item/clothing/undies/portalpanties/equipped(mob/living/carbon/human/H, slot)
	. = ..()
	if(slot != ITEM_SLOT_UNDER_BOTTOM)
		return

	if(H.getorganslot(ORGAN_SLOT_VAGINA))
		org_target = ORGAN_SLOT_VAGINA
		to_chat(H, span_info("You feel magical energies focus around your loins."))
	else
		org_target = ORGAN_SLOT_ANUS
		to_chat(H, span_info("You feel magical energies focus around your backside."))

	if(linked_light)
		linked_light.set_linked_underwear(src)

/obj/item/clothing/undies/portalpanties/dropped(mob/living/carbon/human/H)
	. = ..()
	if(linked_light)
		linked_light.update_appearance()

/obj/item/clothing/undies/portalpanties/Destroy()
	if(linked_light?.linked_underwear == src)
		linked_light.linked_underwear = null
	linked_light = null
	return ..()

/proc/add_portal_message_name_candidate(list/candidates, candidate)
	if(!istext(candidate) || !length(candidate))
		return
	if(candidate in candidates)
		return

	for(var/i in 1 to length(candidates))
		if(length(candidate) > length(candidates[i]))
			candidates.Insert(i, candidate)
			return

	candidates += candidate

/proc/sanitize_portal_visible_message(message, mob/living/carbon/human/source)
	if(!message || !source)
		return message

	var/list/source_names = list()
	add_portal_message_name_candidate(source_names, source.get_visible_name(""))
	add_portal_message_name_candidate(source_names, source.get_face_name("", null, FALSE))
	add_portal_message_name_candidate(source_names, source.real_name)
	add_portal_message_name_candidate(source_names, source.name)
	add_portal_message_name_candidate(source_names, "[source]")

	var/sanitized_message = message
	for(var/source_name in source_names)
		sanitized_message = replacetext(sanitized_message, source_name, "Someone")

	return sanitized_message

/mob/living/carbon/human/get_portal_visible_message_recipients()
	. = list()

	var/obj/item/clothing/undies/portalpanties/portal_underwear = underwear
	if(istype(portal_underwear))
		var/obj/item/portallight/linked_light = portal_underwear.linked_light
		var/mob/living/carbon/human/portal_holder = linked_light?.get_current_holder()
		if(portal_holder && portal_holder != src)
			. |= portal_holder

	for(var/obj/item/portal_light_candidate as anything in held_items)
		if(!istype(portal_light_candidate, /obj/item/portallight))
			continue
		var/obj/item/portallight/portal_light = portal_light_candidate
		var/mob/living/carbon/human/portal_wearer = portal_light.get_wearer()
		if(portal_wearer && portal_wearer != src)
			. |= portal_wearer

	if(!length(.))
		return null

/mob/living/carbon/human/get_portal_visible_message(message)
	return sanitize_portal_visible_message(message, src)

/obj/item/clothing/undies/portalpanties/attackby(obj/item/I, mob/living/carbon/human/user)
	if(!istype(I, /obj/item/portallight))
		return ..()

	var/obj/item/portallight/portal_light = I

	if(linked_light == portal_light)
		set_linked_light(null)
		to_chat(user, span_notice("[portal_light] has been successfully unlinked."))
		return

	set_linked_light(portal_light)
	to_chat(user, span_notice("[portal_light] has been successfully linked."))

/**
 * BASE PORTAL ACTION
*/
/datum/sex_action/portal_base
	abstract_type = /datum/sex_action/portal_base
	var/obj/item/portallight/light
	var/mob/living/carbon/human/target
	check_same_tile = FALSE
	check_distance = FALSE

/datum/sex_action/portal_base/proc/get_held_portal_light(mob/living/user)
	if(!iscarbon(user))
		return null

	var/mob/living/carbon/carbon_user = user
	var/obj/item/held_item = carbon_user.get_active_held_item()
	if(!istype(held_item, /obj/item/portallight))
		return null
	return held_item

/datum/sex_action/portal_base/proc/get_ai_portal_light(mob/living/user)
	if(!user?.ai_controller)
		return null

	var/obj/item/portallight/portal_light = user.ai_controller.blackboard[BB_HORNY_PORTAL_LIGHT]
	if(!istype(portal_light))
		return null
	if(QDELETED(portal_light))
		user.ai_controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
		return null
	if(iscarbon(user))
		return null
	if(!isturf(portal_light.loc))
		return null
	if(!user.Adjacent(portal_light))
		return null
	return portal_light

/datum/sex_action/portal_base/proc/get_portal_wearer(mob/living/user)
	var/obj/item/portallight/portal_light = get_portal_light(user)
	if(!portal_light)
		return null
	return portal_light.get_wearer()

/datum/sex_action/portal_base/proc/get_portal_light(mob/living/user)
	var/obj/item/portallight/portal_light = get_held_portal_light(user)
	if(portal_light)
		return portal_light
	return get_ai_portal_light(user)

/datum/sex_action/portal_base/proc/portal_ready(mob/living/user, mob/living/carbon/human/target)
	var/obj/item/portallight/portal_light = get_portal_light(user)
	if(!portal_light)
		return FALSE

	var/mob/living/carbon/human/portal_target = portal_light.get_wearer()
	if(!portal_target || portal_target != target)
		return FALSE

	if(!isnull(hole_id) && hole_id != portal_light.org_target)
		return FALSE
	if(!isnull(hole_id) && !target.getorganslot(hole_id))
		return FALSE

	return TRUE

/datum/sex_action/portal_base/proc/can_use_portal_light(mob/living/user, obj/item/portallight/portal_light)
	if(!user || !portal_light)
		return FALSE
	if(check_sex_lock(user, user.get_active_precise_hand()))
		return FALSE
	if(check_sex_lock(user, null, portal_light))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/shows_on_menu(mob/living/user, mob/living/carbon/human/target)
	return portal_ready(user, target)

/datum/sex_action/portal_base/can_perform(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/portallight/portal_light = get_portal_light(user)
	if(!portal_light)
		return FALSE
	if(!can_use_portal_light(user, portal_light))
		return FALSE

	if(!portal_ready(user, target))
		return FALSE

	light = portal_light
	src.target = target
	return TRUE

/datum/sex_action/portal_base/lock_sex_object(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	add_sex_lock(user, user.get_active_precise_hand())

	var/obj/item/portallight/portal_light = get_portal_light(user)
	if(portal_light)
		add_sex_lock(user, null, portal_light)

/datum/sex_action/portal_base/is_finished(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		return TRUE
	if(!portal_ready(user, target))
		return TRUE
	return FALSE

/**
 * SEX ACTION: PORTAL HAND
*/

/datum/sex_action/portal_base/portal_hand_base
	abstract_type = /datum/sex_action/portal_base/portal_hand_base
	name = "Portal Hand"
	var/start_message_user = "You start touching your target through the portal."
	var/start_message_target = "A distant touch reaches me through the portal!"
	var/perform_message_user = "You %FORCE% finger your target through the portal."
	var/perform_message_target = "Someone %FORCE% fingers me through the portal."
	var/finish_message_user = "You withdraw your hand from the portal."
	var/finish_message_target = "The distant touch on me fades away."
	var/target_arousal_amt = 2
	var/target_pain_amt = 4
	var/target_orgasm_amt = 2

/datum/sex_action/portal_base/portal_hand_base/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!user.has_free_sex_hands())
		return FALSE
	if(user.get_inactive_held_item())
		return FALSE
	if(!user.get_bodypart(user.get_inactive_precise_hand()))
		return FALSE
	if(check_sex_lock(user, user.get_inactive_precise_hand()))
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_hand_base/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_warning(start_message_user))
	to_chat(target, span_love(start_message_target))

/datum/sex_action/portal_base/portal_hand_base/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	do_thrust_animate(user, user)

	if(can_show_action_message())
		var/force_adjective = get_generic_force_adjective()
		to_chat(user, spanify_force(replacetext(perform_message_user, "%FORCE%", force_adjective)))
		to_chat(target, spanify_force(replacetext(perform_message_target, "%FORCE%", force_adjective)))

	perform_sex_action(target, user, target_arousal_amt, target_pain_amt, target_orgasm_amt)
	handle_passive_ejaculation(target)
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	portal_touch_feedback(user, target)

/datum/sex_action/portal_base/portal_hand_base/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target, must_flip)
	if(must_flip)
		to_chat(user, span_love("I climax from the portal touch, my body trembling with pleasure!"))
		to_chat(target, span_love("Your target shudders and reacts to your touch through the portal."))
		return ORGASM_LOCATION_SELF

/datum/sex_action/portal_base/portal_hand_base/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_notice(finish_message_user))
	to_chat(target, span_notice(finish_message_target))

/datum/sex_action/portal_base/portal_hand_base/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	add_sex_lock(user, user.get_inactive_precise_hand())
	add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/portal_base/portal_hand
	parent_type = /datum/sex_action/portal_base/portal_hand_base
	name = "Portal Fingering"
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/portal_base/portal_hand_anal
	parent_type = /datum/sex_action/portal_base/portal_hand_base
	name = "Portal Anal-fingering"
	hole_id = ORGAN_SLOT_ANUS
	target_orgasm_amt = 2
	start_message_user = "You start fingering your target's backside through the portal."
	start_message_target = "A distant touch teases my backside through the portal!"
	target_pain_amt = 6
	perform_message_user = "You %FORCE% finger your target's ass through the portal."
	perform_message_target = "Someone %FORCE% fingers my ass through the portal."

/**
 * SEX ACTION: PORTAL ORAL
*/

/datum/sex_action/portal_base/portal_oral_base
	abstract_type = /datum/sex_action/portal_base/portal_oral_base
	name = "Portal Oral"
	gags_user = TRUE
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	var/start_message_user = "You press your mouth to the portal, reaching your target."
	var/start_message_target = "Warm sensations bloom over me through the portal!"
	var/perform_message_user = "You %FORCE% lick your target through the portal."
	var/perform_message_target = "Someone %FORCE% licks me through the portal."
	var/finish_message_user = "You pull back from the portal."
	var/finish_message_target = "The sensations on me from the portal fade away."
	var/target_arousal_amt = 2
	var/target_pain_amt = 3
	var/target_orgasm_amt = 2
	var/user_arousal_amt = 0
	var/user_pain_amt = 0
	var/user_orgasm_amt = 0

/datum/sex_action/portal_base/portal_oral_base/get_scene_target_slot()
	return hole_id

/datum/sex_action/portal_base/portal_oral_base/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!user.mouth_is_free(user))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_oral_base/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_warning(start_message_user))
	to_chat(target, span_love(start_message_target))

/datum/sex_action/portal_base/portal_oral_base/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.make_sucking_noise()

	if(can_show_action_message())
		var/force_adjective = get_generic_force_adjective()
		to_chat(user, spanify_force(replacetext(perform_message_user, "%FORCE%", force_adjective)))
		to_chat(target, spanify_force(replacetext(perform_message_target, "%FORCE%", force_adjective)))

	perform_sex_action(target, user, target_arousal_amt, target_pain_amt, target_orgasm_amt)
	handle_passive_ejaculation(target)
	portal_touch_feedback(user, target)

	if(user_arousal_amt || user_pain_amt || user_orgasm_amt)
		perform_sex_action(user, target, user_arousal_amt, user_pain_amt, user_orgasm_amt)

/datum/sex_action/portal_base/portal_oral_base/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target, must_flip)
	if(must_flip)
		to_chat(user, span_love("I climax from the mouth on me through the portal, my body shuddering in ecstasy!"))
		to_chat(target, span_love("You bring your target to climax through the portal!"))
		return ORGASM_LOCATION_ORAL

/datum/sex_action/portal_base/portal_oral_base/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_notice(finish_message_user))
	to_chat(target, span_notice(finish_message_target))

/datum/sex_action/portal_base/portal_oral_base/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/portal_base/portal_oral
	parent_type = /datum/sex_action/portal_base/portal_oral_base
	name = "Portal Oral"
	hole_id = ORGAN_SLOT_VAGINA
	start_message_target = "Warm sensations bloom between my legs!"
	perform_message_user = "You %FORCE% lick your target's pussy through the portal."
	perform_message_target = "Someone %FORCE% licks my pussy through the portal."
	user_arousal_amt = 0.5

/datum/sex_action/portal_base/portal_oral_anal
	parent_type = /datum/sex_action/portal_base/portal_oral_base
	name = "Portal Rim"
	hole_id = ORGAN_SLOT_ANUS
	start_message_target = "A warm tongue teases my backside through the portal!"
	perform_message_user = "You %FORCE% rim your target through the portal."
	perform_message_target = "Someone %FORCE% rims my ass through the portal."
	target_pain_amt = 0
	target_orgasm_amt = 1.5

/**
 * SEX ACTION: PORTAL PENIS
*/

/datum/sex_action/portal_base/portal_penis_base
	abstract_type = /datum/sex_action/portal_base/portal_penis_base
	stamina_cost = 0.5
	scene_interaction = SEX_SCENE_INTERACTION_PENETRATION
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = ORGAN_SLOT_PENIS
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	var/start_message_user = "You slide your cock into the portal, reaching your target."
	var/start_message_target = "Something pushes into me through the portal!"
	var/perform_message_user = "You %FORCE% fuck your target through the portal."
	var/perform_message_target = "Someone %FORCE% fucks me through the portal."
	var/climax_message_self = "You feel your target shuddering around your member in orgasm."
	var/climax_message_target = "The invading member shudders and spills deep inside me!"
	var/finish_message_user = "You pull your cock back from the portal."
	var/finish_message_target = "The member pulls out of me through the portal."

/datum/sex_action/portal_base/portal_penis_base/get_scene_target_slot()
	return hole_id

/datum/sex_action/portal_base/portal_penis_base/can_perform(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_penis_base/on_start(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_warning(start_message_user))
	to_chat(target, span_love(start_message_target))

/datum/sex_action/portal_base/portal_penis_base/on_perform(mob/living/user, mob/living/carbon/human/target)
	do_thrust_animate(user, user)

	if(can_show_action_message(user, target))
		var/force_adjective = get_generic_force_adjective()
		to_chat(user, spanify_force(replacetext(perform_message_user, "%FORCE%", force_adjective)))
		to_chat(target, spanify_force(replacetext(perform_message_target, "%FORCE%", force_adjective)))

	perform_sex_action(user, target, 2, 0, 2)
	perform_sex_action(target, user, 2, 3, 2)
	handle_passive_ejaculation(target)
	handle_passive_ejaculation(user)
	playsound(user, get_force_sound(), 50, TRUE, -2, ignore_walls = FALSE)
	portal_touch_feedback(user, target)

/datum/sex_action/portal_base/portal_penis_base/handle_climax_message(mob/living/user, mob/living/carbon/human/target, must_flip)
	if(must_flip)
		to_chat(user, span_love("I cum from the fucking through the portal, my body trembling in ecstasy!"))
		to_chat(target, span_love(climax_message_self))
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_SELF

	to_chat(user, span_love("You cum inside your target! You shudder with pleasure."))
	to_chat(target, span_love(climax_message_target))
	user.lose_virginity()
	target.lose_virginity()
	return ORGASM_LOCATION_INTO

/datum/sex_action/portal_base/portal_penis_base/on_finish(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_notice(finish_message_user))
	to_chat(target, span_notice(finish_message_target))

/datum/sex_action/portal_base/portal_penis_base/lock_sex_object(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/portal_base/portal_penis_vaginal
	parent_type = /datum/sex_action/portal_base/portal_penis_base
	name = "Portal Vaginal"
	hole_id = ORGAN_SLOT_VAGINA
	start_message_user = "You slide your cock into the portal, reaching your target's pussy."
	start_message_target = "Something pushes into my pussy through the portal!"
	perform_message_user = "You %FORCE% fuck your target's pussy through the portal."
	perform_message_target = "Someone %FORCE% fucks my pussy through the portal."
	climax_message_self = "You feel your target's pussy spasming around your member, shuddering in orgasm."
	climax_message_target = "The invading member shudders and lets out ropes of seed deep inside my pussy!"

/datum/sex_action/portal_base/portal_penis_anal
	parent_type = /datum/sex_action/portal_base/portal_penis_base
	name = "Portal Anal"
	hole_id = ORGAN_SLOT_ANUS
	start_message_user = "You slide your cock into the portal, reaching your target's ass."
	start_message_target = "Something pushes into my ass through the portal!"
	perform_message_user = "You %FORCE% fuck your target's ass through the portal."
	perform_message_target = "Someone %FORCE% fucks my ass through the portal."
	climax_message_self = "You feel your target's ass spasming around your member, shuddering in orgasm."
	climax_message_target = "The invading member shudders and lets out ropes of seed deep inside my ass!"

/**
 * SEX ACTION: PORTAL VAGINA
*/

/datum/sex_action/portal_base/portal_vagina_base
	abstract_type = /datum/sex_action/portal_base/portal_vagina_base
	stamina_cost = 0.4
	var/required_user_organ = ORGAN_SLOT_VAGINA
	var/start_message_user = "You press yourself against the portal, reaching your target."
	var/start_message_target = "A slick warmth rubs against me through the portal!"
	var/perform_message_user = "You %FORCE% grind yourself against your target through the portal."
	var/perform_message_target = "Someone %FORCE% grinds against me through the portal."
	var/finish_message_user = "You pull back from the portal, still tingling."
	var/finish_message_target = "The slick grinding against me through the portal fades away."
	var/user_arousal_amt = 2
	var/user_pain_amt = 2
	var/user_orgasm_amt = 3
	var/target_arousal_amt = 1.5
	var/target_pain_amt = 2
	var/target_orgasm_amt = 1.5

/datum/sex_action/portal_base/portal_vagina_base/can_perform(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!user.getorganslot(required_user_organ))
		return FALSE
	if(check_sex_lock(user, required_user_organ))
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_vagina_base/on_start(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_warning(start_message_user))
	to_chat(target, span_love(start_message_target))

/datum/sex_action/portal_base/portal_vagina_base/on_perform(mob/living/user, mob/living/carbon/human/target)
	do_thrust_animate(user, user)

	if(can_show_action_message(user, target))
		var/force_adjective = get_generic_force_adjective()
		to_chat(user, spanify_force(replacetext(perform_message_user, "%FORCE%", force_adjective)))
		to_chat(target, spanify_force(replacetext(perform_message_target, "%FORCE%", force_adjective)))

	perform_sex_action(user, target, user_arousal_amt, user_pain_amt, user_orgasm_amt)
	perform_sex_action(target, user, target_arousal_amt, target_pain_amt, target_orgasm_amt)
	playsound(user, get_force_sound(), 45, TRUE, -2, ignore_walls = FALSE)
	portal_touch_feedback(user, target)

/datum/sex_action/portal_base/portal_vagina_base/handle_climax_message(mob/living/user, mob/living/carbon/human/target, must_flip)
	if(must_flip)
		to_chat(user, span_love("Pleasure crests through the portal and makes me shudder in orgasm!"))
		to_chat(target, span_love("You feel your target shudder and climax against you through the portal!"))
		return ORGASM_LOCATION_SELF

	to_chat(user, span_love("Pleasure crashes through you as you grind yourself to orgasm against the portal!"))
	to_chat(target, span_love("The slick pressure against me through the portal shudders with climax."))
	return ORGASM_LOCATION_SELF

/datum/sex_action/portal_base/portal_vagina_base/on_finish(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	to_chat(user, span_notice(finish_message_user))
	to_chat(target, span_notice(finish_message_target))

/datum/sex_action/portal_base/portal_vagina_base/lock_sex_object(mob/living/user, mob/living/carbon/human/target)
	. = ..()
	add_sex_lock(user, required_user_organ)
	add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/portal_base/portal_vagina_vaginal
	parent_type = /datum/sex_action/portal_base/portal_vagina_base
	name = "Portal Grinding"
	required_user_organ = ORGAN_SLOT_VAGINA
	hole_id = ORGAN_SLOT_VAGINA
	start_message_user = "You grind your cunt against the portal, reaching your target's pussy."
	start_message_target = "A slick warmth grinds against my pussy through the portal!"
	perform_message_user = "You %FORCE% grind your cunt against your target's pussy through the portal."
	perform_message_target = "Someone %FORCE% grinds against my pussy through the portal."

/datum/sex_action/portal_base/portal_vagina_anal
	parent_type = /datum/sex_action/portal_base/portal_vagina_base
	name = "Portal Anal-grinding"
	required_user_organ = ORGAN_SLOT_ANUS
	hole_id = ORGAN_SLOT_ANUS
	start_message_user = "You press your backside to the portal, teasing your target's ass."
	start_message_target = "A warm, slick pressure teases my ass through the portal!"
	perform_message_user = "You %FORCE% grind your ass against your target's ass through the portal."
	perform_message_target = "Someone %FORCE% grinds against my ass through the portal."
	user_pain_amt = 3
	target_pain_amt = 3

/**
 * SEX ACTION: PORTAL STORAGE
*/

/datum/sex_action/portal_base/portal_store_base
	abstract_type = /datum/sex_action/portal_base/portal_store_base
	requires_hole_storage = FALSE
	continous = TRUE
	var/obj/item/organ/genitals/target_organ
	var/base_pain_amt = 2

/datum/sex_action/portal_base/portal_store_base/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/stored_item = user.get_inactive_held_item()
	if(!stored_item?.can_enter_body_storage_layer(STORAGE_LAYER_INNER))
		return FALSE
	if(istype(stored_item, /obj/item/portallight))
		return FALSE
	if(check_sex_lock(user, user.get_inactive_precise_hand()))
		return FALSE
	if(check_sex_lock(user, null, stored_item))
		return FALSE
	if(check_sex_lock(target, hole_id, null, stored_item))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_store_base/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	var/obj/item/stored_item = user.get_inactive_held_item()
	if(!stored_item)
		stop_runtime()
		return

	target_organ = target.getorganslot(hole_id)
	if(!target_organ)
		stop_runtime()
		return
	// The hole sets the pace: the same time the holes window would take for this toy.
	time_toy_insert_cycle(target_organ, stored_item)

	to_chat(user, spanify_force("I start inserting \the [stored_item] into the portal..."))
	if(user != target)
		to_chat(target, spanify_force("Something is being inserted into me through the portal..."))

	var/used_sex_volume = sex_volume
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		used_sex_volume *= 0.5
	play_toy_reach_sound(target_organ, target, used_sex_volume)

/datum/sex_action/portal_base/portal_store_base/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/pain_amt = base_pain_amt

	if(!target_organ)
		target_organ = target.getorganslot(hole_id)
	if(!target_organ)
		stop_runtime()
		return

	var/obj/item/stored_item = user.get_inactive_held_item()
	if(!stored_item)
		stop_runtime()
		return

	var/use_force = (force >= SEX_FORCE_HIGH)
	// The shared slip roll: a tight, dry fit fumbles unless forced; the next cycle tries again.
	var/obj/item/organ/genitals/filling_organ/hole = target_organ
	if(istype(hole) && hole.roll_toy_insert_slip(stored_item, use_force))
		to_chat(user, spanify_force("\The [stored_item] slips from my grip at the portal and will not go in."))
		if(user != target)
			to_chat(target, spanify_force("Something fumbles at the far side of my portal..."))
		return
	var/success = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_TRY_INSERT, stored_item, STORAGE_LAYER_INNER, use_force)
	switch(success)
		if(INSERT_FEEDBACK_OK)
			to_chat(user, spanify_force("I stuff \the [stored_item] into the portal..."))
			if(user != target)
				to_chat(target, spanify_force("Something is being inserted into me through the portal!"))
		if(INSERT_FEEDBACK_OK_FORCE)
			if(prob(15))
				var/stuffed_result = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, use_force)
				if(stuffed_result == INSERT_FEEDBACK_OK_FORCE || stuffed_result == INSERT_FEEDBACK_OK)
					pain_amt += 4
					to_chat(user, spanify_force("\The [stored_item] slips deeper through the portal!"))
					if(user != target)
						to_chat(target, spanify_force("Something slips deep inside me!"))
			else
				pain_amt += 4
				to_chat(user, spanify_force("I force \the [stored_item] through the portal, fighting the pressure!"))
				if(user != target)
					to_chat(target, spanify_force("Something is forced inside me!"))
		if(INSERT_FEEDBACK_ALMOST_FULL)
			pain_amt += 2
			to_chat(user, spanify_force("I stuff \the [stored_item] into the portal, but it will not fit much more..."))
			if(user != target)
				to_chat(target, spanify_force("Another item is pushed into me, stretching me to the limit."))
		if(INSERT_FEEDBACK_STUFFED)
			if(use_force && prob(50))
				var/stuffed_result = SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP, use_force)
				if(stuffed_result == INSERT_FEEDBACK_OK_FORCE || stuffed_result == INSERT_FEEDBACK_OK)
					pain_amt += 2
					to_chat(user, spanify_force("\The [stored_item] slips deeper through the portal!"))
					if(user != target)
						to_chat(target, spanify_force("Something slips deep inside me!"))
			else
				to_chat(user, spanify_force("The portal is too full to stuff even \the [stored_item] into."))
				if(user != target)
					to_chat(target, spanify_force("Something probes my portal, but I am too full!"))
				stop_runtime()
				return
		if(INSERT_FEEDBACK_TRY_FORCE)
			pain_amt += 3
			to_chat(user, spanify_force("I feel like \the [stored_item] might fit if I use more force."))
			if(user != target)
				to_chat(target, spanify_force("Something probes my portal..."))
		if(FALSE)
			to_chat(user, spanify_force("I fail to stuff \the [stored_item] into the portal."))
			if(user != target)
				to_chat(target, spanify_force("Something probes my portal..."))
			stop_runtime()
			return

	portal_touch_feedback(user, target, "insert")
	user.update_inv_hands()
	user.update_a_intents()
	perform_sex_action(user, target, 0.5, pain_amt, 0.5)
	handle_passive_ejaculation()

/datum/sex_action/portal_base/portal_store_base/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	add_sex_lock(user, user.get_inactive_precise_hand())

	var/obj/item/stored_item = user.get_inactive_held_item()
	if(stored_item)
		add_sex_lock(user, null, stored_item)

	add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/portal_base/portal_store_vaginal
	parent_type = /datum/sex_action/portal_base/portal_store_base
	name = "Portal Stuffing"
	hole_id = ORGAN_SLOT_VAGINA
	base_pain_amt = 2

/datum/sex_action/portal_base/portal_store_anal
	parent_type = /datum/sex_action/portal_base/portal_store_base
	name = "Portal Anal-stuffing"
	hole_id = ORGAN_SLOT_ANUS
	base_pain_amt = 4

/datum/sex_action/portal_base/portal_remove_base
	abstract_type = /datum/sex_action/portal_base/portal_remove_base
	continous = TRUE
	var/obj/item/organ/genitals/target_organ
	var/base_pain_amt = 1
	/// The stored item the next cycle reaches for, chosen early so the cycle's length fits it.
	var/obj/item/pending_toy

/datum/sex_action/portal_base/portal_remove_base/Destroy()
	target_organ = null
	pending_toy = null
	return ..()

/datum/sex_action/portal_base/portal_remove_base/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE

	target_organ = target.getorganslot(hole_id)
	if(!target_organ)
		return FALSE
	if(!length(target_organ.get_body_storage_items_for_interaction(STORAGE_LAYER_INNER, BODYSTORAGE_REMOVE_MANUAL)))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_remove_base/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	if(!user.get_inactive_held_item() && check_sex_lock(user, user.get_inactive_precise_hand()))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_remove_base/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	target_organ = target.getorganslot(hole_id)
	// Pick the first item now so the first cycle already takes the holes window's time for it.
	pending_toy = choose_toy_to_reach(target_organ, STORAGE_LAYER_INNER)
	to_chat(user, span_warning("I start removing items from the portal..."))
	var/used_sex_volume = sex_volume
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		used_sex_volume *= 0.5
	play_toy_reach_sound(target_organ, target, used_sex_volume)

/datum/sex_action/portal_base/portal_remove_base/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)

	if(!target_organ)
		target_organ = target.getorganslot(hole_id)
	if(!target_organ)
		stop_runtime()
		return

	var/obj/item/organ/genitals/filling_organ/hole = target_organ
	var/obj/item/removed_item = toy_still_in_reach(hole, pending_toy, STORAGE_LAYER_INNER) ? pending_toy : choose_toy_to_reach(hole, STORAGE_LAYER_INNER)
	pending_toy = null
	if(!removed_item || !istype(hole))
		to_chat(user, spanify_force("I couldn't find anything inside..."))
		stop_runtime()
		return
	// The shared grip roll: the same odds, slips and passage the holes window gives.
	switch(hole.resolve_toy_removal(removed_item, STORAGE_LAYER_INNER, user))
		if(TOY_REMOVE_SLIPPED_DEEPER)
			to_chat(user, spanify_force("\The [removed_item] slips from my fingers and deeper through the portal, past where I can reach."))
			if(user != target)
				to_chat(target, spanify_force("Something slips deep inside me!"))
			pending_toy = choose_toy_to_reach(hole, STORAGE_LAYER_INNER)
			return
		if(TOY_REMOVE_NO_GRIP)
			to_chat(user, spanify_force("I can't get a grip on \the [removed_item] through the portal..."))
			pending_toy = removed_item
			return
		if(TOY_REMOVE_STUCK)
			to_chat(user, spanify_force("\The [removed_item] will not come."))
			stop_runtime()
			return

	if(user.get_inactive_held_item())
		user.visible_message(spanify_force("\The [removed_item] falls down on the floor..."))
		removed_item.doMove(get_turf(user))
	else
		to_chat(user, spanify_force("I fish out \the [removed_item] from the portal..."))
		removed_item.doMove(get_turf(user))
		if(!user.put_in_inactive_hand(removed_item))
			removed_item.doMove(get_turf(user))

	portal_touch_feedback(user, target, "remove")
	perform_sex_action(user, target, 0.5, base_pain_amt, 0.5)
	handle_passive_ejaculation()
	pending_toy = choose_toy_to_reach(hole, STORAGE_LAYER_INNER)

/datum/sex_action/portal_base/portal_remove_base/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!user.get_inactive_held_item())
		add_sex_lock(user, user.get_inactive_precise_hand())
	add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/portal_base/portal_remove_vaginal
	parent_type = /datum/sex_action/portal_base/portal_remove_base
	name = "Portal Retrieval"
	hole_id = ORGAN_SLOT_VAGINA
	base_pain_amt = 1

/datum/sex_action/portal_base/portal_remove_anal
	parent_type = /datum/sex_action/portal_base/portal_remove_base
	name = "Portal Anal-retrieval"
	hole_id = ORGAN_SLOT_ANUS
	base_pain_amt = 2
/*
/datum/sex_action/portal_base/portal_object_fuck
	name = "Portal Toy"
	var/ouchietext = "owie"
	do_time = 4 SECONDS //slower on your own but not as much as ass since this is on your front.

	var/self = FALSE

	var/obj/item/organ/genitals/target_organ

	continous = TRUE


/datum/sex_action/portal_base/portal_object_fuck/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!get_sextoy_in_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/portal_base/portal_object_fuck/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!user.get_inactive_held_item())
		return FALSE
	return TRUE


/datum/sex_action/portal_base/portal_object_fuck/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	var/obj/item/dildo = user.get_active_held_item()
	if(istype(user.get_active_held_item(), /obj/item/weapon) || istype(user.get_active_held_item(), /obj/item/ammo_casing))
		to_chat(user, span_userdanger("\the [dildo] will hurt your target!"))
		return FALSE

	if(istype(user.get_active_held_item(), /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/contdildo = dildo
		if(contdildo.spillable)
			to_chat(user, span_info("\the [contdildo] will likely spill inside me."))
			to_chat(user, span_smallred("I can pump it with <bold>speed</bold> for faster success."))

	user.visible_message(span_warning("[user] stuffs \the [dildo] in their cunt..."))
	var/used_sex_volume = sex_volume
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		used_sex_volume *= 0.5
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), used_sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/portal_base/portal_object_fuck/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/pain_amt = 3 //base pain amt to use
	var/obj/item/dildo = user.get_active_held_item()

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] fucks their cunt with \the [dildo]."))
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		action_volume *= 0.5
	var/used_sex_volume = sex_volume
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		used_sex_volume *= 0.5
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
				target.visible_message(span_notice("[contdildo] splashes it's contents around your target's hole as it is packed full!"))
				contdildo.reagents.reaction(target, TOUCH, speed, FALSE)
				contdildo.reagents.remove_all(speed)
			else
				target.visible_message(span_notice(pick("[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] fill your target's ass.", "[user] feeds your target's ass with [english_list(contdildo.reagents.reagent_list)] from \The [contdildo]", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] splash into your target's ass.", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] flood into your target's ass.")), span_notice(pick("[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] fill my ass.", "I feed my ass with [english_list(contdildo.reagents.reagent_list)] from \The [contdildo]", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] splash into my ass.", "[english_list(contdildo.reagents.reagent_list)] from \the [contdildo] flood into me.")))
				contdildo.reagents.trans_to(targetpuss, speed, 1, TRUE, FALSE, targetpuss, FALSE, INJECT, FALSE, TRUE)
			playsound(user.loc, 'sound/misc/mat/endin.ogg', 20, TRUE)
			pain_amt = -8 //liquid ease pain i guess
			target.heal_bodypart_damage(0,1,0,TRUE) //water on burn i guess.

	perform_sex_action(user, target, 2, pain_amt, 2)
	handle_passive_ejaculation()


/datum/sex_action/portal_base/portal_object_fuck/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target, must_flip)
	user.visible_message(span_love("your target cream themselves!"))
	user.lose_virginity()
	return ORGASM_LOCATION_SELF

/datum/sex_action/portal_base/portal_object_fuck/on_finish(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/dildo = get_sextoy_in_hand(user)
	user.visible_message(span_warning("[user] pulls \the [dildo] from your target's cunt."))*/
/**
 * CRAFT AND SUPPLY
*/
// Both halves are arcyne work; the pair links by touching the light to the smallclothes.
/datum/repeatable_crafting_recipe/arcyne/portal_light
	name = "portal light"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t1 = 1,
		/obj/item/gem/amethyst = 1,
		/obj/item/natural/glass = 1,
	)
	output = /obj/item/portallight
	starting_atom = /obj/item/gem/amethyst
	attacked_atom = /obj/item/natural/glass
	craftdiff = 2

/datum/repeatable_crafting_recipe/arcyne/portal_panties
	name = "portal panties"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t1 = 1,
		/obj/item/gem/amethyst = 1,
		/obj/item/natural/silk = 2,
	)
	output = /obj/item/clothing/undies/portalpanties
	starting_atom = /obj/item/gem/amethyst
	attacked_atom = /obj/item/natural/silk
	craftdiff = 2
