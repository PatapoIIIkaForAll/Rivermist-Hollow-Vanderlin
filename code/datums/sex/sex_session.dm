/datum/sex_session //! TODO SEX SOUNDS
	/// The initiating user
	var/mob/living/user
	/// Target of our actions
	var/mob/living/target
	/// Which zone on our side the interaction list is filtered by
	var/user_zone_filter = SEX_UI_ZONE_ANY
	/// Which zone on the target side the interaction list is filtered by
	var/target_zone_filter = SEX_UI_ZONE_ANY
	/// Active actions currently running in this session
	var/list/datum/sex_action/active_actions = list()
	/// Compatibility pointer for older callers that still expect one current action
	var/datum/sex_action/current_action = null
	/// Enum of desired speed
	var/speed = SEX_SPEED_MID
	/// Enum of desired force
	var/force = SEX_FORCE_MID
	/// Makes genital arousal automatic by default
	var/manual_arousal = SEX_MANUAL_AROUSAL_DEFAULT
	/// Whether we want to screw until finished, or non stop
	var/do_until_finished = TRUE
	///inactivity bumps
	var/inactivity = 0
	/// Reference to the collective this session belongs to
	var/datum/collective_message/collective = null
	///have we just climaxed?
	var/just_climaxed = FALSE

	var/static/sex_id = 0
	var/our_sex_id = 0 //this is so we can have more then 1 sex id open at once
	/// Level of pleasure resistance
	var/resistance_to_pleasure = RESIST_NONE
	/// Level of edging others
	var/edging_other = FALSE

	var/datum/ui_updater/session_updater
	var/static/list/action_zone_filter_options = list(
		"Any" = SEX_UI_ZONE_ANY,
		"Mouth" = SEX_UI_ZONE_MOUTH,
		"Genitals" = SEX_UI_ZONE_GENITALS,
		"Arms" = SEX_UI_ZONE_ARMS,
		"Legs" = SEX_UI_ZONE_LEGS,
		"Body" = SEX_UI_ZONE_BODY,
		"Misc" = SEX_UI_ZONE_MISC,
	)

/datum/sex_session/New(mob/living/session_user, mob/living/session_target)
	user = session_user
	target = session_target
	sex_id++
	our_sex_id = sex_id
	assign_to_collective()

	RegisterSignal(user, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(on_participant_qdeleting))
	if(target != user)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_participant_qdeleting))

	addtimer(CALLBACK(src, PROC_REF(check_sex)), 30 SECONDS)

/datum/sex_session/Destroy(force, ...)
	if(user)
		UnregisterSignal(user, list(COMSIG_SEX_CLIMAX, COMSIG_SEX_AROUSAL_CHANGED, COMSIG_PARENT_QDELETING))
	if(target && target != user)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	stop_current_action()
	// Remove from collective
	if(session_updater)
		qdel(session_updater)
		session_updater = null

	if(collective)
		collective.sessions -= src
		// If this was the last session in the collective, remove the collective
		if(!length(collective.sessions))
			//collective.unregister_collective_tab()
			LAZYREMOVE(GLOB.sex_collectives, collective)
			qdel(collective)
		collective = null

	if(active_actions)
		active_actions.Cut()
	active_actions = null
	current_action = null
	user = null
	target = null

	GLOB.sex_sessions -= src
	. = ..()


/datum/sex_session/proc/assign_to_collective()
	// Check if we can merge with an existing collective
	for(var/datum/collective_message/existing_collective in GLOB.sex_collectives)
		if(existing_collective.can_merge_session(src))
			existing_collective.merge_session(src)
			return

	// No existing collective found, create a new one
	var/datum/collective_message/new_collective = new /datum/collective_message(src)
	LAZYADD(GLOB.sex_collectives, new_collective)
	collective = new_collective

/datum/sex_session/proc/check_sex()
	if(length(active_actions) || is_ui_open())
		inactivity--
		inactivity = CLAMP(inactivity, 0, 11)
		addtimer(CALLBACK(src, PROC_REF(check_sex)), 30 SECONDS)
		return

	inactivity++

	if(inactivity < 5)
		addtimer(CALLBACK(src, PROC_REF(check_sex)), 30 SECONDS)
		return
	qdel(src)

/datum/sex_session/proc/on_participant_qdeleting()
	SIGNAL_HANDLER
	qdel(src)

/datum/sex_session/proc/is_ui_open()
	if(!user?.client)
		return FALSE
	return winexists(user.client, "sexcon[our_sex_id]")

/datum/sex_session/proc/add_ui_tracking(window_id)
	if(session_updater)
		return
	session_updater = new /datum/ui_updater(user, window_id, src, FALSE)

	session_updater.track_property("arousal_data", "updateProgressBars", variable = FALSE)
	RegisterSignal(user, COMSIG_SEX_AROUSAL_CHANGED, PROC_REF(on_arousal_changed), TRUE)

	session_updater.start_updates()

/datum/sex_session/proc/on_arousal_changed()
    if(session_updater)
        var/arousal_string = get_arousal_data_string()
        session_updater.push_data_change("arousal_data", arousal_string)

/datum/sex_session/proc/get_arousal_data_string()
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)

	var/max_arousal = MAX_AROUSAL || 500
	var/orgasm_threshold = PASSIVE_EJAC_THRESHOLD
	var/current_arousal = arousal_data["arousal"] || 0
	var/current_orgasm_prog = arousal_data["orgasm_progress"] || 0
	var/arousal_percent = min(100, (current_arousal / max_arousal) * 100)
	var/pleasure_percent = min(100, (current_orgasm_prog / orgasm_threshold) * 100)
	var/pain_percent = 0

	return "[arousal_percent],[pleasure_percent],[pain_percent]"

/datum/sex_session/proc/check_climax()
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] < ACTIVE_EJAC_THRESHOLD)
		return FALSE
	return TRUE

/datum/sex_session/proc/get_active_action(action_ref)
	if(istype(action_ref, /datum/sex_action))
		var/datum/sex_action/action = action_ref
		if(action in active_actions)
			return action
		action_ref = action.get_menu_action_key()

	var/action_key = get_action_key(action_ref)
	for(var/datum/sex_action/action as anything in active_actions)
		if(action_key && action.get_menu_action_key() == action_key)
			return action
		if(ispath(action_ref, /datum/sex_action) && action.type == action_ref)
			return action
	return null

/datum/sex_session/proc/is_action_active(action_type)
	return !isnull(get_active_action(action_type))

/datum/sex_session/proc/get_action_priority(datum/sex_action/action, mob/living/viewer)
	if(!action || !viewer)
		return -1000000
	if(viewer == target)
		return action.target_priority
	if(viewer == user)
		return action.user_priority
	return -1000000

/datum/sex_session/proc/get_highest_priority_action_for(mob/living/viewer)
	var/datum/sex_action/highest_action
	for(var/datum/sex_action/action as anything in active_actions)
		if(!highest_action)
			highest_action = action
			continue
		if(get_action_priority(action, viewer) > get_action_priority(highest_action, viewer))
			highest_action = action
	return highest_action

/datum/sex_session/proc/update_current_action()
	current_action = get_highest_priority_action_for(user)

/datum/sex_session/proc/try_start_action(action_type)
	if(is_action_active(action_type))
		try_stop_current_action(action_type)
		return
	var/datum/sex_action/action = instantiate_action(action_type)
	if(!action)
		return
	if(!can_perform_action(action))
		return

	active_actions += action
	update_current_action()
	inactivity = 0
	log_combat(user, target, "Started sex action: [action.name] with [target.name].")
	INVOKE_ASYNC(src, PROC_REF(sex_action_loop), action)

/datum/sex_session/proc/try_stop_current_action(action_ref)
	if(!length(active_actions))
		return
	if(!action_ref)
		stop_current_action()
		return

	var/datum/sex_action/action = get_active_action(action_ref)
	if(action)
		stop_current_action(action)

/datum/sex_session/proc/considered_limp(mob/limper)
	if(QDELETED(limper))
		return TRUE // If no limper or deleted, consider it limp
	var/list/arousal_data = list()
	SEND_SIGNAL(limper, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal_value = arousal_data["arousal"]
	if(arousal_value >= VISIBLE_AROUSAL_THRESHOLD)
		return FALSE
	return TRUE

/datum/sex_session/proc/sex_action_loop(datum/sex_action/action)
	if(!action || !(action in active_actions))
		return
	if(action.on_start(user, target) == FALSE)
		stop_current_action(action)
		return

	while(action in active_actions)
		//if(isnull(target.client))
		//	break

		var/stamina_cost = action.stamina_cost * get_stamina_cost_multiplier()
		if(!user.adjust_stamina(-stamina_cost))
			break

		var/do_time = action.do_time / get_speed_multiplier()
		var/do_after_flags = IGNORE_USER_DIR_CHANGE | IGNORE_HELD_ITEM | IGNORE_SLOWDOWNS | IGNORE_SLOWDOWNS | IGNORE_USER_DOING
		var/interaction_key = "sex_action_[REF(action)]"
		if(!do_after(user, do_time, target = target, timed_action_flags = do_after_flags, interaction_key = interaction_key))
			break

		if(QDELETED(action) || !(action in active_actions))
			break
		if(!can_perform_action(action, TRUE))
			break
		if(action.is_finished(user, target))
			break
		if(action.stop_requested)
			break

		action.on_perform(user, target)
		if(QDELETED(action) || !(action in active_actions))
			break
		if(istype(user.loc, /obj/structure/closet))
			var/obj/structure/closet/sex_shack = user.loc
			sex_shack.Shake(1, 3, 15)

		if(user.has_kink(KINK_VISUAL_EFFECTS)) //Hearts played on action that can be turned off at will
			action.show_sex_effects(user)

		if(action.is_finished(user, target))
			break
		if(!action.continous)
			break

	stop_current_action(action)

/datum/sex_session/proc/stop_current_action(action_ref)
	if(!length(active_actions))
		return
	if(!action_ref)
		var/list/actions_to_stop = active_actions.Copy()
		for(var/datum/sex_action/action as anything in actions_to_stop)
			stop_current_action(action)
		return

	var/datum/sex_action/action = get_active_action(action_ref)
	if(user && target)
		var/key = "sex_action_[REF(action)]"
		user.stop_doing(key)
	if(!action)
		return

	active_actions -= action
	action.on_finish(user, target)
	update_current_action()
	if(!length(active_actions))
		// This is only a one-shot "finish the current loop" latch; don't let it leak into a future encounter.
		just_climaxed = FALSE
	qdel(action)

/datum/sex_session/proc/can_perform_action(action_type, performing = FALSE)
	var/datum/sex_action/action = get_action_template(action_type)
	if(!action)
		return FALSE
	if(!inherent_perform_check(action))
		return FALSE
	if(!action.can_perform(user, target) && !performing)
		return FALSE
	return TRUE

/datum/sex_session/proc/inherent_perform_check(action_type)
	var/datum/sex_action/action = get_action_template(action_type)
	if(!action)
		return FALSE
	if(!target)
		return FALSE
	if(user.stat != CONSCIOUS)
		return FALSE
	if(!user.adjacent_or_closet(target) && action.check_distance)
		return FALSE
	if(action.check_incapacitated)
		var/incapacitated_flags = IGNORE_GRAB
		if(!action.requires_free_hands)
			incapacitated_flags |= IGNORE_RESTRAINTS
		if(user.incapacitated(incapacitated_flags))
			return FALSE
	if(action.requires_free_hands && !user.has_free_sex_hands())
		return FALSE
	if(action.check_same_tile && !user.check_closet(target))
		var/same_tile = (get_turf(user) == get_turf(target))
		var/grab_bypass = (action.aggro_grab_instead_same_tile && user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE
	if(action.require_grab)
		var/grabstate = user.get_highest_grab_state_on(target)
		if(grabstate == null || grabstate < action.required_grab_state)
			return FALSE
	return TRUE

/datum/sex_session/proc/perform_sex_action(mob/living/action_initiator, mob/living/action_target, arousal_amt, pain_amt, orgasm_prog_amt, datum/sex_action/sex_act)

	var/list/arousal_data_target = list()
	SEND_SIGNAL(action_target, COMSIG_SEX_GET_AROUSAL, arousal_data_target)


	if(HAS_TRAIT(user, TRAIT_GOODLOVER) && user != action_initiator)
		arousal_amt *= 1.5
		orgasm_prog_amt *= 1.5
		if(prob(10)) //10 perc chance each action to emit the message so they know who the fuckin' wituser.
			var/lovermessage = pick("This feels so good!","I am in nirvana!","This is too good to be possible!","By the Gods!","I can't stop, too good!~")
			to_chat(action_target, span_love(lovermessage))

	if(action_target != user && edging_other)
		if(arousal_data_target["arousal"] >= AROUSAL_EDGING_THRESHOLD + 15)
			var/succes_chance = 100
			if(prob(5))
				to_chat(user, span_love("I try to match my movements so that they don't climax too soon..."))
			if(speed > SEX_SPEED_MID || force > SEX_FORCE_MID)
				succes_chance *= 0.5
			if(action_target.has_status_effect(/datum/status_effect/edging_overstimulation))
				succes_chance *= 0.3
				if(prob(10))
					to_chat(user, span_love("They are just too sensitive for me to control their pleasure..."))
			if(user.get_stat_level(STATKEY_PER) < 7)
				succes_chance *= 0.7
				if(prob(10))
					to_chat(user, span_love("I can't tell if they are close or not..."))
			if(prob(succes_chance))
				SEND_SIGNAL(action_target, COMSIG_SEX_EDGED_BY_OTHER_STATE, TRUE) //yeah, feels like a hack, honesytly, but it works

	var/res_send = RESIST_NONE
	var/mob/living/action_user_final
	var/giving = TRUE

	if(user == action_initiator) //set proper user
		action_user_final = user
	else
		action_user_final = action_initiator
		giving = FALSE

	var/list/arousal_data_user = list()
	SEND_SIGNAL(action_user_final, COMSIG_SEX_GET_AROUSAL, arousal_data_user)
	res_send = arousal_data_user["resistance_to_pleasure"]

	SEND_SIGNAL(action_user_final, COMSIG_SEX_RECEIVE_ACTION, sex_act, action_initiator, action_target, arousal_amt, pain_amt, orgasm_prog_amt, giving, force, speed, res_send)

/datum/sex_session/proc/handle_passive_ejaculation(mob/living/handler)
	if(!handler)
		handler = user
	var/list/arousal_data = list()
	SEND_SIGNAL(handler, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal_multiplier = arousal_data["arousal_multiplier"]
	var/arousal_value = arousal_data["arousal"]

	if(arousal_multiplier > 1.5 && user.check_handholding())
		if(prob(5))
			SEND_SIGNAL(handler, COMSIG_SEX_RECEIVE_ACTION, 3, 0, 1, 0)
		if(arousal_value < 70)
			SEND_SIGNAL(handler, COMSIG_SEX_ADJUST_AROUSAL, 0.2)

		if(iscarbon(handler))
			var/mob/living/carbon/carbon_handler = handler
			if(carbon_handler.handcuffed)
				if(prob(8))
					var/chaffepain = pick(10,10,10,10,20,20,30)
					SEND_SIGNAL(handler, COMSIG_SEX_RECEIVE_ACTION, 3, chaffepain, 1, 0)
					handler.visible_message(("<span class='love_mid'>[handler] squirms uncomfortably in [handler.p_their()] restraints.</span>"), \
						("<span class='love_extreme'>I feel [carbon_handler.handcuffed] rub uncomfortably against my skin.</span>"))
				if(arousal_value < ACTIVE_EJAC_THRESHOLD)
					SEND_SIGNAL(handler, COMSIG_SEX_ADJUST_AROUSAL, 0.25)

/datum/sex_session/proc/perform_deepthroat_oxyloss(mob/living/action_target, oxyloss_amt)
	var/oxyloss_multiplier = 0
	switch(force)
		if(SEX_FORCE_LOW)
			oxyloss_multiplier = 0
		if(SEX_FORCE_MID)
			oxyloss_multiplier = 0
		if(SEX_FORCE_HIGH)
			oxyloss_multiplier = 0.5
		if(SEX_FORCE_EXTREME)
			oxyloss_multiplier = 1.0
	oxyloss_amt *= oxyloss_multiplier
	if((oxyloss_amt <= 0) || (action_target.getOxyLoss() > 30))
		return
	action_target.adjustOxyLoss(oxyloss_amt)
	// Indicate someone is choking through sex
	if(action_target.oxyloss >= 25 && prob(33))
		action_target.emote(pick(list("gag", "choke", "gasp")), forced = TRUE)

/datum/sex_session/proc/get_speed_multiplier()
	switch(speed)
		if(SEX_SPEED_LOW)
			return 1.0
		if(SEX_SPEED_MID)
			return 1.5
		if(SEX_SPEED_HIGH)
			return 2.0
		if(SEX_SPEED_EXTREME)
			return 2.5

/datum/sex_session/proc/get_stamina_cost_multiplier()
	switch(force)
		if(SEX_FORCE_LOW)
			return 1.0
		if(SEX_FORCE_MID)
			return 1.5
		if(SEX_FORCE_HIGH)
			return 2.0
		if(SEX_FORCE_EXTREME)
			return 2.5

/datum/sex_session/proc/adjust_speed(amt)
	speed = clamp(speed + amt, SEX_SPEED_MIN, SEX_SPEED_MAX)

/datum/sex_session/proc/adjust_force(amt)
	force = clamp(force + amt, SEX_FORCE_MIN, SEX_FORCE_MAX)

/datum/sex_session/proc/adjust_resist(amt)
	resistance_to_pleasure = clamp(resistance_to_pleasure + amt, RESIST_NONE, RESIST_HIGH)

/datum/sex_session/proc/finished_check()
	if(!do_until_finished)
		return FALSE
	if(just_climaxed)
		just_climaxed = FALSE
		return TRUE
	return FALSE

/datum/sex_session/proc/on_climax(mob/source)
	if(!do_until_finished)
		return
	just_climaxed = TRUE
	try_stop_current_action()


/datum/sex_session/proc/get_force_string()
	switch(force)
		if(SEX_FORCE_LOW)
			return "<font color='#eac8de'>GENTLE</font>"
		if(SEX_FORCE_MID)
			return "<font color='#e9a8d1'>FIRM</font>"
		if(SEX_FORCE_HIGH)
			return "<font color='#f05ee1'>ROUGH</font>"
		if(SEX_FORCE_EXTREME)
			return "<font color='#d146f5'>BRUTAL</font>"

/datum/sex_session/proc/get_speed_string()
	switch(speed)
		if(SEX_SPEED_LOW)
			return "<font color='#eac8de'>SLOW</font>"
		if(SEX_SPEED_MID)
			return "<font color='#e9a8d1'>STEADY</font>"
		if(SEX_SPEED_HIGH)
			return "<font color='#f05ee1'>QUICK</font>"
		if(SEX_SPEED_EXTREME)
			return "<font color='#d146f5'>UNRELENTING</font>"

/datum/sex_session/proc/get_manual_arousal_string()
	switch(manual_arousal)
		if(SEX_MANUAL_AROUSAL_DEFAULT)
			return "<font color='#eac8de'>NATURAL</font>"
		if(SEX_MANUAL_AROUSAL_UNAROUSED)
			return "<font color='#e9a8d1'>UNAROUSED</font>"
		if(SEX_MANUAL_AROUSAL_PARTIAL)
			return "<font color='#f05ee1'>PARTIALLY ERECT</font>"
		if(SEX_MANUAL_AROUSAL_FULL)
			return "<font color='#d146f5'>FULLY ERECT</font>"
/datum/sex_session/proc/get_generic_force_adjective()
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(list("gently", "carefully", "tenderly", "gingerly", "delicately", "lazily"))
		if(SEX_FORCE_MID)
			return pick(list("firmly", "vigorously", "eagerly", "steadily", "intently"))
		if(SEX_FORCE_HIGH)
			return pick(list("roughly", "carelessly", "forcefully", "fervently", "fiercely"))
		if(SEX_FORCE_EXTREME)
			return pick(list("brutally", "violently", "relentlessly", "savagely", "mercilessly"))

/datum/sex_session/proc/spanify_force(string)
	switch(force)
		if(SEX_FORCE_LOW)
			return "<span class='love_low'>[string]</span>"
		if(SEX_FORCE_MID)
			return "<span class='love_mid'>[string]</span>"
		if(SEX_FORCE_HIGH)
			return "<span class='love_high'>[string]</span>"
		if(SEX_FORCE_EXTREME)
			return "<span class='love_extreme'>[string]</span>"

/datum/sex_session/proc/get_resist_string()
	switch(resistance_to_pleasure)
		if(RESIST_NONE)
			return "<font color='#eac8de'>NONE</font>"
		if(RESIST_LOW)
			return "<font color='#e9a8d1'>LOW</font>"
		if(RESIST_MEDIUM)
			return "<font color='#f05ee1'>MEDIUM</font>"
		if(RESIST_HIGH)
			return "<font color='#d146f5'>HIGH</font>"

/datum/sex_session/proc/get_force_sound()
	switch(force)
		if(SEX_FORCE_LOW, SEX_FORCE_MID)
			return pick(SEX_SOUNDS_SLOW)
		if(SEX_FORCE_HIGH, SEX_FORCE_EXTREME)
			return pick(SEX_SOUNDS_HARD)

/datum/sex_session/proc/sanitize_ui_zone_filter(filter_value)
	var/zone_filter = text2num(filter_value)
	switch(zone_filter)
		if(SEX_UI_ZONE_ANY, SEX_UI_ZONE_MOUTH, SEX_UI_ZONE_GENITALS, SEX_UI_ZONE_ARMS, SEX_UI_ZONE_LEGS, SEX_UI_ZONE_BODY, SEX_UI_ZONE_MISC)
			return zone_filter
	return SEX_UI_ZONE_ANY

/datum/sex_session/proc/render_zone_filter_panel(panel_title, task_name, current_filter, selected_tab)
	var/list/content = list()
	content += "<div class='zone-filter-panel'>"
	content += "<div class='zone-filter-title'>[format_ui_text(panel_title)]</div>"
	for(var/filter_label in action_zone_filter_options)
		var/filter_value = action_zone_filter_options[filter_label]
		var/filter_class = "zone-filter-option"
		if(filter_value == current_filter)
			filter_class += " active"
		content += "<a class='[filter_class]' href='?src=[REF(src)];task=[task_name];value=[filter_value];tab=[selected_tab]'>[html_encode(filter_label)]</a>"
	content += "</div>"
	return content.Join("")

/datum/sex_session/proc/get_selected_tab_content(selected_tab)
	switch(selected_tab)
		if("custom_actions")
			return get_custom_actions_tab_content(selected_tab)
		if("genital")
			return get_controls_tab_content(selected_tab)
		if("session")
			return get_session_tab_content()
		if("preferences")
			return get_preferences_tab_content()
		if("kinks")
			return get_kinks_tab_content()
		if("notes")
			return get_notes_tab_content()
	return get_interactions_tab_content(selected_tab)

/datum/sex_session/proc/get_interactions_tab_content(selected_tab)
	var/list/content = list()
	var/list/available_actions = list()
	var/total_available_actions = 0
	var/current_speed_name = plain_quick_control_text(get_speed_string())
	var/current_force_name = plain_quick_control_text(get_force_string())
	var/current_resist_name = plain_quick_control_text(get_resist_string())
	var/lying_direction_name = user.get_lying_direction_name()

	for(var/datum/sex_action/candidate_action as anything in get_all_menu_actions())
		if(!candidate_action.shows_on_menu(user, target))
			continue
		if(is_action_active(candidate_action))
			continue
		total_available_actions++
		if(!candidate_action.matches_ui_filters(user_zone_filter, target_zone_filter))
			continue
		available_actions += candidate_action

	var/target_panel_title = (user == target) ? "On yourself" : "On [target.name]"

	content += "<div class='interaction-layout'>"
	content += render_zone_filter_panel("You use", "set_user_zone_filter", user_zone_filter, selected_tab)
	content += "<div class='interaction-column'>"
	content += "<div class='search-container'>"
	content += "<span class='search-icon'></span>"
	content += "<input type='text' class='search-box' placeholder='Search for an interaction' id='searchBox'>"
	content += "</div>"
	content += "<div class='action-summary'>Showing [length(available_actions)] of [total_available_actions] available interactions for the current zone filters.</div>"

	if(length(active_actions))
		content += "<div class='action-section'>"
		content += "<div class='action-subheader'>Active Actions</div>"
		content += "<div class='action-list'>"
		for(var/datum/sex_action/active_action as anything in active_actions)
			var/active_action_key = url_encode(active_action.get_menu_action_key())
			content += "<div class='action-item active-action-item'>"
			content += "<a class='action-button active' href='?src=[REF(src)];task=action;action_type=[active_action_key];tab=[selected_tab]'>[format_ui_text(active_action.name)]</a>"
			content += "<div class='action-icons'>"
			content += "<a href='?src=[REF(src)];task=stop;action_type=[active_action_key];tab=[selected_tab]' class='icon-btn stop' title='Stop action'>X</a>"
			content += "</div>"
			content += "</div>"
		content += "</div>"
		content += "</div>"

	content += "<div class='action-section'>"
	content += "<div class='action-subheader'>Available Actions</div>"
	if(!length(available_actions))
		content += "<div class='action-empty'>No interactions match these zone filters yet.</div>"
	else
		content += "<div class='action-list'>"
		for(var/datum/sex_action/menu_action as anything in available_actions)
			content += "<div class='action-item searchable-action-item'>"
			var/button_class = "action-button"
			var/can_perform = can_perform_action(menu_action)
			var/action_key = url_encode(menu_action.get_menu_action_key())

			if(menu_action.name == "Salute")
				button_class += " blue"
			if(!can_perform)
				button_class += " linkOff"

			content += "<a class='[button_class]' href='?src=[REF(src)];task=action;action_type=[action_key];tab=[selected_tab]'>[format_ui_text(menu_action.name)]</a>"
			content += "<div class='action-icons'></div>"
			content += "</div>"
		content += "</div>"
	content += "</div>"
	content += "</div>"
	content += render_zone_filter_panel(target_panel_title, "set_target_zone_filter", target_zone_filter, selected_tab)
	content += "</div>"
	content += "<div class='interaction-quick-bar-wrap'>"
	content += "<div class='interaction-quick-bar'>"
	content += "<div class='quick-row'>"
	content += render_interaction_quick_stepper("Speed", current_speed_name, "speed_down", "speed_up", selected_tab)
	content += render_interaction_quick_stepper("Force", current_force_name, "force_down", "force_up", selected_tab)
	content += render_interaction_quick_stepper("Hold", current_resist_name, "resist_down", "resist_up", selected_tab)
	content += "</div>"
	content += "<div class='quick-row'>"
	content += "<a class='quick-toggle[do_until_finished ? " active" : ""]' href='?src=[REF(src)];task=toggle_finished;tab=[selected_tab]'>[do_until_finished ? "Until I'm Finished" : "Until I Stop"]</a>"
	content += "<a class='quick-toggle[edging_other ? " active" : ""]' href='?src=[REF(src)];task=toggle_edging_other;tab=[selected_tab]'>Edge [edging_other ? "On" : "Off"]</a>"
	if(lying_direction_name)
		content += "<a class='quick-toggle' href='?src=[REF(src)];task=swap_lying_direction;tab=[selected_tab]'>Swap Side ([format_ui_text(capitalize(lying_direction_name))])</a>"
	else
		content += "<span class='quick-toggle disabled'>Swap Side</span>"
	content += "</div>"
	content += "</div>"
	content += "</div>"

	return content.Join("")

/datum/sex_session/proc/plain_quick_control_text(value_text)
	var/open_tag_end = findtext(value_text, ">")
	if(open_tag_end)
		value_text = copytext(value_text, open_tag_end + 1)

	return replacetext(value_text, "</font>", "")

/datum/sex_session/proc/render_interaction_quick_stepper(label, value_text, decrease_task, increase_task, selected_tab)
	var/list/content = list()

	content += "<div class='quick-stepper'>"
	content += "<span class='quick-stepper-label'>[label]</span>"
	content += "<a class='quick-stepper-btn' href='?src=[REF(src)];task=[decrease_task];tab=[selected_tab]'>-</a>"
	content += "<span class='quick-stepper-value'>[format_ui_text(value_text)]</span>"
	content += "<a class='quick-stepper-btn' href='?src=[REF(src)];task=[increase_task];tab=[selected_tab]'>+</a>"
	content += "</div>"

	return content.Join("")

/datum/sex_session/proc/get_controls_tab_content(selected_tab)
	var/list/content = list()
	var/current_speed = get_current_speed()
	var/current_force = get_current_force()
	var/current_resist = get_current_resist()
	var/speed_name = get_speed_string()
	var/force_name = get_force_string()
	var/resist_name = get_resist_string()
	var/manual_arousal_name = get_manual_arousal_string()

	content += "<div class='control-section'>"
	content += "<h3>Speed & Force Controls</h3>"

	content += "<div class='slider-container'>"
	content += "<div class='slider-label'>Speed:</div>"
	content += "<div class='slider-wrapper'>"
	content += "<div class='slider-track'>"
	content += "<div class='slider-fill' style='width: [((current_speed - SEX_SPEED_MIN) / (SEX_SPEED_MAX - SEX_SPEED_MIN)) * 100]%;'></div>"
	content += "</div>"
	content += "<div class='slider-notches'>"
	for(var/i = SEX_SPEED_MIN; i <= SEX_SPEED_MAX; i++)
		var/notch_position = ((i - SEX_SPEED_MIN) / (SEX_SPEED_MAX - SEX_SPEED_MIN)) * 100
		var/notch_class = (i <= current_speed) ? "slider-notch active" : "slider-notch"
		content += "<a href='?src=[REF(src)];task=set_speed;value=[i];tab=[selected_tab]' class='[notch_class]' style='left: [notch_position]%;'></a>"
	content += "</div>"
	content += "</div>"
	content += "<div class='slider-value'>[speed_name]</div>"
	content += "</div>"

	content += "<div class='slider-container'>"
	content += "<div class='slider-label'>Force:</div>"
	content += "<div class='slider-wrapper'>"
	content += "<div class='slider-track'>"
	content += "<div class='slider-fill' style='width: [((current_force - SEX_FORCE_MIN) / (SEX_FORCE_MAX - SEX_FORCE_MIN)) * 100]%;'></div>"
	content += "</div>"
	content += "<div class='slider-notches'>"
	for(var/i = SEX_FORCE_MIN; i <= SEX_FORCE_MAX; i++)
		var/notch_position = ((i - SEX_FORCE_MIN) / (SEX_FORCE_MAX - SEX_FORCE_MIN)) * 100
		var/notch_class = (i <= current_force) ? "slider-notch active" : "slider-notch"
		content += "<a href='?src=[REF(src)];task=set_force;value=[i];tab=[selected_tab]' class='[notch_class]' style='left: [notch_position]%;'></a>"
	content += "</div>"
	content += "</div>"
	content += "<div class='slider-value'>[force_name]</div>"
	content += "</div>"

	content += "<div class='slider-container'>"
	content += "<div class='slider-label'>Holding pleasure:</div>"
	content += "<div class='slider-wrapper'>"
	content += "<div class='slider-track'>"
	content += "<div class='slider-fill' style='width: [((current_resist - RESIST_NONE) / (RESIST_HIGH - RESIST_NONE)) * 100]%;'></div>"
	content += "</div>"
	content += "<div class='slider-notches'>"
	for(var/i = RESIST_NONE; i <= RESIST_HIGH; i++)
		var/notch_position = ((i - RESIST_NONE) / (RESIST_HIGH - RESIST_NONE)) * 100
		var/notch_class = (i <= current_resist) ? "slider-notch active" : "slider-notch"
		content += "<a href='?src=[REF(src)];task=set_resist;value=[i];tab=[selected_tab]' class='[notch_class]' style='left: [notch_position]%;'></a>"
	content += "</div>"
	content += "</div>"
	content += "<div class='slider-value'>[resist_name]</div>"
	content += "</div>"

	content += "<div class='control-row'>"
	content += "<a href='?src=[REF(src)];task=toggle_edging_other;tab=[selected_tab]' class='toggle-btn'>[edging_other ? "EDGE THEM" : "DON'T EDGE THEM"]</a>"
	content += "</div>"

	if(user.getorganslot(ORGAN_SLOT_PENIS))
		content += "<div class='control-row'>"
		content += "<a href='?src=[REF(src)];task=manual_arousal_down;tab=[selected_tab]' class='control-btn'>&lt;</a>"
		content += " [manual_arousal_name] "
		content += "<a href='?src=[REF(src)];task=manual_arousal_up;tab=[selected_tab]' class='control-btn'>&gt;</a>"
		content += "</div>"

	content += "<div class='control-row'>"
	content += "<a href='?src=[REF(src)];task=toggle_finished;tab=[selected_tab]' class='toggle-btn'>[do_until_finished ? "UNTIL IM FINISHED" : "UNTIL I STOP"]</a>"
	content += "</div>"
	content += "</div>"

	return content.Join("")

/datum/sex_session/proc/show_ui(selected_tab = "interactions")
	if(!user?.client)
		return
	if(!session_updater)
		add_ui_tracking("sexcon[our_sex_id]")

	var/list/dat = list()
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)

	// CSS styling to match the dark red/brown color scheme
	dat += "<style>"
	dat += "body { background-color: #1a1010; color: #d4af8c; font-family: Arial, sans-serif; font-size: 12px; margin: 0; padding: 0; }"
	dat += ".main-container { background-color: #1a1010; min-height: 100vh; }"
	dat += ".header { background-color: #4a2c20; padding: 15px; border-bottom: 2px solid #8b6914; font-size: 16px; font-weight: bold; color: #d4af8c; }"
	dat += ".status-box { background-color: #2a1a15; border: 1px solid #4a2c20; margin: 10px; padding: 15px; }"
	dat += ".status-item { margin: 3px 0; font-size: 12px; color: #d4af8c; }"
	dat += ".progress-container { margin: 10px; }"
	dat += ".progress-bar { background-color: #2a1a15; height: 25px; margin: 2px 0; position: relative; overflow: hidden; border: 1px solid #4a2c20; }"
	dat += ".progress-fill-pleasure { background: linear-gradient(90deg, #ff69b4, #ff1493); height: 100%; transition: width 0.3s; }"
	dat += ".progress-fill-arousal { background: linear-gradient(90deg, #ff4444, #cc0000); height: 100%; transition: width 0.3s; }"
	dat += ".progress-fill-pain { background: linear-gradient(90deg, #666666, #333333); height: 100%; transition: width 0.3s; }"
	dat += ".progress-label { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-weight: bold; color: #d4af8c; text-shadow: 1px 1px 2px rgba(0,0,0,0.8); }"
	dat += ".tabs { display: flex; background-color: #4a2c20; border-bottom: 1px solid #8b6914; }"
	dat += ".tab { padding: 12px 20px; background-color: #2a1a15; border-right: 1px solid #4a2c20; color: #d4af8c; cursor: pointer; text-decoration: none; }"
	dat += ".tab:hover { background-color: #3a2318; }"
	dat += ".tab.active { background-color: #4a2c20; color: #d4af8c; border-bottom: 2px solid #8b6914; }"
	dat += ".search-container { margin: 0 0 10px 0; display: flex; align-items: center; }"
	dat += ".search-icon { margin-right: 8px; font-size: 14px; }"
	dat += ".search-box { flex-grow: 1; padding: 8px; background-color: #2a1a15; border: 1px solid #4a2c20; color: #d4af8c; border-radius: 3px; margin-right: 5px; }"
	dat += ".search-btn { padding: 8px 12px; background-color: #8b6914; border: none; color: #d4af8c; cursor: pointer; border-radius: 3px; }"
	dat += ".search-btn:hover { background-color: #a07a1a; }"
	dat += ".section-header { background-color: #8b6914; color: #d4af8c; padding: 8px 15px; margin: 10px; font-weight: bold; }"
	dat += ".action-list { margin: 0 10px; }"
	dat += ".action-item { display: flex; align-items: center; margin: 2px 0; }"
	dat += ".interaction-layout { display: flex; gap: 10px; margin: 10px; align-items: flex-start; }"
	dat += ".interaction-column { flex: 1; min-width: 0; }"
	dat += ".zone-filter-panel { width: 120px; background-color: #2a1a15; border: 1px solid #4a2c20; border-radius: 5px; overflow: hidden; flex-shrink: 0; }"
	dat += ".zone-filter-title { background-color: #4a2c20; padding: 8px 10px; font-weight: bold; text-align: center; color: #d4af8c; }"
	dat += ".zone-filter-option { display: block; padding: 8px 10px; border-top: 1px solid #1a1010; color: #d4af8c; text-decoration: none; text-align: center; }"
	dat += ".zone-filter-option:hover { background-color: #3a2318; }"
	dat += ".zone-filter-option.active { background-color: #8b6914; color: #ffffff; }"
	dat += ".action-section { margin-bottom: 12px; }"
	dat += ".action-subheader { background-color: #4a2c20; color: #d4af8c; padding: 8px 12px; font-weight: bold; margin-bottom: 6px; border-radius: 3px; }"
	dat += ".action-summary { margin: 0 0 10px 0; color: #b09070; font-size: 11px; }"
	dat += ".action-empty { background-color: #2a1a15; border: 1px dashed #4a2c20; color: #666666; padding: 12px; text-align: center; font-style: italic; border-radius: 4px; }"
	dat += ".interaction-quick-bar-wrap { margin: 10px 110px 0 110px; text-align: center; clear: both; }"
	dat += ".interaction-quick-bar { display: inline-block; padding: 8px 10px; background-color: rgba(32, 18, 16, 0.96); border: 1px solid #5b3426; border-radius: 8px; box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.28); }"
	dat += ".quick-row { text-align: center; white-space: nowrap; }"
	dat += ".quick-row + .quick-row { margin-top: 6px; }"
	dat += ".quick-stepper { display: inline-block; margin: 0 3px; background-color: #251714; border: 1px solid #5b3426; border-radius: 999px; overflow: hidden; white-space: nowrap; vertical-align: middle; }"
	dat += ".quick-stepper-label { display: inline-block; min-width: 48px; padding: 7px 8px 6px; background-color: #3a2318; color: #cfab84; font-size: 10px; font-weight: bold; letter-spacing: 0.05em; text-transform: uppercase; vertical-align: middle; }"
	dat += ".quick-stepper-btn { display: inline-block; width: 24px; padding: 7px 0 6px; background-color: #140d0c; color: #f4d6b6; text-align: center; text-decoration: none; font-weight: bold; vertical-align: middle; }"
	dat += ".quick-stepper-btn:hover { background-color: #261714; }"
	dat += ".quick-stepper-value { display: inline-block; min-width: 74px; padding: 7px 10px 6px; color: #f4d6b6; text-align: center; font-size: 11px; font-weight: bold; white-space: nowrap; vertical-align: middle; }"
	dat += ".quick-toggle { display: inline-block; margin: 0 3px; padding: 7px 7px 6px; background-color: #241614; border: 1px solid #5b3426; border-radius: 500px; color: #d4af8c; text-decoration: none; font-size: 11px; font-weight: bold; white-space: nowrap; vertical-align: middle; }"
	dat += ".quick-toggle:hover { background-color: #34201b; }"
	dat += ".quick-toggle.active { background-color: #6a4223; color: #fff2df; border-color: #8b6914; }"
	dat += ".quick-toggle.disabled { background-color: #2a1a15; color: #8f7661; border-color: #4a2c20; cursor: default; }"
	dat += ".action-button { flex-grow: 1; padding: 10px 15px; background-color: #4a2c20; color: #d4af8c; text-decoration: none; display: block; font-weight: bold; border: 1px solid #2a1a15; }"
	dat += ".action-button:hover { background-color: #5a3525; }"
	dat += ".action-button.blue { background-color: #3a4a5a; border-color: #5a6a7a; }"
	dat += ".action-button.blue:hover { background-color: #4a5a6a; }"
	dat += ".action-button.active { background-color: #8b6914 !important; color: #ffffff !important; border-color: #a07a1a !important; box-shadow: 0 0 5px rgba(139, 105, 20, 0.5) !important; }"
	dat += ".action-icons { display: flex; margin-left: 5px; }"
	dat += ".icon-btn { display: inline-block; width: 25px; height: 25px; margin-left: 2px; background-color: #4a2c20; border: 1px solid #2a1a15; color: #d4af8c; text-align: center; line-height: 23px; cursor: pointer; font-size: 11px; text-decoration: none; }"
	dat += ".icon-btn:hover { background-color: #5a3525; }"
	dat += ".icon-btn.star { background-color: #8b6914; }"
	dat += ".icon-btn.stop { background-color: #cc4444; }"
	dat += ".linkOn { background-color: #8b6914 !important; color: #ffffff !important; }"
	dat += ".linkOff { background-color: #2a1a15 !important; color: #666666 !important; }"
	dat += ".tab-content { display: none; }"
	dat += ".tab-content.active { display: block; }"
	dat += ".control-section { margin: 10px; padding: 15px; background-color: #2a1a15; border: 1px solid #4a2c20; border-radius: 5px; }"
	dat += ".control-section h3 { color: #d4af8c; margin-top: 0; }"
	dat += ".control-row { margin: 15px 0; text-align: center; }"
	dat += ".control-btn { padding: 8px 15px; margin: 0 5px; background-color: #8b6914; color: #d4af8c; text-decoration: none; border-radius: 3px; }"
	dat += ".control-btn:hover { background-color: #a07a1a; }"
	dat += ".toggle-btn { padding: 8px 15px; background-color: #4a2c20; color: #d4af8c; text-decoration: none; border-radius: 3px; margin: 5px; border: 1px solid #2a1a15; }"
	dat += ".toggle-btn:hover { background-color: #5a3525; }"

	// Slider styles
	dat += ".slider-container { display: flex; align-items: center; justify-content: center; margin: 20px 0; }"
	dat += ".slider-label { min-width: 80px; text-align: right; margin-right: 15px; color: #d4af8c; font-weight: bold; }"
	dat += ".slider-wrapper { position: relative; width: 300px; height: 30px; margin: 0 15px; }"
	dat += ".slider-track { width: 100%; height: 6px; background-color: #2a1a15; border: 1px solid #4a2c20; border-radius: 3px; position: absolute; top: 50%; transform: translateY(-50%); }"
	dat += ".slider-fill { height: 100%; background: linear-gradient(90deg, #8b6914, #a07a1a); border-radius: 2px; transition: width 0.3s ease; }"
	dat += ".slider-notches { position: absolute; width: 100%; height: 30px; top: 0; }"
	dat += ".slider-notch { position: absolute; width: 2px; height: 15px; background-color: #4a2c20; top: 50%; transform: translate(-50%, -50%); cursor: pointer; }"
	dat += ".slider-notch:hover { background-color: #8b6914; }"
	dat += ".slider-notch.active { background-color: #a07a1a; height: 20px; }"
	dat += ".slider-value { min-width: 100px; text-align: left; margin-left: 15px; color: #d4af8c; font-style: italic; }"

	// Styles for kinks and notes tabs
	dat += ".kink-category { margin: 15px 0; }"
	dat += ".kink-category-title { background-color: #8b6914; color: #d4af8c; padding: 8px 15px; font-weight: bold; margin-bottom: 5px; }"
	dat += ".kink-item { background-color: #2a1a15; border: 1px solid #4a2c20; margin: 2px 0; padding: 10px; }"
	dat += ".kink-name { font-weight: bold; color: #d4af8c; margin-bottom: 5px; }"
	dat += ".kink-description { color: #b09070; font-size: 11px; margin-bottom: 5px; }"
	dat += ".kink-intensity { color: #ff69b4; font-size: 11px; }"
	dat += ".kink-notes { color: #a0a0a0; font-style: italic; font-size: 11px; margin-top: 5px; }"
	dat += ".kink-disabled { opacity: 0.5; }"
	dat += ".note-item { background-color: #2a1a15; border: 1px solid #4a2c20; margin: 5px 0; padding: 12px; }"
	dat += ".note-title { font-weight: bold; color: #d4af8c; margin-bottom: 8px; }"
	dat += ".note-content { color: #b09070; line-height: 1.4; margin-bottom: 8px; }"
	dat += ".note-meta { color: #808080; font-size: 10px; }"
	dat += ".no-data { text-align: center; color: #666666; padding: 20px; font-style: italic; }"
	dat += ".session-info { background-color: #2a1a15; border: 1px solid #4a2c20; margin: 10px; padding: 15px; }"
	dat += ".session-name-input { background-color: #2a1a15; border: 1px solid #4a2c20; color: #d4af8c; padding: 8px; margin: 5px 0; width: 200px; }"
	dat += ".participants-list { margin: 10px 0; }"
	dat += ".participant-item { background-color: #3a2a20; padding: 8px; margin: 3px 0; border-left: 3px solid #8b6914; }"
	dat += ".collective-toggle { background-color: #4a2c20; color: #d4af8c; border: 1px solid #2a1a15; padding: 10px 15px; cursor: pointer; margin: 10px 0; }"
	dat += ".collective-toggle.enabled { background-color: #8b6914; color: #ffffff; }"
	dat += ".prefs-container { display: flex; height: 400px; }"
	dat += ".prefs-left, .prefs-right { width: 50%; padding: 10px; }"
	dat += ".prefs-left { border-right: 1px solid #4a2c20; }"
	dat += ".prefs-header { background-color: #8b6914; color: #d4af8c; padding: 8px 15px; margin-bottom: 10px; font-weight: bold; }"
	dat += ".pref-category { margin: 15px 0; }"
	dat += ".pref-category-title { background-color: #4a2c20; color: #d4af8c; padding: 6px 12px; font-weight: bold; margin-bottom: 5px; }"
	dat += ".pref-item { background-color: #2a1a15; border: 1px solid #4a2c20; margin: 2px 0; padding: 8px; }"
	dat += ".pref-name { font-weight: bold; color: #d4af8c; margin-bottom: 3px; }"
	dat += ".pref-description { color: #b09070; font-size: 11px; margin-bottom: 5px; }"
	dat += ".pref-toggle { background-color: #4a2c20; color: #d4af8c; border: none; padding: 5px 10px; cursor: pointer; border-radius: 3px; }"
	dat += ".pref-toggle.enabled { background-color: #8b6914; color: #ffffff; }"
	dat += ".pref-toggle.disabled { background-color: #666666; cursor: not-allowed; }"

	dat += ".notes-sub-tabs { display: flex; background-color: #4a2c20; border-bottom: 1px solid #8b6914; margin-bottom: 15px; }"
	dat += ".notes-sub-tab { padding: 10px 15px; background-color: #2a1a15; border-right: 1px solid #4a2c20; color: #d4af8c; cursor: pointer; text-decoration: none; flex: 1; text-align: center; }"
	dat += ".notes-sub-tab:hover { background-color: #3a2318; }"
	dat += ".notes-sub-tab.active { background-color: #8b6914; color: #ffffff; }"
	dat += ".notes-tab-content { display: none; }"
	dat += ".notes-tab-content.active { display: block; }"
	dat += ".panel-header { border-bottom: 1px solid #4a2c20; padding-bottom: 10px; margin-bottom: 15px; }"
	dat += ".panel-header h3 { margin: 0 0 10px 0; color: #d4af8c; font-size: 16px; }"
	dat += ".note-form { background-color: #1a1010; border: 1px solid #4a2c20; padding: 15px; margin: 10px 0; border-radius: 5px; }"
	dat += ".note-input-title { width: 100%; padding: 8px; background-color: #2a1a15; border: 1px solid #4a2c20; color: #d4af8c; margin-bottom: 10px; }"
	dat += ".note-input-content { width: 100%; height: 80px; padding: 8px; background-color: #2a1a15; border: 1px solid #4a2c20; color: #d4af8c; resize: vertical; }"
	dat += ".note-form-buttons { margin-top: 10px; text-align: right; }"
	dat += ".note-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }"
	dat += ".note-buttons { display: flex; gap: 5px; }"
	dat += ".note-btn { padding: 4px 8px; background-color: #4a2c20; color: #d4af8c; text-decoration: none; border-radius: 3px; font-size: 11px; }"
	dat += ".note-btn:hover { background-color: #5a3525; }"
	dat += ".note-btn.remove-btn { background-color: #cc4444; }"
	dat += ".note-btn.remove-btn:hover { background-color: #dd5555; }"
	dat += ".note-item { background-color: #1a1010; border: 1px solid #4a2c20; margin: 5px 0; padding: 12px; cursor: pointer; transition: all 0.3s ease; }"
	dat += ".note-item:hover { background-color: #2a1a15; border-color: #8b6914; }"
	dat += ".note-item.expanded { background-color: #2a1a15; border-color: #8b6914; box-shadow: 0 2px 8px rgba(139, 105, 20, 0.3); }"
	dat += ".note-content { color: #b09070; line-height: 1.4; margin-bottom: 8px; max-height: 60px; overflow: hidden; transition: max-height 0.3s ease; }"
	dat += ".note-content.expanded { max-height: none; overflow: visible; }"
	dat += ".custom-actions-layout { display: flex; gap: 10px; margin: 10px; align-items: flex-start; }"
	dat += ".custom-actions-sidebar { width: 260px; flex-shrink: 0; }"
	dat += ".custom-actions-editor { flex: 1; min-width: 0; background-color: #2a1a15; border: 1px solid #4a2c20; border-radius: 5px; padding: 15px; }"
	dat += ".custom-sidebar-item { display: block; background-color: #2a1a15; border: 1px solid #4a2c20; color: #d4af8c; text-decoration: none; padding: 10px; margin-bottom: 6px; border-radius: 4px; }"
	dat += ".custom-sidebar-item:hover { background-color: #3a2318; }"
	dat += ".custom-sidebar-item.active { background-color: #8b6914; color: #ffffff; border-color: #a07a1a; }"
	dat += ".custom-sidebar-name { display: block; font-weight: bold; margin-bottom: 4px; }"
	dat += ".custom-sidebar-summary { display: block; font-size: 11px; color: inherit; opacity: 0.9; }"
	dat += ".custom-editor-section { margin-top: 15px; }"
	dat += ".custom-editor-field { display: block; background-color: #1a1010; border: 1px solid #4a2c20; border-radius: 4px; color: #d4af8c; text-decoration: none; padding: 10px; margin-bottom: 8px; }"
	dat += ".custom-editor-field:hover { background-color: #2f1c14; border-color: #8b6914; }"
	dat += ".custom-editor-field.info { cursor: default; }"
	dat += ".custom-editor-field.info:hover { background-color: #1a1010; border-color: #4a2c20; }"
	dat += ".custom-editor-label { display: block; font-weight: bold; margin-bottom: 4px; }"
	dat += ".custom-editor-value { display: block; color: #b09070; line-height: 1.4; }"
	dat += ".custom-editor-detail { display: block; color: #808080; font-size: 10px; margin-top: 4px; }"
	dat += ".custom-editor-empty { color: #666666; font-style: italic; }"
	dat += ".custom-editor-buttons { display: flex; gap: 8px; flex-wrap: wrap; }"

	dat += "</style>"

	dat += "<div class='main-container'>"

	// Dynamic Sex Info
	dat += get_sex_session_header()
	dat += get_sex_session_body()

	dat += "<div class='progress-container'>"
	var/max_arousal = MAX_AROUSAL
	var/orgasm_threshold = PASSIVE_EJAC_THRESHOLD
	var/current_arousal = arousal_data["arousal"] || 0
	var/orgasm_progress = arousal_data["orgasm_progress"] || 0
	var/pleasure_percent = min(100, (orgasm_progress / orgasm_threshold) * 100)
	var/arousal_percent = min(100, (current_arousal / max_arousal) * 100)

	dat += "<div class='progress-bar'>"
	dat += "<div class='progress-fill-pleasure' style='width: [pleasure_percent]%;'></div>"
	dat += "<div class='progress-label'>Orgasm</div>"
	dat += "</div>"

	dat += "<div class='progress-bar'>"
	dat += "<div class='progress-fill-arousal' style='width: [arousal_percent]%;'></div>"
	dat += "<div class='progress-label'>Arousal</div>"
	dat += "</div>"

	dat += "<div class='progress-bar'>"
	dat += "<div class='progress-fill-pain' style='width: 0%;'></div>"
	dat += "<div class='progress-label'>Pain</div>"
	dat += "</div>"
	dat += "</div>"

	dat += "<div class='tabs'>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=interactions' class='tab [selected_tab == "interactions" ? "active" : ""]'>Interactions</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=custom_actions' class='tab [selected_tab == "custom_actions" ? "active" : ""]'>Custom Actions</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=genital' class='tab [selected_tab == "genital" ? "active" : ""]'>Controls</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=session' class='tab [selected_tab == "session" ? "active" : ""]'>Session</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=preferences' class='tab [selected_tab == "preferences" ? "active" : ""]'>Preferences</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=kinks' class='tab [selected_tab == "kinks" ? "active" : ""]'>Kinks</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=notes' class='tab [selected_tab == "notes" ? "active" : ""]'>Notes</a>"
	dat += "</div>"

	dat += "<div class='tab-content active' id='active-tab'>"
	dat += get_selected_tab_content(selected_tab)
	dat += "</div>"

	// JavaScript for search functionality and tab management
	dat += "<script type=\"text/javascript\">"

	dat +="function updateProgressBars(dataString) {"
	dat +=	"var values = dataString.split(',');"
	dat +=	"var arousalPercent = parseFloat(values\[0\]) || 0;"
	dat +=	"var pleasurePercent = parseFloat(values\[1\]) || 0;"
	dat +=	"var painPercent = parseFloat(values\[2\]) || 0;"

	dat +=	"var arousalBar = document.querySelector('.progress-fill-arousal');"
	dat +=	"var pleasureBar = document.querySelector('.progress-fill-pleasure');"
	dat +=	"var painBar = document.querySelector('.progress-fill-pain');"

	dat +=	"if(arousalBar) arousalBar.style.width = arousalPercent + '%';"
	dat +=	"if(pleasureBar) pleasureBar.style.width = pleasurePercent + '%';"
	dat +=	"if(painBar) painBar.style.width = painPercent + '%';"
	dat +=	"}"

	dat += "function switchNotesTab(tabName) {"
	dat += "  var contents = document.querySelectorAll('.notes-tab-content');"
	dat += "  contents.forEach(function(content) {"
	dat += "    content.classList.remove('active');"
	dat += "  });"
	dat += "  "
	dat += "  var tabs = document.querySelectorAll('.notes-sub-tab');"
	dat += "  tabs.forEach(function(tab) {"
	dat += "    tab.classList.remove('active');"
	dat += "  });"
	dat += "  "
	dat += "  if (tabName === 'self') {"
	dat += "    document.getElementById('selfNotesContent').classList.add('active');"
	dat += "    document.getElementById('selfTab').classList.add('active');"
	dat += "  } else if (tabName === 'target') {"
	dat += "    document.getElementById('targetNotesContent').classList.add('active');"
	dat += "    document.getElementById('targetTab').classList.add('active');"
	dat += "  }"
	dat += "}"

	dat += "function stopAction() { window.location.href = '?src=[REF(src)];task=stop;tab=[selected_tab]'; }"
	dat += "function updateSessionName() {"
	dat += "  var nameInput = document.getElementById('sessionNameInput');"
	dat += "  if(nameInput) {"
	dat += "    var newName = nameInput.value.trim();"
	dat += "    if(newName) {"
	dat += "      window.location.href = '?src=[REF(src)];task=update_session_name;name=' + encodeURIComponent(newName) + ';tab=session';"
	dat += "    }"
	dat += "  }"
	dat += "}"
	dat += "document.addEventListener('DOMContentLoaded', function() {"
	dat += "  var searchBox = document.getElementById('searchBox');"
	dat += "  if(searchBox) {"
	dat += "    searchBox.addEventListener('input', function() {"
	dat += "      var filter = this.value.toLowerCase();"
	dat += "      var items = document.querySelectorAll('.searchable-action-item');"
	dat += "      items.forEach(function(item) {"
	dat += "        var text = item.textContent.toLowerCase();"
	dat += "        item.style.display = text.includes(filter) ? 'flex' : 'none';"
	dat += "      });"
	dat += "    });"
	dat += "  }"
	dat += "});"

	dat += "function toggleSelfNoteForm() {"
	dat += "  var form = document.getElementById('selfNoteForm');"
	dat += "  var btn = document.getElementById('addSelfNoteBtn');"
	dat += "  if (form.style.display === 'none' || form.style.display === '') {"
	dat += "    form.style.display = 'block';"
	dat += "    btn.textContent = 'Cancel';"
	dat += "    document.getElementById('selfNoteTitle').focus();"
	dat += "  } else {"
	dat += "    form.style.display = 'none';"
	dat += "    btn.textContent = 'Add Note About Yourself';"
	dat += "    clearSelfNoteForm();"
	dat += "  }"
	dat += "}"

	dat += "function submitSelfNote() {"
	dat += "  var title = document.getElementById('selfNoteTitle').value.trim();"
	dat += "  var content = document.getElementById('selfNoteContent').value.trim();"
	dat += "  if (!title || !content) {"
	dat += "    alert('Please fill in both title and content.');"
	dat += "    return;"
	dat += "  }"
	dat += "  window.location.href = '?src=[REF(src)];task=submit_self_note;title=' + encodeURIComponent(title) + ';content=' + encodeURIComponent(content) + ';tab=notes';"
	dat += "}"

	dat += "function cancelSelfNote() {"
	dat += "  var form = document.getElementById('selfNoteForm');"
	dat += "  var btn = document.getElementById('addSelfNoteBtn');"
	dat += "  form.style.display = 'none';"
	dat += "  btn.textContent = 'Add Note About Yourself';"
	dat += "  clearSelfNoteForm();"
	dat += "}"

	dat += "function clearSelfNoteForm() {"
	dat += "  document.getElementById('selfNoteTitle').value = '';"
	dat += "  document.getElementById('selfNoteContent').value = '';"
	dat += "}"

	dat += "</script>"

	dat += "</div>"

	var/datum/browser/popup = new(user, "sexcon[our_sex_id]", "<center>Sate Desire</center>", 950, 760)
	popup.set_content(dat.Join())
	popup.open()
	return

/datum/sex_session/proc/format_ui_text(value)
	return html_encode("[value]")

/datum/sex_session/proc/format_ui_multiline_text(value)
	var/formatted_text = html_encode("[value]")
	return replacetext(formatted_text, "\n", "<br>")

/datum/sex_session/proc/get_session_tab_content()
	var/list/content = list()

	content += "<div class='session-info'>"

	// Session name editing
	var/session_name = collective?.collective_display_name || "Private Session"
	content += "<div style='margin: 10px 0;'>"
	content += "<label style='color: #d4af8c; font-weight: bold;'>Session Name:</label><br>"
	content += "<input type='text' id='sessionNameInput' class='session-name-input' value='[escape_html_attribute(session_name)]' placeholder='Enter session name...'>"
	content += "<button onclick='updateSessionName()' class='control-btn' style='margin-left: 5px;'>Update</button>"
	content += "</div>"

	// Participants list
	content += "<div class='participants-list'>"
	content += "<h4 style='color: #d4af8c;'>Participants:</h4>"

	var/list/participants = list(user, target)
	if(collective)
		participants = collective.involved_mobs

	for(var/mob/living/participant in participants)
		var/display_name = participant.name
		if(ishuman(participant))
			var/mob/living/carbon/human/human_participant = participant
			display_name = human_participant.get_face_name() || participant.name
		var/is_you = (participant == user) ? " (You)" : ""
		content += "<div class='participant-item'>[format_ui_text(display_name)][is_you]</div>"

	content += "</div>"

	// Collective messaging toggle
	var/collective_enabled = collective ? TRUE : FALSE
	var/any_has_flag = any_has_erp_pref(participants, /datum/erp_preference/boolean/subtle_session_messages)

	var/toggle_class = "collective-toggle"
	if(collective_enabled && any_has_flag)
		toggle_class += " enabled"

	content += "<div class='[toggle_class]' onclick=\"window.location.href='?src=[REF(src)];task=toggle_subtle;tab=session'\">"
	content += "<strong>Subtle Messaging:</strong> [collective_enabled && any_has_flag ? "ENABLED" : "DISABLED"]<br>"
	content += "<small>Allows group chat between all session participants</small>"
	content += "</div>"

	content += "</div>"

	return content.Join("")

/datum/sex_session/proc/get_preferences_tab_content()
	var/list/content = list()

	content += "<div class='prefs-container'>"

	// Left side - User's preferences (editable)
	content += "<div class='prefs-left'>"
	content += "<div class='prefs-header'>Your Preferences</div>"
	content += get_erp_preferences_display(user, TRUE)
	content += "</div>"

	// Right side - Target's preferences (read-only)
	content += "<div class='prefs-right'>"
	content += "<div class='prefs-header'>[format_ui_text(target.name)]'s Preferences</div>"
	content += get_erp_preferences_display(target, FALSE)
	content += "</div>"

	content += "</div>"

	return content.Join("")

/datum/sex_session/proc/get_erp_preferences_display(mob/living/character, editable = FALSE)
	var/list/content = list()

	if(!character.client?.prefs)
		content += "<div class='no-data'>No preferences available</div>"
		return content.Join("")

	var/datum/preferences/prefs = character.client.prefs
	if(!prefs.erp_preferences)
		prefs.erp_preferences = list()

	// Group preferences by category
	var/list/prefs_by_category = list()

	for(var/datum/erp_preference/pref_type as anything in subtypesof(/datum/erp_preference))
		if(IS_ABSTRACT(pref_type))
			continue
		var/datum/erp_preference/pref = new pref_type()
		var/category = pref.category

		if(!prefs_by_category[category])
			prefs_by_category[category] = list()

		prefs_by_category[category][pref_type] = pref

	// Display preferences by category
	for(var/category in prefs_by_category)
		content += "<div class='pref-category'>"
		content += "<div class='pref-category-title'>[format_ui_text(category)]</div>"

		for(var/pref_type in prefs_by_category[category])
			var/datum/erp_preference/pref = prefs_by_category[category][pref_type]

			content += "<div class='pref-item'>"
			content += "<div class='pref-name'>[format_ui_text(pref.name)]</div>"

			if(pref.description)
				content += "<div class='pref-description'>[format_ui_text(pref.description)]</div>"

			// Let the preference datum handle its own UI
			content += pref.show_session_ui(prefs, editable, src)

			content += "</div>"

		content += "</div>"

	return content.Join("")


/datum/sex_session/Topic(href, href_list)
	if(usr != user)
		return
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/selected_tab = href_list["tab"] || "interactions"
	if(handle_custom_action_topic(href_list))
		show_ui(selected_tab)
		return

	switch(href_list["task"])
		if("tab")
			selected_tab = href_list["tab"] || "interactions"
			show_ui(selected_tab)
			return
		if("set_user_zone_filter")
			user_zone_filter = sanitize_ui_zone_filter(href_list["value"])
		if("set_target_zone_filter")
			target_zone_filter = sanitize_ui_zone_filter(href_list["value"])
		if("action")
			var/action_ref = href_list["action_type"]
			if(!get_action_template(action_ref))
				show_ui(selected_tab)
				return
			try_start_action(action_ref)
		if("stop")
			try_stop_current_action(href_list["action_type"])
		if("set_speed")
			var/new_speed = text2num(href_list["value"])
			if(new_speed >= SEX_SPEED_MIN && new_speed <= SEX_SPEED_MAX)
				set_current_speed(new_speed)
		if("set_force")
			var/new_force = text2num(href_list["value"])
			if(new_force >= SEX_FORCE_MIN && new_force <= SEX_FORCE_MAX)
				set_current_force(new_force)
		if("set_resist")
			var/new_resist = text2num(href_list["value"])
			if(new_resist >= RESIST_NONE && new_resist <= RESIST_HIGH)
				set_current_resist(new_resist)
		if("manual_arousal_up")
			adjust_arousal_manual(1)
		if("manual_arousal_down")
			adjust_arousal_manual(-1)
		if("speed_up")
			adjust_speed(1)
		if("speed_down")
			adjust_speed(-1)
		if("force_up")
			adjust_force(1)
		if("force_down")
			adjust_force(-1)
		if("resist_up")
			adjust_resist(1)
		if("resist_down")
			adjust_resist(-1)
		if("toggle_finished")
			do_until_finished = !do_until_finished
		if("set_arousal")
			var/amount = input(user, "Value above [MAX_AROUSAL || 120] will immediately cause orgasm!", "Set Arousal", arousal_data["arousal"]) as num
			SEND_SIGNAL(user, COMSIG_SEX_SET_AROUSAL, amount)
		if("freeze_arousal")
			SEND_SIGNAL(user, COMSIG_SEX_FREEZE_AROUSAL)
		if("toggle_edging_other")
			edging_other = !edging_other
		if("swap_lying_direction")
			user.swap_lying_direction()

		if("update_session_name")
			var/new_name = url_decode(href_list["name"])
			if(new_name && collective)
				collective.collective_display_name = new_name
				//collective.update_collective_tab()
				to_chat(user, "<span class='notice'>Session name updated to '[new_name]'</span>")

		if("toggle_subtle")
			collective.toggle_subtle()

		// Generic preference handler - delegates to the preference datum
		if("handle_pref")
			var/pref_type = text2path(href_list["pref_type"])
			if(!pref_type || !ispath(pref_type, /datum/erp_preference))
				show_ui(selected_tab)
				return

			var/datum/erp_preference/pref = new pref_type()
			if(!user.client?.prefs)
				show_ui(selected_tab)
				return

			// Let the preference handle its own topic
			var/handled = pref.handle_session_topic(user, href_list, user.client.prefs, src)
			if(!handled)
				to_chat(user, "<span class='warning'>Unknown preference action.</span>")

		if("submit_self_note")
			var/note_title = url_decode(href_list["title"])
			var/note_content = url_decode(href_list["content"])

			if(!note_title || !note_content)
				to_chat(user, "<span class='warning'>Both title and content are required.</span>")
				show_ui(selected_tab)
				return

			var/character_slot = get_character_slot(user)

			var/list/existing_notes = get_player_notes_about(user.ckey, user.ckey, character_slot)
			if(existing_notes[note_title])
				to_chat(user, "<span class='warning'>A note with that title already exists. Please choose a different title.</span>")
				show_ui(selected_tab)
				return

			if(set_player_note_about(user.ckey, target.ckey, note_title, note_content, character_slot))
				to_chat(user, "<span class='notice'>Note '[note_title]' saved successfully.</span>")
			else
				to_chat(user, "<span class='warning'>Failed to save note. Please try again.</span>")

		if("edit_self_note")
			var/note_title = url_decode(href_list["note_title"])
			if(!note_title)
				show_ui(selected_tab)
				return

			var/character_slot = get_character_slot(user)
			var/list/notes = get_player_notes_about(user.ckey, user.ckey, character_slot)

			if(!notes[note_title])
				to_chat(user, "<span class='warning'>Note not found.</span>")
				show_ui(selected_tab)
				return

			var/old_content = notes[note_title]["content"]
			var/new_content = input(user, "Edit your self-note:", "Edit Note", old_content) as message|null

			if(!new_content)
				show_ui(selected_tab)
				return

			set_player_note_about(user.ckey, user.ckey, note_title, new_content, character_slot)
			to_chat(user, "<span class='notice'>Self-note '[note_title]' updated.</span>")

		if("remove_self_note")
			var/note_title = url_decode(href_list["note_title"])
			if(!note_title)
				show_ui(selected_tab)
				return

			var/character_slot = get_character_slot(user)
			var/datum/save_manager/SM = get_save_manager(user.ckey)
			if(SM)
				var/save_name = "character_[character_slot]_notes"
				var/list/all_notes = SM.get_data(save_name, "partner_notes", list())
				if(all_notes[ckey(user.ckey)] && all_notes[ckey(user.ckey)][note_title])
					if(alert(user, "Remove note '[note_title]'?", "Remove Note", "Remove", "Cancel") != "Remove")
						show_ui(selected_tab)
						return
					all_notes[ckey(user.ckey)] -= note_title
					SM.set_data(save_name, "partner_notes", all_notes)
					to_chat(user, "<span class='notice'>Self-note '[note_title]' removed.</span>")
				else
					to_chat(user, "<span class='warning'>Note not found.</span>")

	show_ui(selected_tab)

/datum/sex_session/proc/get_sex_session_header()
	if(user == target)
		return "<div class='header'>Interacting with yourself...</div>"
	else
		return "<div class='header'>Interacting with [format_ui_text(target.name)]...</div>"

/datum/sex_session/proc/get_sex_session_body()
	var/list/data = list()
	data += "<div class='status-box'>"
	data += "<div>You... </div>"
	data += user.return_character_information()
	data += "</div>"
	return data.Join("")

/datum/sex_session/proc/get_kinks_tab_content()
	var/list/content = list()
	var/datum/preferences/prefs = target.client?.prefs
	if(!prefs || !prefs.erp_preferences)
		content += "<div class='no-data'>No kink preferences found for this character.</div>"
		return content.Join("")

	var/list/kink_prefs = prefs.erp_preferences["kinks"]
	if(!kink_prefs || !length(kink_prefs))
		content += "<div class='no-data'>No kink preferences found for this character.</div>"
		return content.Join("")

	var/list/kinks_by_category = list()
	for(var/kink_name in kink_prefs)
		var/list/kink_data = kink_prefs[kink_name]
		if(!kink_data["enabled"])
			continue
		var/datum/kink/base_kink = GLOB.available_kinks[kink_name]
		if(!base_kink)
			continue
		var/category = base_kink.category
		if(!kinks_by_category[category])
			kinks_by_category[category] = list()
		kinks_by_category[category][kink_name] = kink_data

	for(var/category in kinks_by_category)
		content += "<div class='kink-category'>"
		content += "<div class='kink-category-title'>[format_ui_text(category)]</div>"
		for(var/kink_name in kinks_by_category[category])
			var/list/kink_data = kinks_by_category[category][kink_name]
			var/datum/kink/base_kink = GLOB.available_kinks[kink_name]
			var/kink_class = "kink-item"
			if(!kink_data["enabled"])
				kink_class += " kink-disabled"
			content += "<div class='[kink_class]'>"
			content += "<div class='kink-name'>[format_ui_text(kink_name)]</div>"
			content += "<div class='kink-description'>[format_ui_text(base_kink.description)]</div>"
			var/intensity_text = get_kink_intensity_text(kink_data["intensity"])
			content += "<div class='kink-intensity'>Intensity: [intensity_text]</div>"
			if(kink_data["notes"])
				content += "<div class='kink-notes'>Notes: [format_ui_text(kink_data["notes"])]</div>"
			content += "</div>"
		content += "</div>"
	return content.Join("")

/proc/get_kink_intensity_text(intensity)//this still needs to be made into a global somewhere numbers are just easier to work with
	switch(intensity)
		if(1) return "Very Light"
		if(2) return "Light"
		if(3) return "Moderate"
		if(4) return "Intense"
		if(5) return "Very Intense"
	return "Unknown"

/datum/sex_session/proc/get_notes_tab_content()
	var/list/content = list()
	var/character_slot = get_character_slot(user)

	// Get your own self-notes and the target's self-notes (shared with you)
	var/list/self_notes = get_player_notes_about(user.ckey, user.ckey, character_slot) // Your notes about yourself
	var/target_character_slot = get_character_slot(target)
	var/list/target_self_notes = get_player_notes_about(target.ckey, target.ckey, target_character_slot) // Target's notes about themselves

	// Sub-tabs for notes
	content += "<div class='notes-sub-tabs'>"
	content += "<a href='javascript:void(0)' class='notes-sub-tab active' onclick='switchNotesTab(\"self\")' id='selfTab'>Your Notes (Shared)</a>"
	content += "<a href='javascript:void(0)' class='notes-sub-tab' onclick='switchNotesTab(\"target\")' id='targetTab'>[format_ui_text(target.name)]'s Notes</a>"
	content += "</div>"

	// Self notes content (initially visible)
	content += "<div class='notes-tab-content active' id='selfNotesContent'>"
	content += "<div class='panel-header'>"
	content += "<h3>Your Notes (Shared with [format_ui_text(target.name)])</h3>"
	content += "<button onclick='toggleSelfNoteForm()' class='control-btn' id='addSelfNoteBtn'>Add Note About Yourself</button>"
	content += "</div>"

	// Hidden form for self notes
	content += "<div id='selfNoteForm' class='note-form' style='display: none;'>"
	content += "<h4>Add Note About Yourself</h4>"
	content += "<input type='text' id='selfNoteTitle' placeholder='Note title...' class='note-input-title'>"
	content += "<textarea id='selfNoteContent' placeholder='Write your note here...' class='note-input-content'></textarea>"
	content += "<div class='note-form-buttons'>"
	content += "<button onclick='submitSelfNote()' class='control-btn'>Save Note</button>"
	content += "<button onclick='cancelSelfNote()' class='control-btn' style='background-color: #666666; margin-left: 5px;'>Cancel</button>"
	content += "</div>"
	content += "</div>"

	// Display self notes
	if(!length(self_notes))
		content += "<div class='no-data'>"
		content += "You haven't written any notes about yourself yet."
		content += "</div>"
	else
		for(var/note_title in self_notes)
			var/list/note_data = self_notes[note_title]
			content += "<div class='note-item'>"
			content += "<div class='note-header'>"
			content += "<div class='note-title'>[format_ui_text(note_title)]</div>"
			content += "<div class='note-buttons'>"
			content += "<a href='?src=[REF(src)];task=edit_self_note;note_title=[url_encode(note_title)];tab=notes' class='note-btn' onclick='event.stopPropagation()'>Edit</a>"
			content += "<a href='?src=[REF(src)];task=remove_self_note;note_title=[url_encode(note_title)];tab=notes' class='note-btn remove-btn' onclick='event.stopPropagation()'>Remove</a>"
			content += "</div>"
			content += "</div>"
			content += "<div class='note-content'>[format_ui_multiline_text(note_data["content"])]</div>"
			var/created_time = note_data["created"]
			var/modified_time = note_data["last_modified"]
			var/time_text = "Created: [time2text(created_time, "MM/DD/YY hh:mm")]"
			if(modified_time != created_time)
				time_text += " | Modified: [time2text(modified_time, "MM/DD/YY hh:mm")]"
			content += "<div class='note-meta'>[format_ui_text(time_text)]</div>"
			content += "</div>"

	content += "</div>" // End self notes content

	// Target's self-notes content (initially hidden)
	content += "<div class='notes-tab-content' id='targetNotesContent'>"
	content += "<div class='panel-header'>"
	content += "<h3>[format_ui_text(target.name)]'s Notes (About Themselves)</h3>"
	content += "</div>"

	// Display target's self-notes (read-only)
	if(!length(target_self_notes))
		content += "<div class='no-data'>"
		content += "[format_ui_text(target.name)] hasn't shared any notes about themselves yet."
		content += "</div>"
	else
		for(var/note_title in target_self_notes)
			var/list/note_data = target_self_notes[note_title]
			content += "<div class='note-item'>"
			content += "<div class='note-header'>"
			content += "<div class='note-title'>[format_ui_text(note_title)]</div>"
			content += "</div>"
			content += "<div class='note-content'>[format_ui_multiline_text(note_data["content"])]</div>"
			var/created_time = note_data["created"]
			var/modified_time = note_data["last_modified"]
			var/time_text = "Created: [time2text(created_time, "MM/DD/YY hh:mm")]"
			if(modified_time != created_time)
				time_text += " | Modified: [time2text(modified_time, "MM/DD/YY hh:mm")]"
			content += "<div class='note-meta'>[format_ui_text(time_text)]</div>"
			content += "</div>"

	content += "</div>" // End target notes content

	return content.Join("")

/datum/sex_session/proc/get_current_speed()
	return speed || SEX_SPEED_LOW

/datum/sex_session/proc/get_current_force()
	return force || SEX_FORCE_LOW

/datum/sex_session/proc/get_current_resist()
	return resistance_to_pleasure || RESIST_NONE

/datum/sex_session/proc/set_current_speed(new_speed)
	speed = clamp(new_speed, SEX_SPEED_MIN, SEX_SPEED_MAX)

/datum/sex_session/proc/set_current_force(new_force)
	force = clamp(new_force, SEX_FORCE_MIN, SEX_FORCE_MAX)

/datum/sex_session/proc/set_current_resist(new_resist)
	resistance_to_pleasure = clamp(new_resist, RESIST_NONE, RESIST_HIGH)
	SEND_SIGNAL(user, COMSIG_SEX_SET_HOLDING, resistance_to_pleasure)

/datum/sex_session/proc/adjust_arousal_manual(amt)
	manual_arousal = clamp(manual_arousal + amt, SEX_MANUAL_AROUSAL_MIN, SEX_MANUAL_AROUSAL_MAX)
	var/aroused = manual_arousal > 2
	SEND_SIGNAL(user, COMSIG_SET_ERECT_STATE, aroused)

/datum/sex_session/proc/get_character_slot(mob/target_mob)
	return target_mob?.client?.prefs.current_slot || 1

/proc/get_player_notes_about(viewer_ckey, target_ckey, character_slot = 1)
	var/datum/save_manager/SM = get_save_manager(viewer_ckey)
	if(!SM)
		return list()

	var/save_name = "character_[character_slot]_notes"
	var/list/all_notes = SM.get_data(save_name, "partner_notes", list())

	return all_notes[ckey(target_ckey)] || list()

/proc/set_player_note_about(writer_ckey, target_ckey, note_title, note_content, character_slot = 1)
	var/datum/save_manager/SM = get_save_manager(writer_ckey)
	if(!SM)
		return FALSE

	var/save_name = "character_[character_slot]_notes"
	var/list/all_notes = SM.get_data(save_name, "partner_notes", list())

	if(!all_notes[ckey(target_ckey)])
		all_notes[ckey(target_ckey)] = list()

	all_notes[ckey(target_ckey)][note_title] = list(
		"content" = note_content,
		"created" = world.realtime,
		"last_modified" = world.realtime
	)

	return SM.set_data(save_name, "partner_notes", all_notes)



