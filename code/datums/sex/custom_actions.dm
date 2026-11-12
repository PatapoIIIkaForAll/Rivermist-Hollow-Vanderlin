/datum/sex_custom_action_template
	abstract_type = /datum/sex_custom_action_template
	var/template_id = null
	var/template_name = "Custom Action"
	var/template_summary = "Start from a blank draft."

/datum/sex_custom_action_template/proc/build_draft()
	var/datum/sex_custom_action_data/draft = new
	draft.template_id = template_id
	draft.name = template_name
	apply_to(draft)
	draft.normalize()
	return draft

/datum/sex_custom_action_template/proc/apply_to(datum/sex_custom_action_data/draft)
	return

/datum/sex_custom_action_template/blank_partner
	template_id = "blank_partner"
	template_name = "Partner Action"
	template_summary = "A clean slate for actions aimed at another participant."

/datum/sex_custom_action_template/blank_partner/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_PARTNER
	draft.required_user_part = SEX_CUSTOM_PART_HANDS
	draft.required_target_part = SEX_CUSTOM_PART_BODY
	draft.requires_free_hands = TRUE
	draft.message_start = "{user} starts {name} with {target}."
	draft.message_tick = "{user} keeps {name} going."
	draft.message_finish = "{user} stops {name}."

/datum/sex_custom_action_template/blank_self
	template_id = "blank_self"
	template_name = "Solo Action"
	template_summary = "A clean slate for actions you perform on yourself."

/datum/sex_custom_action_template/blank_self/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_SELF
	draft.required_user_part = SEX_CUSTOM_PART_HANDS
	draft.required_target_part = SEX_CUSTOM_PART_ANY_GENITALS
	draft.requires_free_hands = TRUE
	draft.message_start = "{user} starts {name}."
	draft.message_tick = "{user} keeps {name} going."
	draft.message_finish = "{user} stops {name}."

/datum/sex_custom_action_template/handplay
	template_id = "handplay"
	template_name = "Hand Play"
	template_summary = "Hands on a partner's sensitive parts."

/datum/sex_custom_action_template/handplay/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_PARTNER
	draft.required_user_part = SEX_CUSTOM_PART_HANDS
	draft.required_target_part = SEX_CUSTOM_PART_ANY_GENITALS
	draft.requires_free_hands = TRUE
	draft.target_arousal = 2
	draft.target_orgasm = 1.5
	draft.user_arousal = 0.6
	draft.user_orgasm = 0.25
	draft.message_start = "{user} starts working {target}'s {target_part} with {user_their} hands."
	draft.message_tick = "{user} keeps teasing {target}'s {target_part} with {force} strokes."
	draft.message_finish = "{user} lets go of {target}'s {target_part}."
	draft.message_climax_active = "{user} climaxes from keeping {name} going!"
	draft.message_climax_passive = "{user} climaxes under {target}'s touch!"

/datum/sex_custom_action_template/oral
	template_id = "oral"
	template_name = "Oral Play"
	template_summary = "Mouth on a partner's genitals."

/datum/sex_custom_action_template/oral/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_PARTNER
	draft.required_user_part = SEX_CUSTOM_PART_MOUTH
	draft.required_target_part = SEX_CUSTOM_PART_ANY_GENITALS
	draft.gags_user = TRUE
	draft.target_arousal = 2.2
	draft.target_orgasm = 2
	draft.user_arousal = 1
	draft.user_orgasm = 0.25
	draft.message_start = "{user} lowers {user_their} mouth onto {target}'s {target_part}."
	draft.message_tick = "{user} keeps pleasuring {target}'s {target_part} with {user_their} mouth."
	draft.message_finish = "{user} lifts {user_their} mouth away from {target}."
	draft.message_climax_active = "{user} climaxes from the taste and tension of {name}!"
	draft.message_climax_passive = "{user} climaxes into {target}'s mouth!"
	draft.active_climax_location = ORGASM_LOCATION_SELF
	draft.passive_climax_location = ORGASM_LOCATION_ORAL

/datum/sex_custom_action_template/bodyplay
	template_id = "bodyplay"
	template_name = "Body Play"
	template_summary = "Broad touching, rubbing, or teasing across the body."

/datum/sex_custom_action_template/bodyplay/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_PARTNER
	draft.required_user_part = SEX_CUSTOM_PART_HANDS
	draft.required_target_part = SEX_CUSTOM_PART_BODY
	draft.requires_free_hands = TRUE
	draft.target_arousal = 0.8
	draft.target_orgasm = 0.6
	draft.user_arousal = 0.4
	draft.message_start = "{user} starts running {user_their} hands over {target}'s body."
	draft.message_tick = "{user} keeps tracing {target}'s body with {force} touches."
	draft.message_finish = "{user} eases {user_their} hands away from {target}."

/datum/sex_custom_action_template/penetration
	template_id = "penetration"
	template_name = "Penetration"
	template_summary = "A penis-focused thrusting template."

/datum/sex_custom_action_template/penetration/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_PARTNER
	draft.required_user_part = SEX_CUSTOM_PART_PENIS
	draft.required_target_part = SEX_CUSTOM_PART_VAGINA
	draft.target_arousal = 2.5
	draft.target_orgasm = 2.2
	draft.user_arousal = 1.5
	draft.user_orgasm = 1.2
	draft.message_start = "{user} presses {user_their} {user_part} against {target}'s {target_part}."
	draft.message_tick = "{user} keeps thrusting into {target} at a {speed} pace."
	draft.message_finish = "{user} pulls back and stops {name}."
	draft.message_climax_active = "{user} climaxes deep inside {target}!"
	draft.message_climax_passive = "{user} climaxes from being filled by {target}!"
	draft.active_climax_location = ORGASM_LOCATION_INTO
	draft.passive_climax_location = ORGASM_LOCATION_SELF

/datum/sex_custom_action_template/footplay
	template_id = "footplay"
	template_name = "Foot Play"
	template_summary = "Feet teasing or stimulating a partner."

/datum/sex_custom_action_template/footplay/apply_to(datum/sex_custom_action_data/draft)
	draft.action_scope = SEX_CUSTOM_SCOPE_PARTNER
	draft.required_user_part = SEX_CUSTOM_PART_FEET
	draft.required_target_part = SEX_CUSTOM_PART_ANY_GENITALS
	draft.target_arousal = 1.5
	draft.target_orgasm = 1.2
	draft.user_arousal = 0.5
	draft.message_start = "{user} hooks {user_their} feet around {target}'s {target_part}."
	draft.message_tick = "{user} keeps teasing {target}'s {target_part} with slow, deliberate footwork."
	draft.message_finish = "{user} slips {user_their} feet away from {target}."

GLOBAL_LIST_INIT(sex_custom_action_templates, build_sex_custom_action_templates())

/proc/build_sex_custom_action_templates()
	. = list()
	for(var/datum/sex_custom_action_template/template_type as anything in typesof(/datum/sex_custom_action_template))
		if(IS_ABSTRACT(template_type))
			continue
		var/datum/sex_custom_action_template/template = new template_type()
		if(!template.template_id)
			continue
		.[template.template_id] = template

/datum/sex_custom_action_data
	var/id = null
	var/template_id = null
	var/name = "Custom Action"
	var/action_scope = SEX_CUSTOM_SCOPE_PARTNER
	var/required_user_part = SEX_CUSTOM_PART_HANDS
	var/required_target_part = SEX_CUSTOM_PART_BODY
	var/require_same_tile = FALSE
	var/require_grab = FALSE
	var/requires_free_hands = FALSE
	var/gags_user = FALSE
	var/gags_target = FALSE
	var/do_time_seconds = 3.3
	var/stamina_cost = 0.5
	var/user_arousal = 0
	var/user_pain = 0
	var/user_orgasm = 0
	var/target_arousal = 0
	var/target_pain = 0
	var/target_orgasm = 0
	var/message_start = null
	var/message_tick = null
	var/message_finish = null
	var/message_climax_active = null
	var/message_climax_passive = null
	var/active_climax_location = null
	var/passive_climax_location = null
	var/created = null
	var/last_modified = null

/datum/sex_custom_action_data/proc/copy()
	var/datum/sex_custom_action_data/copy = new
	copy.id = id
	copy.template_id = template_id
	copy.name = name
	copy.action_scope = action_scope
	copy.required_user_part = required_user_part
	copy.required_target_part = required_target_part
	copy.require_same_tile = require_same_tile
	copy.require_grab = require_grab
	copy.requires_free_hands = requires_free_hands
	copy.gags_user = gags_user
	copy.gags_target = gags_target
	copy.do_time_seconds = do_time_seconds
	copy.stamina_cost = stamina_cost
	copy.user_arousal = user_arousal
	copy.user_pain = user_pain
	copy.user_orgasm = user_orgasm
	copy.target_arousal = target_arousal
	copy.target_pain = target_pain
	copy.target_orgasm = target_orgasm
	copy.message_start = message_start
	copy.message_tick = message_tick
	copy.message_finish = message_finish
	copy.message_climax_active = message_climax_active
	copy.message_climax_passive = message_climax_passive
	copy.active_climax_location = active_climax_location
	copy.passive_climax_location = passive_climax_location
	copy.created = created
	copy.last_modified = last_modified
	return copy

/datum/sex_custom_action_data/proc/normalize()
	name = trim("[name]")
	if(!length(name))
		name = "Custom Action"

	action_scope = clamp(text2num_safe(action_scope), SEX_CUSTOM_SCOPE_PARTNER, SEX_CUSTOM_SCOPE_SELF)
	if(action_scope != SEX_CUSTOM_SCOPE_PARTNER && action_scope != SEX_CUSTOM_SCOPE_SELF)
		action_scope = SEX_CUSTOM_SCOPE_PARTNER

	required_user_part = sanitize_custom_sex_part(required_user_part)
	required_target_part = sanitize_custom_sex_part(required_target_part)
	require_same_tile = !!require_same_tile
	require_grab = !!require_grab
	requires_free_hands = !!requires_free_hands
	gags_user = !!gags_user
	gags_target = !!gags_target
	do_time_seconds = clamp(text2num_safe(do_time_seconds, 3.3), 0.5, 10)
	stamina_cost = clamp(text2num_safe(stamina_cost, 0.5), 0, 10)
	user_arousal = clamp(text2num_safe(user_arousal), 0, 10)
	user_pain = clamp(text2num_safe(user_pain), 0, 10)
	user_orgasm = clamp(text2num_safe(user_orgasm), 0, 10)
	target_arousal = clamp(text2num_safe(target_arousal), 0, 10)
	target_pain = clamp(text2num_safe(target_pain), 0, 10)
	target_orgasm = clamp(text2num_safe(target_orgasm), 0, 10)
	message_start = normalize_custom_action_text(message_start)
	message_tick = normalize_custom_action_text(message_tick)
	message_finish = normalize_custom_action_text(message_finish)
	message_climax_active = normalize_custom_action_text(message_climax_active)
	message_climax_passive = normalize_custom_action_text(message_climax_passive)
	active_climax_location = sanitize_custom_climax_location(active_climax_location)
	passive_climax_location = sanitize_custom_climax_location(passive_climax_location)

/datum/sex_custom_action_data/proc/export_to_save()
	normalize()
	return list(
		"id" = id,
		"template_id" = template_id,
		"name" = name,
		"action_scope" = action_scope,
		"required_user_part" = required_user_part,
		"required_target_part" = required_target_part,
		"require_same_tile" = require_same_tile,
		"require_grab" = require_grab,
		"requires_free_hands" = requires_free_hands,
		"gags_user" = gags_user,
		"gags_target" = gags_target,
		"do_time_seconds" = do_time_seconds,
		"stamina_cost" = stamina_cost,
		"user_arousal" = user_arousal,
		"user_pain" = user_pain,
		"user_orgasm" = user_orgasm,
		"target_arousal" = target_arousal,
		"target_pain" = target_pain,
		"target_orgasm" = target_orgasm,
		"message_start" = message_start,
		"message_tick" = message_tick,
		"message_finish" = message_finish,
		"message_climax_active" = message_climax_active,
		"message_climax_passive" = message_climax_passive,
		"active_climax_location" = active_climax_location,
		"passive_climax_location" = passive_climax_location,
		"created" = created,
		"last_modified" = last_modified,
	)

/datum/sex_custom_action_data/proc/import_from_save(list/data)
	if(!islist(data))
		return FALSE
	id = "[data["id"]]"
	template_id = data["template_id"]
	name = data["name"]
	action_scope = data["action_scope"]
	required_user_part = data["required_user_part"]
	required_target_part = data["required_target_part"]
	require_same_tile = data["require_same_tile"]
	require_grab = data["require_grab"]
	requires_free_hands = data["requires_free_hands"]
	gags_user = data["gags_user"]
	gags_target = data["gags_target"]
	do_time_seconds = data["do_time_seconds"]
	stamina_cost = data["stamina_cost"]
	user_arousal = data["user_arousal"]
	user_pain = data["user_pain"]
	user_orgasm = data["user_orgasm"]
	target_arousal = data["target_arousal"]
	target_pain = data["target_pain"]
	target_orgasm = data["target_orgasm"]
	message_start = data["message_start"]
	message_tick = data["message_tick"]
	message_finish = data["message_finish"]
	message_climax_active = data["message_climax_active"]
	message_climax_passive = data["message_climax_passive"]
	active_climax_location = data["active_climax_location"]
	passive_climax_location = data["passive_climax_location"]
	created = data["created"]
	last_modified = data["last_modified"]
	normalize()
	return TRUE

/proc/text2num_safe(value, fallback = 0)
	if(isnum(value))
		return value
	if(isnull(value))
		return fallback
	var/number = text2num("[value]")
	if(isnull(number))
		return fallback
	return number

/proc/normalize_custom_action_text(value)
	if(isnull(value))
		return null
	var/text = trim("[value]")
	if(!length(text))
		return null
	return text

/proc/sanitize_custom_sex_part(part_value)
	var/part = text2num_safe(part_value, SEX_CUSTOM_PART_NONE)
	switch(part)
		if(SEX_CUSTOM_PART_NONE, SEX_CUSTOM_PART_MOUTH, SEX_CUSTOM_PART_PENIS, SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS, SEX_CUSTOM_PART_BREASTS, SEX_CUSTOM_PART_TESTICLES, SEX_CUSTOM_PART_HANDS, SEX_CUSTOM_PART_FEET, SEX_CUSTOM_PART_THIGHS, SEX_CUSTOM_PART_BODY, SEX_CUSTOM_PART_ANY_GENITALS)
			return part
	return SEX_CUSTOM_PART_NONE

/proc/sanitize_custom_climax_location(location)
	if(isnull(location) || !length("[location]"))
		return null
	switch("[location]")
		if(ORGASM_LOCATION_INTO, ORGASM_LOCATION_ONTO, ORGASM_LOCATION_ORAL, ORGASM_LOCATION_SELF)
			return "[location]"
	return null

/proc/get_custom_sex_scope_label(scope)
	switch(scope)
		if(SEX_CUSTOM_SCOPE_PARTNER)
			return "Partner"
		if(SEX_CUSTOM_SCOPE_SELF)
			return "Solo"
	return "Partner"

/proc/get_custom_sex_part_label(part)
	switch(part)
		if(SEX_CUSTOM_PART_MOUTH)
			return "Mouth"
		if(SEX_CUSTOM_PART_PENIS)
			return "Penis"
		if(SEX_CUSTOM_PART_VAGINA)
			return "Vagina"
		if(SEX_CUSTOM_PART_ANUS)
			return "Anus"
		if(SEX_CUSTOM_PART_BREASTS)
			return "Breasts"
		if(SEX_CUSTOM_PART_TESTICLES)
			return "Testicles"
		if(SEX_CUSTOM_PART_HANDS)
			return "Hands"
		if(SEX_CUSTOM_PART_FEET)
			return "Feet"
		if(SEX_CUSTOM_PART_THIGHS)
			return "Thighs"
		if(SEX_CUSTOM_PART_BODY)
			return "Body"
		if(SEX_CUSTOM_PART_ANY_GENITALS)
			return "Any genitals"
	return "Unspecified"

/proc/get_custom_sex_climax_location_label(location)
	if(isnull(location))
		return "Default"
	switch("[location]")
		if(ORGASM_LOCATION_ONTO)
			return "On body"
		if(ORGASM_LOCATION_INTO)
			return "Inside"
		if(ORGASM_LOCATION_ORAL)
			return "Oral"
		if(ORGASM_LOCATION_SELF)
			return "On self"
	return "Default"

/proc/get_custom_sex_part_filter_mask(part)
	switch(part)
		if(SEX_CUSTOM_PART_MOUTH)
			return SEX_UI_ZONE_MOUTH
		if(SEX_CUSTOM_PART_PENIS, SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS, SEX_CUSTOM_PART_TESTICLES, SEX_CUSTOM_PART_ANY_GENITALS)
			return SEX_UI_ZONE_GENITALS
		if(SEX_CUSTOM_PART_HANDS)
			return SEX_UI_ZONE_ARMS
		if(SEX_CUSTOM_PART_FEET, SEX_CUSTOM_PART_THIGHS)
			return SEX_UI_ZONE_LEGS
		if(SEX_CUSTOM_PART_BREASTS, SEX_CUSTOM_PART_BODY)
			return SEX_UI_ZONE_BODY
	return SEX_UI_ZONE_MISC

/proc/get_custom_action_summary(datum/sex_custom_action_data/action_data)
	if(!action_data)
		return ""
	return "[get_custom_sex_scope_label(action_data.action_scope)] | [get_custom_sex_part_label(action_data.required_user_part)] -> [get_custom_sex_part_label(action_data.required_target_part)]"

/proc/get_custom_sex_action_save_name(character_slot = 1)
	return "character_[character_slot]_custom_actions"

/proc/get_player_custom_sex_actions(player_ckey, character_slot = 1)
	var/datum/save_manager/save_manager = get_save_manager(player_ckey)
	if(!save_manager)
		return list()

	var/list/raw_actions = save_manager.get_data(get_custom_sex_action_save_name(character_slot), "actions", list())
	var/list/custom_actions = list()
	for(var/action_id in raw_actions)
		var/list/raw_action = raw_actions[action_id]
		var/datum/sex_custom_action_data/action_data = new
		if(!action_data.import_from_save(raw_action))
			continue
		if(!length(action_data.id))
			action_data.id = "[action_id]"
		custom_actions[action_data.id] = action_data
	return custom_actions

/proc/save_player_custom_sex_actions(player_ckey, list/custom_actions, character_slot = 1)
	var/datum/save_manager/save_manager = get_save_manager(player_ckey)
	if(!save_manager)
		return FALSE

	var/list/raw_actions = list()
	for(var/action_id in custom_actions)
		var/datum/sex_custom_action_data/action_data = custom_actions[action_id]
		if(!action_data)
			continue
		raw_actions[action_id] = action_data.export_to_save()

	return save_manager.set_data(get_custom_sex_action_save_name(character_slot), "actions", raw_actions)

/proc/generate_custom_sex_action_id()
	return "action_[world.realtime]_[rand(1000, 9999)]"

/datum/sex_action/custom
	abstract_type = /datum/sex_action/custom
	var/datum/sex_custom_action_data/custom_data = null
	var/custom_action_id = null
	var/template_id = null
	var/action_scope = SEX_CUSTOM_SCOPE_PARTNER
	var/required_user_part = SEX_CUSTOM_PART_NONE
	var/required_target_part = SEX_CUSTOM_PART_NONE
	var/user_arousal = 0
	var/user_pain = 0
	var/user_orgasm = 0
	var/target_arousal = 0
	var/target_pain = 0
	var/target_orgasm = 0
	var/message_start = null
	var/message_tick = null
	var/message_finish = null
	var/message_climax_active = null
	var/message_climax_passive = null
	var/active_climax_location = null
	var/passive_climax_location = null

/datum/sex_action/custom/New(datum/sex_custom_action_data/source_data)
	. = ..()
	if(source_data)
		apply_custom_data(source_data)

/datum/sex_action/custom/proc/apply_custom_data(datum/sex_custom_action_data/source_data)
	custom_data = source_data.copy()
	custom_data.normalize()
	custom_action_id = custom_data.id
	template_id = custom_data.template_id
	name = custom_data.name
	action_scope = custom_data.action_scope
	required_user_part = custom_data.required_user_part
	required_target_part = custom_data.required_target_part
	check_same_tile = custom_data.require_same_tile
	require_grab = custom_data.require_grab
	required_grab_state = GRAB_PASSIVE
	requires_free_hands = custom_data.requires_free_hands
	gags_user = custom_data.gags_user
	gags_target = custom_data.gags_target
	do_time = max(1, round(custom_data.do_time_seconds * 10))
	stamina_cost = custom_data.stamina_cost
	user_arousal = custom_data.user_arousal
	user_pain = custom_data.user_pain
	user_orgasm = custom_data.user_orgasm
	target_arousal = custom_data.target_arousal
	target_pain = custom_data.target_pain
	target_orgasm = custom_data.target_orgasm
	message_start = custom_data.message_start
	message_tick = custom_data.message_tick
	message_finish = custom_data.message_finish
	message_climax_active = custom_data.message_climax_active
	message_climax_passive = custom_data.message_climax_passive
	active_climax_location = custom_data.active_climax_location
	passive_climax_location = custom_data.passive_climax_location
	user_menu_zone_mask = get_custom_sex_part_filter_mask(required_user_part)
	target_menu_zone_mask = get_custom_sex_part_filter_mask(required_target_part)

/datum/sex_action/custom/build_runtime_instance()
	if(custom_data)
		return new /datum/sex_action/custom(custom_data)
	return new /datum/sex_action/custom

/datum/sex_action/custom/get_menu_action_key()
	if(length(custom_action_id))
		return "[SEX_CUSTOM_ACTION_PREFIX][custom_action_id]"
	return ..()

/datum/sex_action/custom/shows_on_menu(mob/living/user, mob/living/target)
	if(action_scope == SEX_CUSTOM_SCOPE_SELF)
		return user == target
	return user != target

/datum/sex_action/custom/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!shows_on_menu(user, target))
		return FALSE
	if(!can_use_custom_part(user, target, required_user_part, TRUE))
		return FALSE
	if(!can_use_custom_part(target, user, required_target_part, FALSE))
		return FALSE
	return TRUE

/datum/sex_action/custom/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(. == FALSE)
		return FALSE
	user.visible_message(span_warning(get_custom_message(message_start, user, target, "{user} starts {name}.")))
	return TRUE

/datum/sex_action/custom/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(get_custom_message(message_tick, user, target, "{user} keeps {name} going.")))

	play_custom_feedback(user, target)

	if(target_arousal || target_pain || target_orgasm)
		perform_sex_action(target, user, target_arousal, target_pain, target_orgasm)
		handle_passive_ejaculation(target)
	if(user_arousal || user_pain || user_orgasm)
		perform_sex_action(user, target, user_arousal, user_pain, user_orgasm)
		handle_passive_ejaculation(user)

/datum/sex_action/custom/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning(get_custom_message(message_finish, user, target, "{user} stops {name}.")))

/datum/sex_action/custom/get_scene_interaction()
	if(required_user_part == SEX_CUSTOM_PART_MOUTH && (required_target_part in list(SEX_CUSTOM_PART_PENIS, SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS, SEX_CUSTOM_PART_ANY_GENITALS)))
		return SEX_SCENE_INTERACTION_ORAL
	if(required_target_part == SEX_CUSTOM_PART_MOUTH && (required_user_part in list(SEX_CUSTOM_PART_PENIS, SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS, SEX_CUSTOM_PART_ANY_GENITALS)))
		return SEX_SCENE_INTERACTION_ORAL
	if(required_user_part == SEX_CUSTOM_PART_PENIS && (required_target_part in list(SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS)))
		return SEX_SCENE_INTERACTION_PENETRATION
	if(required_target_part == SEX_CUSTOM_PART_PENIS && (required_user_part in list(SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS)))
		return SEX_SCENE_INTERACTION_PENETRATION
	return ..()

/datum/sex_action/custom/get_scene_user_role()
	var/interaction = get_scene_interaction()
	if(interaction == SEX_SCENE_INTERACTION_ORAL)
		return required_user_part == SEX_CUSTOM_PART_MOUTH ? SEX_SCENE_ROLE_GIVER : SEX_SCENE_ROLE_RECEIVER
	if(interaction == SEX_SCENE_INTERACTION_PENETRATION)
		return required_user_part == SEX_CUSTOM_PART_PENIS ? SEX_SCENE_ROLE_GIVER : SEX_SCENE_ROLE_RECEIVER
	return ..()

/datum/sex_action/custom/get_scene_user_slot()
	return get_scene_slot_for_custom_part(required_user_part)

/datum/sex_action/custom/get_scene_target_role()
	var/interaction = get_scene_interaction()
	if(interaction == SEX_SCENE_INTERACTION_ORAL)
		return required_target_part == SEX_CUSTOM_PART_MOUTH ? SEX_SCENE_ROLE_GIVER : SEX_SCENE_ROLE_RECEIVER
	if(interaction == SEX_SCENE_INTERACTION_PENETRATION)
		return required_target_part == SEX_CUSTOM_PART_PENIS ? SEX_SCENE_ROLE_GIVER : SEX_SCENE_ROLE_RECEIVER
	return ..()

/datum/sex_action/custom/get_scene_target_slot()
	return get_scene_slot_for_custom_part(required_target_part)

/datum/sex_action/custom/proc/get_scene_slot_for_custom_part(part)
	switch(part)
		if(SEX_CUSTOM_PART_MOUTH)
			return BODY_ZONE_PRECISE_MOUTH
		if(SEX_CUSTOM_PART_PENIS)
			return ORGAN_SLOT_PENIS
		if(SEX_CUSTOM_PART_VAGINA)
			return ORGAN_SLOT_VAGINA
		if(SEX_CUSTOM_PART_ANUS)
			return ORGAN_SLOT_ANUS
		if(SEX_CUSTOM_PART_BREASTS)
			return ORGAN_SLOT_BREASTS
	return part

/datum/sex_action/custom/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/message = must_flip ? message_climax_passive : message_climax_active
	var/location = must_flip ? passive_climax_location : active_climax_location
	if(message)
		user.visible_message(span_love(get_custom_message(message, user, target, "[user] climaxes!")))
	else
		user.visible_message(span_love(build_default_custom_climax_message(user, target, location)))
	return location

/datum/sex_action/custom/lock_sex_object(mob/living/user, mob/living/target)
	lock_custom_part(user, required_user_part)
	lock_custom_part(target, required_target_part)

/datum/sex_action/custom/proc/can_use_custom_part(mob/living/owner, mob/living/counterpart, part, acting_side)
	part = sanitize_custom_sex_part(part)
	switch(part)
		if(SEX_CUSTOM_PART_NONE)
			return TRUE
		if(SEX_CUSTOM_PART_MOUTH)
			return !check_sex_lock(owner, BODY_ZONE_PRECISE_MOUTH) && check_location_accessible(counterpart, owner, BODY_ZONE_PRECISE_MOUTH)
		if(SEX_CUSTOM_PART_PENIS)
			return owner.has_penis() && !check_sex_lock(owner, ORGAN_SLOT_PENIS) && check_location_accessible(counterpart, owner, BODY_ZONE_PRECISE_GROIN)
		if(SEX_CUSTOM_PART_VAGINA)
			return owner.has_vagina() && !check_sex_lock(owner, ORGAN_SLOT_VAGINA) && check_location_accessible(counterpart, owner, BODY_ZONE_PRECISE_GROIN)
		if(SEX_CUSTOM_PART_ANUS)
			return owner.getorganslot(ORGAN_SLOT_ANUS) && !check_sex_lock(owner, ORGAN_SLOT_ANUS) && check_location_accessible(counterpart, owner, BODY_ZONE_PRECISE_GROIN)
		if(SEX_CUSTOM_PART_BREASTS)
			return owner.has_breasts() && !check_sex_lock(owner, ORGAN_SLOT_BREASTS) && check_location_accessible(counterpart, owner, BODY_ZONE_CHEST)
		if(SEX_CUSTOM_PART_TESTICLES)
			return owner.has_testicles() && !check_sex_lock(owner, ORGAN_SLOT_TESTICLES) && check_location_accessible(counterpart, owner, BODY_ZONE_PRECISE_GROIN)
		if(SEX_CUSTOM_PART_HANDS)
			if(acting_side)
				return !!find_available_hand(owner)
			return !!find_accessible_custom_slot(owner, counterpart, list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		if(SEX_CUSTOM_PART_FEET)
			return !!find_accessible_custom_slot(owner, counterpart, list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
		if(SEX_CUSTOM_PART_THIGHS)
			return !!find_accessible_custom_slot(owner, counterpart, list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(SEX_CUSTOM_PART_BODY)
			return check_location_accessible(counterpart, owner, BODY_ZONE_CHEST)
		if(SEX_CUSTOM_PART_ANY_GENITALS)
			if(can_use_custom_part(owner, counterpart, SEX_CUSTOM_PART_PENIS, acting_side))
				return TRUE
			if(can_use_custom_part(owner, counterpart, SEX_CUSTOM_PART_VAGINA, acting_side))
				return TRUE
			if(can_use_custom_part(owner, counterpart, SEX_CUSTOM_PART_ANUS, acting_side))
				return TRUE
			if(can_use_custom_part(owner, counterpart, SEX_CUSTOM_PART_TESTICLES, acting_side))
				return TRUE
	return FALSE

/datum/sex_action/custom/proc/find_accessible_custom_slot(mob/living/owner, mob/living/counterpart, list/slots)
	for(var/slot in slots)
		if(check_sex_lock(owner, slot))
			continue
		if(check_location_accessible(counterpart, owner, slot))
			return slot
	return null

/datum/sex_action/custom/proc/lock_custom_part(mob/living/owner, part)
	part = sanitize_custom_sex_part(part)
	switch(part)
		if(SEX_CUSTOM_PART_MOUTH)
			add_sex_lock(owner, BODY_ZONE_PRECISE_MOUTH)
		if(SEX_CUSTOM_PART_PENIS)
			add_sex_lock(owner, ORGAN_SLOT_PENIS)
		if(SEX_CUSTOM_PART_VAGINA)
			add_sex_lock(owner, ORGAN_SLOT_VAGINA)
		if(SEX_CUSTOM_PART_ANUS)
			add_sex_lock(owner, ORGAN_SLOT_ANUS)
		if(SEX_CUSTOM_PART_BREASTS)
			add_sex_lock(owner, ORGAN_SLOT_BREASTS)
		if(SEX_CUSTOM_PART_TESTICLES)
			add_sex_lock(owner, ORGAN_SLOT_TESTICLES)
		if(SEX_CUSTOM_PART_HANDS)
			var/hand_slot = get_hand_lock_slot(owner)
			if(hand_slot)
				add_sex_lock(owner, hand_slot)
		if(SEX_CUSTOM_PART_FEET)
			var/foot_slot = find_accessible_custom_slot(owner, owner, list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
			if(foot_slot)
				add_sex_lock(owner, foot_slot)
		if(SEX_CUSTOM_PART_ANY_GENITALS)
			if(owner.getorganslot(ORGAN_SLOT_PENIS))
				add_sex_lock(owner, ORGAN_SLOT_PENIS)
			if(owner.getorganslot(ORGAN_SLOT_VAGINA))
				add_sex_lock(owner, ORGAN_SLOT_VAGINA)
			if(owner.getorganslot(ORGAN_SLOT_ANUS))
				add_sex_lock(owner, ORGAN_SLOT_ANUS)
			if(owner.getorganslot(ORGAN_SLOT_TESTICLES))
				add_sex_lock(owner, ORGAN_SLOT_TESTICLES)
		if(SEX_CUSTOM_PART_THIGHS, SEX_CUSTOM_PART_BODY)
			// Broad body areas do not map cleanly to one precise lock in the current sex-lock system.
			// If you want them to reserve a specific limb or chest slot, wire that choice here.
			return

/datum/sex_action/custom/proc/get_custom_message(template, mob/living/user, mob/living/target, fallback)
	var/message = template
	if(isnull(message) || !length("[message]"))
		message = fallback
	if(isnull(message) || !length("[message]"))
		return "[user] acts."

	var/rendered = html_encode("[message]")
	rendered = replacetext(rendered, "{name}", html_encode(name))
	rendered = replacetext(rendered, "{user}", html_encode("[user]"))
	rendered = replacetext(rendered, "{target}", html_encode("[target]"))
	rendered = replacetext(rendered, "{user_name}", html_encode(user.name))
	rendered = replacetext(rendered, "{target_name}", html_encode(target.name))
	rendered = replacetext(rendered, "{user_their}", html_encode(user.p_their()))
	rendered = replacetext(rendered, "{target_their}", html_encode(target.p_their()))
	rendered = replacetext(rendered, "{user_them}", html_encode(user.p_them()))
	rendered = replacetext(rendered, "{target_them}", html_encode(target.p_them()))
	rendered = replacetext(rendered, "{user_theirs}", html_encode(user.p_their()))
	rendered = replacetext(rendered, "{target_theirs}", html_encode(target.p_their()))
	rendered = replacetext(rendered, "{user_part}", html_encode(LOWER_TEXT(get_custom_sex_part_label(required_user_part))))
	rendered = replacetext(rendered, "{target_part}", html_encode(LOWER_TEXT(get_custom_sex_part_label(required_target_part))))
	rendered = replacetext(rendered, "{force}", html_encode(get_custom_force_word()))
	rendered = replacetext(rendered, "{speed}", html_encode(get_custom_speed_word()))
	return rendered

/datum/sex_action/custom/proc/get_custom_force_word()
	switch(force)
		if(SEX_FORCE_LOW)
			return "gentle"
		if(SEX_FORCE_MID)
			return "firm"
		if(SEX_FORCE_HIGH)
			return "rough"
		if(SEX_FORCE_EXTREME)
			return "brutal"
		if(SEX_FORCE_UNRELENTING)
			return "unrelenting"
	return "steady"

/datum/sex_action/custom/proc/get_custom_speed_word()
	switch(speed)
		if(SEX_SPEED_LOW)
			return "slow"
		if(SEX_SPEED_MID)
			return "steady"
		if(SEX_SPEED_HIGH)
			return "quick"
		if(SEX_SPEED_EXTREME)
			return "relentless"
		if(SEX_SPEED_UNRELENTING)
			return "furious"
	return "steady"

/datum/sex_action/custom/proc/build_default_custom_climax_message(mob/living/user, mob/living/target, location)
	switch(location)
		if(ORGASM_LOCATION_ONTO)
			if(target && user != target)
				return "[user] climaxes over [target]!"
			return "[user] climaxes all over [user.p_them()]self!"
		if(ORGASM_LOCATION_INTO)
			if(target && user != target)
				return "[user] climaxes inside [target]!"
			return "[user] climaxes deep inside [user.p_them()]self!"
		if(ORGASM_LOCATION_ORAL)
			if(target && user != target)
				return "[user] climaxes into [target]'s mouth!"
			return "[user] climaxes into [user.p_their()] own mouth!"
		if(ORGASM_LOCATION_SELF)
			return "[user] climaxes from [name]!"
	return "[user] climaxes!"

/datum/sex_action/custom/proc/play_custom_feedback(mob/living/user, mob/living/target)
	if(required_user_part == SEX_CUSTOM_PART_MOUTH)
		user.make_sucking_noise()
		return
	if(required_user_part == SEX_CUSTOM_PART_HANDS)
		playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
		return
	if((required_user_part in list(SEX_CUSTOM_PART_PENIS, SEX_CUSTOM_PART_THIGHS, SEX_CUSTOM_PART_BODY)) || (required_target_part in list(SEX_CUSTOM_PART_MOUTH, SEX_CUSTOM_PART_VAGINA, SEX_CUSTOM_PART_ANUS, SEX_CUSTOM_PART_ANY_GENITALS)))
		do_thrust_animate(user, target)
