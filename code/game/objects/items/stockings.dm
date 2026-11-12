/obj/item/clothing/legwears
	name = "stockings"
	desc = "A legwear made just for the pure aesthetics. Popular in courts and brothels alike."
	icon = 'modular_rmh/icons/clothing/underwear/stockings.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/underwear/onmob/stockings.dmi'
	icon_state = "stockings"
	item_state = "stockings"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	blade_dulling = DULLING_CUT
	grid_width = 32
	grid_height = 32
	max_integrity = 100
	// The ripped look shows at half integrity; zero shreds worn stockings off the legs.
	integrity_failure = 0.5
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = /datum/attribute/skill/misc/sewing/mending
	salvage_result = /obj/item/natural/cloth
	slot_flags = ITEM_SLOT_MOUTH | ITEM_SLOT_SOCKS
	muteinmouth = TRUE
	color = "#e6e5e5"
	var/icon_state_base
	var/damaged_icon = 'modular_rmh/icons/clothing/onmob/helpers/ripped_stockings_icon.dmi'
	var/damaged_overlay_icon = 'modular_rmh/icons/clothing/onmob/helpers/ripped_stockings_onmob.dmi'

/obj/item/clothing/legwears/Initialize(mapload, ...)
	. = ..()
	icon_state_base = icon_state

/obj/item/clothing/legwears/update_clothes_damaged_state(damaging = TRUE)
	if(damaged_icon && damaged_overlay_icon)

		if(damaging)
			damaged_clothes = 1
			icon = damaged_icon
			mob_overlay_icon = damaged_overlay_icon
			icon_state = "[icon_state_base]_ripped"
			if(!findtext(name, "ripped ", 1, 8))
				name = "ripped [name]"
		else
			damaged_clothes = 0
			icon = initial(icon)
			mob_overlay_icon = initial(mob_overlay_icon)
			icon_state = icon_state_base
			if(findtext(name, "ripped ", 1, 8))
				name = copytext(name, 8)
		update_appearance(updates = ALL)
	else
		. = ..()

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_socks()

/obj/item/clothing/legwears/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(user.mouth == src)
		icon_state = null
		user.update_body()
		user.update_body_parts()

/obj/item/clothing/legwears/dropped(mob/user)
	. = ..()
	icon_state = icon_state_base
	update_clothes_damaged_state(damaged_clothes)

/obj/item/clothing/legwears/atom_break(damage_flag, silent)
	var/mob/living/carbon/human/wearer = loc
	if(!silent && istype(wearer) && wearer.legwear_socks == src)
		to_chat(wearer, span_warning("A ladder runs up my [name]!"))
	return ..()

/obj/item/clothing/legwears/atom_destruction(damage_flag)
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.legwear_socks != src || (damage_flag in list("acid", "fire")))
		return ..()
	wearer.visible_message(span_warning("[wearer]'s [name] shred apart and fall away!"), span_warning("My [name] shred apart and fall away!"))
	playsound(wearer, break_sound, 70, TRUE)
	wearer.dropItemToGround(src, force = TRUE)
	return ..()

/// Wears the stockings down; cuts and stabs tear faster than blunt rubs. Returns the damage dealt.
/obj/item/clothing/legwears/proc/snag(amount, damage_flag = SLASH)
	if(amount <= 0 || QDELETED(src) || atom_integrity <= 0)
		return 0
	if(damage_flag == BLUNT)
		amount *= 0.5
	return take_damage(amount, BRUTE, damage_flag, FALSE)

/// Rips the stockings straight to their torn look; returns TRUE only when this call tore them.
/obj/item/clothing/legwears/proc/tear_open(damage_flag = SLASH)
	if(!damaged_icon || obj_broken || QDELETED(src))
		return FALSE
	var/to_break = atom_integrity - integrity_failure * max_integrity
	if(to_break <= 0)
		return FALSE
	take_damage(to_break, BRUTE, damage_flag, FALSE)
	return obj_broken

/// Worn legwear that no trousers or leg armour cover, or null.
/mob/living/carbon/human/proc/get_exposed_legwear()
	RETURN_TYPE(/obj/item/clothing/legwears)
	var/obj/item/clothing/legwears/stockings = legwear_socks
	if(!istype(stockings))
		return null
	for(var/obj/item/clothing/cover as anything in list(wear_pants, wear_armor))
		if(istype(cover) && (cover.body_parts_covered & LEGS))
			return null
	return stockings

/// Worn stockings [actor] can get at, or null when armor over the legs keeps them off.
/mob/living/carbon/human/proc/get_sex_reachable_legwear(mob/living/actor)
	RETURN_TYPE(/obj/item/clothing/legwears)
	var/obj/item/clothing/legwears/stockings = legwear_socks
	if(!istype(stockings))
		return null
	if(get_sex_covering_garment(BODY_ZONE_L_LEG, actor) || get_sex_covering_garment(BODY_ZONE_R_LEG, actor))
		return null
	return stockings


/obj/item/clothing/legwears/random
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/random/Initialize()
	. = ..()
	color = pick("#e6e5e5", "#2b292e", "#173266", "#6F0000", "#664357")

/obj/item/clothing/legwears/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//Silk variants

/obj/item/clothing/legwears/silk
	name = "silk stockings"
	desc = "A legwear made just for the pure aesthetics. Made out of thin silk. Popular among nobles."
	icon_state = "silk"
	item_state = "silk"

/obj/item/clothing/legwears/silk/random
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk/random/Initialize()
	. = ..()
	color = pick("#e6e5e5", "#2b292e", "#173266", "#6F0000", "#664357")

/obj/item/clothing/legwears/silk/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//Fishnets

/obj/item/clothing/legwears/fishnet
	name = "fishnet stockings"
	desc = "A legwear popular among wenches."
	icon_state = "fishnet"
	item_state = "fishnet"

/obj/item/clothing/legwears/fishnet/random
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet/random/Initialize()
	. = ..()
	color = pick("#e6e5e5", "#2b292e", "#173266", "#6F0000", "#664357")

/obj/item/clothing/legwears/fishnet/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//garters

/obj/item/clothing/legwears/stockings_wg
	name = "stockings with garters"
	desc = "Stockings held up by delicate garters. A practical yet alluring design."
	icon_state = "stockings_wg"
	item_state = "stockings_wg"

/obj/item/clothing/legwears/stockings_wg/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_wg/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_wg/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_wg/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_wg/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//silk garters

/obj/item/clothing/legwears/silk_wg
	name = "silk stockings with garters"
	desc = "Silk stockings supported by fine garters. Favored by nobles and courtesans."
	icon_state = "silk_wg"
	item_state = "silk_wg"

/obj/item/clothing/legwears/silk_wg/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_wg/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_wg/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_wg/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_wg/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//stirrup

/obj/item/clothing/legwears/stockings_sir
	name = "stirrup stockings"
	desc = "Stockings with stirrups that hook under the foot for a tight fit."
	icon_state = "stockings_sir"
	item_state = "stockings_sir"

/obj/item/clothing/legwears/stockings_sir/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_sir/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_sir/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_sir/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/stockings_sir/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//silk stirrup

/obj/item/clothing/legwears/silk_sir
	name = "silk stirrup stockings"
	desc = "Silk stockings with stirrups, smooth and form-fitting."
	icon_state = "silk_sir"
	item_state = "silk_sir"

/obj/item/clothing/legwears/silk_sir/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_sir/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_sir/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_sir/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_sir/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//fishnet stirrup

/obj/item/clothing/legwears/fishnet_sir
	name = "fishnet stirrup stockings"
	desc = "Fishnet stockings fitted with stirrups. Bold and unapologetic."
	icon_state = "fishnet_sir"
	item_state = "fishnet_sir"

/obj/item/clothing/legwears/fishnet_sir/white
	color = "#e6e5e5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet_sir/black
	color = "#2b292e"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet_sir/blue
	color = "#173266"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet_sir/red
	color = "#6F0000"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/fishnet_sir/purple
	color = "#664357"
	misc_flags = CRAFTING_TEST_EXCLUDE

//pantyhose

/obj/item/clothing/legwears/thighs
	name = "pantyhose"
	desc = "Form-fitting pantyhose."
	icon_state = "thighs"
	item_state = "thighs"

/obj/item/clothing/legwears/silk_thighs
	name = "silk pantyhose"
	desc = "Smooth silk pantyhose."
	icon_state = "silk_thighs"
	item_state = "silk_thighs"

/obj/item/clothing/legwears/fishnet_thighs
	name = "fishnet pantyhose"
	desc = "Fishnet pantyhose."
	icon_state = "fishnet_thighs"
	item_state = "fishnet_thighs"

//crotchless pantyhose

/obj/item/clothing/legwears/thighs_cl
	name = "crotchless pantyhose"
	desc = "Pantyhose with an intentionally open design."
	icon_state = "thighs_cl"
	item_state = "thighs_cl"

/obj/item/clothing/legwears/silk_thighs_cl
	name = "silk crotchless pantyhose"
	desc = "Silk pantyhose with an intentionally open design."
	icon_state = "silk_thighs_cl"
	item_state = "silk_thighs_cl"

/obj/item/clothing/legwears/fishnet_thighs_cl
	name = "fishnet crotchless pantyhose"
	desc = "Fishnet pantyhose with an intentionally open design."
	icon_state = "fishnet_thighs_cl"
	item_state = "fishnet_thighs_cl"

//Mesh

/obj/item/clothing/legwears/stockings_mesh
	name = "mesh stockings"
	desc = "Snug mesh stockings."
	icon_state = "stockings_mesh_low"
	item_state = "stockings_mesh_low"

/obj/item/clothing/legwears/stockings_mesh_stirrup
	name = "stirrup mesh stockings"
	desc = "Snug mesh stockings with stirrups that hook under the foot for a tight fit."
	icon_state = "stockings_mesh_low_sir"
	item_state = "stockings_mesh_low_sir"

/obj/item/clothing/legwears/stockings_mesh_crotchless
	name = "crotchless mesh pantyhose"
	desc = "Snug mesh pantyhose with an intentionally open design."
	icon_state = "stockings_mesh_cl"
	item_state = "stockings_mesh_cl"

/obj/item/clothing/legwears/stockings_mesh_crotchless_stirrup
	name = "crotchless mesh pantyhose with stirrup"
	desc = "Snug mesh pantyhose with stirrups and an intentionally open design."
	icon_state = "stockings_mesh_sir_cl"
	item_state = "stockings_mesh_sir_cl"

//Priestess

/obj/item/clothing/legwears/priestess
	name = "priestess stockings"
	desc = "Pure white stockings adorned with delicate golden bands, worn by priestesses during rites and ceremonies."
	icon_state = "priestess"
	item_state = "priestess"
	misc_flags = CRAFTING_TEST_EXCLUDE

// Supply

/datum/supply_pack/rogue/wardrobe/suits
	group = "Stockings"

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

//Garters

/datum/supply_pack/rogue/wardrobe/suits/stockings_wg_white
	name = "White Stockings with Garters"
	cost = 15
	contains = list(
		/obj/item/clothing/legwears/stockings_wg/white,
		/obj/item/clothing/legwears/stockings_wg/white,
	)

/datum/supply_pack/rogue/wardrobe/suits/stockings_wg_white_silk
	name = "White Silk Stockings with Garters"
	cost = 35
	contains = list(
		/obj/item/clothing/legwears/silk_wg/white,
		/obj/item/clothing/legwears/silk_wg/white,
	)

// Craft

/datum/repeatable_crafting_recipe/sewing/stockings_white
	name = "stockings"
	output = /obj/item/clothing/legwears
	requirements = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/stockings_white_silk
	name = "silk stockings"
	output = /obj/item/clothing/legwears/silk
	requirements = list(/obj/item/natural/silk = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/stockings_white_fishnet
	name = "fishnet stockings"
	output = /obj/item/clothing/legwears/fishnet
	requirements = list(/obj/item/natural/fibers = 2)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/stockings_wg
	name = "stockings with garters"
	output = /obj/item/clothing/legwears/stockings_wg/white
	requirements = list(
		/obj/item/natural/cloth = 1,
		/obj/item/natural/fibers = 2
	)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/silk_stockings_wg
	name = "silk stockings with garters"
	output = /obj/item/clothing/legwears/silk_wg/white
	requirements = list(
		/obj/item/natural/silk = 1,
		/obj/item/natural/fibers = 2
	)
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/stockings_mesh
	name = "mesh stockings"
	output = /obj/item/clothing/legwears/stockings_mesh
	requirements = list(
		/obj/item/natural/cloth = 1,
		/obj/item/natural/fibers = 2
	)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/stockings_mesh/stirrup
	name = "stirrup mesh stockings"
	output = /obj/item/clothing/legwears/stockings_mesh_stirrup

/datum/repeatable_crafting_recipe/sewing/stockings_mesh/crotchless
	name = "crotchless mesh pantyhose"
	output = /obj/item/clothing/legwears/stockings_mesh_crotchless

/datum/repeatable_crafting_recipe/sewing/stockings_mesh/stirrup_crotchless
	name = "crotchless mesh pantyhose with stirrups"
	output = /obj/item/clothing/legwears/stockings_mesh_crotchless_stirrup

/datum/repeatable_crafting_recipe/sewing/thighs
	name = "pantyhose"
	output = /obj/item/clothing/legwears/thighs
	requirements = list(
		/obj/item/natural/cloth = 2,
		/obj/item/natural/fibers = 1
	)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/stockings_mesh/crotchless
	name = "crotchless pantyhose"
	output = /obj/item/clothing/legwears/thighs_cl

/datum/repeatable_crafting_recipe/sewing/silk_thighs
	name = "silk pantyhose"
	output = /obj/item/clothing/legwears/silk_thighs
	requirements = list(
		/obj/item/natural/silk = 2,
		/obj/item/natural/fibers = 1
	)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/silk_thighs/crotchless
	name = "crotchless silk pantyhose"
	output = /obj/item/clothing/legwears/silk_thighs_cl

/datum/repeatable_crafting_recipe/sewing/fishnet_thighs
	name = "fishnet pantyhose"
	output = /obj/item/clothing/legwears/fishnet_thighs
	requirements = list(
		/obj/item/natural/cloth = 1,
		/obj/item/natural/fibers = 2
	)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/fishnet_thighs/fishnet_thighs_cl
	name = "crotchless fishnet thighs"
	output = /obj/item/clothing/legwears/fishnet_thighs_cl

/datum/repeatable_crafting_recipe/sewing/stockings_white/stockings_wg
	name = "stockings with garter"
	output = /obj/item/clothing/legwears/stockings_wg

/datum/repeatable_crafting_recipe/sewing/stockings_white_silk/silk_wg
	name = "silk stockings with garter"
	output = /obj/item/clothing/legwears/silk_wg

/datum/repeatable_crafting_recipe/sewing/stockings_white/stockings_sir
	name = "stirrup stockings"
	output = /obj/item/clothing/legwears/stockings_sir

/datum/repeatable_crafting_recipe/sewing/stockings_white_silk/silk_sir
	name = "silk stirrup stockings"
	output = /obj/item/clothing/legwears/silk_sir

/datum/repeatable_crafting_recipe/sewing/stockings_white_fishnet/fishnet_sir
	name = "fisnet stirrup stockings"
	output = /obj/item/clothing/legwears/fishnet_sir

/datum/repeatable_crafting_recipe/sewing/stockings_mesh/stockings_mesh_crotchless
	name = "crotchless mesh pantyhose"
	output = /obj/item/clothing/legwears/stockings_mesh_crotchless
