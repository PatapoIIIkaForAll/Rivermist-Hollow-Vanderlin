/obj/item/clothing/undies
	name = "briefs"
	desc = "An absolute necessity."
	icon = 'modular_rmh/icons/obj/misc.dmi'
	mob_overlay_icon = 'modular_rmh/icons/mob/sprite_accessory/underwear.dmi'
	icon_state = "briefs"
	item_state = "briefs"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	blade_dulling = DULLING_CUT
	max_integrity = 200
	integrity_failure = 0.1
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	var/gendered = TRUE
	var/covers_breasts = FALSE
	boob_sized = FALSE
	sewrepair = TRUE
	salvage_result = /obj/item/natural/cloth
	grid_height = 32
	grid_width = 32
	slot_flags = ITEM_SLOT_MOUTH | ITEM_SLOT_UNDERWEAR
	muteinmouth = TRUE

/obj/item/clothing/undies/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.underwear)
			if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN))
				return
			user.visible_message(span_notice("[user] tries to put [src] on [H]..."))
			if(do_after(user, 50, target = H))
				H.equip_to_slot_if_possible(src, ITEM_SLOT_UNDERWEAR, disable_warning = TRUE)

/obj/item/clothing/undies/bikini
	name = "bikini"
	icon_state = "bikini"
	item_state = "bikini"
	covers_breasts = TRUE
	gendered = TRUE
	boob_sized = TRUE

/obj/item/clothing/undies/panties
	name = "panties"
	icon_state = "panties"
	item_state = "panties"
	gendered = FALSE

/obj/item/clothing/undies/leotard
	name = "leotard"
	icon_state = "leotard"
	item_state = "leotard"
	covers_breasts = TRUE
	gendered = TRUE
	boob_sized = TRUE

/obj/item/clothing/undies/athletic_leotard
	name = "athletic leotard"
	icon_state = "athletic_leotard"
	item_state = "athletic_leotard"
	covers_breasts = TRUE
	gendered = TRUE

/obj/item/clothing/undies/braies
	name = "braies"
	desc = "A pair of linen underpants; Psydonia's most common."
	icon_state = "braies"
	item_state = "braies"

// Craft

/datum/repeatable_crafting_recipe/sewing/undies
	name = "briefs"
	output = /obj/item/clothing/undies
	requirements = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/bikini
	name = "bikini"
	output = /obj/item/clothing/undies/bikini
	requirements = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/panties
	name = "panties"
	output = /obj/item/clothing/undies/panties
	requirements = list(/obj/item/natural/cloth = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/leotard
	name = "leotard"
	output = /obj/item/clothing/undies/leotard
	requirements = list(/obj/item/natural/silk = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/athletic_leotard
	name = "athletic leotard"
	output = /obj/item/clothing/undies/athletic_leotard
	requirements = list(/obj/item/natural/silk = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/braies
	name = "braies"
	output = /obj/item/clothing/undies/braies
	requirements = list(/obj/item/natural/cloth = 1)
	craftdiff = 2
