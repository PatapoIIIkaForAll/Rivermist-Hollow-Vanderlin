// Prosthetics window defines. Sorts first in this folder and stays defined.

/// Slots the Prosthetics window offers. Limbs reuse body zones, eyes and organs have their own ids.
#define PROSTHETIC_SLOT_L_ARM BODY_ZONE_L_ARM
#define PROSTHETIC_SLOT_R_ARM BODY_ZONE_R_ARM
#define PROSTHETIC_SLOT_L_LEG BODY_ZONE_L_LEG
#define PROSTHETIC_SLOT_R_LEG BODY_ZONE_R_LEG
#define PROSTHETIC_SLOT_L_EYE "l_eye"
#define PROSTHETIC_SLOT_R_EYE "r_eye"
#define PROSTHETIC_SLOT_HEART "heart"
#define PROSTHETIC_SLOT_LUNGS "lungs"
#define PROSTHETIC_SLOT_TONGUE "tongue"

/// The implicit option of every slot: the body's own part. Never saved.
#define PROSTHETIC_NATURAL "natural"

/// Trait source for effects a saved prosthetic choice gives at spawn.
#define PROSTHETIC_PREF_TRAIT "prosthetic_pref"
