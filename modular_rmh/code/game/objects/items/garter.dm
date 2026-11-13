/obj/item/clothing/garter
	name = "garters"
	desc = "Holds up what's the most precios."
	icon = 'modular_rmh/icons/clothing/underwear/garters.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/underwear/onmob/garters.dmi'
	icon_state = "garters"
	item_state = "garters"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	blade_dulling = DULLING_CUT
	max_integrity = 200
	integrity_failure = 0.1
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = /datum/attribute/skill/misc/sewing/mending
	salvage_result = /obj/item/natural/cloth
	slot_flags = ITEM_SLOT_GARTER

/datum/repeatable_crafting_recipe/sewing/garters
	name = "garter"
	output = /obj/item/clothing/garter
	requirements = list(/obj/item/natural/silk = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2
