// Orifice stretching: openings and insertions share one girth scale, centimetres of circumference.

/// Rest girth per tightness step, Virgin-tight through Gaped.
#define ORIFICE_VAGINA_REST_STEPS list(7, 8.5, 10, 12, 14, 17)
#define ORIFICE_ANUS_REST_STEPS list(4, 5, 6, 7.5, 9.5, 12)
#define ORIFICE_TIGHTNESS_NAMES list("Virgin-tight", "Tight", "Average", "Relaxed", "Loose", "Gaped")
#define ORIFICE_TIGHTNESS_AVERAGE 3

#define ORIFICE_VAGINA_ELASTICITY 1.5
#define ORIFICE_VAGINA_MAX_RATIO 2.5
#define ORIFICE_VAGINA_GAPE_RATIO 1.5
#define ORIFICE_VAGINA_HALF_LIFE (20 MINUTES)
#define ORIFICE_VAGINA_AROUSAL_BONUS 0.3

#define ORIFICE_ANUS_ELASTICITY 1.7
#define ORIFICE_ANUS_MAX_RATIO 3
#define ORIFICE_ANUS_GAPE_RATIO 1.6
#define ORIFICE_ANUS_HALF_LIFE (15 MINUTES)
#define ORIFICE_ANUS_AROUSAL_BONUS 0.15

/// Comfort bonus at full lube.
#define ORIFICE_LUBE_BONUS 0.2
/// Gape clears this far below the gape ratio, as a share of rest girth.
#define ORIFICE_GAPE_HYSTERESIS 0.15
/// Gape strain, how worn open the ring is, runs from zero to this; full strain gapes a stretched hole.
#define ORIFICE_GAPE_STRAIN_MAX 100
/// Strain this close to full snaps to full, since sums of fractional gains land a hair short.
#define ORIFICE_GAPE_STRAIN_SNAP 0.01
/// Strain lost per minute while not gaping.
#define ORIFICE_GAPE_STRAIN_DECAY_PER_MINUTE 15
/// Stretch ratio a hole must have reached before full strain can gape it.
#define ORIFICE_GAPE_ONSET_RATIO 1.3
/// Strain past the relaxed comfort from which thrusts and passages wear the ring, and where one thrust counts in full.
#define ORIFICE_GAPE_ONSET_STRAIN 1.15
#define ORIFICE_GAPE_FULL_STRAIN 1.5
/// A monstrous fit never counts as more than this many full thrusts per thrust.
#define ORIFICE_GAPE_SCALE_CAP 2
/// Full-strain thrusts at mid force and speed that fill the strain; decay between them adds more in play.
#define ORIFICE_GAPE_THRUSTS 30
/// Strain one full-strain passage adds.
#define ORIFICE_GAPE_PASSAGE_STRAIN 15
/// From this strain the menu hint warns that a gape is near.
#define ORIFICE_GAPE_WARN_STRAIN 60
/// The owner feels the ring giving way at these strains; the lines repeat once strain falls below the reset.
#define ORIFICE_GAPE_FEEL_STRAIN 50
#define ORIFICE_GAPE_FEEL_STRONG_STRAIN 80
#define ORIFICE_GAPE_FEEL_RESET_STRAIN 40
/// Recovery runs this many times faster while gaping.
#define ORIFICE_GAPE_RECOVERY_MULT 2
/// A forced over-max insertion may open the hole this far past its maximum.
#define ORIFICE_OVERMAX_ALLOWANCE 1.15
/// Every opening can at least take the largest selectable penis; only truly huge things never fit.
#define ORIFICE_MAX_GIRTH_FLOOR 33
/// Rest this long and trained looseness starts draining back, at this share of rest per minute.
#define ORIFICE_TRAINING_HOLD (1 HOURS)
#define ORIFICE_TRAINING_DRAIN_PER_MINUTE 0.001

/// Share of the gap to the insertion closed per cycle, before force.
#define ORIFICE_ADAPT_RATE 0.15
/// Share closed at once when something first goes in.
#define ORIFICE_ENTRY_SHARE 0.3
/// Receiver pain per unit of strain above comfort, before dryness.
#define ORIFICE_PAIN_PER_STRAIN 40
/// Receiver pain per unit of dryness above one, even with no strain.
#define ORIFICE_FRICTION_PAIN 6
/// Soreness per unit of strain above comfort per cycle, before dryness.
#define ORIFICE_SORENESS_PER_STRAIN 6
#define ORIFICE_SORENESS_DECAY_PER_MINUTE 1
#define ORIFICE_SORE_THRESHOLD 25
#define ORIFICE_RAW_THRESHOLD 50
#define ORIFICE_OVERUSED_THRESHOLD 80
#define ORIFICE_SORENESS_HYSTERESIS 10
/// Extra receiver pain per cycle in each soreness state.
#define ORIFICE_SORE_PAIN 5
#define ORIFICE_RAW_PAIN 12
#define ORIFICE_OVERUSED_PAIN 25
/// Orifice pain may not push the scaled total past this.
#define ORIFICE_PAIN_CAP (PAIN_HIGH_EFFECT + 10)

#define ORIFICE_STATE_FINE 0
#define ORIFICE_STATE_SORE 1
#define ORIFICE_STATE_RAW 2
#define ORIFICE_STATE_OVERUSED 3

/// Storage bulk units per centimetre of girth.
#define ORIFICE_BULK_PER_CM 2.5
/// Inner-layer bulk capacity per bulk unit of current girth.
#define ORIFICE_INNER_CAPACITY_MULT 2
/// Already this open relative to an insertion, it slides in without force.
#define ORIFICE_OPEN_ENOUGH_RATIO 0.85

/// Lubricating units that count as fully slick.
#define LUBE_FULL_UNITS 3
#define LUBE_APPLY_UNITS 2
/// Share of lube on a penis or toy that moves into the hole on entry.
#define LUBE_TRANSFER_SHARE 0.6
#define LUBE_DRY_LEVEL 0.3
#define LUBE_SLICK_LEVEL 0.6
/// Lube level that lets a straining insertion in without force.
#define LUBE_FORCE_SUBSTITUTE_LEVEL 0.5
/// Extra units per second a fast-fading lube loses, times lube_fade minus one.
#define LUBE_FADE_UNITS_PER_SECOND 0.01

#define ORIFICE_DRY_ANUS_MULT 2.5
#define ORIFICE_DAMP_ANUS_MULT 1.6
#define ORIFICE_DRY_VAGINA_MULT 1.5
/// A well-stretched anus takes it dry at this multiplier; past the free ratio, no penalty.
#define ORIFICE_DRY_STRETCHED_MULT 1.2
#define ORIFICE_DRY_STRETCHED_RATIO 1.5
#define ORIFICE_DRY_FREE_RATIO 1.9
/// Arousal below which a dry vagina counts as cold.
#define ORIFICE_COLD_AROUSAL 20
/// Dryness at or above this earns the warning before an act starts.
#define ORIFICE_DRY_WARNING_MULT 1.6

#define PENIS_LENGTH_MIN 5
#define PENIS_LENGTH_MAX 40
#define PENIS_LENGTH_DEFAULT 15
#define PENIS_LENGTH_SMALL_FRAME 11
#define PENIS_LENGTH_LARGE_FRAME 21
/// Visual bucket limits in centimetres of length.
#define PENIS_VISUAL_SMALL_MAX 11
#define PENIS_VISUAL_LARGE_MIN 20
/// Knot girth as a multiple of the shaft.
#define PENIS_KNOT_GIRTH_MULT 1.35
/// Girth a held mob counts as while pushed in.
#define MOB_HOLDER_GIRTH 14
/// Girth per bulk unit for items with no table entry.
#define ORIFICE_GENERIC_GIRTH_PER_BULK 3.5

#define KINK_SIZE_QUEEN "Size Queen"
