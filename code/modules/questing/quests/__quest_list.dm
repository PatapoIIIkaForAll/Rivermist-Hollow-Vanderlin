GLOBAL_LIST_INIT(global_quest_contract_groups, list(
	QUEST_GROUP_ERRANDS = list(QUEST_RETRIEVAL, QUEST_COURIER),
	QUEST_GROUP_BOUNTIES = list(QUEST_HUNT, QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOSS),
	QUEST_GROUP_CARNAL = list(QUEST_FLUID_HARVEST, QUEST_EGG_HARVEST, QUEST_SATE_MARK),
))

GLOBAL_LIST_INIT(global_quest_registry, list(
	QUEST_RETRIEVAL = /datum/quest/retrieval,
	QUEST_COURIER = /datum/quest/courier,
	QUEST_HUNT = /datum/quest/kill/hunt,
	QUEST_CLEAR_OUT = /datum/quest/kill/clearout,
	QUEST_RAID = /datum/quest/kill/raid,
	QUEST_BOSS = /datum/quest/kill/boss,
	QUEST_FLUID_HARVEST = /datum/quest/kill/carnal/fluid,
	QUEST_EGG_HARVEST = /datum/quest/kill/carnal/eggs,
	QUEST_SATE_MARK = /datum/quest/kill/carnal/sate,
))

/// TRUE when the contract type spawns creatures to track, which gives it target previews.
/proc/quest_contract_targets_creatures(contract_type)
	return ispath(GLOB.global_quest_registry[contract_type], /datum/quest/kill)

/// TRUE when the contract type builds its creature pool from the taker's preferences.
/proc/quest_contract_uses_taker_pool(contract_type)
	return ispath(GLOB.global_quest_registry[contract_type], /datum/quest/kill/carnal)
