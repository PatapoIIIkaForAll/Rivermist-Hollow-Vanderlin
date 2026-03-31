/mob/living/proc/get_highest_grab_state_on(mob/living/victim)
	var/grabstate = null
	if(r_grab && r_grab.grabbed == victim)
		if(grabstate == null || r_grab.grab_state > grabstate)
			grabstate = r_grab.grab_state
	if(l_grab && l_grab.grabbed == victim)
		if(grabstate == null || l_grab.grab_state > grabstate)
			grabstate = l_grab.grab_state
	return grabstate

/proc/do_thrust_animate(atom/movable/user, atom/movable/target, pixels = 4, time = 2.7)
	var/datum/sex_session/sex_session
	if(isliving(user) && isliving(target))
		sex_session = get_sex_session(user, target)
		if(!sex_session)
			sex_session = get_sex_session(target, user)
	if(sex_session)
		if(sex_session.speed > SEX_SPEED_MID)
			time = max(0.5, time - 0.25)
		if(sex_session.force < SEX_FORCE_MID)
			pixels = max(1, pixels - 1)
	var/oldx = user.pixel_x
	var/oldy = user.pixel_y
	var/target_x = oldx
	var/target_y = oldy
	var/dir = get_dir(user, target)
	if(user.loc == target.loc)
		dir = user.dir
	switch(dir)
		if(NORTH)
			target_y += pixels
		if(SOUTH)
			target_y -= pixels
		if(WEST)
			target_x -= pixels
		if(EAST)
			target_x += pixels

	animate(user, pixel_x = target_x, pixel_y = target_y, time = time)
	animate(pixel_x = oldx, pixel_y = oldy, time = time)

/mob/living/proc/start_sex_session(mob/living/target, show_ui = TRUE)
	if(!target)
		return
	if(!GetComponent(/datum/component/arousal))
		AddComponent(/datum/component/arousal)
	if(!target.GetComponent(/datum/component/arousal))
		target.AddComponent(/datum/component/arousal)
	var/datum/sex_session/old_session = get_sex_session(src, target)
	if(old_session && !QDELETED(old_session))
		if(show_ui)
			old_session.show_ui()
		return old_session


	var/datum/sex_session/session = new /datum/sex_session(src, target)
	LAZYADD(GLOB.sex_sessions, session)
	if(target.client && client && show_ui)
		session.show_ui()
	return session

/mob/living/proc/make_sucking_noise()
	if(gender == FEMALE)
		playsound(src, pick('sound/misc/mat/girlmouth (1).ogg','sound/misc/mat/girlmouth (2).ogg'), 25, TRUE, ignore_walls = FALSE)
	else
		playsound(src, pick('sound/misc/mat/guymouth (2).ogg','sound/misc/mat/guymouth (3).ogg','sound/misc/mat/guymouth (4).ogg','sound/misc/mat/guymouth (5).ogg'), 35, TRUE, ignore_walls = FALSE)

/mob/living/proc/can_do_sex()
	return TRUE

/mob/living/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	var/mob/living/target = src

	if(user.mmb_intent)
		return ..()
	if(!istype(dragged))
		return
	// Need to drag yourself to the target.
	if(dragged != user)
		return
	if(!user.can_do_sex())
		to_chat(user, "<span class='warning'>I can't do this.</span>")
		return

	if(!user.start_sex_session(target))
		to_chat(user, "<span class='warning'>I'm already sexing.</span>")
		return

/proc/get_sex_session(mob/giver, mob/taker)
	for(var/datum/sex_session/session as anything in GLOB.sex_sessions)
		if(session.user != giver)
			continue
		if(session.target != taker)
			continue
		return session
	return null

/proc/get_or_create_sex_session(mob/living/giver, mob/living/taker, show_ui = FALSE)
	if(!giver || !taker)
		return null

	var/datum/sex_session/session = get_sex_session(giver, taker)
	if(session && !QDELETED(session))
		if(show_ui)
			session.show_ui()
		return session

	return giver.start_sex_session(taker, show_ui)

/mob/living/proc/has_hands()
	return TRUE

/mob/living/proc/has_free_sex_hands()
	return has_hands() && !HAS_TRAIT(src, TRAIT_HANDS_BLOCKED)

/mob/living/proc/has_mouth()
	return TRUE

/mob/living/proc/has_penis()
	return getorganslot(ORGAN_SLOT_PENIS) || gender == MALE

/mob/living/proc/has_testicles()
	return getorganslot(ORGAN_SLOT_TESTICLES) || gender == MALE

/mob/living/proc/has_vagina()
	return getorganslot(ORGAN_SLOT_VAGINA) || gender == FEMALE

/mob/living/proc/has_breasts()
	return getorganslot(ORGAN_SLOT_BREASTS) || gender == FEMALE

/mob/living/proc/has_belly()
	RETURN_TYPE(/obj/item/organ/genitals/belly)
	return getorganslot(ORGAN_SLOT_BELLY)

/mob/living/proc/has_butt()
	RETURN_TYPE(/obj/item/organ/genitals/butt)
	return getorganslot(ORGAN_SLOT_BUTT)

/mob/living/proc/is_fertile()
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = getorganslot(ORGAN_SLOT_VAGINA)
	return vagina?.fertility

/mob/living/proc/is_virile()
	var/obj/item/organ/genitals/filling_organ/testicles/testicles = getorganslot(ORGAN_SLOT_TESTICLES)
	return testicles?.virility

/mob/living/carbon/human/has_penis()
	return getorganslot(ORGAN_SLOT_PENIS)

/mob/living/carbon/human/has_testicles()
	return getorganslot(ORGAN_SLOT_TESTICLES)

/mob/living/carbon/human/has_vagina()
	return getorganslot(ORGAN_SLOT_VAGINA)

/mob/living/carbon/human/has_breasts()
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ/breasts)
	return getorganslot(ORGAN_SLOT_BREASTS)

/mob/living/proc/mouth_is_free()
	return has_mouth() && !mouth_blocked && !is_muzzled() && !is_mouth_covered()

/mob/living/proc/get_worn_choker()
	return null

/mob/living/carbon/get_worn_choker()
	if(istype(choker, /obj/item/clothing/choker))
		return choker
	if(istype(wear_neck, /obj/item/clothing/choker))
		return wear_neck
	return null

/mob/living/proc/snap_worn_choker(mob/living/puller)
	var/obj/item/clothing/choker/worn_choker = get_worn_choker()
	if(!worn_choker)
		return FALSE

	if(worn_choker.loc == src)
		dropItemToGround(worn_choker, TRUE, TRUE)

	if(worn_choker.break_sound)
		playsound(src, 'modular_rmh/sound/effects/snap.ogg', 30, TRUE, -1)

	visible_message(
		span_warning("[puller ? "[puller] thrusts hard enough to snap [src]'s [worn_choker.name]!" : "[src]'s [worn_choker.name] snaps!"]"),
		span_warning("[puller ? "[puller] thrusts hard enough to snap my [worn_choker.name]!" : "My [worn_choker.name] snaps!"]")
	)

	worn_choker.atom_break()

	return TRUE

/mob/living/proc/foot_is_free()
	return is_barefoot()

/mob/living/proc/is_barefoot()
	for(var/item_slot in DEFAULT_SLOT_PRIORITY)
		var/obj/item/clothing = get_item_by_slot(item_slot)
		if(!clothing) // Don't have this slot or not wearing anything in it
			continue
		if(clothing.body_parts_covered & FEET)
			return FALSE
	// If didn't stop before, then we're barefoot
	return TRUE

/mob/living/carbon/human/has_mouth()
	return get_bodypart(BODY_ZONE_HEAD)

/mob/living/carbon/human/has_hands() // technically should be an and but i'll replicate original behavior
	return get_bodypart(BODY_ZONE_L_ARM) || get_bodypart(BODY_ZONE_R_ARM)

/mob/living/proc/get_character_information_line(summary_text)
	if(!length("[summary_text]"))
		return null
	summary_text = "[summary_text]"
	var/last_character = copytext(summary_text, length(summary_text), length(summary_text) + 1)
	if(!(last_character in list(".", "!", "?")))
		summary_text += "."
	return "<div>...[html_encode("[summary_text]")]</div>"

/mob/living/proc/get_general_sex_state_summary()
	var/datum/component/arousal/arousal_component = GetComponent(/datum/component/arousal)
	if(!arousal_component)
		return null

	var/list/arousal_data = list()
	SEND_SIGNAL(src, COMSIG_SEX_GET_AROUSAL, arousal_data)

	var/current_arousal = arousal_data["arousal"] || 0
	var/current_orgasm_progress = arousal_data["orgasm_progress"] || 0
	var/state_summary = "feel calm"

	switch(current_arousal)
		if(1 to 19)
			state_summary = "feel a little worked up"
		if(20 to 49)
			state_summary = "feel lightly aroused"
		if(50 to 79)
			state_summary = "feel hot and needy"
		if(80 to INFINITY)
			state_summary = "feel desperately aroused"

	if(arousal_component.is_spent())
		state_summary += ", but spent from recent release"

	if(current_orgasm_progress >= PASSIVE_EJAC_THRESHOLD)
		state_summary += " and right on the brink"
	else if(current_orgasm_progress >= PASSIVE_EJAC_THRESHOLD * 0.7)
		state_summary += " and close to climax"

	return "[state_summary]."

/mob/living/proc/return_character_information()
	var/list/data = list()
	if(has_hands())
		data += get_character_information_line("have hands, which are [has_free_sex_hands() ? "free" : "blocked"]")
	if(has_mouth())
		data += get_character_information_line("have a mouth, which is [mouth_is_free() ? "uncovered" : "covered"]")
	var/general_state_summary = get_general_sex_state_summary()
	if(general_state_summary)
		data += get_character_information_line(general_state_summary)
	return data

/mob/living/carbon/human/proc/get_visible_groin_summary_description(descriptor_type)
	if(!get_location_accessible(src, BODY_ZONE_PRECISE_GROIN, skipundies = FALSE))
		return null
	var/datum/mob_descriptor/descriptor = new descriptor_type()
	return descriptor.get_description(src)

/mob/living/carbon/human/proc/get_visible_chest_summary_description(descriptor_type)
	if(!get_location_accessible(src, BODY_ZONE_CHEST))
		return null
	if(underwear?.covers_breasts)
		return null
	var/datum/mob_descriptor/descriptor = new descriptor_type()
	return descriptor.get_description(src)

/mob/living/carbon/human/proc/get_visible_anus_summary()
	var/obj/item/organ/genitals/filling_organ/anus/anus = getorganslot(ORGAN_SLOT_ANUS)
	if(!anus)
		return null
	if(!get_location_accessible(src, BODY_ZONE_PRECISE_GROIN, skipundies = FALSE))
		return null
	return "have an exposed anus."

/mob/living/carbon/human/return_character_information()
	var/list/data = ..()
	if(!data)
		data = list()

	var/breasts_summary = get_visible_chest_summary_description(/datum/mob_descriptor/breasts)
	if(breasts_summary)
		data += get_character_information_line("have [breasts_summary]")

	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	var/penis_summary = get_visible_groin_summary_description(/datum/mob_descriptor/penis)
	if(penis_summary)
		data += get_character_information_line("have [penis_summary]")

	var/testicles_summary = null
	if(!penis || penis.sheath_type != SHEATH_TYPE_SLIT)
		testicles_summary = get_visible_groin_summary_description(/datum/mob_descriptor/testicles)
	if(testicles_summary)
		data += get_character_information_line("have [testicles_summary]")

	var/vagina_summary = get_visible_groin_summary_description(/datum/mob_descriptor/vagina)
	if(vagina_summary)
		data += get_character_information_line("have [vagina_summary]")

	var/butt_summary = get_visible_groin_summary_description(/datum/mob_descriptor/butt)
	if(butt_summary)
		data += get_character_information_line("have [butt_summary]")

	var/anus_summary = get_visible_anus_summary()
	if(anus_summary)
		data += get_character_information_line(anus_summary)

	return data

/mob/living/proc/get_active_precise_hand()
	var/active_hand = BODY_ZONE_PRECISE_L_HAND
	if(active_hand_index != 1)
		active_hand = BODY_ZONE_PRECISE_R_HAND
	return active_hand

/mob/living/proc/get_inactive_precise_hand()
	if(get_active_precise_hand() == BODY_ZONE_PRECISE_L_HAND)
		return BODY_ZONE_PRECISE_R_HAND
	return BODY_ZONE_PRECISE_L_HAND

/mob/proc/check_handholding()
	return

/mob/living/carbon/human/check_handholding()
	if(pulledby && pulledby != src)
		var/obj/item/bodypart/LH
		var/obj/item/bodypart/RH
		LH = get_bodypart(BODY_ZONE_PRECISE_L_HAND)
		RH = get_bodypart(BODY_ZONE_PRECISE_R_HAND)
		if(LH || RH)
			for(var/obj/item/grabbing/G in src.grabbedby)
				if(G.limb_grabbed == LH || G.limb_grabbed == RH)
					return TRUE

/proc/return_sessions_with_user(mob/living/user)
	var/list/sessions = list()
	for(var/datum/sex_session/session in GLOB.sex_sessions)
		if(user != session.target && user != session.user)
			continue
		sessions |= session
	return sessions

/proc/return_highest_priority_action(list/sessions = list(), mob/living/user)
	var/datum/sex_session/highest_session
	for(var/datum/sex_session/session in sessions)
		var/datum/sex_action/session_action = session.get_highest_priority_action_for(user)
		if(!session_action)
			continue
		if(!highest_session)
			highest_session = session
			continue
		var/datum/sex_action/highest_action = highest_session.get_highest_priority_action_for(user)
		if(user == session.target)
			if(session_action.target_priority > highest_action.target_priority)
				highest_session = session
				continue
		if(user == session.user)
			if(session_action.user_priority > highest_action.user_priority)
				highest_session = session
				continue
	return highest_session

/mob/proc/get_erp_pref(pref_type)
	if(!client?.prefs)
		return FALSE

	if(!ispath(pref_type, /datum/erp_preference))
		return FALSE

	var/datum/erp_preference/pref = new pref_type()
	return pref.get_value(client.prefs)

/mob/proc/set_erp_pref(pref_type, value)
	if(!client?.prefs)
		return FALSE

	if(!ispath(pref_type, /datum/erp_preference))
		return FALSE

	var/datum/erp_preference/pref = new pref_type()
	pref.set_value(client.prefs, value)
	client.prefs.save_preferences()
	return TRUE

/mob/proc/has_erp_pref(pref_type)
	return get_erp_pref(pref_type) == TRUE

/proc/should_apply_mob_erp_target_pref(mob/living/actor, mob/living/target)
	if(!isliving(actor) || !isliving(target))
		return FALSE
	if(actor.client)
		return FALSE
	if(!target.client)
		return FALSE
	return TRUE

/proc/target_allows_mob_erp_action(mob/living/actor, mob/living/target, pref_type)
	if(!ispath(pref_type, /datum/erp_preference))
		return TRUE
	if(!should_apply_mob_erp_target_pref(actor, target))
		return TRUE
	return target.get_erp_pref(pref_type)

/mob/proc/get_all_erp_prefs()
	if(!client?.prefs)
		return list()

	var/list/prefs_by_category = list()

	for(var/pref_type in subtypesof(/datum/erp_preference))
		var/datum/erp_preference/pref = new pref_type()
		var/category = pref.category
		var/value = pref.get_value(client.prefs)

		if(!prefs_by_category[category])
			prefs_by_category[category] = list()

		prefs_by_category[category][pref_type] = list(
			"name" = pref.name,
			"description" = pref.description,
			"value" = value,
			"pref_object" = pref
		)

	return prefs_by_category

/proc/any_has_erp_pref(list/mobs, pref_type)
	for(var/mob/M in mobs)
		if(M.has_erp_pref(pref_type))
			return TRUE
	return FALSE

/proc/all_have_erp_pref(list/mobs, pref_type)
	for(var/mob/M in mobs)
		if(!M.has_erp_pref(pref_type))
			return FALSE
	return TRUE

/mob/living/proc/has_kink(kink_name)
	if(!client?.prefs?.erp_preferences)
		return FALSE
	var/list/kink_prefs = client.prefs.erp_preferences["kinks"]
	if(!kink_prefs || !kink_prefs[kink_name])
		return FALSE
	return kink_prefs[kink_name]["enabled"]


/mob/living
	var/list/attached_sex_toys = list()

	///npc organs to use
	var/ball_organ = /obj/item/organ/genitals/filling_organ/testicles
	var/ball_min = MIN_TESTICLES_SIZE
	var/ball_max = MAX_TESTICLES_SIZE
	var/breast_organ = /obj/item/organ/genitals/filling_organ/breasts
	var/breast_min = MIN_BREASTS_SIZE
	var/breast_max = MAX_BREASTS_SIZE
	var/ass_organ = /obj/item/organ/genitals/butt
	var/ass_min = MIN_BUTT_SIZE
	var/ass_max = MAX_BUTT_SIZE
	var/penis_organ = /obj/item/organ/genitals/penis
	var/penis_min = MIN_PENIS_SIZE
	var/penis_max = MAX_PENIS_SIZE
	var/butt_organ = /obj/item/organ/genitals/butt
	var/butt_min = MIN_BUTT_SIZE
	var/butt_max = MAX_BUTT_SIZE
	var/vagina_organ = /obj/item/organ/genitals/filling_organ/vagina
	var/show_genitals = FALSE
	var/mouth_blocked = FALSE

/mob/living/Initialize()
	. = ..()
	if(ai_controller)
		var/datum/ai_planning_subtree/horny/hornybehavior = locate() in ai_controller.planning_subtrees
		if(hornybehavior && !GetComponent(/datum/component/arousal))
			AddComponent(/datum/component/arousal)

/mob/living/proc/give_genitals()
	var/mob/living/user = src
	var/obj/item/organ/genitals/filling_organ/anus/anus = user.getorganslot(ORGAN_SLOT_ANUS)
	if(!anus)
		anus = new /obj/item/organ/genitals/filling_organ/anus
		anus.Insert(user, TRUE)
	if(gender == MALE)
		var/obj/item/organ/genitals/filling_organ/testicles/testicles = user.getorganslot(ORGAN_SLOT_TESTICLES)
		if(!testicles)
			if(!show_genitals)
				testicles = new /obj/item/organ/genitals/filling_organ/testicles/invisible
			else
				testicles = new ball_organ
			testicles.organ_size = rand(ball_min, ball_max)
			testicles.Insert(user, TRUE)
		var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
		if(!penis)
			if(!show_genitals)
				penis = new /obj/item/organ/genitals/penis
			else
				penis = new penis_organ
			penis.organ_size = rand(penis_min, penis_max)
			penis.Insert(user, TRUE)
	if(gender == FEMALE)
		var/obj/item/organ/genitals/butt/buttie = user.getorganslot(ORGAN_SLOT_BUTT)
		if(!buttie)
			if(!show_genitals)
				buttie = new /obj/item/organ/genitals/butt/invisible
			else
				buttie = new butt_organ
			buttie.organ_size = rand(butt_min, butt_max)
			buttie.Insert(user, TRUE)
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = user.getorganslot(ORGAN_SLOT_BREASTS)
		if(!breasts)
			if(!show_genitals)
				breasts = new /obj/item/organ/genitals/filling_organ/breasts
			else
				breasts = new breast_organ
			breasts.organ_size = rand(breast_min,breast_max)
			breasts.Insert(user, TRUE)
		var/obj/item/organ/genitals/filling_organ/vagina/vagina = user.getorganslot(ORGAN_SLOT_VAGINA)
		if(!vagina)
			if(!show_genitals)
				vagina = new /obj/item/organ/genitals/filling_organ/vagina
			else
				vagina = new vagina_organ
			vagina.Insert(user, TRUE)
		if(prob(5)) //5 chance to be dickgirl.
			var/obj/item/organ/genitals/filling_organ/testicles/testicles = user.getorganslot(ORGAN_SLOT_TESTICLES)
			if(!testicles)
				if(!show_genitals)
					testicles = new /obj/item/organ/genitals/filling_organ/testicles/invisible
				else
					testicles = new ball_organ
				testicles.organ_size = rand(ball_min, ball_max)
				testicles.Insert(user, TRUE)
			var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
			if(!penis)
				if(!show_genitals)
					penis = new /obj/item/organ/genitals/penis
				else
					penis = new penis_organ
				penis.organ_size = rand(penis_min, penis_max)
				penis.Insert(user, TRUE)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.update_body_parts()

/mob/living/proc/lose_virginity()
	return

/mob/living/carbon/human/lose_virginity()
	virginity = FALSE

/mob/living/proc/adjacent_or_closet(atom/neighbor)
	if(istype(loc, /obj/structure/closet) || istype(loc, /obj/structure/handcart) || istype(neighbor.loc, /obj/structure/closet) || istype(neighbor.loc, /obj/structure/handcart)) // within container
		return loc == neighbor.loc
	return Adjacent(neighbor)

/mob/living/proc/check_closet(atom/neighbor)
	if(istype(loc, /obj/structure/closet) || istype(loc, /obj/structure/handcart) || istype(neighbor.loc, /obj/structure/closet) || istype(neighbor.loc, /obj/structure/handcart)) // within container
		return loc == neighbor.loc
	else
		return FALSE
