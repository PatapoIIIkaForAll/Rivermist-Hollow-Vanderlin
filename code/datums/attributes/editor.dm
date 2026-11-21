/**
 * Attribute Editor: admin window for the attributes and skills of one attribute holder.
 *
 * Every row has a permanent base value and an admin bonus. The admin bonus is its own modifier,
 * so it stacks with (and never overwrites) buffs and other modifiers; those are shown read-only.
 */
/datum/attribute_editor
	var/datum/weakref/target

/datum/attribute_editor/New(datum/attribute_holder/target)
	src.target = WEAKREF(target)

/datum/attribute_editor/ui_state(mob/user)
	return GLOB.always_state

/datum/attribute_editor/ui_status(mob/user, datum/ui_state/state)
	// Opened through an R_ADMIN check; keep checking, the rights may be taken away meanwhile.
	return check_rights_for(user?.client, R_ADMIN) ? UI_INTERACTIVE : UI_CLOSE

/datum/attribute_editor/ui_close(mob/user)
	qdel(src)

/datum/attribute_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AttributeEditor")
		ui.set_autoupdate(FALSE) // buffs change values on their own: refresh every 3 seconds instead
		ui.open()
		admin_ui_slow_refresh(src, 3 SECONDS)

/datum/attribute_editor/ui_static_data(mob/user)
	return list("skill_levels" = list(
		list("name" = "None", "value" = SKILL_LEVEL_NONE),
		list("name" = "Novice", "value" = SKILL_LEVEL_NOVICE),
		list("name" = "Apprentice", "value" = SKILL_LEVEL_APPRENTICE),
		list("name" = "Journeyman", "value" = SKILL_LEVEL_JOURNEYMAN),
		list("name" = "Expert", "value" = SKILL_LEVEL_EXPERT),
		list("name" = "Master", "value" = SKILL_LEVEL_MASTER),
		list("name" = "Legendary", "value" = SKILL_LEVEL_LEGENDARY),
	))

/// The admin bonus list of the holder: attribute type -> bonus. Empty when no bonus was set.
/datum/attribute_editor/proc/admin_bonuses(datum/attribute_holder/attributes)
	var/datum/attribute_modifier/existing_modifier = attributes.has_attribute_modifier(/datum/attribute_modifier/attribute_editor)
	return existing_modifier?.attribute_list ? existing_modifier.attribute_list.Copy() : list()

/datum/attribute_editor/ui_data()
	var/list/data = list()

	var/datum/attribute_holder/attributes = target?.resolve()
	if(!attributes)
		return data

	data["parent"] = attributes.parent?.name
	data["attribute_min"] = attributes.attribute_min
	data["attribute_max"] = attributes.attribute_max
	data["attribute_default"] = attributes.attribute_default
	data["skill_min"] = attributes.skill_min
	data["skill_max"] = attributes.skill_max
	data["skill_default"] = attributes.skill_default
	data["cached_diceroll_modifier"] = attributes.cached_diceroll_modifier

	var/list/bonuses = admin_bonuses(attributes)
	var/list/compiled_attributes = list()
	var/list/compiled_skills = list()
	var/skill_prefix = "[/datum/attribute/skill]/"
	for(var/datum/attribute/attribute as anything in GLOB.all_attributes)
		var/list/this_attribute = list()

		attribute = GLOB.all_attributes[attribute]
		this_attribute["name"] = attribute.name
		this_attribute["desc"] = attribute.desc
		this_attribute["type"] = attribute.type
		this_attribute["value"] = attributes.attribute_list[attribute.type]
		this_attribute["raw_value"] = attributes.raw_attribute_list[attribute.type]
		this_attribute["admin_bonus"] = bonuses[attribute.type] || 0

		if(istype(attribute, /datum/attribute/skill))
			this_attribute["group"] = attribute_editor_skill_group(attribute.type, skill_prefix)
			compiled_skills += list(this_attribute)
		else
			compiled_attributes += list(this_attribute)
	data["attributes"] = compiled_attributes
	data["skills"] = compiled_skills
	return data

/// Reads an attribute typepath sent by the window. Returns null for anything that is not one.
/datum/attribute_editor/proc/read_attribute_type(path_text)
	var/attribute_type = istext(path_text) ? text2path(path_text) : null
	if(!ispath(attribute_type, /datum/attribute) || !GLOB.all_attributes[attribute_type])
		return null
	return attribute_type

/datum/attribute_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/datum/attribute_holder/attributes = target?.resolve()
	if(!attributes)
		to_chat(usr, span_warning("The target attribute holder is gone."))
		qdel(src)
		return
	var/static/list/editable_vars = list("attribute_min", "attribute_max", "attribute_default", "skill_min", "skill_max", "skill_default")
	var/who = "[key_name(usr)] (Attribute Editor, [attributes.parent])"
	switch(action)
		if("change_diceroll_modifier")
			var/new_value = text2num("[params["new_value"]]")
			if(!isnum(new_value))
				return FALSE
			attributes.add_or_update_variable_diceroll_modifier(/datum/diceroll_modifier/attribute_editor, new_value)
			log_admin("[who] set the diceroll modifier to [new_value].")
		if("change_var", "null_var")
			var/attribute_var_name = params["var_name"]
			if(!(attribute_var_name in editable_vars))
				return FALSE
			var/attribute_var_value = null
			if(action == "change_var")
				attribute_var_value = text2num("[params["var_value"]]")
				if(!isnum(attribute_var_value))
					return FALSE
			if(attributes.vv_edit_var(attribute_var_name, attribute_var_value) == FALSE)
				to_chat(usr, span_warning("The attribute holder rejected that edit. This is a bug in the Attribute Editor, please report it."))
				return
			attributes.update_attributes()
			log_admin("[who] set [attribute_var_name] to [isnull(attribute_var_value) ? "null" : attribute_var_value].")
		if("change_attribute", "null_attribute")
			var/attribute_type = read_attribute_type(params["attribute_type"])
			if(!attribute_type)
				return FALSE
			var/list/new_values = admin_bonuses(attributes)
			var/new_value = action == "change_attribute" ? text2num("[params["new_value"]]") : 0
			if(!isnum(new_value))
				return FALSE
			if(new_value)
				new_values[attribute_type] = new_value
			else
				new_values -= attribute_type
			attributes.add_or_update_variable_attribute_modifier(/datum/attribute_modifier/attribute_editor, TRUE, new_values)
			log_admin("[who] set the admin bonus of [attribute_type] to [new_value].")
		if("reset_bonuses")
			attributes.add_or_update_variable_attribute_modifier(/datum/attribute_modifier/attribute_editor, TRUE, list())
			log_admin("[who] cleared every admin bonus.")
		if("change_raw_attribute")
			var/attribute_type = read_attribute_type(params["attribute_type"])
			var/new_value = text2num("[params["new_value"]]")
			if(!attribute_type || !isnum(new_value))
				return FALSE
			var/min_value = attributes.attribute_min
			var/max_value = attributes.attribute_max
			if(ispath(attribute_type, /datum/attribute/skill))
				min_value = attributes.skill_min
				max_value = attributes.skill_max
			if(isnum(min_value) && isnum(max_value))
				new_value = clamp(new_value, min_value, max_value)
			attributes.raw_attribute_list[attribute_type] = new_value
			attributes.update_attributes()
			attributes.seed_skill_xp(attribute_type)
			log_admin("[who] set the base value of [attribute_type] to [new_value].")
		if("null_raw_attribute")
			var/attribute_type = read_attribute_type(params["attribute_type"])
			if(!attribute_type)
				return FALSE
			attributes.raw_attribute_list[attribute_type] = null
			attributes.update_attributes()
			log_admin("[who] reset the base value of [attribute_type] to the default.")
		else
			return FALSE

	return TRUE

/// "/datum/attribute/skill/combat/swords" -> "combat". Paths never change, so each is parsed once.
/proc/attribute_editor_skill_group(skill_type, skill_prefix)
	var/static/list/groups = list()
	. = groups[skill_type]
	if(.)
		return
	var/list/segments = splittext(copytext("[skill_type]", length(skill_prefix) + 1), "/")
	. = length(segments) >= 2 ? segments[1] : "other"
	groups[skill_type] = .
