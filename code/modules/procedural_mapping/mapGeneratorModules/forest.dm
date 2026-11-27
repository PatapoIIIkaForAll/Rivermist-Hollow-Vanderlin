//genstuff
/obj/effect/landmark/mapGenerator/forest
	mapGeneratorType = /datum/mapGenerator/forest
	endTurfX = 200
	endTurfY = 200
	startTurfX = 1
	startTurfY = 1

/datum/mapGenerator/forest
	modules = list(
		/datum/mapGeneratorModule/ambushing,
		/datum/mapGeneratorModule/forestgrassturf,
		/datum/mapGeneratorModule/forestgrassturf/snowy,
		/datum/mapGeneratorModule/forest,
		/datum/mapGeneratorModule/forest/snowy,
		/datum/mapGeneratorModule/forestroad,
		/datum/mapGeneratorModule/forestgrass,
		/datum/mapGeneratorModule/forestswampwaterturf,
		/datum/mapGeneratorModule/forestwaterturf,
	)

/datum/mapGeneratorModule/forest
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/dirt)
	excluded_turfs = list(/turf/open/floor/dirt/road, /turf/open/floor/dirt/snowy)
	spawnableAtoms = list(
		/obj/structure/flora/grass/brown = 60,
		/obj/structure/flora/grass/both = 80,
		/obj/structure/flora/grass/green = 70,
		/obj/structure/flora/grass/thorn_bush = 6,
		/obj/item/natural/rock = 6,
		/obj/structure/flora/grass/herb/random = 5,
		/obj/structure/flora/grass/pumpkin = 2,
		/obj/structure/closet/dirthole/closed/loot = 5,
		/obj/structure/flora/newtree/snow = 25,
		/obj/item/natural/stone = 5,
		/obj/structure/essence_node = 0.4,
		/obj/item/grown/log/tree/stick = 4,
		/obj/structure/flora/grass/bush_meagre/tundra = 4,
		/obj/structure/table/wood/treestump = 4,
		/obj/structure/chair/bench/ancientlog = 3,
		// /obj/item/restraints/legcuffs/beartrap/armed/camouflage = 0.1
	)
	spawnableTurfs = list(
		/turf/open/floor/dirt/road = 30
	)
	allowed_areas = list(/area/outdoors/rmh_darkforest)

// Keep the snowy ground when the forest creates paths.
/datum/mapGeneratorModule/forest/snowy
	allowed_turfs = list(/turf/open/floor/dirt/snowy)
	excluded_turfs = list(/turf/open/floor/dirt/road)
	spawnableTurfs = list(/turf/open/floor/dirt/road/snowy = 30)

/datum/mapGeneratorModule/forestroad
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/dirt/road, /turf/open/floor/dirt/road/snowy)
	allowed_areas = list(/area/outdoors/rmh_darkforest)
	spawnableAtoms = list(
		/obj/item/natural/stone = 3,
		/obj/item/grown/log/tree/stick = 2
	)

/datum/mapGeneratorModule/forestgrassturf
	clusterCheckFlags = CLUSTER_CHECK_NONE
	allowed_turfs = list(/turf/open/floor/dirt)
	excluded_turfs = list(/turf/open/floor/dirt/road, /turf/open/floor/dirt/snowy)
	spawnableTurfs = list(/turf/open/floor/grass = 15)
	allowed_areas = list(/area/outdoors/rmh_darkforest) //RMH_EDIT

// Snowy dirt grows snow-covered grass rather than exposing summer grass.
/datum/mapGeneratorModule/forestgrassturf/snowy
	allowed_turfs = list(/turf/open/floor/dirt/snowy)
	excluded_turfs = list(/turf/open/floor/dirt/road)
	spawnableTurfs = list(/turf/open/floor/grass/cold/winter = 15)

/datum/mapGeneratorModule/forestgrass
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	// Type caches include all grass variants and their snowy subtypes.
	allowed_turfs = list(/turf/open/floor/dirt, /turf/open/floor/grass)
	excluded_turfs = list(/turf/open/floor/dirt/road)
	allowed_areas = list(/area/outdoors/rmh_darkforest) //RMH_EDIT
	spawnableAtoms = list(
		/obj/structure/flora/grass/brown = 60,
		/obj/structure/flora/grass/both = 80,
		/obj/structure/flora/grass/green = 70,
		/obj/structure/flora/grass/bush_meagre/tundra = 7,
		/obj/structure/flora/grass/herb/random = 6,
		/obj/item/grown/log/tree/stick = 5,
		/obj/structure/flora/grass/thorn_bush = 4,
		/obj/structure/chair/bench/ancientlog = 4,
		/obj/item/natural/stone = 3,
		/obj/item/natural/rock = 2,
		/obj/structure/flora/grass/pyroclasticflowers = 1,
		/obj/structure/flora/grass/maneater = 0.3,
		/obj/structure/essence_node = 1,
		/obj/structure/flora/grass/maneater/real = 0.1,
		// /obj/item/restraints/legcuffs/beartrap/armed/camouflage = 0.1
	)

/datum/mapGeneratorModule/forestwaterturf
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	allowed_turfs = list(/turf/open/water/clean)
	allowed_areas = list(/area/outdoors/rmh_darkforest) //RMH_EDIT
	spawnableAtoms = list(
		/obj/structure/flora/grass/water = 20,
		/obj/structure/flora/grass/water/reeds = 25,
		/obj/structure/kneestingers = 25
	)

/datum/mapGeneratorModule/forestswampwaterturf
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	allowed_turfs = list(/turf/open/water/swamp)
	allowed_areas = list(/area/outdoors/rmh_darkforest) //RMH_EDIT
	spawnableAtoms = list(
		/obj/structure/flora/grass/water = 20,
		/obj/structure/flora/grass/water/reeds = 30,
		/obj/structure/kneestingers = 30
	)
