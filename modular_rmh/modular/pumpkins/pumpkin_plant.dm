// Pumpkin crop, whole pumpkin, wild patch and trade hooks, ported from Twilight-Axis.

#define PUMPKIN_CHUNKS 6

/datum/plant_def/pumpkin
	name = "pumpkin patch"
	desc = "Sprawling vines heavy with ripening gourds."
	icon = 'modular_rmh/modular/pumpkins/icons/pumpkin_crop.dmi'
	icon_state = "pumpkin"
	produce_type = /obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin
	uproot_loot = list(/obj/item/natural/fibers)
	produce_amount_min = 1
	produce_amount_max = 3
	maturation_time = 7 MINUTES
	plant_family = FAMILY_CUCURBIT
	nitrogen_requirement = 35
	phosphorus_requirement = 0
	potassium_requirement = 30
	nitrogen_production = 0
	phosphorus_production = 20
	potassium_production = 0
	seed_identity = "pumpkin seeds"

/datum/plant_def/pumpkin/set_genetic_tendencies(datum/plant_genetics/base_genetics)
	base_genetics.water_efficiency = TRAIT_GRADE_POOR
	base_genetics.cold_resistance = TRAIT_GRADE_GOOD

/obj/item/neuFarm/seed/pumpkin
	plant_def_type = /datum/plant_def/pumpkin

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin
	name = "pumpkin"
	desc = "The thick pumpkin rind shields a surprisingly dense fleshy interior."
	icon = 'modular_rmh/modular/pumpkins/icons/pumpkin_items.dmi'
	icon_state = "pumpkin"
	item_weight = 4 KILOGRAMS
	w_class = WEIGHT_CLASS_NORMAL
	grid_width = 64
	grid_height = 32
	seed = /obj/item/neuFarm/seed/pumpkin
	tastes = list("pumpkin" = 1)
	filling_color = "#d9761c"
	nutrition = VEGGIE_NUTRITION * PUMPKIN_CHUNKS
	slices_num = PUMPKIN_CHUNKS
	slice_path = /obj/item/reagent_containers/food/snacks/veg/pumpkin_sliced
	chopping_sound = TRUE
	rotprocess = SHELFLIFE_EXTREME
	sellprice = 3
	/// Cut open, so a spoon can scoop the flesh out.
	var/open = FALSE

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/update_icon_state()
	. = ..()
	icon_state = open ? "pumpkin-open" : "pumpkin"

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/examine(mob/user)
	. = ..()
	if(open)
		. += span_smallnotice("It is cut open. [slices_num] chunk\s of flesh remain inside.")

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click it with a small blade to cut the top open, then scoop the flesh out with a spoon. The empty shell can be carved.")
	. += span_info("Left-click it with a small blade on a table to chop it into slices; the shell and seeds are lost.")
	. += span_info("Smash it with a blunt intent to get its seeds.")

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/canconsume(mob/eater, mob/user, silent = FALSE)
	if(!silent)
		to_chat(user, span_warning("[src] is far too big to bite into. I should cut it up first."))
	return FALSE

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/kitchen/spoon) && !user.cmode)
		if(!open)
			to_chat(user, span_warning("I need to cut [src] open first."))
			return ITEM_INTERACT_BLOCKING
		scoop(user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(open || user.cmode || !tool.get_sharpness() || tool.wlength != WLENGTH_SHORT)
		return ..()
	if(!do_after(user, 0.5 SECONDS, src) || open)
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/foley/slicing.ogg', 60, TRUE, -1)
	open = TRUE
	update_appearance(UPDATE_ICON_STATE)
	user.visible_message(span_notice("[user] cuts the top off [src]."), span_notice("I cut the top off [src]."))
	return ITEM_INTERACT_SUCCESS

/// Takes one chunk of flesh out; the last chunk leaves the shell and the seeds behind.
/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/proc/scoop(mob/living/user)
	if(!do_after(user, 0.5 SECONDS, src) || QDELETED(src) || slices_num <= 0)
		return
	var/turf/location = get_turf(src)
	playsound(location, 'sound/foley/slicing.ogg', 50, TRUE, -1)
	var/obj/item/reagent_containers/food/snacks/chunk = new slice_path(location)
	initialize_slice(chunk, reagents.total_volume / slices_num)
	slices_num--
	user.visible_message(span_notice("[user] scoops a chunk of flesh out of [src]."), span_notice("I scoop a chunk of flesh out of [src]."))
	if(slices_num > 0)
		return
	new /obj/item/pumpkinshell(location)
	drop_seeds(location)
	qdel(src)

/// Same odds as smashing produce for seeds.
/obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin/proc/drop_seeds(turf/location)
	if(!seed || prob(5))
		return
	playsound(location, 'sound/items/seedextract.ogg', 100, FALSE)
	new seed(location, source_genetics)
	if(prob(90))
		new seed(location, source_genetics)
	if(prob(23))
		new seed(location, source_genetics)
	if(prob(6))
		new seed(location, source_genetics)

/obj/structure/flora/grass/pumpkin
	name = "bunch of wild pumpkins"
	desc = "Wild pumpkins overgrown with vines."
	icon = 'modular_rmh/modular/pumpkins/icons/pumpkin_items.dmi'
	icon_state = "wildpumpkin1"
	base_icon_state = "wildpumpkin"
	num_random_icons = 2
	bonus_loot = list(/obj/item/natural/fibers)

/obj/structure/flora/grass/pumpkin/Initialize()
	. = ..()
	if(prob(88))
		bushtype = /obj/item/neuFarm/seed/pumpkin
	grass_replenish_loot()
	if(prob(10))
		looty += /obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin
	pixel_x += rand(-3, 3)
	pixel_y += rand(0, 6)

/datum/supply_pack/seeds/pumpkin
	name = "Pumpkin"
	cost = 3
	contains = /obj/item/neuFarm/seed/pumpkin

/datum/stock/stockpile/pumpkin
	name = "Pumpkins"
	desc = "Heavy gourds, good for pies, soups and lanterns."
	item_type = /obj/item/reagent_containers/food/snacks/produce/vegetable/pumpkin
	held_items = 2
	payout_price = 3
	withdraw_price = 8
	export_price = 6
	importexport_amt = 10
	stockpile_id = STOCK_FOOD

#undef PUMPKIN_CHUNKS
