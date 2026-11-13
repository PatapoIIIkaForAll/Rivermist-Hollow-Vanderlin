/datum/contract_pool/gnoll
	patron_name = "Gorellik"
	issue_text = "The rebuilding pack receives its next shared rites."
	success_text = "Gorellik's old faith stirs. The pack has honored its living vows."
	failure_text = "The pack's vows went unfinished; the old god's attention wanders."
	excused_text = "The wilderness keeps the pack's vows until its companions return."
	goals_per_contract_min = 2
	goals_per_contract_max = 2
	max_favor = GNOLL_MAX_FAVOR
	goal_templates = list(
		/datum/contract_goal/gnoll/hunt,
		/datum/contract_goal/gnoll/territory,
		/datum/contract_goal/gnoll/provisions,
		/datum/contract_goal/gnoll/tribute,
		/datum/contract_goal/gnoll/bond,
		/datum/contract_goal/gnoll/fertility,
		/datum/contract_goal/gnoll/awakening,
	)

/datum/contract_pool/gnoll/roll_goals(datum/antagonist/antag, tier_ceiling, list/exclude_types)
	var/list/goals = ..()
	// Sparse populations and a full pack can leave too few eligible templates after anti-repeat.
	if(length(goals) < goals_per_contract_min)
		var/list/excluded = list()
		for(var/datum/contract_goal/goal in goals)
			excluded += goal.type
		var/list/fallback = ..(antag, tier_ceiling, excluded)
		while(length(fallback))
			var/datum/contract_goal/goal = fallback[1]
			fallback.Cut(1, 2)
			if(length(goals) < goals_per_contract_min)
				goals += goal
			else
				qdel(goal)
	return goals

/datum/contract_goal/gnoll
	var/list/credited_refs = list()

/datum/contract_goal/gnoll/is_valid(datum/antagonist/antag)
	return istype(antag, /datum/antagonist/gnoll)

/datum/contract_goal/gnoll/proc/record_once(datum/subject)
	if(completed || !subject || (REF(subject) in credited_refs))
		return FALSE
	credited_refs += REF(subject)
	add_progress()
	return TRUE

/datum/contract_goal/gnoll/complete()
	var/was_completed = completed
	. = ..()
	var/datum/team/gnoll/pack = get_pack()
	if(!was_completed && completed)
		pack?.on_goal_fulfilled(src)

/datum/contract_goal/gnoll/proc/get_pack()
	var/datum/antagonist/gnoll/champion = antag
	return champion?.pack

/datum/contract_goal/gnoll/hunt
	name = "honor a living hunt"
	description_template = "Subdue the marked quarry: knock them out, make them yield, or keep them tied up for thirty seconds while a packmate is near. Revive a knocked-out quarry, then use Honor the Hunt beside them."
	triumph_reward = 3
	var/datum/weakref/quarry_ref
	var/quarry_name
	var/downed_by_pack = FALSE
	var/recovered = FALSE
	/// Pending check that the quarry stayed tied up long enough.
	var/bound_timer

/datum/contract_goal/gnoll/hunt/is_valid(datum/antagonist/antag)
	return ..() && select_quarry()

/datum/contract_goal/gnoll/hunt/Destroy()
	stop_tracking()
	quarry_ref = null
	return ..()

/datum/contract_goal/gnoll/hunt/proc/stop_tracking()
	var/mob/living/quarry = quarry_ref?.resolve()
	if(quarry)
		UnregisterSignal(quarry, list(COMSIG_LIVING_DEFEATED, COMSIG_LIVING_DEFEAT_RESCUED, COMSIG_LIVING_YIELDED, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED)))
	deltimer(bound_timer)
	bound_timer = null

/datum/contract_goal/gnoll/hunt/proc/is_current()
	return !completed && (src in antag?.contract_party?.current_contract?.goals)

/datum/contract_goal/gnoll/hunt/proc/select_quarry()
	var/datum/team/gnoll/pack = get_pack()
	if(!pack)
		return FALSE
	var/list/candidates = list()
	for(var/mob/living/carbon/human/person in GLOB.player_list)
		if(!can_join_gnoll_rite(person) || !person.defeat_system_is_eligible() || (person.mind in pack.members) || length(person.mind.antag_datums))
			continue
		candidates += person
	if(!length(candidates))
		return FALSE
	track_quarry(pick(candidates))
	return TRUE

/// Swaps the hunt onto a new quarry, resetting progress and its signal hooks.
/datum/contract_goal/gnoll/hunt/proc/track_quarry(mob/living/carbon/human/quarry)
	stop_tracking()
	quarry_ref = WEAKREF(quarry)
	quarry_name = quarry.real_name
	downed_by_pack = FALSE
	recovered = FALSE
	RegisterSignal(quarry, COMSIG_LIVING_DEFEATED, PROC_REF(on_quarry_defeated))
	RegisterSignal(quarry, COMSIG_LIVING_DEFEAT_RESCUED, PROC_REF(on_quarry_recovered))
	RegisterSignal(quarry, COMSIG_LIVING_YIELDED, PROC_REF(on_quarry_yielded))
	RegisterSignal(quarry, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_quarry_bound))
	RegisterSignal(quarry, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), PROC_REF(on_quarry_unbound))

/datum/contract_goal/gnoll/hunt/proc/get_quarry()
	var/mob/living/carbon/human/quarry = quarry_ref?.resolve()
	if(!quarry?.client || !quarry.mind || quarry.stat == DEAD || !quarry.defeat_system_is_eligible() || get_gnoll_antag(quarry))
		if(!is_current() || !select_quarry())
			return null
		quarry = quarry_ref.resolve()
	return quarry

/datum/contract_goal/gnoll/hunt/get_description()
	return "Hunt [html_encode(quarry_name || "a worthy quarry")]: knock them out, make them yield, or keep them tied up for thirty seconds; revive them if needed, then use Honor the Hunt beside them. ([progress]/[target_amount])"

/datum/contract_goal/gnoll/hunt/proc/on_quarry_defeated(mob/living/source)
	SIGNAL_HANDLER
	if(!is_current())
		return
	var/reason = source.last_defeat_snapshot?.reason
	var/mob/living/attacker = source.last_defeat_snapshot?.source_weakref?.resolve()
	// Limb damage can trigger KO before the recent-damage snapshot records its attacker.
	if(reason == DEFEAT_REASON_DAMAGE || reason == DEFEAT_REASON_DEATH)
		attacker = source.get_damage_attack_context() || attacker
	var/datum/antagonist/gnoll/hunter = get_gnoll_antag(attacker)
	downed_by_pack = hunter && hunter.pack == get_pack() && reason != DEFEAT_REASON_HORNY
	recovered = FALSE
	if(downed_by_pack)
		antag.contract_party.notify_members("[quarry_name] is down. Revive the quarry, then use Honor the Hunt beside them.")

/datum/contract_goal/gnoll/hunt/proc/on_quarry_recovered(mob/living/source, mob/living/helper, rescue_source)
	SIGNAL_HANDLER
	if(is_current() && downed_by_pack)
		recovered = TRUE

/datum/contract_goal/gnoll/hunt/proc/on_quarry_yielded(mob/living/source)
	SIGNAL_HANDLER
	if(is_current() && is_pack_near(source))
		mark_subdued("[quarry_name] yields to the pack.")

/datum/contract_goal/gnoll/hunt/proc/on_quarry_bound(mob/living/source)
	SIGNAL_HANDLER
	if(!is_current())
		return
	deltimer(bound_timer)
	bound_timer = addtimer(CALLBACK(src, PROC_REF(check_still_bound)), GNOLL_HUNT_BOUND_TIME, TIMER_STOPPABLE)

/datum/contract_goal/gnoll/hunt/proc/on_quarry_unbound(mob/living/source)
	SIGNAL_HANDLER
	deltimer(bound_timer)
	bound_timer = null

/datum/contract_goal/gnoll/hunt/proc/check_still_bound()
	bound_timer = null
	var/mob/living/quarry = quarry_ref?.resolve()
	if(is_current() && quarry && HAS_TRAIT(quarry, TRAIT_RESTRAINED) && is_pack_near(quarry))
		mark_subdued("[quarry_name] has been held bound long enough.")

/// An awake, yielded or bound quarry needs no revival before the hunt is honored.
/datum/contract_goal/gnoll/hunt/proc/mark_subdued(message)
	if(downed_by_pack && recovered)
		return
	downed_by_pack = TRUE
	recovered = TRUE
	antag.contract_party.notify_members("[message] Use Honor the Hunt beside them.")

/datum/contract_goal/gnoll/hunt/proc/is_pack_near(mob/living/quarry)
	var/datum/team/gnoll/pack = get_pack()
	for(var/datum/mind/member as anything in pack?.members)
		var/mob/living/hunter = member.current
		if(istype(hunter) && hunter.stat == CONSCIOUS && hunter.z == quarry.z && get_dist(hunter, quarry) <= GNOLL_HUNT_WITNESS_RANGE)
			return TRUE
	return FALSE

/datum/contract_goal/gnoll/hunt/proc/conclude(mob/living/carbon/human/hunter)
	var/mob/living/carbon/human/quarry = get_quarry()
	if(!is_current() || !downed_by_pack || !recovered || !quarry || !hunter.Adjacent(quarry) || !can_join_gnoll_rite(quarry))
		return FALSE
	complete()
	stop_tracking()
	to_chat(quarry, span_notice("Gorellik's pack acknowledges the end of the hunt. You are free to go; no further rite is owed."))
	return TRUE

/datum/contract_goal/gnoll/territory
	name = "renew the wild trails"
	description_template = "Consecrate %TARGET% wilderness sites with a trail charm or ritual chalk, at least twenty tiles apart."
	target_minimum = 2
	target_maximum = 3
	var/list/sites = list()

/datum/contract_goal/gnoll/territory/proc/record_site(turf/site)
	if(completed || !site)
		return FALSE
	var/area/site_area = get_area(site)
	if(!site_area.outdoors || istype(site_area, /area/outdoors/town) || istype(site_area, /area/outdoors/exposed/town) || istype(site_area, /area/outdoors/gnoll_camp))
		return FALSE
	for(var/list/coordinates as anything in sites)
		if(coordinates[3] == site.z && max(abs(coordinates[1] - site.x), abs(coordinates[2] - site.y)) < 20)
			return FALSE
	sites += list(list(site.x, site.y, site.z))
	add_progress()
	return TRUE

/datum/contract_goal/gnoll/provisions
	name = "feed the living pack"
	description_template = "Offer food worth %TARGET% points at Gorellik's shrine. Raw, rotten or burnt food is worth 1, plain cooked food 2, and hearty dishes 3."
	target_minimum = 6
	target_maximum = 10

/// Raw or spoiled food counts once, plain cooked food twice, and dishes that give a meal buff three times.
/datum/contract_goal/gnoll/provisions/proc/get_offering_value(obj/item/reagent_containers/food/snacks/food)
	if(ispath(food.eat_effect, /datum/status_effect/buff))
		return 3
	if(ispath(food.eat_effect, /datum/status_effect/debuff))
		return 1
	return 2

/datum/contract_goal/gnoll/tribute
	name = "gather tribute"
	description_template = "Offer %TARGET% amnas in negotiated tribute at Gorellik's shrine."
	target_minimum = 100
	target_maximum = 150

/datum/contract_goal/gnoll/bond
	name = "renew the pack's bonds"
	description_template = "Complete a bonding rite with %TARGET% distinct companions."
	target_minimum = 1
	target_maximum = 2

/datum/contract_goal/gnoll/bond/is_valid(datum/antagonist/antag)
	if(!..())
		return FALSE
	var/eligible_companions = 0
	for(var/mob/living/carbon/human/companion in GLOB.player_list)
		if(companion.mind != antag.owner && can_join_gnoll_rite(companion))
			eligible_companions++
	target_amount = min(target_amount, eligible_companions)
	return target_amount > 0

/datum/contract_goal/gnoll/fertility
	name = "carry the pack's renewal"
	description_template = "Bring a captive to the shrine, perform the fertility rite and seed them. Once the birth-seed arrives, release the carrier from the camp."
	triumph_reward = 3

/datum/contract_goal/gnoll/fertility/is_valid(datum/antagonist/antag)
	if(!..())
		return FALSE
	var/datum/team/gnoll/pack = get_pack()
	if(!pack.has_room())
		return FALSE
	for(var/mob/living/carbon/human/carrier in GLOB.player_list)
		if(!carrier.mind || get_gnoll_antag(carrier) || (REF(carrier.mind) in pack.ritual_carriers))
			continue
		if(carrier.has_erp_pref(/datum/erp_preference/boolean/antag_pregnancy) && get_gnoll_ritual_womb(carrier))
			return TRUE
	return FALSE

/datum/contract_goal/gnoll/awakening
	name = "welcome a mature champion"
	description_template = "Awaken a fully mature adult champion from a pack birth-seed at the shrine."
	triumph_reward = 3

/datum/contract_goal/gnoll/awakening/is_valid(datum/antagonist/antag)
	var/datum/team/gnoll/pack = get_pack()
	return ..() && pack?.has_room() && pack.has_birth_seed() && gnoll_awakening_has_candidates()

/// The awakening polls observers and lobby players; with none available the goal could never be met.
/proc/gnoll_awakening_has_candidates()
	return length(get_ghost_poll_pool()) > 0

/obj/item/gnoll_trail_charm
	name = "Gorellik's trail charm"
	desc = "A braided wilderness charm. Use it in the wilderness to consecrate a trail for your pack."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "amulet"
	w_class = WEIGHT_CLASS_SMALL
	var/trail_message = "consecrates the wild trail with a braided charm"
	var/trail_mark_type

/obj/item/gnoll_trail_charm/attack_self(mob/user, list/modifiers)
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
	if(!champion?.pack)
		to_chat(user, span_warning("Only Gorellik's champions can consecrate trails with this."))
		return
	var/datum/contract_goal/gnoll/territory/goal = champion.pack.get_goal(/datum/contract_goal/gnoll/territory)
	var/turf/site = get_turf(user)
	if(!goal)
		to_chat(user, span_warning("The pack has no unfinished trail rite."))
		return
	if(!do_after(user, GNOLL_RITE_TIME, target = src))
		return
	if(QDELETED(src) || QDELETED(user) || QDELETED(goal) || get_turf(user) != site || get_gnoll_antag(user) != champion || champion.pack.get_goal(/datum/contract_goal/gnoll/territory) != goal)
		return
	if(goal.record_site(site))
		user.visible_message(span_notice("[user] [trail_message]."))
		if(trail_mark_type)
			new trail_mark_type(site)
	else
		to_chat(user, span_warning("Choose wilderness outside town and camp, at least twenty tiles from the pack's other sites."))

