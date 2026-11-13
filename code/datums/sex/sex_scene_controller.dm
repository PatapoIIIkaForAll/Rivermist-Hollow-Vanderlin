/datum/sex_action_effect_context
	var/mob/living/receiver
	var/mob/living/partner
	var/datum/sex_action/action
	var/mob/living/action_initiator
	var/mob/living/action_target
	var/mob/living/action_performer
	var/giving = TRUE
	var/arousal_amt = 0
	var/pain_amt = 0
	var/orgasm_prog_amt = 0
	var/force = SEX_FORCE_MID
	var/speed = SEX_SPEED_MID
	var/resistance = RESIST_NONE
	var/climax_type = null
	var/mob/living/climaxer
	var/atom/climax_destination
	var/climax_method = null
	/// TRUE for a later spurt of a climax already announced, so catchers stay quiet and nothing counts twice.
	var/climax_follow_up = FALSE

/datum/sex_action_effect_context/New(mob/living/_receiver, mob/living/_partner, datum/sex_action/_action, mob/living/_action_initiator, mob/living/_action_target, _giving = TRUE)
	receiver = _receiver
	partner = _partner
	action = _action
	action_initiator = _action_initiator
	action_target = _action_target
	giving = _giving

/datum/sex_action_effect
	var/obj/item/source_item

/datum/sex_action_effect/New(obj/item/_source_item)
	source_item = _source_item

/datum/sex_action_effect/proc/modify_action(datum/sex_action_effect_context/context)
	return

/datum/sex_action_effect/proc/after_action(datum/sex_action_effect_context/context)
	return

/datum/sex_action_effect/proc/intercept_climax(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	return 0

/obj/item/proc/get_sex_action_effects(datum/sex_action_effect_context/context)
	return null

/proc/collect_sex_action_effects(datum/sex_action_effect_context/context)
	var/list/effects = list()
	if(!context)
		return effects
	var/list/seen_items = list()
	collect_sex_action_effects_from_mob(context.action_initiator, context, effects, seen_items)
	collect_sex_action_effects_from_mob(context.action_target, context, effects, seen_items)
	return effects

/proc/collect_sex_action_effects_from_mob(mob/living/effect_mob, datum/sex_action_effect_context/context, list/effects, list/seen_items)
	if(!ishuman(effect_mob))
		return
	var/mob/living/carbon/human/human = effect_mob
	var/static/list/effect_slots = list(
		ORGAN_SLOT_PENIS,
		ORGAN_SLOT_VAGINA,
		ORGAN_SLOT_ANUS,
		ORGAN_SLOT_LEFT_NIP,
		ORGAN_SLOT_RIGHT_NIP,
		ORGAN_SLOT_BREASTS,
	)
	for(var/slot in effect_slots)
		var/obj/item/organ/organ = human.getorganslot(slot)
		if(!organ)
			continue
		// The organ itself may answer, such as an opening stretched around what is in it.
		var/list/organ_effects = organ.get_sex_action_effects(context)
		if(length(organ_effects))
			effects += organ_effects
		var/list/stored_items = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_GET_2D_ITEM_LIST)
		if(!length(stored_items))
			continue
		for(var/obj/item/stored_item as anything in stored_items)
			if(!stored_item || (stored_item in seen_items))
				continue
			seen_items += stored_item
			var/list/item_effects = stored_item.get_sex_action_effects(context)
			if(length(item_effects))
				effects += item_effects
	// Worn underwear, such as a chastity device, joins in as well.
	var/obj/item/worn_underwear = human.underwear
	if(worn_underwear && !(worn_underwear in seen_items))
		seen_items += worn_underwear
		var/list/underwear_effects = worn_underwear.get_sex_action_effects(context)
		if(length(underwear_effects))
			effects += underwear_effects

/proc/qdel_sex_action_effects(list/effects)
	for(var/datum/sex_action_effect/effect as anything in effects)
		qdel(effect)

/proc/apply_sex_action_climax_effects(mob/living/climaxer, mob/living/target, datum/sex_action/action, climax_type, datum/reagents/source_reagents, amount, atom/climax_destination, climax_method, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer, follow_up = FALSE)
	// Succubus essence harvest: a partner's climax feeds a succubus once, not once per spurt.
	if(target && climaxer != target && !follow_up)
		var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(target)
		if(succubus_antag)
			var/was_virgin_at_action_start = action?.was_participant_virgin_at_start(climaxer)
			succubus_antag.harvest_from_climax(climaxer, was_virgin_at_action_start)
	if(!source_reagents || amount <= 0)
		return amount
	var/datum/sex_action_effect_context/context = new(climaxer, target, action, action_initiator ? action_initiator : climaxer, action_target ? action_target : target, TRUE)
	context.climaxer = climaxer
	context.climax_type = climax_type
	context.climax_destination = climax_destination
	context.climax_method = climax_method
	context.climax_follow_up = follow_up
	context.action_performer = action_performer
	var/list/effects = collect_sex_action_effects(context)
	var/remaining = amount
	for(var/datum/sex_action_effect/effect as anything in effects)
		if(remaining <= 0)
			break
		var/consumed = effect.intercept_climax(context, source_reagents, remaining)
		remaining = max(0, remaining - max(consumed, 0))
	qdel_sex_action_effects(effects)
	return remaining

/// Actor-owned controls and TGUI state for a shared sex scene.
/datum/sex_scene_controller
	/// The initiating user
	var/mob/living/user
	/// Target of our actions
	var/mob/living/target
	/// Participant currently selected in this scene-facing UI.
	var/mob/living/ui_selected_participant
	/// Participants this actor explicitly connected to while using the scene.
	var/list/mob/living/linked_participants = list()
	/// Shared multi-participant scene this actor controls.
	var/datum/sex_scene/scene
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

	/// Level of pleasure resistance
	var/resistance_to_pleasure = RESIST_NONE
	/// Level of edging others
	var/edging_other = FALSE
	/// TRUE when this actor pulls their cock out to climax over the partner.
	var/finish_outside = FALSE
	/// TRUE when this actor, lying down, locks their legs around whoever is inside them.
	var/leg_lock = FALSE

	var/static/list/action_zone_filter_options = list(
		"Any" = SEX_UI_ZONE_ANY,
		"Mouth" = SEX_UI_ZONE_MOUTH,
		"Genitals" = SEX_UI_ZONE_GENITALS,
		"Arms" = SEX_UI_ZONE_ARMS,
		"Legs" = SEX_UI_ZONE_LEGS,
		"Body" = SEX_UI_ZONE_BODY,
		"Misc" = SEX_UI_ZONE_MISC,
	)

/datum/sex_scene_controller/New(mob/living/controller_user, mob/living/initial_target)
	user = controller_user
	target = initial_target
	ui_selected_participant = target
	linked_participants |= target
	var/datum/sex_scene/shared_scene = get_or_create_sex_scene(user, target)
	if(!shared_scene || !shared_scene.add_controller(src))
		scene = null
		return
	RegisterSignal(user, COMSIG_SEX_AROUSAL_CHANGED, PROC_REF(on_arousal_changed))
	RegisterSignal(user, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_participant_invalidated))

	addtimer(CALLBACK(src, PROC_REF(check_inactivity)), 30 SECONDS)

/datum/sex_scene_controller/Destroy(force, ...)
	if(user)
		UnregisterSignal(user, list(COMSIG_SEX_AROUSAL_CHANGED, COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	if(scene && !QDELETED(scene))
		scene.remove_controller(src)
	scene = null

	user = null
	target = null
	ui_selected_participant = null
	linked_participants = null
	. = ..()

/datum/sex_scene_controller/proc/set_target(mob/living/new_target)
	if(!new_target || QDELETED(new_target) || !scene || !(new_target in scene.participants))
		return FALSE
	target = new_target
	ui_selected_participant = new_target
	if(!(new_target in linked_participants))
		linked_participants |= new_target
	return TRUE

/datum/sex_scene_controller/proc/unlink_participant(mob/living/participant)
	if(!participant || participant == user || !(participant in linked_participants))
		return FALSE
	linked_participants -= participant
	if(target == participant)
		target = user
		ui_selected_participant = user
	scene?.reconcile_membership()
	return TRUE

/datum/sex_scene_controller/proc/check_inactivity()
	if(length(get_active_actions()) || is_ui_open())
		inactivity--
		inactivity = CLAMP(inactivity, 0, 11)
		addtimer(CALLBACK(src, PROC_REF(check_inactivity)), 30 SECONDS)
		return

	inactivity++

	if(inactivity < 5)
		addtimer(CALLBACK(src, PROC_REF(check_inactivity)), 30 SECONDS)
		return
	qdel(src)

/datum/sex_scene_controller/proc/on_participant_invalidated()
	SIGNAL_HANDLER
	qdel(src)

/datum/sex_scene_controller/proc/is_ui_open()
	if(!user?.client)
		return FALSE
	return !!SStgui.get_open_ui(user, src)

/datum/sex_scene_controller/proc/show_ui()
	if(!user?.client)
		return
	ui_interact(user)

/datum/sex_scene_controller/proc/on_arousal_changed()
	SIGNAL_HANDLER
	SStgui.update_uis(src)

/datum/sex_scene_controller/proc/get_active_action(action_ref)
	var/list/datum/sex_action/controlled_actions = get_active_actions()
	if(istype(action_ref, /datum/sex_action))
		var/datum/sex_action/action = action_ref
		if(action in controlled_actions)
			return action
		action_ref = action.get_menu_action_key()

	var/action_key = get_action_key(action_ref)
	for(var/datum/sex_action/action as anything in controlled_actions)
		if(action_key && action.get_menu_action_key() == action_key)
			return action
		if(ispath(action_ref, /datum/sex_action) && action.type == action_ref)
			return action
	return null

/datum/sex_scene_controller/proc/get_active_actions()
	var/list/actions = list()
	for(var/datum/sex_action/action as anything in scene?.active_actions)
		if(action.action_user == user && action.action_target == target)
			actions += action
	return actions

/datum/sex_scene_controller/proc/is_action_active(action_type)
	return !isnull(get_active_action(action_type))

/datum/sex_scene_controller/proc/try_start_action(action_type, source = "player")
	if(is_action_active(action_type))
		try_stop_action(action_type)
		return
	var/datum/sex_action_proposal/proposal = create_action_proposal(action_type, source)
	var/datum/sex_action/action = proposal?.accept()
	if(!action && proposal?.action?.armor_refusal)
		to_chat(user, span_warning(proposal.action.armor_refusal))
	qdel(proposal)
	return action

/datum/sex_scene_controller/proc/create_action_proposal(action_ref, source = "system")
	return new /datum/sex_action_proposal(src, action_ref, source)

/datum/sex_scene_controller/proc/try_stop_action(action_ref)
	if(!length(get_active_actions()))
		return
	if(!action_ref)
		stop_action()
		return

	var/datum/sex_action/action = get_active_action(action_ref)
	if(action)
		stop_action(action)

/datum/sex_scene_controller/proc/stop_action(action_ref)
	var/list/datum/sex_action/controlled_actions = get_active_actions()
	if(!length(controlled_actions))
		return
	if(!action_ref)
		for(var/datum/sex_action/action as anything in controlled_actions)
			stop_action(action)
		return

	var/datum/sex_action/action = get_active_action(action_ref)
	if(!action)
		return
	scene?.stop_action(action)

/datum/sex_scene_controller/proc/set_remote_context(datum/sex_remote_context/context)
	return scene?.add_remote_context(context)

/datum/sex_scene_controller/proc/clear_remote_context()
	var/datum/sex_remote_context/context = scene?.get_remote_context(user, target, null)
	if(context)
		qdel(context)

/datum/sex_scene_controller/proc/get_bellyriding_component()
	if(!user || !target)
		return null
	var/datum/component/bellyriding/belly_comp = user.GetComponent(/datum/component/bellyriding)
	if(belly_comp && belly_comp.current_victim == target)
		return belly_comp
	belly_comp = target.GetComponent(/datum/component/bellyriding)
	if(belly_comp && belly_comp.current_victim == user)
		return belly_comp
	return null

/// Every action this actor runs, unlike get_active_actions() which is scoped to the selected target.
/datum/sex_scene_controller/proc/get_owned_actions()
	var/list/actions = list()
	for(var/datum/sex_action/action as anything in scene?.active_actions)
		if(action.action_user == user)
			actions += action
	return actions

/datum/sex_scene_controller/proc/set_current_speed(new_speed)
	speed = clamp(new_speed, SEX_SPEED_MIN, SEX_SPEED_MAX)
	for(var/datum/sex_action/action as anything in get_owned_actions())
		action.speed = speed

/datum/sex_scene_controller/proc/set_current_force(new_force)
	force = clamp(new_force, SEX_FORCE_MIN, SEX_FORCE_MAX)
	for(var/datum/sex_action/action as anything in get_owned_actions())
		action.force = force

/datum/sex_scene_controller/proc/set_stop_on_climax(stop_on_climax)
	do_until_finished = !!stop_on_climax
	for(var/datum/sex_action/action as anything in get_active_actions())
		action.stop_on_climax = do_until_finished

/datum/sex_scene_controller/proc/set_current_resist(new_resist)
	resistance_to_pleasure = clamp(new_resist, RESIST_NONE, RESIST_HIGH)
	SEND_SIGNAL(user, COMSIG_SEX_SET_HOLDING, resistance_to_pleasure)

/datum/sex_scene_controller/proc/get_character_slot(mob/target_mob)
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



