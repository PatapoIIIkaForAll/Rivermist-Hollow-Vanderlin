/proc/is_valid_pocket_access_instance_mode(mode)
	return mode == POCKET_ACCESS_INSTANCE_OWNER || mode == POCKET_ACCESS_INSTANCE_USER || mode == POCKET_ACCESS_INSTANCE_LOCATION || mode == POCKET_ACCESS_INSTANCE_CUSTOM

/datum/component/pocket_access
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/template_ref
	var/instance_mode = POCKET_ACCESS_INSTANCE_OWNER
	var/custom_instance_key
	var/lifecycle_policy
	var/idle_timeout

	var/allow_manual_collapse = TRUE
	var/allow_manual_hibernate = TRUE
	var/delete_instances_on_destroy = TRUE

	var/prompt_title = "Pocket Dimension"
	var/prompt_text
	var/collapse_eject_message = "The pocket dimension buckles and throws you back into mundane space!"
	var/destroy_eject_message = "The link to the pocket dimension shatters, and folded space throws you back!"

	var/list/tracked_instance_keys = list()

/datum/component/pocket_access/Initialize(
	template_ref,
	instance_mode = POCKET_ACCESS_INSTANCE_OWNER,
	lifecycle_policy = null,
	idle_timeout = null,
	custom_instance_key = null,
	allow_manual_collapse = TRUE,
	allow_manual_hibernate = TRUE,
	delete_instances_on_destroy = TRUE,
	prompt_title = "Pocket Dimension",
	prompt_text = null,
	collapse_eject_message = null,
	destroy_eject_message = null
)
	if(!isatom(parent) || !template_ref || !is_valid_pocket_access_instance_mode(instance_mode))
		return COMPONENT_INCOMPATIBLE
	if(!isnull(lifecycle_policy) && !is_valid_pocket_lifecycle_policy(lifecycle_policy))
		return COMPONENT_INCOMPATIBLE

	src.template_ref = template_ref
	src.instance_mode = instance_mode
	src.lifecycle_policy = lifecycle_policy
	src.idle_timeout = idle_timeout
	src.custom_instance_key = custom_instance_key
	src.allow_manual_collapse = allow_manual_collapse
	src.allow_manual_hibernate = allow_manual_hibernate
	src.delete_instances_on_destroy = delete_instances_on_destroy
	src.prompt_title = prompt_title || "Pocket Dimension"
	src.prompt_text = prompt_text
	if(!isnull(collapse_eject_message))
		src.collapse_eject_message = collapse_eject_message
	if(!isnull(destroy_eject_message))
		src.destroy_eject_message = destroy_eject_message

/datum/component/pocket_access/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_interact))
	else
		RegisterSignals(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW), PROC_REF(on_interact))

/datum/component/pocket_access/UnregisterFromParent()
	if(!parent)
		return

	var/list/signals = list(COMSIG_PARENT_EXAMINE)
	if(isitem(parent))
		signals += COMSIG_ITEM_ATTACK_SELF
	else
		signals += COMSIG_ATOM_ATTACK_HAND
		signals += COMSIG_ATOM_ATTACK_PAW

	UnregisterSignal(parent, signals)

/datum/component/pocket_access/Destroy(force)
	if(delete_instances_on_destroy && SSpocket_dimensions)
		cleanup_tracked_instance_keys()
		for(var/instance_key in tracked_instance_keys.Copy())
			SSpocket_dimensions.delete_instance(instance_key, destroy_eject_message)

	tracked_instance_keys.Cut()
	template_ref = null
	custom_instance_key = null
	lifecycle_policy = null
	idle_timeout = null
	prompt_text = null
	return ..()

/datum/component/pocket_access/proc/get_effective_lifecycle_policy()
	if(!isnull(lifecycle_policy) && is_valid_pocket_lifecycle_policy(lifecycle_policy))
		return lifecycle_policy

	var/datum/map_template/pocket/template = SSpocket_dimensions?.resolve_template(template_ref)
	return template?.lifecycle_policy || POCKET_LIFECYCLE_KEEP_LOADED

/datum/component/pocket_access/proc/get_effective_idle_timeout()
	if(!isnull(idle_timeout))
		return max(0, idle_timeout)

	var/datum/map_template/pocket/template = SSpocket_dimensions?.resolve_template(template_ref)
	return max(0, template?.idle_timeout || 0)

/datum/component/pocket_access/proc/track_instance_key(instance_key)
	if(!instance_key)
		return
	tracked_instance_keys["[instance_key]"] = TRUE

/datum/component/pocket_access/proc/cleanup_tracked_instance_keys()
	if(!SSpocket_dimensions)
		tracked_instance_keys.Cut()
		return

	for(var/instance_key in tracked_instance_keys.Copy())
		if(SSpocket_dimensions.get_instance(instance_key))
			continue
		tracked_instance_keys -= instance_key

/datum/component/pocket_access/proc/get_instance_key_for_user(mob/user)
	var/list/context = list("key" = null)
	if(SEND_SIGNAL(parent, COMSIG_POCKET_ACCESS_BUILD_INSTANCE_KEY, user, src, context) & COMPONENT_POCKET_ACCESS_USE_CUSTOM_KEY)
		if(!isnull(context["key"]) && length("[context["key"]]"))
			return "[context["key"]]"
		return null

	switch(instance_mode)
		if(POCKET_ACCESS_INSTANCE_OWNER)
			return "pocket_access::owner::[REF(parent)]"
		if(POCKET_ACCESS_INSTANCE_USER)
			if(!user)
				return null
			return "pocket_access::user::[REF(parent)]::[user.ckey || REF(user)]"
		if(POCKET_ACCESS_INSTANCE_LOCATION)
			var/turf/anchor_turf = get_turf(parent)
			if(anchor_turf)
				return "pocket_access::location::[REF(anchor_turf)]"
			return "pocket_access::location::[REF(parent)]"
		if(POCKET_ACCESS_INSTANCE_CUSTOM)
			if(!isnull(custom_instance_key) && length("[custom_instance_key]"))
				return "[custom_instance_key]"
			return "pocket_access::custom::[REF(parent)]"

	return null

/datum/component/pocket_access/proc/get_keyed_instance_for_user(mob/user)
	if(!SSpocket_dimensions)
		return null

	var/instance_key = get_instance_key_for_user(user)
	if(!instance_key)
		return null

	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_instance(instance_key)
	if(instance)
		track_instance_key(instance_key)
	return instance

/datum/component/pocket_access/proc/find_instance_containing_user(mob/user)
	if(!user || !SSpocket_dimensions)
		return null

	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return null

	cleanup_tracked_instance_keys()
	for(var/instance_key in tracked_instance_keys.Copy())
		var/datum/pocket_dimension/instance = SSpocket_dimensions.get_instance(instance_key)
		if(!instance)
			tracked_instance_keys -= instance_key
			continue
		if(instance.contains_turf(user_turf))
			return instance

	return null

/datum/component/pocket_access/proc/get_instance_for_user(mob/user)
	var/datum/pocket_dimension/inside_instance = find_instance_containing_user(user)
	if(inside_instance)
		return inside_instance
	return get_keyed_instance_for_user(user)

/datum/component/pocket_access/proc/get_or_create_instance_for_user(mob/user)
	if(!SSpocket_dimensions)
		return null

	var/instance_key = get_instance_key_for_user(user)
	if(!instance_key)
		return null

	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance(
		instance_key,
		template_ref,
		lifecycle_policy,
		idle_timeout
	)
	if(instance)
		track_instance_key(instance.instance_key)
	return instance

/datum/component/pocket_access/proc/get_default_action(mob/user, datum/pocket_dimension/instance = null)
	instance ||= get_instance_for_user(user)
	if(instance?.contains_turf(get_turf(user)))
		return POCKET_ACTION_LEAVE
	return POCKET_ACTION_ENTER

/datum/component/pocket_access/proc/show_action_feedback(mob/user, list/context, fallback_message = null)
	if(!user)
		return
	to_chat(user, span_warning(context?["message"] || fallback_message || "Nothing answers."))

/datum/component/pocket_access/proc/can_perform_action(mob/user, action, datum/pocket_dimension/instance = null, show_feedback = TRUE)
	var/list/context = list()

	if(!user || !parent)
		context["message"] = "Nothing answers."
	else
		switch(action)
			if(POCKET_ACTION_ENTER)
				if(instance?.contains_turf(get_turf(user)))
					context["message"] = "You are already inside this pocket."
			if(POCKET_ACTION_LEAVE)
				if(!instance || !instance.contains_turf(get_turf(user)))
					context["message"] = "You have nothing to return from."
			if(POCKET_ACTION_HIBERNATE)
				if(!allow_manual_hibernate)
					context["message"] = "This access point cannot hibernate its pocket."
				else if(!instance || instance.is_hibernating())
					context["message"] = "There is no loaded pocket to hibernate."
				else if(instance.has_occupants())
					context["message"] = "The folded space refuses to settle while something living remains inside."
			if(POCKET_ACTION_COLLAPSE)
				if(!allow_manual_collapse)
					context["message"] = "This access point cannot collapse its pocket."
				else if(!instance)
					context["message"] = "Nothing answers. The pocket was already gone."
			else
				context["message"] = "That action is not supported."

	if(context["message"])
		if(show_feedback)
			show_action_feedback(user, context)
		return FALSE

	if(SEND_SIGNAL(parent, COMSIG_POCKET_ACCESS_CAN_PERFORM_ACTION, user, action, src, instance, context) & COMPONENT_POCKET_ACCESS_BLOCK_ACTION)
		if(show_feedback)
			show_action_feedback(user, context)
		return FALSE

	return TRUE

/datum/component/pocket_access/proc/enter_user(mob/user)
	return perform_action(user, POCKET_ACTION_ENTER)

/datum/component/pocket_access/proc/leave_user(mob/user)
	return perform_action(user, POCKET_ACTION_LEAVE)

/datum/component/pocket_access/proc/hibernate_pocket(mob/user)
	return perform_action(user, POCKET_ACTION_HIBERNATE)

/datum/component/pocket_access/proc/collapse_pocket(mob/user)
	return perform_action(user, POCKET_ACTION_COLLAPSE)

/datum/component/pocket_access/proc/store_movable_for_user(mob/user, atom/movable/movable, turf/origin_turf = null, turf/forced_drop_turf = null)
	if(!SSpocket_dimensions || !movable || QDELETED(movable) || movable == parent)
		return FALSE

	var/datum/pocket_dimension/instance = get_or_create_instance_for_user(user)
	if(!instance)
		return FALSE

	var/atom/return_anchor = parent
	var/turf/anchor_turf = get_turf(return_anchor) || origin_turf || get_turf(user)
	if(!instance.send_movable_inside(movable, anchor_turf, forced_drop_turf, return_anchor))
		return FALSE

	keep_parent_outside_pocket(instance, anchor_turf)
	return TRUE

/datum/component/pocket_access/proc/keep_parent_outside_pocket(datum/pocket_dimension/instance, turf/origin_turf)
	if(!instance || !ismovable(parent))
		return

	var/atom/movable/access_point = parent
	if(QDELETED(access_point) || !instance.contains_turf(get_turf(access_point)))
		return

	var/turf/target = origin_turf || instance.get_return_turf()
	if(!target)
		return

	if(isitem(access_point) && ismob(access_point.loc))
		var/mob/item_holder = access_point.loc
		item_holder.temporarilyRemoveItemFromInventory(access_point, TRUE)

	access_point.forceMove(target)

/datum/component/pocket_access/proc/perform_action(mob/user, action, datum/pocket_dimension/instance = null)
	if(!SSpocket_dimensions)
		to_chat(user, span_warning("Pocket dimensions are not available right now."))
		return FALSE

	instance ||= get_instance_for_user(user)
	if(!can_perform_action(user, action, instance))
		return FALSE

	switch(action)
		if(POCKET_ACTION_ENTER)
			var/turf/origin_turf = get_turf(user)
			var/atom/return_anchor = parent
			var/turf/return_turf = get_turf(return_anchor) || origin_turf
			instance = get_or_create_instance_for_user(user)
			if(!instance)
				to_chat(user, span_warning("The folded space sputters and refuses to open."))
				return FALSE
			if(!instance.enter_mob(user, return_turf, return_anchor))
				to_chat(user, span_warning("The folded space sputters and refuses to open."))
				return FALSE
			keep_parent_outside_pocket(instance, return_turf)

		if(POCKET_ACTION_LEAVE)
			if(!instance?.exit_mob(user))
				to_chat(user, span_warning("The way back slips out of reach."))
				return FALSE

		if(POCKET_ACTION_HIBERNATE)
			if(!instance?.hibernate())
				to_chat(user, span_warning("The folded space refuses to settle while something living remains inside."))
				return FALSE

		if(POCKET_ACTION_COLLAPSE)
			if(!SSpocket_dimensions.delete_instance(instance, collapse_eject_message))
				to_chat(user, span_warning("Nothing answers. The pocket was already gone."))
				return FALSE
			instance = null

		else
			to_chat(user, span_warning("That action is not supported."))
			return FALSE

	SEND_SIGNAL(parent, COMSIG_POCKET_ACCESS_PERFORMED_ACTION, user, action, src, instance)
	return TRUE

/datum/component/pocket_access/proc/get_management_actions(mob/user, datum/pocket_dimension/instance, inside_pocket)
	var/list/actions = list()
	var/default_action = inside_pocket ? POCKET_ACTION_LEAVE : POCKET_ACTION_ENTER
	actions += default_action

	if(can_perform_action(user, POCKET_ACTION_HIBERNATE, instance, FALSE))
		actions += POCKET_ACTION_HIBERNATE
	if(can_perform_action(user, POCKET_ACTION_COLLAPSE, instance, FALSE))
		actions += POCKET_ACTION_COLLAPSE

	return actions

/datum/component/pocket_access/proc/get_action_label(action)
	switch(action)
		if(POCKET_ACTION_ENTER)
			return "Enter"
		if(POCKET_ACTION_LEAVE)
			return "Leave"
		if(POCKET_ACTION_HIBERNATE)
			return "Hibernate"
		if(POCKET_ACTION_COLLAPSE)
			return "Collapse"
	return capitalize("[action]")

/datum/component/pocket_access/proc/get_prompt_text(mob/user, datum/pocket_dimension/instance, inside_pocket)
	if(prompt_text)
		return prompt_text
	return "[parent] hums with folded space. What do you want it to do?"

/datum/component/pocket_access/proc/interact(mob/user)
	var/datum/pocket_dimension/instance = get_instance_for_user(user)
	var/inside_pocket = instance?.contains_turf(get_turf(user))
	var/list/actions = get_management_actions(user, instance, inside_pocket)
	if(!length(actions))
		return FALSE

	if(length(actions) == 1)
		return perform_action(user, actions[1], instance)
	if(!user?.client?.prefs)
		return perform_action(user, actions[1], instance)

	var/list/action_by_label = list()
	var/list/options = list()
	for(var/action in actions)
		var/label = get_action_label(action)
		options += label
		action_by_label[label] = action
	options += "Cancel"

	var/choice = tgui_alert(
		user,
		get_prompt_text(user, instance, inside_pocket),
		prompt_title,
		options,
	)
	if(!choice || choice == "Cancel")
		return FALSE

	var/action = action_by_label[choice]
	if(action == POCKET_ACTION_COLLAPSE)
		if(tgui_alert(
			user,
			"Collapse the linked pocket? This ejects any occupants and deletes the room.",
			prompt_title,
			list("Collapse", "Cancel"),
		) != "Collapse")
			return FALSE

	return perform_action(user, action, instance)

/datum/component/pocket_access/proc/get_idle_behavior_text()
	var/effective_policy = get_effective_lifecycle_policy()
	var/effective_timeout = get_effective_idle_timeout()

	if(effective_policy == POCKET_LIFECYCLE_KEEP_LOADED)
		return "Idle behavior: Keep loaded."
	if(!effective_timeout)
		return "Idle behavior: [capitalize(format_pocket_lifecycle_policy(effective_policy))] is disabled."
	return "Idle behavior: [capitalize(format_pocket_lifecycle_policy(effective_policy))] after [DisplayTimeText(effective_timeout)] of idleness."

/datum/component/pocket_access/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/use_hint = isitem(parent) ? "Use it" : "Touch it"
	examine_text += span_notice("[use_hint] to access its pocket space.")
	examine_text += span_notice(get_idle_behavior_text())

	var/datum/pocket_dimension/instance = get_instance_for_user(user)
	if(instance)
		examine_text += span_notice("Current state: [instance.is_hibernating() ? "hibernating" : "loaded"].")

/datum/component/pocket_access/proc/on_interact(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(interact), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN
