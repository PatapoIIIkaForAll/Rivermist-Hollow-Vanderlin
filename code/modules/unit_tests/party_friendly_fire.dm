/// Shared setup: keyed, clientless humans that can hold party seats.
/datum/unit_test/party_fire
	abstract_type = /datum/unit_test/party_fire
	var/list/keyed_mobs = list()
	var/list/prehit_targets = list()

/datum/unit_test/party_fire/Destroy()
	for(var/mob/living/carbon/human/keyed as anything in keyed_mobs)
		if(!QDELETED(keyed))
			keyed.ckey = null
	keyed_mobs.Cut()
	for(var/party_id in GLOB.active_parties.Copy())
		var/datum/party/party = GLOB.active_parties[party_id]
		if(findtext(party.party_name, "partyfiretest"))
			qdel(party)
	return ..()

/datum/unit_test/party_fire/proc/make_keyed(member_key, turf/spot)
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human/species/human/northern, spot)
	member.ckey = member_key
	keyed_mobs += member
	return member

/datum/unit_test/party_fire/proc/make_pair(turf/attacker_spot, turf/ally_spot)
	var/mob/living/carbon/human/attacker = make_keyed("partyfiretesta", attacker_spot)
	var/mob/living/carbon/human/ally = make_keyed("partyfiretestb", ally_spot)
	var/datum/party/party = create_party(attacker, "partyfiretest")
	join_party(ally, party)
	return list(attacker, ally, party)

/datum/unit_test/party_fire/proc/on_prehit(datum/source, list/hit_args)
	SIGNAL_HANDLER
	prehit_targets += source

/// Join, leave, leader hand-over, body deletion and disband keep every link consistent.
/datum/unit_test/party_fire/membership

/datum/unit_test/party_fire/membership/Run()
	var/mob/living/carbon/human/leader = make_keyed("partyfiretestlead", run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = make_keyed("partyfiretestsecond", run_loc_floor_bottom_left)

	var/datum/party/party = create_party(leader, "partyfiretest")
	TEST_ASSERT_NOTNULL(party, "A keyed carbon could not create a party.")
	TEST_ASSERT(join_party(second, party), "A keyed carbon could not join a party.")
	TEST_ASSERT_EQUAL(second.current_party, party, "Joining did not link the body to the party.")
	TEST_ASSERT_EQUAL(length(party.members), 2, "The party should hold two seats.")
	TEST_ASSERT(party.is_leader("partyfiretestlead"), "The founder should lead the party.")

	TEST_ASSERT(leave_party(leader), "The leader could not leave.")
	TEST_ASSERT_NULL(leader.current_party, "A member who left still points at the party.")
	TEST_ASSERT(party.is_leader("partyfiretestsecond"), "The lead did not pass to the next member.")

	TEST_ASSERT(join_party(leader, party), "A former member could not rejoin.")
	TEST_ASSERT(party.set_leader("partyfiretestlead"), "The lead could not be handed back.")
	TEST_ASSERT(party.is_leader("partyfiretestlead"), "set_leader did not change the leader.")

	// A deleted body drops its link but keeps the player's seat.
	second.ckey = null
	keyed_mobs -= second
	qdel(second)
	TEST_ASSERT_NULL(party.bodies["partyfiretestsecond"], "The party kept a deleted body.")
	TEST_ASSERT("partyfiretestsecond" in party.members, "A deleted body cost the player their seat.")

	// The same player in a new body is linked back on login.
	var/mob/living/carbon/human/new_body = make_keyed("partyfiretestsecond", run_loc_floor_bottom_left)
	new_body.sync_party_body()
	TEST_ASSERT_EQUAL(new_body.current_party, party, "A returning member's new body was not linked.")
	TEST_ASSERT_EQUAL(party.bodies["partyfiretestsecond"], new_body, "The party did not record the new body.")

	var/party_id = party.party_id
	party.remove_member("partyfiretestsecond")
	party.remove_member("partyfiretestlead")
	TEST_ASSERT(QDELETED(party), "An empty party was not deleted.")
	TEST_ASSERT_NULL(GLOB.active_parties[party_id], "A deleted party stayed in the active list.")
	TEST_ASSERT_NULL(leader.current_party, "Disbanding left a body pointing at the party.")
	TEST_ASSERT_NULL(new_body.current_party, "Removal left a body pointing at the party.")

/// A swing hits a party member by default, skips them once protection is on, and still hits strangers.
/datum/unit_test/party_fire/melee

/datum/unit_test/party_fire/melee/Run()
	var/turf/attacker_spot = run_loc_floor_bottom_left
	var/turf/side_spot = locate(attacker_spot.x + 1, attacker_spot.y, attacker_spot.z)
	TEST_ASSERT(isfloorturf(side_spot), "The test room has no floor next to the attacker.")

	var/list/pair = make_pair(attacker_spot, side_spot)
	var/mob/living/carbon/human/attacker = pair[1]
	var/mob/living/carbon/human/ally = pair[2]
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human/species/human/northern, side_spot)
	TEST_ASSERT_EQUAL(attacker.current_party, ally.current_party, "The pair did not share a party.")

	// Lying targets skip the miss and defense rolls, so each swing lands.
	ally.set_body_position(LYING_DOWN)
	stranger.set_body_position(LYING_DOWN)

	var/obj/item/weapon/knife/dagger/blade = allocate(/obj/item/weapon/knife/dagger, attacker_spot)
	attacker.put_in_active_hand(blade)
	attacker.update_a_intents()
	TEST_ASSERT_EQUAL(attacker.get_active_held_item(), blade, "The attacker is not holding the dagger.")

	// Protection starts off: party members can hit each other.
	TEST_ASSERT(!attacker.spares_ally(ally), "Party protection is on before the player turned it on.")
	blade.attack(ally, attacker)
	TEST_ASSERT_EQUAL(ally.lastattacker_weakref?.resolve(), attacker, "With protection off the swing skipped the party member.")
	ally.lastattacker_weakref = null

	attacker.toggle_party_protection_verb()
	TEST_ASSERT(attacker.party_fire_guard, "The toggle did not turn protection on.")
	TEST_ASSERT(attacker.spares_ally(ally), "spares_ally does not cover a party member.")
	TEST_ASSERT(!attacker.spares_ally(stranger), "spares_ally covers a stranger.")
	TEST_ASSERT(!attacker.spares_ally(attacker), "spares_ally covers the attacker.")
	TEST_ASSERT(!ally.spares_ally(attacker), "One member's toggle protected the other member's attacks.")

	attacker.stamina = 0
	blade.attack(ally, attacker)
	TEST_ASSERT_NULL(ally.lastattacker_weakref?.resolve(), "A dagger swing reached a party member.")

	attacker.stamina = 0
	blade.attack(stranger, attacker)
	TEST_ASSERT_EQUAL(stranger.lastattacker_weakref?.resolve(), attacker, "A dagger swing did not reach a stranger.")

/// With protection on, arrows fly past the firer's party member and hit the stranger behind.
/datum/unit_test/party_fire/projectile

/datum/unit_test/party_fire/projectile/Run()
	var/turf/firer_spot = run_loc_floor_bottom_left
	var/turf/ally_spot = locate(firer_spot.x + 1, firer_spot.y, firer_spot.z)
	var/turf/stranger_spot = locate(firer_spot.x + 2, firer_spot.y, firer_spot.z)
	TEST_ASSERT(isfloorturf(ally_spot) && isfloorturf(stranger_spot), "The test room is too narrow for a firing line.")

	var/list/pair = make_pair(firer_spot, ally_spot)
	var/mob/living/carbon/human/firer = pair[1]
	var/mob/living/carbon/human/ally = pair[2]
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human/species/human/northern, stranger_spot)

	var/obj/projectile/bullet/reusable/arrow/check_arrow = allocate(/obj/projectile/bullet/reusable/arrow, ally_spot)
	check_arrow.firer = firer
	TEST_ASSERT(check_arrow.can_hit_target(ally, TRUE, TRUE), "With protection off an arrow cannot hit the firer's party member.")
	firer.party_fire_guard = TRUE
	TEST_ASSERT(!check_arrow.can_hit_target(ally, TRUE, TRUE), "An arrow can still hit the firer's party member.")
	TEST_ASSERT(check_arrow.can_hit_target(stranger, TRUE, TRUE), "An arrow cannot hit a stranger.")

	RegisterSignal(ally, COMSIG_PROJECTILE_PREHIT, PROC_REF(on_prehit))
	RegisterSignal(stranger, COMSIG_PROJECTILE_PREHIT, PROC_REF(on_prehit))
	var/obj/projectile/bullet/reusable/arrow/flying_arrow = new(firer_spot)
	flying_arrow.firer = firer
	flying_arrow.preparePixelProjectile(stranger, firer)
	flying_arrow.fire()
	sleep(2 SECONDS)
	UnregisterSignal(ally, COMSIG_PROJECTILE_PREHIT)
	UnregisterSignal(stranger, COMSIG_PROJECTILE_PREHIT)
	if(!QDELETED(flying_arrow))
		qdel(flying_arrow)

	TEST_ASSERT(!(ally in prehit_targets), "The arrow struck the firer's party member.")
	TEST_ASSERT(stranger in prehit_targets, "The arrow did not reach the stranger behind the party member.")

/// With protection on, harmful aimed and area spells skip party members; helpful spells still reach them.
/datum/unit_test/party_fire/spells

/datum/unit_test/party_fire/spells/Run()
	var/turf/caster_spot = run_loc_floor_bottom_left
	var/turf/near_spot = locate(caster_spot.x + 1, caster_spot.y, caster_spot.z)
	TEST_ASSERT(isfloorturf(near_spot), "The test room has no floor next to the caster.")

	var/list/pair = make_pair(caster_spot, near_spot)
	var/mob/living/carbon/human/caster = pair[1]
	var/mob/living/carbon/human/ally = pair[2]
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human/species/human/northern, near_spot)
	caster.mind_initialize()

	var/datum/action/cooldown/spell/status/frostbite/frostbite = new(caster.mind)
	frostbite.Grant(caster)
	var/datum/action/cooldown/spell/status/haste/haste = new(caster.mind)
	haste.Grant(caster)
	var/datum/action/cooldown/spell/healing/heal = new(caster.mind)
	heal.Grant(caster)
	var/datum/action/cooldown/spell/aoe/repulse/repulse = new(caster.mind)
	repulse.Grant(caster)

	TEST_ASSERT(!(frostbite.before_cast(ally) & SPELL_CANCEL_CAST), "With protection off the aimed spell skipped the party member.")
	TEST_ASSERT(ally in repulse.get_things_to_cast_on(caster), "With protection off the area spell skipped the party member.")

	caster.party_fire_guard = TRUE
	TEST_ASSERT(frostbite.before_cast(ally) & SPELL_CANCEL_CAST, "A harmful aimed spell was not stopped on a party member.")
	TEST_ASSERT(!(frostbite.before_cast(stranger) & SPELL_CANCEL_CAST), "A harmful aimed spell was stopped on a stranger.")
	TEST_ASSERT(!(haste.before_cast(ally) & SPELL_CANCEL_CAST), "A buff spell was stopped on a party member.")
	TEST_ASSERT(!(heal.before_cast(ally) & SPELL_CANCEL_CAST), "A healing spell was stopped on a party member.")

	var/list/direct_attack_types = list(
		/datum/action/cooldown/spell/blade_burst,
		/datum/action/cooldown/spell/gravity,
		/datum/action/cooldown/spell/mind_spike,
		/datum/action/cooldown/spell/sacred_flame,
		/datum/action/cooldown/spell/heat_metal,
	)
	for(var/spell_type in direct_attack_types)
		var/datum/action/cooldown/spell/attack_spell = new spell_type(caster.mind)
		attack_spell.Grant(caster)
		TEST_ASSERT(attack_spell.before_cast(ally) & SPELL_CANCEL_CAST, "[spell_type] reached a protected party member.")
		caster.party_fire_guard = FALSE
		TEST_ASSERT(!(attack_spell.before_cast(ally) & SPELL_CANCEL_CAST), "[spell_type] ignored the disabled protection.")
		caster.party_fire_guard = TRUE
		qdel(attack_spell)

	var/list/area_targets = repulse.get_things_to_cast_on(caster)
	TEST_ASSERT(!(ally in area_targets), "An area spell still picks the caster's party member.")
	TEST_ASSERT(stranger in area_targets, "An area spell does not pick a stranger.")

	qdel(frostbite)
	qdel(haste)
	qdel(heal)
	qdel(repulse)
