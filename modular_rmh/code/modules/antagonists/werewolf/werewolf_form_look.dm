GLOBAL_LIST_INIT(werewolf_form_looks, init_werewolf_form_looks())

/proc/init_werewolf_form_looks()
	var/list/looks = list()
	for(var/look_type in subtypesof(/datum/werewolf_form_look))
		var/datum/werewolf_form_look/look = new look_type
		looks[look.id] = look
	return looks

/// The look registered under [id], or the lean look when the id is unknown.
/proc/get_werewolf_form_look(id)
	RETURN_TYPE(/datum/werewolf_form_look)
	if(id)
		. = GLOB.werewolf_form_looks[id]
	if(!.)
		. = GLOB.werewolf_form_looks[WEREWOLF_LOOK_LEAN]

/// One beast art set. Every sheet ships the same state names.
/datum/werewolf_form_look
	var/id
	var/name
	var/icon
	/// Base offsets that centre the sheet's body on its tile.
	var/pixel_x = 0
	var/pixel_y = 0
	var/body_state_male = "wwolf_m"
	var/body_state_female = "wwolf_f"
	var/damage_state_male = "wwolf_m-dam"
	var/damage_state_female = "wwolf_f-dam"
	var/eyes_state = "eyes"
	var/dead_state = "wwolf_dead"
	var/dead_damage_state = "wwolf_dead-dam"
	var/penis_half_state = "penis_half"
	var/penis_full_state = "penis_full"

/datum/werewolf_form_look/proc/get_body_state(gender)
	return gender == MALE ? body_state_male : body_state_female

/datum/werewolf_form_look/proc/get_damage_state(gender)
	return gender == MALE ? damage_state_male : damage_state_female

/// Penis overlay state for an arousal value, or null while soft.
/datum/werewolf_form_look/proc/get_penis_state(arousal)
	if(arousal >= WW_PENIS_FULL_AROUSAL)
		return penis_full_state
	if(arousal >= WW_PENIS_HALF_AROUSAL)
		return penis_half_state
	return null

/// Whether the sheet has [state]; overlays skip states a sheet lacks.
/datum/werewolf_form_look/proc/has_state(state)
	if(!state || !icon)
		return FALSE
	var/static/list/states_by_icon
	states_by_icon ||= list()
	var/icon_key = "[icon]"
	var/list/states = states_by_icon[icon_key]
	if(!states)
		states = list()
		for(var/sheet_state in icon_states(icon))
			states[sheet_state] = TRUE
		states_by_icon[icon_key] = states
	return states[state] ? TRUE : FALSE

/datum/werewolf_form_look/lean
	id = WEREWOLF_LOOK_LEAN
	name = "Lean"
	icon = 'modular_rmh/icons/mob/monster/werewolf.dmi'
	// The sheet draws its body in the left 32 columns, feet on the bottom row, so no shift.

/datum/werewolf_form_look/feral
	id = WEREWOLF_LOOK_FERAL
	name = "Feral"
	icon = 'modular_rmh/icons/mob/monster/werewolf_feral.dmi'
	// Azure Peak body spans the full 48 columns; shift it onto the tile.
	pixel_x = -8

/datum/werewolf_form_look/classic
	id = WEREWOLF_LOOK_CLASSIC
	name = "Classic"
	icon = 'modular_rmh/icons/mob/monster/werewolf_hunched.dmi'
