///Hostile AI controller blackboard keys
#define BB_HOSTILE_ORDER_MODE "BB_HOSTILE_ORDER_MODE"
#define BB_HOSTILE_FRIEND "BB_HOSTILE_FRIEND"
#define BB_HOSTILE_ATTACK_WORD "BB_HOSTILE_ATTACK_WORD"
#define BB_FOLLOW_TARGET "BB_FOLLOW_TARGET"
#define BB_ATTACK_TARGET "BB_ATTACK_TARGET"
#define BB_VISION_RANGE "BB_VISION_RANGE"

/// Basically, what is our vision/hearing range.
#define BB_HOSTILE_VISION_RANGE 10
/// After either being given a verbal order or a pointing order, ignore further of each for this duration
#define AI_HOSTILE_COMMAND_COOLDOWN (2 SECONDS)

// hostile command modes (what pointing at something/someone does depending on the last order the carp heard)
/// Don't do anything (will still react to stuff around them though)
#define HOSTILE_COMMAND_NONE 0
/// Will attack a target.
#define HOSTILE_COMMAND_ATTACK 1
/// Will follow a target.
#define HOSTILE_COMMAND_FOLLOW 2

#define COMMAND_FOLLOW "Follow"
#define COMMAND_STOP "Stop"
#define COMMAND_ATTACK "Attack"


//Hunting defines
#define SUCCESFUL_HUNT_COOLDOWN 5 SECONDS

///Hunting BB keys
#define BB_CURRENT_HUNTING_TARGET "BB_current_hunting_target"
#define BB_HUNTING_COOLDOWN "BB_HUNTING_COOLDOWN"

///Basic Mob Keys

///Tipped blackboards
///Bool that means a basic mob will start reacting to being tipped in it's planning
#define BB_BASIC_MOB_TIP_REACTING "BB_basic_tip_reacting"
///the motherfucker who tipped us
#define BB_BASIC_MOB_TIPPER "BB_basic_tip_tipper"

///Targetting subtrees
#define BB_TARGETED_ACTION "BB_targeted_action"
#define BB_BASIC_MOB_PRIORITY_TARGETS "BB_basic_priority_targets"
#define BB_BASIC_MOB_CURRENT_TARGET "BB_basic_current_target"
#define BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION "BB_basic_current_target_hiding_location"
/// A defeated victim this mob is moving to haul off to its lair (defeat kidnapping).
#define BB_KIDNAP_TARGET "BB_kidnap_target"
#define BB_TARGETTING_DATUM "targetting_datum"
#define BB_BASIC_MOB_FOOD_TARGET "BB_basic_food_target"
#define BB_TARGETTING_DATUM_EQUIPMENT "equip_targetting_datum"
#define BB_BASIC_MOB_RUN_WITH_ITEM "BB_run_with_item"
#define BB_BASIC_MOB_EQUIPMENT_TARGET "BB_equipment_target"
#define BB_BASIC_MOB_NEED_EQUIP "BB_needs_to_equip"
#define BB_BASIC_MOB_UNEQUIPPED_WEAPON "BB_unequipped_weapon"
/// Key for the minimum status at which we want to target mobs (does not need to be specified if CONSCIOUS)
#define BB_TARGET_MINIMUM_STAT "BB_target_minimum_stat"
/// Flag for whether to target only wounded mobs
#define BB_TARGET_WOUNDED_ONLY "BB_target_wounded_only"
/// What typepath the holding object targeting strategy should look for
#define BB_TARGET_HELD_ITEM "BB_target_held_item"

///list of foods this mob likes
#define BB_BASIC_FOODS "BB_basic_foods"
///What creature we want to cocoon
#define BB_BASIC_MOB_COCOON_TARGET "BB_basic_mob_cocoon_target"
/// The partner a spider just came with; only they may be wrapped while merely yielding.
#define BB_SPIDER_SATED_WITH "BB_spider_sated_with"
/// The unsealed cocoon a spider walks to and lays its eggs into.
#define BB_SPIDER_BROOD_COCOON "BB_spider_brood_cocoon"
/// world.time the brood began; the walk gives up after a while.
#define BB_SPIDER_BROOD_SINCE "BB_spider_brood_since"
/// world.time the spider parted the silk; a climax after it ends the brood.
#define BB_SPIDER_BROOD_OPENED_AT "BB_spider_brood_opened_at"
/// The lay act last started, and the eggs stored just before it.
#define BB_SPIDER_BROOD_LAST_ACT "BB_spider_brood_last_act"
#define BB_SPIDER_BROOD_EGGS_BEFORE "BB_spider_brood_eggs_before"
/// Lay acts that took no egg this brood; they are not tried again.
#define BB_SPIDER_BROOD_REFUSED "BB_spider_brood_refused"
/// The occupied cocoon a spider keeps away from, and the world.time that ends.
#define BB_SPIDER_SHUNNED_COCOON "BB_spider_shunned_cocoon"
#define BB_SPIDER_SHUNNED_UNTIL "BB_spider_shunned_until"
/// world.time until a spider that cannot leave its cocoon makes no idle noise.
#define BB_SPIDER_HUSHED_UNTIL "BB_spider_hushed_until"
/// The turf a spider walks to away from a cocoon, and the world.time it first set out.
#define BB_SPIDER_DISPERSE_TURF "BB_spider_disperse_turf"
#define BB_SPIDER_DISPERSE_SINCE "BB_spider_disperse_since"
/// world.time of the hunter's last web spit; a fall on the web soon after presents the target.
#define BB_HORNY_WEB_SPAT_AT "BB_horny_web_spat_at"
/// world.time until which a webbed, fallen target lies presented: the bear-down needs no roll.
#define BB_HORNY_PRESENTED_UNTIL "BB_horny_presented_until"

/// Flag to set on or off if you want your mob to prioritise running away
#define BB_BASIC_MOB_FLEEING "BB_basic_fleeing"
#define BB_BASIC_MOB_NEXT_FLEEING "BB_nex_flee"

///List of mobs who have damaged us
#define BB_BASIC_MOB_RETALIATE_LIST "BB_basic_mob_shitlist"

#define BB_GATOR_IN_WATER "BB_gator_in_water"
#define BB_GATOR_AMBUSH_COOLDOWN "BB_gator_ambush_cooldown"
#define BB_GATOR_DEATH_ROLL_COOLDOWN "BB_gator_death_roll_cooldown"
#define BB_GATOR_PREFERRED_TERRITORY "BB_gator_preferred_territory"

/// Key the bramblesnout's charge action is stored under. Lives here rather than
/// beside the action so the boar and the action can be included in any order.
#define BB_BOAR_CHARGE "bb_boar_charge"

#define BB_DRAGON_ENRAGED "dragon_enraged"
#define BB_DRAGON_SWOOPING "dragon_swooping"
#define BB_DRAGON_RECOVERY_TIME "dragon_recovery_time"
#define BB_DRAGON_ANGER_MODIFIER "dragon_anger_modifier"
#define BB_DRAGON_ATTACK_TYPE "dragon_attack_type"
#define BB_DRAGON_HEALTH_PERCENTAGE "dragon_health_percentage"
#define BB_DRAGON_CL_COOLDOWN "dragon_cl_cooldown"
#define BB_DRAGON_LIGHTNING_COOLDOWN "dragon_lightning_cooldown"
#define BB_DRAGON_SUMMON_COOLDOWN "dragon_summon_cooldown"
#define BB_DRAGON_SLAM_COOLDOWN "dragon_slam_cooldown"
#define BB_DRAGON_SPECIAL_COOLDOWN "dragon_special_cooldown"
#define BB_DRAGON_VOID_COOLDOWN "dragon_void_cooldown"
#define BB_DRAGON_CLONE_COOLDOWN "dragon_clone_cooldown"
#define BB_DRAGON_WING_COOLDOWN "dragon_wing_cooldown"
#define BB_DRAGON_EXPLOSION_COOLDOWN "dragon_explosion_cooldown"
#define BB_DRAGON_PHASE_COOLDOWN "dragon_ohase_cooldown"

#define BB_BASIC_MOB_SCARED_ITEM "scared_item"


#define BB_BASIC_MOB_CURRENT_HORNY_TARGET "BB_basic_current_horny_target"
/// Target a pet order pointed this mob at; while it is the horny target, it passes the ally gate.
#define BB_HORNY_DIRECTED_TARGET "BB_horny_directed_target"
#define BB_HORNY_AGGRO_TARGET "BB_horny_aggro_target"
#define BB_HORNY_HOSTILE_TARGETS "BB_horny_hostile_targets"
#define BB_HORNY_SEEK_COOLDOWN "BB_horny_seek_cooldown"
#define BB_HORNY_TIME_START "BB_horny_time_start"
#define BB_HORNY_INITIAL_STRIP_DONE "BB_horny_initial_strip_done"
#define BB_HORNY_STAND_UP_COUNTER "BB_horny_stand_up_counter"
#define BB_HORNY_ACTIONLESS_TICKS "BB_horny_actionless_ticks"
#define BB_HORNY_PORTAL_LIGHT "BB_horny_portal_light"
/// Hunt phase (HORNY_PHASE_*) and when it began.
#define BB_HORNY_PHASE "BB_horny_phase"
#define BB_HORNY_PHASE_SINCE "BB_horny_phase_since"
/// Temper 0-100 with its last decay stamp; lust 0-100 persists between hunts.
#define BB_HORNY_TEMPER "BB_horny_temper"
#define BB_HORNY_TEMPER_TIME "BB_horny_temper_time"
#define BB_HORNY_LUST "BB_horny_lust"
/// Damage the hunted target dealt this hunt; past the budget the hunt becomes a fight.
#define BB_HORNY_TARGET_DAMAGE "BB_horny_target_damage"
#define BB_HORNY_LAST_SEEN_TURF "BB_horny_last_seen_turf"
#define BB_HORNY_LAST_SEEN_TIME "BB_horny_last_seen_time"
#define BB_HORNY_CHASE_BEST_DISTANCE "BB_horny_chase_best_distance"
#define BB_HORNY_CHASE_GAIN_TIME "BB_horny_chase_gain_time"
#define BB_HORNY_RUSH_UNTIL "BB_horny_rush_until"
#define BB_HORNY_BASE_MOVE_DELAY "BB_horny_base_move_delay"
#define BB_HORNY_SPRINTING "BB_horny_sprinting"
#define BB_HORNY_BREAK_OFF_UNTIL "BB_horny_break_off_until"
#define BB_HORNY_BREAK_OFF_COOLDOWN "BB_horny_break_off_cooldown"
#define BB_HORNY_PRESENT_UNTIL "BB_horny_present_until"
#define BB_HORNY_POUNCE_COOLDOWN "BB_horny_pounce_cooldown"
#define BB_HORNY_LASH_COOLDOWN "BB_horny_lash_cooldown"
#define BB_HORNY_CIRCLE_UNTIL "BB_horny_circle_until"
#define BB_HORNY_SCENT_UNTIL "BB_horny_scent_until"
#define BB_HORNY_PACK_CALLED "BB_horny_pack_called"
#define BB_HORNY_TRAP_COOLDOWN "BB_horny_trap_cooldown"
/// Failed takedowns this catch; every miss makes the next body roll easier.
#define BB_HORNY_WRESTLE_PRESSURE "BB_horny_wrestle_pressure"
/// Set once the pin has landed on a floored target; cleared when the target is on their feet again.
#define BB_HORNY_PINNED "BB_horny_pinned"
/// world.time at which a knotted hunter lets its tie go; set once per tie.
#define BB_HORNY_TIE_UNTIL "BB_horny_tie_until"
/// world.time of the next tug beat while a knotted hunter is tied.
#define BB_HORNY_TIE_NEXT_TUG "BB_horny_tie_next_tug"
