// Which sex actions leave lipstick, where and how; and Nibble, a gentle bite that leaves lipstick-ringed marks.

/datum/sex_action
	/// Lipstick spots the giving mouth marks each cycle; null leaves none.
	var/list/lipstick_spots
	var/lipstick_kind = LIPSTICK_KIND_SMEAR
	/// The action target's mouth does the work, as in facesitting.
	var/lipstick_from_target = FALSE
	/// Both mouths meet and mark each other.
	var/lipstick_mutual = FALSE

/// Spots this run marks; actions that pick a spot when proposed override it.
/datum/sex_action/proc/get_lipstick_spots()
	return lipstick_spots

/// Run after each perform; gates live on the giver and the marked spot.
/datum/sex_action/proc/leave_perform_lipstick_marks()
	var/list/spots = get_lipstick_spots()
	if(!length(spots) || !action_user || !action_target)
		return
	var/mob/living/giver = lipstick_from_target ? action_target : action_user
	var/mob/living/receiver = lipstick_from_target ? action_user : action_target
	for(var/spot in spots)
		giver.leave_lipstick_mark(receiver, spot, lipstick_kind)
		if(lipstick_mutual)
			receiver.leave_lipstick_mark(giver, spot, lipstick_kind)

/datum/sex_action/kissing
	lipstick_spots = list(LIPSTICK_SPOT_LIPS)
	lipstick_kind = LIPSTICK_KIND_KISS
	lipstick_mutual = TRUE

/datum/sex_action/penis_head_worship
	lipstick_spots = list(LIPSTICK_SPOT_COCK)
	lipstick_kind = LIPSTICK_KIND_KISS

/datum/sex_action/blowjob
	lipstick_spots = list(LIPSTICK_SPOT_COCK)
	lipstick_kind = LIPSTICK_KIND_RING

/datum/sex_action/sex/throat
	lipstick_spots = list(LIPSTICK_SPOT_COCK)
	lipstick_kind = LIPSTICK_KIND_DEEP
	lipstick_from_target = TRUE

/datum/sex_action/suck_balls
	lipstick_spots = list(LIPSTICK_SPOT_BALLS)

/datum/sex_action/cunnilingus
	lipstick_spots = list(LIPSTICK_SPOT_VULVA)

/datum/sex_action/crotch_nuzzle
	lipstick_spots = list(LIPSTICK_SPOT_CROTCH)

/datum/sex_action/rimming
	lipstick_spots = list(LIPSTICK_SPOT_ANUS)
	lipstick_kind = LIPSTICK_KIND_RING

/datum/sex_action/facesitting
	lipstick_spots = list(LIPSTICK_SPOT_ANUS)
	lipstick_from_target = TRUE

/datum/sex_action/suck_nipples
	lipstick_spots = list(LIPSTICK_SPOT_NIPPLES)

/datum/sex_action/armpit_nuzzle
	lipstick_spots = list(LIPSTICK_SPOT_ARMPIT)

/datum/sex_action/tonguebath
	lipstick_spots = list(LIPSTICK_SPOT_CHEST, LIPSTICK_SPOT_BELLY)

/datum/sex_action/foot_lick
	lipstick_spots = list(LIPSTICK_SPOT_L_FOOT, LIPSTICK_SPOT_R_FOOT)

/// Gentle nips on the spot the user aims at; no damage, and a lipstick-ringed bite if the lips are painted.
/datum/sex_action/nibble
	name = "Nibble"
	description = "Nip gently at their neck, ear, nipples, thigh or butt."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_BODY | SEX_UI_ZONE_LEGS
	menu_category = "mouth"
	menu_tip = "Nip gently; painted lips leave ringed bites."
	check_same_tile = FALSE
	lipstick_kind = LIPSTICK_KIND_BITE
	/// The targeting-doll zone picked when the action was proposed.
	var/nibble_zone

/datum/sex_action/nibble/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	nibble_zone = controller.user.zone_selected
	return TRUE

/// The spot a zone's nibble lands on; zones without one take the neck.
/datum/sex_action/nibble/proc/get_nibble_spot()
	switch(nibble_zone)
		if(BODY_ZONE_PRECISE_EARS, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL)
			return LIPSTICK_SPOT_EAR
		if(BODY_ZONE_CHEST)
			return LIPSTICK_SPOT_NIPPLES
		if(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)
			return LIPSTICK_SPOT_L_THIGH
		if(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
			return LIPSTICK_SPOT_R_THIGH
		if(BODY_ZONE_PRECISE_GROIN)
			return LIPSTICK_SPOT_BUTT
	return LIPSTICK_SPOT_NECK

/datum/sex_action/nibble/proc/get_nibble_place(mob/living/target)
	var/spot = get_nibble_spot()
	return "[target]'s [GLOB.lipstick_mark_spots[spot]["name"]]"

/datum/sex_action/nibble/get_lipstick_spots()
	return list(get_nibble_spot())

/datum/sex_action/nibble/shows_on_menu(mob/living/user, mob/living/target)
	return user != target

/datum/sex_action/nibble/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(user, target, GLOB.lipstick_mark_spots[get_nibble_spot()]["limb"]))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/nibble/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lowers [user.p_their()] mouth to [get_nibble_place(target)]..."))

/datum/sex_action/nibble/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] nibbles [get_nibble_place(target)]..."))
	perform_sex_action(target, user, 0.8, 0.5, 0)
	perform_sex_action(user, target, 0.3, 0, 0)

/datum/sex_action/nibble/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lifts [user.p_their()] teeth from [get_nibble_place(target)]."))

/datum/sex_action/nibble/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
