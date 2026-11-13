// Buildmode HUD panel states
#define BM_SWITCHSTATE_NONE 0
#define BM_SWITCHSTATE_MODE 1
#define BM_SWITCHSTATE_DIR 2

// Item browser categories
#define BM_CATEGORY_TURF 1
#define BM_CATEGORY_OBJ 2
#define BM_CATEGORY_MOB 3
#define BM_CATEGORY_ITEM 4
#define BM_CATEGORY_WEAPON 5
#define BM_CATEGORY_CLOTHING 6
#define BM_CATEGORY_FOOD 7
#define BM_CATEGORY_REAGENT_CONTAINERS 8

/// Entries per item browser page; each entry is one icon request on the client.
#define BM_ITEMS_PER_PAGE 60
/// Longest accepted item browser search text.
#define BM_SEARCH_MAX_LENGTH 100
/// Window id of the item browser popup.
#define BM_BROWSER_WINDOW "buildmode_browser"
