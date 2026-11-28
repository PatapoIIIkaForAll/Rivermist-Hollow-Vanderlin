#define MUSK_LEVEL_MAX 4
#define MUSK_LEVEL_COST_MIN_PERCENT 45
#define MUSK_LEVEL_COST_MAX_PERCENT 55
#define MUSK_LEVEL_FADE_TIME (15 MINUTES)
#define MUSK_AURA_INTERVAL (3 SECONDS)
#define MUSK_SCENT_RANGE 1
#define MUSK_TRAIL_LENGTH 4
#define MUSK_TRAIL_TIME (30 SECONDS)
#define MUSK_INTELLIGENCE_PENALTY_BY_LEVEL list(1, 1, 2, 2)
#define MUSK_AROUSAL_FLOOR_BY_LEVEL list(5, 10, 15, 25)
#define MUSK_HAZE_DURATION (2 MINUTES)
#define MUSK_HAZE_CLIMAX_GRACE (15 MINUTES)
#define MUSK_HEAVY_LEVEL 3

#define MUSK_ZONE_ARMPITS "armpits"
#define MUSK_ZONE_GROIN "groin"
#define MUSK_ZONE_BUTT "butt"
#define MUSK_ZONE_FEET "feet"

#define MUSK_SWEAT_MAX_STACKS 4
#define MUSK_SWEAT_FEET_MAX_STACKS 6
#define MUSK_SWEAT_BARE_GAIN 1
#define MUSK_SWEAT_HAIRY_GAIN 2
#define MUSK_SWEAT_SHOD_GAIN 2

#define MUSK_QUALITY_BARE 1
#define MUSK_QUALITY_HAIRY 2
#define MUSK_QUALITY_VERY_HAIRY 3

#define MUSK_TIER_MAX 3

#define MUSK_LICK_AROUSAL_PER_STACK 20
#define MUSK_PRESS_TIME (5 SECONDS)
#define MUSK_PRESS_OXYLOSS 2
#define MUSK_PRESS_BURST_COOLDOWN (5 MINUTES)
/// Most climaxes one press can chain; more would stack orgasm strain into lasting debuffs.
#define MUSK_PRESS_MAX_CLIMAXES 2
#define MUSK_PRESS_BURST_TIMER "musk_press_burst"
#define MUSK_CLIMAX_CHAIN_DELAY (2.5 SECONDS)

#define MUSK_SCENT_PLEASANT "Pleasant"
#define MUSK_SCENT_NEUTRAL "Neutral"
#define MUSK_SCENT_FOUL "Foul"
#define MUSK_SCENT_QUALITIES list(MUSK_SCENT_PLEASANT, MUSK_SCENT_NEUTRAL, MUSK_SCENT_FOUL)
#define MUSK_PLEASANT_DIZZY_MULTIPLIER 0.5
#define MUSK_FOUL_DIZZY_MULTIPLIER 2
#define MUSK_FOUL_BLUR_PER_LEVEL (2 SECONDS)

#define MUSK_NOTE_NONE "None"
#define MUSK_NOTES list( \
	MUSK_NOTE_NONE, "Honey", "Milk", "Fresh Bread", "Apples", "Berries", "Wine", "Ale", "Cinnamon", "Cloves", "Mint", \
	"Roses", "Lavender", "Meadow Grass", "Pine Resin", "Moss", "Rain", "Sea Salt", "Iron", "Leather", "Woodsmoke", \
	"Incense", "Old Books", "Tar", "Wet Fur", "Stables", "Ripe Cheese", "Vinegar", "Onions", "Bog Mud", "Wildflowers", \
	"Dried Flowers", "Violets", "Lilac", "Jasmine", "Lilies", "Lily of the Valley", "Peonies", "Tulips", "Irises", \
	"Hyacinths", "Cornflowers", "Poppies", "Daisies", "Dandelions", "Sunflowers", "Marigolds", "Chamomile", "Clover", \
	"Heather", "Honeysuckle", "Water Lilies", "Elderflower", "Linden Blossom", "Apple Blossom", "Cherry Blossom", \
	"Paper", "Parchment", "Ink", "Sealing Wax", "Candle Wax", "Beeswax", "Chalk", "Dust", "Feathers", "Linen", "Cotton", \
	"Wool", "Silk", "Fresh Laundry", "Soap", "Rope", "Lamp Oil", "Linseed Oil", "Paint", "Varnish", "Clay", "Brick", \
	"Wet Stone", "Sand", "Coal", "Ash", "Copper", "Silver", "Amber", "Sawdust", "Cedar", "Oak", "Birch", "Juniper", \
	"Sandalwood", "Willow Bark", "Pine Needles", "Dry Leaves", "Ferns", "Mushrooms", "Damp Earth", "Hay", "Straw", \
	"Grain", "Flour", "Hops", "Snow", "Frost", "Thunderstorm", "Morning Dew", "Mist", "River Water", "Seaweed", "Thyme", \
	"Sage", "Rosemary", "Basil", "Dill", "Bay Leaf", "Wormwood", "Tea", "Pipe Tobacco", "Pepper", "Nutmeg", "Ginger", \
	"Anise", "Caraway", "Saffron", "Vanilla", "Almonds", "Walnuts", "Chestnuts", "Butter", "Pears", "Plums", "Cherries", \
	"Grapes", "Lemon", "Oranges", "Cucumber", "Myrrh" \
)

#define MUSK_CONTACT_DURATION (1 MINUTES)
#define MUSK_CONTACT_LINE_CHANCE 60
#define MUSK_LINE_SMELL "smell"
#define MUSK_LINE_NOTES "notes"
#define MUSK_LINE_HAZE "haze"
#define MUSK_LINE_TASTE "taste"
#define MUSK_LINE_BOND "bond"

#define MUSK_WIPE_HYGIENE 25
#define MUSK_SMEAR_MAX_STACKS 6
#define MUSK_SMEAR_FADE_TIME (5 MINUTES)

#define MUSK_FLUID_SWEAT "sweat"
#define MUSK_SLIP_AMOUNT 5
#define MUSK_SLIP_MIN_AMOUNT 1
#define MUSK_SLIP_TIME (4 SECONDS)
#define MUSK_SLIP_SIGHT_RANGE 1
