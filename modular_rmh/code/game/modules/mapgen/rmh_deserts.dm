//genstuff
/obj/effect/landmark/mapGenerator/rmh_desert
	mapGeneratorType = /datum/mapGenerator/rmh_desert
	endTurfX = 155
	endTurfY = 155
	startTurfX = 1
	startTurfY = 1


/datum/mapGenerator/rmh_desert
	modules = list(/datum/mapGeneratorModule/ambushing,/datum/mapGeneratorModule/rmh_desert,/datum/mapGeneratorModule/rmh_desertroad, /datum/mapGeneratorModule/rmh_desertgrass)


/datum/mapGeneratorModule/rmh_desert
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/sand/dunes)
	excluded_turfs = list(/turf/open/floor/sand/dunes/lightpath, /turf/open/floor/sand/dunes/sandbrick)
	spawnableAtoms = list(
		/obj/structure/flora/grass = 6,
		/obj/structure/flora/grass/bush/desert = 5,
		/obj/structure/flora/grass/bush/desertshrub = 5,
		/obj/structure/sandrock/sandrock1 = 0.5,
		/obj/structure/sandrock/sandrock2 = 0.5,
		/obj/structure/sandrock/sandrock3 = 0.5,
		/obj/structure/sandrock/sandrock4 = 0.5,
		/obj/structure/flora/grass/pyroclasticflowers = 0.1,
		/obj/item/natural/rock/desert = 4)
	allowed_areas = list(/area/outdoors/rmh_desert/valley)

/datum/mapGeneratorModule/rmh_desertroad
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/sand/dunes/lightpath)
	spawnableAtoms = list(
		/obj/item/natural/stone = 15,
		/obj/item/natural/rock/desert = 3,
		/obj/item/grown/log/tree/stick = 6)
	allowed_areas = list(/area/outdoors/rmh_desert/valley)

/datum/mapGeneratorModule/rmh_desertgrass
	clusterCheckFlags =  CLUSTER_CHECK_SAME_ATOMS
	allowed_turfs = list(/turf/open/floor/sand/dunes/darkpath)
	excluded_turfs = list()
	spawnableAtoms = list(
		/obj/structure/flora/grass = 25,
		/obj/structure/flora/grass/herb/random = 2,
		/obj/structure/flora/grass/bush_meagre = 2,
		/obj/item/natural/stone = 6,
		/obj/item/natural/rock = 1,
		/obj/item/grown/log/tree/stick = 3)
	allowed_areas = list(/area/outdoors/rmh_desert/valley)
