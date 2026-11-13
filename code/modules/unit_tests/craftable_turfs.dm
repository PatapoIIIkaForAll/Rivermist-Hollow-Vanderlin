/datum/unit_test/turf_coverage
#ifdef FOCUS_TURF_COVERAGE
	focus = TRUE
#endif

/datum/unit_test/turf_coverage/Run()
	var/list/all_turfs = subtypesof(/turf)
	var/list/all_blueprint_recipes = subtypesof(/datum/blueprint_recipe)
	var/list/used_turfs = list()

	for(var/recipe_type in all_blueprint_recipes)
		var/datum/blueprint_recipe/recipe = new recipe_type()
		if(recipe.result_type && ispath(recipe.result_type, /turf))
			used_turfs |= recipe.result_type
		qdel(recipe)

	var/list/blacklisted_turfs = list(
		/turf/closed,
		/turf/closed/splashscreen,
		/turf/open/floor,
		/turf/open,
		/turf/open/floor/grass/hell,
		/turf/open/floor/grass/eora,
		/turf/open/floor/dirt/ambush,
		/turf/open/floor/cobble/snow,
		/turf/open/floor/volcanic,
		/turf/open/floor/blocks/snow,
		/turf/open/openspace,
		/turf/baseturf_skipover,
		/turf/baseturf_bottom,
		/turf/closed/basic,
		/turf/open/floor/cobblerock/snow,
		/turf/open/floor/plasteel,
		/turf/open/floor/naturalstone,
		/turf/open/floor/plank/h,
		/turf/open/floor/plank,
		/turf/closed/wall,
		/turf/open/floor/sandstone,
		/turf/closed/dungeon_void,
		/turf/closed/sea_fog,
		/turf/template_noop,
		/turf/closed/wall/mineral/underbrick/fake_world,
		/turf/closed/wall/mineral,
		/turf/closed/wall/mineral/stonebrick/reddish,
		/turf/closed/wall/mineral/decostone/cand/reddish,
		/obj/structure/stairs/stone/reddish,
		/turf/closed/wall/mineral/roofwall,
		/turf/closed/wall/mineral/abyssal,
		/turf/closed/wall/mineral/desert_soapstone,
		/turf/open/floor/cracked_earth,
		/turf/open/floor/flesh,
		/turf/open/dungeon_trap,
		/turf/open/floor/blocks/carved,
		/turf/open/floor/churchmarble/purple,
		/turf/open/floor/churchmarble/violet,
		/turf/open/floor/churchmarble/rust,
		/turf/open/floor/churchmarble/pale,
		/turf/open/floor/churchmarble/gold,
		/turf/open/floor/churchmarble/green,
		/turf/open/floor/church/violet,
		/turf/open/floor/church/rust,
		/turf/open/floor/church/pale,
		/turf/open/floor/church/gold,
		/turf/open/floor/church/green,
		/turf/open/floor/churchrough/violet,
		/turf/open/floor/churchrough/rust,
		/turf/open/floor/churchrough/pale,
		/turf/open/floor/churchrough/gold,
		/turf/open/floor/churchrough/green,
		/turf/closed/wall/mineral/decostone/long/east_west,
		/turf/closed/wall/mineral/pipe/line,
		/turf/closed/wall/mineral/pipe/joint,
		/turf/closed/wall/mineral/pipe/joint/four,
		/turf/closed/wall/mineral/brick,
		/turf/open/floor/ruinedwood/herringbone,
		/turf/open/floor/ruinedwood/herringbone_clear,
		/turf/open/floor/tile/harem,
		/turf/open/floor/tile/harem1,
		/turf/open/floor/tile/harem2,
		/turf/open/floor/rooftop/green/north,
		/turf/open/floor/rooftop/green/east,
		/turf/open/floor/rooftop/green/west,
		/turf/open/floor/rooftop/green/corner1,
		/turf/open/floor/dirt/road/snowy,
		/turf/open/floor/snowpath,
		/turf/open/floor/snowpath/snowcorner,
		/turf/open/floor/snowpath/snowpatht,
		/turf/open/floor/snowpath/snowpathx,
		/turf/open/floor/dirt/snowy,
		/turf/open/floor/AzureSand,
		/turf/open/floor/dark_ice,
		/turf/open/floor/desert, // implicit parent for desert floor variants
		/turf/open/floor/desert_grass, // legacy branch; the buildable scrub grass is /turf/open/floor/desert/desert_grass
		/turf/open/floor/desert_grass/nospawn, // legacy branch; the buildable scrub grass is /turf/open/floor/desert/desert_grass
		/turf/open/floor, //alizeria-build
		/turf/open/floor/ruinedwood, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood1, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood2, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood3, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood4, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood5, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood6, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood7, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/carpet1, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood8, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood9, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood10, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood19, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood20, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood21, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood22, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood23, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood24, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood25, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood26, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood27, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood28, //alizeria-build
		/turf/open/floor/ruinedwood/alizeria/tiles/wood29, //alizeria-build
		/turf/open/floor/tile, //alizeria-build
		/turf/open/floor/tile/alizeria, //alizeria-build
		/turf/open/floor/tile/alizeria/tiles, //alizeria-build
		/turf/open/floor/tile/alizeria/tiles/stonefloor1, //alizeria-build
		/turf/open/floor/tile/alizeria/tiles/stonefloor2, //alizeria-build
		/turf/open/floor/tile/alizeria/tiles/stonefloor3, //alizeria-build
		/turf/open/floor/tile/alizeria/tiles/stonefloor4, //alizeria-build
		/turf/open/floor/desert/deserttile/tilegreywhite,
		/turf/open/floor/desert/deserttile/tiledrab2,
		/turf/open/floor/desert/deserttile/tilewhitegreen,
		/turf/open/floor/desert/deserttile/tilewhiteblue,
		/turf/open/floor/desert/deserttile/tilewhitebluespecial,
		/turf/open/floor/desert/deserttile/tilespecial,
		/turf/open/floor/desert/deserttile/tilegreeny,
		/turf/open/floor/desert/deserttile/tilegreyblu
	) \
	+ typesof(/turf/open/floor/mushroom) \
	+ typesof(/turf/open/floor/sandstone_tile) \
	+ typesof(/turf/open/floor/abyss_sand) \
	+ typesof(/turf/open/floor/sand) \
	+ typesof(/turf/open/floor/abyss_tile) \
	+ typesof(/turf/closed/indestructible) \
	+ typesof(/turf/closed/wall/mineral/decostone/fluffstone) \
	+ typesof(/turf/open/floor/plasteel/maniac) \
	+ typesof(/turf/closed/mineral) \
	+ typesof(/turf/open/floor/underworld) \
	+ typesof(/turf/open/floor/snow) \
	+ typesof(/turf/open/floor/woodturned/nosmooth) \
	+ typesof(/turf/open/floor/wood/nosmooth) \
	+ typesof(/turf/open/water) \
	+ typesof(/turf/open/lava) \
	+ typesof(/turf/open/floor/carpet) \
	+ typesof(/turf/closed/wall/mineral/desert_sandstone) \
	+ typesof(/turf/open/floor/maneater_stomach) \
	+ typesof(/turf/open/floor/crawl_space) //mapper-placed tunnels, nothing builds them
	used_turfs |= blacklisted_turfs

	// Find unused turfs
	var/list/unused_turfs = list()
	for(var/turf_type in all_turfs)
		if(!(turf_type in used_turfs))
			unused_turfs += turf_type

	var/unused_list = ""
	for(var/i = 1; i <= unused_turfs.len; i++)
		unused_list += "[unused_turfs[i]]"
		if(i < unused_turfs.len)
			unused_list += ", "

	TEST_ASSERT(!length(unused_turfs), "The following turfs are not used by any blueprint recipe or in the blacklist: [unused_list]")
