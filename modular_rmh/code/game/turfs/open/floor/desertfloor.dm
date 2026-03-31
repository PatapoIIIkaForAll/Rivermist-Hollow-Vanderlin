/turf/open/floor/sand/desertsand
	name = "sand"
	desc = "Hot gold sand."
	icon_state = "sand-1"
	icon = 'modular_rmh/icons/turf/desert.dmi'
	layer = MID_TURF_LAYER
	heelstep = HEELSTEP_SAND
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 3

/turf/open/floor/sand/desertsand/Initialize()
	. = ..()
	var/random_num = rand(1, 2)
	icon_state = "sand-[random_num]"

/turf/open/floor/sand/sandbrick
	name = "sand brick"
	desc = "Brickwork made of sandstone. However, it is already practically weathered away."
	icon_state = "sandbrick-1"
	icon = 'modular_rmh/icons/turf/desert.dmi'
	layer = MID_TURF_LAYER
	heelstep = HEELSTEP_SAND
	footstep = FOOTSTEP_STONE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/stoneland.ogg'
	slowdown = 1

/turf/open/floor/sand/sandbrick/Initialize()
	. = ..()
	var/random_num = rand(1, 2)
	icon_state = "sandbrick-[random_num]"


/turf/open/floor/sand/desertsand/sandpath
	name = "sand road"
	desc = "Tamped sand. Looks like a path."
	icon_state = "sandpath-1"
	layer = MID_TURF_LAYER
	heelstep = HEELSTEP_SAND
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 0
	path_weight = 10

/turf/open/floor/sand/desertsand/sandpath/Initialize()
	. = ..()
	var/random_num = rand(1, 2)
	icon_state = "sandpath-[random_num]"

/turf/open/floor/sand/desertsand/oasis
	name = "wet sand"
	desc = "Dump sand."
	icon_state = "oasissand-1"
	layer = MID_TURF_LAYER
	heelstep = HEELSTEP_SAND
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 2

// ВЗЯТО С РАТВУДОВ - ПОТОМ МОЖНО БУДЕТ УДАЛИТЬ ПОСЛЕ НОРМАЛЬНОГО ДОБАВЛЕНИЯ

/turf/open/floor/sand/dunes
	name = "sand"
	desc = "Its course and rough, and it gets everywhere."
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	icon_state = "dune1"
	footstep = FOOTSTEP_SAND
	//barefootstep = FOOTSTEP_SAND
	//clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/dirtland.wav'
	//smooth = SMOOTH_TRUE
	//canSmoothWith = list(/turf/open/floor, /turf/closed/mineral, /turf/closed/wall/mineral)
	slowdown = 3

//turf/open/floor/sand/dunes/cardinal_smooth(adjacencies)
	//roguesmooth(adjacencies)

/turf/open/floor/sand/dunes/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	icon_state = "dune[rand(1,16)]"

/turf/open/floor/sand/dunes/sandbrick
	icon_state = "sand-brick1"
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	footstep = FOOTSTEP_STONE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/stoneland.wav'
	//smooth = SMOOTH_MORE
	//canSmoothWith = list(/turf/closed/mineral/rogue, /turf/closed/mineral, /turf/closed/wall/mineral/rogue/stonebrick, /turf/closed/wall/mineral/rogue/wood, /turf/closed/wall/mineral/rogue/wooddark, /turf/closed/wall/mineral/rogue/stone, /turf/closed/wall/mineral/rogue/stone/moss, /turf/open/floor/rogue/cobble, /turf/open/floor/rogue/dirt, /turf/open/floor/rogue/grass)
	damage_deflection = 10
	max_integrity = 1000
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')

//turf/open/floor/rogue/sandbrick/cardinal_smooth(adjacencies)
	//roguesmooth(adjacencies)

/turf/open/floor/sand/dunes/sandbrick/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	icon_state = "sand-brick[rand(1,4)]"

/turf/open/floor/sand/dunes/citybrick
	name = "sand bricks"
	icon_state = "city-brick1"
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	footstep = FOOTSTEP_STONE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/stoneland.wav'
	//smooth = SMOOTH_MORE
	//canSmoothWith = list(/turf/closed/mineral/rogue, /turf/closed/mineral, /turf/closed/wall/mineral/rogue/stonebrick, /turf/closed/wall/mineral/rogue/wood, /turf/closed/wall/mineral/rogue/wooddark, /turf/closed/wall/mineral/rogue/stone, /turf/closed/wall/mineral/rogue/stone/moss, /turf/open/floor/rogue/cobble, /turf/open/floor/rogue/dirt, /turf/open/floor/rogue/grass)
	damage_deflection = 10
	max_integrity = 1000
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
	abstract_type = /turf/open/floor/sand/dunes/citybrick

/turf/open/floor/sand/dunes/citybrick/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)

//turf/open/floor/rogue/citybrick/cardinal_smooth(adjacencies)
	//roguesmooth(adjacencies)

/turf/open/floor/sand/dunes/citybrick/citybrick1
	icon_state = "city-brick1-1"

/turf/open/floor/sand/dunes/citybrick/citybrick1/Initialize()
	. = ..()
	icon_state = "city-brick1-[rand(1,4)]"


/turf/open/floor/sand/dunes/citybrick/citybrick2
	icon_state = "city-brick2-1"

/turf/open/floor/sand/dunes/citybrick/citybrick2/Initialize()
	. = ..()
	icon_state = "city-brick2-[rand(1,5)]"


/turf/open/floor/sand/dunes/citybrick/citybrick3
	icon_state = "city-brick3-1" //this only has one variant


/turf/open/floor/sand/dunes/citybrick/citybrick4
	icon_state = "city-brick4-1"

/turf/open/floor/sand/dunes/citybrick/citybrick4/Initialize()
	. = ..()
	icon_state = "city-brick4-[rand(1,2)]"

/turf/open/floor/sand/dunes/citybrick/citybrick5
	icon_state = "city-brick5-1"

/turf/open/floor/sand/dunes/citybrick/citybrick5/Initialize()
	. = ..()
	icon_state = "city-brick5-[rand(1,2)]"


/turf/open/floor/sand/dunes/citybrick/citybrick6
	icon_state = "city-brick6-1"

/turf/open/floor/sand/dunes/citybrick/citybrick6/Initialize()
	. = ..()
	icon_state = "city-brick6-[rand(1,2)]"


/turf/open/floor/sand/dunes/lightpath
	icon_state = "light-path1"
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	//canSmoothWith = list(/turf/open/floor/rogue, /turf/closed/mineral, /turf/closed/wall/mineral)
	slowdown = 0
	footstep = FOOTSTEP_SAND
	//barefootstep = FOOTSTEP_SAND
	//clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	//smooth = SMOOTH_TRUE

//turf/open/floor/rogue/darkpath/cardinal_smooth(adjacencies)
	//roguesmooth(adjacencies)

/turf/open/floor/sand/dunes/lightpath/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	icon_state = "light-path[rand(1,8)]"


/turf/open/floor/sand/dunes/darkpath
	icon_state = "dark-path1"
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	//canSmoothWith = list(/turf/open/floor/rogue, /turf/closed/mineral, /turf/closed/wall/mineral)
	slowdown = 0
	footstep = FOOTSTEP_SAND
	//barefootstep = FOOTSTEP_SAND
	//clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	//smooth = SMOOTH_TRUE

//turf/open/floor/rogue/lightpath/cardinal_smooth(adjacencies)
	//roguesmooth(adjacencies)

/turf/open/floor/sand/dunes/darkpath/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	icon_state = "dark-path[rand(1,8)]"



/obj/effect/decal/desertgrassedge
	name = ""
	desc = ""
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	icon_state = "desertgrass_edges"
	mouse_opacity = 0


/turf/open/floor/sand/dunes/desert_grass
	name = "desert grass"
	desc = "Grass, barely."
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	icon_state = "desertgrass1"
	layer = MID_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	//tiled_dirt = FALSE
	landsound = 'sound/foley/jumpland/grassland.wav'
	slowdown = 0
	//smooth = SMOOTH_TRUE
	//canSmoothWith = list(
	//					/turf/open/floor/rogue/grass,
	//					/turf/open/floor/rogue/dunes,
	//					/turf/open/floor/rogue/citybrick,)
	max_integrity = 1200

/turf/open/floor/sand/dunes/desert_grass/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	icon_state = "desertgrass[rand(1,16)]"


//turf/open/floor/rogue/desert_grass/cardinal_smooth(adjacencies)
	//roguesmooth(adjacencies)

//turf/open/floor/rogue/desert_grass/turf_destruction(damage_flag)
	//. = ..()
	//src.ChangeTurf(/turf/open/floor/rogue/dirt, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/sand/dunes/dirt/desert
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
/turf/open/floor/sand/dunes/dirt/road/desert
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'


///.

/turf/open/floor/sand/dunes/deserttile
	name = "tiles"
	icon_state = "tiledrab"
	icon = 'modular_rmh/icons/turf/desertfloor.dmi'
	footstep = FOOTSTEP_STONE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/stoneland.wav'
	//smooth = SMOOTH_MORE
	//canSmoothWith = list(/turf/closed/mineral/rogue, /turf/closed/mineral, /turf/closed/wall/mineral/rogue/stonebrick, /turf/closed/wall/mineral/rogue/wood, /turf/closed/wall/mineral/rogue/wooddark, /turf/closed/wall/mineral/rogue/stone, /turf/closed/wall/mineral/rogue/stone/moss, /turf/open/floor/rogue/cobble, /turf/open/floor/rogue/dirt, /turf/open/floor/rogue/grass)
	damage_deflection = 10
	max_integrity = 1000
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
