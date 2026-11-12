// Party & raid management for infinite dungeon runs.
// Binds a run to a /datum/party, tracks who is physically inside (present set),
// gates advancement behind a party muster, and handles the assembly UI plus the
// lockout / petition / approval flow for outsiders.

/datum/dungeon_run/proc/bind_party(datum/party/party, mob/living/founder)
	if(istype(party))
		party_ref = WEAKREF(party)
		party_bound = TRUE
		for(var/member_ckey in party.members)
			member_ckeys |= ckey(member_ckey)
		leader_ckey = ckey(party.party_leader_ckey)
	if(istype(founder))
		member_refs |= WEAKREF(founder)
		leader_ref = WEAKREF(founder)
		if(founder.ckey)
			member_ckeys |= ckey(founder.ckey)
			if(!leader_ckey)
				leader_ckey = ckey(founder.ckey)

/datum/dungeon_run/proc/get_participant_id(mob/living/user)
	if(user?.ckey)
		return ckey(user.ckey)
	if(user?.mind?.key)
		return ckey(user.mind.key)
	return "[REF(user)]"

/datum/dungeon_run/proc/add_run_member(mob/living/user)
	if(!istype(user))
		return FALSE
	member_refs |= WEAKREF(user)
	var/member_key = user.ckey || user.mind?.key
	if(member_key)
		member_ckeys |= ckey(member_key)
	return TRUE

/datum/dungeon_run/proc/get_party()
	var/datum/party/party = party_ref?.resolve()
	if(party && !QDELETED(party))
		return party
	return null

/datum/dungeon_run/proc/is_party_member(mob/living/user)
	if(!istype(user))
		return FALSE
	var/member_key = user.ckey || user.mind?.key
	if(member_key && (ckey(member_key) in member_ckeys))
		return TRUE
	return (WEAKREF(user) in member_refs)

/datum/dungeon_run/proc/is_run_leader(mob/living/user)
	if(!is_party_member(user))
		return FALSE
	if(party_bound)
		var/datum/party/party = get_party()
		return party ? party.is_leader(user.ckey) : FALSE
	if(leader_ckey && user.ckey)
		return ckey(user.ckey) == leader_ckey
	return leader_ref?.resolve() == user

/datum/dungeon_run/proc/add_forced_entrant(mob/living/user)
	if(!istype(user) || is_party_member(user))
		return FALSE
	forced_entrant_refs |= WEAKREF(user)
	return TRUE

/datum/dungeon_run/proc/remove_forced_entrant(mob/living/user)
	if(istype(user))
		forced_entrant_refs -= WEAKREF(user)

/datum/dungeon_run/proc/is_forced_entrant(mob/living/user)
	return istype(user) && (WEAKREF(user) in forced_entrant_refs)

/datum/dungeon_run/proc/is_run_participant(mob/living/user)
	return is_party_member(user) || is_forced_entrant(user)

/datum/dungeon_run/proc/mark_present(mob/living/user)
	if(!istype(user))
		return
	// Directly constructed solo runs (notably the harness) adopt their first
	// explicitly marked delver. Live entrances bind the founder before start().
	if(!party_bound && !length(member_ckeys) && !length(member_refs))
		add_run_member(user)
		leader_ref = WEAKREF(user)
		if(user.ckey)
			leader_ckey = ckey(user.ckey)
	if(user.ckey)
		present_ckeys |= ckey(user.ckey)
	// Fall notification + wipe detection (override: re-entry re-marks freely).
	RegisterSignal(user, COMSIG_LIVING_DEFEATED, PROC_REF(on_member_defeated), override = TRUE)

/datum/dungeon_run/proc/mark_absent(mob/living/user)
	if(!istype(user))
		return
	if(user.ckey)
		present_ckeys -= ckey(user.ckey)
	UnregisterSignal(user, COMSIG_LIVING_DEFEATED)

/// Player-controlled or minded DELVERS currently inside a given room.
/// Ghosts and other non-corporeal mobs float on the room's turfs and carry
/// clients, but they are spectators: counting them kept runs from ever
/// collapsing and could even fake a party wipe once the living had left.
/datum/dungeon_run/proc/get_members_in_room(datum/pocket_dimension/dungeon/room)
	var/list/mob/found = list()
	if(QDELETED(room))
		return found
	for(var/mob/occupant as anything in room.get_occupants())
		if(QDELETED(occupant) || !isliving(occupant))
			continue
		if((occupant.mind || occupant.client) && is_run_participant(occupant))
			found += occupant
	return found

/// All minded/client members currently anywhere in the run.
/datum/dungeon_run/proc/get_present_members()
	var/list/mob/found = list()
	for(var/datum/pocket_dimension/dungeon/room as anything in get_all_rooms())
		found += get_members_in_room(room)
	return found

/// The run is joinable only while the present party rests in a break/descent room.
/datum/dungeon_run/proc/is_at_rest()
	if(ending)
		return FALSE
	if(length(stretch_rooms))
		return FALSE
	var/datum/map_template/pocket/dungeon/break_template = current_break_room?.get_dungeon_template()
	if(!break_template)
		return FALSE
	return break_template.room_kind == DUNGEON_ROOM_BREAK || break_template.room_kind == DUNGEON_ROOM_DESCENT

// -- Muster movement ---------------------------------------------------------

/// Attempts to advance the present party through a forward/descent gate.
/// Solo / partyless callers advance immediately. Otherwise all present,
/// conscious, connected members must be gathered in the gate's room.
/datum/dungeon_run/proc/muster_advance(obj/structure/dungeon_gate/gate, mob/living/initiator, force = FALSE, automatic = FALSE)
	if(ending || QDELETED(gate))
		return FALSE
	if(advancing)
		to_chat(initiator, span_warning("Another passage is already taking shape."))
		return FALSE
	if(!is_party_member(initiator) || gate.owning_run != src || QDELETED(gate.source_room) || !gate.source_room.contains_turf(get_turf(initiator)))
		return FALSE
	if(force && !automatic && !is_run_leader(initiator))
		to_chat(initiator, span_warning("Only the expedition leader may force the party onward."))
		return FALSE
	// Anti-branching backstop: this is the single chokepoint every forward/descent
	// opener funnels through (use_gate, the panel's Traverse/Force, right-click).
	// Guarding here means no pathway can ever reopen a committed sibling, even
	// one that skipped use_gate's own forsaken/sealed checks.
	if(gate.forsaken)
		to_chat(initiator, span_warning("That passage is dead stone. The path was already chosen, and it was not this one."))
		return FALSE
	if(gate.sealed)
		to_chat(initiator, span_warning("The passage is sealed. Whatever guards this room holds it shut."))
		return FALSE
	var/datum/pocket_dimension/dungeon/source_room = gate.source_room
	if(QDELETED(source_room))
		return FALSE
	if(gate.requires_key && !gate.key_unlocked)
		to_chat(initiator, span_warning("The passage will not answer without its key."))
		return FALSE

	if(!force && !is_mustered(source_room))
		begin_muster(gate, initiator)
		announce_muster_gap(source_room, initiator)
		return FALSE
	clear_muster()

	advancing = TRUE
	var/datum/pocket_dimension/dungeon/target = gate.resolve_destination()
	if(!target)
		advancing = FALSE
		to_chat(initiator, span_warning("The passage twists shut before me."))
		return FALSE
	if(ending || QDELETED(gate) || gate.owning_run != src || QDELETED(source_room) || !source_room.contains_turf(get_turf(initiator)) || gate.sealed || gate.forsaken || (gate.requires_key && !gate.key_unlocked))
		advancing = FALSE
		return FALSE

	// Cohort = every minded/client mob currently in the source room (carries downed bodies).
	var/list/mob/cohort = get_members_in_room(source_room)
	if(!length(cohort))
		cohort = list(initiator)
	cohort |= initiator

	for(var/mob/living/member as anything in cohort)
		if(QDELETED(member))
			continue
		move_member_through(member, target, source_room)

	// The path is chosen: sibling onward passages fuse shut for good. Only the
	// taken door stays open for backtracking.
	for(var/obj/structure/dungeon_gate/sibling as anything in source_room.gates)
		if(sibling == gate || QDELETED(sibling))
			continue
		if(sibling.gate_role == DUNGEON_GATE_FORWARD || sibling.gate_role == DUNGEON_GATE_DESCENT)
			sibling.forsaken = TRUE

	target.touch()
	source_room.touch()
	advancing = FALSE
	on_room_reached(target, initiator)
	return TRUE

/// TRUE when every present, conscious, connected member is in source_room.
/datum/dungeon_run/proc/is_mustered(datum/pocket_dimension/dungeon/source_room)
	return !length(get_muster_missing(source_room))

/// Moves a single member to a target room's entry turf, dragging pulled cargo.
/datum/dungeon_run/proc/move_member_through(mob/living/member, datum/pocket_dimension/dungeon/target, datum/pocket_dimension/dungeon/source_room)
	var/turf/entry_turf = target.get_entry_turf()
	if(!entry_turf)
		return FALSE
	var/list/atom/movable/dragged = list()
	if(member.pulling && !QDELETED(member.pulling))
		dragged += member.pulling
	for(var/obj/item/grabbing/grab_item in member.held_items)
		if(grab_item.grabbed && !QDELETED(grab_item.grabbed) && ismovable(grab_item.grabbed))
			dragged |= grab_item.grabbed
	member.forceMove(entry_turf)
	if(get_turf(member) != entry_turf)
		return FALSE
	source_room?.current_trait?.on_mob_exited(source_room, member)
	on_member_entered_room(target, member)
	for(var/atom/movable/cargo as anything in dragged)
		if(isliving(cargo) && is_run_participant(cargo))
			continue // another cohort iteration performs its authoritative hooks
		var/turf/drop_turf = target.get_drop_turf(cargo) || entry_turf
		cargo.forceMove(drop_turf)
		if(isliving(cargo))
			var/mob/living/dragged_living = cargo
			if(!is_run_participant(dragged_living))
				add_forced_entrant(dragged_living)
				source_room?.current_trait?.on_mob_exited(source_room, dragged_living)
				on_member_entered_room(target, dragged_living)
	return TRUE

/// Names of present members who still gate a muster from this room (conscious,
/// connected, not defeat-knocked-out, and standing somewhere else).
/datum/dungeon_run/proc/get_muster_missing(datum/pocket_dimension/dungeon/source_room)
	var/list/missing = list()
	if(QDELETED(source_room))
		return missing
	for(var/mob/living/member as anything in get_present_members())
		if(QDELETED(member) || member.stat >= UNCONSCIOUS)
			continue
		if(member.has_status_effect(/datum/status_effect/defeat_knockout))
			continue // defeated members are carried, not waited on
		var/member_id = get_participant_id(member)
		if(!member.client)
			if(!member.ckey && !member.mind?.key)
				continue // clientless harness bodies are not SSD players
			if(!muster_started_at)
				missing += "[member.real_name || member.name] (disconnected)"
				continue
			if(!muster_ssd_since[member_id])
				muster_ssd_since[member_id] = world.time
			if(world.time < muster_ssd_since[member_id] + DUNGEON_MUSTER_SSD_GRACE)
				missing += "[member.real_name || member.name] (disconnected)"
			continue
		muster_ssd_since -= member_id
		if(!source_room.contains_turf(get_turf(member)))
			missing += (member.real_name || member.name)
	return missing

/datum/dungeon_run/proc/begin_muster(obj/structure/dungeon_gate/gate, mob/living/initiator)
	if(muster_gate_ref?.resolve() == gate)
		return
	clear_muster()
	muster_gate_ref = WEAKREF(gate)
	muster_initiator_ref = WEAKREF(initiator)
	muster_started_at = world.time
	muster_timer = addtimer(CALLBACK(src, PROC_REF(resolve_muster_timeout)), DUNGEON_MUSTER_TIMEOUT, TIMER_STOPPABLE)
	notify_roster("The passage begins a [DisplayTimeText(DUNGEON_MUSTER_TIMEOUT)] muster. Gather now; when it ends, those at the gate will advance.")

/datum/dungeon_run/proc/resolve_muster_timeout()
	muster_timer = null
	var/obj/structure/dungeon_gate/gate = muster_gate_ref?.resolve()
	var/mob/living/initiator = muster_initiator_ref?.resolve()
	if(!QDELETED(gate) && (QDELETED(initiator) || !gate.source_room?.contains_turf(get_turf(initiator))))
		for(var/mob/living/member as anything in get_members_in_room(gate.source_room))
			if(is_party_member(member))
				initiator = member
				break
	clear_muster()
	if(QDELETED(gate) || QDELETED(initiator))
		return
	notify_roster("The muster ends. The passage takes those who gathered at its threshold.")
	muster_advance(gate, initiator, TRUE, TRUE)

/datum/dungeon_run/proc/clear_muster()
	if(muster_timer)
		deltimer(muster_timer)
		muster_timer = null
	muster_gate_ref = null
	muster_initiator_ref = null
	muster_started_at = 0
	muster_ssd_since.Cut()

/// Tells the initiator who still needs to gather before the party can advance.
/datum/dungeon_run/proc/announce_muster_gap(datum/pocket_dimension/dungeon/source_room, mob/living/initiator)
	var/list/missing = get_muster_missing(source_room)
	if(length(missing))
		var/time_left = max(0, DUNGEON_MUSTER_TIMEOUT - (world.time - muster_started_at))
		to_chat(initiator, span_warning("The party is not gathered. Still scattered: [english_list(missing)]. The muster resolves in [DisplayTimeText(time_left)]."))
	else
		to_chat(initiator, span_warning("The passage resists. Try again."))

// -- Assembly UI -------------------------------------------------------------

/obj/structure/dungeon_entrance/proc/open_assembly_menu(mob/living/carbon/user)
	if(entrance_kind != DUNGEON_ENTRANCE_INFINITE || !istype(user) || !user.client || !user.Adjacent(src))
		return
	ui_interact(user)

/obj/structure/dungeon_entrance/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/dungeon_entrance/ui_interact(mob/user, datum/tgui/ui)
	if(entrance_kind != DUNGEON_ENTRANCE_INFINITE || !user?.Adjacent(src))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.update_dungeon_title()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DungeonAssembly")
		ui.open()

/obj/structure/dungeon_entrance/ui_data(mob/user)
	var/list/data = list()
	var/datum/party/party = null
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		party = carbon_user.current_party
	data["has_party"] = !!party
	data["party_name"] = party?.party_name
	data["is_leader"] = party ? party.is_leader(user?.ckey) : FALSE
	data["run_active"] = !!active_run
	data["dormant"] = is_dormant()
	data["reopens_in"] = is_dormant() ? round((dormant_until - world.time) / 10) : 0

	var/list/roster = list()
	var/leader_name
	if(party)
		for(var/member_ckey in party.members)
			var/mob/living/member = get_mob_by_ckey(member_ckey)
			var/member_name = member ? (member.real_name || member.name) : member_ckey
			if(party.is_leader(member_ckey))
				leader_name = member_name
			roster += list(list(
				"name" = member_name,
				"rank" = get_player_rank(member_ckey),
				"ready" = !!(member && member.Adjacent(src)),
				"leader" = party.is_leader(member_ckey),
			))
	data["leader_name"] = leader_name
	data["roster"] = roster

	var/datum/dungeon_progress/progress = user?.ckey ? get_dungeon_progress(user.ckey) : null
	data["echoes"] = progress ? progress.echoes : 0

	// Delver's Ledger tab: the echo shop and titles.
	var/list/unlock_data = list()
	var/list/title_data = list()
	if(progress)
		for(var/datum/dungeon_unlock/unlock as anything in get_dungeon_unlock_catalogue())
			unlock_data += list(list(
				"id" = unlock.id,
				"name" = unlock.name,
				"desc" = unlock.desc,
				"cost" = unlock.echo_cost,
				"owned" = progress.has_unlock(unlock.id),
			))
			qdel(unlock)
		for(var/datum/dungeon_cosmetic/cosmetic as anything in get_dungeon_cosmetic_catalogue())
			if(cosmetic.event_only && !progress.has_cosmetic(cosmetic.id))
				qdel(cosmetic)
				continue
			title_data += list(list(
				"id" = cosmetic.id,
				"name" = cosmetic.name,
				"desc" = cosmetic.desc,
				"cost" = cosmetic.echo_cost,
				"owned" = progress.has_cosmetic(cosmetic.id),
				"title_text" = cosmetic.title_text,
			))
			qdel(cosmetic)
	data["unlocks"] = unlock_data
	data["titles"] = title_data
	data["selected_title"] = progress?.selected_title

	var/covenant_owned = !!progress?.has_unlock("grim_covenant")
	data["covenant_owned"] = covenant_owned
	data["heat_locked"] = !!active_run
	var/list/dials = list()
	var/total_heat = 0
	if(covenant_owned)
		for(var/datum/dungeon_heat_dial/dial as anything in get_dungeon_heat_dials())
			var/rank = pending_heat_ranks[dial.id] || 0
			total_heat += rank
			dials += list(list(
				"id" = dial.id,
				"name" = dial.name,
				"desc" = dial.desc,
				"rank" = rank,
				"max_rank" = dial.max_rank,
			))
	data["dials"] = dials
	data["total_heat"] = total_heat
	data["echo_bonus_percent"] = total_heat * DUNGEON_HEAT_ECHO_BONUS * 100
	return data

/obj/structure/dungeon_entrance/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/user = usr
	if(entrance_kind != DUNGEON_ENTRANCE_INFINITE || !iscarbon(user) || !user.Adjacent(src))
		return
	switch(action)
		if("create_party")
			if(user.current_party)
				return
			create_party(user, "[user.real_name]'s Expedition")
			return TRUE
		if("descend_solo")
			if(user.current_party)
				return
			ui.close()
			INVOKE_ASYNC(src, PROC_REF(try_enter), user)
			return TRUE
		if("buy_unlock")
			var/datum/dungeon_progress/progress = user.ckey ? get_dungeon_progress(user.ckey) : null
			if(!progress)
				return
			var/datum/dungeon_unlock/target
			for(var/datum/dungeon_unlock/unlock as anything in get_dungeon_unlock_catalogue())
				if(unlock.id == params["id"])
					target = unlock
				else
					qdel(unlock)
			if(!target)
				return
			if(!progress.has_unlock(target.id))
				if(progress.spend_echoes(target.echo_cost))
					progress.grant_unlock(target.id)
					to_chat(user, span_nicegreen("Unlocked: [target.name]."))
				else
					to_chat(user, span_warning("Not enough echoes."))
			qdel(target)
			return TRUE
		if("buy_title")
			var/datum/dungeon_progress/progress = user.ckey ? get_dungeon_progress(user.ckey) : null
			if(!progress)
				return
			var/datum/dungeon_cosmetic/target
			for(var/datum/dungeon_cosmetic/cosmetic as anything in get_dungeon_cosmetic_catalogue())
				if(cosmetic.id == params["id"])
					target = cosmetic
				else
					qdel(cosmetic)
			if(!target)
				return
			if(target.event_only)
				qdel(target)
				return
			if(!progress.has_cosmetic(target.id))
				if(progress.spend_echoes(target.echo_cost))
					progress.grant_cosmetic(target.id)
					to_chat(user, span_nicegreen("Acquired: [target.name]."))
				else
					to_chat(user, span_warning("Not enough echoes."))
			qdel(target)
			return TRUE
		if("set_title")
			var/datum/dungeon_progress/progress = user.ckey ? get_dungeon_progress(user.ckey) : null
			if(!progress)
				return
			var/title_id = params["id"]
			if(title_id == "none")
				progress.selected_title = null
			else if(progress.has_cosmetic(title_id))
				progress.selected_title = title_id
			else
				return
			progress.save_progress()
			if(ishuman(user))
				var/mob/living/carbon/human/human_user = user
				human_user.update_dungeon_title()
			return TRUE
		if("invite")
			INVOKE_ASYNC(user, TYPE_VERB_REF(/mob/living/carbon, invite_to_party))
			return TRUE
		if("descend")
			var/datum/party/party = user.current_party
			if(!party)
				return
			if(!party.is_leader(user.ckey))
				to_chat(user, span_warning("Only the leader may give the order to descend."))
				return
			ui.close()
			INVOKE_ASYNC(src, PROC_REF(descend_with_party), user, party)
			return TRUE
		if("set_dial")
			if(active_run)
				to_chat(user, span_warning("The pact is sealed for the run already underway."))
				return
			var/datum/party/party = user.current_party
			if(party && !party.is_leader(user.ckey))
				to_chat(user, span_warning("Only the leader may bargain with the covenant."))
				return
			var/datum/dungeon_progress/progress = user.ckey ? get_dungeon_progress(user.ckey) : null
			if(!progress?.has_unlock("grim_covenant"))
				return
			var/dial_id = params["id"]
			var/rank = clamp(text2num(params["rank"]) || 0, 0, 5)
			for(var/datum/dungeon_heat_dial/dial as anything in get_dungeon_heat_dials())
				if(dial.id != dial_id)
					continue
				pending_heat_ranks[dial.id] = clamp(rank, 0, dial.max_rank)
				if(!pending_heat_ranks[dial.id])
					pending_heat_ranks -= dial.id
				return TRUE
			return

/// Starts the run (if needed) and moves every present, adjacent party member in.
/obj/structure/dungeon_entrance/proc/descend_with_party(mob/living/carbon/leader, datum/party/party)
	if(!istype(leader) || !leader.Adjacent(src) || is_dormant())
		to_chat(leader, span_warning("The way down is buried under fresh rubble."))
		return
	if(!active_run)
		if(!party || leader.current_party != party || !party.is_leader(leader.ckey))
			return
		var/datum/dungeon_run/new_run = new(src, theme_filter)
		new_run.bind_party(party, leader)
		new_run.seed_from_progress(get_dungeon_progress(leader.ckey))
		new_run.heat_ranks = consume_pending_heat(leader)
		active_run = new_run
		if(!new_run.start())
			if(active_run == new_run)
				active_run = null
			qdel(new_run)
			to_chat(leader, span_warning("The depths refuse to take shape."))
			return
		// start() yields while maps load. The order must still be valid when it returns.
		if(QDELETED(party) || leader.current_party != party || !party.is_leader(leader.ckey) || !leader.Adjacent(src))
			qdel(new_run)
			return
	if(!active_run.is_party_member(leader))
		return
	var/datum/pocket_dimension/dungeon/break_room = active_run.current_break_room
	if(!break_room)
		to_chat(leader, span_warning("The depths are still taking shape. Try again in a moment."))
		return
	if(!party || active_run.get_party() != party)
		try_enter(leader)
		return
	var/descended = 0
	for(var/member_ckey in active_run.member_ckeys)
		var/mob/living/member = get_mob_by_ckey(member_ckey)
		if(!member || !member.Adjacent(src))
			continue
		if(break_room.enter_mob(member, get_turf(src), src))
			active_run.on_member_entered_room(break_room, member, TRUE)
			descended++
	if(!descended)
		to_chat(leader, span_warning("No one was close enough to descend."))

// -- Lockout, petition & approval -------------------------------------------

/obj/structure/dungeon_entrance/proc/petition_to_join(mob/living/carbon/user)
	if(!istype(user) || !user.client || !active_run)
		return
	if(active_run.is_party_member(user))
		descend_with_party(user, active_run.get_party())
		return
	// Already approved while they were away - honour it without a second vote.
	if(WEAKREF(user) in active_run.accepted_petitioners)
		if(active_run.is_at_rest())
			active_run.admit_petitioner(user)
			return
		to_chat(user, span_warning("The party has moved on into the dark. Wait for them to reach the next place of respite."))
		active_run.accepted_petitioners -= WEAKREF(user)
		active_run.waiting_petitioners |= WEAKREF(user)
		return
	if(!active_run.is_at_rest())
		to_chat(user, span_warning("The party is deep in the dungeon. The way is sealed until they reach a place of respite. You wait by the entrance."))
		active_run.waiting_petitioners |= WEAKREF(user)
		return
	active_run.request_join(user)

/// Asks present members to approve an outsider; non-unanimous per approval mode.
/datum/dungeon_run/proc/request_join(mob/living/carbon/petitioner)
	var/datum/pocket_dimension/dungeon/expected_room = current_break_room
	if(!can_admit_petitioner(petitioner, expected_room, TRUE))
		return
	var/list/mob/voters = list()
	for(var/mob/living/member as anything in get_present_members())
		if(member.client)
			voters += member
	if(!length(voters))
		// No one conscious to approve; admit by default while at rest.
		admit_petitioner(petitioner)
		return
	var/datum/party/party = get_party()
	var/approvals = 0
	var/needed = get_join_approvals_needed(length(voters), party)
	for(var/mob/living/voter as anything in voters)
		if(!can_admit_petitioner(petitioner, expected_room, TRUE))
			to_chat(petitioner, span_warning("The opportunity to join has passed."))
			return
		if(join_approval_mode == DUNGEON_JOIN_APPROVAL_LEADER && party && !party.is_leader(voter.ckey))
			continue
		var/yes = tgui_alert(voter, "[petitioner.real_name] petitions to join your expedition. Allow it?", "A Petitioner", list("Allow", "Deny"))
		if(!can_admit_petitioner(petitioner, expected_room, TRUE))
			to_chat(petitioner, span_warning("The opportunity to join has passed."))
			return
		if(yes == "Allow")
			approvals++
			if(approvals >= needed)
				break
	if(approvals >= needed)
		admit_petitioner(petitioner)
	else
		to_chat(petitioner, span_warning("The party turns you away."))

/datum/dungeon_run/proc/can_admit_petitioner(mob/living/carbon/petitioner, datum/pocket_dimension/dungeon/expected_room, require_client = FALSE)
	if(ending || !istype(petitioner) || QDELETED(petitioner))
		return FALSE
	if(require_client && !petitioner.client)
		return FALSE
	if(current_break_room != expected_room || !is_at_rest())
		return FALSE
	if(party_bound && !get_party())
		return FALSE
	return TRUE

/datum/dungeon_run/proc/get_join_approvals_needed(voter_count, datum/party/party)
	switch(join_approval_mode)
		if(DUNGEON_JOIN_APPROVAL_MAJORITY)
			return FLOOR(voter_count / 2, 1) + 1
		if(DUNGEON_JOIN_APPROVAL_LEADER)
			return 1
	return 1 // ANY

/datum/dungeon_run/proc/admit_petitioner(mob/living/carbon/petitioner)
	if(!can_admit_petitioner(petitioner, current_break_room))
		return FALSE
	// Approval can land long after the petition - the petitioner may have
	// wandered off, or been dragged across the map. Never yank someone into the
	// dark from wherever they happen to be standing: tell them the way is open
	// and let them walk back to the mouth themselves.
	var/obj/structure/dungeon_entrance/entrance = get_entrance()
	if(entrance && !petitioner.Adjacent(entrance))
		to_chat(petitioner, span_nicegreen("The expedition has accepted your petition. Return to [entrance] and touch it to descend - the way will hold for you."))
		accepted_petitioners |= WEAKREF(petitioner)
		waiting_petitioners -= WEAKREF(petitioner)
		return TRUE
	var/datum/party/party = get_party()
	if(party && !(ckey(petitioner.ckey) in party.members))
		if(!join_party(petitioner, party))
			to_chat(petitioner, span_warning("You cannot join this expedition: its party is full, or you are in another party."))
			return FALSE
	add_run_member(petitioner)
	// Actually descending consumes any remembered approval, whichever path got
	// them here.
	accepted_petitioners -= WEAKREF(petitioner)
	waiting_petitioners -= WEAKREF(petitioner)
	var/turf/entry_turf = current_break_room.get_entry_turf()
	if(entry_turf)
		petitioner.forceMove(entry_turf)
		on_member_entered_room(current_break_room, petitioner)
		to_chat(petitioner, span_nicegreen("The party admits you. You descend to join them."))
		for(var/mob/living/member as anything in get_present_members())
			if(member != petitioner)
				to_chat(member, span_notice("[petitioner.real_name] has joined the expedition."))
	return TRUE

/datum/dungeon_run/proc/notify_waiting_petitioners()
	for(var/datum/weakref/petitioner_ref as anything in waiting_petitioners.Copy())
		var/mob/living/petitioner = petitioner_ref.resolve()
		if(!petitioner || QDELETED(petitioner) || !petitioner.client)
			waiting_petitioners -= petitioner_ref
			continue
		to_chat(petitioner, span_nicegreen("The expedition has reached a place of respite. Touch the entrance again to petition to join."))
