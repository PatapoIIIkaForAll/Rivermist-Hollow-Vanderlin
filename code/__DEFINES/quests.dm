#define QUEST_GROUP_ERRANDS "Guild Errands"
#define QUEST_GROUP_BOUNTIES "Bounties"
#define QUEST_GROUP_COMMISSIONS "Player Commissions"
#define QUEST_GROUP_CARNAL "Carnal Contracts"

#define QUEST_TIER_ROUTINE 1
#define QUEST_TIER_RISKY 2
#define QUEST_TIER_DANGEROUS 3
#define QUEST_TIER_DEADLY 4
#define QUEST_TIER_LETHAL 5
#define QUEST_TIER_MYTHIC 6

#define QUEST_RETRIEVAL "Retrieval"
#define QUEST_COURIER "Courier"
#define QUEST_HUNT "Hunt"
#define QUEST_CLEAR_OUT "Clear Out"
#define QUEST_RAID "Raid"
#define QUEST_BOSS "Boss"
#define QUEST_CUSTOM "Commission"
#define QUEST_FLUID_HARVEST "Fluid Harvest"
#define QUEST_EGG_HARVEST "Clutch Recovery"
#define QUEST_SATE_MARK "Sate and Mark"

/// Trait source for gear locked onto quest-spawned mobs.
#define QUEST_SPAWN_LOCK_TRAIT "quest_spawn_lock"
/// Idle quest mobs walk back when they stray further than this from their landmark.
#define QUEST_IDLE_LEASH_RANGE 8

#define CUSTOM_QUEST_PLEDGE (1<<0)

#define QUEST_PLEDGE_BLANK "blank"
#define QUEST_PLEDGE_FILLED "filled"
#define QUEST_PLEDGE_SEALED "sealed"
#define QUEST_PLEDGE_POSTED "posted"

// Shared board population. Player commissions do not count against these limits.
#define QUESTBOARD_POOL_MAX_ROUTINE 3
#define QUESTBOARD_POOL_MAX_RISKY 3
#define QUESTBOARD_POOL_MAX_DANGEROUS 2
#define QUESTBOARD_POOL_MAX_DEADLY 2
#define QUESTBOARD_POOL_MAX_LETHAL 1
#define QUESTBOARD_POOL_MAX_MYTHIC 1
/// Wait after a Lethal or Mythic posting is claimed before the board posts another of that tier.
#define QUESTBOARD_HIGH_TIER_REFILL_COOLDOWN (30 MINUTES)

// Regional threat removed when a quest tied to that region is completed.
#define QUEST_THREAT_REDUCE_ROUTINE 2
#define QUEST_THREAT_REDUCE_RISKY 4
#define QUEST_THREAT_REDUCE_DANGEROUS 6
#define QUEST_THREAT_REDUCE_DEADLY 8
#define QUEST_THREAT_REDUCE_LETHAL 12
#define QUEST_THREAT_REDUCE_MYTHIC 18

#define QUEST_HANDLER_REWARD_MULTIPLIER 2
#define QUEST_MINOR_HANDLER_REWARD_MULTIPLIER 1.2
#define QUEST_REWARD_PER_RISK_POINT 6
#define QUEST_ERRAND_REWARD_PER_RISK_POINT 2
#define QUEST_ERRAND_WORKLOAD_REWARD_MULT 0.2
#define QUEST_DEPOSIT_RATE 0.18
#define QUEST_MIN_DEPOSIT 4
#define QUEST_MAX_DEPOSIT 80

#define QUEST_BASE_REWARD_RETRIEVAL 8
#define QUEST_BASE_REWARD_COURIER 8

#define QUEST_CLEAR_OUT_RISK_BONUS 1
#define QUEST_RAID_RISK_BONUS 3
#define QUEST_BOSS_RISK_BONUS 5

#define QUEST_MOB_SPAWN_WEIGHT "spawn_weight"
#define QUEST_MOB_RISK_VALUE "risk_value"
#define QUEST_MOB_GROUP_MIN "group_min"
#define QUEST_MOB_GROUP_MAX "group_max"
#define QUEST_MOB_DATA(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX) list(QUEST_MOB_SPAWN_WEIGHT = SPAWN_WEIGHT, QUEST_MOB_RISK_VALUE = RISK_VALUE, QUEST_MOB_GROUP_MIN = GROUP_MIN, QUEST_MOB_GROUP_MAX = GROUP_MAX)
#define QUEST_MOB_SOLO(SPAWN_WEIGHT, RISK_VALUE) QUEST_MOB_DATA(SPAWN_WEIGHT, RISK_VALUE, 1, 1)
#define QUEST_MOB_PACK(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX) QUEST_MOB_DATA(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX)

// Delivery quest additional reward scaling
#define QUEST_DELIVERY_DISTANCE_DIVISOR 6 // Divides the distance for reward calculation
#define QUEST_DELIVERY_DISTANCE_BONUS 1 // Adds a bonus for longer distances
#define QUEST_COURIER_BONUS_FLAT 8 // Flat bonus for courier quests, since you gotta wait for a person to open a package
#define QUEST_DELIVERY_PER_ITEM_BONUS 5 // Bonus per item delivered
#define QUEST_HUNT_REWARD_MULTIPLIER 1
#define QUEST_CLEAR_OUT_REWARD_MULTIPLIER 1
#define QUEST_RAID_REWARD_MULTIPLIER 1.25
#define QUEST_BOSS_REWARD_RISK_SQUARE_MULTIPLIER 2
#define QUEST_BOSS_REWARD_RISK_OVERFLOW_START 8
#define QUEST_BOSS_REWARD_RISK_OVERFLOW_BONUS 15
#define QUEST_BOSS_REWARD_MAX 1500
/// Share of the distance bonus a boss contract receives.
#define QUEST_BOSS_DISTANCE_BONUS_SCALE 0.5

// ===== Map difficulty and reward modifiers =====
// Map flag bitfields for mob availability per map
#define QUEST_MAP_FLAG_TOWN (1<<0)
#define QUEST_MAP_FLAG_BOG (1<<1)
#define QUEST_MAP_FLAG_DESERT (1<<2)
#define QUEST_MAP_FLAG_FROZEN (1<<3)
#define QUEST_MAP_FLAG_UNDERDARK (1<<4)
#define QUEST_MAP_FLAG_ALL (QUEST_MAP_FLAG_TOWN | QUEST_MAP_FLAG_BOG | QUEST_MAP_FLAG_DESERT | QUEST_MAP_FLAG_FROZEN | QUEST_MAP_FLAG_UNDERDARK)

// Per-map difficulty multipliers (drives ambush frequency and mob scaling).
// 1.0x = baseline (~8% ambush), 2.0x = ~15% ambush, 3.0x = ~20% ambush.
#define QUEST_MAP_DIFFICULTY_TOWN 0.9
#define QUEST_MAP_DIFFICULTY_TOWN_SNOW 1.0
#define QUEST_MAP_DIFFICULTY_BOG 1.5
#define QUEST_MAP_DIFFICULTY_DESERT 1.3
#define QUEST_MAP_DIFFICULTY_FROZEN 2.0
#define QUEST_MAP_DIFFICULTY_UNDERDARK 3.0

// Per-map reward multipliers (globally scales all quest reward on that map).
#define QUEST_MAP_REWARD_TOWN 0.9
#define QUEST_MAP_REWARD_TOWN_SNOW 1.0
#define QUEST_MAP_REWARD_BOG 1.4
#define QUEST_MAP_REWARD_DESERT 1.3
// Frozen landmarks sit far from the ledger, so a base below the bog keeps payouts within 1.25x of it.
#define QUEST_MAP_REWARD_FROZEN 1.15
#define QUEST_MAP_REWARD_UNDERDARK 2.5
#define QUEST_MAP_REWARD_SCALE 2

// Distance bonus config: base bonus is up to 25% extra reward based on distance from ledger to spawn point.
// Final bonus scales this base value by QUEST_DISTANCE_BONUS_SCALE and doubles it again across z-levels.
#define QUEST_DISTANCE_BONUS_MAX_MULT 0.25
#define QUEST_DISTANCE_BONUS_MAX_RANGE 150
#define QUEST_DISTANCE_BONUS_SCALE 4
#define QUEST_DISTANCE_BONUS_CROSS_Z_SCALE 2

// Quest ambush chance config.
// Ambush chance (%) = clamp(QUEST_AMBUSH_BASE_CHANCE * difficulty_modifier, MIN, MAX).
// At 1.0x difficulty -> 8%, at 2.0x -> 15%, at 3.0x -> 20%.
#define QUEST_AMBUSH_BASE_CHANCE 8
#define QUEST_AMBUSH_MIN_CHANCE 3
#define QUEST_AMBUSH_MAX_CHANCE 25

// ===== Mob map_flags field key =====
#define QUEST_MOB_MAP_FLAGS "map_flags"

// Extended mob data macro with map_flags support
#define QUEST_MOB_DATA_EX(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX, MAP_FLAGS) list(QUEST_MOB_SPAWN_WEIGHT = SPAWN_WEIGHT, QUEST_MOB_RISK_VALUE = RISK_VALUE, QUEST_MOB_GROUP_MIN = GROUP_MIN, QUEST_MOB_GROUP_MAX = GROUP_MAX, QUEST_MOB_MAP_FLAGS = MAP_FLAGS)
#define QUEST_MOB_SOLO_EX(SPAWN_WEIGHT, RISK_VALUE, MAP_FLAGS) QUEST_MOB_DATA_EX(SPAWN_WEIGHT, RISK_VALUE, 1, 1, MAP_FLAGS)
#define QUEST_MOB_PACK_EX(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX, MAP_FLAGS) QUEST_MOB_DATA_EX(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX, MAP_FLAGS)


// ==>>> NEW LIST

#define QUEST_KILL_MOBS_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/smallrat = QUEST_MOB_PACK(10, 1, 2, 5),\
	/mob/living/simple_animal/hostile/retaliate/bat = QUEST_MOB_PACK(8, 2, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/bigrat = QUEST_MOB_PACK(8, 2, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/fox = QUEST_MOB_SOLO(6, 2),\
	/mob/living/simple_animal/hostile/retaliate/raccoon = QUEST_MOB_PACK(5, 3, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/snapper = QUEST_MOB_SOLO(6, 3),\
	/mob/living/simple_animal/hostile/retaliate/shade = QUEST_MOB_SOLO(4, 4),\
	/mob/living/simple_animal/hostile/retaliate/poltergeist = QUEST_MOB_SOLO(4, 4),\
	/mob/living/simple_animal/hostile/dragger = QUEST_MOB_SOLO(4, 4),\
	/mob/living/simple_animal/hostile/retaliate/wolf = QUEST_MOB_PACK(6, 4, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/wolf/dire = QUEST_MOB_SOLO_EX(2, 6, QUEST_MAP_FLAG_TOWN | QUEST_MAP_FLAG_BOG | QUEST_MAP_FLAG_FROZEN),\
	/mob/living/simple_animal/hostile/retaliate/bobcat = QUEST_MOB_SOLO(5, 4),\
	/mob/living/simple_animal/hostile/retaliate/spider = QUEST_MOB_PACK(6, 4, 2, 5),\
	/mob/living/simple_animal/hostile/skeleton = QUEST_MOB_PACK(5, 5, 2, 4),\
	/mob/living/simple_animal/hostile/skeleton/spear = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/simple_animal/hostile/skeleton/bow = QUEST_MOB_PACK(3, 5, 2, 3),\
	/mob/living/simple_animal/hostile/skeleton/axe = QUEST_MOB_PACK(3, 6, 1, 2),\
	/mob/living/carbon/human/species/goblin/npc = QUEST_MOB_PACK(5, 5, 2, 4),\
	/mob/living/carbon/human/species/goblin/npc/cave = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/goblin/npc/sea = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/zizombie/npc/peasant = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/human/northern/thief = QUEST_MOB_PACK(4, 5, 1, 2),\
	/mob/living/carbon/human/species/human/northern/highwayman = QUEST_MOB_PACK(3, 6, 1, 2),\
)
#define QUEST_KILL_MEDIUM_LIST list(\
	/mob/living/carbon/human/species/goblin/npc/cave = QUEST_MOB_PACK(6, 5, 3, 6),\
	/mob/living/carbon/human/species/goblin/npc/sea = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/zizombie/npc/peasant = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/zizombie/npc/warrior = QUEST_MOB_PACK(3, 7, 3, 5),\
	/mob/living/carbon/human/species/skeleton/npc/easy = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/skeleton/npc/pirate = QUEST_MOB_PACK(4, 5, 3, 5),\
	/mob/living/carbon/human/species/skeleton/npc/medium = QUEST_MOB_PACK(3, 7, 3, 5),\
	/mob/living/simple_animal/hostile/orc/orc2 = QUEST_MOB_PACK(5, 6, 3, 5),\
	/mob/living/simple_animal/hostile/orc/spear = QUEST_MOB_PACK(5, 6, 3, 5),\
	/mob/living/simple_animal/hostile/orc/spear2 = QUEST_MOB_PACK(4, 6, 3, 5),\
	/mob/living/simple_animal/hostile/orc/ranged = QUEST_MOB_PACK(4, 6, 3, 4),\
	/mob/living/simple_animal/hostile/orc/orc_marauder = QUEST_MOB_PACK(3, 8, 3, 4),\
	/mob/living/simple_animal/hostile/orc/orc_marauder/spear = QUEST_MOB_PACK(3, 8, 3, 4),\
	/mob/living/simple_animal/hostile/deepone = QUEST_MOB_PACK(4, 6, 3, 5),\
	/mob/living/simple_animal/hostile/deepone/arm = QUEST_MOB_PACK(3, 7, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/spit = QUEST_MOB_PACK(3, 7, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/wiz = QUEST_MOB_PACK(2, 8, 2, 3),\
	/mob/living/simple_animal/hostile/retaliate/gator = QUEST_MOB_PACK(3, 7, 2, 3),\
	/mob/living/simple_animal/hostile/retaliate/bogbug = QUEST_MOB_PACK(5, 6, 3, 6),\
	/mob/living/simple_animal/hostile/retaliate/spider/mutated = QUEST_MOB_PACK(4, 6, 3, 6),\
	/mob/living/carbon/human/species/human/northern/thief = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/human/northern/highwayman = QUEST_MOB_PACK(3, 6, 2, 4),\
)
#define QUEST_RAID_LIST list(\
	/mob/living/carbon/human/species/skeleton/npc/medium = QUEST_MOB_PACK(4, 7, 3, 5),\
	/mob/living/carbon/human/species/skeleton/npc/hard = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/carbon/human/species/zizombie/npc/warrior = QUEST_MOB_PACK(4, 8, 3, 5),\
	/mob/living/carbon/human/species/zizombie/npc/militiamen = QUEST_MOB_PACK(3, 8, 3, 5),\
	/mob/living/simple_animal/hostile/orc/orc_marauder = QUEST_MOB_PACK(4, 8, 3, 5),\
	/mob/living/simple_animal/hostile/orc/orc_marauder/spear = QUEST_MOB_PACK(3, 8, 3, 5),\
	/mob/living/carbon/human/species/orc/warrior = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/carbon/human/species/orc/marauder = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/arm = QUEST_MOB_PACK(4, 7, 3, 5),\
	/mob/living/simple_animal/hostile/deepone/spit = QUEST_MOB_PACK(4, 7, 3, 5),\
	/mob/living/simple_animal/hostile/deepone/wiz = QUEST_MOB_PACK(3, 8, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/elite = QUEST_MOB_PACK(2, 9, 2, 3),\
	/mob/living/carbon/human/species/human/northern/base/very_skilled/medium_gear = QUEST_MOB_PACK(3, 8, 2, 4),\
	/mob/living/carbon/human/species/human/northern/base/skilled/heavy_gear = QUEST_MOB_PACK(3, 8, 2, 4),\
	/mob/living/carbon/human/species/human/northern/base/very_skilled/heavy_gear = QUEST_MOB_PACK(2, 9, 2, 3),\
	/mob/living/carbon/human/species/human/northern/searaider = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/carbon/human/species/human/northern/bog_deserters = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/troll/bog = QUEST_MOB_SOLO(3, 8),\
)
#define QUEST_BOSS_KILL_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/troll/cave = QUEST_MOB_SOLO(4, 8),\
	/mob/living/simple_animal/hostile/retaliate/troll/axe = QUEST_MOB_SOLO(3, 8),\
	/mob/living/simple_animal/hostile/retaliate/troll/broodmother = QUEST_MOB_SOLO(2, 8),\
	/mob/living/simple_animal/hostile/retaliate/elemental/behemoth = QUEST_MOB_SOLO(3, 8),\
	/mob/living/simple_animal/hostile/retaliate/elemental/collossus = QUEST_MOB_SOLO(2, 8),\
	/mob/living/simple_animal/hostile/retaliate/voiddragon = QUEST_MOB_SOLO(3, 13),\
	/mob/living/simple_animal/hostile/retaliate/voiddragon/red = QUEST_MOB_SOLO(2, 14),\
	/mob/living/simple_animal/hostile/boss/fishboss = QUEST_MOB_SOLO(2, 15),\
	/mob/living/simple_animal/hostile/retaliate/voiddragon/red/tsere = QUEST_MOB_SOLO(1, 17),\
	/mob/living/simple_animal/hostile/retaliate/minotaur = QUEST_MOB_SOLO(3, 10),\
	/mob/living/simple_animal/hostile/retaliate/minotaur/axe = QUEST_MOB_SOLO(2, 12),\
)

// ===== Carnal contracts =====
/// Carnal contracts the shared board may hold at once.
#define QUEST_CARNAL_BOARD_MAX 2
#define QUEST_FLUID_REWARD_MULTIPLIER 1.2
#define QUEST_FLUID_REWARD_PER_UNIT 0.5
#define QUEST_EGG_REWARD_MULTIPLIER 1.2
#define QUEST_EGG_REWARD_PER_EGG 4
#define QUEST_SATE_REWARD_MULTIPLIER 1.4
/// Spare ribbons issued on top of one per Sate and Mark target.
#define QUEST_SATE_SPARE_RIBBONS 1

#define QUEST_FLUID_SEED "seed"
#define QUEST_FLUID_NECTAR "nectar"

// Every creature here must run the horny AI subtree; the carnal_contract_pools unit test checks it.
#define QUEST_CARNAL_SATE_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/bigrat = QUEST_MOB_PACK(8, 2, 1, 3),\
	/mob/living/simple_animal/hostile/retaliate/wolf = QUEST_MOB_PACK(6, 4, 1, 3),\
	/mob/living/simple_animal/hostile/retaliate/bobcat = QUEST_MOB_SOLO(5, 4),\
	/mob/living/simple_animal/hostile/retaliate/spider = QUEST_MOB_PACK(6, 4, 1, 3),\
	/mob/living/carbon/human/species/goblin/npc = QUEST_MOB_PACK(5, 5, 1, 3),\
	/mob/living/simple_animal/hostile/retaliate/tentacle = QUEST_MOB_PACK(4, 5, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/spider/mutated = QUEST_MOB_PACK(4, 6, 1, 3),\
	/mob/living/simple_animal/hostile/retaliate/bogbug = QUEST_MOB_PACK(5, 6, 1, 3),\
	/mob/living/carbon/human/species/zizombie/npc/peasant = QUEST_MOB_PACK(4, 6, 1, 3),\
	/mob/living/simple_animal/hostile/retaliate/gator = QUEST_MOB_PACK(3, 7, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/troll/bog = QUEST_MOB_SOLO(3, 8),\
	/mob/living/simple_animal/hostile/retaliate/minotaur = QUEST_MOB_SOLO(2, 10),\
)
// Egg layers only: each one carries a typed ovipositor.
#define QUEST_CARNAL_EGG_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/spider = QUEST_MOB_PACK(6, 4, 2, 3),\
	/mob/living/simple_animal/hostile/retaliate/tentacle = QUEST_MOB_PACK(4, 5, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/spider/mutated = QUEST_MOB_PACK(4, 6, 2, 3),\
	/mob/living/simple_animal/hostile/retaliate/bogbug = QUEST_MOB_PACK(5, 6, 2, 3),\
)
// Simple creatures with their own seed and nectar types (creature_fluids.dm).
#define QUEST_CARNAL_FLUID_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/bigrat = QUEST_MOB_PACK(8, 2, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/wolf = QUEST_MOB_PACK(6, 4, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/bobcat = QUEST_MOB_SOLO(5, 4),\
	/mob/living/simple_animal/hostile/retaliate/spider = QUEST_MOB_PACK(6, 4, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/bogbug = QUEST_MOB_PACK(5, 6, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/gator = QUEST_MOB_PACK(3, 7, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/troll/bog = QUEST_MOB_SOLO(3, 8),\
	/mob/living/simple_animal/hostile/retaliate/minotaur = QUEST_MOB_SOLO(2, 10),\
)
