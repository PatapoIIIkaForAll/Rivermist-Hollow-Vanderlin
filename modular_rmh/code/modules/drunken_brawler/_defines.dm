#define DRUNKEN_RAGE_BLUR_FILTER "drunken_rage_blur"
#define DRUNKEN_RAGE_GLOW_FILTER "drunken_rage_glow"
#define DRUNKEN_RAGE_HIGHLIGHT_FILTER "drunken_rage_highlight"
#define DRUNKEN_BRAWLER_DRINK_THRESHOLD 10
#define DRUNKEN_BRAWLER_SOBER_TIMER (90 SECONDS)

GLOBAL_LIST_INIT(tavern_areas, list(
	/area/indoors/town/tavern,
	/area/indoors/town/rmh/tavern,
	/area/outdoors/exposed/tavern,
	/area/indoors/wilderness/tavern,
))

/proc/is_tavern_area(area/A)
	if(!A)
		return FALSE
	for(var/tavern_type in GLOB.tavern_areas)
		if(istype(A, tavern_type))
			return TRUE
	return FALSE
