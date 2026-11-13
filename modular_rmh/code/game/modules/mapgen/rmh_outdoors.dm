/obj/effect/landmark/mapGenerator/rmh_field
	mapGeneratorType = /datum/mapGenerator/rmh_field
	endTurfX = 155
	endTurfY = 155
	startTurfX = 1
	startTurfY = 1


/datum/mapGenerator/rmh_field
	modules = list(
		/datum/mapGeneratorModule/ambushing,
		/datum/mapGeneratorModule/rmh_field/grass,
		/datum/mapGeneratorModule/rmh_fieldgrass,
		/datum/mapGeneratorModule/rmh_field,
		/datum/mapGeneratorModule/rmh_field/road,
		/datum/mapGeneratorModule/rmh_field/tree_leafs
		)

/datum/mapGeneratorModule/rmh_field
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/dirt)
	excluded_turfs = list(/turf/open/floor/dirt/road)
	spawnableAtoms = list(
		/obj/structure/flora/newtree = 15,
		/obj/structure/flora/grass = 40,
		/obj/effect/spawner/map_spawner/treeorbush = 20,
		/obj/effect/spawner/map_spawner/treeorstump = 20,
		/obj/structure/flora/grass/fullgrass_autumn = 50,
		/obj/structure/flora/grass/sparegrass = 60,
		/obj/structure/flora/grass = 13,
		/obj/structure/flora/grass/bush_meagre = 30,
		/obj/item/natural/stone = 18,
		/obj/item/natural/rock = 2,
		/obj/item/grown/log/tree/stick = 3,
		/obj/structure/closet/dirthole/closed/loot = 3,
		/obj/structure/flora/grass/pyroclasticflowers = 3
						)
	spawnableTurfs = list(/turf/open/floor/dirt/road=5)
	allowed_areas = list(/area/outdoors/rmh_field)

/datum/mapGeneratorModule/rmh_field/road
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/dirt/road)
	excluded_turfs = list()
	spawnableAtoms = list(
		/obj/item/natural/stone = 18,
		/obj/item/grown/log/tree/stick = 3
						)
	allowed_areas = list(/area/outdoors/rmh_field)

/datum/mapGeneratorModule/rmh_field/grass
	clusterCheckFlags = CLUSTER_CHECK_NONE
	allowed_turfs = list(/turf/open/floor/dirt)
	excluded_turfs = list(/turf/open/floor/dirt/road)
	spawnableTurfs = list(/turf/open/floor/grass = 15)
	spawnableAtoms = list()
	allowed_areas = list(/area/outdoors/rmh_field)

/datum/mapGeneratorModule/rmh_fieldgrass
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(
		/turf/open/floor/dirt,
		/turf/open/floor/grass,
		/turf/open/floor/grass/red,
		/turf/open/floor/grass/yel,
		/turf/open/floor/grass/cold,
		/turf/open/floor/grass/healthy
		)
	excluded_turfs = list(/turf/open/floor/dirt/road)
	spawnableAtoms = list(
		/obj/structure/flora/grass = 60,
		/obj/structure/flora/grass/fullgrass_autumn = 80,
		/obj/structure/flora/grass = 70,
		/obj/item/natural/stone = 18,
		/obj/structure/flora/grass/herb/random = 20,
		/obj/structure/flora/grass/pumpkin = 3,
		/obj/item/grown/log/tree/stick = 3
							)
	allowed_areas = list(/area/outdoors/rmh_field)

/datum/mapGeneratorModule/rmh_field/tree_leafs
	clusterCheckFlags = CLUSTER_CHECK_NONE
	allowed_turfs = list(/turf/open)
	excluded_turfs = list(/turf/open/openspace)
	spawnableAtoms = list(/obj/effect/decal/cleanable/dirt/leafs = 30)
	spawnableTurfs = list()
	allowed_areas = list(/area/outdoors/rmh_field)
	include_subtypes = TRUE
	var/list/near_types = list(/obj/structure/flora/newtree)
	var/near_radius = 3

/datum/mapGeneratorModule/rmh_field/tree_leafs/generate()
	near_types = typecacheof(near_types)
	return ..()

/datum/mapGeneratorModule/rmh_field/tree_leafs/place(turf/T)
	if(excluded_turfs[T.type] || !allowed_turfs[T.type] || !allowed_areas[T.loc?.type])
		return
	for(var/atom/movable/thing as anything in T)
		if(near_types[thing.type] || spawnableAtoms[thing.type])
			return
	var/tree_nearby = FALSE
	for(var/atom/movable/thing in range(near_radius, T))
		if(near_types[thing.type])
			tree_nearby = TRUE
			break
	if(!tree_nearby)
		return
	return ..()
