/obj/structure/dungeon_gate
	name = "shifting passage"
	desc = "An archway of stone that was not there a moment ago. The space beyond refuses to settle."
	icon = 'icons/roguetown/misc/doors.dmi'
	icon_state = "wcv"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// DUNGEON_GATE_* role
	var/gate_role = DUNGEON_GATE_FORWARD
	/// Run that owns this gate
	var/datum/dungeon_run/owning_run
	/// Room this gate stands in
	var/datum/pocket_dimension/dungeon/source_room
	/// Destination room; lazily created for forward gates
	var/datum/pocket_dimension/dungeon/destination_room
	/// Template a forward gate will instantiate on first use
	var/datum/map_template/pocket/dungeon/pre_rolled_template
	/// Stable geometry seed for this destination, including retries before traversal succeeds.
	var/generation_seed = 0
	/// Forward gates stay sealed until the room is cleared
	var/sealed = FALSE
	/// DUNGEON_PATH_* — risk/reward flavor of the room beyond
	var/path_type = DUNGEON_PATH_COMBAT
	/// DUNGEON_REWARD_* this door promises for clearing the room beyond
	var/reward_type = DUNGEON_REWARD_MOTES
	/// When set, this gate stays locked until a matching key is applied
	var/requires_key = FALSE
	/// Key id this gate accepts
	var/key_id = "default"
	/// Whether the key lock has been opened
	var/key_unlocked = FALSE
	/// TRUE once a sibling door was chosen instead - the path is committed,
	/// this passage never opens again
	var/forsaken = FALSE
	/// DUNGEON_POP_* - set when this door leads to a special (non-combat) room;
	/// replaces the reward promise with a telegraph of what waits beyond
	var/special_kind

/obj/structure/dungeon_gate/Destroy()
	owning_run = null
	source_room = null
	destination_room = null
	pre_rolled_template = null
	return ..()

/obj/structure/dungeon_gate/examine(mob/user)
	. = ..()
	if(forsaken)
		. += span_warning("It has fused into dead stone. The party chose another path - this one is gone forever.")
		return
	if(requires_key && !key_unlocked)
		. += span_warning("It is locked. A key lies somewhere in this room.")
	if(sealed)
		. += span_warning("It is sealed shut. The hostile presence in this room holds it closed.")
	else if(gate_role == DUNGEON_GATE_BACK)
		. += span_notice("It leads back the way I came.")
	else if(gate_role == DUNGEON_GATE_DESCENT)
		. += span_notice("A stairway plunges deeper. The air below is colder, hungrier.")
	else if(pre_rolled_template)
		var/transition_text = get_transition_destination_text()
		. += span_notice(pre_rolled_template.gate_hint)
		if(leads_to_boss())
			. += span_boldwarning("Beyond this passage, something vast is waiting. The floor's master.")
		else if(transition_text)
			. += span_boldnotice(transition_text)
		else if(special_kind)
			. += span_boldnotice(get_special_kind_text())
		else if(reward_type)
			. += span_notice(get_reward_promise_text())
			. += span_notice("Danger: [get_path_danger_text()].")

/// TRUE when this door's pre-rolled destination is the floor's boss room.
/obj/structure/dungeon_gate/proc/leads_to_boss()
	var/datum/map_template/pocket/dungeon/next_template = pre_rolled_template
	return !!(next_template && next_template.room_kind == DUNGEON_ROOM_BOSS)

/// Describes structural floor transitions that should not carry combat-door
/// danger or reward promises.
/obj/structure/dungeon_gate/proc/get_transition_destination_text()
	var/datum/map_template/pocket/dungeon/next_template = pre_rolled_template
	if(!next_template)
		return null
	var/datum/map_template/pocket/dungeon/source_template = source_room?.get_dungeon_template()
	if(source_template?.room_kind == DUNGEON_ROOM_BREAK && owning_run?.boss_defeated_this_floor)
		return "This passage leads to the entrance of the next floor."
	if(source_template?.room_kind == DUNGEON_ROOM_BOSS)
		if(next_template.room_kind == DUNGEON_ROOM_BREAK)
			if(sealed)
				return "A place of respite waits beyond, sealed until the floor's master falls."
			return "The floor's master has fallen. A place of respite waits beyond."
		if(next_template.room_kind == DUNGEON_ROOM_DESCENT)
			if(sealed)
				return "The way to the next floor waits beyond, sealed until its master falls."
			return "The floor's master has fallen. The way descends to the next floor."
	switch(next_template.room_kind)
		if(DUNGEON_ROOM_BREAK)
			return "A place of respite waits beyond."
		if(DUNGEON_ROOM_DESCENT)
			return "This passage leads to the entrance of the next floor."
	return null

/obj/structure/dungeon_gate/proc/get_reward_promise_text()
	switch(reward_type)
		if(DUNGEON_REWARD_BOON)
			return "Beyond this passage, a blessing awaits."
		if(DUNGEON_REWARD_LOOT)
			return "The smell of old gold seeps through."
		if(DUNGEON_REWARD_VAULT)
			return "Something locked and heavy with treasure waits beyond."
		if(DUNGEON_REWARD_HEAL)
			return "Warm, clean air drifts from beyond."
	return "You hear the faint chime of motes beyond."

/obj/structure/dungeon_gate/proc/get_path_danger_text()
	switch(path_type)
		if(DUNGEON_PATH_TREASURE)
			return "low"
		if(DUNGEON_PATH_SHORTCUT)
			return "low"
		if(DUNGEON_PATH_HAZARD)
			return "high"
		if(DUNGEON_PATH_ELITE)
			return "very high"
	return "moderate"

/obj/structure/dungeon_gate/proc/get_special_kind_text()
	switch(special_kind)
		if(DUNGEON_POP_TRADER)
			return "A haggling voice drifts through the stone."
		if(DUNGEON_POP_MYSTERY)
			return "A strange, watchful stillness waits beyond."
		if(DUNGEON_POP_WAVES)
			return "War-drums beat somewhere past this arch."
	return null


/obj/structure/dungeon_gate/attack_hand(mob/user, list/modifiers)
	. = ..()
	// Players get the full gate panel; anything mindless falls through to nothing.
	if(user.client)
		ui_interact(user)
		return
	use_gate(user)

/obj/structure/dungeon_gate/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/dungeon_gate/ui_interact(mob/user, datum/tgui/ui)
	if(!can_gate_interact(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DungeonGate")
		ui.open()

/obj/structure/dungeon_gate/ui_data(mob/user)
	var/list/data = list()
	data["role"] = gate_role
	data["sealed"] = sealed
	data["forsaken"] = forsaken
	data["locked"] = (requires_key && !key_unlocked)
	var/boss_ahead = leads_to_boss()
	var/transition_text = get_transition_destination_text()
	data["boss_ahead"] = boss_ahead
	data["destination_text"] = transition_text
	data["reward_text"] = (gate_role == DUNGEON_GATE_BACK || special_kind || boss_ahead || transition_text || !reward_type) ? null : get_reward_promise_text()
	data["danger_text"] = (gate_role == DUNGEON_GATE_BACK || boss_ahead || transition_text) ? null : get_path_danger_text()
	data["special_text"] = special_kind ? get_special_kind_text() : null
	data["hint"] = pre_rolled_template?.gate_hint
	data["back_available"] = (gate_role == DUNGEON_GATE_BACK) ? (destination_room && !QDELETED(destination_room)) : TRUE

	var/list/missing = list()
	var/is_leader = FALSE
	if(owning_run && !QDELETED(owning_run))
		if(gate_role != DUNGEON_GATE_BACK && !QDELETED(source_room))
			missing = owning_run.get_muster_missing(source_room)
		is_leader = owning_run.is_run_leader(user)
	data["muster_missing"] = missing
	data["is_leader"] = is_leader
	return data

/obj/structure/dungeon_gate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	if(!isliving(user) || !can_gate_interact(user))
		return
	switch(action)
		if("traverse")
			ui.close()
			use_gate(user)
			return TRUE
		if("force")
			if(!can_use_gate(user) || gate_role == DUNGEON_GATE_BACK || !owning_run.is_run_leader(user))
				return
			ui.close()
			if(user.client)
				user.visible_message(span_notice("[user] begins working the passage open..."), span_notice("I begin working the passage open..."))
				if(!do_after(user, DUNGEON_GATE_TRAVERSE_TIME, src))
					return TRUE
			if(!can_use_gate(user) || gate_role == DUNGEON_GATE_BACK || !owning_run.is_run_leader(user))
				return TRUE
			owning_run.muster_advance(src, user, force = TRUE)
			return TRUE

/obj/structure/dungeon_gate/attack_animal(mob/user, list/modifiers)
	use_gate(user)

/obj/structure/dungeon_gate/attack_paw(mob/user, list/modifiers)
	use_gate(user)

/obj/structure/dungeon_gate/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(requires_key && !key_unlocked && istype(attacking_item, /obj/item/dungeon_key))
		if(!can_gate_interact(user) || !owning_run.is_party_member(user))
			return TRUE
		var/obj/item/dungeon_key/key = attacking_item
		if(key.key_id != key_id)
			to_chat(user, span_warning("This key does not fit this passage."))
			return TRUE
		key_unlocked = TRUE
		qdel(key)
		visible_message(span_nicegreen("[src] grinds open as the key dissolves into light!"))
		return TRUE
	return ..()

/obj/structure/dungeon_gate/proc/use_gate(mob/living/user)
	if(!can_use_gate(user))
		return FALSE
	// Working a passage open takes a moment (players only; the harness and any
	// odd mob paths stay instant).
	if(user.client)
		user.visible_message(span_notice("[user] begins working the passage open..."), span_notice("I begin working the passage open..."))
		if(!do_after(user, DUNGEON_GATE_TRAVERSE_TIME, src))
			return FALSE
		if(!can_use_gate(user))
			return FALSE
	if(gate_role == DUNGEON_GATE_BACK)
		// Backtracking is free: any present member may step back alone.
		var/datum/pocket_dimension/dungeon/back_room = resolve_destination()
		if(!back_room)
			to_chat(user, span_warning("The way back has crumbled."))
			return FALSE
		return transfer_through(user, back_room)
	if(destination_room && !QDELETED(destination_room))
		for(var/mob/living/advanced_member as anything in owning_run.get_members_in_room(destination_room))
			if(owning_run.is_party_member(advanced_member))
				return transfer_through(user, destination_room)
	if(owning_run.is_forced_entrant(user))
		// Captives may follow a route the expedition already opened, but may not
		// choose or instantiate a route of their own.
		if(destination_room && !QDELETED(destination_room))
			return transfer_through(user, destination_room)
		to_chat(user, span_warning("The passage will not answer your hand. Only the expedition may choose the road ahead."))
		return FALSE
	// Forward / descent gates move the whole present party together (muster).
	return owning_run.muster_advance(src, user)

/obj/structure/dungeon_gate/proc/can_gate_interact(mob/living/user)
	if(!istype(user) || QDELETED(src))
		return FALSE
	if(user.client && !user.Adjacent(src))
		return FALSE
	if(!user.mind && !user.client)
		return FALSE
	if(!owning_run || QDELETED(owning_run) || QDELETED(source_room) || owning_run.ending)
		return FALSE
	if(!source_room.contains_turf(get_turf(user)))
		return FALSE
	return owning_run.is_run_participant(user)

/obj/structure/dungeon_gate/proc/can_use_gate(mob/living/user, show_feedback = TRUE)
	if(!can_gate_interact(user))
		return FALSE
	if(forsaken)
		if(show_feedback)
			to_chat(user, span_warning("The passage is dead stone. The path was chosen, and it was not this one."))
		return FALSE
	if(sealed)
		if(show_feedback)
			to_chat(user, span_warning("The passage is sealed. Whatever guards this room holds it shut."))
		return FALSE
	if(requires_key && !key_unlocked)
		if(show_feedback)
			to_chat(user, span_warning("This passage is locked. It needs a key found within this room."))
		return FALSE
	return TRUE

/obj/structure/dungeon_gate/attack_hand_secondary(mob/user, list/modifiers)
	// Right-click no longer force-opens the room instantly - it funnels through
	// the same panel as left-click. The panel's leader-gated Force button is the
	// only way to force a march, and it runs the do_after and the muster checks.
	if(user.client)
		ui_interact(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/dungeon_gate/proc/resolve_destination()
	if(destination_room && !QDELETED(destination_room))
		return destination_room
	destination_room = null
	if((gate_role != DUNGEON_GATE_FORWARD && gate_role != DUNGEON_GATE_DESCENT) || !pre_rolled_template)
		return null
	destination_room = owning_run.instantiate_room_for_gate(src)
	return destination_room

/obj/structure/dungeon_gate/proc/transfer_through(mob/living/user, datum/pocket_dimension/dungeon/target_room)
	var/turf/entry_turf = target_room.get_entry_turf()
	if(!entry_turf)
		return FALSE

	// Bring along whatever the user is dragging - mobs, crates, corpses, anything.
	var/list/atom/movable/dragged = list()
	if(user.pulling && !QDELETED(user.pulling))
		dragged += user.pulling
	for(var/obj/item/grabbing/grab_item in user.held_items)
		if(grab_item.grabbed && !QDELETED(grab_item.grabbed) && ismovable(grab_item.grabbed))
			dragged |= grab_item.grabbed

	user.forceMove(entry_turf)
	if(get_turf(user) != entry_turf)
		return FALSE
	if(source_room && !QDELETED(source_room) && source_room.current_trait)
		source_room.current_trait.on_mob_exited(source_room, user)
	for(var/atom/movable/cargo as anything in dragged)
		var/turf/drop_turf = target_room.get_drop_turf(cargo) || entry_turf
		cargo.forceMove(drop_turf)
		if(isliving(cargo))
			var/mob/living/dragged_living = cargo
			if(!owning_run.is_run_participant(dragged_living))
				owning_run.add_forced_entrant(dragged_living)
			source_room?.current_trait?.on_mob_exited(source_room, dragged_living)
			owning_run.on_member_entered_room(target_room, dragged_living)
	target_room.touch()
	source_room?.touch()
	owning_run.on_room_entered(target_room, user)
	to_chat(user, span_notice("I step through, and the passage seals behind my heels."))
	return TRUE
