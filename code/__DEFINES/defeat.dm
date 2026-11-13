#define DEFEAT_MODE_KO_RUNE "ko_rune"
#define DEFEAT_MODE_KO_ONLY "ko_only"
#define DEFEAT_MODE_NO_RETURN "no_return"
#define DEFEAT_MODE_DEFAULT DEFEAT_MODE_KO_RUNE

#define DEFEAT_REASON_DAMAGE "damage"
#define DEFEAT_REASON_PAIN "pain"
#define DEFEAT_REASON_DEATH "death"
#define DEFEAT_REASON_HAZARD "hazard"
#define DEFEAT_REASON_HORNY "horny"

#define DEFEAT_SEVERITY_LIGHT "light"
#define DEFEAT_SEVERITY_NORMAL "normal"
#define DEFEAT_SEVERITY_SEVERE "severe"

#define DEFEAT_TREATMENT_MEDICAL "medical"
#define DEFEAT_TREATMENT_SPIRITUAL "spiritual"
#define DEFEAT_TREATMENT_UNIVERSAL "universal"

#define DEFEAT_TRAUMA_CATEGORY_PHYSICAL "physical"
#define DEFEAT_TRAUMA_CATEGORY_SPIRITUAL "spiritual"

#define DEFEAT_TRAUMA_PROVIDER_MEDICAL "medical_provider"
#define DEFEAT_TRAUMA_PROVIDER_SHRINE "shrine_provider"
#define DEFEAT_TRAUMA_PROVIDER_UNIVERSAL "universal_provider"

#define DEFEAT_MERCY_DRAUGHT_DOSE 5
#define DEFEAT_BURDEN_DAMAGE_PER_SEVERITY 10
#define DEFEAT_BURDEN_EXHAUSTION_TIME (2 MINUTES)

#define DEFEAT_RECOVERY_MANUAL "manual"
#define DEFEAT_RECOVERY_PREPARED "prepared"
#define DEFEAT_RECOVERY_CAMPFIRE "campfire"
#define DEFEAT_RECOVERY_SELF "self"
#define DEFEAT_RECOVERY_ENVIRONMENTAL "environmental"
#define DEFEAT_RECOVERY_RUNE "rune"
#define DEFEAT_RECOVERY_INTERACTION_KEY "defeat_recovery"

#define DEFEAT_RUNE_MAX_CHARGES 5
#define DEFEAT_RUNE_RECHARGE_TIME (60 MINUTES)
/// Sentinel in the cost table meaning "bill a fraction of current blood" instead of a flat amount.
#define DEFEAT_RUNE_BLOOD_FRACTION_SENTINEL -1
/// Fraction of current blood drawn as the blood tax when spending the final charge.
#define DEFEAT_RUNE_LAST_CHARGE_BLOOD_FRACTION (2/3)

// --- Kidnapping (section 6) ---
/// Trait source for the pacifism held over a captive after their knockout is released.
#define KIDNAP_TRAIT "kidnap_captivity"
/// How long after being kidnapped the knockout wears off, handing the captive their agency back.
#define KIDNAP_KO_RELEASE (1 MINUTES)
/// How long a captor must remain beside its prey without interruption before the kidnapping commits.
#define KIDNAP_HAUL_TIME (3 SECONDS)
/// A released captive cannot be hauled straight back into another lair before they can get clear.
#define KIDNAP_RECAPTURE_GRACE (2 MINUTES)
/// How long a captive has before the surrender option is offered.
#define KIDNAP_SURRENDER_WINDOW (15 MINUTES)
/// How many climaxes endured in captivity offer the surrender option early.
#define KIDNAP_SURRENDER_CLIMAXES 4
/// How long a surrendered NPC-in-distress lingers before despawning.
#define KIDNAP_NPC_DECAY (30 MINUTES)
/// How far a would-be captor looks for rescuers/allies when deciding whether it dares drag prey off.
#define KIDNAP_GUARD_VIEW 6
/// Failed admission (most commonly a full profile) backs the captor off instead of retrying every
/// AI planning cycle and spamming the victim/nearby players.
#define KIDNAP_RETRY_COOLDOWN (30 SECONDS)
/// How long prey must lie bound before a captor with a lair hauls it off instead of playing on.
#define KIDNAP_RESTRAINED_DELAY (2 MINUTES)
/// A struggle against the bonds this recently keeps the captor playing instead of hauling.
#define KIDNAP_STRUGGLE_WINDOW (20 SECONDS)
/// A captor hauls bound prey only after a scene with it this recently.
#define KIDNAP_SCENE_MEMORY (10 MINUTES)
/// Captivity pocket ownership. Shared profiles key by a stable lair id, carrier profiles by the
/// captor reference, and per-captive profiles by the captive reference.
#define DEFEAT_CAPTIVITY_SHARED "shared"
#define DEFEAT_CAPTIVITY_CARRIER "carrier"
#define DEFEAT_CAPTIVITY_CAPTIVE "captive"
/// Profile access rules. These are deliberately data on the profile rather than behavior inferred
/// from the pocket template, so future lairs can expose different entrances without changing core.
#define DEFEAT_CAPTIVITY_ACCESS_RELEASED "released_captive"
#define DEFEAT_CAPTIVITY_ACCESS_CAPTOR "captor"
#define DEFEAT_CAPTIVITY_ACCESS_SEALED "sealed"
/// Explicit choices shown when a captive's knockout-release timer completes.
#define KIDNAP_CHOICE_CALL_RUNE "Call the rune"
#define KIDNAP_CHOICE_WAKE "Wake up"
#define KIDNAP_CHOICE_GIVE_UP "Give up this character"
#define KIDNAP_CHOICE_WAIT "Stay for now"
/// How long "Stay for now" waits before the dialog returns to a still-knocked-out captive.
#define KIDNAP_CHOICE_REPROMPT (5 MINUTES)
/// Namespaced instance keys keep captivity pockets separate from every other pocket-dimension user.
#define DEFEAT_CAPTIVITY_INSTANCE_PREFIX "defeat_captivity"

// --- NPC-in-distress (rescue NPCs) ---
/// do_after time to free a distress NPC.
#define NPC_DISTRESS_RESCUE_TIME (5 SECONDS)
/// Silver coins dropped as a rescue reward (inclusive range).
#define NPC_DISTRESS_REWARD_MIN 10
#define NPC_DISTRESS_REWARD_MAX 20
/// How far a distress NPC looks for nearby players before crying out.
#define NPC_DISTRESS_PLEA_VIEW 7
#define DEFEAT_RUNE_SPEND_KIND "kind"
#define DEFEAT_RUNE_CHARGES_REMAINING "charges_remaining"
#define DEFEAT_RUNE_SPEND_FIRST_FREE "first_free"
#define DEFEAT_RUNE_SPEND_CHARGED "charged"
#define DEFEAT_RUNE_SPEND_EMERGENCY "emergency"

#define DEFEAT_DAMAGE_THRESHOLD_DEFAULT 200
/// Burn counts partially toward the pooled threshold so a 50-damage fireball costs the same as a sword hit.
#define DEFEAT_BURN_DAMAGE_WEIGHT 0.6
/// Oxygen loss is kept out of the pooled defeat threshold: a fall from a higher z-level dumps a big
/// oxy spike that would otherwise KO almost instantly, which isn't fun. Instead oxy only puts you down
/// on its own once it reaches this near-lethal amount (roughly the kill limit).
#define DEFEAT_OXY_THRESHOLD 100
#define DEFEAT_BLOOD_VOLUME_MINIMUM BLOOD_VOLUME_OKAY
/// Recovery leaves this much room below the organ's death boundary so a following life tick cannot
/// immediately kill the victim again. The damage itself is still carried as aftermath.
#define DEFEAT_BRAIN_DAMAGE_MAX (BRAIN_DAMAGE_DEATH - 40)
/// Margin held below the normal death boundary, and below the oxygen threshold.
#define DEFEAT_DAMAGE_SAFETY_MARGIN 25
/// Carried damage after stabilization, as a fraction of the selected Defeat threshold.
#define DEFEAT_WAKE_DAMAGE_FRACTION 0.5
/// Total Endurance that stacked Defeat traumas may take between them, however many are carried.
#define DEFEAT_TRAUMA_ENDURANCE_PENALTY_CAP 6
/// Stat-modifier source enforcing the cap above by handing back the excess.
#define DEFEAT_TRAUMA_ENDURANCE_CAP_SOURCE "defeat_trauma_endurance_cap"
/// A single non-oxygen pool is never allowed to consume more than half of a normal health bar after
/// bounded stabilization. The aggregate cap is calculated from the selected threshold at runtime.
#define DEFEAT_DAMAGE_POOL_CAP_FRACTION 0.5
/// Oxygen has its own near-lethal threshold and therefore gets its own post-stabilization ceiling.
#define DEFEAT_OXY_DAMAGE_CAP (DEFEAT_OXY_THRESHOLD - DEFEAT_DAMAGE_SAFETY_MARGIN)
#define DEFEAT_SHOCK_WARNING_STAGE SHOCK_STAGE_4
#define DEFEAT_SHOCK_DEFEAT_STAGE SHOCK_STAGE_6
#define DEFEAT_SHOCK_HARD_STAGE SHOCK_STAGE_8
#define DEFEAT_SHOCK_SUSTAIN_DURATION (3 SECONDS)
#define DEFEAT_SHOCK_WARNING_COOLDOWN (10 SECONDS)
/// Warn the player once total damage reaches this fraction of their defeat threshold.
#define DEFEAT_DAMAGE_WARNING_FRACTION 0.7
#define DEFEAT_ACTIVE_HARM_WINDOW (3 SECONDS)
#define DEFEAT_PREPARED_MEDICINE_MINIMUM 5
/// Empty-handed revive channel: longest (no medical skill) and shortest (legendary). Scales by rank.
#define DEFEAT_REVIVE_TIME_MAX (150 SECONDS)
#define DEFEAT_REVIVE_TIME_MIN (45 SECONDS)
/// Empty-handed recovery is exhausting even when it succeeds.
#define DEFEAT_MANUAL_HELPER_STAMINA_COST 35
#define DEFEAT_CAMPFIRE_PASSIVE_RECOVERY_TIME (3 MINUTES)
#define DEFEAT_CAMPFIRE_TENDED_RECOVERY_TIME (45 SECONDS)
/// Climax count at which the gradual "you are nearing a horny defeat" warnings begin.
#define DEFEAT_HORNY_WARNING_START 2
/// How long a horny knockout lasts before the victim picks themselves back up unaided (the light case).
#define DEFEAT_HORNY_SELF_RECOVER_TIME (5 MINUTES)
/// Fraction of the (hidden) horny-defeat threshold at which the warning escalates to stage 2.
#define DEFEAT_HORNY_WARNING_BUILD_FRACTION 0.6
/// An "encounter" ends after this long without a counted hostile climax
#define DEFEAT_HORNY_ENCOUNTER_TIMEOUT (5 MINUTES)
/// Deterministic player thresholds snapshot current Constitution and Endurance on the first valid
/// hostile climax. Creature thresholds use immutable type defaults instead.
#define DEFEAT_HORNY_PLAYER_THRESHOLD_MIN 5
#define DEFEAT_HORNY_PLAYER_THRESHOLD_MAX 10
/// Player threshold = (CON + END) / this, before the clamp above. 4 puts an average body at the floor.
#define DEFEAT_HORNY_PLAYER_STAT_DIVISOR 4
#define DEFEAT_HORNY_MOB_THRESHOLD_MIN 1
#define DEFEAT_HORNY_MOB_THRESHOLD_MAX 3
#define DEFEAT_HORNY_THRESHOLD_VALUE "value"
#define DEFEAT_HORNY_THRESHOLD_SOURCE "source"
/// KO Only anti-softlock: when the "Struggle to Your Feet" action is offered, and the auto safety-net
/// timeout after which a still-downed KO Only victim picks themselves up unaided (grievously wounded).
#define DEFEAT_KO_ONLY_STRUGGLE_DELAY (2 MINUTES)
#define DEFEAT_KO_ONLY_AUTO_RECOVER (3 MINUTES)
#define DEFEAT_GRIEVOUS_RECOVERY_TIME (15 MINUTES)
#define DEFEAT_HAZARD_RESCUE_RADIUS 7
#define DEFEAT_FALLBACK_CHECK_INTERVAL (5 SECONDS)

// --- Mob horny-defeat KO (clientless mobs) ---
/// How long a clientless mob stays KO'd from a horny defeat before the cleanup check runs.
#define DEFEAT_MOB_HORNY_KO_DURATION (10 MINUTES)
/// While players remain nearby, how often the KO'd mob re-checks before it may be cleaned up.
#define DEFEAT_MOB_HORNY_KO_RECHECK (30 SECONDS)
/// How far the KO cleanup looks for a watching player before it deletes a lone mob.
#define DEFEAT_MOB_HORNY_CLEANUP_VIEW 7
/// How long a helper works to bring a KO'd mob back to its senses.
#define DEFEAT_MOB_HORNY_HELP_UP_TIME (4 SECONDS)
/// Percent chance an unbound KO'd mob comes to and lashes out when lifted.
#define DEFEAT_MOB_HORNY_LIFT_LASH_CHANCE 35
/// How long the lash-out floors the carrier.
#define DEFEAT_MOB_HORNY_LASH_KNOCKDOWN (2 SECONDS)
