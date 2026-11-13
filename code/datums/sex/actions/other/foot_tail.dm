// Foot- and tail-based intimacy actions. They stimulate a genital (feeding the fluid/drip system), and the foot ones
// read whether the acting feet are bare, stockinged or shod - both for flavour and for how arousing they are.
// Each "groin" interaction is split into cock- and pussy-specific variants so the wording reads naturally.

/// Returns list("desc" = covering text, "mult" = arousal multiplier) for `feet_owner`'s feet.
/// Bare soles are the most arousing; stockings a little less; shoes the least.
/proc/foot_covering_info(mob/living/feet_owner)
	if(ishuman(feet_owner))
		var/mob/living/carbon/human/human_owner = feet_owner
		if(human_owner.shoes)
			return list("desc" = "shod", "mult" = 0.5)
		if(human_owner.legwear_socks)
			return list("desc" = "stocking-clad", "mult" = 0.8)
	return list("desc" = "bare", "mult" = 1)

// --- 1. Tailjob (tail-havers only), on a partner's genitals ---
/datum/sex_action/tailjob
	abstract_type = /datum/sex_action/tailjob
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	check_same_tile = FALSE
	/// The genital slot on the target this variant stimulates.
	var/target_organ_slot
	/// How the target's genital reads in messages.
	var/genital_name

/datum/sex_action/tailjob/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!get_real_organ(user, ORGAN_SLOT_TAIL))
		return FALSE
	if(!target.getorganslot(target_organ_slot))
		return FALSE
	return TRUE

/datum/sex_action/tailjob/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!get_real_organ(user, ORGAN_SLOT_TAIL))
		return FALSE
	if(!target.getorganslot(target_organ_slot))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/tailjob/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] curls [user.p_their()] tail against [target]'s [genital_name]..."))

/datum/sex_action/tailjob/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] teases [target]'s [genital_name] with [user.p_their()] tail..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	perform_sex_action(target, user, 2, 0, 2)
	handle_passive_ejaculation(target)

/datum/sex_action/tailjob/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] uncurls [user.p_their()] tail from [target]'s [genital_name]."))

/datum/sex_action/tailjob/penis
	name = "Tail-tease cock"
	target_organ_slot = ORGAN_SLOT_PENIS
	genital_name = "cock"

/datum/sex_action/tailjob/vagina
	name = "Tail-tease pussy"
	target_organ_slot = ORGAN_SLOT_VAGINA
	genital_name = "pussy"

// --- 2. Footjob (feet on a partner's genitals) ---
/datum/sex_action/footjob_intimate
	abstract_type = /datum/sex_action/footjob_intimate
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	check_same_tile = FALSE
	var/target_organ_slot
	var/genital_name

/datum/sex_action/footjob_intimate/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(target_organ_slot))
		return FALSE
	return TRUE

/datum/sex_action/footjob_intimate/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_L_FOOT))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_R_FOOT))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(target_organ_slot))
		return FALSE
	return TRUE

/datum/sex_action/footjob_intimate/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(user)
	user.visible_message(span_warning("[user] presses [user.p_their()] [covering["desc"]] feet against [target]'s [genital_name]..."))

/datum/sex_action/footjob_intimate/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(user)
	var/mult = covering["mult"]
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rubs [target]'s [genital_name] with [user.p_their()] [covering["desc"]] feet..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	perform_sex_action(target, user, 2 * mult, 0, 2 * mult)
	handle_passive_ejaculation(target)

/datum/sex_action/footjob_intimate/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] takes [user.p_their()] feet off [target]'s [genital_name]."))

/datum/sex_action/footjob_intimate/penis
	name = "Foot-rub cock"
	target_organ_slot = ORGAN_SLOT_PENIS
	genital_name = "cock"

/datum/sex_action/footjob_intimate/vagina
	name = "Foot-rub pussy"
	target_organ_slot = ORGAN_SLOT_VAGINA
	genital_name = "pussy"

// --- 3. Grind foot against vagina (vagina-specific by nature) ---
/datum/sex_action/foot_grind_vagina
	name = "Foot-grind pussy"
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	check_same_tile = FALSE

/datum/sex_action/foot_grind_vagina/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/foot_grind_vagina/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_L_FOOT) && !check_location_accessible(user, user, BODY_ZONE_PRECISE_R_FOOT))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/foot_grind_vagina/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(user)
	user.visible_message(span_warning("[user] settles [user.p_their()] [covering["desc"]] foot against [target]'s pussy..."))

/datum/sex_action/foot_grind_vagina/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(user)
	var/mult = covering["mult"]
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] grinds [user.p_their()] [covering["desc"]] foot against [target]'s pussy..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	perform_sex_action(target, user, 2.5 * mult, 1, 2.5 * mult)
	handle_passive_ejaculation(target)

/datum/sex_action/foot_grind_vagina/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lifts [user.p_their()] foot away from [target]'s pussy."))

// --- 4. Use their feet on your own genitals ---
/datum/sex_action/use_their_feet
	abstract_type = /datum/sex_action/use_their_feet
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_LEGS
	check_same_tile = FALSE
	/// The genital slot on the user (self) being pleasured.
	var/user_organ_slot
	var/genital_name

/datum/sex_action/use_their_feet/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(user_organ_slot))
		return FALSE
	return TRUE

/datum/sex_action/use_their_feet/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!user.getorganslot(user_organ_slot))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_L_FOOT) && !check_location_accessible(user, target, BODY_ZONE_PRECISE_R_FOOT))
		return FALSE
	return TRUE

/datum/sex_action/use_their_feet/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(target)
	user.visible_message(span_warning("[user] guides [target]'s [covering["desc"]] feet against [user.p_their()] [genital_name]..."))

/datum/sex_action/use_their_feet/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(target)
	var/mult = covering["mult"]
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] rubs [user.p_their()] [genital_name] against [target]'s [covering["desc"]] feet..."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	perform_sex_action(user, target, 2 * mult, 0, 2 * mult)
	handle_passive_ejaculation(user)

/datum/sex_action/use_their_feet/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] eases away from [target]'s feet."))

/datum/sex_action/use_their_feet/penis
	name = "Fuck feet"
	user_organ_slot = ORGAN_SLOT_PENIS
	genital_name = "cock"

/datum/sex_action/use_their_feet/vagina
	name = "Ride feet"
	user_organ_slot = ORGAN_SLOT_VAGINA
	genital_name = "pussy"
