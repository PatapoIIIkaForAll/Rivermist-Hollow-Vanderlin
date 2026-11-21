/// One participant's occupied role within a running action.
/datum/sex_scene_role
	var/datum/sex_action/action
	var/mob/living/participant
	var/mob/living/counterpart
	var/interaction
	var/role
	var/body_slot

/datum/sex_scene_role/New(datum/sex_action/action, mob/living/participant, mob/living/counterpart, interaction, role, body_slot)
	src.action = action
	src.participant = participant
	src.counterpart = counterpart
	src.interaction = interaction
	src.role = role
	src.body_slot = body_slot

/datum/sex_scene_role/Destroy(force, ...)
	action = null
	participant = null
	counterpart = null
	return ..()

/// A declarative role requirement used by a multi-action pattern.
/datum/sex_scene_pattern_requirement
	var/interaction
	var/role
	var/list/body_slots

/datum/sex_scene_pattern_requirement/New(interaction, role, list/body_slots)
	src.interaction = interaction
	src.role = role
	src.body_slots = body_slots ? body_slots.Copy() : list()

/datum/sex_scene_pattern_requirement/Destroy(force, ...)
	body_slots = null
	return ..()

/datum/sex_scene_pattern_requirement/proc/matches(datum/sex_scene_role/scene_role)
	if(!scene_role || QDELETED(scene_role))
		return FALSE
	if(interaction && scene_role.interaction != interaction)
		return FALSE
	if(role && scene_role.role != role)
		return FALSE
	if(length(body_slots) && !(scene_role.body_slot in body_slots))
		return FALSE
	return TRUE

/// Declarative definition for a recognized combination of simultaneous actions.
/datum/sex_scene_pattern
	abstract_type = /datum/sex_scene_pattern
	var/pattern_id
	var/display_name
	var/list/datum/sex_scene_pattern_requirement/requirements
	var/require_distinct_actions = TRUE
	var/min_distinct_counterparts = 1
	/// Extra selection weight given to an AI action which completes this pattern.
	var/ai_desirability = 0
	/// Final pleasure multipliers applied while this pattern is active.
	var/focus_pleasure_multiplier = 1
	var/participant_pleasure_multiplier = 1
	/// Stress events applied when somebody climaxes during this pattern.
	var/focus_climax_stress_event
	var/participant_climax_stress_event

/datum/sex_scene_pattern/New()
	requirements = list()

/datum/sex_scene_pattern/Destroy(force, ...)
	for(var/datum/sex_scene_pattern_requirement/requirement as anything in requirements)
		qdel(requirement)
	requirements = null
	return ..()

/datum/sex_scene_pattern/proc/find_matches(datum/sex_scene/scene)
	if(!scene || QDELETED(scene) || !length(requirements))
		return list()
	return find_matches_in_roles(scene.participants, scene.roles)

/datum/sex_scene_pattern/proc/find_matches_in_roles(list/participants, list/available_roles)
	var/list/matches = list()
	if(!length(participants) || !length(available_roles) || !length(requirements))
		return matches

	for(var/mob/living/focus as anything in participants)
		if(!focus || QDELETED(focus))
			continue
		var/list/selected_roles = list()
		collect_matches(participants, available_roles, focus, 1, selected_roles, matches)
	return matches

/datum/sex_scene_pattern/proc/collect_matches(list/participants, list/available_roles, mob/living/focus, requirement_index, list/selected_roles, list/matches)
	if(requirement_index > length(requirements))
		var/list/counterparts = list()
		for(var/datum/sex_scene_role/selected_role as anything in selected_roles)
			counterparts |= selected_role.counterpart
		if(length(counterparts) < min_distinct_counterparts)
			return
		matches += new /datum/sex_scene_pattern_match(src, focus, selected_roles)
		return

	var/datum/sex_scene_pattern_requirement/requirement = requirements[requirement_index]
	for(var/datum/sex_scene_role/scene_role as anything in available_roles)
		if(scene_role.participant != focus || !requirement.matches(scene_role))
			continue
		if(!scene_role.counterpart || QDELETED(scene_role.counterpart) || !(scene_role.counterpart in participants))
			continue
		if(require_distinct_actions)
			var/action_already_selected = FALSE
			for(var/datum/sex_scene_role/selected_role as anything in selected_roles)
				if(selected_role.action == scene_role.action)
					action_already_selected = TRUE
					break
			if(action_already_selected)
				continue

		selected_roles += scene_role
		collect_matches(participants, available_roles, focus, requirement_index + 1, selected_roles, matches)
		selected_roles.Cut(length(selected_roles), length(selected_roles) + 1)

/datum/sex_scene_pattern/proc/get_start_message(datum/sex_scene_pattern_match/pattern_match)
	return

/datum/sex_scene_pattern/proc/get_end_message(datum/sex_scene_pattern_match/pattern_match)
	return

/datum/sex_scene_pattern/proc/get_climax_message(datum/sex_scene_pattern_match/pattern_match, mob/living/climaxer)
	return

/datum/sex_scene_pattern/proc/modify_action_effect(datum/sex_scene_pattern_match/pattern_match, datum/sex_action_effect_context/context)
	if(!pattern_match || !context || !(context.receiver in pattern_match.participants))
		return
	var/pleasure_multiplier = context.receiver == pattern_match.focus ? focus_pleasure_multiplier : participant_pleasure_multiplier
	context.arousal_amt *= pleasure_multiplier
	context.orgasm_prog_amt *= pleasure_multiplier

/datum/sex_scene_pattern/proc/get_climax_stress_event(datum/sex_scene_pattern_match/pattern_match, mob/living/climaxer)
	if(!pattern_match || !(climaxer in pattern_match.participants))
		return null
	return climaxer == pattern_match.focus ? focus_climax_stress_event : participant_climax_stress_event

/datum/sex_scene_pattern/proc/apply_climax_stress(datum/sex_scene_pattern_match/pattern_match, mob/living/climaxer)
	var/stress_event = get_climax_stress_event(pattern_match, climaxer)
	if(stress_event)
		climaxer.add_stress(stress_event)

/datum/sex_scene_pattern/airtight
	pattern_id = SEX_SCENE_PATTERN_AIRTIGHT
	display_name = "Airtight"
	min_distinct_counterparts = 3
	ai_desirability = 8
	focus_pleasure_multiplier = 2
	participant_pleasure_multiplier = 1.1
	focus_climax_stress_event = /datum/stress_event/sex_scene_airtight/focus
	participant_climax_stress_event = /datum/stress_event/sex_scene_airtight/participant

/datum/sex_scene_pattern/airtight/New()
	. = ..()
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_ORAL,
		SEX_SCENE_ROLE_GIVER,
		list(BODY_ZONE_PRECISE_MOUTH),
	)
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_PENETRATION,
		SEX_SCENE_ROLE_RECEIVER,
		list(ORGAN_SLOT_VAGINA),
	)
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_PENETRATION,
		SEX_SCENE_ROLE_RECEIVER,
		list(ORGAN_SLOT_ANUS),
	)

/datum/sex_scene_pattern/airtight/get_start_message(datum/sex_scene_pattern_match/pattern_match)
	if(length(pattern_match?.counterparts) < 3)
		return
	return "[pattern_match.focus] is held airtight between [pattern_match.counterparts[1]], [pattern_match.counterparts[2]], and [pattern_match.counterparts[3]]!"

/datum/sex_scene_pattern/airtight/get_end_message(datum/sex_scene_pattern_match/pattern_match)
	if(!pattern_match?.focus)
		return
	return "The airtight arrangement around [pattern_match.focus] breaks apart."

/datum/sex_scene_pattern/airtight/get_climax_message(datum/sex_scene_pattern_match/pattern_match, mob/living/climaxer)
	if(!pattern_match?.focus || !climaxer)
		return
	if(climaxer == pattern_match.focus)
		return "[climaxer] climaxes while completely filled in the middle of the airtight arrangement!"
	return "[climaxer] climaxes as part of the airtight arrangement around [pattern_match.focus]!"

/datum/sex_scene_pattern/double_penetration
	pattern_id = SEX_SCENE_PATTERN_DOUBLE_PENETRATION
	display_name = "Double penetration"
	min_distinct_counterparts = 2
	ai_desirability = 6
	focus_pleasure_multiplier = 1.2
	participant_pleasure_multiplier = 1.05
	focus_climax_stress_event = /datum/stress_event/sex_scene_double_penetration/focus
	participant_climax_stress_event = /datum/stress_event/sex_scene_double_penetration/participant

/datum/sex_scene_pattern/double_penetration/New()
	. = ..()
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_PENETRATION,
		SEX_SCENE_ROLE_RECEIVER,
		list(ORGAN_SLOT_VAGINA),
	)
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_PENETRATION,
		SEX_SCENE_ROLE_RECEIVER,
		list(ORGAN_SLOT_ANUS),
	)

/datum/sex_scene_pattern/double_penetration/get_start_message(datum/sex_scene_pattern_match/pattern_match)
	if(length(pattern_match?.counterparts) < 2)
		return
	return "[pattern_match.focus] is taken by [pattern_match.counterparts[1]] and [pattern_match.counterparts[2]] in a double penetration!"

/datum/sex_scene_pattern/double_penetration/get_end_message(datum/sex_scene_pattern_match/pattern_match)
	if(!pattern_match?.focus)
		return
	return "The double penetration of [pattern_match.focus] breaks apart."

/datum/sex_scene_pattern/double_penetration/get_climax_message(datum/sex_scene_pattern_match/pattern_match, mob/living/climaxer)
	if(!pattern_match?.focus || !climaxer)
		return
	if(climaxer == pattern_match.focus)
		return "[climaxer] climaxes between both partners during the double penetration!"
	return "[climaxer] climaxes during the double penetration of [pattern_match.focus]!"

/datum/sex_scene_pattern/spitroast
	pattern_id = SEX_SCENE_PATTERN_SPITROAST
	display_name = "Spit-roasting"
	min_distinct_counterparts = 2
	ai_desirability = 4
	focus_pleasure_multiplier = 1.15
	participant_pleasure_multiplier = 1.05
	focus_climax_stress_event = /datum/stress_event/sex_scene_spitroast/focus
	participant_climax_stress_event = /datum/stress_event/sex_scene_spitroast/participant

/datum/sex_scene_pattern/spitroast/New()
	. = ..()
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_ORAL,
		SEX_SCENE_ROLE_GIVER,
		list(BODY_ZONE_PRECISE_MOUTH),
	)
	requirements += new /datum/sex_scene_pattern_requirement(
		SEX_SCENE_INTERACTION_PENETRATION,
		SEX_SCENE_ROLE_RECEIVER,
		list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS),
	)

/datum/sex_scene_pattern/spitroast/get_start_message(datum/sex_scene_pattern_match/pattern_match)
	if(length(pattern_match?.counterparts) < 2)
		return
	return "[pattern_match.focus] is caught between [pattern_match.counterparts[1]] and [pattern_match.counterparts[2]] in a spit-roast!"

/datum/sex_scene_pattern/spitroast/get_end_message(datum/sex_scene_pattern_match/pattern_match)
	if(!pattern_match?.focus)
		return
	return "The spit-roast around [pattern_match.focus] breaks apart."

/datum/sex_scene_pattern/spitroast/get_climax_message(datum/sex_scene_pattern_match/pattern_match, mob/living/climaxer)
	if(!pattern_match?.focus || !climaxer)
		return
	if(climaxer == pattern_match.focus && length(pattern_match.counterparts) >= 2)
		return "[climaxer] climaxes between [pattern_match.counterparts[1]] and [pattern_match.counterparts[2]] in the middle of the spit-roast!"
	return "[climaxer] climaxes while spit-roasting [pattern_match.focus]!"

/// One concrete pattern occurrence centered on a particular participant.
/datum/sex_scene_pattern_match
	var/datum/sex_scene_pattern/pattern
	var/pattern_id
	var/display_name
	var/match_key
	var/mob/living/focus
	var/list/datum/sex_action/actions
	var/list/mob/living/participants
	/// Requirement-ordered partners, used by pattern-owned presentation.
	var/list/mob/living/counterparts

/datum/sex_scene_pattern_match/New(datum/sex_scene_pattern/pattern, mob/living/focus, list/selected_roles)
	src.pattern = pattern
	pattern_id = pattern.pattern_id
	display_name = pattern.display_name
	src.focus = focus
	actions = list()
	participants = list(focus)
	counterparts = list()

	var/list/action_refs = list()
	for(var/datum/sex_scene_role/scene_role as anything in selected_roles)
		actions |= scene_role.action
		participants |= scene_role.counterpart
		counterparts += scene_role.counterpart
		action_refs += REF(scene_role.action)
	match_key = "[pattern_id]:[REF(focus)]:[jointext(action_refs, ":")]"

/datum/sex_scene_pattern_match/Destroy(force, ...)
	pattern = null
	focus = null
	actions = null
	participants = null
	counterparts = null
	return ..()

/// One fully-contextualized request to start an action.
///
/// Player UI and AI both build these proposals, validate the same prepared
/// action, and hand that exact instance to the runtime when accepted.
/datum/sex_action_proposal
	var/datum/sex_scene_controller/controller
	var/datum/sex_scene/scene
	var/datum/sex_action/action
	var/source
	var/accepted = FALSE

/datum/sex_action_proposal/New(datum/sex_scene_controller/controller, action_ref, proposal_source = "system")
	. = ..()
	src.controller = controller
	scene = controller?.scene
	source = proposal_source
	if(!controller || QDELETED(controller) || !scene || QDELETED(scene))
		return
	action = controller.instantiate_action(action_ref)
	if(action && !action.prepare_proposal(controller))
		qdel(action)
		action = null

/datum/sex_action_proposal/Destroy(force, ...)
	if(action && !accepted)
		qdel(action)
	action = null
	controller = null
	scene = null
	return ..()

/datum/sex_action_proposal/proc/can_start()
	if(!action || QDELETED(action) || !controller || QDELETED(controller))
		return FALSE
	return action.can_run()

/datum/sex_action_proposal/proc/get_pattern_desirability()
	if(!action || !scene || QDELETED(scene))
		return 0
	return scene.get_action_pattern_desirability(action, action.action_user, action.action_target)

/datum/sex_action_proposal/proc/accept()
	if(accepted || !can_start())
		return null
	if(!action.bind_runtime(controller))
		return null

	accepted = TRUE
	var/datum/sex_action/accepted_action = action
	action = null
	controller.inactivity = 0
	log_combat(accepted_action.action_user, accepted_action.action_target, "Started sex action: [accepted_action.name] with [accepted_action.action_target.name].")
	accepted_action.start_runtime()
	return accepted_action

/// A shared interaction context directly bound to every participating mob.
///
/// Runtime actions own their loops while the scene owns their shared graph.
/datum/sex_scene
	var/static/next_scene_id = 1
	/// Stable runtime identity used by scene-owned presentation.
	var/scene_id
	/// CSS span attached to speech from participants in this scene.
	var/speech_span_class
	/// Human-readable participant list for UI and future chat presentation.
	var/display_name
	var/list/mob/living/participants
	/// One scene controller per actor; partners are selected within it.
	var/list/datum/sex_scene_controller/controllers
	/// Runtime actions currently taking place anywhere in this scene.
	var/list/datum/sex_action/active_actions
	/// Body slots and items claimed by runtime actions in this scene.
	var/list/datum/sex_scene_resource_claim/resource_claims
	/// Optional remote-interaction grants indexed by their participant pair.
	var/list/datum/sex_remote_context/remote_contexts
	/// Occupied participant roles derived from the active actions.
	var/list/datum/sex_scene_role/roles
	/// Declarative pattern definitions evaluated when the action graph changes.
	var/list/datum/sex_scene_pattern/pattern_definitions
	/// Active pattern matches, keyed by their stable match key.
	var/list/active_patterns
	var/recomputing_patterns = FALSE
	var/pattern_refresh_pending = FALSE
	var/reconciling_membership = FALSE

/datum/sex_scene/New()
	scene_id = next_scene_id
	next_scene_id++
	speech_span_class = "sex_scene_[scene_id]"
	participants = list()
	controllers = list()
	active_actions = list()
	resource_claims = list()
	remote_contexts = list()
	roles = list()
	pattern_definitions = list(
		new /datum/sex_scene_pattern/airtight(),
		new /datum/sex_scene_pattern/double_penetration(),
		new /datum/sex_scene_pattern/spitroast(),
	)
	active_patterns = list()
	update_display_name()

/datum/sex_scene/Destroy(force, ...)
	for(var/pattern_key in active_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		qdel(pattern_match)
	active_patterns.Cut()
	active_patterns = null

	for(var/datum/sex_scene_pattern/pattern as anything in pattern_definitions)
		qdel(pattern)
	pattern_definitions = null

	for(var/datum/sex_scene_role/scene_role as anything in roles)
		qdel(scene_role)
	roles = null

	for(var/mob/living/participant as anything in participants)
		UnregisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
		if(participant.sex_scene == src)
			participant.sex_scene = null
	participants.Cut()
	participants = null

	for(var/datum/sex_scene_controller/controller as anything in controllers)
		if(controller.scene == src)
			controller.scene = null
		qdel(controller)
	controllers.Cut()
	controllers = null

	for(var/datum/sex_action/action as anything in active_actions)
		if(action.scene == src)
			action.scene = null
		qdel(action)
	active_actions.Cut()
	active_actions = null

	for(var/datum/sex_scene_resource_claim/claim as anything in resource_claims)
		if(claim.scene == src)
			claim.scene = null
	resource_claims.Cut()
	resource_claims = null

	for(var/datum/sex_remote_context/context as anything in remote_contexts)
		if(context.scene == src)
			context.scene = null
		qdel(context)
	remote_contexts.Cut()
	remote_contexts = null

	scene_id = null
	speech_span_class = null
	display_name = null
	return ..()

/datum/sex_scene/proc/update_display_name()
	var/list/participant_names = list()
	for(var/mob/living/participant as anything in participants)
		if(!participant || QDELETED(participant))
			continue
		var/participant_name = participant.name
		if(ishuman(participant))
			var/mob/living/carbon/human/human_participant = participant
			participant_name = human_participant.get_face_name() || participant.name
		participant_names += participant_name
	display_name = jointext(participant_names, " & ")

/datum/sex_scene/proc/add_participant(mob/living/participant)
	if(!participant || QDELETED(participant))
		return FALSE
	if(participant.sex_scene == src)
		participants |= participant
		return TRUE

	var/datum/sex_scene/existing_scene = participant.sex_scene
	if(existing_scene && !QDELETED(existing_scene))
		if(!merge_scene(existing_scene, participant))
			return FALSE
		if(participant.sex_scene == src)
			return TRUE

	var/list/prospective_participants = participants.Copy()
	prospective_participants |= participant
	if(!can_include_participants(prospective_participants, participant))
		return FALSE

	participants |= participant
	participant.sex_scene = src
	RegisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_participant_invalidated))
	update_display_name()
	if(length(GLOB.sense_relay_mobs))
		ensure_dullahan_head_contexts(src)
	return TRUE

/datum/sex_scene/proc/remove_participant(mob/living/participant)
	if(!participant || !(participant in participants))
		return FALSE

	reconciling_membership = TRUE
	var/list/controllers_to_remove = get_controllers_involving(participant)
	for(var/datum/sex_scene_controller/controller as anything in controllers_to_remove)
		if(controller.user == participant)
			qdel(controller)
		else
			controller.unlink_participant(participant)
	var/list/actions_to_remove = get_actions_involving(participant)
	for(var/datum/sex_action/action as anything in actions_to_remove)
		stop_action(action)
	var/list/contexts_to_remove = remote_contexts.Copy()
	for(var/datum/sex_remote_context/context as anything in contexts_to_remove)
		if(context.get_caster() == participant || context.get_target() == participant)
			qdel(context)
	detach_participant(participant)
	reconciling_membership = FALSE
	reconcile_membership()
	return TRUE

/datum/sex_scene/proc/detach_participant(mob/living/participant)
	if(!participant || !(participant in participants))
		return FALSE
	UnregisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	participants -= participant
	if(participant.sex_scene == src)
		participant.sex_scene = null

	update_display_name()
	recompute_patterns()
	return TRUE

/datum/sex_scene/proc/can_include_participants(list/prospective_participants, mob/living/explicit_joiner)
	if(length(prospective_participants) > SEX_SCENE_MAX_PARTICIPANTS)
		return FALSE
	if(length(prospective_participants) <= 2)
		return TRUE
	for(var/mob/living/participant as anything in prospective_participants)
		if(!participant || QDELETED(participant))
			return FALSE
		if(participant == explicit_joiner)
			continue
	return TRUE

/datum/sex_scene/proc/add_controller(datum/sex_scene_controller/controller)
	if(!controller || QDELETED(controller))
		return FALSE
	if(get_controller(controller.user) && get_controller(controller.user) != controller)
		return FALSE
	if(!(controller.user in participants) || controller.user.sex_scene != src)
		return FALSE
	for(var/mob/living/linked_participant as anything in controller.linked_participants)
		if(!(linked_participant in participants) || linked_participant.sex_scene != src)
			return FALSE

	controllers |= controller
	controller.scene = src
	return TRUE

/datum/sex_scene/proc/remove_controller(datum/sex_scene_controller/controller)
	if(!controller || !(controller in controllers))
		return FALSE

	controllers -= controller
	if(controller.scene == src)
		controller.scene = null
	if(!reconciling_membership)
		reconcile_membership()
	return TRUE

/datum/sex_scene/proc/reconcile_membership()
	if(reconciling_membership || QDELETED(src))
		return
	reconciling_membership = TRUE

	var/list/referenced_participants = list()
	for(var/datum/sex_scene_controller/controller as anything in controllers)
		if(!controller || QDELETED(controller))
			continue
		referenced_participants |= controller.user
		referenced_participants |= controller.linked_participants
	for(var/datum/sex_action/action as anything in active_actions)
		if(!action || QDELETED(action))
			continue
		referenced_participants |= action.action_user
		referenced_participants |= action.action_target

	var/list/stale_participants = participants - referenced_participants
	for(var/mob/living/participant as anything in stale_participants)
		detach_participant(participant)

	if(!length(participants))
		reconciling_membership = FALSE
		qdel(src)
		return

	var/list/unvisited = participants.Copy()
	var/list/components = list()
	while(length(unvisited))
		var/mob/living/seed = unvisited[1]
		var/list/component = list(seed)
		var/list/queue = list(seed)
		unvisited -= seed
		while(length(queue))
			var/mob/living/current = queue[1]
			queue.Cut(1, 2)
			for(var/datum/sex_scene_controller/controller as anything in controllers)
				if(controller.user == current)
					for(var/mob/living/neighbor as anything in controller.linked_participants)
						if(neighbor in unvisited)
							unvisited -= neighbor
							component |= neighbor
							queue |= neighbor
				else if(current in controller.linked_participants)
					var/mob/living/neighbor = controller.user
					if(neighbor in unvisited)
						unvisited -= neighbor
						component |= neighbor
						queue |= neighbor
			for(var/datum/sex_action/action as anything in active_actions)
				var/mob/living/neighbor
				if(action.action_user == current)
					neighbor = action.action_target
				else if(action.action_target == current)
					neighbor = action.action_user
				if(neighbor && (neighbor in unvisited))
					unvisited -= neighbor
					component |= neighbor
					queue |= neighbor
		components += list(component)

	if(length(components) > 1)
		for(var/component_index in 2 to length(components))
			var/list/component = components[component_index]
			split_component_into_scene(component)

	update_display_name()
	recompute_patterns()
	reconciling_membership = FALSE

/datum/sex_scene/proc/split_component_into_scene(list/component)
	if(!length(component))
		return null
	var/datum/sex_scene/new_scene = new
	new_scene.reconciling_membership = TRUE

	for(var/mob/living/participant as anything in component)
		UnregisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
		participants -= participant
		if(participant.sex_scene == src)
			participant.sex_scene = null
		new_scene.participants |= participant
		participant.sex_scene = new_scene
		new_scene.RegisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_participant_invalidated))

	var/list/transferred_controllers = controllers.Copy()
	for(var/datum/sex_scene_controller/controller as anything in transferred_controllers)
		if(!(controller.user in component))
			continue
		controllers -= controller
		new_scene.controllers |= controller
		controller.scene = new_scene

	var/list/transferred_actions = active_actions.Copy()
	for(var/datum/sex_action/action as anything in transferred_actions)
		if(!(action.action_user in component) || !(action.action_target in component))
			continue
		active_actions -= action
		new_scene.active_actions |= action
		action.scene = new_scene
		for(var/datum/sex_scene_resource_claim/claim as anything in action.resource_claims)
			resource_claims -= claim
			new_scene.resource_claims |= claim
			claim.scene = new_scene

	var/list/transferred_contexts = remote_contexts.Copy()
	for(var/datum/sex_remote_context/context as anything in transferred_contexts)
		if(!(context.get_caster() in component) || !(context.get_target() in component))
			continue
		remote_contexts -= context
		new_scene.remote_contexts |= context
		context.scene = new_scene

	var/list/transferred_roles = roles.Copy()
	for(var/datum/sex_scene_role/scene_role as anything in transferred_roles)
		if(!(scene_role.action in new_scene.active_actions))
			continue
		roles -= scene_role
		new_scene.roles |= scene_role

	new_scene.update_display_name()
	new_scene.recompute_patterns()
	new_scene.reconciling_membership = FALSE
	for(var/datum/sex_scene_controller/controller as anything in new_scene.controllers)
		SStgui.update_uis(controller)
	return new_scene

/datum/sex_scene/proc/get_controller(mob/living/user)
	if(!user)
		return null
	for(var/datum/sex_scene_controller/controller as anything in controllers)
		if(!controller || QDELETED(controller))
			continue
		if(controller.user == user)
			return controller
	return null

/datum/sex_scene/proc/get_controllers_involving(mob/living/participant)
	var/list/matching_controllers = list()
	if(!participant || !(participant in participants))
		return matching_controllers
	for(var/datum/sex_scene_controller/controller as anything in controllers)
		if(!controller || QDELETED(controller))
			continue
		if(controller.user == participant || (participant in controller.linked_participants))
			matching_controllers += controller
	return matching_controllers

/datum/sex_scene/proc/add_action(datum/sex_action/action)
	if(!action || QDELETED(action))
		return FALSE
	if(!(action.action_user in participants) || !(action.action_target in participants))
		return FALSE
	if(action.scene && action.scene != src)
		return FALSE

	active_actions |= action
	action.scene = src
	index_action_roles(action)
	recompute_patterns()
	return TRUE

/datum/sex_scene/proc/add_resource_claim(datum/sex_scene_resource_claim/claim)
	if(!claim || QDELETED(claim) || claim.owner?.scene != src)
		return FALSE
	resource_claims |= claim
	claim.scene = src
	return TRUE

/datum/sex_scene/proc/add_remote_context(datum/sex_remote_context/context)
	if(!context || QDELETED(context))
		return FALSE
	var/mob/living/caster = context.get_caster()
	var/mob/living/remote_target = context.get_target()
	if(!(caster in participants) || !(remote_target in participants))
		return FALSE

	var/list/old_contexts = remote_contexts.Copy()
	for(var/datum/sex_remote_context/old_context as anything in old_contexts)
		if(old_context.get_caster() == caster && old_context.get_target() == remote_target)
			qdel(old_context)

	remote_contexts |= context
	context.scene = src
	return TRUE

/datum/sex_scene/proc/remove_remote_context(datum/sex_remote_context/context)
	if(!context || !(context in remote_contexts))
		return FALSE
	remote_contexts -= context
	if(context.scene == src)
		context.scene = null
	return TRUE

/datum/sex_scene/proc/get_remote_context(mob/living/caster, mob/living/remote_target, datum/sex_action/action)
	for(var/datum/sex_remote_context/context as anything in remote_contexts)
		if(!context || QDELETED(context))
			continue
		if(context.get_caster() != caster || context.get_target() != remote_target)
			continue
		if(!context.is_valid(src))
			qdel(context)
			continue
		if(action && !context.allows_action(action))
			continue
		return context
	return null

/datum/sex_scene/proc/remove_resource_claim(datum/sex_scene_resource_claim/claim)
	if(!claim || !(claim in resource_claims))
		return FALSE
	resource_claims -= claim
	if(claim.scene == src)
		claim.scene = null
	return TRUE

/datum/sex_scene/proc/is_resource_claimed(datum/sex_action/requesting_action, mob/living/locked_host, organ_slot, obj/item/item, obj/item/storage_item)
	if(!locked_host || (!organ_slot && !item))
		return FALSE
	for(var/datum/sex_scene_resource_claim/claim as anything in resource_claims)
		if(!claim || QDELETED(claim) || claim.owner == requesting_action || !claim.hard_lock)
			continue
		if(claim.locked_host != locked_host)
			continue
		var/item_claimed = claim.locked_item && claim.locked_item == item
		var/organ_claimed = claim.locked_organ_slot && claim.locked_organ_slot == organ_slot
		if(!item_claimed && !organ_claimed)
			continue
		if(organ_claimed && storage_item && requesting_action?.can_fit_item_in_hole(locked_host, organ_slot, storage_item))
			continue
		return TRUE
	return FALSE

/datum/sex_scene/proc/remove_action(datum/sex_action/action)
	if(!action || !(action in active_actions))
		return FALSE

	active_actions -= action
	remove_action_roles(action)
	if(action.scene == src)
		action.scene = null
	recompute_patterns()
	if(!reconciling_membership)
		reconcile_membership()
	return TRUE

/datum/sex_scene/proc/stop_action(datum/sex_action/action)
	if(!action || QDELETED(action) || !(action in active_actions))
		return FALSE

	var/mob/living/action_user = action.action_user
	var/mob/living/action_target = action.action_target
	if(action_user && action_target)
		action_user.stop_doing("sex_action_[REF(action)]")

	var/datum/sex_remote_context/action_remote_context = action.get_valid_remote_context()
	if(action_remote_context)
		action_remote_context.show_action_message(action, MAGE_HAND_ACTION_MESSAGE_FINISH)
		action_remote_context.clear_action_overlay(action)
	else
		action.remote_context?.clear_action_overlay(action)

	action.run_act_hook(TYPE_PROC_REF(/datum/sex_action, on_finish), action_user, action_target)
	action.unbind_runtime()
	qdel(action)

	for(var/datum/sex_scene_controller/controller as anything in controllers)
		if(controller && !QDELETED(controller))
			SStgui.update_uis(controller)
	return TRUE

/datum/sex_scene/proc/forget_action(datum/sex_action/action)
	if(!action)
		return
	active_actions -= action
	remove_action_roles(action)
	if(action.scene == src)
		action.scene = null

	var/list/pattern_keys_to_remove = list()
	for(var/pattern_key in active_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		if(action in pattern_match.actions)
			pattern_keys_to_remove += pattern_key
	for(var/pattern_key in pattern_keys_to_remove)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		active_patterns.Remove(pattern_key)
		qdel(pattern_match)
	if(!reconciling_membership)
		reconcile_membership()

/datum/sex_scene/proc/index_action_roles(datum/sex_action/action)
	if(!action || QDELETED(action))
		return
	var/list/action_roles = action.build_scene_roles()
	for(var/datum/sex_scene_role/scene_role as anything in action_roles)
		if(!scene_role || QDELETED(scene_role))
			continue
		if(scene_role.action != action || !(scene_role.participant in participants) || !(scene_role.counterpart in participants))
			qdel(scene_role)
			continue
		roles += scene_role

/datum/sex_scene/proc/remove_action_roles(datum/sex_action/action)
	var/list/roles_to_remove = list()
	for(var/datum/sex_scene_role/scene_role as anything in roles)
		if(scene_role.action == action)
			roles_to_remove += scene_role
	for(var/datum/sex_scene_role/scene_role as anything in roles_to_remove)
		roles -= scene_role
		qdel(scene_role)

/datum/sex_scene/proc/refresh_action_roles(datum/sex_action/action)
	if(!action || !(action in active_actions))
		return FALSE
	remove_action_roles(action)
	index_action_roles(action)
	recompute_patterns()
	return TRUE

/datum/sex_scene/proc/get_roles_for(mob/living/participant, interaction, role)
	var/list/matching_roles = list()
	if(!participant || !(participant in participants))
		return matching_roles
	for(var/datum/sex_scene_role/scene_role as anything in roles)
		if(scene_role.participant != participant)
			continue
		if(interaction && scene_role.interaction != interaction)
			continue
		if(role && scene_role.role != role)
			continue
		matching_roles += scene_role
	return matching_roles

/datum/sex_scene/proc/get_pattern_matches(pattern_id, mob/living/participant)
	var/list/matches = list()
	for(var/pattern_key in active_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		if(pattern_id && pattern_match.pattern_id != pattern_id)
			continue
		if(participant && !(participant in pattern_match.participants))
			continue
		matches += pattern_match
	return matches

/datum/sex_scene/proc/has_pattern(pattern_id, mob/living/participant, focus_only = FALSE)
	for(var/pattern_key in active_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		if(pattern_match.pattern_id != pattern_id)
			continue
		if(participant)
			if(focus_only && pattern_match.focus != participant)
				continue
			if(!focus_only && !(participant in pattern_match.participants))
				continue
		return TRUE
	return FALSE

/// Returns the strongest pattern-owned AI bonus for adding this action to the scene.
/// Acquisition callers may evaluate a user prospectively without mutating scene membership.
/datum/sex_scene/proc/get_action_pattern_desirability(datum/sex_action/action, mob/living/user, mob/living/target, allow_new_participant = FALSE)
	if(!action || QDELETED(action) || !user || !target)
		return 0
	if(!(target in participants))
		return 0

	var/list/scoring_participants = participants
	if(!(user in scoring_participants))
		if(!allow_new_participant)
			return 0
		if(user.sex_scene && !QDELETED(user.sex_scene) && user.sex_scene != src)
			scoring_participants = participants | user.sex_scene.participants
		else
			scoring_participants = participants.Copy()
			scoring_participants |= user
		if(length(scoring_participants) > SEX_SCENE_AI_MAX_PARTICIPANTS)
			return 0
		if(!can_include_participants(scoring_participants, user))
			return 0

	var/list/candidate_roles = action.build_scene_roles_for(user, target)
	if(!length(candidate_roles))
		return 0

	var/list/combined_roles = roles.Copy()
	combined_roles += candidate_roles
	var/best_desirability = 0

	for(var/datum/sex_scene_pattern/pattern as anything in pattern_definitions)
		if(pattern.ai_desirability <= best_desirability)
			continue
		var/list/pattern_matches = pattern.find_matches_in_roles(scoring_participants, combined_roles)
		for(var/datum/sex_scene_pattern_match/pattern_match as anything in pattern_matches)
			if((action in pattern_match.actions) && !has_pattern(pattern.pattern_id, pattern_match.focus, focus_only = TRUE))
				best_desirability = pattern.ai_desirability
			qdel(pattern_match)

	for(var/datum/sex_scene_role/candidate_role as anything in candidate_roles)
		qdel(candidate_role)
	return best_desirability

/datum/sex_scene/proc/recompute_patterns()
	if(recomputing_patterns)
		pattern_refresh_pending = TRUE
		return

	recomputing_patterns = TRUE
	do
		pattern_refresh_pending = FALSE
		var/list/candidate_matches = list()
		for(var/datum/sex_scene_pattern/pattern as anything in pattern_definitions)
			var/list/pattern_matches = pattern.find_matches(src)
			for(var/datum/sex_scene_pattern_match/pattern_match as anything in pattern_matches)
				if(candidate_matches[pattern_match.match_key])
					qdel(pattern_match)
					continue
				candidate_matches[pattern_match.match_key] = pattern_match
		remove_subsumed_pattern_matches(candidate_matches)

		// Keep one canonical occurrence of a pattern around each focus. Prefer
		// the already-running match so late joiners cannot replace its actors
		// or make shared core actions apply the same modifier more than once.
		var/list/canonical_pattern_keys = list()
		for(var/pattern_key in active_patterns)
			var/datum/sex_scene_pattern_match/canonical_existing_match = active_patterns[pattern_key]
			if(!candidate_matches[pattern_key])
				continue
			canonical_pattern_keys["[canonical_existing_match.pattern_id]:[REF(canonical_existing_match.focus)]"] = pattern_key

		var/list/competing_pattern_keys = list()
		for(var/pattern_key in candidate_matches)
			var/datum/sex_scene_pattern_match/canonical_candidate_match = candidate_matches[pattern_key]
			var/focus_pattern_key = "[canonical_candidate_match.pattern_id]:[REF(canonical_candidate_match.focus)]"
			var/canonical_key = canonical_pattern_keys[focus_pattern_key]
			if(!canonical_key)
				canonical_pattern_keys[focus_pattern_key] = pattern_key
			else if(canonical_key != pattern_key)
				competing_pattern_keys += pattern_key

		for(var/pattern_key in competing_pattern_keys)
			var/datum/sex_scene_pattern_match/competing_match = candidate_matches[pattern_key]
			candidate_matches.Remove(pattern_key)
			qdel(competing_match)

		var/list/previous_matches = active_patterns.Copy()
		for(var/pattern_key in previous_matches)
			var/datum/sex_scene_pattern_match/existing_match = active_patterns[pattern_key]
			var/datum/sex_scene_pattern_match/candidate_match = candidate_matches[pattern_key]
			if(candidate_match)
				qdel(candidate_match)
				candidate_matches.Remove(pattern_key)
				continue
			active_patterns.Remove(pattern_key)
			notify_pattern_change(existing_match, started = FALSE)
			qdel(existing_match)

		for(var/pattern_key in candidate_matches)
			var/datum/sex_scene_pattern_match/new_match = candidate_matches[pattern_key]
			active_patterns[pattern_key] = new_match
			notify_pattern_change(new_match, started = TRUE)
	while(pattern_refresh_pending)
	recomputing_patterns = FALSE

/// Keeps the most complete arrangement when the same focus and actions also
/// satisfy smaller patterns (airtight supersedes its spit-roast/DP subsets).
/datum/sex_scene/proc/remove_subsumed_pattern_matches(list/candidate_matches)
	var/list/keys_to_remove = list()
	for(var/higher_key in candidate_matches)
		var/datum/sex_scene_pattern_match/higher_match = candidate_matches[higher_key]
		for(var/lower_key in candidate_matches)
			if(lower_key == higher_key || (lower_key in keys_to_remove))
				continue
			var/datum/sex_scene_pattern_match/lower_match = candidate_matches[lower_key]
			if(lower_match.focus != higher_match.focus)
				continue
			if(length(lower_match.actions) >= length(higher_match.actions))
				continue
			var/is_action_subset = TRUE
			for(var/datum/sex_action/action as anything in lower_match.actions)
				if(!(action in higher_match.actions))
					is_action_subset = FALSE
					break
			if(is_action_subset)
				keys_to_remove |= lower_key

	for(var/pattern_key in keys_to_remove)
		var/datum/sex_scene_pattern_match/pattern_match = candidate_matches[pattern_key]
		candidate_matches.Remove(pattern_key)
		qdel(pattern_match)

/datum/sex_scene/proc/notify_pattern_change(datum/sex_scene_pattern_match/pattern_match, started)
	if(!pattern_match || QDELETED(pattern_match))
		return
	var/message = started ? pattern_match.pattern?.get_start_message(pattern_match) : pattern_match.pattern?.get_end_message(pattern_match)
	if(message && pattern_match.focus && !QDELETED(pattern_match.focus))
		pattern_match.focus.visible_message(span_love(message))

	var/signal = started ? COMSIG_SEX_SCENE_PATTERN_STARTED : COMSIG_SEX_SCENE_PATTERN_ENDED
	SEND_SIGNAL(src, signal, pattern_match)
	for(var/mob/living/participant as anything in pattern_match.participants)
		if(!participant || QDELETED(participant))
			continue
		SEND_SIGNAL(participant, signal, pattern_match)
	for(var/datum/sex_scene_controller/controller as anything in controllers)
		if(!controller || QDELETED(controller))
			continue
		SStgui.update_uis(controller)

/datum/sex_scene/proc/modify_action_effect(datum/sex_action_effect_context/context)
	if(!context?.action || !context.receiver)
		return
	for(var/pattern_key in active_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		if(!(context.action in pattern_match.actions) || !(context.receiver in pattern_match.participants))
			continue
		pattern_match.pattern?.modify_action_effect(pattern_match, context)

/datum/sex_scene/proc/handle_pattern_climax(mob/living/climaxer, datum/sex_action/action)
	if(!climaxer || QDELETED(climaxer))
		return FALSE
	var/handled = FALSE
	for(var/pattern_key in active_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = active_patterns[pattern_key]
		if(!(climaxer in pattern_match.participants))
			continue
		if(action && !(action in pattern_match.actions))
			continue
		var/message = pattern_match.pattern?.get_climax_message(pattern_match, climaxer)
		if(message)
			climaxer.visible_message(span_love(message))
		pattern_match.pattern?.apply_climax_stress(pattern_match, climaxer)
		handled = TRUE
	return handled

/datum/sex_scene/proc/get_actions_involving(mob/living/participant)
	var/list/actions = list()
	if(!participant || !(participant in participants))
		return actions

	for(var/datum/sex_action/action as anything in active_actions)
		if(action.action_user == participant || action.action_target == participant)
			actions += action
	return actions

/datum/sex_scene/proc/get_actions_between(mob/living/first, mob/living/second)
	var/list/actions = list()
	if(!first || !second)
		return actions
	for(var/datum/sex_action/action as anything in active_actions)
		if((action.action_user == first && action.action_target == second) || (action.action_user == second && action.action_target == first))
			actions += action
	return actions

/datum/sex_scene/proc/merge_scene(datum/sex_scene/other_scene, mob/living/explicit_joiner)
	if(!other_scene || other_scene == src || QDELETED(other_scene))
		return FALSE
	var/list/prospective_participants = participants | other_scene.participants
	if(!can_include_participants(prospective_participants, explicit_joiner))
		return FALSE

	var/list/transferred_participants = other_scene.participants.Copy()
	for(var/mob/living/participant as anything in transferred_participants)
		other_scene.UnregisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
		other_scene.participants -= participant
		participants |= participant
		participant.sex_scene = src
		RegisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_participant_invalidated))
	update_display_name()

	var/list/transferred_controllers = other_scene.controllers.Copy()
	for(var/datum/sex_scene_controller/controller as anything in transferred_controllers)
		other_scene.controllers -= controller
		if(get_controller(controller.user))
			qdel(controller)
			continue
		controllers |= controller
		controller.scene = src

	var/list/transferred_actions = other_scene.active_actions.Copy()
	for(var/datum/sex_action/action as anything in transferred_actions)
		other_scene.active_actions -= action
		active_actions |= action
		action.scene = src

	var/list/transferred_claims = other_scene.resource_claims.Copy()
	for(var/datum/sex_scene_resource_claim/claim as anything in transferred_claims)
		other_scene.resource_claims -= claim
		resource_claims |= claim
		claim.scene = src

	var/list/transferred_contexts = other_scene.remote_contexts.Copy()
	for(var/datum/sex_remote_context/context as anything in transferred_contexts)
		other_scene.remote_contexts -= context
		remote_contexts |= context
		context.scene = src

	var/list/transferred_roles = other_scene.roles.Copy()
	for(var/datum/sex_scene_role/scene_role as anything in transferred_roles)
		other_scene.roles -= scene_role
		roles += scene_role

	var/list/transferred_patterns = other_scene.active_patterns.Copy()
	for(var/pattern_key in transferred_patterns)
		var/datum/sex_scene_pattern_match/pattern_match = other_scene.active_patterns[pattern_key]
		other_scene.active_patterns.Remove(pattern_key)
		if(active_patterns[pattern_key])
			qdel(pattern_match)
			continue
		active_patterns[pattern_key] = pattern_match

	qdel(other_scene)
	recompute_patterns()
	return TRUE

/datum/sex_scene/proc/on_participant_invalidated(mob/living/participant)
	SIGNAL_HANDLER
	remove_participant(participant)

/// Returns one shared scene for both participants, merging their scenes if needed.
/proc/get_or_create_sex_scene(mob/living/first_participant, mob/living/second_participant)
	if(!first_participant || !second_participant)
		return null
	if(QDELETED(first_participant) || QDELETED(second_participant))
		return null

	var/created_scene = FALSE
	var/datum/sex_scene/scene = first_participant.sex_scene
	if(scene && QDELETED(scene))
		first_participant.sex_scene = null
		scene = null

	var/datum/sex_scene/other_scene = second_participant.sex_scene
	if(other_scene && QDELETED(other_scene))
		second_participant.sex_scene = null
		other_scene = null

	if(!scene)
		if(other_scene)
			scene = other_scene
		else
			scene = new /datum/sex_scene()
			created_scene = TRUE
	else if(other_scene && other_scene != scene)
		if(!scene.merge_scene(other_scene, first_participant))
			return null

	if(!scene.add_participant(first_participant) || !scene.add_participant(second_participant))
		if(created_scene)
			qdel(scene)
		return null
	return scene

/mob/living
	/// Shared context for all simultaneous sexual interactions involving this mob.
	var/datum/sex_scene/sex_scene

/mob/living/proc/get_active_sex_scene_patterns(pattern_id)
	if(!sex_scene || QDELETED(sex_scene))
		return list()
	return sex_scene.get_pattern_matches(pattern_id, src)

/mob/living/proc/has_active_sex_scene_pattern(pattern_id)
	return !!sex_scene?.has_pattern(pattern_id, src)
