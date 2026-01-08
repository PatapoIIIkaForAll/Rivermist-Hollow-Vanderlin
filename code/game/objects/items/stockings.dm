/obj/item/clothing/legwears
	name = "stockings(under)"
	desc = "A legwear made just for the pure aesthetics. Popular in courts and brothels alike."
	icon = 'modular_rmh/icons/clothing/stockings.dmi'
	mob_overlay_icon = 'modular_rmh/icons/mob/sprite_accessory/stockings.dmi'
	icon_state = "stockings"
	item_state = "stockings"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	blade_dulling = DULLING_CUT
	max_integrity = 200
	integrity_failure = 0.1
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	var/gendered
	var/covers_breasts = FALSE
	sewrepair = TRUE
	salvage_result = /obj/item/natural/cloth
	slot_flags = ITEM_SLOT_MOUTH | ITEM_SLOT_SOCKS
	muteinmouth = TRUE

/obj/item/clothing/legwears/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.legwear_socks)
			if(!get_location_accessible(H, BODY_ZONE_PRECISE_L_FOOT))
				return
			if(!get_location_accessible(H, BODY_ZONE_PRECISE_R_FOOT))
				return
			user.visible_message(span_notice("[user] tries to put [src] on [H]..."))
			if(do_after(user, 50, target = H))
				H.equip_to_slot_if_possible(src, ITEM_SLOT_SOCKS, disable_warning = TRUE)


/obj/item/clothing/legwears/random/Initialize()
	. = ..()
	color = pick("#e6e5e5", "#2b292e", "#173266", "#6F0000", "#664357")

/obj/item/clothing/legwears/white
	color = "#e6e5e5"

/obj/item/clothing/legwears/black
	color = "#2b292e"

/obj/item/clothing/legwears/blue
	color = "#173266"

/obj/item/clothing/legwears/red
	color = "#6F0000"

/obj/item/clothing/legwears/purple
	color = "#664357"

//Silk variants

/obj/item/clothing/legwears/silk
	name = "silk stockings"
	desc = "A legwear made just for the pure aesthetics. Made out of thin silk. Popular among nobles."
	icon_state = "silk"
	item_state = "silk"

/obj/item/clothing/legwears/silk/random/Initialize()
	. = ..()
	color = pick("#e6e5e5", "#2b292e", "#173266", "#6F0000", "#664357")

/obj/item/clothing/legwears/silk/white
	color = "#e6e5e5"

/obj/item/clothing/legwears/silk/black
	color = "#2b292e"

/obj/item/clothing/legwears/silk/blue
	color = "#173266"

/obj/item/clothing/legwears/silk/red
	color = "#6F0000"

/obj/item/clothing/legwears/silk/purple
	color = "#664357"

//Fishnets

/obj/item/clothing/legwears/fishnet
	name = "fishnet stockings"
	desc = "A legwear popular among wenches."
	icon_state = "fishnet"
	item_state = "fishnet"

/obj/item/clothing/legwears/fishnet/random/Initialize()
	. = ..()
	color = pick("#e6e5e5", "#2b292e", "#173266", "#6F0000", "#664357")

/obj/item/clothing/legwears/fishnet/white
	color = "#e6e5e5"

/obj/item/clothing/legwears/fishnet/black
	color = "#2b292e"

/obj/item/clothing/legwears/fishnet/blue
	color = "#173266"

/obj/item/clothing/legwears/fishnet/red
	color = "#6F0000"

/obj/item/clothing/legwears/fishnet/purple
	color = "#664357"

// Supply

/datum/supply_pack/rogue/wardrobe/suits/stockings_white
	name = "White Stockings"
	cost = 10
	contains = list(
					/obj/item/clothing/legwears/white,
					/obj/item/clothing/legwears/white,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_black
	name = "Black Stockings"
	cost = 10
	contains = list(
					/obj/item/clothing/legwears/black,
					/obj/item/clothing/legwears/black,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_blue
	name = "Blue Stockings"
	cost = 10
	contains = list(
					/obj/item/clothing/legwears/blue,
					/obj/item/clothing/legwears/blue,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_red
	name = "Red Stockings"
	cost = 10
	contains = list(
					/obj/item/clothing/legwears/red,
					/obj/item/clothing/legwears/red,
				)
/datum/supply_pack/rogue/wardrobe/suits/stockings_purple
	name = "Purple Stockings"
	cost = 10
	contains = list(
					/obj/item/clothing/legwears/purple,
					/obj/item/clothing/legwears/purple,
				)

//Silk

/datum/supply_pack/rogue/wardrobe/suits/stockings_white_silk
	name = "White Silk Stockings"
	cost = 30
	contains = list(
					/obj/item/clothing/legwears/silk/white,
					/obj/item/clothing/legwears/silk/white,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_black_silk
	name = "Black Silk Stockings"
	cost = 30
	contains = list(
					/obj/item/clothing/legwears/silk/black,
					/obj/item/clothing/legwears/silk/black,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_blue_silk
	name = "Blue Silk Stockings"
	cost = 30
	contains = list(
					/obj/item/clothing/legwears/silk/blue,
					/obj/item/clothing/legwears/silk/blue,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_red_silk
	name = "Red Silk Stockings"
	cost = 30
	contains = list(
					/obj/item/clothing/legwears/silk/red,
					/obj/item/clothing/legwears/silk/red,
				)
/datum/supply_pack/rogue/wardrobe/suits/stockings_purple_silk
	name = "Purple Silk Stockings"
	cost = 30
	contains = list(
					/obj/item/clothing/legwears/silk/purple,
					/obj/item/clothing/legwears/silk/purple,
				)

//Fishnets

/datum/supply_pack/rogue/wardrobe/suits/stockings_white_fishnet
	name = "White Fishnet Stockings"
	cost = 5
	contains = list(
					/obj/item/clothing/legwears/fishnet/white,
					/obj/item/clothing/legwears/fishnet/white,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_black_fishnet
	name = "Black Fishnet Stockings"
	cost = 5
	contains = list(
					/obj/item/clothing/legwears/fishnet/black,
					/obj/item/clothing/legwears/fishnet/black,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_blue_fishnet
	name = "Blue Fishnet Stockings"
	cost = 5
	contains = list(
					/obj/item/clothing/legwears/fishnet/blue,
					/obj/item/clothing/legwears/fishnet/blue,
				)

/datum/supply_pack/rogue/wardrobe/suits/stockings_red_fishnet
	name = "Red Fishnet Stockings"
	cost = 5
	contains = list(
					/obj/item/clothing/legwears/fishnet/red,
					/obj/item/clothing/legwears/fishnet/red,
				)
/datum/supply_pack/rogue/wardrobe/suits/stockings_purple_fishnet
	name = "Purple Fishnet Stockings"
	cost = 5
	contains = list(
					/obj/item/clothing/legwears/fishnet/purple,
					/obj/item/clothing/legwears/fishnet/purple,
				)

// Craft

/datum/repeatable_crafting_recipe/sewing/stockings_white
	name = "stockings"
	output = /obj/item/clothing/legwears/white
	requirements = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/stockings_white_silk
	name = "silk stockings"
	output = /obj/item/clothing/legwears/silk/white
	requirements = list(/obj/item/natural/silk = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/stockings_white_fishnet
	name = "fishnet stockings"
	output = /obj/item/clothing/legwears/fishnet/white
	requirements = list(/obj/item/natural/fibers = 2)
	craftdiff = 3
