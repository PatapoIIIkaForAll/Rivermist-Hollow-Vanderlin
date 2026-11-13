/* ------------------------------------------------------------------ */
/* Storage components                                                  */
/* ------------------------------------------------------------------ */

/datum/component/storage/concrete/grid/jewelry_box
	screen_max_columns = 2
	screen_max_rows = 3
	max_w_class = WEIGHT_CLASS_NORMAL
	/// show_to() hides the previous view of the same mob first; that hide must not shut the lid.
	var/reshowing = FALSE

/datum/component/storage/concrete/grid/jewelry_box/New(datum/P, ...)
	. = ..()
	set_holdable(cant_hold_list = list(/obj/item/grown/log))

/datum/component/storage/concrete/grid/jewelry_box/show_to(mob/M)
	reshowing = TRUE
	. = ..()
	reshowing = FALSE
	if(!. || !isliving(M))
		return
	var/obj/item/storage/jewelry_box/box = parent
	if(istype(box))
		box.set_viewed(TRUE)

/datum/component/storage/concrete/grid/jewelry_box/hide_from(mob/M)
	. = ..()
	if(reshowing || has_living_viewers())
		return
	var/obj/item/storage/jewelry_box/box = parent
	if(istype(box) && !QDELETED(box))
		box.set_viewed(FALSE)

/datum/component/storage/concrete/grid/jewelry_box/proc/has_living_viewers()
	for(var/mob/viewer as anything in can_see_contents())
		if(isliving(viewer))
			return TRUE
	return FALSE

/datum/component/storage/concrete/grid/jewelry_box/rich
	screen_max_columns = 1
	screen_max_rows = 2
	max_w_class = WEIGHT_CLASS_SMALL

/datum/component/storage/concrete/grid/kerchief
	screen_max_columns = 1
	screen_max_rows = 1
	max_w_class = WEIGHT_CLASS_SMALL
	rustle_sound = 'sound/foley/cloth_wipe (1).ogg'

/datum/component/storage/concrete/grid/kerchief/New(datum/P, ...)
	. = ..()
	set_holdable(cant_hold_list = list(/obj/item/grown/log))

/* ------------------------------------------------------------------ */
/* Large jewelry box                                                   */
/* ------------------------------------------------------------------ */

/obj/item/storage/jewelry_box
	name = "large jewelry box"
	desc = "A sturdy nailed box of planks. Heavy, but it keeps a lot safe."
	icon = 'modular_rmh/icons/obj/jewelry_boxes.dmi'
	icon_state = "jbox_big"
	base_icon_state = "jbox_big"
	item_weight = 900 GRAMS
	w_class = WEIGHT_CLASS_NORMAL
	grid_width = 64
	grid_height = 64
	resistance_flags = FLAMMABLE
	sellprice = 15
	component_type = /datum/component/storage/concrete/grid/jewelry_box
	/// TRUE while at least one living mob is looking inside.
	var/viewed = FALSE
	/// TRUE when the lid was flipped up by hand on an empty box, without looking inside.
	var/propped_open = FALSE
	/// Current lid position, derived from the two flags above.
	var/lid_open = FALSE
	/// Usage hint added to examine.
	var/examine_hint = "Middle-click to open or close the lid."

/obj/item/storage/jewelry_box/examine(mob/user)
	. = ..()
	if(examine_hint)
		. += span_info(examine_hint)

/obj/item/storage/jewelry_box/proc/set_viewed(new_state)
	viewed = new_state
	update_lid()

/obj/item/storage/jewelry_box/proc/set_propped_open(new_state)
	propped_open = new_state
	update_lid()

/obj/item/storage/jewelry_box/proc/update_lid()
	var/new_state = viewed || propped_open
	if(lid_open == new_state)
		return
	lid_open = new_state
	on_lid_changed()

/// The lid always sounds like a chest; rummaging inside rustles through the storage component.
/obj/item/storage/jewelry_box/proc/on_lid_changed()
	playsound(src, lid_open ? 'sound/misc/chestopen.ogg' : 'sound/misc/chestclose.ogg', 25, TRUE, -3)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/storage/jewelry_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][get_state_suffix()][isturf(loc) ? "_world" : ""]"

/obj/item/storage/jewelry_box/proc/get_state_suffix()
	if(!lid_open)
		return ""
	return length(contents) ? "_ajar" : "_open"

/obj/item/storage/jewelry_box/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(isturf(OldLoc) != isturf(loc))
		update_appearance(UPDATE_ICON_STATE)

/obj/item/storage/jewelry_box/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/item/storage/jewelry_box/Initialize(mapload, ...)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_CLICKEDON, PROC_REF(on_clicked))

/obj/item/storage/jewelry_box/proc/on_clicked(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(!LAZYACCESS(modifiers, MIDDLE_CLICK))
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICKED) || LAZYACCESS(modifiers, CTRL_CLICKED) || LAZYACCESS(modifiers, ALT_CLICKED))
		return
	if(!isliving(user) || user.next_move > world.time || user.incapacitated())
		return
	if(!user.CanReach(src))
		return
	user.changeNext_move(CLICK_CD_FAST)
	INVOKE_ASYNC(src, PROC_REF(middle_click_interact), user)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/storage/jewelry_box/proc/middle_click_interact(mob/living/user)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(!storage)
		return
	if(lid_open)
		set_propped_open(FALSE)
		if(user.active_storage == storage)
			storage.close(user)
		return
	if(!length(contents))
		set_propped_open(TRUE)
		return
	storage.user_show_to_mob(user)

/* ------------------------------------------------------------------ */
/* Rich jewelry box                                                    */
/* ------------------------------------------------------------------ */

/obj/item/storage/jewelry_box/rich
	name = "rich jewelry box"
	desc = "A dainty box lined with dyed cloth and dusted with gold. Simply holding it feels nice."
	icon_state = "jbox_rich"
	base_icon_state = "jbox_rich"
	item_weight = 500 GRAMS
	w_class = WEIGHT_CLASS_SMALL
	grid_width = 32
	grid_height = 64
	sellprice = 60
	component_type = /datum/component/storage/concrete/grid/jewelry_box/rich
	var/datum/weakref/carrier_ref

/obj/item/storage/jewelry_box/rich/Initialize(mapload, ...)
	. = ..()
	var/static/list/container_connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_container_moved),
	)
	AddComponent(/datum/component/connect_containers, src, container_connections)
	update_carrier()

/obj/item/storage/jewelry_box/rich/Destroy()
	var/mob/living/carbon/old_carrier = carrier_ref?.resolve()
	carrier_ref = null
	if(old_carrier)
		release_carrier(old_carrier)
	return ..()

/obj/item/storage/jewelry_box/rich/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	update_carrier()

/obj/item/storage/jewelry_box/rich/proc/on_container_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	update_carrier()

/obj/item/storage/jewelry_box/rich/proc/update_carrier()
	var/mob/living/carbon/new_carrier = recursive_loc_check(src, /mob/living/carbon)
	var/mob/living/carbon/old_carrier = carrier_ref?.resolve()
	if(new_carrier == old_carrier)
		return
	carrier_ref = new_carrier ? WEAKREF(new_carrier) : null
	if(old_carrier)
		release_carrier(old_carrier)
	new_carrier?.add_stress(/datum/stress_event/jewelry_box)

/obj/item/storage/jewelry_box/rich/proc/release_carrier(mob/living/carbon/old_carrier)
	if(QDELETED(old_carrier))
		return
	old_carrier.remove_stress(/datum/stress_event/jewelry_box)
	// The bonus does not stack, but another box still carried must keep it alive.
	for(var/obj/item/storage/jewelry_box/rich/other in old_carrier.get_all_contents())
		if(other != src && other.carrier_ref?.resolve() == old_carrier)
			old_carrier.add_stress(/datum/stress_event/jewelry_box)
			return

/datum/stress_event/jewelry_box
	stress_change = -1
	desc = span_green("I carry a lovely jewelry box.")

/* ------------------------------------------------------------------ */
/* Kerchief                                                            */
/* ------------------------------------------------------------------ */

/obj/item/storage/jewelry_box/kerchief
	name = "kerchief"
	desc = "A square of cloth, good for wrapping a small treasure or a bite to eat."
	icon_state = "kerchief"
	base_icon_state = "kerchief"
	item_weight = 10 GRAMS
	w_class = WEIGHT_CLASS_TINY
	grid_width = 32
	grid_height = 32
	sellprice = 4
	component_type = /datum/component/storage/concrete/grid/kerchief
	examine_hint = "Food wrapped in it spoils at half the usual pace."
	/// Wrapped food -> list(warming when wrapped, rotprocess when wrapped)
	var/list/wrapped_food
	/// TRUE while a dye color picker is open for this kerchief.
	var/dyeing = FALSE

/obj/item/storage/jewelry_box/kerchief/Destroy()
	for(var/obj/item/reagent_containers/food/snacks/food as anything in wrapped_food)
		unwrap_food(food)
	LAZYNULL(wrapped_food)
	return ..()

/obj/item/storage/jewelry_box/kerchief/examine(mob/user)
	. = ..()
	if(!length(contents))
		. += span_info("Middle-click it while holding dyes to dye it.")

/obj/item/storage/jewelry_box/kerchief/on_lid_changed()
	return

/obj/item/storage/jewelry_box/kerchief/get_state_suffix()
	return length(contents) ? "_tied" : ""

/obj/item/storage/jewelry_box/kerchief/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(istype(arrived, /obj/item/reagent_containers/food/snacks))
		wrap_food(arrived)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/storage/jewelry_box/kerchief/Exited(atom/movable/gone, direction)
	if(LAZYACCESS(wrapped_food, gone))
		unwrap_food(gone)
	return ..()

/obj/item/storage/jewelry_box/kerchief/proc/wrap_food(obj/item/reagent_containers/food/snacks/food)
	if(!food.rotprocess)
		return
	var/start_warming = food.warming || 0
	LAZYSET(wrapped_food, food, list(start_warming, food.rotprocess))
	food.rotprocess = food.rotprocess * 2 + start_warming

/obj/item/storage/jewelry_box/kerchief/proc/unwrap_food(obj/item/reagent_containers/food/snacks/food)
	var/list/saved = LAZYACCESS(wrapped_food, food)
	LAZYREMOVE(wrapped_food, food)
	if(!saved || !food.rotprocess)
		return
	var/start_warming = saved[1]
	var/lost = start_warming - (food.warming || 0)
	food.warming = start_warming - lost / 2
	food.rotprocess = saved[2]

/obj/item/storage/jewelry_box/kerchief/middle_click_interact(mob/living/user)
	var/obj/item/dye_pack/dye = user.get_active_held_item()
	if(!istype(dye))
		var/datum/component/storage/storage = GetComponent(/datum/component/storage)
		if(user.active_storage == storage)
			storage.close(user)
		else
			storage?.user_show_to_mob(user)
		return
	if(length(contents))
		to_chat(user, span_warning("I need to empty [src] before dyeing it."))
		return
	if(dyeing)
		return
	INVOKE_ASYNC(src, PROC_REF(start_dyeing), user, dye)

/obj/item/storage/jewelry_box/kerchief/proc/can_keep_dyeing(mob/living/user, obj/item/dye_pack/dye)
	if(QDELETED(src) || QDELETED(user) || QDELETED(dye))
		return FALSE
	if(user.get_active_held_item() != dye)
		return FALSE
	if(!user.CanReach(src))
		to_chat(user, span_warning("I am too far from [src]."))
		return FALSE
	if(length(contents))
		to_chat(user, span_warning("I need to empty [src] before dyeing it."))
		return FALSE
	return TRUE

/obj/item/storage/jewelry_box/kerchief/proc/start_dyeing(mob/living/user, obj/item/dye_pack/dye)
	dyeing = TRUE
	var/new_color = tgui_color_picker(user, "Choose a color for [src].", "Dyeing", color || "#FFFFFF", 1 MINUTES)
	dyeing = FALSE
	if(!new_color || !can_keep_dyeing(user, dye))
		return
	user.visible_message(span_notice("[user] starts dyeing [src]."), span_notice("I start dyeing [src]."))
	playsound(src, pick('sound/foley/waterwash (1).ogg', 'sound/foley/waterwash (2).ogg'), 50, FALSE)
	if(!do_after(user, 2 SECONDS, src))
		return
	if(!can_keep_dyeing(user, dye))
		return
	add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	qdel(dye)
	user.visible_message(span_notice("[user] dyes [src]."), span_notice("I dye [src]."))

/* ------------------------------------------------------------------ */
/* Nails                                                               */
/* ------------------------------------------------------------------ */

/obj/item/nails
	name = "handful of nails"
	desc = "A handful of iron nails."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "nails5"
	item_weight = 50 GRAMS
	w_class = WEIGHT_CLASS_TINY
	grid_width = 32
	grid_height = 32
	sellprice = 5

/datum/anvil_recipe/tools/iron/nails
	name = "Handful of Nails"
	recipe_name = "a handful of nails"
	created_item = /obj/item/nails
	craftdiff = 2

/* ------------------------------------------------------------------ */
/* Crafting                                                            */
/* ------------------------------------------------------------------ */

/datum/repeatable_crafting_recipe/crafting/jewelry_box
	name = "large jewelry box"
	category = "Containers"
	skillcraft = /datum/attribute/skill/craft/carpentry
	starting_atom = /obj/item/weapon/chisel
	attacked_atom = /obj/item/natural/wood/plank
	allow_inverse_start = FALSE
	tool_usage = list(
		/obj/item/weapon/chisel = list("carves the planks", "carve the planks"),
		/obj/item/weapon/hammer = list("hammers the nails in", "hammer the nails in", 'sound/foley/Building-01.ogg'),
	)
	output = /obj/item/storage/jewelry_box
	requirements = list(
		/obj/item/natural/wood/plank = 2,
		/obj/item/nails = 2,
	)
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/jewelry_box/rich
	name = "rich jewelry box"
	output = /obj/item/storage/jewelry_box/rich
	requirements = list(
		/obj/item/natural/wood/plank = 1,
		/obj/item/nails = 1,
		/obj/item/natural/cloth = 1,
		/obj/item/dye_pack/luxury = 1,
		/obj/item/alch/golddust = 1,
	)
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/kerchief
	name = "kerchief"
	output = /obj/item/storage/jewelry_box/kerchief
	requirements = list(
		/obj/item/natural/cloth = 2,
		/obj/item/natural/fibers = 2,
	)
	category = "Misc"
	craftdiff = 1

/* ------------------------------------------------------------------ */
/* SCOM rings take a single cell like every other ring                 */
/* ------------------------------------------------------------------ */

/obj/item/scomstone
	grid_width = 32
	grid_height = 32

/* ------------------------------------------------------------------ */
/* Prefilled variants with SCOM rings                                  */
/* ------------------------------------------------------------------ */

/obj/item/storage/jewelry_box/rich/crownstone
	populate_contents = list(
		/obj/item/scomstone/garrison,
	)

/obj/item/storage/jewelry_box/rich/handpin
	populate_contents = list(
		/obj/item/scomstone/garrison/hand,
	)

/obj/item/storage/jewelry_box/houndstones
	populate_contents = list(
		/obj/item/scomstone/bad/garrison,
		/obj/item/scomstone/bad/garrison,
		/obj/item/scomstone/bad/garrison,
		/obj/item/scomstone/bad/garrison,
		/obj/item/scomstone/bad/garrison,
		/obj/item/scomstone/bad/garrison,
	)

/obj/item/storage/jewelry_box/kerchief/serfstone
	populate_contents = list(
		/obj/item/scomstone/bad,
	)

/obj/item/storage/jewelry_box/kerchief/scomstone
	populate_contents = list(
		/obj/item/scomstone,
	)
