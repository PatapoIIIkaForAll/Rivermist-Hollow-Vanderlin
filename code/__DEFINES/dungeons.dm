// -- Infinite dungeon system (see docs/superpowers/specs/2026-06-10-infinite-dungeons-design.md) --

// Room kinds for /datum/map_template/pocket/dungeon
#define DUNGEON_ROOM_ONESHOT "oneshot"
#define DUNGEON_ROOM_COMBAT "combat"
#define DUNGEON_ROOM_BREAK "break"

// Theme tags used to filter template pools
#define DUNGEON_THEME_BANDIT "bandit"
#define DUNGEON_THEME_BEAR "bear"
#define DUNGEON_THEME_DROW "drow"
#define DUNGEON_THEME_RATFOLK "ratfolk"
#define DUNGEON_THEME_SPIDER "spider"
#define DUNGEON_THEME_SWAMPGOB "swampgob"
#define DUNGEON_THEME_TENTACLE "tentacle"
#define DUNGEON_THEME_TEST "test"
#define DUNGEON_THEME_WEREWOLF "werewolf"
#define DUNGEON_THEME_WOLF "wolf"

// Gate roles
#define DUNGEON_GATE_FORWARD "forward"
#define DUNGEON_GATE_BACK "back"

// Entrance kinds
#define DUNGEON_ENTRANCE_ONESHOT "oneshot"
#define DUNGEON_ENTRANCE_INFINITE "infinite"

/// Idle timeout for an uncleared dungeon nobody is inside
#define DUNGEON_DEFAULT_IDLE_TIMEOUT (10 MINUTES)
/// How long a cleared, empty dungeon lingers before collapsing
#define DUNGEON_CLEARED_IDLE_TIMEOUT (3 MINUTES)
/// How long an entrance stays dormant after its dungeon collapses
#define DUNGEON_ENTRANCE_COOLDOWN (20 MINUTES)
/// Combat rooms cleared between break rooms in an infinite run
#define DUNGEON_RUN_STRETCH_LENGTH 5
/// A run force-collapses after this long with no client-bearing occupant
#define DUNGEON_RUN_ABANDON_TIMEOUT (30 MINUTES)

// -- Roguelike crawler additions --

// Additional room kinds
#define DUNGEON_ROOM_BOSS "boss"
#define DUNGEON_ROOM_DESCENT "descent"

// Additional gate role
#define DUNGEON_GATE_DESCENT "descent"

// Path types (branching risk/reward)
#define DUNGEON_PATH_COMBAT "combat"
#define DUNGEON_PATH_TREASURE "treasure"
#define DUNGEON_PATH_HAZARD "hazard"
#define DUNGEON_PATH_ELITE "elite"
#define DUNGEON_PATH_SHORTCUT "shortcut"

/// Highest floor the floor-config registry guarantees a hand-authored config for;
/// beyond this, the deepest config is reused with a rising tier.
#define DUNGEON_MAX_DESIGNED_FLOOR 5

// -- Party & raid management --

// Join approval threshold for outsiders petitioning an at-rest party
#define DUNGEON_JOIN_APPROVAL_ANY "any"          // any single present member approves
#define DUNGEON_JOIN_APPROVAL_MAJORITY "majority"// >half of present members
#define DUNGEON_JOIN_APPROVAL_LEADER "leader"    // party leader only
/// Active approval mode
#define DUNGEON_JOIN_APPROVAL_MODE DUNGEON_JOIN_APPROVAL_ANY

/// A muster auto-resolves (leader/threshold force-advance) after this long waiting
#define DUNGEON_MUSTER_TIMEOUT (45 SECONDS)
/// Grace after which a disconnected member stops gating a muster
#define DUNGEON_MUSTER_SSD_GRACE (20 SECONDS)

// -- In-run currency (motes) & meta-currency (echoes) --

/// Base motes a normal guardian drops on death
#define DUNGEON_MOTE_GUARDIAN_BASE 2
/// Extra motes per floor
#define DUNGEON_MOTE_FLOOR_BONUS 1.2
/// Elite guardian mote multiplier
#define DUNGEON_MOTE_ELITE_MULT 2

// -- Encounter difficulty curve --
// Guardians are enhanced from a FLOOR-relative delve, not the run's cumulative
// room count: difficulty resets each floor and climbs with the floor tier,
// instead of compounding without bound across a long run.

/// Delve levels added per floor tier
#define DUNGEON_DELVE_PER_TIER 2
/// Hard ceiling on the delve fed to the affix system
#define DUNGEON_DELVE_MAX 10
/// Fraction of unspent motes that converts to echoes when a run is banked
#define DUNGEON_ECHO_CONVERSION 0.25
/// Shrine price to fully restore the delver's damaged, repairable worn armor
#define DUNGEON_SHRINE_ARMOR_REPAIR_COST 50
/// Shrine price to lift one lingering defeat trauma - dearer than mending
/// wounds, since it buys back what a fall actually cost you
#define DUNGEON_SHRINE_TRAUMA_COST 80
/// Save-manager file name for per-ckey dungeon meta progression
#define DUNGEON_SAVE_FILE "dungeon"

// -- Encounter director: combat styles for spawn-entry tagging --

#define DUNGEON_STYLE_MELEE "melee"
#define DUNGEON_STYLE_RANGED "ranged"
#define DUNGEON_STYLE_CASTER "caster"

/// % chance a trait-eligible room rolls a room trait
#define DUNGEON_ROOM_TRAIT_CHANCE 50

/// Faction shared by every dungeon-native guardian (prevents infighting)
#define FACTION_DUNGEON "dungeon"
/// Channel time to work a dungeon gate open (players only)
#define DUNGEON_GATE_TRAVERSE_TIME (2 SECONDS)
/// Grace after a full party wipe before the dungeon ends the run
#define DUNGEON_WIPE_GRACE (30 SECONDS)

// -- Roguelike Heart: door rewards & stretch deck --

/// What a forward gate promises for clearing the room beyond it
#define DUNGEON_REWARD_BOON "boon"
#define DUNGEON_REWARD_MOTES "motes"
#define DUNGEON_REWARD_LOOT "loot"
#define DUNGEON_REWARD_HEAL "heal"
#define DUNGEON_REWARD_VAULT "vault"

/// Weighted remainder of the stretch deck after guarantees (VAULT is guarantee-only)
#define DUNGEON_DECK_REMAINDER_WEIGHTS list(DUNGEON_REWARD_MOTES = 40, DUNGEON_REWARD_HEAL = 25, DUNGEON_REWARD_LOOT = 20, DUNGEON_REWARD_BOON = 15)

/// How many recent combat templates a run remembers and avoids repeating
#define DUNGEON_RECENT_TEMPLATE_MEMORY 3

// -- Roguelike Heart: boon rarity --

#define DUNGEON_BOON_COMMON "common"
#define DUNGEON_BOON_RARE "rare"
#define DUNGEON_BOON_EPIC "epic"

// -- Roguelike Tail: heat (The Grim Covenant) --

/// Echo cost of the Grim Covenant unlock (enables heat dials)
#define DUNGEON_COVENANT_COST 30
/// Extra echo conversion per total heat rank
#define DUNGEON_HEAT_ECHO_BONUS 0.05
/// Wipe grace with Iron Contract engaged
#define DUNGEON_WIPE_GRACE_IRON (10 SECONDS)

// Heat dial ids
#define DUNGEON_HEAT_HARDENED "hardened_foes"
#define DUNGEON_HEAT_ELITES "elite_presence"
#define DUNGEON_HEAT_CRUEL "cruel_architecture"
#define DUNGEON_HEAT_FORCED_MARCH "forced_march"
#define DUNGEON_HEAT_IRON_CONTRACT "iron_contract"
#define DUNGEON_HEAT_SEALED_MERCY "sealed_mercy"

// -- Roguelike Tail: dark bargains --

/// % chance a floor-2+ break room grows a bargain altar
#define DUNGEON_BARGAIN_ALTAR_CHANCE 30
/// Bargain altars appear from this floor onward
#define DUNGEON_BARGAIN_MIN_FLOOR 2
/// Fraction of max health the Price of Flesh takes from every roster member
#define DUNGEON_BARGAIN_FLESH_CUT 0.15
/// Cursed rooms owed per curse-priced bargain
#define DUNGEON_BARGAIN_CURSE_ROOMS 2
/// Cursed-room clear compensation, in multiples of a base guardian mote drop
#define DUNGEON_CURSED_MOTE_BONUS 2

// -- Roguelike Tail: non-combat rooms --

/// % chance per stretch that one mid-stretch room is special (non-combat)
#define DUNGEON_SPECIAL_ROOM_CHANCE 40
/// Waves a wave-challenge room spawns in total
#define DUNGEON_WAVE_COUNT 3
/// Wave-challenge clear payout: base + per-floor motes
#define DUNGEON_WAVE_PAYOUT_BASE 45
#define DUNGEON_WAVE_PAYOUT_FLOOR 15

// Room population modes (what fills a room besides/instead of a normal fight)
#define DUNGEON_POP_COMBAT "combat"
#define DUNGEON_POP_TRADER "trader"
#define DUNGEON_POP_MYSTERY "mystery"
#define DUNGEON_POP_WAVES "waves"

// -- Floor bosses and party scaling --

/// Guardian health added per party member beyond the first
#define DUNGEON_PARTY_HP_PER_MEMBER 0.4
/// Extra party members that still add guardian health
#define DUNGEON_PARTY_HP_MAX_EXTRA 4
/// Defeat-pool damage a humanoid floor boss soaks on floor 1, before floor and party scaling
#define DUNGEON_BOSS_CARBON_TOUGHNESS 250
/// Lowest weapon, shield and grappling skill a humanoid floor boss fights with
#define DUNGEON_BOSS_MIN_COMBAT_SKILL SKILL_LEVEL_EXPERT
/// Escorts a floor boss brings before counting extra party members
#define DUNGEON_BOSS_ESCORT_BASE 2
/// Most escorts a floor boss can bring
#define DUNGEON_BOSS_ESCORT_MAX 5
/// Floor-1 damage of a promoted boss's slam
#define DUNGEON_BOSS_SLAM_DAMAGE 15
