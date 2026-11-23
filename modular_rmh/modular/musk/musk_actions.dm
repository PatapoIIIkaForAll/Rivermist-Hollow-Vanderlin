/datum/sex_action/musk_press
	abstract_type = /datum/sex_action/musk_press
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	menu_category = "mouth"
	do_time = MUSK_PRESS_TIME
	continous = FALSE
	gags_target = TRUE
	var/sweat_zone
	var/body_zone = BODY_ZONE_CHEST
	var/user_lock_slot

/datum/sex_action/musk_press/proc/get_place(mob/living/user)
	return ""

/datum/sex_action/musk_press/proc/get_start_line(mob/living/user, mob/living/target)
	return "[user] grabs [target]'s head and presses [target.p_their()] face [get_place(user)]!"

/datum/sex_action/musk_press/proc/can_bare_zone(mob/living/user)
	return check_location_accessible(user, user, body_zone, TRUE)

/datum/sex_action/musk_press/get_speed_multiplier()
	return 1

/datum/sex_action/musk_press/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return user.get_musk_sweat()?.get_stacks(sweat_zone) > 0

/datum/sex_action/musk_press/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!(user.get_musk_sweat()?.get_stacks(sweat_zone) > 0))
		return FALSE
	if(!can_bare_zone(user))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(user_lock_slot && check_sex_lock(user, user_lock_slot))
		return FALSE
	return TRUE

/datum/sex_action/musk_press/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH, null, FALSE)
	if(user_lock_slot)
		add_sex_lock(user, user_lock_slot, null, FALSE)

/datum/sex_action/musk_press/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning(get_start_line(user, target)))

/datum/sex_action/musk_press/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] smothers [target] [get_place(user)]..."))
	do_thrust_animate(user, target)
	perform_deepthroat_oxyloss(target, MUSK_PRESS_OXYLOSS)
	perform_sex_action(user, target, 0.6, 0, 0.3)
	if(smother_in_musk(user, target))
		return
	perform_sex_action(target, user, 0.8, 0, 0.4)
	handle_passive_ejaculation(target)

/datum/sex_action/musk_press/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets [target] up for air."))

/datum/sex_action/musk_press/proc/smother_in_musk(mob/living/user, mob/living/target)
	var/datum/musk_sweat/sweat = user.get_musk_sweat()
	var/stacks = sweat?.get_stacks(sweat_zone)
	if(!stacks || !ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if(!human_target.is_musk_susceptible())
		return FALSE
	human_target.touch_musk(user, MUSK_GAIN_PRESS)
	to_chat(human_target, span_love(musk_press_text(human_target, sweat_zone, sweat.get_tier(sweat_zone))))
	human_target.take_musk_hit(min(stacks, MUSK_LEVEL_MAX), user, TRUE)
	if(MOBTIMER_EXISTS(human_target, MUSK_PRESS_BURST_TIMER) && !MOBTIMER_FINISHED(human_target, MUSK_PRESS_BURST_TIMER, MUSK_PRESS_BURST_COOLDOWN))
		perform_sex_action(human_target, user, 2, 0, 1)
		return TRUE
	MOBTIMER_SET(human_target, MUSK_PRESS_BURST_TIMER)
	musk_climax_burst(human_target, min(stacks, MUSK_PRESS_MAX_CLIMAXES))
	return TRUE

/datum/sex_action/musk_press/armpit
	name = "Press into armpit"
	menu_tip = "Smother their face in the musk of your armpit."
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	sweat_zone = MUSK_ZONE_ARMPITS
	body_zone = BODY_ZONE_CHEST

/datum/sex_action/musk_press/armpit/get_place(mob/living/user)
	return "into [user.p_their()] sweaty armpit"

/datum/sex_action/musk_press/crotch
	name = "Press into crotch"
	menu_tip = "Smother their face in the musk of your crotch."
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	sweat_zone = MUSK_ZONE_GROIN
	body_zone = BODY_ZONE_PRECISE_GROIN

/datum/sex_action/musk_press/crotch/get_place(mob/living/user)
	return "into [user.p_their()] sweaty crotch"

/datum/sex_action/musk_press/butt
	name = "Press into butt"
	menu_tip = "Bury their face in the musk between your cheeks."
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS | SEX_UI_ZONE_MISC
	sweat_zone = MUSK_ZONE_BUTT
	body_zone = BODY_ZONE_PRECISE_GROIN
	user_lock_slot = ORGAN_SLOT_ANUS

/datum/sex_action/musk_press/butt/get_place(mob/living/user)
	return "between [user.p_their()] sweaty cheeks"

/datum/sex_action/musk_lick
	abstract_type = /datum/sex_action/musk_lick
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	menu_category = "mouth"
	continous = FALSE
	var/sweat_zone
	var/body_zone = BODY_ZONE_CHEST
	var/place_name = "skin"
	var/target_lock_slot

/datum/sex_action/musk_lick/proc/can_reach_zone(mob/living/user, mob/living/target)
	return check_location_accessible(user, target, body_zone, TRUE)

/datum/sex_action/musk_lick/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return target.get_musk_sweat()?.get_stacks(sweat_zone) > 0

/datum/sex_action/musk_lick/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!(target.get_musk_sweat()?.get_stacks(sweat_zone) > 0))
		return FALSE
	if(!can_reach_zone(user, target))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(target_lock_slot && check_sex_lock(target, target_lock_slot))
		return FALSE
	return TRUE

/datum/sex_action/musk_lick/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	if(target_lock_slot)
		add_sex_lock(target, target_lock_slot, null, FALSE)

/datum/sex_action/musk_lick/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] leans in to [target]'s sweaty [place_name], tongue out..."))

/datum/sex_action/musk_lick/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/datum/musk_sweat/sweat = target.get_musk_sweat()
	if(!sweat?.get_stacks(sweat_zone))
		return
	var/tier = sweat.get_tier(sweat_zone)
	var/quality = sweat.get_quality(sweat_zone)
	var/stacks = sweat.wipe(sweat_zone)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] licks the sweat from [target]'s [place_name]..."))
	user.make_mouth_noise("lick")
	perform_sex_action(target, user, 0.6, 0, 0.3)
	handle_passive_ejaculation(target)
	taste_musk(user, target, stacks, tier, quality)

/datum/sex_action/musk_lick/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] tongue away from [target]."))

/datum/sex_action/musk_lick/proc/taste_musk(mob/living/user, mob/living/target, stacks, tier, quality)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/licker = user
	if(!licker.is_musk_susceptible())
		to_chat(licker, span_notice(musk_plain_lick_text(licker)))
		return
	licker.touch_musk(target, MUSK_GAIN_LICK)
	to_chat(licker, span_love(musk_lick_text(licker, sweat_zone, tier, quality)))
	licker.tell_once_per_contact(MUSK_LINE_NOTES, musk_notes_text(licker, target.get_musk()?.scent_notes))
	SEND_SIGNAL(licker, COMSIG_SEX_ADJUST_AROUSAL, stacks * MUSK_LICK_AROUSAL_PER_STACK)
	licker.take_musk_hit(min(stacks, MUSK_LEVEL_MAX), target, TRUE)

/datum/sex_action/musk_lick/armpit
	name = "Lick sweaty armpit"
	menu_tip = "Lap the musky sweat from their armpit until it shines."
	target_menu_zone_mask = SEX_UI_ZONE_ARMS
	sweat_zone = MUSK_ZONE_ARMPITS
	body_zone = BODY_ZONE_CHEST
	place_name = "armpit"

/datum/sex_action/musk_lick/crotch
	name = "Lick sweaty crotch"
	menu_tip = "Lap the musky sweat from their crotch until it shines."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	sweat_zone = MUSK_ZONE_GROIN
	body_zone = BODY_ZONE_PRECISE_GROIN
	place_name = "crotch"

/datum/sex_action/musk_lick/butt
	name = "Lick sweaty butt"
	menu_tip = "Lap the musky sweat from between their cheeks."
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS | SEX_UI_ZONE_MISC
	sweat_zone = MUSK_ZONE_BUTT
	body_zone = BODY_ZONE_PRECISE_GROIN
	place_name = "butt"
	target_lock_slot = ORGAN_SLOT_ANUS

/proc/musk_climax_burst(mob/living/climaxer, count)
	if(count <= 0)
		return
	if(count > 1)
		to_chat(climaxer, span_love(musk_burst_text(climaxer)))
	var/datum/weakref/climaxer_ref = WEAKREF(climaxer)
	musk_climax_once(climaxer_ref)
	for(var/climax_index in 1 to count - 1)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(musk_climax_once), climaxer_ref), MUSK_CLIMAX_CHAIN_DELAY * climax_index)

/proc/musk_climax_once(datum/weakref/climaxer_ref)
	var/mob/living/climaxer = climaxer_ref?.resolve()
	if(QDELETED(climaxer) || climaxer.stat == DEAD)
		return
	var/datum/component/arousal/arousal = climaxer.GetComponent(/datum/component/arousal)
	arousal?.ejaculate(null, climaxer, null, FALSE)
