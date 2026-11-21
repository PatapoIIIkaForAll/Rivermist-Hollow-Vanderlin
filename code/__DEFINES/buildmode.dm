// Buildmode HUD panel states
#define BM_SWITCHSTATE_NONE 0
#define BM_SWITCHSTATE_MODE 1
#define BM_SWITCHSTATE_DIR 2

// Spawn catalogue (item browser) limits
/// Cards per catalogue page.
#define BM_ITEMS_PER_PAGE 48
/// Longest accepted catalogue search text.
#define BM_SEARCH_MAX_LENGTH 100
/// Most favourites one admin can keep.
#define BM_MAX_FAVORITES 100
/// How many recently picked types are remembered.
#define BM_MAX_RECENT 24
/// Largest manual pixel offset, in either direction.
#define BM_MAX_OFFSET 32

// Basic mode tools: what a plain left click does. Modifier hotkeys work whatever tool is picked.
#define BM_TOOL_PLACE "place"
#define BM_TOOL_PIXEL "pixel"
#define BM_TOOL_AREA "area"
#define BM_TOOL_ERASE "erase"
#define BM_TOOL_COPY "copy"
#define BM_TOOL_PICK "pick"
#define BM_TOOL_DELETE "delete"

/// Area paint/erase over this many tiles asks for confirmation.
#define BM_AREA_CONFIRM_TILES 400
/// Area paint/erase over this many tiles is refused.
#define BM_AREA_MAX_TILES 4096
