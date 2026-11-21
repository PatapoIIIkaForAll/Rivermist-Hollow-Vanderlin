/proc/get_player_rank(ckey)
	var/datum/save_manager/SM = get_save_manager(ckey)
	if(SM)
		return SM.get_data("player_data", "rank", "Copper Adventurer")
	return "Copper Adventurer"

/proc/set_player_rank(ckey, rank)
	var/datum/save_manager/SM = get_save_manager(ckey)
	if(SM)
		return SM.set_data("player_data", "rank", rank)
	return FALSE

/// How long a party invitation waits for an answer.
#define PARTY_INVITE_TIMEOUT (30 SECONDS)
/// Minimum gap between "I hold back" lines to one attacker.
#define PARTY_SPARE_MESSAGE_COOLDOWN (3 SECONDS)

GLOBAL_LIST_EMPTY(active_parties)
/// Invitee ckey = world.time the pending invitation expires.
GLOBAL_LIST_EMPTY(pending_party_invites)

/proc/send_party_invite(mob/living/carbon/invitee, datum/party/party, mob/living/carbon/inviter)
	if(!istype(invitee) || !invitee.ckey || !party || !inviter)
		return FALSE

	var/invitee_ckey = ckey(invitee.ckey)
	var/expires_at = GLOB.pending_party_invites[invitee_ckey]
	if(expires_at && world.time < expires_at)
		to_chat(inviter, span_warning("[invitee.real_name] already has a pending party invitation!"))
		return FALSE

	GLOB.pending_party_invites[invitee_ckey] = world.time + PARTY_INVITE_TIMEOUT
	var/party_id = party.party_id
	var/response = tgui_alert(invitee, "[inviter.real_name] has invited you to join the party '[party.party_name]'. Do you accept?", "Party Invitation", list("Accept", "Decline"), PARTY_INVITE_TIMEOUT)
	GLOB.pending_party_invites -= invitee_ckey

	// The party may have disbanded while the invitee read the prompt.
	party = GLOB.active_parties[party_id]
	if(QDELETED(invitee) || QDELETED(inviter))
		return FALSE

	if(response != "Accept")
		to_chat(inviter, span_notice("[invitee.real_name] declined your party invitation."))
		to_chat(invitee, span_notice("You declined the party invitation from [inviter.real_name]."))
		return FALSE

	if(!party || invitee.current_party || !inviter.ckey || !party.is_leader(inviter.ckey))
		to_chat(invitee, span_warning("The party invitation is no longer valid!"))
		to_chat(inviter, span_warning("Unable to add [invitee.real_name] - invitation expired or party changed!"))
		return FALSE

	if(!join_party(invitee, party))
		to_chat(invitee, span_warning("Failed to join the party!"))
		to_chat(inviter, span_warning("Failed to add [invitee.real_name] to the party!"))
		return FALSE

	to_chat(inviter, span_notice("[invitee.real_name] has joined your party!"))
	to_chat(invitee, span_notice("You have joined '[party.party_name]'!"))
	return TRUE

/proc/create_party(mob/living/carbon/leader, party_name = "New Party")
	if(!istype(leader) || !leader.ckey)
		return null

	if(leader.current_party)
		to_chat(leader, span_warning("You are already in a party!"))
		return null

	var/datum/party/new_party = new /datum/party(leader.ckey, party_name)
	GLOB.active_parties[new_party.party_id] = new_party

	new_party.add_member(leader)

	return new_party

/proc/join_party(mob/living/carbon/joiner, datum/party/target_party)
	if(!istype(joiner) || !joiner.ckey || QDELETED(target_party))
		return FALSE

	if(joiner.current_party)
		to_chat(joiner, span_warning("You are already in a party!"))
		return FALSE

	return target_party.add_member(joiner)

/proc/leave_party(mob/living/carbon/leaver)
	if(!istype(leaver) || !leaver.ckey || !leaver.current_party)
		return FALSE

	var/datum/party/party = leaver.current_party
	return party.remove_member(leaver.ckey)


/mob/living/carbon/verb/create_party_verb()
	set name = "Create Party"
	set category = "IC.Party"
	set desc = "Create a new party"

	if(!src.ckey)
		return

	if(src.current_party)
		to_chat(src, span_warning("You are already in a party!"))
		return

	var/party_name = browser_input_text(src, "Enter party name", "Create Party", max_length = MAX_CHARTER_LEN)
	if(!party_name || QDELETED(src) || current_party)
		return

	var/datum/party/new_party = create_party(src, party_name)
	if(new_party)
		to_chat(src, span_notice("Party '[party_name]' created successfully!"))

/mob/living/carbon/verb/leave_party_verb()
	set name = "Leave Party"
	set category = "IC.Party"
	set desc = "Leave your current party"

	if(!current_party)
		to_chat(src, span_warning("You are not in a party!"))
		return

	if(leave_party(src))
		to_chat(src, span_notice("You have left the party."))

/mob/living/carbon/verb/invite_to_party()
	set name = "Invite to Party"
	set category = "IC.Party"
	set desc = "Invite someone to your party"

	if(!current_party)
		to_chat(src, span_warning("You are not in a party!"))
		return

	if(!current_party.is_leader(ckey))
		to_chat(src, span_warning("Only the party leader can invite members!"))
		return

	var/list/candidates = list()
	for(var/mob/living/carbon/candidate in view(7, src))
		if(candidate != src && candidate.ckey && !candidate.current_party)
			candidates += candidate
	if(!length(candidates))
		to_chat(src, span_warning("There is no one nearby who can join a party."))
		return

	var/mob/living/carbon/invitee = browser_input_list(src, "Choose a target to invite.", "Party Invite", candidates)
	if(!istype(invitee) || QDELETED(invitee) || QDELETED(src) || !current_party)
		return

	if(!invitee.ckey)
		to_chat(src, span_warning("This person cannot join parties!"))
		return

	if(invitee.current_party)
		to_chat(src, span_warning("[invitee.real_name] is already in a party!"))
		return

	send_party_invite(invitee, current_party, src)

/mob/living/carbon/verb/remove_from_party_verb()
	set name = "Remove from Party"
	set category = "IC.Party"
	set desc = "Remove a member from your party"

	if(!current_party || !current_party.is_leader(ckey))
		to_chat(src, span_warning("Only the party leader can remove members!"))
		return

	var/list/choices = current_party.get_member_choices(ckey)
	if(!length(choices))
		to_chat(src, span_warning("There is no one else in your party."))
		return

	var/choice = browser_input_list(src, "Choose a member to remove.", "Remove from Party", choices)
	if(!choice || !current_party || !current_party.is_leader(ckey))
		return

	var/target_ckey = choices[choice]
	if(current_party.remove_member(target_ckey))
		to_chat(src, span_notice("[choice] was removed from the party."))

/mob/living/carbon/verb/make_party_leader_verb()
	set name = "Make Party Leader"
	set category = "IC.Party"
	set desc = "Hand the party lead to another member. Anyone may take it while the leader is disconnected."

	if(!current_party)
		to_chat(src, span_warning("You are not in a party!"))
		return

	var/datum/party/party = current_party
	if(!party.is_leader(ckey))
		var/mob/leader_mob = get_mob_by_ckey(party.party_leader_ckey)
		if(leader_mob?.client)
			to_chat(src, span_warning("Only the party leader can hand over the lead."))
			return
		party.set_leader(ckey)
		return

	var/list/choices = party.get_member_choices(ckey)
	if(!length(choices))
		to_chat(src, span_warning("There is no one else in your party."))
		return

	var/choice = browser_input_list(src, "Choose the new party leader.", "Make Party Leader", choices)
	if(!choice || current_party != party || !party.is_leader(ckey))
		return

	party.set_leader(choices[choice])

/mob/living/carbon/verb/toggle_party_protection_verb()
	set name = "Toggle Party Protection"
	set category = "IC.Party"
	set desc = "Choose whether your attacks, shots and spells skip your party members."

	party_fire_guard = !party_fire_guard
	if(party_fire_guard)
		to_chat(src, span_notice("My attacks now skip my party members."))
	else
		to_chat(src, span_notice("My attacks can now hit my party members."))

/datum/party
	var/party_id
	var/party_name = "New Party"
	/// Member ckeys in join order; the first one takes over when the leader leaves.
	var/list/members = list()
	var/party_leader_ckey
	var/max_members = 6
	var/created_time
	var/last_activity_time
	/// Member ckey = the carbon body that member plays, cleared when that body is deleted.
	var/list/bodies = list()

/datum/party/New(leader_ckey, name = "New Party")
	party_id = "[world.realtime]_[rand(1000, 9999)]"
	party_name = name
	party_leader_ckey = ckey(leader_ckey)
	created_time = world.realtime
	last_activity_time = world.realtime

/datum/party/Destroy()
	for(var/member_ckey in bodies.Copy())
		unbind_body(member_ckey)
	members.Cut()
	GLOB.active_parties -= party_id
	return ..()

/datum/party/proc/add_member(mob/living/carbon/target_mob)
	if(!istype(target_mob) || !target_mob.ckey)
		return FALSE

	var/target_ckey = ckey(target_mob.ckey)

	// A member returning in a new body keeps their place.
	if(target_ckey in members)
		bind_body(target_mob, target_ckey)
		update_party_huds()
		return TRUE

	if(length(members) >= max_members)
		return FALSE

	if(target_mob.current_party)
		return FALSE

	members += target_ckey
	bind_body(target_mob, target_ckey)

	update_party_huds()

	notify_party("[target_mob.real_name] has joined the party!", target_mob)
	to_chat(target_mob, span_notice("Use Toggle Party Protection to make my attacks skip party members."))

	return TRUE

/datum/party/proc/remove_member(target_ckey)
	target_ckey = ckey(target_ckey)

	if(!(target_ckey in members))
		return FALSE

	var/mob/leaving_mob = bodies[target_ckey] || get_mob_by_ckey(target_ckey)
	var/leaving_name = leaving_mob ? (leaving_mob.real_name || leaving_mob.name) : target_ckey

	members -= target_ckey
	unbind_body(target_ckey)

	if(!length(members))
		qdel(src)
		return TRUE

	if(target_ckey == party_leader_ckey)
		party_leader_ckey = members[1]
		notify_party("[get_member_name(party_leader_ckey)] is now the party leader!")

	update_party_huds()
	notify_party("[leaving_name] has left the party.")

	return TRUE

/datum/party/proc/set_leader(new_leader_ckey)
	new_leader_ckey = ckey(new_leader_ckey)
	if(!(new_leader_ckey in members) || new_leader_ckey == party_leader_ckey)
		return FALSE
	party_leader_ckey = new_leader_ckey
	notify_party("[get_member_name(new_leader_ckey)] is now the party leader!")
	return TRUE

/// Links a member ckey to the carbon body they play, dropping any older body.
/datum/party/proc/bind_body(mob/living/carbon/body, member_ckey)
	var/mob/living/carbon/old_body = bodies[member_ckey]
	if(old_body == body)
		body.current_party = src
		return
	if(old_body)
		body.party_fire_guard = old_body.party_fire_guard
		unbind_body(member_ckey)
	if(body.current_party && body.current_party != src)
		body.current_party.release_body(body)
	bodies[member_ckey] = body
	body.current_party = src
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(on_body_deleted))

/datum/party/proc/unbind_body(member_ckey)
	var/mob/living/carbon/body = bodies[member_ckey]
	bodies -= member_ckey
	if(!body)
		return
	UnregisterSignal(body, COMSIG_PARENT_QDELETING)
	body.clear_party_huds()
	if(body.current_party == src)
		body.current_party = null

/// Unlinks a body from whichever member ckey it is bound to.
/datum/party/proc/release_body(mob/living/carbon/body)
	for(var/member_ckey in bodies)
		if(bodies[member_ckey] == body)
			unbind_body(member_ckey)
			return

/datum/party/proc/on_body_deleted(mob/living/carbon/source)
	SIGNAL_HANDLER
	release_body(source)
	update_party_huds()

/datum/party/proc/get_member_name(member_ckey)
	var/mob/member_mob = bodies[member_ckey] || get_mob_by_ckey(member_ckey)
	return member_mob ? (member_mob.real_name || member_mob.name) : member_ckey

/// Display name = ckey for every member except the one given.
/datum/party/proc/get_member_choices(exclude_ckey)
	exclude_ckey = ckey(exclude_ckey)
	var/list/choices = list()
	for(var/member_ckey in members)
		if(member_ckey == exclude_ckey)
			continue
		var/display_name = get_member_name(member_ckey)
		if(choices[display_name])
			display_name = "[display_name] ([member_ckey])"
		choices[display_name] = member_ckey
	return choices

/datum/party/proc/update_party_huds()
	for(var/member_ckey in bodies)
		var/mob/living/carbon/member_mob = bodies[member_ckey]
		if(member_mob?.client)
			member_mob.update_party_hud()

/datum/party/proc/notify_party(message, exclude_mob = null)
	last_activity_time = world.realtime
	for(var/member_ckey in members)
		var/mob/member_mob = get_mob_by_ckey(member_ckey)
		if(member_mob && member_mob != exclude_mob)
			to_chat(member_mob, span_notice("[message]"))

/datum/party/proc/get_member_rank(member_ckey)
	return get_player_rank(member_ckey)

/datum/party/proc/is_leader(check_ckey)
	return ckey(check_ckey) == party_leader_ckey


/mob/living/carbon
	/// When TRUE this mob's attacks, shots and spells skip its own party members.
	var/party_fire_guard = FALSE
	COOLDOWN_DECLARE(party_spare_message_cooldown)

/mob/living/carbon/Login()
	. = ..()
	if(client)
		sync_party_body()

/// Rebinds the party of whoever now plays this body, and refreshes party HUDs.
/mob/living/carbon/proc/sync_party_body()
	var/my_ckey = ckey(ckey)
	if(!my_ckey)
		return
	if(current_party && current_party.bodies[my_ckey] != src)
		current_party.release_body(src)
	if(!current_party)
		for(var/party_id in GLOB.active_parties)
			var/datum/party/party = GLOB.active_parties[party_id]
			if(my_ckey in party.members)
				party.bind_body(src, my_ckey)
				break
	current_party?.update_party_huds()

/// TRUE when this mob's harmful attacks should skip victim. The one rule every attack path asks.
/mob/proc/spares_ally(atom/victim, feedback = FALSE)
	return FALSE

/mob/living/carbon/spares_ally(atom/victim, feedback = FALSE)
	if(!current_party || !party_fire_guard || victim == src || !iscarbon(victim))
		return FALSE
	var/mob/living/carbon/ally = victim
	if(ally.current_party != current_party)
		return FALSE
	if(feedback && COOLDOWN_FINISHED(src, party_spare_message_cooldown))
		COOLDOWN_START(src, party_spare_message_cooldown, PARTY_SPARE_MESSAGE_COOLDOWN)
		to_chat(src, span_notice("I hold back: [ally] is in my party."))
	return TRUE

/mob/living/carbon/proc/update_party_hud()
	clear_party_huds()
	if(!client || !current_party)
		return

	var/hud_index = 0
	for(var/member_ckey in current_party.members)
		var/mob/living/carbon/member_mob = current_party.bodies[member_ckey]
		if(!member_mob || member_mob == src)
			continue

		var/member_rank = current_party.get_member_rank(member_ckey)

		var/atom/movable/screen/party_member_health/health_hud = new()
		health_hud.screen_loc = "EAST-1:28,CENTER+[2-hud_index]:15"
		health_hud.set_party_member(member_mob, current_party)

		var/atom/movable/screen/party_member_name/name_hud = new()
		name_hud.screen_loc = "EAST-1,CENTER+[2-hud_index]:15"
		name_hud.set_party_member(member_mob, current_party, member_rank)

		client.screen += health_hud
		client.screen += name_hud

		party_hud_elements += health_hud
		party_hud_elements += name_hud

		hud_index++
		if(hud_index >= 5)
			break

/mob/living/carbon/proc/clear_party_huds()
	for(var/atom/movable/screen/element in party_hud_elements)
		if(client)
			client.screen -= element
		qdel(element)

	party_hud_elements = list()

#undef PARTY_INVITE_TIMEOUT
#undef PARTY_SPARE_MESSAGE_COOLDOWN

// Not really sure where is best to put this, so it can go in here for now.
/mob/living/carbon/proc/make_acquaintance()
	var/mob/living/carbon/inviter = usr
	var/list/mobs = list()
	for(var/mob/living/carbon/person in view(2, inviter))
		if(!person.mind || mind.do_i_know(person.mind))
			continue
		if(person == inviter)
			continue
		mobs += person

	if(!LAZYLEN(mobs))
		return FALSE

	var/mob/living/carbon/invitee = browser_input_list(inviter, "Choose a target to add.", "Acquaintance", mobs)
	if(!invitee)
		return FALSE

	if(!invitee.ckey || !invitee.mind)
		to_chat(inviter, "<span class='warning'>This person is unable to become your acquaintance!</span>")
		return FALSE

	if(cmode)
		to_chat(inviter, "<span class='warning'>You cannot do this during combat!</span>")
		return FALSE
	if(invitee.cmode)
		to_chat(inviter, "<span class='warning'>This person is too busy at this time. Try again later.</span>")
		return FALSE

	var/invitee_choice = alert(invitee, "[src.real_name] wishes to make become an acquaintance, do you agree?", "Become Acquaintances", "Yes", "No")
	if(!(invitee_choice == "Yes"))
		return FALSE

	// Sanity check
	if(!mind)
		return FALSE

	to_chat(inviter, "<span class='notice'>You are now acquaintances with [invitee.real_name]!</span>")
	to_chat(invitee, "<span class='notice'>You are now acquaintances with [inviter.real_name]!</span>")
	mind.share_identities(invitee.mind)
	return TRUE
