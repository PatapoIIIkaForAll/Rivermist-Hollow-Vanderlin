
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	RETURN_TYPE(/obj/item/bodypart)
	if(!zone)
		zone = BODY_ZONE_CHEST
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(bodypart.body_zone == zone)
			return bodypart
		for(var/subzone in bodypart.subtargets)
			if(subzone != zone)
				continue
			return bodypart

/mob/living/carbon/proc/get_bodypart_complex(list/zones)
	if(!length(zones))
		zones = list(BODY_ZONE_CHEST)
	var/list/targets = list()
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(bodypart.body_zone in zones)
			targets += bodypart
		else
			for(var/subzone in bodypart.subtargets)
				if(!(subzone in zones))
					continue
				targets += bodypart
				break
	if(length(targets))
		return pick(targets)

/mob/living/carbon/has_hand_for_held_index(i, extra_checks)
	if(!i || length(hand_bodyparts) < i)
		return FALSE
	var/obj/item/bodypart/hand_instance = hand_bodyparts[i]
	if(hand_instance && !hand_instance.bodypart_disabled)
		if(extra_checks)
			if(!hand_instance.fingers || HAS_TRAIT(hand_instance, TRAIT_FINGERLESS))
				return FALSE
		return hand_instance
	return FALSE

/mob/proc/has_left_hand(check_disabled = TRUE)
	return TRUE

/mob/living/carbon/has_left_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(L.held_index % 2)
			if(!check_disabled || !L.bodypart_disabled)
				return TRUE
	return FALSE



/mob/proc/has_right_hand(check_disabled = TRUE)
	return TRUE

/mob/living/carbon/has_right_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(!(L.held_index % 2))
			if(!check_disabled || !L.bodypart_disabled)
				return TRUE
	return FALSE

/// Get the bodypart for whatever hand we have active, Only relevant for carbons
/mob/proc/get_active_hand()
	return FALSE

/mob/living/carbon/get_active_hand()
	return LAZYACCESS(hand_bodyparts, active_hand_index)

/mob/living/carbon/proc/get_missing_limbs()
	RETURN_TYPE(/list)
	var/list/full = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
	)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/proc/get_disabled_limbs()
	return list()

/mob/living/carbon/get_disabled_limbs()
	var/list/full = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
	)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting?.bodypart_disabled)
			disabled += zone
	return disabled

//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/mob/living/carbon/proc/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/proc/update_limb_efficiencies()
	return

/mob/living/carbon/update_limb_efficiencies()
	if(status_flags & BUILDING_ORGANS)
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.update_limb_efficiency()

//Limb numbers
/mob/proc/get_num_arms(check_disabled = TRUE)
	return 2

/mob/living/carbon/get_num_arms(check_disabled = TRUE)
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			if(!check_disabled || !affecting?.bodypart_disabled)
				.++
		if(affecting.body_part == ARM_LEFT)
			if(!check_disabled || !affecting?.bodypart_disabled)
				.++

//sometimes we want to ignore that we don't have the required amount of arms.
/mob/proc/get_arm_ignore()
	return 0

/mob/proc/get_num_legs(check_disabled = TRUE)
	return 2

/mob/living/carbon/get_num_legs(check_disabled = TRUE)
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part & LEG_RIGHT)
			if(!check_disabled || !affecting?.bodypart_disabled)
				.++
		if(affecting.body_part & LEG_LEFT)
			if(!check_disabled || !affecting?.bodypart_disabled)
				.++

//sometimes we want to ignore that we don't have the required amount of legs.
/mob/proc/get_leg_ignore()
	return FALSE


/mob/living/carbon/human/get_leg_ignore()
	if(movement_type & (FLYING | FLOATING))
		return TRUE
	return FALSE

/mob/living/proc/get_taur_tail()
	RETURN_TYPE(/obj/item/bodypart/taur)
	return null

/mob/living/carbon/get_taur_tail()
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_zone == BODY_ZONE_TAUR)
			return affecting
	return null

/mob/living/carbon/proc/ensure_not_taur()
	var/needs_new_legs = FALSE
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = X
		if(O.body_zone == BODY_ZONE_TAUR)
			O.drop_limb(1)
			qdel(O)
			needs_new_legs = TRUE

	if(needs_new_legs)
		var/obj/item/bodypart/N
		N = new /obj/item/bodypart/l_leg
		N.attach_limb(src)

		N = new /obj/item/bodypart/r_leg
		N.attach_limb(src)

	// make sure we unapply our clipmasks; whoever set BUILDING_ORGANS redraws once when done
	if(!(status_flags & BUILDING_ORGANS))
		regenerate_icons()
	set_resting(FALSE)

/mob/living/carbon/proc/Taurize(taur_type = /obj/item/bodypart/taur, color = "#ffffff", markings = "#ffffff", tertiary = "#ffffff")
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = X
		// drop taur tails too
		if(O.body_part == LEG_LEFT || O.body_part == LEG_RIGHT || O.body_zone == BODY_ZONE_TAUR)
			O.drop_limb(1)
			qdel(O)

	var/obj/item/bodypart/taur/T = new taur_type()
	T.taur_color = color
	if(markings)
		T.taur_markings = markings
	if(tertiary)
		T.taur_tertiary = tertiary
	T.attach_limb(src)

	// make sure we apply our clipmasks; whoever set BUILDING_ORGANS redraws once when done
	if(!(status_flags & BUILDING_ORGANS))
		regenerate_icons()
	resting = FALSE
	update_resting()
	set_body_position(STANDING_UP)
	set_lying_angle(0)
