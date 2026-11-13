SUBSYSTEM_DEF(questboard)
	name = "Quest Board"
	wait = 30 SECONDS
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	/// Unclaimed quests keyed by the RMH six-tier scale.
	var/list/quest_pool = list()
	var/list/pool_max = list(
		QUESTBOARD_POOL_MAX_ROUTINE,
		QUESTBOARD_POOL_MAX_RISKY,
		QUESTBOARD_POOL_MAX_DANGEROUS,
		QUESTBOARD_POOL_MAX_DEADLY,
		QUESTBOARD_POOL_MAX_LETHAL,
		QUESTBOARD_POOL_MAX_MYTHIC,
	)
	var/list/generation_queue = list()
	var/next_refresh = 0
	/// Tier -> world.time before which a claimed Lethal or Mythic slot stays empty.
	var/list/tier_refill_after = list()

/datum/controller/subsystem/questboard/Initialize(start_timeofday)
	reset_pool()
	return ..()

/datum/controller/subsystem/questboard/fire(resumed)
	if(!resumed)
		prune_stale_quests()
		if(world.time < next_refresh)
			return
		build_generation_queue()
		next_refresh = world.time + 5 MINUTES

	while(length(generation_queue))
		var/tier = generation_queue[1]
		generation_queue.Cut(1, 2)
		var/datum/quest/generated_quest = try_generate_quest(tier)
		if(generated_quest)
			add_quest(generated_quest)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/questboard/proc/reset_pool()
	quest_pool = list(list(), list(), list(), list(), list(), list())
	generation_queue = list()
	next_refresh = 0
	tier_refill_after = list()

/// Starts the refill wait when a generated Lethal or Mythic posting is claimed.
/datum/controller/subsystem/questboard/proc/on_posting_claimed(datum/quest/posted_quest)
	if(!posted_quest || posted_quest.player_commission)
		return
	var/tier = posted_quest.requested_tier
	if(tier >= QUEST_TIER_LETHAL)
		tier_refill_after["[tier]"] = world.time + QUESTBOARD_HIGH_TIER_REFILL_COOLDOWN

/datum/controller/subsystem/questboard/proc/build_generation_queue()
	generation_queue = list()
	for(var/tier in QUEST_TIER_ROUTINE to QUEST_TIER_MYTHIC)
		if(world.time < tier_refill_after["[tier]"])
			continue
		var/generated_count = 0
		for(var/datum/quest/posted_quest as anything in quest_pool[tier])
			if(!posted_quest.player_commission)
				generated_count++
		var/needed = pool_max[tier] - generated_count
		if(needed <= 0)
			continue
		for(var/index in 1 to needed)
			generation_queue += tier

/datum/controller/subsystem/questboard/proc/get_generation_ledger()
	for(var/obj/structure/fake_machine/contractledger/ledger as anything in GLOB.contract_ledgers)
		if(ledger.type != /obj/structure/fake_machine/contractledger)
			continue
		if(ledger.get_contract_ledger_id() == "guild_contracts")
			return ledger
	return null

/datum/controller/subsystem/questboard/proc/try_generate_quest(tier)
	var/obj/structure/fake_machine/contractledger/generation_ledger = get_generation_ledger()
	if(!generation_ledger)
		return null

	var/list/valid_types = list()
	var/carnal_board_full = count_carnal_postings() >= QUEST_CARNAL_BOARD_MAX
	for(var/contract_type in GLOB.global_quest_registry)
		var/datum/quest/quest_path = GLOB.global_quest_registry[contract_type]
		if(tier < initial(quest_path.minimum_tier) || tier > initial(quest_path.maximum_tier))
			continue
		if(carnal_board_full && quest_contract_uses_taker_pool(contract_type))
			continue
		var/datum/quest/template = new quest_path()
		if(template.can_generate_for_world())
			valid_types += contract_type
		qdel(template)
	if(!length(valid_types))
		return null

	valid_types = shuffle(valid_types)
	for(var/contract_type in valid_types)
		var/datum/quest/generated_quest = generation_ledger.create_quest_for_type(contract_type)
		if(!generated_quest)
			continue
		generated_quest.requested_tier = tier

		var/obj/effect/landmark/quest_spawner/landmark = generation_ledger.find_quest_landmark(tier, contract_type)
		if(!landmark || !generated_quest.generate(landmark))
			qdel(generated_quest)
			continue

		generated_quest.calculate_distance_bonus(get_turf(generation_ledger), get_turf(landmark))
		generated_quest.try_setup_quest_ambush(landmark)
		generated_quest.reward_amount = generated_quest.calculate_reward(get_turf(landmark))
		generated_quest.deposit_amount = generated_quest.calculate_deposit(generated_quest.reward_amount)
		generated_quest.on_issued_from_ledger(generation_ledger, null)
		generated_quest.expiry_time = world.time + get_expiry_duration(tier)
		return generated_quest
	return null

/datum/controller/subsystem/questboard/proc/count_carnal_postings()
	. = 0
	for(var/datum/quest/posted_quest as anything in get_all_posted_quests())
		if(posted_quest.contract_group == QUEST_GROUP_CARNAL)
			.++

/datum/controller/subsystem/questboard/proc/get_expiry_duration(tier)
	switch(tier)
		if(QUEST_TIER_ROUTINE)
			return rand(20 MINUTES, 40 MINUTES)
		if(QUEST_TIER_RISKY)
			return rand(25 MINUTES, 45 MINUTES)
		if(QUEST_TIER_DANGEROUS)
			return rand(30 MINUTES, 50 MINUTES)
		if(QUEST_TIER_DEADLY)
			return rand(40 MINUTES, 60 MINUTES)
		if(QUEST_TIER_LETHAL)
			return rand(50 MINUTES, 75 MINUTES)
		if(QUEST_TIER_MYTHIC)
			return rand(60 MINUTES, 90 MINUTES)
	return 30 MINUTES

/datum/controller/subsystem/questboard/proc/add_quest(datum/quest/posted_quest)
	if(!posted_quest || QDELETED(posted_quest))
		return FALSE
	var/tier = clamp(posted_quest.requested_tier, QUEST_TIER_ROUTINE, QUEST_TIER_MYTHIC)
	posted_quest.requested_tier = tier
	if(!(posted_quest in quest_pool[tier]))
		quest_pool[tier] += posted_quest
	return TRUE

/datum/controller/subsystem/questboard/proc/remove_quest(datum/quest/posted_quest)
	if(!posted_quest)
		return FALSE
	for(var/tier in QUEST_TIER_ROUTINE to QUEST_TIER_MYTHIC)
		if(posted_quest in quest_pool[tier])
			quest_pool[tier] -= posted_quest
			return TRUE
	return FALSE

/datum/controller/subsystem/questboard/proc/is_posted(datum/quest/posted_quest)
	if(!posted_quest)
		return FALSE
	for(var/tier in QUEST_TIER_ROUTINE to QUEST_TIER_MYTHIC)
		if(posted_quest in quest_pool[tier])
			return TRUE
	return FALSE

/datum/controller/subsystem/questboard/proc/find_posted_quest(quest_ref)
	if(!quest_ref)
		return null
	for(var/tier in QUEST_TIER_ROUTINE to QUEST_TIER_MYTHIC)
		for(var/datum/quest/posted_quest as anything in quest_pool[tier])
			if(REF(posted_quest) == quest_ref)
				return posted_quest
	return null

/datum/controller/subsystem/questboard/proc/get_all_posted_quests()
	var/list/all_quests = list()
	for(var/tier in QUEST_TIER_ROUTINE to QUEST_TIER_MYTHIC)
		all_quests += quest_pool[tier]
	return all_quests

/datum/controller/subsystem/questboard/proc/prune_stale_quests()
	for(var/tier in QUEST_TIER_ROUTINE to QUEST_TIER_MYTHIC)
		var/list/tier_pool = quest_pool[tier]
		for(var/datum/quest/posted_quest as anything in tier_pool.Copy())
			if(QDELETED(posted_quest))
				tier_pool -= posted_quest
				continue
			if(posted_quest.player_commission)
				continue
			if(posted_quest.expiry_time && world.time >= posted_quest.expiry_time)
				tier_pool -= posted_quest
				log_game("Quest posting expired: [posted_quest.title] ([posted_quest.get_tier_label()])")
				qdel(posted_quest)
