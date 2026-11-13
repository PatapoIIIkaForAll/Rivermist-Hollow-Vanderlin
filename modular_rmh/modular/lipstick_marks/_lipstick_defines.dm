// Shared defines for the lipstick marks module; this file sorts first in the module's include list.

/// Face marks on the average frame, and limb marks per body sheet.
#define LIPSTICK_MARK_ICON 'modular_rmh/modular/lipstick_marks/icons/lipstick_marks.dmi'
/// Limb marks for 32x64 body sheets.
#define LIPSTICK_MARK_TALL_ICON 'modular_rmh/modular/lipstick_marks/icons/lipstick_marks_tall.dmi'
/// Marks drawn over penis, balls, vulva, breast and butt sprites.
#define LIPSTICK_ORGAN_MARK_ICON 'modular_rmh/modular/lipstick_marks/icons/lipstick_marks_organs.dmi'
/// Marks over the 64x32 taur penis and balls sprites.
#define LIPSTICK_TAUR_MARK_ICON 'modular_rmh/modular/lipstick_marks/icons/lipstick_marks_taur.dmi'
/// Nipple marks for the animated front breasts, with empty copies of every one-shot.
#define LIPSTICK_BREAST_CHILD_ICON 'modular_rmh/modular/lipstick_marks/icons/lipstick_marks_breast_child.dmi'

/// Kisses on one spot stop counting here; text reads it as "several".
#define LIPSTICK_MARK_MAX_COUNT 3

// Indexes into one mark entry.
#define LIPSTICK_MARK_COLOR 1
#define LIPSTICK_MARK_ALPHA 2
#define LIPSTICK_MARK_COUNT 3
#define LIPSTICK_MARK_KIND 4
/// world.time the mark was last refreshed; fading counts from here.
#define LIPSTICK_MARK_TIME 5

#define LIPSTICK_KIND_KISS "kiss"
#define LIPSTICK_KIND_SMEAR "smear"
#define LIPSTICK_KIND_RING "ring"
/// A ring at the root of the shaft, from taking it all the way.
#define LIPSTICK_KIND_DEEP "deep"
#define LIPSTICK_KIND_BITE "bite"

/// Steps a mark fades through before it is gone.
#define LIPSTICK_FADE_STEPS 4
#define LIPSTICK_FADE_STEP_TIME (15 MINUTES)
/// Shown alpha at or under this reads as faint.
#define LIPSTICK_FAINT_ALPHA 110

// How a spot is drawn.
/// Average-frame art moved by OFFSET_FACE, on BODY_LAYER.
#define LIPSTICK_ART_FACE "face"
/// Per-sheet art on BODY_LAYER, above the organs.
#define LIPSTICK_ART_TOP "top"
/// Per-sheet art just above the limbs, under the organs.
#define LIPSTICK_ART_LOW "low"
/// Art drawn over an organ overlay; it follows the organ's sprite, layer and clothing rules.
#define LIPSTICK_ART_ORGAN "organ"

/// Layer of per-sheet marks drawn under the organs.
#define LIPSTICK_LOW_LAYER (BODYPARTS_LAYER - 0.5)

#define LIPSTICK_SPOT_LIPS "lips"
#define LIPSTICK_SPOT_CHEEK "cheek"
#define LIPSTICK_SPOT_FOREHEAD "forehead"
#define LIPSTICK_SPOT_NOSE "nose"
#define LIPSTICK_SPOT_EAR "ear"
#define LIPSTICK_SPOT_NECK "neck"
#define LIPSTICK_SPOT_CHEST "chest"
#define LIPSTICK_SPOT_NIPPLES "nipples"
#define LIPSTICK_SPOT_ARMPIT "armpit"
#define LIPSTICK_SPOT_BELLY "belly"
#define LIPSTICK_SPOT_CROTCH "crotch"
#define LIPSTICK_SPOT_COCK "cock"
#define LIPSTICK_SPOT_BALLS "balls"
#define LIPSTICK_SPOT_VULVA "vulva"
#define LIPSTICK_SPOT_BUTT "butt"
#define LIPSTICK_SPOT_ANUS "anus"
#define LIPSTICK_SPOT_L_ARM "l_arm"
#define LIPSTICK_SPOT_R_ARM "r_arm"
#define LIPSTICK_SPOT_L_HAND "l_hand"
#define LIPSTICK_SPOT_R_HAND "r_hand"
#define LIPSTICK_SPOT_L_THIGH "l_thigh"
#define LIPSTICK_SPOT_R_THIGH "r_thigh"
#define LIPSTICK_SPOT_L_FOOT "l_foot"
#define LIPSTICK_SPOT_R_FOOT "r_foot"
