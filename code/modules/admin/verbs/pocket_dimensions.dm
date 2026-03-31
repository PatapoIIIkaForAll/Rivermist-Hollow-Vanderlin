/client/proc/show_pocket_dimension_debug_report(datum/pocket_dimension/instance, include_snapshot_details = FALSE)
	if(!instance || QDELETED(instance) || !mob)
		return

	var/window_id = include_snapshot_details ? "pocket_snapshot_[instance.instance_id]" : "pocket_debug_[instance.instance_id]"
	var/window_title = include_snapshot_details ? "Pocket Snapshot Dump" : "Pocket Dimension Debugger"
	var/datum/browser/browser = new(mob, window_id, window_title, 800, 650)
	browser.set_content(instance.build_debug_html(include_snapshot_details))
	browser.open()

/client/proc/pocket_dimension_debugger()
	set category = "Debug.Mapping"
	set name = "Pocket Dimension Debugger"
	set desc = "Inspect and manage live pocket dimension instances."

	if(!check_rights(R_DEBUG))
		return
	if(!SSpocket_dimensions)
		to_chat(src, span_warning("Pocket dimensions are not available right now."))
		return
	if(!mob)
		return

	var/list/instance_choices = SSpocket_dimensions.build_debug_instance_choices()
	if(!length(instance_choices))
		to_chat(src, span_notice("There are no active pocket dimension instances to inspect."))
		return

	var/list/labels = list()
	for(var/label in instance_choices)
		labels += label
	labels = sortList(labels)

	var/selected_label = tgui_input_list(mob, "Select a pocket dimension instance to inspect.", "Pocket Dimension Debugger", labels)
	if(!selected_label)
		return

	var/datum/pocket_dimension/instance = instance_choices[selected_label]
	if(!instance || QDELETED(instance))
		to_chat(src, span_warning("That pocket instance is no longer available."))
		return

	var/list/actions = list(
		"Inspect State",
		"Dump Snapshot",
		"View Variables",
		"Force Wake",
		"Force Hibernate",
		"Force Collapse",
	)
	var/action = tgui_input_list(mob, "Choose a debug action for [selected_label].", "Pocket Dimension Debugger", actions)
	if(!action)
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Pocket Dimension Debugger")

	switch(action)
		if("Inspect State")
			show_pocket_dimension_debug_report(instance)

		if("Dump Snapshot")
			show_pocket_dimension_debug_report(instance, TRUE)

		if("View Variables")
			debug_variables(instance)

		if("Force Wake")
			if(!instance.is_hibernating())
				to_chat(src, span_notice("[instance.get_debug_label()] is already loaded."))
				return
			if(!instance.activate())
				to_chat(src, span_warning("Failed to wake [instance.get_debug_label()]."))
				return

			message_admins(span_adminnotice("[key_name_admin(src)] force-woke [instance.get_debug_label()]."))
			log_admin("[key_name(src)] force-woke [instance.get_debug_label()].")
			to_chat(src, span_notice("Force-woke [instance.get_debug_label()]."))

		if("Force Hibernate")
			if(instance.is_hibernating())
				to_chat(src, span_notice("[instance.get_debug_label()] is already hibernating."))
				return
			if(!instance.hibernate())
				to_chat(src, span_warning("Failed to hibernate [instance.get_debug_label()]. It may still have occupants inside."))
				return

			message_admins(span_adminnotice("[key_name_admin(src)] force-hibernated [instance.get_debug_label()]."))
			log_admin("[key_name(src)] force-hibernated [instance.get_debug_label()].")
			to_chat(src, span_notice("Force-hibernated [instance.get_debug_label()]."))

		if("Force Collapse")
			if(tgui_alert(
				mob,
				"Collapse [selected_label]? This ejects foreign contents and deletes the pocket.",
				"Pocket Dimension Debugger",
				list("Collapse", "Cancel"),
			) != "Collapse")
				return

			if(!SSpocket_dimensions.delete_instance(instance, "Folded space buckles under administrative pressure and throws you back!"))
				to_chat(src, span_warning("Failed to collapse [selected_label]."))
				return

			message_admins(span_adminnotice("[key_name_admin(src)] force-collapsed [selected_label]."))
			log_admin("[key_name(src)] force-collapsed [selected_label].")
			to_chat(src, span_notice("Force-collapsed [selected_label]."))
