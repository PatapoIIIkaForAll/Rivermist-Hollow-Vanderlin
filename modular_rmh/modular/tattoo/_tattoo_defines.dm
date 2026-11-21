// Skin mark defines: tattoos, brands and body writing. Sorts first and stays defined for every file in this folder.

/// Freshly applied tattoo - crisp, full detail
#define TATTOO_STATE_FRESH 1
/// Tattoo has been partly washed away - patchy, faded, harder to read
#define TATTOO_STATE_FADED 2

/// How many ink tattoos can be stacked on a single zone before it's "full"
#define MAXIMUM_TATTOOS_PER_ZONE 3
/// How many brands, plain or arcane, one zone can carry
#define MAXIMUM_BRANDS_PER_ZONE 1

/// Tattoo is rendered as a quoted piece of lettering, e.g. "ACAB"
#define TATTOO_STYLE_LETTERING "lettering"
/// Tattoo is rendered as an unquoted description of a design, e.g. a wolf's head
#define TATTOO_STYLE_DESIGN "design"

/// Max characters allowed per tattoo or writing entry
#define TATTOO_TEXT_MAX_LENGTH 150
/// Max characters allowed per brand entry
#define BRAND_TEXT_MAX_LENGTH 30

/// Inked under the skin with a needle. Water and soap do nothing; only surgery removes it.
#define TATTOO_MEDIUM_INK "ink"
/// Drawn on the skin with a lump of charcoal. Water smudges it, soap takes it off.
#define TATTOO_MEDIUM_CHARCOAL "charcoal"
/// Painted onto the skin with a loaded brush. Shares charcoal's washing rules.
#define TATTOO_MEDIUM_PAINT "paint"
/// Written with an open lipstick. Shares charcoal's washing rules.
#define TATTOO_MEDIUM_LIPSTICK "lipstick"
/// Written with a quill. Shares charcoal's washing rules.
#define TATTOO_MEDIUM_QUILL "quill"
/// Burned in with a hot iron or a flame. Only a legendary healer's cautery removes it.
#define TATTOO_MEDIUM_BRAND "brand"
/// Burned in with magic and glowing. Only cleansing magic removes it.
#define TATTOO_MEDIUM_ARCANE "arcane"

/// Water or soap used by a rag to wipe one inscription.
#define BODY_WRITING_WIPE_REAGENT_AMOUNT 1

/// The only colour a charcoal drawing can be
#define TATTOO_CHARCOAL_COLOR "#2B2B2B"
/// Quill ink, the same colour a quill writes on paper
#define TATTOO_QUILL_COLOR "#14103f"
/// Seared amber of a plain brand
#define TATTOO_BRAND_COLOR "#c48e42"
/// Glow an arcane brand gets when nothing else is chosen
#define ARCANE_BRAND_DEFAULT_GLOW "#ffb02e"

/// Movespeed modifier id for the pain of getting hand-poked
#define MOVESPEED_ID_TATTOO_PAIN "tattoo_pain"

/// Tattoo-only zones. These are not bodyparts - they are finer-grained spots
/// that live on a bodypart, see GLOB.tattoo_zone_data.
#define TATTOO_ZONE_FOREHEAD "tattoo_forehead"
#define TATTOO_ZONE_CHEEKS "tattoo_cheeks"
#define TATTOO_ZONE_CHIN "tattoo_chin"
#define TATTOO_ZONE_LIPS "tattoo_lips"
#define TATTOO_ZONE_EARS "tattoo_ears"
#define TATTOO_ZONE_HORNS "tattoo_horns"
#define TATTOO_ZONE_NECK "tattoo_neck"
#define TATTOO_ZONE_BACK "tattoo_back"
#define TATTOO_ZONE_BELLY "tattoo_belly"
#define TATTOO_ZONE_WINGS "tattoo_wings"
#define TATTOO_ZONE_TAIL "tattoo_tail"
#define TATTOO_ZONE_L_THIGH "tattoo_l_thigh"
#define TATTOO_ZONE_R_THIGH "tattoo_r_thigh"
#define TATTOO_ZONE_BREASTS "tattoo_breasts"
#define TATTOO_ZONE_GROIN "tattoo_groin"
#define TATTOO_ZONE_BUTTOCKS "tattoo_buttocks"
#define TATTOO_ZONE_PENIS "tattoo_penis"
#define TATTOO_ZONE_VAGINA "tattoo_vagina"
#define TATTOO_ZONE_L_FOOT "tattoo_l_foot"
#define TATTOO_ZONE_R_FOOT "tattoo_r_foot"
