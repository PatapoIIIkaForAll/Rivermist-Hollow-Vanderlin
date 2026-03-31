
///Whether a mob is a werewolf. Returns the werewolf antag datum if found.
#define IS_WEREWOLF(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/werewolf))

// Rage thresholds for /datum/rage/werewolf
#define WW_RAGE_LOW "25"
#define WW_RAGE_MEDIUM "50"
#define WW_RAGE_HIGH "75"
#define WW_RAGE_CRITICAL "100"

// Transformation rules
#define WW_FORCED_TRANSFORM_NIGHT_COUNT 3
#define WW_TRANSFORMATION_COOLDOWN 5 MINUTES
#define WW_TRANSFORMATION_AGONY_INTERVAL 2.5 SECONDS
#define WW_TRANSFORMATION_LOCKDOWN 5.1 SECONDS
#define WW_PENDING_TRANSFORM_REMINDER 30 SECONDS
#define WW_RESTLESS_STRESS_LIGHT 2
#define WW_RESTLESS_STRESS_MEDIUM 4
#define WW_RESTLESS_STRESS_HEAVY 6
