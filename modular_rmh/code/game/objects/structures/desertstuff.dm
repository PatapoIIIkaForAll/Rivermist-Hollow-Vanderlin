//drape
/obj/structure/drape/desert
	name = "desert drape"
	desc = "Made from durable fabric."
	icon = 'modular_rmh/icons/obj/structures/drapes.dmi'
	icon_state = "desertdrape"

/obj/structure/drape/desert2
	name = "desert drape"
	desc = "Made from prestigious fabric."
	icon = 'modular_rmh/icons/obj/structures/drapes.dmi'
	icon_state = "desertdrape1"

/obj/structure/drape/desert2/Initialize()
	. = ..()
	icon_state = "desertdrape[rand(1, 2)]"

//cushion
/obj/item/cushion/desert1
	name = "desert cushion"
	icon = 'modular_rmh/icons/obj/structures/cushions.dmi'
	icon_state = "desertcushion1"

/obj/item/cushion/desert2
	name = "desert cushion"
	icon = 'modular_rmh/icons/obj/structures/cushions.dmi'
	icon_state = "desertcushion2"

/obj/item/cushion/desert3
	name = "desert cushion"
	icon = 'modular_rmh/icons/obj/structures/cushions.dmi'
	icon_state = "desertcushion3"

//kegs

/// The original hierarchy for barrels and buckets is kind of messy, and I didn't want to refactor it all to have sane subtypes.


/obj/structure/fermentation_keg/sandpot
	name = "sand pot"
	desc = "A common clay pot used for storing and sometimes fermenting fluids. Favoured over wooden barrels in the desert of Calimshan due to the relative scarcity of wood."
	icon = 'modular_rmh/icons/obj/structures/pots.dmi'
	icon_state = "sandpot1"

/obj/structure/fermentation_keg/fancypot
	name = "fancy pot"
	desc = "Decorative and Practical!"
	icon = 'modular_rmh/icons/obj/structures/pots.dmi'
	icon_state = "fancypot1"

/obj/item/reagent_containers/glass/bucket/tinypot
	name = "tiny pot"
	icon = 'modular_rmh/icons/obj/structures/pots.dmi'
	icon_state = "tinypot1"

/obj/structure/fermentation_keg/sandpot/Initialize()
	. = ..()
	icon_state = "sandpot[rand(1, 2)]"

/obj/structure/fermentation_keg/fancypot/Initialize()
	. = ..()
	icon_state = "fancypot[rand(1, 2)]"

// Subtypes for sandpots
/obj/structure/fermentation_keg/sandpot/random/water/Initialize()
	. = ..()
	icon_state = "sandpot1"
	reagents.add_reagent(/datum/reagent/water, rand(0,900))

/obj/structure/fermentation_keg/sandpot/random/beer/Initialize()
	. = ..()
	icon_state = "sandpot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, rand(0,900))

/obj/structure/fermentation_keg/sandpot/random/wine/Initialize()
	. = ..()
	icon_state = "sandpot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/wine, rand(0,900))

/obj/structure/fermentation_keg/sandpot/water/Initialize()
	. = ..()
	icon_state = "sandpot1"
	reagents.add_reagent(/datum/reagent/water,900)

/obj/structure/fermentation_keg/sandpot/beer/Initialize()
	. = ..()
	icon_state = "sandpot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/beer,900)

/obj/structure/fermentation_keg/sandpot/wine/Initialize()
	. = ..()
	icon_state = "sandpot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/wine,900)


// Subtypes for fancypots
/obj/structure/fermentation_keg/fancypot/random/water/Initialize()
	. = ..()
	icon_state = "fancypot2"
	reagents.add_reagent(/datum/reagent/water, rand(0,900))

/obj/structure/fermentation_keg/fancypot/random/beer/Initialize()
	. = ..()
	icon_state = "fancypot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, rand(0,900))

/obj/structure/fermentation_keg/fancypot/random/wine/Initialize()
	. = ..()
	icon_state = "fancypot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/wine, rand(0,900))

/obj/structure/fermentation_keg/fancypot/water/Initialize()
	. = ..()
	icon_state = "fancypot2"
	reagents.add_reagent(/datum/reagent/water,900)

/obj/structure/fermentation_keg/fancypot/beer/Initialize()
	. = ..()
	icon_state = "fancypot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/beer,900)

/obj/structure/fermentation_keg/fancypot/wine/Initialize()
	. = ..()
	icon_state = "fancypot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/wine,900)


///
/obj/machinery/light/fueled/wallfire/desert
	name = "desert fireplace"
	icon = 'modular_rmh/icons/obj/lighting/fireplace.dmi'
	icon_state = "fireplace1"
	base_state = "fireplace"
	fueluse = 0
	density = FALSE
	anchored = TRUE
	cookonme = FALSE

///////////

/obj/structure/pillar
	name = "pillar"
	desc = ""
	icon = 'modular_rmh/icons/obj/structures/sandpillar.dmi'
	opacity = 0
	max_integrity = 1000
	density = TRUE
	blade_dulling = DULLING_BASH
	anchored = TRUE
	alpha = 255
	destroy_sound = 'sound/foley/smash_rock.ogg'
	attacked_sound = 'sound/foley/hit_rock.ogg'
	static_debris = list(/obj/item/natural/stone = 10)
	layer = 4.82
	pixel_x = -16
	plane = GAME_PLANE_UPPER

	abstract_type = /obj/structure/pillar

/obj/structure/pillar/sand1
	icon_state = "sandpillar1"


////chairs

/obj/item/chair/wood/desert
	name = "desert chair"
	icon = 'modular_rmh/icons/obj/structures/chairs.dmi'
	icon_state = "desertchair"
	origin_type = /obj/structure/chair/wood/desert

/obj/structure/chair/wood/desert
	name = "desert chair"
	icon = 'modular_rmh/icons/obj/structures/chairs.dmi'
	icon_state = "desertchair"

/obj/structure/chair/bench/throne/desert
	name = "desert throne"
	icon_state = "desertthrone"
	icon = 'modular_rmh/icons/obj/structures/throne.dmi'
	pixel_x = -16

////sofa
/obj/structure/chair/desert_sofa/right
	name = "desert sofa"
	icon_state = "desertsofa_right"
	icon = 'modular_rmh/icons/obj/structures/chairs.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/desert_sofa/left
	name = "desert sofa"
	icon_state = "desertsofa_left"
	icon = 'modular_rmh/icons/obj/structures/chairs.dmi'
	buildstackamount = 1
	item_chair = null

//Sandrocks

/obj/structure/sandrock
	name = "sandrock"
	desc = "A large desert rock protuding from the ground."
	icon_state = "rock1"
	icon = 'modular_rmh/icons/obj/structures/sandrock.dmi'
	opacity = 0
	max_integrity = 1000
	density = TRUE
	blade_dulling = DULLING_BASH
	anchored = TRUE
	alpha = 255
	destroy_sound = 'sound/foley/smash_rock.ogg'
	attacked_sound = 'sound/foley/hit_rock.ogg'
	static_debris = list(/obj/item/natural/stone = 10)
	pixel_x = -48
	pixel_y = -18
	layer = 4.81
	plane = GAME_PLANE_UPPER

	abstract_type = /obj/structure/sandrock

/obj/structure/sandrock/sandrock1
	icon_state = "sandrock1"

/obj/structure/sandrock/sandrock2
	icon_state = "sandrock2"

/obj/structure/sandrock/sandrock3
	icon_state = "sandrock3"

/obj/structure/sandrock/sandrock4
	icon_state = "sandrock4"

/obj/item/natural/rock/desert
	name = "sand rock"
	icon = 'modular_rmh/icons/obj/structures/small_sandrock.dmi'
	icon_state = "sandrock1"

/obj/item/natural/rock/desert/Initialize()
	. = ..()
	icon_state = "sandrock[rand(1,2)]"

//bush

/obj/structure/flora/grass/bush/desert
	name = "saigahorn"
	desc = ""
	icon = 'modular_rmh/icons/obj/flora/desertflora.dmi'
	icon_state = "saigahorn1"

/obj/structure/flora/grass/bush/desert/Initialize()
	. = ..()
	icon_state = "saigahorn[rand(1, 3)]"

/obj/structure/flora/grass/bush/desertshrub
	name = "treelet"
	desc = "A rounded bush-like tree or perhaps tree-like bush native to Zybantium. A valuable source of wood in the sparse desert."
	icon = 'modular_rmh/icons/obj/flora/desertflora.dmi'
	icon_state = "bushshrub1"
	attacked_sound = 'sound/misc/woodhit.ogg'
	max_integrity = 100
	debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1, /obj/item/grown/log/tree/small = 1)

/obj/structure/flora/grass/bush/desertshrub/Initialize()
	. = ..()
	icon_state = "bushshrub[pick(1,2)]"

/obj/structure/flora/tree/palm
	name = "palm tree"
	desc = "Scant, precious shade."
	icon = 'modular_rmh/icons/obj/flora/bigpalm.dmi'
	icon_state = "palm1"
	stump_type = /obj/structure/flora/tree/stump/palm
	pixel_x = -32
	opacity = 0 //palm trees are skinny

/obj/structure/flora/tree/palm/Initialize()
	. = ..()
	icon_state = "palm[rand(1,2)]"

/obj/structure/flora/tree/stump/palm
	name = "tree stump"
	desc = "Shade no more."
	icon_state = "palmstump1"
	icon = 'modular_rmh/icons/obj/flora/bigpalm.dmi'
	stump_type = null
	pixel_x = -32

//Stairs

/obj/structure/stairs/desert
	name = "sand stairs"
	icon = 'modular_rmh/icons/obj/structures/sandstairs.dmi'
	icon_state = "sandstairs"
	max_integrity = 600
