GLOBAL_LIST_INIT(sex_actions, build_sex_actions())

#define SEX_ACTION(sex_action_type) GLOB.sex_actions[sex_action_type]

#define ERP_PREFERENCE_EDIT_GRACE_MINUTES 20
#define ERP_PREFERENCE_EDIT_GRACE_PERIOD (ERP_PREFERENCE_EDIT_GRACE_MINUTES MINUTES)
#define KINK_NOTES_MAX_LENGTH 256

#define MAGE_HAND_ACTION_MESSAGE_START "start"
#define MAGE_HAND_ACTION_MESSAGE_PERFORM "perform"
#define MAGE_HAND_ACTION_MESSAGE_FINISH "finish"


#define COMSIG_SEX_ADJUST_AROUSAL "sex_adjust_arousal"                  // (amount) - Adjust arousal level
#define COMSIG_SEX_SET_AROUSAL "sex_set_arousal"                        // (amount) - Set arousal to specific value
#define COMSIG_SEX_AROUSAL_CHANGED "sex_arosual_change"					// fires to the parent about a change
#define COMSIG_SEX_FREEZE_AROUSAL "sex_freeze_arousal"                  // (freeze_state) - Toggle arousal freeze
#define COMSIG_SEX_GET_AROUSAL "sex_get_arousal"                        // () - Get current arousal info
#define COMSIG_SEX_GET_AROUSAL_FLOOR "sex_get_arousal_floor"            // (list/floor_data) - Raise floor_data["floor"]; cooling stops there
#define COMSIG_SEX_CLIMAX "sex_climax"                                  // (sex_action, action_receiver, action_partner, action_performer) - Handle climax event
#define COMSIG_SEX_ACTION_TICK "sex_action_tick"                        // (sex_action, action_user, action_target) - to both, once per performed beat
#define COMSIG_SEX_RECEIVE_ACTION "sex_receive_action"                  // (sex_action, action_receiver, action_partner, arousal_amt, pain_amt, orgasm_prog_amt, giving, force, speed, resist, action_performer) - Receive action effects
#define COMSIG_SEX_GENERIC_ACTION "sex_receive_gen_action"					// ... - for generic actions without the sex session panel
#define COMSIG_SEX_ADJUST_EDGING "sex_adjust_edging"                 	// (amount) - Adjust edging level
#define COMSIG_SEX_SET_EDGING "sex_set_edging"                        	// (amount) - Set edging to specific value
#define COMSIG_SEX_EDGING_CHANGED "sex_edging_change"					// fires to the parent about a change
#define COMSIG_SEX_SET_HOLDING "sex_set_holding"						// (level) - Sets the holding/resisting pleasure level
#define COMSIG_SEX_HOLE_BEFORE_INSERT "sex_hole_before_insert"						// fires when we insert an object into a *hole*
#define COMSIG_SEX_HOLE_AFTER_INSERT "sex_hole_after_insert"						// fires when we insert an object into a *hole*
#define COMSIG_SEX_HOLE_BEFORE_REMOVE "sex_hole_before_remove"						// fires when we remove an object from a *hole*
#define COMSIG_SEX_HOLE_AFTER_REMOVE "sex_hole_after_remove"						// fires when we remove an object from a *hole*
#define COMSIG_SEX_ADJUST_ORGASM_PROG "sex_adjust_orgasm_prog"                  // (amount) - Adjust orgasm prog level
#define COMSIG_SEX_SET_ORGASM_PROG "sex_set_orgasm_prog"                        // (amount) - Set orgasm prog to specific value
#define COMSIG_SEX_EDGED_BY_OTHER_STATE "sex_set_edged_state"                        // (amount) - Set orgasm prog to specific value
#define COMSIG_SET_ERECT_STATE "sex_set_erectness"						// when we set manual arousal
#define COMSIG_SEX_ORGASM "sex_orgasm"									// manual orgasm

// Knotting Component Signals
/// Attempts to knot a target. Args: (target, force_level, originating_action)
#define COMSIG_SEX_TRY_KNOT "sex_try_knot"
/// Removes an existing knot. Args: (forceful_removal, notify, keep_top_status, keep_btm_status)
#define COMSIG_SEX_REMOVE_KNOT "sex_remove_knot"

// General Sex Signals
/// Checks if user can use their penis. Return: TRUE/FALSE
#define COMSIG_SEX_CAN_USE_PENIS "sex_can_use_penis"
/// Checks if user is considered limp. Return: TRUE/FALSE
#define COMSIG_SEX_CONSIDERED_LIMP "sex_considered_limp"

#define SEX_UI_ZONE_ANY 0
#define SEX_UI_ZONE_MOUTH (1 << 0)
#define SEX_UI_ZONE_GENITALS (1 << 1)
#define SEX_UI_ZONE_ARMS (1 << 2)
#define SEX_UI_ZONE_LEGS (1 << 3)
#define SEX_UI_ZONE_BODY (1 << 4)
#define SEX_UI_ZONE_MISC (1 << 5)

#define SEX_CUSTOM_ACTION_PREFIX "custom:"

#define SEX_CUSTOM_SCOPE_PARTNER 1
#define SEX_CUSTOM_SCOPE_SELF 2

#define SEX_CUSTOM_PART_NONE 0
#define SEX_CUSTOM_PART_MOUTH 1
#define SEX_CUSTOM_PART_PENIS 2
#define SEX_CUSTOM_PART_VAGINA 3
#define SEX_CUSTOM_PART_ANUS 4
#define SEX_CUSTOM_PART_BREASTS 5
#define SEX_CUSTOM_PART_TESTICLES 6
#define SEX_CUSTOM_PART_HANDS 7
#define SEX_CUSTOM_PART_FEET 8
#define SEX_CUSTOM_PART_THIGHS 9
#define SEX_CUSTOM_PART_BODY 10
#define SEX_CUSTOM_PART_ANY_GENITALS 11

/// Scene-level interaction families used by multi-action pattern matching.
#define SEX_SCENE_INTERACTION_ORAL "oral"
#define SEX_SCENE_INTERACTION_PENETRATION "penetration"

/// A participant's direction within one scene-level interaction.
#define SEX_SCENE_ROLE_GIVER "giver"
#define SEX_SCENE_ROLE_RECEIVER "receiver"

/// Stable identifiers for recognized multi-action configurations.
#define SEX_SCENE_PATTERN_AIRTIGHT "airtight"
#define SEX_SCENE_PATTERN_DOUBLE_PENETRATION "double_penetration"
#define SEX_SCENE_PATTERN_SPITROAST "spitroast"

/// Hard cap for one shared multi-participant scene.
#define SEX_SCENE_AI_MAX_PARTICIPANTS 8
#define SEX_SCENE_MAX_PARTICIPANTS 30

/// Sent to a scene and every involved participant when a multi-action pattern begins. Args: (pattern_match)
#define COMSIG_SEX_SCENE_PATTERN_STARTED "sex_scene_pattern_started"
/// Sent to a scene and every involved participant when a multi-action pattern ends. Args: (pattern_match)
#define COMSIG_SEX_SCENE_PATTERN_ENDED "sex_scene_pattern_ended"


#define COMSIG_BODYSTORAGE_TRY_INSERT "hole_try_fit"			// (incoming_item, target_layer, force, override)
#define COMSIG_BODYSTORAGE_FORCE_INSERT "hole_force_insert"		// (incoming_item, target_layer)
#define COMSIG_BODYSTORAGE_CHECK_FIT "hole_check_fit"			// (incoming_item, target_layer, force, override)
#define COMSIG_BODYSTORAGE_TRY_REMOVE "hole_try_remove"			// (removed_item, target_layer, removal_reason)
#define COMSIG_BODYSTORAGE_FORCE_REMOVE "hole_force_remove"		// (removed_item, target_layer)
#define COMSIG_BODYSTORAGE_GET_LISTS "hole_get_lists"           //
#define COMSIG_BODYSTORAGE_SELECT_RAND_ITEM "hole_sel_item"		// (target_layer)
#define COMSIG_BODYSTORAGE_REMOVE_RAND_ITEM "hole_get_item"		// (target_layer)
#define COMSIG_BODYSTORAGE_IS_ITEM_IN "hole_check_item"			// (t_item, target_layer)
#define COMSIG_BODYSTORAGE_IS_ITEM_TYPE_IN "hole_check_item_type"	// (type, target_layer)
#define COMSIG_BODYSTORAGE_GET_2D_ITEM_LIST "hole_2d_list"		// ()
#define COMSIG_BODYSTORAGE_UPDATE_SIZE "hole_update_size"	// ()
#define COMSIG_BODYSTORAGE_CHANGED "hole_changed"			// (storage_component)
#define COMSIG_BODYSTORAGE_FIND_ITEM_LAYER "hole_find_item_layer"	// ()
#define COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND "hole_swap_layers"	// (target_layer, force)
#define COMSIG_BODYSTORAGE_TRY_RESIZE "hole_try_resize"	// (stored_item, new_bulk, force)

#define BODYSTORAGE_REMOVE_MANUAL "manual"
#define BODYSTORAGE_REMOVE_RANDOM "random"
#define BODYSTORAGE_REMOVE_INTERNAL "internal"

#define SEX_SPEED_LOW 1
#define SEX_SPEED_MID 2
#define SEX_SPEED_HIGH 3
#define SEX_SPEED_EXTREME 4
/// Fifth and highest speed; the panel names it Furious, since level four is already Unrelenting.
#define SEX_SPEED_UNRELENTING 5

#define SEX_SPEEDS list(SEX_SPEED_LOW, SEX_SPEED_MID, SEX_SPEED_HIGH, SEX_SPEED_EXTREME, SEX_SPEED_UNRELENTING)

#define SEX_SPEED_MIN 1
#define SEX_SPEED_MAX 5

#define SEX_FORCE_LOW 1
#define SEX_FORCE_MID 2
#define SEX_FORCE_HIGH 3
#define SEX_FORCE_EXTREME 4
/// Fifth and highest force, above Brutal; the panel names it Unrelenting.
#define SEX_FORCE_UNRELENTING 5

#define SEX_FORCES list(SEX_FORCE_LOW, SEX_FORCE_MID, SEX_FORCE_HIGH, SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)

#define SEX_FORCE_MIN 1
#define SEX_FORCE_MAX 5

/// Per-cycle chance and damage for brutal force snagging the receiver's bare stockings.
#define SEX_LEGWEAR_SNAG_CHANCE 15
#define SEX_LEGWEAR_SNAG_DAMAGE 6
/// The same at unrelenting force.
#define SEX_LEGWEAR_SNAG_CHANCE_UNRELENTING 25
#define SEX_LEGWEAR_SNAG_DAMAGE_UNRELENTING 9

// Impact marks: spanks and lashes leave fading, examine-only marks on the struck spot.
#define IMPACT_MARK_NONE 0
#define IMPACT_MARK_FAINT 1
#define IMPACT_MARK_RED 2
#define IMPACT_MARK_BRUISED 3
#define IMPACT_MARK_MAX IMPACT_MARK_BRUISED
/// Strike score (force level + tool tier + Strength bonus) a mark level needs.
#define IMPACT_MARK_SCORE_FAINT 2
#define IMPACT_MARK_SCORE_RED 4
#define IMPACT_MARK_SCORE_BRUISED 6
/// Strength counts from this base, one score point per step above or below it.
#define IMPACT_MARK_STRENGTH_BASE 10
#define IMPACT_MARK_STRENGTH_STEP 5
/// Tool tiers: a bare hand or soft flogger, a strap, paddle or crop, a whip or cane.
#define IMPACT_TOOL_HAND 0
#define IMPACT_TOOL_STRAP 1
#define IMPACT_TOOL_WHIP 2
/// How long each mark level shows before it fades one level.
#define IMPACT_MARK_FADE_FAINT (10 MINUTES)
#define IMPACT_MARK_FADE_RED (20 MINUTES)
#define IMPACT_MARK_FADE_BRUISED (40 MINUTES)
/// Least time between two sates from making or taking marks, by mark level; heavier marks sate sooner.
#define IMPACT_MARK_SATE_COOLDOWN_FAINT (15 MINUTES)
#define IMPACT_MARK_SATE_COOLDOWN_RED (10 MINUTES)
#define IMPACT_MARK_SATE_COOLDOWN_BRUISED (5 MINUTES)
/// Least time between two sates from examining marks.
#define IMPACT_MARK_EXAMINE_SATE_COOLDOWN (5 MINUTES)
// Indexes into one impact mark entry.
#define IMPACT_MARK_LEVEL 1
#define IMPACT_MARK_BY_TOOL 2
#define IMPACT_MARK_TIME 3

#define SEX_MANUAL_AROUSAL_DEFAULT 1
#define SEX_MANUAL_AROUSAL_UNAROUSED 2
#define SEX_MANUAL_AROUSAL_PARTIAL 3
#define SEX_MANUAL_AROUSAL_FULL 4

#define SEX_MANUAL_AROUSALS LIST(SEX_MANUAL_AROUSAL_DEFAULT, SEX_MANUAL_AROUSAL_UNAROUSED, SEX_MANUAL_AROUSAL_PARTIAL, SEX_MANUAL_AROUSAL_FULL)

#define SEX_MANUAL_AROUSAL_MIN 1
#define SEX_MANUAL_AROUSAL_MAX 4

#define BLUEBALLS_GAIN_THRESHOLD 40
#define BLUEBALLS_LOOSE_THRESHOLD 35

#define PAIN_MILD_EFFECT 10
#define PAIN_MED_EFFECT 20
#define PAIN_HIGH_EFFECT 30
#define PAIN_MINIMUM_FOR_DAMAGE PAIN_MED_EFFECT
#define PAIN_DAMAGE_DIVISOR 50

/// Force pain steps. Top step jumps hard; low steps stay under 1 so gentle contact never hurts.
#define SEX_FORCE_PAIN_MULT_LOW 0.25
#define SEX_FORCE_PAIN_MULT_MID 0.75
#define SEX_FORCE_PAIN_MULT_HIGH 2.0
#define SEX_FORCE_PAIN_MULT_EXTREME 4.0
#define SEX_FORCE_PAIN_MULT_UNRELENTING 6.0

/// Speed pain steps. Secondary to force; speed sharpens what force already causes.
#define SEX_SPEED_PAIN_MULT_LOW 0.8
#define SEX_SPEED_PAIN_MULT_MID 1.0
#define SEX_SPEED_PAIN_MULT_HIGH 1.25
#define SEX_SPEED_PAIN_MULT_EXTREME 1.5
#define SEX_SPEED_PAIN_MULT_UNRELENTING 1.75

/// How much the receiver's own arousal softens incoming pain, by arousal band.
#define SEX_PAIN_READINESS_UNAROUSED 1.4
#define SEX_PAIN_READINESS_WARMING 1.0
#define SEX_PAIN_READINESS_READY 0.75
#define SEX_PAIN_READINESS_LOST 0.55

#define SEX_PAIN_READINESS_WARMING_THRESHOLD 20
#define SEX_PAIN_READINESS_READY_THRESHOLD 60
#define SEX_PAIN_READINESS_LOST_THRESHOLD 120

#define MAX_AROUSAL 500
#define PASSIVE_EJAC_THRESHOLD 108
#define ACTIVE_EJAC_THRESHOLD 100
#define MAX_ORGASM_PROG 120
#define SEX_MAX_CHARGE 400
#define CHARGE_FOR_CLIMAX 100
#define VISIBLE_AROUSAL_THRESHOLD 20
#define CHARGE_RECHARGE_RATE (CHARGE_FOR_CLIMAX / (1 MINUTES))
#define AROUSAL_TIME_TO_UNHORNY (5 SECONDS)
#define SPENT_AROUSAL_RATE (0.5 / (1 SECONDS))
#define IMPOTENT_AROUSAL_LOSS_RATE (3 / (1 SECONDS))

#define MOAN_COOLDOWN 3 SECONDS
#define PAIN_COOLDOWN 6 SECONDS
/// Harder force earns faster feedback, so top settings read as continuous.
#define PAIN_COOLDOWN_HIGH (4 SECONDS)
#define PAIN_COOLDOWN_EXTREME (2.5 SECONDS)
#define PAIN_COOLDOWN_UNRELENTING (1.5 SECONDS)

#define LOW_ORGASM_THRESHOLD_GAIN 4
#define MED_ORGASM_THRESHOLD_GAIN 6
#define HIGH_ORGASM_THRESHOLD_GAIN 11
#define OVER_THE_TOP_ORGASM_THRESHOLD_GAIN 16

#define LOW_ORGASM_THRESHOLD_LOSS 3
#define MED_ORGASM_THRESHOLD_LOSS 4
#define HIGH_ORGASM_THRESHOLD_LOSS 7
#define OVER_THE_TOP_ORGASM_THRESHOLD_LOSS 12

#define ORGASM_RESET_TIME (3 MINUTES)
#define ORGASM_COOLDOWN_TIME (10 SECONDS)
#define ORGASM_STRAIN_MAX 100
#define ORGASM_STRAIN_DECAY_INTERVAL (30 SECONDS)
#define ORGASM_STRAIN_DECAY_AMOUNT 4
#define ORGASM_STRAIN_NYMPH_THRESHOLD_MOD 10
#define LOW_ORGASM_STRAIN_GAIN 22
#define MED_ORGASM_STRAIN_GAIN 42
#define HIGH_ORGASM_STRAIN_GAIN 66
#define OVER_THE_TOP_ORGASM_STRAIN_GAIN 90
#define LOW_ORGASM_STRAIN_LOSS 10
#define MED_ORGASM_STRAIN_LOSS 24
#define HIGH_ORGASM_STRAIN_LOSS 44
#define OVER_THE_TOP_ORGASM_STRAIN_LOSS 66
#define AROUSAL_EDGING_THRESHOLD 65
#define MAX_EDGING 90

#define RESIST_NONE 1
#define RESIST_LOW 2
#define RESIST_MEDIUM 3
#define RESIST_HIGH 4

#define AROUSAL_HIGH_UNHORNY_RATE (1.5 / (1 SECONDS))
#define AROUSAL_MID_UNHORNY_RATE (0.4 / (1 SECONDS))
#define AROUSAL_LOW_UNHORNY_RATE (0.2 / (1 SECONDS))

#define LOINHURT_GAIN_THRESHOLD 25

#define MIN_PENIS_SIZE 1
#define DEFAULT_PENIS_SIZE 2
#define MAX_PENIS_SIZE 3
#define TOTAL_PENIS_SIZE 3

#define PENIS_SIZES list(\
	MIN_PENIS_SIZE,\
	DEFAULT_PENIS_SIZE,\
	MAX_PENIS_SIZE,\
	)

#define PENIS_SIZES_BY_NAME list(\
	"Small" = MIN_PENIS_SIZE,\
	"Average" = DEFAULT_PENIS_SIZE,\
	"Large" = MAX_PENIS_SIZE,\
	)

#define PENIS_TYPE_PLAIN 1
#define PENIS_TYPE_KNOTTED 2
#define PENIS_TYPE_EQUINE 3
#define PENIS_TYPE_TAPERED 4
#define PENIS_TYPE_TAPERED_DOUBLE 5
#define PENIS_TYPE_TAPERED_DOUBLE_KNOTTED 6
#define PENIS_TYPE_BARBED 7
#define PENIS_TYPE_BARBED_KNOTTED 8
#define PENIS_TYPE_TENTACLE 9
#define PENIS_TYPE_OVIPOSITOR 10

#define SHEATH_TYPE_NONE 0
#define SHEATH_TYPE_NORMAL 1
#define SHEATH_TYPE_SLIT 2

#define ERECT_STATE_NONE 0
#define ERECT_STATE_PARTIAL 1
#define ERECT_STATE_HARD 2

#define MIN_TESTICLES_SIZE 1
#define DEFAULT_TESTICLES_SIZE 2
#define MAX_TESTICLES_SIZE 3
/// Share of what the balls hold that one climax releases, before the fullness scale.
#define TESTICLES_LOAD_SHARE 0.25
#define TOTAL_TESTICLES_SIZE 3

#define TESTICLE_SIZES list(\
	MIN_TESTICLES_SIZE,\
	DEFAULT_TESTICLES_SIZE,\
	MAX_TESTICLES_SIZE,\
	)

#define TESTICLE_SIZES_BY_NAME list(\
	"Small" = MIN_TESTICLES_SIZE,\
	"Average" = DEFAULT_TESTICLES_SIZE,\
	"Large" = MAX_TESTICLES_SIZE,\
	)

#define ORGAN_SLOT_PENIS "penis"
#define ORGAN_SLOT_TESTICLES "testicles"
#define ORGAN_SLOT_BREASTS "breasts"
#define ORGAN_SLOT_VAGINA "vagina"
#define ORGAN_SLOT_WOMB "womb"
#define ORGAN_SLOT_ANUS "anus"
#define ORGAN_SLOT_BUTT "butt"
#define ORGAN_SLOT_BELLY "belly"
#define ORGAN_SLOT_PUBIC "pubic"
#define ORGAN_SLOT_LEFT_NIP "nip_l"
#define ORGAN_SLOT_RIGHT_NIP "nip_r"

#define BREAST_SIZE_FLAT 0
#define BREAST_SIZE_VERY_SMALL 1
#define BREAST_SIZE_SMALL 2
#define BREAST_SIZE_NORMAL 3
#define BREAST_SIZE_LARGE 4
#define BREAST_SIZE_ENORMOUS 5

#define MIN_BREASTS_SIZE BREAST_SIZE_FLAT
#define DEFAULT_BREASTS_SIZE BREAST_SIZE_NORMAL
#define MAX_BREASTS_SIZE BREAST_SIZE_ENORMOUS
#define TOTAL_BREASTS_SIZE 8

#define BREAST_SIZES list(\
	BREAST_SIZE_FLAT,\
	BREAST_SIZE_VERY_SMALL,\
	BREAST_SIZE_SMALL,\
	BREAST_SIZE_NORMAL,\
	BREAST_SIZE_LARGE,\
	BREAST_SIZE_ENORMOUS,\
	)

#define BREAST_SIZES_BY_NAME list(\
	"Flat" = BREAST_SIZE_FLAT,\
	"Very Small" = BREAST_SIZE_VERY_SMALL,\
	"Small" = BREAST_SIZE_SMALL,\
	"Normal" = BREAST_SIZE_NORMAL,\
	"Large" = BREAST_SIZE_LARGE,\
	"Enormous" = BREAST_SIZE_ENORMOUS,\
	)

#define KINK_PROCESS (1 << 0)
#define KINK_SEX_ACT (1 << 1)
#define KINK_ATTACKED (1 << 2)

#define KINK_BONDAGE "Bondage"
#define KINK_DOMINATION "Domination"
#define KINK_GENTLE "Gentle"
#define KINK_ONOMATOPOEIA "Onomatopoeia"
#define KINK_PRAISE "Praise"
#define KINK_PUBLIC_RISK "Public Risk"
#define KINK_ROLEPLAY "Roleplay"
#define KINK_ROUGH "Rough"
#define KINK_SENSUAL_PLAY "Sensual Play"
#define KINK_SUBMISSIVE "Submissive"
#define KINK_TEASING "Teasing"
#define KINK_VISUAL_EFFECTS "Visual Effects"


#define ORGASM_LOCATION_INTO "into"
#define ORGASM_LOCATION_ONTO "onto"
#define ORGASM_LOCATION_ORAL "oral"
#define ORGASM_LOCATION_SELF "self"
#define ORGASM_LOCATION_CONTAINER "container"

/// Units of femcum a female climax makes; what the wetness cap cannot keep gushes out at once.
#define FEMCUM_ORGASM_VOLUME 10

// Fluid modifier sources. Sources are strings so they never hold a reference.
#define FLUID_SOURCE_PREGNANCY "pregnancy"
#define FLUID_SOURCE_POST_PREGNANCY "post_pregnancy"
#define FLUID_SOURCE_LACTATION_INDUCER "lactation_inducer"
/// Modifiers every member of a species has, such as a small frame.
#define FLUID_SOURCE_SPECIES "species"

// Heat cycle sources, kept as TRAIT_HEAT_CYCLE sources. Species and werewolf heat need the ERP preference.
#define HEAT_SOURCE_QUIRK "heat_quirk"
#define HEAT_SOURCE_SPECIES "heat_species"
#define HEAT_SOURCE_WEREWOLF "heat_werewolf"
/// Heat pulls arousal up to here and holds it: damp, but too low to drip or edge.
#define HEAT_AROUSAL_FLOOR 50
/// Most arousal one heat or pheromone tick adds.
#define HEAT_AROUSAL_STEP 4
/// Pheromone preference flags: which scent arouses you.
#define PHEROMONE_SCENT_HEAT (1<<0)
#define PHEROMONE_SCENT_RUT (1<<1)
/// Someone else's pheromones pull arousal up to here and hold it.
#define PHEROMONE_AROUSAL_FLOOR 40
/// Plain arousal wetness drips to the floor only from this arousal up.
#define VAGINA_DRIP_AROUSAL 80
/// Units per second of own femcum taken back while wetness sits above its arousal target.
#define VAGINA_WETNESS_FADE_RATE 0.02

// Body fluid reagent data keys: who made it, whether makers mixed, and a hint of their last meals.
#define FLUID_DATA_DONOR "fluid_donor"
#define FLUID_DATA_MIXED "fluid_mixed_donors"
#define FLUID_DATA_DIET "fluid_diet_hint"
/// Tasting the same maker again counts as a new visit only this long after the last one.
#define FAMILIAR_TASTE_GAP (1 HOURS)
/// Visits after which a familiar taste becomes a cherished one.
#define FAMILIAR_TASTE_CHERISHED_VISITS 3

// Body zones that body fluids can coat.
#define FLUID_COAT_FACE "face"
#define FLUID_COAT_CHEST "chest"
#define FLUID_COAT_BELLY "belly"
#define FLUID_COAT_GROIN "groin"
#define FLUID_COAT_BACK "back"
#define FLUID_COAT_THIGHS "thighs"
#define FLUID_COAT_FEET "feet"
/// Units one coat zone holds; the rest runs off to the floor.
#define FLUID_COAT_CAPACITY 12
/// A zone holding this much reads and draws as heavily coated.
#define FLUID_COAT_HEAVY_UNITS 6
/// Units spilled on the face when a climax goes into the mouth.
#define FLUID_COAT_ORAL_SPILL 1
/// Share of a bare leak that clings to the skin; the rest drips to the floor.
#define FLUID_COAT_LEAK_SHARE 0.5
/// Aim zone for a shot into the mouth rather than onto the face.
#define PENIS_AIM_MOUTH "mouth"
/// Share of a mouth shot that is swallowed when the mouth is free; the rest glazes the face.
#define PENIS_AIM_MOUTH_SHARE 0.6
/// Least time between two aim announcements from the same grip.
#define PENIS_AIM_MESSAGE_COOLDOWN (3 SECONDS)
/// Least time between two slaps with the same grip.
#define PENIS_SLAP_COOLDOWN (1.5 SECONDS)
/// Slap heft (size, body mismatch, force, stiffness) that knocks the target back a tile.
#define PENIS_SLAP_KNOCKBACK_HEFT 1.5
/// Arousal the cock's owner gets from one slap.
#define PENIS_SLAP_AROUSAL 1

// Spots on a body a crotch can grind against; a turned back reads ass, lower back and back.
#define GRIND_SPOT_FEET "feet"
#define GRIND_SPOT_THIGH "thigh"
#define GRIND_SPOT_HAND "hand"
#define GRIND_SPOT_CROTCH "crotch"
#define GRIND_SPOT_LAP "lap"
#define GRIND_SPOT_BELLY "belly"
#define GRIND_SPOT_ARM "arm"
#define GRIND_SPOT_CHEST "chest"
#define GRIND_SPOT_FACE "face"
/// Leak multiplier while the owner lies down; gravity helps less.
#define FLUID_LYING_LEAK_MULT 0.5
/// Leak multiplier for a vagina or anus while the owner holds it in.
#define FLUID_HELD_LEAK_MULT 0.1
/// Time between the stamina checks of holding fluids in.
#define FLUID_HOLD_TICK (5 SECONDS)
/// Fatigue per hold tick while something is held; far below natural recovery, so it lasts indefinitely.
#define FLUID_HOLD_STAMINA_COST 1
/// Share of the held fluid that gushes out when the hold gives out.
#define FLUID_HOLD_GUSH_SHARE 0.25
/// Time between conception checks while virile seed is inside; short, so timing does not decide the outcome.
#define CONCEPTION_CHECK_INTERVAL (10 SECONDS)
/// Percent chance per minute for a full dose of average seed.
#define CONCEPTION_CHANCE_PER_MINUTE 15
/// Percent chance per check for a full dose of average seed.
#define CONCEPTION_BASE_CHANCE (CONCEPTION_CHANCE_PER_MINUTE * CONCEPTION_CHECK_INTERVAL / (1 MINUTES))
/// Virile seed units below which no check is made.
#define CONCEPTION_MIN_SEED 1
/// Virile seed units that count as a full dose; less scales the chance down.
#define CONCEPTION_FULL_SEED 7
/// Virile seed units at which the chance reaches its cap of twice a full dose.
#define CONCEPTION_DOUBLE_SEED 21
/// Conception chance multiplier while the carrier is in heat.
#define CONCEPTION_HEAT_MULT 2
/// Units of seed the vagina passes into the womb per intake tick; only seed in the womb can take root.
#define WOMB_SEED_INTAKE_PER_TICK 1
/// Time between womb intake ticks.
#define WOMB_SEED_INTAKE_INTERVAL (20 SECONDS)
/// Outcomes of one try to draw a toy out of a hole, from the filling organ's resolve_toy_removal().
#define TOY_REMOVE_OUT 1
#define TOY_REMOVE_NO_GRIP 2
#define TOY_REMOVE_SLIPPED_DEEPER 3
#define TOY_REMOVE_STUCK 4
/// Morning sickness starts this long after conception, somewhere in the range.
#define PREGNANCY_SICKNESS_MIN_DELAY (30 MINUTES)
#define PREGNANCY_SICKNESS_MAX_DELAY (60 MINUTES)
/// How long morning sickness lasts if the belly has not grown first.
#define PREGNANCY_SICKNESS_DURATION (2 HOURS)
/// Time between bouts of morning sickness, somewhere in the range.
#define PREGNANCY_SICKNESS_MIN_GAP (8 MINUTES)
#define PREGNANCY_SICKNESS_MAX_GAP (15 MINUTES)
/// Percent chance that a bout of morning sickness makes the carrier retch.
#define PREGNANCY_RETCH_CHANCE 10
/// Time for a conventional pregnancy belly to grow one stage.
#define PREGNANCY_STAGE_TIME (1 HOURS)
/// Full-term conventional pregnancy stage; the belly shows it with preg_1 and preg_2.
#define PREGNANCY_MAX_STAGE 2
/// A seed sachet only notices a pregnancy at least this old.
#define PREGNANCY_TEST_MIN_AGE (10 MINUTES)
/// Time for a wetted seed sachet to show its result.
#define PREGNANCY_TEST_READ_TIME (3 MINUTES)
/// Time to wet a seed sachet.
#define PREGNANCY_TEST_WET_TIME (5 SECONDS)
/// Conception chance or seed virility left under a contraceptive draught.
#define CONTRACEPTIVE_MULTIPLIER 0.1
/// How long one dose of a contraceptive draught lasts.
#define CONTRACEPTIVE_DURATION (1 HOURS)
/// A climax outside the body splits into two spurts from this many units, three above the next.
#define CLIMAX_SPURT_TWO_UNITS 3
#define CLIMAX_SPURT_THREE_UNITS 5
/// Time between two spurts of one climax; long enough to re-aim between them.
#define CLIMAX_SPURT_INTERVAL (1.2 SECONDS)
/// Arousal share of MAX_AROUSAL above which pulling out can fail; the panel shows the same share.
#define PULL_OUT_FAIL_AROUSAL_SHARE 0.6
/// Percent chance a pull-out fails just above that arousal, and at full arousal.
#define PULL_OUT_FAIL_MIN_CHANCE 10
#define PULL_OUT_FAIL_MAX_CHANCE 30
/// Extra percent chance a pull-out fails while a stronger partner leg-locks the one inside them.
#define LEG_LOCK_PULL_OUT_FAIL_CHANCE 50
/// Highest chance a pull-out fails, so the one inside can always get out in the end.
#define PULL_OUT_FAIL_MAX_TOTAL 90
/// Orgasm progress one edging squeeze takes back.
#define EDGE_SQUEEZE_DRAIN 25
/// Edging charge one squeeze adds.
#define EDGE_SQUEEZE_EDGING 10
/// Least time between two squeezes.
#define EDGE_SQUEEZE_COOLDOWN (3 SECONDS)
/// Orgasm progress a squeeze needs before there is anything to hold back; climax comes at PASSIVE_EJAC_THRESHOLD.
#define EDGE_SQUEEZE_MIN_PROGRESS 70
/// Orgasm progress at which the hand feels the cock throb, the cue to squeeze.
#define EDGE_SQUEEZE_CUE_PROGRESS 85
/// Arousal left after a climax choked off mid-spurt.
#define RUINED_ORGASM_AROUSAL 90
/// How long milk keeps flowing after a conventional pregnancy ends.
#define POST_PREGNANCY_LACTATION_TIME (30 MINUTES)
/// Units of a fluid potion in the blood needed before it takes effect.
#define FLUID_POTION_DOSE 4
/// Least volume in stomach and blood that a swap potion accepts as its paired reagent.
#define FLUID_SWAP_MIN_PAIR_VOLUME 5
/// A swapped fluid costs this many times the nutrition it gives back, so drinking it never profits.
#define FLUID_SWAP_NUTRITION_MARGIN 1.5
/// Testicles holding this share of capacity release a pent-up load.
#define FLUID_PENT_UP_RATIO 0.9
/// Climax release scale for empty and for full testicles; half full releases the base amount.
#define FLUID_PENT_UP_MIN_MULT 0.5
#define FLUID_PENT_UP_MAX_MULT 1.5
/// Units swallowed per lick of a soaked garment, and the least a garment must hold to be licked.
#define FLUID_LICK_AMOUNT 2
#define FLUID_LICK_MIN_VOLUME 0.5
/// Where body fluid stains a garment.
#define FLUID_STAIN_GROIN "groin"
#define FLUID_STAIN_CHEST "chest"
/// Fullness shares at which an engorging organ shows one more size step.
#define FLUID_ENGORGEMENT_STEP_1 0.5
#define FLUID_ENGORGEMENT_STEP_2 0.75
#define FLUID_ENGORGEMENT_STEP_3 0.95

/proc/build_sex_actions()
	. = list()
	for(var/datum/path as anything in typesof(/datum/sex_action))
		if(IS_ABSTRACT(path))
			continue
		.[path] = new path()
	return .



#define SEX_SOUNDS_SLOW list(\
	"sound/misc/mat/sex_clap/slow/SexSlap14.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap20.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap21.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap23.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap34.ogg",\
	)

#define SEX_SOUNDS_HARD list(\
	"sound/misc/mat/sex_clap/hard/SexSmack17.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack18.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack20.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack21.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack24.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack26.ogg",\
	)


#define BELLY_SIZE_FLAT 0
#define BELLY_SIZE_SMALL 1
#define BELLY_SIZE_MEDIUM 2
#define BELLY_SIZE_LARGE 3

#define BELLY_SIZES list(\
	BELLY_SIZE_FLAT = 0,\
	BELLY_SIZE_SMALL = 1,\
	BELLY_SIZE_MEDIUM = 2,\
	BELLY_SIZE_LARGE = 3,\
)
#define BELLY_SIZES_BY_NAME list(\
	"Flat" = BELLY_SIZE_FLAT,\
	"Small" = BELLY_SIZE_SMALL,\
	"Medium" = BELLY_SIZE_MEDIUM,\
	"Large" = BELLY_SIZE_LARGE,\
)

#define BUTT_SIZE_FLAT 0
#define BUTT_SIZE_SMALL 1
#define BUTT_SIZE_MEDIUM 2
#define BUTT_SIZE_LARGE 3

#define BUTT_SIZES list(\
	BUTT_SIZE_FLAT = 0,\
	BUTT_SIZE_SMALL = 1,\
	BUTT_SIZE_MEDIUM = 2,\
	BUTT_SIZE_LARGE = 3,\
)
#define BUTT_SIZES_BY_NAME list(\
	"Flat" = BUTT_SIZE_FLAT,\
	"Small" = BUTT_SIZE_SMALL,\
	"Medium" = BUTT_SIZE_MEDIUM,\
	"Large" = BUTT_SIZE_LARGE,\
)

#define DEFAULT_BELLY_SIZE BELLY_SIZE_FLAT
#define MIN_BELLY_SIZE BELLY_SIZE_FLAT
#define MAX_BELLY_SIZE BELLY_SIZE_LARGE
#define TOTAL_BELLY_SIZE 3
/// Largest stuffed or pregnant bump; levels 1 to this use the preg_N belly sprites.
#define BELLY_BUMP_MAX 4

#define DEFAULT_BUTT_SIZE BUTT_SIZE_FLAT
#define MIN_BUTT_SIZE BUTT_SIZE_SMALL
#define MAX_BUTT_SIZE BUTT_SIZE_LARGE //5 available, above 4 may be too big.
#define TOTAL_BUTT_SIZE 3


#define DRAW_ABOVE "draw_above" //for drawing organs above the clothes

#define HORNY_MOBS_TAG_MALES (1 << 0)
#define HORNY_MOBS_TAG_FEMALES (1 << 1)

// Fine-grained consent for which horny mob families may target a player.
#define HORNY_MOB_TYPE_HUMANOIDS (1 << 0)
#define HORNY_MOB_TYPE_SPIDERS (1 << 1)
#define HORNY_MOB_TYPE_BOG_BUGS (1 << 2)
#define HORNY_MOB_TYPE_TROLLS (1 << 3)
#define HORNY_MOB_TYPE_BEASTS (1 << 4)
#define HORNY_MOB_TYPE_LAMIAS (1 << 5)
#define HORNY_MOB_TYPE_MINOTAURS (1 << 6)
#define HORNY_MOB_TYPE_LYCANS (1 << 7)
#define HORNY_MOB_TYPE_LIZARDS (1 << 8)
#define HORNY_MOB_TYPE_UNDEAD (1 << 9)
#define HORNY_MOB_TYPE_TENTACLES (1 << 10)
#define HORNY_MOB_TYPE_MANEATERS (1 << 11)
#define HORNY_MOB_TYPE_ALL (HORNY_MOB_TYPE_HUMANOIDS | HORNY_MOB_TYPE_SPIDERS | HORNY_MOB_TYPE_BOG_BUGS | HORNY_MOB_TYPE_TROLLS | HORNY_MOB_TYPE_BEASTS | HORNY_MOB_TYPE_LAMIAS | HORNY_MOB_TYPE_MINOTAURS | HORNY_MOB_TYPE_LYCANS | HORNY_MOB_TYPE_LIZARDS | HORNY_MOB_TYPE_UNDEAD | HORNY_MOB_TYPE_TENTACLES | HORNY_MOB_TYPE_MANEATERS)

#define MAGE_HAND_ZONE_GROIN "groin"
#define MAGE_HAND_ZONE_CHEST "chest"
#define MAGE_HAND_ZONE_BUTT "butt"
#define MAGE_HAND_ZONE_MOUTH "mouth"
#define MAGE_HAND_ZONE_BODY "body"

/// Bind zones. Unlike the zones above these are conjured by hand, not driven by a running action.
#define MAGE_HAND_ZONE_ARMS "arms"
#define MAGE_HAND_ZONE_LEGS "legs"
#define MAGE_HAND_ZONE_EYES "eyes"

/// Every Mage Hand mob overlay lives here, stated like worn clothing.
#define MAGE_HAND_OVERLAY_ICON 'modular_rmh/icons/mob/overlays/mage_hands.dmi'
/// Blindness source held by a conjured blindfold.
#define MAGE_HAND_BLIND_TRAIT "mage_hand_blindfold"
/// 25% transparent, so the hands read as conjured rather than solid.
#define MAGE_HAND_OVERLAY_ALPHA 190

/// Mage Hand zone to icon_state suffix. A zone missing from this list draws nothing.
GLOBAL_LIST_INIT(mage_hand_zone_sprites, list(
	MAGE_HAND_ZONE_GROIN = "masturbate",
	MAGE_HAND_ZONE_CHEST = "tittwister",
	MAGE_HAND_ZONE_BUTT = "cheekslap",
	MAGE_HAND_ZONE_MOUTH = "blindfold",
	MAGE_HAND_ZONE_BODY = "tittwister",
	MAGE_HAND_ZONE_ARMS = "shacklesup",
	MAGE_HAND_ZONE_LEGS = "shacklesdown",
	MAGE_HAND_ZONE_EYES = "blindfold",
))

/// Deciseconds each `start_` state runs before handing off to its looping state. Must equal the sheet's summed frame delays.
GLOBAL_LIST_INIT(mage_hand_start_durations, list(
	"masturbate" = 9,
	"tittwister" = 12,
	"cheekslap" = 12,
	"blindfold" = 9,
	"shacklesup" = 9,
	"shacklesdown" = 9,
))

/// Clench roll outcomes, ordered worst to best for the clencher.
#define CLENCH_RESULT_FAIL 0
#define CLENCH_RESULT_INTERRUPT 1
#define CLENCH_RESULT_STOP 2

/// Arcane chastity front modes: which front openings the device leaves open.
#define CHASTITY_FRONT_SEALED 0
#define CHASTITY_FRONT_PENIS 1
#define CHASTITY_FRONT_VAGINA 2
#define CHASTITY_FRONT_ALL 3

/// Directory holding the chastity message banks.
#define CHASTITY_STRINGS_DIR "strings/chastity"
/// A random line from a chastity message bank.
#define pick_chastity_string(FILE, KEY) (pick(strings(FILE, KEY, CHASTITY_STRINGS_DIR)))

// Anal bead sizes; each /datum/bead_shape lists them from tip to ring.
#define BEAD_SMALL 1
#define BEAD_MEDIUM 2
#define BEAD_LARGE 3
#define BEAD_GIANT 4
/// Push results beyond the body-storage insert feedback.
#define BEADS_ALL_IN "beads_all_in"
#define BEADS_TOO_DEEP "beads_too_deep"
