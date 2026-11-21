/obj/item/clothing/ring/baotha
	name = "snake ring"
	desc = "The ring is made of steel with gilding, and it is artfully recreated as a snake. The quality of the work is so high that it feels as if the snake's gem-filled eyes are watching you."
	icon = 'modular_twilightaxis/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/rings_2.dmi'
	icon_state = "baotha_knife"
	max_integrity = 300
	var/realname = null
	var/realdesc = null
	var/realstate = null
	var/realicon = null
	var/baotha_disguised = FALSE
	var/disguise_state = null
	grid_width = 32
	grid_height = 32
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/baotha/Initialize()
	. = ..()
	realname = name
	realdesc = desc
	realstate = icon_state
	realicon = icon

/obj/item/clothing/ring/baotha/examine(mob/living/carbon/human/user)
	. = ..()
	if(iscarbon(user))
		if(user.patron.type == /datum/patron/faerun/evil_gods/Blissara)
			. += ("This creature is a small gift from my patron, and I can make it take any form I desire.")

/obj/item/clothing/ring/baotha/update_icon_state()
	. = ..()
	if(baotha_disguised && disguise_state)
		icon_state = disguise_state
	else
		icon_state = realstate

/obj/item/clothing/ring/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	update_appearance()

/obj/item/clothing/ring/baotha/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	update_appearance()
