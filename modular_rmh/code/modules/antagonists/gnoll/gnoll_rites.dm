GLOBAL_LIST_EMPTY(gnoll_shrines)

/area/outdoors/gnoll_camp
	name = "Gorellik's Wilderness Camp"

/obj/structure/gnoll_shrine
	name = "Gorellik's pack shrine"
	desc = "A wilderness shrine bound with pelts and braided cords. Champions offer provisions and tribute here, hold bonding rites, or claim captives for the fertility rite. Birth-seeds awaken into mature champions here."
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "shrine_dendor_volf"
	density = TRUE
	anchored = TRUE
	var/datum/defeat_trauma_provider/shrine/structure/treatment_provider
	var/datum/defeat_trauma_provider/shrine/structure/gnoll_boon/boon_provider

/obj/structure/gnoll_shrine/Initialize(mapload)
	. = ..()
	GLOB.gnoll_shrines += src
	treatment_provider = new(src)
	boon_provider = new(src)

/obj/structure/gnoll_shrine/Destroy()
	GLOB.gnoll_shrines -= src
	QDEL_NULL(treatment_provider)
	QDEL_NULL(boon_provider)
	return ..()

/obj/structure/gnoll_shrine/examine(mob/user)
	. = ..()
	if(get_gnoll_antag(user))
		. += "<a href='byond://?src=[REF(src)];review_contract=1'>Review the pack's contract</a>"

/obj/structure/gnoll_shrine/Topic(href, list/href_list)
	. = ..()
	if(!href_list["review_contract"])
		return
	var/mob/living/user = usr
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
	if(champion && get_dist(user, src) <= 7)
		show_pack_contract(user, champion)

/// Contract goals plus the pack's boons and unlocked favor perks.
/obj/structure/gnoll_shrine/proc/show_pack_contract(mob/living/user, datum/antagonist/gnoll/champion)
	var/datum/team/gnoll/pack = champion.pack
	if(!pack?.contract_party?.contract_pool)
		to_chat(user, span_notice("Gorellik makes no demands of the pack right now."))
		return
	var/list/lines = pack.contract_party.get_demand_lines()
	lines += "Boon charges: [pack.boon_charges]"
	for(var/level in 1 to pack.get_favor())
		lines += "- [get_gnoll_favor_perk_text(level)]"
	to_chat(user, examine_block(span_notice(lines.Join("<br>"))))

/obj/structure/gnoll_shrine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	INVOKE_ASYNC(src, PROC_REF(choose_rite), user)
	return TRUE

/obj/structure/gnoll_shrine/proc/choose_rite(mob/living/carbon/human/user)
	if(!can_join_gnoll_rite(user) || !Adjacent(user))
		return
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
	if(!champion)
		to_chat(user, span_notice("A champion must invite you to this pack's rites."))
		return
	var/list/rites = list("Review the pack's contract", "Bonding rite", "Fertility rite", "Initiate a Lesser Gnoll", "Treat defeat trauma")
	if(champion.pack.boon_charges > 0)
		rites += "Spend a boon on treatment"
	var/choice = tgui_input_list(user, "Choose a pack rite. Boon charges: [champion.pack.boon_charges].", name, rites)
	if(QDELETED(src) || !Adjacent(user) || !can_join_gnoll_rite(user) || get_gnoll_antag(user) != champion)
		return
	if(choice == "Review the pack's contract")
		show_pack_contract(user, champion)
		return
	if(choice == "Treat defeat trauma")
		treatment_provider.station_interact(user, user.get_active_held_item())
		return
	if(choice == "Spend a boon on treatment")
		spend_boon(user, champion)
		return
	if(!choice)
		return
	if(choice == "Fertility rite")
		begin_fertility_rite(user, champion)
		return
	if(choice == "Bonding rite" && user.has_status_effect(/datum/status_effect/gnoll_bond))
		to_chat(user, span_warning("Finish your existing bonding rite first, or let it lapse."))
		return
	var/list/partners = list()
	for(var/mob/living/carbon/human/partner in oview(1, user))
		if(can_join_gnoll_rite(partner) && Adjacent(partner))
			if(choice == "Bonding rite" && partner.has_status_effect(/datum/status_effect/gnoll_bond))
				continue
			partners += partner
	if(!length(partners))
		to_chat(user, span_notice("No quarry near the shrine."))
		return
	var/mob/living/carbon/human/partner
	if(choice == "Bonding rite" && length(partners) == 1)
		partner = partners[1]
	else
		partner = tgui_input_list(user, "Choose quarry beside the shrine.", name, partners)
	if(QDELETED(src) || !Adjacent(user) || !Adjacent(partner) || !can_join_gnoll_rite(user) || !can_join_gnoll_rite(partner) || get_gnoll_antag(user) != champion)
		return
	switch(choice)
		if("Bonding rite")
			if(user.has_status_effect(/datum/status_effect/gnoll_bond) || partner.has_status_effect(/datum/status_effect/gnoll_bond))
				to_chat(user, span_warning("Finish your existing bonding rite first, or let it lapse."))
				return
			if(!user.apply_status_effect(/datum/status_effect/gnoll_bond, partner, champion.pack))
				return
			if(!partner.apply_status_effect(/datum/status_effect/gnoll_bond, user, champion.pack))
				user.remove_status_effect(/datum/status_effect/gnoll_bond)
				return
			user.visible_message(span_notice("The ritual begins - claim your quarry."))
		if("Initiate a Lesser Gnoll")
			initiate_gnoll(user, partner, champion)

/// The charge is held during the treatment prompt and refunded if nothing is treated.
/obj/structure/gnoll_shrine/proc/spend_boon(mob/living/carbon/human/user, datum/antagonist/gnoll/champion)
	var/datum/team/gnoll/pack = champion.pack
	if(pack.boon_charges <= 0)
		to_chat(user, span_warning("The pack has no boon to spend."))
		return
	pack.boon_charges--
	if(boon_provider.station_interact(user, null))
		pack.contract_party.notify_members("[user.real_name] spends one of Gorellik's boons at the shrine. Boon charges: [pack.boon_charges].")
		return
	if(!QDELETED(pack))
		pack.boon_charges++

/// Drops one weighted gift on a free tile beside the shrine and returns its description.
/obj/structure/gnoll_shrine/proc/leave_gift()
	var/list/spots = list()
	for(var/turf/open/spot in orange(1, src))
		if(!spot.is_blocked_turf(TRUE))
			spots += spot
	var/turf/drop = length(spots) ? pick(spots) : get_turf(src)
	if(!drop)
		return null
	var/gift = pickweight(list(
		"herbs" = 30,
		/obj/item/reagent_containers/glass/bottle/healthpot = 18,
		/obj/item/reagent_containers/glass/bottle/stampot = 10,
		/obj/item/reagent_containers/glass/bottle/vial/mercydraught = 8,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot = 4,
		/obj/item/natural/bundle/cloth/bandage/full = 10,
		/obj/item/weapon/knife/dagger/steel = 8,
		/obj/item/weapon/knife/dagger/steel/dirk = 5,
		/obj/item/weapon/knife/dagger/navaja = 4,
		/obj/item/weapon/knife/dagger/steel/stiletto = 3,
	))
	if(gift == "herbs")
		var/static/list/medicinal_herbs = list(/obj/item/alch/herb/symphitum, /obj/item/alch/herb/hypericum, /obj/item/alch/herb/calendula, /obj/item/alch/herb/salvia, /obj/item/alch/herb/matricaria, /obj/item/alch/herb/valeriana, /obj/item/alch/herb/rosa)
		for(var/i in 1 to 3)
			var/herb_type = pick(medicinal_herbs)
			new herb_type(drop)
		return "a bundle of medicinal herbs"
	var/obj/item/item = new gift(drop)
	return "\a [item]"

/// Paid for by the pack's boon charges: no supplies or training needed.
/datum/defeat_trauma_provider/shrine/structure/gnoll_boon
	station_name = "Gorellik's boon"
	required_skill = null
	untrained_time_multiplier = 1
	resource_cost_override = 0

/// Marks a captive beside the shrine; a champion's climax inside them later starts the pregnancy.
/obj/structure/gnoll_shrine/proc/begin_fertility_rite(mob/living/carbon/human/user, datum/antagonist/gnoll/champion)
	var/datum/team/gnoll/pack = champion.pack
	if(!pack.has_room())
		to_chat(user, span_warning("The pack has reached its champion limit."))
		return
	var/list/captives = list()
	for(var/mob/living/carbon/human/captive in oview(1, user))
		if(Adjacent(captive) && can_carry_gnoll_renewal(captive, pack))
			captives += captive
	if(!length(captives))
		to_chat(user, span_notice("No captive beside the shrine can carry the pack's renewal."))
		return
	var/mob/living/carbon/human/captive = length(captives) == 1 ? captives[1] : tgui_input_list(user, "Choose the captive to carry the pack's renewal.", name, captives)
	if(!captive || QDELETED(src) || !Adjacent(user) || !Adjacent(captive) || get_gnoll_antag(user) != champion)
		return
	user.visible_message(span_warning("[user] begins Gorellik's renewal rite over [captive]."))
	if(!do_after(user, GNOLL_RITE_TIME, target = captive))
		return
	if(QDELETED(src) || !Adjacent(user) || !Adjacent(captive) || !can_join_gnoll_rite(user) || get_gnoll_antag(user) != champion || !pack.has_room() || !can_carry_gnoll_renewal(captive, pack))
		return
	if(!captive.apply_status_effect(/datum/status_effect/gnoll_fertility_mark, pack))
		return
	captive.apply_status_effect(/datum/status_effect/debuff/defeat/gnoll_captive)
	captive.add_stress(/datum/stress_event/gnoll_captured)
	to_chat(captive, span_userdanger("Gorellik's renewal rite settles over you. A pack champion's seed can now take root in you."))
	to_chat(user, span_notice("The rite takes hold. A champion's seed can now quicken within [captive]."))
	log_game("[key_name(user)] marked captive [key_name(captive)] for a Gnoll fertility rite at [AREACOORD(src)].")

/obj/structure/gnoll_shrine/proc/initiate_gnoll(mob/living/carbon/human/user, mob/living/carbon/human/partner, datum/antagonist/gnoll/champion)
	var/datum/team/gnoll/pack = champion.pack
	if(partner.dna?.species?.id != SPEC_ID_GNOLL || length(partner.mind.antag_datums) || !pack.has_room() || is_total_antag_banned(partner.ckey) || is_antag_banned(partner.ckey, ROLE_GNOLL))
		to_chat(user, span_warning("Only an eligible, unaffiliated Lesser Gnoll can take this oath, while the pack has room."))
		return
	pack.reserved_places++
	var/answer = tgui_alert(partner, "Join Gorellik's rebuilding pack as an antagonist? You will become a supernatural Gnoll Champion, leave your current job, and share the pack's contracts. The pack forbids killing quarry and requires their recovery and release.", "Initiation oath", list("Join the pack", "Decline"))
	if(answer == "Join the pack" && !QDELETED(src) && Adjacent(user) && Adjacent(partner) && can_join_gnoll_rite(user) && can_join_gnoll_rite(partner) && get_gnoll_antag(user) == champion && partner.dna?.species?.id == SPEC_ID_GNOLL && !length(partner.mind.antag_datums) && !is_total_antag_banned(partner.ckey) && !is_antag_banned(partner.ckey, ROLE_GNOLL))
		if(do_after(user, GNOLL_RITE_TIME, target = partner) && !QDELETED(src) && Adjacent(user) && Adjacent(partner) && can_join_gnoll_rite(user) && can_join_gnoll_rite(partner) && get_gnoll_antag(user) == champion && partner.dna?.species?.id == SPEC_ID_GNOLL && !length(partner.mind.antag_datums) && !is_total_antag_banned(partner.ckey) && !is_antag_banned(partner.ckey, ROLE_GNOLL))
			if(partner.mind.add_antag_datum(/datum/antagonist/gnoll, pack))
				partner.job = ROLE_GNOLL
				partner.mind.set_assigned_role(SSjob.GetJobType(/datum/job/gnoll))
				partner.hugboxify_for_class_selection()
				SSrole_class_handler.setup_class_handler(partner)
			else
				to_chat(partner, span_notice("The pack cannot accept your oath right now. Your calling is unchanged."))
	pack.reserved_places--

/obj/structure/gnoll_shrine/attackby(obj/item/offering, mob/living/user, list/modifiers)
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
	if(!champion || !can_join_gnoll_rite(user) || !Adjacent(user))
		return ..()
	if(istype(offering, /obj/item/gnoll_birth_seed))
		INVOKE_ASYNC(src, PROC_REF(awaken_champion), user, offering)
		return TRUE
	if(istype(offering, /obj/item/coin))
		var/datum/contract_goal/gnoll/tribute/goal = champion.pack.get_goal(/datum/contract_goal/gnoll/tribute)
		if(!goal)
			to_chat(user, span_notice("There is no unfinished tribute contract. Use the shrine's treatment rite to spend silver on trauma care."))
			return TRUE
		var/obj/item/coin/coins = offering
		var/value = coins.get_real_price()
		if(value > 0 && user.temporarilyRemoveItemFromInventory(coins))
			goal.add_progress(value)
			qdel(coins)
		return TRUE
	if(istype(offering, /obj/item/reagent_containers/food/snacks))
		var/datum/contract_goal/gnoll/provisions/goal = champion.pack.get_goal(/datum/contract_goal/gnoll/provisions)
		var/obj/item/reagent_containers/food/snacks/meal = offering
		var/obj/item/reagent_containers/food/snacks/meat/flesh = meal
		if(istype(flesh) && flesh.cannibalism)
			to_chat(user, span_warning("Gorellik refuses the flesh of people."))
			return TRUE
		if(!goal || istype(meal, /obj/item/reagent_containers/food/snacks/oviposition_egg) || meal.reagents?.get_reagent_amount(/datum/reagent/consumable/nutriment) <= 0)
			to_chat(user, span_warning("The pack has no use for this as a provision right now."))
			return TRUE
		if(user.temporarilyRemoveItemFromInventory(meal))
			goal.add_progress(goal.get_offering_value(meal))
			qdel(meal)
		return TRUE
	return ..()

/// Lapses after GNOLL_BOND_DURATION, or at once when the partners end up too far apart.
/datum/status_effect/gnoll_bond
	id = "gnoll_bond"
	duration = GNOLL_BOND_DURATION
	tick_interval = 2 SECONDS
	alert_type = null
	var/datum/weakref/partner_ref
	var/datum/weakref/pack_ref
	/// Shown when the bond ends; null uses the lapse message, an empty string stays silent.
	var/end_message

/datum/status_effect/gnoll_bond/on_creation(mob/living/new_owner, mob/living/partner, datum/team/gnoll/pack)
	partner_ref = WEAKREF(partner)
	pack_ref = WEAKREF(pack)
	return ..()

/datum/status_effect/gnoll_bond/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_SEX_CLIMAX, PROC_REF(on_bond_scene))
	return TRUE

/datum/status_effect/gnoll_bond/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_SEX_CLIMAX)
	if(isnull(end_message))
		to_chat(owner, span_notice("The pack's bonding rite lapses unfulfilled."))
	else if(end_message)
		to_chat(owner, span_notice(end_message))
	var/mob/living/partner = partner_ref?.resolve()
	partner_ref = null
	var/datum/status_effect/gnoll_bond/other_bond = partner?.has_status_effect(/datum/status_effect/gnoll_bond)
	if(other_bond?.partner_ref?.resolve() == owner)
		if(isnull(other_bond.end_message))
			other_bond.end_message = end_message
		partner.remove_status_effect(/datum/status_effect/gnoll_bond)
	pack_ref = null

/datum/status_effect/gnoll_bond/tick()
	var/mob/living/partner = partner_ref?.resolve()
	if(!partner || !owner.z || owner.z != partner.z || get_dist(owner, partner) > GNOLL_BOND_ESCAPE_RANGE)
		end_message = "The bonding rite breaks as the partners part ways."
		qdel(src)

/datum/status_effect/gnoll_bond/proc/on_bond_scene(mob/living/source, datum/sex_action/action, mob/living/receiver, mob/living/action_partner, atom/performer)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/partner = partner_ref?.resolve()
	var/datum/team/gnoll/pack = pack_ref?.resolve()
	if(!pack || !action || !action.is_runtime_active() || !can_join_gnoll_rite(owner) || !can_join_gnoll_rite(partner) || !owner.Adjacent(partner))
		return
	if(!((action.action_user == owner && action.action_target == partner) || (action.action_user == partner && action.action_target == owner)))
		return
	var/datum/status_effect/gnoll_bond/other_bond = partner.has_status_effect(/datum/status_effect/gnoll_bond)
	if(other_bond?.partner_ref?.resolve() != owner || other_bond.pack_ref?.resolve() != pack)
		return
	var/datum/contract_goal/gnoll/bond/goal = pack.get_goal(/datum/contract_goal/gnoll/bond)
	var/datum/mind/companion = (owner.mind in pack.members) ? partner.mind : owner.mind
	goal?.record_once(companion)
	end_message = "The pack's bonding rite is honored."
	owner.remove_status_effect(/datum/status_effect/gnoll_bond)

/// Set by the shrine's fertility rite; the next pack champion to climax inside the captive conceives.
/datum/status_effect/gnoll_fertility_mark
	id = "gnoll_fertility_mark"
	duration = GNOLL_FERTILITY_MARK_DURATION
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	var/datum/weakref/pack_ref

/datum/status_effect/gnoll_fertility_mark/on_creation(mob/living/new_owner, datum/team/gnoll/pack)
	pack_ref = WEAKREF(pack)
	return ..()

/datum/status_effect/gnoll_fertility_mark/on_remove()
	pack_ref = null
	return ..()

/datum/status_effect/gnoll_fertility_mark/proc/conceive(mob/living/carbon/human/father)
	var/mob/living/carbon/human/carrier = owner
	var/datum/team/gnoll/pack = pack_ref?.resolve()
	if(QDELETED(src) || !pack || !istype(carrier) || !carrier.mind || !pack.has_room() || (REF(carrier.mind) in pack.ritual_carriers))
		return FALSE
	if(!carrier.has_erp_pref(/datum/erp_preference/boolean/antag_pregnancy))
		qdel(src)
		return FALSE
	var/obj/item/organ/genitals/filling_organ/womb/womb = get_gnoll_ritual_womb(carrier)
	if(!womb || !start_gnoll_ritual_pregnancy(carrier, father, pack, womb))
		return FALSE
	pack.ritual_carriers += REF(carrier.mind)
	var/datum/status_effect/temporary_futanari/virility = father.has_status_effect(/datum/status_effect/temporary_futanari)
	virility?.request_dissipation()
	to_chat(carrier, span_userdanger("Gorellik's renewal quickens inside you. It will grow whether the pack keeps you or lets you go; ordinary remedies can still end it."))
	to_chat(father, span_notice("The renewal quickens within [carrier]. Once the birth-seed arrives, the pack must release them from the camp."))
	log_game("[key_name(father)] started a Gnoll ritual pregnancy in [key_name(carrier)] at [AREACOORD(carrier)].")
	qdel(src)
	return TRUE

/// Applied at birth while the carrier is still in the camp; leaving it credits the fertility contract.
/datum/status_effect/gnoll_owed_release
	id = "gnoll_owed_release"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 10 SECONDS
	alert_type = null
	var/datum/weakref/pack_ref
	var/next_reminder = 0

/datum/status_effect/gnoll_owed_release/on_creation(mob/living/new_owner, datum/team/gnoll/pack)
	pack_ref = WEAKREF(pack)
	return ..()

/datum/status_effect/gnoll_owed_release/on_remove()
	pack_ref = null
	return ..()

/datum/status_effect/gnoll_owed_release/tick()
	var/datum/team/gnoll/pack = pack_ref?.resolve()
	if(!pack || owner.stat == DEAD)
		qdel(src)
		return
	if(!is_in_gnoll_camp(owner))
		pack.credit_ritual_release(owner)
		qdel(src)
		return
	if(world.time < next_reminder || !owner.client)
		return
	next_reminder = world.time + GNOLL_RELEASE_REMINDER_INTERVAL
	pack.contract_party.notify_members("[owner.real_name] has delivered the pack's birth-seed. Release them from the camp to honor the renewal.")

/datum/status_effect/debuff/defeat/gnoll_captive
	id = "defeat_gnoll_captive_trauma"
	trauma_label = "Captive of the Pack"
	trauma_category_label = "Captivity"
	trauma_desc = "You were hauled to a gnoll shrine and claimed for its rites. The memory of the pack's grip shakes your nerve and your luck. Spiritual care, time, or a potent remedy restores you."
	treatment_class = DEFEAT_TREATMENT_SPIRITUAL
	trauma_category = DEFEAT_TRAUMA_CATEGORY_SPIRITUAL
	accepted_provider_tags = list(DEFEAT_TRAUMA_PROVIDER_SHRINE, DEFEAT_TRAUMA_PROVIDER_MEDICAL, DEFEAT_TRAUMA_PROVIDER_UNIVERSAL)
	treatment_skill = /datum/attribute/skill/magic/holy
	treatment_skill_requirement = SKILL_RANK_NOVICE
	treatment_description = "Restore composure after captivity by a gnoll pack."

/datum/status_effect/debuff/defeat/gnoll_captive/defeat_base_profile()
	return list(STAT_PERCEPTION = -1, STAT_FORTUNE = -2, STAT_ENDURANCE = -1)

/datum/status_effect/debuff/defeat/gnoll_captive/defeat_apply_feedback()
	to_chat(owner, span_warning("I catch a whiff of hyena musk that isn't there, and my nerve falters."))

/datum/stress_event/gnoll_captured
	desc = span_red("A gnoll pack hauled me to their shrine and claimed me for their rites.")
	timer = 30 MINUTES
	stress_change = 3


