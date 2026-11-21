/datum/sex_action/proc/get_nipple_chest_description(mob/living/target)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasts)
		if(breasts.organ_size <= BREAST_SIZE_FLAT)
			return "flat chest"
		if(breasts.organ_size <= BREAST_SIZE_SMALL)
			return "small breasts"
		if(breasts.organ_size >= BREAST_SIZE_LARGE)
			return "full breasts"
		return "breasts"
	if(target.gender == MALE)
		return "broad chest"
	if(target.gender == FEMALE)
		return "soft chest"
	return "chest"

/datum/sex_action/masturbate/nipples
	name = "Rub nipples"
	description = "Rub your nipples, with flavor matching the shape of your chest."
	target_menu_zone_mask = SEX_UI_ZONE_BODY

/datum/sex_action/masturbate/nipples/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate/nipples/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/nipples/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rubbing the nipples on [user.p_their()] [get_nipple_chest_description(user)]..."))

/datum/sex_action/masturbate/nipples/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "rubs"
	var/arousal_amt = 1.0
	var/pain_amt = 0
	var/orgasm_amt = 0.4

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 1.4
			pain_amt = 0.2
			orgasm_amt = 0.6
		if(SEX_FORCE_HIGH)
			action_text = "tugs on"
			arousal_amt = 1.3
			pain_amt = 1.1
			orgasm_amt = 0.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "pulls at"
			arousal_amt = 1.0
			pain_amt = 1.9
			orgasm_amt = 0.3

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] the nipples on [user.p_their()] [get_nipple_chest_description(user)]..."))

	perform_sex_action(user, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation()

/datum/sex_action/masturbate/nipples/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops touching [user.p_their()] nipples."))

/datum/sex_action/masturbate/other/nipples
	name = "Nipple rubbing"
	remote_phrase = "Rub their nipples"
	description = "Rub their nipples, with flavor matching the shape of their chest."
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	mage_hand_overlay_zone = MAGE_HAND_ZONE_CHEST

/datum/sex_action/masturbate/other/nipples/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/nipples/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/nipples/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts rubbing the nipples on [target]'s [get_nipple_chest_description(target)]..."))

/datum/sex_action/masturbate/other/nipples/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/action_text = "rubs"
	var/arousal_amt = 1.0
	var/pain_amt = 0
	var/orgasm_amt = 0.4

	switch(force)
		if(SEX_FORCE_MID)
			arousal_amt = 1.4
			pain_amt = 0.2
			orgasm_amt = 0.6
		if(SEX_FORCE_HIGH)
			action_text = "tugs on"
			arousal_amt = 1.3
			pain_amt = 1.1
			orgasm_amt = 0.5
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			action_text = "pulls at"
			arousal_amt = 1.0
			pain_amt = 1.9
			orgasm_amt = 0.3

	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [action_text] the nipples on [target]'s [get_nipple_chest_description(target)]..."))

	perform_sex_action(target, user, arousal_amt, pain_amt, orgasm_amt)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/nipples/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops touching [target]'s nipples."))
