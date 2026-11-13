/datum/antagonist/gnoll
	name = "Gnoll Champion"
	job_rank = ROLE_GNOLL
	roundend_category = "Gorellik's Pack"
	antagpanel_category = "Gnoll"
	show_in_roundend = FALSE
	contract_pool_type = /datum/contract_pool/gnoll
	innate_traits = list(TRAIT_VILLAIN, TRAIT_STEELHEARTED, TRAIT_GNOLLHUB)
	var/datum/team/gnoll/pack
	var/calling_type
	var/datum/devotion/gnoll/pack_devotion
	var/last_hunt_damage_time
	/// Until this time, customization edits also reshape the current body.
	var/customization_until = 0
	var/recent_hunt_damage = 0

/datum/antagonist/gnoll/create_team(datum/team/gnoll/new_team)
	if(new_team)
		if(!istype(new_team))
			CRASH("A gnoll was given an incompatible team.")
		pack = new_team
		return
	for(var/datum/team/gnoll/existing_pack in GLOB.antagonist_teams)
		pack = existing_pack
		return
	pack = new

/datum/antagonist/gnoll/get_team()
	return pack

/datum/antagonist/gnoll/can_be_owned(datum/mind/new_owner)
	if(!..() || !ishuman(new_owner.current))
		return FALSE
	for(var/datum/team/gnoll/existing_pack in GLOB.antagonist_teams)
		if(length(existing_pack.members) >= existing_pack.get_member_limit())
			return FALSE
	return TRUE

/datum/antagonist/gnoll/get_shared_contract_party()
	return pack?.contract_party

/datum/antagonist/gnoll/get_contract_minds()
	return pack ? pack.members : list(owner)

/datum/antagonist/gnoll/on_gain()
	owner.special_role = ROLE_GNOLL
	. = ..()
	for(var/datum/mind/companion in pack.members)
		owner.share_identities(companion)

/datum/antagonist/gnoll/greet()
	to_chat(owner.current, span_boldannounce("You are a champion of Gorellik's rebuilding pack."))
	to_chat(owner.current, span_notice("Your pack shares contracts. Review them through IC → Review Contract, IC → Memories, or at the shrine. Subdue your marked quarry by knockout, a yield, or thirty seconds bound while a packmate is near; revive a knocked-out quarry, then use Honor the Hunt beside them. Killing earns nothing."))
	to_chat(owner.current, span_notice("The shrine accepts provisions and tribute, and offers bonding, fertility and initiation rites. Carry a defeated or bound captive to the shrine for the fertility rite; a champion's seed then takes root. Keep or free the carrier while it grows, but release them from the camp once the birth-seed arrives."))
	to_chat(owner.current, span_notice("Your bolas and ropes take quarry alive: a quarry held bound for thirty seconds counts as subdued. Use your trail charm to consecrate distinct wilderness locations. Scent the Quarry gives a rough bearing on the current hunt; nearby listeners can hear your pack howl."))
	to_chat(owner.current, span_notice("Gnoll Claws extends blunt hunting claws in free hands. Their intents are Strike, a quick Bash, a knockback Shove and a heavy Smash; retract them to handle supplies."))
	to_chat(owner.current, span_notice("Stalk hides you until you act or take damage; use it again to reveal yourself. Cast Abduct on yourself to set an anchor, then on aggressively grabbed quarry to bring them there. Fulfilled goals grant shrine boons (free treatments) and gifts by the shrine; fully honored cycles raise Gorellik's favor, which unlocks pack perks. Preferences → Gnoll Customization saves your champion's identity and appearance; it opens after you choose a calling, and edits reshape this body for ten minutes, then apply to future spawns."))

/datum/antagonist/gnoll/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/carbon/human/champion = mob_override || owner.current
	if(!istype(champion))
		return
	champion.set_species(/datum/species/gnoll_champion)
	champion.set_patron(/datum/patron/faerun/evil_gods/Gorellik)
	champion.apply_gnoll_customization()
	RegisterSignal(champion, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_hunt_damage))
	RegisterSignal(champion, COMSIG_LIVING_DEATH, PROC_REF(on_hunt_death))
	RegisterSignal(champion, COMSIG_SEX_CLIMAX, PROC_REF(on_pack_climax))
	champion.add_spell(/datum/action/cooldown/spell/undirected/gnoll_claws, source = src)
	champion.add_spell(/datum/action/cooldown/spell/undirected/gnoll_howl, source = src)
	champion.add_spell(/datum/action/cooldown/spell/undirected/gnoll_scent, source = src)
	champion.add_spell(/datum/action/cooldown/spell/undirected/gnoll_honor_hunt, source = src)
	champion.add_spell(/datum/action/cooldown/spell/undirected/gnoll_stalk, source = src)
	champion.add_spell(/datum/action/cooldown/spell/gnoll_abduct, source = src)
	champion.add_spell(/datum/action/cooldown/spell/undirected/temporary_futanari/gnoll, source = src)
	if(calling_type)
		apply_calling(champion, calling_type)

/datum/antagonist/gnoll/remove_innate_effects(mob/living/mob_override)
	var/mob/living/body = mob_override || owner.current
	if(body)
		UnregisterSignal(body, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_LIVING_DEATH, COMSIG_SEX_CLIMAX))
		body.remove_status_effect(/datum/status_effect/invisibility/gnoll_stalk)
	body?.remove_spells(source = src)
	last_hunt_damage_time = null
	recent_hunt_damage = 0
	QDEL_NULL(pack_devotion)
	return ..()

/datum/antagonist/gnoll/proc/on_hunt_damage(mob/living/source, damage, damage_type, zone)
	SIGNAL_HANDLER
	if(damage <= 0)
		return
	if(isnull(last_hunt_damage_time) || world.time >= last_hunt_damage_time + GNOLL_ABDUCT_RECOVERY)
		recent_hunt_damage = 0
	recent_hunt_damage += damage
	last_hunt_damage_time = world.time
	source.remove_status_effect(/datum/status_effect/invisibility/gnoll_stalk)

/datum/antagonist/gnoll/proc/on_hunt_death(mob/living/source)
	SIGNAL_HANDLER
	source.remove_status_effect(/datum/status_effect/invisibility/gnoll_stalk)

/// Lets a pack without a male champion still perform the fertility rite.
/datum/action/cooldown/spell/undirected/temporary_futanari/gnoll
	name = "Gorellik's Virility"
	desc = "Grow a working penis and testicles for fifteen minutes, or until your seed takes root in a rite-marked captive. Cast again to let them fade early."

/// A pack champion climaxing inside a rite-marked captive starts the renewal pregnancy.
/datum/antagonist/gnoll/proc/on_pack_climax(mob/living/source, datum/sex_action/action, mob/living/initiator, mob/living/target, atom/performer)
	SIGNAL_HANDLER
	if(!action || action.hole_id != ORGAN_SLOT_VAGINA || action.stored_item_type != /obj/item/organ/genitals/penis)
		return
	if(action.get_storage_insertor(action.action_user, action.action_target) != source || !get_real_organ(source, ORGAN_SLOT_PENIS))
		return
	var/mob/living/carrier = action.get_storage_receiver(action.action_user, action.action_target)
	var/datum/status_effect/gnoll_fertility_mark/mark = carrier?.has_status_effect(/datum/status_effect/gnoll_fertility_mark)
	if(!mark || mark.pack_ref?.resolve() != pack)
		return
	INVOKE_ASYNC(mark, TYPE_PROC_REF(/datum/status_effect/gnoll_fertility_mark, conceive), source)

/// Opens the champion menu shortly after spawning, while edits still apply to this body.
/datum/antagonist/gnoll/proc/start_customization_window()
	customization_until = world.time + GNOLL_CUSTOMIZATION_WINDOW
	addtimer(CALLBACK(src, PROC_REF(open_customization)), 3 SECONDS)

/datum/antagonist/gnoll/proc/open_customization()
	var/mob/living/body = owner?.current
	if(!body?.client?.prefs || world.time >= customization_until)
		return
	var/datum/preference/list_type/gnoll_customization/customization = GLOB.preference_entries[/datum/preference/list_type/gnoll_customization]
	customization?.handle_link(body.client.prefs, body)

/datum/antagonist/gnoll/proc/can_focus_abduction()
	return isnull(last_hunt_damage_time) || world.time >= last_hunt_damage_time + GNOLL_ABDUCT_RECOVERY || recent_hunt_damage < GNOLL_ABDUCT_DAMAGE_LIMIT

/datum/antagonist/gnoll/Destroy()
	QDEL_NULL(pack_devotion)
	pack = null
	return ..()

/datum/antagonist/gnoll/on_contract_cycle_closed(datum/antag_contract/contract)
	. = ..()
	for(var/datum/contract_goal/gnoll/hunt/hunt in contract.goals)
		hunt.stop_tracking()

/// Class selection and later body transfers use the same grants without stacking skills or devotion.
/datum/antagonist/gnoll/proc/apply_calling(mob/living/carbon/human/champion, datum/job/advclass/gnoll/calling_path)
	calling_type = calling_path
	var/datum/species/gnoll_champion/species = champion.dna.species
	if(!istype(species))
		return
	if(istype(champion.skin_armor, /obj/item/clothing/armor/regenerating/skin/gnoll))
		champion.skin_armor.icon_state = initial(calling_path.pelt_overlay)
		apply_pelt_favor(champion)
	champion.regenerate_icons()
	if(calling_path == /datum/job/advclass/gnoll/shaman || calling_path == /datum/job/advclass/gnoll/templar)
		QDEL_NULL(pack_devotion)
		pack_devotion = new
		pack_devotion.grant_to(champion)
		champion.add_spell(/datum/action/cooldown/spell/healing, source = src)
		if(calling_path == /datum/job/advclass/gnoll/shaman)
			champion.add_spell(/datum/action/cooldown/spell/healing/greater, source = src)
			champion.add_spell(/datum/action/cooldown/spell/defeat_absolution, source = src)
			champion.add_spell(/datum/action/cooldown/spell/diagnose/holy, source = src)

/datum/antagonist/gnoll/proc/apply_pelt_favor(mob/living/carbon/human/champion)
	if(!ishuman(champion))
		return
	var/obj/item/clothing/armor/regenerating/skin/gnoll/pelt = champion.skin_armor
	if(!istype(pelt) || !calling_type)
		return
	var/datum/job/advclass/gnoll/calling_path = calling_type
	var/thick = pack?.get_favor() >= GNOLL_FAVOR_THICK_PELTS
	pelt.modify_max_integrity(round(initial(calling_path.pelt_integrity) * (thick ? 1.25 : 1)))
	pelt.repair_time = thick ? 20 SECONDS : initial(pelt.repair_time)

/datum/antagonist/gnoll/on_contract_favor_changed(old_favor, new_favor)
	. = ..()
	apply_pelt_favor(owner.current)
	var/gained = new_favor > old_favor
	var/perk = get_gnoll_favor_perk_text(gained ? new_favor : old_favor)
	if(gained)
		to_chat(owner.current, span_boldnotice("Gorellik's favor grows ([new_favor]/[GNOLL_MAX_FAVOR]). [perk]"))
	else
		to_chat(owner.current, span_warning("Gorellik's favor wanes ([new_favor]/[GNOLL_MAX_FAVOR]). The pack loses this boon: [perk]"))

/proc/get_gnoll_favor_perk_text(level)
	switch(level)
		if(GNOLL_FAVOR_KEEN_TRAIL)
			return "Keen Trail: Scent the Quarry is sharper and recovers in thirty seconds."
		if(GNOLL_FAVOR_SWIFT_PATH)
			return "Swift Path: Abduct recovers in three minutes and costs half the blood."
		if(GNOLL_FAVOR_THICK_PELTS)
			return "Thick Pelts: pelts are a quarter tougher and mend faster."
		if(GNOLL_FAVOR_RENEWAL)
			return "Renewal: the pack may hold one more champion, and ritual pregnancies grow faster."
	return ""

/datum/team/gnoll
	name = "Gorellik's Rebuilding Pack"
	member_name = "champion"
	var/datum/contract_party/contract_party
	/// Reservations cover sleeping ghost polls and initiation prompts.
	var/reserved_places = 0
	var/list/ritual_carriers = list()
	var/list/datum/weakref/birth_seeds = list()
	/// Each fulfilled goal grants one free treatment at the shrine.
	var/boon_charges = 0

/datum/team/gnoll/New(starting_members)
	contract_party = new /datum/contract_party(/datum/contract_pool/gnoll, TRUE)
	return ..()

/datum/team/gnoll/Destroy()
	QDEL_NULL(contract_party)
	ritual_carriers = null
	birth_seeds = null
	return ..()

/datum/team/gnoll/proc/has_room()
	// Count the roster, including defeated champions who can still return through their rune.
	return length(members) + reserved_places < get_member_limit()

/datum/team/gnoll/proc/get_favor()
	return contract_party?.favor || 0

/datum/team/gnoll/proc/get_member_limit()
	return GNOLL_PACK_LIMIT + (get_favor() >= GNOLL_FAVOR_RENEWAL ? 1 : 0)

/// Fulfilled goals pay a shrine boon and leave a small gift beside a shrine.
/datum/team/gnoll/proc/on_goal_fulfilled(datum/contract_goal/gnoll/goal)
	boon_charges++
	var/obj/structure/gnoll_shrine/shrine = length(GLOB.gnoll_shrines) ? pick(GLOB.gnoll_shrines) : null
	var/gift = shrine?.leave_gift()
	contract_party.notify_members("Gorellik grants the pack a boon[gift ? " and leaves [gift] by the shrine" : ""]. Boon charges: [boon_charges].")

/datum/team/gnoll/proc/get_goal(goal_path)
	for(var/datum/contract_goal/goal in contract_party.current_contract?.goals)
		if(istype(goal, goal_path) && !goal.completed)
			return goal
	return null

/datum/team/gnoll/proc/has_birth_seed()
	for(var/datum/weakref/seed_ref as anything in birth_seeds.Copy())
		if(seed_ref.resolve())
			return TRUE
		birth_seeds -= seed_ref
	return FALSE

/// The renewal counts only once the carrier has left the camp after the birth-seed arrives.
/datum/team/gnoll/proc/credit_ritual_release(mob/living/carrier)
	var/datum/contract_goal/gnoll/fertility/goal = get_goal(/datum/contract_goal/gnoll/fertility)
	if(goal?.record_once(carrier.mind))
		contract_party.notify_members("[carrier.real_name] has left the camp. The pack's renewal is honored.")
	to_chat(carrier, span_notice("You are free of Gorellik's pack. You owe it nothing further."))

/datum/team/gnoll/roundend_report()
	return "[..()]<br>[contract_party.roundend_ledger()]"

/proc/get_gnoll_antag(mob/living/body)
	return body?.mind?.has_antag_datum(/datum/antagonist/gnoll)

/// Ritual participants must be present, awake adult players.
/proc/can_join_gnoll_rite(mob/living/carbon/human/participant)
	return istype(participant) && participant.client && participant.mind && participant.stat == CONSCIOUS && (participant.age in list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL))

/// A captive is an adult player the pack has defeated, bound, carries or holds in an aggressive grab.
/proc/is_gnoll_captive(mob/living/carbon/human/captive, require_client = TRUE)
	if(!istype(captive) || (require_client && !captive.client) || !captive.mind || captive.stat == DEAD || get_gnoll_antag(captive))
		return FALSE
	if(!(captive.age in list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)))
		return FALSE
	if(captive.has_status_effect(/datum/status_effect/defeat_knockout) || HAS_TRAIT(captive, TRAIT_RESTRAINED) || captive.handcuffed || captive.legcuffed)
		return TRUE
	if(isliving(captive.buckled) && get_gnoll_antag(captive.buckled))
		return TRUE
	var/mob/living/holder = captive.pulledby
	return holder?.grab_state >= GRAB_AGGRESSIVE && get_gnoll_antag(holder)

/// The carrier opted into antagonist pregnancy and has not carried this pack's renewal before.
/proc/can_carry_gnoll_renewal(mob/living/carbon/human/captive, datum/team/gnoll/pack, require_client = TRUE)
	if(!is_gnoll_captive(captive, require_client) || !captive.has_erp_pref(/datum/erp_preference/boolean/antag_pregnancy))
		return FALSE
	if(captive.has_status_effect(/datum/status_effect/gnoll_fertility_mark) || (REF(captive.mind) in pack.ritual_carriers))
		return FALSE
	return !!get_gnoll_ritual_womb(captive)

/proc/is_in_gnoll_camp(atom/movable/thing)
	return istype(get_area(thing), /area/outdoors/gnoll_camp)

