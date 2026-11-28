/datum/sex_action/proc/can_reach_sole(mob/living/actor, mob/living/holder)
	if(ishuman(holder))
		var/mob/living/carbon/human/human_holder = holder
		if(human_holder.shoes)
			return FALSE
	return check_location_accessible(actor, holder, BODY_ZONE_PRECISE_R_FOOT) || check_location_accessible(actor, holder, BODY_ZONE_PRECISE_L_FOOT)

/datum/sex_action/musk_press/feet
	name = "Press under foot"
	menu_tip = "Smother their face under the musk of your sole."
	menu_category = "feet"
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	sweat_zone = MUSK_ZONE_FEET

/datum/sex_action/musk_press/feet/get_place(mob/living/user)
	return "under [user.p_their()] sweaty foot"

/datum/sex_action/musk_press/feet/get_start_line(mob/living/user, mob/living/target)
	return "[user] plants a sweaty foot on [target]'s face and presses down!"

/datum/sex_action/musk_press/feet/can_bare_zone(mob/living/user)
	return can_reach_sole(user, user)

/datum/sex_action/musk_lick/feet
	name = "Lick sweaty feet"
	menu_tip = "Lap the musky sweat from their soles and toes."
	menu_category = "feet"
	target_menu_zone_mask = SEX_UI_ZONE_LEGS
	sweat_zone = MUSK_ZONE_FEET
	place_name = "feet"

/datum/sex_action/musk_lick/feet/can_reach_zone(mob/living/user, mob/living/target)
	return can_reach_sole(user, target)

/datum/sex_action/foot_wipe
	name = "Wipe foot on face"
	menu_tip = "Wipe your foot clean on their face."
	menu_category = "feet"
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	continous = FALSE

/datum/sex_action/foot_wipe/shows_on_menu(mob/living/user, mob/living/target)
	return user != target

/datum/sex_action/foot_wipe/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	return can_reach_sole(user, user) && can_reach_face(user, target)

/datum/sex_action/foot_wipe/proc/can_reach_face(mob/living/user, mob/living/target)
	if(!check_location_accessible(user, target, BODY_ZONE_HEAD))
		return FALSE
	if(!ishuman(target))
		return TRUE
	var/mob/living/carbon/human/human_target = target
	return !human_target.get_coat_zone_cover(FLUID_COAT_FACE)

/datum/sex_action/foot_wipe/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] raises a foot to [target]'s face..."))

/datum/sex_action/foot_wipe/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] wipes [user.p_their()] foot clean on [target]'s face!"))
	play_rub_sound("skin", target)
	perform_sex_action(target, user, 0.6, 0, 0.3)
	handle_passive_ejaculation(target)
	if(!ishuman(user) || !ishuman(target))
		return
	wipe_coat(user, target)
	wipe_sweat(user, target)
	user.adjust_hygiene(MUSK_WIPE_HYGIENE)
	target.adjust_hygiene(-MUSK_WIPE_HYGIENE)

/datum/sex_action/foot_wipe/proc/wipe_coat(mob/living/carbon/human/wiper, mob/living/carbon/human/victim)
	var/datum/component/fluid_coated/coated = wiper.GetComponent(/datum/component/fluid_coated)
	var/datum/fluid_coat/coat = coated?.coats[FLUID_COAT_FEET]
	if(!coat)
		return
	if(coat.is_wet())
		victim.coat_with_fluid(FLUID_COAT_FACE, coat.fluids, coat.fluids.total_volume)
	coated.remove_coat(FLUID_COAT_FEET)

/datum/sex_action/foot_wipe/proc/wipe_sweat(mob/living/carbon/human/wiper, mob/living/carbon/human/victim)
	var/stacks = wiper.get_musk_sweat()?.wipe(MUSK_ZONE_FEET)
	if(!stacks || !victim.is_musk_susceptible())
		return
	victim.touch_musk(wiper, MUSK_GAIN_WIPE)
	victim.smear_with_musk(stacks, wiper)
	victim.take_musk_hit(min(stacks, MUSK_LEVEL_MAX), wiper, TRUE)

/datum/sex_action/toes_in_mouth
	name = "Push toes into mouth"
	menu_tip = "Push your toes into their mouth."
	menu_category = "feet"
	user_menu_zone_mask = SEX_UI_ZONE_LEGS
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE

/datum/sex_action/toes_in_mouth/shows_on_menu(mob/living/user, mob/living/target)
	return user != target

/datum/sex_action/toes_in_mouth/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	if(!can_reach_sole(user, user) || !check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return !check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/toes_in_mouth/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/toes_in_mouth/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/list/covering = foot_covering_info(user)
	user.visible_message(span_warning("[user] pushes [user.p_their()] [covering["desc"]] toes into [target]'s mouth..."))

/datum/sex_action/toes_in_mouth/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] works [user.p_their()] toes in and out of [target]'s mouth..."))
	target.make_mouth_noise(force >= SEX_FORCE_HIGH ? "gag" : "suck")
	perform_sex_action(user, target, 0.5, 0, 0.25)
	perform_sex_action(target, user, 0.5, 0, 0.25)
	handle_passive_ejaculation(target)
	feed_musk(user, target)

/datum/sex_action/toes_in_mouth/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] draws [user.p_their()] toes out of [target]'s mouth."))

/datum/sex_action/toes_in_mouth/proc/feed_musk(mob/living/user, mob/living/target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/taster = target
	var/datum/musk_sweat/sweat = user.get_musk_sweat()
	var/tier = sweat?.get_tier(MUSK_ZONE_FEET)
	if(!sweat?.spend(MUSK_ZONE_FEET) || !taster.is_musk_susceptible())
		return
	taster.touch_musk(user, MUSK_GAIN_TOES)
	taster.tell_once_per_contact(MUSK_LINE_TASTE, musk_toes_text(taster))
	SEND_SIGNAL(taster, COMSIG_SEX_ADJUST_AROUSAL, MUSK_LICK_AROUSAL_PER_STACK)
	taster.take_musk_hit(tier, user, TRUE)

/mob/living/carbon/human/proc/smear_with_musk(stacks, mob/living/carbon/human/source)
	var/datum/status_effect/musk_smear/smear = has_status_effect(/datum/status_effect/musk_smear)
	if(smear)
		smear.add_stacks(stacks, source)
		return
	apply_status_effect(/datum/status_effect/musk_smear, stacks, source)

/datum/status_effect/musk_smear
	id = "musk_smear"
	duration = -1
	tick_interval = MUSK_AURA_INTERVAL
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/debuff/musk_smear
	var/stacks = 0
	var/fade_at = 0
	var/datum/weakref/source_ref

/datum/status_effect/musk_smear/on_creation(mob/living/new_owner, new_stacks = 1, mob/living/carbon/human/source)
	. = ..(new_owner)
	if(QDELETED(src))
		return
	add_stacks(new_stacks, source)
	if(linked_alert)
		linked_alert.name = musk_localized(owner, "Smeared With Sweat", "Чужой пот")
		linked_alert.desc = musk_smear_alert_text(owner)

/datum/status_effect/musk_smear/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_wash))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/status_effect/musk_smear/on_remove()
	UnregisterSignal(owner, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_LIVING_DEATH))
	return ..()

/datum/status_effect/musk_smear/tick()
	if(world.time >= fade_at)
		stacks--
		fade_at = world.time + MUSK_SMEAR_FADE_TIME
	if(stacks <= 0)
		qdel(src)
		return
	waft_musk(owner, stacks, source_ref?.resolve())

/datum/status_effect/musk_smear/get_examine_text(mob/user, list/P)
	return span_love("SUBJECTPRONOUN is smeared across the face with the sweat of somebody's feet.")

/datum/status_effect/musk_smear/proc/add_stacks(amount, mob/living/carbon/human/source)
	stacks = min(stacks + amount, MUSK_SMEAR_MAX_STACKS)
	source_ref = WEAKREF(source)
	fade_at = world.time + MUSK_SMEAR_FADE_TIME
	to_chat(owner, span_love(musk_smear_text(owner)))

/datum/status_effect/musk_smear/proc/on_wash(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & (CLEAN_WASH | CLEAN_SCRUB | CLEAN_ALL)))
		return
	to_chat(owner, span_notice(musk_smear_washed_text(owner)))
	qdel(src)

/datum/status_effect/musk_smear/proc/on_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/debuff/musk_smear
	name = "Smeared With Sweat"
	desc = "Somebody's sweat is smeared over my face, and I breathe it in with every breath."
	icon_state = "debuff"
