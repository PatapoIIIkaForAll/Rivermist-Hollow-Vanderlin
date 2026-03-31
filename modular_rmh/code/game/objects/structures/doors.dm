//DOORS IN THE DESERT DUNGEONS
// FORCED CLOSED STATE VERSION
/obj/structure/door/desertdoorperm
	name = "pyramid door"
	icon_state = "sarcdoor"
	icon = 'modular_rmh/icons/misc/doors.dmi'
	armor = list("blunt" = 15, "slash" = 30, "stab" = 30,  "piercing" = 0, "fire" = 50, "acid" = 50)
	open_sound = 'sound/foley/doors/stoneopen.ogg'
	close_sound = 'sound/foley/doors/stoneclose.ogg'
	repair_thresholds = list(/obj/item/natural/stone = 1)
	broken_repair = /obj/item/natural/stone
	repair_skill = /datum/skill/craft/masonry
	smeltresult = null
	metalizer_result = null
	var/once_open = FALSE

/obj/structure/door/desertdoorperm/Open(silent = FALSE, mob/user)
	..()
	once_open = TRUE

/obj/structure/door/desertdoorperm/Close(silent = FALSE)
	if(once_open)
		return
	..()

/obj/structure/door/desertdoorperm/force_closed()
	if(once_open)
		return
	..()

// NORMAL VERSION
/obj/structure/door/desertdoor
	name = "pyramid door"
	icon_state = "sarcdoor"
	icon = 'modular_rmh/icons/misc/doors.dmi'
	armor = list("blunt" = 15, "slash" = 30, "stab" = 30,  "piercing" = 0, "fire" = 50, "acid" = 50)
	open_sound = 'sound/foley/doors/stoneopen.ogg'
	close_sound = 'sound/foley/doors/stoneclose.ogg'
	repair_thresholds = list(/obj/item/natural/stone = 1)
	broken_repair = /obj/item/natural/stone
	repair_skill = /datum/skill/craft/masonry
	smeltresult = null
	metalizer_result = null
	var/once_open = FALSE
//
