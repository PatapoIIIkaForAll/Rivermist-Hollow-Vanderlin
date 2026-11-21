
///Whether a mob is a werewolf. Returns the werewolf antag datum if found.
#define IS_WEREWOLF(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/werewolf))

// Rage thresholds for /datum/rage/werewolf; its rage_thresholds keys are these numbers as text.
#define WW_RAGE_LOW 25
#define WW_RAGE_MEDIUM 50
#define WW_RAGE_HIGH 75
#define WW_RAGE_CRITICAL 100

// Transformation rules
/// Skipped nights counted toward restless stress; only the full moon forces the change.
#define WW_RESTLESS_NIGHT_CAP 3
#define WW_TRANSFORMATION_COOLDOWN 5 MINUTES
#define WW_TRANSFORMATION_AGONY_INTERVAL (1.5 SECONDS)
// Stun cover for the transformation animation - derived from the agony sleeps so it can't outlive a failed transform by much.
#define WW_TRANSFORMATION_LOCKDOWN (WW_TRANSFORMATION_AGONY_INTERVAL * 2 + 0.5 SECONDS)
#define WW_PENDING_TRANSFORM_REMINDER 30 SECONDS
/// The beast always arrives with at least this much rage: one lunge plus a margin.
#define WW_TRANSFORM_RAGE_FLOOR 40
#define WW_RESTLESS_STRESS_LIGHT 2
#define WW_RESTLESS_STRESS_MEDIUM 4
#define WW_RESTLESS_STRESS_HEAVY 6
#define WW_LAIR_CREATION_TIME 8 SECONDS
/// Beast lunge pounce: knockdown length and the pin window when prey cannot resist the grab.
#define WW_POUNCE_KNOCKDOWN (3 SECONDS)
#define WW_POUNCE_PIN_WINDOW (1 SECONDS)
/// resist_grab refuses resists for this long after the grabber's MT_RESIST_GRAB stamp.
#define WW_GRAB_RESIST_SPACING (2 SECONDS)
/// Lair nest: rage gained resting in it, and how often that bonus comes.
#define WW_NEST_RAGE_BONUS 10
#define WW_NEST_REST_COOLDOWN (10 MINUTES)

// Beast form
#define WEREWOLF_LOOK_LEAN "lean"
#define WEREWOLF_LOOK_FERAL "feral"
#define WEREWOLF_LOOK_CLASSIC "classic"

// Slice 2 (beast profile) defines go below this line.
/// Eye glow when the profile picks none; lean and classic sheets glow amber, feral glows green.
#define WW_EYE_GLOW_DEFAULT "#FFCC33"
#define WW_EYE_GLOW_FERAL "#B9FF4A"
/// Delay before the beast profile menu opens after gaining the curse.
#define WW_CUSTOMIZATION_OPEN_DELAY (3 SECONDS)
/// Profile penis size choices, as a percentage of the beast's base length.
#define WW_PENIS_SCALE_BASE 100
#define WW_PENIS_SCALE_LARGER 125
#define WW_PENIS_SCALE_HUGE 150
/// Refusal shown when a locked beast profile is edited after the first transformation.
#define WW_BEAST_PROFILE_LOCKED_TEXT "The beast has taken its shape; it will not change again this life."

// Slice 3 (rage tiers, rut) defines go below this line.
/// Restless (rage 25): speed stat gained and the share of the keen nose cooldown kept.
#define WW_RESTLESS_SPEED_BONUS 1
#define WW_RESTLESS_NOSE_COOLDOWN_MULT 0.5
/// Hungry (rage 50): feeding heals this many times more.
#define WW_HUNGRY_FEED_MULT 2
/// Rut (rage 75): seed production, orgasm progress and knot force boosts.
#define WW_RUT_SEED_MULT 3
#define WW_RUT_ORGASM_SPEED_MULT 2
#define WW_RUT_KNOT_FORCE_BONUS 1
/// Rut tick length, arousal each scene partner gains per tick, and ticks between pheromone pulses.
#define WW_RUT_TICK_INTERVAL (2 SECONDS)
#define WW_RUT_PARTNER_AROUSAL 3
#define WW_RUT_PULSE_TICKS 5
/// Frenzy (rage 100): length, the rage it falls back to, and the exhaustion stun after.
#define WW_FRENZY_DURATION (60 SECONDS)
#define WW_FRENZY_AFTER_RAGE 50
#define WW_FRENZY_EXHAUSTION_STUN (3 SECONDS)
/// Rage a beast spends climaxing inside a partner.
#define WW_CLIMAX_RAGE_COST 25
/// Rage per sex-action tick the beast takes part in; human skin gets a share of it.
#define WW_SEX_RAGE_PER_TICK 1
#define WW_SEX_RAGE_HUMAN_MULT 0.25
/// Sex rage multipliers by force, gentle to roughest.
#define WW_SEX_RAGE_FORCE_LOW_MULT 0.5
#define WW_SEX_RAGE_FORCE_MID_MULT 1
#define WW_SEX_RAGE_FORCE_HIGH_MULT 2
#define WW_SEX_RAGE_FORCE_EXTREME_MULT 3
#define WW_TAKE_COOLDOWN (10 SECONDS)
/// Scent of the Pack mark left on a bred partner.
#define WW_SCENT_MARK_DURATION (2 HOURS)
#define WW_SCENT_TICK_INTERVAL (5 SECONDS)
#define WW_SCENT_KIN_RANGE 1
#define WW_SCENT_KIN_RAGE 5
#define WW_SCENT_KIN_RAGE_COOLDOWN (1 MINUTES)
/// Mark ticks spent in the rain before it washes the scent off.
#define WW_SCENT_RAIN_RINSE_TICKS 3
/// Conversion chance multiplier when the same wolf breeds its marked partner again.
#define WW_SCENT_REBREED_CONVERSION_MULT 2

// Slice 4 (moon calendar, collar, lineage) defines go below this line.
/// Moon phases, keyed by the night of each dae of the week.
#define WW_MOON_WANING "waning"
#define WW_MOON_DARK "dark"
#define WW_MOON_WAXING "waxing"
#define WW_MOON_GIBBOUS "gibbous"
#define WW_MOON_FULL "full"
/// Nights in one moon cycle; the night of the last dae is the full moon.
#define WW_MOON_CYCLE_NIGHTS 7
#define WW_FULL_MOON_RAGE_MULTIPLIER 2
/// How long a moonshackle collar takes to force a beast back into human skin.
#define WW_COLLAR_REVERSION_TIME (30 SECONDS)
/// A pup shifts free of cooldown within this many tiles of its living elder.
#define WW_PUP_ELDER_RANGE 7
/// Living pups the elder must keep for the pack keeper objective.
#define WW_PACK_KEEPER_PUP_TARGET 2
/// Overlay slot for the beast's penis and eyes; no humanoid code fills it.
#define WW_BEAST_OVERLAY_LAYER FRONT_MUTATIONS_LAYER
#define WW_PENIS_HALF_AROUSAL 10
#define WW_PENIS_FULL_AROUSAL 20
/// The beast's penis is never shorter than this, in centimetres.
#define WW_BEAST_MIN_PENIS_LENGTH 28
#define WW_FOOTSTEP_VOLUME 0.5
#define WW_FOOTSTEP_RANGE -8

// Objective tuning
#define WW_BREED_OBJECTIVE_MIN 5
#define WW_BREED_OBJECTIVE_MAX 10
#define WW_HUNT_OBJECTIVE_MIN 4
#define WW_HUNT_OBJECTIVE_MAX 8
#define WW_SLAY_OBJECTIVE_MIN 4
#define WW_SLAY_OBJECTIVE_MAX 8
#define WW_CONVERT_OBJECTIVE_MIN 3
#define WW_CONVERT_OBJECTIVE_MAX 4
#define WW_CONTRACT_OBJECTIVE_TARGET 400
#define WW_CONTRACT_SCORE_BASE 5
#define WW_CONTRACT_SCORE_STEP 10
#define WW_TRAP_OBJECTIVE_TARGET 4
#define WW_TRAP_ORGASM_TRIGGER 10
#define WW_TRAP_TIME_TRIGGER 10 MINUTES
#define WW_TRAP_RESET_COOLDOWN 2 MINUTES

// Voluntary conversion tuning
#define WW_CREAMPIE_CONVERSION_CHANCE 30
#define WW_CREAMPIE_KNOT_MULTIPLIER 2
#define WW_CONVERSION_PROMPT_TIMEOUT 20 SECONDS
#define WW_VOLUNTARY_BITE_COOLDOWN 6 MINUTES
