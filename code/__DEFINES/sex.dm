GLOBAL_LIST_INIT(sex_actions, build_sex_actions())

GLOBAL_LIST_EMPTY(sex_sessions)
GLOBAL_LIST_EMPTY(sex_collectives)
GLOBAL_VAR_INIT(collective_counter, 1)
GLOBAL_LIST_EMPTY(locked_sex_objects)

#define SEX_ACTION(sex_action_type) GLOB.sex_actions[sex_action_type]


#define COMSIG_SEX_ADJUST_AROUSAL "sex_adjust_arousal"                  // (amount) - Adjust arousal level
#define COMSIG_SEX_SET_AROUSAL "sex_set_arousal"                        // (amount) - Set arousal to specific value
#define COMSIG_SEX_AROUSAL_CHANGED "sex_arosual_change"					// fires to the parent about a change
#define COMSIG_SEX_FREEZE_AROUSAL "sex_freeze_arousal"                  // (freeze_state) - Toggle arousal freeze
#define COMSIG_SEX_GET_AROUSAL "sex_get_arousal"                        // () - Get current arousal info
#define COMSIG_SEX_CLIMAX "sex_climax"                                  // (type, target) - Handle climax event
#define COMSIG_SEX_RECEIVE_ACTION "sex_receive_action"                  // (arousal_amt, pain_amt, giving, force, speed) - Receive action effects
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
/// Attempts to knot a target. Args: (target, force_level)
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

#define BODYSTORAGE_REMOVE_MANUAL "manual"
#define BODYSTORAGE_REMOVE_RANDOM "random"
#define BODYSTORAGE_REMOVE_INTERNAL "internal"

#define SEX_SPEED_LOW 1
#define SEX_SPEED_MID 2
#define SEX_SPEED_HIGH 3
#define SEX_SPEED_EXTREME 4

#define SEX_SPEEDS list(SEX_SPEED_LOW, SEX_SPEED_MID, SEX_SPEED_HIGH, SEX_SPEED_EXTREME)

#define SEX_SPEED_MIN 1
#define SEX_SPEED_MAX 4

#define SEX_FORCE_LOW 1
#define SEX_FORCE_MID 2
#define SEX_FORCE_HIGH 3
#define SEX_FORCE_EXTREME 4

#define SEX_FORCES list(SEX_FORCE_LOW, SEX_FORCE_MID, SEX_FORCE_HIGH, SEX_FORCE_EXTREME)

#define SEX_FORCE_MIN 1
#define SEX_FORCE_MAX 4

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

#define LOW_ORGASM_THRESHOLD_GAIN 4
#define MED_ORGASM_THRESHOLD_GAIN 6
#define HIGH_ORGASM_THRESHOLD_GAIN 11
#define OVER_THE_TOP_ORGASM_THRESHOLD_GAIN 16

#define LOW_ORGASM_THRESHOLD_LOSS 3
#define MED_ORGASM_THRESHOLD_LOSS 4
#define HIGH_ORGASM_THRESHOLD_LOSS 7
#define OVER_THE_TOP_ORGASM_THRESHOLD_LOSS 12

#define ORGASM_RESET_TIME (2 MINUTES)
#define ORGASM_COOLDOWN_TIME (10 SECONDS)
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
#define LOINHURT_LOSE_THRESHOLD 20

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

/proc/build_sex_actions()
	. = list()
	for(var/datum/path as anything in typesof(/datum/sex_action))
		if(IS_ABSTRACT(path))
			continue
		.[path] = new path()
	return .


#define SUBTLE_TAG (1 << 0)
#define SUBTLE_ALL (1 << 1)
#define SUBTLE_NOGHOST (1 << 2)
#define SUBTLE_SHORT (1 << 3)

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

#define DEFAULT_BUTT_SIZE BUTT_SIZE_FLAT
#define MIN_BUTT_SIZE BUTT_SIZE_SMALL
#define MAX_BUTT_SIZE BUTT_SIZE_LARGE //5 available, above 4 may be too big.
#define TOTAL_BUTT_SIZE 3


#define DRAW_ABOVE "draw_above" //for drawing organs above the clothes

#define HORNY_MOBS_TAG_MALES (1 << 0)
#define HORNY_MOBS_TAG_FEMALES (1 << 1)
