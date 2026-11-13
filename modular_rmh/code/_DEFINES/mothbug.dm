#define ROLE_MOTHBUG "Mothbug"
#define FACTION_MOTHBUG "mothbug"

#define MOTHBUG_ADULT_MAX_CHARGE 100
#define MOTHBUG_ADULT_START_CHARGE 40
#define MOTHBUG_HATCHLING_MAX_CHARGE 40
#define MOTHBUG_HATCHLING_START_CHARGE 10

#define MOTHBUG_EAT_TIME (3 SECONDS)
#define MOTHBUG_HATCHLING_EAT_TIME (4 SECONDS)
#define MOTHBUG_NIBBLE_TIME (3 SECONDS)
#define MOTHBUG_TICKLE_TIME (2 SECONDS)
/// Health restored per bite of fabric.
#define MOTHBUG_BITE_HEAL 2

/// Fabric value of a whole item, before material and eater multipliers.
#define MOTHBUG_VALUE_SCRAP 4
#define MOTHBUG_VALUE_SILK_PIECE 6
#define MOTHBUG_VALUE_SMALL_CLOTHING 8
#define MOTHBUG_VALUE_CLOTHING 12
#define MOTHBUG_VALUE_BULKY_CLOTHING 18
#define MOTHBUG_VALUE_BEDSHEET 15
/// Curtains, banners, carpets and tent cloth.
#define MOTHBUG_VALUE_CLOTH_STRUCTURE 20
#define MOTHBUG_STRUCTURE_BITES 4
#define MOTHBUG_CLOSET_TIME (1.5 SECONDS)
#define MOTHBUG_COST_SQUEEZE 20
#define MOTHBUG_SQUEEZE_TIME (4 SECONDS)

/// Hide needs a turf darker than this unless something covers the mothbug.
#define MOTHBUG_HIDE_MAX_LIGHT 0.3
#define MOTHBUG_HIDDEN_ALPHA 40

#define MOTHBUG_COST_WEB 2
#define MOTHBUG_COST_SNARE 15
#define MOTHBUG_COST_BIND 20
#define MOTHBUG_COST_COCOON 35
#define MOTHBUG_COST_DUST 15
#define MOTHBUG_MAX_SNARES 16

#define MOTHBUG_WEB_TIME (3 SECONDS)
#define MOTHBUG_SNARE_TIME (3 SECONDS)
#define MOTHBUG_BIND_TIME (4 SECONDS)
#define MOTHBUG_COCOON_TIME (6 SECONDS)
#define MOTHBUG_COCOON_BREAKOUT (90 SECONDS)
#define MOTHBUG_COCOON_CUT_TIME (5 SECONDS)
#define MOTHBUG_COCOON_DIGEST_INTERVAL (20 SECONDS)
#define MOTHBUG_DUST_BLUR (8 SECONDS)

/// Move delays; mothbugs ignore walk and run, so these are their whole speed. Humans run at 2.
#define MOTHBUG_GROUND_SPEED 2.5
#define MOTHBUG_HATCHLING_SPEED 3.5
#define MOTHBUG_FLIGHT_SPEED 2
#define MOTHBUG_TAKEOFF_TIME (2 SECONDS)
#define MOTHBUG_LAND_TIME (1 SECONDS)
#define MOTHBUG_FLIGHT_TRAIT "mothbug_flight"
#define MOVESPEED_ID_MOTHBUG_FLIGHT "mothbug_flight"

#define MOTHBUG_COST_EGG 40
#define MOTHBUG_EGG_LAY_TIME (5 SECONDS)
#define MOTHBUG_EGG_INCUBATION (6 MINUTES)
#define MOTHBUG_EGG_POLL_TIME (30 SECONDS)
/// Wait before asking again when nobody answered a hatch poll.
#define MOTHBUG_EGG_REPOLL (3 MINUTES)
/// Starting silk of a hatchling from an egg carried inside a host.
#define MOTHBUG_WELL_FED_CHARGE 20
#define MOTHBUG_COLONY_BASE_CAP 3
#define MOTHBUG_COLONY_PLAYERS_PER_SLOT 15
#define MOTHBUG_COLONY_MAX_CAP 8
#define MOTHBUG_PUPATE_FABRIC 120
#define MOTHBUG_PUPATE_MIN_AGE (15 MINUTES)
#define MOTHBUG_PUPATE_SPIN_TIME (3 SECONDS)
#define MOTHBUG_PUPA_TIME (2 MINUTES)
#define MOTHBUG_PUPATE_CHARGE 30

#define MOTHBUG_COST_ERP_EGG 30
/// Each of the four host incubation stages; four stages make six minutes.
#define MOTHBUG_HOST_EGG_STAGE (90 SECONDS)
/// A host-born egg is nearly ready, so it ripens fast.
#define MOTHBUG_WELL_FED_INCUBATION (30 SECONDS)

/// Adult mothbugs the infestation event tries to spawn.
#define MOTHBUG_EVENT_SPAWNS 2
#define MOTHBUG_SPAWN_MAX_LIGHT 0.2
/// Colony silk eaten before the town gets its first hint.
#define MOTHBUG_OMEN_THRESHOLD 300
#define MOTHBUG_FEAST_GOAL 600
#define MOTHBUG_BROOD_GOAL 5
/// Turf light that exposes a mothbug hiding out in the open.
#define MOTHBUG_REVEAL_LIGHT 0.5
#define MOTHBUG_LIGHT_REVEAL_RANGE 3
