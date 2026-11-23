/datum/sex_action/docking
	abstract_type = /datum/sex_action/docking
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	menu_category = "grind"
	climax_coat_zone = FLUID_COAT_GROIN
	uses_user_organs = list(ORGAN_SLOT_PENIS)
	uses_target_organs = list(ORGAN_SLOT_PENIS)
	var/dock_kind = DOCKING_KIND_FORESKIN
	var/sleeve_is_user = TRUE

/datum/sex_action/docking/proc/get_real_penis(mob/living/holder)
	var/obj/item/organ/genitals/penis/penis = holder?.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis || penis.is_false_organ())
		return null
	return penis

/datum/sex_action/docking/proc/get_sleeve_holder(mob/living/user, mob/living/target)
	return sleeve_is_user ? user : target

/datum/sex_action/docking/proc/get_inner_holder(mob/living/user, mob/living/target)
	return sleeve_is_user ? target : user

/datum/sex_action/docking/proc/fits(mob/living/user, mob/living/target)
	if(!user || !target || user == target)
		return FALSE
	var/obj/item/organ/genitals/penis/sleeve = get_real_penis(get_sleeve_holder(user, target))
	if(sleeve?.get_docking_kind() != dock_kind)
		return FALSE
	return !!get_real_penis(get_inner_holder(user, target))

/datum/sex_action/docking/proc/get_force_value(list/values)
	return values[clamp(force, 1, length(values))]

/datum/sex_action/docking/proc/is_stretched(obj/item/organ/genitals/penis/inner, obj/item/organ/genitals/penis/sleeve)
	return inner.get_insert_girth() > sleeve.get_insert_girth() * DOCKING_STRETCH_RATIO

/datum/sex_action/docking/proc/get_sleeve_pain(stretched)
	return DOCKING_SLEEVE_PAIN + (stretched ? DOCKING_STRETCH_PAIN : 0)

/datum/sex_action/docking/shows_on_menu(mob/living/user, mob/living/target)
	return fits(user, target)

/datum/sex_action/docking/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!fits(user, target))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS) || check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/docking/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return fits(user, target)

/datum/sex_action/docking/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	add_sex_lock(target, ORGAN_SLOT_PENIS)

/datum/sex_action/docking/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning(docking_start_text(user, target, dock_kind, sleeve_is_user)))

/datum/sex_action/docking/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/sleeve_holder = get_sleeve_holder(user, target)
	var/mob/living/inner_holder = get_inner_holder(user, target)
	var/obj/item/organ/genitals/penis/sleeve = get_real_penis(sleeve_holder)
	var/obj/item/organ/genitals/penis/inner = get_real_penis(inner_holder)
	if(!sleeve || !inner)
		return
	var/stretched = is_stretched(inner, sleeve)
	var/hidden = sleeve.erect_state != ERECT_STATE_HARD
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(docking_perform_text(user, target, dock_kind, sleeve_is_user, get_generic_force_adjective(), stretched, hidden)))
		if(prob(DOCKING_FEEL_CHANCE))
			to_chat(sleeve_holder, span_love(docking_sleeve_feel_text(sleeve_holder, dock_kind, stretched)))
			to_chat(inner_holder, span_love(docking_inner_feel_text(inner_holder, dock_kind)))
	play_rub_sound("fap", sleeve_holder, DOCKING_RUB_VOLUME)

	var/static/list/inner_arousal = list(1.2, 1.5, 1.8, 2, 2)
	var/static/list/inner_orgasm = list(1, 1.2, 1.4, 1.4, 1.4)
	var/static/list/sleeve_arousal = list(1, 1.2, 1.4, 1.5, 1.5)
	var/static/list/sleeve_orgasm = list(0.8, 1, 1.2, 1.2, 1.2)
	perform_sex_action(inner_holder, sleeve_holder, get_force_value(inner_arousal), 0, get_force_value(inner_orgasm))
	handle_passive_ejaculation(inner_holder)
	perform_sex_action(sleeve_holder, inner_holder, get_force_value(sleeve_arousal), get_sleeve_pain(stretched), get_force_value(sleeve_orgasm))
	handle_passive_ejaculation(sleeve_holder)

/datum/sex_action/docking/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning(docking_finish_text(user, target, dock_kind, sleeve_is_user)))

/datum/sex_action/docking/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/climaxer_is_sleeve = user == get_sleeve_holder(action_user, action_target)
	user.visible_message(span_love(docking_climax_text(user, target, dock_kind, climaxer_is_sleeve)))
	return ORGASM_LOCATION_ONTO

/datum/sex_action/docking/foreskin_wrap
	name = "Dock with foreskin"
	menu_tip = "Roll your foreskin over the head of their cock."
	dock_kind = DOCKING_KIND_FORESKIN
	sleeve_is_user = TRUE

/datum/sex_action/docking/foreskin_enter
	name = "Dock into foreskin"
	menu_tip = "Slip your cockhead inside their foreskin."
	dock_kind = DOCKING_KIND_FORESKIN
	sleeve_is_user = FALSE

/datum/sex_action/docking/sheath_wrap
	name = "Dock with sheath"
	menu_tip = "Take their cock into your own sheath."
	dock_kind = DOCKING_KIND_SHEATH
	sleeve_is_user = TRUE

/datum/sex_action/docking/sheath_enter
	name = "Dock into sheath"
	menu_tip = "Push your cock into their sheath."
	dock_kind = DOCKING_KIND_SHEATH
	sleeve_is_user = FALSE

/datum/sex_action/docking/slit_wrap
	name = "Dock with slit"
	menu_tip = "Take their cock into your own genital slit."
	dock_kind = DOCKING_KIND_SLIT
	sleeve_is_user = TRUE

/datum/sex_action/docking/slit_enter
	name = "Dock into slit"
	menu_tip = "Slide your cock into their genital slit."
	dock_kind = DOCKING_KIND_SLIT
	sleeve_is_user = FALSE
