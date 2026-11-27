#define MEAT 		(1<<0)
#define VEGETABLES 	(1<<1)
#define RAW 		(1<<2)
#define JUNKFOOD 	(1<<3)
#define GRAIN 		(1<<4)
#define FRUIT 		(1<<5)
#define DAIRY 		(1<<6)
#define FRIED 		(1<<7)
#define ALCOHOL 	(1<<8)
#define SUGAR 		(1<<9)
#define GROSS 		(1<<10)
#define TOXIC 		(1<<11)
#define PINEAPPLE	(1<<12)
#define BREAKFAST	(1<<13)
#define CLOTH 		(1<<14)
#define MUSHROOM    (1<<15)
#define EGG			(1<<16)


#define FOOD_FLAGS_IC list( \
	"Meat", \
	"Vegetables", \
	"Raw food", \
	"Junk food", \
	"Grain", \
	"Fruits", \
	"Dairy products", \
	"Fried food", \
	"Alcohol", \
	"Sugary food", \
	"Gross food", \
	"Toxic food", \
	"Pineapples", \
	"Breakfast food", \
	"Clothing", \
	"Eggs", \
)

#define DRINK_NICE	1
#define DRINK_GOOD	2
#define DRINK_VERYGOOD	3
#define DRINK_FANTASTIC	4
#define FOOD_AMAZING 5

#define FARE_IMPOVERISHED 1
#define FARE_POOR 2
#define FARE_NEUTRAL 3
#define FARE_FINE 4
#define FARE_LAVISH 5

#define CULINARY_FAVOURITE_FOOD "Favourite Food"
#define CULINARY_FAVOURITE_DRINK "Favourite Drink"
#define CULINARY_HATED_FOOD "Hated Food"
#define CULINARY_HATED_DRINK "Hated Drink"
#define CULINARY_RANDOM_PREFERENCES "Random Preferences"
#define FAVOURITE_FOOD_TRIUMPH "Favourite Food Triumph"
#define FAVOURITE_DRINK_TRIUMPH "Favourite Drink Triumph"

/// Lowest fare a food needs to count as a favourite. Hated food counts at any fare.
#define FAVOURITE_FOOD_MINFARE FARE_NEUTRAL
/// Lowest quality a drink needs to count as a favourite. Hated drinks count at any quality.
#define FAVOURITE_DRINK_MINQUALITY 0
/// Drink types that count as a favourite at any quality.
#define FAVOURITE_DRINK_ANY_QUALITY DRINKTYPE_MILK

// Dish groups (snacks dish_type). Bits run from ingredient to finished dish; old saves map to the highest bit.
#define DISH_VEGETABLE	(1<<0)
#define DISH_FRUIT		(1<<1)
#define DISH_MEAT		(1<<2)
#define DISH_POULTRY	(1<<3)
#define DISH_SEAFOOD	(1<<4)
#define DISH_EGG		(1<<5)
#define DISH_DAIRY		(1<<6)
#define DISH_BREAD		(1<<7)
#define DISH_PASTRY		(1<<8)
#define DISH_PIE		(1<<9)
#define DISH_SWEET		(1<<10)
#define DISH_SOUP		(1<<11)

// Drink types (consumable reagent drink_type).
#define DRINKTYPE_MILK		(1<<0)
#define DRINKTYPE_TEA		(1<<1)
#define DRINKTYPE_ALE		(1<<2)
#define DRINKTYPE_CIDER		(1<<3)
#define DRINKTYPE_MEAD		(1<<4)
#define DRINKTYPE_WINE		(1<<5)
#define DRINKTYPE_SPIRIT	(1<<6)
