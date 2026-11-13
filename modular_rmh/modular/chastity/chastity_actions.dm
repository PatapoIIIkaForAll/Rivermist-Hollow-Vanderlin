// Chastity play: sex actions done to or with a worn chastity device rather than the organ it locks away.

#define CHASTITY_PART_ANY "any"
#define CHASTITY_PART_COCK "cock"
#define CHASTITY_PART_PUSSY "pussy"
#define CHASTITY_PART_REAR "rear"

/datum/sex_action/chastity
	abstract_type = /datum/sex_action/chastity
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	/// Which locked part the action works; see CHASTITY_PART_*.
	var/device_part = CHASTITY_PART_ANY
	/// TRUE when the action user wears the device, FALSE when the target does.
	var/device_on_user = FALSE
	/// TRUE for actions done on oneself, FALSE for actions done on a partner.
	var/self_only = FALSE
	/// A part the other participant must also have locked away, for device-to-device play.
	var/partner_device_part
	/// Organ slot of the other participant put to use; also list it in uses_*_organs.
	var/partner_organ_slot
	/// TRUE when that organ must be a cock with a genital slit.
	var/partner_needs_slit = FALSE
	/// Body zone of the other participant put to use, such as the mouth.
	var/partner_zone

/datum/sex_action/chastity/proc/get_device_wearer(mob/living/user, mob/living/target)
	return device_on_user ? user : target

/// The participant who does not wear the worked device.
/datum/sex_action/chastity/proc/get_partner(mob/living/user, mob/living/target)
	return device_on_user ? target : user

/// The device [wearer] has on that locks away [part] (this action's part by default), or null.
/datum/sex_action/chastity/proc/get_device(mob/living/wearer, part)
	RETURN_TYPE(/obj/item/clothing/undies/chastity)
	if(!part)
		part = device_part
	var/mob/living/carbon/human/human_wearer = wearer
	if(!istype(human_wearer))
		return null
	var/obj/item/clothing/undies/chastity/device = human_wearer.underwear
	if(!istype(device))
		return null
	switch(part)
		if(CHASTITY_PART_COCK)
			return device.cages_cock() ? device : null
		if(CHASTITY_PART_PUSSY)
			return device.seals_pussy() ? device : null
		if(CHASTITY_PART_REAR)
			return device.blocks_organ_use(ORGAN_SLOT_ANUS) ? device : null
	return (device.get_front_anatomy() || device.blocks_organ_use(ORGAN_SLOT_ANUS)) ? device : null

/// The sex lock slot that keeps two actions off the same locked part.
/datum/sex_action/chastity/proc/get_part_lock_slot(part)
	switch(part || device_part)
		if(CHASTITY_PART_COCK)
			return ORGAN_SLOT_PENIS
		if(CHASTITY_PART_PUSSY)
			return ORGAN_SLOT_VAGINA
		if(CHASTITY_PART_REAR)
			return ORGAN_SLOT_ANUS
	return BODY_ZONE_PRECISE_GROIN

/datum/sex_action/chastity/proc/is_right_pairing(mob/living/user, mob/living/target)
	return self_only == (user == target)

/proc/has_genital_slit(mob/living/living)
	var/obj/item/organ/genitals/penis/penis = living?.getorganslot(ORGAN_SLOT_PENIS)
	return penis?.sheath_type == SHEATH_TYPE_SLIT

/// A tail must be real to move; a worn strapon still counts as a cock.
/datum/sex_action/chastity/proc/partner_has_organ(mob/living/partner)
	if(partner_organ_slot == ORGAN_SLOT_TAIL)
		return get_real_organ(partner, ORGAN_SLOT_TAIL)
	return partner.getorganslot(partner_organ_slot)

/// Whether the other participant has what the action needs, ignoring reach and locks.
/datum/sex_action/chastity/proc/partner_has_parts(mob/living/partner)
	if(partner_device_part && !get_device(partner, partner_device_part))
		return FALSE
	if(partner_organ_slot && !partner_has_organ(partner))
		return FALSE
	if(partner_needs_slit && !has_genital_slit(partner))
		return FALSE
	return TRUE

/datum/sex_action/chastity/shows_on_menu(mob/living/user, mob/living/target)
	if(!is_right_pairing(user, target))
		return FALSE
	if(!user.allows_chastity_play() || !target.allows_chastity_play())
		return FALSE
	if(!get_device(get_device_wearer(user, target)))
		return FALSE
	return partner_has_parts(get_partner(user, target))

/datum/sex_action/chastity/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!is_right_pairing(user, target))
		return FALSE
	if(!user.allows_chastity_play() || !target.allows_chastity_play())
		return FALSE
	var/mob/living/wearer = get_device_wearer(user, target)
	var/mob/living/partner = get_partner(user, target)
	if(!get_device(wearer) || !partner_has_parts(partner))
		return FALSE
	if(check_sex_lock(wearer, get_part_lock_slot()))
		return FALSE
	if(!check_location_accessible(user, wearer, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(partner_device_part && check_sex_lock(partner, get_part_lock_slot(partner_device_part)))
		return FALSE
	if(partner_organ_slot && check_sex_lock(partner, partner_organ_slot))
		return FALSE
	if((partner_device_part || partner_organ_slot == ORGAN_SLOT_PENIS || partner_organ_slot == ORGAN_SLOT_VAGINA) && !check_location_accessible(user, partner, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(partner_zone && (check_sex_lock(partner, partner_zone) || !check_location_accessible(wearer, partner, partner_zone)))
		return FALSE
	return TRUE

/datum/sex_action/chastity/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(get_device_wearer(user, target), get_part_lock_slot(), null, FALSE)
	var/mob/living/partner = get_partner(user, target)
	if(partner_device_part)
		add_sex_lock(partner, get_part_lock_slot(partner_device_part), null, FALSE)
	if(partner_organ_slot)
		add_sex_lock(partner, partner_organ_slot)
	if(partner_zone)
		add_sex_lock(partner, partner_zone)

/// Now and then the device rattles under firmer handling.
/datum/sex_action/chastity/proc/rattle_device(mob/living/wearer)
	if(force >= SEX_FORCE_MID && prob(20 + speed * 10))
		playsound(wearer, SFX_JINGLE_BELLS, 20 + force * 5, TRUE, -2, ignore_walls = FALSE)

/datum/sex_action/chastity/proc/device_name(mob/living/wearer)
	return get_device(wearer, CHASTITY_PART_ANY)?.name || "chastity device"

// ---- Hands ----

/datum/sex_action/chastity/hands
	abstract_type = /datum/sex_action/chastity/hands
	requires_free_hands = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS

/datum/sex_action/chastity/hands/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!find_available_hand(user)

/datum/sex_action/chastity/hands/lock_sex_object(mob/living/user, mob/living/target)
	. = ..()
	var/hand = get_hand_lock_slot(user)
	if(hand)
		add_sex_lock(user, hand)

/datum/sex_action/chastity/hands/self_cock
	name = "Stroke cage"
	description = "Work your caged cock through the bars."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	self_only = TRUE

/datum/sex_action/chastity/hands/self_cock/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] wraps [user.p_their()] hand around [user.p_their()] [device_name(user)] and starts working it slowly, knuckles pressing into the bars."))

/datum/sex_action/chastity/hands/self_cock/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] drags [user.p_their()] palm along [user.p_their()] [device_name(user)], cock straining into the bars with every pass..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 25, TRUE, -2, ignore_walls = FALSE)
	rattle_device(user)
	perform_sex_action(user, user, 1.5, 0, 0.8)
	handle_passive_ejaculation()

/datum/sex_action/chastity/hands/self_cock/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] drops [user.p_their()] hand from [user.p_their()] [device_name(user)], breathless and no further along."))

/datum/sex_action/chastity/hands/self_pussy
	name = "Rub belt"
	description = "Rub at the front plate of your belt."
	device_part = CHASTITY_PART_PUSSY
	device_on_user = TRUE
	self_only = TRUE

/datum/sex_action/chastity/hands/self_pussy/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] presses [user.p_their()] fingers flat against [user.p_their()] [device_name(user)], searching for a gap in the front plate."))

/datum/sex_action/chastity/hands/self_pussy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rubs circles over the front of [user.p_their()] [device_name(user)], fingers pressing where it matters, barely..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 25, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(user, user, 1.5, 0, 0.8)
	handle_passive_ejaculation()

/datum/sex_action/chastity/hands/self_pussy/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] hand away from [user.p_their()] [device_name(user)], no closer to relief."))

/datum/sex_action/chastity/hands/self_rear
	name = "Rub shield"
	description = "Press at the rear plate of your device."
	device_part = CHASTITY_PART_REAR
	device_on_user = TRUE
	self_only = TRUE

/datum/sex_action/chastity/hands/self_rear/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] reaches back to press [user.p_their()] fingers against the rear shield of [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/hands/self_rear/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [user.p_their()] fingers against the rear plate, pressing where the shield rides closest to skin..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(user, user, 1.2, 0, 0.6)
	handle_passive_ejaculation()

/datum/sex_action/chastity/hands/self_rear/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] withdraws [user.p_their()] hand from [user.p_their()] rear shield."))

/datum/sex_action/chastity/hands/fondle
	name = "Fondle device"
	description = "Feel the weight of their device in your hands."

/datum/sex_action/chastity/hands/fondle/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] wraps [user.p_their()] fingers around [target]'s [device_name(target)], feeling the weight of it."))

/datum/sex_action/chastity/hands/fondle/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] squeezes and rolls [target]'s [device_name(target)] in [user.p_their()] palm, working the metal deliberately..."))
	rattle_device(target)
	perform_sex_action(target, user, 0.6, 0, 0.3)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/hands/fondle/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] releases [target]'s [device_name(target)] and pulls [user.p_their()] hands away."))

/datum/sex_action/chastity/hands/stroke_cock
	name = "Cage stroking"
	description = "Stroke their cock through the bars of the cage."
	device_part = CHASTITY_PART_COCK

/datum/sex_action/chastity/hands/stroke_cock/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] closes [user.p_their()] fingers around [target]'s [device_name(target)] and starts a slow, deliberate stroke."))

/datum/sex_action/chastity/hands/stroke_cock/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [target]'s [device_name(target)] with a measured grip, [target.p_their()] cock pressing uselessly into the bars with every pull..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 25, TRUE, -2, ignore_walls = FALSE)
	rattle_device(target)
	perform_sex_action(target, user, 1.8, 0, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/hands/stroke_cock/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of [target]'s [device_name(target)]."))

/datum/sex_action/chastity/hands/rub_pussy
	name = "Belt rubbing"
	description = "Work your fingers along the front of their belt."
	device_part = CHASTITY_PART_PUSSY

/datum/sex_action/chastity/hands/rub_pussy/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] traces two fingers over the front plate of [target]'s [device_name(target)], finding the slot."))

/datum/sex_action/chastity/hands/rub_pussy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [user.p_their()] fingers along the gap in [target]'s [device_name(target)], feeling the heat of locked skin through the slit..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 25, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 1.8, 0, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/hands/rub_pussy/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] slides [user.p_their()] fingers away from [target]'s [device_name(target)]."))

/datum/sex_action/chastity/hands/tease_rear
	name = "Shield teasing"
	description = "Press along the seam of their rear shield."
	device_part = CHASTITY_PART_REAR

/datum/sex_action/chastity/hands/tease_rear/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] slides [user.p_their()] hand behind [target] to find the edge of [target.p_their()] rear shield."))

/datum/sex_action/chastity/hands/tease_rear/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [user.p_their()] fingers along the seam of [target]'s rear shield, pressing inward where the plate meets skin..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 1.4, 0, 0.8)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/hands/tease_rear/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] draws [user.p_their()] hand back from [target]'s rear shield."))

/datum/sex_action/chastity/hands/work_insert
	name = "Work insert"
	description = "Rock their belt so the plug inside it moves."
	device_part = CHASTITY_PART_PUSSY

/datum/sex_action/chastity/hands/work_insert/get_device(mob/living/wearer, part)
	var/obj/item/clothing/undies/chastity/device = ..()
	return device?.has_insert ? device : null

/datum/sex_action/chastity/hands/work_insert/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] takes hold of [target]'s [device_name(target)] with both hands and starts rocking it slowly."))

/datum/sex_action/chastity/hands/work_insert/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rocks [target]'s [device_name(target)], shifting the plug inside with every tilt..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 25, TRUE, -2, ignore_walls = FALSE)
	rattle_device(target)
	perform_sex_action(target, user, 2.3, 1.5, 1.2)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/hands/work_insert/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] steadies [target]'s [device_name(target)] and lets go."))

// ---- Mouth ----

/datum/sex_action/chastity/lick_belt
	name = "Lick belt"
	description = "Work your tongue through the front slits of their belt."
	device_part = CHASTITY_PART_PUSSY
	partner_zone = BODY_ZONE_PRECISE_MOUTH
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_user = TRUE

/datum/sex_action/chastity/lick_belt/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] kneels and brings [user.p_their()] mouth level with [target]'s [device_name(target)]."))

/datum/sex_action/chastity/lick_belt/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [user.p_their()] tongue through the front slits of [target]'s [device_name(target)], finding what little skin it can reach..."))
	user.make_sucking_noise()
	perform_sex_action(target, user, 1.8, 0, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/lick_belt/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls back from [target]'s [device_name(target)], lips wet."))

/datum/sex_action/chastity/rim_shield
	name = "Rim shield"
	description = "Work your tongue along the edges of their rear shield."
	device_part = CHASTITY_PART_REAR
	partner_zone = BODY_ZONE_PRECISE_MOUTH
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_user = TRUE

/datum/sex_action/chastity/rim_shield/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] ducks low and presses [user.p_their()] mouth to the edge of [target]'s rear shield."))

/datum/sex_action/chastity/rim_shield/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] traces [user.p_their()] tongue around the rim of [target]'s shield, chasing the skin just past the metal..."))
	user.make_sucking_noise()
	perform_sex_action(target, user, 2, 0, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/rim_shield/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls back from [target]'s shield, jaw aching, and straightens up."))

/datum/sex_action/chastity/nuzzle_cage
	name = "Cage nuzzle"
	description = "Hold their face against your caged cock."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_zone = BODY_ZONE_PRECISE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH

/datum/sex_action/chastity/nuzzle_cage/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] takes hold of [target]'s head and guides it into [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/nuzzle_cage/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] holds [target]'s face against [user.p_their()] [device_name(user)], nose and cheek pressed into the metal..."))
	rattle_device(user)
	perform_sex_action(user, target, 1, 0, 0.5)
	perform_sex_action(target, user, 0.3, 0, 0)
	handle_passive_ejaculation()

/datum/sex_action/chastity/nuzzle_cage/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] loosens [user.p_their()] grip and lets [target] pull back from [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/force_cage
	name = "Force cage"
	description = "Push their mouth over the bars of your caged cock."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_zone = BODY_ZONE_PRECISE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE

/datum/sex_action/chastity/force_cage/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] grabs [target] by the back of the head and pushes [target.p_their()] mouth onto [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/force_cage/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [target]'s mouth over the bars of [user.p_their()] [device_name(user)], lips dragging across cold metal..."))
	target.make_sucking_noise()
	rattle_device(user)
	perform_sex_action(user, target, 1.3, 0.5, 0.8)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 0, 3, 0)

/datum/sex_action/chastity/force_cage/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] releases [target]'s head and lets [target.p_them()] pull off [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/force_belt
	name = "Force belt"
	description = "Hold their mouth against the front of your belt."
	device_part = CHASTITY_PART_PUSSY
	device_on_user = TRUE
	partner_zone = BODY_ZONE_PRECISE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE

/datum/sex_action/chastity/force_belt/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] seizes [target] and drags [target.p_their()] mouth down to the front of [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/force_belt/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] [device_name(user)] against [target]'s mouth, keeping [target.p_their()] tongue working at the slot..."))
	target.make_sucking_noise()
	perform_sex_action(user, target, 1.8, 0, 1)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 0, 2, 0)

/datum/sex_action/chastity/force_belt/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] releases [target] with a firm shove backward, [target.p_their()] lips wet."))

/datum/sex_action/chastity/force_rim
	name = "Force rim"
	description = "Hold their mouth against your rear shield."
	device_part = CHASTITY_PART_REAR
	device_on_user = TRUE
	partner_zone = BODY_ZONE_PRECISE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE

/datum/sex_action/chastity/force_rim/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] grabs [target] and pushes [target.p_their()] face against the rear shield of [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/force_rim/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] keeps [target]'s mouth pressed to [user.p_their()] shield, making [target.p_them()] lick along its edges..."))
	target.make_sucking_noise()
	perform_sex_action(user, target, 1.3, 0, 0.8)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 0, 2.5, 0)

/datum/sex_action/chastity/force_rim/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pushes [target] back and the shield comes away from [target.p_their()] mouth."))

// ---- Bodies ----

/datum/sex_action/chastity/frot_device
	name = "Frot cage"
	description = "Slide your cock along their locked cage."
	device_part = CHASTITY_PART_COCK
	partner_organ_slot = ORGAN_SLOT_PENIS
	uses_user_organs = list(ORGAN_SLOT_PENIS)

/datum/sex_action/chastity/frot_device/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] presses [user.p_their()] cock flush against [target]'s [device_name(target)]."))

/datum/sex_action/chastity/frot_device/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] slides [user.p_their()] cock along [target]'s [device_name(target)], hips rolling into every pass..."))
	do_thrust_animate(user, target)
	rattle_device(target)
	perform_sex_action(user, target, 1.2, 0, 1)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.2, 0, 0.6)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/frot_device/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rolls [user.p_their()] hips back from [target]'s [device_name(target)]."))

/datum/sex_action/chastity/frot_on_cage
	name = "Offer cage"
	description = "Work their cock along the bars of your cage."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_organ_slot = ORGAN_SLOT_PENIS
	uses_target_organs = list(ORGAN_SLOT_PENIS)

/datum/sex_action/chastity/frot_on_cage/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] reaches for [target] and presses [target.p_their()] cock against [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/frot_on_cage/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [target]'s cock along the bars of [user.p_their()] [device_name(user)], each pass earning a faint rasp of metal..."))
	do_thrust_animate(user, target)
	rattle_device(user)
	perform_sex_action(user, target, 1.1, 0, 0.6)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.5, 0, 1)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/frot_on_cage/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets [target]'s cock slip away from [user.p_their()] [device_name(user)]."))

/datum/sex_action/chastity/cage_to_cage
	name = "Grind cages"
	description = "Grind your caged cock against theirs."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_device_part = CHASTITY_PART_COCK

/datum/sex_action/chastity/cage_to_cage/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] closes in until [user.p_their()] [device_name(user)] knocks against [target]'s [device_name(target)]."))

/datum/sex_action/chastity/cage_to_cage/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] [device_name(user)] against [target]'s [device_name(target)], steel on steel, loud and graceless..."))
	do_thrust_animate(user, target)
	rattle_device(user)
	perform_sex_action(user, target, 1, 0, 0.5)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1, 0, 0.5)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/cage_to_cage/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] steps back, and the two devices part with a last scrape of metal."))

/datum/sex_action/chastity/cage_to_belt
	name = "Press belt"
	description = "Grind your caged cock against the plate of their belt."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_device_part = CHASTITY_PART_PUSSY

/datum/sex_action/chastity/cage_to_belt/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] closes in on [target] until [user.p_their()] [device_name(user)] rests against the plate of [target.p_their()] [device_name(target)]."))

/datum/sex_action/chastity/cage_to_belt/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] [device_name(user)] over the front of [target]'s [device_name(target)], metal scraping on metal..."))
	do_thrust_animate(user, target)
	rattle_device(user)
	perform_sex_action(user, target, 1.1, 1, 0.5)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.1, 1, 0.5)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/cage_to_belt/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] steps back and the two devices separate with a last rasp of metal."))

/datum/sex_action/chastity/grind_cage_pussy
	name = "Cage-grind pussy"
	description = "Roll the bars of your cage along their bare pussy."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_organ_slot = ORGAN_SLOT_VAGINA
	uses_target_organs = list(ORGAN_SLOT_VAGINA)

/datum/sex_action/chastity/grind_cage_pussy/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rolls [user.p_their()] hips forward until [user.p_their()] [device_name(user)] presses against [target]'s pussy."))

/datum/sex_action/chastity/grind_cage_pussy/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds the bars of [user.p_their()] [device_name(user)] along [target]'s pussy, cold metal parting warm folds..."))
	do_thrust_animate(user, target)
	rattle_device(user)
	perform_sex_action(user, target, 1.2, 0, 0.6)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.7, 1, 1.2)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/grind_cage_pussy/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] eases back, the metal of [user.p_their()] [device_name(user)] slick as it leaves [target]."))

/datum/sex_action/chastity/grind_cage_slit
	name = "Cage-grind slit"
	description = "Roll the bars of your cage along their genital slit."
	device_part = CHASTITY_PART_COCK
	device_on_user = TRUE
	partner_organ_slot = ORGAN_SLOT_PENIS
	partner_needs_slit = TRUE
	uses_target_organs = list(ORGAN_SLOT_PENIS)

/datum/sex_action/chastity/grind_cage_slit/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rolls forward until [user.p_their()] [device_name(user)] lies along [target]'s genital slit."))

/datum/sex_action/chastity/grind_cage_slit/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] [device_name(user)] along [target]'s slit, the bars coaxing at what hides inside..."))
	do_thrust_animate(user, target)
	rattle_device(user)
	perform_sex_action(user, target, 1.2, 1, 0.6)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.6, 0, 1.2)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/grind_cage_slit/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rocks back, breaking contact between [user.p_their()] [device_name(user)] and [target]'s slit."))

/datum/sex_action/chastity/ride_cage
	name = "Ride cage"
	description = "Grind your pussy down on their caged cock."
	device_part = CHASTITY_PART_COCK
	partner_organ_slot = ORGAN_SLOT_VAGINA
	uses_user_organs = list(ORGAN_SLOT_VAGINA)

/datum/sex_action/chastity/ride_cage/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] straddles [target] and settles down until [user.p_their()] pussy meets the bars of [target.p_their()] [device_name(target)]."))

/datum/sex_action/chastity/ride_cage/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rolls [user.p_their()] hips along [target]'s [device_name(target)], grinding against bars that have no give..."))
	do_thrust_animate(user, target)
	rattle_device(target)
	perform_sex_action(user, target, 2, 0, 1.5)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.3, 0, 0.6)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/ride_cage/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lifts [user.p_their()] hips off [target]'s [device_name(target)], the metal cold as [user.p_their()] warmth leaves it."))

/datum/sex_action/chastity/ride_cage_slit
	name = "Slit-ride cage"
	description = "Grind your genital slit down on their caged cock."
	device_part = CHASTITY_PART_COCK
	partner_organ_slot = ORGAN_SLOT_PENIS
	partner_needs_slit = TRUE
	uses_user_organs = list(ORGAN_SLOT_PENIS)

/datum/sex_action/chastity/ride_cage_slit/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] straddles [target] and rolls forward until [user.p_their()] slit settles on [target]'s [device_name(target)]."))

/datum/sex_action/chastity/ride_cage_slit/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rides the bars of [target]'s [device_name(target)] with [user.p_their()] slit, grinding down against metal that will not yield..."))
	do_thrust_animate(user, target)
	rattle_device(target)
	perform_sex_action(user, target, 1.8, 0, 1.4)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.2, 1, 0.6)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/ride_cage_slit/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rocks back and lifts [user.p_their()] slit off [target]'s [device_name(target)]."))

/datum/sex_action/chastity/scissor_belt
	name = "Scissor belt"
	description = "Grind your pussy against the plate of their belt."
	device_part = CHASTITY_PART_PUSSY
	partner_organ_slot = ORGAN_SLOT_VAGINA
	uses_user_organs = list(ORGAN_SLOT_VAGINA)

/datum/sex_action/chastity/scissor_belt/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] presses [user.p_their()] bare pussy flush against the plate of [target]'s [device_name(target)]."))

/datum/sex_action/chastity/scissor_belt/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds against the hard plate of [target]'s [device_name(target)], chasing friction the metal refuses to give..."))
	do_thrust_animate(user, target)
	perform_sex_action(user, target, 1.8, 0, 1.2)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.5, 0, 0.6)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/scissor_belt/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] rocks back and lifts away from [target]'s [device_name(target)], flushed and unsatisfied."))

/datum/sex_action/chastity/scissor_locked
	name = "Locked scissoring"
	description = "Grind the plate of your belt against their bare pussy."
	device_part = CHASTITY_PART_PUSSY
	device_on_user = TRUE
	partner_organ_slot = ORGAN_SLOT_VAGINA
	uses_target_organs = list(ORGAN_SLOT_VAGINA)

/datum/sex_action/chastity/scissor_locked/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] shifts forward until [user.p_their()] [device_name(user)] presses against [target]'s pussy."))

/datum/sex_action/chastity/scissor_locked/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] scissors against [target], the slot of [user.p_their()] [device_name(user)] dragging over [target.p_their()] folds..."))
	do_thrust_animate(user, target)
	perform_sex_action(user, target, 1.6, 0.5, 1)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.7, 0.5, 1.2)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/scissor_locked/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] separates, the belt pulling away from [target]'s pussy with a soft drag."))

/datum/sex_action/chastity/scissor_belts
	name = "Scissor belts"
	description = "Grind the plate of your belt against theirs."
	device_part = CHASTITY_PART_PUSSY
	device_on_user = TRUE
	partner_device_part = CHASTITY_PART_PUSSY

/datum/sex_action/chastity/scissor_belts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] moves close until [user.p_their()] [device_name(user)] meets [target]'s [device_name(target)]."))

/datum/sex_action/chastity/scissor_belts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] belt against [target]'s, plate on plate, pressure without relief..."))
	do_thrust_animate(user, target)
	rattle_device(user)
	perform_sex_action(user, target, 1.3, 1, 0.6)
	handle_passive_ejaculation()
	perform_sex_action(target, user, 1.3, 1, 0.6)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/scissor_belts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] untangles [user.p_their()] legs from [target]'s, and the two belts part."))

// ---- Tail ----

/datum/sex_action/chastity/tail
	abstract_type = /datum/sex_action/chastity/tail
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	check_same_tile = FALSE
	partner_organ_slot = ORGAN_SLOT_TAIL

/datum/sex_action/chastity/tail/cage
	name = "Tail-prod cage"
	description = "Tease their caged cock with the tip of your tail."
	device_part = CHASTITY_PART_COCK

/datum/sex_action/chastity/tail/cage/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] sweeps [user.p_their()] tail around and brings its tip to [target]'s [device_name(target)]."))

/datum/sex_action/chastity/tail/cage/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] prods and flicks at [target]'s [device_name(target)] with [user.p_their()] tail, rattling the bars..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	rattle_device(target)
	perform_sex_action(target, user, 1.3, 2, 0.8)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/tail/cage/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] uncoils [user.p_their()] tail from [target]'s [device_name(target)]."))

/datum/sex_action/chastity/tail/shield
	name = "Tail-prod shield"
	description = "Work the tip of your tail along their rear shield."
	device_part = CHASTITY_PART_REAR

/datum/sex_action/chastity/tail/shield/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] works [user.p_their()] tail behind [target] until its tip finds the edge of [target.p_their()] rear shield."))

/datum/sex_action/chastity/tail/shield/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] prods at the seam of [target]'s shield with [user.p_their()] tail, searching for a way past the plate..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 1.1, 3, 0.6)
	handle_passive_ejaculation(target)

/datum/sex_action/chastity/tail/shield/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] withdraws [user.p_their()] tail from [target]'s shield."))

#undef CHASTITY_PART_ANY
#undef CHASTITY_PART_COCK
#undef CHASTITY_PART_PUSSY
#undef CHASTITY_PART_REAR
