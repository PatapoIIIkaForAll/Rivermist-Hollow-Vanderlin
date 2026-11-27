/turf/open/floor
	var/rmh_snowy = FALSE
	var/rmh_snow_cleared_turf = null

/turf/open/floor/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. || !rmh_snow_cleared_turf || user.cmode)
		return
	var/using_shovel = istype(tool, /obj/item/weapon/shovel) && istype(user.used_intent, /datum/intent/shovelscoop)
	var/using_hoe = istype(tool, /obj/item/weapon/hoe) && istype(user.used_intent, /datum/intent/till)
	if(!using_shovel && !using_hoe)
		return NONE
	if(user.stat != CONSCIOUS || !isturf(user.loc) || !user.TurfAdjacent(src) || user.get_active_held_item() != tool)
		return ITEM_INTERACT_BLOCKING
	user.changeNext_move(user.used_intent.clickcd)
	playsound(src, 'sound/items/dig_shovel.ogg', 100, TRUE)
	user.visible_message(span_notice("[user] clears away the snow."), span_notice("You clear away the snow."))
	ChangeTurf(rmh_snow_cleared_turf, flags = CHANGETURF_INHERIT_AIR)
	return ITEM_INTERACT_SUCCESS

/turf/open/floor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !rmh_snowy)
		return
	return rmh_pick_up_snowball(user)

/turf/open/floor/grass/cold/winter
	rmh_snow_cleared_turf = /turf/open/floor/grass/cold
	icon = 'modular_rmh/icons/turf/winter_grass.dmi'
	icon_state = "snow"
	heelstep = HEELSTEP_SNOW
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowedge"
	spread_chance = 0
	rmh_snowy = TRUE

/turf/open/floor/proc/rmh_pick_up_snowball(mob/user)
	if(!isliving(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/mob/living/living_user = user
	if(living_user.stat != CONSCIOUS || !living_user.TurfAdjacent(src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/natural/snowball/snowball = new(src)
	if(living_user.put_in_active_hand(snowball))
		living_user.visible_message(span_notice("[living_user] picks up some snow."))
	else
		qdel(snowball)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/turf/open/floor/dirt/road/snowy
	rmh_snow_cleared_turf = /turf/open/floor/dirt/road
	name = "snowy road"
	desc = "The dirt road is covered in a layer of snow."
	icon = 'modular_rmh/icons/turf/winter_road.dmi'
	icon_state = "snowrough"
	heelstep = HEELSTEP_SNOW
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 0
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowroughedge"
	spread_chance = 0
	path_weight = 10
	rmh_snowy = TRUE

/turf/open/floor/dirt/road/snowy/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	// The road parent deliberately skips the floor interaction, so handle snow here.
	return rmh_pick_up_snowball(user)

/turf/open/floor/dirt/road/snowy/become_muddy()
	. = ..()
	// Keep both the mud states and snowy edges available, including after drying out.
	icon = initial(icon)

/turf/open/floor/dirt/snowy
	rmh_snow_cleared_turf = /turf/open/floor/dirt
	name = "snow"
	desc = "A gentle blanket of snow."
	icon = 'modular_rmh/icons/turf/winter_grass.dmi'
	icon_state = "snow"
	heelstep = HEELSTEP_SNOW
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 2
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowedge"
	spread_chance = 1.1
	rmh_snowy = TRUE

/turf/open/floor/cobble/snow
	rmh_snow_cleared_turf = /turf/open/floor/cobble

/turf/open/floor/cobblerock/snow
	rmh_snow_cleared_turf = /turf/open/floor/cobblerock
	icon = 'modular_rmh/icons/turf/winter_cobblerock.dmi'
	heelstep = HEELSTEP_SNOW
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowcobblerockedge"
	rmh_snowy = TRUE

/turf/open/floor/snow
	rmh_snow_cleared_turf = /turf/open/floor/dirt

/turf/open/floor/snow/patchy
	rmh_snow_cleared_turf = /turf/open/floor/grass/cold

/turf/open/floor/snowpath
	rmh_snow_cleared_turf = /turf/open/floor/dirt/road
	name = "snowy path"
	desc = "The path road is covered in a layer of snow."
	icon = 'modular_rmh/icons/turf/snow.dmi'
	icon_state = "snowpath"
	heelstep = HEELSTEP_SNOW
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 0
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowedge"
	spread_chance = 0
	path_weight = 10

/turf/open/floor/snowpath/snowcorner
	name = "snowy path"
	desc = "The path road is covered in a layer of snow."
	icon = 'modular_rmh/icons/turf/snow.dmi'
	icon_state = "snowpathcorner"
	heelstep = HEELSTEP_SNOW
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 0
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowedge"
	spread_chance = 0
	path_weight = 10

/turf/open/floor/snowpath/snowpatht
	name = "snowy path"
	desc = "The path road is covered in a layer of snow."
	icon = 'modular_rmh/icons/turf/snow.dmi'
	icon_state = "snowpatht"
	heelstep = HEELSTEP_SNOW
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 0
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowedge"
	spread_chance = 0
	path_weight = 10

/turf/open/floor/snowpath/snowpathx
	name = "snowy path"
	desc = "The path road is covered in a layer of snow."
	icon = 'modular_rmh/icons/turf/snow.dmi'
	icon_state = "snowpathx"
	heelstep = HEELSTEP_SNOW
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.ogg'
	slowdown = 0
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_SNOW
	smoothing_list = SMOOTH_GROUP_FLOOR_DIRT + SMOOTH_GROUP_FLOOR_DIRT_ROAD + SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_FLOOR_STONE
	neighborlay = "snowedge"
	spread_chance = 0
	path_weight = 10
